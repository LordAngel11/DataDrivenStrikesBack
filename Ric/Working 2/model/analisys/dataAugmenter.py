import sys
import getopt
import pandas as pd
import numpy as np
import pickle

# -------- GLOBAL VARIABLES --------

TO_AUGMENT = [
    'Número de estacionamiento',
    'Depósitos',
    'Edad'
]

# ----------------------------------


def parse_args(argv):
	generator_options = dict()

	try:
		opts, args = getopt.getopt(argv, "f:", ["file-name="])
	except getopt.GetoptError:
		print("Missing agrs")
		sys.exit(2)

	for opt, arg in opts:
		if opt in ("-f", "--file-name"):
			generator_options['filename'] = arg

	if generator_options['filename'] is None:
		print("Invalid args. Missing filename to augment.")
		sys.exit(2)

	return generator_options


def augmentDataFrame(df_filename):
	raw_data_master = pd.read_excel(df_filename, header=[0])
	raw_data_augment = raw_data_master.copy()

	# -------- GENERATE AREA_CODES --------
	raw_data_augment.insert(0, 'Area code', np.zeros(raw_data_augment.shape[0], dtype=str))
	area_data = dict()
	ac_dict = dict()


	for dep_id, dep in enumerate(raw_data_master['Departamento'].unique()):
		dep_select = raw_data_master[raw_data_master['Departamento'] == dep]

		for prod_id, prov in enumerate(dep_select['Provincia'].unique()):
			prov_select = dep_select[dep_select['Provincia'] == prov]

			for dist_id, dist in enumerate(prov_select['Distrito'].unique()):

				query = raw_data_master[(raw_data_master['Departamento'] == dep) &
										(raw_data_master['Provincia'] == prov) &
										(raw_data_master['Distrito'] == dist)]
				area_code = str(dep_id) + '-' + str(prod_id) + '-' + str(dist_id)
				code_list = raw_data_augment['Area code'].to_numpy()
				code_list[query.index] = area_code
				raw_data_augment['Area code'] = code_list

				area_data[(dep,prov,dist)] = {}
				ac_dict[area_code] = (dep,prov,dist)

    # -------- CORRECTING AGES --------
	ages = raw_data_augment['Edad'].to_numpy()
	dates = raw_data_augment['Fecha entrega del Informe'].to_numpy()

	for i, age in enumerate(ages):
		if age >= 1000:
			ages[i] = np.round(((dates[i] - pd.Timestamp(ages[i])).days)/365.0)
    
	raw_data_augment['Edad'] = ages

	# -------- AUGMENT "WELL-INFORMED" VARIABLES --------
	for augment_dim in TO_AUGMENT:
		for area_code in raw_data_augment['Area code'].unique():
			if area_code == '': continue

			query = raw_data_augment[raw_data_augment['Area code'] == area_code]

			to_augment_array = np.array([val.replace(',','') if isinstance(val, str) else val for val in query[augment_dim].to_list()], dtype=np.float32)
			to_augment_array = np.nan_to_num(to_augment_array, nan = -1)

			augment_mean = np.round(np.mean(to_augment_array[to_augment_array != -1])) if to_augment_array[to_augment_array != -1].shape[0] > 0 else 0
			to_augment_array[to_augment_array == -1] = augment_mean

			area_data[ac_dict[area_code]][augment_dim] = augment_mean

			full_array = raw_data_augment[augment_dim].to_numpy()
			full_array[query.index] = to_augment_array

			raw_data_augment[augment_dim] = full_array

	raw_data_augment['Área Terreno'] = raw_data_augment['Área Terreno'].fillna(0.0)
	raw_data_augment['Área Construcción'] = raw_data_augment['Área Construcción'].fillna(0.0)

	# -------- GENERATE EXTRA METRICS --------
	raw_data_augment.insert(raw_data_augment.shape[1]-2, 'Precio promedio m2 (Terreno)', np.zeros(raw_data_augment.shape[0], dtype=str))
	raw_data_augment.insert(raw_data_augment.shape[1]-2, 'Precio promedio m2 (Construcción)', np.zeros(raw_data_augment.shape[0], dtype=str))

	for area_code in raw_data_augment['Area code'].unique():
		if area_code == '': continue

		query = raw_data_augment[raw_data_augment['Area code'] == area_code]

		build_area_array = np.array([val.replace(',','') if isinstance(val, str) else val for val in query['Área Construcción'].to_list()], dtype=np.float64)
		plot_area_array = np.array([val.replace(',','') if isinstance(val, str) else val for val in query['Área Terreno'].to_list()], dtype=np.float64)
		
		price_array = np.array([val.replace(',','') if isinstance(val, str) else val for val in query['Valor comercial'].to_list()], dtype=np.float64)

		build_area_array = np.nan_to_num(build_area_array, nan=-1)
		build_area_array[build_area_array == 0] = -1
		plot_area_array = np.nan_to_num(plot_area_array, nan=-1)
		plot_area_array[plot_area_array == 0] = -1

		sqrt_m_bval = price_array/build_area_array
		sqrt_m_bval = sqrt_m_bval[sqrt_m_bval >= 0]

		sqrt_m_pval = price_array/plot_area_array
		sqrt_m_pval = sqrt_m_pval[sqrt_m_pval >= 0]

		bval_mean = np.round(np.mean(sqrt_m_bval)) if sqrt_m_bval.shape[0] > 0 else 0
		pval_mean = np.round(np.mean(sqrt_m_pval)) if sqrt_m_pval.shape[0] > 0 else 0

		area_data[ac_dict[area_code]]['Precio promedio m2 (Construcción)'] = bval_mean
		area_data[ac_dict[area_code]]['Precio promedio m2 (Terreno)'] = pval_mean

		avg_bval_list = raw_data_augment['Precio promedio m2 (Construcción)'].to_numpy()
		avg_pval_list = raw_data_augment['Precio promedio m2 (Terreno)'].to_numpy()
		avg_bval_list[query.index] = bval_mean
		avg_pval_list[query.index] = pval_mean
		raw_data_augment['Precio promedio m2 (Construcción)'] = avg_bval_list
		raw_data_augment['Precio promedio m2 (Terreno)'] = avg_pval_list

	raw_data_augment = raw_data_augment.drop('Area code', axis = 1)
	raw_data_augment.to_excel(df_filename[:-5]+'_augmented.xlsx', index=False)

	f = open(df_filename[:-5]+'_augmentation.pkl', 'wb')
	pickle.dump(area_data,f)
	f.close()

if __name__ == '__main__':
	options = parse_args(sys.argv[1:])
	augmentDataFrame(options["filename"])

	print("Data augmented successfully!!")
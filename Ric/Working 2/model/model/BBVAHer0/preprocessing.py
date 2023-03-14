# ---- Standard imports ----
import numpy as np
from sklearn.preprocessing import OrdinalEncoder

# ---- Imports from modules ----
import BBVAHer0.const as const

def sanitize(raw_data, training = False, region = None):
    #if region is not None:
    raw_data = raw_data[raw_data['Provincia'] == 'Lima']

    processed_data = raw_data.iloc[:,[5,8,9,10,13,17,18,19]].fillna(0.0)
    processed_data = processed_data.replace(const.GOOD_CAT).replace(const.CONSERVATION)
    processed_data.columns = const.COLNAMES
    
    dist_encod = OrdinalEncoder()
    enc = dist_encod.fit_transform(processed_data[['Distrito','Valorcomercial']].to_numpy())
    processed_data.Distrito = enc.T[0]

    processed_data = processed_data.applymap(lambda x : float(x.replace(',','')) if isinstance(x,str) else x)

    ground_truth = processed_data.Valorcomercial.to_numpy() if training else None

    processed_data = processed_data.applymap(lambda x : np.cbrt(x + const.EPSILON))
    return processed_data, ground_truth
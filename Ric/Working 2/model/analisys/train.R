#Analisis epxloratorio de los datos 

#Para esto llamamos a todas las librerias

library(readxl)
library(stats)
library(plyr)
library(dplyr)
library(ggbiplot)
library(ggplot2)
library(ggcorrplot)
library(GGally)
library(pca3d)
library(rgl)
library(graphics)
library(pls)
library(writexl)

################# Leeeeemos la base de datos ########################################3
dabase <- read_xlsx("/home/lordangel11/Documentos/Sample/ord80p.xlsx",col_names = FALSE)

head(dabase)

sapply(dabase,class)
###############

dataframe <- as.data.frame(dabase)

dataframe <- subset(dataframe, select = c("...1","...2","...5","...6","...7", "...11", "...12", "...13", "...14", "...15", "...16", "...17", "...18", "...19","...20"))


dataframe <- dataframe[!(row.names(dataframe) %in% c("1")),]


#Renombramos las variables-----------------
colnames(dataframe)[1] = "FechadelInforme"
colnames(dataframe)[2] = "TipodeVia"
#colnames(dataframe)[3] = "Piso"
#colnames(dataframe)[4] = "Departamento"
colnames(dataframe)[3] = "Provincia"
colnames(dataframe)[4] = "Distrito"
colnames(dataframe)[5] = "Estacionamiento"
#colnames(dataframe)[4] = "Depositos"
#colnames(dataframe)[6] = "Latitud"
#colnames(dataframe)[7] = "Longitud"
colnames(dataframe)[6] = "Categoriadelbien"
colnames(dataframe)[7] = "Posicion"
colnames(dataframe)[8] = "Numerodefrentes"
colnames(dataframe)[9] = "Edad"
colnames(dataframe)[10] = "Elevador"
colnames(dataframe)[11] = "Estadodeconservacion"
colnames(dataframe)[12] = "MetodoRepresentado"
colnames(dataframe)[13] = "Areaterreno"
colnames(dataframe)[14] = "Areaconstruccion"
colnames(dataframe)[15] = "Valorcomercial"
#--------------------------------------------

dataframe[is.na(dataframe)] <- 0


#                 COERCION DE DATOS CATEGORIA DEL BIEN             #

dataframe$Categoriadelbien <- as.character(dataframe$Categoriadelbien)

dataframe[dataframe == "Local Comercial"] <- "1"
dataframe[dataframe == "Departamento"] <- "2"
dataframe[dataframe == "Vivienda Unifamiliar"] <- "3"
dataframe[dataframe == "Industria"] <- "4"
dataframe[dataframe == "Estacionamiento/depósito (U.I.)"] <- "5"
dataframe[dataframe == "AVALUOS_TIPOS_INMUEBLE_VEHICULO"] <- "6"
dataframe[dataframe == "Intitución Educativa"] <- "7"
dataframe[dataframe == "Terreno Urbano"] <- "8"
dataframe[dataframe == "Almacén /Taller"] <- "9"
dataframe[dataframe == "Oficina"] <- "10"
dataframe[dataframe == "Hotel"] <- "11"
dataframe[dataframe == "Fundo Agrícola"] <- "12"


#                      COERCION DE DATOS ESTADO DE CONSERVACION                        #

dataframe$Estadodeconservacion <- as.character(dataframe$Estadodeconservacion)

dataframe[dataframe == "En proyecto"] <- "1"
dataframe[dataframe == "En construcción"] <- "2"
dataframe[dataframe == "Regular"] <- "3"
dataframe[dataframe == "Bueno"] <- "4"
dataframe[dataframe == "Muy bueno"] <- "5"


#                    COERCION DE DATOS DE METODOS                  #

dataframe[dataframe == "Costos o reposición (directo)"] <- "1"
dataframe[dataframe == "Comparación de mercado (directo)"] <- "2"
dataframe[dataframe == "Renta o capitalización (indirecto)"] <- "3"


#Top 3 distrtos
dataframeLima <- dataframe[grepl("Lima", dataframe$Distrito),]
dataframeSJL <- dataframe[grepl("San Juan de Lurigancho", dataframe$Distrito),]
dataframeSMP <- dataframe[grepl("San Martín de Porres", dataframe$Distrito),]


write_xlsx(dataframeSJL,'/home/lordangel11/Documentos/Sample/SJL.xlsx')
write_xlsx(dataframeLima,'/home/lordangel11/Documentos/Sample/Lima.xlsx')
write_xlsx(dataframeSMP,'/home/lordangel11/Documentos/Sample/SMP.xlsx')

#Top 5 provincias:
#Arequipá
#Trujillo
#Lima
#Prof coan de cayao
#chiclayo

dataframeArequipa <- dataframe[grepl("Arequipa", dataframe$Provincia),]
dataframeTrujillo <- dataframe[grepl("Trujillo", dataframe$Distrito),]
dataframeLimaprov <- dataframe[grepl("Lima", dataframe$Distrito),]
dataframecayao <- dataframe[grepl("Prov. Const. del Callao", dataframe$Distrito),]
daraframechivlavo <- dataframe[grepl("Chiclayo", dataframe$Distrito),]

write_xlsx(dataframeArequipa,'/home/lordangel11/Documentos/Sample/Arequipa.xlsx')
write_xlsx(dataframeTrujillo,'/home/lordangel11/Documentos/Sample/Trujillo.xlsx')

write_xlsx(dataframeLimaprov,'/home/lordangel11/Documentos/Sample/LimaPROV.xlsx')
write_xlsx(dataframecayao,'/home/lordangel11/Documentos/Sample/cayao.xlsx')
write_xlsx(daraframechivlavo,'/home/lordangel11/Documentos/Sample/chivlavo.xlsx')


eps <- 0.000001

dataframe[is.na(dataframe)] <- 0+eps

dataframe[dataframe == 0] <- 0+eps


dataframe <- data.frame(lapply(dataframe, function(x) as.numeric(as.character(x))))

str(dataframe)

#write_xlsx(dataframe,'/home/lordangel11/Documentos/Sample/Lima.xlsx')


logarithmic <- function(x){
  x <- log10(x)
  return(x)
}


dataframe <- logarithmic(dataframe)

dataframe[is.na(dataframe)] <- 0+eps
dataframe[dataframe == -Inf] <- 0


head(dataframe)

dataframe.pca <- prcomp(dataframe, scale. = TRUE, center = TRUE)

dataframe.pca

summary(dataframe.pca)

#Para esto tenemos

loadings(dataframe.pca)


loading.weights(dataframe.pca)

#PCA Sobre el valor comercial...
dataframe.pca.plot <- autoplot(dataframe.pca, data = dataframe, colour = "Valorcomercial")

dataframe.pca.plot

plot3d(dataframe.pca$x, col= dataframe$Valorcomercial)


biplot.dataframe.pca <- biplot(dataframe.pca, scale = TRUE)

#Fit the model
model <- pcr(Valorcomercial~+Areaterreno+Areaconstruccion+FechadelInforme+Categoriadelbien+Edad+Elevador+MetodoRepresentado+Depositos+TipodeVia+Piso, data=dataframe, scale = TRUE, validation="CV")


summary(model)

validationplot(model)

validationplot(model,val.type = "MSEP")

validationplot(model, val.type = "R2")



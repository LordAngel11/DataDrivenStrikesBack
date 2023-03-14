#Analisis epxloratorio de los datos 

#Para esto llamamos a todas las librerias

library(readxl)
library(tidyverse)
library(stats)
library(priceR)
library(plyr)
library(dplyr)
library(ggbiplot)
library(ggplot2)
library(ggcorrplot)
library(GGally)
library(ggfortify)
library(pca3d)
library(rgl)

dabase <- read_xlsx("data/ord80p.xlsx",col_names = FALSE)

head(dabase)

sapply(dabase,class)

#Vamos a hacer una copia segura del dataframe
dataframe <- as.data.frame(dabase)

dataframe <- dataframe[!(row.names(dataframe) %in% c("1")),]

str(dataframe)

dataframeRUIDO <- 

dataframe <- subset(dataframe, select = c("...7","...8","...14","...15","...18","...19","...20"))

dataframe <- data.frame(lapply(dataframe, function(x) as.numeric(as.character(x))))

dataframe[is.na(dataframe)] <- 0

#Rename
colnames(dataframe)[1] = "Estacionamientos"
colnames(dataframe)[2] = "Depositos"
colnames(dataframe)[3] = "Edad"
colnames(dataframe)[4] = "Elevador"
colnames(dataframe)[5] = "AreaTerreno"
colnames(dataframe)[6] = "Areaconstruccion"
colnames(dataframe)[7] = "Valorcomercial"

eps <- 0.0000001

logarithmic <- function(x){
  x <- log10(x+eps)
  return(x)
}

dataframe <- logarithmic(dataframe)

head(dataframe)

dataframe.pca <- prcomp(dataframe, center = TRUE, scale. = TRUE)

dataframe.pca

summary(dataframe.pca)

#Estacionamientos
dataframe.pca.plot <- autoplot(dataframe.pca, data = dataframe, colour = "Estacionamientos")

dataframe.pca.plot

#Depositos

dataframe.pca.plot <- autoplot(dataframe.pca, data = dataframe, colour = "Depositos")

dataframe.pca.plot

#Edad

dataframe.pca.plot <- autoplot(dataframe.pca, data = dataframe, colour = "Edad")

dataframe.pca.plot


#Elevador

dataframe.pca.plot <- autoplot(dataframe.pca, data = dataframe, colour = "Elevador")

dataframe.pca.plot


#AreadeTerreno

dataframe.pca.plot <- autoplot(dataframe.pca, data = dataframe, colour = "AreaTerreno")

dataframe.pca.plot

#Area de Construcción

dataframe.pca.plot <- autoplot(dataframe.pca, data = dataframe, colour = "Areaconstruccion")

dataframe.pca.plot

#Valorcomercial

dataframe.pca.plot <- autoplot(dataframe.pca, data = dataframe, colour = "Valorcomercial")

dataframe.pca.plot

plot3d(dataframe.pca$x, col= dataframe$Valorcomercial)

dim(dataframe)

#Vectores proyectados sobre el 2D del plano.
biplot.dataframe.pca <- biplot(dataframe.pca)

biplot.dataframe.pca

dataframe.pca.plot



datas <- subset(dataframe, select = c("...2","...7","...8","...14","...15","...18","...19","...20"))




sapply(dabase,class)

#AHora una vez que tenemos el dataframe con las 10 variables de interes vamos a 

dataframe <- data.frame(lapply(dataframe, function(x) as.numeric(as.character(x)))) #A yes xD

#Y ahora todas las variables de interes son datos numericos.
sapply(dataframe, class)


#A partir de esto se tiene que:

summary(dataframe)

df1 <- dataframe

#Rename dataframe
######################################
################################## 

cor = round(cor(finaldf),1)

cor(finaldf)

ggcorrplot(cor(df1))


#Ahora a hacer el analisis de componentes...

datacomp <- df1[,1:8] 

respca <- prcomp(datacomp, scale = TRUE)
names(respca)
head(respca$rotation)[, 1:8]

summary(respca)

ggbiplot::ggbiplot(respca, choices = c(1,2))

respca1 <- princomp(datacomp,cor = TRUE)

#Otra vision del PCA

dataframe.pca <- prcomp(dataframe,center = TRUE,scale. = TRUE) 

summary(dataframe.pca)

str(dataframe.pca)

dataframe.pca.plot

# ggbiplot::ggbiplot(respca1, choices = c(1,2))

ggpairs(df1)
pairs(df1)
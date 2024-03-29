# Dados de consumo anual de água por classe em Salvador 
# Data criacao 01/9/2021
# Tabela de dados obtida do site 
# http://sim.sei.ba.gov.br/metaside/consulta/frame_metadados.wsp?tmp.tabela=t128

######################################################
# 1) Carregar bibliotecas

library(tidyverse)
library(magrittr)
library(dplyr)
library(readr)
library(rjson)
library(RJSONIO)
library("readxl")
# Library para importar dados SQL
#library(DBI)
#library(RMySQL)

#library(pool)
#library(sqldf)
#library(RMariaDB)

# Carragamento de banco de dados

# Settings
#db_user <-'admin'
#db_password <-'password'
#db_name <-'cdnaep'
#db_table <- 'your_data_table'
#db_host <-'127.0.0.1' # for local access
#db_port <-3306

# 3. Read data from db
# drv=RMariaDB::MariaDB(),
#mydb <-  dbConnect(drv =RMariaDB::MariaDB(),user =db_user, 
#                   password = db_password ,
#                   dbname = 'cdnaep', host = db_host, port = db_port)
#
#dbListTables(mydb)

#s <- paste0("SELECT * from", " consumo_agua")
#rs<-NULL
#rs <- dbSendQuery(mydb, s)

#dados<- NULL
#dados <-  dbFetch(rs, n = -1)
#dados
#dbHasCompleted(rs)
#dbClearResult(rs)
library(readxl)
dados <- read_excel("data/t128.xlsx")
names(dados)
dados %<>% mutate(dados, `Comercial` = `Comercial`/1000)
# Temas Subtemas Perguntas
dados <- dados %>% mutate(across(`Comercial`, ~round(.x,1)))
##  Perguntas e titulos 
T_ST_P_No_MEIOAMBIENTE <- read_csv("data/TEMA_SUBTEMA_P_No - MEIOAMBIENTE.csv")


## Arquivo de saida 

SAIDA_POVOAMENTO <- T_ST_P_No_MEIOAMBIENTE %>% 
                    select(TEMA,SUBTEMA,PERGUNTA,NOME_ARQUIVO_JS)
SAIDA_POVOAMENTO <- as.data.frame(SAIDA_POVOAMENTO)

#classes <- NULL
#classes <- levels(as.factor(dados$classe))

# Cores secundarias paleta pantone -
corsec_recossa_azul <- c('#175676','#62acd1','#8bc6d2','#20cfef')

#for ( i in 1:length(classes)) {
  
  objeto_0 <- dados %>%
#        filter(classe %in% c(classes[i])) %>%
    select(Ano,Comercial) %>% filter(Ano>2000) %>%
    arrange(Ano) %>%
    mutate(Ano = as.character(Ano)) %>% list()               
  
  exportJson0 <- toJSON(objeto_0)
  
  
  titulo<-T_ST_P_No_MEIOAMBIENTE$TITULO[1]
  subtexto<-"SEI"
  link <-"http://sim.sei.ba.gov.br/metaside/consulta/frame_metadados.wsp?tmp.tabela=t128" 
  
  data_axis <- paste('[',gsub(' ',',',
                               paste(paste(as.vector(objeto_0[[1]]$Ano)),
                                     collapse = ' ')),']',sep = '')
  
  data_serie <- paste('[',gsub(' ',',',
                               paste(paste(as.vector(objeto_0[[1]]$Comercial)),
                                     collapse = ' ')),']',sep = '')
  
  texto<-paste('{"title":{"text":"',titulo,
               '","subtext":"',subtexto,
               '","sublink":"',link,'"},',
               '"tooltip":{"trigger":"item","responsive":"true","position":"top","formatter":"{c0} M"},',
               '"toolbox":{"left":"center","orient":"horizontal","itemSize":20,"top":20,"show":true,',
               '"feature":{"dataZoom":{"yAxisIndex":"none"},',
               '"dataView":{"readOnly":false},"magicType":{"type":["line","bar"]},',
               '"restore":{},"saveAsImage":{}}},"xAxis":{"type":"category",',
               '"data":',data_axis,'},',
               '"yAxis":{"type":"value","axisLabel":{"formatter":"{value} M"}},',
               '"graphic":[{"type":"text", "left":"center","top":"bottom","z":100, "style":{"fill":"gray","text":"Obs: Ponto é separador decimal", "font":"8px sans-srif","fontSize":12}}],',
               '"series":[{"data":',data_serie,',',
               '"type":"bar","color":"',corsec_recossa_azul[1],'","showBackground":true,',
               '"backgroundStyle":{"color":"rgba(180, 180, 180, 0.2)"},',
               '"itemStyle":{"borderRadius":10,"borderColor":"',corsec_recossa_azul[1],'","borderWidth":2}}]}',sep='')
  
#  SAIDA_POVOAMENTO$CODIGO[i] <- texto   
  texto<-noquote(texto)
 
  
  write(exportJson0,file = paste('data/',gsub('.csv','',T_ST_P_No_MEIOAMBIENTE$NOME_ARQUIVO_JS[1]),
                                 '.json',sep =''))
  write(texto,file = paste('data/',T_ST_P_No_MEIOAMBIENTE$NOME_ARQUIVO_JS[1],
                           sep =''))
  
#}

# Arquivo dedicado a rotina de atualizacao global. 

write_csv2(SAIDA_POVOAMENTO,file ='data/POVOAMENTO.csv',quote='all',escape='none')
#quote="needed")#,escape='none')


objeto_autm <- SAIDA_POVOAMENTO %>% list()
exportJson_aut <- toJSON(objeto_autm)

#write(exportJson_aut,file = paste('data/povoamento.json'))



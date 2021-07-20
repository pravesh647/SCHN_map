library(dplyr)
library(stringr)
library(gsheet)

setwd("~/Sites/SCHN_map")
getwd()

# ??gsheet
# install.packages("googlesheets4")
# library(googlesheets4)

# Reading SCHN directory
directory <- gsheet::gsheet2tbl("https://docs.google.com/spreadsheets/d/1Im81MD2ABH2E39vWV1HzoXsyXjVlE0B6XzDJeq3AglQ/edit?usp=sharing")

colnames(directory) <- str_trim(tolower(colnames(directory)))
colnames(directory)

directory <- directory %>% 
  rename(email = `point of contact email`,
         firstName = `first name`,
         lastName = `full name`,
         services = `general services`,
         findhelp_status = `findhelp status`,
         findhelp_site = `findhelp site`,
         workshop_attendance = `large workshop attendance`)

directory <- directory %>% 
  mutate(zipcode = str_trim(substr(address, str_length(address)-5, str_length(address))),
         state = str_trim(substr(address, str_length(address)-8, str_length(address)-6)),
         street = NA,
         city = NA
  )

directory <- directory[-c(27, 28, 43),]

# Writing the data into file
writexl::write_xlsx(directory, "datasets/schn_directory.xlsx")

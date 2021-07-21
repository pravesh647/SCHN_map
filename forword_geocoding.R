library(gsheet)
library(dplyr)
library(stringr)
library(tidygeocoder)


# setwd("~/Sites/SCHN_map/SCHN_Map")
getwd()

# Importing data to rstudio 
# directory <- readxl::read_xlsx("datasets/schn_directory.xlsx")
directory <- gsheet::gsheet2tbl("https://docs.google.com/spreadsheets/d/1ZLoZhr4SCBctABODSzCLjp_ZUxuUl1-4/edit#gid=529283017")
location_data <- readxl::read_xlsx("datasets/location_database.xlsx")

# Isolating new observations

# Selection only relevant address
directory <- directory %>%
  select(street, city, state)

# Removing any observations that has missing address
if(anyNA(directory$street)){
  directory <- directory[ -which(is.na(directory$street))  ,]
}

if(anyNA(directory$city)){
  directory <- directory[ -which(is.na(directory$city))  ,]
}

if(anyNA(directory$state)){
  directory <- directory[ -which(is.na(directory$state))  ,]
}

# Joining location_data to the left of directory data
directory <- left_join(directory, location_data, by=c("street", "city", "state"))

# Removing any observations from directory data that already has a geo-location
if(anyNA(directory$lat)){
  directory <- directory[ which(is.na(directory$lat))  ,]
}

if(anyNA(directory$long)){
  directory <- directory[ which(is.na(directory$long))  ,]
}

# End of isolation of new observations ----------------------

if(anyNA(directory$lat)){
  # Forward geo coding the physical address
  
  directory <- directory %>% 
    mutate(address = paste0(street, ', ', city, ' ', state)) %>% 
    geocode(address, lat = lat, long = long, method = "arcgis", ) %>% 
    select(-address, -lat...4, -long...5) %>% 
    rename(lat = lat...7,
           long = long...8)
  
  location_data <- rbind(location_data, directory)
  # 
  # ----------------------------------------------------------------------------
  
  # exporting the data
  writexl::write_xlsx(location_data, "datasets/location_database.xlsx")

}

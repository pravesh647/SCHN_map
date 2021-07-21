#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(shinydashboard)
library(leaflet)
library(gsheet)
library(dplyr)
library(stringr)

source("forword_geocoding.R")

directory <- gsheet::gsheet2tbl("https://docs.google.com/spreadsheets/d/1ZLoZhr4SCBctABODSzCLjp_ZUxuUl1-4/edit#gid=529283017")
location_data <- readxl::read_xlsx("datasets/location_database.xlsx")
getwd()


# Define UI for application

# Header of the App---------------------------------
header <- dashboardHeader(
    title = "SCHN Map"
)

?dashboardSidebar
# SideBar of the App---------------------------------
sidebar <- dashboardSidebar(
    disable = TRUE
)

# Body of the app---------------------------------
body <- dashboardBody(
    fluidRow(
        width = "100%",
        leafletOutput("directoryMapPlot", height = "90vh"),
    )
)


ui <- dashboardPage(header, sidebar, body)


# Define server logic required to draw a histogram
server <- function(input, output) {
    
    output$directoryMapPlot <- renderLeaflet({
        directory %>%
            mutate(address = paste0(street, ', ', city, ' ', state) ) %>% 
            
            left_join(location_data, by = c("street", "city", "state")) %>% 
            leaflet() %>% 
            # Base Groups
            addTiles(group = "OSM (default)") %>%
            addProviderTiles(providers$Stamen.Toner, group = "Toner") %>%
            addProviderTiles(providers$Stamen.TonerLite, group = "Toner Lite") %>%
            
            # Overlay Groups
            addMarkers(
                group = "Org",
                popup = paste0(str_to_title(directory$organization),
                               "<br/>",
                               "Services: ", directory$services,
                               "<br/>",
                               "<a href =\"", directory$findhelp_site, "\", target=\"_blank\">Findhelp</a>"
                              )
               
                
            ) %>% 
            
            # Layer Groups
            addLayersControl(
                baseGroups = c("OSM (default)", "Toner", "Toner Lite"),
                
                overlayGroups = c("Assets","Org"),
                options = layersControlOptions(collapsed = TRUE)
            )
        
        
        
        
        
    })
}

# Run the application 
shinyApp(ui = ui, server = server)

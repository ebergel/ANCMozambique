
# app.R
library(shiny)
library(rpivotTable)
library(bslib)
library(descr)
library(dplyr)
library(htmlwidgets)
library(shinyAce)

# Increase the maximum file upload size to 100 MB
options(shiny.maxRequestSize = 100*1024^2)

# Source the UI and server files
source("ui.R")
source("server.R")

# Create the Shiny app
shinyApp(ui = ui, server = server)





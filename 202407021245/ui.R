
# ui.R
library(shiny)
library(rpivotTable)
library(bslib)
library(descr)
library(dplyr)
library(htmlwidgets)
library(shinyAce)

# Define the UI
ui <- fluidPage(
  titlePanel("Antenatal Care in Mozambique:"),
  titlePanel("Interactive Stepped-Wedge Cluster Randomised Trial Data Analysis Tool"),
  titlePanel("..."),
  mainPanel(
    tabsetPanel(type = "tabs",

                tabPanel("Description", 
                         tags$div(
                           tags$h4("Enhance scientific reproducibility", style = "font-size: 28px; font-weight: bold;"),
                           tags$p("This Shiny app is designed to replicate the results of a Stepped-Wedge Pragmatic Cluster Randomized Controlled Trial conducted to improve the quality of antenatal care in Mozambique.", style = "font-size: 16px;"),
                           tags$p("The trial, published in The Lancet Global Health, evaluated the impact of providing medical supply kits to antenatal care clinics. ", style = "font-size: 16px;"),
                           tags$p("This app allows users to explore the trial data interactively through a pivot table widget, enabling them to analyze outcome measures such as blood pressure, proteinuria, and syphilis testing rates without requiring advanced statistical or programming skills. ", style = "font-size: 16px;"),
                           tags$p("The app was developed to enhance scientific reproducibility by making the trial data accessible and analyzable for researchers, practitioners, and policymakers.", style = "font-size: 16px;"),
                           tags$p("The source code for this R Shiny app and the dataset are available for download within the app and at this github repository: https://github.com/ebergel/ANCMozambique.", style = "font-size: 16px;"),
                           tags$p("Reference:", style = "font-size: 16px;"),
                           tags$p("AP Betrán,E. Bergel, S. Griffin,A. Melo, MH Nguyen, A. Carbonell,S. Mondlane,M. Merialdi,M. Temmerman, AM Gülmezoglu, A. German,F. Althabe,A. Biza,B. Crahay,L. Chavane,M. Colomar,T. Delvaux,U. Dyke Ali,L. Fersurela,D. Geelhoed,I. Jille-Taas,CR Malapende,C. Langa, NB Osman, J. Requejo and G. Timbe. Provision of medical supply kits to improve quality of antenatal care in Mozambique: a stepped-wedge cluster randomized trial. The Lancet Global Health. 2018;6(1):https://doi.org/10.1016/S2214-109X(17)30421-7.", 
                                  style = "font-size: 14px;"),),),
                
                tabPanel("Pivot Table", 
                         uiOutput("asRateInput"),
                         rpivotTableOutput("pivotTable")), 
                
                tabPanel("Outcomes (%)", 
                         hr(),
                         uiOutput("pivotControlsR"),
                         rpivotTableOutput("pivotTableR")),
                
                tabPanel("Outcomes (n/N)", 
                         hr(),
                         uiOutput("pivotControlsN"),
                         rpivotTableOutput("pivotTableN")  ),
                
                tabPanel("Lancet Paper", 
                         br(),
                         img(src = "ANC.top.png", style = "width:100%;"),
                         br(),    br(),br(),
                         tags$a(href = "mozambique.pdf", "Click to download PDF", target = "_blank", style = "font-size: 20px; font-weight: bold;"),
                         br(),
                         img(src = "ANC.png", style = "width:100%;")),
                
                tabPanel("Study Results", 
                         br(),
                         img(src = "f1.jpg", style = "width:100%;")),
                
                tabPanel("Code",
                         tabsetPanel(
                           tabPanel("app.R", aceEditor("appCode", mode = "r", readOnly = TRUE, height = "400px")),
                           tabPanel("ui.R", aceEditor("uiCode", mode = "r", readOnly = TRUE, height = "400px")),
                           tabPanel("server.R", aceEditor("serverCode", mode = "r", readOnly = TRUE, height = "400px")),
                           tabPanel("data",  br(),br(),br(),
                                    tags$a(href = "appData.rds", 
                                           titlePanel("..."),
                                           "Click to download data (appData.rds)", 
                                           target = "_blank", 
                                           style = "font-size: 14px; font-weight: bold;")) )   ),
                
                tabPanel("Contact", 
                         tags$div(
                           tags$p("...", style = "font-size: 16px;"),
                           tags$p("Twitter: ", tags$a(href = "https://twitter.com/BergelEduardo", "@BergelEduardo"), style = "font-size: 16px;")   ), )
    )
  )
)
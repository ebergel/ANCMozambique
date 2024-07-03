
# server.R
library(shiny)
library(rpivotTable)
library(bslib)
library(descr)
library(dplyr)
library(htmlwidgets)
library(shinyAce)

# Function to convert 'yes'/'no' to 1/0
convert_yes_no <- function(x) {
  if (is.character(x) || is.factor(x)) {
    unique_vals <- unique(tolower(as.character(x)))
    if (all(unique_vals %in% c("yes", "no", "na", NA))) {
      return(ifelse(tolower(as.character(x)) == "yes", 100, 
                    ifelse(tolower(as.character(x)) == "no", 0, NA)))
    }
  }
  return(x)
}

# ########################################
# server
# ########################################
server <- function(input, output, session)  {
  
  
  # ########################################
  # set dfA
  # ########################################
  dfA <- reactive({
    
    #read dataset
    df <- readRDS("appData.rds")
    
    # var names - reference
    varNames <- '

      clinics              = "Clinics"  ,
      year                 = "Year" ,
      month                = "Month" ,
      study_month          = "Study Month" ,
      intervention         = "Is Intervention Step" ,
      steps                = "Steps" ,
      is_first_visit       = "Is First Visit" ,

      OUT_blood_pressure_done      = "Screening: High Blood Pressure" ,
      OUT_proteinuria_test_done    = "Screening: Proteinuria" ,
      OUT_syphilis_test_done       = "Screening: Syphilis" ,
      OUT_hiv_test_done            = "Screening: HIV" ,
      OUT_HB_test_done             = "Screening: Anemia" ,
      OUT_syphilis_treatment_done  = "Treatment: Syphilis" ,
      OUT_ARV_for_HIV_done         = "Treatment: HIV" ,
      OUT_mebendazol_done          = "Treatment: Worms" ,
      OUT_malaria_treatment_done   = "Treatment: Malaria"  '
    
    return(df)
    
  })
  
  # ########################################
  # set dfB - only outcomes
  # ########################################
  dfB <- reactive({
    req(dfA()) 
    df <- dfA()
    
    # Select   variables
    df <- df[,c(    
                "Screening: High Blood Pressure" ,
                "Screening: Proteinuria" ,
                "Screening: Syphilis" ,
                "Screening: HIV" ,
                "Screening: Anemia" ,
                "Treatment: Syphilis" ,
                "Treatment: HIV" ,
                "Treatment: Worms" ,
                "Treatment: Malaria" )]
    return(df)
  })
  
  # ########################################
  # set df01 - for rates
  # ########################################
  df01 <- reactive({
    req(dfA()) 
    df <- dfA()
  
  outs <- c(    
    "Screening: High Blood Pressure" ,
    "Screening: Proteinuria" ,
    "Screening: Syphilis" ,
    "Screening: HIV" ,
    "Screening: Anemia" ,
    "Treatment: Syphilis" ,
    "Treatment: HIV" ,
    "Treatment: Worms" ,
    "Treatment: Malaria" )
  
  dfouts <- df %>% mutate(across(outs, ~ convert_yes_no(.))) 
  
  return(dfouts)
  })
  

  # #################
  # inputs: pivot UI
  # #################
  output$asRateInput <- renderUI({
    checkboxInput("asRates", "Compute outcome Rates", value = TRUE)
  })
  
  
  # #################
  # inputs: pivot R
  # #################
  output$pivotControlsR <- renderUI({

    req(dfB())
    df <- dfB()

    tagList(
      fluidRow(
        column(6, selectInput("outVarR", "Outcome", choices = names(df), multiple = FALSE  ,selected = "Screening: Proteinuria"  )),
        column(6, selectInput("visitR", "Visit?",   choices = c("First", "Follow Up", "All"), multiple = FALSE, selected = "first"))
        )
      )

  })

  
  # #################
  # inputs: pivot N
  # #################
  output$pivotControlsN <- renderUI({

    req(dfB())
    df <- dfB()

    tagList(
      fluidRow(
        column(6, selectInput("outVarN", "Outcome", choices = names(df), multiple = FALSE  ,selected = "Screening: Proteinuria"  )),
        column(6, selectInput("visitN", "Visit?",   choices = c("First", "Follow Up", "All"), multiple = FALSE, selected = "first"))
        )
      )
  })
  
  # ############
  # render pivot: N
  # ############
  output$pivotTableN <- renderRpivotTable({
    
    req(dfA())
    df <- dfA()
    req(input$outVarN)
    req(input$visitN)
    
    if (input$visitN == "First") {
      df <- df %>% 
        filter(`Is First Visit` == "Yes")
    } else if (input$visitN == "Follow Up") {
      df <- df %>% 
        filter(`Is First Visit` == "No")
    }

    
    rpivotTable( df,
                 rows         = c("Is First Visit", "Clinics" , input$outVarN),
                 cols         = c("Is Intervention Step", "Steps"),
                 rendererName = "Table"
    ) %>%
      htmlwidgets::onRender("
      function(el, x) {
        // Custom JavaScript to hide UI elements for this specific table
        const table = document.getElementById(el.id);
        table.querySelectorAll('.pvtAxisContainer, .pvtVals, .pvtRenderer, .pvtAggregator').forEach(function(el) {
          el.style.display = 'none';
        });
      }
    ")
    
  })
  
  # ############
  # render pivot: R
  # ############
  output$pivotTableR <- renderRpivotTable({
    
    req(df01())
    df <- df01()
    req(input$outVarR)
    req(input$visitR)
    
    if (input$visitR == "First") {
      df <- df %>% 
        filter(`Is First Visit` == "Yes")
    } else if (input$visitR == "Follow Up") {
      df <- df %>% 
        filter(`Is First Visit` == "No")
    }
    
    
    rpivotTable( df,
                 rows = c("Is First Visit","Clinics"),
                 cols = c("Is Intervention Step", "Steps"),
                 vals = input$outVarR,
                 aggregatorName = "Average",
                 rendererName = "Heatmap" 
    ) %>%
      htmlwidgets::onRender("
      function(el, x) {
        // Custom JavaScript to hide UI elements for this specific table
        const table = document.getElementById(el.id);
        table.querySelectorAll('.pvtAxisContainer, .pvtVals, .pvtRenderer, .pvtAggregator').forEach(function(el) {
          el.style.display = 'none';
        });
      }
    ")
    
  })
  
  
  # ###################
  # render pivot UI
  # ###################
  output$pivotTable <-   renderRpivotTable({
   # req(input$asRates)

 if (!is.null(input$asRates)) {

      if (input$asRates) {

        req(df01())
        df <- df01()

        rpivotTable( df,
                       rows = c("Is First Visit", "Clinics"),
                       cols =   "Steps",
                       vals = "Screening: Proteinuria" ,
                       aggregatorName = "Average",
                       rendererName = "Heatmap"  ,
                       inclusions = list( "Is First Visit" = list("Yes") )  ,
                     ,onRefresh       = htmlwidgets::JS("function(config) { Shiny.onInputChange('pivot_onRefresh', config); }")
                     )

      } else {
        
        req(dfA())
        df <- dfA()
        rpivotTable( df,
                     rows         = c("Is First Visit","Clinics" , "Screening: Proteinuria"),
                     cols         = c( "Steps"),
                     rendererName = "Table"  ,
                     inclusions = list( "Is First Visit" = list("Yes") )  ,
                     ,onRefresh       = htmlwidgets::JS("function(config) { Shiny.onInputChange('pivot_onRefresh', config); }")   
                     )
    
    } 
 }
 })
  
  # ###################
  # Load and display code files
  # ###################
  observe({
    updateAceEditor(session, "appCode", value = paste(readLines("app.R"), collapse = "\n"))
    updateAceEditor(session, "uiCode", value = paste(readLines("ui.R"), collapse = "\n"))
    updateAceEditor(session, "serverCode", value = paste(readLines("server.R"), collapse = "\n"))
  })

  
}

  
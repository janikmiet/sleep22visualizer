library(leaflet)

# Choices for drop-downs
vars <- c(
  "No correction",
  "EuroStat"
)

navbarPage("Sleep Apnea Cost", id="nav",
           
           tabPanel("Interactive map",
                    div(class="outer",
                        
                        tags$head(
                          # Include our custom CSS
                          includeCSS("styles.css")#,
                          # includeScript("gomap.js")
                        ),
                        
                        # If not using custom CSS, set height of leafletOutput to a number instead of percent
                        leafletOutput("map", width="100%", height="100%"),
                        
                        # Shiny versions prior to 0.11 should use class = "modal" instead.
                        absolutePanel(id = "controls", class = "panel panel-default", fixed = TRUE,
                                      draggable = TRUE, top = 60, left = "auto", right = 20, bottom = "auto",
                                      width = 440, height = "auto",
                                      
                                      h2("Sleep apnea cost top-down estimation"),
                                      
                                      tags$p("Hovering a cursor in a map shows detailed information of the costs. By clicking the country, link to the calculation popup opens."),
                                      selectInput(inputId = "dataset", label = "Money index correction", choices = vars),
                                      # selectInput(inputId = "size", label = "Size", choices = vars, selected = "adultpop"),
                                      # conditionalPanel("input.color == 'superzip' || input.size == 'superzip'",
                                      #                  # Only prompt for threshold when coloring or sizing by superzip
                                      #                  numericInput("threshold", "SuperZIP threshold (top n percentile)", 5)
                                      # ),
                                      # textOutput("textBox"),
                                      plotOutput("barClasses", height = 800, width = 400),
                                      # plotOutput("scatterCollegeIncome", height = 250)
                        ),
                        
                        tags$div(id="cite",
                                 'Data compiled from ', tags$em('IHME GBD DATA <http://ghdx.healthdata.org/> BY CC BY-NC-ND 4.0 LICENCE'), ' and estimation method delivered from Armeni et al. (2019) Cost-of-illness study of Obstructive Sleep Apnea Syndrome (OSAS) in Italy. Sleep apnea prevalences (OSA) are collected from Benjafield et al. article.'
                        )
                    )
           ),
           
           tabPanel("About",
                    tags$p("Application estimates sleep apnea costs in 45 countries for 15-74 years old population. Data is compiled from IHME GBD DATA <http://ghdx.healthdata.org/> BY CC BY-NC-ND 4.0 LICENCE and sleep apnea prevalences from Benjafield et al. (2019) Estimation of the global prevalence and burden of obstructive sleep apnoea: a literature-based analysis. Estimation method delivered from Armeni et al. (2019) Cost-of-illness study of Obstructive Sleep Apnea Syndrome (OSAS) in Italy -article. For more information of our research project visit project website https://research.janimiettinen.fi/material/sleep22/")
           )
           
           # conditionalPanel("false", icon("crosshair"))
)
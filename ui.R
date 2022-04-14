library(leaflet)

# Choices for drop-downs
vars <- c(
  "No correction" = "slapnea22.RDS",
  "EuroStat" = "slapnea22_eurostat.RDS"
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
                                      
                                      h2("Sleep apnea cost calculation"),
                                      
                                      tags$p("Application estimates sleep apnea costs in 48 countries for 15-74 years old population. Select money index correction method and click countries from the map for more detailed information."),
                                      
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
                                 'Data compiled from ', tags$em('IHME GBD DATA <http://ghdx.healthdata.org/> BY CC BY-NC-ND 4.0 LICENCE'), ' and estimation method delivered from Armeni et al. (2019) Cost-of-illness study of Obstructive Sleep Apnea Syndrome (OSAS) in Italy.'
                        )
                    )
           ),
           
           # tabPanel("Data explorer",
           #          # fluidRow(
           #          #   column(3,
           #          #          selectInput("states", "States", c("All states"="", structure(state.abb, names=state.name), "Washington, DC"="DC"), multiple=TRUE)
           #          #   ),
           #          #   column(3,
           #          #          conditionalPanel("input.states",
           #          #                           selectInput("cities", "Cities", c("All cities"=""), multiple=TRUE)
           #          #          )
           #          #   ),
           #          #   column(3,
           #          #          conditionalPanel("input.states",
           #          #                           selectInput("zipcodes", "Zipcodes", c("All zipcodes"=""), multiple=TRUE)
           #          #          )
           #          #   )
           #          # ),
           #          # fluidRow(
           #          #   column(1,
           #          #          numericInput("minScore", "Min score", min=0, max=100, value=0)
           #          #   ),
           #          #   column(1,
           #          #          numericInput("maxScore", "Max score", min=0, max=100, value=100)
           #          #   )
           #          # ),
           #          hr(),
           #          DT::dataTableOutput("slapneatable")
           # ),
           # 
           # tabPanel("Calculator",
           #          fluidRow(
           #            column(2,
           #                   selectInput("cntry", "Country", locations, multiple=FALSE)
           #                   
           #            ),
           #            column(2,
           #                   conditionalPanel("input.cntry",
           #                                    sliderInput("slapnea_prevalence", "Sleep Apnea Prevalence", min = 0, max = 100, value = 60)
           #                   )
           #            ),
           #            # column(3,
           #            #        conditionalPanel("input.cntry",
           #            #                         selectInput("zipcodes", "Zipcodes", c("All zipcodes"=""), multiple=TRUE)
           #            #        )
           #            # )
           #          ),
           #          fluidRow(
           #            column(1,
           #                   rHandsontableOutput("slapnea22", width = 600, height = 300)
           #            ),
           #            column(1,
           #                   conditionalPanel("input.cntry",
           #                                    sliderInput("slapnea_prevalence1", "Sleep Apnea Prevalence1", min = 0, max = 100, value = 60)
           #                   )
           #            ),
           #            # column(1,
           #            #        conditionalPanel("input.cntry",
           #            #                         sliderInput("slapnea_prevalence2", "Sleep Apnea Prevalence2", min = 0, max = 100, value = 60)
           #            #        )
           #            # ),
           #            # column(1,
           #            #        conditionalPanel("input.cntry",
           #            #                         sliderInput("slapnea_prevalence3", "Sleep Apnea Prevalence3", min = 0, max = 100, value = 60)
           #            #        )
           #            # ),
           #            # column(1,
           #            #        conditionalPanel("input.cntry",
           #            #                         sliderInput("slapnea_prevalence4", "Sleep Apnea Prevalence4", min = 0, max = 100, value = 60)
           #            #        )
           #            # ),
           #            # column(1,
           #            #        conditionalPanel("input.cntry",
           #            #                         sliderInput("slapnea_prevalence5", "Sleep Apnea Prevalence5", min = 0, max = 100, value = 60)
           #            #        )
           #            # )
           #          ),
           #          # fluidRow(
           #          #   column(1,
           #          #          numericInput("cost1", "Min score", min=0, max=100, value=0)
           #          #   ),
           #          #   column(1,
           #          #          numericInput("cost2", "Max score", min=0, max=100, value=100)
           #          #   ),
           #          #   column(1,
           #          #          numericInput("cost3", "Max score", min=0, max=100, value=100)
           #          #   ),
           #          #   column(1,
           #          #          numericInput("cost4", "Max score", min=0, max=100, value=100)
           #          #   ),
           #          #   column(1,
           #          #          numericInput("cost5", "Max score", min=0, max=100, value=100)
           #          #   ),
           #          #   column(1,
           #          #          numericInput("cost6", "Max score", min=0, max=100, value=100)
           #          #   )
           #          # ),
           #          
           # ),
           
           tabPanel("About",
                    tags$p("Application estimates sleep apnea costs in 48 countries for 15-74 years old population. Data is compiled from IHME GBD DATA <http://ghdx.healthdata.org/> BY CC BY-NC-ND 4.0 LICENCE and estimation method delivered from Armeni et al. (2019) Cost-of-illness study of Obstructive Sleep Apnea Syndrome (OSAS) in Italy -article. For more information of our research project visit project website https://research.janimiettinen.fi/material/sleep22/")
           )
           
           # conditionalPanel("false", icon("crosshair"))
)
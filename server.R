library(leaflet)
library(RColorBrewer)
library(scales)
library(lattice)
library(dplyr)


function(input, output, session) {
  
  dataset <- reactive({
    if(input$dataset == "No correction"){
     d <- slapnea22 %>% 
       mutate(
         pop_both = round(pop_both, -1),
         direct_cost = round(direct_cost, -1),
         direct_non_healthcare_cost = round(direct_non_healthcare_cost, -1),
         productivity_lost_cost = round(productivity_lost_cost, -1),
         patient_direct_cost = round(patient_direct_cost, -1),
         patient_nonhealthcare_cost = round(patient_nonhealthcare_cost, -1),
         patient_productivity_cost = round(patient_productivity_cost, -1),
         patient_total_cost = round(patient_total_cost, -1)
       )
    }else{
      d <- slapnea22 %>% 
        mutate(
          pop_both = round(pop_both, -1),
          direct_cost = round(index * direct_cost, -1),
          direct_non_healthcare_cost = round(index * direct_non_healthcare_cost, -1),
          productivity_lost_cost = round(index * productivity_lost_cost, -1),
          patient_direct_cost = round(index * patient_direct_cost, -1),
          patient_nonhealthcare_cost = round(index * patient_nonhealthcare_cost, -1),
          patient_productivity_cost = round(index * patient_productivity_cost, -1),
          patient_total_cost = round(index * patient_total_cost, -1)
        )
    }
    return(d)
    
  })
  
  ## Interactive Map ###########################################
  
  # Create the map
  output$map <- renderLeaflet({
    
    ## Join with map data
    mapdata <- sp::merge(europe_spdf, dataset(), by.x="NAME", by.y="location_name")
    
    ## Create a color palette with handmade bins.
    mybins <- c(0,1000,2000,3000,4000,Inf)
    mypalette <- colorBin( palette="YlOrBr", domain=mapdata@data$POP2005, na.color="transparent", bins=mybins)
    
    # Prepare the text for tooltips:
    mytext <- paste(
      "<b> ", mapdata@data$NAME,"</b> <br/>", 
      "Population (15-74yrs): ", round(mapdata@data$pop_female + mapdata@data$pop_male, -1),"<br/>", 
      "<b> Cost per patient </b> <br/>",
      "Direct: ", round(mapdata@data$patient_direct_cost, 0), "€ <br/>",
      "Non-healthcare: ", round(mapdata@data$patient_nonhealthcare_cost, 0), "€ <br/>",
      "Productivity: ", round(mapdata@data$patient_productivity_cost, 0), "€<br/>",
      "Total: ", round(mapdata@data$patient_total_cost, 0), "€<br/>", 
      # '<a href="https://janimiettinen.shinyapps.io/sleepapneacalculator/?location_name=',mapdata@data$NAME,'">Open calculator</a> ', ## TODO need or no need
      sep="") %>%
      lapply(htmltools::HTML)
    
    ## With costs data
    leaflet(mapdata) %>%
      setView(lng = 19.632137995418812, lat = 54.1384668053237, zoom = 4) %>% 
      # addTiles() %>%
      addPolygons(color = "#444444", 
                  weight = 0.3, #1,  # 0.3,
                  smoothFactor = 0.5,
                  opacity = 1.0, 
                  fillColor = ~mypalette(patient_total_cost),
                  highlightOptions = highlightOptions(color = "white", 
                                                      weight = 2,
                                                      bringToFront = TRUE),
                  stroke=TRUE, 
                  fillOpacity = 0.9, #0.5
                  label = mytext,
                  popup = paste0(
                    "<b>Country: </b>"
                    , mapdata@data$NAME
                    , "<br>"
                    , "<a href='"
                    , "https://janimiettinen.shinyapps.io/sleepapneacalculator/?location_name=",mapdata@data$NAME
                    , "' target='_blank'>"
                    , "Open the calculator</a>"  ),
                  labelOptions = labelOptions(
                    style = list("font-weight" = "normal", padding = "3px 8px"), 
                    textsize = "13px", 
                    direction = "auto"
                  )) %>%
      addLegend(pal=mypalette, 
                values=~patient_total_cost, opacity=0.9, title = "Patient annual cost, €", position = "topleft" ) 
    
  })
  
  
  output$barClasses <- renderPlot({
    
    ### All countries -----
    dataset() %>% 
      select(location_name, patient_direct_cost, patient_nonhealthcare_cost, patient_productivity_cost) %>% 
      tidyr::pivot_longer(c(patient_direct_cost, patient_nonhealthcare_cost, patient_productivity_cost)) -> dplot
    
    ## Barplot of the costs
    ## Create a bar plot by countries
    ggplot(data = dplot) +
      geom_bar(aes(x=reorder(location_name, value), y=value, fill=name), stat="identity") +
      coord_flip() +
      labs(x="", 
           y="euros", 
           fill="",
           title="Costs by countries"#,
           # subtitle = "Patient direct healthcare, direct non-healthcare and productivity lost costs"
           ) +
      # hrbrthemes::theme_ipsum() +
      # scale_fill_discrete(labels=c('Direct healthcare cost', 'Direct non-helthcare cost', 'Productivity losses')) +
      scale_fill_brewer(palette = "Set2", labels=c('Direct healthcare cost', 'Direct non-helthcare cost', 'Productivity losses')) +
      scale_y_continuous(expand = c(0,0)) +
      theme(plot.caption = element_text(hjust = 0, face= "italic"), #Default is hjust=1
            plot.title.position = "plot", #NEW parameter. Apply for subtitle too.
            plot.caption.position =  "plot",
            legend.position = "bottom",
            legend.box.just = "left" ,
            legend.justification = c(1,0))  #NEW parameter
    

  })
  
  output$slapneatable <- DT::renderDataTable({
    df <- dataset() %>%
      mutate(pop_female = round(pop_female,-1),
             pop_male = round(pop_male,-1),
             direct_cost = round(direct_cost,-1),
             direct_non_healthcare_cost = round(direct_non_healthcare_cost,-1),
             productivity_lost_cost = round(productivity_lost_cost,-1),
             absolute_value_severe_moderate = round(absolute_value_severe_moderate,-1),
             absolute_value_mild = round(absolute_value_mild,-1),
             patient_direct_cost = round(patient_direct_cost,-1),
             patient_nonhealthcare_cost = round(patient_nonhealthcare_cost,-1),
             patient_productivity_cost = round(patient_productivity_cost,-1),
             patient_total_cost = round(patient_total_cost,-1)
             )
    # action <- DT::dataTableAjax(session, df, outputId = "ziptable")

    DT::datatable(df)#, options = list(ajax = list(url = action)), escape = FALSE)
  })
}
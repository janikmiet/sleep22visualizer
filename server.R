library(leaflet)
library(RColorBrewer)
library(scales)
library(lattice)
library(dplyr)

# Leaflet bindings are a bit slow; for now we'll just sample to compensate
# set.seed(100)
# zipdata <- allzips[sample.int(nrow(allzips), 10000),]
# By ordering by centile, we ensure that the (comparatively rare) SuperZIPs
# will be drawn last and thus be easier to see
# zipdata <- zipdata[order(zipdata$centile),]

function(input, output, session) {
  
  dataset <- reactive({
    if(input$dataset == "slapnea22.RDS") return(slapnea22)
    if(input$dataset == "slapnea22_eurostat.RDS") return(slapnea22_eurostat)
  })
  
  # output$hot <- renderRHandsontable({
  #   # DF <- values[["DF"]]
  #   DF <- values[[dataset()]]
  #   # if (!is.null(DF))
  #     # rhandsontable(DF, useTypes = as.logical(input$useType), stretchH = "all")
  # })
  
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
      "Population (15-74yrs): ", round(mapdata@data$pop_female + mapdata@data$pop_male, 0),"<br/>", 
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
                  labelOptions = labelOptions(
                    style = list("font-weight" = "normal", padding = "3px 8px"), 
                    textsize = "13px", 
                    direction = "auto"
                  )) %>%
      addLegend(pal=mypalette, 
                values=~patient_total_cost, opacity=0.9, title = "Patient annual cost", position = "topleft" ) 
    
  })
  
  # # A reactive expression that returns the set of zips that are
  # # in bounds right now
  # zipsInBounds <- reactive({
  #   if (is.null(input$map_bounds))
  #     return(zipdata[FALSE,])
  #   bounds <- input$map_bounds
  #   latRng <- range(bounds$north, bounds$south)
  #   lngRng <- range(bounds$east, bounds$west)
  #   
  #   subset(zipdata,
  #          latitude >= latRng[1] & latitude <= latRng[2] &
  #            longitude >= lngRng[1] & longitude <= lngRng[2])
  # })
  # 
  # # Precalculate the breaks we'll need for the two histograms
  # centileBreaks <- hist(plot = FALSE, allzips$centile, breaks = 20)$breaks
  # 
  # ## Just testing leaflet clicks
  # output$textBox <- shiny::renderPrint({
  #   input$map_shape_click
  # })
  
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
    
    ### Only one country ----
    # If no zipcodes are in view, don't plot
    # if (nrow(zipsInBounds()) == 0)
    #   return(NULL)
    ## TODO how to select country???
    # dataset() %>% 
    #   filter(location_name == "Finland") %>% 
    #   select(location_name, patient_direct_cost, patient_nonhealthcare_cost, patient_productivity_cost) %>% 
    #   pivot_longer(c(patient_direct_cost, patient_nonhealthcare_cost, patient_productivity_cost)) -> dplot
    # 
    # ggplot(data = dplot) +
    #   geom_bar(aes(x=reorder(name, -value), y=value, fill=name), stat="identity") +
    #   coord_flip() +
    #   labs(x="", 
    #        y="euros", 
    #        fill="",
    #        title="Costs by classes",
    #        subtitle = "") +
    #   hrbrthemes::theme_ipsum() +
    #   scale_fill_brewer(palette = "Set2", labels=c('Direct healthcare cost', 'Direct non-helthcare cost', 'Productivity losses')) +
    #   scale_x_discrete(labels=c('Direct healthcare cost', 'Direct non-helthcare cost', 'Productivity losses')) +
    #   scale_y_continuous(expand = c(0,0)) +
    #   theme(plot.caption = element_text(hjust = 0, face= "italic"), #Default is hjust=1
    #         plot.title.position = "plot", #NEW parameter. Apply for subtitle too.
    #         plot.caption.position =  "plot",
    #         legend.position = "none")  #NEW parameter
  })
  
  # output$scatterCollegeIncome <- renderPlot({
  #   # If no zipcodes are in view, don't plot
  #   if (nrow(zipsInBounds()) == 0)
  #     return(NULL)
  #   
  #   print(xyplot(income ~ college, data = zipsInBounds(), xlim = range(allzips$college), ylim = range(allzips$income)))
  # })
  # 
  # This observer is responsible for maintaining the circles and legend,
  # according to the variables the user has chosen to map to color and size.
  # observe({
  #   colorBy <- input$color
  #   sizeBy <- input$size
  #   
  #   if (colorBy == "superzip") {
  #     # Color and palette are treated specially in the "superzip" case, because
  #     # the values are categorical instead of continuous.
  #     colorData <- ifelse(zipdata$centile >= (100 - input$threshold), "yes", "no")
  #     pal <- colorFactor("viridis", colorData)
  #   } else {
  #     colorData <- zipdata[[colorBy]]
  #     pal <- colorBin("viridis", colorData, 7, pretty = FALSE)
  #   }
  #   
  #   if (sizeBy == "superzip") {
  #     # Radius is treated specially in the "superzip" case.
  #     radius <- ifelse(zipdata$centile >= (100 - input$threshold), 30000, 3000)
  #   } else {
  #     radius <- zipdata[[sizeBy]] / max(zipdata[[sizeBy]]) * 30000
  #   }
  #   
  #   leafletProxy("map", data = zipdata) %>%
  #     clearShapes() %>%
  #     addCircles(~longitude, ~latitude, radius=radius, layerId=~zipcode,
  #                stroke=FALSE, fillOpacity=0.4, fillColor=pal(colorData)) %>%
  #     addLegend("bottomleft", pal=pal, values=colorData, title=colorBy,
  #               layerId="colorLegend")
  # })
  
  # Show a popup at the given location
  # showZipcodePopup <- function(zipcode, lat, lng) {
  #   selectedZip <- allzips[allzips$zipcode == zipcode,]
  #   content <- as.character(tagList(
  #     tags$h4("Score:", as.integer(selectedZip$centile)),
  #     tags$strong(HTML(sprintf("%s, %s %s",
  #                              selectedZip$city.x, selectedZip$state.x, selectedZip$zipcode
  #     ))), tags$br(),
  #     sprintf("Median household income: %s", dollar(selectedZip$income * 1000)), tags$br(),
  #     sprintf("Percent of adults with BA: %s%%", as.integer(selectedZip$college)), tags$br(),
  #     sprintf("Adult population: %s", selectedZip$adultpop)
  #   ))
  #   leafletProxy("map") %>% addPopups(lng, lat, content, layerId = zipcode)
  # }
  
  # # When map is clicked, show a popup with city info
  # observe({
  #   leafletProxy("map") %>% clearPopups()
  #   event <- input$map_shape_click
  #   if (is.null(event))
  #     return()
  # 
  #   isolate({
  #     showZipcodePopup(event$id, event$lat, event$lng)
  #   })
  # })
  # 
  
  ## Data Explorer ###########################################
  
  # observe({
  #   cities <- if (is.null(input$states)) character(0) else {
  #     filter(cleantable, State %in% input$states) %>%
  #       `$`('City') %>%
  #       unique() %>%
  #       sort()
  #   }
  #   stillSelected <- isolate(input$cities[input$cities %in% cities])
  #   updateSelectizeInput(session, "cities", choices = cities,
  #                        selected = stillSelected, server = TRUE)
  # })
  # 
  # observe({
  #   zipcodes <- if (is.null(input$states)) character(0) else {
  #     cleantable %>%
  #       filter(State %in% input$states,
  #              is.null(input$cities) | City %in% input$cities) %>%
  #       `$`('Zipcode') %>%
  #       unique() %>%
  #       sort()
  #   }
  #   stillSelected <- isolate(input$zipcodes[input$zipcodes %in% zipcodes])
  #   updateSelectizeInput(session, "zipcodes", choices = zipcodes,
  #                        selected = stillSelected, server = TRUE)
  # })
  # 
  # observe({
  #   if (is.null(input$goto))
  #     return()
  #   isolate({
  #     map <- leafletProxy("map")
  #     map %>% clearPopups()
  #     dist <- 0.5
  #     zip <- input$goto$zip
  #     lat <- input$goto$lat
  #     lng <- input$goto$lng
  #     showZipcodePopup(zip, lat, lng)
  #     map %>% fitBounds(lng - dist, lat - dist, lng + dist, lat + dist)
  #   })
  # })
  # 
  output$slapneatable <- DT::renderDataTable({
    df <- dataset() %>%
      mutate(pop_female = round(pop_female,0),
             pop_male = round(pop_male,0),
             direct_cost = round(direct_cost,0),
             direct_non_healthcare_cost = round(direct_non_healthcare_cost,0),
             productivity_lost_cost = round(productivity_lost_cost,0),
             absolute_value_severe_moderate = round(absolute_value_severe_moderate,0),
             absolute_value_mild = round(absolute_value_mild,0),
             patient_direct_cost = round(patient_direct_cost,0),
             patient_nonhealthcare_cost = round(patient_nonhealthcare_cost,0),
             patient_productivity_cost = round(patient_productivity_cost,0),
             patient_total_cost = round(patient_total_cost,0)
             )
    # action <- DT::dataTableAjax(session, df, outputId = "ziptable")

    DT::datatable(df)#, options = list(ajax = list(url = action)), escape = FALSE)
  })
}
tab <- 0

library(shiny)
shinyServer(function(input, output, session) {
   
    observeEvent(input$tabselected, {
        Region <- Species <- Slider <- NULL
      if (input$tabselected == 1)
      {
         
          if(tab == 0)
          {
              minmax <- reactive({
                  selectYears(filter(asl, SASAP.Region == R, Species == S))
              })
              minmax <- minmax()
              slider <- minmax
              Region <- R
              Species <- S
          } else if (tab == 1)
          {
              slider <- input$sliderYear
              Species <- input$Species
              Region <- input$Region
          } else if (tab == 2)
          {
              slider <- input$sliderYear2
              Species <- input$Species2
              Region <- R
          } else if (tab == 3)
          {
              slider <- input$sliderYear3
              Species <- S
              Region <- input$Region3
          }
          
        output$Region <- renderUI({
          selectInput('Region', 'Region', sort(unique(asl$SASAP.Region)), selected = Region)
            })
        searchResult2 <- reactive({
          sort(unique(filter(asl, SASAP.Region == input$Region)$Species ))
            })
        output$Species <- renderUI({
          req(input$Region)
          selectInput("Species", "Species", searchResult2(), selected = Species)
            })
        minmax <- reactive({
          selectYears(filter(asl, SASAP.Region == Region, Species == Species))
            })
        print(slider)
        print(Region)
        print(Species)
        output$sliderYear <- renderUI({
          req(Species)
          minmax <- minmax()
          sliderInput("sliderYear", "Year range:",
                      min = minmax[1], max = minmax[2],
                      value = c(slider[1], slider[2]),
                      step=1, sep = '')
            })
        tab <<- 1
      }
    })

  observeEvent(input$tabselected, {
    if (input$tabselected == 2)
        {
        if (tab == 1)
        {
            slider <- input$sliderYear
            Species <- input$Species
            R <<- input$Region
        }  else if (tab == 3)
        {
            slider <- input$sliderYear3
            Species <- S
            Region <- input$Region3
        }
        
        output$Species2 <- renderUI({ 
            selectInput(inputId = "Species2", label = "Species", sp, selected = Species)
            })
        minmax <- reactive({
            selectYears(filter(asl, Species == input$Species2))
            })

        output$sliderYear2 <- renderUI({
            req(input$Species2)
            minmax <- minmax()
            sliderInput(inputId = "sliderYear2", "Year range:",
                    min = minmax[1], max = minmax[2],
                    value = c(slider[1], slider[2]),
                    step=1, sep = '')
            })
        tab <<- 2
        
        }
    })
    
  observeEvent(input$tabselected, {
    if (input$tabselected == 3)
        {
        if (tab == 1)
        {
            slider <- input$sliderYear
            Species <- input$Species
            Region <- input$Region
        } else if (tab == 2)
        {
            slider <- input$sliderYear2
            S <<- input$Species2
            Region <- R
        } 
        output$Region3 <- renderUI({
            selectInput('Region3', 'Region', sort(unique(asl$SASAP.Region)), selected = Region)
            })
        minmax <- reactive({
            selectYears(filter(asl, SASAP.Region == input$Region))
            })
        output$sliderYear3 <- renderUI({
            req(input$Region3)
            minmax <- minmax()
            sliderInput("sliderYear3", "Year range:",
                        min = minmax[1], max = minmax[2],
                        value = c(slider[1], slider[2]),
                        step=1, sep = '')
            })
        tab <<- 3
        }
  })
   
    output$plotRegionSp <- renderPlot({
        req(input$Region)
        req(input$Species)
        req(input$sliderYear)
        temp <- filter(asl, SASAP.Region == input$Region, Species == input$Species, sampleYear >= input$sliderYear[1], sampleYear <= input$sliderYear[2])
        model <- lm(meanLenth ~ sampleYear, data=temp)
        eq <- paste(round(model$coefficients[2],2), '* Year +', round(model$coefficients[1],2))
        if (model$coefficients[1] < 0)
        {
            eq <- paste(round(model$coefficients[2],2), '* Year ', round(model$coefficients[1],2))
        } 
        ggplot(temp, 
               aes(x=sampleYear, y=meanLenth)) + 
            geom_point() + geom_smooth(method="lm", color="red", fill = "orange") + 
            geom_smooth(fill = "light blue") + theme_joy() + 
            theme(axis.text.x = element_text(angle = 45, hjust = 1, size=12),
                  axis.text.y = element_text(angle = 0, hjust = 1, size=12),
                  text = element_text(size=15), title = element_text(size=15)) +
            xlab("Time [Years]") + ylab("Mean Length [mm]") +
            ggtitle(paste('Length =', eq, input$tabselected), 
                    subtitle = capitalize(paste(input$Species, "mean size")))
    },  height = 700, width = 600 )

    output$plotAllRegions <- renderPlot({
        req(input$sliderYear2)
        temp <- filter(asl, Species == input$Species2, sampleYear >= input$sliderYear2[1], sampleYear <= input$sliderYear2[2])
        ggplot(temp, 
               aes(x=sampleYear, y=meanLenth)) + 
            geom_point(size=0.5) + geom_smooth(method="lm", color="red", fill="orange") + geom_smooth(fill="light blue") +
            theme_joy() + facet_wrap(~SASAP.Region, ncol = 4) +
            theme(axis.text.x = element_text(angle = 45, hjust = 1, size=12),
                  axis.text.y = element_text(angle = 0, hjust = 1, size=12),
                  text = element_text(size=15), title = element_text(size=15)) +
            xlab("Time [Years]") + ylab("Mean Length [mm]") +             
            ggtitle('',subtitle = capitalize(paste(input$Species2)))
    },  height = 700, width = 600 )
    
    output$plotAllSpecies <- renderPlot({
        req(input$sliderYear3)
        temp <- filter(asl, SASAP.Region == input$Region3, sampleYear >= input$sliderYear3[1], sampleYear <= input$sliderYear3[2])
        ggplot(temp, 
               aes(x=sampleYear, y=meanLenth)) + 
            geom_point(size=0.5) + geom_smooth(method="lm", color="red", fill="orange") + geom_smooth(fill="light blue") +
            theme_joy() + facet_wrap(~Species, ncol = 2) +
            theme(axis.text.x = element_text(angle = 45, hjust = 1, size=12),
                  axis.text.y = element_text(angle = 0, hjust = 1, size=12),
                  text = element_text(size=15), title = element_text(size=15)) +
            xlab("Time [Years]") + ylab("Mean Length [mm]") +             
            ggtitle('',subtitle = capitalize(paste(input$Region3)))
    },  height = 700, width = 600 )
    
})

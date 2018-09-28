randomwalk_ui <- function() {

  fluidPage(
    tabsetPanel(
      tabPanel("Random Walk 1D",
        htmlOutput("random_1d")        
      ),
      tabPanel("Random Walk 2D",
        sidebarLayout(
          sidebarPanel(
            numericInput("x_position", "x-axis start position:", 
                        min = -10, max = 10, value  = 0),
            numericInput("y_position", "y-axis start position:", 
                        min = -10, max = 10, value  = 0),
            sliderInput("steps", "Number of steps:",
                        min=20, max=10000, value=3756),
            numericInput("seed", "Random seed:", 
                        value  = 12345),
            sliderInput("size", "Size of the points:",
                        min=0, max=3, value=1),
            sliderInput("width", "Width of the line-path:",
                        min=0, max=5, value=1),
            h4("Final position:"),
            textOutput("final")
            
          ),
          
          # Show a plot of the generated distribution
          mainPanel(
            plotOutput("path_plot")
          )
        )
      ),
      tabPanel("Lecture Notes", 
                 tags$iframe(style="height:500px; width:100%; scrolling=yes", 
                  src="Random_Walks.pdf#zoom=50&toolbar=0&navpanes=0"
              )       
      )
    )
  )
}

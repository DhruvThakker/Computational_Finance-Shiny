geometricbrownian_ui <- function() {

  fluidPage(
    tabsetPanel(
      tabPanel("Geometric Brownian Motion",
      sidebarLayout(
          sidebarPanel(
            numericInput("gbm_rate", "Return Rate:", 
                        min = 0.001, max = 1, value  = 0.16),
            numericInput("gbm_volatility", "Volatility:", 
                        min = 0.001, max = 5, value  = 0.2),
            sliderInput("gbm_price", "Initial Price:",
                        min=20, max=1000, value=40),
            sliderInput("gbm_steps", "Number of steps:",
                        min=20, max=1000, value=50),
            sliderInput("gbm_time", "Time(in months):",
                        min=1, max=144, value=1),
            sliderInput("gbm_trajectories", "Number of Trajectories:",
                        min=10, max=100, value=50)            
          ),
          
          # Show a plot of the generated distribution
          mainPanel(
            plotOutput("gbm_path_plot")
          )
        )
      ),
      tabPanel("Lecture Notes", 
                 tags$iframe(style="height:500px; width:100%; scrolling=yes", 
                  src="Geometric_Brownian.pdf#zoom=50&toolbar=0&navpanes=0"
              )       
      ),
      tabPanel("Lab Exercise",
        helpText(   a("Random Walk Lab HackerRank", href="https://www.hackerrank.com", target="_blank"))
        #helpText("Coming Soon!!")
      )
    )
  )
}

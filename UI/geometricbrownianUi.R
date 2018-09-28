geometricbrownian_ui <- function() {

  fluidPage(
    tabsetPanel(
      tabPanel("Random Walk 1D",
      helpText("Coming Soon!!")
      ),
      tabPanel("Random Walk 2D",
      helpText("Coming Soon!!")
      ),
      tabPanel("Lecture Notes", 
                 tags$iframe(style="height:500px; width:100%; scrolling=yes", 
                  src="Geometric_Brownian.pdf#zoom=50&toolbar=0&navpanes=0"
              )       
      )
    )
  )
}

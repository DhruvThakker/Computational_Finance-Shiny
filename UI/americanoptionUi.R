americanoption_ui <- function() {

  fluidPage(
    tabsetPanel(
      tabPanel("American Option Binomial",
        helpText("Coming Soon!!")
      ),
      tabPanel("Lecture Notes", 
                 tags$iframe(style="height:500px; width:100%; scrolling=yes", 
                  src="American_Option.pdf#zoom=50&toolbar=0&navpanes=0"
              )       
      ),
      tabPanel("Lab Exercise",
        helpText("Coming Soon!!")
      )
    )
  )
}
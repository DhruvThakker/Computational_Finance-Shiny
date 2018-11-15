americanoption_ui <- function() {

  fluidPage(
    tabsetPanel(
      tabPanel("American Option Binomial",
        #helpText("Coming Soon!!")
        sidebarLayout(
               sidebarPanel = sidebarPanel(
                 h3("Binomial Input"),
                 numericInput("amer_steps", "Number of Steps",
                              min = 1, max = 10, value = 3),
                 radioButtons("amer_type", "Option Type",
                              list("Call" = 1, "Put" = 2),
                              selected = 1, inline = T),
                 numericInput("amer_strike", "Strike Price (in ₹)", value = 4,
                             min = 1, max = 250),
                 numericInput("amer_stock", "Initial Stock Price (in ₹)",
                             value = 4,
                             min = 1, max = 250),
                 numericInput("amer_u", " u", value =2,
                             min = 0, max = 100),
                 numericInput("amer_d", " d ", value =0.5,
                             min = 0, max = 100),
                 numericInput("amer_rate", "Risk-Free Rate", value = 0.25,
                             min = 0, max = 100)
               ),
               mainPanel = mainPanel(
                  grVizOutput('amer_binomial')
               )
             )
      ),
      tabPanel("Lecture Notes", 
                 tags$iframe(style="height:500px; width:100%; scrolling=yes", 
                  src="American_Option.pdf#zoom=50&toolbar=0&navpanes=0"
              )       
      ),
      tabPanel("Lab Exercise",
        helpText(   a("Random Walk Lab HackerRank", href="https://www.hackerrank.com", target="_blank"))
        #helpText("Coming Soon!!")
      )
    )
  )
}
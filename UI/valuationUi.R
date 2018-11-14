# valuation_ui for the display of the greeks
valuation_ui <- function() {
  fluidPage(tabsetPanel(
    tabPanel("Binomial Model",
             sidebarLayout(
               sidebarPanel = sidebarPanel(
                 h3("Binomial Input"),
                 numericInput("euro_steps", "Number of Steps",
                              min = 1, max = 10, value = 3),
                 radioButtons("euro_type", "Option Type",
                              list("Call" = 1, "Put" = 2),
                              selected = 1, inline = T),
                 numericInput("euro_strike", "Strike Price (in ₹)", value = 4,
                             min = 1, max = 250),
                 numericInput("euro_stock", "Initial Stock Price (in ₹)",
                             value = 4,
                             min = 1, max = 250),
                 numericInput("euro_u", " u", value =2,
                             min = 0, max = 100),
                 numericInput("euro_d", " d ", value =0.5,
                             min = 0, max = 100),
                 numericInput("euro_rate", "Risk-Free Rate", value = 0.25,
                             min = 0, max = 100)
               ),
               mainPanel = mainPanel(
                 #plotOutput("price_binomial")
                  grVizOutput('euro_binomial')
               )
             )
    ),
    tabPanel("Lecture Notes", 
                 tags$iframe(style="height:500px; width:100%; scrolling=yes", 
                  src="Risk_Neutral_Valuation.pdf#zoom=50&toolbar=0&navpanes=0"
              )       
    ),
    tabPanel("Black-Scholes Model",
             sidebarLayout(
               sidebarPanel = sidebarPanel(
                 h3("Black-Scholes Input"),
                 radioButtons("I_bs_type", "Option",
                              list("Call" = 1, "Put" = 2),
                              selected = 1, inline = T),
                 sliderInput("I_bs_strike", "Strike Price (in ₹)", value = 100,
                             min = 1, max = 250),
                 sliderInput("I_bs_value_underlying", "Current Value Underlying (in ₹)", 
                             value = 100,
                             min = 1, max = 250),
                 sliderInput("I_bs_maturity", "Maturity (in years)", value = 1,
                             min = 0, max = 5, step = 0.1),
                 sliderInput("I_bs_rf", "Risk-Free Rate (in %)", value = 1,
                             min = 0, max = 20, step = 0.1),
                 sliderInput("I_bs_vola", "Volatility (in %)", value = 1,
                             min = 0, max = 20, step = 0.1)
               ),
               mainPanel = mainPanel(
                 uiOutput("price_bs")
               )
             )
    )
  )
  )
}

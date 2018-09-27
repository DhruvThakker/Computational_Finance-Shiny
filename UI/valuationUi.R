# valuation_ui for the display of the greeks
valuation_ui <- function() {
  fluidPage(tabsetPanel(
    tabPanel("Theory",
             htmlOutput("price_theory")
    ),
    tabPanel("Binomial Model",
             sidebarLayout(
               sidebarPanel = sidebarPanel(
                 h3("Binomial Input"),
                 numericInput("I_price_n_steps", "Number of Steps",
                              min = 1, max = 10, value = 3),
                 radioButtons("I_price_type", "Option",
                              list("Call" = 1, "Put" = 2),
                              selected = 1, inline = T),
                 sliderInput("I_price_strike", "Strike Price (in $)", value = 100,
                             min = 1, max = 250),
                 sliderInput("I_price_value_underlying", "Current Value Underlying (in $)",
                             value = 100,
                             min = 1, max = 250),
                 sliderInput("I_price_tick", "Tick (in $)", value = 10,
                             min = 0, max = 50),
                 sliderInput("I_price_rf", "Risk-Free Rate (in %)", value = 1,
                             min = 0, max = 20)
               ),
               mainPanel = mainPanel(
                 plotOutput("price_binomial")
               )
             )
    ),
    tabPanel("Black-Scholes Model",
             sidebarLayout(
               sidebarPanel = sidebarPanel(
                 h3("Black-Scholes Input"),
                 radioButtons("I_bs_type", "Option",
                              list("Call" = 1, "Put" = 2),
                              selected = 1, inline = T),
                 sliderInput("I_bs_strike", "Strike Price (in $)", value = 100,
                             min = 1, max = 250),
                 sliderInput("I_bs_value_underlying", "Current Value Underlying (in $)", 
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

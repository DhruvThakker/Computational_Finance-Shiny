# greek_ui for the display of the greeks
greek_ui <- function() {
  sidebarLayout(
    sidebarPanel = sidebarPanel(
      h3("Financial Greek Inputs"),
      radioButtons("I_greek_dir", "Position", 
                   list("Long" = 1, "Short" = 2), 
                   selected = 1, inline = T),
      radioButtons("I_greek_type", "Option",
                   list("Call" = 1, "Put" = 2),
                   selected = 1, inline = T),
      radioButtons("I_greek_eu_am", "Option Type",
                   list("European" = 1, "American" = 2), inline = T),
      sliderInput("I_greek_strike", "Strike Price (in $)", value = 100,
                  min = 1, max = 250),
      sliderInput("I_greek_value_underlying", "Current Value Underlying (in $)", 
                  value = 100,
                  min = 1, max = 250),
      sliderInput("I_greek_maturity", "Maturity (in years)", value = 1,
                  min = 0, max = 5, step = 0.1),
      sliderInput("I_greek_dvd_yield", "Dividend Yield (in %)", value = 5,
                  min = 0, max = 20),
      sliderInput("I_greek_rf", "Risk-Free Rate (in %)", value = 1,
                  min = 0, max = 20),
      sliderInput("I_greek_vola", "Volatility (in %)", value = 1,
                  min = 0, max = 20)
    ), 
    mainPanel = mainPanel(
      tabsetPanel(
        tabPanel("Theory",
                 DT::dataTableOutput("greek_theory")
        ),
        tabPanel("Text Result",
                 verbatimTextOutput("text_single_result")
        ),
        tabPanel("The Greeks ",
                 radioButtons("I_greek_var", "Variable",
                              list("Underlying" = "underlying",
                                   "Strike" = "strike",
                                   "Dividend Yield" = "dvd_yield",
                                   "Risk-Free Rate" = "rf",
                                   "Maturity" = "maturity",
                                   "Volatility" = "vola"),
                              inline = T),
                 plotOutput("plot_greeks"),
                 "Note: the greeks refer mostly to the cases where the variable is the underlying."
        )
      )
    )
  )
}
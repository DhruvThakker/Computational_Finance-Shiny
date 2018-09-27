# payoff_ui for the calculation-tab
payoff_ui <- function() {
  sidebarLayout(
    sidebarPanel = sidebarPanel(
      h3("Option Basket Input"),
      radioButtons("I_basket_dir", "Position", 
                   list("Long" = 1, "Short" = 2), 
                   selected = 1, inline = T),
      radioButtons("I_basket_type", "Option Type",
                   list("Call" = 1, "Put" = 2, "Underlying" = 3),
                   selected = 1, inline = T),
      conditionalPanel("input.I_basket_type < 3", 
                       sliderInput("I_basket_strike", "Strike Price", value = 100,
                                   min = 0, max = 250)
      ),
      actionButton("BT_basket_new_option", "Insert", icon = icon("check")),
      actionButton("BT_basket_clear", "Clear", icon = icon("remove")),
      textOutput("text_new_option"),
      br(),
      helpText("The premium is automatically calculated for a given volatility\n",
               "and for an underlying currently worth ₹100.")
    ),
    mainPanel = mainPanel(
      tabsetPanel(
        tabPanel("Theory",
                 htmlOutput("payoff_theory")),
        tabPanel("Figure",
                 plotOutput("p_payoffs")
        ),
        tabPanel("Data",
                 DT::dataTableOutput("t_option_basket")
        )
      )
    )
  )
  
}
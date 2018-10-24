# main_file for the main-tabs 
main_ui <- shinyUI(
  navbarPage("Classroom Computational Finance",
             tabPanel("Payoff",
                      payoff_ui()
             ),   
             tabPanel("Valuation", 
                      valuation_ui()
             ),
             tabPanel("Random Walks",
                      randomwalk_ui()
             ),
            # tabPanel("Price and the Greeks",
            #          greek_ui()
            # ),
             tabPanel("Geometric Browian Motion",
                      geometricbrownian_ui()
             ),
             tabPanel("American Option Pricing",
                      americanoption_ui()
             ),
             tabPanel("About",
                       #helpText("v 0.1 @ 2017", br())
                       about_ui()
                                )
  )
)
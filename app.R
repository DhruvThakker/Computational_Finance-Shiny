########################################################################
# PACKAGES and FUNCTIONS #
########################################################################

# if necessary install the following packages with:
# pkgs <- c("data.table", "DT", "ggplot2", "knitr", "magrittr", "rmarkdown", 
#           "RQuantLib", "shiny")
# install.packages(pkgs)

library(data.table)
library(DT)
library(ggplot2)
library(knitr)
library(magrittr)
library(rmarkdown)
library(shiny)

library(fOptions)
library(sde)
source("R/functions.R")

# uncomment this if the text-files should be recompiled
# rmdfiles <- c("files/about.Rmd", "files/text_intro_options.Rmd", "files/text_intro_valuation.Rmd")
# sapply(rmdfiles, knit, quiet = T)
# sapply(rmdfiles, render, quiet = T)

########################################################################
# UI #
########################################################################

#Payoff UI
source("UI/payoffUi.R")

#Greek UI
source("UI/greekUi.R")

#Valuation UI
source("UI/valuationUi.R")

#Random Walk UI
source("UI/randomwalkUi.R")

#Brownian UI
source("UI/geometricbrownianUi.R")

#American Option UI
source("UI/americanoptionUi.R")

#About UI
source("UI/aboutUi.R")

#Main UI
source("UI/mainUi.R")



########################################################################
# SERVER #
########################################################################

source("R/server.R")

########################################################################
# RUN APP #
########################################################################

shinyApp(main_ui, server_fun)
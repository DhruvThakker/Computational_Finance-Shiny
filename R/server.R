server_fun <- function(input, output, session) {
  # init ----
  output$payoff_theory <- renderUI({includeHTML("files/text_intro_options.html")})
  output$price_theory <- renderUI({includeHTML("files/text_intro_valuation.html")})
  empty_dt_positions()
  render_plot1(output = output)
  render_positions_table(output)
  output$text_new_option <- renderText("")
  
  # Observe Events Basket ----
  observeEvent(input$BT_basket_new_option, {
    cat("New Option!\n")
    opt.dir <- input$I_basket_dir
    opt.type <- input$I_basket_type
    opt.strike <- input$I_basket_strike 
    
    opt.dir <- ifelse(opt.dir == 1, "Long", "Short")
    
    if (opt.type == 1) {
      opt.type <- "Call"
    } else if (opt.type == 2) {
      opt.type <- "Put"
    } else if (opt.type == 3) {
      opt.type <- "Underlying"
      opt.strike <- 100
    }
    
    if (opt.type != "Underlying") {
      cat(tolower(opt.type))
      opt.premium <- fEuropean(type = tolower(opt.type),
                               underlying = 100,
                               strike = opt.strike,
                               dividendYield = 0,
                               riskFreeRate = 0,
                               maturity = 1,
                               volatility = 0.2)[["value"]] %>% round(4)
    } else {
      opt.premium <- 0
    }
    
    tmp <- data.table(name = paste0(opt.dir, " ", 
                                    opt.type, " ", 
                                    opt.strike),
                      type = opt.type,
                      dir = opt.dir,
                      strike = opt.strike,
                      premium = opt.premium)
    
    dt.positions <<- rbindlist(list(dt.positions,
                                    tmp))
    cat("New Option registered!\n")
    plotPF(output)
    text_option <- paste("New", opt.type, "inserted, with a premium of", 
                         opt.premium)
    output$text_new_option <- renderText(text_option)
  })
  
  observeEvent(input$BT_basket_clear, {
    cat("clear!\n")
    # reset inputs!
    output$text_new_option <- renderText("files/text_intro_options.html")
    updateSliderInput(session, "I_basket_strike", value = 100)
    updateRadioButtons(session, "I_basket_dir", selected = 1)
    updateRadioButtons(session, "I_basket_type", selected = "Call")
    
    # reset data!
    empty_dt_positions()
    render_plot1(NA, output = output)
    render_positions_table(output)
  })
  
  # Single Options ----
  option <- reactive(data.table(type = ifelse(input$I_greek_type == 1, "call", 
                                              "put"),
                                dir = ifelse(input$I_greek_dir == 1, "long", 
                                             "short"),
                                strike = input$I_greek_strike,
                                underlying = input$I_greek_value_underlying,
                                maturity = input$I_greek_maturity,
                                dvd_yield = input$I_greek_dvd_yield / 100,
                                rf = input$I_greek_rf / 100,
                                vola = input$I_greek_vola / 100,
                                eu_am = ifelse(input$I_greek_eu_am == 1,
                                               "European", "American")))
  
  option_result <- reactive({
    dat <- option()
    
    if (dat$eu_am == "European") {
      fEuropean(type = dat$type,
                underlying = dat$underlying,
                strike = dat$strike,
                dividendYield = dat$dvd_yield,
                riskFreeRate = dat$rf,
                maturity = dat$maturity,
                volatility = dat$vola) %>% round(4)
    } else {
      fAmerican(type = dat$type,
                underlying = dat$underlying,
                strike = dat$strike,
                dividendYield = dat$dvd_yield,
                riskFreeRate = dat$rf,
                maturity = dat$maturity,
                volatility = dat$vola) %>% round(4)
    }
  })
  
  greek_plot_data <- reactive({
    dat <- option()
    
    var <- input$I_greek_var
    
    val <- dat[, var, with = F] %>% as.numeric()
    
    input_parameters <- data.table(var = var,
                                   val_min = round(val * 0.75, 4),
                                   val_max = round(val * 1.25, 4))
    
    # no values for the american option.. return emtpy dt
    if (input$I_greek_eu_am == 2) {
      n0 <- numeric(0)
      pdat <- data.table(xvar = n0, xval = n0, yvar = n0, yval = n0)
    } else {
      pdat <- sensitivityWrapper(input_parameters, dat)
    }
    
    return(pdat)
  })
  
  output$plot_greeks <- renderPlot({
    
    pdat <- greek_plot_data()
    cat(nrow(pdat))
    if (nrow(pdat) == 0) {
      empty_df <- data.frame(x = 0, y = 0, 
                             label = "Greeks currently not available for American Options")
      ggplot(empty_df, aes(x = x, y = y, label = label)) +
        geom_text() + theme_void()
    } else {
      ggplot(pdat[is.finite(yval)], aes(x = xval, y = yval)) + geom_line() + 
        theme_bw() + xlab(fUpper(pdat[1, xvar])) + 
        facet_wrap(~yvar, scales = "free") + ggtitle("The Greeks") +
        ylab("Value of the Greek") 
    }
  })
  
  interpretation <-  c("Value of the option",
                       "Sensitivity of the option value to a change in the underlying",
                       "Sensitivity of the option delta to a change in the underlying",
                       "Sensitivity of the option value to a change in the underlying's volatility",
                       "Sensitivity of the option value to a change in t, the remaining time to maturity",
                       "Sensitivity of the option value to a change in the risk-free interest rate",
                       "Sensitivity of the option value to a change in the dividend yield")
  
  df <- data.frame(greek = c("value", "delta", "gamma", "vega", "theta", "rho", "dividendRho"),
                   interpretation = interpretation)
  
  df_dt <- datatable(df, rownames = NA, colnames = c("Greek", "Interpretation"))
  
  output$greek_theory <- DT::renderDataTable(df_dt)
  
  output$text_single_result <- renderPrint(option_result())
  
  
  # Prices & Valuation
  
  #output$price_binomial <- renderPlot({
  #  create_tree(n_steps = input$euro_steps,
  #              type = ifelse(input$euro_type == 1, "call", "put"),
  #              s_0 = input$euro_stock, 
  #              u = input$euro_u, 
  #              k = input$euro_strike, 
  #              rf = input$euro_rate/100)
  #}, height = 700)
  
  output$euro_binomial=renderGrViz({
    x <- genlattice.european.reg(Asset=input$euro_stock, IntRate=input$euro_rate, Strike=input$euro_strike, NoSteps=input$euro_steps, U=input$euro_u, D=input$euro_d, Type=input$euro_type)
    y <- capture.output(dotlattice(x, digits=3))
    grViz(y)
  })

  bs_data <- reactive({
    list(
      type = input$I_bs_type,
      s0 = input$I_bs_value_underlying,
      k = input$I_bs_strike,
      r = input$I_bs_rf/100,
      ti = input$I_bs_maturity,
      s = input$I_bs_vola/100
    )
  })
  
  output$price_bs <- renderUI({
    text1 <- "The Black-Scholes formula predicts an option price for a European call option to be equal to
    $$ C = S_0 N(d_1) - Ke^{-rt} N(d_2) $$
    with
    $$ d_1 = \\frac{ln(S_o/Ke^{-rT})}{\\sigma \\sqrt{T}} $$
    and 
    $$ d_2 = d_1 - \\sigma \\sqrt{T}. $$

    The put option is priced using the put-call parity and is expected to be worth

    $$ P = Ke^{-rT} N(-d_2) - S_0N(-d_1). $$


    The result of the inputs from the left side are:
        "
        
        text2_call <- "$$ C = %.0f*N(%.03f) - %.0f e^{-%.03f * %.01f} * N(%.03f) = %.03f $$
    with 
    $$ d_1 = \\frac{ln(%.0f/%.0fe^{-%.03f*%.01f})}{%.03f\\sqrt{%.01f}} = %.03f, $$

    $$ d_2 = %.03f - %.03f \\sqrt{%.01f} = %0.3f, $$

    $$ N(d_1) = N(%.03f) = %.03f, $$
    and
    $$ N(d_2) = N(%.03f) = %.03f, $$
        "
    
    text2_put <- "$$ P = %.0fe^{%.03f*%.01f} * N(-%.03f) - %.0f * N(-%.03f) = %.03f $$
    with 
    $$ d_1 = \\frac{ln(%.0f/%.0fe^{%.03f*%.01f})}{%.03f\\sqrt{%.01f}} = %.03f $$

    $$ d_2 = %.03f - %.03f \\sqrt{%.01f} = %0.3f, $$

    $$ N(-d1) = N(%.03f) = %.03f, $$
    and
    $$ N(-d2) = N(%.03f) = %.03f, $$
        "
    
    s0 <- bs_data()$s0
    k <- bs_data()$k
    r <- bs_data()$r
    ti <- bs_data()$ti
    s <- bs_data()$s
    
    d1 <- (log(s0/(k*exp(-r*ti)))) / (s*sqrt(ti))
    d2 <-  d1 - s*sqrt(ti)
    n_d1 <-  pnorm(d1)
    n_d2 <- pnorm(d2)
    n_d1_minus <- pnorm(-d1)
    n_d2_minus <- pnorm(-d2)
    C <- s0*n_d1 - k * exp(-r*ti)*n_d2
    P <- k*exp(-r*ti)*n_d2_minus - s0*n_d1_minus
    
    if (bs_data()$type == 1) {
      withMathJax(
        sprintf(paste0(text1, text2_call), s0, d1, k, r, ti, d2, C, s0, k, r, ti, 
                s, ti, d1, d1, s, ti, d2, d1, n_d1, d2, n_d2))
    } else {
      withMathJax(
        sprintf(paste0(text1, text2_put), k, -r, ti, d2, s0, d1, P, s0, k, -r, ti,
                s, ti, d1, d1, s, ti, d2, -d1, n_d1_minus, -d2, n_d2_minus))
    }
  })
  
  #Random Walk 1D
  #output$random_1d <- renderUI({includeHTML("files/text_intro_valuation.html")})
  output$random_1d_plot <- renderPlot(
    {
      # Generate k random walks across time {0, 1, ... , T}
      T <- input$steps_1dr
      k <- input$walks_1dr
      initial.value <- input$x_position_1dr

      GetRandomWalk <- function(K=T,v=initial.value) {
        # Add a bionomial at each step
        samples = rbinom(K,1,0.5)
        samples[samples==0] = -1
        v + c(0, cumsum(samples))
      }

      # Matrix of random walks
      values <- replicate(k, GetRandomWalk())
      # Create an empty plot
      #dev.new(height=8, width=12)
      #print(values)

      plot(0:T, rep(NA, T + 1), main=sprintf("%s Random Walks", k),
          xlab="time", ylab="value",
          ylim=initial.value + ((T+10)/2) * c(-1, 1))
      mtext(sprintf("%s%s} with initial value of %s",
                    "Across time {0, 1, ... , ", T, initial.value))
      for (i in 1:k) {
        lines(0:T, values[ , i], lwd=0.7, col=i)
      }

    }
  )
  #Random Walk 2D
  resultRandom <- reactive({
    my_random_walk <- f1(input$steps)
    random_points <- c(input$x_position, input$y_position)
    start(my_random_walk) <- random_points
    set.seed(input$seed)
    my_random_walk
  })
  
  output$path_plot <- renderPlot({
    # plot of path_plot
    plot(resultRandom(),cex=input$size,pch="*",lwd=input$width,lty=2,col="#88888844")
    points(resultRandom()$trace[1,1],resultRandom()$trace[1,2],col="orange",cex=4,pch="*")
    points(tail(resultRandom()$trace,1)[1],tail(resultRandom()$trace,1)[2],col="red",cex=4,pch="*")
  })
  
  output$final <- renderText({
    paste("(",tail(resultRandom()$trace,1)[1],",",tail(resultRandom()$trace,1)[2],")")
  })

  #Random Walk 3D
  output$plot3d <- renderPlotly({
    
    k=input$steps_3dr
    xi=input$x_position_3dr
    yi=input$y_position_3dr
    zi=input$z_position_3dr
    GetRandomWalk <- function(K=k,v=0) {
        # Add a bionomial at each step
        samples = rbinom(K,1,0.5)
        samples[samples==0] = -1
        v + c(0, cumsum(samples))
    }
    x1 = GetRandomWalk(v=xi)
    y1 = GetRandomWalk(v=yi)
    z1 = GetRandomWalk(v=zi)
    plot_ly (
      type = 'scatter3d' ,
      name = '3d path',
      x = x1 ,
      y = y1 ,
      z = z1 ,
      mode = 'lines',
      line = list(color = 'rgba(49,130,189, 1)', width = 2) ) %>%
    add_trace(
      x = x1[1], 
      y = y1[1],
      z = z1[1], 
      type = 'scatter3d', 
      name = 'Start',
      mode = 'markers', 
      marker = list(color = 'rgba(49,130,189, 1)', size = 5)) %>%
    add_trace(
      x = x1[k+1], 
      y = y1[k+1],
      z = z1[k+1], 
      type = 'scatter3d',
      name = 'End', 
      mode = 'markers', 
      marker = list(color = 'rgba(67,67,67,1)', size = 5))
  })

  #Geometric Brownain Motion Start
  output$gbm_path_plot <- renderPlot(
    {
      mu=input$gbm_rate; sigma=input$gbm_volatility; P0=input$gbm_price; T = input$gbm_time/12
      nt=input$gbm_trajectories; n=input$gbm_steps
      #############Generate nt trajectories
      dt=T/n; t=seq(0,T,by=dt)
      X=matrix(rep(0,length(t)*nt), nrow=nt)
      for (i in 1:nt) {X[i,]= GBM(x=P0,r=mu,sigma=sigma,T=T,N=n)}
      ##Plot
      ymax=max(X); ymin=min(X) #bounds for simulated prices
      plot(t,X[1,],t='l',ylim=c(ymin, ymax), col=1,ylab="Price P(t)",xlab="Time t(years)")
      for(i in 2:nt){lines(t,X[i,], t='l',ylim=c(ymin, ymax),col=i)}
    }
  )
  #Geometric Brownain Motion End

  #American Binomial Begin
  output$amer_binomial=renderGrViz({
    x <- genlattice.american.reg(Asset=input$amer_stock, IntRate=input$amer_rate, Strike=input$amer_strike, NoSteps=input$amer_steps, U=input$amer_u, D=input$amer_d, Type=input$amer_type)
    y <- capture.output(dotlattice(x, digits=3))
    grViz(y)
  })
  #American Binomail End
  #About Page
  output$about_page <- renderUI({includeHTML("files/about.html")})

}
calcPF <- function(dt.positions, xmin = 80, xmax = 120) {
  
  res <- lapply(1:nrow(dt.positions), function(i) {
    x <- xmin:xmax
    op <- dt.positions[i]
    s <- op[, strike]
    
    vals <- switch(toupper(op[, type]),
                   "CALL" = {
                     ifelse(x < s, 0, x - s)
                   },
                   "PUT" = {
                     ifelse(x < s, s - x, 0)
                   },
                   "UNDERLYING" = x - s)
    
    op.vals <- data.table(x = x,
                          name = op[, name],
                          type = op[, type],
                          dir = op[, dir],
                          strike = s,
                          premium = op[, premium],
                          payoff = op[, toupper(dir) == "LONG"]*vals - 
                            op[, toupper(dir) == "SHORT"]*vals)
    
    op.vals[, profit := payoff + ifelse(op[, toupper(dir) == "LONG"], 
                                        -premium, 
                                        premium)]
    
    return(op.vals)
  }) %>% rbindlist
  # Calculate total
  
  tot <- res[, .(name = "Net Position", type = "NET", dir = NA, strike = NA, 
                 premium = sum(premium), payoff = sum(payoff),
                 profit = sum(profit)),
             by = c("x")]
  
  res <- rbindlist(list(tot, res))
  return(res)  
}
plotPF <- function(output) {
  gg_color_hue <- function(n) {
    hues <- seq(15, 375, length = n + 1)
    hcl(h = hues, l = 65, c = 100)[1:n]
  }
  fUpper <- function(x){
    u <- toupper(substr(x, 1, 1))
    l <- tolower(substr(x, 2, nchar(x)))
    paste0(u,l)
  }
  
  basket <- dt.positions
  xvals <- basket$strike
  
  dt.vals <- calcPF(basket, xmin = 0.75*min(xvals), xmax = 1.25*max(xvals))
  
  dt.vals[, ':=' (name = ifelse(toupper(type) == "UNDERLYING",
                                paste(type, dir),
                                ifelse(toupper(type) == "NET",
                                       "Net Position", 
                                       paste(dir, type, strike, 
                                             paste0("(",premium,")")
                                             )
                                       )
                                )
                  )
          ]
  
  adj_names <- sort(dt.vals[!name %in% c("Net Position"), unique(name)])
  
  values <- gg_color_hue(length(adj_names))
  names(values) <- adj_names
  values <- c(c('Net Position' = "#000000"), values)
  
  linetypes <- rep("solid", length(adj_names))
  names(linetypes) <- adj_names
  linetypes <- c(c('Net Position' = "dashed"), linetypes)
  
  plot1 <- ggplot(dt.vals, aes(x = x, y = profit, 
                               color = name,
                               linetype = name)) +
    geom_hline(yintercept = 0, col = "grey") +
    geom_line(alpha = 0.5) + theme_bw() + 
    ggtitle("Profit/losses") + 
    xlab("Value of the Underlying Asset") + ylab("Profit/Loss") +
    scale_color_manual(name = "", values = values, 
                       breaks = c("Net Position", adj_names)) +
    scale_linetype_manual(name = "", values = linetypes,
                          breaks = c("Net Position", adj_names))
  
  render_plot1(plot1, output)
  render_positions_table(output)
  T
}
render_positions_table <- function(output) {
  output$t_option_basket <- DT::renderDataTable(dt.positions[, .(Type = type, 
                                                             Position = dir,
                                                             Strike = strike, 
                                                             Premium = premium)])
  
}
render_plot1 <- function(plot1 = NA, output) {
  
  if (!is.ggplot(plot1)){
    plot1 <- ggplot() + 
      annotate("text", x = 1, y = 1, label = "Empty Basket") + 
      theme_bw() + ggtitle("Profit/losses") + 
      xlab("Value of the Underlying Asset") + ylab("Profit/Loss")
  }
  
  output$p_payoffs <- renderPlot(plot1)
  
}
empty_dt_positions <- function(){
  dt.positions <<- data.table(name = numeric(0),
                              type = numeric(0),
                              dir = numeric(0),
                              strike = numeric(0),
                              premium = numeric(0))
}
fUpper <- function(x) {
  one <- toupper(substr(x, 1, 1))
  two <- substr(x, 2, nchar(x))
  return(paste0(one, two))
}
sensitivityInputs <- function(dat, var, val_min, val_max, n_vals = 100) {
  xvals <- seq(from = val_min, to = val_max, length.out = n_vals)
  
  res <- lapply(xvals, function(value) {
    r_type <- dat$type
    r_underlying <- dat$underlying
    r_strike <- dat$strike
    r_dvd_yield <- dat$dvd_yield
    r_rf <- dat$rf
    r_maturity <- dat$maturity
    r_vola <- dat$vola
    
    assign(paste0("r_", var), value)
    if (dat$eu_am == "European") {
      # tmp <- EuropeanOption(type = r_type,
      #                       underlying = r_underlying,
      #                       strike = r_strike,
      #                       dividendYield = r_dvd_yield,
      #                       riskFreeRate = r_rf,
      #                       maturity = r_maturity,
      #                       volatility = r_vola) %>% as.numeric
      
      tmp <- fEuropean(type = r_type,
                            underlying = r_underlying,
                            strike = r_strike,
                            dividendYield = r_dvd_yield,
                            riskFreeRate = r_rf,
                            maturity = r_maturity,
                            volatility = r_vola) %>% as.numeric
    } else {
      # tmp <- AmericanOption(type = r_type,
      #                       underlying = r_underlying,
      #                       strike = r_strike,
      #                       dividendYield = r_dvd_yield,
      #                       riskFreeRate = r_rf,
      #                       maturity = r_maturity,
      #                       volatility = r_vola,
      #                       engine = "CrankNicolson") %>% as.numeric
      tmp <- fAmerican(type = r_type,
                            underlying = r_underlying,
                            strike = r_strike,
                            dividendYield = r_dvd_yield,
                            riskFreeRate = r_rf,
                            maturity = r_maturity,
                            volatility = r_vola) %>% as.numeric
    }
    names(tmp) <- c("value", "delta", "gamma", "vega", "theta", "rho")
    # names(tmp) <- c("value", "delta", "gamma", "vega", "theta", "rho", "divRho")
    data.table(t(tmp))
  }) %>% rbindlist
  
  res[, var := xvals, with = F]
  
  return(res)
}
sensitivityWrapper <- function(input_params, dat) {
  
  res <- apply(input_params, 1, function(row_el) {
    sensitivityInputs(dat = dat, 
                      var = row_el["var"], 
                      val_min = as.numeric(row_el["val_min"]),
                      val_max = as.numeric(row_el["val_max"]), 
                      n_vals = 100)
  })
  
  tmp <- lapply(res, function(el) {
    var <- names(el)[ncol(el)]
    
    tm <- melt(el, id.vars = var, variable.name = "yvar", value.name = "yval")
    tm[, xvar := var]
    setnames(tm, var, "xval")
    setcolorder(tm, c("xvar", "xval", "yvar", "yval"))
    return(tm)
  }) %>% rbindlist
  
  return(tmp)
  
}


###############
# Binomial Tree
###############
get_edges <- function(n_steps) {
  res <- lapply(0:n_steps, function(t) {
    x_start <- t - 1
    x_end <- t
    y_end <- seq(from = t, to = -t, by = -2)
    
    y_start <- y_end - 1
    
    y_start <- y_start[-length(y_start)]
    
    if (t > 0) {
      values <- data.table(xs = x_start,
                           xe = x_end,
                           ys = rep(y_start, length(y_end)), 
                           ye = rep(y_end, length(y_start)))[abs(ys - ye) < 2]
    } else {
      nu <- numeric(0)
      values <- data.table(xs = nu,
                           xe = nu,
                           ys = nu,
                           ye = nu)
    }
    
    return(values)
  })
  return(rbindlist(res))
}
get_nodes <- function(n_steps) {
  res <- lapply(0:n_steps, function(t) {
    x <- t
    y <- seq(from = t, to = -t, by = -2)
    
    return(data.table(x = x, y = y))
  })
  res2 <- rbindlist(res)
  
  return(res2)
}
create_tree <- function(n_steps, type = "call", s_0 = 100, u = 0.5, k = 100, rf = 0.1) {
  
  edges <- get_edges(n_steps)
  nodes <- get_nodes(n_steps)
  U = 1+u/100
  D = 1-u/100
  qu = ((1+rf)-D)/(U-D)
  qd = (U-(1+rf))/(U-D)
  nodes[, s_t := ifelse(y>0, U^y*s_0, D^(-y)*s_0)]
  #nodes[, s_t := y*tick + s_0]
  
  if (type == "call") {
    nodes[x == max(x), c_t := ifelse(s_t > k, s_t - k, 0)]
  } else if (type == "put") {
    nodes[x == max(x), c_t := ifelse(s_t < k, k - s_t, 0)]
  } else {
    stop("Unknown type, only 'call'/'put' allowed!")
  }
  
  nodes[, ':=' (delta = NA, b = NA)]
  
  for (lvl in (max(nodes$x) - 1):0) {
    tmp <- nodes[x == lvl]
    
    nodes_up <- nodes[x == lvl + 1][, .(y = y - 1, c_u = c_t, s_u = s_t)]
    nodes_down <- nodes[x == lvl + 1][, .(y = y + 1, c_d = c_t, s_d = s_t)]
    
    tmp <- merge(tmp, nodes_up, by = "y", all.x = T)
    tmp <- merge(tmp, nodes_down, by = "y", all.x = T)
    tmp[, delta := (c_u - c_d) / (s_u - s_d)]
    tmp[, b := (c_d - s_d * delta) / (1 + rf)]
    tmp[, c_t := (qu*c_u + qd*c_d)*(1+rf)]
    nodes <- rbindlist(list(tmp[, .(x, y, s_t, c_t, delta, b)],
                            nodes[x != lvl,]))
  }
  
  nodes[, label := paste("S[t] = ", s_t, 
                         #"\nDelta = ", round(delta, 4),
                         #"\nB = ", round(b, 4),
                         "\nC[t] = ", round(c_t, 4),
                         "\nqu = ", round(U,4))
                         ]
  
  ggplot() + 
    theme_void() +
    geom_segment(data = edges, aes(x = xs, xend = xe, y = ys, yend = ye)) + 
    geom_label(data = nodes, 
               aes(x = x, y = y, label = label), fill = "white") + # parse = T
    geom_label(data = data.table(x = 0:max(nodes$x), y = max(nodes$y) + 1, 
                                 lab = paste0("t = ", 0:max(nodes$x))),
               aes(x = x, y = y, label = lab), fill = "white") +
    scale_y_continuous(limits = c(-1,1) + range(nodes$y))
  
}

fEuropean <- function(type, underlying, strike, dividendYield, riskFreeRate, maturity, volatility) {
  type <- tolower(type)
  stopifnot(type %in% c("call", "put"))
  
  val <- GBSOption(TypeFlag = substr(type, 1, 1), S = underlying, X = strike, Time = maturity, r = riskFreeRate, 
                   b = riskFreeRate - dividendYield, sigma = volatility)
  price <- val@price
  
  greeks <- c("delta", "gamma", "vega", "theta", "rho")
  greek_res <- lapply(greeks, function(greek) {
    GBSGreeks(Selection = greek, TypeFlag = substr(type, 1, 1), S = underlying, X = strike, Time = maturity, 
              r = riskFreeRate, b =  riskFreeRate - dividendYield, sigma = volatility)
  })
  names(greek_res) <- greeks
  return(c(value = price, unlist(greek_res)))
}

fAmerican <- function(type, underlying, strike, dividendYield, riskFreeRate, maturity, volatility) {
  type <- tolower(type)
  stopifnot(type %in% c("call", "put"))
  
  val <-  BAWAmericanApproxOption(TypeFlag = substr(type, 1, 1), S = underlying, X = strike, Time = maturity, 
                                  r = riskFreeRate, b = riskFreeRate - dividendYield, sigma = volatility)
  price <- val@price
  
  greeks <- c("delta", "gamma", "vega", "theta", "rho")
  greek_res <- rep(NA, length(greeks))
  names(greek_res) <- greeks
  return(c(value = price, unlist(greek_res)))
}

################# 2D Random Walk #########################
check_x <- function(x){
  # This function is used to check the input is a valid integer
  if(x<=0){stop("steps must be greater than zero")}
  if(x%%1!=0){stop("steps must be an integer")}
  TRUE
}
RandomWalk2d_oop <- function(step,result=0){
  # This function is used to generate random walk in two space dimensions without for loop. 
  # It is almost same with the function in question 3. 
  # But this time, we need to return start position and samples 
  # in order to calculate how many step the point move to each direction.
  
  # steps : the number of steps to be taken. 
  # result : what kind of result you want to get.
  # 0 output the final position. 1 output the full path.
  
  # When result = 0, the function will generate the final position.
  # When result = 1, the function will generate a list including start point, 
  # sample steps and trace in order to be used in oop function
  
  check_x(step)
  # check steps to make sure all steps are positive integer
  samples <- matrix(0, ncol = 2, nrow = step)
  position <- matrix(0, ncol = 2, nrow = step)
  index_xy <- cbind(seq(step),sample(c(1,2),step,TRUE))  
  samples[index_xy] <- sample(c(-1,1),step,TRUE) 
  # do the random sampling at one time instead of using for loop
  position[,1] <- cumsum(samples[,1])
  position[,2] <- cumsum(samples[,2])
  trace <- cbind(position[,1],position[,2])
  trace <- rbind(c(0,0),trace)
  final_position <- tail(trace,1)
  if(result==0){
      return(final_position)
    }
    if(result==1){
      return(list(
        start = c(0,0),
        samples = samples,
        trace = trace))
    }
}
f1 <- function(step){
  # This function is used to generate S3 class "RandomWalk"
  
  # steps : the number of steps to be taken. 
  # result : what kind of result you want to get. 
  # The output will be a class of "RandomWalk". 
  
  # Method: 
  # summary: print out the start position, final position 
  #          and how many steps move to each directions 
  # plot: print the full path in a plot
  # "[": extract value from trace to print out the position of the i-th step
  # "[<-": move the origin and the entire walk
  Random_Walk <- RandomWalk2d_oop(step, result = 1)
  final <- list(
    start = Random_Walk$start,
    samples = Random_Walk$samples,
    trace = Random_Walk$trace,
    right = sum(Random_Walk$samples[,1]==1),
    left = sum(Random_Walk$samples[,1]==-1),
    up = sum(Random_Walk$samples[,2]==1),
    down = sum(Random_Walk$samples[,2]==-1)
  )
  class(final) <- "RandomWalk"
  final
}
summary.RandomWalk <- function(object){
  # summary method
  structure(object, class=c("summary.RandomWalk", class(object)))
}
print.summary.RandomWalk <- function(x,...){
  # summary print method
  cat('object "RawndomWalk"\n')
  start <- paste("(",x$start[1],",",x$start[2], ")",sep="")
  cat("The start point is :", start, "\n")
  display <- paste("(",tail(x$trace,1)[1],",",tail(x$trace,1)[2],")",sep = "")
  cat("The final position is :", display,"\n")
  cat(x$right,"steps move to right", "\n")
  cat(x$left,"steps move to left", "\n")
  cat(x$up,"steps move to up", "\n")
  cat(x$down,"steps move to down", "\n")
  cat("The total steps is", sum(x$right,x$left,x$up,x$down) ,"\n" )
  invisible(x)
}
plot.RandomWalk <- function(x, ...){
  # plot method
  plot(x$trace,type="l")
}
"[.RandomWalk" <- function(x,i){
  # extract method
  x$trace[i,]
}
check_value <- function(value){
  # This function is used to check the whether the input is a 2-dim vector with integer values
  if(length(value)>2|length(value)<2){stop("'value' must have exact two values")}
  if(value[1]%%1!=0|value[2]%%1!=0){stop("'value' must be two integer")}
  TRUE
}
"start<-" <- function(x,value){
  check_value(value)
  x$start=x$start+value
  x$trace[,1] <- x$trace[,1]+value[1] 
  x$trace[,2] <- x$trace[,2]+value[2]
  return(x)
}
start <-  function(x,value) UseMethod("start<-")
#my_walk <- f1(500) 
#summary(my_walk)

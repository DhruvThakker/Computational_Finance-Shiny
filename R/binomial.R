dotlattice <- function(S, digits=2) {
  
  shape <- "plaintext"
  
  cat("digraph G {", "\n", sep="")
  cat("node[shape=",shape,"];","\n", sep="")
  cat("rankdir=LR;","\n")
  
  cat("edge[arrowhead=none];","\n")
  
  # Create a dot node for each element in the lattice
  for (i in 1:nrow(S)) {
    x <- round(S$asset[i], digits=digits)
    y <- round(S$option[i], digits=digits)
    
    # Detect the American tree and draw accordingly
    early.exercise <- ""
    if (("exercise" %in% colnames(S)) && S$exercise[i]) {
      early.exercise <- "shape=oval,"
    }
    
    cat("node", i, "[", early.exercise, "label=\"", x, ", ", y, "\"];", "\n", sep="")
  }
  
  # The number of levels in a binomial lattice of length N
  # is `$\frac{\sqrt{8N+1}-1}{2}$`
  L <- ((sqrt(8*nrow(S)+1)-1)/2 - 1)
  
  k<-1
  for (i in 1:L) {
    tabs <- rep("\t",i-1)
    j <- i
    while(j>0) {
      cat("node",k,"->","node",(k+i),";\n",sep="")
      cat("node",k,"->","node",(k+i+1),";\n",sep="")
      k <- k + 1
      j <- j - 1
    }
  }
  
  cat("}", sep="")
}

payoff.vanilla.call <- function(Asset, Strike) {
  return( max(0, Asset - Strike) )
}

payoff.vanilla.put <- function(Asset, Strike) {
  return( max(0, Strike - Asset) )
}

genlattice.european.reg <- function(Asset, Strike, IntRate, NoSteps, U, D, Type) {
  
  # The number of tree nodes to process.
  count <- sum(1 : (NoSteps+1))
  
  # This data frame will store asset and option prices.
  # The mapping from tree node (i,j) to linear index
  # inside the data frame will have to be computed.
  X <- data.frame(matrix(NA, nrow=count, ncol=2))
  names(X) <- c("asset", "option")
  
  u = U
  d = D
  r = IntRate
  k = Strike

  q_u = (1+r-d)/(u-d)
  q_d = (u-1-r)/(u-d)

  Payoff = payoff.vanilla.call

  if(Type == 2)
  Payoff = payoff.vanilla.put
  
  # Compute the asset and option prices, starting 
  # from the last node of the tree, which is
  # its bottom right corner when viewed as a graph.
  # Work up and backwards. Backwards, comrades!
  for (i in NoSteps:0) {
    for (j in i:0) {
      X$asset[count] <- Asset * u^(i-j) * d^j
      # Compute the payoff directly for the last step's nodes,
      # otherwise use a formula.
      if (i == NoSteps) {
        X$option[count] <- Payoff(X$asset[count], Strike)
      } else {
        X$option[count] <- (q_u * X$option[count+i+1] + q_d * X$option[count+i+2])*(1/(1+r))
        #cat("Count is: ",count,'Price',X$option[count], '1',X$option[count+i+1],'2',X$option[count+i+2])
      }
      
      count <- count - 1
    }
  }
  
  return(X)
}

genlattice.american.reg <- function(Asset, Strike, IntRate, NoSteps, U, D, Type) {
  
  # The number of tree nodes to process.
  count <- sum(1 : (NoSteps+1))
  
  # This data frame will store asset and option prices.
  # The mapping from tree node (i,j) to linear index
  # inside the data frame will have to be computed.
  X <- data.frame(matrix(NA, nrow=count, ncol=2))
  names(X) <- c("asset", "option")
  
  u = U
  d = D
  r = IntRate
  k = Strike

  q_u = (1+r-d)/(u-d)
  q_d = (u-1-r)/(u-d)
  
  Payoff = payoff.vanilla.call

  if(Type == 2)
  Payoff = payoff.vanilla.put
  
  # Compute the asset and option prices, starting 
  # from the last node of the tree, which is
  # its bottom right corner when viewed as a graph.
  # Work up and backwards. Backwards, comrades!
  for (i in NoSteps:0) {
    for (j in i:0) {
      X$asset[count] <- Asset * u^(i-j) * d^j
      # Compute the payoff directly for the last step's nodes,
      # otherwise use a formula.
      if (i == NoSteps) {
        X$option[count] <- Payoff(X$asset[count], Strike)
      } else {
        X$option[count] <- (q_u * X$option[count+i+1] + q_d * X$option[count+i+2])*(1/(1+r))
        X$option[count] <- max(Payoff(X$asset[count], Strike),X$option[count])
        #cat("Count is: ",count,'Price',X$option[count], '1',X$option[count+i+1],'2',X$option[count+i+2])
      }
      
      count <- count - 1
    }
  }
  
  return(X)
}
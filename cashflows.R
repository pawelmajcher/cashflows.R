# cashflows.R 0.2.1
# a list of useful functions for calculating and presenting cashflows in R
# the file is updated from time to time so periodically check for updates

# copyright 2020
# Paweł Majcher

cashflow <- function(payments, periods=1:length(payments)) {
  
  if (length(payments) != length(periods)) {
    stop("The length of the vector of payments doesn't match the length of the vector of periods")
  }
  
  orderedPeriods = sort(periods[!duplicated(periods)])
  orderedPayments = c()
  
  for (period in orderedPeriods) {
    orderedPayments = c(orderedPayments, sum(payments[periods==period]))
  }
  
  orderedPeriods=orderedPeriods[orderedPayments!=0]
  orderedPayments=orderedPayments[orderedPayments!=0]
  
  orderedPeriods=orderedPeriods[!is.na(orderedPayments)]
  orderedPayments=orderedPayments[!is.na(orderedPayments)]
  
  list(payments=orderedPayments, periods=orderedPeriods)
}

cfmerge <- function(...) {
  payments=c()
  periods=c()
  
  for (CF in list(...)) {
    payments=c(payments, CF$payments)
    periods=c(periods, CF$periods)
  }
  
  cashflow(payments=payments, periods=periods)
}

cfmatrix <- function(cf, vertical=FALSE) {
  new_matrix = matrix(c(cf$periods, cf$payments), nrow=2, byrow = TRUE)
  rownames(new_matrix) = c("Period","Amount")
  colnames(new_matrix) = paste("Payment", 1:length(cf$periods))
  if (vertical) {
    new_matrix = t(new_matrix)
  }
  return(new_matrix)
}

annuity <- function(period, amount=1, due=FALSE) {
  if (period==Inf) {period=10000}
  if (due==TRUE) {periods=0:(period-1)} else {periods=1:period}
  cashflow(payments = rep(amount, times=period), periods = periods)
}

bond <- function(principal, maturity, couponRate=0, boughtFor=0) {
  if (length(couponRate)==1) {couponRate = rep(couponRate, times=maturity)}
  
  if (length(couponRate)!=maturity) {
    stop("Coupon rate vector doesn't have the correct length (1 or maturity)")
  }
  
  cfmerge(cashflow(payments = principal*couponRate),
                 cashflow(payments = principal, periods = maturity),
                 cashflow(payments = -boughtFor, periods = 0))
}

timevalue <- function(cf, v=NA, i=NA, t=0, as.cashflow=FALSE) {
  if(any(is.na(v)) & all(!is.na(i))) { v=1/(1+i) }
  
  if (length(v)==1) {v=rep(v, times=length(cf$payments))}
  
  if (length(v)!=length(cf$payments)) {
    stop("The discount factor vector does not have correct length")
  }
  
  cf$periods = cf$periods - t
  cf$payments = cf$payments * v^cf$periods
  cf$periods = cf$periods + t
  
  cf = cashflow(cf$payments, periods = cf$periods)
  
  if (as.cashflow) { return(cf) } else { return( sum(cf$payments) ) }
}

presentvalue <- function(cf, v=NA, i=NA, as.cashflow=FALSE) {
  timevalue(cf=cf, v=v, i=i, t=0, as.cashflow = as.cashflow)
}

simpletimevalue <- function(cf, i, method=NA, t=0, as.cashflow=FALSE) {
  if (t==0) { method="e" }
  #method doesn't matter when t==0, but prevents from raising error
  
  if (method=="e") {
    cf$payments = cf$payments / (1 + i*cf$periods)
    cf$payments = cf$payments * (1 + i*t)
  } else if (method=="rp") {
    cf$periods = cf$periods - t
    cf$payments[cf$periods>0] = cf$payments[cf$periods>0] / (1 + i*cf$periods[cf$periods>0])
    cf$payments[cf$periods<0] = cf$payments[cf$periods<0] * (1 + -1*i*cf$periods[cf$periods<0])
    cf$periods = cf$periods + t
  } else {
    stop("The method of calculating the value of the cash flow has not been chosen")
  }
  
  cf = cashflow(cf$payments, periods = cf$periods)
  
  if (as.cashflow) { return(cf) } else { return( sum(cf$payments) ) }
}
# ---
#   title: "Directional Trading"
# author: "Dayanara M. Diaz Vargas"
# date: "2/28/2021"
# output: html_document
# ---
  
  # Introduction
  
#   Directional trading is trading when the instrument is trending up or down or, in other
# words, continuation in the trend as like historical winners are expected to be winners and
# historical losers are expected to lose. You bet on the direction of the instrument and you aim
# for buying at a low price and selling at a high price. 



# Step 1: Import dataset

# I like to analyze GOOGLE stock, so the analysis will circle around that.




# set working directory 
setwd("C:/Users/ddaya/OneDrive/Data Science Portfolio/Quantitative Finance/Algortihmic Trading")
# import dataset
library(quantmod)
getSymbols("GOOGL",src="yahoo") # confirm if this is the GOOGLE data
GOOGLE<- GOOGL[,"GOOGL.Close"] # choose the closing price of the stock
class(GOOGLE) # with this, we confirm that our class is "xts", and "zoo" means that GOOGLE
# stock is in time index format
GOOGLE<- GOOGLE[(index(GOOGLE) >= "2015-01-01" & index(GOOGLE) <= "2020-12-31"),] 
head(GOOGLE)



# Step 2: Clean dataset

# Generate the daily arithmetic return of the stock.
# We will use the "Delt" function from the "Quantmode" package, to calculate the k-period percent difference within one series. 

# Arithmetic differences are used by default: Lag = (x2(t) - x1(t-k))/x1(t-k)

# **Note**:
#  *Arithmetic average* return is the return on investment calculated by simply adding the returns for all sub-periods and then dividing it by total number of periods. It overstates the true return and is only appropriate for shorter time periods.

# The arithmetic average return is always higher than the other average return measure called the geometric average return. The arithmetic return ignores the compounding effect and order of returns and it is misleading when the investment returns are volatile.


ret_GOOGLE<- Delt(GOOGLE,k=1, type="arithmetic") # converts the raw closing prices to return and by default with 1 lag 
head(ret_GOOGLE)




# To calculate the log difference, we apply this formula:  Lag = log(x2(t)/x1(t-k))

# **Note**:
#  *log return* is better for our stock analysis, because it provides us a return that acknowledges the compounding effect. That is, for a stock growing from $100 to $105, this yields a log return of 4.88%. For small returns, arithmetic and logarithmic returns will be similar, but, as returns get further away from zero, these two formulations will produce increasingly different answers.If one is modeling the stock market, it is common to assume that returns are normally distributed. In this context, log returns are far superior to arithmetic returns since the sum of repeated samples from a normal distribution is normally distributed. However, the product of repeated samples from a normal distribution is not normally distributed.

# Thus, the compound return over n periods is merely the difference in log between initial and final periods.



log_ret_GOOGLE<- Delt(GOOGLE,k=1, type="log") # converts the raw closing prices to return and by default with 1 lag 
head(log_ret_GOOGLE)




## Step 3: Explore dataset

plot(GOOGLE)



# We can notice how the stock has increased for more than $1000.00 during the last 5 years. We can also observe the dates when the price dropped. Notice that the price has a steep decline between mid February - beginning of April. This reflects the global stock market crash that began on February 20th, 2020 and ended on April 7th, 2020.


# Descriptive Statistics

summary(log_ret_GOOGLE)



# From the table above, we can see that the median is positive, so we can say that we have more days with positive returns than days were the stock is negative.


plot(log_ret_GOOGLE)


# We can see that the days with the biggest return took place around the summer of 2015, and the return was about 15%. Moreover, we can also notice that the most common return is positive, between 0%-3%.


# Step 4: Create Backtest datasets
# To understand the generalization capacity of the model and for that we should divide the dataset in two smaller datasets, one dataset consisting of 70-80% of the data and the second dataset
# consisting of the remaining 20-30% of the data. The first dataset is called the in-sample
# dataset and the second is called the out-sample dataset. 

# We should use in-sample data to backtest our strategy, estimate the optimal set of parameters, and evaluate its performance. The optimal set of parameters has to be applied on out-sample data to understand the generalization capacity of rules and parameters. If the performance on out-sample data is pretty similar to in-sample data, we assume the parameters and rule set have good generalization power and
# can be used for live trading.



# Backtest dates
in_sd<- "2015-01-01" # start date of in-sample data
in_ed<- "2019-12-31" # end date of out-of-sample data
out_sd<- "2020-01-01" # start date of out-of-sample data
out_ed<- "2020-12-31" # end date of out-of-sample data

# generate Backtest datasets
in_GOOGLE<- GOOGLE[(index(GOOGLE) >= in_sd& index(GOOGLE) <= in_ed),] # in-sample GOOGLE stock price
in_ret_GOOGLE<- log_ret_GOOGLE[(index(log_ret_GOOGLE) >= in_sd& index(log_ret_GOOGLE) <= in_ed),] # in-sample GOOGLE stock return
out_GOOGLE<- GOOGLE[(index(GOOGLE) >= out_sd& index(GOOGLE) <= out_ed),] #Out-of-sample GOOGLE stock price
out_ret_GOOGLE<- log_ret_GOOGLE[(index(log_ret_GOOGLE) >= out_sd& index(log_ret_GOOGLE) <=out_ed),] # Out-of-sample GOOGLE stock return




# Step 5: Generate automated trading signals

# I will use moving average convergence divergence (MACD) and Bollinger band indicators
# to generate automated trading signals.


### Notes


# ***MACD***: Moving average convergence divergence (MACD) is a trend-following momentum indicator that shows the relationship between two moving averages of a security's price. The MACD is calculated by subtracting the 26-period exponential moving average (EMA) from the 12-period EMA.

# The result of that calculation is the MACD line. A nine-day EMA of the MACD called the "signal line," is then plotted on top of the MACD line, which can function as a trigger for buy and sell signals. Traders may buy the security when the MACD crosses above its signal line and sell-or short-the security when the MACD crosses below the signal line. Moving average convergence divergence (MACD) indicators can be interpreted in several ways, but the more common methods are crossovers, divergences, and rapid rises/falls.


# ***Bollinger Band***: A Bollinger Band� is a technical analysis tool defined by a set of trendlines plotted two standard deviations (positively and negatively) away from a simple moving average (SMA) of a security's price, but which can be adjusted to user preferences.


# Bollinger Bands� were developed and copyrighted by famous technical trader John Bollinger, designed to discover opportunities that give investors a higher probability of properly identifying when an asset is oversold or overbought.

# Bollinger Bands� are a highly popular technique. Many traders believe the closer the prices move to the upper band, the more overbought the market, and the closer the prices move to the lower band, the more oversold the market. John Bollinger has a set of 22 rules to follow when using the bands as a trading system. Because standard deviation is a measure of volatility, when the markets become more volatile the bands widen; during less volatile periods, the bands contract.




# signals
macd<- MACD(in_GOOGLE, nFast =5, nSlow = 20, nSig = 9,maType="SMA", percent
= FALSE)


#  MACD indicator and its signal value, with this, we can identify the time during the first two weeks of a month that outperforms the trading of the whole month. 

        # NOTES: 
        # nFast = Number of periods for "faster or short term Moving Average" is the Moving
        #         Average that only
        #         considers prices over short period of time and is thus more reactive to daily
        #         price changes. I set it up for 5 business days, or 1 week.

        # nSlow = Number of periods for "slow or long term Moving Average" is the long term
        #         moving average that is
        #         deemed slower as it encapsulates prices over a longer period and is more
        #         lethargic. However, it tends to smooth out price noises which are often
        #         reflected in short term moving averages. I set it up for 20 business days or 1
        #          month.
        
        # MACD = The 5-period exponential moving average (EMA) minus the 20-period EMA.

        # nSig = Number of periods for signal moving average. A 9-period EMA of the MACD.


  bb <- BBands(in_GOOGLE, n = 20, maType="SMA", sd = 2) # presents the lower band, average, upper band, and percentage Bollingerband
  




# To use our signals, I generated the following:
#  (1) = A **buy** signal when the stock is above the upper Bollinger band and the macd value is above its macd-signal value.  
#  (-1) = A **sell** signal when GOOGLE is down the lower Bollinger band and macd is less than its macd-signal value
#  (0) = An **out of market** when the signal is 0


 signal <- NULL
  print("Dates to buy GOOGLE stock")
    signal <- ifelse(in_GOOGLE> bb[,'up'] &macd[,'macd']
>macd[,'signal'],1,ifelse(in_GOOGLE< bb[,'dn'] &macd[,'macd']
<macd[,'signal'],-1,0))
        signal[signal$GOOGL.Close == 1, ] # only return "BUY" dates
          print("Amount of dates with BUY signal")
            length(signal[signal$GOOGL.Close == 1, ] )
              print("Amount of dates with SELL signal")
                length(signal[signal$GOOGL.Close == -1, ] )
                  print("Amount of dates with OUT OF MARKET signal")
                    length(signal[signal$GOOGL.Close == 0, ])
        


# Step 6: Trading strategy evaluation
# **To evaluate the stock return**
# Trade return is calculated using the return of the Dow Jones Index and the previous day
# signal.

trade_return<- in_ret_GOOGLE*lag(signal)
  print("Dates with a positive return relative to their previous date")
    trade_return[trade_return$Delt.1.log > 0, ] # only show dates that provide a positive return
      



# **To see strategy performance**


library(PerformanceAnalytics)
  cumm_ret<- Return.cumulative(trade_return) # return of stock trades from "2015-01-01" to "2019-12-31" 
    annual_ret<- Return.annualized(trade_return)
        summary(as.ts(trade_return))  # summary will give the minimum, first quartile, median,
                                      # mean, third quartile, and maximum of all trade return on
                                      # a daily basis. 
         
      



# **Visualize the return**
# plots cumulative and daily return along with drawdown at a given point of time

 charts.PerformanceSummary(trade_return)



# We can see that the drawback shows a decline from a historical peak that took place near the Summer of 2015, which is to be expected from a good performing stock. We can also see that the stock's volatility decreased through time, as its cummulative return has decreased through time.

# **EXploring return statistics**
#  Here we will calculate the maximum drawdown of trade return throughout the
# trading period and we can see that 0.3234323 means the maximum drawdown is 32.34%.

maxDrawdown(trade_return)



# Here, we calculate the daily standard deviation for trade returns. 

StdDev(trade_return) 



# To calculate the annualized standard deviation for trade returns. 

StdDev.annualized(trade_return) 



# Now, we calculate the VaR calculation for strategy return.

VaR(trade_return, p = 0.95)



# This is to calculate the Sharpe ratio of the strategy on a daily and annualized basis
# respectively.
# The Sharpe ratio on a daily basis is -0.02099614 and annualized is -0.379258. The Sharpe
# ratio has two parameters: Rf and FUN. Rf is for risk-free rate of interest and FUN is for the
# denominator. In the Sharpe ratio calculation, I used FUN=StdDev; it could also be VaR.


# More on the Sharpie Ratio: The ratio is the average return earned in excess of the risk-free rate per unit of volatility or total risk. Volatility is a measure of the price fluctuations of an asset or portfolio.


SharpeRatio(as.ts(trade_return), Rf = 0, p = 0.95, FUN = "StdDev") 

SharpeRatio.annualized(trade_return, Rf = 0) 




# Step 7: Generate Trading Signals for Out-of-Sample dataset

#**Trading Strategy**
#  Since the performance of our strategy is good, we sill apply it in our out-of-sample data. 

macd<- MACD(out_GOOGLE, nFast = 7, nSlow = 12, nSig = 15,maType="SMA",
            percent = FALSE)
bb <- BBands(out_GOOGLE, n = 20, maType="SMA", sd = 2)



# **Apply the strategy for the out-of-sample dataset**

signal <- NULL
signal <- ifelse(out_GOOGLE> bb[,'up'] &macd[,'macd']
                 >macd[,'signal'],1,ifelse(out_GOOGLE< bb[,'dn'] &macd[,'macd']
                                           <macd[,'signal'],-1,0))



# Trading strategy performance metrics:

trade_return<- out_ret_GOOGLE*lag(signal)
cumm_ret<- Return.cumulative(trade_return)
annual_ret<- Return.annualized(trade_return)
charts.PerformanceSummary(trade_return)




maxdd<- maxDrawdown(trade_return)
maxdd
sd<- StdDev(trade_return)
sd
sda<- StdDev.annualized(trade_return)
sda
VaR(trade_return, p = 0.95)
SharpeRatio(as.ts(trade_return), Rf = 0, p = 0.95, FUN = "StdDev")
SharpeRatio.annualized(trade_return, Rf = 0)



# Conclusion: 
# We have a *Sharpie Ratio* below 0, which means we need to improve our trading strategy.  Moreover, we also have a mean return below 0 (for the in-sample dataset). One solution for these problems may be to diversify our portfolio, or maybe change the number of periods evaluated for the fast and slow MA.

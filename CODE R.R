library(jsonlite)
library(dplyr)
library(purrr)

get_rate <- function(d) {
  message("Fetching: ", d)
  url <- paste0("https://cbu.uz/en/arkhiv-kursov-valyut/json/all/", d, "/")
  tryCatch({
    data <- fromJSON(url)
    data %>% 
      filter(Ccy == "USD") %>%   # <-- adjust column name once you see str(test)
      mutate(date = d)
  }, error = function(e) NULL)
}

dates <- seq(as.Date("2015-01-01"), as.Date("2026-08-15"), by = "week")
results <- map_dfr(dates, get_rate)

#confirmation
url <- "https://cbu.uz/en/arkhiv-kursov-valyut/json/all/2024-01-15/"
test <- fromJSON(url)
str(test)

dates <- seq(as.Date("2015-01-01"), as.Date("2026-08-15"), by = "week")
results <- map_dfr(dates, get_rate)

results$Rate <- as.numeric(results$Rate)
results$date <- as.Date(results$date)

#ggplot
library(ggplot2)


results_clean <- results %>%
  select(date,Rate) 
  
head(results_clean, 5)
str(results_clean)


         

ggplot(results_clean, aes(x = Date, y = Rate)) +
  geom_line(color = "steelblue") +
  scale_x_date(
    date_breaks = "1 year",
    date_labels = "%Y"
  ) +
  labs(
    title = "UZS/USD Exchange Rate",
    x = "YEARS",
    y = "Rate (USD rate in UZS)"
  ) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

#fitting ARIMA

forecast::tsdisplay(results_clean$Rate)

kpss.test(results_clean)

library(tseries)
adf.test(results_clean$Rate)
kpss.test(results_clean$Rate) #our data is not stationary

#time to differenciate

Rate_dif <- diff(results_clean$Rate)

adf.test(Rate_dif)
kpss.test(Rate_dif) #now our data is stationary

forecast::tsdisplay(Rate_dif)
#as we can see our ACF and PACF shows that our data is now PURE RANDOM WALK ARIMA(0,1,0)

#now we can check it with AUTO ARIMA 
library(forecast)
auto.arima(results_clean$Rate) #even Auto arima suggests ARIMA(0.1.0)

#now we can compare it with naive

train <- head(results_clean$Rate, -10)
test  <- tail(results_clean$Rate, 10)

fit_arima <- auto.arima(train)
fcast_arima <- forecast(fit_arima, h = 10)

fit_naive <- naive(train, h = 10)

accuracy(fcast_arima, test)
accuracy(fit_naive, test)


#now we use GARCH for forecasting volatality
library(rugarch)
install.packages("rugarch")

spec <- ugarchspec(
  variance.model = list(model = "sGARCH", garchOrder = c(1, 1)),
  mean.model = list(armaOrder = c(0, 0), include.mean = TRUE)
)
 
#fit GARCH
fit_garch <- ugarchfit(spec = spec, data = Rate_dif)
fit_garch

#forecasting volatality
fcast_garch <- ugarchforecast(fit_garch, n.ahead = 10)
fcast_garch
plot(fcast_garch, which = 3)

#While the direction of exchange rate movements is unpredictable (random walk), volatility itself is predictable and clusters over time. Current volatility is below its historical average, and the GARCH(1,1) model forecasts it reverting upward toward the long-run level over the next 10 weeks — information relevant for hedging or risk exposure decisions, even without being able to forecast the rate's direction

#now its time to prediction interval

# ARIMA point forecast (the center of the interval)
mean_fcast <- forecast(fit_arima, h = 10)$mean

# GARCH volatility forecast (the width of the interval)
sigma_fcast <- sigma(fcast_garch)

# Build 95% interval: mean ± 1.96 * sigma

upper_95 <- mean_fcast + 1.96 * sigma_fcast
lower_95 <- mean_fcast - 1.96 * sigma_fcast

# Combine into one table
interval_table <- data.frame(
  step = 1:10,
  forecast = as.numeric(mean_fcast),
  lower_95 = as.numeric(lower_95),
  upper_95 = as.numeric(upper_95)
)
interval_table

#GGPLOT thee prediction interval
ggplot(interval_table, aes(x = step)) +
  geom_line(aes(y = forecast), color = "steelblue") +
  geom_ribbon(aes(ymin = lower_95, ymax = upper_95), alpha = 0.2, fill = "steelblue") +
  labs(title = "10 weeks prediction",
       x = "next weeks", y = "UZS/USD Rate") +
  theme_minimal()

write.csv(results, file = "UZS-USD data.csv")
getwd()


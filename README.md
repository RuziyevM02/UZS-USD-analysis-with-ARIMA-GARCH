# UZS-USD-analysis-with-ARIMA-GARCH
Markdown

An empirical time-series analysis modeling the **Uzbekistani Som to US Dollar (UZS/USD)** exchange rate using **ARIMA** and **GARCH(1,1)** models in R.

---

## Executive Summary

* **Data Pipeline:** Automated API ingestion of historical UZS/USD exchange rates from the Central Bank of Uzbekistan (CBU) spanning **2015 to 2026**.
* **Mean Modeling (ARIMA):** Statistical testing (ADF & KPSS) confirmed a non-stationary time series with a single order of integration $I(1)$. Model comparison against naive benchmarks demonstrated that exchange rate returns follow a **Random Walk**.
* **Volatility Dynamics (GARCH):** Fitted a **sGARCH(1,1)** model on differenced returns to capture volatility clustering, demonstrating conditional variance mean-reversion over a 10-week horizon.
* **Hybrid Prediction Intervals:** Engineered custom 95% forecast intervals combining ARIMA point estimates with GARCH-derived conditional standard errors ($\sigma_t$).

---

## Key Results & Visualizations

<p align="center">
  <img width="860" height="512" alt="GGPLOT of actual data" src="https://github.com/user-attachments/assets/77212142-0bb8-435f-b207-09ecc8125976" />
  <img width="860" height="512" alt="ACF   PACF actual" src="https://github.com/user-attachments/assets/9ed39b18-5a93-4ba3-9a74-754e532548f5" />
</p>
<p align="center">
  <img width="860" height="512" alt="ACF   PACF diff" src="https://github.com/user-attachments/assets/8dc68203-2bd5-4f0d-b281-8a801b24e395" />
  <img width="860" height="512" alt="prediction interval" src="https://github.com/user-attachments/assets/13f1e845-d002-4f6e-85cd-dd28f6e11dcb" />
</p>

---

## Key Findings & Conclusion

1. **Exchange Rate Predictability:** ADF and KPSS tests confirm the level series is non-stationary and becomes stationary after first-differencing ($\Delta Y_t$). `auto.arima()` selected an $ARIMA(0,1,0)$ specification. Out-of-sample backtesting revealed that a naive benchmark outperforms drift-inclusive specifications ($RMSE = 71$ vs. $105$), confirming market efficiency and random walk behavior.
2. **Predictable Volatility Clustering:** While price direction is unpredictable, conditional variance exhibits statistically significant clustering. The fitted $GARCH(1,1)$ model predicts volatility mean-reverting toward its long-run historical baseline over the 10-week forecast horizon.
3. **Risk Management Implications:** Integrating GARCH conditional standard deviations into ARIMA point forecasts provides dynamic, risk-adjusted prediction intervals—yielding critical insights for financial hedging and currency risk management.

---

## Tech Stack & Dependencies

* **Language:** R
* **Data Processing:** `dplyr`, `purrr`, `jsonlite`
* **Time Series & Econometrics:** `tseries`, `forecast`, `rugarch`
* **Data Visualization:** `ggplot2`

---

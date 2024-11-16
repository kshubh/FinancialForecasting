# -*- coding: utf-8 -*-
"""
Created on Tue Mar 19 09:38:00 2024

@author: ZChen4
"""

#%%
# Corrections made to ETS_Model class:
# - Fixed constructor name from __int__ to __init__.
# - Used isinstance(self.data, pd.Series) for data type check.
# - Corrected parameter extraction in summary() with self.fit.params.get() and added checks for trend/seasonal.
# - Implemented plot() method to visualize actual vs fitted values.
# - Added forecast() method to predict future values.
# - Renamed output CSV to 'Parameters.csv' in summary() method.
# - Imported matplotlib for plotting functionality.

import pandas as pd
from statsmodels.tsa.exponential_smoothing.ets import ETSModel
import matplotlib.pyplot as plt

class ETS_Model(object):
    def __init__(self, data, error='add', trend=None, seasonal=None, 
                 damped_trend=False, seasonal_periods=None):
        self.data = data
        assert isinstance(self.data, pd.Series), 'Data input should be a pandas Series'
        self.error = error
        self.trend = trend
        self.seasonal = seasonal
        self.damped_trend = damped_trend
        self.seasonal_periods = seasonal_periods
        
        # Define the ETS model with provided parameters
        self.model = ETSModel(
            endog=self.data,
            error=self.error,
            trend=self.trend,
            seasonal=self.seasonal,
            damped_trend=self.damped_trend,
            seasonal_periods=self.seasonal_periods,
        )
        # Fit the model
        self.fit = self.model.fit(disp=False)

    def plot(self):
        # Plotting method to visualize fitted vs actual values
        self.data.plot(label="Actual")
        self.fit.fittedvalues.plot(label="Fitted", linestyle="--")
        plt.legend()
        plt.show()
        
    def summary(self):
        print(self.fit.summary())
        res_df = pd.DataFrame({
            'ETS Model Name': [self.fit.model.__class__.__name__],
            'AIC': [self.fit.aic],
            'Smoothing Level (alpha)': [self.fit.params.get('smoothing_level', None)],
            'Smoothing Trend (beta)': [self.fit.params.get('smoothing_slope', None) if self.trend else None],
            'Smoothing Seasonal (gamma)': [self.fit.params.get('smoothing_seasonal', None) if self.seasonal else None],
            'Damping Trend (phi)': [self.fit.params.get('damping_trend', None) if self.trend else None],
            'Seasonal Periods': [self.seasonal_periods]
        })
        
        res_df.to_csv('Parameters.csv', index=False)

    def forecast(self, steps=7):
        # Forecasting the next specified number of steps (default to 7 days for one week)
        forecast = self.fit.forecast(steps=steps)
        forecast.index = pd.date_range(start=self.data.index[-1] + pd.Timedelta(days=1), periods=steps, freq='D')
        return forecast

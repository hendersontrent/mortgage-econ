#-------------------------------------------
# This script sets out to produce some
# statistical models
#-------------------------------------------

#-------------------------------------------
# Author: Trent Henderson, 22 September 2020
#-------------------------------------------

# Import modules

import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.ticker as mtick
import seaborn as sns
import scipy as sp
from sklearn.model_selection import train_test_split
from sklearn.metrics import mean_squared_error
import statsmodels.api as sm
from statsmodels.formula.api import ols

#%%
#------------------ LOAD DATA --------------------------------------

d = pd.read_csv("/Users/trenthenderson/Documents/Git/mortgage-econ/data/educ-occ-mortgage.csv")

# Clean data

d = d.dropna()

X = d['educ_occ_score']
y = d['median_mortgage_repayment']

# Define X and y variables as numpy objects

X = X.to_numpy()
y = y.to_numpy()

# Split into train test sets

X_train, X_test, y_train, y_test = train_test_split(X, y, test_size = 0.20)

#%%
#------------------ MODELLING --------------------------------------

# Add intercept constant

X_train = sm.add_constant(X_train)

# Set up modelling structure

m1 = sm.OLS(y_train, X_train).fit()

# Get model summary

print(m1.summary())

#%%
#------------------ PREDICTION -------------------------------------

# Get predictions

X_test_new = sm.add_constant(X_test)

new_y = m1.predict(X_test_new)

print(mean_squared_error(y_test, new_y))

#%%

se = sp.stats.sem(new_y)

preds = {'X': X_test, 'y_hat': new_y, 'lower': new_y - (2*se), 'upper': new_y + (2*se)}
preds_df = pd.DataFrame(preds)

#%%
#------------------ DATA VISUALISATION -----------------------------

# Set style

sns.set()

fig, ax = plt.subplots(figsize = (10, 7))

# Plot real data

sns.scatterplot(x = X_test, y = y_test, color = "#05445E", label = "True Data", alpha = 0.8, ax = ax)

# Add confidence intervals

#ax.fill_between(x = preds_df['X'], y1 = preds_df['lower'], y2 = preds_df['upper'], color = "#FEB06A", alpha = 0.4)

# Plot predictions

sns.lineplot(x = preds_df['X'], y = preds_df['y_hat'], color = "#FEB06A", label = "OLS Prediction", ax = ax)

# Annotate

style = dict(size = 10, color = 'black')
text = "R2 = " + str(round(m1.rsquared*100,2)) + "%"
ax.text(x = 770, y = 40000, s = text, **style)

# Other plot and legend features

ax.legend(loc = 'upper left')
ax.set_xlabel('SEIFA Index of Education and Occupation')
ax.set_ylabel('Median Mortgage Repayment')
ax.set_title('OLS Model Out-of-Sample Test')

# Make y axis dollar signs

fmt = '${x:,.0f}'
tick = mtick.StrMethodFormatter(fmt)
ax.yaxis.set_major_formatter(tick)

# Save plot

plt.savefig('/Users/trenthenderson/Documents/Git/mortgage-econ/output/ols.png', dpi = 800)

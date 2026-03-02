import numpy as np
import pandas as pd
import os
from sklearn.ensemble import HistGradientBoostingRegressor
import matplotlib.pyplot as plt

# Load data
df = pd.read_csv('load data here')
df['firm_fac'] = df['firm_fac'].astype('category')
df['mktCap_1b'] = df['mktCap'] / 1000  # re-scale for ease of interpretation

# Setting up the machine learning model
X = df.drop(columns=['mktCap_1b', 'mktCap', 'shokenCode', 'firmName', 'ln_mktCap'])
y = df['mktCap_1b']

X_filtered = X[X['year'] <= 2021]  # Filter the data to include only rows before 2022
y_filtered = y.loc[X_filtered.index]

X_train = X_filtered.sample(frac=0.8, random_state=42)
y_train = y_filtered.loc[X_train.index]

# Estimation
hgbdt_model = HistGradientBoostingRegressor(random_state=2024101, learning_rate=0.1,categorical_features='from_dtype')
hgbdt_model.fit(X_train, y_train)

# Feature of interest
feature_name = 'pct_femaleMger'

# Custom PDP over specified range
avg_preds = []
custom_values = range(6, 82, 2)

for val in custom_values:
    X_temp = X.copy()
    X_temp[feature_name] = val
    avg_preds.append(np.mean(hgbdt_model.predict(X_temp)))

# Plot
plt.figure(figsize=(7, 4))
plt.plot(list(custom_values), avg_preds, color='blue')
plt.xlabel("Share of Managerial Roles Held by Women (%)")
plt.ylabel("Partial Dependence (Market Cap, 1 Billion Yen)")
plt.grid(True)
plt.tight_layout()
plt.savefig()
plt.show()

import numpy as np
import pandas as pd
import os
import shap
from sklearn.ensemble import HistGradientBoostingRegressor
import matplotlib.pyplot as plt

# load data: Tosho Prime firms, 2013-23.
# df = pd.read_csv('load data here')

# Preprocess dataframe for analysis
df['firm_fac'] = df['firm_fac'].astype('category')
df = pd.get_dummies(df, columns=['firm_fac'], drop_first=True) # add firm dummmies (as in fixed effects models)

df['mktCap_1b'] = df['mktCap'] / 1000   # re-scale for ease of interpretation.
numeric_cols = df.select_dtypes(include=['number']).columns
df[numeric_cols] = df[numeric_cols].fillna(df[numeric_cols].min())

df['pct_mgmtPosition'] = 100* df['n_mgmtPosition'] / df['n_employees']
df.loc[df['pct_mgmtPosition'] > 100, 'pct_mgmtPosition'] = np.nan

# Python objects for machine learning
X = df.drop(columns=['mktCap_1b','mktCap',"shokenCode",'firmName',"ln_mktCap"])
y = df[['mktCap_1b']]
 
X_train, y_train = X, y
X_filtered = X[X['year'] <= 2021]  # Filter the data to include only rows before 2022
y_filtered = y.loc[X_filtered.index]

X_test = X[X['year'] == 2023]
X_train = X_filtered.sample(frac=0.6, random_state=42)
y_train = y_filtered.loc[X_train.index]
y_test = df[df['year'] == 2023][['mktCap_1b']]


# Estimation: Gradient boosting 
from sklearn.ensemble import HistGradientBoostingRegressor
hgbdt_model = HistGradientBoostingRegressor(random_state=2024101, learning_rate=0.1, categorical_features='from_dtype')
hgbdt_model.fit(X_train, y_train)

# Loop
vec_figure_variable = ['define relevant variables here']

xlabels = {
    'define th labels for the those in vec_figure_variable'
}

for variable in vec_figure_variable:

    if variable == 'n_boardMembers':
        feature_values = np.arange(7, 13).reshape(-1, 1)  
    elif variable == 'n_nonExec':
        feature_values = np.arange(1,10).reshape(-1,1)
    elif variable == 'aveCompensation_directors':
        feature_values = np.arange(70,120).reshape(-1,1)
    else:
        min_value = X[variable].min()
        max_value = X[variable].max()
        feature_values = np.linspace(min_value, max_value, 100).reshape(-1, 1)

    # 対象サンプル
    index = df[(df['firmName'] == 'your firm here') & (df['year'] == 2023)].index
    sample = X.iloc[index]

    predictions = np.zeros(len(feature_values))

    for i in range(len(feature_values)):
        input_data = sample.copy()
        input_data[variable] = feature_values[i][0]  # 値を代入
        input_data = input_data.values.reshape(1, -1)
        predictions[i] = hgbdt_model.predict(input_data)

    # Plot
    plt.figure(figsize=(6, 6))
    plt.plot(feature_values.flatten(), predictions, label=f'Sample {index}', color='blue')
    plt.title(f'ICE Curve for {xlabels[variable]}')
    plt.xlabel(xlabels[variable])  
    plt.ylabel('Predicted Outcome (Market Cap, 1 Billion Yen)')
    plt.legend()
    plt.grid()

    output_path = os.path.join(current_directory,
                               f'ice_curve_astellas_2023_{variable}.jpeg')
    plt.savefig(output_path, dpi=300, bbox_inches='tight')
    plt.close()

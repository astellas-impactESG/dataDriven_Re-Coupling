import pandas as pd
import xgboost
import shap
import matplotlib.pyplot as plt

# load data 
df = pd.read_csv('[load data here]')
df['firm_fac'] = df['firm_fac'].astype('category')
df['mktCap_1b'] = df['mktCap'] / 1000   # re-scale for ease of interpretation.

# Setting up the machine learning model
X = df.drop(columns=['mktCap_1b','mktCap',"firm_fac","shokenCode",'firmName',"ln_mktCap",
                     "L1_ln_mktCap","pbr","per","roe","ebitda","roic",'roa',"n_femaleMnger",
                     "industryCat","ind_DaiBunrui_en","ind_ChuBunrui_en","industryCat_en"])

y = df['mktCap_1b']
bst = xgboost.train({"learning_rate": 0.01,
                     "seed": 0}, xgboost.DMatrix(X, label=y), 500)
explainer = shap.TreeExplainer(bst)
explanation = explainer(X)

# Plot 
plt.figure(figsize=(10, 8))
shap.summary_plot(explanation, X, max_display=25)
plt.tight_layout()
plt.savefig("shap_summary.png", dpi=300, bbox_inches="tight")
plt.close()

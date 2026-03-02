# Replication Package for "Data-Driven Re-Coupling: An Embedded Case Study of Astellas Pharma's Journey to Substantive Legitimacy"

**Authors:** Daisuke Kato, Takehiro Metoki, Yohsuke Hagiwara, Shintaro Omuro, Shingo Iino  
**Affiliations:** Astellas Pharma Inc. (Sustainability; Digital X); Waseda University, Graduate School of Accountancy

---

## Overview

This repository contains the replication code for the macro-level quantitative analysis reported in the paper. The analysis seeks to identify non-financial indicators (NFIs) associated with market capitalization using a panel dataset of 1,694 TSE Prime Market firms (2013–2023).

The empirical pipeline consists of three stages:

- **SHAP-based contribution analysis** — XGBoost model trained via `xgboost.train` with SHAP values computed using `TreeExplainer` (reproduces Figure 2)
- **Fixed-effects causal analysis** — Fixed effects panel regression with industry-clustered standard errors and AME estimation (reproduces Figure 3)
- **corrrelation_all** - A scatter plot showing the correlation of market capitalization and the share of female managers (reproduces Figure 4)
- **pdp_femaleManagers.py** - A partial dependence plot (reproduces Figure 5)
- **correlation_astellas** - A scatter plot showing the correlation of market capialization and NFIs for Astellas (reproduces Figure 6, Supplmentary Figure 1,2,3,4,5,6)
- **ICE simulation** — Individual Conditional Expectation curves using `HistGradientBoostingRegressor`, anchored to Astellas' 2023 profile (reproduces Figure 7, Supplmentary Figure 1,2,3,4,5,6)

---

## Repository Structure

```
.
├── README.md
├── LICENSE
├── requirements.txt          # Python dependencies
├── requirements_R.txt        # R dependencies
└── code/
    ├── shap_analysis.py    # XGBoost + SHAP (contribution & predictive analysis)
    ├── ice_simulation.py   # ICE curve simulation for a focal firm
    ├── fixed_effects.R     # Fixed-effects panel regression + AME estimation
    ├── correlation_all.R   # Scatter plot (all companies)
    ├── correlation_astellas.R # Scatter plot (Astellas)
    └── pdp_femaleManagers.py  # PDP 
```

---

## Data Availability

The empirical analysis uses the **TERRAST** dataset (Tokyo Stock Exchange Prime Market, 2013–2023), a proprietary ESG data platform that aggregates publicly available corporate disclosures via AI and big data technologies.

**The raw data cannot be redistributed** due to the data provider's terms of service. Researchers wishing to replicate the analysis should contact TERRAST directly to obtain access.

To run the code, place the licensed dataset at `data/toshoPrime_2013-2023_en.csv` and replace all `'[load data here]'` placeholders in the scripts with the appropriate file path.

---

## Software Requirements

### Python (scripts 1–2)

Tested on Python 3.13.12. Install dependencies:

```bash
pip install -r requirements.txt
```

| Package | Version |
|---|---|
| matplotlib | 3.10.8 |
| matplotlib-inline | 0.2.1 |
| numpy | 2.3.5 |
| pandas | 3.0.0 |
| scikit-learn | 1.8.0 |
| shap | 0.50.0 |
| xgboost | 3.2.0 |

### R (script 3)

Tested on R 4.4.2. See `requirements_R.txt` for the full dependency list. Install dependencies manually:

```r
install.packages(c("tidyverse", "conflicted", "fixest", "marginaleffects"))
```

| Package | Version |
|---|---|
| conflicted | 1.2.0 |
| fixest | 0.12.1 |
| marginaleffects | 0.28.0 |
| tidyverse | 2.0.0 |

---

## How to Reproduce

Run scripts in order from the `code/` directory. Each script expects the data file from TERRAST.
**Before running**, set the following variables in the script:

- `vec_X` (fixed_effects.R): column names of human capital indicators in your licensed dataset
- `vec_G`(fixed_effects.R): column names of governance indicators in your licensed dataset
- `datagrid(totalAssets = ...)`: replace the placeholder string with the appropriate numeric value for Astellas' total assets
- `c_hk` (correlation_all.R): column names of human capital indicators in your licensed dataset
- `c_gov`(correlation_all.R): column names of governance indicators in your licensed dataset

---

## Correspondence

For questions about this replication package, please open a GitHub Issue.  
For questions about the paper itself, please contact the corresponding authors via SSRN.

---

## License

This replication code is released under the **Apache License 2.0**. See [`LICENSE`](LICENSE) for details.

The TERRAST dataset is proprietary and is **not** covered by this license.

# corelation_all.r
remove(list = ls())
library(tidyverse)
library(here)

# load data
# df <- read_csv("load data here")

df$pct_mgmt <- 100*df$n_mgmtPosition /df$n_employees  

df <- df %>% arrange(shokenCode, year)

df2 <- df %>%
  arrange(shokenCode, year) %>%
  group_by(shokenCode) %>%
  mutate(across(
    !c(firmName, year), 
    ~ (.-lag(.)) / lag(.) * 100,
    .names = "pct_change_{.col}"
  )) %>% 
  ungroup

df2 <- df2 %>% 
  arrange(shokenCode,year) %>% 
  group_by(shokenCode) %>% 
  mutate(L1_pct_change_mktCap = lag(pct_change_mktCap,1))

# get annual % change 
df2 <- df2 %>% select(shokenCode,year,contains("pct_change_"))

# Reshape dataframe to long format for easy plotting
df_long <- df2 %>% ungroup %>% 
  select(-c(shokenCode, year,L1_pct_change_mktCap)) %>%  # Exclude non-numeric variables
  pivot_longer(
    cols = -pct_change_mktCap,  # Keep pct_change_mktCap as the reference variable
    names_to = "variable",
    values_to = "value"
  )

df_long$value[is.infinite(df_long$value)] <- NA

# human capital
# c_hk <- c("list relevant variables here")

# governance 
# c_gov <- c("list relevant variables here")


dffem <- df_long %>% filter(str_detect(variable,c_hk[7]))
dffem$value[is.infinite(dffem$value)] <- NA
dffem <- dffem %>% filter(!is.na(value)&!is.na(pct_change_mktCap ))
dffem <- dffem %>% filter(value <= quantile(dffem$value,.995,na.rm=T))
dffem <- dffem %>% filter(pct_change_mktCap <= quantile(dffem$pct_change_mktCap,.999,na.rm=T))
dffem <- dffem %>% filter(pct_change_mktCap >= quantile(dffem$pct_change_mktCap,.001,na.rm=T))


#' ##########
# Figure 4 
#' ##########

ggplot(dffem, aes(x = value, y = pct_change_mktCap)) +
  geom_point(alpha = 0.5, color = "black") +  # Scatter points with some transparency
  geom_smooth(method = "lm", color = "red", 
              linetype = "dashed", linewidth=.9,
              se = FALSE) +  # Add regression line
  labs(
    title = "",
    x = "Annual % Change in % of Female Managers",
    y = "Annual % Change in Market Cap"
  ) +
  theme_minimal()


## Loop - generate names #####
path <- here()

for (var_name in c_gov) {
  dffem <- df_long %>% filter(str_detect(variable, var_name))
  
  dffem$value[is.infinite(dffem$value)] <- NA
  
  dffem <- dffem %>% 
    filter(!is.na(value) & !is.na(pct_change_mktCap)) %>%
    filter(value <= quantile(value, 0.995, na.rm = TRUE)) %>%
    filter(pct_change_mktCap <= quantile(pct_change_mktCap, 0.999, na.rm = TRUE)) %>%
    filter(pct_change_mktCap >= quantile(pct_change_mktCap, 0.001, na.rm = TRUE))
  
  p <- ggplot(dffem, aes(x = value, y = pct_change_mktCap)) +
    geom_point(alpha = 0.5, color = "black") +
    geom_smooth(method = "lm", color = "red", 
                linetype = "dashed", linewidth = 0.9,
                se = FALSE) +
    labs(
      title = paste("Regression for", var_name),
      x = "Annual % Change in ESG Indicator",
      y = "Annual % Change in Market Cap"
    ) +
    theme_minimal()
  
  # Save plot with sanitized name
  filename <- paste0("plot_", gsub("[^a-zA-Z0-9]", "_", var_name), ".jpeg")
  filename2 <- paste(path,filename,sep="/")
  ggsave(filename2, plot = p, width = 8, height = 6)
  
  print(var_name)
}


# governance 
df_long %>% 
  filter(str_detect(variable, paste0(c_gov,collapse="|"))) %>% 
  ggplot(., aes(x = value, y = pct_change_mktCap)) +
  geom_point(alpha = 0.5, color = "black") +  # Scatter points with some transparency
  geom_smooth(method = "lm", color = "red", 
              linetype = "dashed", linewidth=.9,
              se = FALSE) +  # Add regression line
  facet_wrap(~ variable, scales = "free", ncol=4) +  # Create multiple plots for each variable
  labs(
    title = "Scatter Plot: pct_change_mktCap vs Other Variables",
    x = "Governance Indicators",
    y = "Annual % Change in Market Cap"
  ) +
  theme_minimal()

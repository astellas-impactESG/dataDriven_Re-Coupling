# Prep  ---
remove(list = ls())
library(tidyverse); library(here); library(conflicted); 
library(glue); library(ggrepel); library(broom)
conflicts_prefer(dplyr::filter); conflicts_prefer(dplyr::lag)

# load data 
# df <- read_csv("load data here") %>% filter(str_detect(firmName,"アステラス"))  # load the data

# Generate a new variable: Pct of Managers 
df$pct_mgmt <- 100*df$n_mgmtPosition /df$n_employees  

# Change the data form from wide to long
df_long <- df %>%
  pivot_longer(cols = -mktCap,names_to = "variable",values_to = "value") 

# Rescaling for ease of interpretation
df_long$mktCap_cho <- df_long$mktCap / 1000000


#' ##################
# Correlation #########
#' ##################

unique_variables <- unique(df_long$variable) # a list of variable names

# Loop through each unique variable
for (var in 1:length(unique_variables)) {
  # Filter the dataframe for the current variable
  filtered_data <- df_long %>% filter(variable == unique_variables[var])
  
  # Calculate correlation
  correlation <- cor(filtered_data$value, filtered_data$mktCap_cho, use = "complete.obs")
  
  # Create the plot
  p <- ggplot(filtered_data, aes(x = value, y = mktCap_cho)) +
    geom_point() +
    theme_minimal() +
    geom_smooth(method = "lm", se = FALSE, color = "red", linetype = "dashed") +
    ylab("時価総額（兆円）") +
    xlab(unique_variables[var]) +  # Set x-axis label to the current variable
    geom_text(aes(label = paste0("r = ", round(correlation, 2))),
              fontface = "plain",
              x = Inf, y = Inf, hjust = 2, vjust = 8, color = "black", size = 7.5) + 
    theme(text = element_text(size = 15))
  
  
  # Save the plot (uncomment to save figures)
  file_name <- paste0(here(), "/jp_",str_replace_all(unique_variables[var],"/","_"),".jpeg")
  ggsave(file_name, plot = p, width = 7, height = 4)
  print(var)
  Sys.sleep(.5)
}


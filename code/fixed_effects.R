#  Preparation 
remove(list = ls())
library(tidyverse)
library(conflicted)
library(fixest)         # Panel data
library(marginaleffects) # AME estimation

conflicts_prefer(dplyr::filter)
conflicts_prefer(dplyr::lag)

# データ --------- 
# df <- read_csv("load data here")

# vec_X <-c("")
# vec_G <- c("")

df.ame <- rbind(data.frame(term = vec_X, 
                           estimate = rep(NA, length(vec_X)), 
                           std = rep(NA, length(vec_X)),
                           esgCat = "humanK"),
                data.frame(term = vec_G, 
                           estimate = rep(NA, length(vec_G)), 
                           std = rep(NA, length(vec_G)),
                           esgCat = "Gov"))
df.ame$nobs <- NA
df.ame$model <- paste0("ln_mktCap ~ ", df.ame$term, " * totalAssets + n_employees + gm_pct + annGrowthRate_pct + levRatio |firm_fac")


for(i in 1:nrow(df.ame)){
  # addtive model
  model <- feols(as.formula(df.ame$model[i]), data = df, vcov = ~ind_DaiBunrui_en,
                 notes = F)
  
  slope_i <- slopes(model,
                    variables = df.ame$term[i],
                    newdata = datagrid(totalAssets = "自社の総資産")) 
  
  df.ame$term[i] <- slope_i$term
  df.ame$estimate[i] <- slope_i$estimate
  df.ame$std[i] <- slope_i$std.error
  df.ame$nobs[i] <- model$nobs
  print(i)
}


df.ame$lower <- df.ame$estimate - df.ame$std*1.96
df.ame$upper <- df.ame$estimate + df.ame$std*1.96
df.ame$neg <- as.character(ifelse(df.ame$estimate<0,1,0))

## coef bar chart - for presentation -----
df.ame$est_lab <- round(df.ame$estimate,2)
df.ame$est_lab <- ifelse(df.ame$est_lab>0, paste0("+",df.ame$est_lab),
                         df.ame$est_lab)
df.ame$est_lab <- paste0(df.ame$est_lab,"%")

df.ame %>% 
  ggplot(., aes(fct_reorder(term, estimate,.desc=F), estimate)) +
  geom_col(width=0.4,alpha=.6)+
  geom_errorbar(aes(ymin=lower, 
                    ymax=upper),
                width=.15, # Width of the error bars
                position=position_dodge(.9),
                color="gray20")+
  ylab("時価総額の変化率（%）") + xlab("")+  theme_light()+
  geom_text(stat="identity", 
            aes(label=est_lab,vjust=-.9,hjust=-.1))+
  theme(legend.position = "none", axis.text=element_text(size=13),
        axis.text.x = element_text(angle = 60,size=7,hjust=1))+
  coord_flip()


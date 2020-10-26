#-------------------------------------------
# This script sets out to produce a 
# correlation matrix plot
#-------------------------------------------

#-----------------------------------------
# Author: Trent Henderson, 26 October 2020
#-----------------------------------------

# Prep dataset

corr_dat <- d %>%
  drop_na() %>%
  dplyr::select(c(usual_resident_population, prop_dwellings_internet_accessed, median_mortgage_repayment,
                  median_total_household_income, educ_occ_score)) %>%
  rename(`Usual Resident Population` = usual_resident_population,
         `Proportion of Dwellings with Internet Access` = prop_dwellings_internet_accessed,
         `Median Mortgage Repayment` = median_mortgage_repayment,
         `Median Household Income` = median_total_household_income,
         `SEIFA Education Occupation Index` = educ_occ_score)

# Calculate correlation matrix

corr <- round(cor(corr_dat), digits = 2)

#------------------------ DATA VISUALISATIONS ----------------------

CairoPNG("output/corrplot.png", 800, 600)
ggcorrplot(corr, type = "lower", lab = TRUE,
           hc.order = TRUE, colors = c("steelblue2", "white", "#FEB06A"))
dev.off()

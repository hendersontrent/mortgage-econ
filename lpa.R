#-------------------------------------------
# This script sets out to produce an LPA
# analysis
#-------------------------------------------

#-----------------------------------------
# Author: Trent Henderson, 25 October 2020
#-----------------------------------------

# Scale data to prepare it for modelling

d1 <- d %>%
  drop_na() %>%
  mutate(scaled_pop = scale(usual_resident_population),
         scaled_int = scale(prop_dwellings_internet_accessed),
         scaled_pay = scale(median_mortgage_repayment),
         scaled_inc = scale(median_total_household_income),
         scaled_seifa = scale(educ_occ_score)) %>%
  mutate(scaled_pop = as.numeric(scaled_pop),
         scaled_int = as.numeric(scaled_int),
         scaled_pay = as.numeric(scaled_pay),
         scaled_inc = as.numeric(scaled_inc),
         scaled_seifa = as.numeric(scaled_seifa))

#------------------------- MODEL SPECIFICATION ---------------------

m1 <- d1[1:nrow(d1), ] %>%
  dplyr::select(c(scaled_pop, scaled_int, scaled_pay, scaled_inc, scaled_seifa)) %>%
  single_imputation() %>%
  estimate_profiles(1:6,
                    variances = c("equal", "varying"),
                    covariances = c("zero", "varying"))

#------------------------- OUTPUTS ---------------------------------

#-----------------
# FIT INDICES
#-----------------

m1 %>%
  compare_solutions(statistics = c("AIC", "BIC", "AWE", "CLC", "KIC"))

#-----------------
# DEFAULT LPA PLOT
#-----------------

# Plot LPA

m1 %>%
  plot_profiles()

#-----------------
# FIT STATISTICS
#-----------------

# Get fit statistics

get_fit(m1)

#-----------------
# COLLECT OUTPUTS
#-----------------

# Get outputs in a dataframe

lpa_outputs <- get_data(m1)

# Filter to just Model 6/6 Classes as this model had the best model fit

lpa_outputs_filt <- lpa_outputs %>%
  filter(model_number == "6" & classes_number == 6)

# Join back in to main dataset

d3 <- d1
d3 <- mutate(d3, id = rownames(d3)) # Add id variable to join properly

d3 <- d3 %>%
  mutate(id = as.numeric(id)) %>%
  inner_join(lpa_outputs_filt, by = c("scaled_pop" = "scaled_pop", "scaled_int" = "scaled_int",
                                      "scaled_pay" = "scaled_pay", "scaled_inc" = "scaled_inc", 
                                      "scaled_seifa" = "scaled_seifa", "id" = "id")) %>%
  group_by(id) %>%
  slice(which.max(Probability)) %>% # Return just the class with highest probability to which the postcode belongs
  ungroup()

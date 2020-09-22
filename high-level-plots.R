#-------------------------------------------
# This script sets out to produce high level
# initial plots and some basic modelling
# diagnostics
#-------------------------------------------

#-------------------------------------------
# Author: Trent Henderson, 22 September 2020
#-------------------------------------------

library(tidyverse)
library(scales)
library(Cairo)
library(mgcv)

# Create an output folder if none exists:

if(!dir.exists('output')) dir.create('output')

# Load data

d <- read_csv("data/educ-occ-mortgage.csv") %>%
  filter(main_state != "OT") %>%
  filter(!is.na(main_state))

#------------------------ DATA VISUALISATIONS ----------------------

# Plotting function

plotter <- function(data){
  p <- data %>%
    filter(main_state != "OT") %>%
    filter(!is.na(main_state)) %>%
    ggplot(aes(x = educ_occ_score, y = median_mortgage_repayment)) +
    geom_point(colour = "#05445E", size = 2, alpha = 0.6) +
    geom_smooth(formula = y ~ s(x), method = "gam", fill = "steelblue2", colour = "steelblue2", alpha = 0.4,
                size = 1.25) +
    labs(title = "Education/Occupation Advantage and Mortgage Repayments by Postcode",
         subtitle = "Higher SEIFA Index score indicates relatively higher educational/occupational status",
         x = "SEIFA Index of Education and Occupation",
         y = "Median Mortgage Repayment",
         caption = "Analysis: Orbisant Analytics.") +
    scale_y_continuous(labels = dollar) +
    theme_bw() +
    theme(panel.grid.minor = element_blank(),
          strip.background = element_rect(fill = "#05445E"),
          strip.text = element_text(colour = "white", face = "bold"))
  
  return(p)
}

# Unfaceted

p <- plotter(d)
print(p)

# Faceted

p1 <- plotter(d) +
  facet_wrap(~main_state)
print(p1)

#------------------------ MODELLING DIAGNOSTICS --------------------

# Specify models

m1 <- glm(median_mortgage_repayment ~ educ_occ_score, data = d)
m2 <- gam(median_mortgage_repayment ~ s(educ_occ_score), data = d)
m3 <- gam(median_mortgage_repayment ~ s(educ_occ_score) + main_state, data = d)

# Check AICs

AIC(m1)
AIC(m2)
AIC(m3)

#------------------------ EXPORTS ----------------------------------

CairoPNG("output/unfaceted.png", 800, 600)
print(p)
dev.off()

CairoPNG("output/faceted.png", 800, 600)
print(p1)
dev.off()

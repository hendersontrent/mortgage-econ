#-------------------------------------------
# This script sets out to produce high level
# initial plots
#-------------------------------------------

#-------------------------------------------
# Author: Trent Henderson, 22 September 2020
#-------------------------------------------

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

#------------------------ EXPORTS ----------------------------------

CairoPNG("output/unfaceted.png", 800, 600)
print(p)
dev.off()

CairoPNG("output/faceted.png", 800, 600)
print(p1)
dev.off()

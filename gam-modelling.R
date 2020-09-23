#-------------------------------------------
# This script sets out to build statistical
# models on economic data to understand
# relationships with mortgage repayments
#
# NOTE: This script requires setup.R to
# have been run first
#-------------------------------------------

#-------------------------------------------
# Author: Trent Henderson, 23 September 2020
#-------------------------------------------

# Load data

d <- read_csv("data/mortgage-data.csv") %>%
  drop_na() %>%
  filter(main_state != "OT") %>%
  mutate(usual_resident_population = log(usual_resident_population))

#--------------------------- MODELLING -----------------------------

# Test both GLM and GAM models and compare fits

m1 <- glm(median_mortgage_repayment ~ median_total_household_income + prop_dwellings_internet_accessed +
            educ_occ_score + usual_resident_population + main_state, data = d)

m2 <- gam(median_mortgage_repayment ~ s(median_total_household_income) + s(prop_dwellings_internet_accessed) +
            s(educ_occ_score) + s(usual_resident_population) + main_state, data = d)

AIC(m1)
AIC(m2)

# Model statistics

summary(m1)
summary(m2)

# Extract predicted model effects for each predictor in the better-fitting GAM model

p <- plot_model(m2, type = "pred")

income <- p$median_total_household_income$data
internet <- p$prop_dwellings_internet_accessed$data
seifa <- p$educ_occ_score$data
population <- p$usual_resident_population$data
state <- p$main_state$data

#--------------------------- DATA VISUALISATION --------------------

# Income

income_plot <- income %>%
  ggplot() +
  geom_line(aes(x = x, y = predicted), colour = "steelblue2", size = 1.25) +
  geom_ribbon(aes(x = x, ymin = conf.low, ymax = conf.high), fill = "steelblue2", alpha = 0.4) +
  labs(title = "Median household income",
       subtitle = "Smooth effects",
       x = "Median Total Household Income",
       y = "Median Mortage Repayment") +
  scale_x_continuous(labels = dollar) +
  scale_y_continuous(labels = dollar) +
  theme_bw() +
  theme(panel.grid.minor = element_blank())
print(income_plot)

# Internet

internet_plot <- internet %>%
  ggplot() +
  geom_line(aes(x = x, y = predicted), colour = "steelblue2", size = 1.25) +
  geom_ribbon(aes(x = x, ymin = conf.low, ymax = conf.high), fill = "steelblue2", alpha = 0.4) +
  labs(title = "Dwellings internet access",
       subtitle = "Smooth effects",
       x = "Median Total Household Income",
       y = "Median Mortage Repayment") +
  scale_y_continuous(labels = dollar) +
  theme_bw() +
  theme(panel.grid.minor = element_blank())
print(internet_plot)

# Education Occupation Advantage

seifa_plot <- seifa %>%
  ggplot() +
  geom_line(aes(x = x, y = predicted), colour = "steelblue2", size = 1.25) +
  geom_ribbon(aes(x = x, ymin = conf.low, ymax = conf.high), fill = "steelblue2", alpha = 0.4) +
  labs(title = "Education occupation",
       subtitle = "Smooth effects",
       x = "Index of Education Occupation",
       y = "Median Mortage Repayment") +
  scale_y_continuous(labels = dollar) +
  theme_bw() +
  theme(panel.grid.minor = element_blank())
print(seifa_plot)

# Population

pop_plot <- population %>%
  mutate(x = exp(x)) %>%
  ggplot() +
  geom_line(aes(x = x, y = predicted), colour = "steelblue2", size = 1.25) +
  geom_ribbon(aes(x = x, ymin = conf.low, ymax = conf.high), fill = "steelblue2", alpha = 0.4) +
  labs(title = "Resident population",
       subtitle = "Smooth effects",
       x = "Resident Population",
       y = "Median Mortage Repayment") +
  scale_x_continuous(labels = comma) +
  scale_y_continuous(labels = dollar) +
  theme_bw() +
  theme(panel.grid.minor = element_blank())
print(pop_plot)

# State/Territory

state_plot <- state %>%
  mutate(state = case_when(
         x == 1 ~ "VIC",
         x == 2 ~ "NSW",
         x == 3 ~ "TAS",
         x == 4 ~ "WA",
         x == 5 ~ "QLD",
         x == 6 ~ "SA",
         x == 7 ~ "NT",
         x == 8 ~ "ACT")) %>%
  ggplot() +
  geom_segment(aes(x = conf.low, xend = conf.high, y = state, yend = state), colour = "steelblue2", alpha = 0.6,
               size = 4) +
  geom_point(aes(x = predicted, y = state), size = 5, colour = "#05445E") +
  labs(title = "State/Territory",
       subtitle = "Predicted effects",
       x = "Median Mortage Repayment",
       y = "State/Territory") +
  scale_x_continuous(labels = dollar) +
  theme_bw() +
  theme(panel.grid.minor = element_blank())
print(state_plot)

#--------------------------- EXPORTS -------------------------------
  
# Merge all and save

CairoPNG("output/merged-gam-effects.png", 800, 600)
ggarrange(income_plot, internet_plot, seifa_plot, pop_plot, state_plot,
          nrow = 2, ncol = 3)
dev.off()

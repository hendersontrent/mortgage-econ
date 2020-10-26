#-------------------------------------------
# This script sets out to load all 
# things required for the project
#-------------------------------------------

#-------------------------------------------
# Author: Trent Henderson, 23 September 2020
#-------------------------------------------

# Load packages

library(tidyverse)
library(mgcv)
library(scales)
library(MASS)
library(sjPlot)
library(ggpubr)
library(tidyLPA)
library(Cairo)
library(ggcorrplot)

# Turn off scientific notation

options(scipen = 999)

# Load data

d <- read_csv("data/mortgage-data.csv") %>%
  filter(main_state != "OT") %>%
  filter(!is.na(main_state))

# Create an output folder if none exists:

if(!dir.exists('output')) dir.create('output')

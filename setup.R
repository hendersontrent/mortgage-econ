#-------------------------------------------
# This script sets out to load all 
# things required for the project
#-------------------------------------------

#-------------------------------------------
# Author: Trent Henderson, 23 September 2020
#-------------------------------------------

# Load packages

library(tidyverse)
library(DBI)
library(mgcv)
library(scales)
library(MASS)
library(sjPlot)
library(ggpubr)
library(Cairo)

# Turn off scientific notation

options(scipen = 999)

# Create an output folder if none exists:

if(!dir.exists('output')) dir.create('output')

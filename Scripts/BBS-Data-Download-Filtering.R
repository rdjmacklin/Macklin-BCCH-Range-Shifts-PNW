################################################################################

# Script Title: Downloading the Breeding Bird Survey Data for Route 212 "Point 
# Grey"

# Script Author: Rory Macklin (macklin@zoology.ubc.ca)

# Date: September 16, 2022

################################################################################

# Open "groundhog" package to conduct package version control.

library(groundhog)

# Load required packages using "groundhog" to access versions most recent to
# 2022-09-14.

groundhog.library(tidyverse, date = "2022-09-14")
groundhog.library(zip, date = "2022-09-14")

# We will use the bbsAssistant package to download the Breeding Bird Survey
# dataset.

groundhog.library("github::trashbirdecology/bbsAssistant", "2022-09-14")

# Create subdirectory for BBS dataset if one does not already exist.

if(!(dir.exists("./Data/Raw_Data/BBS_raw"))) {
  dir.create("./Data/Raw_Data/BBS_raw")
}

# Download 2020 release of the Breeding Bird Dataset using dataset identifier
# (sb_id) found at https://github.com/TrashBirdEcology/bbsAssistant

grab_bbs_data(sb_id = "5ea04e9a82cefae35a129d65", bbs_dir = "./Data/Raw_Data/BBS_raw")

# Delete unnecessary files to save storage space. Retain metadata files for later
# use.

file.remove("./Data/Raw_Data/BBS_raw/50-StopData.zip")
file.remove("./Data/Raw_Data/BBS_raw/MigrantNonBreeder.zip")

# Decompress ZIP files to access annual total species counts for all routes in
# British Columbia.

zip::unzip("./Data/Raw_Data/BBS_raw/States.zip", exdir = "./Data/Raw_Data/BBS_raw/")
zip:unzip("./Data/Raw_Data/BBS_raw/States/BritCol.zip", exdir = "./Data/Raw_Data/BBS_raw/British_Columbia/")

# Remove unused States to save storage space. Retain Washington and Oregon for 
# use in later analyses

states_delete <- list.files(path = "./Data/Raw_Data/BBS_raw/States", full.names = TRUE)
states_delete <- states_delete[!(states_delete %in% paste0("./Data/Raw_Data/BBS_raw/States/", c("BritCol.zip", "Washing.zip", "Oregon.zip")))]

file.remove(states_delete)

# Read and filter British Columbia total annual species counts and filter to
# Point Grey route (#212).

PointGrey_TotalCounts <- read_csv("./Data/Raw_Data/BBS_raw/British_Columbia/BritCol.csv") %>%
  filter(Route == 212) %>%
  select(RouteDataID, CountryNum, StateNum, Route, Year, AOU, SpeciesTotal)

# Filter annual total counts for all species at Point Grey route to only include
# Black-capped Chickadee (AOU code 07350). Filter out now redundant AOU codes,
# rename columns to more accurately describe the data they contain.

PointGrey_BCCH <- PointGrey_TotalCounts %>%
  filter(AOU == "07350") %>%
  select(-AOU) %>%
  mutate(BCCH_Count = SpeciesTotal) %>%
  select(-SpeciesTotal)

# Write data to cleaned CSV file, if necessary creating a subdirectory for the
# filtered dataset.

if(!(dir.exists("./Data/Clean_Data/BBS_filtered"))) {
  dir.create("./Data/Clean_Data/BBS_filtered")
}

write_csv(PointGrey_BCCH, "./Data/Clean_Data/BBS_filtered/PointGrey_BCCH.csv")

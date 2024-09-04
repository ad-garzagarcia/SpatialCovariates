# Load necessary libraries
library(raster)
library(sp)
library(sf)
library(dplyr)
library(ggplot2)

# Define paths
data_path <- "C://Jag_Metadata_20240820.csv"
hfp_path <- "D:/Spatial Covariates/hii/"
flii_raster_path <- "D:/Spatial Covariates/flii/flii_earth.tif"
ecoregion_shp_path <- "D:/Spatial Covariates/Ecoregions2017/Ecoregions2017.shp"

# Load your dataset
data <- read.csv(data_path)


# Convert your data to an sf object with coordinates
data_sf <- st_as_sf(data, coords = c("longs_x", "lats_y"), crs = 4326, remove = FALSE)

# Load the Ecoregions shapefile and clean geometries
ecoregions <- st_read(ecoregion_shp_path)
ecoregions_clean <- st_make_valid(ecoregions)

data_joined <- st_join(data_sf, ecoregions_clean, left = TRUE) %>%
  mutate(Ecoregion = ECO_NAME,
         Biome = BIOME_NAME,
         Biome_Number = BIOME_NUM) %>%
  st_drop_geometry()

# Function to extract the average HII value within a 25 km buffer around coordinates
extract_hfp_buffer <- function(lat, lon, surv_year, buffer_radius = 25000) {
  # Adjust the survey year if it's beyond 2020 or before 2000
  if (surv_year > 2020) {
    surv_year <- 2020
  } else if (surv_year < 2000) {
    surv_year <- 2000
  }
  
  # Construct the file name based on the adjusted survey year
  file_name <- paste0(hfp_path, "hii_", surv_year, "-01-01.tif")
  
  # Load the corresponding  raster
  if (file.exists(file_name)) {
    hfp_raster <- raster(file_name)
    
    # Create a spatial point for the coordinates assuming they are in WGS 84
    point <- st_as_sf(data.frame(lon = lon, lat = lat), coords = c("lon", "lat"), crs = 4326)
    
    # Transform the point to the raster's CRS
    point_transformed <- st_transform(point, crs(hfp_raster))
    
    # Create a buffer around the point
    buffer <- st_buffer(point_transformed, dist = buffer_radius)
    
    # Convert the buffer back to a Spatial object for compatibility with raster operations
    buffer_sp <- as(buffer, "Spatial")
    
    # Crop the raster to the buffer extent
    cropped_raster <- crop(hfp_raster, buffer_sp)
    
    # Mask the raster with the buffer
    masked_raster <- mask(cropped_raster, buffer_sp)
    
    # Calculate the mean hfp value within the buffer
    hfp_value <- cellStats(masked_raster, stat = 'mean', na.rm = TRUE)
    
    return(list(hfp_value = hfp_value, source_file = file_name))
  } else {
    return(list(hfp_value = NA, source_file = NA))
  }
}

# Apply the function to each row in the dataset
results_hfp <- mapply(extract_hfp_buffer, 
                      lat = data_joined$lats_y, 
                      lon = data_joined$longs_x, 
                      surv_year = data_joined$surv_year, 
                      SIMPLIFY = FALSE)

# Extract the hfp values and source file information
data_joined$hfp_value <- sapply(results_hfp, function(x) x$hfp_value)
data_joined$hfp_source_file <- sapply(results_hfp, function(x) x$source_file)

# Function to extract the average FLII value within a 25 km buffer around coordinates
extract_flii_buffer <- function(lat, lon, buffer_radius = 25000) {
  # Load the FLII raster
  flii_raster <- raster(flii_raster_path)
  
  # Create a spatial point for the coordinates assuming they are in WGS 84
  point <- st_as_sf(data.frame(lon = lon, lat = lat), coords = c("lon", "lat"), crs = 4326)
  
  # Transform the point to the raster's CRS
  point_transformed <- st_transform(point, crs(flii_raster))
  
  # Create a buffer around the point
  buffer <- st_buffer(point_transformed, dist = buffer_radius)
  
  # Convert the buffer back to a Spatial object for compatibility with raster operations
  buffer_sp <- as(buffer, "Spatial")
  
  # Crop the raster to the buffer extent
  cropped_raster <- crop(flii_raster, buffer_sp)
  
  # Mask the raster with the buffer
  masked_raster <- mask(cropped_raster, buffer_sp)
  
  # Calculate the mean FLII value within the buffer
  flii_value <- cellStats(masked_raster, stat = 'mean', na.rm = TRUE)
  
  return(flii_value)
}

# Apply the function to each row in the dataset
data_joined$FLII_value <- mapply(extract_flii_buffer, 
                                 lat = data_joined$lats_y, 
                                 lon = data_joined$longs_x, 
                                 SIMPLIFY = TRUE)


# Plot Ecoregion
ggplot(data_joined, aes(x = longs_x, y = lats_y, color = Ecoregion)) +
  geom_point(size = 2) +
  theme_minimal() +
  labs(title = "Ecoregions at Survey Locations",
       x = "Longitude", 
       y = "Latitude")

# Plot Biome
ggplot(data_joined, aes(x = longs_x, y = lats_y, color = Biome)) +
  geom_point(size = 2) +
  theme_minimal() +
  labs(title = "Biomes at Survey Locations",
       x = "Longitude", 
       y = "Latitude")



# Plot hfp Value
ggplot(data_joined, aes(x = longs_x, y = lats_y, color = hfp_value)) +
  geom_point(size = 2) +
  scale_color_viridis_c(option = "viridis", name = "hfp Value") +
  theme_minimal() +
  labs(title = "Human Footprint Index (hfp) at Survey Locations",
       x = "Longitude", 
       y = "Latitude")

# Plot FLII Value
ggplot(data_joined, aes(x = longs_x, y = lats_y, color = FLII_value)) +
  geom_point(size = 2) +
  scale_color_viridis_c(option = "viridis", name = "FLII Value") +
  theme_minimal() +
  labs(title = "Forest Landscape Integrity Index (FLII) at Survey Locations",
       x = "Longitude", 
       y = "Latitude")

#Save the final dataset with all covariates
write.csv(data_joined, "C:/Users/Alejandro/OneDrive - Griffith University/Desktop/JagMetadata_Raw_SpatialCovaraites.csv", row.names = FALSE)

#We have mangroves due to Belize ("Jaguar ( Panthera onca ) density and tenure in a critical biological corridor")
# so we need to chnage it to Peten-veracruz moist forests and Tropical Voradleaf forests

# Modify entries with "Mangroves" in BIO_NAME
data_joined <- data_joined %>%
  mutate(Biome = ifelse(grepl("Mangroves", Biome), "Tropical & Subtropical Moist Broadleaf Forests", Biome),
         Biome_Number = ifelse(grepl("Mangroves", Biome), 1, Biome_Number),
         Ecoregion = ifelse(grepl("Mangroves", Biome), "Peten-Veracruz moist forests", Ecoregion))


#Lets check again..
# Plot Biome
ggplot(data_joined, aes(x = longs_x, y = lats_y, color = Biome)) +
  geom_point(size = 2) +
  theme_minimal() +
  labs(title = "Biomes at Survey Locations",
       x = "Longitude", 
       y = "Latitude")
#No mangroves so that checks out, lets check the data for ECOREGIONS
table(data_joined$Ecoregion)
table(data_joined$Biome)
colnames(data_joined)
#Now lest filter
# Check for NAs in Biome and Ecoregion columns
na_biome <- sum(is.na(data_joined$Biome))
na_ecoregion <- sum(is.na(data_joined$Ecoregion))

# Print results
cat("Number of NAs in Biome column:", na_biome, "\n")
cat("Number of NAs in Ecoregion column:", na_ecoregion, "\n")
# Filter and print rows where Biome or Ecoregion is NA
na_rows <- data_joined %>%
  filter(is.na(Biome) | is.na(Ecoregion))

# Print the rows with NA values in Biome or Ecoregion
print(na_rows)

colnames(data_joined)

# Remove commas and convert camtrap_days to numeric
data_joined <- data_joined %>%
  mutate(camtrap_days = as.numeric(gsub(",", "", camtrap_days)))

# Check if the conversion was successful
if (all(!is.na(data_joined$camtrap_days))) {
  cat("camtrap_days column successfully converted to numeric.\n")
} else {
  cat("Some entries in camtrap_days could not be converted to numeric. Titles of problematic rows:\n")
  
  # Print titles of rows where conversion failed
  failed_conversion_rows <- data_joined %>%
    filter(is.na(camtrap_days))
  
  print(failed_conversion_rows$title)
}

table(data_joined$country)

# Merge the specified countries
data_joined <- data_joined %>%
  mutate(country = recode(country,
                          "Argentina" = "Argentina and Paraguay",
                          "Paraguay" = "Argentina and Paraguay",
                          "French Guyana" = "Guyanas",
                          "Guyana" = "Guyanas",
                          "Guatemala" = "Guatemala and Honduras",
                          "Honduras" = "Guatemala and Honduras"))

# Check the result
table(data_joined$country)

# Save the cleaned dataset as a CSV file
write.csv(data_joined, "C:/Users/Alejandro/OneDrive - Griffith University/Desktop/curated_JagMetadata20240820.csv", row.names = FALSE)


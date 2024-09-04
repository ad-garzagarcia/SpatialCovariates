
# README: Jaguar Metadata and Spatial Covariate Extraction / Extracción de Metadatos de Jaguar y Covariables Espaciales

<details>
  <summary>Versión en Español</summary>

## Resumen
Este script procesa datos de encuestas de densidad de jaguares, vinculándolos a covariables espaciales como el Índice de Huella Humana (HFP), el Índice de Integridad del Paisaje Forestal (FLII) y los datos asociados a ecorregiones y biomas. Extrae la información espacial relevante, limpia y modifica el conjunto de datos, y genera gráficos visuales de las covariables y características geográficas.

El resultado final es un conjunto de datos curado que se guarda como un archivo CSV e incluye las covariables espaciales para su análisis posterior.

## Requisitos
Para ejecutar este script, se requieren las siguientes bibliotecas de R:

- `raster`
- `sp`
- `sf`
- `dplyr`
- `ggplot2`

## Archivos y Rutas
Asegúrate de que las siguientes rutas en el script sean correctas antes de ejecutarlo:

- **`data_path`**: Ruta al archivo CSV de entrada que contiene los metadatos de densidad de jaguares.
- **`hfp_path`**: Directorio que contiene los archivos raster del Índice de Huella Humana (HFP).
- **`flii_raster_path`**: Ruta al archivo raster del Índice de Integridad del Paisaje Forestal (FLII).
- **`ecoregion_shp_path`**: Ruta al archivo shapefile de las ecorregiones.
</details>



<details>
  <summary>English Version</summary>

## Overview
This script processes Jaguar density survey data, linking it to spatial covariates such as the Human Footprint Index (HFP), Forest Landscape Integrity Index (FLII), and associated ecoregion and biome data. It extracts relevant spatial information, cleans and modifies the dataset, and generates visual plots of covariates and geographic features.

The final output is a curated dataset saved as a CSV file that includes spatial covariates for further analysis.

## Requirements
To run this script, the following R libraries are required:

- `raster`
- `sp`
- `sf`
- `dplyr`
- `ggplot2`

## Files and Paths
Ensure that the following paths in the script are correct before running:

- **`data_path`**: Path to the input CSV file containing Jaguar density metadata.
- **`hfp_path`**: Directory containing Human Footprint Index (HFP) raster files.
- **`flii_raster_path`**: Path to the Forest Landscape Integrity Index (FLII) raster file.
- **`ecoregion_shp_path`**: Path to the shapefile for ecoregions.

# README: Metadatos de Jaguar y Extracción de Covariables Espaciales


#!/usr/local/bin/Rscript

library(dht)
dht::greeting()

dht::qlibrary(dplyr)
dht::qlibrary(tidyr)
dht::qlibrary(sf)

doc <- '
Usage:
  census_block.R <filename> <census_year>
'

opt <- docopt::docopt(doc)
## for interactive testing
## opt <- docopt::docopt(doc, args = c('test/my_address_file_geocoded.csv', '2020', 'tracts'))

if(! opt$census_year %in% c('2020', '2010')) {
  cli::cli_alert_danger('Available census geographies include years 2010, and 2020.')
  stop()
}

message('\nreading input file...')
raw_data <- readr::read_csv(opt$filename)

## prepare data for calculations
raw_data$.row <- seq_len(nrow(raw_data))

d <-
  raw_data %>%
  select(.row, lat, lon) %>%
  na.omit() %>%
  group_by(lat, lon) %>%
  nest(.rows = c(.row)) %>%
  st_as_sf(coords = c('lon', 'lat'), crs = 4326)

d <- st_transform(d, 5072)

message('\nloading census shape files...')


geography <- readRDS(file=paste0("/app/block_", opt$census_year, "_5072.rds"))


message('\nfinding containing geography for each point...')
d <- sf::st_join(d, geography, left = FALSE, largest = TRUE)

## merge back on .row after unnesting .rows into .row
d <- d %>%
  unnest(cols = c(.rows)) %>%
  st_drop_geometry()

out <- left_join(raw_data, d, by = '.row') %>% select(-.row)

out_file_name <- paste0(tools::file_path_sans_ext(opt$filename), '_census_block_', opt$census_year, '.csv')
readr::write_csv(out, out_file_name)
message('\nFINISHED! output written to ', out_file_name)

library(tidyverse)
library(sf)

# 2010
library(tidyverse)

get_block_shp <- function(fl_name, state_folder, state_fips) {
  fl.name.zip <- paste0(fl_name, '.zip')
  download.file(paste0('https://www2.census.gov/geo/tiger/TIGER2020PL/STATE/', state_folder, "/",
                       state_fips, "/", fl.name.zip),
                destfile=fl.name.zip)
  unzip(fl.name.zip)
  unlink(fl.name.zip)
  fl.name.shp <- paste0(fl_name, '.shp')
  d.tmp <- sf::read_sf(fl.name.shp) %>% sf::st_transform(5072)
  unlink(list.files(pattern = fl_name))
  return(d.tmp)
}

states <-
  tigris::states() %>%
  sf::st_drop_geometry() %>%
  arrange(STATEFP) %>%
  select(STATEFP, NAME) %>%
  mutate(state_folder = paste0(STATEFP, "_", toupper(NAME)),
         state_folder = stringr::str_replace_all(state_folder, " ", "_"),
         fl_name = paste0('tl_2020_', STATEFP, '_tabblock20')) %>%
  filter(as.numeric(STATEFP) < 57)

block_shp <- pmap(list(states$fl_name, states$state_folder, states$STATEFP),
                        possibly(get_block_group_shp, NA_real_))
names(block_shp) <- states$NAME

block_shp_all <- block_shp[[1]]

for (i in 2:length(block_shp)) {
  block_shp_all <- rbind(block_shp_all, block_shp[[i]])
}

blk_sf_2010 <- block_shp_all %>%
  dplyr::select(fips_block_id_2010 = GEOID10,
                geometry) %>%
  mutate(fips_block_id_2010 = as.character(fips_block_id_2010))

saveRDS(blk_sf_2020, "block_2010_5072.rds")



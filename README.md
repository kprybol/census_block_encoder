# census_block_group <a href='https://degauss.org'><img src='DeGAUSS_hex.png' align="right" height="138.5" /></a>

> A docker container for assigning census block group and/or tract identifier to geocoded addresses.

## DeGAUSS example call

```sh
docker run --rm -v $PWD:/tmp ghcr.io/degauss-org/census_block_group:0.4.3 my_address_file_geocoded.csv 2010
```

* The first argument (`my_address_file_geocoded.csv`) is the name of your geocoded csv file.

* The second argument (`2010`) is the year for assignment of census geographies. Available years for census block group and census tract identifiers include 2010, and 2020.
    
## Geomarker data

- block shapefiles for 2010 were obtained directly from the [U.S. Census Bureau](https://www.census.gov/geographies/mapping-files/2020/geo/tiger-line-file.html) via `get_2010_block.R`. 

- block shapefiles for 2020 were obtained directly from the [U.S. Census Bureau](https://www.census.gov/geographies/mapping-files/2020/geo/tiger-line-file.html) via `get_2020_block.R`. 

- to avoid any geometry evaluation errors (i.e. self-intersecting rings), we used `sf::st_make_valid` on all tract and block group polygons

- The transformed block group shapefiles are stored at 

    + [`cert-geo-buckets.s3.amazonaws.com/block_2020_5072.rds`](https://cert-geo-buckets.s3.amazonaws.com/block_2020_5072.rds)

    + [`cert-geo-buckets.s3.amazonaws.com/block_2010_5072.rds`](https://cert-geo-buckets.s3.amazonaws.com/block_2010_5072.rds)


## Census block groups and GEOIDs

- Census blocks are a low level designation within the US Census geographical hierarchy, one degree finer than a census tract. The US Census provides a diagram visualizing the [hierarchy](https://www2.census.gov/geo/pdfs/reference/geodiagram.pdf).
- The first 11 characters in a census block group GEOID indicate the census tract, county and state that the block group lies within. The US Census GEOIDs are constructed in a manner that reflects the geographical hierary of the designated area. By using the segments of the GEOID, it is possible to select data based on area types further up in the hierarchy.

    | Area Type | GEOID | Number of Digits | Example Area | Example GEOID |
    | :-- | :-- | :-- | :-- | :-- |
    | State | State | 2 | Ohio | 39 |
    | County | State + County | 2+3=5 | Hamilton County | 39061 |
    | Census Tract | State + County + Tract | 2+3+6=11 | Tract 32 in Hamilton County | 39061003200 | 
    | Block Group | State + County + Tract +<br /> Block Group | 2+3+6+1=12 | Block Group 1 in Tract 32 | 390610032001 |

## st_census_tract

For spatiotemporal data in which each location is associated with a specified date range, consider using the [`st_census_tract`](https://degauss.org/st_census_tract/) container, which adds census tract identifiers for the appropriate vintage (1970-2020) based on `start_date` and `end_date` for each input location.

## DeGAUSS details

For detailed documentation on DeGAUSS, including general usage and installation, please see the [DeGAUSS webpage](https://degauss.org).

### References

Steven Manson, Jonathan Schroeder, David Van Riper, Tracy Kugler, and Steven Ruggles. IPUMS National Historical Geographic Information System: Version 15.0 [dataset]. Minneapolis, MN: IPUMS. 2020. http://doi.org/10.18128/D050.V15.0


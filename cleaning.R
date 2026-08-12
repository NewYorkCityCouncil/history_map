# cleaning
library(tidyverse)
library(sf)
library(leaflet)


raw_1940 <- read_csv("data/raw/1940.csv") %>%
  janitor::clean_names() %>%
  filter(county %in% c("Bronx", "New York", "Queens", "Kings", "Richmond"))

raw_1950 <- read_csv("data/raw/1950.csv") %>%
  janitor::clean_names() %>%
  filter(county %in% c("Bronx", "New York", "Queens", "Kings", "Richmond"))

raw_1960 <- read_csv("data/raw/1960.csv") %>%
  janitor::clean_names() %>%
  filter(county %in% c("Bronx", "New York", "Queens", "Kings", "Richmond"))

raw_1970 <- read_csv("data/raw/1970.csv") %>%
  janitor::clean_names() %>%
  filter(county %in% c("Bronx", "New York", "Queens", "Kings", "Richmond"))

raw_1980_his <- read_csv("data/raw/1980_his.csv") %>%
  janitor::clean_names() %>%
  filter(county %in% c("Bronx", "New York", "Queens", "Kings", "Richmond"))

raw_1980_nonhis <- read_csv("data/raw/1980_nonhis.csv") %>%
  janitor::clean_names() %>%
  filter(county %in% c("Bronx", "New York", "Queens", "Kings", "Richmond"))

raw_1990 <- read_csv("data/raw/1990.csv") %>%
  janitor::clean_names() %>%
  filter(county %in% c("Bronx", "New York", "Queens", "Kings", "Richmond"))

raw_2000 <- read_csv("data/raw/2000.csv") %>%
  janitor::clean_names() %>%
  filter(county %in% c("Bronx", "New York", "Queens", "Kings", "Richmond"))

raw_2010 <- read_csv("data/raw/2010.csv") %>%
  janitor::clean_names() %>%
  filter(
    county %in%
      c(
        "Bronx County",
        "New York County",
        "Queens County",
        "Kings County",
        "Richmond County"
      )
  )

raw_2020 <- read_csv("data/raw/2020.csv") %>%
  janitor::clean_names() %>%
  filter(
    county %in%
      c(
        "Bronx County",
        "New York County",
        "Queens County",
        "Kings County",
        "Richmond County"
      )
  )


############
## Step 1 ##
############

data_1940 <- raw_1940 %>%
  mutate(
    total = white + nonwhite
  ) %>%
  mutate(black = NA, hispanic = NA, asian = NA) %>%
  select(gisjoin, year, total, white, black, hispanic, asian, other = nonwhite)

data_1950 <- raw_1950 %>%
  mutate(total = white + black + other) %>%
  mutate(hispanic = NA, asian = NA) %>%
  select(gisjoin, year, total, white, black, hispanic, asian, other)

data_1960 <- raw_1960 %>%
  mutate(total = white + black + other) %>%
  mutate(hispanic = NA, asian = NA) %>%
  select(gisjoin, year, total, white, black, hispanic, asian, other)

data_1970 <- raw_1970 %>%
  mutate(
    white = white_man + white_woman,
    black = black_man + black_woman,
    asian = japanese_man +
      japanese_woman +
      chinese_man +
      chinese_woman +
      korean_man +
      korean_woman +
      filipino_man +
      filipino_woman,
    other = other_man +
      other_woman +
      native_man +
      native_woman +
      hawaiian_man +
      hawaiian_woman
  ) %>%
  mutate(total = white + black + asian + other) %>%
  mutate(hispanic = NA) %>%
  select(gisjoin, year, total, white, black, hispanic, asian, other)

data_1980 <- raw_1980_his %>%
  select(gisjoin, white_his, black_his, native_his, other_his) %>%
  {
    left_join(raw_1980_nonhis, ., by = "gisjoin")
  } %>%
  mutate(
    white = white_total - white_his,
    black = black_total - black_his,
    native = native_total - native_his,
    other = other_total - other_his,
    hispanic = white_his + black_his + native_his + other_his,
    other = other + native,
  ) %>%
  rename(asian = asian_total) %>%
  select(
    -c(
      "white_his",
      "black_his",
      "native_his",
      "other_his",
      "white_total",
      "black_total",
      "native_total",
      "other_total",
      "native"
    )
  ) %>%
  mutate(total = white + black + hispanic + asian + other) %>%
  select(gisjoin, year, total, white, black, hispanic, asian, other)


data_1990 <- raw_1990 %>%
  mutate(
    hispanic = white_his + black_his + asian_his + native_his + other_his
  ) %>%
  select(
    -c(
      "native",
      "white_his",
      "black_his",
      "asian_his",
      "native_his",
      "other_his",
    )
  ) %>%
  mutate(total = white + black + hispanic + asian + other) %>%
  select(gisjoin, year, total, white, black, hispanic, asian, other)


data_2000 <- raw_2000 %>%
  mutate(other = other + hawaiian + native + multi) %>%
  mutate(
    hispanic = white_his +
      black_his +
      asian_his +
      native_his +
      hawaiian_his +
      other_his +
      multi_his
  ) %>%
  select(
    -c(
      "hawaiian",
      "native",
      "multi",
      "white_his",
      "black_his",
      "asian_his",
      "native_his",
      "hawaiian_his",
      "other_his",
      "multi_his"
    )
  ) %>%
  mutate(total = white + black + hispanic + asian + other) %>%
  select(gisjoin, year, total, white, black, hispanic, asian, other)

data_2010 <- raw_2010 %>%
  mutate(other = other + hawaiian + native + multi) %>%
  select(
    -c(
      "hawaiian",
      "native",
      "multi",
      "non_his",
      "white_his",
      "black_his",
      "asian_his",
      "native_his",
      "hawaiian_his",
      "other_his",
      "multi_his"
    )
  ) %>%
  mutate(total = white + black + hispanic + asian + other) %>%
  select(gisjoin, year, total, white, black, hispanic, asian, other)

data_2020 <- raw_2020 %>%
  mutate(other = other + hawaiian + native + multi) %>%
  select(
    -c(
      "hawaiian",
      "native",
      "multi",
      "non_his",
      "white_his",
      "black_his",
      "asian_his",
      "native_his",
      "hawaiian_his",
      "other_his",
      "multi_his"
    )
  ) %>%
  mutate(total = white + black + hispanic + asian + other) %>%
  select(gisjoin, year, total, white, black, hispanic, asian, other)


##############
### INCOME ###
##############

raw_inc_1950 <- read_csv("data/raw/inc_1950.csv") %>%
  janitor::clean_names() %>%
  filter(county %in% c("Bronx", "Kings", "Queens", "New York", "Richmond"))

bins_1950 <- tribble(
  ~lower , ~upper ,
       0 ,    499 ,
     500 ,    999 ,
    1000 ,   1499 ,
    1500 ,   1999 ,
    2000 ,   2499 ,
    2500 ,   2999 ,
    3000 ,   3499 ,
    3500 ,   3999 ,
    4000 ,   4499 ,
    4500 ,   4999 ,
    5000 ,   5999 ,
    6000 ,   6999 ,
    7000 ,   9999 ,
   10000 , 100000
)

raw_inc_1960 <- read_csv("data/raw/inc_1960.csv") %>%
  janitor::clean_names() %>%
  filter(county %in% c("Bronx", "Kings", "Queens", "New York", "Richmond")) %>%
  mutate(
    inc0_to_999 = fam0_to_999 + per0_to_999,
    inc1000_to_1999 = fam_1000_to_1999 + per1000_to_1999,
    inc2000_to_2999 = fam2000_to_2999 + per2000_to_2999,
    inc3000_to_3999 = fam3000_to_3999 + per3000_to_3999,
    inc4000_to_4999 = fam4000_to_4999 + per4000_to_4999,
    inc5000_to_5999 = fam5000_to_5999 + per5000_to_5999,
    inc6000_to_6999 = fam6000_to_6999 + per6000_to_6999,
    inc7000_to_7999 = fam7000_to_7999 + per7000_to_7999,
    inc8000_to_8999 = fam8000_to_8999 + per8000_to_8999,
    inc9000_to_9999 = fam9000_to_9999 + per9000_to_9999,
    inc10000_to_14999 = fam10000_to_14999 + per10000_to_14999,
    inc15000_to_24999 = fam15000_to_24999 + per15000_to_24999,
    inc25000_or_over = fam25000_or_over + per25000_or_over
  )

bins_1960 <- tribble(
  ~lower , ~upper ,
       0 ,    999 ,
    1000 ,   1999 ,
    2000 ,   2999 ,
    3000 ,   3999 ,
    4000 ,   4999 ,
    5000 ,   5999 ,
    6000 ,   6999 ,
    7000 ,   7999 ,
    8000 ,   8999 ,
    9000 ,   9999 ,
   10000 ,  14999 ,
   15000 ,  24999 ,
   25000 , 250000
)


raw_inc_1970 <- read_csv("data/raw/inc_1970.csv") %>%
  janitor::clean_names() %>%
  filter(county %in% c("Bronx", "Kings", "Queens", "New York", "Richmond")) %>%
  mutate(
    inc0_to_999 = fam0_to_999 + per0_to_999,
    inc1000_to_1999 = fam1000_to_1999 + per1000_to_1999,
    inc2000_to_2999 = fam2000_to_2999 + per2000_to_2999,
    inc3000_to_3999 = fam3000_to_3999 + per3000_to_3999,
    inc4000_to_4999 = fam4000_to_4999 + per4000_to_4999,
    inc5000_to_5999 = fam5000_to_5999 + per5000_to_5999,
    inc6000_to_6999 = fam6000_to_6999 + per6000_to_6999,
    inc7000_to_7999 = fam7000_to_7999 + per7000_to_7999,
    inc8000_to_8999 = fam8000_to_8999 + per8000_to_8999,
    inc9000_to_9999 = fam9000_to_9999 + per9000_to_9999,
    inc10000_to_11999 = fam10000_to_11999 + per10000_to_11999,
    inc12000_to_14999 = fam12000_to_14999 + per12000_to_14999,
    inc15000_to_24999 = fam15000_to_24999 + per15000_to_24999,
    inc25000_to_49999 = fam25000_to_49999 + per25000_to_49999,
    inc50000_or_over = fam50000_and_over + per50000_and_over
  ) %>%
  mutate(
    inc0_to_999 = replace_na(inc0_to_999, 0),
    inc1000_to_1999 = replace_na(inc1000_to_1999, 0),
    inc2000_to_2999 = replace_na(inc2000_to_2999, 0),
    inc3000_to_3999 = replace_na(inc3000_to_3999, 0),
    inc4000_to_4999 = replace_na(inc4000_to_4999, 0),
    inc5000_to_5999 = replace_na(inc5000_to_5999, 0),
    inc6000_to_6999 = replace_na(inc6000_to_6999, 0),
    inc7000_to_7999 = replace_na(inc7000_to_7999, 0),
    inc8000_to_8999 = replace_na(inc8000_to_8999, 0),
    inc9000_to_9999 = replace_na(inc9000_to_9999, 0),
    inc10000_to_11999 = replace_na(inc10000_to_11999, 0),
    inc12000_to_14999 = replace_na(inc12000_to_14999, 0),
    inc15000_to_24999 = replace_na(inc15000_to_24999, 0),
    inc25000_to_49999 = replace_na(inc25000_to_49999, 0),
    inc50000_or_over = replace_na(inc50000_or_over, 0)
  )

bins_1970 <- tribble(
  ~lower , ~upper ,
       0 ,    999 ,
    1000 ,   1999 ,
    2000 ,   2999 ,
    3000 ,   3999 ,
    4000 ,   4999 ,
    5000 ,   5999 ,
    6000 ,   6999 ,
    7000 ,   7999 ,
    8000 ,   8999 ,
    9000 ,   9999 ,
   10000 ,  11999 ,
   12000 ,  14999 ,
   15000 ,  24999 ,
   25000 ,  49999 ,
   50000 , 500000
)

raw_inc_1980_2020 <- read_csv("data/raw/inc_1980_2020.csv") %>%
  janitor::clean_names() %>%
  filter(
    county %in%
      c(
        "Bronx County",
        "Kings County",
        "Queens County",
        "New York County",
        "Richmond County"
      )
  )


grouped_median_row <- function(freq, lower, upper) {
  cum_freq <- cumsum(freq)
  N <- sum(freq)

  if (N == 0) {
    return(NA)
  } # handle empty rows

  median_idx <- which(cum_freq >= N / 2)[1]

  L <- lower[median_idx]
  h <- upper[median_idx] - lower[median_idx]
  cf_prev <- ifelse(median_idx == 1, 0, cum_freq[median_idx - 1])
  f <- freq[median_idx]

  median_est <- L + ((N / 2 - cf_prev) / f) * h

  return(median_est)
}


inc_1950 <- raw_inc_1950 %>%
  select(gisjoin) %>%
  mutate(
    income = apply(
      raw_inc_1950 %>% select(starts_with("inc")),
      1,
      grouped_median_row,
      lower = bins_1950$lower,
      upper = bins_1950$upper
    )
  )


inc_1960 <- raw_inc_1960 %>%
  select(gisjoin) %>%
  mutate(
    income = apply(
      raw_inc_1960 %>% select(starts_with("inc")),
      1,
      grouped_median_row,
      lower = bins_1960$lower,
      upper = bins_1960$upper
    )
  )

inc_1970 <- raw_inc_1970 %>%
  select(gisjoin) %>%
  mutate(
    income = apply(
      raw_inc_1970 %>% select(starts_with("inc")),
      1,
      grouped_median_row,
      lower = bins_1970$lower,
      upper = bins_1970$upper
    )
  )


inc_1980 <- raw_inc_1980_2020 %>%
  select(gisjoin = gjoin1980, income = inc_1980)

inc_1990 <- raw_inc_1980_2020 %>%
  select(gisjoin = gjoin1990, income = inc_1990)

inc_2000 <- raw_inc_1980_2020 %>%
  select(gisjoin = gjoin2000, income = inc_2000)

inc_2010 <- raw_inc_1980_2020 %>%
  select(gisjoin = gjoin2012, income = inc_2010)

inc_2020 <- raw_inc_1980_2020 %>%
  select(gisjoin = gjoin2022, income = inc_2020)

#########################
### FILTER GEOMETRIES ###
#########################

# geom_1940_raw <- st_read("geometries/raw/1940/US_tract_1940_conflated.shp") %>%
#   st_transform(4326)

# geom_1940 <- geom_1940_raw %>%
#   filter(STATE == "36") %>%
#   filter(COUNTY %in% c("085", "047", "081", "061", "005")) %>%
#   select(GISJOIN, geometry)

# st_write(geom_1940, "geometries/clean/1940.geojson")

# geom_1950_raw <- st_read("geometries/raw/1950/US_tract_1950_conflated.shp") %>%
#   st_transform(4326)

# geom_1950 <- geom_1950_raw %>%
#   filter(NHGISST == "360") %>%
#   filter(COUNTY %in% c("085", "047", "081", "061", "005")) %>%
#   select(GISJOIN, geometry)

# st_write(geom_1950, "geometries/clean/1950.geojson")

# geom_1960_raw <- st_read("geometries/raw/1960/US_tract_1960_conflated.shp") %>%
#   st_transform(4326)

# geom_1960 <- geom_1960_raw %>%
#   filter(NHGISST == "360") %>%
#   filter(COUNTY %in% c("085", "047", "081", "061", "005")) %>%
#   select(GISJOIN, geometry)

# st_write(geom_1960, "geometries/clean/1960.geojson")

# geom_1970_raw <- st_read("geometries/raw/1970/US_tract_1970_conflated.shp") %>%
#   st_transform(4326)

# geom_1970 <- geom_1970_raw %>%
#   filter(NHGISST == "360") %>%
#   filter(COUNTY %in% c("085", "047", "081", "061", "005")) %>%
#   select(GISJOIN, geometry)

# st_write(geom_1970, "geometries/clean/1970.geojson")

# geom_1980_raw <- st_read("geometries/raw/1980/US_tract_1980_conflated.shp") %>%
#   st_transform(4326)

# geom_1980 <- geom_1980_raw %>%
#   filter(NHGISST == "360") %>%
#   filter(COUNTY %in% c("085", "047", "081", "061", "005")) %>%
#   select(GISJOIN, geometry)

# st_write(geom_1980, "geometries/clean/1980.geojson")

# geom_1990_raw <- st_read("geometries/raw/1990/US_tract_1990_conflated.shp") %>%
#   st_transform(4326)

# geom_1990 <- geom_1990_raw %>%
#   filter(NHGISST == "360") %>%
#   filter(COUNTY %in% c("085", "047", "081", "061", "005")) %>%
#   select(GISJOIN, geometry)

# st_write(geom_1990, "geometries/clean/1990.geojson")

# geom_2000_raw <- st_read("geometries/raw/2000/US_tract_2000_tl10.shp") %>%
#   st_transform(4326)

# geom_2000 <- geom_2000_raw %>%
#   filter(STATEFP00 == "36") %>%
#   filter(COUNTYFP00 %in% c("085", "047", "081", "061", "005")) %>%
#   select(GISJOIN, geometry)

# st_write(geom_2000, "geometries/clean/2000.geojson")

# geom_2010_raw <- st_read("geometries/raw/2010/US_tract_2010.dbf") %>%
#   st_transform(4326)

# geom_2010 <- geom_2010_raw %>%
#   filter(STATEFP10 == "36") %>%
#   filter(COUNTYFP10 %in% c("085", "047", "081", "061", "005")) %>%
#   select(GISJOIN, geometry)

# st_write(geom_2010, "geometries/clean/2010.geojson")

# geom_2020_raw <- st_read("geometries/raw/2020/US_tract_2020.dbf") %>%
#   st_transform(4326)

# geom_2020 <- geom_2020_raw %>%
#   filter(STATEFP == "36") %>%
#   filter(COUNTYFP %in% c("085", "047", "081", "061", "005")) %>%
#   select(GISJOIN, geometry)

# st_write(geom_2020, "geometries/clean/2020.geojson")

#######################
### JOIN GEOMETRIES ###
#######################

geom_1940 <- st_read("geometries/clean/1940.geojson")
geom_1950 <- st_read("geometries/clean/1950.geojson")
geom_1960 <- st_read("geometries/clean/1960.geojson")
geom_1970 <- st_read("geometries/clean/1970.geojson")
geom_1980 <- st_read("geometries/clean/1980.geojson")
geom_1990 <- st_read("geometries/clean/1990.geojson")
geom_2000 <- st_read("geometries/clean/2000.geojson")
geom_2010 <- st_read("geometries/clean/2010.geojson")
geom_2020 <- st_read("geometries/clean/2020.geojson")

data <-
  rbind(
    data_1940 %>%
      mutate(income = NA) %>%
      left_join(geom_1940, by = c("gisjoin" = "GISJOIN")),
    data_1950 %>%
      left_join(inc_1950, by = "gisjoin") %>%
      left_join(geom_1950, by = c("gisjoin" = "GISJOIN")),
    data_1960 %>%
      left_join(inc_1960, by = "gisjoin") %>%
      left_join(geom_1960, by = c("gisjoin" = "GISJOIN")),
    data_1970 %>%
      left_join(inc_1970, by = "gisjoin") %>%
      left_join(geom_1970, by = c("gisjoin" = "GISJOIN")),
    data_1980 %>%
      left_join(inc_1980, by = "gisjoin") %>%
      left_join(geom_1980, by = c("gisjoin" = "GISJOIN")),
    data_1990 %>%
      left_join(inc_1990, by = "gisjoin") %>%
      left_join(geom_1990, by = c("gisjoin" = "GISJOIN")),
    data_2000 %>%
      left_join(inc_2000, by = "gisjoin") %>%
      left_join(geom_2000, by = c("gisjoin" = "GISJOIN")),
    data_2010 %>%
      left_join(inc_2010, by = "gisjoin") %>%
      left_join(geom_2010, by = c("gisjoin" = "GISJOIN")),
    data_2020 %>%
      left_join(inc_2020, by = "gisjoin") %>%
      left_join(geom_2020, by = c("gisjoin" = "GISJOIN"))
  ) %>%
  mutate(
    perc_white = white / total,
    perc_black = black / total,
    perc_hispanic = hispanic / total,
    perc_asian = asian / total,
    perc_other = other / total
  ) %>%
  mutate(income = if_else(total < 50, NA, income)) %>%
  {
    st_set_geometry(., .$geometry)
  }

st_write(data, "data/data.geojson")


breaks <- data %>%
  st_drop_geometry() %>%
  filter(year != 1940) %>%
  group_by(year) %>%
  summarize(
    value = list(
      quantile(
        income,
        probs = seq(0, 1, by = 0.1),
        na.rm = TRUE
      )
    ),
    .groups = "drop"
  ) %>%
  unnest_longer(value, indices_to = "percentile") %>%
  mutate(percentile = as.numeric(str_remove(percentile, "%")) / 100) %>%
  mutate(
    value = if_else(percentile %in% c(0, 1), value, round(value, digits = -2))
  )

write_csv(breaks, "data/breaks.csv")

import { csv as d3csv } from "d3-fetch";

/**
 * Loads the full GeoJSON FeatureCollection, equivalent to:
 *   nyc_data <- st_read("data/data.geojson")
 *
 * Expected shape: FeatureCollection where each feature's `properties`
 * includes at minimum:
 *   year          (number)     - census year, e.g. 1990
 *   income        (number|null)
 *   perc_white    (number|null) - 0-1
 *   perc_black    (number|null) - 0-1
 *   perc_hispanic (number|null) - 0-1
 *   perc_asian    (number|null) - 0-1
 *   perc_other    (number|null) - 0-1
 */
export async function loadGeoData(url = "/data/data.geojson") {
  const res = await fetch(url);
  if (!res.ok) {
    throw new Error(`Failed to load ${url}: ${res.status} ${res.statusText}`);
  }
  return res.json();
}

/**
 * Loads the income bin breakpoints, equivalent to:
 *   breaks <- read_csv("data/breaks.csv")
 *
 * Expected columns: year, value (one row per interior break point,
 * multiple rows per year).
 */
export async function loadBreaksData(url = "/data/breaks.csv") {
  const rows = await d3csv(url, (d) => ({
    year: Number(d.year),
    value: Number(d.value),
  }));
  return rows;
}

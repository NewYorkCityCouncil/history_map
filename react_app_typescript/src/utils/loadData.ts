import { csv as d3csv } from "d3-fetch";
import type { BreakRow, TractFeatureCollection } from "../types/data.ts";

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
 *   perc_hispanic (number|null) - 0-1 (only meaningful 1980+)
 *   perc_asian    (number|null) - 0-1
 *   perc_other    (number|null) - 0-1
 */
export async function loadGeoData(url = "/Dashboards/history_map/data/data.geojson"): Promise<TractFeatureCollection> {
  const res = await fetch(url);
  if (!res.ok) {
    throw new Error(`Failed to load ${url}: ${res.status} ${res.statusText}`);
  }
  return (await res.json()) as TractFeatureCollection;
}

/**
 * Loads the income bin breakpoints, equivalent to:
 *   breaks <- read_csv("data/breaks.csv")
 *
 * Expected columns: year, value (one row per interior break point,
 * multiple rows per year).
 */
export async function loadBreaksData(url = "/Dashboards/history_map/data/breaks.csv"): Promise<BreakRow[]> {
  const rows = await d3csv(url, (d): BreakRow => ({
    year: Number(d.year),
    value: Number(d.value),
  }));
  return rows;
}

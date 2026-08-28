/**
 * Type definitions for the NYC demographic history dashboard.
 *
 * These types describe the shape of the GeoJSON tract data and the
 * income-break CSV that the app loads at runtime.
 */

/**
 * The set of data fields that can be selected in the variable dropdown.
 * Each corresponds to a column in the GeoJSON feature properties.
 */
export type SelectableVar =
  | "perc_white"
  | "perc_black"
  | "perc_hispanic"
  | "perc_asian"
  | "perc_other"
  | "income";

/**
 * Properties attached to each census-tract GeoJSON feature.
 *
 * All demographic fields are nullable (0-1 for percentages, dollars for
 * income) because not every field is available for every census year.
 */
export interface TractProperties {
  /** Census year, e.g. 1990. */
  year: number;
  /** Median household income in dollars, or null if unavailable. */
  income: number | null;
  /** Percentage of White residents (0-1), or null. */
  perc_white: number | null;
  /** Percentage of Black residents (0-1), or null. */
  perc_black: number | null;
  /** Percentage of Hispanic residents (0-1), or null (1980+ only). */
  perc_hispanic: number | null;
  /** Percentage of Asian residents (0-1), or null. */
  perc_asian: number | null;
  /** Percentage of Other-race residents (0-1), or null. */
  perc_other: number | null;
  /** Allow any additional properties the GeoJSON may carry. */
  [key: string]: unknown;
}

/**
 * A single census-tract GeoJSON Feature.
 */
export interface TractFeature {
  type: "Feature";
  properties: TractProperties;
  geometry:
    | { type: "Polygon"; coordinates: number[][][] }
    | { type: "MultiPolygon"; coordinates: number[][][][] }
    | null;
}

/**
 * The top-level GeoJSON FeatureCollection of census tracts.
 */
export interface TractFeatureCollection {
  type: "FeatureCollection";
  features: TractFeature[];
}

/**
 * A single row from breaks.csv — an interior break point for the income
 * color scale for a given census year.
 */
export interface BreakRow {
  year: number;
  value: number;
}

/**
 * The race and income variable groups available for a given census year,
 * as returned by `getVariablesForYear()`.
 *
 * Keys are human-readable dropdown labels; values are the `SelectableVar`
 * field names used to index into the tract properties.
 */
export interface VariableGroups {
  race: Record<string, SelectableVar>;
  income: Record<string, SelectableVar>;
}

import type { VariableGroups } from "../types/data.ts";

// Census years shown on the slider. Update this to match the distinct
// `year` values actually present in your data.geojson.
export const YEARS: number[] = [1940, 1950, 1960, 1970, 1980, 1990, 2000, 2010, 2020];

// Human-readable labels for the map legend / popups, keyed by field name.
export const FIELD_LABELS: Record<string, string> = {
  perc_white: "% White",
  perc_black: "% Black",
  perc_hispanic: "% Hispanic",
  perc_asian: "% Asian",
  perc_other: "% Other",
  income: "Med. Income",
};

/**
 * Mirrors the `vars_available` reactive in the Shiny app: which race and
 * income fields are selectable for a given census year, and what their
 * dropdown labels should read as.
 */
export function getVariablesForYear(year: number): VariableGroups {
  switch (year) {
    case 1940:
      return {
        race: { White: "perc_white", Other: "perc_other" },
        income: {},
      };

    case 1950:
    case 1960:
      return {
        race: {
          White: "perc_white",
          Black: "perc_black",
          Other: "perc_other",
        },
        income: { "Median Household Income": "income" },
      };

    case 1970:
      return {
        race: {
          White: "perc_white",
          Black: "perc_black",
          Asian: "perc_asian",
          Other: "perc_other",
        },
        income: { "Median Household Income": "income" },
      };

    default:
      // 1980 onward
      return {
        race: {
          "White Non-Hisp.": "perc_white",
          "Black Non-Hisp.": "perc_black",
          Hispanic: "perc_hispanic",
          "Asian Non-Hisp.": "perc_asian",
          "Other Non-Hisp.": "perc_other",
        },
        income: { "Median Household Income": "income" },
      };
  }
}

// "Race" pre-1980, "Race/Ethnicity" from 1980 onward (Hispanic origin was
// added as its own category starting with the 1980 Census).
export function getRaceGroupLabel(year: number): string {
  return year >= 1980 ? "Race/Ethnicity" : "Race";
}

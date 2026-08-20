import type { TractProperties } from "../types/data.ts";

const currencyFmt = new Intl.NumberFormat("en-US", {
  style: "currency",
  currency: "USD",
  maximumFractionDigits: 0,
});

const pct = (v: number): string => `${(v * 100).toFixed(1)}%`;

/**
 * Builds the same popup HTML the Shiny app precomputes in its `mutate()`
 * call, but on demand from a feature's properties. Fields are skipped
 * when null/undefined, same as the R ifelse(!is.na(...), ...) chain.
 */
export function buildPopupHtml(properties: TractProperties): string {
  const rows: string[] = [];

  if (properties.income != null) {
    rows.push(`Income: ${currencyFmt.format(properties.income)}`);
  }
  if (properties.perc_white != null) {
    rows.push(`White: ${pct(properties.perc_white)}`);
  }
  if (properties.perc_black != null) {
    rows.push(`Black: ${pct(properties.perc_black)}`);
  }
  if (properties.perc_hispanic != null) {
    rows.push(`Hispanic: ${pct(properties.perc_hispanic)}`);
  }
  if (properties.perc_asian != null) {
    rows.push(`Asian: ${pct(properties.perc_asian)}`);
  }
  if (properties.perc_other != null) {
    rows.push(`Other Race: ${pct(properties.perc_other)}`);
  }

  return rows.join("<br>");
}

import { scaleThreshold } from "d3-scale";
import { interpolateViridis } from "d3-scale-chromatic";

/** Evenly sample `n` colors along the viridis scale (0 -> 1). */
export function viridisColors(n) {
  if (n <= 1) return [interpolateViridis(0)];
  return Array.from({ length: n }, (_, i) => interpolateViridis(i / (n - 1)));
}

/**
 * Equivalent of:
 *   colorBin(palette = "viridis", domain = c(0, 1), bins = 8)
 * used for the percentage fields (perc_white, perc_black, ...).
 * Returns a d3 scaleThreshold: call scale(value) -> hex color.
 */
export function getPercentColorScale(nBins = 8) {
  const breaks = Array.from({ length: nBins - 1 }, (_, i) => (i + 1) / nBins);
  return scaleThreshold().domain(breaks).range(viridisColors(nBins));
}

/**
 * Equivalent of:
 *   colorBin(palette = "viridis", domain = values, bins = inc_bins)
 * where inc_bins is the explicit vector of break points read from
 * breaks.csv for the selected year.
 *
 * @param {number[]} breakpoints - sorted interior bin edges for this year,
 *   e.g. [25000, 40000, 55000, 70000, 90000] (n edges -> n+1 bins)
 */
export function getIncomeColorScale(breakpoints) {
  const sorted = [...breakpoints].sort((a, b) => a - b);
  return scaleThreshold().domain(sorted).range(viridisColors(sorted.length + 1));
}

/**
 * Returns the { scale, bins } pair used to render both the map fill and
 * the legend for whichever variable is currently selected.
 *
 * @param {string} selectedVar - e.g. "perc_white" or "income"
 * @param {number} year
 * @param {Array<{year: number, value: number}>} breaksData - parsed breaks.csv
 */
export function buildColorScale(selectedVar, year, breaksData) {
  if (selectedVar === "income") {
    const breakpoints = breaksData
      .filter((d) => Number(d.year) === Number(year))
      .map((d) => Number(d.value))
      .sort((a, b) => a - b);

    return {
      scale: getIncomeColorScale(breakpoints),
      bins: [-Infinity, ...breakpoints, Infinity],
      isCurrency: true,
    };
  }

  const scale = getPercentColorScale(8);
  return {
    scale,
    bins: [0, ...scale.domain(), 1],
    isCurrency: false,
  };
}

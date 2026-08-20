import { scaleThreshold } from "d3-scale";
import { interpolateViridis } from "d3-scale-chromatic";
import type { BreakRow, SelectableVar } from "../types/data.ts";

export type ColorScale = (value: number) => string;

export interface BuiltColorScale {
  scale: ColorScale;
  /** Bin edges, including -Infinity/Infinity or 0/1 endpoints, one longer
   *  than the number of colors in the scale. Used to render the legend. */
  bins: number[];
  colors: string[];
  isCurrency: boolean;
}

/** Evenly sample `n` colors along the viridis scale (0 -> 1). */
export function viridisColors(n: number): string[] {
  if (n <= 1) return [interpolateViridis(0)];
  return Array.from({ length: n }, (_, i) => interpolateViridis(i / (n - 1)));
}

/**
 * Equivalent of:
 *   colorBin(palette = "viridis", domain = c(0, 1), bins = 8)
 * used for the percentage fields (perc_white, perc_black, ...).
 */
export function getPercentColorScale(nBins = 8): { scale: ColorScale; breaks: number[]; colors: string[] } {
  const breaks = Array.from({ length: nBins - 1 }, (_, i) => (i + 1) / nBins);
  const colors = viridisColors(nBins);
  const d3scale = scaleThreshold<number, string>().domain(breaks).range(colors);
  return { scale: (v: number) => d3scale(v), breaks, colors };
}

/**
 * Equivalent of:
 *   colorBin(palette = "viridis", domain = values, bins = inc_bins)
 * where inc_bins is the explicit vector of break points read from
 * breaks.csv for the selected year.
 */
export function getIncomeColorScale(breakpoints: number[]): { scale: ColorScale; colors: string[] } {
  const sorted = [...breakpoints].sort((a, b) => a - b);
  const colors = viridisColors(sorted.length + 1);
  const d3scale = scaleThreshold<number, string>().domain(sorted).range(colors);
  return { scale: (v: number) => d3scale(v), colors };
}

/**
 * Returns the scale/bins/colors used to render both the map fill and the
 * legend for whichever variable is currently selected.
 */
export function buildColorScale(
  selectedVar: SelectableVar,
  year: number,
  breaksData: BreakRow[]
): BuiltColorScale {
  if (selectedVar === "income") {
    const breakpoints = breaksData
      .filter((d) => d.year === year)
      .map((d) => d.value)
      .sort((a, b) => a - b);

    const { scale, colors } = getIncomeColorScale(breakpoints);
    return {
      scale,
      colors,
      bins: [-Infinity, ...breakpoints, Infinity],
      isCurrency: true,
    };
  }

  const { scale, breaks, colors } = getPercentColorScale(8);
  return {
    scale,
    colors,
    bins: [0, ...breaks, 1],
    isCurrency: false,
  };
}

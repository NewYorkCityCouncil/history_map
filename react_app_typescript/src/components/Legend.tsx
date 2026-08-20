import { useEffect } from "react";
import { useMap } from "react-leaflet";
import L from "leaflet";
import { FIELD_LABELS } from "../config/variablesByYear.ts";
import type { SelectableVar } from "../types/data.ts";

const currencyFmt = new Intl.NumberFormat("en-US", {
  style: "currency",
  currency: "USD",
  maximumFractionDigits: 0,
});

function formatBreak(value: number, isCurrency: boolean): string {
  if (!Number.isFinite(value)) return value > 0 ? "max" : "min";
  return isCurrency ? currencyFmt.format(value) : `${Math.round(value * 100)}%`;
}

export interface LegendProps {
  selectedVar: SelectableVar;
  colors: string[];
  bins: number[];
  isCurrency: boolean;
}

/**
 * Renders a bottom-right Leaflet control, equivalent to:
 *   addLegend(pal = pal, values = df$values, position = "bottomright", ...)
 */
export default function Legend({ selectedVar, colors, bins, isCurrency }: LegendProps) {
  const map = useMap();

  useEffect(() => {
    const control = L.control({ position: "bottomright" });

    control.onAdd = () => {
      const div = L.DomUtil.create("div", "map-legend");
      const title = FIELD_LABELS[selectedVar] ?? selectedVar;

      const rowsHtml = colors
        .map((color, i) => {
          const lower = bins[i];
          const upper = bins[i + 1];
          const label =
            i === 0
              ? `< ${formatBreak(upper, isCurrency)}`
              : i === colors.length - 1
                ? `> ${formatBreak(lower, isCurrency)}`
                : `${formatBreak(lower, isCurrency)} - ${formatBreak(upper, isCurrency)}`;

          return `
            <div class="map-legend-row">
              <span class="map-legend-swatch" style="background:${color}"></span>
              <span>${label}</span>
            </div>
          `;
        })
        .join("");

      div.innerHTML = `<div class="map-legend-title">${title}</div>${rowsHtml}`;
      return div;
    };

    control.addTo(map);
    return () => {
      control.remove();
    };
  }, [map, selectedVar, colors, bins, isCurrency]);

  return null;
}

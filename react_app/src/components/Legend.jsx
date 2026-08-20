import { useEffect } from "react";
import { useMap } from "react-leaflet";
import L from "leaflet";
import { FIELD_LABELS } from "../config/variablesByYear.js";

const currencyFmt = new Intl.NumberFormat("en-US", {
  style: "currency",
  currency: "USD",
  maximumFractionDigits: 0,
});

function formatBreak(value, isCurrency) {
  if (!Number.isFinite(value)) return value > 0 ? "max" : "min";
  return isCurrency ? currencyFmt.format(value) : `${Math.round(value * 100)}%`;
}

/**
 * Renders a bottom-right Leaflet control, equivalent to:
 *   addLegend(pal = pal, values = df$values, position = "bottomright", ...)
 */
export default function Legend({ selectedVar, colorScale, bins, isCurrency }) {
  const map = useMap();

  useEffect(() => {
    const control = L.control({ position: "bottomright" });

    control.onAdd = () => {
      const div = L.DomUtil.create("div", "map-legend");
      const title = FIELD_LABELS[selectedVar] ?? selectedVar;

      const rowsHtml = colorScale
        .range()
        .map((color, i) => {
          const lower = bins[i];
          const upper = bins[i + 1];
          const label =
            i === 0
              ? `< ${formatBreak(upper, isCurrency)}`
              : i === colorScale.range().length - 1
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
    return () => control.remove();
  }, [map, selectedVar, colorScale, bins, isCurrency]);

  return null;
}

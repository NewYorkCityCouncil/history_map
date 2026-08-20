import { useEffect, useMemo, useState } from "react";
import { MapContainer, TileLayer, GeoJSON } from "react-leaflet";
import type { Layer, Path, PathOptions } from "leaflet";
import { loadGeoData, loadBreaksData } from "../utils/loadData.ts";
import { buildColorScale } from "../utils/colorScale.ts";
import { buildPopupHtml } from "../utils/popupContent.ts";
import Legend from "./Legend.tsx";
import type { BreakRow, SelectableVar, TractFeature, TractFeatureCollection } from "../types/data.ts";

const NYC_CENTER: [number, number] = [40.7, -73.94];
const INITIAL_ZOOM = 11;

export interface DemographicMapProps {
  year: number;
  selectedVar: SelectableVar;
}

export default function DemographicMap({ year, selectedVar }: DemographicMapProps) {
  const [geoData, setGeoData] = useState<TractFeatureCollection | null>(null);
  const [breaksData, setBreaksData] = useState<BreakRow[]>([]);
  const [error, setError] = useState<string | null>(null);

  // One-time load, equivalent to the top-level st_read()/read_csv() calls.
  useEffect(() => {
    let cancelled = false;

    Promise.all([loadGeoData(), loadBreaksData()])
      .then(([geo, breaks]) => {
        if (cancelled) return;
        setGeoData(geo);
        setBreaksData(breaks);
      })
      .catch((err: unknown) => {
        if (!cancelled) setError(err instanceof Error ? err.message : String(err));
      });

    return () => {
      cancelled = true;
    };
  }, []);

  // Equivalent of `nyc_by_year <- split(nyc_data, nyc_data$year)` plus the
  // `filtered_data` reactive.
  const filteredFeatures: TractFeatureCollection | null = useMemo(() => {
    if (!geoData) return null;
    return {
      type: "FeatureCollection",
      features: geoData.features.filter((f) => f.properties.year === year),
    };
  }, [geoData, year]);

  // Equivalent of the `color_pal` reactive.
  const { scale, colors, bins, isCurrency } = useMemo(
    () => buildColorScale(selectedVar, year, breaksData),
    [selectedVar, year, breaksData]
  );

  const hasValues =
    filteredFeatures?.features.some((f) => f.properties[selectedVar] != null) ?? false;

  const style = (feature?: TractFeature): PathOptions => {
    const value = feature?.properties[selectedVar];
    return {
      fillColor: value == null ? "transparent" : scale(value),
      fillOpacity: 0.7,
      color: "black",
      weight: 0.5,
    };
  };

  const onEachFeature = (feature: TractFeature, layer: Layer) => {
    layer.bindPopup(buildPopupHtml(feature.properties));
    layer.on({
      mouseover: (e) => (e.target as Path).setStyle({ weight: 2, color: "blue" }),
      mouseout: (e) => (e.target as Path).setStyle({ weight: 0.5, color: "black" }),
    });
  };

  return (
    <div className="map-canvas">
      <MapContainer className="leaflet-map" center={NYC_CENTER} zoom={INITIAL_ZOOM}>
        <TileLayer
          attribution='&copy; <a href="https://carto.com/attributions">CARTO</a>'
          url="https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png"
        />

        {filteredFeatures && hasValues && (
          <>
            <GeoJSON
              key={`${year}-${selectedVar}`}
              data={filteredFeatures}
              style={style as (feature?: GeoJSON.Feature) => PathOptions}
              onEachFeature={onEachFeature as (feature: GeoJSON.Feature, layer: Layer) => void}
            />
            <Legend
              selectedVar={selectedVar}
              colors={colors}
              bins={bins}
              isCurrency={isCurrency}
            />
          </>
        )}
      </MapContainer>

      {!geoData && !error && <div className="map-loading">Loading map data…</div>}
      {error && <div className="map-loading">Error loading data: {error}</div>}
    </div>
  );
}

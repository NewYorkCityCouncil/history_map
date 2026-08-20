import { useEffect, useMemo, useState } from "react";
import { MapContainer, TileLayer, GeoJSON } from "react-leaflet";
import { loadGeoData, loadBreaksData } from "../utils/loadData.js";
import { buildColorScale } from "../utils/colorScale.js";
import { buildPopupHtml } from "../utils/popupContent.js";
import Legend from "./Legend.jsx";

const NYC_CENTER = [40.7, -73.94];
const INITIAL_ZOOM = 11;

export default function DemographicMap({ year, selectedVar }) {
  const [geoData, setGeoData] = useState(null);
  const [breaksData, setBreaksData] = useState([]);
  const [error, setError] = useState(null);

  // One-time load, equivalent to the top-level st_read()/read_csv() calls.
  useEffect(() => {
    let cancelled = false;

    Promise.all([loadGeoData(), loadBreaksData()])
      .then(([geo, breaks]) => {
        if (cancelled) return;
        setGeoData(geo);
        setBreaksData(breaks);
      })
      .catch((err) => {
        if (!cancelled) setError(err.message);
      });

    return () => {
      cancelled = true;
    };
  }, []);

  // Equivalent of `nyc_by_year <- split(nyc_data, nyc_data$year)` plus the
  // `filtered_data` reactive.
  const filteredFeatures = useMemo(() => {
    if (!geoData) return null;
    return {
      type: "FeatureCollection",
      features: geoData.features.filter(
        (f) => Number(f.properties.year) === Number(year)
      ),
    };
  }, [geoData, year]);

  // Equivalent of the `color_pal` reactive.
  const { scale, bins, isCurrency } = useMemo(
    () => buildColorScale(selectedVar, year, breaksData),
    [selectedVar, year, breaksData]
  );

  const hasValues =
    filteredFeatures?.features.some((f) => f.properties[selectedVar] != null) ?? false;

  const style = (feature) => {
    const value = feature.properties[selectedVar];
    return {
      fillColor: value == null ? "transparent" : scale(value),
      fillOpacity: 0.7,
      color: "black",
      weight: 0.5,
    };
  };

  const onEachFeature = (feature, layer) => {
    layer.bindPopup(buildPopupHtml(feature.properties));
    layer.on({
      mouseover: (e) => e.target.setStyle({ weight: 2, color: "blue" }),
      mouseout: (e) => e.target.setStyle({ weight: 0.5, color: "black" }),
    });
  };

  return (
    <div className="map-canvas">
      <MapContainer
        className="leaflet-map"
        center={NYC_CENTER}
        zoom={INITIAL_ZOOM}
      >
        <TileLayer
          attribution='&copy; <a href="https://carto.com/attributions">CARTO</a>'
          url="https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png"
        />

        {filteredFeatures && hasValues && (
          <>
            <GeoJSON
              key={`${year}-${selectedVar}`}
              data={filteredFeatures}
              style={style}
              onEachFeature={onEachFeature}
            />
            <Legend
              selectedVar={selectedVar}
              colorScale={scale}
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

# Demographic History of NYC — React port

A React/Leaflet port of the original R Shiny app. Same behavior: a slider
picks a census year, a dropdown picks race/ethnicity or income, and the
choropleth + legend + popups update accordingly.

## Setup

```bash
npm install
npm run dev
```

This assumes Node 18+ and a bundler-friendly environment (Vite). Nothing
here has been run against real data yet — see below.

## Wiring up your data

Drop your two source files into `public/data/`:

```
public/data/data.geojson
public/data/breaks.csv
```

They're fetched at runtime the same way the Shiny app read them with
`st_read()` / `read_csv()`. Expected shapes:

**`data.geojson`** — a `FeatureCollection`. Each feature's `properties`
should include:

| field           | type          | notes                              |
|-----------------|---------------|-------------------------------------|
| `year`          | number        | census year, e.g. `1990`            |
| `income`        | number \| null| median household income             |
| `perc_white`    | number \| null| 0–1                                  |
| `perc_black`    | number \| null| 0–1                                  |
| `perc_hispanic` | number \| null| 0–1 (only meaningful 1980+)          |
| `perc_asian`    | number \| null| 0–1                                  |
| `perc_other`    | number \| null| 0–1                                  |

**`breaks.csv`** — one row per income bin edge, per year:

```csv
year,value
1950,25000
1950,40000
1950,55000
...
```

## If your geometry/field names differ

Everything that touches field names lives in three places, mirroring
where the equivalent logic sat in the Shiny app:

- `src/config/variablesByYear.js` — which variables exist per year
  (was the `vars_available` switch statement)
- `src/utils/popupContent.js` — popup HTML (was the `mutate(popup = ...)` chain)
- `src/utils/colorScale.js` — color binning (was `colorBin(...)`)

## Shiny → React mapping

| Shiny piece                          | React equivalent                          |
|---------------------------------------|--------------------------------------------|
| `sliderInput("year", ...)`            | `ControlPanel` year `<input type="range">` |
| `renderUI` grouped `selectInput`      | `ControlPanel` `<select><optgroup>`        |
| `vars_available` reactive             | `getVariablesForYear()`                    |
| `filtered_data` / `split(nyc_data, year)` | `useMemo` filter in `DemographicMap`   |
| `color_pal` reactive / `colorBin()`   | `buildColorScale()`                        |
| `renderLeaflet` / `leafletProxy`      | `<MapContainer>` + `<GeoJSON>`             |
| `addLegend()`                         | `Legend.jsx` (custom Leaflet control)      |
| popup `mutate()` chain                | `buildPopupHtml()`                         |
| `bindCache(input$year, ...)`          | `useMemo` dependency arrays                |
| custom navbar CSS/logo                | `Navbar.jsx` + `index.css`                 |

## Known gaps to double check once real data is in

- `YEARS` in `variablesByYear.js` is hardcoded to `1940…2020`; set it to
  whatever distinct years your GeoJSON actually contains.
- The legend's bucket labels assume `colorScale.range()` bins line up
  1:1 with `bins` — double check with your real income breakpoints.
- No draggable control panel (the Shiny version used `draggable = TRUE`
  on `absolutePanel`); add a library like `react-draggable` if you want
  that back.

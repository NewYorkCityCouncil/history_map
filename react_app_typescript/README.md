# Demographic History of NYC — React + TypeScript port

A typed React/Leaflet port of the original R Shiny app. Same behavior: a
slider picks a census year, a dropdown picks race/ethnicity or income, and
the choropleth + legend + popups update accordingly.

## Setup

```bash
npm install
npm run dev
```

Requires Node 18+. `npm run typecheck` runs `tsc --noEmit` if you want to
check types without starting the dev server.

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

This matches the `TractProperties` interface in `src/types/data.ts` — if
your field names differ, edit that interface first and TypeScript will
flag every place that needs updating.

**`breaks.csv`** — one row per income bin edge, per year:

```csv
year,value
1950,25000
1950,40000
1950,55000
...
```

## Where things live

- `src/types/data.ts` — shared types (`TractProperties`, `SelectableVar`,
  `BreakRow`, etc.). Start here if your data schema differs.
- `src/config/variablesByYear.ts` — which variables exist per year (was
  the `vars_available` switch statement)
- `src/utils/popupContent.ts` — popup HTML (was the `mutate(popup = ...)`
  chain)
- `src/utils/colorScale.ts` — color binning (was `colorBin(...)`)
- `src/utils/loadData.ts` — fetch + parse (was `st_read()` / `read_csv()`)
- `src/components/DemographicMap.tsx` — the Leaflet map itself (was
  `renderLeaflet` / `leafletProxy`)
- `src/components/ControlPanel.tsx` — year slider + grouped select (was
  `absolutePanel` / `renderUI`)
- `src/components/Legend.tsx` — custom Leaflet control (was `addLegend()`)

## Type-checking note

This was written and syntax/type-checked locally against the TypeScript
compiler, but the actual npm packages (`react-leaflet`, `@types/leaflet`,
`@types/geojson`, etc.) weren't installed in the environment that built
it — there was no network access to fetch them. Run `npm install` and
then `npm run typecheck` as your first step to catch anything that
shakes out once the real type definitions are in place. The two spots
most likely to need a small tweak are the `style`/`onEachFeature` casts
in `DemographicMap.tsx`, since `react-leaflet`'s `GeoJSON` typings can be
version-sensitive.

## Known gaps to double check once real data is in

- `YEARS` in `variablesByYear.ts` is hardcoded to `1940…2020`; set it to
  whatever distinct years your GeoJSON actually contains.
- The legend's bucket labels assume `colors` and `bins` line up 1:1 —
  double check with your real income breakpoints.
- No draggable control panel (the Shiny version used `draggable = TRUE`
  on `absolutePanel`); add a library like `react-draggable` if you want
  that back.

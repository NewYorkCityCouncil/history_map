import { useEffect, useState } from "react";
import Navbar from "./components/Navbar.tsx";
import ControlPanel from "./components/ControlPanel.tsx";
import DemographicMap from "./components/DemographicMap.tsx";
import { YEARS, getVariablesForYear } from "./config/variablesByYear.ts";
import type { SelectableVar } from "./types/data.ts";

export default function App() {
  const [year, setYear] = useState<number>(YEARS[0]);
  const [selectedVar, setSelectedVar] = useState<SelectableVar>("perc_white");

  // Equivalent of the `selected =` fallback in the Shiny renderUI(): if the
  // current variable isn't offered for the newly selected year, fall back
  // to perc_white.
  useEffect(() => {
    const vars = getVariablesForYear(year);
    const validValues: SelectableVar[] = [
      ...Object.values(vars.race),
      ...Object.values(vars.income),
    ];
    if (!validValues.includes(selectedVar)) {
      setSelectedVar("perc_white");
    }
  }, [year, selectedVar]);

  return (
    <div className="app">
      <Navbar />
      <div className="map-panel">
        <DemographicMap year={year} selectedVar={selectedVar} />
        <ControlPanel
          year={year}
          onYearChange={setYear}
          selectedVar={selectedVar}
          onVarChange={setSelectedVar}
        />
      </div>
    </div>
  );
}

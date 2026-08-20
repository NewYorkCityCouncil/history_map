import { useEffect, useState } from "react";
import Navbar from "./components/Navbar.jsx";
import ControlPanel from "./components/ControlPanel.jsx";
import DemographicMap from "./components/DemographicMap.jsx";
import { YEARS, getVariablesForYear } from "./config/variablesByYear.js";

export default function App() {
  const [year, setYear] = useState(YEARS[0]);
  const [selectedVar, setSelectedVar] = useState("perc_white");

  // Equivalent of the `selected =` fallback in the Shiny renderUI(): if the
  // current variable isn't offered for the newly selected year, fall back
  // to perc_white.
  useEffect(() => {
    const vars = getVariablesForYear(year);
    const validValues = [...Object.values(vars.race), ...Object.values(vars.income)];
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

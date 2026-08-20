import { useMemo } from "react";
import { YEARS, getVariablesForYear, getRaceGroupLabel } from "../config/variablesByYear.js";

export default function ControlPanel({ year, onYearChange, selectedVar, onVarChange }) {
  const vars = useMemo(() => getVariablesForYear(year), [year]);
  const raceLabel = getRaceGroupLabel(year);
  const yearIndex = YEARS.indexOf(year);

  return (
    <div className="control-panel">
      <div className="control-group">
        <label className="control-label" htmlFor="year-slider">
          Census Year:
        </label>
        <input
          id="year-slider"
          type="range"
          className="year-slider"
          min={0}
          max={YEARS.length - 1}
          step={1}
          value={yearIndex === -1 ? 0 : yearIndex}
          onChange={(e) => onYearChange(YEARS[Number(e.target.value)])}
        />
        <div className="year-slider-value">{year}</div>
      </div>

      <div className="control-group">
        <label className="control-label" htmlFor="variable-select">
          Display:
        </label>
        <select
          id="variable-select"
          className="variable-select"
          value={selectedVar}
          onChange={(e) => onVarChange(e.target.value)}
        >
          <optgroup label={raceLabel}>
            {Object.entries(vars.race).map(([label, value]) => (
              <option key={value} value={value}>
                {label}
              </option>
            ))}
          </optgroup>

          {Object.keys(vars.income).length > 0 && (
            <optgroup label="Income">
              {Object.entries(vars.income).map(([label, value]) => (
                <option key={value} value={value}>
                  {label}
                </option>
              ))}
            </optgroup>
          )}
        </select>
      </div>
    </div>
  );
}

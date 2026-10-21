import logo from "../assets/data-council-logo-white.png";


export default function Navbar() {
  return (
    <header className="navbar">
      <nav className="navbar-links">
        <a
          href="https://github.com/NewYorkCityCouncil"
          target="_blank"
          rel="noopener noreferrer"
        >
          Data Home
        </a>
        <a
          href="https://rnd.council.nyc.gov/Dashboards/shiny_lib/"
          target="_blank"
          rel="noopener noreferrer"
        >
          Dashboard Library
        </a>
      </nav>

      <span className="navbar-title">Demographic History of NYC</span>

      <img
        className="navbar-logo"
        src={logo}
        alt="NYC Council"
      />
    </header>
  );
}

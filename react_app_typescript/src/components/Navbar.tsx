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
          href="https://rnd.council.nyc.gov/shiny/DashboardDepot/"
          target="_blank"
          rel="noopener noreferrer"
        >
          Dashboard Library
        </a>
      </nav>

      <span className="navbar-title">Demographic History of NYC</span>

      <img
        className="navbar-logo"
        src="/data-council-logo-white.png"
        alt="NYC Council"
      />
    </header>
  );
}

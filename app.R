library(shiny)
library(tidyverse)
library(leaflet)
library(sf)
library(dplyr)
library(scales)
library(bslib)

nyc_data <- st_read("data/data.geojson") %>%
  mutate(
    popup = paste0(
      ifelse(
        !is.na(income),
        paste0("Income: ", scales::dollar(income), "<br>"),
        ""
      ),
      ifelse(
        !is.na(perc_white),
        paste0("White: ", scales::percent(perc_white, accuracy = 0.1)),
        ""
      ),
      ifelse(
        !is.na(perc_black),
        paste0(
          "<br>Black: ",
          scales::percent(perc_black, accuracy = 0.1)
        ),
        ""
      ),
      ifelse(
        !is.na(perc_hispanic),
        paste0(
          "<br>Hispanic: ",
          scales::percent(perc_hispanic, accuracy = 0.1)
        ),
        ""
      ),
      ifelse(
        !is.na(perc_asian),
        paste0("<br>Asian: ", scales::percent(perc_asian, accuracy = 0.1)),
        ""
      ),
      ifelse(
        !is.na(perc_other),
        paste0("<br>Other Race: ", scales::percent(perc_other, accuracy = 0.1)),
        ""
      )
    )
  )


breaks <- read_csv("data/breaks.csv")


# ---- links ----
link_datahome <- tags$a(
  icon("github"),
  " Data Home",
  href = "https://github.com/NewYorkCityCouncil",
  target = "_blank",
  rel = "noopener noreferrer"
)

link_dashboardlibrary <- tags$a(
  icon("r-project"),
  " Dashboard Library",
  href = "https://rnd.council.nyc.gov/shiny/DashboardDepot/",
  target = "_blank",
  rel = "noopener noreferrer"
)


# ---- UI ----
ui <- page_navbar(
  tags$head(
    tags$script(
      HTML(
        '$(document).ready(function() {
         $(".navbar .container-fluid")
           .append("<img id=\'myImage\' src=\'data-council-logo-white.png\' align=\'right\' height=\'40px\'>");
       });'
      )
    ),
    tags$style(HTML(
      "
      html, body {
        height: 100%;
        margin: 0;
      }

      body {
        display: flex;
        flex-direction: column;
      }

      /* Main content created by page_navbar */
      .main {
        flex: 1 1 auto;
        display: flex;
        flex-direction: column;
        padding: 0 !important;
      }

      /* Remove Bootstrap container padding */
      .main > .container-fluid {
        padding: 0 !important;
        margin: 0 !important;
        height: 100%;
      }

      /* Tabs fill available height */
      .tab-content {
        height: 100%;
        display: flex;
      }

      .tab-pane.active {
        flex: 1 1 auto;
        display: flex;
        padding: 0 !important;
      }

      /* Map fills remaining space */
      #map {
        width: 100%;
        height: 100%;
        flex: 1 1 auto;
      }

      /* ---------------- Navbar ---------------- */



      .navbar .navbar-brand {
        position: absolute;
        left: 50%;
        top: 50%;
        transform: translate(-50%, -50%); /* horizontal + vertical centering */

        margin: 0;
        padding: 0;

        font-size: 1.35rem;     /* increase title size */
        font-weight: 600;       /* slightly stronger than default */
        line-height: 1.2;
        text-align: center;
        white-space: nowrap;
      }


      .navbar .navbar-nav {
        margin-left: 0;
      }

      .navbar {
        min-height: 44px;
        padding-top: 4px;
        padding-bottom: 4px;
        margin-bottom: 0;
      }

      .navbar-brand {
        font-size: 1rem;
        padding: 0;
      }

      .navbar-nav .nav-link {
        padding-top: 4px;
        padding-bottom: 4px;
        font-size: 0.95rem;
      }

      @media (max-width:992px) {
        #myImage {
          position: fixed;
          right: 10%;
          bottom: .5%;
        }
      }

      html, body {
        height: 100%;
        margin: 0;
      }


      .irs-grid-pol.small {
        display: none;
      }

      /* Make selectInput dropdown taller */
      .selectize-dropdown-content {
        max-height: 500px !important;
      }
    "
    ))
  ),

  title = "Demographic History of NYC",

  nav_menu(
    title = "",
    align = "left",
    nav_item(link_datahome),
    nav_item(link_dashboardlibrary)
  ),

  theme = bs_theme(bootswatch = "simplex", primary = "#2F56A6"),
  bg = "#2F56A6",

  nav_panel(
    "Map",
    leafletOutput(
      "map"
    ),

    absolutePanel(
      top = 50,
      right = 20,
      width = 350,
      draggable = TRUE,
      style = paste(
        "background: rgba(255,255,255,0.95);",
        "padding: 15px;",
        "border-radius: 10px;",
        "box-shadow: 0 2px 10px rgba(0,0,0,0.3);"
      ),

      sliderInput(
        "year",
        "Census Year:",
        min = min(nyc_data$year),
        max = max(nyc_data$year),
        value = min(nyc_data$year),
        step = 10,
        sep = "",
        ticks = TRUE
      ),

      uiOutput("variable_selector")
    )
  )
)


# ---- SERVER ----
server <- function(input, output, session) {
  # Available variables by year
  vars_available <- reactive({
    switch(
      as.character(input$year),

      "1940" = list(
        race = c(
          "White" = "perc_white",
          "Other" = "perc_other"
        ),
        income = c()
      ),

      "1950" = list(
        race = c(
          "White" = "perc_white",
          "Black" = "perc_black",
          "Other" = "perc_other"
        ),
        income = c(
          "Median Household Income" = "income"
        )
      ),

      "1960" = list(
        race = c(
          "White" = "perc_white",
          "Black" = "perc_black",
          "Other" = "perc_other"
        ),
        income = c(
          "Median Household Income" = "income"
        )
      ),

      "1970" = list(
        race = c(
          "White" = "perc_white",
          "Black" = "perc_black",
          "Asian" = "perc_asian",
          "Other" = "perc_other"
        ),
        income = c(
          "Median Household Income" = "income"
        )
      ),

      list(
        race = c(
          "White Non-Hisp." = "perc_white",
          "Black Non-Hisp." = "perc_black",
          "Hispanic" = "perc_hispanic",
          "Asian Non-Hisp." = "perc_asian",
          "Other Non-Hisp." = "perc_other"
        ),
        income = c(
          "Median Household Income" = "income"
        )
      )
    )
  })

  # ---- Dynamic selector with grouped choices ----
  output$variable_selector <- renderUI({
    race_label <- if (input$year >= 1980) {
      "Race/Ethnicity"
    } else {
      "Race"
    }

    choices_list <- list()

    choices_list[[race_label]] <- as.list(vars_available()$race)

    if (length(vars_available()$income) > 0) {
      choices_list[["Income"]] <- as.list(vars_available()$income)
    }

    selectInput(
      "selected_var",
      "Display:",
      choices = choices_list,
      selected = if (
        !is.null(input$selected_var) &&
          input$selected_var %in%
            c(vars_available()$race, vars_available()$income)
      ) {
        input$selected_var
      } else {
        "perc_white"
      }
    )
  })

  # ---- Filter data ----
  nyc_by_year <- split(nyc_data, nyc_data$year)

  filtered_data <- reactive({
    nyc_by_year[[as.character(input$year)]]
  }) %>%
    bindCache(input$year)

  # ---- Color palette ----
  color_pal <- reactive({
    df <- filtered_data()

    req(
      input$selected_var %in% names(df)
    )

    values <- df[[input$selected_var]]

    req(any(!is.na(values)))

    if (input$selected_var == "income") {
      inc_bins <- breaks %>%
        filter(year == input$year) %>%
        pull(value)

      colorBin(
        palette = "viridis",
        domain = values,
        na.color = "transparent",
        bins = inc_bins
      )
    } else {
      colorBin(
        palette = "viridis",
        domain = c(0, 1),
        na.color = "transparent",
        bins = 8
      )
    }
  }) %>%
    bindCache(input$year, input$selected_var)

  # ---- Initial map ----
  output$map <- renderLeaflet({
    leaflet() %>%
      addProviderTiles(providers$CartoDB.Positron) %>%
      setView(
        lng = -73.94,
        lat = 40.70,
        zoom = 11
      )
  })

  # ---- Update map ---
  observeEvent(
    list(input$year, input$selected_var),
    {
      df <- filtered_data()

      req(input$selected_var %in% colnames(df))

      df$values <- df[[input$selected_var]]

      req(!is.null(df$values))
      req(any(!is.na(df$values)))

      pal <- color_pal()

      leafletProxy("map", data = df) %>%
        clearShapes() %>%
        clearControls() %>%

        addPolygons(
          fillColor = ~ pal(values),
          fillOpacity = 0.7,
          color = "black",
          weight = 0.5,

          popup = ~popup,

          highlightOptions = highlightOptions(
            weight = 2,
            color = "blue",
            bringToFront = TRUE
          )
        ) %>%

        addLegend(
          pal = pal,
          values = df$values,
          position = "bottomright",
          title = switch(
            input$selected_var,
            "perc_white" = "% White",
            "perc_black" = "% Black",
            "perc_hispanic" = "% Hispanic",
            "perc_asian" = "% Asian",
            "perc_other" = "% Other",
            "income" = "Med. Income"
          ),
          labFormat = if (input$selected_var == "income") {
            labelFormat(
              prefix = "$",
              big.mark = ",",
              digits = 0
            )
          } else {
            labelFormat(
              transform = function(x) 100 * x,
              suffix = "%",
              digits = 1
            )
          }
        )
    }
  )
}

shinyApp(ui, server)

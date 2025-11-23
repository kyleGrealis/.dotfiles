---
name: shiny-patterns
description: Shiny application development patterns and best practices. Covers app structure, reactivity, UI design with bslib/shinywidgets, and performance optimization. Use when building or reviewing Shiny applications.
---

# Shiny Application Patterns

This skill defines preferred patterns for building Shiny applications, focusing on traditional structures that are maintainable, performant, and appropriate for small-to-medium scale apps.

## Preferred App Structure

**Traditional multi-file structure** (not golem, not rhino unless project complexity demands it):

```
app-name/
├── app.R               # Main app file (or use ui.R + server.R)
├── R/                  # All R code loaded at startup
│   ├── ui_components.R     # UI building blocks
│   ├── server_logic.R      # Server helper functions
│   ├── data_processing.R   # Data manipulation functions
│   └── utils.R             # Utility functions
├── www/                # Static assets
│   ├── styles.css      # Custom CSS
│   ├── logo.png        # Images
│   └── script.js       # Custom JavaScript (if needed)
├── data/               # Data files
│   ├── processed/      # Pre-processed data
│   └── raw/            # Raw data (if needed)
├── ext/                # External resources or modules (optional)
└── README.md
```

**Key principles**:
- Everything in `R/` is loaded when the app starts
- Keep files organized by purpose, not by feature
- Use `www/` for static assets (CSS, images, JS)
- Use `data/` for data files
- Avoid heavy framework overhead unless truly needed

## app.R Structure

**Single-file apps** (app.R):
```r
# Load packages
library(shiny)
library(bslib)
library(dplyr)

# Source R files
source('R/ui_components.R')
source('R/server_logic.R')
source('R/utils.R')

# UI
ui <- page_navbar(
  title = 'App Name',
  theme = app_theme,
  
  nav_panel(
    'Main',
    layout_sidebar(
      sidebar = sidebar(
        # Inputs here
      ),
      # Main content here
    )
  )
)

# Server
server <- function(input, output, session) {
  # Reactive values and expressions
  
  # Outputs
  
  # Observers
}

# Run app
shinyApp(ui, server)
```

**Two-file structure** (ui.R + server.R):
Use when UI and server logic are substantial. Structure is similar but split across files.

## UI Design with bslib

**Prefer bslib** for modern, themeable UI:

```r
# Define theme once
app_theme <- bs_theme(
  version = 5,
  bootswatch = 'flatly',  # or NULL for default
  base_font = font_google('Roboto'),
  'navbar-bg' = '#333',
  'navbar-fg' = '#fff'
)

# Use page_navbar or page_sidebar
ui <- page_navbar(
  title = 'App Name',
  theme = app_theme,
  
  nav_panel(
    'Analysis',
    layout_sidebar(
      sidebar = sidebar(
        selectInput('variable', 'Choose variable', choices = vars),
        actionButton('run', 'Run Analysis')
      ),
      card(
        card_header('Results'),
        plotOutput('plot')
      )
    )
  )
)
```

**bslib components to use**:
- `page_navbar()` / `page_sidebar()` - Modern page layouts
- `layout_sidebar()` - Sidebar layouts with responsive behavior
- `card()` / `value_box()` - Content containers
- `accordion()` - Collapsible sections
- `tooltip()` / `popover()` - Interactive help

## UI Enhancements with shinyWidgets

**Use shinyWidgets** for better input controls:

```r
library(shinyWidgets)

# Better select input with search
pickerInput(
  'variable',
  'Select variables',
  choices = vars,
  multiple = TRUE,
  options = pickerOptions(
    liveSearch = TRUE,
    actionsBox = TRUE
  )
)

# Pretty toggle switches
prettySwitch(
  'show_outliers',
  'Show outliers',
  value = TRUE,
  status = 'primary'
)

# Slider with better styling
sliderTextInput(
  'year',
  'Select year',
  choices = 2010:2024,
  selected = 2024
)
```

## htmltools for Dynamic UI

**Use htmltools** for programmatic HTML generation:

```r
library(htmltools)

# Build UI programmatically
create_metric_cards <- function(metrics) {
  tags$div(
    class = 'row',
    lapply(metrics, \(m) {
      tags$div(
        class = 'col-md-3',
        value_box(
          title = m$name,
          value = m$value,
          showcase = bs_icon(m$icon)
        )
      )
    })
  )
}
```

## Reactivity Patterns

**Reactive values**:
```r
# Initialize reactive values
rv <- reactiveValues(
  data = NULL,
  filtered_data = NULL,
  model_results = NULL
)

# Update in observers
observeEvent(input$load_data, {
  rv$data <- read_data()
})
```

**Reactive expressions** (for computed values):
```r
# Reactive expression (caches result)
filtered_data <- reactive({
  req(rv$data)
  rv$data |>
    filter(year >= input$year_min, year <= input$year_max)
})

# Use in outputs
output$plot <- renderPlot({
  ggplot(filtered_data(), aes(x = year, y = value)) +
    geom_line()
})
```

**Event reactivity**:
```r
# Only react to specific events
observeEvent(input$run_analysis, {
  # Run expensive computation only when button clicked
  rv$results <- run_analysis(filtered_data())
})
```

**Isolation** (prevent reactivity):
```r
# This won't react to input$variable changes
observeEvent(input$update, {
  process_data(isolate(input$variable))
})
```

## Performance Optimization

**1. Minimize reactivity**:
```r
# BAD - Recalculates on every input change
output$table <- renderTable({
  data |>
    filter(category == input$category) |>
    summarize(mean = mean(value))
})

# GOOD - Only recalculates when button clicked
summary_data <- eventReactive(input$calculate, {
  data |>
    filter(category == input$category) |>
    summarize(mean = mean(value))
})

output$table <- renderTable({
  summary_data()
})
```

**2. Use reactive expressions to avoid recomputation**:
```r
# Reactive expression caches result
filtered <- reactive({
  data |> filter(year == input$year)
})

# Multiple outputs use cached result
output$plot1 <- renderPlot({ plot(filtered()) })
output$plot2 <- renderPlot({ plot(filtered()) })  # Uses cached version
output$table <- renderTable({ filtered() })  # Uses cached version
```

**3. Debounce rapid inputs**:
```r
# Wait 500ms after user stops typing
year_debounced <- reactive({
  input$year
}) |> debounce(500)

filtered_data <- reactive({
  data |> filter(year == year_debounced())
})
```

**4. Pre-process data**:
```r
# Load and process data once at startup (outside server function)
processed_data <- readRDS('data/processed/clean_data.rds')

server <- function(input, output, session) {
  # Use pre-processed data
  output$plot <- renderPlot({
    ggplot(processed_data, aes(x, y)) + geom_point()
  })
}
```

## Modularization (When Needed)

**Use Shiny modules** for complex, reusable components (not every component):

```r
# Module UI
filter_ui <- function(id) {
  ns <- NS(id)
  tagList(
    selectInput(ns('variable'), 'Variable', choices = NULL),
    sliderInput(ns('range'), 'Range', min = 0, max = 100, value = c(0, 100))
  )
}

# Module server
filter_server <- function(id, data) {
  moduleServer(id, function(input, output, session) {
    # Update choices based on data
    observe({
      updateSelectInput(session, 'variable', choices = names(data()))
    })
    
    # Return filtered data
    reactive({
      req(input$variable)
      data() |>
        filter(!!sym(input$variable) >= input$range[1],
               !!sym(input$variable) <= input$range[2])
    })
  })
}

# Use in main app
ui <- fluidPage(
  filter_ui('filter1')
)

server <- function(input, output, session) {
  filtered <- filter_server('filter1', reactive(my_data))
}
```

**When to use modules**:
- Component is reused multiple times in the app
- Complexity justifies encapsulation
- Need to namespace inputs/outputs

**When NOT to use modules**:
- Simple apps with few components
- One-off UI sections
- Adds unnecessary complexity

## Error Handling

**Validate inputs**:
```r
output$plot <- renderPlot({
  # Require input before proceeding
  req(input$variable)
  
  # Validate input
  validate(
    need(nrow(data()) > 0, 'No data available'),
    need(input$variable %in% names(data()), 'Invalid variable selected')
  )
  
  # Proceed with plot
  ggplot(data(), aes(x = !!sym(input$variable))) +
    geom_histogram()
})
```

**Try-catch for robustness**:
```r
observeEvent(input$run, {
  result <- tryCatch(
    {
      run_analysis(data())
    },
    error = function(e) {
      showNotification(
        paste('Error:', e$message),
        type = 'error',
        duration = NULL
      )
      NULL
    }
  )
  
  if (!is.null(result)) {
    rv$results <- result
    showNotification('Analysis complete', type = 'message')
  }
})
```

## User Feedback

**Use notifications**:
```r
showNotification(
  'Data loaded successfully',
  type = 'message',  # or 'warning', 'error'
  duration = 3
)
```

**Use progress indicators**:
```r
observeEvent(input$process, {
  withProgress(message = 'Processing data...', value = 0, {
    for (i in 1:10) {
      incProgress(1/10, detail = paste('Step', i))
      Sys.sleep(0.1)  # Simulate work
    }
  })
})
```

**Use modal dialogs for confirmations**:
```r
observeEvent(input$delete, {
  showModal(
    modalDialog(
      title = 'Confirm deletion',
      'Are you sure you want to delete this data?',
      footer = tagList(
        modalButton('Cancel'),
        actionButton('confirm_delete', 'Delete', class = 'btn-danger')
      )
    )
  )
})
```

## File Organization Best Practices

**R/ directory organization**:
```r
R/
├── ui_components.R      # Reusable UI functions
├── server_helpers.R     # Server-side helper functions
├── data_processing.R    # Data manipulation functions
├── plotting.R           # Plot generation functions
└── utils.R              # General utilities
```

**Source files in app.R**:
```r
# Source all R files
list.files('R', pattern = '\\.R$', full.names = TRUE) |>
  walk(source)
```

## Common Anti-Patterns to Avoid

**1. Doing expensive computation in render functions**:
```r
# BAD
output$plot <- renderPlot({
  expensive_computation() |>  # Runs every time plot re-renders
    create_plot()
})

# GOOD
computed_data <- reactive({
  expensive_computation()  # Caches result
})

output$plot <- renderPlot({
  create_plot(computed_data())
})
```

**2. Not using req() for conditional dependencies**:
```r
# BAD - Errors when input is NULL
output$result <- renderText({
  paste('Selected:', input$choice)
})

# GOOD
output$result <- renderText({
  req(input$choice)
  paste('Selected:', input$choice)
})
```

**3. Using observe() when observeEvent() is clearer**:
```r
# BAD - Unclear what triggers this
observe({
  if (input$button > 0) {
    do_something()
  }
})

# GOOD - Clear trigger
observeEvent(input$button, {
  do_something()
})
```

**4. Growing reactive values unnecessarily**:
```r
# BAD - Memory leak
observeEvent(input$add, {
  rv$history <- c(rv$history, input$value)  # Grows forever
})

# GOOD - Limit history
observeEvent(input$add, {
  rv$history <- tail(c(rv$history, input$value), 100)
})
```

## Testing Shiny Apps

**Use shinytest2** for testing:
```r
library(shinytest2)

test_that('App loads correctly', {
  app <- AppDriver$new()
  app$expect_values()
})

test_that('Filter works', {
  app <- AppDriver$new()
  app$set_inputs(year = 2020)
  app$expect_values(output = 'filtered_data')
})
```

## Summary

**Key principles for Shiny apps**:
1. Use **traditional structure** for most apps (not golem/rhino unless needed)
2. Load all R code from `R/` at startup
3. Use **bslib** for modern, themeable UI
4. Use **shinyWidgets** for enhanced inputs
5. Minimize reactivity - use `eventReactive()` for expensive operations
6. Cache with reactive expressions
7. Validate inputs with `req()` and `validate()`
8. Use modules only when complexity justifies it
9. Pre-process data outside the server function when possible
10. Provide user feedback (notifications, progress, validation messages)

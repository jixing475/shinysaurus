#' explore UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd 
#'
#' @importFrom shiny NS tagList 
#' @import bs4Dash
mod_explore_ui <- function(id){
  # obtain names of available datasauRus data sets
  ds_names <- unique(datasauRus::datasaurus_dozen$dataset)
  
  ns <- NS(id)
  tagList(
    fluidRow(
      col_12(
        bs4Card(
          inputId = ns("doc_card"),
          title = "About this UI",
          status = "primary",
          solidHeader = TRUE,
          width = 12,
          collapsible = TRUE,
          collapsed = FALSE,
          closeable = TRUE,
          includeMarkdown(app_sys("app", "docs", "explore.md"))
        )
      )
    ),
    fluidRow(
      col_12(
        bs4Card(
          inputId = ns("explore_card"),
          title = "Explore!",
          status = "primary",
          solidHeader = TRUE,
          width = 12,
          collapsible = TRUE,
          collapsed = FALSE,
          closeable = TRUE,
          
          fluidRow(
            col_12(
              selectInput(
                ns("data_select"),
                "Select your dataset!",
                choices = ds_names,
                selected = ds_names[1]
              )
            )
          ),
          
          fluidRow(
            bs4InfoBoxOutput(
              ns("box_x"),
              width = 4
            ),
            bs4InfoBoxOutput(
              ns("box_y"),
              width = 4
            ),
            bs4InfoBoxOutput(
              ns("box_cor"),
              width = 4
            )
          ),
          
          fluidRow(
            col_8(
              plotly::plotlyOutput(ns("ds_plot"), height = "600px"),
              verbatimTextOutput(ns("info"))
            ),
            col_4(
              DT::dataTableOutput(ns("ds_table"))
            )
          )
        )
      )
    )
  )
}
    
#' explore Server Function
#'
#' @noRd 
mod_explore_server <- function(input, output, session){
  ns <- session$ns
  
  # keep track of which rows
  df_rows <- reactiveVal(NULL)
  df_sub <- reactiveVal(NULL)
  
  # reactive for data frame selected
  data_df <- reactive({
    req(input$data_select)
    extract_dataset(input$data_select)
  })
  
  # render the info boxes
  output$box_x <- renderbs4InfoBox({
    req(data_df())
    if (!is.null(df_sub())) {
      df <- df_sub()
    } else {
      df <- data_df()
    }
    bs4InfoBox(
      title = "Mean (SD) of X",
      gradientColor = "success",
      value = mean_sd_print(df, "x"),
      icon = "table"
    )
  })
  
  output$box_y <- renderbs4InfoBox({
    req(data_df())
    if (!is.null(df_sub())) {
      df <- df_sub()
    } else {
      df <- data_df()
    }
    bs4InfoBox(
      title = "Mean (SD) of Y",
      gradientColor = "success",
      value = mean_sd_print(df, "y"),
      icon = "table"
    )
  })
  
  output$box_cor <- renderbs4InfoBox({
    req(data_df())
    if (!is.null(df_sub())) {
      df <- df_sub()
    } else {
      df <- data_df()
    }
    bs4InfoBox(
      title = "Correlation",
      gradientColor = "primary",
      value = round(cor(x = df$x, y = df$y), 2),
      icon = "table"
    )
  })
  
  # render interactive graph via plotly
  output$ds_plot <- plotly::renderPlotly({
    req(data_df())
    render_data_graph(data_df())
  })
  
  output$info <- renderPrint({
    tmp <- plotly::event_data("plotly_selected", source = "A")
    if (is.null(tmp)) {
      df_sub(NULL)
    }
    print("Hi there!")
  })
  
  # obtain rows selected in plotly chart and update reactive value
  observeEvent(event_data("plotly_selected", source = "A"), {
    
    df_rows_sel <- event_data("plotly_selected")$customdata
    df_rows(df_rows_sel)
    
    if (is.null(df_rows_sel)) {
      df_sub(NULL)
    } else {
      df_filtered <- dplyr::slice(data_df(), df_rows_sel)
      df_sub(df_filtered)
    }
    
  })
  
  output$ds_table <- DT::renderDataTable({
    req(data_df())
    
    if (is.null(df_sub())) {
      res <- data_df()
    } else {
      res <- df_sub()
    }
    return(res)
  },
  rownames = FALSE,
  options = list(dom = 'tip')
  )
 
}
    
## To be copied in the UI
# mod_explore_ui("explore_ui_1")
    
## To be copied in the server
# callModule(mod_explore_server, "explore_ui_1")
 

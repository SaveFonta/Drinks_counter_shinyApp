library(shiny)
library(ggplot2)

# Definisci l'interfaccia utente
ui <- fluidPage(
  titlePanel("Calcolatore Alcolici per Aperitivo"),
  sidebarLayout(
    sidebarPanel(
      numericInput("num_guests", "Numero di invitati:", 60, min = 1),
      numericInput("duration", "Durata dell'evento (ore):", 6, min = 1),
      numericInput("hard_drinkers", "Percentuale Hard drinkers (%):", 25, min = 0, max = 100),
      numericInput("medium_drinkers", "Percentuale Medium drinkers (%):", 50, min = 0, max = 100),
      numericInput("light_drinkers", "Percentuale Light drinkers (%):", 20, min = 0, max = 100),
      numericInput("non_drinkers", "Percentuale Astemi (%):", 5, min = 0, max = 100),
      numericInput("beer_ratio", "Percentuale Birre (%):", 25, min = 0, max = 100),
      numericInput("spritz_ratio", "Percentuale Spritz (%):", 40, min = 0, max = 100),
      numericInput("gin_tonic_ratio", "Percentuale Gin Tonic (%):", 30, min = 0, max = 100),
      numericInput("jagermeister_ratio", "Percentuale Jägermeister (%):", 5, min = 0, max = 100),
      actionButton("calculate", "Calcola", class = "btn-primary")
    ),
    mainPanel(
      uiOutput("validation_message"),
      tabsetPanel(
        tabPanel("Risultati",
                 tableOutput("results"),
                 tableOutput("ingredients"),
                 tableOutput("ice")),
        tabPanel("Grafico",
                 plotOutput("drink_plot"))
      )
    )
  ),
  tags$head(
    tags$style(
      HTML("
        .btn-primary {
          background-color: #007bff;
          color: white;
          border: none;
          padding: 10px 20px;
          border-radius: 5px;
          font-size: 16px;
          cursor: pointer;
        }
        .btn-primary:hover {
          background-color: #0056b3;
        }
      ")
    )
  )
)

# Funzione per calcolare i drink con un modello esponenziale
calculate_drinks <- function(num_guests, duration, hard_drinkers, medium_drinkers, light_drinkers, non_drinkers) {
  total_drinks <- 0
  
  # Parametri per la decrescita esponenziale (aumento per un calo più veloce)
  decay_rate_hard <- 0.8
  decay_rate_medium <- 0.6
  decay_rate_light <- 0.4
  
  for (hour in 1:duration) {
    drinks_per_hour <- (hard_drinkers * (5 * exp(-decay_rate_hard * (hour - 1))) +  # Hard drinkers
                          medium_drinkers * (3 * exp(-decay_rate_medium * (hour - 1))) + # Medium drinkers
                          light_drinkers * (2 * exp(-decay_rate_light * (hour - 1))) +  # Light drinkers
                          non_drinkers * 0) / 100
    total_drinks <- total_drinks + num_guests * drinks_per_hour
  }
  return(total_drinks)
}

# Funzione per calcolare gli ingredienti
calculate_ingredients <- function(total_drinks, gin_tonic_ratio, spritz_ratio) {
  # Calcola il numero di drink per ciascun tipo
  gin_tonic_drinks <- total_drinks * gin_tonic_ratio / 100
  spritz_drinks <- total_drinks * spritz_ratio / 100
  
  # Ingredienti per Gin Tonic
  gin_per_drink <- 50 / 1000  # in litri
  tonic_per_drink <- 150 / 1000  # in litri
  
  # Ingredienti per Spritz
  prosecco_per_drink <- 90 / 1000  # in litri
  aperol_per_drink <- 60 / 1000  # in litri
  soda_per_drink <- 30 / 1000  # in litri
  
  # Calcola la quantità totale necessaria
  total_gin <- gin_tonic_drinks * gin_per_drink
  total_tonic <- gin_tonic_drinks * tonic_per_drink
  total_prosecco <- spritz_drinks * prosecco_per_drink
  total_aperol <- spritz_drinks * aperol_per_drink
  total_soda <- spritz_drinks * soda_per_drink
  
  # Crea un data frame per gli ingredienti
  data.frame(
    Ingrediente = c("Gin", "Acqua Tonica", "Prosecco", "Aperol", "Soda"),
    Quantità = c(
      paste0(round(total_gin, 2), " litri"),
      paste0(round(total_tonic, 2), " litri"),
      paste0(round(total_prosecco, 2), " litri"),
      paste0(round(total_aperol, 2), " litri"),
      paste0(round(total_soda, 2), " litri")
    )
  )
}

# Funzione per calcolare il ghiaccio con le nuove proporzioni
calculate_ice <- function(total_drinks, gin_tonic_ratio, spritz_ratio, jagermeister_ratio) {
  # Calcola il numero di drink per ciascun tipo
  gin_tonic_drinks <- total_drinks * gin_tonic_ratio / 100
  spritz_drinks <- total_drinks * spritz_ratio / 100
  jagermeister_drinks <- total_drinks * jagermeister_ratio / 100
  
  # Ghiaccio necessario per tipo di drink (in kg, 1 litro = 1 kg)
  ice_per_gin_tonic <- 0.09  # 90 grammi
  ice_per_spritz <- 0.09  # 90 grammi
  ice_per_jagermeister <- 0.03  # 30 grammi
  
  # Calcola il volume totale di ghiaccio necessario
  total_ice_gin_tonic <- gin_tonic_drinks * ice_per_gin_tonic
  total_ice_spritz <- spritz_drinks * ice_per_spritz
  total_ice_jagermeister <- jagermeister_drinks * ice_per_jagermeister
  
  total_ice_kg <- total_ice_gin_tonic + total_ice_spritz + total_ice_jagermeister
  
  # Crea un data frame per il ghiaccio
  data.frame(
    Tipo = "Ghiaccio",
    Quantità = paste0(round(total_ice_kg, 2), " kg")
  )
}

# Definisci il server
server <- function(input, output) {
  
  observeEvent(input$calculate, {
    # Funzione per la validazione delle percentuali
    validate_percentages <- reactive({
      total_beer_spritz_gin_jager <- sum(input$beer_ratio, input$spritz_ratio, input$gin_tonic_ratio, input$jagermeister_ratio)
      total_drinkers <- sum(input$hard_drinkers, input$medium_drinkers, input$light_drinkers, input$non_drinkers)
      
      if (total_beer_spritz_gin_jager != 100) {
        return("Le percentuali delle bevande devono sommare a 100.")
      }
      
      if (total_drinkers != 100) {
        return("Le percentuali dei tipi di bevitore devono sommare a 100.")
      }
      
      return(NULL)
    })
    
    output$validation_message <- renderUI({
      validation_message <- validate_percentages()
      if (!is.null(validation_message)) {
        tags$div(style = "color: red;", validation_message)
      }
    })
    
    output$results <- renderTable({
      validation_message <- validate_percentages()
      if (!is.null(validation_message)) {
        return(NULL)
      }
      
      # Calcola il numero totale di drink consumati
      total_drinks <- calculate_drinks(
        num_guests = input$num_guests,
        duration = input$duration,
        hard_drinkers = input$hard_drinkers,
        medium_drinkers = input$medium_drinkers,
        light_drinkers = input$light_drinkers,
        non_drinkers = input$non_drinkers
      )
      
      # Distribuzione dei drink tra le bevande
      beer <- total_drinks * input$beer_ratio / 100
      spritz <- total_drinks * input$spritz_ratio / 100
      gin_tonic <- total_drinks * input$gin_tonic_ratio / 100
      jagermeister <- total_drinks * input$jagermeister_ratio / 100
      
      # Calcoli finali per quantità
      beer_liters <- beer * 0.5
      spritz_liters <- spritz * 0.18
      gin_tonic_liters <- gin_tonic * 0.2
      jagermeister_liters <- jagermeister * 0.04
      
      # Crea un data frame per i risultati
      data.frame(
        Bevanda = c("Birre", "Spritz", "Gin Tonic", "Jägermeister"),
        Quantità = c(
          paste0(round(beer), " bottiglie (", round(beer_liters, 2), " litri)"),
          paste0(round(spritz), " bicchieri (", round(spritz_liters, 2), " litri)"),
          paste0(round(gin_tonic), " bicchieri (", round(gin_tonic_liters, 2), " litri)"),
          paste0(round(jagermeister), " shot (", round(jagermeister_liters, 2), " litri)")
        )
      )
    })
    
    output$ingredients <- renderTable({
      validation_message <- validate_percentages()
      if (!is.null(validation_message)) {
        return(NULL)
      }
      
      # Calcola gli ingredienti necessari
      ingredients <- calculate_ingredients(
        total_drinks = calculate_drinks(
          num_guests = input$num_guests,
          duration = input$duration,
          hard_drinkers = input$hard_drinkers,
          medium_drinkers = input$medium_drinkers,
          light_drinkers = input$light_drinkers,
          non_drinkers = input$non_drinkers
        ),
        gin_tonic_ratio = input$gin_tonic_ratio,
        spritz_ratio = input$spritz_ratio
      )
      
      ingredients
    })
    
    output$ice <- renderTable({
      validation_message <- validate_percentages()
      if (!is.null(validation_message)) {
        return(NULL)
      }
      
      # Calcola il ghiaccio necessario
      ice <- calculate_ice(
        total_drinks = calculate_drinks(
          num_guests = input$num_guests,
          duration = input$duration,
          hard_drinkers = input$hard_drinkers,
          medium_drinkers = input$medium_drinkers,
          light_drinkers = input$light_drinkers,
          non_drinkers = input$non_drinkers
        ),
        gin_tonic_ratio = input$gin_tonic_ratio,
        spritz_ratio = input$spritz_ratio,
        jagermeister_ratio = input$jagermeister_ratio
      )
      
      ice
    })
    
    output$drink_plot <- renderPlot({
      validation_message <- validate_percentages()
      if (!is.null(validation_message)) {
        return(NULL)
      }
      
      # Calcola il numero totale di drink consumati
      total_drinks <- calculate_drinks(
        num_guests = input$num_guests,
        duration = input$duration,
        hard_drinkers = input$hard_drinkers,
        medium_drinkers = input$medium_drinkers,
        light_drinkers = input$light_drinkers,
        non_drinkers = input$non_drinkers
      )
      
      # Distribuzione dei drink tra le bevande
      beer <- total_drinks * input$beer_ratio / 100
      spritz <- total_drinks * input$spritz_ratio / 100
      gin_tonic <- total_drinks * input$gin_tonic_ratio / 100
      jagermeister <- total_drinks * input$jagermeister_ratio / 100
      
      # Dati per il grafico
      drink_data <- data.frame(
        Bevanda = c("Birre", "Spritz", "Gin Tonic", "Jägermeister"),
        Quantità = c(beer, spritz, gin_tonic, jagermeister)
      )
      
      ggplot(drink_data, aes(x = Bevanda, y = Quantità, fill = Bevanda)) +
        geom_bar(stat = "identity") +
        labs(title = "Distribuzione dei Drink", x = "Tipo di Drink", y = "Numero di Drink") +
        theme_minimal() +
        scale_fill_brewer(palette = "Set3")
    })
  })
}

shinyApp(ui = ui, server = server)



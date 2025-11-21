library(shiny)
library(ggplot2)
library(dplyr)
library(shinydashboard)
library(scales)
library(DT)
library(MASS)
library(plotly)
library(arrow)


# Carregar dados ----

at <- read_parquet("F84_atendimentos_dashboard.parquet", sep = ",", encoding = "UTF-8")

pac <- read_parquet("F84_pac_dashboard.parquet", sep = ",", encoding = "UTF-8")

pac <- pac %>%
  mutate(
    ano_dt_inicio = as.numeric(substr(DT_INICIO, 1, 4))
  )

filtro_ano_pac <- function(df, input_ano) {
  if (is.null(input_ano)) return(df)
  
  df %>%
    filter(
      ano >= input_ano & ano_dt_inicio <= input_ano
    )
}

tabela_procs <- read.csv("procedimentos_caps.csv", encoding = "UTF-8", stringsAsFactors = FALSE) 

dados_scatterplot <- at %>%
  group_by(UFMUN, nome, pop) %>%
  summarise(qtd_atendimentos = n(), .groups = "drop") %>%
  dplyr::select(UFMUN, nome, pop, qtd_atendimentos)


# UI ----
ui <- dashboardPage(
  skin = "blue",  # mantém coerência com seu CSS
  dashboardHeader(
    titleWidth = 250,
    title = "Projeto F84 - Autismo no Brasil"
  ),
  
  dashboardSidebar(
    width = 250,
    sidebarMenu(
      menuItem("Distribuição Demográfica", tabName = "demografia"),
      menuItem("Localização", tabName = "localizacao"),
      menuItem("Procedimentos", tabName = "procedimentos"),
      menuItem("Situações", tabName = "situacoes"),
      menuItem("CID Primária/Secundária", tabName = "cid"),
      menuItem("Tendência Temporal", tabName = "temporal"),
      menuItem("Estatísticas Estaduais", tabName = "estadual"),
      menuItem("Estatísticas Municipais", tabName = "municipio")
    )
  ),
  
  dashboardBody(
    tags$link(rel="stylesheet", type="text/css", href="www/style.css"),
    tags$script(src = "www/meu_script.js"),
    
    
    # Define o conteúdo das abas
    tabItems(
      
      ##### Demografia #####
      tabItem(
        tabName = "demografia",
        fluidRow(
          box(width = 3, title = "Filtros", solidHeader = TRUE, status = "primary",
              selectInput("estado_dem", "Selecione o Estado:", choices = NULL, multiple = TRUE),
              selectInput("municipio_dem", "Selecione o Município:", choices = NULL, multiple = TRUE),
              selectInput("ano_dem", "Selecione os Anos:", choices = NULL, multiple = TRUE),
              selectInput("tipo_dado_dem", "Tipo de dado:", choices = c("Atendimentos","Pacientes"))
          ),
          
          box(width = 9, title = "Distribuição Demográfica", solidHeader = TRUE, status = "primary",
             
              fluidRow(
                valueBoxOutput("box_total_atend_dem"),
                valueBoxOutput("box_total_pac_dem")
              ),
              
               # Primeira linha: sexo e etnia (dados filtrados)
              fluidRow(
                column(width = 6, plotOutput("plot_sexo")),
                column(width = 6, plotOutput("plot_etnia"))
              ),
              
              # Segunda linha: gráfico fixo nacional
              fluidRow(
                column(width = 6,
                       plotOutput("plot_sexo_brasil")
                ),
                column(width = 6,
                       plotOutput("plot_etnia_brasil")
                )
              ),
              
              # Terceira linha: distribuição de idade
              plotOutput("plot_idade", height = "300px")
          )
        )
      ),
      
      
      ##### Localização #####
      tabItem(
        tabName = "localizacao",
        fluidRow(
          box(width = 3, title = "Filtros", solidHeader = TRUE, status = "primary",
              selectInput("estado_loc", "Selecione o Estado:", choices = NULL, multiple = TRUE),
              selectInput("sexo_loc", "Selecione o Sexo:", choices = NULL, multiple = TRUE),
              selectInput("etnia_loc", "Selecione a Etnia:", choices = NULL, multiple = TRUE),
              selectInput("ano_loc", "Selecione os Anos:", choices = NULL, multiple = TRUE),
              selectInput("tipo_dado_loc", "Tipo de dado:", choices = c("Atendimentos","Pacientes"))
          ),
          box(width = 9, title = "Distribuição Geográfica", solidHeader = TRUE, status = "primary",
              
              fluidRow(
                valueBoxOutput("box_total_atend_loc"),
                valueBoxOutput("box_total_pac_loc")
              ),
              
              plotOutput("plot_estado"),
              plotOutput("plot_municipio"),
              
              fluidRow(
                column(6,
                       selectizeInput(
                         "search_city_scatter",
                         "Buscar cidade:",
                         choices = sort(unique(dados_scatterplot$nome)),
                         multiple = FALSE,
                         options = list(
                           placeholder = 'Digite o nome da cidade...',
                           maxOptions = 5
                         )
                       )
                )
              ),
              
              plotlyOutput("plot_scatter")
          )
        )
      ),
      
      
      ##### Procedimentos #####
      tabItem(
        tabName = "procedimentos",
        fluidRow(
          box(width = 3, title = "Filtros", solidHeader = TRUE, status = "primary",
              selectInput("estado_proc", "Selecione o Estado:", choices = NULL, multiple = TRUE),
              selectInput("municipio_proc", "Selecione o Município:", choices = NULL, multiple = TRUE),
              selectInput("sexo_proc", "Selecione o Sexo:", choices = NULL, multiple = TRUE),
              selectInput("cor_proc", "Selecione a Etnia:", choices = NULL, multiple = TRUE),
              selectInput("ano_proc", "Selecione os Anos:", choices = NULL, multiple = TRUE)
          ),
          box(width = 9, title = "Top Procedimentos", solidHeader = TRUE, status = "primary",
              
              fluidRow(
                valueBoxOutput("box_total_atend_proc"),
                valueBoxOutput("box_total_pac_proc")
              ),
              
              plotOutput("plot_top_proc", height = "600px")
          )
        )
      ),
      
      
      ##### Situações #####
      tabItem(
        tabName = "situacoes",
        fluidRow(
          box(width = 3, title = "Filtros", solidHeader = TRUE, status = "primary",
              selectInput("estado_sit", "Selecione o Estado:", choices = NULL, multiple = TRUE),
              selectInput("municipio_sit", "Selecione o Município:", choices = NULL, multiple = TRUE),
              selectInput("sexo_sit", "Selecione o Sexo:", choices = NULL, multiple = TRUE),
              selectInput("cor_sit", "Selecione a Etnia:", choices = NULL, multiple = TRUE),
              selectInput("ano_sit", "Selecione os Anos:", choices = NULL, multiple = TRUE)
          ),
          box(width = 9, title = "Situações", solidHeader = TRUE, status = "primary",
              
              fluidRow(
                valueBoxOutput("box_total_atend_sit"),
                valueBoxOutput("box_total_pac_sit")
              ),
              
              plotOutput("plot_drogas"),
              plotOutput("plot_rua")
          )
        )
      ),
      
      
      ##### Cid #####
      tabItem(
        tabName = "cid",
        fluidRow(
          # Filtros específicos da aba CID
          box(
            width = 3,
            title = "Filtros",
            solidHeader = TRUE,
            status = "primary",
            selectInput("estado_cid", "Selecione o Estado:", choices = NULL, multiple = TRUE),
            selectInput("municipio_cid", "Selecione o Município:", choices = NULL, multiple = TRUE),
            selectInput("sexo_cid", "Selecione o Sexo:", choices = NULL, multiple = TRUE),
            selectInput("cor_cid", "Selecione a Etnia:", choices = NULL, multiple = TRUE)
          ),
          
          # Gráficos CID
          box(
            width = 9,
            title = "Distribuição de CIDs",
            solidHeader = TRUE,
            status = "primary",
            
            fluidRow(
              valueBoxOutput("box_total_atend_cid"),
              valueBoxOutput("box_total_pac_cid")
            ),
            
            fluidRow(
              column(width = 6, plotOutput("plot_cidpri")),
              column(width = 6, plotOutput("plot_cidassoc"))
            )
          )
        )
      ),
      
      
      ##### Temporal #####
      tabItem(
        tabName = "temporal",
        fluidRow(
          # Filtros específicos da aba Temporal
          box(
            width = 3,
            title = "Filtros",
            solidHeader = TRUE,
            status = "primary",
            selectInput("estado_temporal", "Selecione o Estado:", choices = NULL, multiple = TRUE)
          ),
          
          
          # Gráficos de evolução
          box(
            width = 9,
            title = "Evolução dos Atendimentos",
            solidHeader = TRUE,
            status = "primary",
            
            fluidRow(
              valueBoxOutput("box_total_atend_temp"),
              valueBoxOutput("box_total_pac_temp")
            ),
            
            fluidRow(
              column(width = 4, plotOutput("plot_inicio")),
              column(width = 4, plotOutput("plot_fim")),
              column(width = 4, plotOutput("plot_atendimentos"))
            )
          )
        )
      ),
      
      
      ##### Estadual #####
      tabItem(
        tabName = "estadual",
        fluidRow(
          box(
            width = 12,
            title = "Estatísticas por Estado",
            solidHeader = TRUE,
            status = "primary",
            
            # Filtro de tipo de dado
            selectInput(
              "tipo_dado_estado",
              "Tipo de dado:",
              choices = c("Atendimentos", "Pacientes"),
              selected = "Atendimentos"
            ),
            
            DTOutput("tabela_estado")
          )
        )
      ),
      
      
      ##### Municipial #####
      tabItem(
        tabName = "municipio",
        fluidRow(
          box(
            width = 12,
            title = "Estatísticas por Município",
            solidHeader = TRUE,
            status = "primary",
            
            # Filtro de tipo de dado
            selectInput(
              "tipo_dado_municipio",
              "Tipo de dado:",
              choices = c("Atendimentos", "Pacientes"),
              selected = "Atendimentos"
            ),
            
            DTOutput("tabela_municipio")
          )
        )
      )
      
    )
  )
)






# SERVER ----
server <- function(input, output, session) {
  
  is_pac <- FALSE
  is_atend <- FALSE  
  
  
#----SELECTS------
  
  ##### Selects Gerais #####
  observe({
    estados <- sort(unique(at$uf))
    cores <- sort(unique(na.omit(at$RACACOR)))
    sexos   <- sort(unique(at$SEXOPAC))
    anos <- unique(at$ano[at$ano >= 2013])
    
    # Demografia
    updateSelectInput(session, "estado_dem", choices = estados)
    updateSelectInput(session, "ano_dem", choices = anos)
    
    
    # Localização
    updateSelectInput(session, "estado_loc", choices = estados)
    updateSelectInput(session, "sexo_loc", choices = sexos)
    updateSelectInput(session, "etnia_loc", choices = cores)
    updateSelectInput(session, "ano_loc", choices = anos)
    
    # Procedimentos
    updateSelectInput(session, "estado_proc", choices = estados)
    updateSelectInput(session, "sexo_proc", choices = sexos)
    updateSelectInput(session, "cor_proc", choices = cores)
    updateSelectInput(session, "ano_proc", choices = anos)
    
    # Situações
    updateSelectInput(session, "estado_sit", choices = estados)
    updateSelectInput(session, "sexo_sit", choices = sexos)
    updateSelectInput(session, "cor_sit", choices = cores)
    updateSelectInput(session, "ano_sit", choices = anos)
    
    updateSelectInput(session, "estado_cid", choices = estados)
    updateSelectInput(session, "sexo_cid", choices = sexos)
    updateSelectInput(session, "cor_cid", choices = cores)
    updateSelectInput(session, "ano_cid", choices = anos)
    
    updateSelectInput(session, "estado_temporal", choices = estados)
  })
  
  ##### Selects de município #####
  observeEvent(input$estado_dem, {
    # Só atualiza municípios quando o estado for escolhido
    req(input$estado_dem)
    
    # Filtra municípios correspondentes ao(s) estado(s) selecionado(s)
    municipios_filtrados <- pac %>%
      filter(uf %in% input$estado_dem) %>%
      distinct(nome) %>%
      arrange(nome) %>%
      pull(nome)
    
    # Atualiza o seletor de município
    updateSelectInput(session, "municipio_dem",
                      choices = municipios_filtrados,
                      selected = NULL)
  })
  
  
  observeEvent(input$estado_proc, {
    # Só atualiza municípios quando o estado for escolhido
    req(input$estado_proc)
    
    # Filtra municípios correspondentes ao(s) estado(s) selecionado(s)
    municipios_filtrados <- pac %>%
      filter(uf %in% input$estado_proc) %>%
      distinct(nome) %>%
      arrange(nome) %>%
      pull(nome)
    
    # Atualiza o seletor de município
    updateSelectInput(session, "municipio_proc",
                      choices = municipios_filtrados,
                      selected = NULL)
  })
  
  
  observeEvent(input$estado_sit, {
    # Só atualiza municípios quando o estado for escolhido
    req(input$estado_sit)
    
    # Filtra municípios correspondentes ao(s) estado(s) selecionado(s)
    municipios_filtrados <- pac %>%
      filter(uf %in% input$estado_sit) %>%
      distinct(nome) %>%
      arrange(nome) %>%
      pull(nome)
    
    # Atualiza o seletor de município
    updateSelectInput(session, "municipio_sit",
                      choices = municipios_filtrados,
                      selected = NULL)
  })
  
  observeEvent(input$estado_cid, {
    # Só atualiza municípios quando o estado for escolhido
    req(input$estado_cid)
    
    # Filtra municípios correspondentes ao(s) estado(s) selecionado(s)
    municipios_filtrados <- pac %>%
      filter(uf %in% input$estado_cid) %>%
      distinct(nome) %>%
      arrange(nome) %>%
      pull(nome)
    
    # Atualiza o seletor de município
    updateSelectInput(session, "municipio_cid",
                      choices = municipios_filtrados,
                      selected = NULL)
  })
  
  
  
  

#-----FILTROS E DADOS---------
  
  
  ##### Demografia #####
  dados_demografia <- reactive({
    if(input$tipo_dado_dem=="Pacientes") {
      pac %>%
        filter(
          is.null(input$estado_dem) | uf %in% input$estado_dem,
          is.null(input$municipio_dem) | nome %in% input$municipio_dem
        ) %>%
        filtro_ano_pac(input$ano_dem)
    } else {
      at %>%
        filter(
          is.null(input$estado_dem) | uf %in% input$estado_dem,
          is.null(input$ano_dem)  | ano %in% input$ano_dem,
          is.null(input$municipio_dem) | nome %in% input$municipio_dem
        )
    }
  })
  
  ##### Localização #####
  dados_localizacao <- reactive({
    if(input$tipo_dado_loc=="Pacientes") {
      pac %>%
        filter(
          is.null(input$estado_loc) | uf %in% input$estado_loc,
          is.null(input$sexo_loc)   | SEXOPAC %in% input$sexo_loc,
          is.null(input$etnia_loc)  | RACACOR %in% input$etnia_loc
        ) %>%
        filtro_ano_pac(input$ano_loc)
    } else {
      at %>%
        filter(
          is.null(input$estado_loc) | uf %in% input$estado_loc,
          is.null(input$sexo_loc)   | SEXOPAC %in% input$sexo_loc,
          is.null(input$etnia_loc)  | RACACOR %in% input$etnia_loc,
          is.null(input$ano_loc)  | ano %in% input$ano_loc
        )
    }
  })
  
  dados_atendimentos_por_estado <- reactive({
    if(input$tipo_dado_loc=="Pacientes") {
      pac %>%
        filter(
          is.null(input$sexo_loc)   | SEXOPAC %in% input$sexo_loc,
          is.null(input$etnia_loc)  | RACACOR %in% input$etnia_loc
        ) %>%
        filtro_ano_pac(input$ano_loc)
    } else {
      at %>%
        filter(
          is.null(input$sexo_loc)   | SEXOPAC %in% input$sexo_loc,
          is.null(input$etnia_loc)  | RACACOR %in% input$etnia_loc,
          is.null(input$ano_loc)  | ano %in% input$ano_loc
        )
    }
  })
  
  
  ##### Procedimentos #####
  dados_proc <- reactive({
    at %>%
      filter(
        is.null(input$estado_proc) | uf %in% input$estado_proc,
        is.null(input$municipio_proc) | nome %in% input$municipio_proc,
        is.null(input$sexo_proc)   | SEXOPAC %in% input$sexo_proc,
        is.null(input$cor_proc)    | RACACOR %in% input$cor_proc,
        is.null(input$ano_proc)  | ano %in% input$ano_proc
      )
  })
  
  
  ##### Situações #####
  dados_situacoes <- reactive({
    pac %>%
      filter(
        is.null(input$estado_sit) | uf %in% input$estado_sit,
        is.null(input$municipio_sit) | nome %in% input$municipio_sit,
        is.null(input$sexo_sit)   | SEXOPAC %in% input$sexo_sit,
        is.null(input$cor_sit)    | RACACOR %in% input$cor_sit
      ) %>%
      filtro_ano_pac(input$ano_sit)
  })
  
  ##### Cid #####
  dados_cid <- reactive({
    pac %>%
      filter(
        is.null(input$estado_cid) | uf %in% input$estado_cid,
        is.null(input$municipio_cid) | nome %in% input$municipio_cid,
        is.null(input$sexo_cid)   | SEXOPAC %in% input$sexo_cid,
        is.null(input$cor_cid)    | RACACOR %in% input$cor_cid
      )
  })
  
  ##### Temporal #####
  dados_temporal <- reactive({
    pac %>%
      filter(
        is.null(input$estado_temporal) | uf %in% input$estado_temporal
      )
  })
  
  dados_temporal_atend <- reactive({
    at %>%
      filter(
        is.null(input$estado_temporal) | uf %in% input$estado_temporal
      )
  })
  
  
  ##### Estadual #####
  dados_estado <- reactive({
    if (input$tipo_dado_estado == "Pacientes") {
      pac 
    } else {
      at 
    }
  })

  
  ##### Municipal #####
  dados_municipio <- reactive({
    if (input$tipo_dado_municipio == "Pacientes") {
      pac %>%
        group_by(nome)
    } else {
      at %>%
        group_by(nome)
    }
  })
  
  
  
  
  
  
  
  
  #----BOXES-----
  ##### Demografia #####
  output$box_total_atend_dem <- renderValueBox({
    total_atend <- nrow(
      at %>%
        filter(
          is.null(input$estado_dem) | uf %in% input$estado_dem,
          is.null(input$municipio_dem) | nome %in% input$municipio_dem,
          is.null(input$ano_dem) | ano %in% input$ano_dem
        )
    )
    
    valueBox(
      format(total_atend, big.mark = "."),
      "Total de Atendimentos",
      icon = icon("stethoscope"),
      color = "purple"
    )
  })
  

  output$box_total_pac_dem <- renderValueBox({
    total_pac <- n_distinct(
      pac %>%
        filter(
          is.null(input$estado_dem) | uf %in% input$estado_dem,
          is.null(input$municipio_dem) | nome %in% input$municipio_dem
        ) %>%
        filtro_ano_pac(input$ano_dem) %>%
        pull(CNS_PAC)
    )
    
    valueBox(
      format(total_pac, big.mark = "."),
      "Total de Pacientes",
      icon = icon("users"),
      color = "teal"
    )
  })
  
  ##### Localização #####
  output$box_total_atend_loc <- renderValueBox({
    total_atend <- nrow(
      at %>%
        filter(
          is.null(input$estado_loc) | uf %in% input$estado_loc,
          is.null(input$sexo_loc)   | SEXOPAC %in% input$sexo_loc,
          is.null(input$etnia_loc)  | RACACOR %in% input$etnia_loc,
          is.null(input$ano_loc)  | ano %in% input$ano_loc
        )
    )
    
    valueBox(
      format(total_atend, big.mark = "."),
      "Total de Atendimentos",
      icon = icon("stethoscope"),
      color = "purple"
    )
  })
  
 
  output$box_total_pac_loc <- renderValueBox({
    total_pac <- n_distinct(
      pac %>%
        filter(
          is.null(input$estado_loc) | uf %in% input$estado_loc,
          is.null(input$sexo_loc)   | SEXOPAC %in% input$sexo_loc,
          is.null(input$etnia_loc)  | RACACOR %in% input$etnia_loc
        ) %>%
        filtro_ano_pac(input$ano_loc) %>%
        pull(CNS_PAC)
    )
    
    valueBox(
      format(total_pac, big.mark = "."),
      "Total de Pacientes",
      icon = icon("users"),
      color = "teal"
    )
  })
  
  
  ##### Procedimentos #####
  
  output$box_total_atend_proc <- renderValueBox({
    total_atend <- nrow(
      at %>%
        filter(
          is.null(input$estado_proc) | uf %in% input$estado_proc,
          is.null(input$municipio_proc) | nome %in% input$municipio_proc,
          is.null(input$sexo_proc)   | SEXOPAC %in% input$sexo_proc,
          is.null(input$cor_proc)    | RACACOR %in% input$cor_proc,
          is.null(input$ano_proc)  | ano %in% input$ano_proc
        )
    )
    
    valueBox(
      format(total_atend, big.mark = "."),
      "Total de Atendimentos",
      icon = icon("stethoscope"),
      color = "purple"
    )
  })
  
 
  output$box_total_pac_proc <- renderValueBox({
    total_pac <- n_distinct(
      pac %>%
        filter(
          is.null(input$estado_proc) | uf %in% input$estado_proc,
          is.null(input$municipio_proc) | nome %in% input$municipio_proc,
          is.null(input$sexo_proc)   | SEXOPAC %in% input$sexo_proc,
          is.null(input$cor_proc)    | RACACOR %in% input$cor_proc
        ) %>%
        filtro_ano_pac(input$ano_proc) %>%
        pull(CNS_PAC)
    )
    
    valueBox(
      format(total_pac, big.mark = "."),
      "Total de Pacientes",
      icon = icon("users"),
      color = "teal"
    )
  })
  
  
  ##### Situações #####
  output$box_total_atend_sit <- renderValueBox({
    total_atend <- nrow(
      at %>%
        filter(
          is.null(input$estado_sit) | uf %in% input$estado_sit,
          is.null(input$municipio_sit) | nome %in% input$municipio_sit,
          is.null(input$sexo_sit)   | SEXOPAC %in% input$sexo_sit,
          is.null(input$cor_sit)    | RACACOR %in% input$cor_sit,
          is.null(input$ano_sit)  | ano %in% input$ano_sit
        )
    )
    
    valueBox(
      format(total_atend, big.mark = "."),
      "Total de Atendimentos",
      icon = icon("stethoscope"),
      color = "purple"
    )
  })
  
 
  output$box_total_pac_sit <- renderValueBox({
    total_pac <- n_distinct(
      pac %>%
        filter(
          is.null(input$estado_sit) | uf %in% input$estado_sit,
          is.null(input$municipio_sit) | nome %in% input$municipio_sit,
          is.null(input$sexo_sit)   | SEXOPAC %in% input$sexo_sit,
          is.null(input$cor_sit)    | RACACOR %in% input$cor_sit
        ) %>%
        filtro_ano_pac(input$ano_sit) %>%
        pull(CNS_PAC)
    )
    
    valueBox(
      format(total_pac, big.mark = "."),
      "Total de Pacientes",
      icon = icon("users"),
      color = "teal"
    )
  })
  
  
  ##### Cid #####
  output$box_total_atend_cid <- renderValueBox({
    total_atend <- nrow(
      at %>%
        filter(
          is.null(input$estado_cid) | uf %in% input$estado_cid,
          is.null(input$municipio_cid) | nome %in% input$municipio_cid,
          is.null(input$sexo_cid)   | SEXOPAC %in% input$sexo_cid,
          is.null(input$cor_cid)    | RACACOR %in% input$cor_cid
        )
    )
    
    valueBox(
      format(total_atend, big.mark = "."),
      "Total de Atendimentos",
      icon = icon("stethoscope"),
      color = "purple"
    )
  })
  
 
  output$box_total_pac_cid <- renderValueBox({
    total_pac <- n_distinct(
      pac %>%
        filter(
          is.null(input$estado_cid) | uf %in% input$estado_cid,
          is.null(input$municipio_cid) | nome %in% input$municipio_cid,
          is.null(input$sexo_cid)   | SEXOPAC %in% input$sexo_cid,
          is.null(input$cor_cid)    | RACACOR %in% input$cor_cid
        ) %>%
        pull(CNS_PAC)
    )
    
    valueBox(
      format(total_pac, big.mark = "."),
      "Total de Pacientes",
      icon = icon("users"),
      color = "teal"
    )
  })
  
  
  ##### Temporal #####
  output$box_total_atend_temp <- renderValueBox({
    total_atend <- nrow(
      at %>%
        filter(
          is.null(input$estado_temporal) | uf %in% input$estado_temporal
        )
    )
    
    valueBox(
      format(total_atend, big.mark = "."),
      "Total de Atendimentos",
      icon = icon("stethoscope"),
      color = "purple"
    )
  })
  
  
  output$box_total_pac_temp <- renderValueBox({
    total_pac <- n_distinct(
      pac %>%
        filter(
          is.null(input$estado_temporal) | uf %in% input$estado_temporal
        ) %>%
        pull(CNS_PAC)
    )
    
    valueBox(
      format(total_pac, big.mark = "."),
      "Total de Pacientes",
      icon = icon("users"),
      color = "teal"
    )
  })
  
  
  
  
  
  
  
#----GRÁFICOS-----
  
  ##### Gênero #####
  output$plot_sexo <- renderPlot({
    dados <- dados_demografia() %>%
      count(SEXOPAC) %>%
      mutate(pct = n / sum(n) * 100,
             label = paste0(SEXOPAC, " (", round(pct,1), "%)"))
    
    ggplot(dados, aes(x=2, y=n, fill=SEXOPAC)) +
      geom_col() +
      coord_polar(theta="y") +
      xlim(0.5,2.5) +
      theme_void() +
      geom_text(aes(label=label), position=position_stack(vjust=0.5)) +
      labs(title="Distribuição por Sexo") +
      theme(legend.position="none")
  })
  
  
  ##### Etnia #####
  output$plot_etnia <- renderPlot({
    dados <- dados_demografia() %>%
      count(RACACOR) %>%
      mutate(pct = n / sum(n) * 100,
             label = paste0(RACACOR, " (", round(pct,1), "%)"))
    
    ggplot(dados, aes(x=2, y=n, fill=RACACOR)) +
      geom_col(width=1, color="white") +
      coord_polar(theta="y", start = pi/3) +
      xlim(0.5,2.5) +
      scale_fill_manual(values=c(
        "Branca"="#1f77b4","Preta"="#ff7f0e","Parda"="#2ca02c",
        "Amarela"="#d62728","Indígena"="#9467bd","Outra"="#8c564b"
      )) +
      theme_void() +
      geom_text(aes(label=label), position=position_stack(vjust=0.5)) +
      labs(title="Distribuição por Etnia") +
      theme(legend.position="right")
  })
  
  
  ##### Etnia Base #####
output$plot_etnia_brasil <- renderPlot({
  dados_brasil <- tibble(
    RACACOR = c("Branca", "Parda", "Preta", "Indígena", "Amarela"),
    Percentual = c(43.46, 45.34, 10.17, 0.6, 0.42)
  )
  
  ggplot(dados_brasil, aes(x = 2, y = Percentual, fill = RACACOR)) +
    geom_col(width = 1, color = "white") +
    coord_polar(theta = "y", start = pi/3) +
    xlim(0.5, 2.5) +
    scale_fill_manual(values = c(
      "Branca" = "#1f77b4",
      "Preta" = "#ff7f0e",
      "Parda" = "#2ca02c",
      "Amarela" = "#d62728",
      "Indígena" = "#9467bd"
    )) +
    theme_void() +
    geom_text(aes(label = paste0(round(Percentual, 2), "%")),
              position = position_stack(vjust = 0.5),
              size = 5) +
    labs(title = "Distribuição por Etnia no Brasil (IBGE 2022)") +
    theme(legend.position = "right")
})
  
  
  ##### Gênero Base #####
  output$plot_sexo_brasil <- renderPlot({
    dados_brasil <- tibble(
      Sexo = c("Feminino", "Masculino"),
      Percentual = c(51.48, 48.52)
    )
    
    ggplot(dados_brasil, aes(x = 2, y = Percentual, fill = Sexo)) +
      geom_col(width = 1, color = "white") +
      coord_polar(theta = "y") +
      xlim(0.5, 2.5) +
      theme_void() +
      geom_text(aes(label = paste0(round(Percentual, 1), "%")), 
                position = position_stack(vjust = 0.5),
                size = 5) +
      #scale_fill_manual(values = c("Feminino" = "#E377C2", "Masculino" = "#1F77B4")) +
      labs(title = "Distribuição por Sexo - Brasil (IBGE 2022)") +
      theme(legend.position = "right")
  })
  
  
  ##### Idade #####
  output$plot_idade <- renderPlot({
    dados <- dados_demografia() %>%
      mutate(
        IDADEPAC = as.numeric(IDADEPAC),
        faixa_idade = case_when(
          IDADEPAC < 5  ~ "0-4",
          IDADEPAC < 10 ~ "5-9",
          IDADEPAC < 15 ~ "10-14",
          IDADEPAC < 20 ~ "15-19",
          IDADEPAC < 25 ~ "20-24",
          IDADEPAC < 30 ~ "25-29",
          IDADEPAC < 35 ~ "30-34",
          IDADEPAC < 40 ~ "35-39",
          IDADEPAC < 45 ~ "40-44",
          IDADEPAC < 50 ~ "45-49",
          TRUE ~ "50+"
        ),
        faixa_idade = factor(
          faixa_idade,
          levels = c("0-4", "5-9", "10-14", "15-19", "20-24",
                     "25-29", "30-34", "35-39", "40-44", "45-49", "50+")
        )
      )
    
    ggplot(dados, aes(x = faixa_idade)) +
      geom_bar(fill = "purple") +
      labs(title = "Distribuição de Idade", x = "Faixa etária", y = "Frequência")
  })
  
  
  ##### Atendimentos por Estado #####
  output$plot_estado <- renderPlot({
    ggplot(dados_atendimentos_por_estado(), aes(x=uf)) +
      geom_bar(fill="orange") +
      labs(title="Atendimentos por Estado", x="Estado", y="N atendimentos")
  })
  
  
  ##### Top Municípios #####
  output$plot_municipio <- renderPlot({
    dados <- dados_localizacao()
    
    if (input$tipo_dado_loc == "Pacientes") {
      top_mun <- dados %>%
        count(MUNPAC, nome, sort = TRUE) %>%
        head(20)
    } else {
      top_mun <- dados %>%
        count(UFMUN, nome, sort = TRUE) %>%
        head(20)
    }
    
    ggplot(top_mun, aes(x = reorder(nome, n), y = n)) +
      geom_col(fill = "red") +
      coord_flip() +
      labs(
        title = "Top 20 Municípios com mais atendimentos/pacientes",
        x = "Município",
        y = "Nº de atendimentos/pacientes"
      )
  })
  
  ##### Scatterplot #####
  output$plot_scatter <- renderPlot({
    dados <- reactive({
      dados_scatterplot %>%
        filter(!is.na(pop), !is.na(qtd_atendimentos), pop > 0, qtd_atendimentos > 0) %>%
        mutate(
          x = log10(pop),
          y = log10(qtd_atendimentos)
        )
    })
    
    output$plot_scatter <- renderPlotly({
      df <- dados()
      
      # Regressão linear no espaço log-log
      modelo <- lm(y ~ x, data = df)
      a <- coef(modelo)[2]
      b <- coef(modelo)[1]
      
      # Densidade bivariada
      k <- kde2d(df$x, df$y, n = 100)
      dens <- expand.grid(x = k$x, y = k$y)
      dens$z <- as.vector(k$z)
      
      # Adiciona destaque se a cidade estiver na busca
      df$highlight <- ifelse(tolower(df$nome) == tolower(input$search_city_scatter), "Sim", "Não")
      
      p <- ggplot() +
        geom_point(data = df, aes(x = x, y = y, color = highlight, text = nome),
                   alpha = 0.5, size = 2) +
        scale_color_manual(values = c("Sim" = "red", "Não" = "blue")) +
        geom_contour(data = dens, aes(x = x, y = y, z = z), color = "black", linewidth = 0.8) +
        geom_abline(intercept = b, slope = a, color = "darkgreen", linewidth = 1) +
        labs(
          title = "Distribuição de Atendimentos vs População dos Municípios",
          subtitle = sprintf("Reta de tendência: y = %.2f·x + %.2f", a, b),
          x = "log10(População)",
          y = "log10(Atendimentos)"
        ) +
        theme_minimal(base_size = 13) +
        theme(legend.position = "none")
      
      ggplotly(p, tooltip = "text")
    })
  })
  
  
  ##### Situação de Rua #####
  output$plot_rua <- renderPlot({
    ggplot(dados_situacoes(), aes(x=SIT_RUA)) +
      geom_bar(fill="brown") +
      labs(title="Pacientes em Situação de Rua", x="Situação", y="N atendimentos")
  })
  
  
  ###### Uso de Drogas #####
  output$plot_drogas <- renderPlot({
    ggplot(dados_situacoes(), aes(x=TP_DROGA)) +
      geom_bar(fill="pink") +
      labs(title="Pacientes Usuários de Drogas", x="Droga", y="N atendimentos")
  })
  
  
  
  ##### Procedimentos #####
 
  output$plot_top_proc <- renderPlot({
    todos_proc <- dados_proc() %>%
      filter(!is.na(PA_PROC_ID) & PA_PROC_ID != "") %>%  # opcional: remove nulos ou vazios
      count(PA_PROC_ID, sort = TRUE) %>%
      # junta com a tabela de códigos
      left_join(tabela_procs, by = c("PA_PROC_ID" = "codigo")) %>%
      # usa o nome do procedimento, e se não existir, mostra o código
      mutate(procedimento = ifelse(is.na(procedimento), as.character(PA_PROC_ID), procedimento))
    
    ggplot(todos_proc, aes(x=reorder(procedimento, n), y=n)) +
      geom_col(fill="cyan") +
      coord_flip() +
      labs(title="Distribuição de Procedimentos", x="Procedimento", y="N atendimentos")
  })
  
  
  ##### CID Primária #####
  output$plot_cidpri <- renderPlot({
    top_cidpri <- dados_cid() %>% count(CIDPRI, sort=TRUE) %>% head(15)
    ggplot(top_cidpri, aes(x=reorder(CIDPRI,n), y=n)) +
      geom_col(fill="navy") +
      coord_flip() +
      labs(title="CID Primária mais Frequente", x="CID", y="N atendimentos")
  })
  
  
  ##### CID Secundária #####
  output$plot_cidassoc <- renderPlot({
    top_cidassoc <- dados_cid() %>%
      filter(!is.na(CIDASSOC) & CIDASSOC != "") %>%
      count(CIDASSOC, sort = TRUE) %>%
      head(15)
    ggplot(top_cidassoc, aes(x=reorder(CIDASSOC,n), y=n)) +
      geom_col(fill="darkred") +
      coord_flip() +
      labs(title="CID Secundária mais Frequente", x="CID", y="N atendimentos")
  })
  
  
  ##### Ano de Início #####
  output$plot_inicio <- renderPlot({
    
    dados_filtrados <- dados_temporal() %>%
      mutate(ano_inicio = as.integer(substr(DT_INICIO, 1, 4))) %>%
      filter(!is.na(ano_inicio) & ano_inicio >= 2013)
    
    ggplot(dados_filtrados, aes(x = factor(ano_inicio))) +
      geom_bar(fill = "gold") +
      labs(title = "Ano de Início de Tratamento (a partir de 2013)", 
           x = "Ano", y = "N atendimentos")
  })
  
  
  ##### Ano de Fim #####
  output$plot_fim <- renderPlot({
    dados_fim <- dados_temporal_atend() %>%
      filter(!is.na(DT_FIM) & DT_FIM != "")
    
    ggplot(dados_fim, aes(x = as.factor(substr(DT_FIM,1,4)))) +
      geom_bar(fill = "gray") +
      labs(title = "Ano de Fim de Tratamento", x = "Ano", y = "N atendimentos")
    
  })
  
  
  ###### Atendimentos por Ano #####
  output$plot_atendimentos <- renderPlot({
    ggplot(dados_temporal_atend(), aes(x = as.factor(ano))) +
      geom_bar(fill = "darkviolet") +
      scale_y_continuous(labels = scales::label_comma()) +
      labs(
        title = "Atendimentos por Ano",
        x = "Ano",
        y = "N atendimentos"
      )
  })
  
  ##### Total Estado #####
  total_atendimentos_estado <- at %>%
    group_by(uf) %>%
    summarise(total_atendimentos = n(), .groups = "drop")
  
  
  ##### Tabela estadual #####
  output$tabela_estado <- renderDT({
    
    dados <- dados_estado() %>%
      mutate(IDADEPAC = pmax(IDADEPAC, 1, na.rm = TRUE))  # pacientes ou atendimentos filtrados
    
    tabela <- dados %>%
      group_by(uf) %>%
      summarise(
        total_pacientes = n_distinct(CNS_PAC),
        media_idade = round(mean(IDADEPAC, na.rm=TRUE),1),
        homens = sum(SEXOPAC=="M", na.rm=TRUE),
        mulheres = sum(SEXOPAC=="F", na.rm=TRUE),
        branca = sum(RACACOR=="Branca", na.rm=TRUE),
        preta = sum(RACACOR=="Preta", na.rm=TRUE),
        parda = sum(RACACOR=="Parda", na.rm=TRUE),
        amarela = sum(RACACOR=="Amarela", na.rm=TRUE),
        indigena = sum(RACACOR=="Indígena", na.rm=TRUE),
        outra = sum(RACACOR=="Outra", na.rm=TRUE),
        rua = sum(SIT_RUA=="S", na.rm=TRUE),
        drogas = sum(TP_DROGA=="S", na.rm=TRUE),
        .groups="drop"
      ) %>%
      left_join(total_atendimentos_estado, by="uf") %>%  # junta o total de atendimentos
      mutate(media_atendimentos_por_paciente = round(total_atendimentos / total_pacientes,2)) %>%
      # reorganiza colunas
      dplyr::select(uf, total_pacientes, total_atendimentos, media_atendimentos_por_paciente, everything()) %>%
      rename(
        Estado = uf,
        `Total de atendimentos` = total_atendimentos,
        `Total de pacientes` = total_pacientes,
        `Média de atendimentos por paciente` = media_atendimentos_por_paciente,
        `Média da idade dos pacientes` = media_idade,
        Homens = homens,
        Mulheres = mulheres,
        Branca = branca,
        Preta = preta,
        Parda = parda,
        Amarela = amarela,
        Indígena = indigena,
        Outra = outra,
        `Situação de Rua` = rua,
        `Usuários de Drogas` = drogas
      )
    
    datatable(tabela, rownames=FALSE, options=list(pageLength=10, scrollX=TRUE))
  })
  
  
  ##### Total Municípios #####
  total_atendimentos_municipio <- at %>%
    group_by(UFMUN) %>%
    summarise(total_atendimentos = n(), .groups = "drop")
  
  
  ##### Tabela Municipal #####
  output$tabela_municipio <- renderDT({
    
    dados <- dados_municipio() %>%
      mutate(IDADEPAC = pmax(IDADEPAC, 1, na.rm = TRUE))  # pacientes ou atendimentos filtrados
    
    tabela <- dados %>%
      group_by(UFMUN) %>%
      summarise(
        nome_municipio = first(nome),  # pega o primeiro nome (único por código)
        total_pacientes = n_distinct(CNS_PAC),
        media_idade = round(mean(IDADEPAC, na.rm=TRUE), 1),
        homens = sum(SEXOPAC == "M", na.rm = TRUE),
        mulheres = sum(SEXOPAC == "F", na.rm = TRUE),
        branca = sum(RACACOR == "Branca", na.rm = TRUE),
        preta = sum(RACACOR == "Preta", na.rm = TRUE),
        parda = sum(RACACOR == "Parda", na.rm = TRUE),
        amarela = sum(RACACOR == "Amarela", na.rm = TRUE),
        indigena = sum(RACACOR == "Indígena", na.rm = TRUE),
        outra = sum(RACACOR == "Outra", na.rm = TRUE),
        rua = sum(SIT_RUA == "S", na.rm = TRUE),
        drogas = sum(TP_DROGA == "S", na.rm = TRUE),
        .groups = "drop"
      ) %>%
      left_join(total_atendimentos_municipio, by = "UFMUN") %>%  # junta o total de atendimentos
      mutate(media_atendimentos_por_paciente = round(total_atendimentos / total_pacientes, 2)) %>%
      dplyr::select(UFMUN, nome_municipio, total_pacientes, total_atendimentos, media_atendimentos_por_paciente, everything()) %>%
      rename(
        'Código do Município' = UFMUN,
        Nome = nome_municipio,
        `Total de atendimentos` = total_atendimentos,
        `Total de pacientes` = total_pacientes,
        `Média de atendimentos por paciente` = media_atendimentos_por_paciente,
        `Média da idade dos pacientes` = media_idade,
        Homens = homens,
        Mulheres = mulheres,
        Branca = branca,
        Preta = preta,
        Parda = parda,
        Amarela = amarela,
        Indígena = indigena,
        Outra = outra,
        `Situação de Rua` = rua,
        `Usuários de Drogas` = drogas
      )
    
    datatable(tabela, rownames = FALSE, options = list(pageLength = 10, scrollX = TRUE))
  })
}

# Rodar o app
shinyApp(ui = ui, server = server)

library(shiny)
library(shinythemes)
library(data.table)
library(ggmap)
library(xml2)
library("png")

ui <- fluidPage(
  includeCSS("styles.css"),
  navbarPage("Analiza danych NYC Bike Share", header=tags$head(includeCSS("styles.css")) ,
             tabPanel("Ogólne",
                      sidebarLayout(
                        sidebarPanel(h2("Informacje ogólne"), width = 0),
                        mainPanel(
                          h2("Liczba wypożyczeń w ciągu roku - 20.551.697"),
                          h2("Liczba wszystkich używanych rówerów - 19.571"),
                          h2("Liczba wszystkich stacji ~ 1.000"),
                          br(),
                          h3("Wypożyczenia w poszczególnych miesiącach."),
                          plotOutput("Wypozyczone_rowery")
                          
                        )
                        )
                      ),
             tabPanel("Kto więcej wypożycza?",
                      sidebarLayout(
                        sidebarPanel(
                         
                         checkboxGroupInput(inputId = "plec", label = "Wybierz płeć użytkownika", 
                                            choices = c("Brak danych", "Mężczyzna", "Kobieta"), selected = c("Brak danych", "Mężczyzna", "Kobieta")),
                         checkboxGroupInput(inputId = "sub", label = "Wybierz typ subskrypcji",
                                            choices = c("Subscriber", "Customer"), selected = c("Subscriber", "Customer") )
                        ),
                        mainPanel(
                          plotOutput("sub_vs_cust"),
                          plotOutput("age_and_gender")
                        )
                        
                      )
             ),
             tabPanel("Długość podróży",
                      sidebarLayout(
                        sidebarPanel(
                          checkboxGroupInput(inputId = "btns", label = "Wybierz długość podróży",
                                       choices = c("bardzo krótka - 0 - 15 min"=1, "krótka - 15 - 30 min" = 2,
                                                   "średnia - 30 - 45 min"=3, "długa - ponad 45 min"=4), selected = c(1,2,3,4))
                        ),
                        mainPanel(
                          plotOutput("dlPodrozy", width = "100%"),
                          plotOutput("barPlotDlPodrozy")
                        )
                      )),
             tabPanel("Zagęszczenie ruchu na stacjach",
                      sidebarLayout(
                        sidebarPanel(
                        ),
                        mainPanel(
                          imageOutput("stacje")
                        )
                      )),
             tabPanel("Dojazdy do pracy",
                      sidebarLayout(
                        sidebarPanel(
                        ),
                        mainPanel(
                          imageOutput("rano")
                        )
                      )),
              tabPanel("Powroty z pracy",
                       sidebarLayout(
                         sidebarPanel(
                         ),
                         mainPanel(
                           imageOutput("wieczor")
                         )
                       )),
             tabPanel("Weekendy czy dni powszednie?",
                      sidebarLayout(
                        
                        sidebarPanel(
                          p("Profil użytkownika"),
                          sliderInput("mies", "Miesiące", 
                                      min = 1, max = 12, value = c(1,12)
                          ),
                          checkboxGroupInput(inputId = "stud", label = "Wybierz status użytkownika", 
                                             choices = c("Młodzież i studenci", "Pozostali użytkownicy"), selected = c("Młodzież i studenci", "Pozostali użytkownicy")
                          ),
                          checkboxGroupInput(inputId = "typ", label = "Wybierz typ subskrypcji",
                                             choices = c("Subscribers", "Customers"), selected =c("Subscribers", "Customers") 
                          )
                          
                          
                        ),
                        mainPanel(
                          plotOutput("ruch_weekendy"),
                          plotOutput("ruch_godzinowo")
                          
                        )
                      )
                      
             ),
             tabPanel("Miejsca turystyczne",
                      sidebarLayout(
                        sidebarPanel(),
                        mainPanel(
                          imageOutput("turysci")
                        )
                      )),
             tabPanel("Rozmieszczenie szkół",
                      sidebarLayout(
                        sidebarPanel(),
                        mainPanel(
                          imageOutput("studenci")
                        )
                      ))
  ))
  



server <- function(input, output) {
  library(data.table)
  library(readr)
  library(ggplot2)
  library(gridExtra)
  
  
  #output$favorite_routes <- renderPlot({
  #})
  
  output$sub_vs_cust <- renderPlot({
    df <- read_csv(file = "przeliczone_dane/sub_vs_customers.csv")
    ggplot(data=df, aes(x = usertype, y=N, fill=as.factor(N))) +
      geom_bar(stat="identity") +
      scale_fill_manual(values=c("#6a040f", "#e85d04")) +
      theme(legend.position = "none") +
      xlab("Typ użytkownika") +
      ggtitle("Liczba wypożyczeń z uwagi na typ użytkownika w skali roku") +
      theme(plot.title =element_text(size = 18, face  ="bold", margin = margin(10,0,10,0)), 
            axis.text.x = element_text(size = 14, vjust = 0.5),
            axis.title = element_text(size = 15, face = "bold", color = "#03071e"))
  
  })
  
  output$dlPodrozy <- renderPlot({
    trips_hours <- read_csv("przeliczone_dane/tripduration_over_hours.csv")
    dt <- data.table(NULL)
    print(input$btns[1])
      for (i in 1: length(input$btns)) {
        for (j in 1:4) {
          if (input$btns[i] == j) {
            if (j == 1) {
              data <- data.table(hour=c(1:24),trips_hours[,"0-15min.N"])
              setnames(data, new="N", old = "0-15min.N")
              data <- data[,`długość podróży`:="1. bardzo krótka"]
              dt <- rbind(dt,data)
            }
            else if (j == 2) {
              data <- data.table(hour=c(1:24),trips_hours[,"15-30min.N"])
              setnames(data, new="N", old = "15-30min.N")
              data <- data[,`długość podróży`:="2. krótka"]
              dt <- rbind(dt, data, use.names=FALSE )
            }
            else if (j == 3) {
              data <- data.table(hour=c(1:24),trips_hours[,"30-45min.N"])
              setnames(data, new="N", old = "30-45min.N")
              data <- data[,`długość podróży`:="3. średnia"]
              dt <- rbind(dt, data, use.names=FALSE )
            }
            else {
              data <- data.table(hour=c(1:24),trips_hours[,"over 45min.N"])
              setnames(data, new="N", old = "over 45min.N")
              data <- data[,`długość podróży`:="4. długa"]
              dt <- rbind(dt, data, use.names=FALSE )
            }
          }
        }
      }
    
    if (dim(dt) != 0) {
      ggplot(data=dt,aes(x=hour, y = `długość podróży`, color = `długość podróży`, size=N)) +
        geom_point(alpha=0.5) +
        scale_size( name="Liczba wypożyczeń (N)", range = c(1,12)) +
        ggtitle("Długość podróży w poszczególnych godzinach.(czerwiec - wrzesień)")
    }
    
  })
  
  output$barPlotDlPodrozy <- renderPlot({
    dane <- read.csv("ile_podrozy_okreslonej_dl.csv")
    plot_1 <- ggplot(data=dane,aes(x = `typ.podrozy`, y = N, fill = as.factor(N))) +
      geom_bar(stat="identity", width = 0.4) +
      scale_fill_manual(values=c("#05668d", "#028090", "#00a896", "#02c39a" )) +
      theme(legend.position = "none") +
      xlab("Typ podróży") +
      ggtitle("Liczba podróży danej długości(czerwiec - wrzesień)")+
      theme(plot.title =element_text(size = 16, face  ="bold", margin = margin(10,0,10,0)), 
            axis.text.x = element_text(size = 14, vjust = 0.5),
            axis.title = element_text(size = 14, face = "bold", color = "#03071e"))
    
    czas_wypozyczenia <- read_csv("czas_wypozyczenia.csv")
    plot_2 <- ggplot(data=czas_wypozyczenia, aes(x= reorder(`miesiac`, c(1:12)), y=`srednia_dl`, fill = srednia_dl)) +
      geom_bar(stat="identity")+
      scale_fill_continuous(type = "gradient", low = "#00004d",
                            high = "#cc99ff")+
      scale_x_discrete(labels=c("STY", "LUT", "MAR", "KWI", "MAJ", "CZE", "LIP", "SIE", "WRZ", "PAZ", "LIS", "GRU"))+
      xlab("")+
      ylab("Średnia długość podróży [min]")+
      ggtitle("Średnia długość podróży w poszczególnych miesiącach")+
      theme(legend.position = "none",
            plot.title =element_text(size = 16, face  ="bold", margin = margin(10,0,10,0)), 
            axis.text.x = element_text(size = 14, vjust = 0.5),
            axis.title = element_text(size = 14, face = "bold", color = "#03071e"))
    
    grid.arrange(plot_1, plot_2, ncol=2)
  })
  
  output$stacje <- renderImage({
    list(src = "plots/zageszczenie_ruchu_ogolnie.png")
    }, 
    deleteFile = FALSE
  )
  
  output$rano <- renderImage({
    
    list(src = "plots/zageszczenie_ruchu_rano.png")
  }, 
    deleteFile = FALSE
  )
  
  output$wieczor <- renderImage({
    list(src = "plots/zageszczenie_ruchu_wieczor.png")
  }, 
  deleteFile = FALSE
  )
  
  output$Wypozyczone_rowery <- renderPlot({
    ruch <- read_csv("ruch.csv")
    ggplot(ruch, aes(x = reorder(`miesiace`, c(1:12)), y = liczba_rowerow, fill = liczba_rowerow))+
      geom_bar(stat = "identity")+
      #ggtitle("Liczba wypożyczonych rowerów w ciągu roku")+
      ylab("Liczba wypożyczonych rowerów [szt]")+
      xlab("")+
      scale_x_discrete(labels=c("STY", "LUT", "MAR", "KWI", "MAJ", "CZE", "LIP", "SIE", "WRZ", "PAZ", "LIS", "GRU"))
    
  })
  output$age_and_gender <- renderPlot({
    age_and_gender <- read_csv("Age_and_gender.csv")
    paleta = c("#1B9E77", "#D95F02", "#7570B3")
    if( !("Brak danych" %in% input$plec)){
      age_and_gender <- age_and_gender[age_and_gender$gender != 0,]
      paleta <- c("#D95F02", "#7570B3")
    }
    if( !("Kobieta" %in% input$plec)){
      age_and_gender <- age_and_gender[age_and_gender$gender != 2,]
      paleta = c("#D95F02", "#1B9E77")
    }
    if( !("Mężczyzna" %in% input$plec)){
      age_and_gender <- age_and_gender[age_and_gender$gender != 1,]
      paleta = c("#7570B3", "#1B9E77")
    }
    if( !("Subscriber" %in% input$sub)){
      age_and_gender <- age_and_gender[age_and_gender$usertype != "Subscriber",]
    }
    if( !("Customer" %in% input$sub)){
      age_and_gender <- age_and_gender[age_and_gender$usertype != "Customer",]
    }
    
    ggplot(data=age_and_gender, aes(x=`rok urodzenia`, y=`liczba osob`, fill = as.factor(gender))) +
      geom_bar(stat="identity")+
      geom_text(aes(y=0, label=10), vjust=1.6, 
                color="white", size=3.5)+
      scale_fill_manual(values = paleta, name = "Płeć", labels = c(input$plec) )+
      ggtitle("Chrarakterystyka użytkowników")+
      ylab("Liczba osób") + 
      theme(plot.title =element_text(size = 18, face  ="bold", margin = margin(10,0,10,0)))
  })
  
  #output$Srednia_dl_podrozy <- renderPlot({
  #})
  output$ruch_weekendy <- renderPlot({
    weekend_vs_zwykly <- read_csv("weekend_vs_zwykly.csv")
    
    ggplot(weekend_vs_zwykly, aes(x=as.Date(tydzien), y=srednia, group=weekend, colour=weekend)) +
      geom_point()+
      geom_line(size = 1)+
      ggtitle("Średnia ilość wypożyczeń w ciągu dnia w kolejnych tygodniach")+
      scale_colour_brewer(palette = "Set1", name = "", labels = c("Dni powszednie", "Weekendy") )+
      ylab("Ilość wypożyczeń [szt]")+
      xlab("")+
      theme(plot.title =element_text(size = 16, face  ="bold", margin = margin(10,0,10,0)), 
            axis.text = element_text(size = 14, vjust = 0.5),
            axis.title = element_text(size = 14, face = "bold", color = "#03071e"))
      
  })
  output$ruch_godzinowo <- renderPlot({
    weekend_godzinowo <- read_csv("Weekend_godzinowo.csv")
    
    weekend_godzinowo <- weekend_godzinowo[weekend_godzinowo$month >= input$mies[1] & weekend_godzinowo$month <= max(input$mies), ]
    
    
    if( !("Młodzież i studenci" %in% input$stud)){
      weekend_godzinowo <- weekend_godzinowo[weekend_godzinowo$student == "FALSE",]
    }
    if( !("Pozostali użytkownicy" %in% input$stud)){
      weekend_godzinowo <- weekend_godzinowo[weekend_godzinowo$student == "TRUE",]
    }
    if( !("Subscribers" %in% input$typ)){
      weekend_godzinowo <- weekend_godzinowo[weekend_godzinowo$usertype != "Subscriber",]
    }
    if( !("Customers" %in% input$typ)){
      weekend_godzinowo <- weekend_godzinowo[weekend_godzinowo$usertype != "Customer",]
    }
    
    test <- as.data.table(tapply(weekend_godzinowo$liczba_tras, list(weekend_godzinowo$godzina, weekend_godzinowo$weekend), FUN = sum))
    test <- cbind(c(0:23), test)
    colnames(test) <- c("godzina", "powszedni", "weekend")
    
    
    plot1 <- ggplot(test, aes(x=godzina , y= powszedni, fill = powszedni)) +
      geom_bar(stat = "identity", alpha = 1, width = 0.7, position = position_dodge(width = 0.8))+
      ggtitle("Godziny wypożyczeń w dni powszednie")+
      scale_fill_continuous(low = "#001782", high = "#989898")+
      #scale_fill_manual(name = "", labels = c("Dni powszednie", "Weekendy"))+
      ylab("Ilość wypożyczeń [szt]")+
      xlab("")+
      theme(plot.title =element_text(size = 16, face  ="bold", margin = margin(10,0,10,0)), 
            axis.text.x = element_text(size = 14, vjust = 0.5),
            axis.title = element_text(size = 14, face = "bold", color = "#03071e"))
    
    
    plot2 <- ggplot(test, aes(x=godzina , y= weekend, fill = weekend)) +
      geom_bar(stat = "identity", alpha = 1, width = 0.7, position = position_dodge(width = 0.8))+
      ggtitle("Godziny wypożyczeń w weekendy")+
      scale_fill_continuous(low = "#800000", high = "#009c0d")+
      #scale_fill_manual(name = "", labels = c("Dni powszednie", "Weekendy"))+
      ylab("Ilość wypożyczeń [szt]")+
      xlab("")+
      theme(plot.title =element_text(size = 16, face  ="bold", margin = margin(10,0,10,0)), 
            axis.text.x = element_text(size = 14, vjust = 0.5),
            axis.title = element_text(size = 14, face = "bold", color = "#03071e"))

    
    grid.arrange(plot1, plot2, ncol=2)
    
  })
  
  output$turysci <- renderImage({
    list(src = "plots/turysci_plot.png")
  }, 
  deleteFile = FALSE)
  
  output$studenci <- renderImage({
    list(src = "plots/students_plot.png")
  }, 
  deleteFile = FALSE)
  
}

shinyApp(ui = ui, server = server)
library(ggplot2)
library(data.table)
library(ggmap)
library(leaflet)
library(magrittr)


## generowanie wykresów

## Najczęstsze trasy
routes100 <- read.csv("przeliczone_dane/routes_to_plot_final.csv")
routes100 <- routes100[1:10,]
dt <- data.table(group = c("start", "end"),
                       startLat = routes100$start.latitude,
                      startLon = routes100$start.longitude,
                      endLat = routes100$end.latitude,
                      endLon = routes100$end.longitude,
                 stringsAsFactors = FALSE
                 )
dt_ready <- data.table(group =  c("start", "end"),
                       lat = c(dt$startLat, dt$endLat),
                       long = c(dt$startLon, dt$endLon))
leaflet()%>%
  addTiles() %>%
  addPolylines(data = dt_ready, lng = ~long, lat = ~lat, group = ~group)

## Wczytanie mapy ----
register_google(key = "API_KEY", write = TRUE)
nyc <- c(lon = -74.0059, lat = 40.74)
nyc_map <- get_map(nyc, zoom = 12, scale = 4)
map <- ggmap(nyc_map, extent = "device")

## Zagęszczenie ruchu ----
## Ogólnie ----
busyStations <- read_csv("przeliczone_dane/busy_stations.csv")

p1 <- map + geom_point(data= busyStations, aes(x=longitude, y=latitude, color=N), alpha=0.5, size = 1) + 
  scale_size(range=c(.1, 10)) +
  scale_color_gradient(low = "#ffba08", high = "#03071e") +
  ggtitle("Zagęszczenie ruchu na stacjach") + 
  labs(color = "Wypożyczone rowery na stacji") +
  theme(legend.title = element_text(size = 8 ))
  coord_equal(ratio=1)
ggsave("plots/zageszczenie_ruchu_ogolnie.png", plot = p1, width = 10, height = 10, units = "cm")
## Rano ----

morning <- read_csv("przeliczone_dane/end_stations_morning.csv")
p2 <- map + geom_point(data = morning, aes(x=longitude, y=latitude, color=N),alpha=0.4, size =1.25) + 
  scale_size(range=c(.1, 10)) +
  scale_color_gradient(low="orange", high="blue") +
  ggtitle("Stacje docelowe rano (7 - 10, pon - pt)") +
  labs(color = "Wypożyczone rowery na stacji") +
  theme(legend.title = element_text(size = 8 )) +
  coord_equal(ratio=1) 

ggsave("plots/zageszczenie_ruchu_rano.png", plot = p2, width = 10, height = 10, units = "cm")

## Wieczór ----

evening <- read_csv("przeliczone_dane/end_stations_evening.csv")
p3 <- map + geom_point(data = evening, aes(x=longitude, y=latitude, color=N),alpha=0.4, size = 1.25) + 
  scale_size(range=c(.1, 10)) +
  scale_color_gradient(low="orange", high="blue") +
  ggtitle("Stacje docelowe wieczorem (16 - 19, pon - pt)") +
  labs(color = "Wypożyczone rowery na stacji") +
  theme(legend.title = element_text(size = 8 )) +
  coord_equal(ratio=1)

ggsave("plots/zageszczenie_ruchu_wieczor.png", plot = p3, width = 10, height = 10, units = "cm")

## Turysci ----

Tourists <- data.table(read.csv("przeliczone_dane/polygon_tourists_map.csv"))

setnames(Tourists, old = c("end.station.latitude", "end.station.longitude"), new = c("latitude", "longitude"))

pTurysci <- map + stat_density2d(aes(x = longitude, y = latitude, fill = ..level..), alpha = 0.7,
                     size = 2, bins = 4, data = Tourists ,geom = "polygon") +
  scale_fill_viridis_c(direction = -1) + 
  ggtitle("Miejsca odwiedzane przez turystów") 

ggsave("plots/turysci_plot.png", plot = pTurysci, width = 7, height = 7, units = "cm")

## Uczniowie ----
Students_data <- data.table(read.csv("przeliczone_dane/student_routes.csv"))

pStudenci <- map + geom_point(data=Students_data, aes(x = `end.station.longitude`, y = `end.station.latitude`, size = N), alpha = 0.6, color = "blue") +
   ggtitle("Stacje docelowe osób 7-18 lat, w godzinach porannych(pon-pt)") +
  labs(size = "Liczba zwrotów") +
  theme(legend.title = element_text(size = 6 ), plot.title = element_text(size = 7)) 

ggsave("plots/students_plot.png", plot=pStudenci, width = 7, height = 7, units = "cm")

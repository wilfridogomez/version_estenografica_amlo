library(rvest)
library(tidyverse)
library(data.table)
library(stringr)


#Inicializamos una lista vacía para almacenar los enlaces
all_links <- list()

range=530

# Bucle para recorrer todas las páginas
for(i in 1:range) {
  # Construimos la URL de la página
  url <- paste0("https://lopezobrador.org.mx/secciones/comunicados/page/",i)
  
  # Leemos la página web
  web_page <- read_html(url)
  
  # Extraemos los enlaces dentro de elementos con la clase 'mi-clase'
  links <- web_page %>% 
    html_nodes(".entry-title a") %>% 
    html_attr("href")
  
  # Almacenamos los enlaces en la lista
  all_links[[i]] <- links
  
  # Pausa para ser respetuoso con el servidor (opcional)
  #Sys.sleep(1)
}

# Combinamos todos los enlaces en un único vector
all_links <- unlist(all_links)


# Inicializar un dataframe vacío para almacenar la información
all_data <- tibble(
  Title = character(),
  Author = character(),
  Author_Link = character(),
  Date_Published = character(),
  Text = character()
)

# Bucle para recorrer cada artículo y extraer información
for (link in all_links) {
  # Leer la página del artículo
  article_page <- read_html(link)
  
  # Extraer información del artículo
  title <- article_page %>% html_node(".entry-title") %>% html_text(trim = TRUE)
  author <- article_page %>% html_node(".entry-author") %>% html_text(trim = TRUE)
  author_link <- article_page %>% html_node(".entry-author a") %>% html_attr("href")
  date_published <- article_page %>% html_node(".entry-date") %>% html_text(trim = TRUE)
  
  # Extraer todas las etiquetas <p> dentro de .entry-content y concatenar su contenido con saltos de línea
  text <- article_page %>% html_nodes(".entry-content p") %>% html_text(trim = TRUE) %>% 
    paste(collapse = "\n\n")
  
  # Crear un dataframe para el artículo actual
  current_data <- tibble(
    Title = title,
    Author = author,
    Author_Link = author_link,
    Date_Published = date_published,
    Text = text,
  )
  
  # Añadir el dataframe del artículo actual al dataframe general
  all_data <- bind_rows(all_data, current_data)
  
  # Pausa opcional para ser cortés con el servidor
  #Sys.sleep(1)
}

filtered_data <- all_data %>%
  filter(str_detect(Title, "estenográfica"))


filtered_data |> write_csv("out/mañaneras.csv")

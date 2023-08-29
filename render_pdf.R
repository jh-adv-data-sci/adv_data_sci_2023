library(pagedown)
htmls = list.files(pattern = ".html", path = "slides", recursive = FALSE,
           full.names = TRUE)
sapply(htmls, pagedown::chrome_print)

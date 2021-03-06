# Ebooks gratuitos de la editorial Springer con R
# www.overfitting.net
# https://www.overfitting.net/2020/05/ebooks-gratuitos-de-springer-con-r.html

library(rvest)

iif = function(condicion, val1, val2) {
    if (condicion) return(val1)
    return(val2)
}


libros=read.csv("SpringerEbooks.csv", sep=";", stringsAsFactors=F)
N=nrow(libros)
failed=0L
cat("", file="download.log")

for (i in 1:N) {
    nombre=libros$BookTitle[i]
    for (char in c(".","/",",",":",";"," ","-","_","@","®")) {  # Camel case
        nombre=gsub(char, "", nombre, fixed=T)  # Permitimos & y ++ 
    }
    numero=paste0(iif(i<10, "00", iif(i<100, "0", "")), i)
    nombre=paste0(numero, "_", nombre, ".pdf")
    
    url=libros$OpenURL[i]  # Specifying URL for website to be scraped
    pagina=read_html(url)  # Reading the HTML code from the website
    
    enlace=html_nodes(pagina, xpath='//*[@id="main-content"]/article[1]/div/div/div[2]/div/div/a')
    if (length(enlace)==0) {  # No se ha encontrado enlace de solo PDF
        enlace=html_nodes(pagina, xpath='//*[@id="main-content"]/article[1]/div/div/div[2]/div/a')
        if (length(enlace)==0) {  # Tampoco se ha encontrado enlace PDF/Epub
            texto="FAILED - No free PDF/Epub available"
            failed=failed+1
        } else {
            texto="OK     - Both PDF/Epub available"        
        }
    } else {
        texto="OK     - Only PDF available"
    }
    
    if (length(enlace)>0) {
        enlace2=html_attr(enlace, "href")[1]  # Solo primer elemento (el PDF)
        base=gsub("/openurl.*", "", url)
        url_pdf=paste0(base, enlace2)
        download.file(url_pdf, destfile=nombre, mode='wb')
    }
    
    texto=paste0(i, ": ", texto, " for '", nombre, "'\n")
    cat(texto, file="download.log", append=T)
}

cat(paste0("\n", failed, " failed files out of ", N, "\n"),
    file="download.log", append=T)

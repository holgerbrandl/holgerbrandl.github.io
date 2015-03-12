#!/usr/bin/env Rscript


articleRmd=commandArgs(T)[1]

#articleRmd="2015-03-01-simple-elegant-caching-using-magrittr-and-quote.Rmd"

if(!file.exists(articleRmd)){
    stop(paste0("input rmd file '", articleRmd, "' does not exist"))
}

## see http://jfisher-usgs.github.io/r/2012/07/03/knitr-jekyll/
require(knitr)
require(stringr)


KnitPost <- function(input, base.url = "/") {
    opts_knit$set(base.url = base.url)
    fig.path <- file.path("figs", sub(".Rmd$", "", basename(input)))
    opts_chunk$set(fig.path = fig.path)
    opts_chunk$set(fig.cap = "center")
    opts_chunk$set(cache = F)

    render_jekyll()
#    render_jekyll(highlight="none")

    output.path=file.path("_posts", str_replace(basename(input), "Rmd", "md"))

    knit(input, output=output.path, envir = parent.frame())
}

KnitPost(articleRmd)
system("mv figs/* ../figs")


#knit2html("2015-03-01-simple-elegant-caching-using-magrittr-and-quote.Rmd", envir = parent.frame())

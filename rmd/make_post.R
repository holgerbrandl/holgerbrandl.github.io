## see http://jfisher-usgs.github.io/r/2012/07/03/knitr-jekyll/

require(knitr)
require(stringr)

baseDir<-"/Users/brandl/projects/holgerbrandl.github.io"

KnitPost <- function(input, base.url = "/") {
    opts_knit$set(base.url = base.url)
    fig.path <- file.path(baseDir, "figs", sub(".Rmd$", "", basename(input)))
    opts_chunk$set(fig.path = fig.path)
    opts_chunk$set(fig.cap = "center")

    render_jekyll(highlight="none")
#    render_jekyll(highlight="none")

    output.path=file.path(baseDir, "_posts", str_replace(basename(input), "Rmd", "md"))

    knit(input, output=output.path, envir = parent.frame())
}

KnitPost("2015-03-01-simple-elegant-caching-using-magrittr-and-quote.Rmd")


#knit2html("2015-03-01-simple-elegant-caching-using-magrittr-and-quote.Rmd", envir = parent.frame())

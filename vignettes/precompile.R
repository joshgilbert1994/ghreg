# The vignette fits Stan models, so it is knitted ahead of time: edit
# ghreg.Rmd.orig, then run this script from the package root.
devtools::load_all()
old <- setwd("vignettes")
knitr::knit("ghreg.Rmd.orig", "ghreg.Rmd")
setwd(old)

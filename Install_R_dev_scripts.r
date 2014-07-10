# load function to source additional functions form github
source_https <- function(url, ...) {
  require(RCurl)
  sapply(c(url, ...), function(u) {
    eval(parse(text = getURL(u, followlocation = TRUE, cainfo = system.file("CurlSSL", "cacert.pem", package = "RCurl"))), envir = .GlobalEnv)
  })
}

# function to produce raw pco
source_https("https://raw.githubusercontent.com/MG-RAST/AMETHST/master/plot_pco.r")
# MGRAST_plot_pco

# new function to render the raw pco with metadata
source_https("https://raw.githubusercontent.com/DrOppenheimer/matR-apps/master/plot_fun.12-10-13/pcoa/render_calculated_pcoa.dev.v3.r")
# render_pcoa.v3

# new function that applies DESeq based normalization (latest and greatest)
source_https("https://raw.githubusercontent.com/DrOppenheimer/matR-apps/master/normalize_fun.2-27-14/norm_redux.v4.r")
# MGRAST_preprocessing

# stats
source_https("https://raw.githubusercontent.com/DrOppenheimer/matR-apps/master/stats_fun.2-27-14/matR_stats_from_files.r")

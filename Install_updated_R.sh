#!/bin/bash
####################################################################################
### INSTALL UPDATED R ONLY - this version for 14.04 (trusty)
####################################################################################
# return non zero when it should
# echo "options(warn=2); install.packages('RColorBrewer', repos='http://cran.r-project.org')" | R --slave --vanilla
# https://github.com/qiime/qiime-deploy/issues/15

# To uninstall R
# sudo apt-get remove r-base-core


####################################################################################
### Simplified version
####################################################################################
export http_proxy=http://cloud-proxy:3128
export https_proxy=ftp://cloud-proxy:3128
export ftp_proxy=ftp://cloud-proxy:3128

sudo bash << EOFSHELL
echo 'deb http://cran.cnr.Berkeley.edu/bin/linux/ubuntu precise/' >> /etc/apt/sources.list 
echo 'deb http://cran.cnr.Berkeley.edu/bin/linux/ubuntu trusty/' >> /etc/apt/sources.list 
EOFSHELL

sudo -E apt-add-repository ppa:marutter/rrutter; sudo -E apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E084DAB9
sudo apt-get update
sudo apt-get -y install xserver-xorg-dev libcurl4-openssl-dev libxml2-dev libx11-dev freeglut3 freeglut3-dev
sudo apt-get install -y --force-yes r-base
####################################################################################


# ### Install as root
# #sudo bash << EOFSHELL
# ### Install Curl
# # sudo apt-get remove r-base-core
# #sudo apt-get -y update
# #sudo apt-get -y install xserver-xorg-dev libcurl4-openssl-dev libxml2-dev libx11-dev freeglut3 freeglut3-dev
# ### add cran public key # this makes it possible to install most current R below
# sudo bash << EOFSHELL
# echo 'deb http://cran.cnr.Berkeley.edu/bin/linux/ubuntu precise/' >> /etc/apt/sources.list 
# echo 'deb http://cran.cnr.Berkeley.edu/bin/linux/ubuntu trusty/' >> /etc/apt/sources.list 
# EOFSHELL
# #sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E084DAB9

# ### to get the key with a proxy you may have to do something like this
# # sudo bash << EOFSHELL
# # export http_proxy=http://cloud-proxy:3128; export https_proxy=http://cloud-proxy:3128; sudo -E apt-add-repository ppa:marutter/rrutter
# # EOFSHELL

# http_proxy=http://cloud-proxy:3128 export https_proxy=http://cloud-proxy:3128; sudo -E apt-add-repository ppa:marutter/rrutter; sudo -E apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E084DAB9


# #sudo add-apt-repository ppa:marutter/rdev
# sudo apt-get update
# sudo apt-get -y install xserver-xorg-dev libcurl4-openssl-dev libxml2-dev libx11-dev freeglut3 freeglut3-dev
# sudo apt-get install -y --force-yes r-base

# ### for qiime install later, uncomment the universe and multiverse repositories from /etc/apt/sources.list
# #sudo echo deb http://cran.rstudio.com/bin/linux/ubuntu trusty/ >> /etc/apt/sources.list
# #sudo sed -e '/verse$/s/^#\{1,\}//' /etc/apt/sources.list > /etc/apt/sources.list.edit; mv /etc/apt/sources.list.edit /etc/apt/sources.list
# #EOFSHELL
# ### upgrade
# # sudo apt-get update -y
# # sudo apt-get upgrade -y
# # sudo apt-get build-dep -y --force-yes r-base
# # #sudo apt-get build-dep -y --force-yes r-base-core
# # #sudo apt-get build-dep -y --force-yes r-base-dev
# # # install R dependencies (mostly for image production support)
# # sudo apt-get install -y --force-yes r-base r-base-dev  # install R
# # ### Install addition packages
# # cat >install_packages.r<<EOF
# # # Optional - Install these packages - first from cran, then from BioConductor
# # install.packages(c("KernSmooth", "codetools", "httr", "scatterplot3d", "devtools", "RJSONIO","RCurl", "matlab", "ggplot2", "ecodist"), dependencies = TRUE, repos="http://cran.rstudio.com/", lib="/usr/lib/R/library")
# # source("http://bioconductor.org/biocLite.R")
# # biocLite (pkgs=c("DESeq","preprocessCore"))
# # q()
# # EOF
# # R --vanilla --slave < install_packages.r
# # rm install_packages.r
# echo "DONE INSTALLING R"
# ####################################################################################

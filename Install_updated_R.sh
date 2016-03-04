#!/bin/bash
####################################################################################
### INSTALL UPDATED R ONLY - this version for 14.04 (trusty)
####################################################################################
# return non zero when it should
# echo "options(warn=2); install.packages('RColorBrewer', repos='http://cran.r-project.org')" | R --slave --vanilla
# https://github.com/qiime/qiime-deploy/issues/15

### Install as root
#sudo bash << EOFSHELL
### Install Curl
sudo apt-get -y update
sudo apt-get -y install xserver-xorg-dev libcurl4-openssl-dev libxml2-dev libX11-dev freeglut3 freeglut3-dev
### add cran public key # this makes it possible to install most current R below
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E084DAB9
### for qiime install later, uncomment the universe and multiverse repositories from /etc/apt/sources.list
sudo echo deb http://cran.rstudio.com/bin/linux/ubuntu trusty/ >> /etc/apt/sources.list
sudo sed -e '/verse$/s/^#\{1,\}//' /etc/apt/sources.list > /etc/apt/sources.list.edit; mv /etc/apt/sources.list.edit /etc/apt/sources.list
#EOFSHELL
### upgrade
sudo apt-get update -y
sudo apt-get upgrade -y 
sudo apt-get build-dep r-base   # install R dependencies (mostly for image production support)
sudo apt-get install -y r-base  # install R
### Install addition packages
cat >install_packages.r<<EOF
# Optional - Install these packages - first from cran, then from BioConductor
install.packages(c("KernSmooth", "codetools", "httr", "scatterplot3d", "devtools", "RJSONIO","RCurl", "matlab", "ggplot2", "ecodist"), dependencies = TRUE, repos="http://cran.rstudio.com/", lib="/usr/lib/R/library")
source("http://bioconductor.org/biocLite.R")
biocLite (pkgs=c("DESeq","preprocessCore"))
q()
EOF
R --vanilla --slave < install_packages.r
rm install_packages.r
echo "DONE INSTALLING R"
####################################################################################

#!/bin/bash
####################################################################################
### INSTALL UPDATED R ONLY - this version for 14.04 (trusty)
####################################################################################
# return non zero when it should
# echo "options(warn=2); install.packages('RColorBrewer', repos='http://cran.r-project.org')" | R --slave --vanilla
# https://github.com/qiime/qiime-deploy/issues/15

### Install as root
sudo bash
### Install Curl
apt-get -y update
apt-get -y install xserver-xorg-dev libcurl4-openssl-dev libxml2-dev libX11-dev freeglut3 freeglut3-dev
### add cran public key # this makes it possible to install most current R below
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E084DAB9
### for qiime install later, uncomment the universe and multiverse repositories from /etc/apt/sources.list
echo deb http://cran.rstudio.com/bin/linux/ubuntu trusty/ >> /etc/apt/sources.list
sed -e '/verse$/s/^#\{1,\}//' /etc/apt/sources.list > /etc/apt/sources.list.edit; mv /etc/apt/sources.list.edit /etc/apt/sources.list
### upgrade
apt-get -y update
apt-get -y upgrade 
apt-get -y build-dep r-base # install R dependencies (mostly for image production support)
apt-get -y install r-base   # install R
### Install addition packages
cat >install_packages.r<<EOF
# Install these packages 
install.packages(c("KernSmooth", "codetools", "httr", "scatterplot3d"), dependencies = TRUE, repos="http://cran.rstudio.com/", lib="/usr/lib/R/library")
source("http://bioconductor.org/biocLite.R")
biocLite (pkgs=c("DESeq","preprocessCore"))
q()
EOF
R --vanilla --slave < install_packages.r
rm install_packages.r
echo "DONE INSTALLING R"
####################################################################################
  

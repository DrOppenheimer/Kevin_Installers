#!/bin/bash
####################################################################################
### INSTALL UPDATED R ONLY - this version for 14.04 (trusty)
####################################################################################
### Install as root
sudo bash
### Install Curl
apt-get -y install libcurl4-openssl-dev libxml2-dev
### add cran public key # this makes it possible to install most current R below
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E084DAB9
### for qiime install later, uncomment the universe and multiverse repositories from /etc/apt/sources.list
echo deb http://cran.rstudio.com/bin/linux/ubuntu trusty/ >> /etc/apt/sources.list
sed -e '/verse$/s/^#\{1,\}//' /etc/apt/sources.list > /etc/apt/sources.list.edit; mv /etc/apt/sources.list.edit /etc/apt/sources.list
### update and upgrade
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
  

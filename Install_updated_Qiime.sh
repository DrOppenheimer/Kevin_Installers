#!/bin/bash
# Simple script to install Qiime

####################################################################################
### install dependencies for qiime_deploy and R (R stuff is from another script this was copied from)
####################################################################################
cd /home/ubuntu
# use a super user shell to get the vm updated and all of the Qiime pre-reqs installed
sudo bash << EOSHELL_1
### for R install later add cran release specific repos to /etc/apt/sources.list
# echo deb http://cran.rstudio.com/bin/linux/ubuntu precise/ >> /etc/apt/sources.list # 12.04 # Only exist for LTS - check version with lsb_release -a
echo deb http://cran.rstudio.com/bin/linux/ubuntu trusty/ >> /etc/apt/sources.list  # 14.04 # Only exist for LTS - check version with lsb_release -a
### add cran public key # this makes it possible to install most current R below
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E084DAB9
### for qiime install later, uncomment the universe and multiverse repositories from /etc/apt/sources.list
sed -e '/verse$/s/^#\{1,\}//' /etc/apt/sources.list > /etc/apt/sources.list.edit; mv /etc/apt/sources.list.edit /etc/apt/sources.list
### update and upgrade
apt-get -y update
apt-get -y upgrade 
### install required packages
apt-get -y --force-yes upgrade python-dev libncurses5-dev libssl-dev libzmq-dev libgsl0-dev openjdk-6-jdk libxml2 libxslt1.1 libxslt1-dev ant git subversion zlib1g-dev libpng12-dev libfreetype6-dev mpich2 libreadline-dev gfortran unzip libmysqlclient18 libmysqlclient-dev ghc sqlite3 libsqlite3-dev libc6-i386 libbz2-dev libx11-dev libcairo2-dev libcurl4-openssl-dev libglu1-mesa-dev freeglut3-dev mesa-common-dev xorg openbox emacs r-cran-rgl xorg-dev libxml2-dev mongodb-server bzr make gcc mercurial python-qcli
apt-get clean
EOSHELL_1
####################################################################################

####################################################################################
### Clone repos for qiime-deploy and qiime-deploy-config
####################################################################################
cd /home/ubuntu/
git clone git://github.com/qiime/qiime-deploy.git
git clone https://github.com/qiime/qiime-deploy-conf
# git clone https://github.com/MG-RAST/AMETHST.git # has a custom minimal qiime install
####################################################################################

####################################################################################
### INSTALL DEFAULT QIIME ### also see https://github.com/qiime/qiime-deploy 4-23-14
####################################################################################
## This will also install cdbfasta & cdbyank, python and perl
## Uncomment the universe and multiverse repositories from /etc/apt/sources.list
# sudo bash
# sed -e '/verse$/s/^#\{1,\}//' /etc/apt/sources.list > /etc/apt/sources.list.edit; mv /etc/apt/sources.list.edit /etc/apt/sources.list
# exit
## see qiime-deploy options
# python ~/qiime-deploy/qiime-deploy.py -h
# Installation of Qiime with edited qiime config in the AMETHST repo
cd /home/ubuntu/
sudo python ./qiime-deploy/qiime-deploy.py ./qiime_software/ -f ./qiime-deploy-conf/qiime-1.8.0/qiime.conf --force-remove-failed-dirs
# NOTE that this installation of Qiime uses a heavily edited version of the configuration file found here:
# https://github.com/qiime/qiime-deploy-conf/blob/master/qiime-1.8.0/qiime.conf
# Notable differences — leave many of the components uninstalled, is not used to install R, we do that below
####################################################################################

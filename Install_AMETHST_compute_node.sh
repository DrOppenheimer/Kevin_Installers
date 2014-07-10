#!/bin/bash                                                                                                                                              
####################################################################################
### Script to create an AMETHST compute node from 14.04 bare
### used this to spawn a 14.04 VM:
# vmAWE.pl --create=1 --flavor_name=idp.100 --groupname=k_am_test.2 --key_name=kevin_share --image_name="Ubuntu Trusty 14.04" --namelist=yamato
####################################################################################

####################################################################################
### Create envrionment variables for key options
####################################################################################
cat >>/home/ubuntu/.bashrc<<EOF
AWE_SERVER="http://140.221.84.145:8000"
AWE_CLIENT_GROUP="k_am_test.2"
EOF
source /home/ubuntu/.bashrc
####################################################################################

####################################################################################
### move /tmp to /mnt/tmp (compute frequntly needs the space, exact amount depends on data)
####################################################################################
sudo bash
rm -r /tmp; mkdir -p /mnt/tmp/; chmod 777 /mnt/tmp/; sudo ln -s /mnt/tmp/ /tmp
exit
####################################################################################

####################################################################################
### install dependencies for qiime_deploy and R
####################################################################################
cd /home/ubuntu
sudo bash
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
apt-get -y install python-dev libncurses5-dev libssl-dev libzmq-dev libgsl0-dev openjdk-6-jdk libxml2 libxslt1.1 libxslt1-dev ant git subversion build-essential zlib1g-dev libpng12-dev libfreetype6-dev mpich2 libreadline-dev gfortran unzip libmysqlclient18 libmysqlclient-dev ghc sqlite3 libsqlite3-dev libc6-i386 libbz2-dev libx11-dev libcairo2-dev libcurl4-openssl-dev libglu1-mesa-dev freeglut3-dev mesa-common-dev xorg openbox emacs r-cran-rgl xorg-dev libxml2-dev
exit
####################################################################################

####################################################################################
### Clone repos for qiime-deploy and AMETHST
####################################################################################
cd /home/ubuntu/
git clone git://github.com/qiime/qiime-deploy.git
git clone https://github.com/MG-RAST/AMETHST.git
####################################################################################

####################################################################################
### INSTALL QIIME ### also see https://github.com/qiime/qiime-deploy 4-23-14
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
sudo python ./qiime-deploy/qiime-deploy.py ./qiime_software/ -f ./AMETHST/qiime_configuration/qiime.amethst.config --force-remove-failed-dirs
# NOTE that this installation of Qiime uses a heavily edited version of the configuration file found here:
# https://github.com/qiime/qiime-deploy-conf/blob/master/qiime-1.8.0/qiime.conf
# Notable differences — leave many of the components uninstalled, is not used to install R, we do that below
####################################################################################

####################################################################################
### INSTALL cdbtools (Took care of the cdb failure above)
####################################################################################
sudo bash
CURL="http://sourceforge.net/projects/cdbfasta/files/latest/download?source=files"
CBASE="cdbfasta"
#echo "###### downloading $CBASE ######"
curl -L $CURL > $CBASE".tar.gz"
tar zxf $CBASE".tar.gz"
#echo "###### installing $CBASE ######"
pushd $CBASE
make
cp cdbfasta $IDIR/bin/.
cp cdbyank $IDIR/bin/.
popd
rm $CBASE".tar.gz"
rm -rf $CBASE
exit
####################################################################################

####################################################################################
### INSTALL most current R on Ubuntu 14.04, install multiple non-base packages
####################################################################################
sudo bash
apt-get -y build-dep r-base # install R dependencies (mostly for image production support)
apt-get -y install r-base   # install R
# Install R packages, including matR, along with their dependencies
cat >install_packages.r<<EOF
## Simple R script to install packages not included as part of r-base
# Install these packages for matR and AMETHST
install.packages(c("KernSmooth", "codetools", "httr", "scatterplot3d", "rgl", "matlab", "ecodist", "gplots", "devtools"), dependencies = TRUE, repos="http://cran.rstudio.com/", lib="/usr/lib/R/library")
# Install these packages for Qiime
install.packages(c("ape", "random-forest", "r-color-brewer", "klar", "vegan", "ecodist", "gtools", "optparse"), dependencies = TRUE, repos="http://cran.rstudio.com/", lib="/usr/lib/R/library")
# Install matR
library(devtools)
install_github("MG-RAST/matR", dependencies=FALSE)
library(matR)
source("http://bioconductor.org/biocLite.R")
biocLite (pkgs=c("DESeq","preprocessCore"))
dependencies()
q()
EOF
R --vanilla --slave < install_packages.r
rm install_packages.r
exit
####################################################################################

####################################################################################
#### install perl packages
####################################################################################
sudo bash 
#curl -L http://cpanmin.us | perl - --sudo App::cpanminus
curl -L http://cpanmin.us | perl - --sudo Statistics::Descriptive
#cpan -f App::cpanminus # ? if this is first run of cpan, it will have to configure, can't figure out how to force yes for its questions
#                       # this may already be installed
#cpanm Statistics::Descriptive
exit
####################################################################################

####################################################################################
### Add AMETHST to Path (permanently)
sudo bash 
echo "export PATH=$PATH:/home/ubuntu/AMETHST" >> /home/ubuntu/.bashrc
source ~/.bashrc
exit
####################################################################################

####################################################################################
### Test AMETHST function
####################################################################################
test_amethst.sh
####################################################################################

####################################################################################
### INSTALL, CONFIGURE, and START AWE client (Uses Wei's script - commented copies of script and configureation are in appendix below
####################################################################################
### INSTALL
cd /home/ubuntu
curl http://www.mcs.anl.gov/~wtang/files/install_aweclient.sh > install_aweclient.sh
chmod u=+x install_aweclient.sh
./install_aweclient.sh
source /home/ubuntu/.bashrc
### CONFIGURE
cat >awe_client_config<<EOF
[Directories]
# See documentation for details of deploying Shock
site=$GOPATH/src/github.com/MG-RAST/AWE/site
data=/mnt/data/awe/data
logs=/mnt/data/awe/logs

[Args]
debuglevel=0

[Client]
totalworker=2
workpath=/mnt/data/awe/work
supported_apps=*
app_path=/home/ubuntu/apps/bin
serverurl=${AWE_SERVER}
name=${HOSTNAME}
group=${AWE_CLIENT_GROUP}
auto_clean_dir=true
worker_overlap=false
print_app_msg=true
username=
password=
#for openstack client only
#openstack_metadata_url=http://169.254.169.254/2009-04-04/meta-data
domain=default-domain #e.g. megallan

EOF

### Activate AWE client in a screen
screen -S awe_client -d -m /home/ubuntu/gopath/bin/awe-client -conf /home/ubuntu/awe_client_config
####################################################################################

####################################################################################
### DONE
####################################################################################







####################################################################################
####################################################################################
####################################################################################
####################################################################################
### APPENDIX

### FOR ALL THINGS AWE SEE http://www.mcs.anl.gov/~wtang/files/awe-example.pdf # and
### https://github.com/MG-RAST/AWE/wiki/Manual-to-Get-Started # and
### https://github.com/MG-RAST/AWE/

####################################################################################
### INSTALL AWE
### from http://www.mcs.anl.gov/~wtang/files/install_aweclient.sh # 7-10-14
####################################################################################
#!/bin/bash
# set -xe
# INSTALLDIR=${HOME}
# #here we could wait for volume to be attached
# cd ${INSTALLDIR}

# # create directories:
# for i in data logs work ; do mkdir -p ${INSTALLDIR}/data/awe/${i} ; chmod 777 ${INSTALLDIR}/data/awe/${i} ; done
# cd ${INSTALLDIR}
# sudo apt-get update
# sudo apt-get -y install mongodb-server bzr make gcc mercurial git
# if [ ! -e ${INSTALLDIR}/go/bin/go ]
# then
# mkdir -p ${INSTALLDIR}/gopath
# hg clone -u release https://code.google.com/p/go
# cd ${INSTALLDIR}/go/src
# ./all.bash
# fi
# export GOPATH=${INSTALLDIR}/gopath
# export PATH=$PATH:${INSTALLDIR}/go/bin:${INSTALLDIR}/gopath/bin
# n=`grep "export GOPATH=${INSTALLDIR}/gopath" ~/.bashrc | wc -l`
# if [ $n -eq 0 ]
# then
#     echo "export GOPATH=${INSTALLDIR}/gopath" >> ~/.bashrc
#     echo "PATH=\$PATH:${INSTALLDIR}/go/bin:${INSTALLDIR}/gopath/bin" >> ~/.bashrc
# fi
# if [ ! -d ${INSTALLDIR}/gopath/src/github.com/MG-RAST/AWE ]
# then
# go get github.com/MG-RAST/AWE/...
# else
# cd ${INSTALLDIR}/gopath/bin
# rm -f ${INSTALLDIR}/gopath/bin/AWE_BUILD.sh
# wget http://www.mcs.anl.gov/~wtang/files/AWE_BUILD.sh
# chmod +x AWE_BUILD.sh
# #go get will build when getting the code, AWE_BUILD.sh is used to build if code changes
# cd ${INSTALLDIR}/gopath/src/github.com/MG-RAST/AWE
# git pull origin master
# ${INSTALLDIR}/gopath/bin/AWE_BUILD.sh
# fi
# mkdir -p ${INSTALLDIR}/etc
# #upstart symlink
# sudo ln -s -f /lib/init/upstart-job /etc/init.d/awe-client
# cd ${INSTALLDIR}
# sudo rm -f awe-client.conf /etc/init/awe-client.conf
# wget http://www.mcs.anl.gov/~wtang/files/awe-client.conf 
# sudo mv awe-client.conf /etc/init/awe-client.conf
# # install scripts for software other than AWE client
# mkdir -p ${INSTALLDIR}/install_scripts/
# FILESPEC=*.sh
# for SCRIPT in ${INSTALLDIR}/install_scripts/$FILESPEC
# do
# if [ -x $SCRIPT ]
# then
# echo "Executing install script: $SCRIPT"
# $SCRIPT
# fi
# done
# cd ${INSTALLDIR}
# echo "install awe done!"
####################################################################################

####################################################################################
### CONFIGURE AWE (client only)
### from https://raw.githubusercontent.com/MG-RAST/AWE/master/templates/awec.cfg.template
####################################################################################
# [Directories]
# # See documentation for details of deploying Shock
# site=$GOPATH/src/github.com/MG-RAST/AWE/site
# data=/mnt/data/awe/data
# logs=/mnt/data/awe/logs

# [Args]
# debuglevel=0

# [Client]
# totalworker=2
# workpath=/mnt/data/awe/work
# supported_apps=
# app_path=/home/ubuntu/apps/bin
# serverurl=http://localhost:8001
# name=default_client
# group=default_group
# auto_clean_dir=false
# worker_overlap=false
# print_app_msg=true
# username=
# password=
# #for openstack client only
# #openstack_metadata_url=http://169.254.169.254/2009-04-04/meta-data
# domain=default-domain #e.g. megallan
####################################################################################

####################################################################################
### INSTALL UPDATED R ONLY
####################################################################################
# ### add cran public key # this makes it possible to install most current R below
# apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E084DAB9
# ### for qiime install later, uncomment the universe and multiverse repositories from /etc/apt/sources.list
# echo deb http://cran.rstudio.com/bin/linux/ubuntu trusty/ >> /etc/apt/sources.list
# sed -e '/verse$/s/^#\{1,\}//' /etc/apt/sources.list > /etc/apt/sources.list.edit; mv /etc/apt/sources.list.edit /etc/apt/sources.list
# ### update and upgrade
# apt-get -y update
# apt-get -y upgrade 
# apt-get -y build-dep r-base # install R dependencies (mostly for image production support)
# apt-get -y install r-base   # install R
# ### Install addition packages
# cat >install_packages.r<<EOF
# # Install these packages 
# install.packages(c("KernSmooth", "codetools", "httr", "scatterplot3d"), dependencies = TRUE, repos="http://cran.rstudio.com/", lib="/usr/lib/R/library")
# q()
# EOF
# R --vanilla --slave < install_packages.r
# rm install_packages.r
####################################################################################
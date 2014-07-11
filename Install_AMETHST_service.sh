#!/bin/bash

#### THIS SCRIPT IS NOT COMPLETE YET 7-10-14
set -e # print commands 
set -x # stops script on an error

####################################################################################
### Start KBase-VM and deploy amethst module and its dependencies
#vmAWE.pl --create 1 --groupname=am_service --flavor_name=idp.100 --image_name=kbase-image-v26 --deploy_target=/kb/ --root_deploy="kbase(amethst_service)" --group=am_service --instance_names=enterprise
### or install service on KBase VM that is already running
#vmAWE.pl --group=kbase-kevin1 --deploy_target=/kb/ --root_deploy="kbase(amethst_service)"
####################################################################################

####################################################################################
### prepare tmp directory (only backend needs that!)
####################################################################################
sudo bash
rm -r /tmp; mkdir -p /mnt/tmp/; chmod 777 /mnt/tmp/; sudo ln -s /mnt/tmp/ /tmp
exit
####################################################################################

####################################################################################
### copy the key from the existing vm 
############### A key like the one you get when you follow this procedure on a KB VM ###############
sudo bash
### get the key
head -n 42 /home/ubuntu/cloudinit.sh > cloudinit_key.sh 
source /home/ubuntu/cloudinit_key.sh # don’t give location for runtime when asked - just ctrl c out
### places copy of key in ~root/.ssh/id_rsa
### 1) copy private key (e.g. kbase_rsa) to VM ~/.ssh/
cp ~root/.ssh/id_rsa ~/.ssh/
### 2) start ssh agent: 
eval `ssh-agent -s`
### 3) add key: 
ssh-add ~/.ssh/id_rsa
# ( on the kbase image the rsa key is stored in the cloudinit.sh )
exit
####################################################################################################


# install emacs and git
apt-get install -y emacs git

# clone the bootstrap repo
cd /home/ubuntu
git clone kbase@git.kbase.us:bootstrap

# create directory for runtime
mkdir -p /kb/runtime

# add it as env variable
target=/kb/runtime

# create and populate dev_container
cd /home/ubuntu
git clone kbase@git.kbase.us:dev_container.git
cd /home/ubuntu/dev_container/modules
# clone modules into the dev_container
git clone https://github.com/kbase/amethst_service.git # ( not kbase@git.kbase.us:awe_service.git ! )
git clone https://github.com/kbase/typecomp.git
git clone https://github.com/kbase/matR.git
git clone https://github.com/kbase/shock_service.git
git clone https://github.com/kbase/awe_service.git
git clone https://github.com/kbase/kbapi_common.git
git clone kbase@git.kbase.us:auth.git # needs the key from above
git clone kbase@git.kbase.us:jars.git # needs the key from above

# deploy services 
cd /home/ubuntu/dev_container
# source /kb/runtime/env/java-build-runtime.env 
./bootstrap /kb/runtime
. user-env.sh
make 
make deploy

# source environment
source /kb/deployment/user-env.sh

# location of AMETHST binary
# /home/ubuntu/dev_container/modules/amethst_service/AMETHST
# add AMETHST directory to path
echo "export PATH=/home/ubuntu/dev_container/modules/amethst_service/AMETHST/.:$PATH" >> ~/.bashrc
source ~/.bashrc
###





# ####################################################################################
# ### Deploy client
# sudo bash
# cd /kb/dev_container/
# ./bootstrap /kb/runtime
# source /kb/dev_container/user-env.sh

# cd /kb/dev_container/modules/amethst_service
# git pull
# make
# make deploy-client
# source /kb/deployment/user-env.sh
# make test-client
# ####################################################################################

# ####################################################################################
# ### Deploy and start service
# ####################################################################################
# sudo bash
# cd /kb/dev_container/
# ./bootstrap /kb/runtime
# source /kb/dev_container/user-env.sh

# cd /kb/dev_container/modules/amethst_service
# git pull
# make
# make deploy-service
# source /kb/deployment/user-env.sh
# <here you might need to start service, not sure>
# make test-service
# ### Start AMETHST service manually
# ## make sure that the amethst_service is running
# ## start a screen session, then
# #sudo bash
# #source /kb/deployment/user-env.sh
# #cd /kb/deployment/services/amethst_service/
# #./start_service
# ## exit (don’t kill) screen
# ####################################################################################

# ####################################################################################
# ### Deploy backend and start AWE-client
# ####################################################################################
# sudo bash
# cd /kb/dev_container/
# ./bootstrap /kb/runtime
# source /kb/dev_container/user-env.sh

# cd /kb/dev_container/modules/amethst_service
# git pull
# make
# make deploy-backend
# source /kb/deployment/user-env.sh
# make test-backend
# ####################################################################################

# ####################################################################################
# ### start AWE client
# ####################################################################################
# ### start AWE client (remotely)
# #vmAWE.pl --group amethst-wolfgang --command="sudo /kb/deployment/services/awe_service/start_aweclient"
# ### start AWE client (locally as ubuntu user):
# #sudo /kb/deployment/services/awe_service/start_aweclient
# ####################################################################################

# ####################################################################################
# ### check status on AWE monitor
# #http://140.221.85.36:8080/awemonitor.html
# ####################################################################################
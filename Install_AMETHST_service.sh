#!/bin/bash

#### THIS SCRIPT IS NOT COMPLETE YET 7-10-14
set -e # checking of all commands 
set -x # print each command before execution

#sudo bash << EOFSHELL # wrapper to run whole shell as root
#EOFSHELL              #
# configuration for the service is in /home/ubuntu/dev_container/modules/amethst_service/deploy.cfg

# Check to make sure that server is correct in
# /kb/deployment

# location of AMETHST binary
# /home/ubuntu/dev_container/modules/amethst_service/AMETHST


####################################################################################
### Start KBase-VM and deploy amethst module and its dependencies
#vmAWE.pl --create 1 --groupname=am_service --flavor_name=idp.100 --image_name=kbase-image-v26 --deploy_target=/kb/ --root_deploy="kbase(amethst_service)" --group=am_service --instance_names=enterprise
### or install service on KBase VM that is already running
#vmAWE.pl --group=kbase-kevin1 --deploy_target=/kb/ --root_deploy="kbase(amethst_service)"
####################################################################################

####################################################################################
### prepare tmp directory (only backend needs that!)
####################################################################################
# sudo bash << EOFSHELL_1
# #sudo bash
# sudo rm -r /tmp 
# sudo mkdir -p /mnt/tmp/ 
# sudo chmod 777 /mnt/tmp/
# #sudo ln -s /mnt/tmp/ /tmp
# sudo ln -s /mnt/tmp/ /tmp
# #exit
# EOFSHELL_1
####################################################################################

####################################################################################
### set your KB_AUTH_TOKEN (by hand - is added to ~/.profile below )
####################################################################################
KB_AUTH_TOKEN=""
####################################################################################

####################################################################################
### copy the key from the existing vm 
############### A key like the one you get when you follow this procedure on a KB VM ###############
sudo bash << EOFSHELL_2
#sudo bash
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
#exit
EOFSHELL_2
####################################################################################################

####################################################################################################
### KBase bootstratp ( from https://docs.google.com/document/d/1MvZQprSwh8S9SthIws_YH85mpKX6TGD-ukajxVtpZpM/edit )
####################################################################################################
sudo bash << EOFSHELL_3
## install emacs and git
#apt-get install -y emacs git

# clone the bootstrap repo
#cd /home/ubuntu
#cd /root
#git clone kbase@git.kbase.us:bootstrap

# create and populate dev_container
cd /kb
git clone kbase@git.kbase.us:dev_container.git
cd /kb/dev_container/modules
# clone modules into the dev_container
git clone https://github.com/kbase/amethst_service.git # ( not kbase@git.kbase.us:awe_service.git ! )
git clone https://github.com/kbase/typecomp.git
git clone https://github.com/kbase/matR.git
git clone https://github.com/kbase/shock_service.git
git clone https://github.com/kbase/awe_service.git # --recursive
git clone https://github.com/kbase/kbapi_common.git
git clone kbase@git.kbase.us:auth.git # needs the key from above
git clone kbase@git.kbase.us:jars.git # needs the key from above

# deploy all installed KBase services 
cd /kb/dev_container
/kb/dev_container/bootstrap /kb/runtime
source /kb/dev_container/user-env.sh
make 
make deploy

# add amethst to path
echo "export PATH=\"/kb/dev_container/modules/amethst_service/AMETHST/:/kb/deployment/bin:$PATH\"" >> /kb/deployment/user-env.sh

# add KBase env and amethst service start to .profile - load a KB_AUTH_TOKEN
echo "export KB_AUTH_TOKEN=\"${KB_AUTH_TOKEN}\"" >> ~/.profile ## DON'T FORGET TO ADD KB_AUTH_TOKEN to ~/.profile
echo "source /kb/deployment/user-env.sh" >> ~/.profile

# add starting the service to the /etc/rc.local file to start the service at boot
rm /etc/rc.local
cat >/etc/rc.local<<EOF_2
#!/bin/sh -e
sudo screen -S awe_service -d -m bash -c "source /kb/deployment/user-env.sh; source /home/ubuntu/.profile; sudo /kb/deployment/services/amethst_service/start_service"
EOF_2
chmod +x /etc/rc.local

# Patch from Wolfgang -- will not be necessary in the future
cd /kb/deployment/lib/AWE
rm Client.pm
wget https://raw.githubusercontent.com/wgerlach/AWE/master/utils/lib/AWE/Client.pm

EOFSHELL_3
####################################################################################################
####################################################################################################
sudo reboot

# END - Notes from here on
####################################################################################################
####################################################################################################
####################################################################################################
####################################################################################################
####################################################################################################
####################################################################################################




# source environment
source /kb/deployment/user-env.sh

####################################################################################################
# configuration for the service is in /kb/dev_container/modules/amethst_service/deploy.cfg
# and                                 /kb/deployment/deployment.cfg

## DON'T FORGET TO ADD KB_AUTH_TOKEN to ~/.profile

####################################################################################################
### Deploy and start AMETHST service (is not currently part of the bottstrap)
####################################################################################################
sudo bash << EOFSHELL_4
/kb/dev_container/bootstrap /kb/runtime
source /kb/dev_container/user-env.sh
source /kb/deployment/user-env.sh
/kb/deployment/services/amethst_service/start_service &
# add AMETHST directory to path
echo "export PATH=/kb/dev_container/modules/amethst_service/AMETHST/:$PATH;" >> /kb/deployment/user-env.sh
source /kb/deployment/user-env.sh

echo "sudo /kb/deployment/services/amethst_service/start_service &" >> ~/.profile
echo "source /kb/deployment/user-env.sh" >> ~/.profile
EOFSHELL_4
####################################################################################################

####################################################################################################
### Force AMETHST service to start on boot
####################################################################################################
# sudo bash << EOFSHELL_5
# rm /etc/rc.local

# cat >/etc/rc.local<<EOF_2
# #!/bin/sh -e 
# . /home/ubuntu/.profile
# EOF_2
# chmod +x /etc/rc.local

# EOFSHELL_5

# sudo reboot
####################################################################################################


####################################################################################################
####################################################################################################
####################################################################################################
### Just notes from here on
####################################################################################################
####################################################################################################
####################################################################################################

# configuration for the service is in /home/ubuntu/dev_container/modules/amethst_service/deploy.cfg
# Update it by updating repo:
# https://github.com/kbase/amethst_service


# cat >/home/ubuntu/start_AMETHST_service.sh<<EOF_1
# #!/bin/sh -e 
# echo "starting amethst_service"
# . /kb/deployment/user-env.sh
# /kb/deployment/services/amethst_service/start_service &
# echo "amethst_service should be running"
# EOF_1

# chmod +x start_AMETHST_service.sh

# rm /etc/rc.local

# cat >/etc/rc.local<<EOF_2
# #!/bin/sh -e 
# sudo screen -S amethst_service -d -m /home/ubuntu/start_AMETHST_service.sh
# EOF_2


# #### Deploy amethst service manually 
# cd /kb/dev_container/modules/amethst_service
# git pull
# make
# make deploy-service
# source /kb/deployment/user-env.sh
# #<here you might need to start service, not sure>
# make test-service
# ###################################################

# #### Start AMETHST service manually
# # make sure that the amethst_service is running
# # start a screen session, then
# sudo bash
# cd /kb/deployment/services/amethst_service/
# ./start_service &
# # exit (don’t kill) screen
# ###################################################


# Deploy client
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

# Deploy and start service
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


# Start AMETHST service manually
# # make sure that the amethst_service is running
# # start a screen session, then
# sudo bash
# source /kb/deployment/user-env.sh
# cd /kb/deployment/services/amethst_service/
# ./start_service
# # exit (don’t kill) screen





# make sure that auth token is on the VM


# see configuration of the service here after delploy
# /home/ubuntu/dev_container/modules/amethst_service




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
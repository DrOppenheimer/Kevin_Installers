#!/bin/bash

####################################################################################
### Start KBase-VM and deploy amethst module and its dependencies
#vmAWE.pl --create 1 --groupname=am_service --flavor_name=idp.100 --image_name=kbase-image-v26 --deploy_target=/kb/ --root_deploy="kbase(amethst_service)"
### or install service on KBase VM that is already running
#vmAWE.pl --group=kbase-kevin1 --deploy_target=/kb/ --root_deploy="kbase(amethst_service)"
####################################################################################

####################################################################################
### prepare tmp directory (only backend needs that!)
####################################################################################
sudo mkdir -p /mnt/my_temp_dir/ /mnt/tmp/; sudo chmod 777 /mnt/my_temp_dir/ /mnt/tmp/
####################################################################################

####################################################################################
### Deploy client
sudo bash
cd /kb/dev_container/
./bootstrap /kb/runtime
source /kb/dev_container/user-env.sh

cd /kb/dev_container/modules/amethst_service
git pull
make
make deploy-client
source /kb/deployment/user-env.sh
make test-client
####################################################################################

####################################################################################
### Deploy and start service
####################################################################################
sudo bash
cd /kb/dev_container/
./bootstrap /kb/runtime
source /kb/dev_container/user-env.sh

cd /kb/dev_container/modules/amethst_service
git pull
make
make deploy-service
source /kb/deployment/user-env.sh
<here you might need to start service, not sure>
make test-service
### Start AMETHST service manually
## make sure that the amethst_service is running
## start a screen session, then
#sudo bash
#source /kb/deployment/user-env.sh
#cd /kb/deployment/services/amethst_service/
#./start_service
## exit (don’t kill) screen
####################################################################################

####################################################################################
### Deploy backend and start AWE-client
####################################################################################
sudo bash
cd /kb/dev_container/
./bootstrap /kb/runtime
source /kb/dev_container/user-env.sh

cd /kb/dev_container/modules/amethst_service
git pull
make
make deploy-backend
source /kb/deployment/user-env.sh
make test-backend
####################################################################################

####################################################################################
### start AWE client
####################################################################################
### start AWE client (remotely)
#vmAWE.pl --group amethst-wolfgang --command="sudo /kb/deployment/services/awe_service/start_aweclient"
### start AWE client (locally as ubuntu user):
#sudo /kb/deployment/services/awe_service/start_aweclient
####################################################################################

####################################################################################
### check status on AWE monitor
#http://140.221.85.36:8080/awemonitor.html
####################################################################################
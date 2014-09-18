# start up VM

# shorcut using one of Wolfgang's images
#vmAWE.pl --create=1 --flavor_name=i2.small.sd --groupname=kevin_awe_server_aufs --key_name=kevin_share --image_name="docker1.1.2_AUFS"
vmAWE.pl --create=1 --flavor_name=i2.small.sd --groupname=kevin_awe_server --key_name=kevin_share --image_name="Ubuntu 14.04 Trusty" --wantip

sudo bash

cd ~
curl www.mcs.anl.gov/~wtang/files/install_awe.sh > install_awe.sh
chmod +x ~/install_awe.sh
./install_awe.sh

cd ~

export GOPATH=/home/ubuntu/gopath
export PATH=$PATH:/home/ubuntu/go/bin:/home/ubuntu/gopath/bin
export PATH=$PATH:/home/ubuntu/gopath/src/github.com/MG-RAST/AWE/utils
 
#* replace ubuntu with proper user name
#** Optional: edit .bashrc to export above environmental variable automatically for future use
 
# VARS FOR CONFIG
export GOPATH=/home/ubuntu/gopath
export PATH=$PATH:/home/ubuntu/go/bin:/home/ubuntu/gopath/bin
export PATH=$PATH:/home/ubuntu/gopath/src/github.com/MG-RAST/AWE/utils
#export AWE_SERVER="http://kbase.us/services/awe/" # KBase production
#export AWE_SERVER="http://140.221.67.190:7080" # KBase dev # external ip
#export AWE_SERVER="http://10.1.16.5:7080" # KBase dev # internal ip
#export AWE_SERVER="http://140.221.84.148:8000" # MG-RAST
#export AWE_CLIENT_GROUP="amethst"
#export HOSTNAME=`hostname` #${HOSTNAME}
#export GOPATH=/home/ubuntu/gopath
export AWE_DATA="/data/awe/data"
export AWE_WORK="/data/awe/work"
export AWE_LOGS="/data/awe/logs"
export LOCAL_HOST=`hostname`
KB_AUTH_TOKEN=""
AWE_CLIENT_GROUP_TOKEN=""

mkdir -p ${AWE_DATA}
mkdir -p ${AWE_WORK}
mkdir -p ${AWE_LOGS}


cat >/home/ubuntu/awe_server_config<<EOF_4 # from https://github.com/MG-RAST/AWE/blob/master/templates/awes.cfg.template
[Anonymous]
# Controls whether an anonymous user can read/write/delete jobs.
# Also controls whether an anonymous user can read/write/delete clientgroups.
# values: true/false
# NOTE: You'll want all of these values to be false in a secure setup, leaving
# any of these as true is basically done for ease of development or if you
# are running AWE in a closed environment where you can trust all connections.
read=true
write=true
delete=true
cg_read=false
cg_write=false
cg_delete=false

[Ports]
# Ports for site/api
# Note: use of port 80 may require root access
site-port=8080
api-port=8000

[External]
site-url=
api-url=

[Admin]
# If you're running AWE with user and clientgroup Auth enabled, you'll want
# to designate at least one admin user for creation of the clientgroups and
# managing your AWE server.
users=keegan
email=kkeeganX@anl.gov (remove X from address)
secretkey=supersecretkey

[Auth]
globus_token_url=https://nexus.api.globusonline.org/goauth/token?grant_type=client_credentials
globus_profile_url=https://nexus.api.globusonline.org/users
client_auth_required=true

[Directories]
# See documentation for details of deploying Shock
site=$GOPATH/src/github.com/MG-RAST/AWE/site
data=${AWE_DATA}
logs=${AWE_LOGS}
awf=$GOPATH/src/github.com/MG-RAST/AWE/templates/awf_templates

[Mongodb]
# Mongodb configuration:
# Hostnames and ports hosts=host1[,host2:port,...,hostN]
hosts=localhost
database=AWEDB
user=
password=

[Mongodb-Node-Indices]
# See http://www.mongodb.org/display/DOCS/Indexes#Indexes-CreationOptions for more info on mongodb index options.
# key=unique:true/false[,dropDups:true/false][,sparse:true/false]
id=unique:true

[Args]
debuglevel=0

[Server]
perf_log_workunit=true

[Client]
totalworker=2
workpath=${AWE_WORK}
supported_apps=
app_path=/home/ubuntu/apps/bin
#serverurl=http://localhost:8000 # ???
serverurl=http://${LOCAL_HOST}:8000 # ???
name=default_client
group=amethst
auto_clean_dir=false
worker_overlap=false
print_app_msg=false
username=
password=
#for openstack client only
#openstack_metadata_url=http://169.254.169.254/2009-04-04/meta-data
domain=default-domain #e.g. megallan
EOF_4


screen -S awe_server
sudo bash
/home/ubuntu/gopath/bin/awe-server -conf ~/awe_server_config &

# pid: 1281 saved to file: /data/awe/data/pidfile

##########################################################################################################################################################
##########################################################################################################################################################
##########################################################################################################################################################
##########################################################################################################################################################
















# Wolfgang's method:


curl
http://shock.metagenomics.anl.gov/node/a8560eb3-d1e7-4fc7-b01e-c7c8a2a544e0?download
> awe.tgz

sudo docker load -i awe.tgz


mkdir -p /mnt/data/awe/logs ; mkdir ~/awe-config ; cd ~/awe-config


cd ~/awe-config ; wget
https://raw.githubusercontent.com/wgerlach/AWE_develop/master/awe-server.cfg

check configuration of awe-server.cfg

create config.js
/home/gopath/src/github.com/MG-RAST/AWE/site/js/config.js
make sure to use your IP !
content:
var RetinaConfig = {
    "awe_ip": "http://140.221.67.184:8001",
    "workflow_ip": "http://140.221.67.184:8001/awf",
    "authResources": { "default": "KBase",
                       "KBase": { "icon": "KBase_favicon.ico",
                                  "prefix": "kbgo4711" } },
    "mgrast_api": "http://api.metagenomics.anl.gov",
    "authentication": true
}


sudo docker.io run -t -i --name awe-server \
-p 80:80 \
-p 8001:8001 \
-v /data/db/:/data/db/ \
-v /home/ubuntu/awe-config/:/awe-config/ \
-v /mnt/data/awe/:/mnt/data/awe/ \
awe:20140615 \
bash -c "mkdir -p /awe/logs/ && cp /awe-config/config.js
/home/gopath/src/github.com/MG-RAST/AWE/site/js/ ; rm -f
/usr/sbin/policy-rc.d ; apt-get -y install mongodb-server ; rm -f
/awe/logs/* && rm -f /home/gopath/bin/awe-server && cd
/home/gopath/src/github.com/MG-RAST/ && rm -rf AWE golib go-dockerclient
&& git clone https://github.com/wgerlach/AWE.git -b master && git clone
https://github.com/MG-RAST/golib.git && git clone
https://github.com/MG-RAST/go-dockerclient.git && cd && go install -v
github.com/MG-RAST/AWE/... && /home/gopath/bin/awe-server -debug 1 -conf
/awe-config/awe-server.cfg"







################################################################################################
################################################################################################
################################################################################################
################################################################################################


# longer way

vmAWE.pl --create=1 --flavor_name=i2.small.sd --groupname=kevin_awe_server --key_name=kevin_share --image_name="Ubuntu 14.04 Trusty"


# This is mostly frorm:
# https://docs.google.com/document/d/1UNp8GK9QTzWXCkGj4yNj9IqzoM8i34gZaucsSyHGVxo/edit

# 1 Install AWE
# 1.1 install prerequisite software:
 
sudo apt-get update
sudo apt-get -y install mongodb-server bzr make gcc mercurial git
 
# * The commands at each step are examples for Ubuntu systems
# 1.2 install go programming language:
 
cd ~
mkdir -p ~/gopath
hg clone -u release https://code.google.com/p/go
cd ~/go/src ./all.bash

export GOPATH=/home/ubuntu/gopath
export PATH=$PATH:/home/ubuntu/go/bin:/home/ubuntu/gopath/bin
export PATH=$PATH:/home/ubuntu/gopath/src/github.com/MG-RAST/AWE/utils
 
#* replace ubuntu with proper user name
#** Optional: edit .bashrc to export above environmental variable automatically for future use
 
# VARS FOR CONFIG
export GOPATH=/home/ubuntu/gopath
export PATH=$PATH:/home/ubuntu/go/bin:/home/ubuntu/gopath/bin
export PATH=$PATH:/home/ubuntu/gopath/src/github.com/MG-RAST/AWE/utils
#export AWE_SERVER="http://kbase.us/services/awe/" # KBase production
#export AWE_SERVER="http://140.221.67.190:7080" # KBase dev # external ip
#export AWE_SERVER="http://10.1.16.5:7080" # KBase dev # internal ip
#export AWE_SERVER="http://140.221.84.148:8000" # MG-RAST
#export AWE_CLIENT_GROUP="amethst"
#export HOSTNAME=`hostname` #${HOSTNAME}
#export GOPATH=/home/ubuntu/gopath
export AWE_DATA="/data/awe/data"
export AWE_WORK="/data/awe/work"
export AWE_LOGS="/data/awe/logs"
KB_AUTH_TOKEN=""
AWE_CLIENT_GROUP_TOKEN=""

mkdir -p ${AWE_DATA}
mkdir -p ${AWE_WORK}
mkdir -p ${AWE_LOGS}


cat >/home/ubuntu/awe_server_config<<EOF_4 # from https://github.com/MG-RAST/AWE/blob/master/templates/awes.cfg.template
[Anonymous]
# Controls whether an anonymous user can read/write/delete jobs.
# Also controls whether an anonymous user can read/write/delete clientgroups.
# values: true/false
# NOTE: You'll want all of these values to be false in a secure setup, leaving
# any of these as true is basically done for ease of development or if you
# are running AWE in a closed environment where you can trust all connections.
read=true
write=true
delete=true
cg_read=false
cg_write=false
cg_delete=false

[Ports]
# Ports for site/api
# Note: use of port 80 may require root access
site-port=8080
api-port=8000

[External]
site-url=
api-url=

[Admin]
# If you're running AWE with user and clientgroup Auth enabled, you'll want
# to designate at least one admin user for creation of the clientgroups and
# managing your AWE server.
users=keegan
email=kkeeganX@anl.gov (remove X from address)
secretkey=supersecretkey

[Auth]
globus_token_url=https://nexus.api.globusonline.org/goauth/token?grant_type=client_credentials
globus_profile_url=https://nexus.api.globusonline.org/users
client_auth_required=true

[Directories]
# See documentation for details of deploying Shock
site=$GOPATH/src/github.com/MG-RAST/AWE/site
data=${AWE_DATA}
logs=${AWE_LOGS}
awf=$GOPATH/src/github.com/MG-RAST/AWE/templates/awf_templates

[Mongodb]
# Mongodb configuration:
# Hostnames and ports hosts=host1[,host2:port,...,hostN]
hosts=localhost
database=AWEDB
user=
password=

[Mongodb-Node-Indices]
# See http://www.mongodb.org/display/DOCS/Indexes#Indexes-CreationOptions for more info on mongodb index options.
# key=unique:true/false[,dropDups:true/false][,sparse:true/false]
id=unique:true

[Args]
debuglevel=0

[Server]
perf_log_workunit=true

[Client]
totalworker=2
workpath=${AWE_WORK}
supported_apps=
app_path=/home/ubuntu/apps/bin
serverurl=http://localhost:8000
name=default_client
group=amethst
auto_clean_dir=false
worker_overlap=false
print_app_msg=false
username=
password=
#for openstack client only
#openstack_metadata_url=http://169.254.169.254/2009-04-04/meta-data
domain=default-domain #e.g. megallan
EOF_4




/home/ubuntu/gopath/bin/awe-server -conf ~/awe_server_config


##########################################################################################################################################################
##########################################################################################################################################################
##########################################################################################################################################################
##########################################################################################################################################################


AWE Manual


1.     Install AWE
2.     Configure AWE
3.     Run AWE
4.     Submit pipeline jobs
5.     Prepare pipeline template
6.     Check queue status
  (any question pls direct to Wei Tang at wtang@mcs.anl.gov)
1 Install AWE
 
1.3 getting source code and install

#sudo apt-get install gccgo-go 
#go get github.com/MG-RAST/AWE/...
git clone https://github.com/MG-RAST/AWE.git
 
* awe-server and awe-client are installed at this point
 
1.4 update source code and rebuild
Source code directory is at $GOPATH/src/github.com/MG-RAST/AWE. Following commands will recompile and install latest version of AWE.
 
cd $GOPATH/src/github.com/MG-RAST/AWE
git pull origin master
AWE_BUILD.sh
 
*AWE_BUILD.sh is under source code directory AWE/utils
 
** Easy install on Magellan VM:
 
To install AWE on an empty Magellan VM, simply run following script:
 
www.mcs.anl.gov/~wtang/files/install_awe.sh
 
Download it and run:
. install_awe.sh  or source install_awe.sh
(Since the script exports environment variables and then used them in the script, you need to use . or source to run this script)
2 configure AWE
2.1 prepare needed directories
 
makedir –p </path/to/awe/data>
mkdir –p </path/to/awe/log>
mkdir –p </path/to/awe/work>
 
* These three directories stores job script and bson data for awe server, logs for awe-server or awe-client, and workunit intermediate data for awe-client, respectively (the paths should be configured in the configure file).
 
2.2 prepare configure file (server and client)
 
2.2.1 get sample from:
 
https://github.com/MG-RAST/AWE/blob/master/templates/awe.cfg.template
 
2.2.2 edit and make sure following fields are configured properly
awe-server:
 
(required)
 
site=/home/<user>/gopath/src/github.com/MG-RAST/AWE/site
data=</path/to/awe/data>
logs=</path/to/awe/log>
site-port=<the port number for site service, e.g. 8080>
api-port=<the port number for api service, e.g. 8000>
awe-client
 
(required)
workpath=</path/to/awe/work>
serverurl=http://awe-server-url:api-port (be consistent with server configuration)
 
(optional)
clientprofile=<path/to/client/profile> (if not configured here, the profile path should be specified as a the command line argument)
print_app_msg=false (if true, the client running terminal will print standout and standerr msg produced by the applications running on that client)
 
2.3 prepare configure file (client only)
 
1) Get sample from:
 
https://raw.github.com/MG-RAST/AWE/master/templates/clientprofile.json
 
2) Edit and make sure following fields are configured properly
 
“name”:”myclient”  -- change myclient to a name you want this client to have (use case: one can can submit job and specify only client with certain name to checkout.)
“apps”:[“app1”,”app2”] – list of the applications that can run directly from the client’s machine (commands are in $PATH) (a client can only checkout workunits that with command names in this list)
3 Run AWE
3.1 Run awe-server
 
1) Make sure local accessible MongoDB is running
2) Make sure at least one Shock instance is running and accessible via http
3) Start command:
 
awe-server –conf <path/to/cfg> [-recover] [-debug 0-3]
 
Options:
 -recover: if this flag is set, awe-server will automatically recover unfinished jobs before the last time the  awe-server was shut down or encountered a failure
 -debug: set the debug log level from 0 to 3, by default debug log is not printed (level
 
3.2 Run awe-clients
 
1) Make sure the supported applications can run from command line
2) Start command:
 
awe-client –conf <path/to/cfg> [-profile <path/to/profile] [-debug 0-3]
 
3.3 Check logs
 
1) Log location
 
Logs of server and client can be found under <path/to/awe/logs>
 
2) Log types: access.log, error.log, debug.log, event.log, perf.log
 
4 Submit a pipeline job
 
To submit a pipeline job one can use the job submit tool AWE/utils/awe_submit.pl
4.1 Examples
 
awe_submit.pl -awe=localhost:8001 -shock=localhost:8000 -node=shock_node_id -pipeline=mgrast.json.template   (use case 2)
 
or
awe_submit.pl -awe=localhost:8001 -shock=localhost:8000 -input=raw.100k.fastq -pipeline=mgrast.json.template   (use case 2)
or
 
awe_submit.pl –awe=localhost:8001 –script=mgrast.json    (use case 3)
 
4.2 Usage
 
Pipeline job submitter for AWE
Command name: awe_submit.pl
Options:
     -awe=<AWE server URL (ip:port), required>
     -shock=<Shock URL (ip:port), required>
     -node=<shock node of the input file>
     -type=<input file type, fna|fasta|fastq|fa, required when -node is set>
     -upload=<input file that is local and to be uploaded>
     -pipeline=<path for pipeline job template, required when -node or -upload is set>
     -script=<path for complete job json file>
     -name=<job name>
     -user=<user name>
     -project=<project name>
     -cgroups=<exclusive_client_group_list (separate by ',')>
     
     
Use case 1: submit a job with a shock url for the input file location and a pipeline template (input file is on shock)
      Required options: -node, -pipeline, -awe (if AWE_HOST not in ENV), -shock (if SHOCK_HOST not in ENV)
      Optional options: -name, -user, -project, -cgroups
      Operations:
               1. create job script based on job template and available info
               2. submit the job json script to awe
 
Use case 2: submit a job with a local input file and a pipeline template (input file is local and will be uploaded to shock automatially;
      Required options: -upload, -pipeline, -awe (if AWE_HOST not in ENV), -shock (if SHOCK_HOST not in ENV)
      Optional options: -name, -user, -project, -cgroups
      Operations:
               1. upload input file to shock
               2. create job script based on job template and available info
               3. submit the job json script to awe
               
Use case 3: submit a job with a complete job json script (job script is already instantiated, suitable for recomputation)
      Required options: -script, -awe
      Optional options: none  (all needed info is in the job script)
      Operations: submit the job json script to awe directly.
      
note:
1. the three use cases are mutual exclusive: at least one and only one of -node, -upload, and -upload can be specified at one time.
2. if AWE_HOST (ip:port) and SHOCK_HOST (ip:port) are configured as environment variables, -awe and -shock are not needed respectively. But
the specified -awe and -shock will over write the preconfigured environment variables.
 
5 prepare a pipeline template:
 
A sample pipeline template is available at:
 
https://github.com/MG-RAST/AWE/blob/master/templates/pipeline_templates/simple_example.template
 
(The hashtag #xxx will be replaced by words with real information by the command line arguments of the job submitter.)
 
The template is a json struct which contains two main field: Info and Task List:
Info part can be reused for any pipeline.
Task list part is specific for different pipelines.
For each task, following required field needs to be defined:
Taskid: a number to representing this task
Cmd.name: the command name 
Cmd.args, if it is the input file, use @ before the word. 
DependOn: the ids of the tasks it depends on
Input: the input file name, shock host, and node, if node is unknown (for some intermediate files), use “-“ or just omit this field
Output: the output filename, shock host, and node, if node is unknown (for some intermediate files), use “-“
PartInfo: specify which input and output will be split and merge
TotalWork: the number of workunits to be split for this task.
MaxWorkSize: controls the max size (MB) of each split, have higher priority than TotalWork
 
6 check queue status
 
Queue status on the awe-server can be view by running the command AWE/utils/awe_qstat.pl
 
awe_qstat.pl –awe=awe-server:port [-r]
 
Following message will be shown:
 
+++++AWE server queue status+++++
total jobs .......... 10
    in-progress: (10)
    suspended:   (0)
total tasks ......... 57
    pending:     (9)
    completed:   (38)
    suspended:   (0)
total workunits ..... 21
    queuing:     (0)
    checkout:    (21)
    suspended:   (0)
total clients ....... 9
    busy:        (7)
    idle:        (2)
    suspend:     (0)
---last update: 2013-03-11 02:01:25.395572 +0000 UTC
 
There are other APIs supported to query the information of Job and workunits. Detaild API usage can be found below:
 



#!/bin/bash

echo "Installing MG-RAST-Tools and dependencies"
echo "script created from history with Wolfgang's help setting it up first time"

cd /home/ubuntu/git
git clone https://github.com/MG-RAST/MG-RAST-Tools.git
git clone https://github.com/MG-RAST/Shock.git
git clone https://github.com/MG-RAST/Shock.git
git clone https://github.com/wgerlach/USAGEPOD.git
cd /usr/share/perl5
sudo ln -s /home/ubuntu/git/Shock/libs/SHOCK/
sudo ln -s /home/ubuntu/git/AWE/utils/lib/AWE/
sudo ln -s /home/ubuntu/git/USAGEPOD/lib/USAGEPOD.pm
cd /usr/local/bin/
sudo ln -s /home/ubuntu/git/MG-RAST-Tools/tools/bin/mg-awe-submit.pl

cat >>/home/ubuntu/.profile<<EOF

export AWE_SERVER_URL=http://140.221.84.148:8000
export AWE_CLIENT_GROUP=am_compute
export SHOCK_SERVER_URL=http://shock.metagenomics.anl.gov:80
EOF

echo "Done installing MG-RAST-Tools"
echo "Try this command to check:"
echo "mg-awe-submit.pl --status"
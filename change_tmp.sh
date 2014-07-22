#!/bin/sh                                                                                                                                                
#### Change default temp directory to a different location
#### make sure this is executable
#### place it in /home/ubuntu/bin
#### and add the following line to /etc/rc.local
#### sh /home/ubuntu/bin/change_tmp.sh
                                                                                                        
# define variables
log="/home/ubuntu/change_tmp.sh.log";                                                                                                                                       
tmp_link="/tmp";
new_tmp="/mnt/tmp";
current_tmp=`readlink $tmp_link`;

# delete the old log if it is there
if [ -e $log ]; then
    sudo rm $log;
    sudo echo "deleted the old log ( $log ) and started this one" >> $log
    sudo echo >> $log
fi; 

# make sure that new_tmp exists -- create it if it doesn't
if [ ! -d $new_tmp ]; then
    sudo echo "( $new_tmp ) does not exist" >> $log;
    sudo chmod -R 777 /mnt/;
    sudo mkdir $new_tmp;
    sudo chmod -R 777 $new_tmp;
    sudo echo "now ( $new_tmp ) does exist" >> $log;
    sudo echo >> $log;
fi;

# make sure that current_tmp has a value, if not, give it one that can be changed below                                                 
if [ -z $current_tmp ]; then
    sudo echo "$tmp_link links to: ( $current_tmp )  (which you can't see because doesn't exist)" >> $log
    current_tmp="NA";
    sudo echo "now it links to $current_tmp" >> $log
    sudo echo >> $log;
fi;

# create link to new tmp directory                                                                                                 
if [ $current_tmp != $new_tmp ]; then
    sudo echo "$tmp_link should link to ( $new_tmp ) but it links to ( $current_tmp ) instead. Fixing this now.">> $log
    sudo rm -rf $tmp_link;
    sudo ln -s $new_tmp $tmp_link;
    sudo echo "( $tmp_link ) did point to: ( $current_tmp )" >> $log;
    sudo echo "( $tmp_link ) now points to: ( $new_tmp )" >> $log;
else
    sudo echo "$tmp_link already points to:$new_tmp" >> $log;
fi;
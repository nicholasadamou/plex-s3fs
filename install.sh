#!/bin/bash

# This sourced 16 scripts to determine if it should use apt... then uses apt no matter what.
# This does the same thing.
echo -e "\e[38;5;54m  Install 'plex-s3fs'\n\n\e[0m";

if [[ $EUID -eq 0 ]]; then echo "This script cannot be run as root or using sudo!"; exit 1; fi;

# install plex and s3fs
sudo apt-get update;
sudo apt-get install -y snapd;
sudo apt-get install -y s3fs || sudo apt-get install -y s3fs-fuse;
sudo snap install plexmediaserver;

# Collect information on s3 bucket
echo -ne "Enter S3 Bucket Name: " ; read bucket_name; echo -e '\n';
echo -ne "Enter AWS Secret Key ID: " ; read secret_key_id; echo -e '\n';
echo -ne "Enter AWS Secret Key: " ; read secret_key; echo -e '\n';

# APPEND!! (not overwrite!) Bucket name Amazon AWS Secret Key & ID.
echo "${bucket_name}:${secret_key_id}:${secret_key}" | sudo tee -a "/etc/passwd-s3fs" &>/dev/null
sudo sort -u /etc/passwd-s3fs # safely remove duplicate lines
sudo chmod 600 "/etc/passwd-s3fs" # set required perms.
sudo chown $SUDO_USER "/etc/passwd-s3fs" # make sure user can access

# Make sure the mount point exists and is empty/unmounted
sudo mkdir -p "/mnt/${bucket_name}" &>/dev/null # only root can mkdir in /mnt
fusermount -u "/mnt/${bucket_name}" || sudo umount "/mnt/${bucket_name}" &>/dev/null
sudo chown $SUDO_USER "/etc/passwd-s3fs" # make sure user can access

# Make the Amazon AWS S3 Bucket mount on boot.
payload="s3fs#${bucket_name} /mnt/${bucket_name} fuse _netdev,rw,nosuid,nodev,allow_other,nonempty 0 0";
grep -Fq "${payload}" /etc/fstab || echo "${payload}" | sudo tee -a /etc/fstab &>/dev/null

# Mount the S3 Bucket
mount -a || sudo mount -a;

# Why not automate this?
#echo -e "\e[38;5;54m  We need to obtain the required claim token. To do this, you will need to use ssh tunneling to gain access and setup the server for first run. During the first run, you setup Plex to make it available and configurable. However, this setup option will only be triggered if you access it over http://localhost:32400/web, it will not be triggered if you access it over http://ip_of_server:32400/web. Since we are setting up PMS (Plex Media Server) on a headless server, you can use a SSH tunnel to link http://localhost:32400/web (on your current computer) to http://localhost:32400/web (on the headless server running PMS) by executing: ssh username@ip_of_server -L 32400:ip_of_server:32400 -N";

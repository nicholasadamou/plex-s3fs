#!/bin/bash

declare current_dir && \
    current_dir="$(dirname "${BASH_SOURCE[0]}")" && \
    cd "${current_dir}" && \
    source <(curl -s "https://raw.githubusercontent.com/nicholasadamou/utilities/master/utilities.sh")

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

main() {

	print_in_purple "  Configure 'plex-s3fs'\n\n"

	# Ask for SUDO permissions.
	ask_for_sudo

	# Update the system first.
	sudo apt update && \
		sudo apt upgrade -y && \
		sudo apt autoremove -y && \
		sudo apt clean

	# Install Plex-Media-Server via Snap.
	install_snap_package "plexmediaserver"

	# Install s3fs using APT.
	install_package "s3fs"

	# Obtain Amazon AWS S3 Bucket Name.
	ask "Enter Amazon AWS S3 Bucket Name: " ; bucket_name=$(get_answer)

	# Obtain Amazon AWS Secret Key & ID.
	ask "Enter Amazon AWS Secret Key ID: " ; secret_key_id=$(get_answer)
	ask "Enter Amazon AWS Secret Key: " ; secret_key=$(get_answer)

	# Write Amazon AWS Secret Key & ID to '/etc/passwd-s3fs'.
	echo "${secret_key_id}:${secret_key}" > "/etc/passwd-s3fs"

	# Change the permissions of '/etc/passwd-s3fs'.
	sudo chmod 600 "/etc/passwd-s3fs"

	# Make sure the mount point exists. If not, create it.
	if ! [ -d "/mnt/${bucket_name}" ]; then
		mkdir -p "/mnt/${bucket_name}"
	fi

	# Make the Amazon AWS S3 Bucket mount on boot.
	payload="s3fs#${bucket_name} /mnt/${bucket_name} fuse _netdev,rw,nosuid,nodev,allow_other,nonempty 0 0"
	grep -Fq "${payload}" /etc/fstab || {
		echo "${payload}" >> /etc/fstab
	}
	
	# Mount the S3 Bucket
	mount -a

	print_warning "We need to obtain the required claim token. To do this, you will need to use ssh tunneling to gain access and setup the server for first run. During the first run, you setup Plex to make it available and configurable. However, this setup option will only be triggered if you access it over http://localhost:32400/web, it will not be triggered if you access it over http://ip_of_server:32400/web. Since we are setting up PMS (Plex Media Server) on a headless server, you can use a SSH tunnel to link http://localhost:32400/web (on your current computer) to http://localhost:32400/web (on the headless server running PMS) by executing: ssh username@ip_of_server -L 32400:localhost:32400 -N"

}

main


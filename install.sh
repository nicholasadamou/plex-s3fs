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
	execute \
		"sudo apt update && \
			sudo apt upgrade -y && \
			sudo apt autoremove -y && \
			sudo apt clean" \
		"Debian (Install all available updates)"

	# Install Plex-Media-Server via Snap.
	install_snap_package "plexmediaserver" "" "plexmediaserver"

	# Install s3fs using APT.
	install_package "s3fs" "s3fs"

	# Obtain Amazon AWS S3 Bucket Name.
	bucket_name=$(ask "Enter Amazon AWS S3 Bucket Name: ")

	# Obtain Amazon AWS Secret Key & ID.
	secret_key_id=$(ask "Enter Amazon AWS Secret Key ID: ")
	secret_key=$(ask "Enter Amazon AWS Secret Key: ")

	# Write Amazon AWS Secret Key & ID to '$HOME/.passwd-s3fs'.
	echo "${secret_key_id}:${secret_key}" > "$HOME/.passwd-s3fs"

	# Change the permissions of '${HOME}/.passwd-s3fs'.
	sudo chmod 600 "${HOME}/.passwd-s3fs"

	# Determine where to mount the S3 Bucket to on the file-system.
	mount_point="$(ask "Where do you want to mount the S3 Bucket to? (e.g. /mnt/Plex): ")"

	# Make sure the mount point exists. If not, create it.
	if ! [ -d "${mount_point}" ]; then
		mkdir -p "${mount_point}"
	fi

	# Make the Amazon AWS S3 Bucket mount on boot.
	payload="s3fs#${bucket_name} ${mount_point} fuse.s3fs rw,nosuid,nodev,allow_other 0 0"
	grep -Fq "${payload}" /etc/fstab || {
		echo "${payload}" >> /etc/fstab
	}
	
	# Mount the S3 Bucket
	mount -a

	# Run 's3fs' on boot.
	payload="@reboot s3fs ${bucket_name} ${mount_point} -o passwd_file=${HOME}/.passwd-s3fs"
	grep -Fq "$payload" /etc/cron.d/s3fs || {
		echo "${payload}" > /etc/cron.d/s3fs
	}

	print_warning "We need to obtain the required claim token. To do this, you will  need to use ssh tunneling to gain access and setup the server for first run. During the first run, you setup Plex to make it available and configurable. However, this setup option will only be triggered if you access it over http://localhost:32400/web, it will not be triggered if you access it over http://ip_of_server:32400/web. Since we are setting up PMS (Plex Media Server) on a headless server, you can use a SSH tunnel to link http://localhost:32400/web (on your current computer) to http://localhost:32400/web (on the headless server running PMS) by executing: ssh username@ip_of_server -L 32400:ip_of_server:32400 -N"

}


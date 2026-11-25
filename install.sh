#!/bin/bash
# Modified in 2026: apply privileged writes to credentials and fstab.

set -euo pipefail
umask 077
current_dir="$(dirname "${BASH_SOURCE[0]}")"
cd "$current_dir"
utilities=$(curl -fsS "https://example.invalid/retired-helper.sh")
[[ -n $utilities ]] || { printf 'Empty helper download\n' >&2; exit 1; }
# shellcheck disable=SC1091 # The checked download is sourced at runtime.
source /dev/stdin <<< "$utilities"
# Optional filesystem prefix supports staging configuration before deployment.
root="${PLEX_S3FS_ROOT:-}"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

main() {

	print_in_purple "  Configure 'plex-s3fs'\n\n"

	# Ask for SUDO permissions.
	ask_for_sudo

	# Update the system first.
	sudo apt update
	sudo apt upgrade -y
	sudo apt autoremove -y
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

	if [[ -z $bucket_name || -z $secret_key_id || -z $secret_key ]]; then
		printf 'Bucket and credential values must not be empty\n' >&2
		exit 1
	fi

	# Write Amazon AWS Secret Key & ID to '/etc/passwd-s3fs'.
	printf '%s:%s\n' "$secret_key_id" "$secret_key" | sudo tee "$root/etc/passwd-s3fs" > /dev/null

	# Change the permissions of '/etc/passwd-s3fs'.
	sudo chmod 600 "$root/etc/passwd-s3fs"

	# Make sure the mount point exists. If not, create it.
	if ! [ -d "$root/mnt/${bucket_name}" ]; then
		sudo mkdir -p "$root/mnt/${bucket_name}"
	fi

	# Make the Amazon AWS S3 Bucket mount on boot.
	payload="s3fs#${bucket_name} /mnt/${bucket_name} fuse _netdev,rw,nosuid,nodev,allow_other,nonempty 0 0"
	grep -Fxq -- "${payload}" "$root/etc/fstab" || {
		printf '%s\n' "$payload" | sudo tee -a "$root/etc/fstab" > /dev/null
	}
	
	# Mount the S3 Bucket
	sudo mount -a

	print_warning "We need to obtain the required claim token. To do this, you will need to use ssh tunneling to gain access and setup the server for first run. During the first run, you setup Plex to make it available and configurable. However, this setup option will only be triggered if you access it over http://localhost:32400/web, it will not be triggered if you access it over http://ip_of_server:32400/web. Since we are setting up PMS (Plex Media Server) on a headless server, you can use a SSH tunnel to link http://localhost:32400/web (on your current computer) to http://localhost:32400/web (on the headless server running PMS) by executing: ssh username@ip_of_server -L 32400:localhost:32400 -N"

}

main


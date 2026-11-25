#!/bin/bash
# Modified in 2026: use direct system commands and privileged configuration writes.
set -euo pipefail
umask 077
# Optional filesystem prefix stages files; package installation and mounting still run.
root="${PLEX_S3FS_ROOT:-}"

printf "Configure plex-s3fs\n"
read -r -p 'Amazon S3 bucket name: ' bucket_name || { printf 'Missing bucket name\n' >&2; exit 1; }
read -rs -p 'AWS access key ID: ' secret_key_id || { printf 'Missing access key ID\n' >&2; exit 1; }
printf '\n' >&2
read -rs -p 'AWS secret access key: ' secret_key || { printf 'Missing secret access key\n' >&2; exit 1; }
printf '\n' >&2
if [[ -z $bucket_name || -z $secret_key_id || -z $secret_key ]]; then
    printf 'Bucket and credential values must not be empty\n' >&2
    exit 1
fi

sudo -v
sudo apt update
sudo apt upgrade -y
sudo apt autoremove -y
sudo apt clean
sudo snap install plexmediaserver
sudo apt install -y s3fs

printf '%s:%s\n' "$secret_key_id" "$secret_key" | sudo tee "$root/etc/passwd-s3fs" > /dev/null
sudo chmod 600 "$root/etc/passwd-s3fs"
if [[ ! -d "$root/mnt/$bucket_name" ]]; then
    sudo mkdir -p "$root/mnt/$bucket_name"
fi
payload="s3fs#$bucket_name /mnt/$bucket_name fuse _netdev,rw,nosuid,nodev,allow_other,nonempty 0 0"
if ! grep -Fxq -- "$payload" "$root/etc/fstab"; then
    printf '%s\n' "$payload" | sudo tee -a "$root/etc/fstab" > /dev/null
fi
sudo mount -a
printf 'Configure Plex through an SSH tunnel: ssh -L 32400:localhost:32400 -N username@server-address\n'
printf 'Then open http://localhost:32400/web on your computer.\n'

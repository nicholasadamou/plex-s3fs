#!/usr/bin/env bash
# Contract fixture for the remotely retrieved helpers, not their implementation.
print_in_purple() { printf '%s\n' "$*"; }
print_warning() { printf '%s\n' "$*"; }
ask_for_sudo() { sudo -v; }
install_snap_package() { sudo snap install "$@"; }
install_package() { sudo apt install "$@"; }
ask() {
    case "$*" in
        'Enter Amazon AWS S3 Bucket Name: ') answer=${TEST_BUCKET-media} ;;
        'Enter Amazon AWS Secret Key ID: ') answer=${TEST_KEY_ID-fixture-id} ;;
        'Enter Amazon AWS Secret Key: ') answer=${TEST_SECRET-fixture-secret} ;;
        *) return 93 ;;
    esac
}
get_answer() { printf '%s' "$answer"; }

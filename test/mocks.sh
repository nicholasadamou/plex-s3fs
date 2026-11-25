#!/usr/bin/env bash
# These exported functions intercept subprocess dependencies; PATH has no fallbacks.
curl() {
    [[ $# == 2 ]] || return 91
    [[ "$*" == '-fsS https://example.invalid/retired-helper.sh' ]] || return 91
    [[ ${FAIL_COMMAND:-} != curl ]] || return 23
    /bin/cat "$FIXTURE/utilities.sh"
}
sudo() {
    # Fixtures use whitespace-free arguments; reject merged argument boundaries.
    local argument
    for argument; do [[ $argument != *[[:space:]]* ]] || return 92; done
    printf '%s\n' "$*" >> "$FIXTURE/commands"
    [[ ${FAIL_COMMAND:-} != "$*" ]] || return 23
    case "$*" in
        '-v'|'apt update'|'apt upgrade -y'|'apt autoremove -y'|'apt clean'|'apt install s3fs'|'snap install plexmediaserver'|'mount -a') ;;
        "tee $PLEX_S3FS_ROOT/etc/passwd-s3fs"|"tee -a $PLEX_S3FS_ROOT/etc/fstab") /usr/bin/tee "${@:2}" ;;
        "chmod 600 $PLEX_S3FS_ROOT/etc/passwd-s3fs") /usr/bin/chmod "${@:2}" ;;
        "mkdir -p $PLEX_S3FS_ROOT/mnt/media") /usr/bin/mkdir "${@:2}" ;;
        *) printf 'Unexpected privileged command\n' >&2; return 92 ;;
    esac
}
export -f curl sudo

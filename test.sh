#!/usr/bin/env bash
set -Eeuo pipefail
if [[ $EUID == 0 || ! -d /app || -w /app || -e /var/run/docker.sock ]]; then
    printf 'Run verification in the restricted Docker container documented in docs/development.md.\n' >&2
    exit 1
fi
shellcheck install.sh test.sh
trap 'printf "Integration assertion failed at line %s\n" "$LINENO" >&2' ERR
export FIXTURE
FIXTURE=$(mktemp -d)
trap 'rm -rf "$FIXTURE"' EXIT
mkdir "$FIXTURE/bin"
ln -s /usr/bin/grep "$FIXTURE/bin/"
# These exported functions intercept subprocess dependencies; PATH has no fallbacks.
sudo() {
    # Fixtures use whitespace-free arguments; reject merged argument boundaries.
    local argument
    for argument; do [[ $argument != *[[:space:]]* ]] || return 92; done
    printf '%s\n' "$*" >> "$FIXTURE/commands"
    [[ ${FAIL_COMMAND:-} != "$*" ]] || return 23
    case "$*" in
        '-v'|'apt update'|'apt upgrade -y'|'apt autoremove -y'|'apt clean'|'apt install -y s3fs'|'snap install plexmediaserver'|'mount -a') ;;
        "tee $PLEX_S3FS_ROOT/etc/passwd-s3fs"|"tee -a $PLEX_S3FS_ROOT/etc/fstab") /usr/bin/tee "${@:2}" ;;
        "chmod 600 $PLEX_S3FS_ROOT/etc/passwd-s3fs") /usr/bin/chmod "${@:2}" ;;
        "mkdir -p $PLEX_S3FS_ROOT/mnt/media") /usr/bin/mkdir "${@:2}" ;;
        *) printf 'Unexpected privileged command\n' >&2; return 92 ;;
    esac
}
export -f sudo
export PLEX_S3FS_ROOT="$FIXTURE/root"
reset() {
    rm -rf "$PLEX_S3FS_ROOT"
    mkdir -p "$PLEX_S3FS_ROOT/etc"
    printf '# preserved\n' > "$PLEX_S3FS_ROOT/etc/fstab"
    : > "$FIXTURE/commands"
    printf 'media\nfixture-id\nfixture-secret\n' > "$FIXTURE/input"
}
run() { PATH="$FIXTURE/bin" /bin/bash "$PWD/install.sh" < "$FIXTURE/input" > "$FIXTURE/output" 2>&1; }
private_output() {
    if grep -Eq 'fixture-id|fixture-secret' "$FIXTURE/output" "$FIXTURE/commands"; then
        printf 'Credential leaked into captured output or command log\n' >&2
        exit 1
    fi
}
reset
run
printf 'fixture-id:fixture-secret\n' | cmp - "$PLEX_S3FS_ROOT/etc/passwd-s3fs"
[[ $(stat -c %a "$PLEX_S3FS_ROOT/etc/passwd-s3fs") == 600 ]]
[[ -d "$PLEX_S3FS_ROOT/mnt/media" ]]
printf '# preserved\ns3fs#media /mnt/media fuse _netdev,rw,nosuid,nodev,allow_other,nonempty 0 0\n' | cmp - "$PLEX_S3FS_ROOT/etc/fstab"
cat <<EOF | cmp - "$FIXTURE/commands"
-v
apt update
apt upgrade -y
apt autoremove -y
apt clean
snap install plexmediaserver
apt install -y s3fs
tee $PLEX_S3FS_ROOT/etc/passwd-s3fs
chmod 600 $PLEX_S3FS_ROOT/etc/passwd-s3fs
mkdir -p $PLEX_S3FS_ROOT/mnt/media
tee -a $PLEX_S3FS_ROOT/etc/fstab
mount -a
EOF
private_output
cp "$PLEX_S3FS_ROOT/etc/fstab" "$FIXTURE/expected-fstab"
: > "$FIXTURE/commands"
run
cmp "$FIXTURE/expected-fstab" "$PLEX_S3FS_ROOT/etc/fstab"
if grep -Eq 'mkdir|tee -a' "$FIXTURE/commands"; then exit 1; fi
private_output
for failure in "chmod 600 $PLEX_S3FS_ROOT/etc/passwd-s3fs" '-v' 'apt update' 'apt upgrade -y' 'apt autoremove -y' 'apt clean' 'snap install plexmediaserver' 'apt install -y s3fs' "tee $PLEX_S3FS_ROOT/etc/passwd-s3fs" "mkdir -p $PLEX_S3FS_ROOT/mnt/media" "tee -a $PLEX_S3FS_ROOT/etc/fstab" 'mount -a'; do
    reset
    if FAIL_COMMAND="$failure" run; then printf 'Failure did not abort: %s\n' "$failure" >&2; exit 1; fi
    private_output
    [[ $failure == 'mount -a' ]] || ! grep -Fxq 'mount -a' "$FIXTURE/commands"
    [[ $(tail -n 1 "$FIXTURE/commands") == "$failure" ]]
done
# Empty fields and EOF at each prompt must fail before sudo or filesystem writes.
for input in '\nfixture-id\nfixture-secret\n' 'media\n\nfixture-secret\n' 'media\nfixture-id\n\n' '' 'media\n' 'media\nfixture-id\n'; do
    reset
    printf '%b' "$input" > "$FIXTURE/input"
    if run; then printf 'Invalid input accepted\n' >&2; exit 1; fi
    [[ ! -s "$FIXTURE/commands" ]]
    [[ ! -e "$PLEX_S3FS_ROOT/etc/passwd-s3fs" ]]
    [[ ! -d "$PLEX_S3FS_ROOT/mnt/media" ]]
    private_output
done
reset
if { sudo unexpected-command; } > "$FIXTURE/output" 2>&1; then exit 1; fi
if { sudo apt 'upgrade -y'; } > "$FIXTURE/output" 2>&1; then exit 1; fi
for command in 'apt update' 'curl https://unexpected.invalid' 'snap install plexmediaserver' 'mount -a'; do
    if PATH="$FIXTURE/bin" /bin/bash -c "$command" > "$FIXTURE/output" 2>&1; then exit 1; fi
done
printf 'Actual installer integration passed: files, modes, commands, rerun, and failure aborts.\n'

#!/usr/bin/env bash
set -Eeuo pipefail
trap 'printf "Integration assertion failed at line %s\n" "$LINENO" >&2' ERR
export FIXTURE
FIXTURE=$(mktemp -d)
trap 'rm -rf "$FIXTURE"' EXIT
mkdir "$FIXTURE/bin"
ln -s /usr/bin/dirname /usr/bin/grep "$FIXTURE/bin/"
cp test/utilities.sh "$FIXTURE/utilities.sh"
source test/mocks.sh
export PLEX_S3FS_ROOT="$FIXTURE/root"
reset() {
    rm -rf "$PLEX_S3FS_ROOT"
    mkdir -p "$PLEX_S3FS_ROOT/etc"
    printf '# preserved\n' > "$PLEX_S3FS_ROOT/etc/fstab"
    : > "$FIXTURE/commands"
}
run() { PATH="$FIXTURE/bin" /bin/bash "$PWD/install.sh" > "$FIXTURE/output" 2>&1; }
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
apt install s3fs
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
for failure in "chmod 600 $PLEX_S3FS_ROOT/etc/passwd-s3fs" curl '-v' 'apt update' 'apt upgrade -y' 'apt autoremove -y' 'apt clean' 'snap install plexmediaserver' 'apt install s3fs' "tee $PLEX_S3FS_ROOT/etc/passwd-s3fs" "mkdir -p $PLEX_S3FS_ROOT/mnt/media" "tee -a $PLEX_S3FS_ROOT/etc/fstab" 'mount -a'; do
    reset
    if FAIL_COMMAND="$failure" run; then printf 'Failure did not abort: %s\n' "$failure" >&2; exit 1; fi
    private_output
    [[ $failure == 'mount -a' ]] || ! grep -Fxq 'mount -a' "$FIXTURE/commands"
    if [[ $failure == curl ]]; then
        [[ ! -s "$FIXTURE/commands" ]]
        [[ ! -e "$PLEX_S3FS_ROOT/etc/passwd-s3fs" ]]
    else
        [[ $(tail -n 1 "$FIXTURE/commands") == "$failure" ]]
    fi
done
for variable in TEST_BUCKET TEST_KEY_ID TEST_SECRET; do
    reset
    export "$variable="
    if run; then printf 'Empty input accepted: %s\n' "$variable" >&2; exit 1; fi
    unset "$variable"
    [[ ! -e "$PLEX_S3FS_ROOT/etc/passwd-s3fs" ]]
    [[ ! -d "$PLEX_S3FS_ROOT/mnt/media" ]]
    private_output
    [[ $(tail -n 1 "$FIXTURE/commands") == 'apt install s3fs' ]]
done
reset
if { sudo unexpected-command; } > "$FIXTURE/output" 2>&1; then exit 1; fi
if PATH="$FIXTURE/bin" /bin/bash -c 'apt update' > "$FIXTURE/output" 2>&1; then exit 1; fi
if curl https://unexpected.invalid > "$FIXTURE/output" 2>&1; then exit 1; fi
for helper in '' false; do
    reset
    printf '%s' "$helper" > "$FIXTURE/utilities.sh"
    if run; then printf 'Broken helper import did not abort\n' >&2; exit 1; fi
    [[ ! -s "$FIXTURE/commands" ]]
    private_output
done
printf 'Actual installer integration passed: files, modes, commands, rerun, and failure aborts.\n'

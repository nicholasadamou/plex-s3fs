#!/usr/bin/env bash
set -euo pipefail
repository_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
docker build --file "$repository_root/test/Dockerfile" \
    --tag plex-s3fs-verify "$repository_root"
docker run --rm --network none --read-only --cap-drop ALL \
    --tmpfs /tmp:rw,nosuid,nodev,size=256m --pids-limit 256 \
    --security-opt no-new-privileges plex-s3fs-verify

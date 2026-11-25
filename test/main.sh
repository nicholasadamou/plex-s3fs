#!/usr/bin/env bash
set -euo pipefail

cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.."

for script in install.sh test/main.sh test/verify.sh; do
    bash -n "$script"
done

# The installer sources remote utilities at runtime; verification stays offline.
shellcheck --exclude=SC1090 install.sh
shellcheck test/main.sh test/verify.sh

printf 'plex-s3fs verification passed (shell syntax and ShellCheck).\n'

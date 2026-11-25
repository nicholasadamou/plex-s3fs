#!/usr/bin/env bash
set -euo pipefail
cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.."
export PATH="$PWD/node_modules/.bin:$PATH"

mapfile -d '' scripts < <(find . -path ./node_modules -prune -o -name '*.sh' -print0)
for script in "${scripts[@]}"; do bash -n "$script"; done
# The installer sources remote utilities; static analysis must stay offline.
shellcheck --exclude=SC1090 "${scripts[@]}"
bash test/integration.sh
markdownlint-cli2 '**/*.md' '#node_modules'
while IFS= read -r -d '' document; do
    output="/tmp/rendered/${document#./}"
    mkdir -p "$(dirname -- "$output")"
    mmdc -p test/puppeteer.json -i "$document" -o "$output"
done < <(find . -path ./node_modules -prune -o -name '*.md' -print0)

# Negative controls prove the validators reject broken inputs.
reject() {
    if "$@" > /tmp/rejected.log 2>&1; then
        printf 'Expected rejection: %s\n' "$*" >&2
        exit 1
    fi
}
printf '# Broken\n### Skipped heading\n' > /tmp/invalid.md
reject markdownlint-cli2 --config .markdownlint-cli2.jsonc /tmp/invalid.md
# Literal fences and variables form intentionally invalid fixtures.
# shellcheck disable=SC2016
printf '# Invalid diagram\n\n```mermaid\nflowchart LR\nA --> [\n```\n' > /tmp/invalid-diagram.md
reject mmdc -p test/puppeteer.json -i /tmp/invalid-diagram.md -o /tmp/invalid-output.md
# shellcheck disable=SC2016
printf '#!/bin/bash\necho $unquoted\n' > /tmp/invalid.sh
reject shellcheck /tmp/invalid.sh
printf '#!/bin/bash\nif then\n' > /tmp/syntax.sh
reject bash -n /tmp/syntax.sh

# Count every source/config file, including future additions, excluding content and locks.
mapfile -d '' sources < <(find . \
    \( -path ./node_modules -o -path ./assets -o -path ./docs -o -path ./LICENSES \) -prune -o \
    -type f ! -name '*.md' ! -name '*.lock' ! -name LICENSE ! -name NOTICE -print0)
lines=$(cat "${sources[@]}" | awk 'NF { count++ } END { print count }')
printf 'Handwritten verification/code/config: %s / 350 nonblank lines\n' "$lines"
(( lines <= 350 ))
printf 'Shell, Markdown, Mermaid rendering, installer integration, negative controls, and LOC budget passed.\n'

#!/usr/bin/env bash
set -euo pipefail
expected_version="${1:?Usage: check-image.sh OPENCLAW_VERSION}"
[[ "$(id -u)" == 1000 && "$(id -g)" == 1600 ]] || { echo 'Unexpected runtime UID/GID' >&2; exit 1; }
[[ "$HOME" == /home/node && -w /home/node ]] || { echo 'Invalid or unwritable HOME' >&2; exit 1; }
for tool in openclaw ssh scp gh rg jq rsync fd tree file less unzip zip shellcheck shfmt ffmpeg ffprobe convert identify exiftool mediainfo; do
    command -v "$tool" >/dev/null || { echo "Missing tool: $tool" >&2; exit 1; }
done
actual_version="$(openclaw --version)"
# Match the exact version token, with an optional v prefix.
if ! printf '%s\n' "$actual_version" | tr ' ()' '\n' | grep -Fxq -e "$expected_version" -e "v$expected_version"; then
    printf 'Version mismatch: expected %s, got %s\n' "$expected_version" "$actual_version" >&2
    exit 1
fi
ffmpeg -version >/dev/null
convert -version >/dev/null
exiftool -ver >/dev/null
mediainfo --Version >/dev/null
printf 'PASS: %s; UID/GID=%s:%s; required tools available\n' "$actual_version" "$(id -u)" "$(id -g)"

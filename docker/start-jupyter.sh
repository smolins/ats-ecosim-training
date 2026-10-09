#!/usr/bin/env bash
set -euo pipefail

mkdir -p /home/training/work
cp -Rn /opt/ats-ecosim-training/course/. /home/training/work/
# Keep the index aligned with this image when an existing workspace is reused.
cp /opt/ats-ecosim-training/course/reference/CURRENT.md /home/training/work/reference/CURRENT.md

export JUPYTER_TOKEN="${JUPYTER_TOKEN:-$(python -c 'import secrets; print(secrets.token_urlsafe(32))')}"
echo "Open http://127.0.0.1:${ATS_ECOSIM_PUBLIC_PORT:-8888}/lab?token=${JUPYTER_TOKEN}"

# Warm the large OpenCode binary before Jupyter AI's short `opencode --version`
# check, and log slow starts (slow disk, limited CPU, or emulation).
start=$SECONDS
if ! timeout 120 opencode --version >/dev/null 2>&1; then
  echo "Warning: 'opencode --version' failed; the OpenCode persona may be unavailable." >&2
elif (( SECONDS - start > 5 )); then
  echo "Note: OpenCode took $((SECONDS - start)) s to start (slow disk/CPU or emulation)." >&2
fi

exec jupyter lab --ip=0.0.0.0 --port=8888 --no-browser \
  --ServerApp.root_dir=/home/training/work

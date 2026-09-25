#!/usr/bin/env bash
set -euo pipefail

mkdir -p /home/training/work
cp -Rn /opt/ats-ecosim-training/course/. /home/training/work/

export JUPYTER_TOKEN="${JUPYTER_TOKEN:-$(python -c 'import secrets; print(secrets.token_urlsafe(32))')}"
echo "Open http://127.0.0.1:${ATS_ECOSIM_PUBLIC_PORT:-8888}/lab?token=${JUPYTER_TOKEN}"

exec jupyter lab --ip=0.0.0.0 --port=8888 --no-browser \
  --ServerApp.root_dir=/home/training/work

#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
image="${ATS_ECOSIM_IMAGE:-ats-ecosim-training:local}"
workspace="${ATS_ECOSIM_WORKSPACE:-${repo_root}/work}"
config="${ATS_ECOSIM_OPENCODE_CONFIG:-}"
key_name="${ATS_ECOSIM_KEY_ENV:-ATS_ECOSIM_API_KEY}"
port="${ATS_ECOSIM_PORT:-8888}"

if [[ ! "$key_name" =~ ^[A-Za-z_][A-Za-z0-9_]*$ ]]; then
  echo "Invalid API key environment variable name: ${key_name}" >&2
  exit 2
fi
if [[ ! "$port" =~ ^[0-9]+$ ]]; then
  echo "ATS_ECOSIM_PORT must be numeric" >&2
  exit 2
fi

mkdir -p "$workspace"
workspace="$(cd "$workspace" && pwd -P)"
docker_args=(--rm -it --init \
  --user "$(id -u):$(id -g)" \
  --env HOME=/home/training/work \
  --env "ATS_ECOSIM_PUBLIC_PORT=${port}" \
  --publish "127.0.0.1:${port}:8888" \
  --mount "type=bind,source=${workspace},target=/home/training/work")

if [[ -n "$config" ]]; then
  if [[ ! -f "$config" ]]; then
    echo "OpenCode config does not exist: ${config}" >&2
    exit 2
  fi
  config="$(cd "$(dirname "$config")" && pwd)/$(basename "$config")"
  docker_args+=(--mount "type=bind,source=${config},target=/home/training/opencode.json,readonly" \
    --env OPENCODE_CONFIG=/home/training/opencode.json)
fi

if [[ -n "${!key_name:-}" ]]; then
  docker_args+=(--env "$key_name")
elif [[ -n "$config" ]]; then
  echo "Set ${key_name} before using the AI assistant." >&2
fi

printf 'Course templates (host): %s/course\n' "$repo_root"
printf 'Editable workspace (host): %s\n' "$workspace"
printf 'Jupyter files (container): /home/training/work\n'
exec docker run "${docker_args[@]}" "$image"

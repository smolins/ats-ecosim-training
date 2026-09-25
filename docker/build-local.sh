#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
tag="${1:-ats-ecosim-training:local}"
amanzi_ref="${AMANZI_REF:-master}"
ats_ref="${ATS_REF:-agraus/ecosim_pk}"
build_jobs="${ATS_ECOSIM_BUILD_JOBS:-1}"
amanzi_commit="${AMANZI_COMMIT:-$(git ls-remote https://github.com/amanzi/amanzi.git "refs/heads/${amanzi_ref}" | awk '{print $1}')}"
ats_commit="${ATS_COMMIT:-$(git ls-remote https://github.com/amanzi/ats.git "refs/heads/${ats_ref}" | awk '{print $1}')}"

if [[ -z "$amanzi_commit" || -z "$ats_commit" ]]; then
  echo "Could not resolve Amanzi or ATS source revision" >&2
  exit 1
fi

echo "Amanzi: ${amanzi_commit}"
echo "ATS: ${ats_commit}"
docker build -f "${repo_root}/docker/Dockerfile.base" -t ats-ecosim-training:base "${repo_root}"
docker build -f "${repo_root}/docker/Dockerfile.tpls" \
  --build-arg BASE_IMAGE=ats-ecosim-training:base \
  --build-arg BUILD_JOBS="$build_jobs" \
  --build-arg AMANZI_REF="$amanzi_ref" \
  --build-arg AMANZI_COMMIT="$amanzi_commit" \
  -t ats-ecosim-training:tpls "${repo_root}"
docker build -f "${repo_root}/docker/Dockerfile.training" \
  --build-arg TPL_IMAGE=ats-ecosim-training:tpls \
  --build-arg BUILD_JOBS="$build_jobs" \
  --build-arg ATS_REF="$ats_ref" \
  --build-arg ATS_COMMIT="$ats_commit" \
  -t "$tag" "${repo_root}"
echo "Built ${tag}"

# CI build of the three image layers with a registry layer cache.
# Run from the repository root: docker buildx bake -f docker/docker-bake.hcl training
# Each layer's FROM resolves to the previous bake target instead of a local tag.

variable "AMANZI_COMMIT" { default = "" }
variable "ATS_COMMIT" { default = "" }
variable "ECOSIM_COMMIT" { default = "" }
variable "SOURCE_REPO" { default = "https://github.com/unknown/ats-ecosim-training" }
variable "TAG" { default = "ats-ecosim-training:local" }
variable "ARCH" { default = "amd64" }
# Registry repository for layer caches; empty disables the cache.
variable "CACHE_REPO" { default = "" }

function "cache_from" {
  params = [layer]
  result = CACHE_REPO == "" ? [] : ["type=registry,ref=${CACHE_REPO}:buildcache-${layer}-${ARCH}"]
}

function "cache_to" {
  params = [layer]
  result = CACHE_REPO == "" ? [] : ["type=registry,ref=${CACHE_REPO}:buildcache-${layer}-${ARCH},mode=max"]
}

target "base" {
  context = "."
  dockerfile = "docker/Dockerfile.base"
  cache-from = cache_from("base")
  cache-to = cache_to("base")
}

target "tpls" {
  context = "."
  dockerfile = "docker/Dockerfile.tpls"
  contexts = { "ats-ecosim-training:base" = "target:base" }
  args = {
    AMANZI_COMMIT = AMANZI_COMMIT
    ECOSIM_COMMIT = ECOSIM_COMMIT
  }
  cache-from = cache_from("tpls")
  cache-to = cache_to("tpls")
}

target "training" {
  context = "."
  dockerfile = "docker/Dockerfile.training"
  contexts = { "ats-ecosim-training:tpls" = "target:tpls" }
  args = {
    ATS_COMMIT = ATS_COMMIT
    ECOSIM_COMMIT = ECOSIM_COMMIT
    SOURCE_REPO = SOURCE_REPO
  }
  tags = [TAG]
  output = ["type=docker"]
  cache-from = cache_from("training")
  cache-to = cache_to("training")
}

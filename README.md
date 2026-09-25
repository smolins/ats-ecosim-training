# ATS–EcoSIM training

A beginner course for running ATS coupled to EcoSIM in JupyterLab. The container
includes a Release ATS build, scientific Python, Jupyter AI, and the OpenCode
agent. Participants use their own API key with an instructor-supplied
`opencode.json`; the course itself can run without AI access.

## Quick start

Install Docker Desktop or a compatible Docker engine. Allow enough disk space
for a scientific simulation image and its output. Once the GitHub release image
is public, pull it and launch from this repository:

```bash
docker pull ghcr.io/<owner>/ats-ecosim-training:latest
export ATS_ECOSIM_IMAGE=ghcr.io/<owner>/ats-ecosim-training:latest
./run-training.sh
```

Replace `<owner>` with the lowercase GitHub repository owner. Open the localhost
URL printed by JupyterLab, including its login token. The script binds port
8888 to `127.0.0.1`, mounts `./work` as the writable course workspace, and
copies lesson files there on first launch. Existing lesson edits and simulation
results persist between runs. Open `01_setup.ipynb` first.

To use a different workspace or host port:

```bash
ATS_ECOSIM_WORKSPACE="$HOME/my-ecosim-work" ATS_ECOSIM_PORT=8899 ./run-training.sh
```

## OpenCode setup

Obtain the instructor's `opencode.json` and the name of the environment
variable its `apiKey` field references. Set that variable in your shell, then
launch with a read-only config mount:

```bash
export MY_ORG_API_KEY='your-key-here'
export ATS_ECOSIM_KEY_ENV=MY_ORG_API_KEY
export ATS_ECOSIM_OPENCODE_CONFIG="$HOME/path/to/opencode.json"
./run-training.sh
```

The script passes the named environment variable to Docker without putting its
value on the command line. Do not add keys to notebooks or the config file.
Jupyter AI should display `@OpenCode` in its sidebar. The Jupyter AI ACP client
launches OpenCode as an agent; a separate OpenCode server is unnecessary.
OpenCode's config supports `{env:MY_ORG_API_KEY}` in the provider's `apiKey`
field. The instructor will provide the endpoint and model definitions. The
instructor config should include `"permission": {"edit": "ask", "bash": "ask"}`
so file edits and shell commands request participant approval.

## Build locally

`docker/build-local.sh` builds the base, Amanzi TPL, and ATS training layers
for the host architecture. It resolves Amanzi `master` and ATS
`agraus/ecosim_pk` to commit IDs at the start of the build and prints them.
You can override them with `AMANZI_COMMIT` and `ATS_COMMIT` to repeat a build.
The build compiles scientific dependencies and may take considerable time.
Local builds default to one compilation job to limit memory use; set
`ATS_ECOSIM_BUILD_JOBS` if your Docker engine has more CPUs and RAM.
The TPL Dockerfile applies a small Amanzi build patch that sets
`NETCDF_ENABLE_TESTS=OFF`. Python's HDF5 and NetCDF packages are installed after
ATS is compiled, so the compiled libraries use Amanzi's HDF5 headers.

```bash
./docker/build-local.sh
./run-training.sh
```

The reference clones in `amanzi/`, `ats-short-course/`, and `ats-demos/` are
excluded from the Docker context. The course inputs and forcing data are
copied into `course/` with the upstream ATS demos license and copyright files.

## Image publication

The GitHub Actions workflow in `.github/workflows/image.yml` builds on native
amd64 and arm64 runners. A version tag such as `v0.1.0` publishes architecture
images and combines them as `ghcr.io/<owner>/ats-ecosim-training:v0.1.0` and
`:latest`. A manual run publishes a commit SHA tag. The workflow uses
`GITHUB_TOKEN` with `packages: write`; the GHCR package must be public for
participants to pull it without signing in. Docker chooses the matching
architecture automatically from the combined tag.

## Troubleshooting

- If port 8888 is occupied, set `ATS_ECOSIM_PORT=8899`.
- If `ats` is missing, confirm you pulled the training image and set
  `ATS_ECOSIM_IMAGE` to its complete tag.
- If OpenCode appears but cannot call the model, confirm the config path,
  environment variable name, key, model, and endpoint with the instructor.
- If a simulation fails, inspect its `ats.log` in the corresponding `.demo`
  directory. The run helper also prints the last 25 log lines.
- On Linux, the launcher runs the container with your host UID and GID so the
  mounted workspace remains writable.

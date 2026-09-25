# ATS–EcoSIM training

A beginner course for running ATS coupled to EcoSIM in JupyterLab. The container
includes a Release ATS build, scientific Python, Jupyter AI, and the OpenCode
agent. Participants can use their own API key with an instructor-supplied
`opencode.json`; the course itself can run without AI access.

## Quick start

Install Docker Desktop or a compatible Docker engine. Allow enough disk space
for a scientific simulation image and its output. Once the GitHub image
is public, pull it and launch from this repository:

```bash
docker pull ghcr.io/smolins/ats-ecosim-training:latest
export ATS_ECOSIM_IMAGE=ghcr.io/smolins/ats-ecosim-training:latest
./run-training.sh
```

Open the localhost URL printed by JupyterLab, including its login token. The
script binds port 8888 to `127.0.0.1`. It prints the absolute host paths for
the course templates and your editable workspace before starting Docker:

| Location | Purpose |
| --- | --- |
| Repository `course/` on the host | Templates packaged in the image; edits here require rebuilding the image. |
| Repository `work/` on the host | Your editable notebooks, inputs, and simulation results. |
| `/home/training/work` in JupyterLab | The same files as host `work/`, mounted into the container. |

The first launch copies course files into `work/`; later launches preserve your
edits and results. Set `ATS_ECOSIM_WORKSPACE` to use a different host folder.
Open `01_setup.ipynb` first.

To use a different workspace or host port:

```bash
ATS_ECOSIM_WORKSPACE="$HOME/my-ecosim-work" ATS_ECOSIM_PORT=8899 ./run-training.sh
```

## OpenCode setup

OpenCode is installed even without an `opencode.json`. In JupyterLab, open a
Jupyter AI chat and choose **OpenCode** from the chat input's persona picker.
After it initializes, a separate model menu appears. To inspect OpenCode's
default model catalog, run `opencode models` in a JupyterLab terminal. Listed
models may still require provider credentials to answer a prompt. A default
catalog does not include the instructor's private models or endpoints.

To use the instructor's models, obtain their `opencode.json` and the name of
the environment variable its `apiKey` field references. Set that variable in
your shell, then launch with a read-only config mount:

```bash
export MY_ORG_API_KEY='your-key-here'
export ATS_ECOSIM_KEY_ENV=MY_ORG_API_KEY
export ATS_ECOSIM_OPENCODE_CONFIG="$HOME/path/to/opencode.json"
./run-training.sh
```

The script passes the named environment variable to Docker without putting its
value on the command line. Do not add keys to notebooks or the config file.
The Jupyter AI ACP client launches OpenCode as an agent; a separate OpenCode
server is unnecessary.
OpenCode's config supports `{env:MY_ORG_API_KEY}` in the provider's `apiKey`
field. The instructor will provide the endpoint and model definitions. The
instructor config should include `"permission": {"edit": "ask", "bash": "ask"}`
so file edits and shell commands request participant approval. The workspace
includes the ATS and EcoSIM source revisions selected for the image under
`reference/`. `AGENTS.md` guides OpenCode to inspect those files and the lesson
XML inputs when answering capability questions, with file citations. Editing
the source copies does not rebuild ATS.

## Build locally

`docker/build-local.sh` builds the base, Amanzi TPL, and ATS training layers
for the host architecture. It resolves Amanzi `master`, ATS
`agraus/ecosim_pk`, and EcoSIM `agraus/PrescribedPhenology` to commit IDs at
the start of the build and prints them. You can override them with
`AMANZI_COMMIT`, `ATS_COMMIT`, and `ECOSIM_COMMIT` to repeat a build.
The build compiles scientific dependencies and may take considerable time.
Local builds default to one compilation job to limit memory use; set
`ATS_ECOSIM_BUILD_JOBS` if your Docker engine has more CPUs and RAM.
A 2 GB Docker VM ran out of memory while compiling Trilinos even with one job;
increase Docker's memory allocation before a clean local build.
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

The container does not set an MPI-rank cap. The supplied examples use a
single-column mesh and are supported with one rank (`ats input.xml`, or
`mpirun -np 1 ats input.xml`). A two-rank run of the current snow example fails
during mesh partitioning. Available CPU cores alone do not determine whether
an ATS case supports multiple ranks; a future parallel example will need an
appropriate mesh and validation.

## Image publication

The GitHub Actions workflow in `.github/workflows/image.yml` builds on native
amd64 and arm64 runners. A version tag such as `v0.1.0` publishes architecture
images and combines them as `ghcr.io/smolins/ats-ecosim-training:v0.1.0` and
`:latest`. A manual run on `main` also publishes `:latest`; every run publishes
a `sha-<commit>` tag. A manual run from another branch publishes only its SHA
tag. Run the updated workflow from `main` once to create `:latest` before using
the quick-start pull command. The workflow uses
`GITHUB_TOKEN` with `packages: write`; the GHCR package must be public for
participants to pull it without signing in. Docker chooses the matching
architecture automatically from the combined tag.

## Troubleshooting

- If port 8888 is occupied, set `ATS_ECOSIM_PORT=8899`.
- If `ats` is missing, confirm you pulled the training image and set
  `ATS_ECOSIM_IMAGE` to its complete tag.
- If OpenCode is missing from the chat persona picker, check that you pulled
  the newest image and inspect `docker logs <container>` for Jupyter extension
  errors. In a JupyterLab terminal, check `opencode --version`,
  `jupyter server extension list`, and `jupyter labextension list`. The model
  picker only appears after a persona starts.
- If OpenCode appears but cannot call the model, confirm the config path,
  environment variable name, key, model, and endpoint with the instructor.
- If a simulation fails, inspect its `ats.log` in the corresponding `.demo`
  directory. The run helper also prints the last 25 log lines.
- On Linux, the launcher runs the container with your host UID and GID so the
  mounted workspace remains writable.

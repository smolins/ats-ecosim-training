# ATS–EcoSIM training

Open the notebooks in order:

1. `01_setup.ipynb` checks the simulation and notebook environment.
2. `02_first_run.ipynb` prepares and runs a short EcoSIM snow simulation.
3. `03_explore_results.ipynb` plots the result and compares snow albedo settings.

The examples come from `ats-demos/14_ecosim` on its `smolins/ecosim` branch.
The provided inputs normally run for 1,826 days. The course helper copies an
input into a separate `.demo` directory and reduces it to 30 days by default.
Forcing files stay beside those run directories under `examples/ecosim/data`.
Simulation output is written to the mounted workspace and is excluded from Git.
The repository's `course/` directory holds templates. The launcher copies them
into the host's `work/` directory on first launch; that editable directory is
`/home/training/work` in JupyterLab. The launcher prints both host paths. A
custom `ATS_ECOSIM_WORKSPACE` replaces host `work/`, and existing edits are
preserved on later launches.

These single-column exercises are supported with one MPI rank. Run them with
`ats input.xml` or `mpirun -np 1 ats input.xml`; the current mesh fails when
partitioned across two ranks.

To use OpenCode, open a Jupyter AI chat and choose it from the chat input's
persona picker. Its model menu appears after the agent initializes. OpenCode
should appear without `opencode.json`; in a JupyterLab terminal, `opencode models`
lists its default model catalog. To use instructor models, mount their config
and provide the API key environment variable described in the top-level README.
The lessons also work without an API key.
For capability questions, the assistant can read the ATS and EcoSIM source
included with the image under `reference/`. Start with
`reference/CURRENT.md`; `AGENTS.md` tells the agent how to cite the code.

Prompt ideas:

- “Explain the cycle driver and EcoSIM PK in this input file.”
- “Can this EcoSIM build represent plant phenology? Show the relevant source
  files and explain which settings enable it.”
- “What does `surface-snow_depth` represent in this plot?”
- “Before editing anything, suggest a safe snow albedo experiment.”

OpenCode can edit files and run commands after you approve its requests. Work
in your own copy of the course so you can inspect and keep your changes.

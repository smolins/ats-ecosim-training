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

The Jupyter AI sidebar should show `@OpenCode`. To use it, mount the instructor's
`opencode.json` and provide the API key environment variable described in the
top-level README. The lessons also work without an API key.

Prompt ideas:

- “Explain the cycle driver and EcoSIM PK in this input file.”
- “What does `surface-snow_depth` represent in this plot?”
- “Before editing anything, suggest a safe snow albedo experiment.”

OpenCode can edit files and run commands after you approve its requests. Work
in your own copy of the course so you can inspect and keep your changes.

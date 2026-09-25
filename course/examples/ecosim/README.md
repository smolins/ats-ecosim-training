# EcoSIM lesson inputs

These inputs and forcing files were copied from `14_ecosim` in
`amanzi/ats-demos`, branch `smolins/ecosim`, commit
`6b148aad111eb387ad021437e7a3d4f06c456d1d`.

`snow_dynamics_albedo_internal.xml` is the upstream
`single_column.template.xml` renamed for the course. The run helper copies
each input into a sibling `.demo` directory and changes only its end time.
The input files refer to `../data`, which is why the run directories remain
beside the `data` directory.

`data/ecosim_pftpar_20260303.nc` is the EcoSIM plant trait parameter file used
by the optional `snow_dynamics_phenology_roots.xml` case. That input sets
`engine input file` to this path and enables prescribed phenology. The three
snow albedo cases set the engine input file to `Null` and do not use it. This
copy matches the file in `ats-demos/14_ecosim/data` at the commit above; its
original creation history is not established by this repository.

The supplied cases use a single-column mesh and are supported with one MPI
rank. The run helper reads the duration from each prepared XML input; it does
not create a separate duration marker. Existing edited inputs are preserved.
Older workspaces may contain `duration_days.txt`; the helper ignores it, and
participants can remove it when convenient.

Upstream license and copyright terms are included here.

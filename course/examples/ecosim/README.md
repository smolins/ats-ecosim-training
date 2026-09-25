# EcoSIM lesson inputs

These inputs and forcing files were copied from `14_ecosim` in
`amanzi/ats-demos`, branch `smolins/ecosim`, commit
`6b148aad111eb387ad021437e7a3d4f06c456d1d`.

`snow_dynamics_albedo_internal.xml` is the upstream
`single_column.template.xml` renamed for the course. The run helper copies
each input into a sibling `.demo` directory and changes only its end time.
The input files refer to `../data`, which is why the run directories remain
beside the `data` directory.

Upstream license and copyright terms are included here.

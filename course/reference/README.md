# ATS and EcoSIM source reference

This folder contains readable copies of ATS and EcoSIM source revisions
included with the running image. `CURRENT.md` names those revisions and
states whether the EcoSIM library's build revision was verified. The
subfolders are named by commit ID, so older copies can coexist if you reuse
the same workspace with a newer image. Each copy includes `REVISION` and
`SOURCE_URL` files.

The ATS–EcoSIM coupling is under `ats/<revision>/src/pks/ecosim/`. The separate
EcoSIM implementation is under `ecosim/<revision>/`. Compare these sources with
the lesson inputs in `examples/ecosim/inputs/` when exploring a capability.

These files are reference copies. Edits here do not change the installed ATS
executable or EcoSIM library.

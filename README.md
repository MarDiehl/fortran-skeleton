# fortran-skeleton
Cmake-based fortran skeletons

Simply place any Fortran (and optionally C) sources in `src` and compile and execute with `./run.sh`.

The version for PETSc uses the compilers defined by PETSc.
To use PETSc `PETSC_DIR` and `PETSC_ARCH` need to be set.
If PETSc is not available, use `$F90` and `$CC` environment variables.

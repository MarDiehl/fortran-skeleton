rm -rf build
mkdir build
cd build
cmake .. -DCMAKE_BUILD_TYPE=DEBUG -DOPTIMIZATION=OFF -DOPENMP=OFF
make
if [ -z ${PETSC_ARCH+x} ]; 
    then export PETSC_ARCH=''
fi
${PETSC_DIR}/lib/petsc/bin/petscmpiexec -valgrind -n 1 src/executable

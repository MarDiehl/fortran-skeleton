#! /usr/bin/env sh

if [ -z ${F90+x} ]; 
    then export F90=gfortran
fi
if [ -z ${CC+x} ]; 
   then export CC=gcc
fi
rm -rf build
mkdir build
cd build
cmake .. -DCMAKE_BUILD_TYPE=DEBUG -DOPTIMIZATION=OFF -DOPENMP=OFF -DCMAKE_Fortran_COMPILER=$F90 -DCMAKE_C_COMPILER=$CC
make
./src/executable

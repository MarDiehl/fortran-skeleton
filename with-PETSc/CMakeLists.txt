cmake_minimum_required(VERSION 3.12.0)
include(FindPkgConfig REQUIRED)

if(DEFINED ENV{PETSC_DIR})
    message("PETSC_DIR:\n$ENV{PETSC_DIR}\n")
else()
  message (FATAL_ERROR "PETSc location (PETSC_DIR) is not defined")
endif ()

# Dummy project to determine compiler names and version
project(Prerequisites LANGUAGES)
set(ENV{PKG_CONFIG_PATH} "$ENV{PETSC_DIR}/$ENV{PETSC_ARCH}/lib/pkgconfig")
pkg_check_modules(PETSC REQUIRED PETSc>=3.12.0 PETSc<3.17.0)
pkg_get_variable(CMAKE_Fortran_COMPILER PETSc fcompiler)
pkg_get_variable(CMAKE_C_COMPILER PETSc ccompiler)

project(executable Fortran C)

add_definitions(-DPETSC)

if (CMAKE_BUILD_TYPE STREQUAL "")
  set (CMAKE_BUILD_TYPE "RELEASE")
endif ()
string(TOUPPER "${CMAKE_BUILD_TYPE}" CMAKE_BUILD_TYPE)

# Predefined sets for OPTIMIZATION/OPENMP based on BUILD_TYPE
if (CMAKE_BUILD_TYPE STREQUAL "DEBUG" OR CMAKE_BUILD_TYPE STREQUAL "SYNTAXONLY")
    set (DEBUG_FLAGS "${DEBUG_FLAGS} -DDEBUG")
    set (PARALLEL "OFF")
    set (OPTI "OFF")
elseif (CMAKE_BUILD_TYPE STREQUAL "RELEASE")
    set (PARALLEL "ON")
    set (OPTI "DEFENSIVE")
elseif(CMAKE_BUILD_TYPE STREQUAL "DEBUGRELEASE")
    set(DEBUG_FLAGS "${DEBUG_FLAGS} -DDEBUG")
    set(PARALLEL "ON")
    set(OPTI "DEFENSIVE")
elseif (CMAKE_BUILD_TYPE STREQUAL "PERFORMANCE")
    set (PARALLEL "ON")
    set (OPTI "AGGRESSIVE")
else()
    message(FATAL_ERROR "Invalid build type: CMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}")
endif ()

# $OPTIMIZATION takes precedence over $BUILD_TYPE defaults
if (OPTIMIZATION STREQUAL "" OR NOT DEFINED OPTIMIZATION)
    set (OPTIMIZATION "${OPTI}")
else ()
    set (OPTIMIZATION "${OPTIMIZATION}")
endif ()

# $OPENMP takes precedence over $BUILD_TYPE defaults
if (OPENMP STREQUAL "" OR NOT DEFINED OPENMP)
    set (OPENMP "${PARALLEL}")
else ()
    set(OPENMP "${OPENMP}")
endif ()

# syntax check only(mainly for pre-receive hook)
if (CMAKE_BUILD_TYPE STREQUAL "SYNTAXONLY")
    set (BUILDCMD_POST "${BUILDCMD_POST} -fsyntax-only")
endif ()


list(APPEND CMAKE_MODULE_PATH ${PROJECT_SOURCE_DIR}/cmake)
if (CMAKE_Fortran_COMPILER_ID STREQUAL "Intel")
  include(Compiler-Intel)
elseif(CMAKE_Fortran_COMPILER_ID STREQUAL "GNU")
  include(Compiler-GNU)
elseif(CMAKE_Fortran_COMPILER_ID STREQUAL "IntelLLVM")
    include(Compiler-IntelLLVM)
elseif(CMAKE_Fortran_COMPILER_ID STREQUAL "PGI")
  include(Compiler-PGI)
else ()
  message (FATAL_ERROR "Compiler type (CMAKE_Fortran_COMPILER_ID) not recognized")
endif ()

file(STRINGS "$ENV{PETSC_DIR}/$ENV{PETSC_ARCH}/lib/petsc/conf/petscvariables" PETSC_EXTERNAL_LIB REGEX "PETSC_EXTERNAL_LIB_BASIC = .*$?")
string(REPLACE "PETSC_EXTERNAL_LIB_BASIC = " "" PETSC_EXTERNAL_LIB "${PETSC_EXTERNAL_LIB}")
message("PETSC_EXTERNAL_LIB:\n${PETSC_EXTERNAL_LIB}\n")

file(STRINGS "$ENV{PETSC_DIR}/$ENV{PETSC_ARCH}/lib/petsc/conf/petscvariables" PETSC_INCLUDES REGEX "PETSC_FC_INCLUDES = .*$?")
string(REPLACE "PETSC_FC_INCLUDES = " "" PETSC_INCLUDES "${PETSC_INCLUDES}")
message("PETSC_INCLUDES:\n${PETSC_INCLUDES}\n")

set (CMAKE_Fortran_FLAGS_${CMAKE_BUILD_TYPE} "${BUILDCMD_PRE} ${OPENMP_FLAGS} ${STANDARD_CHECK} ${OPTIMIZATION_FLAGS} ${COMPILE_FLAGS} ${PRECISION_FLAGS}")
set(CMAKE_Fortran_LINK_EXECUTABLE           "${BUILDCMD_PRE} ${CMAKE_Fortran_COMPILER} ${OPENMP_FLAGS} ${OPTIMIZATION_FLAGS} ${LINKER_FLAGS}")

if (CMAKE_BUILD_TYPE STREQUAL "DEBUG")
  set (CMAKE_Fortran_FLAGS_${CMAKE_BUILD_TYPE} "${CMAKE_Fortran_FLAGS_${CMAKE_BUILD_TYPE}} ${DEBUG_FLAGS}")
  set (CMAKE_Fortran_LINK_EXECUTABLE           "${CMAKE_Fortran_LINK_EXECUTABLE} ${DEBUG_FLAGS}")
endif ()

set (CMAKE_Fortran_FLAGS_${CMAKE_BUILD_TYPE} "${CMAKE_Fortran_FLAGS_${CMAKE_BUILD_TYPE}} ${PETSC_INCLUDES} ${BUILDCMD_POST}")
set(CMAKE_Fortran_LINK_EXECUTABLE            "${CMAKE_Fortran_LINK_EXECUTABLE} <OBJECTS> -o <TARGET> <LINK_LIBRARIES> -L${PETSC_LIBRARY_DIRS} -lpetsc ${PETSC_EXTERNAL_LIB} -lz ${BUILDCMD_POST}")

message ("Fortran Compiler Flags:\n${CMAKE_Fortran_FLAGS_${CMAKE_BUILD_TYPE}}\n")
message ("C Compiler Flags:\n${CMAKE_C_FLAGS_${CMAKE_BUILD_TYPE}}\n")
message ("Fortran Linker Command:\n${CMAKE_Fortran_LINK_EXECUTABLE}\n")

# location of code
add_subdirectory (src)

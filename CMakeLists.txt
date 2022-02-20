file(GLOB sources *.f90 *.F90 *.c *.C)

add_executable(executable ${sources})
install (TARGETS executable RUNTIME DESTINATION bin)
      

file(GLOB sources *.f90 *.c)

add_executable(executable ${sources})
install (TARGETS executable RUNTIME DESTINATION bin)
      

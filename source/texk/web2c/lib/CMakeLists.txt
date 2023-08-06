# CMakeLists.txt for texk/web2c/lib


## lib

set(web2c_lib_SRCS
  basechsuffix.c
  chartostring.c
  coredump.c
  eofeoln.c
  fprintreal.c
  inputint.c
  input2int.c
  lib.h
  main.c
  openclose.c
  printversion.c
  setupvar.c
  uexit.c
  usage.c
  version.c
  zround.c
  )

add_library(web2c_lib STATIC ${web2c_lib_SRCS})

target_include_directories(web2c_lib
  PRIVATE "${CMAKE_CURRENT_SOURCE_DIR}/.."
  PRIVATE "${CMAKE_CURRENT_BINARY_DIR}/.."
  )

target_link_libraries(web2c_lib PUBLIC kpathsea)


## libp 

set(web2c_libp_SRCS
  openclose.c
  printversion.c
  )

add_library(web2c_libp STATIC ${web2c_libp_SRCS})

target_compile_definitions(web2c_libp PRIVATE -DPTEX)

target_include_directories(web2c_libp
  PRIVATE "${CMAKE_CURRENT_SOURCE_DIR}/.."
  PRIVATE "${CMAKE_CURRENT_BINARY_DIR}/.."
  )

target_link_libraries(web2c_libp PUBLIC kpathsea ptexenc)

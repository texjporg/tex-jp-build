# CMakeLists.txt for mendexk directory

set(VERSION "3.6")

add_compile_options("$<$<CXX_COMPILER_ID:MSVC>:/utf-8>")

include(cmake/config.cmake)

get_property(KPATHSEA_INCLUDES GLOBAL PROPERTY KPATHSEA_INCLUDES)

include_directories(${KPATHSEA_INCLUDES})

set(mendex_SOURCES
  convert.c
  exkana.h
  exvar.h
  fread.c
  fwrite.c
  kana.h
  kp.c
  kp.h
  ktable.h
  main.c
  mendex.h
  version.h
  pageread.c
  qsort.c
  qsort.h
  sort.c
  styfile.c
  var.h
  )

add_executable(mendex ${mendex_SOURCES})

target_include_directories(mendex
  PRIVATE "${CMAKE_CURRENT_SOURCE_DIR}"
  PRIVATE "${CMAKE_CURRENT_BINARY_DIR}"
  )

target_link_libraries(mendex kpathsea ptexenc)

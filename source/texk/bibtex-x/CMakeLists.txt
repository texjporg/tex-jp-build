# CMakeLists.txt for bibtex-x directory

set(VERSION "4.01")

cmake_policy (SET CMP0115 NEW)

add_compile_options("$<$<CXX_COMPILER_ID:MSVC>:/utf-8>")

include(cmake/config.cmake)

get_property(KPATHSEA_INCLUDES GLOBAL PROPERTY KPATHSEA_INCLUDES)

include_directories(${KPATHSEA_INCLUDES})

set(common_sources
  bibtex-1.c
  bibtex-2.c
  bibtex-3.c
  bibtex-4.c
  bibtex.c
  bibtex.h
  datatype.h
  gblprocs.h
  gblvars.h
  utils.c
  utils.h
  version.h
  sysdep.h
  config.h
  )
set(bibtex8_SOURCES ${common_sources})
set(bibtexu_SOURCES ${common_sources})

add_executable(bibtex8 ${bibtex8_SOURCES})
add_executable(bibtexu ${bibtexu_SOURCES})

target_include_directories(bibtex8
  PRIVATE "${CMAKE_CURRENT_SOURCE_DIR}"
  PRIVATE "${CMAKE_CURRENT_BINARY_DIR}"
  PUBLIC "${KPATHSEA_INCLUDES}"
  )
target_include_directories(bibtexu
  PRIVATE "${CMAKE_CURRENT_SOURCE_DIR}"
  PRIVATE "${CMAKE_CURRENT_BINARY_DIR}"
  PUBLIC "${KPATHSEA_INCLUDES}"
  )

target_compile_definitions(bibtex8 PRIVATE -DKPATHSEA -DHAVE_CONFIG_H -DSUPPORT_8BIT)
target_compile_definitions(bibtexu PRIVATE -DKPATHSEA -DHAVE_CONFIG_H -DUTF_8 -DWITH_SYSTEM_ICU)

target_link_libraries(bibtex8 kpathsea)
target_link_libraries(bibtexu kpathsea icu)

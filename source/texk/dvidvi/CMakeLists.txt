# CMakeLists.txt for dvidvi directory

set(VERSION "1.1")

cmake_policy (SET CMP0115 NEW)

include(cmake/config.cmake)

get_property(KPATHSEA_INCLUDES GLOBAL PROPERTY KPATHSEA_INCLUDES)

set(dvidvi_SOURCES
  dvidvi.c
  config.h
  )

add_executable(dvidvi ${dvidvi_SOURCES})

target_include_directories(dvidvi
  PRIVATE "${CMAKE_CURRENT_BINARY_DIR}"
  )

target_compile_definitions(dvidvi PRIVATE -DKPATHSEA -DHAVE_CONFIG_H -DASCIIPTEX)

target_link_libraries(dvidvi kpathsea)

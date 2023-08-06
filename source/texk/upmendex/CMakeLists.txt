# CMakeLists.txt for upmendex directory

set(VERSION "1.07")

add_compile_options("$<$<CXX_COMPILER_ID:MSVC>:/utf-8>")

include(cmake/config.cmake)

get_property(KPATHSEA_INCLUDES GLOBAL PROPERTY KPATHSEA_INCLUDES)

include_directories(${KPATHSEA_INCLUDES})

set(upmendex_SOURCES
  convert.c
  exkana.h
  exvar.h
  fread.c
  fwrite.c
  kana.h
  kp.c
  kp.h
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

add_executable(upmendex ${upmendex_SOURCES})

target_include_directories(upmendex
  PRIVATE "${CMAKE_CURRENT_SOURCE_DIR}"
  PRIVATE "${CMAKE_CURRENT_BINARY_DIR}"
  )

target_compile_definitions(upmendex PRIVATE -DWITH_SYSTEM_ICU)

target_link_libraries(upmendex kpathsea icu)

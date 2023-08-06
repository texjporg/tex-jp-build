# CMakeLists.txt for dvi2tty directory

set(VERSION "6.0.2")

include(cmake/config.cmake)

get_property(KPATHSEA_INCLUDES GLOBAL PROPERTY KPATHSEA_INCLUDES)

include_directories(${KPATHSEA_INCLUDES})

set(SRC dvi2tty-src)

set(disdvi_SOURCES
  ${SRC}/commands.h
  ${SRC}/disdvi.c
  )
set(dvi2tty_SOURCES
  ${SRC}/commands.h
  ${SRC}/dvi2tty.c
  ${SRC}/dvi2tty.h
  ${SRC}/tex2ucs.h
  ${SRC}/dvistuff.c
  )

add_executable(disdvi ${disdvi_SOURCES})
add_executable(dvi2tty ${dvi2tty_SOURCES})

target_compile_definitions(disdvi
  PRIVATE -DKPATHSEA -DPTEXENC
  )
target_compile_definitions(dvi2tty
  PRIVATE -DKPATHSEA
  )

target_include_directories(disdvi
  PRIVATE "${CMAKE_CURRENT_SOURCE_DIR}"
  PRIVATE "${CMAKE_CURRENT_BINARY_DIR}"
  )
target_include_directories(dvi2tty
  PRIVATE "${CMAKE_CURRENT_SOURCE_DIR}"
  PRIVATE "${CMAKE_CURRENT_BINARY_DIR}"
  )

target_link_libraries(disdvi kpathsea ptexenc)
target_link_libraries(dvi2tty kpathsea ptexenc)

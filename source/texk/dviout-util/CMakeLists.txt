# CMakeLists.txt for dviout-util directory

set(VERSION "20220409")

cmake_policy (SET CMP0115 NEW)

add_compile_options("$<$<CXX_COMPILER_ID:MSVC>:/utf-8>")

include(cmake/config.cmake)

set(dvispc_SOURCES
  dvispc.c
  common.h
  )
set(chkdvifont_SOURCES
  chkdvifont.c
  dd.h
  msvcdir.h
  common.h
  )

set(dvispc_SOURCES ${dvispc_SOURCES} config.h)
set(chkdvifont_SOURCES ${chkdvifont_SOURCES} config.h)

add_executable(dvispc ${dvispc_SOURCES})
add_executable(chkdvifont ${chkdvifont_SOURCES})

target_include_directories(dvispc
  PRIVATE "${CMAKE_CURRENT_BINARY_DIR}"
  )
target_include_directories(chkdvifont
  PRIVATE "${CMAKE_CURRENT_BINARY_DIR}"
  )

target_compile_definitions(dvispc PRIVATE -DPTEXENC)

target_link_libraries(dvispc ptexenc)

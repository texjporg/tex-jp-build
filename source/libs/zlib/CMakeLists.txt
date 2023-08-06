# CMakeLists.txt for libpng

include(CheckIncludeFile)

check_include_file(unistd.h Z_HAVE_UNISTD_H)

configure_file(
  "${CMAKE_CURRENT_SOURCE_DIR}/zlib-src/zconf.h.cmakein"
  "${CMAKE_CURRENT_BINARY_DIR}/include/zconf.h"
  @ONLY
  )

configure_file(
  "${CMAKE_CURRENT_SOURCE_DIR}/zlib-src/zlib.h"
  "${CMAKE_CURRENT_BINARY_DIR}/include/zlib.h"
  COPYONLY
  )

set(zlib_SRCS
  zlib-src/adler32.c
  zlib-src/compress.c
  zlib-src/crc32.c
  zlib-src/crc32.h
  zlib-src/deflate.c
  zlib-src/deflate.h
  zlib-src/infback.c
  zlib-src/gzclose.c
  zlib-src/gzguts.h
  zlib-src/gzlib.c
  zlib-src/gzread.c
  zlib-src/gzwrite.c
  zlib-src/inffast.c
  zlib-src/inffast.h
  zlib-src/inffixed.h
  zlib-src/inflate.c
  zlib-src/inflate.h
  zlib-src/inftrees.c
  zlib-src/inftrees.h
  zlib-src/trees.c
  zlib-src/trees.h
  zlib-src/uncompr.c
  zlib-src/zutil.h
  zlib-src/zutil.c
  )

set(zlib_SRCS ${zlib_SRCS}
  include/zconf.h
  include/zlib.h
  )

add_library(zlib STATIC ${zlib_SRCS})

if(MSVC)
  target_compile_definitions(zlib
    PRIVATE -D_CRT_NONSTDC_NO_WARNINGS=1
    PRIVATE -D_CRT_SECURE_NO_WARNINGS=1
    )
endif()

target_include_directories(zlib
  PUBLIC ${CMAKE_CURRENT_BINARY_DIR}/include
  )

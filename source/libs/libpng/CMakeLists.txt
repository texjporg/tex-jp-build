# CMakeLists.txt for libpng

configure_file(
  "${CMAKE_CURRENT_SOURCE_DIR}/libpng-src/png.h"
  "${CMAKE_CURRENT_BINARY_DIR}/include/png.h"
  COPYONLY
  )

configure_file(
  "${CMAKE_CURRENT_SOURCE_DIR}/libpng-src/pngconf.h"
  "${CMAKE_CURRENT_BINARY_DIR}/include/pngconf.h"
  COPYONLY
  )

configure_file(
  "${CMAKE_CURRENT_SOURCE_DIR}/libpng-src/scripts/pnglibconf.h.prebuilt"
  "${CMAKE_CURRENT_BINARY_DIR}/include/pnglibconf.h"
  COPYONLY
  )

set(libpng_SRCS
  libpng-src/png.c
  libpng-src/pngerror.c
  libpng-src/pngget.c
  libpng-src/pngmem.c
  libpng-src/pngpread.c
  libpng-src/pngread.c
  libpng-src/pngrio.c
  libpng-src/pngrtran.c
  libpng-src/pngrutil.c
  libpng-src/pngset.c
  libpng-src/pngtrans.c
  libpng-src/pngwio.c
  libpng-src/pngwrite.c
  libpng-src/pngwtran.c
  libpng-src/pngwutil.c
  )

set(libpng_SRCS ${libpng_SRCS}
  include/png.h
  include/pngconf.h
  include/pnglibconf.h
  )

add_library(libpng STATIC ${libpng_SRCS})

target_compile_definitions(libpng
  PRIVATE _CRT_SECURE_NO_WARNINGS=1
  )

target_include_directories(libpng
  PUBLIC "${CMAKE_CURRENT_BINARY_DIR}/include"
  )

target_link_libraries(libpng zlib)

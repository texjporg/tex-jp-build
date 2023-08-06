# CMakeLists.txt for ptexenc

set(PTEXENC_VERSION "1.4.3")

option(NO_PTENC_DLL "NO_PTENC_DLL" ON)
option(KANJI_ICONV "use iconv for kanji <=> unicode conversion." OFF)

if (KANJI_ICONV)
  include(CheckIncludeFile)
  check_include_file(iconv.h HAVE_ICONV_H)

  include(CheckSymbolExists)
  check_symbol_exists(atexit "stdlib.h" HAVE_ATEXIT)
  check_symbol_exists(on_exit "stdlib.h" HAVE_ON_EXIT)
endif()

configure_file(
  "${CMAKE_CURRENT_SOURCE_DIR}/cmake/c-auto.h.in"
  "${CMAKE_CURRENT_BINARY_DIR}/ptexenc/c-auto.h"
  @ONLY
  )

set(ptexenc_SRCS
  jisx0208.h
  kanjicnv.c
  ptexenc.c
  ptexenc/kanjicnv.h
  ptexenc/unicode-jp.h
  unicode-jp.c
  unicode.c
  )

set(ptexenc_HDRS
  ptexenc/ptexenc.h
  ptexenc/unicode.h
  )
set(ptexenc_SRCS ${ptexenc_SRCS} ${ptexenc_HDRS})

set(ptexenc_SRCS ${ptexenc_SRCS}
  ptexenc/c-auto.h
  )

if(NO_PTENC_DLL)
  add_library(ptexenc STATIC ${ptexenc_SRCS})
  target_compile_definitions(ptexenc PUBLIC NO_PTENC_DLL)
else()
  add_library(ptexenc SHARED ${ptexenc_SRCS})
endif()

target_compile_definitions(ptexenc PRIVATE -DMAKE_PTENC_DLL)

target_include_directories(ptexenc
  PUBLIC "${CMAKE_CURRENT_SOURCE_DIR}"
  PUBLIC "${CMAKE_CURRENT_BINARY_DIR}"
  )

target_link_libraries(ptexenc PUBLIC kpathsea)

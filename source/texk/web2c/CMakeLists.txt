# CMakeLists.txt for web2c directory

set(WEB2CVERSION " (TeX Live ${TEX_LIVE_VERSION})")

option(NO_DUMP_SHARE "disable architecture-independent dump files. Faster on LittleEndian architectures." OFF)

set(WITH_EDITOR "" CACHE STRING "web2c: Default editor for interactive `e' option.")
if("${WITH_EDITOR}" MATCHES "^(|yes|no)$")
  if(WIN32)
    set(WITH_EDITOR "texworks --position=%d \\\"%s\\\"")
  else()
    set(WITH_EDITOR "vi +%d '%s'")
  endif()
endif()
set(EDITOR "${WITH_EDITOR}")

include(CheckIncludeFile)
CHECK_INCLUDE_FILE(dirent.h HAVE_DIRENT_H)
CHECK_INCLUDE_FILE(locale.h HAVE_LOCALE_H)
CHECK_INCLUDE_FILE(ndir.h HAVE_NDIR_H)
CHECK_INCLUDE_FILE(stdlib.h HAVE_STDLIB_H)
CHECK_INCLUDE_FILE(string.h HAVE_STRING_H)
CHECK_INCLUDE_FILE(sys/dir.h HAVE_SYS_DIR_H)
CHECK_INCLUDE_FILE(sys/ndir.h HAVE_SYS_NDIR_H)
CHECK_INCLUDE_FILE(sys/stat.h HAVE_SYS_STAT_H)
CHECK_INCLUDE_FILE(sys/timeb.h HAVE_SYS_TIMEB_H)
CHECK_INCLUDE_FILE(sys/time.h HAVE_SYS_TIME_H)
CHECK_INCLUDE_FILE(sys/wait.h HAVE_SYS_WAIT_H)
CHECK_INCLUDE_FILE(unistd.h HAVE_UNISTD_H)

include(CheckSymbolExists)
check_symbol_exists(fmax "math.h" HAVE_FMAX)
check_symbol_exists(ftime "sys/timeb.h" HAVE_FTIME)
check_symbol_exists(gettimeofday "sys/time.h" HAVE_GETTIMEOFDAY)
check_symbol_exists(mkstemp "stdlib.h" HAVE_MKSTEMP)
check_symbol_exists(mktemp "stdlib.h" HAVE_MKTEMP)
check_symbol_exists(setlocale "locale.h" HAVE_SETLOCALE)
check_symbol_exists(strlcat "string.h" HAVE_STRLCAT)
check_symbol_exists(strlcpy "string.h" HAVE_STRLCPY)
check_symbol_exists(uintptr_t "stdint.h" HAVE_UINTPTR_T)

include(CheckTypeSize)
CHECK_TYPE_SIZE("int" SIZEOF_INT)
CHECK_TYPE_SIZE("long" SIZEOF_LONG)
CHECK_TYPE_SIZE("off_t" SIZEOF_OFF_T)
CHECK_TYPE_SIZE("void *" SIZEOF_VOID_P)

include(cmake/CheckReturnTypeOfSignalHandlers.cmake)
check_return_type_of_signal_handlers(RETSIGTYPE)

configure_file(
  "${CMAKE_CURRENT_SOURCE_DIR}/cmake/c-auto.h.in"
  "${CMAKE_CURRENT_BINARY_DIR}/w2c/c-auto.h"
  )

add_subdirectory(lib)
add_subdirectory(web2c)

set(web2c_texmf web2c/common.defines web2c/texmf.defines web2c/coerce.h)

include(cmake/functions.cmake)

# tangle and ctangle
include(cmake/bootstrap.cmake)

include(cmake/cweb.cmake)

# pTeX
include(cmake/ptex.cmake)

# e-pTeX
#include(cmake/eptex.cmake)

# upTeX
include(cmake/uptex.cmake)

# e-upTeX
#include(cmake/euptex.cmake)

# libmd5
#include(cmake/md5.cmake)

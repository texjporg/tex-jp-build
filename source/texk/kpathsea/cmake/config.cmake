## 

if(WIN32)
  option(NO_KPSE_DLL "NO_KPSE_DLL" OFF)
endif()

option(MAKE_OMEGA_OCP_BY_DEFAULT "Run mkocp if OCP file is missing." OFF)
option(MAKE_OMEGA_OFM_BY_DEFAULT "Run mkofm if OFM file is missing." OFF)
option(MAKE_TEX_FMT_BY_DEFAULT "Run mktexfmt if format file is missing." OFF)
option(MAKE_TEX_MF_BY_DEFAULT "Run mktexmf if MF source is missing." OFF)
option(MAKE_TEX_PK_BY_DEFAULT "Run mktexpk if PK font is missing." OFF)
option(MAKE_TEX_TEX_BY_DEFAULT "Run mktextex if TeX source is missing." OFF)
option(MAKE_TEX_TFM_BY_DEFAULT "Run mktextfm if TFM file is missing." OFF)

if(MSVC)
  set(HAVE_DIRENT_H 1)
  set(HAVE_GETCWD 1)

  configure_file(
    "${CMAKE_CURRENT_SOURCE_DIR}/cmake/dirent.h"
    "${CMAKE_CURRENT_BINARY_DIR}/dirent.h"
    COPYONLY
    )

  set(kpathsea_SRCS
    ${kpathsea_SRCS}
    "${CMAKE_CURRENT_SOURCE_DIR}/cmake/dirent.c"
    )
endif()

include(CheckIncludeFile)

check_include_file(assert.h HAVE_ASSERT_H)
check_include_file(dirent.h HAVE_DIRENT_H)
check_include_file(float.h HAVE_FLOAT_H)
check_include_file(inttypes.h HAVE_INTTYPES_H)
check_include_file(libintl.h HAVE_LIBINTL_H)
check_include_file(limits.h HAVE_LIMITS_H)
check_include_file(memory.h HAVE_MEMORY_H)
check_include_file(ndir.h HAVE_NDIR_H)
check_include_file(pwd.h HAVE_PWD_H)
check_include_file(stdint.h HAVE_STDINT_H)
check_include_file(stdlib.h HAVE_STDLIB_H)
check_include_file(strings.h HAVE_STRINGS_H)
check_include_file(string.h HAVE_STRING_H)
check_include_file(sys/dir.h HAVE_SYS_DIR_H)
check_include_file(sys/ndir.h HAVE_SYS_NDIR_H)
check_include_file(sys/param.h HAVE_SYS_PARAM_H)
check_include_file(unistd.h HAVE_UNISTD_H)

include(CheckSymbolExists)

check_symbol_exists(getcwd "unistd.h" HAVE_GETCWD)
check_symbol_exists(getwd "unistd.h" HAVE_GETWD)
check_symbol_exists(memcmp "string.h" HAVE_MEMCMP)
check_symbol_exists(memcpy "string.h" HAVE_MEMCPY)
check_symbol_exists(strchr "string.h" HAVE_STRCHR)
check_symbol_exists(strrchr "string.h" HAVE_STRRCHR)

check_symbol_exists(isascii "ctype.h" HAVE_DECL_ISASCII)
check_symbol_exists(putenv "stdlib.h" HAVE_DECL_PUTENV)

include(CheckIncludeFiles)

check_include_files("stdlib.h;stdarg.h;string.h;float.h" STDC_HEADERS)

configure_file(
  "${CMAKE_CURRENT_SOURCE_DIR}/cmake/c-auto.h.in"
  "${CMAKE_CURRENT_BINARY_DIR}/c-auto.h"
  @ONLY
  )

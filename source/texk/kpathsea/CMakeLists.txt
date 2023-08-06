# CMakeLists.txt for kpathsea

set(kpathsea_VERSION "6.3.5")

include(cmake/config.cmake)

set(KPATHSEA_INCLUDES "${CMAKE_CURRENT_BINARY_DIR}/.." "${CMAKE_CURRENT_SOURCE_DIR}/..")
include_directories(${KPATHSEA_INCLUDES})

set(kpathsea_SRCS ${kpathsea_SRCS}
  tex-file.c
  absolute.c
  atou.c
  cnf.c
  concat.c
  concat3.c
  concatn.c
  db.c
  debug.c
  dir.c
  elt-dirs.c
  expand.c
  extend-fname.c
  file-p.c
  find-suffix.c
  fn.c
  fontmap.c
  hash.c
  kdefault.c
  kpathsea.c
  line.c
  magstep.c
  make-suffix.c
  path-elt.c
  pathsearch.c
  proginit.c
  progname.c
  readable.c
  rm-suffix.c
  str-list.c
  str-llist.c
  tex-glyph.c
  tex-hush.c
  tex-make.c
  tilde.c
  uppercasify.c
  variable.c
  version.c
  xbasename.c
  xcalloc.c
  xdirname.c
  xfopen.c
  xfseek.c
  xftell.c
  xgetcwd.c
  xmalloc.c
  xopendir.c
  xputenv.c
  xrealloc.c
  xstat.c
  xstrdup.c
  )

if(NOT MINGW32)
  set(kpathsea_SRCS ${kpathsea_SRCS}
    getopt.c
    getopt1.c
    )
endif()

if(WIN32)
  if(MINGW32)
    set(kpathsea_SRCS ${kpathsea_SRCS}
      mingw32.c
      xfseeko.c
      xftello.c
      )
  else()
    set(kpathsea_SRCS ${kpathsea_SRCS}
      win32lib.c
      )
  endif()

  set(kpathsea_SRCS ${kpathsea_SRCS}
    knj.c
    )
else()
  set(kpathsea_SRCS ${kpathsea_SRCS}
    xfseeko.c
    xftello.c
    )
endif()

set(kpathsea_HDRS
  c-auto.h
  kpathsea.h
  paths.h
  )

# Headers included directly into kpathsea.h
set(kpathsea_direct_headers
  absolute.h
  c-dir.h
  c-fopen.h
  c-namemx.h
  c-pathch.h
  c-pathmx.h
  c-stat.h
  cnf.h
  concatn.h
  expand.h
  getopt.h
  line.h
  magstep.h
  pathsearch.h
  proginit.h
  readable.h
  tex-glyph.h
  tex-hush.h
  tex-make.h
  variable.h
  version.h
  )

set(kpathsea_HDRS ${kpathsea_HDRS} ${kpathsea_direct_headers})

set(kpathsea_HDRS ${kpathsea_HDRS}
  c-ctype.h
  c-errno.h
  c-limits.h
  c-memstr.h
  c-minmax.h
  c-proto.h
  c-std.h
  c-unistd.h
  debug.h
  hash.h
  knj.h
  lib.h
  mingw32.h
  progname.h
  simpletypes.h
  str-list.h
  str-llist.h
  systypes.h
  tex-file.h
  types.h
  win32lib.h
  )

set(kpathsea_HDRS ${kpathsea_HDRS} config.h)

set(kpathsea_SRCS ${kpathsea_SRCS} ${kpathsea_HDRS})

if(WIN32)
  if(NO_KPSE_DLL)
    add_library(kpathsea STATIC ${kpathsea_SRCS})
    target_compile_definitions(kpathsea PUBLIC -DNO_KPSE_DLL)
  else()
    add_library(kpathsea SHARED ${kpathsea_SRCS})
    set_target_properties(kpathsea PROPERTIES OUTPUT_NAME "kpathsealib")
  endif()
  target_compile_definitions(kpathsea PRIVATE -DEXEEXT=\".EXE\")
else()
  add_library(kpathsea ${kpathsea_SRCS})
endif()

target_include_directories(kpathsea PUBLIC ${KPATHSEA_INCLUDES})

target_compile_definitions(kpathsea PRIVATE -DMAKE_KPSE_DLL)

add_custom_command(
  OUTPUT paths.h
  DEPENDS texmf.cnf cmake/cnf-to-paths.py
  COMMAND python3.exe "${CMAKE_CURRENT_SOURCE_DIR}/cmake/cnf-to-paths.py"
    "${CMAKE_CURRENT_SOURCE_DIR}/texmf.cnf"
    "${CMAKE_CURRENT_BINARY_DIR}/paths.h"
  )

add_custom_command(
  OUTPUT kpathsea.h
  DEPENDS cmake/kpathsea.py
  COMMAND python3.exe "${CMAKE_CURRENT_SOURCE_DIR}/cmake/kpathsea.py"
    "${CMAKE_CURRENT_BINARY_DIR}/kpathsea.h"
    config.h paths.h ${kpathsea_direct_headers}
  )


## The programs
## kpseaccess kpsereadlink kpsestat kpsewhich

add_executable(kpseaccess access.c)

add_executable(kpsereadlink readlink.c)

add_executable(kpsestat kpsestat.c)

add_executable(kpsewhich kpsewhich.c)
target_link_libraries(kpsewhich kpathsea)

if(WIN32)
  add_subdirectory(win32)
endif()

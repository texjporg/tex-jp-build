

## libkanji

add_library(libkanji
  ptexdir/kanji.c
  ptexdir/kanji.h
  ptexdir/kanji_dump.c
  )

target_include_directories(libkanji
  PRIVATE "${CMAKE_CURRENT_SOURCE_DIR}"
  PRIVATE "${CMAKE_CURRENT_BINARY_DIR}"
  )

target_link_libraries(libkanji ptexenc kpathsea zlib)


### pTeX SyncTeX
#
#set(ptex_include_synctex
#  PRIVATE "${CMAKE_CURRENT_SOURCE_DIR}/synctexdir"
#  )
#
#set(ptex_link_synctex
#  zlib
#  )
#
#set(ptex_ch_synctex
#  synctexdir/synctex-def.ch0
#  synctexdir/synctex-p-mem.ch0
#  synctexdir/synctex-mem.ch0
#  synctexdir/synctex-p-mem.ch1
#  synctexdir/synctex-p-rec.ch0
#  synctexdir/synctex-rec.ch0
#  synctexdir/synctex-rec.ch1
#  synctexdir/synctex-rec.ch2
#  synctexdir/synctex-p-rec.ch1
#  )
#
#set(dist_ptex_SOURCES_synctex
#  synctexdir/synctex.c
#  synctexdir/synctex.h
#  synctexdir/synctex-common.h
#  synctexdir/synctex-ptex.h
#  )
#
#set(ptex_definitions_synctex
#  PRIVATE -D__SyncTeX__
#  PRIVATE -DSYNCTEX_ENGINE_H=\"synctex-ptex.h\"
#  )
#
## pTeX
#
#set(ptex_c_h
#  ptexini.c
#  ptex0.c
#  ptexcoerce.h
#  ptexd.h
#  )
#
#set(nodist_ptex_SOURCES
#  ${ptex_c_h}
#  ptex-pool.c
#  )
#
#set(dist_ptex_SOURCES
#  ptexdir/ptexextra.c
#  ptexdir/ptexextra.h
#  ptexdir/ptex_version.h
#  ${dist_ptex_SOURCES_synctex}
#  )
#
#set(ptex_web_srcs
#  tex.web
#  tex.ch
#  tracingstacklevels.ch
#  partoken.ch
#  zlib-fmt.ch
#  )
#
#set(ptex_ch_srcs
#  ptexdir/ptex-base.ch
#  ${ptex_ch_synctex}
#  tex-binpool.ch
#  )
#
#set(ptex_SRCS
#  ${nodist_ptex_SOURCES}
#  ${dist_ptex_SOURCES}
#  )
#
#if(WIN32)
#  add_library(ptex SHARED ${ptex_SRCS})
#else()
#  add_executable(ptex ${ptex_SRCS})
#endif()
#
#target_compile_definitions(ptex ${ptex_definitions_synctex})
#
#target_include_directories(ptex
#  PRIVATE "${CMAKE_CURRENT_SOURCE_DIR}"
#  PRIVATE "${CMAKE_CURRENT_BINARY_DIR}"
#  ${ptex_include_synctex}
#  )
#
#target_link_libraries(ptex libkanji web2c_libp ptexenc zlib web2c_lib kpathsea ${ptex_link_synctex})
#
#web2c_convert(ptex OUTPUT ${ptex_c_h} DEPENDS ptex.p ${web2c_texmf} ptexdir/ptex.defines)
#
#web2c_texmf_tangle(ptex OUTPUT ptex.p ptex.pool DEPENDS ptex.web ptex.ch)
#
#web2c_tie_m(ptex.web SOURCES ${ptex_web_srcs})
#web2c_tie_c(ptex.ch SOURCES ptex.web ${ptex_ch_srcs})
#
#add_custom_command(
#  OUTPUT ptex-pool.c
#  DEPENDS ptex.pool ptexd.h makecpool
#  COMMAND "${CMAKE_CURRENT_SOURCE_DIR}/cmake/makecpool.py"
#    "--makecpool" "$<TARGET_FILE:makecpool>"
#    ptex ptex-pool.c
#  )
#
#if(WIN32)
#  add_executable(calldll_ptex "cmake/calldll.c")
#  target_compile_definitions(calldll_ptex PRIVATE DLLPROC=dllptexmain)
#  target_link_libraries(calldll_ptex ptex)
#
#  foreach(name ptex)
#    add_custom_command(TARGET calldll_ptex POST_BUILD
#      COMMAND ${CMAKE_COMMAND} -E copy
#        "$<TARGET_FILE:calldll_ptex>"
#        "$<TARGET_FILE_DIR:calldll_ptex>/${name}.exe"
#      )
#  endforeach()
#endif()

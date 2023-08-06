
# e-upTeX SyncTeX

set(euptex_include_synctex
  PRIVATE "${CMAKE_CURRENT_SOURCE_DIR}/synctexdir"
  )

set(euptex_link_synctex
  zlib
  )

set(euptex_ch_synctex
  synctexdir/synctex-def.ch0
  synctexdir/synctex-ep-mem.ch0
  synctexdir/synctex-mem.ch0
  synctexdir/synctex-e-mem.ch0
  synctexdir/synctex-ep-mem.ch1
  synctexdir/synctex-p-rec.ch0
  synctexdir/synctex-rec.ch0
  synctexdir/synctex-rec.ch1
  synctexdir/synctex-ep-rec.ch0
  synctexdir/synctex-e-rec.ch0
  synctexdir/synctex-p-rec.ch1
  )

set(dist_euptex_SOURCES_synctex
  synctexdir/synctex.c
  synctexdir/synctex.h
  synctexdir/synctex-common.h
  synctexdir/synctex-euptex.h
  )

set(euptex_definitions_synctex
  PRIVATE -D__SyncTeX__
  PRIVATE -DSYNCTEX_ENGINE_H=\"synctex-euptex.h\"
  )

# e-upTeX

set(euptex_c_h
  euptexini.c
  euptex0.c
  euptexcoerce.h
  euptexd.h
  )

set(nodist_euptex_SOURCES
  ${euptex_c_h}
  euptex-pool.c
  )

set(dist_euptex_SOURCES
  euptexdir/euptexextra.c
  euptexdir/euptexextra.h
  ${dist_euptex_SOURCES_synctex}
  )

set(euptex_prereq
  euptexd.h
  etexdir/etex_version.h
  ptexdir/ptex_version.h
  eptexdir/eptex_version.h
  uptexdir/uptex_version.h
  )

set(euptex_web_srcs
  tex.web
  etexdir/etex.ch
  etexdir/tex.ch0
  tex.ch
  tracingstacklevels.ch
  partoken.ch
  showstream.ch
  zlib-fmt.ch
  etexdir/tex.ech
  )

set(euptex_ch_srcs
  eptexdir/etex.ch0
  ptexdir/ptex-base.ch
  uptexdir/uptex-m.ch
  euptexdir/euptex.ch0
  eptexdir/eptex.ech
  eptexdir/etex.ch1
  euptexdir/euptex.ch1
  ${euptex_ch_synctex}
  eptexdir/fam256.ch
  euptexdir/pdfstrcmp-eup-pre.ch
  eptexdir/pdfutils.ch
  euptexdir/pdfstrcmp-eup-post.ch
  eptexdir/suppresserrors.ch
  eptexdir/char-warning-eptex.ch
  tex-binpool.ch
  )

set(euptex_SRCS
  ${nodist_euptex_SOURCES}
  ${dist_euptex_SOURCES}
  ${euptex_prereq}
  )

if(WIN32)
  add_library(euptex SHARED ${euptex_SRCS})
else()
  add_executable(euptex ${euptex_SRCS})
endif()

target_compile_definitions(euptex ${euptex_definitions_synctex})

target_include_directories(euptex
  PRIVATE "${CMAKE_CURRENT_SOURCE_DIR}"
  PRIVATE "${CMAKE_CURRENT_SOURCE_DIR}/libmd5"
  PRIVATE "${CMAKE_CURRENT_BINARY_DIR}"
  ${euptex_include_synctex}
  )

target_link_libraries(euptex libukanji web2c_libp ptexenc libmd5 zlib web2c_lib kpathsea ${euptex_link_synctex})

web2c_convert(euptex OUTPUT ${euptex_c_h} DEPENDS euptex.p ${web2c_texmf} euptexdir/euptex.defines)

web2c_texmf_tangle(euptex OUTPUT euptex.p euptex.pool DEPENDS euptex.web euptex.ch)

web2c_tie_m(euptex.web SOURCES ${euptex_web_srcs})
web2c_tie_c(euptex.ch SOURCES euptex.web ${euptex_ch_srcs})

add_custom_command(
  OUTPUT euptex-pool.c
  DEPENDS euptex.pool euptexd.h makecpool
  COMMAND "${CMAKE_CURRENT_SOURCE_DIR}/cmake/makecpool.py"
    "--makecpool" "$<TARGET_FILE_DIR:makecpool>/makecpool"
    euptex euptex-pool.c
  )

if(WIN32)
  add_executable(calldll_euptex "cmake/calldll.c")
  target_compile_definitions(calldll_euptex PRIVATE DLLPROC=dlleuptexmain)
  target_link_libraries(calldll_euptex euptex)

  foreach(name uptex euptex platex-dev uplatex uplatex-dev)
    add_custom_command(TARGET calldll_euptex POST_BUILD
      COMMAND ${CMAKE_COMMAND} -E copy
        "$<TARGET_FILE:calldll_euptex>"
        "$<TARGET_FILE_DIR:calldll_euptex>/${name}.exe"
      )
  endforeach()
endif()

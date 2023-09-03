

## e-pTeX SyncTeX

set(eptex_include_synctex
  PRIVATE "${CMAKE_CURRENT_SOURCE_DIR}/synctexdir"
  )

set(eptex_link_synctex
  zlib
  )

set(eptex_ch_synctex
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

set(dist_eptex_SOURCES_synctex
  synctexdir/synctex.c
  synctexdir/synctex.h
  synctexdir/synctex-common.h
  synctexdir/synctex-eptex.h
  )

set(eptex_definitions_synctex
  PRIVATE -D__SyncTeX__
  PRIVATE -DSYNCTEX_ENGINE_H=\"synctex-eptex.h\"
  )

# e-pTeX

set(eptex_c_h
  eptexini.c
  eptex0.c
  eptexcoerce.h
  eptexd.h
  )

set(nodist_eptex_SOURCES
  ${eptex_c_h}
  eptex-pool.c
  )

set(dist_eptex_SOURCES
  eptexdir/eptexextra.c
  eptexdir/eptexextra.h
  eptexdir/eptex_version.h
  ${dist_eptex_SOURCES_synctex}
  )

set(eptex_web_srcs
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

set(eptex_ch_srcs
  eptexdir/eptex-base.ch
  eptexdir/etex.ch0
  ptexdir/ptex-base.ch
  eptexdir/eptex.ech
  eptexdir/etex.ch1
  ${eptex_ch_synctex}
  eptexdir/fam256.ch
  eptexdir/pdfutils.ch
  eptexdir/suppresserrors.ch
  eptexdir/char-warning-eptex.ch
  tex-binpool.ch
  )

set(eptex_SRCS
  ${nodist_eptex_SOURCES}
  ${dist_eptex_SOURCES}
  )

if(WIN32)
  add_library(eptex SHARED ${eptex_SRCS})
else()
  add_executable(eptex ${eptex_SRCS})
endif()

target_compile_definitions(eptex ${eptex_definitions_synctex})

target_include_directories(eptex
  PRIVATE "${CMAKE_CURRENT_SOURCE_DIR}"
  PRIVATE "${CMAKE_CURRENT_SOURCE_DIR}/libmd5"
  PRIVATE "${CMAKE_CURRENT_BINARY_DIR}"
  ${eptex_include_synctex}
  )

target_link_libraries(eptex libkanji web2c_libp ptexenc libmd5 zlib web2c_lib kpathsea ${eptex_link_synctex})

web2c_convert(eptex OUTPUT ${eptex_c_h} DEPENDS eptex.p ${web2c_texmf} eptexdir/eptex.defines)

web2c_texmf_tangle(eptex OUTPUT eptex.p eptex.pool DEPENDS eptex.web eptex.ch)

web2c_tie_m(eptex.web SOURCES ${eptex_web_srcs})
web2c_tie_c(eptex.ch SOURCES eptex.web ${eptex_ch_srcs})

add_custom_command(
  OUTPUT eptex-pool.c
  DEPENDS eptex.pool eptexd.h makecpool
  COMMAND python3.exe "${CMAKE_CURRENT_SOURCE_DIR}/cmake/makecpool.py"
    "--makecpool" "$<TARGET_FILE:makecpool>"
    eptex eptex-pool.c
  )

if(WIN32)
  add_executable(calldll_eptex "cmake/calldll.c")
  target_compile_definitions(calldll_eptex PRIVATE DLLPROC=dlleptexmain)
  target_link_libraries(calldll_eptex eptex)

  foreach(name ptex eptex platex)
    add_custom_command(TARGET calldll_eptex POST_BUILD
      COMMAND ${CMAKE_COMMAND} -E copy
        "$<TARGET_FILE:calldll_eptex>"
        "$<TARGET_FILE_DIR:calldll_eptex>/${name}.exe"
      )
  endforeach()
endif()

# CMakeLists.txt for dvipdfm-x

set(VERSION "20220710")

include(cmake/config.cmake)

get_property(KPATHSEA_INCLUDES GLOBAL PROPERTY KPATHSEA_INCLUDES)

include_directories(${KPATHSEA_INCLUDES})

set(xdvipdfmx_SOURCES
  agl.c
  agl.h
  bmpimage.c
  bmpimage.h
  cff.c
  cff.h
  cff_dict.c
  cff_dict.h
  cff_limits.h
  cff_stdstr.h
  cff_types.h
  cid_basefont.h
  cid.c
  cid.h
  cidtype0.c
  cidtype0.h
  cidtype2.c
  cidtype2.h
  cmap.c
  cmap.h
  cmap_p.h
  cmap_read.c
  cmap_read.h
  cmap_write.c
  cmap_write.h
  cs_type2.c
  cs_type2.h
  dpxconf.c
  dpxconf.h
  dpxcrypt.c
  dpxcrypt.h
  dpxfile.c
  dpxfile.h
  dpxutil.c
  dpxutil.h
  dvi.c
  dvi.h
  dvicodes.h
  dvipdfmx.c
  dvipdfmx.h
  epdf.c
  epdf.h
  error.c
  error.h
  fontmap.c
  fontmap.h
  jp2image.c
  jp2image.h
  jpegimage.c
  jpegimage.h
  mem.c
  mem.h
  mfileio.c
  mfileio.h
  mpost.c
  mpost.h
  mt19937ar.c
  numbers.c
  numbers.h
  otl_opt.c
  otl_opt.h
  pdfcolor.c
  pdfcolor.h
  pdfdev.c
  pdfdev.h
  pdfdoc.c
  pdfdoc.h
  pdfdraw.c
  pdfdraw.h
  pdfencrypt.c
  pdfencrypt.h
  pdfencoding.c
  pdfencoding.h
  pdffont.c
  pdffont.h
  pdflimits.h
  pdfnames.c
  pdfnames.h
  pdfobj.c
  pdfobj.h
  pdfparse.c
  pdfparse.h
  pdfresource.c
  pdfresource.h
  pdfximage.c
  pdfximage.h
  pkfont.c
  pkfont.h
  pngimage.c
  pngimage.h
  pst.c
  pst.h
  pst_obj.c
  pst_obj.h
  sfnt.c
  sfnt.h
  spc_color.c
  spc_color.h
  spc_dvipdfmx.c
  spc_dvipdfmx.h
  spc_dvips.c
  spc_dvips.h
  spc_html.c
  spc_html.h
  spc_misc.c
  spc_misc.h
  spc_pdfm.c
  spc_pdfm.h
  spc_tpic.c
  spc_tpic.h
  spc_util.h
  spc_util.c
  spc_xtx.c
  spc_xtx.h
  specials.c
  specials.h
  subfont.c
  subfont.h
  system.h
  t1_char.c
  t1_char.h
  t1_load.c
  t1_load.h
  tfm.c
  tfm.h
  truetype.c
  truetype.h
  tt_aux.c
  tt_aux.h
  tt_cmap.c
  tt_cmap.h
  tt_glyf.c
  tt_glyf.h
  tt_gsub.c
  tt_gsub.h
  tt_post.c
  tt_post.h
  tt_table.c
  tt_table.h
  type0.c
  type0.h
  type1.c
  type1.h
  type1c.c
  type1c.h
  unicode.c
  unicode.h
  vf.c
  vf.h
  xbb.c
  )

set(xdvipdfmx_SOURCES ${xdvipdfmx_SOURCES} ${CMAKE_CURRENT_BINARY_DIR}/config.h)

if(WIN32)
  add_library(xdvipdfmx SHARED ${xdvipdfmx_SOURCES})
  set_target_properties(xdvipdfmx PROPERTIES OUTPUT_NAME "dvipdfmx")
else()
  add_executable(xdvipdfmx ${xdvipdfmx_SOURCES})
endif()

target_compile_definitions(xdvipdfmx
  PRIVATE -DHAVE_CONFIG_H=1
  PRIVATE -DHAVE_LIBPNG
  PRIVATE -DHAVE_ZLIB
  PRIVATE -DHAVE_ZLIB_COMPRESS2
  )

if(MSVC)
  target_compile_definitions(xdvipdfmx
    PRIVATE -D_CRT_SECURE_NO_WARNINGS=1
    PRIVATE -D_CRT_NONSTDC_NO_DEPRECATE=1
    )
endif()

target_include_directories(xdvipdfmx
  PRIVATE "${CMAKE_CURRENT_BINARY_DIR}"
  )

target_link_libraries(xdvipdfmx kpathsea libpng zlib)

if(WIN32)
  add_executable(calldll_xdvipdfmx "cmake/calldll.c")
  target_compile_definitions(calldll_xdvipdfmx PRIVATE DLLPROC=dlldvipdfmxmain)
  target_link_libraries(calldll_xdvipdfmx xdvipdfmx)

  foreach(name dvipdfm dvipdfmx xdvipdfmx ebb extractbb)
    add_custom_command(TARGET calldll_xdvipdfmx POST_BUILD
      COMMAND ${CMAKE_COMMAND} -E copy
        "$<TARGET_FILE_DIR:calldll_xdvipdfmx>/calldll_xdvipdfmx.exe"
        "$<TARGET_FILE_DIR:calldll_xdvipdfmx>/${name}.exe"
      )
  endforeach()
endif()

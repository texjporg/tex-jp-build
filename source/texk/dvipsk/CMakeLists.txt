# CMakeLists.txt for dvips

set(VERSION "2023.1")

include(cmake/config.cmake)

get_property(KPATHSEA_INCLUDES GLOBAL PROPERTY KPATHSEA_INCLUDES)

include_directories(${KPATHSEA_INCLUDES})

set(afm2tfm_SOURCES
  afm2tfm.c
  )
set(dvips_SOURCES
  bbox.c
  bitmapenc.c
  color.c
  config.h
  debug.h
  dopage.c
  dosection.c
  dospecial.c
  download.c
  dpicheck.c
  drawPS.c
  dviinput.c
  dvips.c
  dvips.h
  emspecial.c
  finclude.c
  fontdef.c
  header.c
  hps.c
  loadfont.c
  output.c
  papersiz.c
  paths.h
  pprescan.c
  prescan.c
  protos.h
  protos_add.h
  ptexmac.h
  repack.c
  resident.c
  scalewidth.c
  scanpage.c
  search.c
  skippage.c
  t1part.c
  t1part.h
  tfmload.c
  unpack.c
  virtualfont.c
  writet1.c
  )

set(afm2tfm_SOURCES ${afm2tfm_SOURCES} c-auto.h)
set(dvips_SOURCES ${dvips_SOURCES} c-auto.h)

add_executable(afm2tfm ${afm2tfm_SOURCES})
add_executable(dvips ${dvips_SOURCES})

target_compile_definitions(afm2tfm
  PRIVATE -DKPATHSEA
  PRIVATE -DHAVE_CONFIG_H=1
  )
target_compile_definitions(dvips
  PRIVATE -DKPATHSEA
  PRIVATE -DHAVE_CONFIG_H=1
  )

target_include_directories(afm2tfm
  PRIVATE "${CMAKE_CURRENT_SOURCE_DIR}"
  PRIVATE "${CMAKE_CURRENT_BINARY_DIR}"
  )
target_include_directories(dvips
  PRIVATE "${CMAKE_CURRENT_SOURCE_DIR}"
  PRIVATE "${CMAKE_CURRENT_BINARY_DIR}"
  )

target_link_libraries(afm2tfm kpathsea)
target_link_libraries(dvips kpathsea)

# CMakeLists.txt for makejvf directory

get_property(KPATHSEA_INCLUDES GLOBAL PROPERTY KPATHSEA_INCLUDES)

include_directories(${KPATHSEA_INCLUDES})

set(makejvf_SOURCES
  main.c
  makejvf.h
  tfmread.c
  tool.c
  uniblock.c
  uniblock.h
  usrtable.c
  usrtable.h
  version.h
  write.c
  )

add_executable(makejvf ${makejvf_SOURCES})

target_link_libraries(makejvf kpathsea ptexenc)


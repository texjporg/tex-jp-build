# CMakeLists.txt for omegafonts

## omegafonts

get_property(KPATHSEA_INCLUDES GLOBAL PROPERTY KPATHSEA_INCLUDES)

include_directories(${KPATHSEA_INCLUDES})

set(omfonts_SOURCES
  char_routines.c
  char_routines.h
  dimen_routines.c
  dimen_routines.h
  dvi.h
  error_routines.c
  error_routines.h
  extra_routines.c
  extra_routines.h
  font_routines.c
  font_routines.h
  header_routines.c
  header_routines.h
  ligkern_routines.c
  ligkern_routines.h
  list_routines.c
  list_routines.h
  manifests.h
  omfonts.c
  omfonts.h
  out_ofm.c
  out_ofm.h
  out_routines.c
  out_routines.h
  param_routines.c
  param_routines.h
  parse_ofm.c
  parse_ofm.h
  parser.h
  pl-parser.y
  pl-parser.c
  pl-lexer.l
  pl-lexer.c
  print_routines.c
  print_routines.h
  )

# set(omfonts_SOURCES ${omfonts_SOURCES} ${CMAKE_CURRENT_BINARY_DIR}/config.h)

if(WIN32)
  add_library(omfonts STATIC ${omfonts_SOURCES})
  set_target_properties(omfonts PROPERTIES OUTPUT_NAME "omfonts")
else()
  add_executable(omfonts ${omfonts_SOURCES})
endif()

target_compile_definitions(omfonts
  PRIVATE -DHAVE_CONFIG_H=1
  )

if(MSVC)
  target_compile_definitions(omfonts
    PRIVATE -D_CRT_SECURE_NO_WARNINGS=1
    PRIVATE -D_CRT_NONSTDC_NO_DEPRECATE=1
    PRIVATE -DYY_NO_UNISTD_H=1
    PRIVATE DLLPROC=dllomfontsmain
    )
endif()

target_include_directories(omfonts
  PRIVATE "${CMAKE_CURRENT_SOURCE_DIR}/.."
  PRIVATE "${CMAKE_CURRENT_BINARY_DIR}/.."
  )

target_link_libraries(omfonts web2c_lib libweb2c kpathsea)

if(WIN32)
  add_executable(calldll_omfonts "cmake/calldll.c")
  target_compile_definitions(calldll_omfonts PRIVATE DLLPROC=dllomfontsmain)
  target_link_libraries(calldll_omfonts omfonts)

  foreach(name omfonts ovp2ovf ofm2opl opl2ofm ofm2opl)
    add_custom_command(TARGET calldll_omfonts POST_BUILD
      COMMAND ${CMAKE_COMMAND} -E copy
        "$<TARGET_FILE_DIR:calldll_omfonts>/calldll_omfonts.exe"
        "$<TARGET_FILE_DIR:calldll_omfonts>/${name}.exe"
      )
  endforeach()
endif()


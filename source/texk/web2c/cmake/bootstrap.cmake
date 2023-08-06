# tangle and ctangle

# WEB2C 
function(web2c_convert BASE)
  cmake_parse_arguments(PARSE_ARGV 1 CONVERT "" "" "OUTPUT;DEPENDS")
  if(NOT CONVERT_OUTPUT)
    set(CONVERT_OUTPUT ${BASE}.c ${BASE}.h)
  endif()
  if(NOT CONVERT_DEPENDS)
    set(CONVERT_DEPENDS ${BASE}.p)
  endif()
  add_custom_command(
    OUTPUT ${CONVERT_OUTPUT}
    DEPENDS ${CONVERT_DEPENDS} web2c fixwrites splitup "${CMAKE_CURRENT_SOURCE_DIR}/cmake/web2c-sh.py"
    COMMAND python3.exe "${CMAKE_CURRENT_SOURCE_DIR}/cmake/web2c-sh.py"
      "--srcdir" "${CMAKE_CURRENT_SOURCE_DIR}"
      "--web2c" "$<TARGET_FILE_DIR:web2c>"
      ${BASE}
    )
endfunction()

#
# tangle
#
add_executable(tangle
  tangle.c
  tangle.h
  )

target_include_directories(tangle
  PRIVATE "${CMAKE_CURRENT_SOURCE_DIR}"
  PRIVATE "${CMAKE_CURRENT_BINARY_DIR}"
  )

target_link_libraries(tangle web2c_lib kpathsea)

web2c_tangleboot(tangle)

web2c_convert(tangle)

#
# tangleboot
#
configure_file(
  "${CMAKE_CURRENT_SOURCE_DIR}/tangleboot.pin"
  "${CMAKE_CURRENT_BINARY_DIR}/tangleboot.p"
  COPYONLY
  )

web2c_convert(tangleboot
  OUTPUT tangleboot.c tangleboot.h
  DEPENDS "${CMAKE_CURRENT_BINARY_DIR}/tangleboot.p"
  )

add_executable(tangleboot
  tangleboot.c
  tangleboot.h
  )

target_include_directories(tangleboot
  PRIVATE "${CMAKE_CURRENT_SOURCE_DIR}"
  PRIVATE "${CMAKE_CURRENT_BINARY_DIR}"
  )

target_link_libraries(tangleboot web2c_lib kpathsea)

#
# ctangle
#
add_executable(ctangle ctangle.c cweb.c)

if(MSVC)
  target_compile_definitions(ctangle PRIVATE -D_CRT_DECLARE_NONSTDC_NAMES=0)
endif()

target_include_directories(ctangle
  PRIVATE "${CMAKE_CURRENT_SOURCE_DIR}"
  PRIVATE "${CMAKE_CURRENT_BINARY_DIR}"
  )

target_link_libraries(ctangle web2c_lib kpathsea)

add_custom_command(
  OUTPUT ctangle.c
  BYPRODUCTS ctangle.c
  DEPENDS ctangleboot cwebdir/comm-w2c.h cwebdir/ctangle.w cwebdir/ctang-w2c.ch
  COMMAND ${CMAKE_COMMAND} -E env
    "CWEBINPUTS=${CMAKE_CURRENT_SOURCE_DIR}/cwebdir"
    "TEXMFCNF=${CMAKE_CURRENT_SOURCE_DIR}/../kpathsea"
    "$<TARGET_FILE:ctangleboot>" ctangle ctang-w2c
  )
add_custom_command(
  OUTPUT cweb.c
  BYPRODUCTS cweb.c
  DEPENDS ctangleboot cwebdir/common.w cwebdir/comm-w2c.ch
  COMMAND ${CMAKE_COMMAND} -E env
    "CWEBINPUTS=${CMAKE_CURRENT_SOURCE_DIR}/cwebdir"
    "TEXMFCNF=${CMAKE_CURRENT_SOURCE_DIR}/../kpathsea"
    "$<TARGET_FILE:ctangleboot>" common comm-w2c cweb.c
  )

#
# ctangleboot
#
add_executable(ctangleboot ctangleboot.c cwebboot.c)

if(MSVC)
  target_compile_definitions(ctangleboot PRIVATE -D_CRT_DECLARE_NONSTDC_NAMES=0)
endif()

target_include_directories(ctangleboot
  PRIVATE "${CMAKE_CURRENT_SOURCE_DIR}"
  PRIVATE "${CMAKE_CURRENT_BINARY_DIR}"
  )

target_link_libraries(ctangleboot web2c_lib kpathsea)

configure_file(
  "${CMAKE_CURRENT_SOURCE_DIR}/ctangleboot.cin"
  "${CMAKE_CURRENT_BINARY_DIR}/ctangleboot.c"
  COPYONLY
  )

configure_file(
  "${CMAKE_CURRENT_SOURCE_DIR}/cwebboot.cin"
  "${CMAKE_CURRENT_BINARY_DIR}/cwebboot.c"
  COPYONLY
  )



function(web2c_tangle BASE)
  add_custom_command(
    OUTPUT ${BASE}.p
    DEPENDS ${BASE}.web ${BASE}.ch tangle
    COMMAND ${CMAKE_COMMAND} -E env
      "WEBINPUTS=.;${CMAKE_CURRENT_SOURCE_DIR}"
      "TEXMFCNF=${CMAKE_CURRENT_SOURCE_DIR}/../kpathsea"
      "$<TARGET_FILE:tangle>" ${BASE} ${BASE}
    )
endfunction()

function(web2c_tangleboot BASE)
  add_custom_command(
    OUTPUT ${BASE}.p
    DEPENDS ${BASE}.web ${BASE}.ch tangleboot
    COMMAND ${CMAKE_COMMAND} -E env
    "WEBINPUTS=.;${CMAKE_CURRENT_SOURCE_DIR}"
    "TEXMFCNF=${CMAKE_CURRENT_SOURCE_DIR}/../kpathsea"
    "$<TARGET_FILE:tangleboot>" ${BASE} ${BASE}
    )
endfunction()


function(web2c_tie_m OUTPUT)
  cmake_parse_arguments(TIE "" "" "SOURCES" ${ARGN})
  add_custom_command(
    OUTPUT ${OUTPUT}
    DEPENDS ${TIE_SOURCES} tie
    COMMAND ${CMAKE_COMMAND} -E env
      "WEBINPUTS=.;${CMAKE_CURRENT_SOURCE_DIR}"
      "TEXMFCNF=${CMAKE_CURRENT_SOURCE_DIR}/../kpathsea"
      "$<TARGET_FILE:tie>" -m ${OUTPUT} ${TIE_SOURCES}
    )
endfunction()

function(web2c_tie_c OUTPUT)
  cmake_parse_arguments(TIE "" "" "SOURCES" ${ARGN})
  add_custom_command(
    OUTPUT ${OUTPUT}
    DEPENDS ${TIE_SOURCES} tie
    COMMAND ${CMAKE_COMMAND} -E env
      "WEBINPUTS=.;${CMAKE_CURRENT_SOURCE_DIR}"
      "TEXMFCNF=${CMAKE_CURRENT_SOURCE_DIR}/../kpathsea"
      "$<TARGET_FILE:tie>" -c ${OUTPUT} ${TIE_SOURCES}
    )
endfunction()

function(web2c_texmf_tangle BASE)
  cmake_parse_arguments(PARSE_ARGV 1 CONVERT "" "" "OUTPUT;DEPENDS")
  if(NOT CONVERT_OUTPUT)
    set(CONVERT_OUTPUT ${BASE}.p)
  endif()
  if(NOT CONVERT_DEPENDS)
    set(CONVERT_DEPENDS ${BASE}.web ${BASE}.ch)
  endif()
  add_custom_command(
    OUTPUT ${CONVERT_OUTPUT}
    DEPENDS ${CONVERT_DEPENDS} tangle
    COMMAND ${CMAKE_COMMAND} -E env
      "TEXMFCNF=${CMAKE_CURRENT_SOURCE_DIR}/../kpathsea"
      "WEBINPUTS=.;${CMAKE_CURRENT_SOURCE_DIR}"
      "CWEBINPUTS=.;${CMAKE_CURRENT_SOURCE_DIR}"
      "$<TARGET_FILE:tangle>" ${BASE} ${BASE}
    )
endfunction()

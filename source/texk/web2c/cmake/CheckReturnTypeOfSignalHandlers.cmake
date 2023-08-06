include_guard(GLOBAL)

function(check_return_type_of_signal_handlers _VARIABLE)

  if(NOT DEFINED ${_VARIABLE})
    if(NOT CMAKE_REQUIRED_QUIET)
      message(CHECK_START "checking return type of signal handlers")
    endif()

    set(_SOURCE
      "#include <sys/types.h>\n"
      "#include <signal.h>\n"
      "int main(){ return *(signal (0, 0)) (0) == 1; }\n"
      )

    file(WRITE "${CMAKE_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/CMakeTmp/CheckReturnTypeOfSignalHandlers.c"
      ${_SOURCE}
      )
    try_compile(${_VARIABLE}
      ${CMAKE_BINARY_DIR}
      ${CMAKE_BINARY_DIR}/${CMAKE_FILES_DIRECTORY}/CMakeTmp/CheckReturnTypeOfSignalHandlers.c
      COMPILE_DEFINITIONS ${CMAKE_REQUIRED_DEFINITIONS}
      OUTPUT_VARIABLE OUTPUT
      )

    if(${_VARIABLE})
      set(${_VARIABLE} "int" CACHE INTERNAL "return type of signal handlers")
      if(NOT CMAKE_REQUIRED_QUIET)
        message(CHECK_PASS "int")
      endif()
      file(APPEND ${CMAKE_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/CMakeOutput.log
        "Determining return type of signal handlers is int with the following output:\n"
        "${OUTPUT}\n\n"
        )
    else()
      set(${_VARIABLE} "void" CACHE INTERNAL "return type of signal handlers")
      if(NOT CMAKE_REQUIRED_QUIET)
        message(CHECK_PASS "void")
      endif()
      file(APPEND ${CMAKE_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/CMakeOutput.log
        "Determining return type of signal handlers is void with the following output:\n"
        "${OUTPUT}\n\n${_SOURCE}\n\n"
        )
    endif()
  endif()

endfunction()
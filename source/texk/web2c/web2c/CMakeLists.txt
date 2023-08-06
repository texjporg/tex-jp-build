# CMakeLists.txt for web2c

add_library(libweb2c STATIC kps.c)

target_compile_definitions(libweb2c
  PRIVATE -DMAKE_KPSE_DLL=1
  )
if(MSVC)
  target_compile_definitions(libweb2c
    PRIVATE -D_CRT_SECURE_NO_WARNINGS=1
    )
endif()

target_include_directories(libweb2c
  PRIVATE "${CMAKE_CURRENT_SOURCE_DIR}/.."
  PRIVATE "${CMAKE_CURRENT_BINARY_DIR}/.."
  )

target_link_libraries(libweb2c kpathsea)

#
# web2c
#
add_executable(web2c
  web2c-parser.c
  web2c-parser.h
  web2c-lexer.c
  main.c
  web2c.h
  )

if(MSVC)
  target_compile_definitions(web2c
    PRIVATE -D_CRT_SECURE_NO_WARNINGS=1
    )
endif()

if(NOT HAVE_UNISTD_H)
  target_compile_definitions(web2c
    PRIVATE -DYY_NO_UNISTD_H
    )
endif()

target_include_directories(web2c
  PRIVATE "${CMAKE_CURRENT_SOURCE_DIR}/.."
  PRIVATE "${CMAKE_CURRENT_BINARY_DIR}/.."
  )

target_link_libraries(web2c libweb2c kpathsea)

#
# fixwrites
#
add_executable(fixwrites
  fixwrites.c
  )

if(MSVC)
  target_compile_definitions(fixwrites
    PRIVATE -D_CRT_SECURE_NO_WARNINGS=1
    )
endif()

target_include_directories(fixwrites
  PRIVATE "${CMAKE_CURRENT_SOURCE_DIR}/.."
  PRIVATE "${CMAKE_CURRENT_BINARY_DIR}/.."
  )

target_link_libraries(fixwrites libweb2c kpathsea)

#
# splitup
#
add_executable(splitup
  splitup.c
  )

if(MSVC)
  target_compile_definitions(splitup
    PRIVATE -D_CRT_SECURE_NO_WARNINGS=1
    )
endif()

target_include_directories(splitup
  PRIVATE "${CMAKE_CURRENT_SOURCE_DIR}/.."
  PRIVATE "${CMAKE_CURRENT_BINARY_DIR}/.."
  )

target_link_libraries(splitup libweb2c kpathsea)

#
# makecpool
#
add_executable(makecpool
  makecpool.c
  )

if(MSVC)
  target_compile_definitions(makecpool
    PRIVATE -D_CRT_SECURE_NO_WARNINGS=1
    PRIVATE -D_CRT_NONSTDC_NO_DEPRECATE=1
    )
endif()

target_include_directories(makecpool
  PRIVATE "${CMAKE_CURRENT_SOURCE_DIR}/.."
  PRIVATE "${CMAKE_CURRENT_BINARY_DIR}/.."
  )

target_link_libraries(makecpool libweb2c kpathsea)

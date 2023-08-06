# md5.cmake

add_library(libmd5 libmd5/md5.c libmd5/md5.h)

if(MSVC)
  target_compile_definitions(libmd5 PRIVATE -D_CRT_SECURE_NO_WARNINGS=1)
endif()

target_include_directories(libmd5
  PRIVATE "${CMAKE_CURRENT_SOURCE_DIR}"
  PRIVATE "${CMAKE_CURRENT_BINARY_DIR}"
  )

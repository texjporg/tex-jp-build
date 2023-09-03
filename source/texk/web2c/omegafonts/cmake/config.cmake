
include(CheckIncludeFile)
check_include_file(inttypes.h HAVE_INTTYPES_H)
check_include_file(stdint.h HAVE_STDINT_H)

include(CheckSymbolExists)
if(MSVC)
  check_symbol_exists(_timezone "time.h" HAVE_TIMEZONE)
else()
  check_symbol_exists(timezone "time.h" HAVE_TIMEZONE)
endif()

include(CheckStructHasMember)
check_struct_has_member("struct tm" tm_gmtoff time.h HAVE_TM_GMTOFF)

configure_file(cmake/config.h.in config.h)

/* nptexextra.h: banner etc. for npTeX.

   This is included by npTeX, from nptexextra.c
*/

#include <etexdir/etex_version.h> /* for ETEX_VERSION */

#define BANNER "This is npTeX, Version 3.141592653-" ETEX_VERSION "-np0.0.00"
#define COPYRIGHT_HOLDER "D.E. Knuth"
#define AUTHOR "Japanese TeX Development Community"
#define PROGRAM_HELP NPTEXHELP
#define BUG_ADDRESS "issue@texjp.org"
#define DUMP_VAR TEXformatdefault
#define DUMP_LENGTH_VAR formatdefaultlength
#define DUMP_OPTION "fmt"
#define DUMP_EXT ".fmt"
#define INPUT_FORMAT kpse_tex_format
#define INI_PROGRAM "ininptex"
#define VIR_PROGRAM "virnptex"

#ifdef Xchr
#undef Xchr
#define Xchr(x) (x)
#endif /* Xchr */

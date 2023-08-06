/* DLL calling main program for TeX's
 * DLLPROC must be defined in the Makefile
 * as -DDLLPROC=dlltexmain
 *
 */
#include <windows.h>
__declspec(dllimport) DLLPROC(int ac, char **av);
int main(int ac, char **av)
{
  return (DLLPROC(ac, av));
}

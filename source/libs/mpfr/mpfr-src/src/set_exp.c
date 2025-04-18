/* mpfr_set_exp - set the exponent of a floating-point number

Copyright 2002-2004, 2006-2025 Free Software Foundation, Inc.
Contributed by the Pascaline and Caramba projects, INRIA.

This file is part of the GNU MPFR Library.

The GNU MPFR Library is free software; you can redistribute it and/or modify
it under the terms of the GNU Lesser General Public License as published by
the Free Software Foundation; either version 3 of the License, or (at your
option) any later version.

The GNU MPFR Library is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser General Public
License for more details.

You should have received a copy of the GNU Lesser General Public License
along with the GNU MPFR Library; see the file COPYING.LESSER.
If not, see <https://www.gnu.org/licenses/>. */

#include "mpfr-impl.h"

int
mpfr_set_exp (mpfr_ptr x, mpfr_exp_t exponent)
{
  if (MPFR_LIKELY (MPFR_IS_PURE_FP (x) &&
                   exponent >= __gmpfr_emin &&
                   exponent <= __gmpfr_emax))
    {
      MPFR_EXP(x) = exponent; /* do not use MPFR_SET_EXP of course... */
      return 0;
    }
  else
    {
      return 1;
    }
}

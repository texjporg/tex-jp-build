/* mpfr_ui_div -- divide a machine integer by a floating-point number

Copyright 2000-2025 Free Software Foundation, Inc.
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


#define MPFR_NEED_LONGLONG_H
#include "mpfr-impl.h"

int
mpfr_ui_div (mpfr_ptr y, unsigned long int u, mpfr_srcptr x, mpfr_rnd_t rnd_mode)
{
  MPFR_LOG_FUNC
    (("u=%lu x[%Pd]=%.*Rg rnd=%d",
      u, mpfr_get_prec(x), mpfr_log_prec, x, rnd_mode),
     ("y[%Pd]=%.*Rg", mpfr_get_prec(y), mpfr_log_prec, y));

  if (MPFR_UNLIKELY(MPFR_IS_SINGULAR(x)))
    {
      if (MPFR_IS_NAN(x))
        {
          MPFR_SET_NAN(y);
          MPFR_RET_NAN;
        }
      else if (MPFR_IS_INF(x)) /* u/Inf = 0 */
        {
          MPFR_SET_ZERO(y);
          MPFR_SET_SAME_SIGN(y,x);
          MPFR_RET(0);
        }
      else /* u / 0 */
        {
          MPFR_ASSERTD(MPFR_IS_ZERO(x));
          if (u)
            {
              /* u > 0, so y = sign(x) * Inf */
              MPFR_SET_SAME_SIGN(y, x);
              MPFR_SET_INF(y);
              MPFR_SET_DIVBY0 ();
              MPFR_RET(0);
            }
          else
            {
              /* 0 / 0 */
              MPFR_SET_NAN(y);
              MPFR_RET_NAN;
            }
        }
    }
  else if (MPFR_LIKELY(u != 0))
    {
      int inex;
      MPFR_SAVE_EXPO_DECL (expo);

      /* Optimization note: Exponent save/restore operations may be
         removed if mpfr_div works even when uu is out-of-range. */
      MPFR_SAVE_EXPO_MARK (expo);

#ifdef MPFR_LONG_WITHIN_LIMB
      {
        mpfr_t uu;
        mp_limb_t up[1];
        int cnt;

        MPFR_TMP_INIT1(up, uu, GMP_NUMB_BITS);
        MPFR_ASSERTN(u == (mp_limb_t) u);
        count_leading_zeros(cnt, (mp_limb_t) u);
        up[0] = (mp_limb_t) u << cnt;

        MPFR_SET_EXP (uu, GMP_NUMB_BITS - cnt);
        inex = mpfr_div (y, uu, x, rnd_mode);
      }
#else
      {
      mpfr_t uu;

      mpfr_init2 (uu, sizeof (unsigned long) * CHAR_BIT);
      mpfr_set_ui (uu, u, MPFR_RNDZ);
      inex = mpfr_div (y, uu, x, rnd_mode);
      mpfr_clear (uu);
      }
#endif

      MPFR_SAVE_EXPO_UPDATE_FLAGS (expo, __gmpfr_flags);
      MPFR_SAVE_EXPO_FREE (expo);
      return mpfr_check_range (y, inex, rnd_mode);
    }
  else /* u = 0, and x != 0 */
    {
      MPFR_SET_ZERO(y);         /* if u=0, then set y to 0 */
      MPFR_SET_SAME_SIGN(y, x); /* u considered as +0: sign(+0/x) = sign(x) */
      MPFR_RET(0);
    }
}

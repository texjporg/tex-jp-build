/* mpfr_digamma -- digamma function of a floating-point number

Copyright 2009-2025 Free Software Foundation, Inc.
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

/* FIXME: Check that MPFR_GET_EXP can only be called on regular values
   (in r14025, this is not the case) and that there cannot be integer
   overflows. */

/* Put in s an approximation of digamma(x).
   Assumes x >= 2.
   Assumes s does not overlap with x.
   Returns an integer e such that the error is bounded by 2^e ulps
   of the result s.
*/
static mpfr_exp_t
mpfr_digamma_approx (mpfr_ptr s, mpfr_srcptr x)
{
  mpfr_prec_t p = MPFR_PREC (s);
  mpfr_t t, u, invxx;
  mpfr_exp_t e, exps, f, expu;
  unsigned long n;

  MPFR_ASSERTN (MPFR_IS_POS (x) && MPFR_GET_EXP (x) >= 2);

  mpfr_init2 (t, p);
  mpfr_init2 (u, p);
  mpfr_init2 (invxx, p);

  mpfr_log (s, x, MPFR_RNDN);         /* error <= 1/2 ulp */
  mpfr_ui_div (t, 1, x, MPFR_RNDN);   /* error <= 1/2 ulp */
  mpfr_div_2ui (t, t, 1, MPFR_RNDN); /* exact */
  mpfr_sub (s, s, t, MPFR_RNDN);
  /* error <= 1/2 + 1/2*2^(EXP(olds)-EXP(s)) + 1/2*2^(EXP(t)-EXP(s)).
     For x >= 2, log(x) >= 2*(1/(2x)), thus olds >= 2t, and olds - t >= olds/2,
     thus 0 <= EXP(olds)-EXP(s) <= 1, and EXP(t)-EXP(s) <= 0, thus
     error <= 1/2 + 1/2*2 + 1/2 <= 2 ulps. */
  e = 2; /* initial error */
  mpfr_sqr (invxx, x, MPFR_RNDZ);     /* invxx = x^2 * (1 + theta)
                                         for |theta| <= 2^(-p) */
  mpfr_ui_div (invxx, 1, invxx, MPFR_RNDU); /* invxx = 1/x^2 * (1 + theta)^2 */

  /* in the following we note err=xxx when the ratio between the approximation
     and the exact result can be written (1 + theta)^xxx for |theta| <= 2^(-p),
     following Higham's method */
  mpfr_set_ui (t, 1, MPFR_RNDN); /* err = 0 */
  for (n = 1;; n++)
    {
      /* The main term is Bernoulli[2n]/(2n)/x^(2n) = B[n]/(2n+1)!(2n)/x^(2n)
         = B[n]*t[n]/(2n) where t[n]/t[n-1] = 1/(2n)/(2n+1)/x^2. */
      mpfr_mul (t, t, invxx, MPFR_RNDU);        /* err = err + 3 */
      mpfr_div_ui (t, t, 2 * n, MPFR_RNDU);     /* err = err + 1 */
      mpfr_div_ui (t, t, 2 * n + 1, MPFR_RNDU); /* err = err + 1 */
      /* we thus have err = 5n here */
      mpfr_div_ui (u, t, 2 * n, MPFR_RNDU);     /* err = 5n+1 */
      mpfr_mul_z (u, u, mpfr_bernoulli_cache(n), MPFR_RNDU);/* err = 5n+2, and the
                                                   absolute error is bounded
                                                   by 10n+4 ulp(u) [Rule 11] */
      /* if the terms 'u' are decreasing by a factor two at least,
         then the error coming from those is bounded by
         sum((10n+4)/2^n, n=1..infinity) = 24 */
      exps = MPFR_GET_EXP (s);
      expu = MPFR_GET_EXP (u);
      if (expu < exps - (mpfr_exp_t) p)
        break;
      mpfr_sub (s, s, u, MPFR_RNDN); /* error <= 24 + n/2 */
      if (MPFR_GET_EXP (s) < exps)
        e <<= exps - MPFR_GET_EXP (s);
      e ++; /* error in mpfr_sub */
      f = 10 * n + 4;
      while (expu < exps)
        {
          f = (1 + f) / 2;
          expu ++;
        }
      e += f; /* total rounding error coming from 'u' term */
    }

  mpfr_clear (t);
  mpfr_clear (u);
  mpfr_clear (invxx);

  f = 0;
  while (e > 1)
    {
      f++;
      e = (e + 1) / 2;
      /* Invariant: 2^f * e does not decrease */
    }
  return f;
}

/* Use the reflection formula Digamma(1-x) = Digamma(x) + Pi * cot(Pi*x),
   i.e., Digamma(x) = Digamma(1-x) - Pi * cot(Pi*x).
   Assume x < 1/2. */
static int
mpfr_digamma_reflection (mpfr_ptr y, mpfr_srcptr x, mpfr_rnd_t rnd_mode)
{
  mpfr_prec_t p = MPFR_PREC(y) + 10;
  mpfr_t t, u, v;
  mpfr_exp_t e1, expv, expx, q;
  int inex;
  MPFR_ZIV_DECL (loop);

  MPFR_LOG_FUNC
    (("x[%Pd]=%.*Rg rnd=%d", mpfr_get_prec(x), mpfr_log_prec, x, rnd_mode),
     ("y[%Pd]=%.*Rg inexact=%d", mpfr_get_prec(y), mpfr_log_prec, y, inex));

  /* we want that 1-x is exact with precision q: if 0 < x < 1/2, then
     q = PREC(x)-EXP(x) is ok, otherwise if -1 <= x < 0, q = PREC(x)-EXP(x)
     is ok, otherwise for x < -1, PREC(x) is ok if EXP(x) <= PREC(x),
     otherwise we need EXP(x) */
  expx = MPFR_GET_EXP (x);
  if (expx < 0)
    q = MPFR_PREC(x) + 1 - expx;
  else if (expx <= MPFR_PREC(x))
    q = MPFR_PREC(x) + 1;
  else
    q = expx;
  MPFR_ASSERTN (q <= MPFR_PREC_MAX);
  mpfr_init2 (u, q);
  MPFR_DBGRES(inex = mpfr_ui_sub (u, 1, x, MPFR_RNDN));
  MPFR_ASSERTN(inex == 0);

  /* if x is half an integer, cot(Pi*x) = 0, thus Digamma(x) = Digamma(1-x) */
  mpfr_mul_2ui (u, u, 1, MPFR_RNDN);
  inex = mpfr_integer_p (u);
  mpfr_div_2ui (u, u, 1, MPFR_RNDN);
  if (inex)
    {
      inex = mpfr_digamma (y, u, rnd_mode);
      goto end;
    }

  mpfr_init2 (t, p);
  mpfr_init2 (v, p);

  MPFR_ZIV_INIT (loop, p);
  for (;;)
    {
      mpfr_const_pi (v, MPFR_RNDN);  /* v = Pi*(1+theta) for |theta|<=2^(-p) */
      mpfr_mul (t, v, x, MPFR_RNDN); /* (1+theta)^2 */
      e1 = MPFR_GET_EXP(t) - (mpfr_exp_t) p + 1; /* bound for t: err(t) <= 2^e1 */
      mpfr_cot (t, t, MPFR_RNDN);
      /* cot(t * (1+h)) = cot(t) - theta * (1 + cot(t)^2) with |theta|<=t*h */
      if (MPFR_GET_EXP(t) > 0)
        e1 = e1 + 2 * MPFR_EXP(t) + 1;
      else
        e1 = e1 + 1;
      /* now theta * (1 + cot(t)^2) <= 2^e1 */
      e1 += (mpfr_exp_t) p - MPFR_EXP(t); /* error is now 2^e1 ulps */
      mpfr_mul (t, t, v, MPFR_RNDN);
      e1 ++;
      mpfr_digamma (v, u, MPFR_RNDN);   /* error <= 1/2 ulp */
      expv = MPFR_GET_EXP (v);
      mpfr_sub (v, v, t, MPFR_RNDN);
      if (MPFR_NOTZERO(v))
        {
          if (MPFR_GET_EXP (v) < MPFR_GET_EXP (t))
            e1 += MPFR_EXP(t) - MPFR_EXP(v); /* scale error for t wrt new v */
          /* now take into account the 1/2 ulp error for v */
          if (expv - MPFR_EXP(v) - 1 > e1)
            e1 = expv - MPFR_EXP(v) - 1;
          else
            e1 ++;
          e1 ++; /* rounding error for mpfr_sub */
          if (MPFR_CAN_ROUND (v, p - e1, MPFR_PREC(y), rnd_mode))
            break;
        }
      MPFR_ZIV_NEXT (loop, p);
      mpfr_set_prec (t, p);
      mpfr_set_prec (v, p);
    }
  MPFR_ZIV_FREE (loop);

  inex = mpfr_set (y, v, rnd_mode);

  mpfr_clear (t);
  mpfr_clear (v);
 end:
  mpfr_clear (u);

  return inex;
}

/* we have x >= 1/2 here */
static int
mpfr_digamma_positive (mpfr_ptr y, mpfr_srcptr x, mpfr_rnd_t rnd_mode)
{
  mpfr_prec_t p = MPFR_PREC(y) + 10, q;
  mpfr_t t, u, x_plus_j;
  int inex;
  mpfr_exp_t errt, erru, expt;
  unsigned long j = 0, min;
  MPFR_ZIV_DECL (loop);

  MPFR_LOG_FUNC
    (("x[%Pd]=%.*Rg rnd=%d", mpfr_get_prec(x), mpfr_log_prec, x, rnd_mode),
     ("y[%Pd]=%.*Rg inexact=%d", mpfr_get_prec(y), mpfr_log_prec, y, inex));

  /* For very large x, use |digamma(x) - log(x)| < 1/x < 2^(1-EXP(x)).
     However, for a fixed value of GUARD, MPFR_CAN_ROUND() might fail
     with probability 1/2^GUARD, in which case the default code will
     fail since it requires x+1 to be exact, thus a huge precision if
     x is huge. There are two workarounds:
     * either perform a Ziv's loop, by increasing GUARD at each step.
       However, this might fail if x is moderately large, in which case
       more terms of the asymptotic expansion would be needed.
     * implement a full asymptotic expansion (with Ziv's loop). */
#define GUARD 30
  if (MPFR_PREC(y) + GUARD < MPFR_EXP(x))
    {
      /* this ensures EXP(x) >= 3, thus x >= 4, thus log(x) > 1 */
      mpfr_init2 (t, MPFR_PREC(y) + GUARD);
      mpfr_log (t, x, MPFR_RNDN);
      /* |t - digamma(x)| <= 1/2*ulp(t) + |digamma(x) - log(x)|
                          <= 1/2*ulp(t) + 2^(1-EXP(x))
                          <= 1/2*ulp(t) + 2^(-PREC(y)-GUARD)
                          <= ulp(t)
         since |t| >= 1 thus ulp(t) >= 2^(1-PREC(y)-GUARD) */
      if (MPFR_CAN_ROUND (t, MPFR_PREC(y) + GUARD, MPFR_PREC(y), rnd_mode))
        {
          inex = mpfr_set (y, t, rnd_mode);
          mpfr_clear (t);
          return inex;
        }
      mpfr_clear (t);
    }

  /* compute a precision q such that x+1 is exact */
  if (MPFR_PREC(x) < MPFR_GET_EXP(x))
    {
      /* The goal of the first assertion is to let the compiler ignore
         the second one when MPFR_EMAX_MAX <= MPFR_PREC_MAX. */
      MPFR_ASSERTD (MPFR_EXP(x) <= MPFR_EMAX_MAX);
      MPFR_ASSERTN (MPFR_EXP(x) <= MPFR_PREC_MAX);
      q = MPFR_EXP(x);
    }
  else
    q = MPFR_PREC(x) + 1;

  /* FIXME: q can be much too large, e.g. equal to the maximum exponent! */
  MPFR_LOG_MSG (("q=%Pd\n", q));

  mpfr_init2 (x_plus_j, q);

  mpfr_init2 (t, p);
  mpfr_init2 (u, p);
  MPFR_ZIV_INIT (loop, p);
  for(;;)
    {
      /* Lower bound for x+j in mpfr_digamma_approx call: since the smallest
         term of the divergent series for Digamma(x) is about exp(-2*Pi*x), and
         we want it to be less than 2^(-p), this gives x > p*log(2)/(2*Pi)
         i.e., x >= 0.1103 p.
         To be safe, we ensure x >= 0.25 * p.
      */
      min = (p + 3) / 4;
      if (min < 2)
        min = 2;

      mpfr_set (x_plus_j, x, MPFR_RNDN);
      mpfr_set_ui (u, 0, MPFR_RNDN);
      j = 0;
      while (mpfr_cmp_ui (x_plus_j, min) < 0)
        {
          j ++;
          mpfr_ui_div (t, 1, x_plus_j, MPFR_RNDN); /* err <= 1/2 ulp */
          mpfr_add (u, u, t, MPFR_RNDN);
          inex = mpfr_add_ui (x_plus_j, x_plus_j, 1, MPFR_RNDZ);
          if (inex != 0) /* we lost one bit */
            {
              q ++;
              mpfr_prec_round (x_plus_j, q, MPFR_RNDZ);
              mpfr_nextabove (x_plus_j);
            }
          /* since all terms are positive, the error is bounded by j ulps */
        }
      for (erru = 0; j > 1; erru++, j = (j + 1) / 2);
      errt = mpfr_digamma_approx (t, x_plus_j);
      expt = MPFR_GET_EXP (t);
      mpfr_sub (t, t, u, MPFR_RNDN);
      /* Warning! t may be zero (more likely in small precision). Note
         that in this case, this is an exact zero, not an underflow. */
      if (MPFR_NOTZERO(t))
        {
          if (MPFR_GET_EXP (t) < expt)
            errt += expt - MPFR_EXP(t);
          /* Warning: if u is zero (which happens when x_plus_j >= min at the
             beginning of the while loop above), EXP(u) is not defined.
             In this case we have no error from u. */
          if (MPFR_NOTZERO(u) && MPFR_GET_EXP (t) < MPFR_GET_EXP (u))
            erru += MPFR_EXP(u) - MPFR_EXP(t);
          if (errt > erru)
            errt = errt + 1;
          else if (errt == erru)
            errt = errt + 2;
          else
            errt = erru + 1;
          if (MPFR_CAN_ROUND (t, p - errt, MPFR_PREC(y), rnd_mode))
            break;
        }
      MPFR_ZIV_NEXT (loop, p);
      mpfr_set_prec (t, p);
      mpfr_set_prec (u, p);
    }
  MPFR_ZIV_FREE (loop);
  inex = mpfr_set (y, t, rnd_mode);
  mpfr_clear (t);
  mpfr_clear (u);
  mpfr_clear (x_plus_j);
  return inex;
}

int
mpfr_digamma (mpfr_ptr y, mpfr_srcptr x, mpfr_rnd_t rnd_mode)
{
  int inex;
  MPFR_SAVE_EXPO_DECL (expo);

  MPFR_LOG_FUNC
    (("x[%Pd]=%.*Rg rnd=%d", mpfr_get_prec(x), mpfr_log_prec, x, rnd_mode),
     ("y[%Pd]=%.*Rg inexact=%d", mpfr_get_prec(y), mpfr_log_prec, y, inex));

  if (MPFR_UNLIKELY(MPFR_IS_SINGULAR(x)))
    {
      if (MPFR_IS_NAN(x))
        {
          MPFR_SET_NAN(y);
          MPFR_RET_NAN;
        }
      else if (MPFR_IS_INF(x))
        {
          if (MPFR_IS_POS(x)) /* Digamma(+Inf) = +Inf */
            {
              MPFR_SET_SAME_SIGN(y, x);
              MPFR_SET_INF(y);
              MPFR_RET(0);
            }
          else                /* Digamma(-Inf) = NaN */
            {
              MPFR_SET_NAN(y);
              MPFR_RET_NAN;
            }
        }
      else /* Zero case */
        {
          /* the following works also in case of overlap */
          MPFR_SET_INF(y);
          MPFR_SET_OPPOSITE_SIGN(y, x);
          MPFR_SET_DIVBY0 ();
          MPFR_RET(0);
        }
    }

  /* Digamma is undefined for negative integers */
  if (MPFR_IS_NEG(x) && mpfr_integer_p (x))
    {
      MPFR_SET_NAN(y);
      MPFR_RET_NAN;
    }

  /* now x is a normal number */

  MPFR_SAVE_EXPO_MARK (expo);
  /* for x very small, we have Digamma(x) = -1/x - gamma + O(x), more precisely
     -1 < Digamma(x) + 1/x < 0 for -0.2 < x < 0.2, thus:
     (i) either x is a power of two, then 1/x is exactly representable, and
         as long as 1/2*ulp(1/x) > 1, we can conclude;
     (ii) otherwise assume x has <= n bits, and y has <= n+1 bits, then
   |y + 1/x| >= 2^(-2n) ufp(y), where ufp means unit in first place.
   Since |Digamma(x) + 1/x| <= 1, if 2^(-2n) ufp(y) >= 2, then
   |y - Digamma(x)| >= 2^(-2n-1)ufp(y), and rounding -1/x gives the correct result.
   If x < 2^E, then y > 2^(-E), thus ufp(y) > 2^(-E-1).
   A sufficient condition is thus EXP(x) <= -2 MAX(PREC(x),PREC(Y)). */
  if (MPFR_GET_EXP (x) < -2)
    {
      if (MPFR_EXP(x) <= -2 * (mpfr_exp_t) MAX(MPFR_PREC(x), MPFR_PREC(y)))
        {
          int signx = MPFR_SIGN(x);
          inex = mpfr_si_div (y, -1, x, rnd_mode);
          if (inex == 0) /* x is a power of two */
            { /* result always -1/x, except when rounding down */
              if (rnd_mode == MPFR_RNDA)
                rnd_mode = (signx > 0) ? MPFR_RNDD : MPFR_RNDU;
              if (rnd_mode == MPFR_RNDZ)
                rnd_mode = (signx > 0) ? MPFR_RNDU : MPFR_RNDD;
              if (rnd_mode == MPFR_RNDU)
                inex = 1;
              else if (rnd_mode == MPFR_RNDD)
                {
                  mpfr_nextbelow (y);
                  inex = -1;
                }
              else /* nearest */
                inex = 1;
            }
          MPFR_SAVE_EXPO_UPDATE_FLAGS (expo, __gmpfr_flags);
          goto end;
        }
    }

  /* if x < 1/2 we use the reflection formula */
  if (MPFR_IS_NEG(x) || MPFR_EXP(x) < 0)
    inex = mpfr_digamma_reflection (y, x, rnd_mode);
  else
    inex = mpfr_digamma_positive (y, x, rnd_mode);

 end:
  MPFR_SAVE_EXPO_FREE (expo);
  return mpfr_check_range (y, inex, rnd_mode);
}

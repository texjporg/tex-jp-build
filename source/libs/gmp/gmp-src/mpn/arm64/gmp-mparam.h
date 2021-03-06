/* gmp-mparam.h -- Compiler/machine parameter header file.

Copyright 2019 Free Software Foundation, Inc.

This file is part of the GNU MP Library.

The GNU MP Library is free software; you can redistribute it and/or modify
it under the terms of either:

  * the GNU Lesser General Public License as published by the Free
    Software Foundation; either version 3 of the License, or (at your
    option) any later version.

or

  * the GNU General Public License as published by the Free Software
    Foundation; either version 2 of the License, or (at your option) any
    later version.

or both in parallel, as here.

The GNU MP Library is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
for more details.

You should have received copies of the GNU General Public License and the
GNU Lesser General Public License along with the GNU MP Library.  If not,
see https://www.gnu.org/licenses/.  */

#define GMP_LIMB_BITS 64
#define GMP_LIMB_BYTES 8

/* 1536 MHz Cortex-A53 */
/* FFT tuning limit = 0.5 M */
/* Generated by tuneup.c, 2019-09-29, gcc 5.4 */

#define DIVREM_1_NORM_THRESHOLD              3
#define DIVREM_1_UNNORM_THRESHOLD            4
#define MOD_1_1P_METHOD                      2  /* 2.08% faster than 1 */
#define MOD_1_NORM_THRESHOLD                 3
#define MOD_1_UNNORM_THRESHOLD               4
#define MOD_1N_TO_MOD_1_1_THRESHOLD          8
#define MOD_1U_TO_MOD_1_1_THRESHOLD          6
#define MOD_1_1_TO_MOD_1_2_THRESHOLD        10
#define MOD_1_2_TO_MOD_1_4_THRESHOLD        20
#define PREINV_MOD_1_TO_MOD_1_THRESHOLD     21
#define USE_PREINV_DIVREM_1                  1
#define DIV_QR_1N_PI1_METHOD                 1  /* 38.26% faster than 2 */
#define DIV_QR_1_NORM_THRESHOLD             13
#define DIV_QR_1_UNNORM_THRESHOLD        MP_SIZE_T_MAX  /* never */
#define DIV_QR_2_PI2_THRESHOLD           MP_SIZE_T_MAX  /* never */
#define DIVEXACT_1_THRESHOLD                 0  /* always */
#define BMOD_1_TO_MOD_1_THRESHOLD           40

#define DIV_1_VS_MUL_1_PERCENT             159

#define MUL_TOOM22_THRESHOLD                14
#define MUL_TOOM33_THRESHOLD                49
#define MUL_TOOM44_THRESHOLD                82
#define MUL_TOOM6H_THRESHOLD               173
#define MUL_TOOM8H_THRESHOLD               236

#define MUL_TOOM32_TO_TOOM43_THRESHOLD      81
#define MUL_TOOM32_TO_TOOM53_THRESHOLD      76
#define MUL_TOOM42_TO_TOOM53_THRESHOLD      81
#define MUL_TOOM42_TO_TOOM63_THRESHOLD      80
#define MUL_TOOM43_TO_TOOM54_THRESHOLD      74

#define SQR_BASECASE_THRESHOLD               0  /* always */
#define SQR_TOOM2_THRESHOLD                 18
#define SQR_TOOM3_THRESHOLD                 67
#define SQR_TOOM4_THRESHOLD                166
#define SQR_TOOM6_THRESHOLD                222
#define SQR_TOOM8_THRESHOLD                333

#define MULMID_TOOM42_THRESHOLD             20

#define MULMOD_BNM1_THRESHOLD               10
#define SQRMOD_BNM1_THRESHOLD               11

#define MUL_FFT_MODF_THRESHOLD             316  /* k = 5 */
#define MUL_FFT_TABLE3                                      \
  { {    316, 5}, {     13, 6}, {      7, 5}, {     15, 6}, \
    {     13, 7}, {      7, 6}, {     15, 7}, {      8, 6}, \
    {     17, 7}, {      9, 6}, {     19, 7}, {     17, 8}, \
    {      9, 7}, {     20, 8}, {     11, 7}, {     23, 8}, \
    {     13, 9}, {      7, 8}, {     19, 9}, {     11, 8}, \
    {     27, 9}, {     15, 8}, {     33, 9}, {     19, 8}, \
    {     41, 9}, {     23, 8}, {     49, 9}, {     27,10}, \
    {     15, 9}, {     39,10}, {     23, 9}, {     51,11}, \
    {     15,10}, {     31, 9}, {     71,10}, {     39, 9}, \
    {     83,10}, {     47, 9}, {     99,10}, {     55,11}, \
    {     31,10}, {     63, 9}, {    127, 8}, {    255, 9}, \
    {    131,10}, {     71, 8}, {    287,10}, {     79, 9}, \
    {    159, 8}, {    319,10}, {     87,11}, {     47,10}, \
    {     95, 9}, {    191, 8}, {    383,10}, {    103, 9}, \
    {    207, 8}, {    415,10}, {    111, 9}, {    223,12}, \
    {     31,11}, {     63, 9}, {    255, 8}, {    511,10}, \
    {    135, 9}, {    287, 8}, {    575,11}, {     79,10}, \
    {    159, 9}, {    319, 8}, {    639,10}, {    175, 9}, \
    {    351, 8}, {    703,11}, {     95,10}, {    191, 9}, \
    {    383, 8}, {    767,10}, {    207, 9}, {    415,11}, \
    {    111,10}, {    223, 9}, {    447,12}, {     63,10}, \
    {    255, 9}, {    511, 8}, {   1023, 9}, {    543,10}, \
    {    287, 9}, {    575, 8}, {   1151,11}, {    159,10}, \
    {    319, 9}, {    639,11}, {    175,10}, {    351, 9}, \
    {    703, 8}, {   1407,12}, {     95,11}, {    191,10}, \
    {    383, 9}, {    767,11}, {    207,10}, {    415, 9}, \
    {    831,11}, {    223,10}, {    447,13}, {   8192,14}, \
    {  16384,15}, {  32768,16}, {  65536,17}, { 131072,18}, \
    { 262144,19}, { 524288,20}, {1048576,21}, {2097152,22}, \
    {4194304,23}, {8388608,24} }
#define MUL_FFT_TABLE3_SIZE 118
#define MUL_FFT_THRESHOLD                 3200

#define SQR_FFT_MODF_THRESHOLD             272  /* k = 5 */
#define SQR_FFT_TABLE3                                      \
  { {    272, 5}, {     13, 6}, {      7, 5}, {     15, 6}, \
    {      8, 5}, {     17, 6}, {     17, 7}, {     17, 8}, \
    {      9, 7}, {     19, 8}, {     11, 7}, {     23, 8}, \
    {     13, 9}, {      7, 8}, {     15, 7}, {     31, 8}, \
    {     19, 9}, {     11, 8}, {     27, 9}, {     15, 8}, \
    {     33, 9}, {     19, 8}, {     39, 9}, {     23, 8}, \
    {     47, 9}, {     27,10}, {     15, 9}, {     39,10}, \
    {     23, 9}, {     47,11}, {     15,10}, {     31, 9}, \
    {     67,10}, {     39, 9}, {     79,10}, {     47, 9}, \
    {     95, 8}, {    191,10}, {     55,11}, {     31,10}, \
    {     63, 8}, {    255,10}, {     71, 9}, {    143, 8}, \
    {    287,10}, {     79, 9}, {    159,11}, {     47,10}, \
    {     95, 9}, {    191, 8}, {    383, 7}, {    767,10}, \
    {    103, 9}, {    207,12}, {     31,11}, {     63, 9}, \
    {    255, 8}, {    511, 7}, {   1023, 9}, {    271,10}, \
    {    143, 9}, {    287,11}, {     79,10}, {    159, 9}, \
    {    319, 8}, {    639,10}, {    175, 9}, {    351, 8}, \
    {    703,11}, {     95,10}, {    191, 9}, {    383, 8}, \
    {    767,10}, {    207, 9}, {    415, 8}, {    831,10}, \
    {    223,12}, {     63,10}, {    255, 9}, {    511, 8}, \
    {   1023,10}, {    271,11}, {    143,10}, {    287, 9}, \
    {    575, 8}, {   1151,11}, {    159,10}, {    319, 9}, \
    {    639,11}, {    175,10}, {    351, 9}, {    703,12}, \
    {     95,11}, {    191,10}, {    383, 9}, {    767,11}, \
    {    207,10}, {    415, 9}, {    831,11}, {    223,10}, \
    {    447,13}, {   8192,14}, {  16384,15}, {  32768,16}, \
    {  65536,17}, { 131072,18}, { 262144,19}, { 524288,20}, \
    {1048576,21}, {2097152,22}, {4194304,23}, {8388608,24} }
#define SQR_FFT_TABLE3_SIZE 112
#define SQR_FFT_THRESHOLD                 2688

#define MULLO_BASECASE_THRESHOLD             0  /* always */
#define MULLO_DC_THRESHOLD                  38
#define MULLO_MUL_N_THRESHOLD             6253
#define SQRLO_BASECASE_THRESHOLD             4
#define SQRLO_DC_THRESHOLD                  67
#define SQRLO_SQR_THRESHOLD               5240

#define DC_DIV_QR_THRESHOLD                 42
#define DC_DIVAPPR_Q_THRESHOLD             152
#define DC_BDIV_QR_THRESHOLD                39
#define DC_BDIV_Q_THRESHOLD                 93

#define INV_MULMOD_BNM1_THRESHOLD           37
#define INV_NEWTON_THRESHOLD               163
#define INV_APPR_THRESHOLD                 162

#define BINV_NEWTON_THRESHOLD              194
#define REDC_1_TO_REDC_N_THRESHOLD          43

#define MU_DIV_QR_THRESHOLD                998
#define MU_DIVAPPR_Q_THRESHOLD             998
#define MUPI_DIV_QR_THRESHOLD               98
#define MU_BDIV_QR_THRESHOLD               807
#define MU_BDIV_Q_THRESHOLD                924

#define POWM_SEC_TABLE  6,30,194,579,1730

#define GET_STR_DC_THRESHOLD                15
#define GET_STR_PRECOMPUTE_THRESHOLD        29
#define SET_STR_DC_THRESHOLD               788
#define SET_STR_PRECOMPUTE_THRESHOLD      1816

#define FAC_DSC_THRESHOLD                  236
#define FAC_ODD_THRESHOLD                   24

#define MATRIX22_STRASSEN_THRESHOLD         10
#define HGCD2_DIV1_METHOD                    1  /* 7.05% faster than 3 */
#define HGCD_THRESHOLD                     101
#define HGCD_APPR_THRESHOLD                104
#define HGCD_REDUCE_THRESHOLD             1679
#define GCD_DC_THRESHOLD                   330
#define GCDEXT_DC_THRESHOLD                242
#define JACOBI_BASE_METHOD                   4  /* 20.00% faster than 1 */

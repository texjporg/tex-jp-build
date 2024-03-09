/*
  unicode.c -- utilities for Unicode
  written by N. Tsuchimura
*/

#include <ptexenc/c-auto.h>
#include <ptexenc/unicode.h>
#include <ptexenc/kanjicnv.h>

#include <stdio.h>  /* for fprintf() */

/* determine if UTF-8 character or not */
boolean isUTF8(int length, int nth, int c)
{
    c &= 0xff;
    switch (length * 8 + nth) {
    case 011: return (0x00 <= c && c < 0x80);
    case 021: return (0xc2 <= c && c < 0xe0);
    case 031: return (0xe0 <= c && c < 0xf0);
    case 041: return (0xf0 <= c && c < 0xf5);
    case 022:
    case 032: case 033:
    case 042: case 043: case 044:
        return (0x80 <= c && c < 0xc0);
    default:
        fprintf(stderr, "isUTF8: unexpected param length=%d, nth=%d\n",
                length, nth);
    }        
    return false;
}


int UTF8length(int first_byte)
{
    first_byte &= 0xff;
    if (first_byte < 0x80) return 1;
    if (first_byte < 0xc2) return -2;  /* illegal */
    if (first_byte < 0xe0) return 2;
    if (first_byte < 0xf0) return 3;
    if (first_byte < 0xf5) return 4;
    return -1; /* reserved/undefined */
}


/* with strict range check */
#define DEFINE_UTF8SLENGTH(SUFF,TYPE) \
int UTF8Slength ## SUFF(TYPE *buff, int buff_len) \
{ \
    int i, len; \
    len = UTF8length(buff[0]); \
    if (len < 0) return -2; /* illegal */ \
    if (len > buff_len) return -3; /* overflow */ \
    for (i=0; i<len; i++) { \
        if (!isUTF8(len, 1+i, buff[i])) return -1; /* not UTF-8 */ \
    } \
    return len; \
}

DEFINE_UTF8SLENGTH(, unsigned char)
DEFINE_UTF8SLENGTH(short, unsigned short)


/* WITHOUT strict range check */
long UTF8StoUCS(unsigned char *s)
{
    switch (UTF8length(s[0])) {
    case 1: return s[0];
    case 2: return UTF8BtoUCS(s[0], s[1]);
    case 3: return UTF8CtoUCS(s[0], s[1], s[2]);
    case 4: return UTF8DtoUCS(s[0], s[1], s[2], s[3]);
    default: return 0; /* error */
    }
}

/* used only for debug */
#ifdef DEBUG
int UCStoUTF8S(long ucs, unsigned char *s)
{
    if (ucs < 0x80) {
	*s = ucs;
	return 1;
    } else if (ucs < 0x800) {
	*s++ = UCStoUTF8B1(ucs);
	*s++ = UCStoUTF8B2(ucs);
	return 2;
    } else if (ucs < 0xFFFF) {
	*s++ = UCStoUTF8C1(ucs);
	*s++ = UCStoUTF8C2(ucs);
	*s++ = UCStoUTF8C3(ucs);
	return 3;
    } else if (ucs < 0x10FFFF) {
	*s++ = UCStoUTF8D1(ucs);
	*s++ = UCStoUTF8D2(ucs);
	*s++ = UCStoUTF8D3(ucs);
	*s++ = UCStoUTF8D4(ucs);
	return 4;
    }
    return 0; /* unsupported */
}
#endif /* DEBUG */


long UCStoUTF8(long ucs)
{
    if (ucs < 0x80)     return ucs;
    if (ucs < 0x800)    return LONG(0,0,
				    UCStoUTF8B1(ucs),
				    UCStoUTF8B2(ucs));
    if (ucs < 0xFFFF)   return LONG(0,
				    UCStoUTF8C1(ucs),
				    UCStoUTF8C2(ucs),
				    UCStoUTF8C3(ucs));
    if (ucs < 0x10FFFF) return LONG(UCStoUTF8D1(ucs),
				    UCStoUTF8D2(ucs),
				    UCStoUTF8D3(ucs),
				    UCStoUTF8D4(ucs));
    return 0; /* unsupported */
}


#define UCS_MAX 0x110000L

/* using over U+10.FFFF Area */
long UCStoUPTEX (long ucs)
{
    return ucs;
}

/* using over U+10.FFFF Area */
long UPTEXtoUCS (long uptex)
{
    long vs;
    if (uptex>=0xC00000) {                        /* for SVS */
        return uptex;
    }
    if (uptex>=0x400000) {                        /* for IVS */
        uptex = UVS_divide_code(uptex, &vs);
        if (uptex == 0) return 0;
        if (vs >= 0xE0100) {
            return ((vs-0xE0100 +16) << 20) + uptex;
        } else {
            return ((vs-0xFE00) << 18) + 0xC00000 + uptex;
        }
    }
    if (uptex>=UCS_MAX*2) return uptex;
    if (uptex>=UCS_MAX)   return uptex % UCS_MAX; /* for OTF package */
    return uptex;
}

long
UVS_combine_code(long ucv, long uvs)
{
    if (ucv > 0x3FFFF)
        return 0;
    if (ucv <= 0x2FFFF && uvs >= 0xFE00 && uvs <= 0xFE0F) { /* SVS, VS1 .. VS16 */
        return ucv + ((uvs - 0xFE00) << 18) + 0xC00000;
    }
    if (uvs >= 0xE0100) {  /* IVS */
        if (                  ucv <= 0x0FFFF && uvs <=0xE011F) { /* VS17 .. VS48 */
            return  ucv           + ((uvs - 0xE0100 + 0x40) << 16);
        }
        if (ucv >= 0x20000 && ucv <= 0x2FFFF && uvs <=0xE010F) { /* VS17 .. VS32 */
            return (ucv & 0xFFFF) + ((uvs - 0xE0100 + 0x80) << 16);
        }
        if (ucv >= 0x30000                   && uvs <=0xE010F) { /* VS17 .. VS32 */
            return (ucv & 0xFFFF) + ((uvs - 0xE0100 + 0xA0) << 16);
        }
    }
    /* Unsupported Variation Sequence */
    return 0;
}

long
UVS_divide_code(long code, long* uvs)
{
    long u, v;

    if (code<0x400000 || code>=0x1000000) {
      /* Undefined */
        goto Undefined;
    }

    if (code>=0xC00000) {
      /* SVS */
        u = code & 0x3FFFF;
        v = (code & 0x3FFFFF) >> 18;
        if (uvs) *uvs = v + 0xFE00;
        return u;
    }

      /* IVS */
    u = code & 0xFFFF;
    v = code >> 16;
    if (v < 0x40) {
        goto Undefined;
    } else if (v < 0x60) {
        if (uvs) *uvs = v - 0x40 + 0xE0100;
        return u;
    } else if (v < 0x80) {
        goto Undefined;
    } else if (v < 0x90) {
        if (uvs) *uvs = v - 0x80 + 0xE0100;
        return u + 0x20000;
    } else if (v < 0xA0) {
        goto Undefined;
    } else if (v < 0xB0) {
        if (uvs) *uvs = v - 0xA0 + 0xE0100;
        return u + 0x30000;
    }

 Undefined:
    /* Undefined */
    if (uvs) *uvs = 0;
    return 0;
}

/* This is dvipdfmx, an eXtended version of dvipdfm by Mark A. Wicks.

    Copyright (C) 2002-2021 by Jin-Hwan Cho, Matthias Franz, and Shunsaku Hirata,
    the dvipdfmx project team.
    
    Copyright (C) 1998, 1999 by Mark A. Wicks <mwicks@kettering.edu>

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.
    
    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.
    
    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA.
*/

#ifdef HAVE_CONFIG_H
#include <config.h>
#endif

#include <string.h>

#include "system.h"
#include "error.h"
#include "mem.h"

#include "dpxconf.h"
#include "dpxcrypt.h"
#include "dpxfile.h"
#include "dpxutil.h"

#include "pdfobj.h"

#include "agl.h"
#include "pdfencoding.h"
#include "cmap.h"
#include "unicode.h"

#include "type1.h"
#include "type1c.h"
#include "truetype.h"

#include "pkfont.h"

#include "cidtype0.h"
#include "type0.h"
#include "tt_cmap.h"

#include "dvipdfmx.h"

#include "pdffont.h"

#define MREC_HAS_TOUNICODE(m) ((m) && (m)->opt.tounicode)

void
pdf_font_set_dpi (int font_dpi)
{
  PKFont_set_dpi(font_dpi);
}

static union {
  char p[sizeof(int)];
  int* i;
} unique_tag_count;

/* This function used to be implemented as
 *
 *     for (i = 0; i < 6; i++) {
 *         ch = rand() % 26;
 *         tag[i] = ch + 'A';
 *     }
 *     tag[6] = '\0';
 *
 * but this meant that the tag would change on every run, producing a
 * non-deterministic PDF file. You could work around this by setting
 * `SOURCE_DATE_EPOCH` in the environment (since the current time is used to
 * seed `rand`), but that requires extra effort. Instead, we use an MD5 hash of
 * the input (dvi) filename, the output (pdf) filename, and a counter that
 * increments on each call to this function. This produces a deterministic tag
 * for each document, provided that the input filename, the output filename, and
 * the order/number of fonts remains the same.
 *
 * Why do we need this function in the first place? Well, since we are
 * subsetting the fonts, this means that the "LM Roman 10" font in one document
 * will not be the same as the "LM Roman 10" font in another document. This can
 * cause problems when older/buggy PDF processors merge or embed multiple
 * documents, since it's invalid to have two fonts with the same name and
 * neither font is a strict subset/superset of the other.
 *
 * pdfTeX and LuaTeX solve this by hashing over the subsetting hash table, but
 * this only works there since they only generate the PDF font name _after_
 * creating the subset. (x)dvipdfmx generates the PDF font name as (almost) the
 * very first step when including a font, so we couldn't use this method without
 * extensive refactoring.
 *
 * The pdfTeX and LuaTeX methods guarantee that multiple incompatible subsets
 * will never have the same name (barring hash collisions), and the prior `rand`
 * method had the same guarantee (barring an _extremely_ unlikely RNG
 * collision). This new method isn't quite as good since if the input and output
 * are both pipes, then both filenames will be `NULL` and the tag will only
 * depend on the counter. But I think that most PDF processors these days will
 * properly check for font name collisions, so this is probably good enough.
 */
void
pdf_font_make_uniqueTag (char *tag)
{
  MD5_CONTEXT state;
  unsigned char digest[16];
  int i, ch;

  unique_tag_count.i++;

  MD5_init(&state);
  if (dvi_filename)
    MD5_write(&state, dvi_filename, strlen(dvi_filename));
  if (pdf_filename)
    MD5_write(&state, pdf_filename, strlen(pdf_filename));
  MD5_write(&state, unique_tag_count.p, sizeof(unique_tag_count));
  MD5_final(digest, &state);

  for (i = 0; i < 6; i++) {
    ch = digest[i] % 26;
    tag[i] = ch + 'A';
  }
  tag[6] = '\0';
}

static void
init_CIDSysInfo (CIDSysInfo *csi) {
  csi->registry   = NULL;
  csi->ordering   = NULL;
  csi->supplement = 0;
}

static void
pdf_init_font_struct (pdf_font *font)
{
  ASSERT(font);

  font->ident       = NULL;
  font->filename    = NULL;
  font->subtype     = -1;
  font->font_id     = -1;
  font->fontname    = NULL;
  memset(font->uniqueID, 0, 7);
  font->index       = 0;

  font->encoding_id = -1;

  font->reference   = NULL;
  font->resource    = NULL;
  font->descriptor  = NULL;

  font->point_size  = 0;
  font->design_size = 0;

  font->usedchars   = NULL;
  font->flags       = 0;

  font->type0.descendant = -1;
  font->type0.wmode      = 0;

  init_CIDSysInfo(&font->cid.csi);
  font->cid.need_vmetrics  = 0;
  font->cid.usedchars_v    = NULL;
  font->cid.options.embed  = 0;
  font->cid.options.style  = FONT_STYLE_NONE;
  font->cid.options.stemv  = 0;
  init_CIDSysInfo(&font->cid.options.csi);

  return;
}

static void
pdf_flush_font (pdf_font *font)
{
  char *fontname, *uniqueTag;

  if (!font)
    return;
  if ((font->flags & PDF_FONT_FLAG_IS_ALIAS) || (font->flags & PDF_FONT_FLAG_IS_REENCODE)) {
    return;
  }

  if (font->resource && font->reference) {
    switch (font->subtype) {
    case PDF_FONT_FONTTYPE_TYPE3:
    case PDF_FONT_FONTTYPE_TYPE0:
      break;
    case PDF_FONT_FONTTYPE_CIDTYPE0:
    case PDF_FONT_FONTTYPE_CIDTYPE2:
      break;
    default:
      if (font->flags & PDF_FONT_FLAG_NOEMBED) {
        pdf_add_dict(font->resource, pdf_new_name("BaseFont"), pdf_new_name(font->fontname));
        if (font->descriptor) {
          pdf_add_dict(font->descriptor, pdf_new_name("FontName"), pdf_new_name(font->fontname));
        }
      } else {
        ASSERT(font->fontname);
        fontname  = NEW(7+strlen(font->fontname)+1, char);
        uniqueTag = pdf_font_get_uniqueTag(font);
        sprintf(fontname, "%6s+%s", uniqueTag, font->fontname);
        pdf_add_dict(font->resource, pdf_new_name("BaseFont"), pdf_new_name(fontname));
        if (font->descriptor) {
          pdf_add_dict(font->descriptor, pdf_new_name("FontName"), pdf_new_name(fontname));
        }
        RELEASE(fontname);
      }
      if (font->descriptor) {
        pdf_add_dict(font->resource, pdf_new_name("FontDescriptor"), pdf_ref_obj(font->descriptor));
      }
    }
  }

  if (font->resource)
    pdf_release_obj(font->resource);
  if (font->descriptor)
    pdf_release_obj(font->descriptor);
  if (font->reference)
    pdf_release_obj(font->reference);

  font->reference  = NULL;
  font->resource   = NULL;
  font->descriptor = NULL;

  return;
}

static void
pdf_clean_font_struct (pdf_font *font)
{
  if (!font)
    return;

  if (font->resource)
    WARN("font \"%s\" not properly released?", font->ident);
    
  if (font->ident)
    RELEASE(font->ident);
  if (font->filename)
    RELEASE(font->filename);
  if (font->fontname)
    RELEASE(font->fontname);
  if (font->usedchars) {
    if (!(font->flags & PDF_FONT_FLAG_USEDCHAR_SHARED))
    RELEASE(font->usedchars);
  }
  if (font->cid.csi.registry)
    RELEASE(font->cid.csi.registry);
  if (font->cid.csi.ordering)
    RELEASE(font->cid.csi.ordering);
  if (font->cid.options.csi.registry)
    RELEASE(font->cid.options.csi.registry);
  if (font->cid.options.csi.ordering)
    RELEASE(font->cid.options.csi.ordering);
  if (font->cid.usedchars_v)
    RELEASE(font->cid.usedchars_v);

  font->ident     = NULL;
  font->filename  = NULL;
  font->fontname  = NULL;
  font->usedchars = NULL;
  font->cid.csi.registry = NULL;
  font->cid.csi.ordering = NULL;
  font->cid.options.csi.registry = NULL;
  font->cid.options.csi.ordering = NULL;
  font->cid.usedchars_v  = NULL;

  return;
}

#define CACHE_ALLOC_SIZE 16u

static struct {
  int       count;
  int       capacity;
  pdf_font *fonts;
} font_cache = {
  0, 0, NULL
};

void
pdf_init_fonts (void)
{
  ASSERT(font_cache.fonts == NULL);  

  agl_init_map();

  CMap_cache_init();
  pdf_init_encodings();

  font_cache.count    = 0;
  font_cache.capacity = CACHE_ALLOC_SIZE;
  font_cache.fonts    = NEW(font_cache.capacity, pdf_font);

  {
    time_t current_time;

    current_time = dpx_util_get_unique_time_if_given();
    if (current_time == INVALID_EPOCH_VALUE)
      current_time = time(NULL);
    srand(current_time);
  }
}

#define CHECK_ID(n) do {\
  if ((n) < 0 || (n) >= font_cache.count) {\
    ERROR("Invalid font ID: %d", (n));\
  }\
} while (0)

static pdf_font *
GET_FONT (int font_id)
{
  pdf_font *font = NULL;

  if (font_id >= 0 && font_id < font_cache.count) {
   font = &font_cache.fonts[font_id];
   if (font->flags & PDF_FONT_FLAG_IS_ALIAS) {
     font = &font_cache.fonts[font->font_id];
   }
  }
  
  return font;
}

pdf_font *
pdf_get_font_data (int font_id)
{
  CHECK_ID(font_id);

  return &font_cache.fonts[font_id];
}

char *
pdf_get_font_ident (int font_id)
{
  pdf_font *font;

  CHECK_ID(font_id);

  font = &font_cache.fonts[font_id];

  return font->ident;
}

pdf_obj *
pdf_get_font_reference (int font_id)
{
  pdf_font  *font;

  CHECK_ID(font_id);

  font = GET_FONT(font_id);
  if (font->flags & PDF_FONT_FLAG_IS_REENCODE) {
    font = GET_FONT(font->font_id);
  }
  if (!font->reference) {
    font->reference = pdf_ref_obj(pdf_font_get_resource(font));
  }
  if (font->subtype == PDF_FONT_FONTTYPE_TYPE0) {
    if (!pdf_lookup_dict(font->resource, "DescendantFonts")) {
      pdf_obj  *array;

      array = pdf_new_array();
      pdf_add_array(array, pdf_get_font_reference(font->type0.descendant));
      pdf_add_dict(font->resource, pdf_new_name("DescendantFonts"), array);
    }
  }

  return pdf_link_obj(font->reference);
}

pdf_obj *
pdf_get_font_resource (int font_id)
{
  pdf_font  *font;

  CHECK_ID(font_id);

  font = GET_FONT(font_id);
  if (font->flags & PDF_FONT_FLAG_IS_REENCODE) {
    font = GET_FONT(font->font_id);
  }
  if (!font->resource)
    font->resource = pdf_new_dict();

  return font->resource; /* FIXME */
}

char *
pdf_get_font_usedchars (int font_id)
{
  pdf_font *font;

  CHECK_ID(font_id);

  font = GET_FONT(font_id);
  if (font->flags & PDF_FONT_FLAG_IS_REENCODE) {
    font = GET_FONT(font->font_id);
  }
  if (font->subtype != PDF_FONT_FONTTYPE_TYPE0) {
    if (!font->usedchars) {
      font->usedchars = NEW(256, char);
      memset(font->usedchars, 0, 256 * sizeof(char));
    }
  }

  return font->usedchars;
}

int
pdf_get_font_wmode (int font_id)
{
  pdf_font *font;

  CHECK_ID(font_id);

  font = GET_FONT(font_id);
  if (font->flags & PDF_FONT_FLAG_IS_REENCODE) {
    font = GET_FONT(font->font_id);
  }
  if (font->subtype == PDF_FONT_FONTTYPE_TYPE0) {
    return font->type0.wmode;
  } else {
    return 0;
  }
}

int
pdf_get_font_subtype (int font_id)
{
  pdf_font *font;

  CHECK_ID(font_id);

  font = GET_FONT(font_id);
  if (font->flags & PDF_FONT_FLAG_IS_REENCODE) {
    font = GET_FONT(font->font_id);
  }

  return font->subtype;
}

int
pdf_get_font_encoding (int font_id)
{
  pdf_font *font;

  CHECK_ID(font_id);

  font = GET_FONT(font_id);

  return font->encoding_id;
}

int
pdf_font_resource_name (int font_id, char *buff)
{
  int       len;
  pdf_font *font;

  CHECK_ID(font_id);

  font = &font_cache.fonts[font_id];
  if (font->flags & PDF_FONT_FLAG_IS_ALIAS) {
    font_id = font->font_id;
  }
  font = GET_FONT(font_id);
  if (font->flags & PDF_FONT_FLAG_IS_REENCODE) {
    font_id = font->font_id;
  }
  len = sprintf(buff, "F%d", font_id);

  return len;
}

/* The rule for ToUnicode creation is:
 *
 *  If "tounicode" option is specified in fontmap, use that.
 *  If there is ToUnicode CMap with same name as TFM, use that.
 *  If no "tounicode" option is used and no ToUnicode CMap with
 *  same name as TFM is found, create ToUnicode CMap from glyph
 *  names and AGL file.
 */
static int
try_load_ToUnicode_CMap (pdf_font *font)
{
  pdf_obj     *tounicode;
  const char  *cmap_name = NULL;
  fontmap_rec *mrec      = NULL; /* Be sure fontmap is still alive here */

  ASSERT(font);

  /* We are using different encoding for Type0 font.
   * This feature is unavailable for them.
   */
  if (font->subtype == PDF_FONT_FONTTYPE_TYPE0)
    return  0;

  ASSERT(font->ident);

  mrec = pdf_lookup_fontmap_record(font->ident);
  if (MREC_HAS_TOUNICODE(mrec)) {
    cmap_name = mrec->opt.tounicode;
  } else {
    cmap_name = font->ident;
  }
  tounicode = pdf_load_ToUnicode_stream(cmap_name);

  if (!tounicode) {
    if (MREC_HAS_TOUNICODE(mrec)) {
      WARN("Failed to read ToUnicode mapping \"%s\"...", mrec->opt.tounicode);
    }
  } else {
    if (pdf_obj_typeof(tounicode) != PDF_STREAM) {
      ERROR("Object returned by pdf_load_ToUnicode_stream() not stream object! (This must be bug)");
    } else if (pdf_stream_length(tounicode) > 0) {
      pdf_obj *fontdict = pdf_font_get_resource(font);

      pdf_add_dict(fontdict,
                   pdf_new_name("ToUnicode"),
                   pdf_ref_obj (tounicode)); /* _FIXME_ */
      if (dpx_conf.verbose_level > 0)
        MESG("pdf_font>> ToUnicode CMap \"%s\" attached to font id=\"%s\".\n",
             cmap_name, font->ident);
    }
    pdf_release_obj(tounicode);
  }

  return  0;
}

void
pdf_close_fonts (void)
{
  int  font_id;

  for (font_id = 0; font_id < font_cache.count; font_id++) {
    pdf_font  *font;

    font = &font_cache.fonts[font_id];
    if ((font->flags & PDF_FONT_FLAG_IS_ALIAS) ||
        (font->flags & PDF_FONT_FLAG_IS_REENCODE) ||
        !font->reference) {
      continue;
    }
    if (font->subtype == PDF_FONT_FONTTYPE_CIDTYPE0 ||
        font->subtype == PDF_FONT_FONTTYPE_CIDTYPE2) {
      continue;
    }

    if (dpx_conf.verbose_level > 0) {
      if (font->subtype != PDF_FONT_FONTTYPE_TYPE0) {
        MESG("(%s", font->filename);
        if (dpx_conf.verbose_level > 2 &&
            !(font->flags & PDF_FONT_FLAG_NOEMBED)) {
          MESG("[%s+%s]", pdf_font_get_uniqueTag(font), font->fontname);
        } else if (dpx_conf.verbose_level > 1) {
          MESG("[%s]", font->fontname);
        }
        if (dpx_conf.verbose_level > 1) {
          if (font->encoding_id >= 0) {
            MESG("[%s]", pdf_encoding_get_name(font->encoding_id));
          } else {
            MESG("[built-in]");
          }
        }
      }
    }

    /* Must come before load_xxx */
    try_load_ToUnicode_CMap(font);

    switch (font->subtype) {
    case PDF_FONT_FONTTYPE_TYPE1:
      if (dpx_conf.verbose_level > 0)
        MESG("[Type1]");
      if (!(font->flags & PDF_FONT_FLAG_BASEFONT))
        pdf_font_load_type1(font);
      break;
    case PDF_FONT_FONTTYPE_TYPE1C:
      if (dpx_conf.verbose_level > 0)
        MESG("[Type1C]");
      pdf_font_load_type1c(font);
      break;
    case PDF_FONT_FONTTYPE_TRUETYPE:
      if (dpx_conf.verbose_level > 0)
        MESG("[TrueType]");
      pdf_font_load_truetype(font);
      break;
    case PDF_FONT_FONTTYPE_TYPE3:
      if (dpx_conf.verbose_level > 0)
        MESG("[Type3/PK]");
      pdf_font_load_pkfont (font);
      break;
    case PDF_FONT_FONTTYPE_TYPE0:
      if (dpx_conf.verbose_level > 0)
        MESG("[Type0]");
      pdf_font_load_type0(font);
      break;
    }

    if (font->encoding_id >= 0) {
      if (font->subtype != PDF_FONT_FONTTYPE_TYPE0) {
        pdf_encoding_add_usedchars(font->encoding_id, font->usedchars);
      }
    }

    if (dpx_conf.verbose_level > 0) {
      if (font->subtype != PDF_FONT_FONTTYPE_TYPE0) {
        MESG(")");
      }
    }
  }

  pdf_encoding_complete();
  /* Order is important... */
  for (font_id = 0; font_id < font_cache.count; font_id++) {
    pdf_font *font = &font_cache.fonts[font_id];

    if ((font->flags & PDF_FONT_FLAG_IS_ALIAS) ||
        (font->flags & PDF_FONT_FLAG_IS_REENCODE) ||
        !font->reference) {
      continue;
    }

    switch (font->subtype) {
    case PDF_FONT_FONTTYPE_CIDTYPE0:
    case PDF_FONT_FONTTYPE_CIDTYPE2:
      pdf_font_load_cidfont(font);
      break;
    }
  }

  for (font_id = 0; font_id < font_cache.count; font_id++) {
    pdf_font *font;

    font = &font_cache.fonts[font_id];

    if ((font->flags & PDF_FONT_FLAG_IS_ALIAS) ||
        (font->flags & PDF_FONT_FLAG_IS_REENCODE) ||
        !font->reference) {
      pdf_flush_font(font);
      pdf_clean_font_struct(font);
      continue;
    }
  
    if (font->encoding_id >= 0 &&
        font->subtype != PDF_FONT_FONTTYPE_TYPE0 &&
        font->subtype != PDF_FONT_FONTTYPE_CIDTYPE0 &&
        font->subtype != PDF_FONT_FONTTYPE_CIDTYPE2) {
      pdf_obj *enc_obj = pdf_get_encoding_obj(font->encoding_id);
      pdf_obj *tounicode;

      /* Predefined encodings (and those simplified to them) are embedded
       * as direct objects, but this is purely a matter of taste.
       */
      if (enc_obj) {
        if (font->subtype == PDF_FONT_FONTTYPE_TRUETYPE) {
          if (pdf_encoding_is_predefined(font->encoding_id) && PDF_OBJ_NAMETYPE(enc_obj)) {
           pdf_add_dict(font->resource,
                        pdf_new_name("Encoding"), pdf_link_obj(enc_obj));           
          }
        } else {
          pdf_add_dict(font->resource,
                       pdf_new_name("Encoding"),
                       PDF_OBJ_NAMETYPE(enc_obj) ? pdf_link_obj(enc_obj) : pdf_ref_obj(enc_obj));
        }
      }
      /* For built-in encoding, each font loader create ToUnicode CMap. */
      if (!pdf_lookup_dict(font->resource, "ToUnicode")) {
        tounicode = pdf_encoding_get_tounicode(font->encoding_id);
        if (tounicode) {
          pdf_add_dict(font->resource,
                       pdf_new_name("ToUnicode"), pdf_ref_obj(tounicode));
        }
      }
    } else if (font->subtype == PDF_FONT_FONTTYPE_TRUETYPE) {
      /* encoding_id < 0 means MacRoman here (but not really)
       * We use MacRoman as "default" encoding. */
      pdf_add_dict(font->resource,
                   pdf_new_name("Encoding"),
                   pdf_new_name("MacRomanEncoding"));
    }
    pdf_flush_font(font);
    pdf_clean_font_struct(font);
  }

  RELEASE(font_cache.fonts);
  font_cache.fonts    = NULL;
  font_cache.count    = 0;
  font_cache.capacity = 0;

  CMap_cache_close();
  pdf_close_encodings();

  agl_close_map (); /* After encoding */

  return;
}

int
pdf_font_findresource (const char *ident, double scale)
{
  int font_id, found = 0;

  for (font_id = 0; font_id < font_cache.count; font_id++) {
    pdf_font *font;

    font = &font_cache.fonts[font_id];
    switch (font->subtype) {
    case PDF_FONT_FONTTYPE_TYPE1:
    case PDF_FONT_FONTTYPE_TYPE1C:
    case PDF_FONT_FONTTYPE_TRUETYPE:
    case PDF_FONT_FONTTYPE_TYPE0:
      if (!strcmp(ident, font->ident)) {
        found = 1;
      }
      break;
    case PDF_FONT_FONTTYPE_TYPE3:
    /* There shouldn't be any encoding specified for PK font.
     * It must be always font's build-in encoding.
     *
     * TODO: a PK font with two encodings makes no sense. Change?
     */
      if (!strcmp(ident, font->ident) && scale == font->point_size) {
        found = 1;
      }
      break;
    }

    if (found) {
      if (dpx_conf.verbose_level > 0) {
        MESG("\npdf_font>> Font \"%s\" (enc_id=%d) found at id=%d.\n", font->ident, font->encoding_id, font_id);
      }
      break;
    }
  }

  return found ? font_id : -1;
}

static int
create_font_alias (const char *ident, int font_id)
{
  int       this_id;
  pdf_font *font, *src;

  if (font_id < 0 || font_id >= font_cache.count)
    return -1;
  
  src = &font_cache.fonts[font_id];

  this_id = font_cache.count;
  if (font_cache.count >= font_cache.capacity) {
    font_cache.capacity += CACHE_ALLOC_SIZE;
    font_cache.fonts     = RENEW(font_cache.fonts, font_cache.capacity, pdf_font);
  }
  font = &font_cache.fonts[this_id];
  pdf_init_font_struct(font);

  font->ident   = NEW(strlen(ident) + 1, char);
  strcpy(font->ident, ident);
  font->font_id     = font_id;
  font->subtype     = src->subtype;
  font->encoding_id = src->encoding_id;

  font->flags      |= PDF_FONT_FLAG_IS_ALIAS;

  font_cache.count++;

  return this_id;
}

static int
create_font_reencoded (const char *ident, int font_id, int cmap_id)
{
  int       this_id;
  pdf_font *font;

  if (font_cache.count + 1 >= font_cache.capacity) {
    font_cache.capacity += CACHE_ALLOC_SIZE;
    font_cache.fonts     = RENEW(font_cache.fonts, font_cache.capacity, pdf_font);
  }

  this_id = font_cache.count;
  font    = &font_cache.fonts[this_id];
  pdf_init_font_struct(font);
  font->ident       = NEW(strlen(ident) + 1, char);
  strcpy(font->ident, ident);
  font->font_id     = font_id;
  font->subtype     = PDF_FONT_FONTTYPE_TYPE0;
  font->encoding_id = cmap_id;
  font->flags      |= PDF_FONT_FLAG_IS_REENCODE;
  font->flags      |= PDF_FONT_FLAG_USEDCHAR_SHARED;
  font_cache.count++;

  return this_id;
}

int
pdf_font_load_font (const char *ident, double font_scale, const fontmap_rec *mrec)
{
  int         font_id = -1;
  pdf_font   *font;
  int         encoding_id = -1, cmap_id = -1;
  const char *fontname;

  /*
   * Get appropriate info from map file. (PK fonts at two different
   * point sizes would be looked up twice unecessarily.)
   */
  fontname = mrec ? mrec->font_name : ident;
  /* XeTeX specific...
   * First try loading GID-to-CID mapping from CFF CID-keyed OpenType font.
   * There was a serious bug in xdv support... It was implemented with the wrong
   * assumption that CID always equals to GID. 
   * TODO: There is a possibility that GID-to-CID mapping is not one-to-one.
   * Use internal glyph ordering rather than map GID to CIDs.
   */
  if (mrec && mrec->opt.use_glyph_encoding) {
    int wmode = 0;
    /* Should be always Identity-H or Identity-V for XeTeX output. */
    if (mrec->enc_name) {
      if (!strcmp(mrec->enc_name, "Identity-V"))
        wmode = 1;
      else if (!strcmp(mrec->enc_name, "Identity-H"))
        wmode = 0;
      else {
        WARN("Unexpected encoding specified for xdv: %s", mrec->enc_name);
      }
      /* cmap_id < 0 is returned if ...
       *  Font is not a CFF font
       *  GID to CID mapping is identity mapping
       * 
       * TODO: fontmap record still has Identity CMap assigned but actually different CMap
       * can be attached to the font here. Should we fix mrec->enc_name here?
       */
      cmap_id = otf_try_load_GID_to_CID_map(mrec->font_name, mrec->opt.index, wmode);
    }
  }

  if (cmap_id < 0 && mrec && mrec->enc_name) {
    if (!strcmp(mrec->enc_name, "unicode")) {
      cmap_id = otf_load_Unicode_CMap(mrec->font_name,
                                      mrec->opt.index, mrec->opt.otl_tags,
                                      ((mrec->opt.flags & FONTMAP_OPT_VERT) ? 1 : 0));
      if (cmap_id < 0) {
        cmap_id = t1_load_UnicodeCMap(mrec->font_name, mrec->opt.otl_tags,
                                      ((mrec->opt.flags & FONTMAP_OPT_VERT) ? 1 : 0));
      }
    } else if (!strstr(mrec->enc_name, ".enc") || strstr(mrec->enc_name, ".cmap")) {
      cmap_id = CMap_cache_find(mrec->enc_name);
    }
    if (cmap_id < 0) {
      encoding_id = pdf_encoding_findresource(mrec->enc_name);
    }
  }

  if (mrec && mrec->enc_name) {
    if (cmap_id < 0 && encoding_id < 0) {
      WARN("Could not read encoding file: %s", mrec->enc_name);
      return -1;
    }
  }

  if (mrec && cmap_id >= 0) {
    /* Composite font */
    CMap       *cmap;
    CIDSysInfo *csi;
    int         wmode, cid_id;

    cmap    = CMap_cache_get(cmap_id);
    csi     = CMap_is_Identity(cmap) ? NULL : CMap_get_CIDSysInfo(cmap);
    wmode   = CMap_get_wmode(cmap);
    
    cid_id = pdf_font_cidfont_lookup_cache(font_cache.fonts, font_cache.count, mrec->font_name, csi, &mrec->opt);
    if (cid_id >= 0) {
      for (font_id = 0; font_id < font_cache.count; font_id++) {
        font = &font_cache.fonts[font_id];
        if (font->subtype != PDF_FONT_FONTTYPE_TYPE0)
          continue;
        if (font->type0.wmode == wmode && font->type0.descendant == cid_id) {
          break;
        }
      }
      if (font_id >= 0 && font_id < font_cache.count) {
        font = &font_cache.fonts[font_id];
        if (font->encoding_id == cmap_id) {
          if (dpx_conf.verbose_level > 0) {
            MESG("\npdf_font>> Type0 font \"%s\" cmap_id=<%s,%d> found at font_id=<%s,%d>.\n",
                 mrec->font_name, mrec->enc_name, cmap_id, pdf_get_font_ident(font_id), font_id);
          }
          if (!strcmp(ident, font->ident)) {
            return font_id;
          } else {
            return create_font_alias(ident, font_id);
          }
        } else {
          if (dpx_conf.verbose_level > 0) {
            MESG("\npdf_font>> Type0 font \"%s\" cmap_id=<%s,%d> found at font_id=<%s,%d>. (re-encoded)\n",
                 mrec->font_name, mrec->enc_name, cmap_id, pdf_get_font_ident(font_id), font_id);
          }
          return create_font_reencoded(ident, font_id, cmap_id);
        }
      }
    }

    /* plus one for CIDFont */
    if (font_cache.count + 1 >= font_cache.capacity) {
      font_cache.capacity += CACHE_ALLOC_SIZE;
      font_cache.fonts     = RENEW(font_cache.fonts, font_cache.capacity, pdf_font);
    }

    if (cid_id < 0) {
      pdf_font *cidfont;

      cid_id  = font_cache.count;
      cidfont = &font_cache.fonts[cid_id];
      pdf_init_font_struct(cidfont);
      if (pdf_font_open_cidfont(cidfont, fontname, csi, &mrec->opt) < 0) {
        pdf_clean_font_struct(cidfont);
        return -1;
      }
      font_cache.count++;
    }
    font_id = font_cache.count;
    font    = &font_cache.fonts[font_id];
    pdf_init_font_struct(font);
    if (pdf_font_open_type0(font, cid_id, wmode) < 0) {
      pdf_clean_font_struct(font);
      return -1;
    }
    font->ident       = NEW(strlen(ident) + 1, char);
    strcpy(font->ident, ident);
    font->subtype     = PDF_FONT_FONTTYPE_TYPE0;
    font->encoding_id = cmap_id;
    
    font_cache.count++;

    if (dpx_conf.verbose_level > 0) {
      MESG("\n");
      MESG("pdf_font>> Type0 font \"%s\" ", fontname);
      MESG("cmap_id=<%s,%d> ", mrec->enc_name, font->encoding_id);
      MESG("font_id=<%s,%d>.", ident, font_id);
      MESG("\n");
    }
  } else {
    /* Simple Font - always embed. */
    for (font_id = 0; font_id < font_cache.count; font_id++) {
      font = &font_cache.fonts[font_id];
      if (font->flags & PDF_FONT_FLAG_IS_ALIAS)
        continue;
      switch (font->subtype) {
      case PDF_FONT_FONTTYPE_TYPE1:
      case PDF_FONT_FONTTYPE_TYPE1C:
      case PDF_FONT_FONTTYPE_TRUETYPE:
        /* fontname here is font file name.
         * We must compare both font file name and encoding
         *
         * TODO: Embed a font only once if it is used
         *       with two different encodings
         */
        if (!strcmp(fontname, font->filename) && encoding_id == font->encoding_id &&
            (!mrec || mrec->opt.index == font->index)) {
          if (dpx_conf.verbose_level > 0) {
            MESG("\npdf_font>> Simple font \"%s\" (enc_id=%d) found at id=%d.\n", fontname, encoding_id, font_id);
          }
          if (!strcmp(ident, font->ident)) {
            return font_id;
          } else {
            return create_font_alias(ident, font_id);
          }
        }
        break;
      case PDF_FONT_FONTTYPE_TYPE3:
        /* There shouldn't be any encoding specified for PK font.
         * It must be always font's build-in encoding.
         *
         * TODO: a PK font with two encodings makes no sense. Change?
         */
        if (!strcmp(fontname, font->filename) && font_scale == font->point_size) {
          if (dpx_conf.verbose_level > 0) {
            MESG("\npdf_font>> Simple font \"%s\" (enc_id=%d) found at id=%d.\n", fontname, encoding_id, font_id);
          }
          if (!strcmp(ident, font->ident)) {
            return font_id;
          } else {
            return create_font_alias(ident, font_id);
          }
        }
        break;
      }
    }

    font_id = font_cache.count;
    if (font_cache.count >= font_cache.capacity) {
      font_cache.capacity += CACHE_ALLOC_SIZE;
      font_cache.fonts     = RENEW(font_cache.fonts, font_cache.capacity, pdf_font);
    }

    font = &font_cache.fonts[font_id];
    pdf_init_font_struct(font);

    font->ident       = NEW(strlen(ident) + 1, char);
    strcpy(font->ident, ident);
    font->encoding_id = encoding_id;
    font->filename    = NEW(strlen(fontname) + 1, char);
    font->point_size  = font_scale;
    strcpy(font->filename, fontname);
    font->index       = (mrec && mrec->opt.index) ? mrec->opt.index : 0;
    font->flags      |= (mrec && (mrec->opt.flags & FONTMAP_OPT_NOEMBED)) ? PDF_FONT_FLAG_NOEMBED : 0;
    if (pdf_font_open_type1(font, font->filename, font->index, font->encoding_id, (font->flags & PDF_FONT_FLAG_NOEMBED) ? 0 : 1) >= 0) {
      font->subtype = PDF_FONT_FONTTYPE_TYPE1;
    } else if (pdf_font_open_type1c(font, font->filename, font->index, font->encoding_id, (font->flags & PDF_FONT_FLAG_NOEMBED) ? 0 : 1) >= 0) {
      font->subtype = PDF_FONT_FONTTYPE_TYPE1C;
    } else if (pdf_font_open_truetype(font, font->filename, font->index, font->encoding_id, (font->flags & PDF_FONT_FLAG_NOEMBED) ? 0 : 1) >= 0) {
      font->subtype = PDF_FONT_FONTTYPE_TRUETYPE;
    } else if (pdf_font_open_pkfont(font, font->filename, font->index, font->encoding_id, (font->flags & PDF_FONT_FLAG_NOEMBED) ? 0 : 1, font->point_size) >= 0) {
      font->subtype = PDF_FONT_FONTTYPE_TYPE3;
    } else {
      pdf_clean_font_struct(font);
      return -1;
    }

    font_cache.count++;

    if (dpx_conf.verbose_level > 0) {
      MESG("\n");
	    MESG("pdf_font>> Simple font \"%s\" ", fontname);
      MESG("enc_id=<%s,%d> ", (mrec && mrec->enc_name) ? mrec->enc_name : "builtin", font->encoding_id);
      MESG("font_id=<%s,%d>.", ident, font_id);
      MESG("\n");
    }
  }

  return  font_id;
}

pdf_obj *
pdf_font_get_resource (pdf_font *font)
{
  ASSERT(font);

  if (!font->resource) {
    font->resource = pdf_new_dict();
    pdf_add_dict(font->resource, pdf_new_name("Type"), pdf_new_name("Font"));
    switch (font->subtype) {
    case PDF_FONT_FONTTYPE_TYPE1:
    case PDF_FONT_FONTTYPE_TYPE1C:
      pdf_add_dict(font->resource, pdf_new_name("Subtype"), pdf_new_name("Type1"));
      break;
    case PDF_FONT_FONTTYPE_TYPE3:
      pdf_add_dict(font->resource, pdf_new_name("Subtype"), pdf_new_name("Type3"));
      break;
    case PDF_FONT_FONTTYPE_TRUETYPE:
      pdf_add_dict(font->resource, pdf_new_name("Subtype"), pdf_new_name("TrueType"));
      break;
    default:
      break;
    }
  }

  return font->resource;
}

pdf_obj *
pdf_font_get_descriptor (pdf_font *font)
{
  ASSERT(font);

  if (font->subtype == PDF_FONT_FONTTYPE_TYPE0) {
    return NULL;
  } else if (!font->descriptor) {
    font->descriptor = pdf_new_dict();
    pdf_add_dict(font->descriptor, pdf_new_name("Type"), pdf_new_name("FontDescriptor"));
  }

  return font->descriptor;
}

char *
pdf_font_get_uniqueTag (pdf_font *font)
{
  ASSERT(font);

  if (font->uniqueID[0] == '\0') {
    pdf_font_make_uniqueTag(font->uniqueID);
  }

  return font->uniqueID;
}

/*
 * Please don't use TFM widths for the /Widths
 * entry of the font dictionary.
 *
 * PDF 32000-1:2008 (p.255)
 *
 *   These widths shall be consistent with the
 *   actual widths given in the font program.
 */

#include "tfm.h"

int
pdf_check_tfm_widths (const char *ident, double *widths, int firstchar, int lastchar, const char *usedchars)
{
  int    error     = 0;
  int    tfm_id, code, count = 0;
  double sum       = 0.0;
  double tolerance = 1.0;
  int    override  = 0; /* Don't set to 1! */

  tfm_id = tfm_open(ident, 0);
  if (tfm_id < 0)
    return 0;
  for (code = firstchar; code <= lastchar; code++) {
    if (usedchars[code]) {
      double width, diff;
      
      width = 1000. * tfm_get_width(tfm_id, code);
      diff  = widths[code] - width;
      diff  = diff < 0 ? -diff : diff;
      if (override) {
        widths[code] = width;
      } else if (diff > tolerance) {
        if (dpx_conf.verbose_level > 0) {
          WARN("Intolerable difference in glyph width: font=%s, char=%d", ident, code);
          WARN("font: %g vs. tfm: %g", widths[code], width);
        }
        sum  += diff;
      }
      count++;
    }
  }

  error = sum > 0.5 * count * tolerance ? -1 : 0;

  return override ? 0 : error;
}

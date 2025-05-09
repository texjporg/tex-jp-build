## $Id$
## Makefile.am for the TeX Live subdirectory texk/dvipdfm-x/
##
## Copyright 2015-2025 Karl Berry <tex-live@tug.org>
## Copyright 2009-2015 Peter Breitenlohner <tex-live@tug.org>
## You may freely use, modify and/or distribute this file.
##
bin_PROGRAMS = xdvipdfmx
if !WIN32
dist_bin_SCRIPTS = dvipdft
endif !WIN32

AM_CPPFLAGS = $(KPATHSEA_INCLUDES) $(LIBPNG_INCLUDES) $(ZLIB_INCLUDES) $(LIBPAPER_INCLUDES)
AM_CFLAGS = $(WARNING_CFLAGS)

xdvipdfmx_SOURCES = \
	agl.c \
	agl.h \
	bmpimage.c \
	bmpimage.h \
	cff.c \
	cff.h \
	cff_dict.c \
	cff_dict.h \
	cff_limits.h \
	cff_stdstr.h \
	cff_types.h \
	cid_basefont.h \
	cid.c \
	cid.h \
	cidtype0.c \
	cidtype0.h \
	cidtype2.c \
	cidtype2.h \
	cmap.c \
	cmap.h \
	cmap_p.h \
	cmap_read.c \
	cmap_read.h \
	cmap_write.c \
	cmap_write.h \
	cs_type2.c \
	cs_type2.h \
	dpxconf.c \
	dpxconf.h \
	dpxcrypt.c \
	dpxcrypt.h \
	dpxfile.c \
	dpxfile.h \
	dpxutil.c \
	dpxutil.h \
	dvi.c \
	dvi.h \
	dvicodes.h \
	dvipdfmx.c \
	dvipdfmx.h \
	epdf.c \
	epdf.h \
	error.c \
	error.h \
	fontmap.c \
	fontmap.h \
	jp2image.c \
	jp2image.h \
	jpegimage.c \
	jpegimage.h \
	mem.c \
	mem.h \
	mfileio.c \
	mfileio.h \
	mpost.c \
	mpost.h \
	mt19937ar.c \
	numbers.c \
	numbers.h \
	otl_opt.c \
	otl_opt.h \
	pdfcolor.c \
	pdfcolor.h \
	pdfdev.c \
	pdfdev.h \
	pdfdoc.c \
	pdfdoc.h \
	pdfdraw.c \
	pdfdraw.h \
	pdfencrypt.c \
	pdfencrypt.h \
	pdfencoding.c \
	pdfencoding.h \
	pdffont.c \
	pdffont.h \
	pdflimits.h \
	pdfnames.c \
	pdfnames.h \
	pdfobj.c \
	pdfobj.h \
	pdfparse.c \
	pdfparse.h \
	pdfresource.c \
	pdfresource.h \
	pdfximage.c \
	pdfximage.h \
	pkfont.c \
	pkfont.h \
	pngimage.c \
	pngimage.h \
	pst.c \
	pst.h \
	pst_obj.c \
	pst_obj.h \
	sfnt.c \
	sfnt.h \
	spc_color.c \
	spc_color.h \
	spc_dvipdfmx.c \
	spc_dvipdfmx.h \
	spc_dvips.c \
	spc_dvips.h \
	spc_html.c \
	spc_html.h \
	spc_misc.c \
	spc_misc.h \
	spc_pdfm.c \
	spc_pdfm.h \
	spc_tpic.c \
	spc_tpic.h \
	spc_util.h \
	spc_util.c \
	spc_xtx.c \
	spc_xtx.h \
	specials.c \
	specials.h \
	subfont.c \
	subfont.h \
	system.h \
	t1_char.c \
	t1_char.h \
	t1_load.c \
	t1_load.h \
	tfm.c \
	tfm.h \
	truetype.c \
	truetype.h \
	tt_aux.c \
	tt_aux.h \
	tt_cmap.c \
	tt_cmap.h \
	tt_glyf.c \
	tt_glyf.h \
	tt_gsub.c \
	tt_gsub.h \
	tt_post.c \
	tt_post.h \
	tt_table.c \
	tt_table.h \
	type0.c \
	type0.h \
	type1.c \
	type1.h \
	type1c.c \
	type1c.h \
	unicode.c \
	unicode.h \
	vf.c \
	vf.h \
	xbb.c

LDADD = $(KPATHSEA_LIBS) $(LIBPNG_LIBS) $(ZLIB_LIBS) $(LIBPAPER_LIBS)

$(xdvipdfmx_OBJECTS): config.force

## Links
##
bin_links = \
	xdvipdfmx$(EXEEXT):dvipdfm \
	xdvipdfmx$(EXEEXT):dvipdfmx

# extractbb is now a separate package, reimplemented in Lua.

if WIN32
noinst_PROGRAMS = call_xdvipdfmx
endif WIN32

call_xdvipdfmx_CPPFLAGS = -DEXEPROG=\"xdvipdfmx.exe\"
nodist_call_xdvipdfmx_SOURCES = callexe.c

include $(top_srcdir)/../../am/bin_links.am

## Manpages

dist_man1_MANS = man/dvipdfmx.1 man/dvipdft.1 man/extractbb.1
man1_links = \
	dvipdfmx:dvipdfm \
	dvipdfmx:xdvipdfmx
include $(top_srcdir)/../../am/man1_links.am

## Data
##
configdatadir = $(datarootdir)/texmf-dist/dvipdfmx
dist_configdata_DATA = data/dvipdfmx.cfg
 
glyphlistdatadir = $(datarootdir)/texmf-dist/fonts/map/glyphlist
dist_glyphlistdata_DATA = data/glyphlist.txt data/pdfglyphlist.txt

mapdatadir = $(datarootdir)/texmf-dist/fonts/map/dvipdfmx
dist_mapdata_DATA = data/cid-x.map

cmapdatadir = $(datarootdir)/texmf-dist/fonts/cmap/dvipdfmx
dist_cmapdata_DATA = data/EUC-UCS2

install-exec-hook: install-bin-links
if WIN32
# same install happens in web2c/omegafonts.
	$(INSTALL_PROGRAM_ENV) $(LIBTOOL) $(AM_LIBTOOLFLAGS) $(LIBTOOLFLAGS) --mode=install $(INSTALL_PROGRAM) call_xdvipdfmx$(EXEEXT) "$(DESTDIR)$(bindir)/dvipdfm$(EXEEXT)"
	$(INSTALL_PROGRAM_ENV) $(LIBTOOL) $(AM_LIBTOOLFLAGS) $(LIBTOOLFLAGS) --mode=install $(INSTALL_PROGRAM) call_xdvipdfmx$(EXEEXT) "$(DESTDIR)$(bindir)/dvipdfmx$(EXEEXT)"
endif WIN32

install-data-hook: install-man1-links

uninstall-hook: uninstall-bin-links uninstall-man1-links
if WIN32
	rm -f $(DESTDIR)$(bindir)/dvipdfm$(EXEEXT)
	rm -f $(DESTDIR)$(bindir)/dvipdfmx$(EXEEXT)
endif WIN32

all-local: config.force

config.force: $(ZLIB_DEPEND) $(LIBPNG_DEPEND) $(KPATHSEA_DEPEND) $(LIBPAPER_DEPEND)
	echo timestamp >config.force
	$(SHELL) ./config.status --recheck

DISTCLEANFILES = config.force

## Rebuild libkpathsea
@KPATHSEA_RULE@
## Rebuild libpng
@LIBPNG_RULE@
## Rebuild libz
@ZLIB_RULE@
## Rebuild libpaper
@LIBPAPER_RULE@

## Tests
##
TESTS = xdvipdfmx.test xdvipdfm-ann.test xdvipdfm-bad.test xdvipdfm-bb.test
TESTS += xdvipdfm-bkm.test xdvipdfm-pdf.test xdvipdfm-psz.test
TESTS += xdvipdfm-ptx.test xdvipdfm-res.test
TESTS += xdvipdfm-rev.test xdvipdfm-ttc.test
TESTS += dvipdfmx-upjf.test dvipdfmx-upjf2.test dvipdfmx-upjf3.test dvipdfmx-incl.test
TESTS += dvipdfmx-lmr0.test dvipdfmx-lmr1.test
TESTS += dvipdfmx-ttf0.test
xdvipdfmx.log xdvipdfm-ann.log xdvipdfm-bad.log xdvipdfm-bb.log \
	xdvipdfm-bkm.log xdvipdfm-pdf.log xdvipdfm-psz.log \
	xdvipdfm-ptx.log xdvipdfm-res.log \
	xdvipdfm-rev.log xdvipdfm-ttc.log \
	dvipdfmx-upjf.log dvipdfmx-upjf2.log dvipdfmx-upjf3.log dvipdfmx-incl.log \
	dvipdfmx-lmr0.log dvipdfmx-lmr1.log \
	dvipdfmx-ttf0.log: \
	xdvipdfmx$(EXEEXT)
EXTRA_DIST = $(TESTS)
## xdvipdfmx.test
EXTRA_DIST += tests/dvipdfmx.cfg tests/psfonts.map
EXTRA_DIST += tests/cmr10.pfb tests/cmr10.tfm
EXTRA_DIST += tests/image.dvi tests/image.tex
EXTRA_DIST += tests/xbmc.dvi tests/xbmc.tex tests/xbmc10.600pk tests/xbmc10.tfm
DISTCLEANFILES += image*.pdf xbmc*.pdf
## xdvipdfm-ann.test
EXTRA_DIST += tests/annot.dvi tests/annot.tex
DISTCLEANFILES += annot*.pdf
## xdvipdfm-bad.test
EXTRA_DIST += tests/ids_2_6.dvi tests/ids_3_2.dvi tests/ids_a_b.dvi tests/opc_fe.dvi
EXTRA_DIST += tests/ptx_2_2.dvi tests/ptx_6_6.dvi tests/rev_2_2.dvi tests/rev_2_3.dvi
EXTRA_DIST += tests/void.dvi
## xdvipdfm-bb.test
EXTRA_DIST += tests/image.bmp tests/picbmp.bb tests/picbmp.xbb
EXTRA_DIST += tests/image.jp2 tests/picjp2.bb tests/picjp2.xbb
EXTRA_DIST += tests/image.jpeg tests/picjpeg.bb tests/picjpeg.xbb
EXTRA_DIST += tests/image.png tests/picpng.bb tests/picpng.xbb
EXTRA_DIST += tests/image.pdf tests/picpdf.bb tests/picpdf.xbb
DISTCLEANFILES += pic*.*
## xdvipdfm-bkm.test
EXTRA_DIST += tests/bookm.dvi tests/bookm.tex
DISTCLEANFILES += bookm*.pdf
## xdvipdfm-pdf.test
EXTRA_DIST += tests/xdvipdfm-pdf.xdv tests/rpki-ecosystem.drawio.pdf
DISTCLEANFILES += xdvipdfm-pdf*.pdf
## xdvipdfm-psz.test
EXTRA_DIST += tests/paper.dvi tests/paper.tex
DISTCLEANFILES += paper*.pdf
## xdvipdfm-ptx.test
EXTRA_DIST += tests/ptex.dvi
DISTCLEANFILES += ptex*.pdf
## xdvipdfm-res.test
EXTRA_DIST += tests/resrc.dvi tests/resrc.tex
DISTCLEANFILES += resrc*.pdf
## xdvipdfm-rev.test
EXTRA_DIST += tests/reverse.dvi
DISTCLEANFILES += reverse.pdf
## xdvipdfm-ttc.test
EXTRA_DIST += tests/ttc.dvi tests/ttc.tex tests/test.ttc
DISTCLEANFILES += ttc*.pdf
## dvipdfmx-upjf.test
EXTRA_DIST += tests/upjf.dvi tests/upjf.tex tests/upjf.map tests/Makefile_upjf
EXTRA_DIST += tests/upjf_full.cnf tests/upjf_omit.cnf
EXTRA_DIST += tests/upjf_full.vf tests/upjf_omit.vf
EXTRA_DIST += tests/upjf-r.tfm tests/upjf-g.tfm tests/upjf.tfm tests/UPJF-UTF16-H
EXTRA_DIST += tests/upjv_full.vf tests/upjv_omit.vf
EXTRA_DIST += tests/upjv-r.tfm tests/upjv-g.tfm tests/upjv.tfm tests/UPJF-UTF16-V
EXTRA_DIST += tests/upjf-g00.opl tests/upjf-g00.ofm
EXTRA_DIST += tests/upjv-g00.opl tests/upjv-g00.ofm
EXTRA_DIST += tests/upjf-r00.opl tests/upjf-r00.ofm
EXTRA_DIST += tests/upjv-r00.opl tests/upjv-r00.ofm
EXTRA_DIST += tests/upjf1-r.pl tests/upjf1-r.tfm
EXTRA_DIST += tests/upjf1_full.zvp0 tests/upjf1_full.vf
EXTRA_DIST += tests/upjf1_omit.zvp0 tests/upjf1_omit.vf
DISTCLEANFILES += upjf.vf upjv.vf upjf-*.ofm upjv-*.ofm upjf-*.tfm upjf_*.pdf upjf1_*.pdf
## dvipdfmx-upjf2.test
EXTRA_DIST += tests/upjf2_full.zvp0 tests/upjf2_full.vf
EXTRA_DIST += tests/upjv2_full.zvp0 tests/upjv2_full.vf
EXTRA_DIST += tests/upjf-c.pl tests/upjf-c.tfm
EXTRA_DIST += tests/upjv-c.pl tests/upjv-c.tfm
EXTRA_DIST += tests/upjf-hara.map
DISTCLEANFILES += upjf2_*.pdf
## dvipdfmx-upjf3.test
EXTRA_DIST += tests/upjf3_full.zvp0 tests/upjf3_full.vf
EXTRA_DIST += tests/upjv3_full.zvp0 tests/upjv3_full.vf
EXTRA_DIST += tests/upjf4_full.zvp0 tests/upjf4_full.vf
EXTRA_DIST += tests/upjv4_full.zvp0 tests/upjv4_full.vf
EXTRA_DIST += tests/upjf-hu.tfm tests/upjf-hi.tfm
EXTRA_DIST += tests/upjv-hu.tfm tests/upjv-hi.tfm
EXTRA_DIST += tests/upjf-noto.map tests/upjf-ipa.map
DISTCLEANFILES += upjf3_*.pdf
## dvipdfmx-incl.test
EXTRA_DIST += tests/multi_incl.dvi tests/multi_incl.tex tests/sue-mp.pdf
DISTCLEANFILES += multi_incl.pdf
## dvipdfmx-lmr0.test, dvipdfmx-lmr1.test
EXTRA_DIST += tests/lmr0.tex tests/lmr0-al.dvi tests/lmr0-up.dvi
DISTCLEANFILES += lmr0-*.pdf
## dvipdfmx-ttf0.test
EXTRA_DIST += tests/cprm00.tex tests/cprm00.dvi
DISTCLEANFILES += cprm*.pdf
##
EXTRA_DIST += tests/fullmap.dvi tests/fullmap.tex

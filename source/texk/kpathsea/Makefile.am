## $Id$
## Makefile.am for the TeX Live subdirectory texk/kpathsea/
##
## Copyright 2015-2024 Karl Berry <tex-live@tug.org>
## Copyright 2009-2015 Peter Breitenlohner <tex-live@tug.org>
## You may freely use, modify and/or distribute this file.

SUBDIRS = . doc man

EXTRA_DIST = COPYING.LESSERv2 PROJECTS

AM_CPPFLAGS = -I$(top_builddir)/.. -I$(top_srcdir)/..
AM_CFLAGS = $(WARNING_CFLAGS)

lib_LTLIBRARIES = libkpathsea.la

libkpathsea_la_CPPFLAGS = $(AM_CPPFLAGS) -DMAKE_KPSE_DLL
if have_EXEEXT
libkpathsea_la_CPPFLAGS += -DEXEEXT=\"$(EXEEXT)\"
endif have_EXEEXT

libkpathsea_la_LDFLAGS = -bindir @bindir@ -no-undefined -version-info $(KPSE_LT_VERSINFO)

libkpathsea_la_LIBADD = $(LTLIBOBJS)

BUILT_SOURCES = paths.h

## Put tex-file.c first, because it's what depends on the paths, and may
## reduce frustration if the paths are wrong by doing it first.
libkpathsea_la_SOURCES = \
	tex-file.c \
	absolute.c \
	atou.c \
	cnf.c \
	concat.c \
	concat3.c \
	concatn.c \
	db.c \
	debug.c \
	dir.c \
	elt-dirs.c \
	expand.c \
	extend-fname.c \
	file-p.c \
	find-suffix.c \
	fn.c \
	fontmap.c \
	hash.c \
	kdefault.c \
	kpathsea.c \
	line.c \
	magstep.c \
	make-suffix.c \
	path-elt.c \
	pathsearch.c \
	proginit.c \
	progname.c \
	readable.c \
	rm-suffix.c \
	str-list.c \
	str-llist.c \
	tex-glyph.c \
	tex-hush.c \
	tex-make.c \
	tilde.c \
	uppercasify.c \
	variable.c \
	version.c \
	xbasename.c \
	xcalloc.c \
	xdirname.c \
	xfopen.c \
	xfseek.c \
	xftell.c \
	xgetcwd.c \
	xmalloc.c \
	xopendir.c \
	xputenv.c \
	xrealloc.c \
	xstat.c \
	xstrdup.c

if !MINGW32
libkpathsea_la_SOURCES += \
	getopt.c \
	getopt1.c
endif !MINGW32

if WIN32
if MINGW32
libkpathsea_la_SOURCES += \
	mingw32.c \
	xfseeko.c \
	xftello.c
else !MINGW32
libkpathsea_la_SOURCES += \
	win32lib.c
endif !MINGW32
libkpathsea_la_SOURCES += \
	knj.c
SUBDIRS += win32
else !WIN32
libkpathsea_la_SOURCES += \
	xfseeko.c \
	xftello.c
endif !WIN32

$(libkpathsea_la_OBJECTS): paths.h kpathsea.h

EXTRA_DIST += \
	putenv.c

kpseincludedir = ${includedir}/kpathsea

nodist_kpseinclude_HEADERS = \
	c-auto.h \
	kpathsea.h \
	paths.h

kpseinclude_HEADERS = config.h $(direct_headers) $(indirect_headers)

# Headers included directly into kpathsea.h
#
direct_headers = \
	absolute.h \
	c-dir.h \
	c-fopen.h \
	c-namemx.h \
	c-pathch.h \
	c-pathmx.h \
	c-stat.h \
	cnf.h \
	concatn.h \
	expand.h \
	getopt.h \
	line.h \
	magstep.h \
	pathsearch.h \
	proginit.h \
	readable.h \
	tex-glyph.h \
	tex-hush.h \
	tex-make.h \
	variable.h \
	version.h

# Headers included indirectly into kpathsea.h
#
indirect_headers = \
	c-ctype.h \
	c-errno.h \
	c-limits.h \
	c-memstr.h \
	c-minmax.h \
	c-proto.h \
	c-std.h \
	c-unistd.h \
	debug.h \
	hash.h \
	knj.h \
	lib.h \
	mingw32.h \
	progname.h \
	simpletypes.h \
	str-list.h \
	str-llist.h \
	systypes.h \
	tex-file.h \
	types.h \
	win32lib.h

noinst_HEADERS = \
	db.h \
	default.h \
	fn.h \
	fontmap.h \
	tilde.h \
	xopendir.h \
	xstat.h

pkgconfigdir = ${libdir}/pkgconfig

pkgconfig_DATA = kpathsea.pc

## Handle backslash continuations, then null out comments and
## leading/trailing whitespace.  An awk script does the rest.
## 
## We don't want to rewrite paths.h when we have only changed comments
## in texmf.cnf that have no effect on paths.h, since that would cause
## almost everything to be rebuilt.
##
paths.h: stamp-paths
stamp-paths: texmf.cnf bsnl.awk cnf-to-paths.awk
# ensure grep is not completely broken, e.g., from GREP_OPTIONS.
	echo a | grep -v b >/dev/null || { echo "*** grep broken, goodbye."; exit 1; }
#
# generate paths.h without build machine directories.
	echo "/* paths.h: Generated from texmf.cnf. */" >paths.tmp
	$(AWK) -f $(srcdir)/bsnl.awk $(srcdir)/texmf.cnf \
	| sed -e 's/%.*//' -e 's/^[ 	]*//' -e 's/[ 	]*$$//' \
	| $(AWK) -f $(srcdir)/cnf-to-paths.awk \
	>>paths.tmp
	@if cmp -s paths.h paths.tmp 2>/dev/null; then \
	  echo "paths.h is unchanged"; \
	else \
	  echo "cp paths.tmp paths.h"; \
	  cp paths.tmp paths.h; \
	fi
	rm -f paths.tmp
	date >$@

## Similarly we don't want to rewrite kpathsea.h when only Makefile has
## been remade but kpathsea.h remains the same.
##
kpathsea.h: stamp-kpathsea
stamp-kpathsea: Makefile paths.h
	$(AM_V_GEN)rm -f $@; \
	( echo '/* This is a generated file */'; \
	  echo '/* collecting all public kpathsea headers. */'; \
	  for f in config.h paths.h $(direct_headers); do \
	    echo "#include <kpathsea/$$f>"; \
	  done ) >kpathsea.tmp && \
	if cmp -s kpathsea.h kpathsea.tmp 2>/dev/null; then \
	  echo "kpathsea.h is unchanged"; \
	else \
	  echo "generated kpathsea.h"; \
	  cp kpathsea.tmp kpathsea.h; \
	fi && rm -f kpathsea.tmp && date >$@

EXTRA_DIST += bsnl.awk cnf-to-paths.awk

DISTCLEANFILES = paths.h stamp-paths kpathsea.h

## The programs
bin_PROGRAMS = kpseaccess kpsereadlink kpsestat kpsewhich

kpseaccess_SOURCES = access.c

kpsereadlink_SOURCES = readlink.c

kpsewhich_LDADD = libkpathsea.la

EXTRA_PROGRAMS = progname-test xdirtest

progname_test_CPPFLAGS = $(AM_CPPFLAGS) -DMAKE_KPSE_DLL -DTEST
progname_test_SOURCES = progname.c
progname_test_LDADD = libkpathsea.la

xdirtest_LDADD = libkpathsea.la

## The scripts and their data
web2cdir = $(datarootdir)/texmf-dist/web2c

dist_noinst_DATA = texmf.cnf

install-data-local: installdirs-am
	$(MKDIR_P) '$(DESTDIR)$(web2cdir)'
	@for f in $(dist_noinst_DATA); do \
	  if grep "original $$f --" "$(DESTDIR)$(web2cdir)/$$f" >/dev/null 2>&1 \
	      || test ! -r "$(DESTDIR)$(web2cdir)/$$f"; then \
	    echo " $(INSTALL_DATA) '$(srcdir)/$$f' '$(DESTDIR)$(web2cdir)/$$f'"; \
	    $(INSTALL_DATA) "$(srcdir)/$$f" "$(DESTDIR)$(web2cdir)/$$f"; \
	  else :; fi; \
	done

uninstall-local:
	@for f in $(dist_noinst_DATA); do \
	  if grep "original $$f --" "$(DESTDIR)$(web2cdir)/$$f" >/dev/null 2>&1; then \
	    echo " rm -f '$(DESTDIR)$(web2cdir)/$$f'"; \
	    rm -f "$(DESTDIR)$(web2cdir)/$$f"; \
	  else :; fi; \
	done

## Tests
AM_TESTS_ENVIRONMENT  = LN_S='$(LN_S)'; export LN_S;
AM_TESTS_ENVIRONMENT += LT_OBJDIR='$(LT_OBJDIR)'; export LT_OBJDIR;
#
TESTS  = tests/cnfline.test tests/cnfnewline.test tests/cnfnlink.test
TESTS += tests/cnfnull.test tests/cnfprog.test
TESTS += tests/kpseaccess.test
TESTS += tests/kpsereadlink.test
TESTS += tests/kpsesafe.test tests/kpsestat.test tests/kpsewhich.test
#
tests/cnfline.log tests/cnfnewline.log tests/cnfnull.log tests/cnfprog.log \
  tests/kpsesafe.log tests/kpsewhich.log: kpsewhich$(EXEEXT)
tests/kpseaccess.log: kpseaccess$(EXEEXT)
tests/kpsereadlink.log: kpsereadlink$(EXEEXT)
tests/kpsestat.log: kpsestat$(EXEEXT)
#
EXTRA_DIST += $(TESTS)
EXTRA_DIST += tests/cnfline/texmf.cnf
EXTRA_DIST += tests/cnfnewline/texmf.cnf
EXTRA_DIST += tests/cnfprog/texmf.cnf

# Rebuild
rebuild_prereq =
rebuild_target = all-am
CLEANFILES =

include $(srcdir)/../../am/rebuild.am

## $Id$
## Proxy Makefile.am to build libpaper for TeX Live.
##
##   Copyright 2017 Karl Berry <tex-live@tug.org>
##   Copyright 2013-2015 Peter Breitenlohner <tex-live@tug.org>
##
##   This file is free software; the copyright holder
##   gives unlimited permission to copy and/or distribute it,
##   with or without modifications, as long as this notice is preserved.
##
## We want to re-distribute the whole original harfbuzz source tree.
##
EXTRA_DIST = $(LIBPAPER_TREE)

## Changes applied to the original source tree
##
EXTRA_DIST += TLpatches

# Files not to be distributed
include $(srcdir)/../../am/dist_hook.am
NEVER_NAMES += $(NEVER_NAMES_SUB)

AM_CPPFLAGS = -I$(top_srcdir)/$(LIBPAPER_TREE)/lib $(WARNING_CFLAGS)

SUBDIRS = . include

noinst_LIBRARIES = libpaper.a

libpaper_a_SOURCES = \
	@LIBPAPER_TREE@/lib/dimen.c \
	@LIBPAPER_TREE@/lib/dimen.h \
	@LIBPAPER_TREE@/lib/paper.c \
	@LIBPAPER_TREE@/lib/paper.h \
	@LIBPAPER_TREE@/lib/paperspecs.h

LDADD = libpaper.a

paperconf_SOURCES = @LIBPAPER_TREE@/src/paperconf.c

noinst_MANS = paperconf.1

## Tests
##
if build
check_PROGRAMS = paperconf
dist_check_SCRIPTS = paper.test
TESTS = paper.test
endif build
paper.log: paperconf$(EXEEXT)

# Rebuild
rebuild_prereq =
rebuild_target = all
CLEANFILES =

include $(srcdir)/../../am/rebuild.am

if MAINTAINER_MODE
BUILT_SOURCES = $(LIBPAPER_TREE)/lib/paperspecs.h

paperspecs.h: paperspecs Makefile
	echo '    /* This file has been automaticaly generated.' >$@
	echo '       Edit paperspecs to make changes to the papers specifications. */' >>$@
	echo >>$@
	env LANG=C LC_ALL=C $(AWK) '{ factor = 1.0; \
	       if ($$4 == "mm") factor = 72.0 / 25.4; \
	       if ($$4 == "in") factor = 72.0; \
	       printf("    { \"%s\", %5f, %5f },\n", \
		      $$1, $$2 * factor, $$3 * factor); }' < $< >> $@
endif MAINTAINER_MODE


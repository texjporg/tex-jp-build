#!/bin/sh -x

# making working directory to build targets.
cd source && mkdir -p Work && cd Work

########################################
# configure && make && make install, and run tests
# on build source top directory.
# in web2c, we only make:
# (e|u)ptex, (u)pmpost, cweave, tie, and (c)tangle.
# [NOTE] We build "raw" etex, which is disabled in TL.
# [TODO] How to build omegaware and omegafonts?
../Build --no-clean \
  --disable-all-pkgs \
  --enable-debug \
  --enable-dvi2tty \
  --enable-dviout-util \
  --enable-dvipdfm-x \
  --enable-dvipsk \
  --enable-makejvf \
  --enable-mendexk \
  --enable-upmendex \
  --enable-dvidvi \
  --enable-seetexk \
  --enable-web2c \
  --enable-etex \
  --enable-ptex \
  --enable-eptex \
  --enable-uptex \
  --enable-euptex \
  --enable-pmp \
  --enable-upmp \
  --enable-web-progs \
  --enable-bibtex-x \
  --disable-tex \
  --disable-mf \
  --disable-mflua \
  --disable-mfluajit \
  --disable-mp \
  --disable-luatex \
  --disable-luajittex \
  --disable-luahbtex \
  --disable-luajithbtex \
  --disable-pdftex \
  --disable-xetex \
  --disable-hitex \
  --disable-aleph \
  --without-mf-x-toolkit \
  --with-gnu-ld \
  --without-x \
  --without-system-kpathsea \
  --without-system-ptexenc \
  --without-system-zlib \
  --without-system-libpaper \
  --without-system-libpng \
  --without-system-freetype2 \
  --without-system-gd \
  --without-system-pixman \
  --without-system-cairo \
  --without-system-gmp \
  --without-system-mpfr \
  --without-system-poppler \
  --without-system-xpdf \
  --without-system-zziplib \
  --without-system-graphite2 \
  --without-system-teckit \
  --without-system-icu \
  --without-system-harfbuzz \
  --disable-xpdfopen \
  CFLAGS=-g CXXFLAGS=-g

#!/bin/sh
# $Id$
# Public domain. Report basics of current system; run from top-level
# Makefile so any make overrides will be taken into account. (And from
# Build.) buildenv.log with full environment dump is also created.

do_config_status=true
if test "x$1" = x--no-config-status; then
  shift
  do_config_status=false
fi

printf 'UNAME\t"%s"\n'    "`uname -a`"

# /etc/issue often contains only placeholders, so don't bother.

printf 'MAKE-v\t"%s"\n'   "`${MAKE-make} -v 2>&1 | sed 1q`"
# BSD make does not give version info with -v, but the
# first line of the usage message is sort of an identifier.

# our configure defaults to using gcc and g++.
printf 'CC-v\t"%s"\n'     "`${CC-gcc} --version 2>&1 | sed 1q`"
printf 'CXX-v\t"%s"\n'    "`${CXX-g++} --version 2>&1 | sed 1q`"

# Some Linux-based systems provide this, but don't worry if not there.
# Let's hope that other systems are sufficiently identified by uname,
# don't feel like doing a big system-information hunt. But if we do:
#   http://www.datadisk.co.uk/html_docs/misc/unix_commands.htm
if test -n "`lsb_release -a 2>/dev/null`"; then
  printf '\nLSB_RELEASE\n'
  lsb_release -a 2>&1
fi

# the whole configure line and more, if requested.
# (We want this from make, but not from Build.)
$do_config_status \
&& test -s config.status \
&& (printf '\nCONFIG_STATUS\n'; ./config.status --version | sed -n '1,/^$/p')

exit 0

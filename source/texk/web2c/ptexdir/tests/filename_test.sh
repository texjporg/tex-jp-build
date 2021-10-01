#!/bin/bash
cat <<'EOF' > filename_日本語.tex
% UTF-8 encoding
\def\TEST#1{\ifx#1\relax\else\immediate\write16{[\meaning#1]}\expandafter\TEST\fi}
\expandafter\TEST\jobname\relax

\immediate\openout0=\jobname.txt
\immediate\write0{日本語}
\immediate\closeout0

\openin0=\jobname.txt
\ifeof0
  \immediate\write16{File `\jobname.txt' not found.}
\else
  \read0 to \TEXT
  \immediate\write16{TEXT=\TEXT}
\fi
\closein0

\input \jobname.txt

\end

EOF

ln -s filename_日本語.tex "filename_日本a.tex"
eptex "\input {filename_日本a}"
euptex "\input {filename_日本a}"
ls "filename_日本a".*
rm "filename_日本a".*
ln -s filename_日本語.tex filename_日本ßſa.tex
euptex filename_日本ßſa
ls filename_日本ßſa.*
rm filename_日本ßſa.*

eptex "-jobname=漢ßſa" filename_日本語
ls 漢*; rm 漢*
euptex "-jobname=漢ßſa" filename_日本語
ls 漢*; rm 漢*
rm filename_日本語.tex

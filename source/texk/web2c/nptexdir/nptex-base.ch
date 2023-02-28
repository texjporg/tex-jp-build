@x
% Here is TeX material that gets inserted after \input webmac
@y
% Here is TeX material that gets inserted after \input webmac
\def\pTeX{p\kern-.15em\TeX}
\def\upTeX{u\pTeX}
@z

@x
\def\eTeX{$\varepsilon$-\TeX}
@y
\def\eTeX{$\varepsilon$-\TeX}
\def\epTeX{$\varepsilon$-\pTeX}
\def\eupTeX{$\varepsilon$-\upTeX}
\def\upTeX{u\pTeX}
\def\npTeX{n\pTeX}
\def\pdfTeX{pdf\/\TeX}
@z

@x
@d eTeX_version_string=='-2.6' {current \eTeX\ version}
@y
@d eTeX_version_string=='-2.6' {current \eTeX\ version}
@#
@d epTeX_version_string=='-230214'
@d epTeX_version_number==230214
@z

@x
@d banner==TeX_banner
@d banner_k==TeX_banner_k
@y
@d pTeX_version=4
@d pTeX_minor_version=1
@d pTeX_revision==".0"
@d pTeX_version_string=='-p4.1.0' {current \pTeX\ version}
@#
@d upTeX_version=1
@d upTeX_revision==".29"
@d upTeX_version_string=='-u1.29' {current \upTeX\ version}
@#
@d npTeX_version=0
@d npTeX_revision==".0"
@d npTeX_version_string==eTeX_version_string, '-np0.0'
@#
@d npTeX_banner=='This is npTeX, Version 3.141592653',npTeX_version_string
@d npTeX_banner_k==npTeX_banner
  {printed when \npTeX\ starts}
@#
@d banner==npTeX_banner
@d banner_k==npTeX_banner_k
@z

@x
@d hyph_prime=607 {another prime for hashing \.{\\hyphenation} exceptions;
                if you change this, you should also change |iinf_hyphen_size|.}
@y
@d hyph_prime=607 {another prime for hashing \.{\\hyphenation} exceptions;
                if you change this, you should also change |iinf_hyphen_size|.}
@d text_size=0 {size code for the largest size in a family}
@d script_size=256 {size code for the medium size in a family}
@d script_script_size=512 {size code for the smallest size in a family}
@d max_char_val=@"0800000 {to separate char and command code}
@z

@x
@d not_found4=49 {like |not_found|, when there's more than four}
@y
@d not_found4=49 {like |not_found|, when there's more than four}
@d not_found5=50 {like |not_found|, when there's more than five}
@z

@x
@!ASCII_code=0..255; {eight-bit numbers}
@y
@!ASCII_code=0..255; {eight-bit numbers}
@!KANJI_code=0..@"7FFFFF; {0..0x10FFFF: Unicode, 0x110000..0x7FFFFF: special}
@!ext_ASCII_code=0..32768; { only use 0--511 }
@z

@x
xchr: array [ASCII_code] of text_char;
   { specifies conversion of output characters }
@y
xchr: array [ext_ASCII_code] of ext_ASCII_code;
   { specifies conversion of output characters }
@z

@x
for i:=@'177 to @'377 do xchr[i]:=i;
@y
for i:=@'177 to @'777 do xchr[i]:=i;
@z

@x
@!eight_bits=0..255; {unsigned one-byte quantity}
@y
@!eight_bits=0..255; {unsigned one-byte quantity}
@!sixteen_bits=0..65535; {unsigned two-bytes quantity}
@z

@x
@ All of the file opening functions are defined in C.
@y
@ All of the file opening functions are defined in C.

@ Kanji code handling.
@z

@x
@<Glob...@>=
@!buffer:^ASCII_code; {lines of characters being read}
@y
In \pTeX, we use another array |buffer2[]| to indicate which byte
is a part of a Japanese character.
|buffer2[]| is initialized to zero in reading one line from a file
(|input_ln|). |buffer2[i]| is set to one when |buffer[i]| is known
to be a part of a Japanese character, in |get_next| routine.

@<Glob...@>=
@!buffer:^ASCII_code; {lines of characters being read}
@!buffer2:^ASCII_code;
@z

@x
@!packed_ASCII_code = 0..255; {elements of |str_pool| array}
@y
@!packed_ASCII_code = 0..32768; {elements of |str_pool| array}
  { 256..511 are used by (non-Japanese) UTF-8 sequence }
  { 512..767 are used by Japanese UTF-8 sequence }
@z

@x
while j<str_start[s+1] do
  begin if so(str_pool[j])<>buffer[k] then
@y
while j<str_start[s+1] do
  begin if so(str_pool[j])<>buffer2[k]*@"100+buffer[k] then
@z

@x
@!init function get_strings_started:boolean; {initializes the string pool,
  but returns |false| if something goes wrong}
label done,exit;
var k,@!l:0..255; {small indices or counters}
@y
@!init function get_strings_started:boolean; {initializes the string pool,
  but returns |false| if something goes wrong}
label done,exit;
var k,@!l:KANJI_code; {small indices or counters}
@z

@x
@!trick_buf:array[0..ssup_error_line] of ASCII_code; {circular buffer for
  pseudoprinting}
@y
@!trick_buf:array[0..ssup_error_line] of ext_ASCII_code; {circular buffer for
  pseudoprinting}
@!trick_buf2:array[0..ssup_error_line] of 0..@'24; {pTeX: buffer for KANJI}
@!kcode_pos: 0..@'24; {pTeX: denotes whether first byte or second byte of KANJI
  1..2:2byte-char, 11..13:3byte-char, 21..24:4byte-char}
@!kcp: 0..@'24; {temporary |kcode_pos|}
@!prev_char: ASCII_code;
@z

@x
@ @<Initialize the output routines@>=
selector:=term_only; tally:=0; term_offset:=0; file_offset:=0;
@y
@ @<Initialize the output routines@>=
selector:=term_only; tally:=0; term_offset:=0; file_offset:=0;
kcode_pos:=0;
@z

@x
procedure print_ln; {prints an end-of-line}
begin case selector of
term_and_log: begin wterm_cr; wlog_cr;
  term_offset:=0; file_offset:=0;
  end;
log_only: begin wlog_cr; file_offset:=0;
  end;
term_only: begin wterm_cr; term_offset:=0;
  end;
no_print,pseudo,new_string: do_nothing;
othercases write_ln(write_file[selector])
endcases;@/
@y
procedure print_ln; {prints an end-of-line}
var @!ii: integer;
begin case selector of
term_and_log: begin
  if nrestmultichr(kcode_pos)>0 then
  for ii:=0 to nrestmultichr(kcode_pos)-1 do
    begin wterm(' '); wlog(' '); end;
  wterm_cr; wlog_cr; term_offset:=0; file_offset:=0;
  end;
log_only: begin
  if nrestmultichr(kcode_pos)>0 then
  for ii:=0 to nrestmultichr(kcode_pos)-1 do wlog(' ');
  wlog_cr; file_offset:=0;
  end;
term_only: begin
  if nrestmultichr(kcode_pos)>0 then
  for ii:=0 to nrestmultichr(kcode_pos)-1 do wterm(' ');
  wterm_cr; term_offset:=0;
  end;
no_print,pseudo,new_string: do_nothing;
othercases write_ln(write_file[selector])
endcases;@/
kcode_pos:=0;
@z

@x
procedure print_char(@!s:ASCII_code); {prints a single character}
label exit;
begin if @<Character |s| is the current new-line character@> then
 if selector<pseudo then
  begin print_ln; return;
  end;
case selector of
term_and_log: begin wterm(xchr[s]); wlog(xchr[s]);
  incr(term_offset); incr(file_offset);
  if term_offset=max_print_line then
    begin wterm_cr; term_offset:=0;
    end;
  if file_offset=max_print_line then
    begin wlog_cr; file_offset:=0;
    end;
  end;
log_only: begin wlog(xchr[s]); incr(file_offset);
  if file_offset=max_print_line then print_ln;
  end;
term_only: begin wterm(xchr[s]); incr(term_offset);
  if term_offset=max_print_line then print_ln;
  end;
no_print: do_nothing;
pseudo: if tally<trick_count then trick_buf[tally mod error_line]:=s;
@y
procedure print_char(@!s:ext_ASCII_code); {prints a single character}
label exit; {label is not used but nonetheless kept (for other changes?)}
begin if @<Character |s| is the current new-line character@> then
 if selector<pseudo then
  begin print_ln; return;
  end;
if s>@"2FF then s:=s mod @"100;
if s<@"100 then kcode_pos:=0
else if (kcode_pos=1)or((kcode_pos>=@'11)and(kcode_pos<=@'12))
   or((kcode_pos>=@'21)and(kcode_pos<=@'23)) then incr(kcode_pos)
else if iskanji1(xchr[s-@"100]) then
  begin
  if (ismultichr(4,1,xchr[s])) then kcode_pos:=@'21
  else if (ismultichr(3,1,xchr[s])) then kcode_pos:=@'11
  else kcode_pos:=1;
  if (selector=term_and_log)or(selector=log_only) then
    if file_offset>=max_print_line-nrestmultichr(kcode_pos) then
       begin wlog_cr; file_offset:=0;
       end;
  if (selector=term_and_log)or(selector=term_only) then
    if term_offset>=max_print_line-nrestmultichr(kcode_pos) then
       begin wterm_cr; term_offset:=0;
       end;
  end
else kcode_pos:=0;
case selector of
term_and_log: begin wterm(xchr[s]); incr(term_offset);
  if term_offset=max_print_line then
    begin wterm_cr; term_offset:=0;
    end;
  wlog(xchr[s]); incr(file_offset);
  if file_offset=max_print_line then
    begin wlog_cr; file_offset:=0;
    end;
  end;
log_only: begin wlog(xchr[s]); incr(file_offset);
  if file_offset=max_print_line then print_ln;
  end;
term_only: begin wterm(xchr[s]); incr(term_offset);
  if term_offset=max_print_line then print_ln;
  end;
no_print: do_nothing;
pseudo: if tally<trick_count then
  begin trick_buf[tally mod error_line]:=s;
  trick_buf2[tally mod error_line]:=kcode_pos;
  end;
@z

@x
procedure print(@!s:integer); {prints string |s|}
label exit;
var j:pool_pointer; {current character code position}
@!nl:integer; {new-line character to restore}
begin if s>=str_ptr then s:="???" {this can't happen}
@.???@>
else if s<256 then
  if s<0 then s:="???" {can't happen}
  else begin if selector>pseudo then
      begin print_char(s); return; {internal strings are not expanded}
      end;
    if (@<Character |s| is the current new-line character@>) then
      if selector<pseudo then
        begin print_ln; return;
        end;
    nl:=new_line_char; new_line_char:=-1;
      {temporarily disable new-line character}
    j:=str_start[s];
    while j<str_start[s+1] do
      begin print_char(so(str_pool[j])); incr(j);
      end;
    new_line_char:=nl; return;
    end;
j:=str_start[s];
while j<str_start[s+1] do
  begin print_char(so(str_pool[j])); incr(j);
  end;
exit:end;
@y
procedure print(@!s:integer); {prints string |s|}
label exit;
var j:pool_pointer; {current character code position}
@!nl:integer; {new-line character to restore}
begin if s>=str_ptr then s:="???" {this can't happen}
@.???@>
else if s<256 then
  if s<0 then s:="???" {can't happen}
  else begin if selector>pseudo then
      begin print_char(s); return; {internal strings are not expanded}
      end;
    if (@<Character |s| is the current new-line character@>) then
      if selector<pseudo then
        begin print_ln; return;
        end;
    if xprn[s] then begin print_char(s); return; end;
    nl:=new_line_char; new_line_char:=-1;
      {temporarily disable new-line character}
    j:=str_start[s];
    while j<str_start[s+1] do
      begin print_char(so(str_pool[j])); incr(j);
      end;
    new_line_char:=nl; return;
    end;
j:=str_start[s];
while j<str_start[s+1] do
  begin print_char(so(str_pool[j])); incr(j);
  end;
exit:end;
@z

@x
procedure slow_print(@!s:integer); {prints string |s|}
var j:pool_pointer; {current character code position}
begin if (s>=str_ptr) or (s<256) then print(s)
else begin j:=str_start[s];
  while j<str_start[s+1] do
    begin print(so(str_pool[j])); incr(j);
    end;
  end;
end;
@y
procedure slow_print(@!s:integer); {prints string |s|}
var j:pool_pointer; {current character code position}
c:integer;
begin if (s>=str_ptr) or (s<256) then print(s)
else begin j:=str_start[s];
  while j<str_start[s+1] do
    begin c:=so(str_pool[j]);
    if c>=@"100 then print_char(c) else print(c); incr(j);
    end;
  end;
end;

procedure slow_print_filename(@!s:integer);
  {prints string |s| which represents filename, without code conversion}
var i,j,l:pool_pointer; p:integer;
begin if (s>=str_ptr) or (s<256) then print(s)
else begin i:=str_start[s]; l:=str_start[s+1];
  while i<l do begin
    p:=multistrlenshort(str_pool, l, i);
    if p<>1 then
      begin for j:=i to i+p-1 do print_char(@"100+(so(str_pool[j]) mod @"100));
      i:=i+p; end
    else begin print(so(str_pool[i]) mod @"100); incr(i); end;
    end;
  end;
end;

procedure print_quoted(@!s:integer);
  {prints string |s| which represents filename,
   omitting quotes and with code conversion}
var i,l:pool_pointer; j,p:integer;
begin if s<>0 then begin
  i:=str_start[s]; l:=str_start[s+1];
  while i<l do begin
    p:=multistrlenshort(str_pool, l, i);
    if p<>1 then begin
      for j:=i to i+p-1 do print_char(@"100+(so(str_pool[j]) mod @"100));
      i:=i+p; end
    else begin
      if so(str_pool[i])<>"""" then print(so(str_pool[i]) mod @"100);
      incr(i); end;
    end;
  end;
end;

@z

@x
@<Initialize the output...@>=
if src_specials_p or file_line_error_style_p or parse_first_line_p then
  wterm(banner_k)
else
  wterm(banner);
@y
@<Initialize the output...@>=
if src_specials_p or file_line_error_style_p or parse_first_line_p then
  wterm(banner_k)
else
  wterm(banner);
  wterm(' (');
  wterm(conststringcast(get_enc_string));
  wterm(')');
@z

@x
@ Old versions of \TeX\ needed a procedure called |print_ASCII| whose function
@y
@ Hexadecimal printing.

@d print_hex_safe(#)==if #<0 then print_int(#) else print_hex(#)

@ Old versions of \TeX\ needed a procedure called |print_ASCII| whose function
@z

@x
@p procedure term_input; {gets a line from the terminal}
@y
@p procedure@?print_unread_buffer_with_ptenc; forward;@t\2@>@/
procedure term_input; {gets a line from the terminal}
@z

@x
if last<>first then for k:=first to last-1 do print(buffer[k]);
@y
if last<>first then print_unread_buffer_with_ptenc(first,last);
@z

@x
@* \[8] Packed data.
@y
@* \[7b] Random numbers.

\font\tenlogo=logo10 % font used for the METAFONT logo
\def\MP{{\tenlogo META}\-{\tenlogo POST}}
\def\pdfTeX{pdf\TeX}

This section is (almost) straight from MetaPost. I had to change
the types (use |integer| instead of |fraction|), but that should
not have any influence on the actual calculations (the original
comments refer to quantities like |fraction_four| ($2^{30}$), and
that is the same as the numeric representation of |maxdimen|).

I've copied the low-level variables and routines that are needed, but
only those (e.g. |m_log|), not the accompanying ones like |m_exp|. Most
of the following low-level numeric routines are only needed within the
calculation of |norm_rand|. I've been forced to rename |make_fraction|
to |make_frac| because TeX already has a routine by that name with
a wholly different function (it creates a |fraction_noad| for math
typesetting) -- Taco

And now let's complete our collection of numeric utility routines
by considering random number generation.
\MP\ generates pseudo-random numbers with the additive scheme recommended
in Section 3.6 of {\sl The Art of Computer Programming}; however, the
results are random fractions between 0 and |fraction_one-1|, inclusive.

There's an auxiliary array |randoms| that contains 55 pseudo-random
fractions. Using the recurrence $x_n=(x_{n-55}-x_{n-31})\bmod 2^{28}$,
we generate batches of 55 new $x_n$'s at a time by calling |new_randoms|.
The global variable |j_random| tells which element has most recently
been consumed.

@<Glob...@>=
@!randoms:array[0..54] of integer; {the last 55 random values generated}
@!j_random:0..54; {the number of unused |randoms|}
@!random_seed:scaled; {the default random seed}

@ A small bit of metafont is needed.

@d fraction_half==@'1000000000 {$2^{27}$, represents 0.50000000}
@d fraction_one==@'2000000000 {$2^{28}$, represents 1.00000000}
@d fraction_four==@'10000000000 {$2^{30}$, represents 4.00000000}
@d el_gordo == @'17777777777 {$2^{31}-1$, the largest value that \MP\ likes}
@d halfp(#)==(#) div 2
@d double(#) == #:=#+# {multiply a variable by two}

@ The |make_frac| routine produces the |fraction| equivalent of
|p/q|, given integers |p| and~|q|; it computes the integer
$f=\lfloor2^{28}p/q+{1\over2}\rfloor$, when $p$ and $q$ are
positive. If |p| and |q| are both of the same scaled type |t|,
the ``type relation'' |make_frac(t,t)=fraction| is valid;
and it's also possible to use the subroutine ``backwards,'' using
the relation |make_frac(t,fraction)=t| between scaled types.

If the result would have magnitude $2^{31}$ or more, |make_frac|
sets |arith_error:=true|. Most of \MP's internal computations have
been designed to avoid this sort of error.

If this subroutine were programmed in assembly language on a typical
machine, we could simply compute |(@t$2^{28}$@>*p)div q|, since a
double-precision product can often be input to a fixed-point division
instruction. But when we are restricted to \PASCAL\ arithmetic it
is necessary either to resort to multiple-precision maneuvering
or to use a simple but slow iteration. The multiple-precision technique
would be about three times faster than the code adopted here, but it
would be comparatively long and tricky, involving about sixteen
additional multiplications and divisions.

This operation is part of \MP's ``inner loop''; indeed, it will
consume nearly 10\pct! of the running time (exclusive of input and output)
if the code below is left unchanged. A machine-dependent recoding
will therefore make \MP\ run faster. The present implementation
is highly portable, but slow; it avoids multiplication and division
except in the initial stage. System wizards should be careful to
replace it with a routine that is guaranteed to produce identical
results in all cases.
@^system dependencies@>

As noted below, a few more routines should also be replaced by machine-dependent
code, for efficiency. But when a procedure is not part of the ``inner loop,''
such changes aren't advisable; simplicity and robustness are
preferable to trickery, unless the cost is too high.
@^inner loop@>

@p function make_frac(@!p,@!q:integer):integer;
var @!f:integer; {the fraction bits, with a leading 1 bit}
@!n:integer; {the integer part of $\vert p/q\vert$}
@!negative:boolean; {should the result be negated?}
@!be_careful:integer; {disables certain compiler optimizations}
begin if p>=0 then negative:=false
else  begin negate(p); negative:=true;
  end;
if q<=0 then
  begin debug if q=0 then confusion("/");@;@+gubed@;@/
@:this can't happen /}{\quad \./@>
  negate(q); negative:=not negative;
  end;
n:=p div q; p:=p mod q;
if n>=8 then
  begin arith_error:=true;
  if negative then make_frac:=-el_gordo@+else make_frac:=el_gordo;
  end
else  begin n:=(n-1)*fraction_one;
  @<Compute $f=\lfloor 2^{28}(1+p/q)+{1\over2}\rfloor$@>;
  if negative then make_frac:=-(f+n)@+else make_frac:=f+n;
  end;
end;

@ The |repeat| loop here preserves the following invariant relations
between |f|, |p|, and~|q|:
(i)~|0<=p<q|; (ii)~$fq+p=2^k(q+p_0)$, where $k$ is an integer and
$p_0$ is the original value of~$p$.

Notice that the computation specifies
|(p-q)+p| instead of |(p+p)-q|, because the latter could overflow.
Let us hope that optimizing compilers do not miss this point; a
special variable |be_careful| is used to emphasize the necessary
order of computation. Optimizing compilers should keep |be_careful|
in a register, not store it in memory.
@^inner loop@>

@<Compute $f=\lfloor 2^{28}(1+p/q)+{1\over2}\rfloor$@>=
f:=1;
repeat be_careful:=p-q; p:=be_careful+p;
if p>=0 then f:=f+f+1
else  begin double(f); p:=p+q;
  end;
until f>=fraction_one;
be_careful:=p-q;
if be_careful+p>=0 then incr(f)

@

@p function take_frac(@!q:integer;@!f:integer):integer;
var @!p:integer; {the fraction so far}
@!negative:boolean; {should the result be negated?}
@!n:integer; {additional multiple of $q$}
@!be_careful:integer; {disables certain compiler optimizations}
begin @<Reduce to the case that |f>=0| and |q>0|@>;
if f<fraction_one then n:=0
else  begin n:=f div fraction_one; f:=f mod fraction_one;
  if q<=el_gordo div n then n:=n*q
  else  begin arith_error:=true; n:=el_gordo;
    end;
  end;
f:=f+fraction_one;
@<Compute $p=\lfloor qf/2^{28}+{1\over2}\rfloor-q$@>;
be_careful:=n-el_gordo;
if be_careful+p>0 then
  begin arith_error:=true; n:=el_gordo-p;
  end;
if negative then take_frac:=-(n+p)
else take_frac:=n+p;
end;

@ @<Reduce to the case that |f>=0| and |q>0|@>=
if f>=0 then negative:=false
else  begin negate(f); negative:=true;
  end;
if q<0 then
  begin negate(q); negative:=not negative;
  end;

@ The invariant relations in this case are (i)~$\lfloor(qf+p)/2^k\rfloor
=\lfloor qf_0/2^{28}+{1\over2}\rfloor$, where $k$ is an integer and
$f_0$ is the original value of~$f$; (ii)~$2^k\L f<2^{k+1}$.
@^inner loop@>

@<Compute $p=\lfloor qf/2^{28}+{1\over2}\rfloor-q$@>=
p:=fraction_half; {that's $2^{27}$; the invariants hold now with $k=28$}
if q<fraction_four then
  repeat if odd(f) then p:=halfp(p+q)@+else p:=halfp(p);
  f:=halfp(f);
  until f=1
else  repeat if odd(f) then p:=p+halfp(q-p)@+else p:=halfp(p);
  f:=halfp(f);
  until f=1

@ The subroutines for logarithm and exponential involve two tables.
The first is simple: |two_to_the[k]| equals $2^k$. The second involves
a bit more calculation, which the author claims to have done correctly:
|spec_log[k]| is $2^{27}$ times $\ln\bigl(1/(1-2^{-k})\bigr)=
2^{-k}+{1\over2}2^{-2k}+{1\over3}2^{-3k}+\cdots\,$, rounded to the
nearest integer.

@<Glob...@>=
@!two_to_the:array[0..30] of integer; {powers of two}
@!spec_log:array[1..28] of integer; {special logarithms}


@ @<Set init...@>=
two_to_the[0]:=1;
for k:=1 to 30 do two_to_the[k]:=2*two_to_the[k-1];
spec_log[1]:=93032640;
spec_log[2]:=38612034;
spec_log[3]:=17922280;
spec_log[4]:=8662214;
spec_log[5]:=4261238;
spec_log[6]:=2113709;
spec_log[7]:=1052693;
spec_log[8]:=525315;
spec_log[9]:=262400;
spec_log[10]:=131136;
spec_log[11]:=65552;
spec_log[12]:=32772;
spec_log[13]:=16385;
for k:=14 to 27 do spec_log[k]:=two_to_the[27-k];
spec_log[28]:=1;

@

@p function m_log(@!x:integer):integer;
var @!y,@!z:integer; {auxiliary registers}
@!k:integer; {iteration counter}
begin if x<=0 then @<Handle non-positive logarithm@>
else  begin y:=1302456956+4-100; {$14\times2^{27}\ln2\approx1302456956.421063$}
  z:=27595+6553600; {and $2^{16}\times .421063\approx 27595$}
  while x<fraction_four do
    begin double(x); y:=y-93032639; z:=z-48782;
    end; {$2^{27}\ln2\approx 93032639.74436163$
      and $2^{16}\times.74436163\approx 48782$}
  y:=y+(z div unity); k:=2;
  while x>fraction_four+4 do
    @<Increase |k| until |x| can be multiplied by a
      factor of $2^{-k}$, and adjust $y$ accordingly@>;
  m_log:=y div 8;
  end;
end;

@ @<Increase |k| until |x| can...@>=
begin z:=((x-1) div two_to_the[k])+1; {$z=\lceil x/2^k\rceil$}
while x<fraction_four+z do
  begin z:=halfp(z+1); k:=k+1;
  end;
y:=y+spec_log[k]; x:=x-z;
end

@ @<Handle non-positive logarithm@>=
begin print_err("Logarithm of ");
@.Logarithm...replaced by 0@>
print_scaled(x); print(" has been replaced by 0");
help2("Since I don't take logs of non-positive numbers,")@/
  ("I'm zeroing this one. Proceed, with fingers crossed.");
error; m_log:=0;
end

@ The following somewhat different subroutine tests rigorously if $ab$ is
greater than, equal to, or less than~$cd$,
given integers $(a,b,c,d)$. In most cases a quick decision is reached.
The result is $+1$, 0, or~$-1$ in the three respective cases.

@d return_sign(#)==begin ab_vs_cd:=#; return;
  end

@p function ab_vs_cd(@!a,b,c,d:integer):integer;
label exit;
var @!q,@!r:integer; {temporary registers}
begin @<Reduce to the case that |a,c>=0|, |b,d>0|@>;
loop@+  begin q := a div d; r := c div b;
  if q<>r then
    if q>r then return_sign(1)@+else return_sign(-1);
  q := a mod d; r := c mod b;
  if r=0 then
    if q=0 then return_sign(0)@+else return_sign(1);
  if q=0 then return_sign(-1);
  a:=b; b:=q; c:=d; d:=r;
  end; {now |a>d>0| and |c>b>0|}
exit:end;

@ @<Reduce to the case that |a...@>=
if a<0 then
  begin negate(a); negate(b);
  end;
if c<0 then
  begin negate(c); negate(d);
  end;
if d<=0 then
  begin if b>=0 then
    if ((a=0)or(b=0))and((c=0)or(d=0)) then return_sign(0)
    else return_sign(1);
  if d=0 then
    if a=0 then return_sign(0)@+else return_sign(-1);
  q:=a; a:=c; c:=q; q:=-b; b:=-d; d:=q;
  end
else if b<=0 then
  begin if b<0 then if a>0 then return_sign(-1);
  if c=0 then return_sign(0) else return_sign(-1);
  end

@ To consume a random integer, the program below will say `|next_random|'
and then it will fetch |randoms[j_random]|.

@d next_random==if j_random=0 then new_randoms
  else decr(j_random)

@p procedure new_randoms;
var @!k:0..54; {index into |randoms|}
@!x:integer; {accumulator}
begin for k:=0 to 23 do
  begin x:=randoms[k]-randoms[k+31];
  if x<0 then x:=x+fraction_one;
  randoms[k]:=x;
  end;
for k:=24 to 54 do
  begin x:=randoms[k]-randoms[k-24];
  if x<0 then x:=x+fraction_one;
  randoms[k]:=x;
  end;
j_random:=54;
end;

@ To initialize the |randoms| table, we call the following routine.

@p procedure init_randoms(@!seed:integer);
var @!j,@!jj,@!k:integer; {more or less random integers}
@!i:0..54; {index into |randoms|}
begin j:=abs(seed);
while j>=fraction_one do j:=halfp(j);
k:=1;
for i:=0 to 54 do
  begin jj:=k; k:=j-k; j:=jj;
  if k<0 then k:=k+fraction_one;
  randoms[(i*21)mod 55]:=j;
  end;
new_randoms; new_randoms; new_randoms; {``warm up'' the array}
end;

@ To produce a uniform random number in the range |0<=u<x| or |0>=u>x|
or |0=u=x|, given a |scaled| value~|x|, we proceed as shown here.

Note that the call of |take_frac| will produce the values 0 and~|x|
with about half the probability that it will produce any other particular
values between 0 and~|x|, because it rounds its answers.

@p function unif_rand(@!x:integer):integer;
var @!y:integer; {trial value}
begin next_random; y:=take_frac(abs(x),randoms[j_random]);
if y=abs(x) then unif_rand:=0
else if x>0 then unif_rand:=y
else unif_rand:=-y;
end;

@ Finally, a normal deviate with mean zero and unit standard deviation
can readily be obtained with the ratio method (Algorithm 3.4.1R in
{\sl The Art of Computer Programming\/}).

@p function norm_rand:integer;
var @!x,@!u,@!l:integer; {what the book would call $2^{16}X$, $2^{28}U$,
  and $-2^{24}\ln U$}
begin repeat
  repeat next_random;
  x:=take_frac(112429,randoms[j_random]-fraction_half);
    {$2^{16}\sqrt{8/e}\approx 112428.82793$}
  next_random; u:=randoms[j_random];
  until abs(x)<u;
x:=make_frac(x,u);
l:=139548960-m_log(u); {$2^{24}\cdot12\ln2\approx139548959.6165$}
until ab_vs_cd(1024,l,x,x)>=0;
norm_rand:=x;
end;
@* \[8] Packed data.
@z

@x
@d min_quarterword=0 {smallest allowable value in a |quarterword|}
@d max_quarterword=255 {largest allowable value in a |quarterword|}
@d min_halfword==-@"FFFFFFF {smallest allowable value in a |halfword|}
@d max_halfword==@"FFFFFFF {largest allowable value in a |halfword|}
@y
@d min_quarterword=0 {smallest allowable value in a |quarterword|}
@d max_quarterword=@"FFFF {largest allowable value in a |quarterword|}
@d min_halfword=-@"3FFFFFFF {smallest allowable value in a |halfword|}
@d max_halfword=@"3FFFFFFF {largest allowable value in a |halfword|}
@d number_usvs=@"0110000 {number of Unicode characters}
@z

@x
  (mem_top+sup_main_memory>=max_halfword) then bad:=14;
@y
  (mem_top+sup_main_memory>=max_halfword)or@|
  (hi(0)<>0) then bad:=14;
@z

@x
sufficiently large.
@y
sufficiently large and this is required for \pTeX.
@z

@x
@d ho(#)==# {to take a sixteen-bit item from a halfword}
@y
@d ho(#)==# {to take a sixteen-bit item from a halfword}
@d KANJI(#)==# {pTeX: to output a KANJI code}
@d tokanji(#)==# {pTeX: to take a KANJI code from a halfword}
@d tonum(#)==# {pTeX: to put a KANJI code into a halfword}
@z

@x
specifies the order of infinity to which glue setting applies (|normal|,
|fil|, |fill|, or |filll|). The |subtype| field is not used in \TeX.
@y
specifies the order of infinity to which glue setting applies (|normal|,
|sfi|, |fil|, |fill|, or |filll|). The |subtype| field is not used in \TeX.
In \pTeX\ the |subtype| field records the box direction |box_dir|.
@z

@x
In \eTeX\ the |subtype| field records the box direction mode |box_lr|.
@y
In \eTeX\ the |subtype| field records the box direction mode |box_lr|.
In \epTeX\ the |subtype| field is |qi(16*box_lr+box_dir)|.
@z

@x
@d hlist_node=0 {|type| of hlist nodes}
@d box_node_size=7 {number of words to allocate for a box node}
@d width_offset=1 {position of |width| field in a box node}
@d depth_offset=2 {position of |depth| field in a box node}
@d height_offset=3 {position of |height| field in a box node}
@d width(#) == mem[#+width_offset].sc {width of the box, in sp}
@d depth(#) == mem[#+depth_offset].sc {depth of the box, in sp}
@d height(#) == mem[#+height_offset].sc {height of the box, in sp}
@d shift_amount(#) == mem[#+4].sc {repositioning distance, in sp}
@d list_offset=5 {position of |list_ptr| field in a box node}
@d list_ptr(#) == link(#+list_offset) {beginning of the list inside the box}
@d glue_order(#) == subtype(#+list_offset) {applicable order of infinity}
@d glue_sign(#) == type(#+list_offset) {stretching or shrinking}
@d normal=0 {the most common case when several cases are named}
@d stretching = 1 {glue setting applies to the stretch components}
@d shrinking = 2 {glue setting applies to the shrink components}
@d glue_offset = 6 {position of |glue_set| in a box node}
@d glue_set(#) == mem[#+glue_offset].gr
  {a word of type |glue_ratio| for glue setting}
@y
@d hlist_node=0 {|type| of hlist nodes}
@d box_node_size=8 {number of words to allocate for a box node}
@#
@d dir_max = 5 {the maximal absolute value of direction}
@d box_dir(#) == ((qo(subtype(#)))mod 16 - dir_max) {direction of a box}
@d set_box_dir(#) == subtype(#):=box_lr(#)*16+set_box_dir_end
@d set_box_dir_end(#) == qi(#)+dir_max
@#
@d dir_default = 0 {direction of the box, default Left to Right}
@d dir_dtou = 1 {direction of the box, Bottom to Top}
@d dir_tate = 3 {direction of the box, Top to Bottom}
@d dir_yoko = 4 {direction of the box, equal default}
@d any_dir == dir_yoko,dir_tate,dir_dtou
@#
@d width_offset=1 {position of |width| field in a box node}
@d depth_offset=2 {position of |depth| field in a box node}
@d height_offset=3 {position of |height| field in a box node}
@d width(#) == mem[#+width_offset].sc {width of the box, in sp}
@d depth(#) == mem[#+depth_offset].sc {depth of the box, in sp}
@d height(#) == mem[#+height_offset].sc {height of the box, in sp}
@d shift_amount(#) == mem[#+4].sc {repositioning distance, in sp}
@d list_offset=5 {position of |list_ptr| field in a box node}
@d list_ptr(#) == link(#+list_offset) {beginning of the list inside the box}
@d glue_order(#) == subtype(#+list_offset) {applicable order of infinity}
@d glue_sign(#) == type(#+list_offset) {stretching or shrinking}
@d normal=0 {the most common case when several cases are named}
@d stretching = 1 {glue setting applies to the stretch components}
@d shrinking = 2 {glue setting applies to the shrink components}
@d glue_offset = 6 {position of |glue_set| in a box node}
@d glue_set(#) == mem[#+glue_offset].gr
  {a word of type |glue_ratio| for glue setting}
@d space_offset = 7 {position of |glue_set| in a box node}
@d space_ptr(#) == link(#+space_offset)
@d xspace_ptr(#) == info(#+space_offset)
@z

@x
width(p):=0; depth(p):=0; height(p):=0; shift_amount(p):=0; list_ptr(p):=null;
glue_sign(p):=normal; glue_order(p):=normal; set_glue_ratio_zero(glue_set(p));
@y
width(p):=0; depth(p):=0; height(p):=0; shift_amount(p):=0; list_ptr(p):=null;
glue_sign(p):=normal; glue_order(p):=normal; set_glue_ratio_zero(glue_set(p));
space_ptr(p):=zero_glue; xspace_ptr(p):=zero_glue; set_box_dir(p)(dir_default);
add_glue_ref(zero_glue); add_glue_ref(zero_glue);
@z

@x
@d vlist_node=1 {|type| of vlist nodes}
@y
@d vlist_node=1 {|type| of vlist nodes}

@ A |dir_node| stands for direction change.

@d dir_node=2 {|type| of dir nodes}

@p function new_dir_node(b:pointer; dir:eight_bits):pointer;
var p:pointer; {the new node}
begin if type(b)>vlist_node then confusion("new_dir_node:not box");
p:=new_null_box; type(p):=dir_node; set_box_dir(p)(dir);
case abs(box_dir(b)) of
  dir_yoko: @<Yoko to other direction@>;
  dir_tate: @<Tate to other direction@>;
  dir_dtou: @<DtoU to other direction@>;
  othercases confusion("new_dir_node:illegal dir");
endcases;
link(b):=null; list_ptr(p):=b;
new_dir_node:=p;
end;

@ @<Yoko to other direction@>=
  case dir of
  dir_tate: begin width(p):=height(b)+depth(b);
      depth(p):=width(b)/2; height(p):=width(b)-depth(p);
      end;
  dir_dtou: begin width(p):=height(b)+depth(b);
      depth(p):=0; height(p):=width(b);
      end;
  othercases confusion("new_dir_node:y->?");
  endcases

@ @<Tate to other direction@>=
  case dir of
  dir_yoko: begin width(p):=height(b)+depth(b);
      depth(p):=0; height(p):=width(b);
      end;
  dir_dtou: begin width(p):=width(b);
      depth(p):=height(b); height(p):=depth(b);
      end;
  othercases confusion("new_dir_node:t->?");
  endcases

@ @<DtoU to other direction@>=
  case dir of
  dir_yoko: begin width(p):=height(b)+depth(b);
      depth(p):=0; height(p):=width(b);
      end;
  dir_tate: begin width(p):=width(b);
      depth(p):=height(b); height(p):=depth(b);
      end;
  othercases confusion("new_dir_node:d->?");
  endcases
@z

@x
@d rule_node=2 {|type| of rule nodes}
@y
@d rule_node=3 {|type| of rule nodes}
@z

@x
@d ins_node=3 {|type| of insertion nodes}
@d ins_node_size=5 {number of words to allocate for an insertion}
@d float_cost(#)==mem[#+1].int {the |floating_penalty| to be used}
@d ins_ptr(#)==info(#+4) {the vertical list to be inserted}
@d split_top_ptr(#)==link(#+4) {the |split_top_skip| to be used}
@y
@d ins_node=4 {|type| of insertion nodes}
@d ins_node_size=6 {number of words to allocate for an insertion}
@d float_cost(#)==mem[#+1].int {the |floating_penalty| to be used}
@d ins_ptr(#)==info(#+4) {the vertical list to be inserted}
@d split_top_ptr(#)==link(#+4) {the |split_top_skip| to be used}
@d ins_dir(#)==(subtype(#+5)-dir_max) {direction of |ins_node|}
@d set_ins_dir(#) == subtype(#+5):=set_box_dir_end
@z

@x
@ A |mark_node| has a |mark_ptr| field that points to the reference count
@y
@ A |disp_node| has a |disp_dimen| field that points to the displacement
distance of the baselineshift between Latin characters and Kanji chatacters.

@d disp_node=5 {|type| of a displace node}
@d disp_dimen(#)==mem[#+1].sc

@ A |mark_node| has a |mark_ptr| field that points to the reference count
@z

@x
@d mark_node=4 {|type| of a mark node}
@y
@d mark_node=6 {|type| of a mark node}
@z

@x
@d adjust_node=5 {|type| of an adjust node}
@y
@d adjust_node=7 {|type| of an adjust node}
@z

@x
@d adjust_ptr(#)==mem[#+1].int
  {vertical list to be moved out of horizontal list}
@y
@d adjust_pre == subtype  {<>0 => pre-adjustment}
@#{|append_list| is used to append a list to |tail|}
@d append_list(#) == begin link(tail) := link(#); append_list_end
@d append_list_end(#) == tail := #; end

@d adjust_ptr(#)==mem[#+1].int
  {vertical list to be moved out of horizontal list}
@z

@x
@d ligature_node=6 {|type| of a ligature node}
@y
@d ligature_node=8 {|type| of a ligature node}
@z

@x
@d disc_node=7 {|type| of a discretionary node}
@y
@d disc_node=9 {|type| of a discretionary node}
@z

@x
@d whatsit_node=8 {|type| of special extension nodes}
@y
@d whatsit_node=10 {|type| of special extension nodes}
@z

@x
@d math_node=9 {|type| of a math node}
@y
@d math_node=11 {|type| of a math node}
@z

@x
@d glue_node=10 {|type| of node that points to a glue specification}
@y
@d glue_node=12 {|type| of node that points to a glue specification}
@z

@x
orders of infinity (|normal|, |fil|, |fill|, or |filll|)
@y
orders of infinity (|normal|, |sfi|, |fil|, |fill|, or |filll|)
@z

@x
@d fil=1 {first-order infinity}
@d fill=2 {second-order infinity}
@d filll=3 {third-order infinity}
@y
@d sfi=1 {first-order infinity}
@d fil=2 {second-order infinity}
@d fill=3 {third-order infinity}
@d filll=4 {fourth-order infinity}
@z

@x
@!glue_ord=normal..filll; {infinity to the 0, 1, 2, or 3 power}
@y
@!glue_ord=normal..filll; {infinity to the 0, 1, 2, 3, or 4 power}
@z

@x
@d kern_node=11 {|type| of a kern node}
@d explicit=1 {|subtype| of kern nodes from \.{\\kern} and \.{\\/}}
@d acc_kern=2 {|subtype| of kern nodes from accents}
@y
@d kern_node=13 {|type| of a kern node}
@d explicit=1 {|subtype| of kern nodes from \.{\\kern}}
@d acc_kern=2 {|subtype| of kern nodes from accents}
@d ita_kern=3 {|subtype| of kern nodes from \.{\\/}}
@z

@x
@d penalty_node=12 {|type| of a penalty node}
@y
@d penalty_node=14 {|type| of a penalty node}
@d widow_pena=1 {|subtype| of penalty nodes from \.{\\jcharwidowpenalty}}
@d kinsoku_pena=2 {|subtype| of penalty nodes from kinsoku}
@z

@x
@d unset_node=13 {|type| for an unset node}
@y
@d unset_node=15 {|type| for an unset node}
@z

@x
@ In fact, there are still more types coming. When we get to math formula
processing we will see that a |style_node| has |type=14|; and a number
of larger type codes will also be defined, for use in math mode only.
@y
@ In fact, there are still more types coming. When we get to math formula
processing we will see that a |style_node| has |type=16|; and a number
of larger type codes will also be defined, for use in math mode only.
@z

@x
@d fil_glue==zero_glue+glue_spec_size {\.{0pt plus 1fil minus 0pt}}
@y
@d sfi_glue==zero_glue+glue_spec_size {\.{0pt plus 1fi minus 0pt}}
@d fil_glue==sfi_glue+glue_spec_size {\.{0pt plus 1fil minus 0pt}}
@z

@x
@d hi_mem_stat_min==mem_top-13 {smallest statically allocated word in
  the one-word |mem|}
@d hi_mem_stat_usage=14 {the number of one-word nodes always present}
@y
@d pre_adjust_head==mem_top-14  {head of pre-adjustment list returned by |hpack|}
@d hi_mem_stat_min==mem_top-14 {smallest statically allocated word in
  the one-word |mem|}
@d hi_mem_stat_usage=15 {the number of one-word nodes always present}
@z

@x
stretch(fil_glue):=unity; stretch_order(fil_glue):=fil;@/
stretch(fill_glue):=unity; stretch_order(fill_glue):=fill;@/
@y
stretch(sfi_glue):=unity; stretch_order(sfi_glue):=sfi;@/
stretch(fil_glue):=unity; stretch_order(fil_glue):=fil;@/
stretch(fill_glue):=unity; stretch_order(fill_glue):=fill;@/
@z

@x
@* \[12] Displaying boxes.
@y
@<Declare procedures that need to be declared forward for \pdfTeX@>@;

@* \[12] Displaying boxes.
@z

@x
@p procedure short_display(@!p:integer); {prints highlights of list |p|}
@y
@p@t\4@>@<Declare the pTeX-specific |print_font_...| procedures@>@;@/
procedure short_display(@!p:integer); {prints highlights of list |p|}
@z

@x
      print_ASCII(qo(character(p)));
@y
      if font_dir[font(p)]<>dir_default then
        begin p:=link(p); print_kanji(info(p));
        end
      else print_ASCII(qo(character(p))); { We have |character(p)<256| }
@z

@x
hlist_node,vlist_node,ins_node,whatsit_node,mark_node,adjust_node,
  unset_node: print("[]");
@y
hlist_node,vlist_node,dir_node,ins_node,whatsit_node,
  mark_node,adjust_node,unset_node: print("[]");
@z

@x
  print_char(" "); print_ASCII(qo(character(p)));
@y
  print_char(" ");
  if font_dir[font(p)]<>dir_default then
    begin p:=link(p); print_kanji(info(p));
    end
  else print_ASCII(qo(character(p))); { We have |character(p)<256| }
@z

@x
  begin print("fil");
  while order>fil do
@y
  begin print("fi");
  while order>sfi do
@z

@x
if is_char_node(p) then print_font_and_char(p)
else  case type(p) of
  hlist_node,vlist_node,unset_node: @<Display box |p|@>;
  rule_node: @<Display rule |p|@>;
  ins_node: @<Display insertion |p|@>;
  whatsit_node: @<Display the whatsit node |p|@>;
@y
if is_char_node(p) then
  begin print_font_and_char(p);
  if font_dir[font(p)]<>dir_default then p:=link(p)
  end
else  case type(p) of
  hlist_node,vlist_node,dir_node,unset_node: @<Display box |p|@>;
  rule_node: @<Display rule |p|@>;
  ins_node: @<Display insertion |p|@>;
  whatsit_node: @<Display the whatsit node |p|@>;
  disp_node: begin print_esc("displace "); print_scaled(disp_dimen(p));
    end;
@z

@x
@ @<Display box |p|@>=
begin if type(p)=hlist_node then print_esc("h")
else if type(p)=vlist_node then print_esc("v")
else print_esc("unset");
@y
@ @<Display box |p|@>=
begin case type(p) of
  hlist_node: print_esc("h");
  vlist_node: print_esc("v");
  dir_node: print_esc("dir");
  othercases print_esc("unset")
  endcases@/;
@z

@x
  if shift_amount(p)<>0 then
    begin print(", shifted "); print_scaled(shift_amount(p));
    end;
@y
  if shift_amount(p)<>0 then
    begin print(", shifted "); print_scaled(shift_amount(p));
    end;
@z

@x
  end;
@y
  if box_dir(p)<>dir_default then
    begin print_direction_alt(box_dir(p));
    end;
  end;
@z

@x
@ @<Display insertion |p|@>=
begin print_esc("insert"); print_int(qo(subtype(p)));
print(", natural size "); print_scaled(height(p));
@y
@ @<Display insertion |p|@>=
begin print_esc("insert"); print_int(qo(subtype(p)));
print_dir(abs(ins_dir(p)));
print(", natural size "); print_scaled(height(p));
@z

@x
@ @<Display penalty |p|@>=
begin print_esc("penalty "); print_int(penalty(p));
end
@y
@ @<Display penalty |p|@>=
begin print_esc("penalty "); print_int(penalty(p));
if subtype(p)=widow_pena then print("(for \jcharwidowpenalty)")
else if subtype(p)=kinsoku_pena then print("(for kinsoku)");
end
@z

@x
@ @<Display adjustment |p|@>=
begin print_esc("vadjust"); node_list_display(adjust_ptr(p)); {recursive call}
end
@y
@ @<Display adjustment |p|@>=
begin print_esc("vadjust"); if adjust_pre(p) <> 0 then print(" pre ");
node_list_display(adjust_ptr(p)); {recursive call}
end
@z

@x
    hlist_node,vlist_node,unset_node: begin flush_node_list(list_ptr(p));
      free_node(p,box_node_size); goto done;
      end;
@y
    hlist_node,vlist_node,dir_node,unset_node:
      begin flush_node_list(list_ptr(p));
      fast_delete_glue_ref(space_ptr(p));
      fast_delete_glue_ref(xspace_ptr(p));
      free_node(p,box_node_size); goto done;
      end;
@z

@x
    kern_node,math_node,penalty_node: do_nothing;
@y
    disp_node,
    kern_node,math_node,penalty_node: do_nothing;
@z

@x
@ @<Case statement to copy...@>=
@y
@ @<Case statement to copy...@>=
@z

@x
hlist_node,vlist_node,unset_node: begin r:=get_node(box_node_size);
  mem[r+6]:=mem[p+6]; mem[r+5]:=mem[p+5]; {copy the last two words}
@y
dir_node,
hlist_node,vlist_node,unset_node: begin r:=get_node(box_node_size);
  mem[r+7]:=mem[p+7];
  mem[r+6]:=mem[p+6]; mem[r+5]:=mem[p+5]; {copy the last three words}
  add_glue_ref(space_ptr(r)); add_glue_ref(xspace_ptr(r));
@z

@x
ins_node: begin r:=get_node(ins_node_size); mem[r+4]:=mem[p+4];
  add_glue_ref(split_top_ptr(p));
  ins_ptr(r):=copy_node_list(ins_ptr(p)); {this affects |mem[r+4]|}
  words:=ins_node_size-1;
  end;
@y
ins_node: begin r:=get_node(ins_node_size);
  mem[r+5]:=mem[p+5]; mem[r+4]:=mem[p+4];
  add_glue_ref(split_top_ptr(p));
  ins_ptr(r):=copy_node_list(ins_ptr(p)); {this affects |mem[r+4]|}
  words:=ins_node_size-2;
  end;
@z

@x
kern_node,math_node,penalty_node: begin r:=get_node(small_node_size);
@y
disp_node,
kern_node,math_node,penalty_node: begin r:=get_node(small_node_size);
@z

@x
@d max_char_code=15 {largest catcode for individual characters}
@y
@d cjk_code_flag=16
@d kanji=letter+cjk_code_flag {kanji}
@d kana=kanji+cjk_code_flag {hiragana, katakana, alphabet}
@d other_kchar=other_char+cjk_code_flag {cjk symbol codes}
@d hangul=kana+cjk_code_flag {hangul codes}
@d max_char_code=64 {largest catcode for individual characters}
@z

@x
@d char_num=16 {character specified numerically ( \.{\\char} )}
@d math_char_num=17 {explicit math code ( \.{\\mathchar} )}
@d mark=18 {mark definition ( \.{\\mark} )}
@d xray=19 {peek inside of \TeX\ ( \.{\\show}, \.{\\showbox}, etc.~)}
@d make_box=20 {make a box ( \.{\\box}, \.{\\copy}, \.{\\hbox}, etc.~)}
@d hmove=21 {horizontal motion ( \.{\\moveleft}, \.{\\moveright} )}
@d vmove=22 {vertical motion ( \.{\\raise}, \.{\\lower} )}
@d un_hbox=23 {unglue a box ( \.{\\unhbox}, \.{\\unhcopy} )}
@d un_vbox=24 {unglue a box ( \.{\\unvbox}, \.{\\unvcopy} )}
@y
@d char_num=max_char_code+1 {character specified numerically ( \.{\\char} )}
@d kchar_num=char_num+1 {cjk character specified numerically ( \.{\\kchar} )}
@d math_char_num=kchar_num+1 {explicit math code ( \.{\\mathchar} )}
@d mark=math_char_num+1 {mark definition ( \.{\\mark} )}
@d xray=mark+1 {peek inside of \TeX\ ( \.{\\show}, \.{\\showbox}, etc.~)}
@d make_box=xray+1 {make a box ( \.{\\box}, \.{\\copy}, \.{\\hbox}, etc.~)}
@d hmove=make_box+1 {horizontal motion ( \.{\\moveleft}, \.{\\moveright} )}
@d vmove=hmove+1 {vertical motion ( \.{\\raise}, \.{\\lower} )}
@d un_hbox=vmove+1 {unglue a box ( \.{\\unhbox}, \.{\\unhcopy} )}
@d un_vbox=un_hbox+1 {unglue a box ( \.{\\unvbox}, \.{\\unvcopy} )}
@z

@x
@d remove_item=25 {nullify last item ( \.{\\unpenalty},
  \.{\\unkern}, \.{\\unskip} )}
@d hskip=26 {horizontal glue ( \.{\\hskip}, \.{\\hfil}, etc.~)}
@d vskip=27 {vertical glue ( \.{\\vskip}, \.{\\vfil}, etc.~)}
@d mskip=28 {math glue ( \.{\\mskip} )}
@d kern=29 {fixed space ( \.{\\kern} )}
@d mkern=30 {math kern ( \.{\\mkern} )}
@d leader_ship=31 {use a box ( \.{\\shipout}, \.{\\leaders}, etc.~)}
@d halign=32 {horizontal table alignment ( \.{\\halign} )}
@d valign=33 {vertical table alignment ( \.{\\valign} )}
@y
@d remove_item=un_vbox+1 {nullify last item ( \.{\\unpenalty},
  \.{\\unkern}, \.{\\unskip} )}
@d hskip=remove_item+1 {horizontal glue ( \.{\\hskip}, \.{\\hfil}, etc.~)}
@d vskip=hskip+1 {vertical glue ( \.{\\vskip}, \.{\\vfil}, etc.~)}
@d mskip=vskip+1 {math glue ( \.{\\mskip} )}
@d kern=mskip+1 {fixed space ( \.{\\kern} )}
@d mkern=kern+1 {math kern ( \.{\\mkern} )}
@d leader_ship=mkern+1 {use a box ( \.{\\shipout}, \.{\\leaders}, etc.~)}
@d halign=leader_ship+1 {horizontal table alignment ( \.{\\halign} )}
@d valign=halign+1 {vertical table alignment ( \.{\\valign} )}
@z

@x
@d no_align=34 {temporary escape from alignment ( \.{\\noalign} )}
@d vrule=35 {vertical rule ( \.{\\vrule} )}
@d hrule=36 {horizontal rule ( \.{\\hrule} )}
@d insert=37 {vlist inserted in box ( \.{\\insert} )}
@d vadjust=38 {vlist inserted in enclosing paragraph ( \.{\\vadjust} )}
@d ignore_spaces=39 {gobble |spacer| tokens ( \.{\\ignorespaces} )}
@d after_assignment=40 {save till assignment is done ( \.{\\afterassignment} )}
@d after_group=41 {save till group is done ( \.{\\aftergroup} )}
@d break_penalty=42 {additional badness ( \.{\\penalty} )}
@d start_par=43 {begin paragraph ( \.{\\indent}, \.{\\noindent} )}
@d ital_corr=44 {italic correction ( \.{\\/} )}
@d accent=45 {attach accent in text ( \.{\\accent} )}
@d math_accent=46 {attach accent in math ( \.{\\mathaccent} )}
@d discretionary=47 {discretionary texts ( \.{\\-}, \.{\\discretionary} )}
@d eq_no=48 {equation number ( \.{\\eqno}, \.{\\leqno} )}
@d left_right=49 {variable delimiter ( \.{\\left}, \.{\\right} )}
@y
@d no_align=valign+1 {temporary escape from alignment ( \.{\\noalign} )}
@d vrule=no_align+1 {vertical rule ( \.{\\vrule} )}
@d hrule=vrule+1 {horizontal rule ( \.{\\hrule} )}
@d insert=hrule+1 {vlist inserted in box ( \.{\\insert} )}
@d vadjust=insert+1 {vlist inserted in enclosing paragraph ( \.{\\vadjust} )}
@d ignore_spaces=vadjust+1 {gobble |spacer| tokens ( \.{\\ignorespaces} )}
@d after_assignment=ignore_spaces+1 {save till assignment is done ( \.{\\afterassignment} )}
@d after_group=after_assignment+1 {save till group is done ( \.{\\aftergroup} )}
@d break_penalty=after_group+1 {additional badness ( \.{\\penalty} )}
@d start_par=break_penalty+1 {begin paragraph ( \.{\\indent}, \.{\\noindent} )}
@d ital_corr=start_par+1 {italic correction ( \.{\\/} )}
@d accent=ital_corr+1 {attach accent in text ( \.{\\accent} )}
@d math_accent=accent+1 {attach accent in math ( \.{\\mathaccent} )}
@d discretionary=math_accent+1 {discretionary texts ( \.{\\-}, \.{\\discretionary} )}
@d eq_no=discretionary+1 {equation number ( \.{\\eqno}, \.{\\leqno} )}
@d left_right=eq_no+1 {variable delimiter ( \.{\\left}, \.{\\right} )}
@z

@x
@d math_comp=50 {component of formula ( \.{\\mathbin}, etc.~)}
@d limit_switch=51 {diddle limit conventions ( \.{\\displaylimits}, etc.~)}
@d above=52 {generalized fraction ( \.{\\above}, \.{\\atop}, etc.~)}
@d math_style=53 {style specification ( \.{\\displaystyle}, etc.~)}
@d math_choice=54 {choice specification ( \.{\\mathchoice} )}
@d non_script=55 {conditional math glue ( \.{\\nonscript} )}
@d vcenter=56 {vertically center a vbox ( \.{\\vcenter} )}
@d case_shift=57 {force specific case ( \.{\\lowercase}, \.{\\uppercase}~)}
@d message=58 {send to user ( \.{\\message}, \.{\\errmessage} )}
@d extension=59 {extensions to \TeX\ ( \.{\\write}, \.{\\special}, etc.~)}
@d in_stream=60 {files for reading ( \.{\\openin}, \.{\\closein} )}
@d begin_group=61 {begin local grouping ( \.{\\begingroup} )}
@d end_group=62 {end local grouping ( \.{\\endgroup} )}
@d omit=63 {omit alignment template ( \.{\\omit} )}
@d ex_space=64 {explicit space ( \.{\\\ } )}
@d no_boundary=65 {suppress boundary ligatures ( \.{\\noboundary} )}
@d radical=66 {square root and similar signs ( \.{\\radical} )}
@d end_cs_name=67 {end control sequence ( \.{\\endcsname} )}
@d min_internal=68 {the smallest code that can follow \.{\\the}}
@d char_given=68 {character code defined by \.{\\chardef}}
@d math_given=69 {math code defined by \.{\\mathchardef}}
@d last_item=70 {most recent item ( \.{\\lastpenalty},
  \.{\\lastkern}, \.{\\lastskip} )}
@d max_non_prefixed_command=70 {largest command code that can't be \.{\\global}}
@y
@d math_comp=left_right+1 {component of formula ( \.{\\mathbin}, etc.~)}
@d limit_switch=math_comp+1 {diddle limit conventions ( \.{\\displaylimits}, etc.~)}
@d above=limit_switch+1 {generalized fraction ( \.{\\above}, \.{\\atop}, etc.~)}
@d math_style=above+1 {style specification ( \.{\\displaystyle}, etc.~)}
@d math_choice=math_style+1 {choice specification ( \.{\\mathchoice} )}
@d non_script=math_choice+1 {conditional math glue ( \.{\\nonscript} )}
@d vcenter=non_script+1 {vertically center a vbox ( \.{\\vcenter} )}
@d case_shift=vcenter+1 {force specific case ( \.{\\lowercase}, \.{\\uppercase}~)}
@d message=case_shift+1 {send to user ( \.{\\message}, \.{\\errmessage} )}
@d extension=message+1 {extensions to \TeX\ ( \.{\\write}, \.{\\special}, etc.~)}
@d in_stream=extension+1 {files for reading ( \.{\\openin}, \.{\\closein} )}
@d begin_group=in_stream+1 {begin local grouping ( \.{\\begingroup} )}
@d end_group=begin_group+1 {end local grouping ( \.{\\endgroup} )}
@d omit=end_group+1 {omit alignment template ( \.{\\omit} )}
@d ex_space=omit+1 {explicit space ( \.{\\\ } )}
@d no_boundary=ex_space+1 {suppress boundary ligatures ( \.{\\noboundary} )}
@d radical=no_boundary+1 {square root and similar signs ( \.{\\radical} )}
@d end_cs_name=radical+1 {end control sequence ( \.{\\endcsname} )}
@d min_internal=end_cs_name+1 {the smallest code that can follow \.{\\the}}
@d char_given=min_internal {character code defined by \.{\\chardef}}
@d kchar_given=char_given+1 {cjk character code defined by \.{\\kchardef}}
@d math_given=kchar_given+1 {math code defined by \.{\\mathchardef}}
@d omath_given=math_given+1 {math code defined by \.{\\omathchardef}}
@d last_item=omath_given+1 {most recent item ( \.{\\lastpenalty},
  \.{\\lastkern}, \.{\\lastskip} )}
@d inhibit_glue=last_item+1 {inhibit adjust glue ( \.{\\inhibitglue} )}
@d chg_dir=inhibit_glue+1 {change dir mode by \.{\\tate}, \.{\\yoko}}
@d max_non_prefixed_command=chg_dir {largest command code that can't be \.{\\global}}
@z

@x
@d toks_register=71 {token list register ( \.{\\toks} )}
@d assign_toks=72 {special token list ( \.{\\output}, \.{\\everypar}, etc.~)}
@d assign_int=73 {user-defined integer ( \.{\\tolerance}, \.{\\day}, etc.~)}
@d assign_dimen=74 {user-defined length ( \.{\\hsize}, etc.~)}
@d assign_glue=75 {user-defined glue ( \.{\\baselineskip}, etc.~)}
@d assign_mu_glue=76 {user-defined muglue ( \.{\\thinmuskip}, etc.~)}
@d assign_font_dimen=77 {user-defined font dimension ( \.{\\fontdimen} )}
@d assign_font_int=78 {user-defined font integer ( \.{\\hyphenchar},
  \.{\\skewchar} )}
@d set_aux=79 {specify state info ( \.{\\spacefactor}, \.{\\prevdepth} )}
@d set_prev_graf=80 {specify state info ( \.{\\prevgraf} )}
@d set_page_dimen=81 {specify state info ( \.{\\pagegoal}, etc.~)}
@d set_page_int=82 {specify state info ( \.{\\deadcycles},
@y
@d toks_register=max_non_prefixed_command+1 {token list register ( \.{\\toks} )}
@d assign_toks=toks_register+1
  {special token list ( \.{\\output}, \.{\\everypar}, etc.~)}
@d assign_int=assign_toks+1
  {user-defined integer ( \.{\\tolerance}, \.{\\day}, etc.~)}
@d assign_dimen=assign_int+1 {user-defined length ( \.{\\hsize}, etc.~)}
@d assign_glue=assign_dimen+1 {user-defined glue ( \.{\\baselineskip}, etc.~)}
@d assign_mu_glue=assign_glue+1 {user-defined muglue ( \.{\\thinmuskip}, etc.~)}
@d assign_font_dimen=assign_mu_glue+1
  {user-defined font dimension ( \.{\\fontdimen} )}
@d assign_font_int=assign_font_dimen+1
  {user-defined font integer ( \.{\\hyphenchar}, \.{\\skewchar} )}
@d assign_kinsoku=assign_font_int+1
  {user-defined kinsoku character ( \.{\\prebreakpenalty},
   \.{\\postbreakpenalty} )}
@d assign_inhibit_xsp_code=assign_kinsoku+1
  {user-defined inhibit xsp character ( \.{\\inhibitxspcode} )}
@d set_kansuji_char=assign_inhibit_xsp_code+1
  {user-defined kansuji character ( \.{\\kansujichar} )}
@d set_aux=set_kansuji_char+1
  {specify state info ( \.{\\spacefactor}, \.{\\prevdepth} )}
@d set_prev_graf=set_aux+1 {specify state info ( \.{\\prevgraf} )}
@d set_page_dimen=set_prev_graf+1 {specify state info ( \.{\\pagegoal}, etc.~)}
@d set_page_int=set_page_dimen+1 {specify state info ( \.{\\deadcycles},
@z

@x
@d set_box_dimen=83 {change dimension of box ( \.{\\wd}, \.{\\ht}, \.{\\dp} )}
@d set_shape=84 {specify fancy paragraph shape ( \.{\\parshape} )}
@y
@d set_box_dimen=set_page_int+1 {change dimension of box ( \.{\\wd}, \.{\\ht}, \.{\\dp} )}
@d set_shape=set_box_dimen+1 {specify fancy paragraph shape ( \.{\\parshape} )}
@z

@x
@d def_code=85 {define a character code ( \.{\\catcode}, etc.~)}
@d def_family=86 {declare math fonts ( \.{\\textfont}, etc.~)}
@d set_font=87 {set current font ( font identifiers )}
@d def_font=88 {define a font file ( \.{\\font} )}
@d register=89 {internal register ( \.{\\count}, \.{\\dimen}, etc.~)}
@d max_internal=89 {the largest code that can follow \.{\\the}}
@d advance=90 {advance a register or parameter ( \.{\\advance} )}
@d multiply=91 {multiply a register or parameter ( \.{\\multiply} )}
@d divide=92 {divide a register or parameter ( \.{\\divide} )}
@d prefix=93 {qualify a definition ( \.{\\global}, \.{\\long}, \.{\\outer} )}
@y
@d def_code=set_shape+1 {define a character code ( \.{\\catcode}, etc.~)}
@d def_family=def_code+1 {declare math fonts ( \.{\\textfont}, etc.~)}
@d set_font=def_family+1 {set current font ( font identifiers )}
@d def_font=set_font+1 {define a font file ( \.{\\font} )}
@d def_jfont=def_font+1 {define a font file ( \.{\\jfont} )}
@d def_tfont=def_jfont+1 {define a font file ( \.{\\tfont} )}
@d register=def_tfont+1 {internal register ( \.{\\count}, \.{\\dimen}, etc.~)}
@d max_internal=register {the largest code that can follow \.{\\the}}
@d advance=max_internal+1 {advance a register or parameter ( \.{\\advance} )}
@d multiply=advance+1 {multiply a register or parameter ( \.{\\multiply} )}
@d divide=multiply+1 {divide a register or parameter ( \.{\\divide} )}
@d prefix=divide+1 {qualify a definition ( \.{\\global}, \.{\\long}, \.{\\outer} )}
@z

@x
@d let=94 {assign a command code ( \.{\\let}, \.{\\futurelet} )}
@d shorthand_def=95 {code definition ( \.{\\chardef}, \.{\\countdef}, etc.~)}
  {or \.{\\charsubdef}}
@d read_to_cs=96 {read into a control sequence ( \.{\\read} )}
@y
@d let=prefix+1 {assign a command code ( \.{\\let}, \.{\\futurelet} )}
@d shorthand_def=let+1 {code definition ( \.{\\chardef}, \.{\\countdef}, etc.~)}
  {or \.{\\charsubdef}}
@d read_to_cs=shorthand_def+1 {read into a control sequence ( \.{\\read} )}
@z

@x
@d def=97 {macro definition ( \.{\\def}, \.{\\gdef}, \.{\\xdef}, \.{\\edef} )}
@d set_box=98 {set a box ( \.{\\setbox} )}
@d hyph_data=99 {hyphenation data ( \.{\\hyphenation}, \.{\\patterns} )}
@d set_interaction=100 {define level of interaction ( \.{\\batchmode}, etc.~)}
@d max_command=100 {the largest command code seen at |big_switch|}
@y
@d def=read_to_cs+1 {macro definition ( \.{\\def}, \.{\\gdef}, \.{\\xdef}, \.{\\edef} )}
@d set_box=def+1 {set a box ( \.{\\setbox} )}
@d hyph_data=set_box+1 {hyphenation data ( \.{\\hyphenation}, \.{\\patterns} )}
@d set_interaction=hyph_data+1 {define level of interaction ( \.{\\batchmode}, etc.~)}
@d set_auto_spacing=set_interaction+1 {set auto spacing mode
  ( \.{\\autospacing}, \.{\\noautospacing}, \.{\\autoxspacing}, \.{\\noautoxspacing} )}
@d set_enable_cjk_token=set_auto_spacing+1 {set cjk mode
  ( \.{\\enablecjktoken}, \.{\\disablecjktoken}, \.{\\forcecjktoken} )}
@d partoken_name=set_enable_cjk_token+1 {set |par_token| name}
@d max_command=partoken_name {the largest command code seen at |big_switch|}
@z

@x
@<Types...@>=
@!list_state_record=record@!mode_field:-mmode..mmode;@+
  @!head_field,@!tail_field: pointer;
@y
@<Types...@>=
@!list_state_record=record@!mode_field:-mmode..mmode;@+
  @!dir_field,@!adj_dir_field: -dir_yoko..dir_yoko;
  @!pdisp_field: scaled;
  @!head_field,@!tail_field,@!pnode_field,@!last_jchr_field: pointer;
  @!disp_called_field: boolean;
  @!inhibit_glue_flag_field: integer;
@z

@x
@d head==cur_list.head_field {header node of current list}
@d tail==cur_list.tail_field {final node on current list}
@y
@d direction==cur_list.dir_field {current direction}
@d adjust_dir==cur_list.adj_dir_field {current adjust direction}
@d head==cur_list.head_field {header node of current list}
@d tail==cur_list.tail_field {final node on current list}
@d prev_node==cur_list.pnode_field {previous to last |disp_node|}
@d prev_disp==cur_list.pdisp_field {displacemant at |prev_node|}
@d last_jchr==cur_list.last_jchr_field {final jchar node on current list}
@d disp_called==cur_list.disp_called_field {is a |disp_node| present in the current list?}
@d inhibit_glue_flag==cur_list.inhibit_glue_flag_field {is \.{\\inhibitglue} specified at the current list?}
@z

@x
@d tail_append(#)==begin link(tail):=#; tail:=link(tail);
  end
@y
@d tail_append(#)==begin link(tail):=#; tail:=link(tail);
  end
@d prev_append(#)==begin link(prev_node):=#;
  link(link(prev_node)):=tail; prev_node:=link(prev_node);
  end
@z

@x
mode:=vmode; head:=contrib_head; tail:=contrib_head;
@y
mode:=vmode; head:=contrib_head; tail:=contrib_head; prev_node:=tail;
direction:=dir_yoko; adjust_dir:=direction; prev_disp:=0; last_jchr:=null;
disp_called:=false;
@z

@x
last_glue:=max_halfword; last_penalty:=0; last_kern:=0;
last_node_type:=-1;
@y
last_glue:=max_halfword; last_penalty:=0; last_kern:=0;
last_node_type:=-1; last_node_subtype:=-1;
@z

@x
incr(nest_ptr); head:=get_avail; tail:=head; prev_graf:=0; mode_line:=line;
@y
incr(nest_ptr); head:=new_null_box; tail:=head; prev_node:=tail;
prev_graf:=0; prev_disp:=0; disp_called:=false; last_jchr:=null; mode_line:=line;
@z

@x
@p procedure pop_nest; {leave a semantic level, re-enter the old}
begin free_avail(head); decr(nest_ptr); cur_list:=nest[nest_ptr];
end;
@y
@p procedure pop_nest; {leave a semantic level, re-enter the old}
begin
fast_delete_glue_ref(space_ptr(head)); fast_delete_glue_ref(xspace_ptr(head));
free_node(head,box_node_size); decr(nest_ptr); cur_list:=nest[nest_ptr];
end;
@z

@x
  print_nl("### "); print_mode(m);
@y
  print_nl("### "); print_direction(nest[p].dir_field);
  print(", "); print_mode(m);
@z

@x
@d active_base=1 {beginning of region 1, for active character equivalents}
@d single_base=active_base+256 {equivalents of one-character control sequences}
@d null_cs=single_base+256 {equivalent of \.{\\csname\\endcsname}}
@y
@d active_base=1 {beginning of region 1, for active character equivalents}
@d single_base=active_base+number_usvs {equivalents of one-character control sequences}
@d null_cs=single_base+number_usvs {equivalent of \.{\\csname\\endcsname}}
@z

@x
@d frozen_special=frozen_control_sequence+10
  {permanent `\.{\\special}'}
@d frozen_null_font=frozen_control_sequence+11
  {permanent `\.{\\nullfont}'}
@y
@d frozen_special=frozen_control_sequence+10
  {permanent `\.{\\special}'}
@d frozen_primitive=frozen_control_sequence+11
  {permanent `\.{\\pdfprimitive}'}
@d prim_eqtb_base=frozen_primitive+1
@d prim_size=2100 {maximum number of primitives }
@d frozen_null_font=prim_eqtb_base+prim_size+1
  {permanent `\.{\\nullfont}'}
@z

@x
@d thin_mu_skip_code=15 {thin space in math formula}
@d med_mu_skip_code=16 {medium space in math formula}
@d thick_mu_skip_code=17 {thick space in math formula}
@d glue_pars=18 {total number of glue parameters}
@y
@d kanji_skip_code=15 {between kanji-kanji space}
@d xkanji_skip_code=16 {between latin-kanji or kanji-latin space}
@d thin_mu_skip_code=17 {thin space in math formula}
@d med_mu_skip_code=18 {medium space in math formula}
@d thick_mu_skip_code=19 {thick space in math formula}
@d jfm_skip=20 {space refer from JFM}
@d glue_pars=21 {total number of glue parameters}
@z

@x
@d thick_mu_skip==glue_par(thick_mu_skip_code)
@y
@d thick_mu_skip==glue_par(thick_mu_skip_code)
@d kanji_skip==glue_par(kanji_skip_code)
@d xkanji_skip==glue_par(xkanji_skip_code)
@z

@x
thick_mu_skip_code: print_esc("thickmuskip");
othercases print("[unknown glue parameter!]")
@y
thick_mu_skip_code: print_esc("thickmuskip");
kanji_skip_code: print_esc("kanjiskip");
xkanji_skip_code: print_esc("xkanjiskip");
jfm_skip: print("refer from jfm");
othercases print("[unknown glue parameter!]")
@z

@x
primitive("thickmuskip",assign_mu_glue,glue_base+thick_mu_skip_code);@/
@!@:thick_mu_skip_}{\.{\\thickmuskip} primitive@>
@y
primitive("thickmuskip",assign_mu_glue,glue_base+thick_mu_skip_code);@/
@!@:thick_mu_skip_}{\.{\\thickmuskip} primitive@>
primitive("kanjiskip",assign_glue,glue_base+kanji_skip_code);@/
@!@:kanji_skip_}{\.{\\kanjiskip} primitive@>
primitive("xkanjiskip",assign_glue,glue_base+xkanji_skip_code);@/
@!@:xkanji_skip_}{\.{\\xkanjiskip} primitive@>
@z

@x
@d etex_toks=etex_toks_base+1 {end of \eTeX's token list parameters}
@y
@d node_recipe_loc=every_eof_loc+1 {not really used, but serves as a flag}
@d etex_toks=node_recipe_loc+1 {end of \eTeX's token list parameters}
@z

@x
@d math_font_base=cur_font_loc+1 {table of 48 math font numbers}
@d cat_code_base=math_font_base+48
  {table of 256 command codes (the ``catcodes'')}
@d lc_code_base=cat_code_base+256 {table of 256 lowercase mappings}
@y
@d math_font_base=cur_font_loc+1 {table of 768 math font numbers}
@d cur_jfont_loc=math_font_base+768
@d cur_tfont_loc=cur_jfont_loc+1
@d auto_spacing_code=cur_tfont_loc+1
@d auto_xspacing_code=auto_spacing_code+1
@d enable_cjk_token_code=auto_xspacing_code+1
@d cat_code_base=enable_cjk_token_code+1
  {table of |number_usvs| command codes (the ``catcodes'')}
@d cjkx_code_base=cat_code_base+number_usvs
  {table of |number_usvs| command codes for the wchar's catcodes }
@d auto_xsp_code_base=cjkx_code_base+number_usvs {table of 256 auto spacer flag}
@d inhibit_xsp_code_base=auto_xsp_code_base+256
@d kinsoku_base=inhibit_xsp_code_base+1024 {table of 1024 kinsoku mappings}
@d kansuji_base=kinsoku_base+1024 {table of 10 kansuji mappings}
@d lc_code_base=kansuji_base+10 {table of 256 lowercase mappings}
@z

@x
@d char_sub_code(#)==equiv(char_sub_code_base+#)
  {Note: |char_sub_code(c)| is the true substitution info plus |min_halfword|}
@y
@d char_sub_code(#)==equiv(char_sub_code_base+#)
  {Note: |char_sub_code(c)| is the true substitution info plus |min_halfword|}
@#
@d cur_jfont==equiv(cur_jfont_loc) {pTeX: }
@d cur_tfont==equiv(cur_tfont_loc)
@d auto_spacing==equiv(auto_spacing_code)
@d auto_xspacing==equiv(auto_xspacing_code)
@d enable_cjk_token==equiv(enable_cjk_token_code)
@d cjkx_code(#)==equiv(cjkx_code_base+#)
@d auto_xsp_code(#)==equiv(auto_xsp_code_base+#)
@d inhibit_xsp_type(#)==eq_type(inhibit_xsp_code_base+#)
@d inhibit_xsp_code(#)==equiv(inhibit_xsp_code_base+#)
@d kinsoku_type(#)==eq_type(kinsoku_base+#)
@d kinsoku_code(#)==equiv(kinsoku_base+#)
@d kansuji_char(#)==equiv(kansuji_base+#)
@d check_echar_range(#)==((cat_code(#)<>letter)or(cat_code(#)<>other_char)or(cjkx_code(#)>0))
@z

@x
@ We initialize most things to null or undefined values. An undefined font
@y
@ @p function kcat_code(@!c:integer):integer;
var @!cc:integer;
begin cc:=cat_code(c);
if cc=other_char then kcat_code:=other_kchar
else kcat_code:=letter+cjkx_code(cc)*cjk_code_flag;
end;

@ We initialize most things to null or undefined values. An undefined font
@z

@x
@d var_code==@'70000 {math code meaning ``use the current family''}
@y
@d var_code==@"70000 {math code meaning ``use the current family''}
@z

@x
cur_font:=null_font; eq_type(cur_font_loc):=data;
eq_level(cur_font_loc):=level_one;@/
@y
cur_font:=null_font; eq_type(cur_font_loc):=data;
eq_level(cur_font_loc):=level_one;@/
cur_jfont:=null_font; eq_type(cur_jfont_loc):=data;
eq_level(cur_jfont_loc):=level_one;@/
cur_tfont:=null_font; eq_type(cur_tfont_loc):=data;
eq_level(cur_tfont_loc):=level_one;@/
@z

@x
for k:=math_font_base to math_font_base+47 do eqtb[k]:=eqtb[cur_font_loc];
@y
for k:=math_font_base to math_font_base+767 do eqtb[k]:=eqtb[cur_font_loc];
@z

@x
for k:=0 to 255 do
  begin cat_code(k):=other_char; math_code(k):=hi(k); sf_code(k):=1000;
  end;
@y
eqtb[auto_spacing_code]:=eqtb[cat_code_base];
eqtb[auto_xspacing_code]:=eqtb[cat_code_base];
eqtb[enable_cjk_token_code]:=eqtb[cat_code_base];
for k:=0 to 255 do
  begin cat_code(k):=other_char;
  math_code(k):=hi(k); sf_code(k):=1000;
  auto_xsp_code(k):=0;
  end;
for k:=0 to number_usvs-1 do
  begin cat_code(k):=other_char; cjkx_code(k):=0;
  end;
for k:=0 to 1023 do
  begin inhibit_xsp_code(k):=0; inhibit_xsp_type(k):=0;
  kinsoku_code(k):=0; kinsoku_type(k):=0;
  end;
@z

@x
for k:="0" to "9" do math_code(k):=hi(k+var_code);
for k:="A" to "Z" do
  begin cat_code(k):=letter; cat_code(k+"a"-"A"):=letter;@/
  math_code(k):=hi(k+var_code+@"100);
  math_code(k+"a"-"A"):=hi(k+"a"-"A"+var_code+@"100);@/
  lc_code(k):=k+"a"-"A"; lc_code(k+"a"-"A"):=k+"a"-"A";@/
  uc_code(k):=k; uc_code(k+"a"-"A"):=k;@/
  sf_code(k):=999;
  end;
@y
for k:="0" to "9" do
  begin math_code(k):=hi(k+var_code);
  auto_xsp_code(k):=3;
  end;
kansuji_char(0):=toDVI(fromJIS(@"213B));
kansuji_char(1):=toDVI(fromJIS(@"306C));
kansuji_char(2):=toDVI(fromJIS(@"4673));
kansuji_char(3):=toDVI(fromJIS(@"3B30));
kansuji_char(4):=toDVI(fromJIS(@"3B4D));
kansuji_char(5):=toDVI(fromJIS(@"385E));
kansuji_char(6):=toDVI(fromJIS(@"4F3B));
kansuji_char(7):=toDVI(fromJIS(@"3C37));
kansuji_char(8):=toDVI(fromJIS(@"482C));
kansuji_char(9):=toDVI(fromJIS(@"3665));
for k:="A" to "Z" do
  begin cat_code(k):=letter; cat_code(k+"a"-"A"):=letter;@/
  math_code(k):=hi(k+var_code+@"100);
  math_code(k+"a"-"A"):=hi(k+"a"-"A"+var_code+@"100);@/
  lc_code(k):=k+"a"-"A"; lc_code(k+"a"-"A"):=k+"a"-"A";@/
  uc_code(k):=k; uc_code(k+"a"-"A"):=k;@/
  auto_xsp_code(k):=3; auto_xsp_code(k+"a"-"A"):=3;@/
  sf_code(k):=999;
  end;
{ |cjkx_code| init }
for k:=@"80 to @"A9 do begin cat_code(k):=other_char; cjkx_code(k):=1; end;
for k:=@"AB to @"B9 do begin cat_code(k):=other_char; cjkx_code(k):=1; end;
for k:=@"BB to @"BF do begin cat_code(k):=other_char; cjkx_code(k):=1; end;
for k:=@"250 to @"10FF do begin cat_code(k):=other_char; cjkx_code(k):=1; end;
for k:=@"1100 to @"11FF do begin cat_code(k):=letter; cjkx_code(k):=3; end;
for k:=@"1200 to @"1DFF do begin cat_code(k):=other_char; cjkx_code(k):=1; end;
for k:=@"1F00 to @"2E7F do begin cat_code(k):=other_char; cjkx_code(k):=1; end;
for k:=@"2E80 to @"2FEF do begin cat_code(k):=letter; cjkx_code(k):=1; end;
for k:=@"2FF0 to @"303F do begin cat_code(k):=other_char; cjkx_code(k):=1; end;
for k:=@"3040 to @"30FF do begin cat_code(k):=letter; cjkx_code(k):=2; end;
for k:=@"3100 to @"312F do begin cat_code(k):=letter; cjkx_code(k):=1; end;
for k:=@"3130 to @"318F do begin cat_code(k):=letter; cjkx_code(k):=3; end;
for k:=@"3190 to @"31EF do begin cat_code(k):=letter; cjkx_code(k):=1; end;
for k:=@"31F0 to @"31FF do begin cat_code(k):=letter; cjkx_code(k):=2; end;
for k:=@"3200 to @"33FF do begin cat_code(k):=other_char; cjkx_code(k):=1; end;
for k:=@"3400 to @"4DBF do begin cat_code(k):=letter; cjkx_code(k):=1; end;
for k:=@"4DC0 to @"4DFF do begin cat_code(k):=other_char; cjkx_code(k):=1; end;
for k:=@"4E00 to @"9FFF do begin cat_code(k):=letter; cjkx_code(k):=1; end;
for k:=@"A000 to @"A95F do begin cat_code(k):=other_char; cjkx_code(k):=1; end;
for k:=@"A960 to @"A97F do begin cat_code(k):=letter; cjkx_code(k):=3; end;
for k:=@"A980 to @"ABFF do begin cat_code(k):=other_char; cjkx_code(k):=1; end;
for k:=@"AC00 to @"D7FF do begin cat_code(k):=letter; cjkx_code(k):=3; end;
for k:=@"D800 to @"F8FF do begin cat_code(k):=other_char; cjkx_code(k):=1; end;
for k:=@"F900 to @"FAFF do begin cat_code(k):=letter; cjkx_code(k):=1; end;
for k:=@"FB00 to @"FF0F do begin cat_code(k):=other_char; cjkx_code(k):=1; end;
for k:=@"FF10 to @"FF19 do begin cat_code(k):=letter; cjkx_code(k):=2; end;
for k:=@"FF1A to @"FF20 do begin cat_code(k):=other_char; cjkx_code(k):=1; end;
for k:=@"FF21 to @"FF3A do begin cat_code(k):=letter; cjkx_code(k):=2; end;
for k:=@"FF3B to @"FF40 do begin cat_code(k):=other_char; cjkx_code(k):=1; end;
for k:=@"FF41 to @"FF5A do begin cat_code(k):=letter; cjkx_code(k):=2; end;
for k:=@"FF5B to @"FF65 do begin cat_code(k):=other_char; cjkx_code(k):=1; end;
for k:=@"FF66 to @"FF6F do begin cat_code(k):=letter; cjkx_code(k):=2; end;
for k:=@"FF71 to @"FF9D do begin cat_code(k):=letter; cjkx_code(k):=2; end;
for k:=@"FF9E to @"1AFEF do begin cat_code(k):=other_char; cjkx_code(k):=1; end;
for k:=@"1AFF0 to @"1B16F do begin cat_code(k):=letter; cjkx_code(k):=2; end;
for k:=@"1B170 to @"1FFFF do begin cat_code(k):=other_char; cjkx_code(k):=1; end;
for k:=@"20000 to @"323AF do begin cat_code(k):=letter; cjkx_code(k):=1; end;
for k:=@"323B0 to @"10FFFF do begin cat_code(k):=other_char; cjkx_code(k):=1; end;
cat_code(@"D7):=other_char; cjkx_code(@"D7):=1;
cat_code(@"F7):=other_char; cjkx_code(@"F7):=1;
cat_code(@"FF70):=other_char; cjkx_code(@"FF70):=1;
@z

@x
begin if n=cur_font_loc then print("current font")
else if n<math_font_base+16 then
  begin print_esc("textfont"); print_int(n-math_font_base);
  end
else if n<math_font_base+32 then
  begin print_esc("scriptfont"); print_int(n-math_font_base-16);
  end
else  begin print_esc("scriptscriptfont"); print_int(n-math_font_base-32);
@y
begin if n=cur_font_loc then print("current font")
else if n<math_font_base+script_size then
  begin print_esc("textfont"); print_int(n-math_font_base);
  end
else if n<math_font_base+script_script_size then
  begin print_esc("scriptfont"); print_int(n-math_font_base-script_size);
  end
else  begin print_esc("scriptscriptfont");
  print_int(n-math_font_base-script_script_size);
@z

@x
@ @<Show the halfword code in |eqtb[n]|@>=
if n<math_code_base then
  begin if n<lc_code_base then
    begin print_esc("catcode"); print_int(n-cat_code_base);
    end
@y
@ @<Show the halfword code in |eqtb[n]|@>=
if n<math_code_base then
  begin if n<cjkx_code_base then
    begin print_esc("catcode"); print_int(n-cat_code_base);
    end
  else if n<auto_xsp_code_base then
    begin print_esc("cjkxcode"); print_int(n-cjkx_code_base);
    end
  else if n<inhibit_xsp_code_base then
    begin print_esc("xspcode"); print_int(n-auto_xsp_code_base);
    end
  else if n<kinsoku_base then
    begin print("inhibitxspcode table "); print_int(n-inhibit_xsp_code_base);
      print(", type=");
      case eq_type(n) of
        0: print("both");   { |inhibit_both| }
        1: print("before"); { |inhibit_previous| }
        2: print("after");  { |inhibit_after| }
        3: print("none");   { |inhibit_none| }
        4: print("unused"); { |inhibit_unused| }
      end; {there are no other cases}
      print(", code");
    end
  else if n<kansuji_base then
    begin print("kinsoku table "); print_int(n-kinsoku_base);
      print(", type=");
      case eq_type(n) of
        0: print("no");
        1: print("pre");    { |pre_break_penalty_code| }
        2: print("post");   { |post_break_penalty_code| }
        3: print("unused"); { |kinsoku_unused_code| }
      end; {there are no other cases}
      print(", code");
    end
  else if n<lc_code_base then
    begin print_esc("kansujichar"); print_int(n-kansuji_base);
    end
@z

@x
@d cur_fam_code=44 {current family}
@d escape_char_code=45 {escape character for token output}
@d default_hyphen_char_code=46 {value of \.{\\hyphenchar} when a font is loaded}
@d default_skew_char_code=47 {value of \.{\\skewchar} when a font is loaded}
@d end_line_char_code=48 {character placed at the right end of the buffer}
@d new_line_char_code=49 {character that prints as |print_ln|}
@d language_code=50 {current hyphenation table}
@d left_hyphen_min_code=51 {minimum left hyphenation fragment size}
@d right_hyphen_min_code=52 {minimum right hyphenation fragment size}
@d holding_inserts_code=53 {do not remove insertion nodes from \.{\\box255}}
@d error_context_lines_code=54 {maximum intermediate line pairs shown}
@d tex_int_pars=55 {total number of \TeX's integer parameters}
@y
@d cur_fam_code=44 {current family}
@d cur_jfam_code=45 {current kanji family}
@d escape_char_code=46 {escape character for token output}
@d default_hyphen_char_code=47 {value of \.{\\hyphenchar} when a font is loaded}
@d default_skew_char_code=48 {value of \.{\\skewchar} when a font is loaded}
@d end_line_char_code=49 {character placed at the right end of the buffer}
@d new_line_char_code=50 {character that prints as |print_ln|}
@d language_code=51 {current hyphenation table}
@d left_hyphen_min_code=52 {minimum left hyphenation fragment size}
@d right_hyphen_min_code=53 {minimum right hyphenation fragment size}
@d holding_inserts_code=54 {do not remove insertion nodes from \.{\\box255}}
@d error_context_lines_code=55 {maximum intermediate line pairs shown}
@d jchr_widow_penalty_code=56
            {penalty for creating a widow KANJI character line}
@d text_baseline_shift_factor_code=57
@d script_baseline_shift_factor_code=58
@d scriptscript_baseline_shift_factor_code=59
@d ptex_lineend_code=60
@d ptex_tracing_fonts_code=61
@d tex_int_pars=62 {total number of \TeX's integer parameters}
@z

@x
@d int_pars=web2c_int_pars {total number of integer parameters}
@#
@d etex_int_base=tex_int_pars {base for \eTeX's integer parameters}
@y
@d etex_int_base=web2c_int_pars {base for \eTeX's integer parameters}
@z

@x
@d saving_hyph_codes_code=etex_int_base+8 {save hyphenation codes for languages}
@d eTeX_state_code=etex_int_base+9 {\eTeX\ state variables}
@y
@d saving_hyph_codes_code=etex_int_base+8 {save hyphenation codes for languages}
@d read_papersize_special_code=etex_int_base+9
@d suppress_long_error_code=etex_int_base+10
@d suppress_outer_error_code=etex_int_base+11
@d suppress_mathpar_error_code=etex_int_base+12
@d eTeX_state_code=etex_int_base+13 {\eTeX\ state variables}
@z

@x
@d del_code(#)==eqtb[del_code_base+#].int
@y
@d del_code(#)==eqtb[del_code_base+#].int
@d del_code1(#)==getintone(eqtb[del_code_base+#])
@z

@x
@d cur_fam==int_par(cur_fam_code)
@d escape_char==int_par(escape_char_code)
@y
@d cur_fam==int_par(cur_fam_code)
@d cur_jfam==int_par(cur_jfam_code)
@d escape_char==int_par(escape_char_code)
@d jchr_widow_penalty==int_par(jchr_widow_penalty_code)
@d text_baseline_shift_factor==int_par(text_baseline_shift_factor_code)
@d script_baseline_shift_factor==int_par(script_baseline_shift_factor_code)
@d scriptscript_baseline_shift_factor==int_par(scriptscript_baseline_shift_factor_code)
@d ptex_lineend==int_par(ptex_lineend_code)
@d ptex_tracing_fonts==int_par(ptex_tracing_fonts_code)
@z

@x
@d saving_hyph_codes==int_par(saving_hyph_codes_code)
@y
@d saving_hyph_codes==int_par(saving_hyph_codes_code)
@d read_papersize_special==int_par(read_papersize_special_code)
@d suppress_long_error==int_par(suppress_long_error_code)
@d suppress_outer_error==int_par(suppress_outer_error_code)
@d suppress_mathpar_error==int_par(suppress_mathpar_error_code)
@z

@x
new_line_char_code:print_esc("newlinechar");
@y
new_line_char_code:print_esc("newlinechar");
cur_jfam_code:print_esc("jfam");
jchr_widow_penalty_code:print_esc("jcharwidowpenalty");
text_baseline_shift_factor_code:print_esc("textbaselineshiftfactor");
script_baseline_shift_factor_code:print_esc("scriptbaselineshiftfactor");
scriptscript_baseline_shift_factor_code:print_esc("scriptscriptbaselineshiftfactor");
ptex_lineend_code:print_esc("ptexlineendmode");
ptex_tracing_fonts_code:print_esc("ptextracingfonts");
@z

@x
primitive("newlinechar",assign_int,int_base+new_line_char_code);@/
@!@:new_line_char_}{\.{\\newlinechar} primitive@>
@y
primitive("newlinechar",assign_int,int_base+new_line_char_code);@/
@!@:new_line_char_}{\.{\\newlinechar} primitive@>
primitive("jfam",assign_int,int_base+cur_jfam_code);@/
@!@:cur_jfam_}{\.{\\jfam} primitive@>
primitive("jcharwidowpenalty",assign_int,int_base+jchr_widow_penalty_code);@/
@!@:jchr_widow_penalty}{\.{\\jcharwidowpenalty} primitive@>
primitive("textbaselineshiftfactor",assign_int,int_base+text_baseline_shift_factor_code);@/
@!@:text_baseline_shift_factor}{\.{\\textbaselineshiftfactor} primitive@>
primitive("scriptbaselineshiftfactor",assign_int,int_base+script_baseline_shift_factor_code);@/
@!@:script_baseline_shift_factor}{\.{\\scriptbaselineshiftfactor} primitive@>
primitive("scriptscriptbaselineshiftfactor",assign_int,int_base+scriptscript_baseline_shift_factor_code);@/
@!@:scriptscript_baseline_shift_factor}{\.{\\scriptscriptbaselineshiftfactor} primitive@>
primitive("ptexlineendmode",assign_int,int_base+ptex_lineend_code);@/
@!@:ptex_lineend_mode_}{\.{\\ptexlineendmode} primitive@>
primitive("ptextracingfonts",assign_int,int_base+ptex_tracing_fonts_code);@/
@!@:ptex_tracing_fonts_}{\.{\\ptextracingfonts} primitive@>
@z

@x
for k:=0 to 255 do del_code(k):=-1;
del_code("."):=0; {this null delimiter is used in error recovery}
@y
for k:=0 to 255 do
  begin del_code(k):=-1; setintone(eqtb[del_code_base+k],-1);
  end;
del_code("."):=0; setintone(eqtb[del_code_base+"."],0);
      {this null delimiter is used in error recovery}
@z

@x
@d h_offset_code=18 {amount of horizontal offset when shipping pages out}
@d v_offset_code=19 {amount of vertical offset when shipping pages out}
@d emergency_stretch_code=20 {reduces badnesses on final pass of line-breaking}
@d dimen_pars=21 {total number of dimension parameters}
@d scaled_base=dimen_base+dimen_pars
  {table of 256 user-defined \.{\\dimen} registers}
@d eqtb_size=scaled_base+255 {largest subscript of |eqtb|}
@y
@d h_offset_code=18 {amount of horizontal offset when shipping pages out}
@d v_offset_code=19 {amount of vertical offset when shipping pages out}
@d emergency_stretch_code=20 {reduces badnesses on final pass of line-breaking}
@d t_baseline_shift_code=21 {shift amount when mixing TATE-kumi and Alphabet}
@d y_baseline_shift_code=22 {shift amount when mixing YOKO-kumi and Alphabet}
@d pdf_page_width_code=23  {page width}
@d pdf_page_height_code=24 {page height}
@d dimen_pars=25 {total number of dimension parameters}
@d scaled_base=dimen_base+dimen_pars
  {table of 256 user-defined \.{\\dimen} registers}
@d kinsoku_penalty_base=scaled_base+256 {table of 256 kinsoku registers}
@d eqtb_size=kinsoku_penalty_base+255 {largest subscript of |eqtb|}
@z

@x
@d dimen(#)==eqtb[scaled_base+#].sc
@d dimen_par(#)==eqtb[dimen_base+#].sc {a scaled quantity}
@y
@d dimen(#)==eqtb[scaled_base+#].sc
@d dimen_par(#)==eqtb[dimen_base+#].sc {a scaled quantity}
@d kinsoku_penalty(#)==eqtb[kinsoku_penalty_base+#].int
@z

@x
@d h_offset==dimen_par(h_offset_code)
@d v_offset==dimen_par(v_offset_code)
@y
@d h_offset==dimen_par(h_offset_code)
@d v_offset==dimen_par(v_offset_code)
@d t_baseline_shift==dimen_par(t_baseline_shift_code)
@d y_baseline_shift==dimen_par(y_baseline_shift_code)
@z

@x
@d emergency_stretch==dimen_par(emergency_stretch_code)
@y
@d emergency_stretch==dimen_par(emergency_stretch_code)
@d pdf_page_width==dimen_par(pdf_page_width_code)
@d pdf_page_height==dimen_par(pdf_page_height_code)
@z

@x
h_offset_code:print_esc("hoffset");
v_offset_code:print_esc("voffset");
emergency_stretch_code:print_esc("emergencystretch");
othercases print("[unknown dimen parameter!]")
@y
h_offset_code:print_esc("hoffset");
v_offset_code:print_esc("voffset");
t_baseline_shift_code:print_esc("tbaselineshift");
y_baseline_shift_code:print_esc("ybaselineshift");
emergency_stretch_code:print_esc("emergencystretch");
pdf_page_width_code:    print_esc("pdfpagewidth");
pdf_page_height_code:   print_esc("pdfpageheight");
othercases print("[unknown dimen parameter!]")
@z

@x
primitive("hoffset",assign_dimen,dimen_base+h_offset_code);@/
@!@:h_offset_}{\.{\\hoffset} primitive@>
primitive("voffset",assign_dimen,dimen_base+v_offset_code);@/
@!@:v_offset_}{\.{\\voffset} primitive@>
@y
primitive("hoffset",assign_dimen,dimen_base+h_offset_code);@/
@!@:h_offset_}{\.{\\hoffset} primitive@>
primitive("voffset",assign_dimen,dimen_base+v_offset_code);@/
@!@:v_offset_}{\.{\\voffset} primitive@>
primitive("tbaselineshift",assign_dimen,dimen_base+t_baseline_shift_code);@/
@!@:t_baseline_shift_}{\.{\\tbaselineshift} primitive@>
primitive("ybaselineshift",assign_dimen,dimen_base+y_baseline_shift_code);@/
@!@:y_baseline_shift_}{\.{\\ybaselineshift} primitive@>
@z

@x
else if n<=eqtb_size then @<Show equivalent |n|, in region 6@>
else print_char("?"); {this can't happen either}
end;
tats
@y
else if n<kinsoku_penalty_base then @<Show equivalent |n|, in region 6@>
else if n<=eqtb_size then begin
  print("kinsoku table "); print_int(n-kinsoku_penalty_base);
  print(", penalty="); print_int(eqtb[n].int);
  end
else print_char("?"); {this can't happen either}
end;
tats
@z

@x
@!cs_count:integer; {total number of known identifiers}
@y
@!cs_count:integer; {total number of known identifiers}

@ Primitive support needs a few extra variables and definitions

@d prim_prime=1777 {about 85\pct! of |primitive_size|}
@d prim_base=1
@d prim_next(#) == prim[#].lh {link for coalesced lists}
@d prim_text(#) == prim[#].rh {string number for control sequence name, plus one}
@d prim_is_full == (prim_used=prim_base) {test if all positions are occupied}
@d prim_eq_level_field(#)==#.hh.b1
@d prim_eq_type_field(#)==#.hh.b0
@d prim_equiv_field(#)==#.hh.rh
@d prim_eq_level(#)==prim_eq_level_field(eqtb[prim_eqtb_base+#]) {level of definition}
@d prim_eq_type(#)==prim_eq_type_field(eqtb[prim_eqtb_base+#]) {command code for equivalent}
@d prim_equiv(#)==prim_equiv_field(eqtb[prim_eqtb_base+#]) {equivalent value}
@d undefined_primitive=0
@d biggest_char=255 { 65535 in XeTeX }

@<Glob...@>=
@!prim: array [0..prim_size] of two_halves;  {the primitives table}
@!prim_used:pointer; {allocation pointer for |prim|}
@z

@x
@ @<Set init...@>=
no_new_control_sequence:=true; {new identifiers are usually forbidden}
@y
@ @<Set init...@>=
no_new_control_sequence:=true; {new identifiers are usually forbidden}
prim_next(0):=0; prim_text(0):=0;
for k:=1 to prim_size do prim[k]:=prim[0];
@z

@x
text(frozen_dont_expand):="notexpanded:";
@.notexpanded:@>
@y
prim_used:=prim_size; {nothing is used}
text(frozen_dont_expand):="notexpanded:";
@.notexpanded:@>
eq_type(frozen_primitive):=ignore_spaces;
equiv(frozen_primitive):=1;
eq_level(frozen_primitive):=level_one;
text(frozen_primitive):="pdfprimitive";
@z

@x
for k:=j to j+l-1 do append_char(buffer[k]);
@y
for k:=j to j+l-1 do append_char(buffer2[k]*@"100+buffer[k]);
@z

@x
@ Single-character control sequences do not need to be looked up in a hash
table, since we can use the character code itself as a direct address.
@y
@ Here is the subroutine that searches the primitive table for an identifier

@p function prim_lookup(@!s:str_number):pointer; {search the primitives table}
label found; {go here if you found it}
var h:integer; {hash code}
@!p:pointer; {index in |hash| array}
@!k:pointer; {index in string pool}
@!j,@!l:integer;
begin
if s<=biggest_char then begin
  if s<0 then begin p:=undefined_primitive; goto found; end
  else p:=(s mod prim_prime)+prim_base; {we start searching here}
  l:=1
  end
else begin
  j:=str_start[s];
  if s = str_ptr then l := cur_length else l := length(s);
  @<Compute the primitive code |h|@>;
  p:=h+prim_base; {we start searching here; note that |0<=h<prim_prime|}
  end;
loop@+begin
  if prim_text(p)>1+biggest_char then { |p| points a multi-letter primitive }
    begin if length(prim_text(p)-1)=l then
      if str_eq_str(prim_text(p)-1,s) then goto found;
    end
  else if prim_text(p)=1+s then goto found; { |p| points a single-letter primitive }
  if prim_next(p)=0 then
    begin if no_new_control_sequence then
      p:=undefined_primitive
    else @<Insert a new primitive after |p|, then make
      |p| point to it@>;
    goto found;
    end;
  p:=prim_next(p);
  end;
found: prim_lookup:=p;
end;

@ @<Insert a new primitive...@>=
begin if prim_text(p)>0 then
  begin repeat if prim_is_full then overflow("primitive size",prim_size);
@:TeX capacity exceeded primitive size}{\quad primitive size@>
  decr(prim_used);
  until prim_text(prim_used)=0; {search for an empty location in |prim|}
  prim_next(p):=prim_used; p:=prim_used;
  end;
prim_text(p):=s+1;
end

@ The value of |prim_prime| should be roughly 85\pct! of
|prim_size|, and it should be a prime number.

@<Compute the primitive code |h|@>=
h:=str_pool[j];
for k:=j+1 to j+l-1 do
  begin h:=h+h+str_pool[k];
  while h>=prim_prime do h:=h-prim_prime;
  end

@ Single-character control sequences do not need to be looked up in a hash
table, since we can use the character code itself as a direct address.
@z

@x
procedure print_cs(@!p:integer); {prints a purported control sequence}
@y
procedure print_cs(@!p:integer); {prints a purported control sequence}
var j, l:pool_pointer; @!cat:0..max_char_code;
@z

@x
else  begin print_esc(text(p));
  print_char(" ");
  end;
@y
else  begin
  if (p>=prim_eqtb_base)and(p<frozen_null_font) then
    l:=prim_text(p-prim_eqtb_base)-1 else l:=text(p);
  print_esc(l); j:=str_start[l]; l:=str_start[l+1];
  if l>j+1 then begin
    if (str_pool[j]>=@"100)and(l-j=multistrlenshort(str_pool, l, j)) then
      begin cat:=cjkx_code(fromBUFFshort(str_pool, l, j));
      if (cat<>other_kchar) then print_char(" ");
      end
    else print_char(" "); end
  else print_char(" ");
  end;
@z

@x
else print_esc(text(p));
@y
else if (p>=prim_eqtb_base)and(p<frozen_null_font) then
    print_esc(prim_text(p-prim_eqtb_base)-1)
else print_esc(text(p));
@z

@x
@p @!init procedure primitive(@!s:str_number;@!c:quarterword;@!o:halfword);
var k:pool_pointer; {index into |str_pool|}
@y
@p @!init procedure primitive(@!s:str_number;@!c:quarterword;@!o:halfword);
var k:pool_pointer; {index into |str_pool|}
@!prim_val:integer; {needed to fill |prim_eqtb|}
@z

@x
begin if s<256 then cur_val:=s+single_base
@y
begin if s<256 then begin
  cur_val:=s+single_base;
  prim_val:=prim_lookup(s);
end
@z

@x
  for j:=0 to l-1 do buffer[first+j]:=so(str_pool[k+j]);
@y
  for j:=0 to l-1 do begin
    buffer[first+j]:=Lo(so(str_pool[k+j])); buffer2[first+j]:=Hi(so(str_pool[k+j])); end;
@z

@x
  flush_string; text(cur_val):=s; {we don't want to have the string twice}
  end;
eq_level(cur_val):=level_one; eq_type(cur_val):=c; equiv(cur_val):=o;
end;
tini
@y
  flush_string; text(cur_val):=s; {we don't want to have the string twice}
  prim_val:=prim_lookup(s);
  end;
eq_level(cur_val):=level_one; eq_type(cur_val):=c; equiv(cur_val):=o;
prim_eq_level(prim_val):=level_one;
prim_eq_type(prim_val):=c;
prim_equiv(prim_val):=o;
end;
tini
@z

@x
primitive("char",char_num,0);@/
@!@:char_}{\.{\\char} primitive@>
@y
primitive("char",char_num,0);@/
@!@:char_}{\.{\\char} primitive@>
primitive("kchar",kchar_num,0);@/
@!@:kchar_}{\.{\\kchar} primitive@>
@z

@x
primitive("delimiter",delim_num,0);@/
@!@:delimiter_}{\.{\\delimiter} primitive@>
@y
primitive("delimiter",delim_num,0);@/
@!@:delimiter_}{\.{\\delimiter} primitive@>
primitive("odelimiter",delim_num,1);@/
@!@:delimiter_}{\.{\\odelimiter} primitive@>
@z

@x
primitive("font",def_font,0);@/
@!@:font_}{\.{\\font} primitive@>
@y
primitive("font",def_font,0);@/
@!@:font_}{\.{\\font} primitive@>
primitive("jfont",def_jfont,0);@/
@!@:jfont_}{\.{\\jfont} primitive@>
primitive("tfont",def_tfont,0);@/
@!@:tfont_}{\.{\\tfont} primitive@>
@z

@x
primitive("mathaccent",math_accent,0);@/
@!@:math_accent_}{\.{\\mathaccent} primitive@>
primitive("mathchar",math_char_num,0);@/
@!@:math_char_}{\.{\\mathchar} primitive@>
@y
primitive("mathaccent",math_accent,0);@/
@!@:math_accent_}{\.{\\mathaccent} primitive@>
primitive("mathchar",math_char_num,0);@/
@!@:math_char_}{\.{\\mathchar} primitive@>
primitive("omathaccent",math_accent,1);@/
@!@:math_accent_}{\.{\\omathaccent} primitive@>
primitive("omathchar",math_char_num,1);@/
@!@:math_char_}{\.{\\omathchar} primitive@>
@z

@x
primitive("radical",radical,0);@/
@!@:radical_}{\.{\\radical} primitive@>
@y
primitive("radical",radical,0);@/
@!@:radical_}{\.{\\radical} primitive@>
primitive("oradical",radical,1);@/
@!@:radical_}{\.{\\oradical} primitive@>
@z

@x
primitive("relax",relax,256); {cf.\ |scan_file_name|}
@y
primitive("relax",relax,max_char_val); {cf.\ |scan_file_name|}
@z

@x
char_num: print_esc("char");
@y
char_num: print_esc("char");
kchar_num: print_esc("kchar");
@z

@x
def_font: print_esc("font");
@y
def_font: print_esc("font");
def_jfont: print_esc("jfont");
def_tfont: print_esc("tfont");
@z

@x
delim_num: print_esc("delimiter");
@y
delim_num: if chr_code=0 then print_esc("delimiter")
  else print_esc("odelimiter");
@z

@x
ignore_spaces: print_esc("ignorespaces");
@y
ignore_spaces: if chr_code=0 then print_esc("ignorespaces") else print_esc("pdfprimitive");
@z

@x
math_accent: print_esc("mathaccent");
math_char_num: print_esc("mathchar");
@y
math_accent: if chr_code=0 then print_esc("mathaccent")
  else print_esc("omathaccent");
math_char_num: if chr_code=0 then print_esc("mathchar")
  else print_esc("omathchar");
@z

@x
no_expand: print_esc("noexpand");
@y
no_expand: if chr_code=0 then print_esc("noexpand")
   else print_esc("pdfprimitive");
@z

@x
radical: print_esc("radical");
@y
radical: if chr_code=0 then print_esc("radical")
  else print_esc("oradical");
@z

@x
@<Print the font identifier for |font(p)|@>=
print_esc(font_id_text(font(p)))
@y
@<Print the font identifier for |font(p)|@>=
begin
  print_esc(font_id_text(font(p)));
  if ptex_tracing_fonts > 0 then begin
    print(" (");
    print_font_name_and_size(font(p));
  if ptex_tracing_fonts > 1 then begin
    print_font_dir_and_enc(font(p));
  end;
    print(")");
  end;
end;

@ @<Declare the pTeX-specific |print_font_...| procedures@>=
procedure print_font_name_and_size(f:internal_font_number);
begin
  print(font_name[f]);
  if font_size[f]<>font_dsize[f] then begin
    print("@@");
    print_scaled(font_size[f]);
    print("pt");
  end;
end;
@#
procedure print_font_dir_and_enc(f:internal_font_number);
begin
  if font_dir[f]=dir_tate then print("/TATE")
  else if font_dir[f]=dir_yoko then print("/YOKO");
  if font_enc[f]=2 then print("+Unicode")
  else if font_enc[f]=1 then print("+JIS");
end;
@z

@x
@p procedure eq_word_define(@!p:pointer;@!w:integer);
label exit;
begin if eTeX_ex and(eqtb[p].int=w) then
  begin assign_trace(p,"reassigning")@;@/
  return;
  end;
assign_trace(p,"changing")@;@/
if xeq_level[p]<>cur_level then
  begin eq_save(p,xeq_level[p]); xeq_level[p]:=cur_level;
  end;
eqtb[p].int:=w;
assign_trace(p,"into")@;@/
exit:end;
@y
@p procedure eq_word_define(@!p:pointer;@!w:integer);
label exit;
begin if eTeX_ex and(eqtb[p].int=w) then
  begin assign_trace(p,"reassigning")@;@/
  return;
  end;
assign_trace(p,"changing")@;@/
if xeq_level[p]<>cur_level then
  begin eq_save(p,xeq_level[p]); xeq_level[p]:=cur_level;
  end;
eqtb[p].int:=w;
assign_trace(p,"into")@;@/
exit:end;
@#
procedure del_eq_word_define(@!p:pointer;@!w,wone:integer);
label exit;
begin if eTeX_ex and(eqtb[p].int=w)and(getintone(eqtb[p])=wone) then
  begin assign_trace(p,"reassigning")@;@/
  return;
  end;
assign_trace(p,"changing")@;@/
if xeq_level[p]<>cur_level then
  begin eq_save(p,xeq_level[p]); xeq_level[p]:=cur_level;
  end;
eqtb[p].int:=w; setintone(eqtb[p],wone);
assign_trace(p,"into")@;@/
exit:end;
@z

@x
procedure geq_word_define(@!p:pointer;@!w:integer); {global |eq_word_define|}
begin assign_trace(p,"globally changing")@;@/
begin eqtb[p].int:=w; xeq_level[p]:=level_one;
end;
assign_trace(p,"into")@;@/
end;
@y
procedure geq_word_define(@!p:pointer;@!w:integer); {global |eq_word_define|}
begin assign_trace(p,"globally changing")@;@/
begin eqtb[p].int:=w; xeq_level[p]:=level_one;
end;
assign_trace(p,"into")@;@/
end;
@#
procedure del_geq_word_define(@!p:pointer;@!w,wone:integer);
  {global |del_eq_word_define|}
begin assign_trace(p,"globally changing")@;@/
begin eqtb[p].int:=w; setintone(eqtb[p],wone); xeq_level[p]:=level_one;
end;
assign_trace(p,"into")@;@/
end;
@z

@x
@d cs_token_flag==@'7777 {amount added to the |eqtb| location in a
  token that stands for a control sequence; is a multiple of~256, less~1}
@d left_brace_token=@'0400 {$2^8\cdot|left_brace|$}
@d left_brace_limit=@'1000 {$2^8\cdot(|left_brace|+1)$}
@d right_brace_token=@'1000 {$2^8\cdot|right_brace|$}
@d right_brace_limit=@'1400 {$2^8\cdot(|right_brace|+1)$}
@d math_shift_token=@'1400 {$2^8\cdot|math_shift|$}
@d tab_token=@'2000 {$2^8\cdot|tab_mark|$}
@d out_param_token=@'2400 {$2^8\cdot|out_param|$}
@d space_token=@'5040 {$2^8\cdot|spacer|+|" "|$}
@d letter_token=@'5400 {$2^8\cdot|letter|$}
@d other_token=@'6000 {$2^8\cdot|other_char|$}
@d match_token=@'6400 {$2^8\cdot|match|$}
@d end_match_token=@'7000 {$2^8\cdot|end_match|$}
@y
@d cs_token_flag=@"1FFFFFFF {amount added to the |eqtb| location in a
  token that stands for a control sequence; is a multiple of~@@"1000000, less~1}
@d left_brace_token=@"0800000 {$2^{23}\cdot|left_brace|$}
@d left_brace_limit=@"1000000 {$2^{23}\cdot(|left_brace|+1)$}
@d right_brace_token=@"1000000 {$2^{23}\cdot|right_brace|$}
@d right_brace_limit=@"1800000 {$2^{23}\cdot(|right_brace|+1)$}
@d math_shift_token=@"1800000 {$2^{23}\cdot|math_shift|$}
@d tab_token=@"2000000 {$2^{23}\cdot|tab_mark|$}
@d out_param_token=@"2800000 {$2^{23}\cdot|out_param|$}
@d space_token=@"5000020 {$2^{23}\cdot|spacer|+|" "|$}
@d letter_token=@"5800000 {$2^{23}\cdot|letter|$}
@d other_token=@"6000000 {$2^{23}\cdot|other_char|$}
@d match_token=@"6800000 {$2^{23}\cdot|match|$}
@d end_match_token=@"7000000 {$2^{23}\cdot|end_match|$}
@z

@x
@d protected_token=@'7001 {$2^8\cdot|end_match|+1$}
@y
@d protected_token=@"7000001 {$2^{23}\cdot|end_match|+1$}
@z

@x
@ @<Display token |p|...@>=
if (p<hi_mem_min) or (p>mem_end) then
  begin print_esc("CLOBBERED."); return;
@.CLOBBERED@>
  end;
if info(p)>=cs_token_flag then print_cs(info(p)-cs_token_flag)
else  begin m:=info(p) div @'400; c:=info(p) mod @'400;
  if info(p)<0 then print_esc("BAD.")
@.BAD@>
  else @<Display the token $(|m|,|c|)$@>;
  end
@y
@ @<Display token |p|...@>=
if (p<hi_mem_min) or (p>mem_end) then
  begin print_esc("CLOBBERED."); return;
@.CLOBBERED@>
  end;
if info(p)>=cs_token_flag then print_cs(info(p)-cs_token_flag) {|wchar_token|}
else  begin
  m:=info(p) div max_char_val; c:=info(p) mod max_char_val;
  if info(p)<0 then print_esc("BAD.")
@.BAD@>
  else @<Display the token $(|m|,|c|)$@>;
end
@z

@x
@<Display the token ...@>=
case m of
left_brace,right_brace,math_shift,tab_mark,sup_mark,sub_mark,spacer,
  letter,other_char: print(c);
@y
@<Display the token ...@>=
case m of
left_brace,right_brace,math_shift,tab_mark,sup_mark,sub_mark,spacer,
  letter,other_char: print_utf8(c);
kanji,kana,other_kchar,hangul: print_kanji(KANJI(c));
@z

@x
@d chr_cmd(#)==begin print(#); print_ASCII(chr_code);
@y
@d chr_cmd(#)==begin print(#); 
  if chr_code<@"80 then print_ASCII(chr_code)
  else print_utf8(chr_code); 
@z

@x
letter: chr_cmd("the letter ");
other_char: chr_cmd("the character ");
@y
letter: chr_cmd("the letter ");
other_char: chr_cmd("the character ");
kanji,kana,other_kchar: begin
  print("kanji character ");
  if chr_code<@"80 then print_ASCII(chr_code) else print_kanji(KANJI(chr_code));
  end;
@z

@x
1) |state=mid_line| is the normal state.\cr
2) |state=skip_blanks| is like |mid_line|, but blanks are ignored.\cr
3) |state=new_line| is the state at the beginning of a line.\cr}}$$
@y
1) |state=mid_line| is the normal state.\cr
2) |state=mid_kanji| is like |mid_line|, and internal KANJI string.\cr
3) |state=skip_blanks| is like |mid_line|, but blanks are ignored.\cr
4) |state=skip_blanks_kanji| is like |mid_kanji|, but blanks are ignored.\cr
5) |state=new_line| is the state at the beginning of a line.\cr}}$$
@z

@x
ignored; after this case is processed, the next value of |state| will
be |skip_blanks|.
@y
ignored; after this case is processed, the next value of |state| will
be |skip_blanks|.

If \.{\\ptexlineendmode} is odd, the |state| become |skip_blanks_kanji|
after a control word which ends with a Japanese character. This is
similar to |skip_blanks|, but the |state| will be |mid_kanji| after
|skip_blanks_kanji+left_brace| and |skip_blanks_kanji+right_brace|,
instead of |mid_line|.
@z

@x
@d mid_line=1 {|state| code when scanning a line of characters}
@d skip_blanks=2+max_char_code {|state| code when ignoring blanks}
@d new_line=3+max_char_code+max_char_code {|state| code at start of line}
@y
@d mid_line=1 {|state| code when scanning a line of characters}
@d mid_kanji=2+max_char_code {|state| code when scanning a line of characters}
@d skip_blanks=3+max_char_code+max_char_code {|state| code when ignoring blanks}
@d skip_blanks_kanji=4+max_char_code+max_char_code+max_char_code
   {|state| code when ignoring blanks}
@d new_line=5+max_char_code+max_char_code+max_char_code+max_char_code
   {|state| code at start of line}
@z

@x
@d every_eof_text=every_eof_loc-eTeX_text_offset
  {|token_type| code for \.{\\everyeof}}
@y
@d every_eof_text=every_eof_loc-eTeX_text_offset
  {|token_type| code for \.{\\everyeof}}
@#
@d node_recipe_text=node_recipe_loc-eTeX_text_offset
  {|token_type| code for \.{\\nptexnoderecipe}}
@z

@x
@p procedure show_context; {prints where the scanner is}
label done;
var old_setting:0..max_selector; {saved |selector| setting}
@y
@p procedure show_context; {prints where the scanner is}
label done, done1;
var old_setting:0..max_selector; {saved |selector| setting}
@!s: pointer; {temporary pointer}
@z

@x
every_eof_text: print_nl("<everyeof> ");
@y
every_eof_text: print_nl("<everyeof> ");
node_recipe_text: print_nl("<nptexnoderecipe> ");
@z

@x
@d begin_pseudoprint==
  begin l:=tally; tally:=0; selector:=pseudo;
  trick_count:=1000000;
  end
@y
@d begin_pseudoprint==
  begin l:=tally; tally:=0; selector:=pseudo; kcode_pos:=0;
  trick_count:=1000000;
  end
@z

@x
@d set_trick_count==
  begin first_count:=tally;
  trick_count:=tally+1+error_line-half_error_line;
  if trick_count<error_line then trick_count:=error_line;
  end
@y
@d set_trick_count==
  begin first_count:=tally;
  kcp:=trick_buf2[(first_count-1)mod error_line];
  if (first_count>0)and(kcp>0) then
    first_count:=first_count+nrestmultichr(kcp);
  trick_count:=first_count+1+error_line-half_error_line;
  if trick_count<error_line then trick_count:=error_line;
  end
@z

@x
for q:=p to first_count-1 do print_char(trick_buf[q mod error_line]);
print_ln;
for q:=1 to n do print_char(" "); {print |n| spaces to begin line~2}
if m+n<=error_line then p:=first_count+m else p:=first_count+(error_line-n-3);
@y
kcp:=trick_buf2[p mod error_line];
if (kcp mod @'10)>1 then begin
  p:=p+nrestmultichr(kcp)+1; n:=n-nrestmultichr(kcp)-1; end;
for q:=p to first_count-1 do print_char(trick_buf[q mod error_line]);
print_ln;
for q:=1 to n do print_char(" "); {print |n| spaces to begin line~2}
if m+n<=error_line then p:=first_count+m else p:=first_count+(error_line-n-3);
kcp:=trick_buf2[(p-1) mod error_line];
if ((kcp mod @'10)>0)and(nrestmultichr(kcp)>0) then p:=p-(kcp mod @'10);
@z

@x
if j>0 then for i:=start to j-1 do
  begin if i=loc then set_trick_count;
  print(buffer[i]);
  end
@y
if j>0 then begin
  i:=start;
  if (loc<=j-1)and(start<=loc) then begin
    for i:=start to loc-1 do
      if buffer2[i]>0 then
        print_char(@"100*buffer2[i]+buffer[i]) else print(buffer[i]);
        set_trick_count; print_unread_buffer_with_ptenc(loc,j);
    end
  else
    for i:=start to j-1 do
      if buffer2[i]>0 then
        print_char(@"100*buffer2[i]+buffer[i]) else print(buffer[i]);
  end
@z

@x
@ @<Pseudoprint the token list@>=
begin_pseudoprint;
if token_type<macro then show_token_list(start,loc,100000)
else show_token_list(link(start),loc,100000) {avoid reference count}
@y
@ @<Pseudoprint the token list@>=
begin_pseudoprint;
if token_type<macro then
  begin  if (token_type=backed_up)and(loc<>null) then
    begin  if (link(start)=null)and(check_kanji(info(start))) then {|wchar_token|}
      begin cur_input:=input_stack[base_ptr-1];
      s:=get_avail; info(s):=(info(loc) mod max_char_val);
      cur_input:=input_stack[base_ptr];
      link(start):=s;
      show_token_list(start,loc,100000);
      free_avail(s);link(start):=null;
      goto done1;
      end;
    end;
  show_token_list(start,loc,100000);
  end
else show_token_list(link(start),loc,100000); {avoid reference count}
done1:
@z

@x
first:=buf_size; repeat buffer[first]:=0; decr(first); until first=0;
@y
first:=buf_size; repeat buffer[first]:=0; buffer2[first]:=0; decr(first); until first=0;
@z

@x
primitive("par",par_end,256); {cf.\ |scan_file_name|}
@y
primitive("par",par_end,max_char_val); {cf.\ |scan_file_name|}
@z

@x
@p procedure check_outer_validity;
var p:pointer; {points to inserted token list}
@!q:pointer; {auxiliary pointer}
begin if scanner_status<>normal then
@y
@p procedure check_outer_validity;
var p:pointer; {points to inserted token list}
@!q:pointer; {auxiliary pointer}
begin if suppress_outer_error=0 then if scanner_status<>normal then
@z

@x
@d start_cs=26 {another}
@y
@d start_cs=26 {another}
@d not_exp=27
@z

@x
@!cat:0..max_char_code; {|cat_code(cur_chr)|, usually}
@y
@!cat:escape..max_char_code; {|cat_code(cur_chr)|, usually}
@!l:0..buf_size; {temporary index into |buffer|}
@z

@x
@!d:2..3; {number of excess characters in an expanded code}
@y
@!d:small_number; {number of excess characters in an expanded code}
@!sup_count:small_number;
@!i:integer;
@z

@x
@ @<Input from external file, |goto restart| if no input found@>=
@^inner loop@>
begin switch: if loc<=limit then {current line not yet finished}
  begin cur_chr:=buffer[loc]; incr(loc);
  reswitch: cur_cmd:=cat_code(cur_chr);
@y
@ @<Input from external file, |goto restart| if no input found@>=
@^inner loop@>
begin switch: if loc<=limit then {current line not yet finished}
  begin
    cur_chr:=fromBUFF(ustringcast(buffer), limit+1, loc);
    i:=1;
    reswitch: cur_cmd:=cat_code(cur_chr);
    if (cur_cmd=letter)and(cjkx_code(cur_chr)>0) then
      cur_cmd:=letter+cjkx_code(cur_chr)*cjk_code_flag
    else if (cur_cmd=other_char)and(cjkx_code(cur_chr)>0) then
      cur_cmd:=other_kchar;
    if i>0 then begin
      if cur_cmd>=cjk_code_flag then
        begin for l:=loc to loc-1+multistrlen(ustringcast(buffer), limit+1, loc) do
          buffer2[l]:=1;
        loc:=loc+multistrlen(ustringcast(buffer), limit+1, loc);
        end
      else loc:=loc+multistrlen(ustringcast(buffer), limit+1, loc);
      end;
    i:=0;
@z

@x
@d any_state_plus(#) == mid_line+#,skip_blanks+#,new_line+#
@y
@d any_state_plus(#) ==
  mid_line+#,mid_kanji+#,skip_blanks+#,skip_blanks_kanji+#,new_line+#
@z

@x
@ @<Cases where character is ignored@>=
any_state_plus(ignore),skip_blanks+spacer,new_line+spacer
@y
@ @<Cases where character is ignored@>=
any_state_plus(ignore),skip_blanks+spacer,skip_blanks_kanji+spacer,new_line+spacer
@z

@x
@ @d add_delims_to(#)==#+math_shift,#+tab_mark,#+mac_param,
  #+sub_mark,#+letter,#+other_char
@y
@ @d add_delims_to(#)==#+math_shift,#+tab_mark,#+mac_param,
  #+sub_mark,#+letter,#+other_char
@d all_jcode(#)==#+kanji,#+kana,#+other_kchar
@d hangul_code(#)==#+hangul
@z

@x
mid_line+spacer:@<Enter |skip_blanks| state, emit a space@>;
mid_line+car_ret:@<Finish line, emit a space@>;
skip_blanks+car_ret,any_state_plus(comment):
  @<Finish line, |goto switch|@>;
new_line+car_ret:@<Finish line, emit a \.{\\par}@>;
mid_line+left_brace: incr(align_state);
skip_blanks+left_brace,new_line+left_brace: begin
  state:=mid_line; incr(align_state);
  end;
mid_line+right_brace: decr(align_state);
skip_blanks+right_brace,new_line+right_brace: begin
  state:=mid_line; decr(align_state);
  end;
add_delims_to(skip_blanks),add_delims_to(new_line): state:=mid_line;
@y
mid_kanji+spacer,mid_line+spacer:@<Enter |skip_blanks| state, emit a space@>;
mid_line+car_ret:@<Finish line, emit a space@>;
mid_kanji+car_ret: if skip_mode then @<Finish line, |goto switch|@>
  else @<Finish line, emit a space@>;
skip_blanks+car_ret,skip_blanks_kanji+car_ret,any_state_plus(comment):
  @<Finish line, |goto switch|@>;
new_line+car_ret:@<Finish line, emit a \.{\\par}@>;
mid_line+left_brace: incr(align_state);
mid_kanji+left_brace: begin incr(align_state);
  if ((ptex_lineend div 4) mod 2)=1 then state:=mid_line;
  end;
skip_blanks+left_brace,new_line+left_brace: begin
  state:=mid_line; incr(align_state);
  end;
skip_blanks_kanji+left_brace: begin
  state:=mid_kanji; incr(align_state);
  end;
mid_line+right_brace: decr(align_state);
mid_kanji+right_brace: begin decr(align_state);
  if ((ptex_lineend div 4) mod 2)=1 then state:=mid_line;
  end;
skip_blanks+right_brace,new_line+right_brace: begin
  state:=mid_line; decr(align_state);
  end;
skip_blanks_kanji+right_brace: begin
  state:=mid_kanji; decr(align_state);
  end;
add_delims_to(skip_blanks),add_delims_to(skip_blanks_kanji),
add_delims_to(new_line),add_delims_to(mid_kanji):
  state:=mid_line;
all_jcode(skip_blanks),all_jcode(skip_blanks_kanji),all_jcode(new_line),
all_jcode(mid_line):
  state:=mid_kanji;
hangul_code(skip_blanks),hangul_code(skip_blanks_kanji),hangul_code(new_line),
hangul_code(mid_kanji):
  state:=mid_line;

@ @<Global...@>=
skip_mode:boolean;

@ @<Set init...@>=
skip_mode:=true;
@z

@x
if cur_cmd>=outer_call then check_outer_validity;
@y
if (suppress_outer_error=0)and(cur_cmd>=outer_call) then check_outer_validity;
@z

@x
@<If this |sup_mark| starts an expanded character...@>=
begin if cur_chr=buffer[loc] then if loc<limit then
  begin c:=buffer[loc+1]; @+if c<@'200 then {yes we have an expanded char}
    begin loc:=loc+2; 
    if is_hex(c) then if loc<=limit then
      begin cc:=buffer[loc]; @+if is_hex(cc) then
        begin incr(loc); hex_to_cur_chr; goto reswitch;
        end;
      end;
    if c<@'100 then cur_chr:=c+@'100 @+else cur_chr:=c-@'100;
    goto reswitch;
    end;
  end;
state:=mid_line;
end
@y
@<If this |sup_mark| starts an expanded character...@>=
begin if cur_chr=buffer[loc] then if loc<limit then
  begin sup_count:=2;
  {we have |^^| and another char; check how many |^|s we have altogether, up to a max of 6}
  while (sup_count<6) and (loc+2*sup_count-2<=limit) and (cur_chr=buffer[loc+sup_count-1]) do
    incr(sup_count);
  {check whether we have enough hex chars for the number of |^|s}
  for d:=1 to sup_count do
    if not is_hex(buffer[loc+sup_count-2+d]) then {found a non-hex char, so do single |^^X| style}
      begin c:=buffer[loc+1];
      if c<@'200 then
        begin loc:=loc+2;
        if c<@'100 then cur_chr:=c+@'100 @+else cur_chr:=c-@'100;
        goto reswitch;
        end;
      goto not_exp;
      end;
  {there were the right number of hex chars, so convert them}
  cur_chr:=0;
  for d:=1 to sup_count do
    begin c:=buffer[loc+sup_count-2+d];
    if c<="9" then cur_chr:=16*cur_chr+c-"0"
    else cur_chr:=16*cur_chr+c-"a"+10;
    end;
  {check the resulting value is within the valid range}
  if cur_chr>=number_usvs then
    begin cur_chr:=buffer[loc];
    goto not_exp;
    end;
  loc:=loc+2*sup_count-1;
  goto reswitch;
  end;
not_exp: state:=mid_line;
end
@z

@x
if cur_cmd>=outer_call then check_outer_validity;
@y
if (suppress_outer_error=0)and(cur_cmd>=outer_call) then check_outer_validity;
@z

@x
@<Scan a control...@>=
begin if loc>limit then cur_cs:=null_cs {|state| is irrelevant in this case}
else  begin start_cs: k:=loc; cur_chr:=buffer[k]; cat:=cat_code(cur_chr);
  incr(k);
  if cat=letter then state:=skip_blanks
  else if cat=spacer then state:=skip_blanks
  else state:=mid_line;
  if (cat=letter)and(k<=limit) then
    @<Scan ahead in the buffer until finding a nonletter;
    if an expanded code is encountered, reduce it
    and |goto start_cs|; otherwise if a multiletter control
    sequence is found, adjust |cur_cs| and |loc|, and
    |goto found|@>
  else @<If an expanded code is present, reduce it and |goto start_cs|@>;
  cur_cs:=single_base+buffer[loc]; incr(loc);
  end;
found: cur_cmd:=eq_type(cur_cs); cur_chr:=equiv(cur_cs);
if cur_cmd>=outer_call then check_outer_validity;
end
@y
@<Scan a control...@>=
begin if loc>limit then cur_cs:=null_cs {|state| is irrelevant in this case}
else  begin start_cs: k:=loc;
  cur_chr:=fromBUFF(ustringcast(buffer), limit+1, k);
  cat:=cat_code(cur_chr);
  if (cat=letter)and(cjkx_code(cur_chr)>0) then
    cat:=letter+cjkx_code(cur_chr)*cjk_code_flag
  else if (cat=other_char)and(cjkx_code(cur_chr)>0) then
    cat:=other_kchar;
  if cat>=cjk_code_flag then
    for l:=k to k-1+multistrlen(ustringcast(buffer), limit+1, k) do
      buffer2[l]:=1;
  k:=k+multistrlen(ustringcast(buffer), limit+1, k);
  if (cat=letter)or(cat=hangul) then state:=skip_blanks
  else if (cat=kanji)or(cat=kana) then
    begin if (ptex_lineend mod 2)=0 then state:=skip_blanks_kanji
    else state:=skip_blanks end
  else if cat=spacer then state:=skip_blanks
  else if cat=other_kchar then
    begin if ((ptex_lineend div 2) mod 2)=0 then state:=mid_kanji
    else state:=mid_line end
  else state:=mid_line;
  if ((cat=letter)or(cat=kanji)or(cat=kana)or(cat=hangul))and(k<=limit) then
    @<Scan ahead in the buffer until finding a nonletter;
    if an expanded code is encountered, reduce it
    and |goto start_cs|; otherwise if a multiletter control
    sequence is found, adjust |cur_cs| and |loc|, and
    |goto found|@>
  else @<If an expanded code is present, reduce it and |goto start_cs|@>;
  {single-letter control sequence}
  cur_cs:=single_base+fromBUFF(ustringcast(buffer), limit+1, loc);
  loc:=loc+multistrlen(ustringcast(buffer), limit+1, loc);
  end;
found: cur_cmd:=eq_type(cur_cs); cur_chr:=equiv(cur_cs);
if (suppress_outer_error=0)and(cur_cmd>=outer_call) then check_outer_validity;
end
@z

@x
@<If an expanded...@>=
begin if buffer[k]=cur_chr then @+if cat=sup_mark then @+if k<limit then
  begin c:=buffer[k+1]; @+if c<@'200 then {yes, one is indeed present}
    begin d:=2;
    if is_hex(c) then @+if k+2<=limit then
      begin cc:=buffer[k+2]; @+if is_hex(cc) then incr(d);
      end;
    if d>2 then
      begin hex_to_cur_chr; buffer[k-1]:=cur_chr;
      end
    else if c<@'100 then buffer[k-1]:=c+@'100
    else buffer[k-1]:=c-@'100;
    limit:=limit-d; first:=first-d;
    while k<=limit do
      begin buffer[k]:=buffer[k+d]; incr(k);
      end;
    goto start_cs;
    end;
  end;
end
@y
@<If an expanded...@>=
begin if buffer[k]=cur_chr then @+if cat=sup_mark then @+if k<limit then
  begin sup_count:=2;
  {we have |^^| and another char; check how many |^|s we have altogether, up to a max of 6}
  while (sup_count<6) and (k+2*sup_count-2<=limit) and (buffer[k+sup_count-1]=cur_chr) do
    incr(sup_count);
  {check whether we have enough hex chars for the number of |^|s}
  for d:=1 to sup_count do
    if not is_hex(buffer[k+sup_count-2+d]) then {found a non-hex char, so do single |^^X| style}
      begin c:=buffer[k+1];
      if c<@'200 then
        begin if c<@'100 then buffer[k-1]:=c+@'100 @+else buffer[k-1]:=c-@'100;
        d:=2; limit:=limit-d; buffer2[k-1]:=0;
        while k<=limit do
          begin buffer2[k]:=buffer2[k+d]; buffer[k]:=buffer[k+d]; incr(k);
          end;
        goto start_cs;
        end
      else sup_count:=0;
      end;
  if sup_count>0 then {there were the right number of hex chars, so convert them}
    begin cur_chr:=0;
    for d:=1 to sup_count do
      begin c:=buffer[k+sup_count-2+d];
      if c<="9" then cur_chr:=16*cur_chr+c-"0"
      else cur_chr:=16*cur_chr+c-"a"+10;
      end;
    {check the resulting value is within the valid range}
    if cur_chr>=number_usvs then cur_chr:=buffer[k]
    else  begin
      i:=toBUFF(cur_chr); d:=2*sup_count-1;
      if BYTE1(i)<>0 then begin decr(d); buffer[k-1]:=BYTE1(i); buffer2[k-1]:=0; incr(k); end; 
      if BYTE2(i)<>0 then begin decr(d); buffer[k-1]:=BYTE2(i); buffer2[k-1]:=0; incr(k); end; 
      if BYTE3(i)<>0 then begin decr(d); buffer[k-1]:=BYTE3(i); buffer2[k-1]:=0; incr(k); end; 
                                buffer[k-1]:=BYTE4(i); buffer2[k-1]:=0;
      i:=0;
      {shift the rest of the buffer left by |d| chars}
      limit:=limit-d;
      while k<=limit do
        begin buffer2[k]:=buffer2[k+d]; buffer[k]:=buffer[k+d]; incr(k);
        end;
      goto start_cs;
      end
    end
  end
end
@z

@x
@ @<Scan ahead in the buffer...@>=
begin repeat cur_chr:=buffer[k]; cat:=cat_code(cur_chr); incr(k);
until (cat<>letter)or(k>limit);
@<If an expanded...@>;
if cat<>letter then decr(k);
  {now |k| points to first nonletter}
if k>loc+1 then {multiletter control sequence has been scanned}
  begin cur_cs:=id_lookup(loc,k-loc); loc:=k; goto found;
  end;
end
@y
@ @<Scan ahead in the buffer...@>=
begin repeat
  cur_chr:=fromBUFF(ustringcast(buffer), limit+1, k);
  cat:=cat_code(cur_chr);
  if (cat=letter)and(cjkx_code(cur_chr)>0) then
    cat:=letter+cjkx_code(cur_chr)*cjk_code_flag
  else if (cat=other_char)and(cjkx_code(cur_chr)>0) then
    cat:=other_kchar;
  if cat>=cjk_code_flag then
    for l:=k to k-1+multistrlen(ustringcast(buffer), limit+1, k) do
      buffer2[l]:=1;
  k:=k+multistrlen(ustringcast(buffer), limit+1, k);
  if cat=letter then state:=skip_blanks;
until not((cat=letter)or(cat=kanji)or(cat=kana)or(cat=hangul))or(k>limit);
@<If an expanded...@>;
if not((cat=letter)or(cat=kanji)or(cat=kana)or(cat=hangul)) then decr(k);
if cat=other_kchar then k:=k-multilenbuffchar(cur_chr)+1; {now |k| points to first nonletter}
if k>loc+multistrlen(ustringcast(buffer),limit+1,loc) then {multiletter control sequence has been scanned}
  begin cur_cs:=id_lookup(loc,k-loc); loc:=k; goto found;
  end;
end
@z

@x
@<Input from token list, |goto restart| if end of list or
  if a parameter needs to be expanded@>=
if loc<>null then {list not exhausted}
@^inner loop@>
  begin t:=info(loc); loc:=link(loc); {move to next}
  if t>=cs_token_flag then {a control sequence token}
    begin cur_cs:=t-cs_token_flag;
    cur_cmd:=eq_type(cur_cs); cur_chr:=equiv(cur_cs);
    if cur_cmd>=outer_call then
      if cur_cmd=dont_expand then
        @<Get the next token, suppressing expansion@>
      else check_outer_validity;
    end
  else  begin cur_cmd:=t div @'400; cur_chr:=t mod @'400;
    case cur_cmd of
    left_brace: incr(align_state);
    right_brace: decr(align_state);
    out_param: @<Insert macro parameter and |goto restart|@>;
    othercases do_nothing
    endcases;
    end;
  end
else  begin {we are done with this token list}
  end_token_list; goto restart; {resume previous level}
  end
@y
@<Input from token list, |goto restart| if end of list or
  if a parameter needs to be expanded@>=
if loc<>null then {list not exhausted}
@^inner loop@>
  begin t:=info(loc); loc:=link(loc); {move to next}
  if t>=cs_token_flag then {a control sequence token}
    begin cur_cs:=t-cs_token_flag;
    cur_cmd:=eq_type(cur_cs); cur_chr:=equiv(cur_cs);
    if cur_cmd>=outer_call then
      if cur_cmd=dont_expand then
        @<Get the next token, suppressing expansion@>
      else if suppress_outer_error=0 then check_outer_validity;
    end
  else
    begin cur_cmd:=t div max_char_val; cur_chr:=t mod max_char_val;
    case cur_cmd of
    left_brace: incr(align_state);
    right_brace: decr(align_state);
    out_param: @<Insert macro parameter and |goto restart|@>;
    othercases do_nothing
    endcases;
    end;
  end
else  begin {we are done with this token list}
  end_token_list; goto restart; {resume previous level}
  end
@z

@x
  end_file_reading; {resume previous level}
  check_outer_validity; goto restart;
@y
  end_file_reading; {resume previous level}
  if suppress_outer_error=0 then check_outer_validity; goto restart;
@z

@x
  if start<limit then for k:=start to limit-1 do print(buffer[k]);
  first:=limit; prompt_input("=>"); {wait for user response}
@.=>@>
  if last>first then
    begin for k:=first to last-1 do {move line down in buffer}
      buffer[k+start-first]:=buffer[k];
@y
  if start<limit then for k:=start to limit-1 do
    if buffer2[k]>0 then print_char(buffer[k]) else print(buffer[k]);
  first:=limit; prompt_input("=>"); {wait for user response}
@.=>@>
  if last>first then
    begin for k:=first to last-1 do {move line down in buffer}
      begin buffer[k+start-first]:=buffer[k]; buffer2[k+start-first]:=buffer2[k]; end;
@z

@x
@p procedure get_token; {sets |cur_cmd|, |cur_chr|, |cur_tok|}
begin no_new_control_sequence:=false; get_next; no_new_control_sequence:=true;
@^inner loop@>
if cur_cs=0 then cur_tok:=(cur_cmd*@'400)+cur_chr
else cur_tok:=cs_token_flag+cur_cs;
end;
@y
@p procedure get_token; {sets |cur_cmd|, |cur_chr|, |cur_tok|}
begin no_new_control_sequence:=false; get_next; no_new_control_sequence:=true;
@^inner loop@>
if cur_cs=0 then
  if (cur_cmd>=kanji)and(cur_cmd<=hangul) then {|wchar_token|}
    cur_tok:=(cur_cmd*max_char_val)+cur_chr
  else cur_tok:=(cur_cmd*max_char_val)+cur_chr
else cur_tok:=cs_token_flag+cur_cs;
end;
@z

@x
var t:halfword; {token that is being ``expanded after''}
@!p,@!q,@!r:pointer; {for list manipulation}
@y
var t:halfword; {token that is being ``expanded after''}
@!b:boolean; {keep track of nested csnames}
@!p,@!q,@!r:pointer; {for list manipulation}
@z

@x
@ @<Expand a nonmacro@>=
@y
@ @<Glob...@>=
@!is_in_csname: boolean;

@ @<Set init...@>=
is_in_csname := false;

@ @<Expand a nonmacro@>=
@z

@x
no_expand:@<Suppress expansion of the next token@>;
@y
no_expand: if cur_chr=0 then @<Suppress expansion of the next token@>
  else @<Implement \.{\\pdfprimitive}@>;
@z

@x
@<Suppress expansion...@>=
begin save_scanner_status:=scanner_status; scanner_status:=normal;
get_token; scanner_status:=save_scanner_status; t:=cur_tok;
back_input; {now |start| and |loc| point to the backed-up token |t|}
if (t>=cs_token_flag)and(t<>end_write_token) then
  begin p:=get_avail; info(p):=cs_token_flag+frozen_dont_expand;
  link(p):=loc; start:=p; loc:=p;
  end;
end
@y
@<Suppress expansion...@>=
begin save_scanner_status:=scanner_status; scanner_status:=normal;
get_token; scanner_status:=save_scanner_status; t:=cur_tok;
back_input; {now |start| and |loc| point to the backed-up token |t|}
if (t>=cs_token_flag)and(t<>end_write_token) then
  begin p:=get_avail; info(p):=cs_token_flag+frozen_dont_expand;
  link(p):=loc; start:=p; loc:=p;
  end;
end

@ The \.{\\pdfprimitive} handling. If the primitive meaning of the next
token is an expandable command, it suffices to replace the current
token with the primitive one and restart |expand|/

Otherwise, the token we just read has to be pushed back, as well
as a token matching the internal form of \.{\\pdfprimitive}, that is
sneaked in as an alternate form of |ignore_spaces|.
@!@:pdfprimitive_}{\.{\\pdfprimitive} primitive (internalized)@>

Simply pushing back a token that matches the correct internal command
does not work, because approach would not survive roundtripping to a
temporary file.

@<Implement \.{\\pdfprimitive}@>=
begin save_scanner_status := scanner_status; scanner_status:=normal;
get_token; scanner_status:=save_scanner_status;
if cur_cs < hash_base then
  cur_cs := prim_lookup(cur_cs-single_base)
else
  cur_cs := prim_lookup(text(cur_cs));
if cur_cs<>undefined_primitive then begin
  t := prim_eq_type(cur_cs);
  if t>max_command then begin
    cur_cmd := t;
    cur_chr := prim_equiv(cur_cs);
    cur_tok := (cur_cmd*max_char_val)+cur_chr;
    cur_cs  := 0;
    goto reswitch;
    end
  else begin
    back_input; { now |loc| and |start| point to a one-item list }
    p:=get_avail; info(p):=cs_token_flag+frozen_primitive;
    link(p):=loc; loc:=p; start:=p;
    end;
  end;
end

@ This block deals with unexpandable \.{\\primitive} appearing at a spot where
an integer or an internal values should have been found. It fetches the
next token then resets |cur_cmd|, |cur_cs|, and |cur_tok|, based on the
primitive value of that token. No expansion takes place, because the
next token may be all sorts of things. This could trigger further
expansion creating new errors.

@<Reset |cur_tok| for unexpandable primitives, goto restart @>=
begin
get_token;
if cur_cs < hash_base then
  cur_cs := prim_lookup(cur_cs-single_base)
else
  cur_cs  := prim_lookup(text(cur_cs));
if cur_cs<>undefined_primitive then begin
  cur_cmd := prim_eq_type(cur_cs);
  cur_chr := prim_equiv(cur_cs);
  cur_cs  := prim_eqtb_base+cur_cs;
  cur_tok := cs_token_flag+cur_cs;
  end
else begin
  cur_cmd := relax;
  cur_chr := 0;
  cur_tok := cs_token_flag+frozen_relax;
  cur_cs  := frozen_relax;
  end;
goto restart;
end
@z

@x
@ @<Complain about an undefined macro@>=
begin print_err("Undefined control sequence");
@.Undefined control sequence@>
@y
@ @<Complain about an undefined macro@>=
begin 
print_nl("!!! "); print_int(cur_cmd);
print_err("Undefined control sequence");
@.Undefined control sequence@>
@z


@x
begin r:=get_avail; p:=r; {head of the list of characters}
repeat get_x_token;
@y
begin r:=get_avail; p:=r; {head of the list of characters}
b := is_in_csname; is_in_csname := true;
repeat get_x_token;
@z

@x
@<Look up the characters of list |r| in the hash table, and set |cur_cs|@>;
@y
is_in_csname := b;
@<Look up the characters of list |r| in the hash table, and set |cur_cs|@>;
@z

@x
if eq_type(cur_cs)=undefined_cs then
  begin eq_define(cur_cs,relax,256); {N.B.: The |save_stack| might change}
  end; {the control sequence will now match `\.{\\relax}'}
@y
if eq_type(cur_cs)=undefined_cs then
  begin eq_define(cur_cs,relax,max_char_val); {N.B.: The |save_stack| might change}
  end; {the control sequence will now match `\.{\\relax}'}
@z

@x
@ @<Look up the characters of list |r| in the hash table...@>=
j:=first; p:=link(r);
while p<>null do
  begin if j>=max_buf_stack then
    begin max_buf_stack:=j+1;
    if max_buf_stack=buf_size then
      overflow("buffer size",buf_size);
@:TeX capacity exceeded buffer size}{\quad buffer size@>
    end;
  buffer[j]:=info(p) mod @'400; incr(j); p:=link(p);
  end;
if j>first+1 then
  begin no_new_control_sequence:=false; cur_cs:=id_lookup(first,j-first);
  no_new_control_sequence:=true;
  end
else if j=first then cur_cs:=null_cs {the list is empty}
else cur_cs:=single_base+buffer[first] {the list has length one}
@y
@ 
@d set_buffer_from_t(#)==begin
      if BYTE1(t)<>0 then begin buffer[j]:=BYTE1(t); buffer2[j]:=#; incr(j); end;
      if BYTE2(t)<>0 then begin buffer[j]:=BYTE2(t); buffer2[j]:=#; incr(j); end;
      if BYTE3(t)<>0 then begin buffer[j]:=BYTE3(t); buffer2[j]:=#; incr(j); end;
                                buffer[j]:=BYTE4(t); buffer2[j]:=#; incr(j);
    end

@<Look up the characters of list |r| in the hash table...@>=
j:=first; p:=link(r);
while p<>null do
  begin if j>=max_buf_stack then
    begin max_buf_stack:=j+1;
    if max_buf_stack=buf_size then
      overflow("buffer size",buf_size);
@:TeX capacity exceeded buffer size}{\quad buffer size@>
    end;
  if info(p) mod max_char_val>=@"80 then {|wchar_token|}
    begin t:=toBUFF(info(p) mod max_char_val);
    if info(p) div max_char_val>=cjk_code_flag then set_buffer_from_t(1)
    else set_buffer_from_t(0);
    p:=link(p);
    end
  else
    begin buffer[j]:=info(p) mod max_char_val; buffer2[j]:=0; incr(j); p:=link(p);
    end;
  end;
if j>first+1 then
  begin no_new_control_sequence:=false; cur_cs:=id_lookup(first,j-first);
  no_new_control_sequence:=true;
  end
else if j=first then cur_cs:=null_cs {the list is empty}
else cur_cs:=single_base+buffer[first] {the list has length one}
@z

@x
@p procedure get_x_token; {sets |cur_cmd|, |cur_chr|, |cur_tok|,
  and expands macros}
label restart,done;
begin restart: get_next;
@^inner loop@>
if cur_cmd<=max_command then goto done;
if cur_cmd>=call then
  if cur_cmd<end_template then macro_call
  else  begin cur_cs:=frozen_endv; cur_cmd:=endv;
    goto done; {|cur_chr=null_list|}
    end
else expand;
goto restart;
done: if cur_cs=0 then cur_tok:=(cur_cmd*@'400)+cur_chr
else cur_tok:=cs_token_flag+cur_cs;
end;
@y
@p procedure get_x_token; {sets |cur_cmd|, |cur_chr|, |cur_tok|,
  and expands macros}
label restart,done;
begin restart: get_next;
@^inner loop@>
if cur_cmd<=max_command then goto done;
if cur_cmd>=call then
  if cur_cmd<end_template then macro_call
  else  begin cur_cs:=frozen_endv; cur_cmd:=endv;
    goto done; {|cur_chr=null_list|}
    end
else expand;
goto restart;
done: if cur_cs=0 then
  if (cur_cmd>=kanji)and(cur_cmd<=hangul) then
    cur_tok:=(cur_cmd*max_char_val)+cur_chr
  else cur_tok:=(cur_cmd*max_char_val)+cur_chr
else cur_tok:=cs_token_flag+cur_cs;
end;
@z

@x
@p procedure x_token; {|get_x_token| without the initial |get_next|}
begin while cur_cmd>max_command do
  begin expand;
  get_next;
  end;
if cur_cs=0 then cur_tok:=(cur_cmd*@'400)+cur_chr
else cur_tok:=cs_token_flag+cur_cs;
@y
@p procedure x_token; {|get_x_token| without the initial |get_next|}
begin while cur_cmd>max_command do
  begin expand;
  get_next;
  end;
if cur_cs=0 then
  if (cur_cmd>=kanji)and(cur_cmd<=hangul) then
    cur_tok:=(cur_cmd*max_char_val)+cur_chr
  else cur_tok:=(cur_cmd*max_char_val)+cur_chr
else cur_tok:=cs_token_flag+cur_cs;
@z

@x
if cur_tok=par_token then if long_state<>long_call then
  @<Report a runaway argument and abort@>;
@y
if cur_tok=par_token then if long_state<>long_call then
  if suppress_long_error=0 then @<Report a runaway argument and abort@>;
@z

@x
  if cur_tok=par_token then if long_state<>long_call then
    @<Report a runaway argument and abort@>;
@y
  if cur_tok=par_token then if long_state<>long_call then
    if suppress_long_error=0 then @<Report a runaway argument and abort@>;
@z

@x
@!k:pool_pointer; {index into |str_pool|}
begin p:=backup_head; link(p):=null; k:=str_start[s];
@y
@!k:pool_pointer; {index into |str_pool|}
@!save_cur_cs:pointer; {to save |cur_cs|}
begin p:=backup_head; link(p):=null; k:=str_start[s];
save_cur_cs:=cur_cs;
@z

@x
    scan_keyword:=false; return;
@y
    cur_cs:=save_cur_cs;
    scan_keyword:=false; return;
@z

@x
@p procedure@?scan_int; forward; {scans an integer value}
@y
@p procedure@?scan_int; forward; {scans an integer value}
procedure@?scan_something_internal_ident; forward;
@z

@x
@d tok_val=5 {token lists}

@<Glob...@>=
@!cur_val:integer; {value returned by numeric scanners}
@y
@d tok_val=5 {token lists}
@d node_recipe_val=6 { \.{\\nptexnoderecipe} token lists }

@<Glob...@>=
@!cur_val:integer; {value returned by numeric scanners}
@!cur_val1:integer;
@z

@x
@p procedure scan_something_internal(@!level:small_number;@!negative:boolean);
@y
@p @t\4@>@<Declare procedures needed in |scan_something_internal|@>@t@>@/
@z

@x
  {fetch an internal parameter}
label exit;
var m:halfword; {|chr_code| part of the operand token}
@!q,@!r:pointer; {general purpose indices}
@!tx:pointer; {effective tail node}
@y
procedure scan_something_internal(@!level:small_number;@!negative:boolean);
  {fetch an internal parameter}
label exit, restart;
var m:halfword; {|chr_code| part of the operand token}
@!q,@!r:pointer; {general purpose indices}
@!tx:pointer; {effective tail node}
@!qx:halfword; {general purpose index}
@z

@x
begin m:=cur_chr;
@y
begin restart: m:=cur_chr;
@z

@x
case cur_cmd of
def_code: @<Fetch a character code from some table@>;
toks_register,assign_toks,def_family,set_font,def_font: @<Fetch a token list or
  font identifier, provided that |level=tok_val|@>;
@y
case cur_cmd of
assign_kinsoku: @<Fetch breaking penalty from some table@>;
assign_inhibit_xsp_code: @<Fetch inhibit type from some table@>;
set_kansuji_char: @<Fetch kansuji char code from some table@>;
def_code: @<Fetch a character code from some table@>;
toks_register,assign_toks,def_family,set_font,def_font,def_jfont,def_tfont:
  @<Fetch a token list or font identifier, provided that |level=tok_val|@>;
@z

@x
char_given,math_given: scanned_result(cur_chr)(int_val);
@y
kchar_given,
omath_given,
char_given,math_given: scanned_result(cur_chr)(int_val);
@z

@x
last_item: @<Fetch an item in the current node, if appropriate@>;
@y
last_item: @<Fetch an item in the current node, if appropriate@>;
ignore_spaces: {trap unexpandable primitives}
  if cur_chr=1 then @<Reset |cur_tok| for unexpandable primitives, goto restart@>;
@z

@x
@<Fix the reference count, if any, and negate |cur_val| if |negative|@>;
exit:end;
@y
@<Fix the reference count, if any, and negate |cur_val| if |negative|@>;
exit:end;

@ @p procedure scan_something_internal_ident;
  begin scan_something_internal(ident_val,false); end;
@z

@x
@ @<Fetch a character code from some table@>=
begin scan_char_num;
if m=math_code_base then scanned_result(ho(math_code(cur_val)))(int_val)
else if m<math_code_base then scanned_result(equiv(m+cur_val))(int_val)
else scanned_result(eqtb[m+cur_val].int)(int_val);
@y
@ @<Fetch a character code from some table@>=
begin
if m=math_code_base then begin
  scan_ascii_num; cur_val1:=ho(math_code(cur_val));
  if ((cur_val1 div @"10000)>8) or
     (((cur_val1 mod @"10000) div @"100)>15) then
    begin print_err("Extended mathchar used as mathchar");
@.Bad mathchar@>
    help2("A mathchar number must be between 0 and ""7FFF.")@/
      ("I changed this one to zero."); int_error(cur_val1);
    scanned_result(0)(int_val)
    end;
  cur_val1:=(cur_val1 div @"10000)*@"1000+cur_val1 mod @"1000;
  scanned_result(cur_val1)(int_val);
  end
else if m=(math_code_base+128) then begin
  scan_ascii_num; cur_val1:=ho(math_code(cur_val));
  cur_val:=(cur_val1 div @"10000) * @"1000000
           +((cur_val1 div @"100) mod @"100) * @"10000
           +(cur_val1 mod @"100);
  scanned_result(cur_val)(int_val);
  end
else if m=del_code_base then begin
  scan_ascii_num; cur_val1:=del_code(cur_val); cur_val:=del_code1(cur_val);
  if ((cur_val1 div @"100) mod @"100 >= 16) or (cur_val>=@"1000) then
  begin print_err("Extended delimiter code used as delcode");
@.Bad delimiter code@>
    help2("A numeric delimiter code must be between 0 and 2^{27}-1.")@/
      ("I changed this one to zero."); error;
    scanned_result(0)(int_val);
    end
  else if cur_val1<0 then
    scanned_result(cur_val)(int_val)
  else
    scanned_result(cur_val1*@"1000+cur_val)(int_val);
  end
else if m=(del_code_base+128) then begin
  { Aleph seems \.{\\odelcode} always returns $-1$.}
  scan_ascii_num; scanned_result(-1)(int_val);
  end
else if m=cjkx_code_base then
  begin scan_char_num;
  scanned_result(equiv(m+cur_val))(int_val); end
else if m=cat_code_base then
  begin scan_char_num;
  scanned_result(equiv(m+cur_val))(int_val); end
else if m<math_code_base then { \.{\\lccode}, \.{\\uccode}, \.{\\sfcode} }
  begin scan_ascii_num;
  scanned_result(equiv(m+cur_val))(int_val) end
else { \.{\\delcode} }
  begin scan_ascii_num;
  scanned_result(eqtb[m+cur_val].int)(int_val) end;
@z

@x
    else cur_val:=sa_ptr(m)
  else cur_val:=equiv(m);
  cur_val_level:=tok_val;
@y
    else cur_val:=sa_ptr(m)
  else if cur_chr=node_recipe_loc then begin
    scan_char_num;
    find_sa_element(node_recipe_val, cur_val, false);
    if cur_ptr=null then cur_val:=null
    else cur_val:=sa_ptr(cur_ptr);
    end
  else cur_val:=equiv(m);
  cur_val_level:=tok_val;
@z

@x
@d input_line_no_code=glue_val+2 {code for \.{\\inputlineno}}
@d badness_code=input_line_no_code+1 {code for \.{\\badness}}
@y
@d last_node_subtype_code=glue_val+2 {code for \.{\\lastnodesubtype}}
@d last_node_char_code=glue_val+3 {code for \.{\\lastnodechar}}
@d last_node_font_code=glue_val+4 {code for \.{\\lastnodefont}}
@d input_line_no_code=glue_val+5 {code for \.{\\inputlineno}}
@d badness_code=glue_val+6 {code for \.{\\badness}}
@d ptex_version_code=badness_code+1 {code for \.{\\ptexversion}}
@d uptex_version_code=ptex_version_code+1 {code for \.{\\uptexversion}}
@d eptex_version_code=uptex_version_code+1 {code for \.{\\epTeXversion}}
@d nptex_version_code=eptex_version_code+1 {code for \.{\\nptexversion}}
@d ptex_minor_version_code=nptex_version_code+1 {code for \.{\\ptexminorversion}}
@d pdf_last_x_pos_code=ptex_minor_version_code+1 {code for \.{\\pdflastxpos}}
@d pdf_last_y_pos_code=pdf_last_x_pos_code+1 {code for \.{\\pdflastypos}}
@d pdf_shell_escape_code=pdf_last_y_pos_code+1 {code for \.{\\pdflastypos}}
@d elapsed_time_code=pdf_shell_escape_code+1 {code for \.{\\pdfelapsedtime}}
@d random_seed_code=elapsed_time_code+1 {code for \.{\\pdfrandomseed}}
@z

@x
@d eTeX_int=badness_code+1 {first of \eTeX\ codes for integers}
@y
@d eTeX_int=random_seed_code+1 {first of \eTeX\ codes for integers}
@z

@x
@d eTeX_dim=eTeX_int+8 {first of \eTeX\ codes for dimensions}
@y
@d eTeX_dim=eTeX_int+11 {first of \eTeX\ codes for dimensions}
@z

@x
primitive("badness",last_item,badness_code);
@!@:badness_}{\.{\\badness} primitive@>
@y
primitive("badness",last_item,badness_code);
@!@:badness_}{\.{\\badness} primitive@>
primitive("ptexversion",last_item,ptex_version_code);
@!@:ptexversion_}{\.{\\ptexversion} primitive@>
primitive("uptexversion",last_item,uptex_version_code);
@!@:uptexversion_}{\.{\\uptexversion} primitive@>
primitive("epTeXversion",last_item,eptex_version_code);
@!@:epTeXversion_}{\.{\\epTeXversion} primitive@>
primitive("nptexversion",last_item,nptex_version_code);
@!@:nptexversion_}{\.{\\nptexversion} primitive@>
primitive("ptexminorversion",last_item,ptex_minor_version_code);
@!@:ptexminorversion_}{\.{\\ptexminorversion} primitive@>
@z

@x
  input_line_no_code: print_esc("inputlineno");
@y
  input_line_no_code: print_esc("inputlineno");
  ptex_version_code: print_esc("ptexversion");
  uptex_version_code: print_esc("uptexversion");
  eptex_version_code: print_esc("epTeXversion");
  nptex_version_code: print_esc("nptexversion");
  ptex_minor_version_code: print_esc("ptexminorversion");
@z

@x
begin scan_register_num; fetch_box(q);
if q=null then cur_val:=0 @+else cur_val:=mem[q+m].sc;
@y
begin scan_register_num; fetch_box(q);
if q=null then cur_val:=0
else  begin qx:=q;
  while (q<>null)and(abs(box_dir(q))<>abs(direction)) do q:=link(q);
  if q=null then
    begin r:=link(qx); link(qx):=null;
    q:=new_dir_node(qx,abs(direction)); link(qx):=r;
    cur_val:=mem[q+m].sc;
    delete_glue_ref(space_ptr(q)); delete_glue_ref(xspace_ptr(q));
    free_node(q,box_node_size);
    end
  else cur_val:=mem[q+m].sc;
  end;
@z

@x
legal in similar contexts.

@y
legal in similar contexts.

The macro |find_effective_tail_pTeX| sets |tx| to the last non-|disp_node|
of the current list.
@z

@x
node of the current list.
@y
node of the current list.
The macro |find_effective_tail_epTeX| sets |tx| to the last non-\.{\\endM}
non-|disp_node| of the current list.
@z

@x
@d find_effective_tail==find_effective_tail_eTeX

@<Fetch an item in the current node...@>=
@y
@d find_effective_tail_pTeX==
tx:=tail;
if not is_char_node(tx) then
  if type(tx)=disp_node then
    begin tx:=prev_node;
    if not is_char_node(tx) then
      if type(tx)=disp_node then {|disp_node| from a discretionary}
        begin tx:=head; q:=link(head);
        while q<>prev_node do
          begin if is_char_node(q) then tx:=q
          else if type(q)<>disp_node then tx:=q;
          end;
        q:=link(q);
        end;
    end
@#
@d find_effective_tail_epTeX==
tx:=tail;
if not is_char_node(tx) then if type(tx)=disp_node then tx:=prev_node;
if not is_char_node(tx) then
  if (type(tx)=disp_node) {|disp_node| from a discretionary}
    or((type(tx)=math_node)and(subtype(tx)=end_M_code)) then
    begin r:=head; q:=link(head);
    while q<>tx do
      begin if is_char_node(q) then r:=q
      else if (type(q)<>disp_node)and
        ((type(q)<>math_node)or(subtype(q)<>end_M_code)) then r:=q;
      q:=link(q);
      end;
    tx:=r;
    end
@#
@d find_effective_tail==find_effective_tail_epTeX
@#
@d find_last_char==
if font_dir[font(tx)]<>dir_default then cur_val:=KANJI(info(link(tx))) mod max_char_val
else cur_val:=qo(character(tx))

@d ignore_font_kerning==
begin if ((type(tx)=glue_node) and (subtype(tx)=jfm_skip+1))
  or ((type(tx)=penalty_node) and (subtype(tx)=kinsoku_pena)) then
  tx:=last_jchr
else if (type(tx)=kern_node) and (subtype(tx)=normal) then
  begin r:=head; q:=link(head);
  while q<>tx do
    begin r:=q;
    if is_char_node(q) then if font_dir[font(q)]<>dir_default then q:=link(q);
    q:=link(q);
    end;
  if ((type(r)=penalty_node) and (subtype(r)=kinsoku_pena)) then tx:=last_jchr else tx:=r;
  end;
end

@<Fetch an item in the current node...@>=
@z

@x
 if m>=eTeX_glue then @<Process an expression and |return|@>@;
 else if m>=eTeX_dim then
  begin case m of
  @/@<Cases for fetching a dimension value@>@/
  end; {there are no other cases}
  cur_val_level:=dimen_val;
  end
 else begin case m of
  input_line_no_code: cur_val:=line;
  badness_code: cur_val:=last_badness;
  @/@<Cases for fetching an integer value@>@/
  end; {there are no other cases}
@y
 if m>=eTeX_glue then @<Process an expression and |return|@>@;
 else if m>=eTeX_dim then
  begin case m of
  @/@<Cases for fetching a dimension value@>@/
  end; {there are no other cases}
  cur_val_level:=dimen_val;
  end
 else begin case m of
  input_line_no_code: cur_val:=line;
  badness_code: cur_val:=last_badness;
  ptex_version_code: cur_val:=pTeX_version;
  uptex_version_code: cur_val:=upTeX_version;
  eptex_version_code: cur_val:=epTeX_version_number;
  nptex_version_code: cur_val:=npTeX_version;
  ptex_minor_version_code: cur_val:=pTeX_minor_version;
  @/@<Cases for fetching an integer value@>@/
  end; {there are no other cases}
@z

@x
else begin if cur_chr=glue_val then cur_val:=zero_glue@+else cur_val:=0;
@y
else begin if cur_chr=glue_val then cur_val:=zero_glue@+else cur_val:=0;
  find_effective_tail;
@z

@x
  find_effective_tail;
  if cur_chr=last_node_type_code then
    begin cur_val_level:=int_val;
    if (tx=head)or(mode=0) then cur_val:=-1;
    end
  else cur_val_level:=cur_chr;
@y
  if (cur_chr=last_node_type_code)or(cur_chr=last_node_subtype_code) then
    begin cur_val_level:=int_val;
    if (tx=head)or(mode=0) then cur_val:=-1;
    end
  else if cur_chr=last_node_char_code then
    begin cur_val_level:=int_val; cur_val:=-1;
    end
  else if cur_chr=last_node_font_code then
    begin cur_val_level:=ident_val; cur_val:=null_font+font_id_base;
    end
  else cur_val_level:=cur_chr;
  if (cur_chr=last_node_char_code)or(cur_chr=last_node_font_code) then
    if is_char_node(tx)and(tx<>head) then begin
      { |tx| might be ``second node'' of a KANJI character; so we need to look the node before |tx| }
      r:=head; q:=head;
      while q<>tx do begin r:=q; q:=link(q); end; { |r| is the node just before |tx| }
      if (r<>head)and is_char_node(r) then if font_dir[font(r)]<>dir_default then tx:=r;
      if cur_chr=last_node_char_code then find_last_char
      else cur_val:=font(tx)+font_id_base;
      end;
@z

@x
  if not is_char_node(tx)and(mode<>0) then
    case cur_chr of
    int_val: if type(tx)=penalty_node then cur_val:=penalty(tx);
    dimen_val: if type(tx)=kern_node then cur_val:=width(tx);
    glue_val: if type(tx)=glue_node then
      begin cur_val:=glue_ptr(tx);
      if subtype(tx)=mu_glue then cur_val_level:=mu_val;
      end;
@y
  if not is_char_node(tx)and(tx<>head)and(mode<>0) then
    case cur_chr of
    int_val: if type(tx)=penalty_node then cur_val:=penalty(tx);
    dimen_val: if type(tx)=kern_node then cur_val:=width(tx);
    glue_val: if type(tx)=glue_node then
      begin cur_val:=glue_ptr(tx);
      if subtype(tx)=mu_glue then cur_val_level:=mu_val;
      end;
@z

@x
    last_node_type_code: if type(tx)<=unset_node then cur_val:=type(tx)+1
      else cur_val:=unset_node+2;
@y
    last_node_type_code: if type(tx)<=unset_node then
        begin if type(tx)=dir_node then tx:=list_ptr(tx);
        cur_val:=type(tx);
        if cur_val<dir_node then cur_val:=cur_val+1
        else if cur_val>disp_node then cur_val:=cur_val-1;
        end
      else cur_val:=unset_node; {\epTeX's |unset_node| is \eTeX's |unset_node+2|}
    last_node_subtype_code: if type(tx)<=unset_node then cur_val:=subtype(tx)
        { non-math nodes }
      else begin
        cur_val:=type(tx);
        if cur_val<unset_node+4 then cur_val:=cur_val-unset_node-1
          { |style_noad|, |choice_noad|, |ord_noad| }
        else if cur_val=unset_node+4 then cur_val:=cur_val-unset_node-1+subtype(tx)
        else cur_val:=cur_val-unset_node+1;
      end;
    last_node_char_code: begin
      ignore_font_kerning;
      if is_char_node(tx) then
        find_last_char
      else if type(tx)=ligature_node then
        {decompose a ligature to original characters}
        begin r:=lig_ptr(tx);
        while link(r)<>null do r:=link(r);
        cur_val:=qo(character(r));
        end
      {else: already -1}
      end;
    last_node_font_code: begin
      ignore_font_kerning;
      if is_char_node(tx) then
        cur_val:=font(tx)+font_id_base
      else if type(tx)=ligature_node then
        cur_val:=font(lig_char(tx))+font_id_base
      {else: already nullfont}
      end;
@z

@x
  else if (mode=vmode)and(tx=head) then
@y
  else if (mode=vmode)and(tx=head) then
@z

@x
    last_node_type_code: cur_val:=last_node_type;
@y
    last_node_type_code: cur_val:=last_node_type;
    last_node_subtype_code: cur_val:=last_node_subtype;
@z

@x
procedure scan_char_num;
begin scan_int;
if (cur_val<0)or(cur_val>255) then
  begin print_err("Bad character code");
@.Bad character code@>
  help2("A character number must be between 0 and 255.")@/
    ("I changed this one to zero."); int_error(cur_val); cur_val:=0;
  end;
end;
@y
procedure scan_ascii_num;
begin scan_int;
if (cur_val<0)or(cur_val>255) then
  begin print_err("Bad character code");
@.Bad character code@>
  help2("A character number must be between 0 and 255.")@/
    ("I changed this one to zero."); int_error(cur_val); cur_val:=0;
  end;
end;
procedure scan_char_num;
begin scan_int;
if not is_char_ascii(cur_val) and not is_char_kanji(cur_val) then
  begin print_err("Bad character code");
@.Bad character code@>
  help2("A character number must be between 0 and 255, or KANJI code.")@/
    ("I changed this one to zero."); int_error(cur_val); cur_val:=0;
  end;
end;
@z

@x
procedure scan_four_bit_int;
begin scan_int;
if (cur_val<0)or(cur_val>15) then
  begin print_err("Bad number");
@.Bad number@>
  help2("Since I expected to read a number between 0 and 15,")@/
    ("I changed this one to zero."); int_error(cur_val); cur_val:=0;
  end;
end;
@y
procedure scan_four_bit_int;
begin scan_int;
if (cur_val<0)or(cur_val>15) then
  begin print_err("Bad number");
@.Bad number@>
  help2("Since I expected to read a number between 0 and 15,")@/
    ("I changed this one to zero."); int_error(cur_val); cur_val:=0;
  end;
end;
@#
procedure scan_big_four_bit_int;
begin scan_int;
if (cur_val<0)or(cur_val>255) then
  begin print_err("Bad number");
@.Bad register code@>
  help2("Since I expected to read a number between 0 and 255,")@/
    ("I changed this one to zero."); int_error(cur_val); cur_val:=0;
  end;
end;
@z

@x
procedure scan_fifteen_bit_int;
begin scan_int;
if (cur_val<0)or(cur_val>@'77777) then
  begin print_err("Bad mathchar");
@.Bad mathchar@>
  help2("A mathchar number must be between 0 and 32767.")@/
    ("I changed this one to zero."); int_error(cur_val); cur_val:=0;
  end;
end;
@y
procedure scan_fifteen_bit_int;
begin scan_int;
if (cur_val<0)or(cur_val>@'77777) then
  begin print_err("Bad mathchar");
@.Bad mathchar@>
  help2("A mathchar number must be between 0 and 32767.")@/
    ("I changed this one to zero."); int_error(cur_val); cur_val:=0;
  end;
cur_val:=((cur_val div @"1000) * @"10000)+(cur_val mod @"1000);
end;
@#
procedure scan_real_fifteen_bit_int;
begin scan_int;
if (cur_val<0)or(cur_val>@'77777) then
  begin print_err("Bad mathchar");
@.Bad mathchar@>
  help2("A mathchar number must be between 0 and 32767.")@/
    ("I changed this one to zero."); int_error(cur_val); cur_val:=0;
  end;
end;
@#
procedure scan_big_fifteen_bit_int;
begin scan_int;
if (cur_val<0)or(cur_val>@"7FFFFFF) then
  begin print_err("Bad extended mathchar");
@.Bad mathchar@>
  help2("An extended mathchar number must be between 0 and ""7FFFFFF.")@/
    ("I changed this one to zero."); int_error(cur_val); cur_val:=0;
  end;
{ e-pTeX doesn't support 65536 characters for math font. }
cur_val:=((cur_val div @"10000) * @"100)+(cur_val mod @"100);
end;
@#
procedure scan_omega_fifteen_bit_int;
begin scan_int;
if (cur_val<0)or(cur_val>@"7FFFFFF) then
  begin print_err("Bad extended mathchar");
@.Bad mathchar@>
  help2("An extended mathchar number must be between 0 and ""7FFFFFF.")@/
    ("I changed this one to zero."); int_error(cur_val); cur_val:=0;
  end;
end;
@z

@x
procedure scan_twenty_seven_bit_int;
begin scan_int;
if (cur_val<0)or(cur_val>@'777777777) then
  begin print_err("Bad delimiter code");
@.Bad delimiter code@>
  help2("A numeric delimiter code must be between 0 and 2^{27}-1.")@/
    ("I changed this one to zero."); int_error(cur_val); cur_val:=0;
  end;
end;
@y
procedure scan_twenty_seven_bit_int;
begin scan_int;
if (cur_val<0)or(cur_val>@'777777777) then
  begin print_err("Bad delimiter code");
@.Bad delimiter code@>
  help2("A numeric delimiter code must be between 0 and 2^{27}-1.")@/
    ("I changed this one to zero."); int_error(cur_val); cur_val:=0;
  end;
cur_val1 := cur_val mod @"1000; cur_val := cur_val div @"1000;
cur_val := ((cur_val div @"1000) * @"10000) + (cur_val mod @"1000);
end;
@#
procedure scan_fifty_one_bit_int;
var iiii:integer;
begin scan_int;
if (cur_val<0)or(cur_val>@'777777777) then
  begin print_err("Bad delimiter code");
@.Bad delimiter code@>
  help2("A numeric delimiter (first part) must be between 0 and 2^{27}-1.")
    ("I changed this one to zero."); int_error(cur_val); cur_val:=0;
  end;
iiii:=((cur_val div @"10000) * @"100) + (cur_val mod @"100);
scan_int;
if (cur_val<0)or(cur_val>@"FFFFFF) then
  begin print_err("Bad delimiter code");
@.Bad delimiter code@>
help2("A numeric delimiter (second part) must be between 0 and 2^{24}-1.")@/
    ("I changed this one to zero."); int_error(cur_val); cur_val:=0;
  end;
{ e-pTeX doesn't support 65536 characters for math font. }
cur_val1:=((cur_val div @"10000) * @"100) + (cur_val mod @"100);
cur_val:=iiii;
end;
@z

@x
@p procedure scan_int; {sets |cur_val| to an integer}
label done;
@y
@p procedure scan_int; {sets |cur_val| to an integer}
label done, restart;
@z

@x
if cur_tok=alpha_token then @<Scan an alphabetic character code into |cur_val|@>
@y
restart:
if cur_tok=alpha_token then @<Scan an alphabetic character code into |cur_val|@>
else if cur_tok=cs_token_flag+frozen_primitive then
  @<Reset |cur_tok| for unexpandable primitives, goto restart@>
@z

@x
@<Scan an alphabetic character code into |cur_val|@>=
begin get_token; {suppress macro expansion}
if cur_tok<cs_token_flag then
  begin cur_val:=cur_chr;
  if cur_cmd<=right_brace then
    if cur_cmd=right_brace then incr(align_state)
    else decr(align_state);
  end
else if cur_tok<cs_token_flag+single_base then
  cur_val:=cur_tok-cs_token_flag-active_base
else cur_val:=cur_tok-cs_token_flag-single_base;
if cur_val>255 then
  begin print_err("Improper alphabetic constant");
@.Improper alphabetic constant@>
  help2("A one-character control sequence belongs after a ` mark.")@/
    ("So I'm essentially inserting \0 here.");
  cur_val:="0"; back_error;
  end
else @<Scan an optional space@>;
end
@y
@<Scan an alphabetic character code into |cur_val|@>=
begin get_token; {suppress macro expansion}
if cur_tok<cs_token_flag then
  if (cur_cmd>=kanji)and(cur_cmd<=hangul) then {|wchar_token|}
    begin skip_mode:=false; cur_val:=tonum(cur_chr);
    end
  else begin cur_val:=cur_chr;
  if cur_cmd<=right_brace then
    if cur_cmd=right_brace then incr(align_state)
    else decr(align_state);
  end
else if cur_tok<cs_token_flag+single_base then
  cur_val:=cur_tok-cs_token_flag-active_base
else
  cur_val:=cur_tok-cs_token_flag-single_base;
if cur_val>=number_usvs then
  begin print_hex(cur_val); print_err("Improper alphabetic constant");
@.Improper alphabetic constant@>
  help2("A one-character control sequence belongs after a ` mark.")@/
    ("So I'm essentially inserting \0 here.");
  cur_val:="0"; back_error;
  end
else @<Scan an optional space@>;
skip_mode:=true;
end
@z

@x
@<Scan for \(f)\.{fil} units...@>=
if scan_keyword("fil") then
@.fil@>
  begin cur_order:=fil;
@y
@<Scan for \(f)\.{fil} units...@>=
if scan_keyword("fi") then
@.fil@>
  begin cur_order:=sfi;
@z

@x
if scan_keyword("em") then v:=(@<The em width for |cur_font|@>)
@.em@>
else if scan_keyword("ex") then v:=(@<The x-height for |cur_font|@>)
@.ex@>
else goto not_found;
@y
if scan_keyword("em") then v:=(@<The em width for |cur_font|@>)
@.em@>
else if scan_keyword("ex") then v:=(@<The x-height for |cur_font|@>)
@.ex@>
else if scan_keyword("zw") then @<The KANJI width for |cur_jfont|@>
@.zw@>
else if scan_keyword("zh") then @<The KANJI height for |cur_jfont|@>
@.zh@>
else goto not_found;
@z

@x
else if scan_keyword("sp") then goto done
@.sp@>
@y
else if scan_keyword("H") then set_conversion(7227)(10160)
@.H@>
else if scan_keyword("Q") then set_conversion(7227)(10160)
@.Q@>
else if scan_keyword("sp") then goto done
@.sp@>
@z

@x
help6("Dimensions can be in units of em, ex, in, pt, pc,")@/
  ("cm, mm, dd, cc, bp, or sp; but yours is a new one!")@/
@y
help6("Dimensions can be in units of em, ex, zw, zh, in, pt, pc,")@/
  ("cm, mm, dd, cc, bp, H, Q, or sp; but yours is a new one!")@/
@z

@x
function str_toks(@!b:pool_pointer):pointer;
@y
function str_toks_cat(@!b:pool_pointer;@!cat:small_number):pointer;
@z

@x
@!t:halfword; {token being appended}
@!k:pool_pointer; {index into |str_pool|}
begin str_room(1);
p:=temp_head; link(p):=null; k:=b;
while k<pool_ptr do
  begin t:=so(str_pool[k]);
  if t=" " then t:=space_token
  else t:=other_token+t;
@y
@!t,tb:halfword; {token being appended}
@!k:pool_pointer; {index into |str_pool|}
begin str_room(1);
p:=temp_head; link(p):=null; k:=b;
while k<pool_ptr do
  begin  tb:=so(str_pool[k]);
  t:=fromBUFFshort(str_pool, pool_ptr, k); 
  k:=k+multistrlenshort(str_pool, pool_ptr, k)-1;
  if cat=0 then
    begin if tb>=@"100 then t:=other_kchar*max_char_val+t { |wchar_token| }
    else if t=" " then t:=space_token
    else t:=other_token+t;
    end
  else if cat=active_char then t:= cs_token_flag + active_base + t
  else t:=t+cat*max_char_val;
@z

@x
pool_ptr:=b; str_toks:=p;
end;
@y
pool_ptr:=b; str_toks_cat:=p;
end;

function str_toks(@!b:pool_pointer):pointer;
begin str_toks:=str_toks_cat(b,0); end;
@z

@x
@d number_code=0 {command code for \.{\\number}}
@d roman_numeral_code=1 {command code for \.{\\romannumeral}}
@d string_code=2 {command code for \.{\\string}}
@d meaning_code=3 {command code for \.{\\meaning}}
@d font_name_code=4 {command code for \.{\\fontname}}
@d etex_convert_base=5 {base for \eTeX's command codes}
@d eTeX_revision_code=etex_convert_base {command code for \.{\\eTeXrevision}}
@d etex_convert_codes=etex_convert_base+1 {end of \eTeX's command codes}
@d job_name_code=etex_convert_codes {command code for \.{\\jobname}}
@y
@d number_code=0 {command code for \.{\\number}}
@d roman_numeral_code=1 {command code for \.{\\romannumeral}}
@d kansuji_code=2 {command code for \.{\\kansuji}}
@d string_code=3 {command code for \.{\\string}}
@d meaning_code=4 {command code for \.{\\meaning}}
@d font_name_code=5 {command code for \.{\\fontname}}
@d euc_code=6 {command code for \.{\\euc}}
@d sjis_code=7 {command code for \.{\\sjis}}
@d jis_code=8 {command code for \.{\\jis}}
@d kuten_code=9 {command code for \.{\\kuten}}
@d ucs_code=10 {command code for \.{\\ucs}}
@d toucs_code=11 {command code for \.{\\toucs}}
@d tojis_code=12 {command code for \.{\\tojis}}
@d ptex_font_name_code=13 {command code for \.{\\ptexfontname}}
@d ptex_revision_code=14 {command code for \.{\\ptexrevision}}
@d uptex_revision_code=15 {command code for \.{\\uptexrevision}}
@d nptex_revision_code=16 {command code for \.{\\nptexrevision}}
@d ptex_convert_codes=17 {end of \pTeX's command codes}
@d etex_convert_base=ptex_convert_codes {base for \eTeX's command codes}
@d eTeX_revision_code=etex_convert_base {command code for \.{\\eTeXrevision}}
@d etex_convert_codes=etex_convert_base+1 {end of \eTeX's command codes}
@d expanded_code            = etex_convert_codes {command code for \.{\\expanded}}
@d pdf_first_expand_code    = expanded_code + 1 {base for \pdfTeX-like command codes}
@d pdf_strcmp_code          = pdf_first_expand_code+0 {command code for \.{\\pdfstrcmp}}
@d pdf_creation_date_code   = pdf_first_expand_code+1 {command code for \.{\\pdfcreationdate}}
@d pdf_file_mod_date_code   = pdf_first_expand_code+2 {command code for \.{\\pdffilemoddate}}
@d pdf_file_size_code       = pdf_first_expand_code+3 {command code for \.{\\pdffilesize}}
@d pdf_mdfive_sum_code      = pdf_first_expand_code+4 {command code for \.{\\pdfmdfivesum}}
@d pdf_file_dump_code       = pdf_first_expand_code+5 {command code for \.{\\pdffiledump}}
@d uniform_deviate_code     = pdf_first_expand_code+6 {command code for \.{\\pdfuniformdeviate}}
@d normal_deviate_code      = pdf_first_expand_code+7 {command code for \.{\\pdfnormaldeviate}}
@d pdf_convert_codes        = pdf_first_expand_code+8 {end of \pdfTeX-like command codes}
@d Uchar_convert_code       = pdf_convert_codes   {command code for \.{\\Uchar}}
@d Ucharcat_convert_code    = pdf_convert_codes+1 {command code for \.{\\Ucharcat}}
@d eptex_convert_codes      = pdf_convert_codes+2 {end of \epTeX's command codes}
@d job_name_code=eptex_convert_codes {command code for \.{\\jobname}}
@z

@x
primitive("fontname",convert,font_name_code);@/
@!@:font_name_}{\.{\\fontname} primitive@>
@y
primitive("fontname",convert,font_name_code);@/
@!@:font_name_}{\.{\\fontname} primitive@>
primitive("kansuji",convert,kansuji_code);
@!@:kansuji_}{\.{\\kansuji} primitive@>
primitive("euc",convert,euc_code);
@!@:euc_}{\.{\\euc} primitive@>
primitive("sjis",convert,sjis_code);
@!@:sjis_}{\.{\\sjis} primitive@>
primitive("jis",convert,jis_code);
@!@:jis_}{\.{\\jis} primitive@>
primitive("kuten",convert,kuten_code);
@!@:kuten_}{\.{\\kuten} primitive@>
primitive("ucs",convert,ucs_code);
@!@:ucs_}{\.{\\ucs} primitive@>
primitive("toucs",convert,toucs_code);
@!@:toucs_}{\.{\\toucs} primitive@>
primitive("tojis",convert,tojis_code);
@!@:tojis_}{\.{\\tojis} primitive@>
primitive("ptexfontname",convert,ptex_font_name_code);
@!@:ptexfontname_}{\.{\\ptexfontname} primitive@>
primitive("ptexrevision",convert,ptex_revision_code);
@!@:ptexrevision_}{\.{\\ptexrevision} primitive@>
primitive("uptexrevision",convert,uptex_revision_code);
@!@:uptexrevision_}{\.{\\uptexrevision} primitive@>
primitive("nptexrevision",convert,nptex_revision_code);
@!@:nptexrevision_}{\.{\\nptexrevision} primitive@>
@z

@x
primitive("jobname",convert,job_name_code);@/
@y
@#
primitive("expanded",convert,expanded_code);@/
@!@:expanded_}{\.{\\expanded} primitive@>
@#
primitive("jobname",convert,job_name_code);@/
@z

@x
  font_name_code: print_esc("fontname");
@y
  font_name_code: print_esc("fontname");
  kansuji_code: print_esc("kansuji");
  euc_code:print_esc("euc");
  sjis_code:print_esc("sjis");
  jis_code:print_esc("jis");
  kuten_code:print_esc("kuten");
  ucs_code:print_esc("ucs");
  toucs_code:print_esc("toucs");
  tojis_code:print_esc("tojis");
  ptex_font_name_code: print_esc("ptexfontname");
  ptex_revision_code:print_esc("ptexrevision");
  uptex_revision_code:print_esc("uptexrevision");
  nptex_revision_code:print_esc("nptexrevision");
@z

@x
  eTeX_revision_code: print_esc("eTeXrevision");
@y
  eTeX_revision_code: print_esc("eTeXrevision");
  expanded_code:      print_esc("expanded");
  pdf_strcmp_code:        print_esc("pdfstrcmp");
  pdf_creation_date_code: print_esc("pdfcreationdate");
  pdf_file_mod_date_code: print_esc("pdffilemoddate");
  pdf_file_size_code:     print_esc("pdffilesize");
  pdf_mdfive_sum_code:    print_esc("pdfmdfivesum");
  pdf_file_dump_code:     print_esc("pdffiledump");
  uniform_deviate_code:   print_esc("pdfuniformdeviate");
  normal_deviate_code:    print_esc("pdfnormaldeviate");
  Uchar_convert_code:     print_esc("Uchar");
  Ucharcat_convert_code:  print_esc("Ucharcat");
@z

@x
@p procedure conv_toks;
var old_setting:0..max_selector; {holds |selector| setting}
@y

The extra temp string |u| is needed because |pdf_scan_ext_toks| incorporates
any pending string in its output. In order to save such a pending string,
we have to create a temporary string that is destroyed immediately after.

@d save_cur_string==if str_start[str_ptr]<pool_ptr then u:=make_string else u:=0
@d restore_cur_string==if u<>0 then decr(str_ptr)

@ Not all catcode values are allowed by \.{\\Ucharcat}:
@d illegal_Ucharcat_catcode(#)==((#<left_brace)or(#>active_char)or(#=out_param)or(#=ignore))and((#<kanji)or(#>hangul))

@p procedure conv_toks;
var old_setting:0..max_selector; {holds |selector| setting}
@!cx:KANJI_code; {temporary register for KANJI}
@z

@x
@!save_scanner_status:small_number; {|scanner_status| upon entry}
@y
@!save_scanner_status:small_number; {|scanner_status| upon entry}
@!save_def_ref: pointer; {|def_ref| upon entry, important if inside `\.{\\message}'}
@!save_warning_index: pointer;
@!bool: boolean; {temp boolean}
@!u: str_number; {saved current string string}
@!s: str_number; {first temp string}
@!i: integer;
@!j: integer;
@!cat:small_number; {desired catcode, or 0 for automatic |spacer|/|other_char| selection}
@z

@x
begin c:=cur_chr; @<Scan the argument for command |c|@>;
@y
begin cat:=0; c:=cur_chr; @<Scan the argument for command |c|@>;
u:=0; { will become non-nil if a string is already being built}
@z

@x
selector:=old_setting; link(garbage):=str_toks(b); ins_list(link(temp_head));
@y
selector:=old_setting; link(garbage):=str_toks_cat(b,cat); ins_list(link(temp_head));
@z

@x
@ @<Scan the argument for command |c|@>=
case c of
number_code,roman_numeral_code: scan_int;
string_code, meaning_code: begin save_scanner_status:=scanner_status;
  scanner_status:=normal; get_token; scanner_status:=save_scanner_status;
  end;
@y
@ @<Scan the argument for command |c|@>=
KANJI(cx):=0;
case c of
number_code,roman_numeral_code,
kansuji_code,euc_code,sjis_code,jis_code,kuten_code,
ucs_code,toucs_code,tojis_code: scan_int;
ptex_font_name_code: scan_font_ident;
ptex_revision_code, uptex_revision_code, nptex_revision_code: do_nothing;
string_code, meaning_code: begin save_scanner_status:=scanner_status;
  scanner_status:=normal; get_token;
  if (cur_cmd>=kanji)and(cur_cmd<=hangul) then {|wchar_token|}
    KANJI(cx):=cur_tok;
  scanner_status:=save_scanner_status;
  end;
@z

@x
eTeX_revision_code: do_nothing;
@y
eTeX_revision_code: do_nothing;
expanded_code:
  begin
    save_scanner_status := scanner_status;
    save_warning_index := warning_index;
    save_def_ref := def_ref;
    save_cur_string;
    scan_pdf_ext_toks;
    warning_index := save_warning_index;
    scanner_status := save_scanner_status;
    ins_list(link(def_ref));
    free_avail(def_ref);
    def_ref := save_def_ref;
    restore_cur_string;
    return;
  end;
pdf_strcmp_code:
  begin
    save_scanner_status := scanner_status;
    save_warning_index := warning_index;
    save_def_ref := def_ref;
    save_cur_string;
    compare_strings;
    def_ref := save_def_ref;
    warning_index := save_warning_index;
    scanner_status := save_scanner_status;
    restore_cur_string;
  end;
pdf_creation_date_code:
  begin
    b := pool_ptr;
    getcreationdate;
    link(garbage) := str_toks(b);
    ins_list(link(temp_head));
    return;
  end;
pdf_file_mod_date_code:
  begin
    save_scanner_status := scanner_status;
    save_warning_index := warning_index;
    save_def_ref := def_ref;
    save_cur_string;
    scan_pdf_ext_toks;
    s := tokens_to_string(def_ref);
    delete_token_ref(def_ref);
    def_ref := save_def_ref;
    warning_index := save_warning_index;
    scanner_status := save_scanner_status;
    b := pool_ptr;
    getfilemoddate(s);
    link(garbage) := str_toks(b);
    flush_str(s);
    ins_list(link(temp_head));
    restore_cur_string;
    return;
  end;
pdf_file_size_code:
  begin
    save_scanner_status := scanner_status;
    save_warning_index := warning_index;
    save_def_ref := def_ref;
    save_cur_string;
    scan_pdf_ext_toks;
    s := tokens_to_string(def_ref);
    delete_token_ref(def_ref);
    def_ref := save_def_ref;
    warning_index := save_warning_index;
    scanner_status := save_scanner_status;
    b := pool_ptr;
    getfilesize(s);
    link(garbage) := str_toks(b);
    flush_str(s);
    ins_list(link(temp_head));
    restore_cur_string;
    return;
  end;
pdf_mdfive_sum_code:
  begin
    save_scanner_status := scanner_status;
    save_warning_index := warning_index;
    save_def_ref := def_ref;
    save_cur_string;
    bool := scan_keyword("file");
    scan_pdf_ext_toks;
    s := tokens_to_string(def_ref);
    delete_token_ref(def_ref);
    def_ref := save_def_ref;
    warning_index := save_warning_index;
    scanner_status := save_scanner_status;
    b := pool_ptr;
    getmd5sum(s, bool);
    link(garbage) := str_toks(b);
    flush_str(s);
    ins_list(link(temp_head));
    restore_cur_string;
    return;
  end;
pdf_file_dump_code:
  begin
    save_scanner_status := scanner_status;
    save_warning_index := warning_index;
    save_def_ref := def_ref;
    save_cur_string;
    {scan offset}
    cur_val := 0;
    if (scan_keyword("offset")) then begin
      scan_int;
      if (cur_val < 0) then begin
        print_err("Bad file offset");
@.Bad file offset@>
        help2("A file offset must be between 0 and 2^{31}-1,")@/
          ("I changed this one to zero.");
        int_error(cur_val);
        cur_val := 0;
      end;
    end;
    i := cur_val;
    {scan length}
    cur_val := 0;
    if (scan_keyword("length")) then begin
      scan_int;
      if (cur_val < 0) then begin
        print_err("Bad dump length");
@.Bad dump length@>
        help2("A dump length must be between 0 and 2^{31}-1,")@/
          ("I changed this one to zero.");
        int_error(cur_val);
        cur_val := 0;
      end;
    end;
    j := cur_val;
    {scan file name}
    scan_pdf_ext_toks;
    s := tokens_to_string(def_ref);
    delete_token_ref(def_ref);
    def_ref := save_def_ref;
    warning_index := save_warning_index;
    scanner_status := save_scanner_status;
    b := pool_ptr;
    getfiledump(s, i, j);
    link(garbage) := str_toks(b);
    flush_str(s);
    ins_list(link(temp_head));
    restore_cur_string;
    return;
  end;
uniform_deviate_code:     scan_int;
normal_deviate_code:      do_nothing;
Uchar_convert_code: begin scan_char_num;
    if check_echar_range(cur_val) then cat:=other_kchar;
    end;
Ucharcat_convert_code:
  begin
    scan_char_num;
    i:=cur_val;
    scan_int;
    if illegal_Ucharcat_catcode(cur_val) then
      begin print_err("Invalid code ("); print_int(cur_val);
@.Invalid code@>
        print("), should be in the ranges 1..4, 6..8, 10..13, 16..19");
        help1("I'm going to use 12 instead of that illegal code value.");@/
        error; cat:=other_char;
      end 
    else cat:=cur_val;
    cur_val:=i;
    end;
@z

@x
@ @<Print the result of command |c|@>=
case c of
number_code: print_int(cur_val);
roman_numeral_code: print_roman_int(cur_val);
string_code:if cur_cs<>0 then sprint_cs(cur_cs)
  else print_char(cur_chr);
@y
@ @<Print the result of command |c|@>=
case c of
number_code: print_int(cur_val);
roman_numeral_code: print_roman_int(cur_val);
kansuji_code: print_kansuji(cur_val);
jis_code:   begin cur_val:=fromJIS(cur_val);
  if cur_val=0 then print_int(-1) else print_int(cur_val); end;
euc_code:   begin cur_val:=fromEUC(cur_val);
  if cur_val=0 then print_int(-1) else print_int(cur_val); end;
sjis_code:  begin cur_val:=fromSJIS(cur_val);
  if cur_val=0 then print_int(-1) else print_int(cur_val); end;
kuten_code: begin cur_val:=fromKUTEN(cur_val);
  if cur_val=0 then print_int(-1) else print_int(cur_val); end;
ucs_code:   if (isinternalUPTEX) then print_int(fromUCS(cur_val))
  else begin cur_val:=fromUCS(cur_val);
  if cur_val=0 then print_int(-1) else print_int(cur_val); end;
toucs_code: if (isinternalUPTEX) then print_int(toUCS(cur_val))
  else begin cur_val:=toUCS(cur_val);
  if cur_val=0 then print_int(-1) else print_int(cur_val); end;
tojis_code: begin cur_val:=toJIS(cur_val);
  if cur_val=0 then print_int(-1) else print_int(cur_val); end;
ptex_font_name_code: begin
  print_font_name_and_size(cur_val);
  print_font_dir_and_enc(cur_val);
  end;
ptex_revision_code: print(pTeX_revision);
uptex_revision_code: print(upTeX_revision);
nptex_revision_code: print(npTeX_revision);
string_code:if cur_cs<>0 then sprint_cs(cur_cs)
  else if cur_chr<@"80 then print_char(cur_chr)
  else if cur_cmd>=kanji then print_kanji(cur_chr)
  else print_utf8(cur_chr);
@z

@x
eTeX_revision_code: print(eTeX_revision);
@y
eTeX_revision_code: print(eTeX_revision);
pdf_strcmp_code: print_int(cur_val);
uniform_deviate_code:     print_int(unif_rand(cur_val));
normal_deviate_code:      print_int(norm_rand);
Uchar_convert_code:
if is_char_ascii(cur_val) then print_utf8(cur_val) else print_kanji(cur_val);
Ucharcat_convert_code:
if cat<kanji then print_utf8(cur_val) else print_kanji(cur_val);
@z

@x
@d if_case_code=16 { `\.{\\ifcase}' }
@y
@d if_case_code=16 { `\.{\\ifcase}' }
@#
@d if_in_csname_code=20 { `\.{\\ifincsname}';  |if_font_char_code| + 1 }
@d if_pdfprimitive_code=21 { `\.{\\ifpdfprimitive}' }
@#
@d if_tdir_code=if_pdfprimitive_code+1 { `\.{\\iftdir}' }
@d if_ydir_code=if_tdir_code+1 { `\.{\\ifydir}' }
@d if_ddir_code=if_ydir_code+1 { `\.{\\ifddir}' }
@d if_mdir_code=if_ddir_code+1 { `\.{\\ifmdir}' }
@d if_tbox_code=if_mdir_code+1 { `\.{\\iftbox}' }
@d if_ybox_code=if_tbox_code+1 { `\.{\\ifybox}' }
@d if_dbox_code=if_ybox_code+1 { `\.{\\ifdbox}' }
@d if_mbox_code=if_dbox_code+1 { `\.{\\ifmbox}' }
@#
@d if_jfont_code=if_mbox_code+1  { `\.{\\ifjfont}' }
@d if_tfont_code=if_jfont_code+1 { `\.{\\iftfont}' }
@#
@d if_cjk_cat_code=if_tfont_code+1  { `\.{\\ifcjkcat}' }
@d if_cjk_token_code=if_cjk_cat_code+1  { `\.{\\ifcjktoken}' }
@z

@x
primitive("ifcase",if_test,if_case_code);
@!@:if_case_}{\.{\\ifcase} primitive@>
@y
primitive("ifcase",if_test,if_case_code);
@!@:if_case_}{\.{\\ifcase} primitive@>
primitive("iftdir",if_test,if_tdir_code);
@!@:if_tdir_}{\.{\\iftdir} primitive@>
primitive("ifydir",if_test,if_ydir_code);
@!@:if_ydir_}{\.{\\ifydir} primitive@>
primitive("ifddir",if_test,if_ddir_code);
@!@:if_ddir_}{\.{\\ifddir} primitive@>
primitive("ifmdir",if_test,if_mdir_code);
@!@:if_mdir_}{\.{\\ifmdir} primitive@>
primitive("iftbox",if_test,if_tbox_code);
@!@:if_tbox_}{\.{\\iftbox} primitive@>
primitive("ifybox",if_test,if_ybox_code);
@!@:if_ybox_}{\.{\\ifybox} primitive@>
primitive("ifdbox",if_test,if_dbox_code);
@!@:if_dbox_}{\.{\\ifdbox} primitive@>
primitive("ifmbox",if_test,if_mbox_code);
@!@:if_mbox_}{\.{\\ifmbox} primitive@>
primitive("ifjfont",if_test,if_jfont_code);
@!@:if_jfont_}{\.{\\ifjfont} primitive@>
primitive("iftfont",if_test,if_tfont_code);
@!@:if_tfont_}{\.{\\iftfont} primitive@>
primitive("ifcjkcat",if_test,if_cjk_cat_code);
@!@:if_cjk_cat_}{\.{\\ifcjkcat} primitive@>
primitive("ifcjktoken",if_test,if_cjk_token_code);
@!@:if_cjk_token_}{\.{\\ifcjktoken} primitive@>
@z

@x
  if_case_code:print_esc("ifcase");
@y
  if_case_code:print_esc("ifcase");
  if_tdir_code:print_esc("iftdir");
  if_ydir_code:print_esc("ifydir");
  if_ddir_code:print_esc("ifddir");
  if_mdir_code:print_esc("ifmdir");
  if_tbox_code:print_esc("iftbox");
  if_ybox_code:print_esc("ifybox");
  if_dbox_code:print_esc("ifdbox");
  if_mbox_code:print_esc("ifmbox");
  if_pdfprimitive_code:print_esc("ifpdfprimitive");
  if_jfont_code:print_esc("ifjfont");
  if_tfont_code:print_esc("iftfont");
  if_cjk_cat_code:print_esc("ifcjkcat");
  if_cjk_token_code:print_esc("ifcjktoken");
@z

@x
var b:boolean; {is the condition true?}
@!r:"<"..">"; {relation to be evaluated}
@y
var b:boolean; {is the condition true?}
@!e:boolean; {keep track of nested csnames}
@!r:"<"..">"; {relation to be evaluated}
@z

@x
if_char_code, if_cat_code: @<Test if two characters match@>;
@y
if_char_code, if_cat_code, if_cjk_cat_code: @<Test if two characters match@>;
@z

@x
if_void_code, if_hbox_code, if_vbox_code: @<Test box register status@>;
@y
if_tdir_code: b:=(abs(direction)=dir_tate);
if_ydir_code: b:=(abs(direction)=dir_yoko);
if_ddir_code: b:=(abs(direction)=dir_dtou);
if_mdir_code: b:=(direction<0);
if_tbox_code, if_ybox_code, if_dbox_code, if_mbox_code,
if_void_code, if_hbox_code, if_vbox_code: @<Test box register status@>;
if_pdfprimitive_code: begin
  save_scanner_status:=scanner_status;
  scanner_status:=normal;
  get_next;
  scanner_status:=save_scanner_status;
  if cur_cs < hash_base then
    m := prim_lookup(cur_cs-single_base)
  else
    m := prim_lookup(text(cur_cs));
  b :=((cur_cmd<>undefined_cs) and
       (m<>undefined_primitive) and
       (cur_cmd=prim_eq_type(m)) and
       (cur_chr=prim_equiv(m)));
  end;
if_jfont_code, if_tfont_code:
  begin scan_font_ident;
  if this_if=if_jfont_code then b:=(font_dir[cur_val]=dir_yoko)
  else if this_if=if_tfont_code then b:=(font_dir[cur_val]=dir_tate);
  end;
if_cjk_token_code: 
  begin get_next; b:=(cur_cmd>=cjk_code_flag);
  end;
@z

@x
if this_if=if_void_code then b:=(p=null)
else if p=null then b:=false
else if this_if=if_hbox_code then b:=(type(p)=hlist_node)
else b:=(type(p)=vlist_node);
@y
if this_if=if_void_code then b:=(p=null)
else if p=null then b:=false
else begin
  if type(p)=dir_node then p:=list_ptr(p);
  if this_if=if_hbox_code then b:=(type(p)=hlist_node)
  else if this_if=if_vbox_code then b:=(type(p)=vlist_node)
  else if this_if=if_tbox_code then b:=(abs(box_dir(p))=dir_tate)
  else if this_if=if_ybox_code then b:=(abs(box_dir(p))=dir_yoko)
  else if this_if=if_dbox_code then b:=(abs(box_dir(p))=dir_dtou)
  else b:=(box_dir(p)<0);
  end
@z

@x
if (cur_cmd>active_char)or(cur_chr>255) then {not a character}
  begin m:=relax; n:=256;
  end
else  begin m:=cur_cmd; n:=cur_chr;
  end;
get_x_token_or_active_char;
if (cur_cmd>active_char)or(cur_chr>255) then
  begin cur_cmd:=relax; cur_chr:=256;
  end;
if this_if=if_char_code then b:=(n=cur_chr)@+else b:=(m=cur_cmd);
@y
if (cur_cmd>=kanji)and(cur_cmd<=hangul) then
  begin m:=cur_cmd; n:=cur_chr;
  end
else if (cur_cmd>active_char)or(cur_chr>=max_char_val) then
  begin m:=relax; n:=max_char_val;
  end
else  begin m:=cur_cmd; n:=cur_chr;
  end;
get_x_token_or_active_char;
if (cur_cmd>=kanji)and(cur_cmd<=hangul) then
  begin cur_cmd:=cur_cmd;
  end {dummy}
else if (cur_cmd>active_char)or(cur_chr>=max_char_val) then
  begin cur_cmd:=relax; cur_chr:=max_char_val;
  end;
if this_if=if_char_code then b:=(n=cur_chr)
else if this_if=if_cat_code then
  b:=((m mod cjk_code_flag)=(cur_cmd mod cjk_code_flag))
else b:=(m=cur_cmd);
@z

@x
@p procedure begin_name;
begin area_delimiter:=0; ext_delimiter:=0; quoted_filename:=false;
end;
@y
@p procedure begin_name;
begin area_delimiter:=0; ext_delimiter:=0; quoted_filename:=false; prev_char:=0;
end;
@z

@x
else  begin str_room(1); append_char(c); {contribute |c| to the current string}
  if IS_DIR_SEP(c) then
    begin area_delimiter:=cur_length; ext_delimiter:=0;
    end
  else if c="." then ext_delimiter:=cur_length;
  more_name:=true;
  end;
end;
@y
else  begin str_room(1); append_char(c); {contribute |c| to the current string}
  if (IS_DIR_SEP(c)and(not_kanji_char_seq(prev_char,c))) then
    begin area_delimiter:=cur_length; ext_delimiter:=0;
    end
  else if c="." then ext_delimiter:=cur_length;
  more_name:=true;
  end;
  prev_char:=c;
end;
@z

@x
@d print_quoted(#) == {print string |#|, omitting quotes}
if #<>0 then
  for j:=str_start[#] to str_start[#+1]-1 do
    if so(str_pool[j])<>"""" then
      print(so(str_pool[j]))

@y
@z

@x
@d append_to_name(#)==begin c:=#; if not (c="""") then begin incr(k);
  if k<=file_name_size then name_of_file[k]:=xchr[c];
  end end
@y
@d append_to_name_char(#)==begin incr(k);
  if k<=file_name_size then name_of_file[k]:=xchr[#];
  end

@d append_to_name_hex(#)==if (#)<10 then append_to_name_char((#)+"0")
  else append_to_name_char((#)-10+"a")

@d append_to_name(#)==begin c:=#; if not (c="""") then append_to_name_char(c); end

@d append_to_name_escape(#)==begin
  c:=(#) mod @"100; append_to_name_char(c);
end

@d append_to_name_str_pool(#)==if not ((#)="""") then append_to_name_escape(#)
@z

@x
name_of_file:= xmalloc_array (ASCII_code, length(a)+length(n)+length(e)+1);
@y
name_of_file:= xmalloc_array (ASCII_code, (length(a)+length(n)+length(e))*4+1);
@z

@x
for j:=str_start[a] to str_start[a+1]-1 do append_to_name(so(str_pool[j]));
for j:=str_start[n] to str_start[n+1]-1 do append_to_name(so(str_pool[j]));
for j:=str_start[e] to str_start[e+1]-1 do append_to_name(so(str_pool[j]));
@y
for j:=str_start[a] to str_start[a+1]-1 do append_to_name_str_pool(so(str_pool[j]));
for j:=str_start[n] to str_start[n+1]-1 do append_to_name_str_pool(so(str_pool[j]));
for j:=str_start[e] to str_start[e+1]-1 do append_to_name_str_pool(so(str_pool[j]));
@z

@x
name_of_file := xmalloc_array (ASCII_code, n+(b-a+1)+format_ext_length+1);
@y
name_of_file := xmalloc_array (ASCII_code, (n+(b-a+1)+format_ext_length)*4+1);
@z

@x
loop@+begin if (cur_cmd>other_char)or(cur_chr>255) then {not a character}
    begin back_input; goto done;
    end;
  {If |cur_chr| is a space and we're not scanning a token list, check
   whether we're at the end of the buffer. Otherwise we end up adding
   spurious spaces to file names in some cases.}
  if (cur_chr=" ") and (state<>token_list) and (loc>limit) then goto done;
  if not more_name(cur_chr) then goto done;
  get_x_token;
  end;
  end;
done: end_name; name_in_progress:=false;
@y
skip_mode:=false;
loop@+begin
  if (cur_cmd mod cjk_code_flag>other_char)or(cur_chr>max_char_val) then {not an alphabet}
    begin back_input; goto done;
    end
  {If |cur_chr| is a space and we're not scanning a token list, check
   whether we're at the end of the buffer. Otherwise we end up adding
   spurious spaces to file names in some cases.}
   else if ((cur_chr=" ") and (state<>token_list) and (loc>limit)) or not more_name(cur_chr) then goto done;
  get_x_token;
  end;
  end;
done: end_name; name_in_progress:=false;
skip_mode:=true;
@z

@x
if buffer[l]=end_line_char then decr(l);
for k:=1 to l do print(buffer[k]);
print_ln; {now the transcript file contains the first line of input}
@y
if buffer[l]=end_line_char then decr(l); print_unread_buffer_with_ptenc(1,l+1);
print_ln; {now the transcript file contains the first line of input}
@z

@x
begin
if src_specials_p or file_line_error_style_p or parse_first_line_p
then
  wlog(banner_k)
else
  wlog(banner);
@y
begin
if src_specials_p or file_line_error_style_p or parse_first_line_p
then
  wlog(banner_k)
else
  wlog(banner);
  wlog(' (');
  wlog(conststringcast(get_enc_string));
  wlog(')');
@z

@x
print_char("("); incr(open_parens);
slow_print(full_source_filename_stack[in_open]); update_terminal;
@y
print_char("("); incr(open_parens);
slow_print_filename(full_source_filename_stack[in_open]); update_terminal;
@z

@x
This is called BigEndian order.
@!@^BigEndian order@>
@y
This is called BigEndian order.
@!@^BigEndian order@>

We get \TeX\ knowledge about KANJI fonts from \.{JFM} files.
The \.{JFM} format holds more two 16-bit integers, |id| and |nt|,
at the top of the file.
$$\vbox{\halign{\hfil#&$\null=\null$#\hfil\cr
|id|&identification code of the file;\cr
|nt|&number of words in the |char_type| table;\cr}}$$
The identification byte, |id| equals~11 or~9. When \TeX\ reads a font file,
the |id| equals~11 or~9 then the font is the \.{JFM}, othercases it is
the \.{TFM} file. The \.{TFM} holds |lf| at the same postion of |id|,
usually it takes a larger number than~9 or~11.
The |nt| is nonnegative and less than $2^{15}$.

We must have |bc=0|,
$$\hbox{|lf=7+lh+nt+(ec-bc+1)+nw+nh+nd+ni+nl+nk+ne+np|.}$$

@d yoko_jfm_id=11 {for `yoko-kumi' fonts}
@d tate_jfm_id=9  {for `tate-kumi' fonts}
@z

@x
operation looks for both |list_tag| and |ext_tag|.
@y
operation looks for both |list_tag| and |ext_tag|.

If the \.{JFM}, the |lig_tag| is called |gk_tag|. The |gk_tag| means that
this character has a glue/kerning program starting at position |remainder|
in the |glue_kern| array. And a \.{JFM} does not use |tag=2| and |tag=3|.
@z

@x
@d lig_tag=1 {character has a ligature/kerning program}
@y
@d lig_tag=1 {character has a ligature/kerning program}
@d gk_tag=1 {character has a glue/kerning program}
@z

@x
@<Glob...@>=
@!font_info: ^fmemory_word;
@y
@<Glob...@>=
@!font_info: ^memory_word; {pTeX: use halfword for |char_type| table.}
@!font_dir: ^eight_bits;
  {pTeX: direction of fonts, 0 is default, 1 is Yoko, 2 is Tate}
@!font_enc: ^eight_bits;
  {pTeX: encoding of fonts, 0 is default, 1 is JIS, 2 is Unicode}
@!font_num_ext: ^integer;
  {pTeX: number of the |char_type| table.}
@!jfm_enc: eight_bits; {pTeX: holds scanned result of encoding}
@z

@x
@!char_base: ^integer;
  {base addresses for |char_info|}
@y
@!char_base: ^integer;
  {base addresses for |char_info|}
@!ctype_base: ^integer;
  {pTeX: base addresses for KANJI character type parameters}
@z

@x
@ @<Set init...@>=
@y
@ @<Set init...@>=
jfm_enc:=0;
@z

@x
@d orig_char_info_end(#)==#].qqqq
@d orig_char_info(#)==font_info[char_base[#]+orig_char_info_end
@y
@d orig_char_info_end(#)==#].qqqq
@d orig_char_info(#)==font_info[char_base[#]+orig_char_info_end
@#
@d kchar_code_end(#)==#].hh.rh
@d kchar_code(#)==font_info[ctype_base[#]+kchar_code_end
@d kchar_type_end(#)==#].hh.lhfield
@d kchar_type(#)==font_info[ctype_base[#]+kchar_type_end
@z

@x
@d lig_kern_start(#)==lig_kern_base[#]+rem_byte {beginning of lig/kern program}
@d lig_kern_restart_end(#)==256*op_byte(#)+rem_byte(#)+32768-kern_base_offset
@d lig_kern_restart(#)==lig_kern_base[#]+lig_kern_restart_end
@y
@d lig_kern_start(#)==lig_kern_base[#]+rem_byte {beginning of lig/kern program}
@d lig_kern_restart_end(#)==256*op_byte(#)+rem_byte(#)+32768-kern_base_offset
@d lig_kern_restart(#)==lig_kern_base[#]+lig_kern_restart_end
@d glue_kern_start(#)==lig_kern_base[#]+rem_byte {beginning of glue/kern program}
@d glue_kern_restart_end(#)==256*op_byte(#)+rem_byte(#)+32768-kern_base_offset
@d glue_kern_restart(#)==lig_kern_base[#]+glue_kern_restart_end
@z

@x
var k:font_index; {index into |font_info|}
@y
var k:font_index; {index into |font_info|}
@!jfm_flag:dir_default..dir_tate; {direction of the \.{JFM}}
@!nt:halfword; {number of the |char_type| tables}
@!cx:KANJI_code; {kanji code}
@z

@x
@d read_sixteen(#)==begin #:=fbyte;
  if #>127 then abort;
  fget; #:=#*@'400+fbyte;
  end
@y
@d read_sixteen(#)==begin #:=fbyte;
  if #>127 then abort;
  fget; #:=#*@'400+fbyte;
  end
@d read_twentyfourx(#)==begin #:=fbyte;
  fget; #:=#*@"100+fbyte;
  fget; #:=#+fbyte*@"10000;
  end
@z

@x
@ @<Read the {\.{TFM}} size fields@>=
begin read_sixteen(lf);
fget; read_sixteen(lh);
fget; read_sixteen(bc);
fget; read_sixteen(ec);
if (bc>ec+1)or(ec>255) then abort;
if bc>255 then {|bc=256| and |ec=255|}
  begin bc:=1; ec:=0;
  end;
fget; read_sixteen(nw);
fget; read_sixteen(nh);
fget; read_sixteen(nd);
fget; read_sixteen(ni);
fget; read_sixteen(nl);
fget; read_sixteen(nk);
fget; read_sixteen(ne);
fget; read_sixteen(np);
if lf<>6+lh+(ec-bc+1)+nw+nh+nd+ni+nl+nk+ne+np then abort;
if (nw=0)or(nh=0)or(nd=0)or(ni=0) then abort;
end
@y
@ @<Read the {\.{TFM}} size fields@>=
begin read_sixteen(lf);
fget; read_sixteen(lh);
if lf=yoko_jfm_id then
  begin jfm_flag:=dir_yoko; nt:=lh;
  fget; read_sixteen(lf);
  fget; read_sixteen(lh);
  end
else if lf=tate_jfm_id then
  begin jfm_flag:=dir_tate; nt:=lh;
  fget; read_sixteen(lf);
  fget; read_sixteen(lh);
  end
else begin jfm_flag:=dir_default; nt:=0;
  end;
fget; read_sixteen(bc);
fget; read_sixteen(ec);
if (bc>ec+1)or(ec>255) then abort;
if bc>255 then {|bc=256| and |ec=255|}
  begin bc:=1; ec:=0;
  end;
fget; read_sixteen(nw);
fget; read_sixteen(nh);
fget; read_sixteen(nd);
fget; read_sixteen(ni);
fget; read_sixteen(nl);
fget; read_sixteen(nk);
fget; read_sixteen(ne);
fget; read_sixteen(np);
if jfm_flag<>dir_default then
  begin if lf<>7+lh+nt+(ec-bc+1)+nw+nh+nd+ni+nl+nk+ne+np then abort;
  end
else
  begin if lf<>6+lh+(ec-bc+1)+nw+nh+nd+ni+nl+nk+ne+np then abort;
  end;
if (nw=0)or(nh=0)or(nd=0)or(ni=0) then abort;
end
@z

@x
@<Use size fields to allocate font information@>=
lf:=lf-6-lh; {|lf| words should be loaded into |font_info|}
if np<7 then lf:=lf+7-np; {at least seven parameters will appear}
if (font_ptr=font_max)or(fmem_ptr+lf>font_mem_size) then
  @<Apologize for not loading the font, |goto done|@>;
f:=font_ptr+1;
char_base[f]:=fmem_ptr-bc;
width_base[f]:=char_base[f]+ec+1;
height_base[f]:=width_base[f]+nw;
depth_base[f]:=height_base[f]+nh;
italic_base[f]:=depth_base[f]+nd;
lig_kern_base[f]:=italic_base[f]+ni;
kern_base[f]:=lig_kern_base[f]+nl-kern_base_offset;
exten_base[f]:=kern_base[f]+kern_base_offset+nk;
param_base[f]:=exten_base[f]+ne
@y
@<Use size fields to allocate font information@>=
if jfm_flag<>dir_default then
  lf:=lf-7-lh  {If \.{JFM}, |lf| holds more two-16bit records than \.{TFM}}
else
  lf:=lf-6-lh; {|lf| words should be loaded into |font_info|}
if np<7 then lf:=lf+7-np; {at least seven parameters will appear}
if (font_ptr=font_max)or(fmem_ptr+lf>font_mem_size) then
  @<Apologize for not loading the font, |goto done|@>;
f:=font_ptr+1;
font_dir[f]:=jfm_flag;
font_enc[f]:=jfm_enc; if jfm_flag=dir_default then font_enc[f]:=0;
font_num_ext[f]:=nt;
ctype_base[f]:=fmem_ptr;
char_base[f]:=ctype_base[f]+nt-bc;
width_base[f]:=char_base[f]+ec+1;
height_base[f]:=width_base[f]+nw;
depth_base[f]:=height_base[f]+nh;
italic_base[f]:=depth_base[f]+nd;
lig_kern_base[f]:=italic_base[f]+ni;
kern_base[f]:=lig_kern_base[f]+nl-kern_base_offset;
exten_base[f]:=kern_base[f]+kern_base_offset+nk;
param_base[f]:=exten_base[f]+ne;
@z

@x
@ @<Read character data@>=
for k:=fmem_ptr to width_base[f]-1 do
  begin store_four_quarters(font_info[k].qqqq);
@y
@ @<Read character data@>=
if jfm_flag<>dir_default then
  for k:=ctype_base[f] to ctype_base[f]+nt-1 do
    begin
    fget; read_twentyfourx(cx);
    if jfm_enc=2 then {Unicode TFM}
      font_info[k].hh.rh:=toDVI(fromUCS(cx))
    else if jfm_enc=1 then {JIS-encoded TFM}
      font_info[k].hh.rh:=toDVI(fromJIS(cx))
    else
      font_info[k].hh.rh:=tokanji(cx); {|kchar_code|}
    fget; cx:=fbyte;
    font_info[k].hh.lhfield:=tonum(cx); {|kchar_type|}
    end;
for k:=char_base[f]+bc to width_base[f]-1 do
  begin store_four_quarters(font_info[k].qqqq);
@z

@x
@d current_character_being_worked_on==k+bc-fmem_ptr
@y
@d current_character_being_worked_on==k-char_base[f]
@z

@x
    if a>128 then
      begin if 256*c+d>=nl then abort;
      if a=255 then if k=lig_kern_base[f] then bchar:=b;
      end
    else begin if b<>bchar then check_existence(b);
      if c<128 then check_existence(d) {check ligature}
      else if 256*(c-128)+d>=nk then abort; {check kern}
      if a<128 then if k-lig_kern_base[f]+a+1>=nl then abort;
      end;
    end;
@y
    if a>128 then
      begin if 256*c+d>=nl then abort;
      if a=255 then if k=lig_kern_base[f] then bchar:=b;
      end
    else begin if b<>bchar then check_existence(b);
      if c<128 then begin
          if jfm_flag<>dir_default then begin if d>=ne then abort; end
        else check_existence(d); {check ligature}
      end else if 256*(c-128)+d>=nk then abort; {check kern}
      if a<128 then if k-lig_kern_base[f]+a+1>=nl then abort;
      end;
    end;
@z

@x
for k:=exten_base[f] to param_base[f]-1 do
  begin store_four_quarters(font_info[k].qqqq);
@y
if jfm_flag<>dir_default then
  for k:=exten_base[f] to param_base[f]-1 do
    store_scaled(font_info[k].sc) {NOTE: this area subst for glue program}
else for k:=exten_base[f] to param_base[f]-1 do
  begin store_four_quarters(font_info[k].qqqq);
@z

@x
adjust(char_base); adjust(width_base); adjust(lig_kern_base);
@y
adjust(ctype_base);
adjust(char_base); adjust(width_base); adjust(lig_kern_base);
@z

@x
if cur_cmd=def_font then f:=cur_font
@y
if cur_cmd=def_jfont then f:=cur_jfont
else if cur_cmd=def_tfont then f:=cur_tfont
else if cur_cmd=def_font then f:=cur_font
@z

@x
else if cur_cmd=def_family then
  begin m:=cur_chr; scan_four_bit_int; f:=equiv(m+cur_val);
@y
else if cur_cmd=def_family then
  begin m:=cur_chr; scan_big_four_bit_int; f:=equiv(m+cur_val);
@z

@x
else  begin print_err("Missing font identifier");
@y
else if (cur_cmd=last_item)and(cur_chr=last_node_font_code) then
  begin scan_something_internal_ident; f:=cur_val-font_id_base;
  end
else  begin print_err("Missing font identifier");
@z

@x
@p procedure char_warning(@!f:internal_font_number;@!c:eight_bits);
var old_setting: integer; {saved value of |tracing_online|}
@y
@d print_lc_hex(#)==l:=#;
  if l<10 then print_char(l+"0")@+else print_char(l-10+"a")

@p procedure char_warning(@!f:internal_font_number;@!c:integer);
var @!l:0..255; {small indices or counters}
old_setting: integer; {saved value of |tracing_online|}
@z

@x
  print_ASCII(c); print(" in font ");
@y
  if (c<" ")or(c>"~") then
    begin print_char("^"); print_char("^");
    if c<64 then print_char(c+64)
    else if c<128 then print_char(c-64)
    else begin print_lc_hex(c div 16);  print_lc_hex(c mod 16); end
    end
  else print_ASCII(c);
  print(" in font ");
@z

@x
@ Here is a function that returns a pointer to a character node for a
@y
@ Another warning for (u)\pTeX.

@p procedure char_warning_jis(@!f:internal_font_number;@!jc:KANJI_code);
begin if tracing_lost_chars>0 then
  begin begin_diagnostic;
  print_nl("Character "); print_kanji(jc); print(" (");
  print_hex(jc); print(") cannot be typeset in JIS-encoded JFM ");
  slow_print(font_name[f]);
  print_char(","); print_nl("so I use .notdef glyph instead.");
  end_diagnostic(false);
  end;
end;

@ Here is a function that returns a pointer to a character node for a
@z

@x
@d set1=128 {typeset a character and move right}
@y
@d set1=128 {typeset a character and move right}
@d set2=129 {typeset a character and move right}
@d set3=130 {typeset a character and move right}
@z

@x
@d post_post=249 {postamble ending}
@y
@d post_post=249 {postamble ending}
@d dirchg=255 {direction change}
@z

@x
@d id_byte=2 {identifies the kind of \.{DVI} files described here}
@y
@d id_byte=2 {identifies the kind of \.{DVI} files described here}
@d ex_id_byte=3 {identifies the kind of extended \.{DVI} files}
@z

@x
@ The last part of the postamble, following the |post_post| byte that
signifies the end of the font definitions, contains |q|, a pointer to the
|post| command that started the postamble.  An identification byte, |i|,
comes next; this currently equals~2, as in the preamble.
@y
@ The last part of the postamble, following the |post_post| byte that
signifies the end of the font definitions, contains |q|, a pointer to the
|post| command that started the postamble.  An identification byte, |i|,
comes next; this equals~2 or~3. If \pTeX\ primitives are not used then the
identification byte equals~2, othercase this is set to~3.
@z

@x
 {character and font in current |char_node|}
@!c:quarterword;
@!f:internal_font_number;
@y
 {character and font in current |char_node|}
@!c:quarterword;
@!f:internal_font_number;
@!dir_used:boolean; {Is this dvi extended?}
@z

@x
doing_leaders:=false; dead_cycles:=0; cur_s:=-1;
@y
doing_leaders:=false; dead_cycles:=0; cur_s:=-1; dir_used:=false;
@z

@x
@d box_lr(#) == (qo(subtype(#))) {direction mode of a box}
@d set_box_lr(#) ==  subtype(#):=set_box_lr_end
@d set_box_lr_end(#) == qi(#)
@y
@d box_lr(#) == ((qo(subtype(#)))div 16) {direction mode of a box}
@d set_box_lr(#) == subtype(#):=box_dir(#)+dir_max+set_box_lr_end
@d set_box_lr_end(#) == qi(16*(#))
@z

@x
@ @<Initialize variables as |ship_out| begins@>=
@y
@ @<Initialize variables as |ship_out| begins@>=
@<Calculate DVI page dimensions and margins@>;
@z

@x
dvi_h:=0; dvi_v:=0; cur_h:=h_offset; dvi_f:=null_font;
@y
dvi_h:=0; dvi_v:=0; cur_h:=h_offset; dvi_f:=null_font;
dvi_dir:=dir_yoko; cur_dir_hv:=dvi_dir;
@z

@x
procedure hlist_out; {output an |hlist_node| box}
label reswitch, move_past, fin_rule, next_p, continue, found;
var base_line: scaled; {the baseline coordinate for this box}
@y
procedure hlist_out; {output an |hlist_node| box}
label reswitch, move_past, fin_rule, next_p, continue, found;
var base_line: scaled; {the baseline coordinate for this box}
@!disp: scaled; {displacement}
@!save_dir:eight_bits; {what |dvi_dir| should pop to}
@!jc:KANJI_code; {temporary register for KANJI codes}
@!ksp_ptr:pointer; {position of |auto_spacing_glue| in the hlist}
@z

@x
incr(cur_s);
if cur_s>0 then dvi_out(push);
if cur_s>max_push then max_push:=cur_s;
save_loc:=dvi_offset+dvi_ptr; base_line:=cur_v;
prev_p:=this_box+list_offset;
@<Initialize |hlist_out| for mixed direction typesetting@>;
left_edge:=cur_h;
@y
ksp_ptr:=space_ptr(this_box);
incr(cur_s);
if cur_s>0 then dvi_out(push);
if cur_s>max_push then max_push:=cur_s;
save_loc:=dvi_offset+dvi_ptr;
synch_dir;
base_line:=cur_v; disp:=0; revdisp:=0;
prev_p:=this_box+list_offset;
@<Initialize |hlist_out| for mixed direction typesetting@>;
left_edge:=cur_h;
@z

@x
@<Output node |p| for |hlist_out|...@>=
reswitch: if is_char_node(p) then
  begin synch_h; synch_v;
  repeat f:=font(p); c:=character(p);
  if f<>dvi_f then @<Change font |dvi_f| to |f|@>;
  if font_ec[f]>=qo(c) then if font_bc[f]<=qo(c) then
    if char_exists(orig_char_info(f)(c)) then  {N.B.: not |char_info|}
      begin if c>=qi(128) then dvi_out(set1);
      dvi_out(qo(c));@/
      cur_h:=cur_h+char_width(f)(orig_char_info(f)(c));
      goto continue;
      end;
  if mltex_enabled_p then
    @<Output a substitution, |goto continue| if not possible@>;
continue:
  prev_p:=link(prev_p); {N.B.: not |prev_p:=p|, |p| might be |lig_trick|}
  p:=link(p);
  until not is_char_node(p);
  dvi_h:=cur_h;
  end
else @<Output the non-|char_node| |p| for |hlist_out|
    and move to the next node@>
@y
@<Output node |p| for |hlist_out|...@>=
reswitch: if is_char_node(p) then
  begin synch_h; synch_v;
  chain:=false;
  repeat f:=font(p); c:=character(p);
  if f<>dvi_f then @<Change font |dvi_f| to |f|@>;
  if font_dir[f]=dir_default then
    begin chain:=false;
    if font_ec[f]>=qo(c) then if font_bc[f]<=qo(c) then
      if char_exists(orig_char_info(f)(c)) then  {N.B.: not |char_info|}
        begin if c>=qi(128) then dvi_out(set1);
        dvi_out(qo(c));@/
        cur_h:=cur_h+char_width(f)(orig_char_info(f)(c));
        goto continue;
        end;
    if mltex_enabled_p then
      @<Output a substitution, |goto continue| if not possible@>;
continue:
    end
  else
    begin if chain=false then chain:=true
    else begin cur_h:=cur_h+width(ksp_ptr);
      if g_sign<>normal then
        begin  if g_sign=stretching then
          begin  if stretch_order(ksp_ptr)=g_order then
            cur_h:=cur_h+round(float(glue_set(this_box))*stretch(ksp_ptr));
@^real multiplication@>
          end
        else
          begin  if shrink_order(ksp_ptr)=g_order then
            cur_h:=cur_h-round(float(glue_set(this_box))*shrink(ksp_ptr));
@^real multiplication@>
          end;
        end;
      synch_h;
      end;
    prev_p:=link(prev_p); {N.B.: not |prev_p:=p|, |p| might be |lig_trick|}
    p:=link(p);
    jc:=KANJI(info(p)) mod max_char_val;
    if font_enc[f]=2 then {Unicode TFM}
      jc:=toUCS(jc)
    else if font_enc[f]=1 then {JIS-encoded TFM}
      begin if toJIS(jc)=0 then char_warning_jis(f,jc);
      jc:=toJIS(jc); end
    else
      jc:=toDVI(jc);
    if (jc<@"10000) then begin
      dvi_out(set2);
    end else begin
      dvi_out(set3); dvi_out(BYTE2(jc));
    end;
    dvi_out(BYTE3(jc)); dvi_out(BYTE4(jc));
    cur_h:=cur_h+char_width(f)(orig_char_info(f)(c)); {not |jc|}
    end;
  dvi_h:=cur_h; p:=link(p);
  until not is_char_node(p);
  chain:=false;
  end
else @<Output the non-|char_node| |p| for |hlist_out|
    and move to the next node@>
@z

@x
@ @<Output the non-|char_node| |p| for |hlist_out|...@>=
begin case type(p) of
hlist_node,vlist_node:@<Output a box in an hlist@>;
rule_node: begin rule_ht:=height(p); rule_dp:=depth(p); rule_wd:=width(p);
  goto fin_rule;
  end;
whatsit_node: @<Output the whatsit node |p| in an hlist@>;
@y
@ @<Output the non-|char_node| |p| for |hlist_out|...@>=
begin case type(p) of
hlist_node,vlist_node,dir_node:@<Output a box in an hlist@>;
rule_node: begin rule_ht:=height(p); rule_dp:=depth(p); rule_wd:=width(p);
  goto fin_rule;
  end;
whatsit_node: @<Output the whatsit node |p| in an hlist@>;
disp_node: begin disp:=disp_dimen(p); revdisp:=disp; cur_v:=base_line+disp; end;
@z

@x
@ @<Output a box in an hlist@>=
if list_ptr(p)=null then cur_h:=cur_h+width(p)
else  begin save_h:=dvi_h; save_v:=dvi_v;
  cur_v:=base_line+shift_amount(p); {shift the box down}
@y
@ @<Output a box in an hlist@>=
if list_ptr(p)=null then cur_h:=cur_h+width(p)
else  begin save_h:=dvi_h; save_v:=dvi_v; save_dir:=dvi_dir;
  cur_v:=base_line+disp+shift_amount(p); {shift the box down}
@z

@x
  if type(p)=vlist_node then vlist_out@+else hlist_out;
  dvi_h:=save_h; dvi_v:=save_v;
  cur_h:=edge; cur_v:=base_line;
  end
@y
  case type(p) of
    hlist_node:hlist_out;
    vlist_node:vlist_out;
    dir_node:dir_out;
  endcases;
  dvi_h:=save_h; dvi_v:=save_v; dvi_dir:=save_dir;
  cur_h:=edge; cur_v:=base_line+disp; cur_dir_hv:=save_dir;
  end
@z

@x
@ @<Output a rule in an hlist@>=
if is_running(rule_ht) then rule_ht:=height(this_box);
if is_running(rule_dp) then rule_dp:=depth(this_box);
@y
@ @<Output a rule in an hlist@>=
if is_running(rule_ht) then rule_ht:=height(this_box)+disp;
if is_running(rule_dp) then rule_dp:=depth(this_box)-disp;
@z

@x
@<Output a leader box at |cur_h|, ...@>=
begin cur_v:=base_line+shift_amount(leader_box); synch_v; save_v:=dvi_v;@/
synch_h; save_h:=dvi_h; temp_ptr:=leader_box;
@y
@<Output a leader box at |cur_h|, ...@>=
begin cur_v:=base_line+disp+shift_amount(leader_box); synch_v; save_v:=dvi_v;@/
synch_h; save_h:=dvi_h; save_dir:=dvi_dir; temp_ptr:=leader_box;
@z

@x
if type(leader_box)=vlist_node then vlist_out@+else hlist_out;
doing_leaders:=outer_doing_leaders;
dvi_v:=save_v; dvi_h:=save_h; cur_v:=base_line;
cur_h:=save_h+leader_wd+lx;
end
@y
case type(leader_box) of
  hlist_node:hlist_out;
  vlist_node:vlist_out;
  dir_node:dir_out;
endcases;
doing_leaders:=outer_doing_leaders;
dvi_v:=save_v; dvi_h:=save_h; dvi_dir:=save_dir;
cur_v:=base_line; cur_h:=save_h+leader_wd+lx; cur_dir_hv:=save_dir;
end
@z

@x
begin cur_g:=0; cur_glue:=float_constant(0);
this_box:=temp_ptr; g_order:=glue_order(this_box);
g_sign:=glue_sign(this_box); p:=list_ptr(this_box);
incr(cur_s);
if cur_s>0 then dvi_out(push);
if cur_s>max_push then max_push:=cur_s;
save_loc:=dvi_offset+dvi_ptr; left_edge:=cur_h; cur_v:=cur_v-height(this_box);
@y
@!save_dir:integer; {what |dvi_dir| should pop to}
begin cur_g:=0; cur_glue:=float_constant(0);
this_box:=temp_ptr; g_order:=glue_order(this_box);
g_sign:=glue_sign(this_box); p:=list_ptr(this_box);
incr(cur_s);
if cur_s>0 then dvi_out(push);
if cur_s>max_push then max_push:=cur_s;
save_loc:=dvi_offset+dvi_ptr;
synch_dir;
left_edge:=cur_h; cur_v:=cur_v-height(this_box);
@z

@x
@ @<Output the non-|char_node| |p| for |vlist_out|@>=
begin case type(p) of
hlist_node,vlist_node:@<Output a box in a vlist@>;
rule_node: begin rule_ht:=height(p); rule_dp:=depth(p); rule_wd:=width(p);
  goto fin_rule;
  end;
@y
@ @<Output the non-|char_node| |p| for |vlist_out|@>=
begin case type(p) of
hlist_node,vlist_node,dir_node: @<Output a box in a vlist@>;
rule_node: begin rule_ht:=height(p); rule_dp:=depth(p); rule_wd:=width(p);
  goto fin_rule;
  end;
@z

@x
@<Output a box in a vlist@>=
if list_ptr(p)=null then cur_v:=cur_v+height(p)+depth(p)
else  begin cur_v:=cur_v+height(p); synch_v;
  save_h:=dvi_h; save_v:=dvi_v;
@y
@<Output a box in a vlist@>=
if list_ptr(p)=null then cur_v:=cur_v+height(p)+depth(p)
else begin cur_v:=cur_v+height(p); synch_v;
  save_h:=dvi_h; save_v:=dvi_v; save_dir:=dvi_dir;
@z

@x
  if type(p)=vlist_node then vlist_out@+else hlist_out;
  dvi_h:=save_h; dvi_v:=save_v;
  cur_v:=save_v+depth(p); cur_h:=left_edge;
  end
@y
  case type(p) of
    hlist_node:hlist_out;
    vlist_node:vlist_out;
    dir_node:dir_out;
  endcases;
  dvi_h:=save_h; dvi_v:=save_v; dvi_dir:=save_dir;
  cur_v:=save_v+depth(p); cur_h:=left_edge; cur_dir_hv:=save_dir;
  end
@z

@x
@<Output a leader box at |cur_v|, ...@>=
@y
@<Output a leader box at |cur_v|, ...@>=
@z

@x
cur_v:=cur_v+height(leader_box); synch_v; save_v:=dvi_v;
temp_ptr:=leader_box;
outer_doing_leaders:=doing_leaders; doing_leaders:=true;
if type(leader_box)=vlist_node then vlist_out@+else hlist_out;
doing_leaders:=outer_doing_leaders;
dvi_v:=save_v; dvi_h:=save_h; cur_h:=left_edge;
cur_v:=save_v-height(leader_box)+leader_ht+lx;
end
@y
cur_v:=cur_v+height(leader_box); synch_v; save_v:=dvi_v; save_dir:=dvi_dir;
temp_ptr:=leader_box;
outer_doing_leaders:=doing_leaders; doing_leaders:=true;
case type(leader_box) of
  hlist_node:hlist_out;
  vlist_node:vlist_out;
  dir_node:dir_out;
endcases;
doing_leaders:=outer_doing_leaders;
dvi_v:=save_v; dvi_h:=save_h; dvi_dir:=save_dir;
cur_h:=left_edge; cur_v:=save_v-height(leader_box)+leader_ht+lx;
cur_dir_hv:=save_dir;
end
@z

@x
@p procedure ship_out(@!p:pointer); {output the box |p|}
label done;
var page_loc:integer; {location of the current |bop|}
@y
@p procedure ship_out(@!p:pointer); {output the box |p|}
label done;
var page_loc:integer; {location of the current |bop|}
@!del_node:pointer; {used when delete the |dir_node| continued box}
@z

@x
@<Ship box |p| out@>;
@y
if type(p)=dir_node then
  begin del_node:=p; p:=list_ptr(p);
  delete_glue_ref(space_ptr(del_node));
  delete_glue_ref(xspace_ptr(del_node));
  free_node(del_node,box_node_size);
  end;
flush_node_list(link(p)); link(p):=null;
if abs(box_dir(p))<>dir_yoko then p:=new_dir_node(p,dir_yoko);
@<Ship box |p| out@>;
@z

@x
if type(p)=vlist_node then vlist_out@+else hlist_out;
@y
case type(p) of
  hlist_node:hlist_out;
  vlist_node:vlist_out;
  dir_node:dir_out;
endcases;
@z

@x
  @<Output the font definitions for all fonts that were used@>;
  dvi_out(post_post); dvi_four(last_bop); dvi_out(id_byte);@/
@y
  @<Output the font definitions for all fonts that were used@>;
  dvi_out(post_post); dvi_four(last_bop);
  if dir_used then dvi_out(ex_id_byte) else dvi_out(id_byte);@/
@z

@x
@ If the global variable |adjust_tail| is non-null, the |hpack| routine
also removes all occurrences of |ins_node|, |mark_node|, and |adjust_node|
items and appends the resulting material onto the list that ends at
location |adjust_tail|.

@<Glob...@>=
@!adjust_tail:pointer; {tail of adjustment list}
@y
@ If the global variable |adjust_tail| is non-null, the |hpack| routine
also removes all occurrences of |ins_node|, |mark_node|, and |adjust_node|
items and appends the resulting material onto the list that ends at
location |adjust_tail|.

@<Glob...@>=
@!adjust_tail:pointer; {tail of adjustment list}
@!last_disp:scaled; {displacement at end of list}
@!cur_kanji_skip:pointer;
@!cur_xkanji_skip:pointer;
@z

@x
@ @<Set init...@>=adjust_tail:=null; last_badness:=0;
@y
@ @<Set init...@>=adjust_tail:=null; last_badness:=0;
  cur_kanji_skip:=zero_glue; cur_xkanji_skip:=zero_glue;
{ koko
  |incr(glue_ref_count(cur_kanji_skip));|
  |incr(glue_ref_count(cur_xkanji_skip));|
}
@z

@x
@p function hpack(@!p:pointer;@!w:scaled;@!m:small_number):pointer;
label reswitch, common_ending, exit;
var r:pointer; {the box node that will be returned}
@y
@p function hpack(@!p:pointer;@!w:scaled;@!m:small_number):pointer;
label reswitch, common_ending, exit;
var r:pointer; {the box node that will be returned}
@!k:pointer; {points to a |kanji_space| specification}
@!disp:scaled; {displacement}
@z

@x
q:=r+list_offset; link(q):=p;@/
h:=0; @<Clear dimensions to zero@>;
@y
set_box_dir(r)(dir_default);
space_ptr(r):=cur_kanji_skip; xspace_ptr(r):=cur_xkanji_skip;
add_glue_ref(cur_kanji_skip); add_glue_ref(cur_xkanji_skip);
k:=cur_kanji_skip;
q:=r+list_offset; link(q):=p;@/
h:=0; @<Clear dimensions to zero@>;
disp:=0;
@z

@x
while p<>null do @<Examine node |p| in the hlist, taking account of its effect
  on the dimensions of the new box, or moving it to the adjustment list;
  then advance |p| to the next node@>;
if adjust_tail<>null then link(adjust_tail):=null;
height(r):=h; depth(r):=d;@/
@<Determine the value of |width(r)| and the appropriate glue setting;
  then |return| or |goto common_ending|@>;
common_ending: @<Finish issuing a diagnostic message
      for an overfull or underfull hbox@>;
exit: if TeXXeT_en then @<Check for LR anomalies at the end of |hpack|@>;
hpack:=r;
end;
@y
while p<>null do @<Examine node |p| in the hlist, taking account of its effect
  on the dimensions of the new box, or moving it to the adjustment list;
  then advance |p| to the next node@>;
if adjust_tail<>null then link(adjust_tail):=null;
if pre_adjust_tail<>null then link(pre_adjust_tail):=null;
height(r):=h; depth(r):=d;@/
@<Determine the value of |width(r)| and the appropriate glue setting;
  then |return| or |goto common_ending|@>;
common_ending:
  @<Finish issuing a diagnostic message for an overfull or underfull hbox@>;
exit: last_disp:=disp;
if TeXXeT_en then @<Check for LR anomalies at the end of |hpack|@>;
hpack:=r;
end;
@z

@x
total_stretch[normal]:=0; total_shrink[normal]:=0;
@y
total_stretch[normal]:=0; total_shrink[normal]:=0;
total_stretch[sfi]:=0; total_shrink[sfi]:=0;
@z

@x
@ @<Examine node |p| in the hlist, taking account of its effect...@>=
@^inner loop@>
begin reswitch: while is_char_node(p) do
  @<Incorporate character dimensions into the dimensions of
    the hbox that will contain~it, then move to the next node@>;
if p<>null then
  begin case type(p) of
  hlist_node,vlist_node,rule_node,unset_node:
    @<Incorporate box dimensions into the dimensions of
      the hbox that will contain~it@>;
  ins_node,mark_node,adjust_node: if adjust_tail<>null then
    @<Transfer node |p| to the adjustment list@>;
  whatsit_node:@<Incorporate a whatsit node into an hbox@>;
@y
@ @<Examine node |p| in the hlist, taking account of its effect...@>=
@^inner loop@>
begin reswitch: chain:=false;
while is_char_node(p) do
  @<Incorporate character dimensions into the dimensions of
    the hbox that will contain~it, then move to the next node@>;
if p<>null then
  begin case type(p) of
  hlist_node,vlist_node,dir_node,rule_node,unset_node:
    @<Incorporate box dimensions into the dimensions of
      the hbox that will contain~it@>;
  ins_node,mark_node,adjust_node: if (adjust_tail<>null) or (pre_adjust_tail<> null) then
    @<Transfer node |p| to the adjustment list@>;
  whatsit_node:@<Incorporate a whatsit node into an hbox@>;
  disp_node:begin disp:=disp_dimen(p); revdisp:=disp; end;
@z

@x
@<Incorporate box dimensions into the dimensions of the hbox...@>=
begin x:=x+width(p);
if type(p)>=rule_node then s:=0 @+else s:=shift_amount(p);
if height(p)-s>h then h:=height(p)-s;
if depth(p)+s>d then d:=depth(p)+s;
end
@y
@<Incorporate box dimensions into the dimensions of the hbox...@>=
begin x:=x+width(p);
if type(p)>=rule_node then s:=disp @+else s:=shift_amount(p)+disp;
if height(p)-s>h then h:=height(p)-s;
if depth(p)+s>d then d:=depth(p)+s;
end
@z

@x
@<Incorporate character dimensions into the dimensions of the hbox...@>=
begin f:=font(p); i:=char_info(f)(character(p)); hd:=height_depth(i);
x:=x+char_width(f)(i);@/
s:=char_height(f)(hd);@+if s>h then h:=s;
s:=char_depth(f)(hd);@+if s>d then d:=s;
p:=link(p);
end
@y
@<Incorporate character dimensions into the dimensions of the hbox...@>=
begin f:=font(p); i:=char_info(f)(character(p)); hd:=height_depth(i);
x:=x+char_width(f)(i);@/
s:=char_height(f)(hd)-disp; if s>h then h:=s;
s:=char_depth(f)(hd)+disp; if s>d then d:=s;
if font_dir[f]<>dir_default then
  begin p:=link(p);
  if chain then
    begin x:=x+width(k);@/
    o:=stretch_order(k); total_stretch[o]:=total_stretch[o]+stretch(k);
    o:=shrink_order(k); total_shrink[o]:=total_shrink[o]+shrink(k);
    end
  else chain:=true;
  end
else chain:=false;
p:=link(p);
end
@z

@x
to make a deletion.
@^inner loop@>
@y
to make a deletion.
@^inner loop@>

@<Glob...@>=
@!pre_adjust_tail: pointer;

@ @<Set init...@>=
pre_adjust_tail := null;

@ Materials in \.{\\vadjust} used with \.{pre} keyword will be appended to
|pre_adjust_tail| instead of |adjust_tail|.

@d update_adjust_list(#) == begin
    if # = null then
        confusion("pre vadjust");
    link(#) := adjust_ptr(p);
    while link(#) <> null do
        # := link(#);
end
@z

@x
@<Transfer node |p| to the adjustment list@>=
begin while link(q)<>p do q:=link(q);
if type(p)=adjust_node then
  begin link(adjust_tail):=adjust_ptr(p);
  while link(adjust_tail)<>null do adjust_tail:=link(adjust_tail);
  p:=link(p); free_node(link(q),small_node_size);
  end
else  begin link(adjust_tail):=p; adjust_tail:=p; p:=link(p);
  end;
link(q):=p; p:=q;
@y
@<Transfer node |p| to the adjustment list@>=
begin while link(q)<>p do q:=link(q);
    if type(p) = adjust_node then begin
        if adjust_pre(p) <> 0 then
            update_adjust_list(pre_adjust_tail)
        else
            update_adjust_list(adjust_tail);
        p := link(p); free_node(link(q), small_node_size);
    end
else  begin link(adjust_tail):=p; adjust_tail:=p; p:=link(p);
  end;
link(q):=p; p:=q;
@z

@x
else if total_stretch[fil]<>0 then o:=fil
@y
else if total_stretch[fil]<>0 then o:=fil
else if total_stretch[sfi]<>0 then o:=sfi
@z

@x
else if total_shrink[fil]<>0 then o:=fil
@y
else if total_shrink[fil]<>0 then o:=fil
else if total_shrink[sfi]<>0 then o:=sfi
@z

@x
begin last_badness:=0; r:=get_node(box_node_size); type(r):=vlist_node;
subtype(r):=min_quarterword; shift_amount(r):=0;
@y
begin last_badness:=0; r:=get_node(box_node_size); type(r):=vlist_node;
subtype(r):=min_quarterword; shift_amount(r):=0; set_box_dir(r)(dir_default);
space_ptr(r):=zero_glue; xspace_ptr(r):=zero_glue;
add_glue_ref(zero_glue); add_glue_ref(zero_glue);
@z

@x
@ @<Examine node |p| in the vlist, taking account of its effect...@>=
begin if is_char_node(p) then confusion("vpack")
@:this can't happen vpack}{\quad vpack@>
else  case type(p) of
  hlist_node,vlist_node,rule_node,unset_node:
    @<Incorporate box dimensions into the dimensions of
      the vbox that will contain~it@>;
@y
@ @<Examine node |p| in the vlist, taking account of its effect...@>=
begin if is_char_node(p) then confusion("vpack")
@:this can't happen vpack}{\quad vpack@>
else  case type(p) of
  hlist_node,vlist_node,dir_node,rule_node,unset_node:
    @<Incorporate box dimensions into the dimensions of
      the vbox that will contain~it@>;
@z

@x
\yskip\hang|math_type(q)=math_char| means that |fam(q)| refers to one of
the sixteen font families, and |character(q)| is the number of a character
@y
\yskip\hang|math_type(q)=math_char| means that |fam(q)| refers to one of
the 256 font families, and |character(q)| is the number of a character
@z

@x
@d noad_size=4 {number of words in a normal noad}
@d nucleus(#)==#+1 {the |nucleus| field of a noad}
@d supscr(#)==#+2 {the |supscr| field of a noad}
@d subscr(#)==#+3 {the |subscr| field of a noad}
@y
\yskip\hang In Japanese, |math_type(q)=math_jchar| means that |fam(q)|
refers to one of the sixteen kanji font families, and |KANJI(q)| is the
internal kanji code number.
@^Japanese extentions@>

@d noad_size=5 {number of words in a normal noad}
@d nucleus(#)==#+1 {the |nucleus| field of a noad}
@d supscr(#)==#+2 {the |supscr| field of a noad}
@d subscr(#)==#+3 {the |subscr| field of a noad}
@d kcode_noad(#)==#+4
@d math_kcode(#)==info(#+4) {the |kanji character| field of a noad}
@d kcode_noad_nucleus(#)==#+3
@d math_kcode_nucleus(#)==info(#+3)
    {the |kanji character| field offset from nucleus}
@#
@d math_jchar=6
@d math_text_jchar=7
@z

@x
@d math_char=1 {|math_type| when the attribute is simple}
@d sub_box=2 {|math_type| when the attribute is a box}
@d sub_mlist=3 {|math_type| when the attribute is a formula}
@d math_text_char=4 {|math_type| when italic correction is dubious}
@y
@d math_char=1 {|math_type| when the attribute is simple}
@d sub_box=2 {|math_type| when the attribute is a box}
@d sub_exp_box=3 {|math_type| when the attribute is an explicit created box}
@d sub_mlist=4 {|math_type| when the attribute is a formula}
@d math_text_char=5 {|math_type| when italic correction is dubious}

@<Initialize table entries...@>=
text_baseline_shift_factor:=1000;
read_papersize_special:=1;
script_baseline_shift_factor:=700;
scriptscript_baseline_shift_factor:=500;

@z

@x
@d left_delimiter(#)==#+4 {first delimiter field of a noad}
@d right_delimiter(#)==#+5 {second delimiter field of a fraction noad}
@d radical_noad=inner_noad+1 {|type| of a noad for square roots}
@d radical_noad_size=5 {number of |mem| words in a radical noad}
@y
@d left_delimiter(#)==#+5 {first delimiter field of a noad}
@d right_delimiter(#)==#+4 {second delimiter field of a fraction noad}
@d radical_noad=inner_noad+1 {|type| of a noad for square roots}
@d radical_noad_size=6 {number of |mem| words in a radical noad}
@z

@x
mem[supscr(p)].hh:=empty_field;
new_noad:=p;
@y
mem[supscr(p)].hh:=empty_field;
mem[kcode_noad(p)].hh:=empty_field;
new_noad:=p;
@z

@x
@d accent_noad_size=5 {number of |mem| words in an accent noad}
@d accent_chr(#)==#+4 {the |accent_chr| field of an accent noad}
@y
@d accent_noad_size=6 {number of |mem| words in an accent noad}
@d accent_chr(#)==#+5 {the |accent_chr| field of an accent noad}
@z

@x
procedure print_fam_and_char(@!p:pointer); {prints family and character}
begin print_esc("fam"); print_int(fam(p)); print_char(" ");
print_ASCII(qo(character(p)));
@y
procedure print_fam_and_char(@!p:pointer;@!t:integer);
                    {prints family and character}
var @!cx:KANJI_code; {temporary register for KANJI}
begin print_esc("fam"); print_int(fam(p)); print_char(" ");
if t=math_char then print_ASCII(qo(character(p)))
else  begin KANJI(cx):=math_kcode_nucleus(p); print_utf8(cx);
  end;
@z

@x
  math_char: begin print_ln; print_current_string; print_fam_and_char(p);
    end;
  sub_box: show_info; {recursive call}
@y
  math_char, math_jchar: begin print_ln; print_current_string;
    print_fam_and_char(p,math_type(p));
    end;
  sub_box, sub_exp_box: show_info; {recursive call}
@z

@x
accent_noad: begin print_esc("accent"); print_fam_and_char(accent_chr(p));
@y
accent_noad: begin print_esc("accent");
  print_fam_and_char(accent_chr(p),math_char);
@z

@x
  begin if math_type(nucleus(p))>=sub_box then
    flush_node_list(info(nucleus(p)));
  if math_type(supscr(p))>=sub_box then
    flush_node_list(info(supscr(p)));
  if math_type(subscr(p))>=sub_box then
    flush_node_list(info(subscr(p)));
@y
  begin if (math_type(nucleus(p))>=sub_box)
       and (math_type(nucleus(p))<>math_jchar)
       and (math_type(nucleus(p))<>math_text_jchar) then
    flush_node_list(info(nucleus(p)));
  if math_type(supscr(p))>=sub_box
       and (math_type(supscr(p))<>math_jchar)
       and (math_type(supscr(p))<>math_text_jchar) then
    flush_node_list(info(supscr(p)));
  if math_type(subscr(p))>=sub_box
       and (math_type(subscr(p))<>math_jchar)
       and (math_type(subscr(p))<>math_text_jchar) then
    flush_node_list(info(subscr(p)));
@z

@x
other font information. A size code, which is a multiple of 16, is added to a
family number to get an index into the table of internal font numbers
for each combination of family and size.  (Be alert: Size codes get
larger as the type gets smaller.)

@d text_size=0 {size code for the largest size in a family}
@d script_size=16 {size code for the medium size in a family}
@d script_script_size=32 {size code for the smallest size in a family}
@y
other font information. A size code, which is a multiple of 256, is added to a
family number to get an index into the table of internal font numbers
for each combination of family and size.  (Be alert: Size codes get
larger as the type gets smaller.)
@z

@x
else cur_size:=16*((cur_style-text_style) div 2);
@y
else cur_size:=script_size*((cur_style-text_style) div 2);
@z

@x
function var_delimiter(@!d:pointer;@!s:small_number;@!v:scaled):pointer;
@y
function var_delimiter(@!d:pointer;@!s:integer;@!v:scaled):pointer;
@z

@x
@!hd: eight_bits; {height-depth byte}
@!r: four_quarters; {extensible pieces}
@!z: small_number; {runs through font family members}
@y
@!hd: eight_bits; {height-depth byte}
@!r: four_quarters; {extensible pieces}
@!z: integer; {runs through font family members}
@z

@x
  begin z:=z+s+16;
  repeat z:=z-16; g:=fam_fnt(z);
@y
  begin z:=z+s+script_size;
  repeat z:=z-script_size; g:=fam_fnt(z);
@z

@x
  until z<16;
@y
  until z<script_size;
@z

@x
  begin if type(b)=vlist_node then b:=hpack(b,natural);
  p:=list_ptr(b);
  if (is_char_node(p))and(link(p)=null) then
    begin f:=font(p); v:=char_width(f)(char_info(f)(character(p)));
    if v<>width(b) then link(p):=new_kern(width(b)-v);
    end;
@y
  begin if type(b)<>hlist_node then b:=hpack(b,natural);
  p:=list_ptr(b);
  if is_char_node(p) then
    if font_dir[font(p)]<>dir_default then
      begin if link(link(p))=null then
        begin f:=font(p); v:=char_width(f)(orig_char_info(f)(character(p)));
        if v<>width(b) then link(link(p)):=new_kern(width(b)-v);
        end
      end
    else if link(p)=null then
      begin f:=font(p); v:=char_width(f)(orig_char_info(f)(character(p)));
      if v<>width(b) then link(p):=new_kern(width(b)-v);
      end;
  delete_glue_ref(space_ptr(b)); delete_glue_ref(xspace_ptr(b));
@z

@x
@!cur_mlist:pointer; {beginning of mlist to be translated}
@!cur_style:small_number; {style code at current place in the list}
@!cur_size:small_number; {size code corresponding to |cur_style|}
@y
@!cur_mlist:pointer; {beginning of mlist to be translated}
@!cur_style:small_number; {style code at current place in the list}
@!cur_size:integer; {size code corresponding to |cur_style|}
@z

@x
function clean_box(@!p:pointer;@!s:small_number):pointer;
@y
function shift_sub_exp_box(@!q:pointer):pointer;
  { We assume that |math_type(q)=sub_exp_box| }
  var d: halfword; {displacement}
  begin
    if abs(direction)=abs(box_dir(info(q))) then begin
      if abs(direction)=dir_tate then begin
        if box_dir(info(q))=dir_tate then d:=t_baseline_shift
        else d:=y_baseline_shift end
      else d:=y_baseline_shift;
      if cur_style<script_style then
        d:=xn_over_d(d,text_baseline_shift_factor, 1000)
      else if cur_style<script_script_style then
        d:=xn_over_d(d,script_baseline_shift_factor, 1000)
      else
        d:=xn_over_d(d,scriptscript_baseline_shift_factor, 1000);
      shift_amount(info(q)):=shift_amount(info(q))-d;
    end;
    math_type(q):=sub_box;
    shift_sub_exp_box:=info(q);
  end;
function clean_box(@!p:pointer;@!s:small_number;@!jc:halfword):pointer;
@z

@x
math_char: begin cur_mlist:=new_noad; mem[nucleus(cur_mlist)]:=mem[p];
  end;
sub_box: begin q:=info(p); goto found;
  end;
@y
math_char: begin cur_mlist:=new_noad; mem[nucleus(cur_mlist)]:=mem[p];
  end;
math_jchar: begin cur_mlist:=new_noad; mem[nucleus(cur_mlist)]:=mem[p];
  math_kcode(cur_mlist):=jc;
  end;
sub_box: begin q:=info(p); goto found;
  end;
sub_exp_box: begin q:=shift_sub_exp_box(p); goto found;
  end;
@z

@x
found: if is_char_node(q)or(q=null) then x:=hpack(q,natural)
  else if (link(q)=null)and(type(q)<=vlist_node)and(shift_amount(q)=0) then
    x:=q {it's already clean}
  else x:=hpack(q,natural);
@y
found: if is_char_node(q)or(q=null) then x:=hpack(q,natural)
  else if (link(q)=null)and(type(q)<=dir_node)and(shift_amount(q)=0) then
    x:=q {it's already clean}
  else x:=hpack(q,natural);
@z

@x
if is_char_node(q) then
  begin r:=link(q);
@y
if is_char_node(q) then
  begin if font_dir[font(q)]<>dir_default then q:=link(q);
  r:=link(q);
@z

@x
else  begin if (qo(cur_c)>=font_bc[cur_f])and(qo(cur_c)<=font_ec[cur_f]) then
    cur_i:=orig_char_info(cur_f)(cur_c)
  else cur_i:=null_character;
  if not(char_exists(cur_i)) then
    begin char_warning(cur_f,qo(cur_c));
    math_type(a):=empty; cur_i:=null_character;
    end;
  end;
@y
else  begin if font_dir[cur_f]<>dir_default then
    cur_c:=qi(get_jfm_pos(KANJI(math_kcode_nucleus(a)),cur_f));
  if (qo(cur_c)>=font_bc[cur_f])and(qo(cur_c)<=font_ec[cur_f]) then
    cur_i:=orig_char_info(cur_f)(cur_c)
  else cur_i:=null_character;
  if not(char_exists(cur_i)) then
    begin char_warning(cur_f,qo(cur_c));
    math_type(a):=empty; cur_i:=null_character;
    end;
  end;
@z

@x
var mlist:pointer; {beginning of the given list}
@!penalties:boolean; {should penalty nodes be inserted?}
@!style:small_number; {the given style}
@y
var mlist:pointer; {beginning of the given list}
@!penalties:boolean; {should penalty nodes be inserted?}
@!style:small_number; {the given style}
@!u:pointer; {temporary register}
@z

@x
@!p,@!x,@!y,@!z: pointer; {temporary registers for list construction}
@!pen:integer; {a penalty to be inserted}
@!s:small_number; {the size of a noad to be deleted}
@y
@!p,@!x,@!y,@!z: pointer; {temporary registers for list construction}
@!pen:integer; {a penalty to be inserted}
@!s:integer; {the size of a noad to be deleted}
@z

@x
@<Make a second pass over the mlist, removing all noads and inserting the
  proper spacing and penalties@>;
end;
@y
@<Make a second pass over the mlist, removing all noads and inserting the
  proper spacing and penalties@>;
p:=new_null_box; link(p):=link(temp_head);
adjust_hlist(p,false); link(temp_head):=link(p);
delete_glue_ref(space_ptr(p)); delete_glue_ref(xspace_ptr(p));
free_node(p,box_node_size);
end;
@z

@x
free_node(z,box_node_size);
@y
delete_glue_ref(space_ptr(z)); delete_glue_ref(xspace_ptr(z));
free_node(z,box_node_size);
@z

@x
kern_node: begin math_kern(q,cur_mu); goto done_with_node;
  end;
@y
kern_node: begin math_kern(q,cur_mu); goto done_with_node;
  end;
disp_node: goto done_with_node;
@z

@x
  overbar(clean_box(nucleus(q),cramped_style(cur_style)),@|
@y
  overbar(clean_box(nucleus(q),cramped_style(cur_style),math_kcode(q)),@|
@z

@x
begin x:=clean_box(nucleus(q),cur_style);
@y
begin x:=clean_box(nucleus(q),cur_style,math_kcode(q));
@z

@x
if type(v)<>vlist_node then confusion("vcenter");
@y
if type(v)=dir_node then
  begin if type(list_ptr(v))<>vlist_node then confusion("dircenter")
  end
else  begin if type(v)<>vlist_node then confusion("vcenter")
  end;
@z

@x
begin x:=clean_box(nucleus(q),cramped_style(cur_style));
@y
begin x:=clean_box(nucleus(q),cramped_style(cur_style),math_kcode(q));
@z

@x
  x:=clean_box(nucleus(q),cramped_style(cur_style)); w:=width(x); h:=height(x);
@y
  x:=clean_box(nucleus(q),cramped_style(cur_style),math_kcode(q));
  w:=width(x); h:=height(x);
@z

@x
x:=clean_box(nucleus(q),cur_style); delta:=delta+height(x)-h; h:=height(x);
@y
x:=clean_box(nucleus(q),cur_style,math_kcode(q));
delta:=delta+height(x)-h; h:=height(x);
@z

@x
x:=clean_box(numerator(q),num_style(cur_style));
z:=clean_box(denominator(q),denom_style(cur_style));
@y
x:=clean_box(numerator(q),num_style(cur_style),math_kcode(q));
z:=clean_box(denominator(q),denom_style(cur_style),math_kcode(q));
@z

@x
  delta:=char_italic(cur_f)(cur_i); x:=clean_box(nucleus(q),cur_style);
@y
  delta:=char_italic(cur_f)(cur_i);
  x:=clean_box(nucleus(q),cur_style,math_kcode(q));
@z

@x
begin x:=clean_box(supscr(q),sup_style(cur_style));
y:=clean_box(nucleus(q),cur_style);
z:=clean_box(subscr(q),sub_style(cur_style));
@y
begin x:=clean_box(supscr(q),sup_style(cur_style),math_kcode(q));
y:=clean_box(nucleus(q),cur_style,math_kcode(q));
z:=clean_box(subscr(q),sub_style(cur_style),math_kcode(q));
@z

@x
  begin free_node(x,box_node_size); list_ptr(v):=y;
  end
@y
  begin
    delete_glue_ref(space_ptr(x)); delete_glue_ref(xspace_ptr(x));
    free_node(x,box_node_size); list_ptr(v):=y;
  end
@z

@x
if math_type(subscr(q))=empty then free_node(z,box_node_size)
@y
if math_type(subscr(q))=empty then begin
  delete_glue_ref(space_ptr(z)); delete_glue_ref(xspace_ptr(z));
  free_node(z,box_node_size)
end
@z

@x
procedure make_ord(@!q:pointer);
label restart,exit;
var a:integer; {address of lig/kern instruction}
@!p,@!r:pointer; {temporary registers for list manipulation}
begin restart:@t@>@;@/
if math_type(subscr(q))=empty then if math_type(supscr(q))=empty then
 if math_type(nucleus(q))=math_char then
  begin p:=link(q);
  if p<>null then if (type(p)>=ord_noad)and(type(p)<=punct_noad) then
    if math_type(nucleus(p))=math_char then
    if fam(nucleus(p))=fam(nucleus(q)) then
      begin math_type(nucleus(q)):=math_text_char;
      fetch(nucleus(q));
      if char_tag(cur_i)=lig_tag then
        begin a:=lig_kern_start(cur_f)(cur_i);
        cur_c:=character(nucleus(p));
        cur_i:=font_info[a].qqqq;
        if skip_byte(cur_i)>stop_flag then
          begin a:=lig_kern_restart(cur_f)(cur_i);
          cur_i:=font_info[a].qqqq;
          end;
        loop@+ begin @<If instruction |cur_i| is a kern with |cur_c|, attach
            the kern after~|q|; or if it is a ligature with |cur_c|, combine
            noads |q| and~|p| appropriately; then |return| if the cursor has
            moved past a noad, or |goto restart|@>;
          if skip_byte(cur_i)>=stop_flag then return;
          a:=a+qo(skip_byte(cur_i))+1;
          cur_i:=font_info[a].qqqq;
          end;
        end;
      end;
  end;
exit:end;
@y
procedure make_ord(@!q:pointer);
label restart,exit;
var a:integer; {address of lig/kern instruction}
@!gp,@!gq,@!p,@!r:pointer; {temporary registers for list manipulation}
@!rr:halfword;
begin restart:@t@>@;@/
if (math_type(subscr(q))=empty)and(math_type(supscr(q))=empty)and@|
((math_type(nucleus(q))=math_char)or(math_type(nucleus(q))=math_jchar)) then
  begin p:=link(q);
  if p<>null then if (type(p)>=ord_noad)and(type(p)<=punct_noad) then
   if fam(nucleus(p))=fam(nucleus(q)) then
    if math_type(nucleus(p))=math_char then
      begin math_type(nucleus(q)):=math_text_char;
      fetch(nucleus(q));
      if char_tag(cur_i)=lig_tag then
        begin a:=lig_kern_start(cur_f)(cur_i);
        cur_c:=character(nucleus(p));
        cur_i:=font_info[a].qqqq;
        if skip_byte(cur_i)>stop_flag then
          begin a:=lig_kern_restart(cur_f)(cur_i);
          cur_i:=font_info[a].qqqq;
          end;
        loop@+ begin @<If instruction |cur_i| is a kern with |cur_c|, attach
            the kern after~|q|; or if it is a ligature with |cur_c|, combine
            noads |q| and~|p| appropriately; then |return| if the cursor has
            moved past a noad, or |goto restart|@>;
          if skip_byte(cur_i)>=stop_flag then return;
          a:=a+qo(skip_byte(cur_i))+1;
          cur_i:=font_info[a].qqqq;
          end;
        end;
      end
    else  if math_type(nucleus(p))=math_jchar then
      begin math_type(nucleus(q)):=math_text_jchar;
      fetch(nucleus(p)); a:=cur_c; fetch(nucleus(q));
      if char_tag(cur_i)=gk_tag then
        begin cur_c:=a; a:=glue_kern_start(cur_f)(cur_i);
        {|cur_c|:=qi(|get_jfm_pos|(|math_kcode|(p),
                   |fam_fnt|(fam(nucleus(p))+|cur_size|)));}
         cur_i:=font_info[a].qqqq;
         if skip_byte(cur_i)>stop_flag then {huge glue/kern table rearranged}
           begin a:=glue_kern_restart(cur_f)(cur_i);
           cur_i:=font_info[a].qqqq;
           end;
       loop@+ begin
         if next_char(cur_i)=cur_c then if skip_byte(cur_i)<=stop_flag then
         if op_byte(cur_i)<kern_flag then
           begin gp:=font_glue[cur_f]; rr:=rem_byte(cur_i);
           if gp<>null then begin
             while((type(gp)<>rr)and(link(gp)<>null)) do begin gp:=link(gp);
               end;
             gq:=glue_ptr(gp);
             end
           else begin gp:=get_node(small_node_size);
             font_glue[cur_f]:=gp; gq:=null;
             end;
           if gq=null then
             begin type(gp):=rr; gq:=new_spec(zero_glue); glue_ptr(gp):=gq;
             a:=exten_base[cur_f]+qi((qo(rr))*3); width(gq):=font_info[a].sc;
             stretch(gq):=font_info[a+1].sc; shrink(gq):=font_info[a+2].sc;
             add_glue_ref(gq); link(gp):=get_node(small_node_size);
             gp:=link(gp); glue_ptr(gp):=null; link(gp):=null;
             end;
           p:=new_glue(gq); subtype(p):=jfm_skip+1;
           link(p):=link(q); link(q):=p; return;
           end
         else begin p:=new_kern(char_kern(cur_f)(cur_i));
           link(p):=link(q); link(q):=p; return;
           end;
         if skip_byte(cur_i)>=stop_flag then return;
         a:=a+qo(skip_byte(cur_i))+1; {SKIP property}
         cur_i:=font_info[a].qqqq;
         end;
        end;
      end;
  end;
exit:end;
@z

@x
math_char, math_text_char:
@y
math_char, math_text_char, math_jchar, math_text_jchar:
@z

@x
sub_box: p:=info(nucleus(q));
@y
sub_box: p:=info(nucleus(q));
sub_exp_box: p:=shift_sub_exp_box(nucleus(q));
@z

@x
  begin delta:=char_italic(cur_f)(cur_i); p:=new_character(cur_f,qo(cur_c));
  if (math_type(nucleus(q))=math_text_char)and(space(cur_f)<>0) then
    delta:=0; {no italic correction in mid-word of text font}
  if (math_type(subscr(q))=empty)and(delta<>0) then
    begin link(p):=new_kern(delta); delta:=0;
@y
  begin delta:=char_italic(cur_f)(cur_i); p:=new_character(cur_f,qo(cur_c));
  u:=p;
  if font_dir[cur_f]<>dir_default then begin
    link(u):=get_avail; u:=link(u); info(u):=math_kcode(q);
  end;
  if ((math_type(nucleus(q))=math_text_char)or
      (math_type(nucleus(q))=math_text_jchar))and(space(cur_f)<>0) then
    delta:=0; {no italic correction in mid-word of text font}
  if (math_type(subscr(q))=empty)and(delta<>0) then begin
    link(u):=new_kern(delta); delta:=0;
@z

@x
procedure make_scripts(@!q:pointer;@!delta:scaled);
var p,@!x,@!y,@!z:pointer; {temporary registers for box construction}
@!shift_up,@!shift_down,@!clr:scaled; {dimensions in the calculation}
@!t:small_number; {subsidiary size code}
@y
procedure make_scripts(@!q:pointer;@!delta:scaled);
var p,@!x,@!y,@!z:pointer; {temporary registers for box construction}
@!shift_up,@!shift_down,@!clr:scaled; {dimensions in the calculation}
@!t:integer; {subsidiary size code}
@z

@x
  shift_down:=depth(z)+sub_drop(t);
  free_node(z,box_node_size);
  end;
@y
  shift_down:=depth(z)+sub_drop(t);
  delete_glue_ref(space_ptr(z)); delete_glue_ref(xspace_ptr(z));
  free_node(z,box_node_size);
  end;
@z

@x
begin x:=clean_box(subscr(q),sub_style(cur_style));
@y
begin x:=clean_box(subscr(q),sub_style(cur_style),math_kcode(q));
@z

@x
begin x:=clean_box(supscr(q),sup_style(cur_style));
@y
begin x:=clean_box(supscr(q),sup_style(cur_style),math_kcode(q));
@z

@x
begin y:=clean_box(subscr(q),sub_style(cur_style));
@y
begin y:=clean_box(subscr(q),sub_style(cur_style),math_kcode(q));
@z

@x
othercases confusion("mlist3")
@y
disp_node: begin link(p):=q; p:=q; q:=link(q); link(p):=null; goto done;
  end;
othercases confusion("mlist3")
@z

@x
@d align_stack_node_size=5 {number of |mem| words to save alignment states}
@y
@d align_stack_node_size=6 {number of |mem| words to save alignment states}
@z

@x
@!cur_head,@!cur_tail:pointer; {adjustment list pointers}
@y
@!cur_head,@!cur_tail:pointer; {adjustment list pointers}
@!cur_pre_head,@!cur_pre_tail:pointer; {pre-adjustment list pointers}
@z

@x
cur_head:=null; cur_tail:=null;
@y
cur_head:=null; cur_tail:=null;
cur_pre_head:=null; cur_pre_tail:=null;
@z

@x
info(p+4):=cur_head; link(p+4):=cur_tail;
align_ptr:=p;
cur_head:=get_avail;
@y
info(p+4):=cur_head; link(p+4):=cur_tail;
info(p+5):=cur_pre_head; link(p+5):=cur_pre_tail;
align_ptr:=p;
cur_head:=get_avail;
cur_pre_head:=get_avail;
@z

@x
begin free_avail(cur_head);
p:=align_ptr;
cur_tail:=link(p+4); cur_head:=info(p+4);
@y
begin free_avail(cur_head);
free_avail(cur_pre_head);
p:=align_ptr;
cur_tail:=link(p+4); cur_head:=info(p+4);
cur_pre_tail:=link(p+5); cur_pre_head:=info(p+5);
@z

@x
cur_align:=link(preamble); cur_tail:=cur_head; init_span(cur_align);
@y
cur_align:=link(preamble); cur_tail:=cur_head; cur_pre_tail:=cur_pre_head;
init_span(cur_align);
@z

@x
if mode=-hmode then space_factor:=1000
else  begin prev_depth:=ignore_depth; normal_paragraph;
  end;
@y
if mode=-hmode then space_factor:=1000
else  begin prev_depth:=ignore_depth; normal_paragraph;
  end;
inhibit_glue_flag:=false;
@z

@x
  begin adjust_tail:=cur_tail; u:=hpack(link(head),natural); w:=width(u);
@y
  begin adjust_tail:=cur_tail; pre_adjust_tail:=cur_pre_tail;
  adjust_hlist(head,false);
  delete_glue_ref(cur_kanji_skip); delete_glue_ref(cur_xkanji_skip);
  cur_kanji_skip:=space_ptr(head); cur_xkanji_skip:=xspace_ptr(head);
  add_glue_ref(cur_kanji_skip); add_glue_ref(cur_xkanji_skip);
  u:=hpack(link(head),natural); w:=width(u);
@z

@x
  cur_tail:=adjust_tail; adjust_tail:=null;
@y
  cur_tail:=adjust_tail; adjust_tail:=null;
  cur_pre_tail:=pre_adjust_tail; pre_adjust_tail:=null;
@z

@x
if n>max_quarterword then confusion("256 spans"); {this can happen, but won't}
@^system dependencies@>
@:this can't happen 256 spans}{\quad 256 spans@>
@y
if n>max_quarterword then confusion("too many spans");
   {this can happen, but won't}
@^system dependencies@>
@:this can't happen too many spans}{\quad too many spans@>
@z

@x
  begin p:=hpack(link(head),natural);
@y
  begin adjust_hlist(head,false);
  delete_glue_ref(cur_kanji_skip); delete_glue_ref(cur_xkanji_skip);
  cur_kanji_skip:=space_ptr(head); cur_xkanji_skip:=xspace_ptr(head);
  add_glue_ref(cur_kanji_skip); add_glue_ref(cur_xkanji_skip);
  p:=hpack(link(head),natural);
@z

@x
  pop_nest; append_to_vlist(p);
  if cur_head<>cur_tail then
    begin link(tail):=link(cur_head); tail:=cur_tail;
    end;
@y
  pop_nest;
  if cur_pre_head <> cur_pre_tail then
      append_list(cur_pre_head)(cur_pre_tail);
  append_to_vlist(p);
  if cur_head <> cur_tail then
      append_list(cur_head)(cur_tail);
@z

@x
  link(tail):=p; tail:=p; space_factor:=1000;
@y
  link(tail):=p; tail:=p; space_factor:=1000;
  inhibit_glue_flag:=false;
@z

@x
var @!p,@!q,@!r,@!s,@!u,@!v: pointer; {registers for the list operations}
@y
var @!p,@!q,@!r,@!s,@!u,@!v,@!z: pointer; {registers for the list operations}
@z

@x
  p:=hpack(preamble,saved(1),saved(0)); overfull_rule:=rule_save;
@y
  z:=new_null_box; link(z):=preamble;
  adjust_hlist(z,false);
  delete_glue_ref(cur_kanji_skip); delete_glue_ref(cur_xkanji_skip);
  cur_kanji_skip:=space_ptr(z); cur_xkanji_skip:=xspace_ptr(z);
  add_glue_ref(cur_kanji_skip); add_glue_ref(cur_xkanji_skip);
  p:=hpack(preamble,saved(1),saved(0)); overfull_rule:=rule_save;
  delete_glue_ref(space_ptr(z)); delete_glue_ref(xspace_ptr(z));
  free_node(z,box_node_size);
@z

@x
glue_order(q):=glue_order(p); glue_sign(q):=glue_sign(p);
glue_set(q):=glue_set(p); shift_amount(q):=o;
r:=link(list_ptr(q)); s:=link(list_ptr(p));
@y
set_box_dir(q)(direction);
glue_order(q):=glue_order(p); glue_sign(q):=glue_sign(p);
glue_set(q):=glue_set(p); shift_amount(q):=o;
r:=link(list_ptr(q)); s:=link(list_ptr(p));
@z

@x
s:=link(s); link(u):=new_null_box; u:=link(u); t:=t+width(s);
if mode=-vmode then width(u):=width(s)@+else
  begin type(u):=vlist_node; height(u):=width(s);
  end
@y
s:=link(s); link(u):=new_null_box; u:=link(u); t:=t+width(s);
if mode=-vmode then width(u):=width(s)@+else
  begin type(u):=vlist_node; height(u):=width(s);
  end;
set_box_dir(u)(direction)
@z

@x
width(r):=w; type(r):=hlist_node;
end
@y
width(r):=w; type(r):=hlist_node;
set_box_dir(r)(direction);
end
@z

@x
height(r):=w; type(r):=vlist_node;
@y
height(r):=w; type(r):=vlist_node;
set_box_dir(r)(direction);
@z

@x
link(temp_head):=link(head);
if is_char_node(tail) then tail_append(new_penalty(inf_penalty))
else if type(tail)<>glue_node then tail_append(new_penalty(inf_penalty))
@y
first_use:=true; chain:=false;
delete_glue_ref(cur_kanji_skip); delete_glue_ref(cur_xkanji_skip);
cur_kanji_skip:=space_ptr(head); cur_xkanji_skip:=xspace_ptr(head);
add_glue_ref(cur_kanji_skip); add_glue_ref(cur_xkanji_skip);
if not is_char_node(tail)and(type(tail)=disp_node) then
  begin free_node(tail,small_node_size); tail:=prev_node; link(tail):=null
  end;
link(temp_head):=link(head);
if is_char_node(tail) then tail_append(new_penalty(inf_penalty))
else if type(tail)<>glue_node then tail_append(new_penalty(inf_penalty))
@z

@x
contains six scaled numbers, since it must record the net change in glue
stretchability with respect to all orders of infinity. The natural width
difference appears in |mem[q+1].sc|; the stretch differences in units of
pt, fil, fill, and filll appear in |mem[q+2..q+5].sc|; and the shrink difference
appears in |mem[q+6].sc|. The |subtype| field of a delta node is not used.

@d delta_node_size=7 {number of words in a delta node}
@y
contains seven scaled numbers, since it must record the net change in glue
stretchability with respect to all orders of infinity. The natural width
difference appears in |mem[q+1].sc|; the stretch differences in units of
pt, sfi, fil, fill, and filll appear in |mem[q+2..q+6].sc|; and the shrink
difference appears in |mem[q+7].sc|. The |subtype| field of a delta node
is not used.

@d delta_node_size=8 {number of words in a delta node}
@z

@x
@ As the algorithm runs, it maintains a set of six delta-like registers
for the length of the line following the first active breakpoint to the
current position in the given hlist. When it makes a pass through the
active list, it also maintains a similar set of six registers for the
@y
@ As the algorithm runs, it maintains a set of seven delta-like registers
for the length of the line following the first active breakpoint to the
current position in the given hlist. When it makes a pass through the
active list, it also maintains a similar set of seven registers for the
@z

@x
k:=1 to 6 do cur_active_width[k]:=cur_active_width[k]+mem[q+k].sc|};$$ and we
want to do this without the overhead of |for| loops. The |do_all_six|
macro makes such six-tuples convenient.

@d do_all_six(#)==#(1);#(2);#(3);#(4);#(5);#(6)
@y
k:=1 to 7 do cur_active_width[k]:=cur_active_width[k]+mem[q+k].sc|};$$ and we
want to do this without the overhead of |for| loops. The |do_all_six|
macro makes such seven-tuples convenient.

@d do_all_six(#)==#(1);#(2);#(3);#(4);#(5);#(6);#(7)
@z

@x
@!active_width:array[1..6] of scaled;
  {distance from first active node to~|cur_p|}
@!cur_active_width:array[1..6] of scaled; {distance from current active node}
@!background:array[1..6] of scaled; {length of an ``empty'' line}
@!break_width:array[1..6] of scaled; {length being computed after current break}
@y
@!active_width:array[1..7] of scaled;
  {distance from first active node to~|cur_p|}
@!cur_active_width:array[1..7] of scaled; {distance from current active node}
@!background:array[1..7] of scaled; {length of an ``empty'' line}
@!break_width:array[1..7] of scaled; {length being computed after current break}
@z

@x
background[2]:=0; background[3]:=0; background[4]:=0; background[5]:=0;@/
background[2+stretch_order(q)]:=stretch(q);@/
background[2+stretch_order(r)]:=@|background[2+stretch_order(r)]+stretch(r);@/
background[6]:=shrink(q)+shrink(r);
@y
background[2]:=0; background[3]:=0; background[4]:=0; background[5]:=0;@/
background[6]:=0;@/
background[2+stretch_order(q)]:=stretch(q);@/
background[2+stretch_order(r)]:=@|background[2+stretch_order(r)]+stretch(r);@/
background[7]:=shrink(q)+shrink(r);
@z

@x
@!cur_p:pointer; {the current breakpoint under consideration}
@y
@!cur_p:pointer; {the current breakpoint under consideration}
@!chain:boolean; {chain current line and next line?}
@z

@x
begin no_break_yet:=false; do_all_six(set_break_width_to_background);
s:=cur_p;
if break_type>unhyphenated then if cur_p<>null then
  @<Compute the discretionary |break_width| values@>;
while s<>null do
  begin if is_char_node(s) then goto done;
@y
begin no_break_yet:=false; do_all_six(set_break_width_to_background);
s:=cur_p;
if break_type>unhyphenated then if cur_p<>null then
  @<Compute the discretionary |break_width| values@>;
while s<>null do
  begin if is_char_node(s) then
    begin if chain then
      begin break_width[1]:=break_width[1]-width(cur_kanji_skip);
      break_width[2+stretch_order(cur_kanji_skip)]:=
         break_width[2+stretch_order(cur_kanji_skip)]-stretch(cur_kanji_skip);
      break_width[7]:=break_width[7]-shrink(cur_kanji_skip);
      end;
    goto done end;
@z

@x
  kern_node: if subtype(s)<>explicit then goto done
    else break_width[1]:=break_width[1]-width(s);
@y
  kern_node: if (subtype(s)<>explicit)and(subtype(s)<>ita_kern) then
    goto done
    else break_width[1]:=break_width[1]-width(s);
@z

@x
break_width[6]:=break_width[6]-shrink(v);
@y
break_width[7]:=break_width[7]-shrink(v);
@z

@x
if is_char_node(v) then
  begin f:=font(v);
  break_width[1]:=break_width[1]-char_width(f)(char_info(f)(character(v)));
  end
else  case type(v) of
  ligature_node: begin f:=font(lig_char(v));@/
    break_width[1]:=@|break_width[1]-
      char_width(f)(char_info(f)(character(lig_char(v))));
    end;
  hlist_node,vlist_node,rule_node,kern_node:
    break_width[1]:=break_width[1]-width(v);
  othercases confusion("disc1")
@:this can't happen disc1}{\quad disc1@>
  endcases
@y
if is_char_node(v) then
  begin f:=font(v);
  break_width[1]:=break_width[1]-char_width(f)(orig_char_info(f)(character(v)));
  if font_dir[f]<>dir_default then v:=link(v);
  end
else case type(v) of
  ligature_node: begin f:=font(lig_char(v));@/
    break_width[1]:=@|break_width[1]-
      char_width(f)(orig_char_info(f)(character(lig_char(v))));
    end;
  hlist_node,vlist_node,dir_node,rule_node,kern_node:
    break_width[1]:=break_width[1]-width(v);
  disp_node: do_nothing;
  othercases confusion("disc1")
@:this can't happen disc1}{\quad disc1@>
  endcases
@z

@x
  break_width[1]:=@|break_width[1]+char_width(f)(char_info(f)(character(s)));
  end
else  case type(s) of
  ligature_node: begin f:=font(lig_char(s));
    break_width[1]:=break_width[1]+
      char_width(f)(char_info(f)(character(lig_char(s))));
    end;
  hlist_node,vlist_node,rule_node,kern_node:
    break_width[1]:=break_width[1]+width(s);
@y
  break_width[1]:=@|break_width[1]+char_width(f)(orig_char_info(f)(character(s)));
  if font_dir[f]<>dir_default then s:=link(s);
  end
else  case type(s) of
  ligature_node: begin f:=font(lig_char(s));
    break_width[1]:=break_width[1]+
      char_width(f)(orig_char_info(f)(character(lig_char(s))));
    end;
  hlist_node,vlist_node,dir_node,rule_node,kern_node:
    break_width[1]:=break_width[1]+width(s);
  disp_node: do_nothing;
@z

@x
subarray |cur_active_width[2..5]|, in units of points, fil, fill, and filll.
@y
subarray |cur_active_width[2..6]|, in units of points, sfi, fil, fill and filll.
@z

@x
if (cur_active_width[3]<>0)or(cur_active_width[4]<>0)or@|
  (cur_active_width[5]<>0) then
@y
if (cur_active_width[3]<>0)or(cur_active_width[4]<>0)or@|
  (cur_active_width[5]<>0)or(cur_active_width[6]<>0) then
@z

@x
@ Shrinkability is never infinite in a paragraph;
we can shrink the line from |r| to |cur_p| by at most |cur_active_width[6]|.

@<Set the value of |b| to the badness for shrinking...@>=
begin if -shortfall>cur_active_width[6] then b:=inf_bad+1
else b:=badness(-shortfall,cur_active_width[6]);
@y
@ Shrinkability is never infinite in a paragraph;
we can shrink the line from |r| to |cur_p| by at most |cur_active_width[7]|.

@<Set the value of |b| to the badness for shrinking...@>=
begin if -shortfall>cur_active_width[7] then b:=inf_bad+1
else b:=badness(-shortfall,cur_active_width[7]);
@z

@x
if cur_p=null then print_esc("par")
else if type(cur_p)<>glue_node then
  begin if type(cur_p)=penalty_node then print_esc("penalty")
  else if type(cur_p)=disc_node then print_esc("discretionary")
@y
if cur_p=null then print_esc("par")
else if (type(cur_p)<>glue_node)and(not is_char_node(cur_p)) then
  begin if type(cur_p)=penalty_node then print_esc("penalty")
  else if type(cur_p)=disc_node then print_esc("discretionary")
@z

@x
@!auto_breaking:boolean; {is node |cur_p| outside a formula?}
@!prev_p:pointer; {helps to determine when glue nodes are breakpoints}
@!q,@!r,@!s,@!prev_s:pointer; {miscellaneous nodes of temporary interest}
@!f:internal_font_number; {used when calculating character widths}
@y
@!auto_breaking:boolean; {is node |cur_p| outside a formula?}
@!prev_p:pointer; {helps to determine when glue nodes are breakpoints}
@!q,@!r,@!s,@!prev_s:pointer; {miscellaneous nodes of temporary interest}
@!f,@!post_f:internal_font_number; {used when calculating character widths}
@!post_p:pointer;
@!cc:ASCII_code;
@!first_use:boolean;
@z

@x
case type(cur_p) of
hlist_node,vlist_node,rule_node: act_width:=act_width+width(cur_p);
@y
case type(cur_p) of
hlist_node,vlist_node,dir_node,rule_node: act_width:=act_width+width(cur_p);
@z

@x
kern_node: if subtype(cur_p)=explicit then kern_break
  else act_width:=act_width+width(cur_p);
@y
kern_node: if (subtype(cur_p)=explicit)or(subtype(cur_p)=ita_kern) then
  kern_break
  else act_width:=act_width+width(cur_p);
@z

@x
mark_node,ins_node,adjust_node: do_nothing;
@y
disp_node,mark_node,ins_node,adjust_node: do_nothing;
@z

@x
@<Advance \(c)|cur_p| to the node following the present string...@>=
begin prev_p:=cur_p;
repeat f:=font(cur_p);
act_width:=act_width+char_width(f)(char_info(f)(character(cur_p)));
cur_p:=link(cur_p);
until not is_char_node(cur_p);
end
@y
@<Advance \(c)|cur_p| to the node following the present string...@>=
begin chain:=false;
if is_char_node(cur_p) then
  if font_dir[font(cur_p)]<>dir_default then
    begin case type(prev_p) of
    hlist_node,vlist_node,dir_node,rule_node,
    ligature_node,disc_node,math_node: begin
      cur_p:=prev_p; try_break(0,unhyphenated); cur_p:=link(cur_p);
      end;
    othercases do_nothing;
    endcases;
    end;
  prev_p:=cur_p; post_p:=cur_p; post_f:=font(post_p);
  repeat f:=post_f; cc:=character(cur_p);
  act_width:=act_width+char_width(f)(orig_char_info(f)(cc));
  post_p:=link(cur_p);
  if font_dir[f]<>dir_default then
    begin prev_p:=cur_p; cur_p:=post_p; post_p:=link(post_p);
    if is_char_node(post_p) then
      begin post_f:=font(post_p);
      if font_dir[post_f]<>dir_default then chain:=true else chain:=false;
      try_break(0,unhyphenated);
      end
    else
      begin chain:=false;
      case type(post_p) of
      hlist_node,vlist_node,dir_node,rule_node,ligature_node,
        disc_node,math_node: try_break(0,unhyphenated);
      othercases do_nothing;
      endcases;
      end;
    if chain then
      begin if first_use then
        begin check_shrinkage(cur_kanji_skip);
        first_use:=false;
        end;
      act_width:=act_width+width(cur_kanji_skip);@|
      active_width[2+stretch_order(cur_kanji_skip)]:=@|
          active_width[2+stretch_order(cur_kanji_skip)]
          +stretch(cur_kanji_skip);@/
      active_width[7]:=active_width[7]+shrink(cur_kanji_skip);
      end;
    prev_p:=cur_p;
    end
  else  if is_char_node(post_p) then
    begin post_f:=font(post_p); chain:=false;
    if font_dir[post_f]<>dir_default then try_break(0,unhyphenated);
    end;
  cur_p:=post_p;
  until not is_char_node(cur_p);
chain:=false;
end
@z

@x
  else if (type(prev_p)=kern_node)and(subtype(prev_p)<>explicit) then
    try_break(0,unhyphenated);
@y
  else if type(prev_p)=kern_node then
    if (subtype(prev_p)<>explicit)and(subtype(prev_p)<>ita_kern) then
    try_break(0,unhyphenated);
@z

@x
active_width[6]:=active_width[6]+shrink(q)
@y
active_width[7]:=active_width[7]+shrink(q)
@z

@x
  disc_width:=disc_width+char_width(f)(char_info(f)(character(s)));
  end
else  case type(s) of
  ligature_node: begin f:=font(lig_char(s));
    disc_width:=disc_width+
      char_width(f)(char_info(f)(character(lig_char(s))));
    end;
  hlist_node,vlist_node,rule_node,kern_node:
    disc_width:=disc_width+width(s);
@y
  disc_width:=disc_width+char_width(f)(orig_char_info(f)(character(s)));
  if font_dir[f]<>dir_default then s:=link(s)
  end
else  case type(s) of
  ligature_node: begin f:=font(lig_char(s));
    disc_width:=disc_width+
      char_width(f)(orig_char_info(f)(character(lig_char(s))));
    end;
  hlist_node,vlist_node,dir_node,rule_node,kern_node:
    disc_width:=disc_width+width(s);
  disp_node: do_nothing;
@z

@x
  act_width:=act_width+char_width(f)(char_info(f)(character(s)));
  end
else  case type(s) of
  ligature_node: begin f:=font(lig_char(s));
    act_width:=act_width+
      char_width(f)(char_info(f)(character(lig_char(s))));
    end;
  hlist_node,vlist_node,rule_node,kern_node:
    act_width:=act_width+width(s);
@y
  act_width:=act_width+char_width(f)(orig_char_info(f)(character(s)));
  if font_dir[f]<>dir_default then s:=link(s)
  end
else  case type(s) of
  ligature_node: begin f:=font(lig_char(s));
    act_width:=act_width+
      char_width(f)(orig_char_info(f)(character(lig_char(s))));
    end;
  hlist_node,vlist_node,dir_node,rule_node,kern_node:
    act_width:=act_width+width(s);
  disp_node: do_nothing;
@z

@x
cur_line:=prev_graf+1;
@y
cur_line:=prev_graf+1; last_disp:=0;
@z

@x
  if type(q)=kern_node then if subtype(q)<>explicit then goto done1;
@y
  if type(q)=kern_node then
    if (subtype(q)<>explicit)and(subtype(q)<>ita_kern) then goto done1;
@z

@x
if q<>null then {|q| cannot be a |char_node|}
  if type(q)=glue_node then
    begin delete_glue_ref(glue_ptr(q));
    glue_ptr(q):=right_skip;
    subtype(q):=right_skip_code+1; add_glue_ref(right_skip);
    goto done;
    end
  else  begin if type(q)=disc_node then
      @<Change discretionary to compulsory and set
        |disc_break:=true|@>
@y
if q<>null then {|q| may be a |char_node|}
  begin if not is_char_node(q) then
    if type(q)=glue_node then
      begin delete_glue_ref(glue_ptr(q));
      glue_ptr(q):=right_skip;
      subtype(q):=right_skip_code+1; add_glue_ref(right_skip);
      goto done;
      end
    else  begin if type(q)=disc_node then
        @<Change discretionary to compulsory and set
          |disc_break:=true|@>
@z

@x
    end
@y
      end
  end
@z

@x
r:=link(q); link(q):=null; q:=link(temp_head); link(temp_head):=r;
@y
r:=link(q); link(q):=null; q:=link(temp_head); link(temp_head):=r;
if last_disp<>0 then begin
  r:=get_node(small_node_size);
  type(r):=disp_node; disp_dimen(r):=last_disp;
  link(r):=q; q:=r; disp_called:=true;
  end;
@z

@x
@ @<Append the new box to the current vertical list...@>=
append_to_vlist(just_box);
if adjust_head<>adjust_tail then
  begin link(tail):=link(adjust_head); tail:=adjust_tail;
   end;
adjust_tail:=null
@y
@ @<Append the new box to the current vertical list...@>=
if pre_adjust_head <> pre_adjust_tail then
    append_list(pre_adjust_head)(pre_adjust_tail);
pre_adjust_tail := null;
append_to_vlist(just_box);
if adjust_head <> adjust_tail then
    append_list(adjust_head)(adjust_tail);
adjust_tail := null
@z

@x
adjust_tail:=adjust_head; just_box:=hpack(q,cur_width,exactly);
@y
adjust_tail:=adjust_head;
pre_adjust_tail := pre_adjust_head;
just_box:=hpack(q,cur_width,exactly);
@z

@x
loop@+  begin if is_char_node(s) then
    begin c:=qo(character(s)); hf:=font(s);
    end
@y
loop@+  begin if is_char_node(s) then
    begin hf:=font(s);
    if font_dir[hf]<>dir_default then
      begin prev_s:=s; s:=link(prev_s); c:=info(s); goto continue;
      end else c:=qo(character(s));
    end
  else if type(s)=disp_node then goto continue
  else if (type(s)=penalty_node)and(subtype(s)<>normal) then goto continue
@z

@x
    whatsit_node,glue_node,penalty_node,ins_node,adjust_node,mark_node:
      goto done4;
@y
    disp_node: do_nothing;
    whatsit_node,glue_node,penalty_node,ins_node,adjust_node,mark_node:
      goto done4;
@z

@x
loop@+  begin get_x_token;
  reswitch: case cur_cmd of
  letter,other_char,char_given:@<Append a new letter or hyphen@>;
  char_num: begin scan_char_num; cur_chr:=cur_val; cur_cmd:=char_given;
    goto reswitch;
    end;
@y
loop@+  begin get_x_token;
  reswitch:
  case cur_cmd of
  letter,other_char,kanji,kana,other_kchar,hangul,
    char_given,kchar_given:@<Append a new letter or hyphen@>;
  char_num,kchar_num: begin scan_char_num; cur_chr:=cur_val; cur_cmd:=char_given;
    goto reswitch;
    end;
@z

@x
@<Enter all of the patterns into a linked trie...@>=
k:=0; hyf[0]:=0; digit_sensed:=false;
loop@+  begin get_x_token;
  case cur_cmd of
  letter,other_char:@<Append a new letter or a hyphen level@>;
@y
@<Enter all of the patterns into a linked trie...@>=
k:=0; hyf[0]:=0; digit_sensed:=false;
loop@+  begin get_x_token;
  case cur_cmd of
  letter,other_char,kanji,kana,other_kchar,hangul:@<Append a new letter or a hyphen level@>;
@z

@x
  hlist_node,vlist_node,rule_node:@<Insert glue for |split_top_skip|
@y
  dir_node,
  hlist_node,vlist_node,rule_node:@<Insert glue for |split_top_skip|
@z

@x
hlist_node,vlist_node,rule_node: begin@t@>@;@/
@y
dir_node,
hlist_node,vlist_node,rule_node: begin@t@>@;@/
@z

@x
  if (active_height[3]<>0) or (active_height[4]<>0) or
    (active_height[5]<>0) then b:=0
  else b:=badness(h-cur_height,active_height[2])
else if cur_height-h>active_height[6] then b:=awful_bad
else b:=badness(cur_height-h,active_height[6])
@y
  if (active_height[3]<>0) or (active_height[4]<>0) or
    (active_height[5]<>0) or (active_height[6]<>0) then b:=0
  else b:=badness(h-cur_height,active_height[2])
else if cur_height-h>active_height[7] then b:=awful_bad
else b:=badness(cur_height-h,active_height[7])
@z

@x
  active_height[6]:=active_height[6]+shrink(q);
@y
  active_height[7]:=active_height[7]+shrink(q);
@z

@x
var v:pointer; {the box to be split}
@y
var v:pointer; {the box to be split}
w:pointer; {|dir_node|}
@z

@x
q:=prune_page_top(q,saving_vdiscards>0);
p:=list_ptr(v); free_node(v,box_node_size);
if q<>null then q:=vpack(q,natural);
change_box(q); {the |eq_level| of the box stays the same}
vsplit:=vpackage(p,h,exactly,split_max_depth);
@y
q:=prune_page_top(q,saving_vdiscards>0);
p:=list_ptr(v);
if q<>null then begin
    q:=vpack(q,natural); set_box_dir(q)(box_dir(v));
  end;
change_box(q);
q:=vpackage(p,h,exactly,split_max_depth);
set_box_dir(q)(box_dir(v));
delete_glue_ref(space_ptr(v)); delete_glue_ref(xspace_ptr(v));
free_node(v,box_node_size);
vsplit:=q;
@z

@x
if type(v)<>vlist_node then
  begin print_err(""); print_esc("vsplit"); print(" needs a ");
  print_esc("vbox");
@:vsplit_}{\.{\\vsplit needs a \\vbox}@>
  help2("The box you are trying to split is an \hbox.")@/
  ("I can't split such a box, so I'll leave it alone.");
  error; vsplit:=null; return;
  end
@y
if type(v)=dir_node then begin
  w:=v; v:=list_ptr(v);
  delete_glue_ref(space_ptr(w));
  delete_glue_ref(xspace_ptr(w));
  free_node(w,box_node_size);
end;
if type(v)<>vlist_node then begin
  print_err(""); print_esc("vsplit"); print(" needs a ");
  print_esc("vbox");
@:vsplit_}{\.{\\vsplit needs a \\vbox}@>
  help2("The box you are trying to split is an \hbox.")@/
  ("I can't split such a box, so I'll leave it alone.");
  error; vsplit:=null; return;
end;
flush_node_list(link(v)); link(v):=null
@z

@x
on the current page. This array contains six |scaled| numbers, like the
@y
on the current page. This array contains seven |scaled| numbers, like the
@z

@x
@d page_shrink==page_so_far[6] {shrinkability of the current page}
@d page_depth==page_so_far[7] {depth of the current page}
@y
@d page_shrink==page_so_far[7] {shrinkability of the current page}
@d page_depth==page_so_far[8] {depth of the current page}
@z

@x
@<Glob...@>=
@!page_so_far:array [0..7] of scaled; {height and glue of the current page}
@y
@<Glob...@>=
@!page_so_far:array [0..8] of scaled; {height and glue of the current page}
@z

@x
@!last_node_type:integer; {used to implement \.{\\lastnodetype}}
@y
@!last_node_type:integer; {used to implement \.{\\lastnodetype}}
@!last_node_subtype:integer; {used to implement \.{\\lastnodesubtype}}
@z

@x
primitive("pagefilstretch",set_page_dimen,3);
@!@:page_fil_stretch_}{\.{\\pagefilstretch} primitive@>
primitive("pagefillstretch",set_page_dimen,4);
@!@:page_fill_stretch_}{\.{\\pagefillstretch} primitive@>
primitive("pagefilllstretch",set_page_dimen,5);
@!@:page_filll_stretch_}{\.{\\pagefilllstretch} primitive@>
primitive("pageshrink",set_page_dimen,6);
@!@:page_shrink_}{\.{\\pageshrink} primitive@>
primitive("pagedepth",set_page_dimen,7);
@!@:page_depth_}{\.{\\pagedepth} primitive@>
@y
primitive("pagefistretch",set_page_dimen,3);
@!@:page_fi_stretch_}{\.{\\pagefistretch} primitive@>
primitive("pagefilstretch",set_page_dimen,4);
@!@:page_fil_stretch_}{\.{\\pagefilstretch} primitive@>
primitive("pagefillstretch",set_page_dimen,5);
@!@:page_fill_stretch_}{\.{\\pagefillstretch} primitive@>
primitive("pagefilllstretch",set_page_dimen,6);
@!@:page_filll_stretch_}{\.{\\pagefilllstretch} primitive@>
primitive("pageshrink",set_page_dimen,7);
@!@:page_shrink_}{\.{\\pageshrink} primitive@>
primitive("pagedepth",set_page_dimen,8);
@!@:page_depth_}{\.{\\pagedepth} primitive@>
@z

@x
3: print_esc("pagefilstretch");
4: print_esc("pagefillstretch");
5: print_esc("pagefilllstretch");
6: print_esc("pageshrink");
@y
3: print_esc("pagefistretch");
4: print_esc("pagefilstretch");
5: print_esc("pagefillstretch");
6: print_esc("pagefilllstretch");
7: print_esc("pageshrink");
@z

@x
print_plus(3)("fil");
print_plus(4)("fill");
print_plus(5)("filll");
@y
print_plus(3)("fi");
print_plus(4)("fil");
print_plus(5)("fill");
print_plus(6)("filll");
@z

@x
last_node_type:=-1;
@y
last_node_type:=-1; last_node_subtype:=-1;
@z

@x
begin p:=box(n);
if p<>null then if type(p)=hlist_node then
  begin print_err("Insertions can only be added to a vbox");
@y
begin p:=box(n);
if p<>null then if type(p)=dir_node then
  begin p:=list_ptr(p);
  delete_glue_ref(space_ptr(box(n)));
  delete_glue_ref(xspace_ptr(box(n)));
  free_node(box(n),box_node_size);
  box(n):=p
end;
if p<>null then if type(p)<>vlist_node then begin
  print_err("Insertions can only be added to a vbox");
@z

@x
last_node_type:=type(p)+1;
@y
if type(p)<dir_node then last_node_type:=type(p)+1
else if type(p)=dir_node then last_node_type:=type(list_ptr(p))+1
else if type(p)<disp_node then last_node_type:=type(p)
else last_node_type:=type(p)-1; {no |disp_node| in a vertical list}
last_node_subtype:=subtype(p);
@z

@x
hlist_node,vlist_node,rule_node: if page_contents<box_there then
    @<Initialize the current page, insert the \.{\\topskip} glue
      ahead of |p|, and |goto continue|@>
@y
hlist_node,vlist_node,dir_node,rule_node: if page_contents<box_there then
    @<Initialize the current page, insert the \.{\\topskip} glue
      ahead of |p|, and |goto continue|@>
@z

@x
  if (page_so_far[3]<>0) or (page_so_far[4]<>0) or@|
    (page_so_far[5]<>0) then b:=0
@y
  if (page_so_far[3]<>0) or (page_so_far[4]<>0) or@|
    (page_so_far[5]<>0) or (page_so_far[6]<>0) then b:=0
@z

@x
if box(n)=null then height(r):=0
else height(r):=height(box(n))+depth(box(n));
@y
if box(n)=null then height(r):=0
else
  begin if abs(ins_dir(p))<>abs(box_dir(box(n))) then
    begin print_err("Insertions can only be added to a same direction vbox");
@.Insertions can only...@>
    help3("Tut tut: You're trying to \insert into a")@/
      ("\box register that now have a different direction.")@/
      ("Proceed, and I'll discard its present contents.");
    box_error(n)
    end
  else
    height(r):=height(box(n))+depth(box(n));
  end;
@z

@x
box(255):=vpackage(link(page_head),best_size,exactly,page_max_depth);
@y
box(255):=vpackage(link(page_head),best_size,exactly,page_max_depth);
set_box_dir(box(255))(page_dir);
@z

@x
if best_ins_ptr(r)=null then wait:=true
else  begin wait:=false; s:=last_ins_ptr(r); link(s):=ins_ptr(p);
@y
if best_ins_ptr(r)=null then wait:=true
else  begin wait:=false;
  n:=qo(subtype(p));
  case abs(box_dir(box(n))) of
    any_dir:
      if abs(ins_dir(p))<>abs(box_dir(box(n))) then begin
        print_err("Insertions can only be added to a same direction vbox");
@.Insertions can only...@>
        help3("Tut tut: You're trying to \insert into a")@/
          ("\box register that now have a different direction.")@/
          ("Proceed, and I'll discard its present contents.");
        box_error(n);
        box(n):=new_null_box; last_ins_ptr(r):=box(n)+list_offset;
      end;
    othercases
      set_box_dir(box(n))(abs(ins_dir(p)));
  endcases;
  s:=last_ins_ptr(r); link(s):=ins_ptr(p);
@z

@x
      free_node(temp_ptr,box_node_size); wait:=true;
@y
      delete_glue_ref(space_ptr(temp_ptr));
      delete_glue_ref(xspace_ptr(temp_ptr));
      free_node(temp_ptr,box_node_size); wait:=true;
@z

@x
free_node(box(n),box_node_size);
box(n):=vpack(temp_ptr,natural);
@y
delete_glue_ref(space_ptr(box(n)));
delete_glue_ref(xspace_ptr(box(n)));
flush_node_list(link(box(n)));
free_node(box(n),box_node_size);
box(n):=vpack(temp_ptr,natural); set_box_dir(box(n))(abs(ins_dir(p)));
@z

@x
@d append_normal_space=120 {go here to append a normal space between words}
@y
@d append_normal_space=120 {go here to append a normal space between words}
@d main_loop_j=130 {like |main_loop|, but |cur_chr| holds a KANJI code}
@d skip_loop=141
@d again_2=150
@#
@d check_node_recipe(#)==
  begin cur_ptr:=null;
  find_sa_element(node_recipe_val,cur_chr,false);
  if (cur_ptr<>null)and(sa_ptr(cur_ptr)<>null) then
    begin begin_token_list(sa_ptr(cur_ptr), node_recipe_text); 
    get_x_token; goto #;
    end;
  end
@z

@x
procedure main_control; {governs \TeX's activities}
label big_switch,reswitch,main_loop,main_loop_wrapup,
@y
procedure main_control; {governs \TeX's activities}
label big_switch,reswitch,main_loop,main_loop_wrapup,
  main_loop_j,main_loop_j+1,main_loop_j+3,skip_loop,again_2,
@z

@x
  main_loop_lookahead,main_loop_lookahead+1,
@y
  main_loop_lookahead,main_loop_lookahead+1,main_loop_lookahead+2,
@z

@x
var@!t:integer; {general-purpose temporary variable}
@y
var@!t:integer; {general-purpose temporary variable}
@!cx:KANJI_code; {kanji character}
@!kp:pointer; {kinsoku penalty register}
@!gp,gq:pointer; {temporary registers for list manipulation}
@!disp:scaled; {displacement register}
@!ins_kp:boolean; {whether insert kinsoku penalty}
@z

@x
case abs(mode)+cur_cmd of
hmode+letter,hmode+other_char,hmode+char_given: goto main_loop;
hmode+char_num: begin scan_char_num; cur_chr:=cur_val; goto main_loop;@+end;
hmode+no_boundary: begin get_x_token;
  if (cur_cmd=letter)or(cur_cmd=other_char)or(cur_cmd=char_given)or
   (cur_cmd=char_num) then cancel_boundary:=true;
  goto reswitch;
  end;
@y
ins_kp:=false;
case abs(mode)+cur_cmd of
hmode+letter,hmode+other_char: begin check_node_recipe(reswitch); goto main_loop; end;
hmode+kanji,hmode+kana,hmode+other_kchar,hmode+hangul: goto main_loop_j;
hmode+kchar_given:
  begin cur_cmd:=kcat_code(cur_chr); goto main_loop_j; end;
hmode+char_given:
  if check_echar_range(cur_chr) then goto main_loop
  else begin cur_cmd:=kcat_code(cur_chr); goto main_loop_j; end;
hmode+char_num: begin scan_char_num; cur_chr:=cur_val;
  if check_echar_range(cur_chr) then goto main_loop
  else begin cur_cmd:=kcat_code(cur_chr); goto main_loop_j; end;
  end;
hmode+kchar_num: begin scan_char_num; cur_chr:=cur_val;
  cur_cmd:=kcat_code(cur_chr);
  goto main_loop_j;
  end;
hmode+no_boundary: begin get_x_token;
  if (cur_cmd=letter)or(cur_cmd=other_char)or
   ((cur_cmd>=kanji)and(cur_cmd<=hangul))or
   (cur_cmd=char_given)or(cur_cmd=char_num)or
   (cur_cmd=kchar_given)or(cur_cmd=kchar_num) then cancel_boundary:=true;
  goto reswitch;
  end;
@z

@x
main_loop:@<Append character |cur_chr| and the following characters (if~any)
  to the current hlist in the current font; |goto reswitch| when
  a non-character has been fetched@>;
@y
main_loop_j:@<Append KANJI-character |cur_chr|
  to the current hlist in the current font; |goto reswitch| when
  a non-character has been fetched@>;
main_loop: inhibit_glue_flag:=false;
@<Append character |cur_chr| and the following characters (if~any)
  to the current hlist in the current font; |goto reswitch| when
  a non-character has been fetched@>;
@z

@x
@<Append character |cur_chr|...@>=
if ((head=tail) and (mode>0)) then begin
  if (insert_src_special_auto) then append_src_special;
end;
adjust_space_factor;@/
@y
@<Append character |cur_chr|...@>=
if ((head=tail) and (mode>0)) then begin
  if (insert_src_special_auto) then append_src_special;
end;
adjust_space_factor;@/
if direction=dir_tate then disp:=t_baseline_shift else disp:=y_baseline_shift;
@<Append |disp_node| at begin of displace area@>;
@z

@x
if lig_stack=null then goto reswitch;
@y
if lig_stack=null then
  begin @<Append |disp_node| at end of displace area@>;
  goto reswitch;
  end;
@z

@x
@<Look ahead for another character...@>=
get_next; {set only |cur_cmd| and |cur_chr|, for speed}
if cur_cmd=letter then goto main_loop_lookahead+1;
if cur_cmd=other_char then goto main_loop_lookahead+1;
if cur_cmd=char_given then goto main_loop_lookahead+1;
x_token; {now expand and set |cur_cmd|, |cur_chr|, |cur_tok|}
if cur_cmd=letter then goto main_loop_lookahead+1;
if cur_cmd=other_char then goto main_loop_lookahead+1;
if cur_cmd=char_given then goto main_loop_lookahead+1;
if cur_cmd=char_num then
  begin scan_char_num; cur_chr:=cur_val; goto main_loop_lookahead+1;
  end;
if cur_cmd=no_boundary then bchar:=non_char;
cur_r:=bchar; lig_stack:=null; goto main_lig_loop;
main_loop_lookahead+1: adjust_space_factor;
fast_get_avail(lig_stack); font(lig_stack):=main_f;
cur_r:=qi(cur_chr); character(lig_stack):=cur_r;
if cur_r=false_bchar then cur_r:=non_char {this prevents spurious ligatures}
@y
@<Look ahead for another character...@>=
get_next; {set only |cur_cmd| and |cur_chr|, for speed}
if cur_cmd=letter then @<Look for \.{\\nptexnoderecipe}, and goto |main_lig_loop| if found@>;
if (cur_cmd>=kanji)and(cur_cmd<=hangul) then
  @<goto |main_lig_loop|@>;
if cur_cmd=other_char then @<Look for \.{\\nptexnoderecipe}, and goto |main_lig_loop| if found@>;
if cur_cmd=char_given then
  begin if check_echar_range(cur_chr) then goto main_loop_lookahead+1
  else begin cur_cmd:=kcat_code(cur_chr); @<goto |main_lig_loop|@>; end;
  end;
if cur_cmd=kchar_given then
  begin cur_cmd:=kcat_code(cur_chr); @<goto |main_lig_loop|@>; end;
x_token; {now expand and set |cur_cmd|, |cur_chr|, |cur_tok|}
if cur_cmd=letter then goto main_loop_lookahead+1;
if (cur_cmd>=kanji)and(cur_cmd<=hangul) then
  @<goto |main_lig_loop|@>;
if cur_cmd=other_char then goto main_loop_lookahead+1;
if cur_cmd=char_given then
  begin if check_echar_range(cur_chr) then goto main_loop_lookahead+1
  else begin cur_cmd:=kcat_code(cur_chr); @<goto |main_lig_loop|@>; end;
  end;
if cur_cmd=char_num then
  begin scan_char_num; cur_chr:=cur_val;
  if check_echar_range(cur_chr) then goto main_loop_lookahead+1
  else begin cur_cmd:=kcat_code(cur_chr); @<goto |main_lig_loop|@>; end;
  end;
if cur_cmd=kchar_num then
  begin scan_char_num; cur_chr:=cur_val;
  cur_cmd:=kcat_code(cur_chr); @<goto |main_lig_loop|@>;
  end;
if cur_cmd=inhibit_glue then
  begin inhibit_glue_flag:=true; goto main_loop_lookahead;
  end;
if cur_cmd=no_boundary then bchar:=non_char;
main_loop_lookahead+2: cur_r:=bchar; lig_stack:=null; goto main_lig_loop;
main_loop_lookahead+1: adjust_space_factor;
inhibit_glue_flag:=false;
fast_get_avail(lig_stack); font(lig_stack):=main_f;
cur_r:=qi(cur_chr); character(lig_stack):=cur_r;
if cur_r=false_bchar then cur_r:=non_char {this prevents spurious ligatures}

@ @<Look for \.{\\nptexnoderecipe}, and goto |main_lig_loop| if found@>=
begin check_node_recipe(main_loop_lookahead+2); print("B"); goto main_loop_lookahead+1; end

@ @<goto |main_lig_loop|@>=
begin bchar:=non_char; cur_r:=bchar; lig_stack:=null;
if ligature_present then pack_lig(rt_hit);
if ins_kp=true then
  begin cx:=cur_l; @<Insert kinsoku penalty@>;
  end;
ins_kp:=false;
goto main_loop_j;
end
@z

@x
link(tail):=temp_ptr; tail:=temp_ptr;
@y
if not is_char_node(tail)and(type(tail)=disp_node) then
  begin link(prev_node):=temp_ptr; link(temp_ptr):=tail; prev_node:=temp_ptr;
  end
else begin link(tail):=temp_ptr; tail:=temp_ptr;
  end;
@z

@x
link(tail):=q; tail:=q;
@y
if not is_char_node(tail)and(type(tail)=disp_node) then
  begin link(prev_node):=q; link(q):=tail; prev_node:=q;
  end
else begin link(tail):=q; tail:=q;
  end
@z

@x
any_mode(ignore_spaces): begin @<Get the next non-blank non-call...@>;
  goto reswitch;
  end;
@y
any_mode(ignore_spaces): begin
  if cur_chr = 0 then begin
    @<Get the next non-blank non-call...@>;
    goto reswitch;
  end
  else begin
    t:=scanner_status;
    scanner_status:=normal;
    get_next;
    scanner_status:=t;
    if cur_cs < hash_base then
      cur_cs := prim_lookup(cur_cs-single_base)
    else
      cur_cs  := prim_lookup(text(cur_cs));
    if cur_cs<>undefined_primitive then begin
      cur_cmd := prim_eq_type(cur_cs);
      cur_chr := prim_equiv(cur_cs);
      cur_tok := cs_token_flag+prim_eqtb_base+cur_cs;
      goto reswitch;
      end;
    end;
  end;
@z

@x
@<Math-only cases in non-math modes, or vice versa@>: insert_dollar_sign;
@y
@<Math-only cases in non-math modes, or vice versa@>: insert_dollar_sign;
mmode+par_end: if suppress_mathpar_error=0 then insert_dollar_sign;
@z

@x
non_math(math_given), non_math(math_comp), non_math(delim_num),
@y
non_math(math_given), non_math(omath_given),
non_math(math_comp), non_math(delim_num),
@z

@x
mmode+endv, mmode+par_end, mmode+stop, mmode+vskip, mmode+un_vbox,
mmode+valign, mmode+hrule
@y
mmode+endv, mmode+stop, mmode+vskip, mmode+un_vbox,
mmode+valign, mmode+hrule
@z

@x
vmode+hrule,hmode+vrule,mmode+vrule: begin tail_append(scan_rule_spec);
@y
vmode+hrule,hmode+vrule,mmode+vrule: begin tail_append(scan_rule_spec);
  inhibit_glue_flag := false;
@z

@x
@d fil_code=0 {identifies \.{\\hfil} and \.{\\vfil}}
@d fill_code=1 {identifies \.{\\hfill} and \.{\\vfill}}
@d ss_code=2 {identifies \.{\\hss} and \.{\\vss}}
@d fil_neg_code=3 {identifies \.{\\hfilneg} and \.{\\vfilneg}}
@d skip_code=4 {identifies \.{\\hskip} and \.{\\vskip}}
@d mskip_code=5 {identifies \.{\\mskip}}
@y
@d sfi_code=0 {identifies \.{\\hfi} and \.{\\vfi}}
@d fil_code=1 {identifies \.{\\hfil} and \.{\\vfil}}
@d fill_code=2 {identifies \.{\\hfill} and \.{\\vfill}}
@d ss_code=3 {identifies \.{\\hss} and \.{\\vss}}
@d fil_neg_code=4 {identifies \.{\\hfilneg} and \.{\\vfilneg}}
@d skip_code=5 {identifies \.{\\hskip} and \.{\\vskip}}
@d mskip_code=6 {identifies \.{\\mskip}}
@z

@x
primitive("hfil",hskip,fil_code);
@!@:hfil_}{\.{\\hfil} primitive@>
@y
primitive("hfi",hskip,sfi_code);
@!@:hfi_}{\.{\\hfi} primitive@>
primitive("hfil",hskip,fil_code);
@!@:hfil_}{\.{\\hfil} primitive@>
@z

@x
primitive("vfil",vskip,fil_code);
@!@:vfil_}{\.{\\vfil} primitive@>
@y
primitive("vfi",vskip,sfi_code);
@!@:vfi_}{\.{\\vfi} primitive@>
primitive("vfil",vskip,fil_code);
@!@:vfil_}{\.{\\vfil} primitive@>
@z

@x
hskip: case chr_code of
  skip_code:print_esc("hskip");
@y
hskip: case chr_code of
  skip_code:print_esc("hskip");
  sfi_code:print_esc("hfi");
@z

@x
vskip: case chr_code of
  skip_code:print_esc("vskip");
@y
vskip: case chr_code of
  skip_code:print_esc("vskip");
  sfi_code:print_esc("vfi");
@z

@x
begin s:=cur_chr;
case s of
fil_code: cur_val:=fil_glue;
@y
begin s:=cur_chr;
case s of
sfi_code: cur_val:=sfi_glue;
fil_code: cur_val:=fil_glue;
@z

@x
end; {now |cur_val| points to the glue specification}
tail_append(new_glue(cur_val));
if s>=skip_code then
@y
end; {now |cur_val| points to the glue specification}
tail_append(new_glue(cur_val));
inhibit_glue_flag := false;
if s>=skip_code then
@z

@x
begin s:=cur_chr; scan_dimen(s=mu_glue,false,false);
tail_append(new_kern(cur_val)); subtype(tail):=s;
end;
@y
begin s:=cur_chr; scan_dimen(s=mu_glue,false,false);
inhibit_glue_flag := false;
if not is_char_node(tail)and(type(tail)=disp_node) then
  begin prev_append(new_kern(cur_val)); subtype(prev_node):=s;
  end
else
  begin tail_append(new_kern(cur_val)); subtype(tail):=s;
  end;
end;
@z

@x
var p,@!q:pointer; {for short-term use}
@y
var p,@!q:pointer; {for short-term use}
@!r:pointer; {temporary}
@z

@x
|global_box_flag-1| represent `\.{\\setbox0}' through `\.{\\setbox32767}';
codes |global_box_flag| through |ship_out_flag-1| represent
`\.{\\global\\setbox0}' through `\.{\\global\\setbox32767}';
@y
|global_box_flag-1| represent `\.{\\setbox0}' through `\.{\\setbox65535}';
codes |global_box_flag| through |ship_out_flag-1| represent
`\.{\\global\\setbox0}' through `\.{\\global\\setbox65535}';
@z

@x
@d box_flag==@'10000000000 {context code for `\.{\\setbox0}'}
@d global_box_flag==@'10000100000 {context code for `\.{\\global\\setbox0}'}
@d ship_out_flag==@'10000200000  {context code for `\.{\\shipout}'}
@d leader_flag==@'10000200001  {context code for `\.{\\leaders}'}
@y
@d box_flag==@"40000000 {context code for `\.{\\setbox0}'}
@d global_box_flag==@"40010000 {context code for `\.{\\global\\setbox0}'}
@d ship_out_flag==@"40020000  {context code for `\.{\\shipout}'}
@d leader_flag==@"40020001  {context code for `\.{\\leaders}'}
@z

@x
primitive("hbox",make_box,vtop_code+hmode);@/
@!@:hbox_}{\.{\\hbox} primitive@>
@y
primitive("hbox",make_box,vtop_code+hmode);@/
@!@:hbox_}{\.{\\hbox} primitive@>
primitive("tate",chg_dir,dir_tate);@/
@!@:tate_}{\.{\\tate} primitive@>
primitive("yoko",chg_dir,dir_yoko);@/
@!@:yoko_}{\.{\\yoko} primitive@>
primitive("dtou",chg_dir,dir_dtou);@/
@!@:dtou_}{\.{\\dtou} primitive@>
@z

@x
  othercases print_esc("hbox")
  endcases;
leader_ship: if chr_code=a_leaders then print_esc("leaders")
@y
  othercases print_esc("hbox")
  endcases;
chg_dir:
  case chr_code of
    dir_yoko: print_esc("yoko");
    dir_tate: print_esc("tate");
    dir_dtou: print_esc("dtou");
  endcases;
leader_ship: if chr_code=a_leaders then print_esc("leaders")
@z

@x
any_mode(make_box): begin_box(0);
@y
any_mode(make_box): begin_box(0);
any_mode(chg_dir):
  begin  if cur_group<>align_group then
    if mode=hmode then
      begin print_err("Improper `"); print_cmd_chr(cur_cmd,cur_chr);
      print("'");
      help2("You cannot change the direction in unrestricted")
      ("horizontal mode."); error;
      end
    else if abs(mode)=mmode then
      begin print_err("Improper `"); print_cmd_chr(cur_cmd,cur_chr);
      print("'");
      help1("You cannot change the direction in math mode."); error;
      end
    else if nest_ptr=0 then change_page_direction(cur_chr)
    else if head=tail then direction:=cur_chr
    else begin print_err("Use `"); print_cmd_chr(cur_cmd,cur_chr);
      print("' at top of list");
      help2("Direction change command is available only while")
      ("current list is null."); error;
      end
  else begin print_err("You can't use `"); print_cmd_chr(cur_cmd,cur_chr);
    print("' in an align");
    help2("To change direction in an align,")
    ("you shold use \hbox or \vbox with \tate or \yoko."); error;
    end
  end;
@z

@x
var p:pointer; {|ord_noad| for new box in math mode}
@y
var p:pointer; {|ord_noad| for new box in math mode}
q:pointer;
@z

@x
  begin shift_amount(cur_box):=box_context;
@y
  begin p:=link(cur_box); link(cur_box):=null;
  while p<>null do begin
    q:=p; p:=link(p);
    if abs(box_dir(q))=abs(direction) then
      begin list_ptr(q):=cur_box; cur_box:=q; link(cur_box):=null;
      end
    else begin
      delete_glue_ref(space_ptr(q));
      delete_glue_ref(xspace_ptr(q));
      free_node(q,box_node_size);
      end;
  end;
  if abs(box_dir(cur_box))<>abs(direction) then
    cur_box:=new_dir_node(cur_box,abs(direction));
  shift_amount(cur_box):=box_context;
@z

@x
  if abs(mode)=vmode then
    begin append_to_vlist(cur_box);
    if adjust_tail<>null then
      begin if adjust_head<>adjust_tail then
        begin link(tail):=link(adjust_head); tail:=adjust_tail;
        end;
      adjust_tail:=null;
      end;
    if mode>0 then build_page;
    end
@y
  if abs(mode)=vmode then
    begin
        if pre_adjust_tail <> null then begin
            if pre_adjust_head <> pre_adjust_tail then
                append_list(pre_adjust_head)(pre_adjust_tail);
            pre_adjust_tail := null;
        end;
        append_to_vlist(cur_box);
        if adjust_tail <> null then begin
            if adjust_head <> adjust_tail then
                append_list(adjust_head)(adjust_tail);
            adjust_tail := null;
        end;
    if mode>0 then build_page;
    end
@z

@x
  else  begin if abs(mode)=hmode then space_factor:=1000
    else  begin p:=new_noad;
      math_type(nucleus(p)):=sub_box;
@y
  else  begin if abs(mode)=hmode then
    begin space_factor:=1000; inhibit_glue_flag:=false; end
    else  begin p:=new_noad;
      math_type(nucleus(p)):=sub_exp_box;
@z

@x
  begin append_glue; subtype(tail):=box_context-(leader_flag-a_leaders);
  leader_ptr(tail):=cur_box;
  end
@y
  begin append_glue; subtype(tail):=box_context-(leader_flag-a_leaders);
  if type(cur_box)<=dir_node then
    begin p:=link(cur_box); link(cur_box):=null;
    while p<>null do
      begin q:=p; p:=link(p);
      if abs(box_dir(q))=abs(direction) then
        begin list_ptr(q):=cur_box; cur_box:=q; link(cur_box):=null;
        end
      else begin
        delete_glue_ref(space_ptr(q));
        delete_glue_ref(xspace_ptr(q));
        free_node(q,box_node_size);
        end;
      end;
    if abs(box_dir(cur_box))<>abs(direction) then
      cur_box:=new_dir_node(cur_box,abs(direction));
    end;
  leader_ptr(tail):=cur_box;
  end
@z

@x
@!r:pointer; {running behind |p|}
@!fm:boolean; {a final \.{\\beginM} \.{\\endM} node pair?}
@!tx:pointer; {effective tail node}
@!m:quarterword; {the length of a replacement list}
@y
@!r:pointer; {running behind |p|}
@!s:pointer; {running behind |r|}
@!t:pointer;
@!fm:integer; {1: if |r|, 2: if |p| is a \.{\\beginM} node}
@!gm:integer; {1: if |link(q)|, 2: if |q| is an  \.{\\endM} node}
@!fd,@!gd:integer; {same for |disp_node|}
@!disp,@!pdisp:scaled; {displacement}
@!a_dir:eight_bits; {adjust direction}
@!tx:pointer; {effective tail node}
@!m:quarterword; {the length of a replacement list}
@z

@x
@ Note that the condition |not is_char_node(tail)| implies that |head<>tail|,
since |head| is a one-word node.
@y
@ Note that in \TeX\ the condition |not is_char_node(tail)| implies that
|head<>tail|, since |head| is a one-word node; this is not so for \pTeX.
@z

@x
@d check_effective_tail(#)==find_effective_tail_eTeX
@d fetch_effective_tail==fetch_effective_tail_eTeX

@<If the current list ends with a box node, delete it...@>=
@y
@d check_effective_tail_pTeX(#)==
tx:=tail;
if not is_char_node(tx) then
  if type(tx)=disp_node then
    begin tx:=prev_node;
    if not is_char_node(tx) then
      if type(tx)=disp_node then #; {|disp_node| from a discretionary}
    end
@#
@d fetch_effective_tail_pTeX(#)== {extract |tx|, merge |disp_node| pair}
q:=head; p:=null; disp:=0; pdisp:=0;
repeat r:=p; p:=q; fd:=false;
if not is_char_node(q) then
  if type(q)=disc_node then
    begin for m:=1 to replace_count(q) do p:=link(p);
    if p=tx then #;
    end
  else if type(q)=disp_node then
    begin pdisp:=disp; disp:=disp_dimen(q); fd:=true;@+end;
q:=link(p);
until q=tx; {found |r|$\to$|p|$\to$|q=tx|}
q:=link(tx); link(p):=q; link(tx):=null;
if q=null then tail:=p
else if fd then {|r|$\to$|p=disp_node|$\to$|q=disp_node|}
  begin prev_node:=r; prev_disp:=pdisp; link(p):=null; tail:=p;
  disp_dimen(p):=disp_dimen(q); free_node(q,small_node_size);
  end
else prev_node:=p
@#
@d fetch_effective_tail_epTeX(#)== {extract |tx|,
  drop \.{\\beginM} \.{\\endM} pair and\slash or merge |disp_node| pair}
q:=head; p:=null; r:=null; fm:=0; fd:=0; disp:=0; pdisp:=0;
repeat s:=r; r:=p; p:=q; fm:=fm div 2; fd:=fd div 2;
if not is_char_node(q) then
  if type(q)=disc_node then
    begin for m:=1 to replace_count(q) do
      begin p:=link(p); if p=tx then #; end
      { |tx| might be a part of discretionary; in this case, nothing will be removed}
    end
  else if (type(q)=math_node)and(subtype(q)=begin_M_code) then fm:=2
  else if type(q)=disp_node then
    begin pdisp:=disp; disp:=disp_dimen(q); fd:=2;@+end;
q:=link(p);
until q=tx; {found |s|$\to$|r|$\to$|p|$\to$|q=tx|}
q:=link(tx); link(p):=q; link(tx):=null;
if q=null then  begin tail:=p; gm:=0; gd:=0;@+end
else  begin if type(q)=math_node then
    begin gm:=2;
    if link(q)=null then gd:=0
    else if type(link(q))=disp_node then gd:=1
    else confusion("tail3");
@:this can't happen tail3}{\quad tail3@>
    end
  else if type(q)=disp_node then
    begin prev_node:=p; gd:=2;
    if link(q)=null then gm:=0
    else if type(link(q))=math_node then gm:=1
    else confusion("tail4");
@:this can't happen tail4}{\quad tail4@>
    end
  else confusion("tail5");
@:this can't happen tail5}{\quad tail5@>
  end;
if gm=0 then if fm=2 then confusion("tail1")
@:this can't happen tail1}{\quad tail1@>
  else if fm=1 then confusion("tail2");
@:this can't happen tail2}{\quad tail2@>
if (fm+fd)=1 then begin fm:=0; fd:=0;@+end;
if gm=0 then fm:=0;
if gd=0 then fd:=0;
@#
if fd>0 then {merge a |disp_node| pair}
  begin if gm=0 then {|p|$\to$|q=disp_node|$to$|null|}
    begin t:=q; q:=null; link(p):=q; tail:=p;@+end
  else if gm=1 then {|p|$\to$|q=disp_node|$to$|end_M|$to$|null|}
    begin t:=q; q:=link(q); link(p):=q; gm:=2;@+end
  else {|p|$\to$|q=end_M|$\to$|disp_node|$to$|null|}
    begin t:=link(q); link(q):=null; tail:=q;@+end;
@#
  if fd=1 then {|s|$\to$|r=disp_node|}
    begin prev_node:=s; disp_dimen(r):=disp_dimen(t);@+end
  else {|r|$\to$|p=disp_node|}
    begin prev_node:=r; disp_dimen(p):=disp_dimen(t);@+end;
  prev_disp:=pdisp; free_node(t,small_node_size); gd:=0;
  end;
@#
if fm>0 then {drop \.{\\beginM} \.{\\endM} pair}
  begin if gd=0 then {|p|$\to$|q=end_M|$to$|null|}
    begin t:=q; q:=null; link(p):=q; tail:=p;@+end
  else if gd=1 then {|p|$\to$|q=end_M|$to$|disp_node|$to$|null|}
    begin t:=q; q:=link(q); link(p):=q; prev_node:=p; link(t):=null
    end
  else {|p|$\to$|q=disp_node|$\to$|end_M|$to$|null|}
    begin t:=link(q); link(q):=null; tail:=q;@+end;
@#
  if fm=1 then {|s|$\to$|r=begin_M|$\to$|p=disp_node|}
    begin link(s):=p; link(r):=t; t:=r; prev_node:=s;@+end
  else {|r|$\to$|p=begin_M|$\to$|q|}
    begin link(r):=q; link(p):=t; t:=p;
    if q=null then tail:=r@+else prev_node:=r;
    end;
  flush_node_list(t);
  end
@#
@d check_effective_tail(#)==find_effective_tail_epTeX
@d fetch_effective_tail==fetch_effective_tail_epTeX

@<If the current list ends with a box node, delete it...@>=
@z

@x
else  begin check_effective_tail(goto done);
  if not is_char_node(tx) then
    if (type(tx)=hlist_node)or(type(tx)=vlist_node) then
      @<Remove the last box, unless it's part of a discretionary@>;
  done:end;
@y
else  begin check_effective_tail(goto done);
  if not is_char_node(tx)and(head<>tx) then
    if (type(tx)=hlist_node)or(type(tx)=vlist_node)
       or(type(tx)=dir_node) then
      @<Remove the last box, unless it's part of a discretionary@>;
  done:end;
@z

@x
begin fetch_effective_tail(goto done);
cur_box:=tx; shift_amount(cur_box):=0;
end
@y
begin fetch_effective_tail(goto done);
cur_box:=tx; shift_amount(cur_box):=0;
if type(cur_box)=dir_node then
  begin link(list_ptr(cur_box)):=cur_box;
  cur_box:=list_ptr(cur_box);
  list_ptr(link(cur_box)):=null;
  end
else
  if box_dir(cur_box)=dir_default then set_box_dir(cur_box)(direction);
end
@z

@x
if k=hmode then
  if (box_context<box_flag)and(abs(mode)=vmode) then
    scan_spec(adjusted_hbox_group,true)
  else scan_spec(hbox_group,true)
else  begin if k=vmode then scan_spec(vbox_group,true)
  else  begin scan_spec(vtop_group,true); k:=vmode;
    end;
  normal_paragraph;
  end;
push_nest; mode:=-k;
@y
a_dir:=adjust_dir;
if k=hmode then
  if (box_context<box_flag)and(abs(mode)=vmode) then
    begin a_dir:=abs(direction); scan_spec(adjusted_hbox_group,true);
    end
  else scan_spec(hbox_group,true)
else  begin if k=vmode then scan_spec(vbox_group,true)
  else  begin scan_spec(vtop_group,true); k:=vmode;
    end;
  normal_paragraph;
  end;
push_nest; mode:=-k; adjust_dir:=a_dir;
@z

@x
else  begin space_factor:=1000;
@y
else  begin space_factor:=1000; inhibit_glue_flag:=false;
@z

@x
hbox_group: package(0);
adjusted_hbox_group: begin adjust_tail:=adjust_head; package(0);
  end;
@y
hbox_group: begin adjust_hlist(head,false); package(0);
  end;
adjusted_hbox_group: begin adjust_hlist(head,false);
  adjust_tail:=adjust_head;
  pre_adjust_tail:=pre_adjust_head; package(0);
  end;
@z

@x
begin d:=box_max_depth; unsave; save_ptr:=save_ptr-3;
if mode=-hmode then cur_box:=hpack(link(head),saved(2),saved(1))
else  begin cur_box:=vpackage(link(head),saved(2),saved(1),d);
  if c=vtop_code then @<Readjust the height and depth of |cur_box|,
    for \.{\\vtop}@>;
  end;
pop_nest; box_end(saved(0));
end;
@y
begin d:=box_max_depth;
  delete_glue_ref(cur_kanji_skip); delete_glue_ref(cur_xkanji_skip);
  if auto_spacing>0 then cur_kanji_skip:=kanji_skip
  else cur_kanji_skip:=zero_glue;
  if auto_xspacing>0 then cur_xkanji_skip:=xkanji_skip
  else cur_xkanji_skip:=zero_glue;
  add_glue_ref(cur_kanji_skip); add_glue_ref(cur_xkanji_skip);
  unsave; save_ptr:=save_ptr-3;
  if mode=-hmode then begin
    cur_box:=hpack(link(head),saved(2),saved(1));
    set_box_dir(cur_box)(direction); pop_nest;
  end else begin
    cur_box:=vpackage(link(head),saved(2),saved(1),d);
    set_box_dir(cur_box)(direction); pop_nest;
    if c=vtop_code then
      @<Readjust the height and depth of |cur_box|, for \.{\\vtop}@>;
  end;
  box_end(saved(0));
end;
@z

@x
vmode+letter,vmode+other_char,vmode+char_num,vmode+char_given,
   vmode+math_shift,vmode+un_hbox,vmode+vrule,
   vmode+accent,vmode+discretionary,vmode+hskip,vmode+valign,
   vmode+ex_space,vmode+no_boundary:@t@>@;@/
  begin back_input; new_graf(true);
  end;
@y
vmode+letter,vmode+other_char,vmode+char_num,vmode+char_given,
   vmode+kchar_num,vmode+kchar_given,
   vmode+math_shift,vmode+un_hbox,vmode+vrule,
   vmode+accent,vmode+discretionary,vmode+hskip,vmode+valign,
   vmode+kanji,vmode+kana,vmode+other_kchar,vmode+hangul,
   vmode+ex_space,vmode+no_boundary:@t@>@;@/
  begin back_input; new_graf(true);
  end;
@z

@x
push_nest; mode:=hmode; space_factor:=1000; set_cur_lang; clang:=cur_lang;
@y
inhibit_glue_flag := false;
push_nest; adjust_dir:=direction;
mode:=hmode; space_factor:=1000; set_cur_lang; clang:=cur_lang;
@z

@x
  if abs(mode)=hmode then space_factor:=1000
@y
  if abs(mode)=hmode then
    begin space_factor:=1000; inhibit_glue_flag:=false; end
@z

@x
  begin if head=tail then pop_nest {null paragraphs are ignored}
  else line_break(false);
@y
  begin if (link(head)=tail)and(not is_char_node(tail)and(type(tail)=disp_node)) then
    begin free_node(tail,small_node_size); tail:=head; link(head):=null; end;
    { |disp_node|-only paragraphs are ignored }
  if head=tail then pop_nest {null paragraphs are ignored}
  else begin adjust_hlist(head,true); line_break(false)
       end;
@z

@x
saved(0):=cur_val; incr(save_ptr);
@y
saved(0) := cur_val;
if (cur_cmd = vadjust) and scan_keyword("pre") then
    saved(1) := 1
else
    saved(1) := 0;
save_ptr := save_ptr + 2;
@z

@x
new_save_level(insert_group); scan_left_brace; normal_paragraph;
push_nest; mode:=-vmode; prev_depth:=ignore_depth;
@y
inhibit_glue_flag:=false;
new_save_level(insert_group); scan_left_brace; normal_paragraph;
push_nest; mode:=-vmode; direction:=adjust_dir; prev_depth:=ignore_depth;
@z

@x
  d:=split_max_depth; f:=floating_penalty; unsave; decr(save_ptr);
@y
  d:=split_max_depth; f:=floating_penalty; unsave; save_ptr := save_ptr - 2;
@z

@x
  {now |saved(0)| is the insertion number, or 255 for |vadjust|}
  p:=vpack(link(head),natural); pop_nest;
  if saved(0)<255 then
    begin tail_append(get_node(ins_node_size));
    type(tail):=ins_node; subtype(tail):=qi(saved(0));
    height(tail):=height(p)+depth(p); ins_ptr(tail):=list_ptr(p);
    split_top_ptr(tail):=q; depth(tail):=d; float_cost(tail):=f;
    end
  else  begin tail_append(get_node(small_node_size));
    type(tail):=adjust_node;@/
    subtype(tail):=0; {the |subtype| is not used}
    adjust_ptr(tail):=list_ptr(p); delete_glue_ref(q);
    end;
  free_node(p,box_node_size);
  if nest_ptr=0 then build_page;
  end;
@y
  {now |saved(0)| is the insertion number, or 255 for |vadjust|}
  p:=vpack(link(head),natural); set_box_dir(p)(direction); pop_nest;
  if saved(0)<255 then
    begin r:=get_node(ins_node_size);
    type(r):=ins_node; subtype(r):=qi(saved(0));
    height(r):=height(p)+depth(p); ins_ptr(r):=list_ptr(p);
    split_top_ptr(r):=q; depth(r):=d; float_cost(r):=f;
    set_ins_dir(r)(box_dir(p));
    if not is_char_node(tail)and(type(tail)=disp_node) then
      prev_append(r)
    else tail_append(r);
    end
  else  begin
    if abs(box_dir(p))<>abs(adjust_dir) then
      begin print_err("Direction Incompatible");
      help1("\vadjust's argument and outer vlist must have same direction.");
      error; flush_node_list(list_ptr(p));
      end
    else  begin
      r:=get_node(small_node_size); type(r):=adjust_node;@/
      adjust_pre(r) := saved(1); {the |subtype| is used for |adjust_pre|}
      adjust_ptr(r):=list_ptr(p); delete_glue_ref(q);
      if not is_char_node(tail)and(type(tail)=disp_node) then
        prev_append(r)
      else tail_append(r);
      end;
    end;
  delete_glue_ref(space_ptr(p));
  delete_glue_ref(xspace_ptr(p));
  free_node(p,box_node_size);
  if nest_ptr=0 then build_page;
  end;
@z

@x
mark_ptr(p):=def_ref; link(tail):=p; tail:=p;
@y
inhibit_glue_flag:=false;
mark_ptr(p):=def_ref;
if not is_char_node(tail)and(type(tail)=disp_node) then
  prev_append(p)
else tail_append(p);
@z

@x
procedure append_penalty;
begin scan_int; tail_append(new_penalty(cur_val));
if mode=vmode then build_page;
end;
@y
procedure append_penalty;
begin scan_int;
  inhibit_glue_flag:=false;
  if not is_char_node(tail)and(type(tail)=disp_node) then
    prev_append(new_penalty(cur_val))
  else tail_append(new_penalty(cur_val));
  if mode=vmode then build_page;
end;
@z

@x
@!r:pointer; {running behind |p|}
@!fm:boolean; {a final \.{\\beginM} \.{\\endM} node pair?}
@!tx:pointer; {effective tail node}
@!m:quarterword; {the length of a replacement list}
@y
@!r:pointer; {running behind |p|}
@!s:pointer; {running behind |r|}
@!t:pointer;
@!fm:integer; {1: if |r|, 2: if |p| is a \.{\\beginM} node}
@!gm:integer; {1: if |link(q)|, 2: if |q| is an  \.{\\endM} node}
@!fd,@!gd:integer; {same for |disp_node|}
@!disp,@!pdisp:scaled; {displacement}
@!tx:pointer; {effective tail node}
@!m:quarterword; {the length of a replacement list}
@z

@x
else  begin check_effective_tail(return);
  if not is_char_node(tx) then if type(tx)=cur_chr then
    begin fetch_effective_tail(return);
    flush_node_list(tx);
@y
else  begin check_effective_tail(return);
  if not is_char_node(tx) then if type(tx)=cur_chr then
    begin fetch_effective_tail(return);
    flush_node_list(tx);
@z

@x
var p:pointer; {the box}
@!c:box_code..copy_code; {should we copy?}
@y
var p:pointer; {the box}
@!c:box_code..copy_code; {should we copy?}
@!disp:scaled; {displacement}
@z

@x
if (abs(mode)=mmode)or((abs(mode)=vmode)and(type(p)<>vlist_node))or@|
   ((abs(mode)=hmode)and(type(p)<>hlist_node)) then
  begin print_err("Incompatible list can't be unboxed");
@.Incompatible list...@>
  help3("Sorry, Pandora. (You sneaky devil.)")@/
  ("I refuse to unbox an \hbox in vertical mode or vice versa.")@/
  ("And I can't open any boxes in math mode.");@/
  error; return;
  end;
if c=copy_code then link(tail):=copy_node_list(list_ptr(p))
else  begin link(tail):=list_ptr(p); change_box(null);
  free_node(p,box_node_size);
  end;
@y
if type(p)=dir_node then p:=list_ptr(p);
if (abs(mode)=mmode)or((abs(mode)=vmode)and(type(p)<>vlist_node))or@|
    ((abs(mode)=hmode)and(type(p)<>hlist_node)) then
  begin print_err("Incompatible list can't be unboxed");
@.Incompatible list...@>
  help3("Sorry, Pandora. (You sneaky devil.)")@/
  ("I refuse to unbox an \hbox in vertical mode or vice versa.")@/
  ("And I can't open any boxes in math mode.");@/
  error; return;
end;
case abs(box_dir(p)) of
  any_dir:
    if abs(direction)<>abs(box_dir(p)) then begin
      print_err("Incompatible direction list can't be unboxed");
      help2("Sorry, Pandora. (You sneaky devil.)")@/
      ("I refuse to unbox a box in different direction.");@/
      error; return;
    end;
endcases;
disp:=0;
if c=copy_code then link(tail):=copy_node_list(list_ptr(p))
else
  begin if type(p)=dir_node then
    begin delete_glue_ref(space_ptr(p));
    delete_glue_ref(xspace_ptr(p));
    free_node(p,box_node_size);
    end;
  flush_node_list(link(p));
  link(tail):=list_ptr(p); change_box(null);
  delete_glue_ref(space_ptr(p));
  delete_glue_ref(xspace_ptr(p));
  free_node(p,box_node_size);
  end;
@z

@x
while link(tail)<>null do tail:=link(tail);
@y
while link(tail)<>null do
  {reset |inhibit_glue_flag| when a node other than |disp_node| is found;
   |disp_node| is always inserted according to tex-jp-build issue 40}
  begin p:=tail; tail:=link(tail);
  if is_char_node(tail) then
    inhibit_glue_flag:=false
  else
    case type(tail) of
    glue_node : begin
      inhibit_glue_flag:=false;
      if (subtype(tail)=kanji_skip_code+1)
             or(subtype(tail)=xkanji_skip_code+1) then
        begin link(p):=link(tail);
        delete_glue_ref(glue_ptr(tail));
        free_node(tail,small_node_size); tail:=p;
        end;
      end;
    penalty_node : begin
      inhibit_glue_flag:=false;
      if subtype(tail)=widow_pena then
        begin link(p):=link(tail); free_node(tail,small_node_size);
        tail:=p;
        end;
      end;
    disp_node :
      begin prev_disp:=disp; disp:=disp_dimen(tail); prev_node:=p;
      end;
    othercases inhibit_glue_flag:=false;
    endcases;
  end;
@z

@x
procedure append_italic_correction;
label exit;
var p:pointer; {|char_node| at the tail of the current list}
@!f:internal_font_number; {the font in the |char_node|}
begin if tail<>head then
  begin if is_char_node(tail) then p:=tail
  else if type(tail)=ligature_node then p:=lig_char(tail)
  else return;
  f:=font(p);
  tail_append(new_kern(char_italic(f)(char_info(f)(character(p)))));
  subtype(tail):=explicit;
  end;
@y
procedure append_italic_correction;
label exit;
var p:pointer; {|char_node| at the tail of the current list}
@!f:internal_font_number; {the font in the |char_node|}
@!d:pointer; {|disp_node|}
begin if tail<>head then
  begin
  if not is_char_node(tail)and(type(tail)=disp_node) then
    begin d:=tail; tail:=prev_node;
    end
  else d:=null;
  if (last_jchr<>null)and(link(last_jchr)=tail)and(is_char_node(tail)) then
    p:=last_jchr
  else if is_char_node(tail) then p:=tail
  else if type(tail)=ligature_node then p:=lig_char(tail)
  else return;
  f:=font(p);
  tail_append(new_kern(char_italic(f)(char_info(f)(character(p)))));
  subtype(tail):=ita_kern;
  if d<>null then
    begin prev_node:=tail; tail_append(d);
    end;
  end;
@z

@x
procedure append_discretionary;
var c:integer; {hyphen character}
begin tail_append(new_disc);
@y
procedure append_discretionary;
var c:integer; {hyphen character}
begin tail_append(new_disc); inhibit_glue_flag:=false;
@z

@x
@!n:integer; {length of discretionary list}
@y
@!n:integer; {length of discretionary list}
@!d:integer; {direction}
@z

@x
p:=link(head); pop_nest;
case saved(-1) of
0:pre_break(tail):=p;
1:post_break(tail):=p;
@y
p:=link(head); d:=abs(direction); pop_nest;
case saved(-1) of
0:if abs(direction)=d then pre_break(tail):=p
  else begin
    print_err("Direction Incompatible");
    help2("\discretionary's argument and outer hlist must have same direction.")@/
    ("I delete your first part."); error; pre_break(tail):=null; flush_node_list(p);
  end;
1:if abs(direction)=d then post_break(tail):=p
  else begin
    print_err("Direction Incompatible");
    help2("\discretionary's argument and outer hlist must have same direction.")@/
    ("I delete your second part."); error; post_break(tail):=null; flush_node_list(p);
  end;
@z

@x
push_nest; mode:=-hmode; space_factor:=1000;
@y
push_nest; mode:=-hmode; space_factor:=1000; inhibit_glue_flag:=false;
@z

@x
else link(tail):=p;
if n<=max_quarterword then replace_count(tail):=n
@y
else if (n>0)and(abs(direction)<>d) then
  begin print_err("Direction Incompatible");
  help2("\discretionary's argument and outer hlist must have same direction.")@/
  ("I delete your third part."); flush_node_list(p); n:=0; error;
  end
else link(tail):=p;
if n<=max_quarterword then replace_count(tail):=n
@z

@x
decr(save_ptr); return;
@y
decr(save_ptr);
prev_node:=tail; tail_append(get_node(small_node_size));
type(tail):=disp_node; disp_dimen(tail):=0; prev_disp:=0;
return;
@z

@x
  begin if not is_char_node(p) then if type(p)>rule_node then
    if type(p)<>kern_node then if type(p)<>ligature_node then
      begin print_err("Improper discretionary list");
@y
  begin if not is_char_node(p) then
    if (type(p)>rule_node)and(type(p)<>kern_node)and
         (type(p)<>ligature_node)and(type(p)<>disp_node) then
      if (type(p)=penalty_node)and(subtype(p)<>normal) then
        begin link(q):=link(p); free_node(p,small_node_size); p:=q;
        end
      else
        begin print_err("Improper discretionary list");
@z

@x
var s,@!t: real; {amount of slant}
@y
var s,@!t: real; {amount of slant}
@!disp:scaled; {displacement}
@!cx:KANJI_code; {temporary register for KANJI}
@z

@x
begin scan_char_num; f:=cur_font; p:=new_character(f,cur_val);
@y
begin scan_char_num;
if not check_echar_range(cur_val) then
  begin KANJI(cx):=cur_val;
  if direction=dir_tate then f:=cur_tfont else f:=cur_jfont;
  p:=new_character(f,get_jfm_pos(KANJI(cx),f));
  if p<>null then
     begin
        link(p):=get_avail;
        if cat_code(cur_val)=other_char then
          info(link(p)):=KANJI(cx) + max_char_val
        else info(link(p)):=KANJI(cx);
     end;
  end
else begin f:=cur_font; p:=new_character(f,cur_val);
  end;
@z

@x
  link(tail):=p; tail:=p; space_factor:=1000;
@y
  link(tail):=p;
  if link(p)<>null then tail:=link(p) else tail:=p;
  @<Append |disp_node| at end of displace area@>;
  space_factor:=1000; inhibit_glue_flag:=false;
@z

@x
q:=null; f:=cur_font;
if (cur_cmd=letter)or(cur_cmd=other_char)or(cur_cmd=char_given) then
  q:=new_character(f,cur_chr)
else if cur_cmd=char_num then
  begin scan_char_num; q:=new_character(f,cur_val);
  end
else back_input
@y
q:=null; f:=cur_font; KANJI(cx):=empty;
if (cur_cmd=letter)or(cur_cmd=other_char) then
  q:=new_character(f,cur_chr)
else if (cur_cmd>=kanji)and(cur_cmd<=hangul) then
  begin  if direction=dir_tate then f:=cur_tfont else f:=cur_jfont;
  cx:=cur_chr;
  end
else if cur_cmd=char_given then
  if check_echar_range(cur_chr) then q:=new_character(f,cur_chr)
  else begin
    if direction=dir_tate then f:=cur_tfont else f:=cur_jfont;
    KANJI(cx):=cur_chr;
    end
else if cur_cmd=char_num then
  begin scan_char_num;
  if check_echar_range(cur_val) then q:=new_character(f,cur_val)
  else  begin
    if direction=dir_tate then f:=cur_tfont else f:=cur_jfont;
    KANJI(cx):=cur_val;
    end
  end
else if cur_cmd=kchar_given then
  begin
    if direction=dir_tate then f:=cur_tfont else f:=cur_jfont;
    KANJI(cx):=cur_chr;
  end
else if cur_cmd=kchar_num then
  begin scan_char_num;
    if direction=dir_tate then f:=cur_tfont else f:=cur_jfont;
    KANJI(cx):=cur_val;
  end
else back_input;
if direction=dir_tate then
  begin if font_dir[f]=dir_tate then disp:=0
  else if font_dir[f]=dir_yoko then disp:=t_baseline_shift-y_baseline_shift
  else disp:=t_baseline_shift
  end
else  begin if font_dir[f]=dir_yoko then disp:=0
  else if font_dir[f]=dir_tate then disp:=y_baseline_shift-t_baseline_shift
  else disp:=y_baseline_shift
  end;
@<Append |disp_node| at begin of displace area@>;
if KANJI(cx)<>empty then
  begin q:=new_character(f,get_jfm_pos(KANJI(cx),f));
  link(q):=get_avail;
  if cat_code(cx)=other_char then
    info(link(q)):=KANJI(cx) + max_char_val
  else
    info(link(q)):=KANJI(cx);
  last_jchr:=q;
  end;
@z

@x
if h<>x then {the accent must be shifted up or down}
  begin p:=hpack(p,natural); shift_amount(p):=x-h;
  end;
@y
if h<>x then {the accent must be shifted up or down}
  begin delete_glue_ref(cur_kanji_skip); delete_glue_ref(cur_xkanji_skip);
  cur_kanji_skip:=zero_glue; cur_xkanji_skip:=zero_glue;
  add_glue_ref(cur_kanji_skip); add_glue_ref(cur_xkanji_skip);
  p:=hpack(p,natural); shift_amount(p):=x-h;
  end;
@z

@x
tail:=new_kern(-a-delta); subtype(tail):=acc_kern; link(p):=tail; p:=q;
@y
tail:=new_kern(-a-delta); subtype(tail):=acc_kern;
if h=x then begin
  if font_dir[font(p)]<>dir_default then link(link(p)):=tail
  else link(p):=tail; end
else link(p):=tail;
{ bugfix: if |p| is KANJI char, |link(p)|:=|tail| collapses |p| and kern after accent. }
p:=q;
@z

@x
if (cur_cmd=math_shift)and(mode>0) then @<Go into display math mode@>
else  begin back_input; @<Go into ordinary math mode@>;
  end;
@y
if (cur_cmd=math_shift)and(mode>0) then @<Go into display math mode@>
else  begin back_input; @<Go into ordinary math mode@>;
  end;
direction:=-abs(direction);
@z

@x
else  begin line_break(true);@/
@y
else if (link(head)=tail)and(not is_char_node(tail)and(type(tail)=disp_node)) then
  begin free_node(tail,small_node_size); tail:=head; link(head):=null;
  @<Prepare for display after an empty paragraph@>
  end
  { |disp_node|-only paragraphs are ignored }
else  begin adjust_hlist(head,true); line_break(true);@/
@z

@x
reswitch: if is_char_node(p) then
  begin f:=font(p); d:=char_width(f)(char_info(f)(character(p)));
  goto found;
  end;
case type(p) of
hlist_node,vlist_node,rule_node: begin d:=width(p); goto found;
  end;
@y
reswitch: if is_char_node(p) then
  begin f:=font(p); d:=char_width(f)(orig_char_info(f)(character(p)));
  if font_dir[f]<>dir_default then p:=link(p);
  goto found;
  end;
case type(p) of
hlist_node,vlist_node,dir_node,rule_node: begin d:=width(p); goto found;
  end;
@z

@x
mmode+left_brace: begin tail_append(new_noad);
  back_input; scan_math(nucleus(tail));
  end;
@y
mmode+left_brace: begin tail_append(new_noad);
  back_input; scan_math(nucleus(tail),kcode_noad(tail));
  end;
@z

@x
@d fam_in_range==((cur_fam>=0)and(cur_fam<16))
@y
@d fam_in_range==((cur_fam>=0)and(cur_fam<script_size))
@z

@x
procedure scan_math(@!p:pointer);
label restart,reswitch,exit;
var c:integer; {math character code}
begin restart:@<Get the next non-blank non-relax...@>;
reswitch:case cur_cmd of
letter,other_char,char_given: begin c:=ho(math_code(cur_chr));
    if c=@'100000 then
      begin @<Treat |cur_chr| as an active character@>;
      goto restart;
      end;
    end;
@y
procedure scan_math(@!p,@!q:pointer);
label restart,reswitch,exit;
var c:integer; {math character code}
cx:KANJI_code; {temporary register for KANJI}
begin KANJI(cx):=0;
restart: @<Get the next non-blank non-relax...@>;
reswitch:case cur_cmd of
letter,other_char,char_given:
  if check_echar_range(cur_chr) then begin
    c:=ho(math_code(cur_chr));
    if c=@"80000 then
      begin @<Treat |cur_chr| as an active character@>;
      goto restart;
      end;
    end
  else
    KANJI(cx):=cur_chr;
kchar_given:
  KANJI(cx):=cur_chr;
kanji,kana,other_kchar,hangul: cx:=cur_chr;
@z

@x
math_char_num: begin scan_fifteen_bit_int; c:=cur_val;
  end;
math_given: c:=cur_chr;
delim_num: begin scan_twenty_seven_bit_int; c:=cur_val div @'10000;
@y
math_char_num: begin
  if cur_chr=0 then scan_fifteen_bit_int
  else scan_big_fifteen_bit_int;
  c:=cur_val;
  end;
math_given: c:=((cur_chr div @"1000) * @"10000) + (cur_chr mod @"1000);
omath_given: c:=((cur_chr div @"10000) * @"100) + (cur_chr mod @"100);
delim_num: begin
  if cur_chr=0 then scan_twenty_seven_bit_int
  else scan_fifty_one_bit_int;
  c:=cur_val;
@z

@x
math_type(p):=math_char; character(p):=qi(c mod 256);
if (c>=var_code)and fam_in_range then fam(p):=cur_fam
else fam(p):=(c div 256) mod 16;
@y
if KANJI(cx)=0 then
  begin math_type(p):=math_char; character(p):=qi(c mod 256);
  if (c>=var_code)and(fam_in_range) then fam(p):=cur_fam
  else fam(p):=(c div 256) mod 256;
  if font_dir[fam_fnt(fam(p)+cur_size)]<>dir_default then
    begin print_err("Not one-byte family");
    help1("IGNORE.");@/
    error;
    end
  end
else  begin
  if q=null then
    begin math_type(p):=sub_mlist; info(p):=new_noad;
    p:=nucleus(info(p)); q:=kcode_noad_nucleus(p);
    end;
  math_type(p):=math_jchar; fam(p):=cur_jfam; character(p):=qi(0);
  math_kcode(p-1):=KANJI(cx) + kcat_code(cx)*max_char_val;
  if font_dir[fam_fnt(fam(p)+cur_size)]=dir_default then
    begin print_err("Not two-byte family");
    help1("IGNORE.");@/
    error;
    end
  end;
@z

@x
mmode+letter,mmode+other_char,mmode+char_given:
  set_math_char(ho(math_code(cur_chr)));
mmode+char_num: begin scan_char_num; cur_chr:=cur_val;
  set_math_char(ho(math_code(cur_chr)));
  end;
@y
mmode+letter,mmode+other_char,mmode+char_given:
  if check_echar_range(cur_chr) then
    set_math_char(ho(math_code(cur_chr)))
  else set_math_kchar(cur_chr);
mmode+kanji,mmode+kana,mmode+other_kchar,mmode+hangul: begin
    cx:=cur_chr; set_math_kchar(KANJI(cx));
  end;
mmode+char_num: begin scan_char_num; cur_chr:=cur_val;
  if check_echar_range(cur_chr) then
    set_math_char(ho(math_code(cur_chr)))
  else set_math_kchar(cur_chr);
  end;
mmode+kchar_given:
  set_math_kchar(cur_chr);
mmode+kchar_num: begin scan_char_num; cur_chr:=cur_val;
  set_math_kchar(cur_chr);
  end;
@z

@x
mmode+math_char_num: begin scan_fifteen_bit_int; set_math_char(cur_val);
  end;
mmode+math_given: set_math_char(cur_chr);
mmode+delim_num: begin scan_twenty_seven_bit_int;
  set_math_char(cur_val div @'10000);
@y
mmode+math_char_num: begin
  if cur_chr=0 then scan_fifteen_bit_int
  else scan_big_fifteen_bit_int;
  set_math_char(cur_val);
  end;
mmode+math_given: begin
  set_math_char(((cur_chr div @"1000) * @"10000)+(cur_chr mod @"1000));
  end;
mmode+omath_given: begin
  set_math_char(((cur_chr div @"10000) * @"100)+(cur_chr mod @"100));
  end;
mmode+delim_num: begin
  if cur_chr=0 then scan_twenty_seven_bit_int
  else scan_fifty_one_bit_int;
  set_math_char(cur_val); {character code of left delimiter}
@z

@x
procedure set_math_char(@!c:integer);
var p:pointer; {the new noad}
begin if c>=@'100000 then
  @<Treat |cur_chr|...@>
else  begin p:=new_noad; math_type(nucleus(p)):=math_char;
  character(nucleus(p)):=qi(c mod 256);
  fam(nucleus(p)):=(c div 256) mod 16;
  if c>=var_code then
    begin if fam_in_range then fam(nucleus(p)):=cur_fam;
    type(p):=ord_noad;
    end
  else  type(p):=ord_noad+(c div @'10000);
  link(tail):=p; tail:=p;
@y
procedure set_math_char(@!c:integer);
var p:pointer; {the new noad}
begin if c>=@"80000 then
  @<Treat |cur_chr|...@>
else  begin p:=new_noad; math_type(nucleus(p)):=math_char;
  character(nucleus(p)):=qi(c mod 256);
  fam(nucleus(p)):=(c div 256) mod 256;
  if c>=var_code then
    begin if fam_in_range then fam(nucleus(p)):=cur_fam;
    type(p):=ord_noad;
   end
  else  type(p):=ord_noad+(c div @"10000);
  link(tail):=p; tail:=p;
  if font_dir[fam_fnt(fam(nucleus(p))+cur_size)]<>dir_default then begin
    print_err("Not one-byte family");
    help1("IGNORE.");@/
    error;
  end;
@z

@x
  type(tail):=cur_chr; scan_math(nucleus(tail));
@y
  type(tail):=cur_chr; scan_math(nucleus(tail),kcode_noad(tail));
@z

@x
@<Declare act...@>=
procedure scan_delimiter(@!p:pointer;@!r:boolean);
begin if r then scan_twenty_seven_bit_int
else  begin @<Get the next non-blank non-relax...@>;
  case cur_cmd of
  letter,other_char: cur_val:=del_code(cur_chr);
  delim_num: scan_twenty_seven_bit_int;
  othercases cur_val:=-1
  endcases;
  end;
if cur_val<0 then @<Report that an invalid delimiter code is being changed
   to null; set~|cur_val:=0|@>;
small_fam(p):=(cur_val div @'4000000) mod 16;
small_char(p):=qi((cur_val div @'10000) mod 256);
large_fam(p):=(cur_val div 256) mod 16;
large_char(p):=qi(cur_val mod 256);
end;
@y
@<Declare act...@>=
procedure scan_delimiter(@!p:pointer;@!r:boolean);
begin if r=1 then scan_twenty_seven_bit_int
else if r=2 then scan_fifty_one_bit_int
else  begin @<Get the next non-blank non-relax...@>;
  case cur_cmd of
  letter,other_char: begin
    cur_val:=del_code(cur_chr); cur_val1:=del_code1(cur_chr);
    end;
  delim_num: if cur_chr=0 then scan_twenty_seven_bit_int
             else scan_fifty_one_bit_int;
  othercases begin cur_val:=-1; cur_val1:=-1; end;
  endcases;
  end;
if cur_val<0 then begin @<Report that an invalid delimiter code is being changed
   to null; set~|cur_val:=0|@>;
 cur_val1:=0;
 end;
small_fam(p):=(cur_val div @"100) mod @"100;
small_char(p):=qi(cur_val mod @"100);
large_fam(p):=(cur_val1 div @"100) mod @"100;
large_char(p):=qi(cur_val1 mod @"100);
end;
@z

@x
scan_delimiter(left_delimiter(tail),true); scan_math(nucleus(tail));
@y
scan_delimiter(left_delimiter(tail),cur_chr+1);
scan_math(nucleus(tail),kcode_noad(tail));
@z

@x
scan_fifteen_bit_int;
character(accent_chr(tail)):=qi(cur_val mod 256);
if (cur_val>=var_code)and fam_in_range then fam(accent_chr(tail)):=cur_fam
else fam(accent_chr(tail)):=(cur_val div 256) mod 16;
@y
if cur_chr=0 then scan_fifteen_bit_int
else scan_big_fifteen_bit_int;
character(accent_chr(tail)):=qi(cur_val mod 256);
if (cur_val>=var_code)and fam_in_range then fam(accent_chr(tail)):=cur_fam
else fam(accent_chr(tail)):=(cur_val div 256) mod 256;
@z

@x
scan_math(nucleus(tail));
@y
scan_math(nucleus(tail),kcode_noad(tail));
@z

@x
  p:=vpack(link(head),saved(1),saved(0)); pop_nest;
  tail_append(new_noad); type(tail):=vcenter_noad;
  math_type(nucleus(tail)):=sub_box; info(nucleus(tail)):=p;
  end;
@y
  p:=vpack(link(head),saved(1),saved(0));
  set_box_dir(p)(direction); pop_nest;
  if abs(box_dir(p))<>abs(direction) then p:=new_dir_node(p,abs(direction));
  tail_append(new_noad); type(tail):=vcenter_noad;
  math_type(nucleus(tail)):=sub_box; info(nucleus(tail)):=p;
  end;
@z

@x
scan_math(p);
@y
scan_math(p,null);
@z

@x
     if math_type(supscr(p))=empty then
      begin mem[saved(0)].hh:=mem[nucleus(p)].hh;
@y
     if ((math_type(supscr(p))=empty)and(math_kcode(p)=null)) then
      begin mem[saved(0)].hh:=mem[nucleus(p)].hh;
@z

@x
var l:boolean; {`\.{\\leqno}' instead of `\.{\\eqno}'}
@y
var l:boolean; {`\.{\\leqno}' instead of `\.{\\eqno}'}
@!disp:scaled; {displacement}
@z

@x
m:=mode; l:=false; p:=fin_mlist(null); {this pops the nest}
@y
delete_glue_ref(cur_kanji_skip); delete_glue_ref(cur_xkanji_skip);
if auto_spacing>0 then cur_kanji_skip:=kanji_skip
else cur_kanji_skip:=zero_glue;
if auto_xspacing>0 then cur_xkanji_skip:=xkanji_skip
else cur_xkanji_skip:=zero_glue;
add_glue_ref(cur_kanji_skip); add_glue_ref(cur_xkanji_skip);
m:=mode; l:=false; p:=fin_mlist(null); {this pops the nest}
@z

@x
begin tail_append(new_math(math_surround,before));
cur_mlist:=p; cur_style:=text_style; mlist_penalties:=(mode>0); mlist_to_hlist;
link(tail):=link(temp_head);
while link(tail)<>null do tail:=link(tail);
tail_append(new_math(math_surround,after));
space_factor:=1000; unsave;
end
@y
begin if direction=dir_tate then disp:=t_baseline_shift
      else disp:=y_baseline_shift;
@<Append |disp_node| at begin of displace area@>;
tail_append(new_math(math_surround,before));
cur_mlist:=p; cur_style:=text_style; mlist_penalties:=(mode>0); mlist_to_hlist;
link(tail):=link(temp_head);
while link(tail)<>null do tail:=link(tail);
tail_append(new_math(math_surround,after));
@<Append |disp_node| at end of displace area@>;
space_factor:=1000; inhibit_glue_flag:=false; unsave;
end
@z

@x
@<Check that another \.\$ follows@>=
begin get_x_token;
@y
@<Check that another \.\$ follows@>=
begin repeat get_x_token;
until (suppress_mathpar_error=0)or(cur_cmd<>par_end);
@z

@x
@!t:pointer; {tail of adjustment list}
@y
@!t:pointer; {tail of adjustment list}
@!pre_t:pointer; {tail of pre-adjustment list}
@z

@x
adjust_tail:=adjust_head; b:=hpack(p,natural); p:=list_ptr(b);
t:=adjust_tail; adjust_tail:=null;@/
@y
adjust_tail:=adjust_head; pre_adjust_tail:=pre_adjust_head;
b:=hpack(p,natural); p:=list_ptr(b);
t:=adjust_tail; adjust_tail:=null;@/
pre_t:=pre_adjust_tail; pre_adjust_tail:=null;@/
@z

@x
push_nest; mode:=hmode; space_factor:=1000; set_cur_lang; clang:=cur_lang;
@y
push_nest; adjust_dir:=direction; inhibit_glue_flag:=false;
mode:=hmode; space_factor:=1000; set_cur_lang; clang:=cur_lang;
@z

@x
begin if (e<>0)and((w-total_shrink[normal]+q<=z)or@|
   (total_shrink[fil]<>0)or(total_shrink[fill]<>0)or
   (total_shrink[filll]<>0)) then
@y
begin if (e<>0)and((w-total_shrink[normal]+q<=z)or@|
   (total_shrink[sfi]<>0)or(total_shrink[fil]<>0)or
   (total_shrink[fill]<>0)or(total_shrink[filll]<>0)) then
@z

@x
  begin free_node(b,box_node_size);
@y
  begin delete_glue_ref(space_ptr(b)); delete_glue_ref(xspace_ptr(b));
  free_node(b,box_node_size);
@z

@x
    begin free_node(b,box_node_size);
@y
    begin delete_glue_ref(space_ptr(b)); delete_glue_ref(xspace_ptr(b));
    free_node(b,box_node_size);
@z

@x
if t<>adjust_head then {migrating material comes after equation number}
  begin link(tail):=link(adjust_head); tail:=t;
  end;
@y
if t<>adjust_head then {migrating material comes after equation number}
  begin link(tail):=link(adjust_head); tail:=t;
  end;
if pre_t<>pre_adjust_head then
  begin link(tail):=link(pre_adjust_head); tail:=pre_t;
  end;
@z

@x
any_mode(toks_register),
any_mode(assign_toks),
any_mode(assign_int),
@y
any_mode(assign_kinsoku),
any_mode(assign_inhibit_xsp_code),
any_mode(set_auto_spacing),
any_mode(set_enable_cjk_token),
any_mode(set_kansuji_char),
any_mode(toks_register),
any_mode(assign_toks),
any_mode(assign_int),
any_mode(def_jfont),
any_mode(def_tfont),
@z

@x
@t\4@>@<Declare subprocedures for |prefixed_command|@>@t@>@;@/
procedure prefixed_command;
label done,exit;
var a:small_number; {accumulated prefix codes so far}
@y
@t\4@>@<Declare the function called |scan_keyword_noexpand|@>
@<Declare subprocedures for |prefixed_command|@>@t@>@;@/
procedure prefixed_command;
label done,exit;
var a:small_number; {accumulated prefix codes so far}
@!m:integer; {ditto}
@z

@x
@d word_define(#)==if global then geq_word_define(#)@+else eq_word_define(#)
@y
@d word_define(#)==if global then geq_word_define(#)@+else eq_word_define(#)
@d del_word_define(#)==if global
                       then del_geq_word_define(#)@+else del_eq_word_define(#)
@z

@x
set_font: define(cur_font_loc,data,cur_chr);
@y
set_font: begin
  if font_dir[cur_chr]=dir_yoko then
    define(cur_jfont_loc,data,cur_chr)
  else if font_dir[cur_chr]=dir_tate then
    define(cur_tfont_loc,data,cur_chr)
  else
    define(cur_font_loc,data,cur_chr)
end;
@z

@x
primitive("futurelet",let,normal+1);@/
@!@:future_let_}{\.{\\futurelet} primitive@>

@ @<Cases of |print_cmd_chr|...@>=
let: if chr_code<>normal then print_esc("futurelet")@+else print_esc("let");

@ @<Assignments@>=
let:  begin n:=cur_chr;
@y
primitive("futurelet",let,normal+1);@/
@!@:future_let_}{\.{\\futurelet} primitive@>

@ @<Cases of |print_cmd_chr|...@>=
let: if chr_code<>normal then print_esc("futurelet")@+else print_esc("let");

@ @<Assignments@>=
let:  begin n:=cur_chr;
@z

@x
@d count_def_code=2 {|shorthand_def| for \.{\\countdef}}
@d dimen_def_code=3 {|shorthand_def| for \.{\\dimendef}}
@d skip_def_code=4 {|shorthand_def| for \.{\\skipdef}}
@d mu_skip_def_code=5 {|shorthand_def| for \.{\\muskipdef}}
@d toks_def_code=6 {|shorthand_def| for \.{\\toksdef}}
@d char_sub_def_code=7 {|shorthand_def| for \.{\\charsubdef}}

@<Put each...@>=
primitive("chardef",shorthand_def,char_def_code);@/
@!@:char_def_}{\.{\\chardef} primitive@>
@y
@d omath_char_def_code=2 {|shorthand_def| for \.{\\omathchardef}}
@d count_def_code=3 {|shorthand_def| for \.{\\countdef}}
@d dimen_def_code=4 {|shorthand_def| for \.{\\dimendef}}
@d skip_def_code=5 {|shorthand_def| for \.{\\skipdef}}
@d mu_skip_def_code=6 {|shorthand_def| for \.{\\muskipdef}}
@d toks_def_code=7 {|shorthand_def| for \.{\\toksdef}}
@d char_sub_def_code=8 {|shorthand_def| for \.{\\charsubdef}}
@d kchar_def_code=char_sub_def_code+1 {|shorthand_def| for \.{\\kchardef}}

@<Put each...@>=
primitive("chardef",shorthand_def,char_def_code);@/
@!@:char_def_}{\.{\\chardef} primitive@>
primitive("kchardef",shorthand_def,kchar_def_code);@/
@!@:kchar_def_}{\.{\\kchardef} primitive@>
@z

@x
primitive("mathchardef",shorthand_def,math_char_def_code);@/
@!@:math_char_def_}{\.{\\mathchardef} primitive@>
@y
primitive("mathchardef",shorthand_def,math_char_def_code);@/
@!@:math_char_def_}{\.{\\mathchardef} primitive@>
primitive("omathchardef",shorthand_def,omath_char_def_code);@/
@!@:math_char_def_}{\.{\\omathchardef} primitive@>
@z

@x
shorthand_def: case chr_code of
  char_def_code: print_esc("chardef");
  math_char_def_code: print_esc("mathchardef");
@y
shorthand_def: case chr_code of
  char_def_code: print_esc("chardef");
  kchar_def_code: print_esc("kchardef");
  math_char_def_code: print_esc("mathchardef");
  omath_char_def_code: print_esc("omathchardef");
@z

@x
char_given: begin print_esc("char"); print_hex(chr_code);
  end;
@y
char_given: begin print_esc("char"); print_hex(chr_code);
  end;
kchar_given: begin print_esc("kchar"); print_hex(chr_code);
  end;
@z

@x
math_given: begin print_esc("mathchar"); print_hex(chr_code);
  end;
@y
math_given: begin print_esc("mathchar"); print_hex(chr_code);
  end;
omath_given: begin print_esc("omathchar"); print_hex(chr_code);
  end;
@z

@x
  char_def_code: begin scan_char_num; define(p,char_given,cur_val);
    end;
@y
  char_def_code: begin scan_char_num; define(p,char_given,cur_val);
    end;
  kchar_def_code: begin scan_char_num; define(p,kchar_given,cur_val);
    end;
@z

@x
  math_char_def_code: begin scan_fifteen_bit_int; define(p,math_given,cur_val);
@y
  math_char_def_code: begin scan_real_fifteen_bit_int;
    define(p,math_given,cur_val);
    end;
  omath_char_def_code: begin scan_omega_fifteen_bit_int;
    define(p,omath_given,cur_val);
@z

@x
      else cur_chr:=toks_base+cur_val;
      end
    else e:=true;
  p:=cur_chr; {|p=every_par_loc| or |output_routine_loc| or \dots}
@y
      else cur_chr:=toks_base+cur_val;
      end
    else e:=true
  else if cur_chr=node_recipe_loc then begin
    scan_char_num;
    find_sa_element(node_recipe_val, cur_val, true);
    cur_chr:=cur_ptr; e:=true;
  end;
  p:=cur_chr; {|p=every_par_loc| or |output_routine_loc| or \dots}
@z

@x
  else q:=equiv(cur_chr);
  if q=null then sa_define(p,null)(p,undefined_cs,null)
@y
  else if cur_chr=node_recipe_loc then begin
    scan_char_num;
    find_sa_element(node_recipe_val, cur_val, false);
    if cur_ptr=null then q:=null
    else q:=sa_ptr(cur_ptr);
  end else q:=equiv(cur_chr);
  if q=null then sa_define(p,null)(p,undefined_cs,null)
@z

@x
assign_int: begin p:=cur_chr; scan_optional_equals; scan_int;
  word_define(p,cur_val);
  end;
@y
assign_int: begin p:=cur_chr; scan_optional_equals; scan_int;
  if p=int_base+cur_fam_code then
    begin if font_dir[fam_fnt(cur_val)]<>dir_default then
      word_define(int_base+cur_jfam_code,cur_val)
    else word_define(p,cur_val);
    end
  else word_define(p,cur_val);
  end;
@z

@x
@<Put each...@>=
primitive("catcode",def_code,cat_code_base);
@!@:cat_code_}{\.{\\catcode} primitive@>
@y
@<Put each...@>=
primitive("catcode",def_code,cat_code_base);
@!@:cat_code_}{\.{\\catcode} primitive@>
primitive("cjkxcode",def_code,cjkx_code_base);
@!@:cjkx_code_}{\.{\\cjkxcode} primitive@>
primitive("xspcode",def_code,auto_xsp_code_base);
@!@:auto_xsp_code_}{\.{\\xspcode} primitive@>
@z

@x
primitive("mathcode",def_code,math_code_base);
@!@:math_code_}{\.{\\mathcode} primitive@>
@y
primitive("mathcode",def_code,math_code_base);
@!@:math_code_}{\.{\\mathcode} primitive@>
primitive("omathcode",def_code,math_code_base+128);
@!@:math_code_}{\.{\\omathcode} primitive@>
@z

@x
primitive("delcode",def_code,del_code_base);
@!@:del_code_}{\.{\\delcode} primitive@>
@y
primitive("delcode",def_code,del_code_base);
@!@:del_code_}{\.{\\delcode} primitive@>
primitive("odelcode",def_code,del_code_base+128);
@!@:del_code_}{\.{\\odelcode} primitive@>
@z

@x
def_code: if chr_code=cat_code_base then print_esc("catcode")
  else if chr_code=math_code_base then print_esc("mathcode")
@y
def_code: if chr_code=cat_code_base then print_esc("catcode")
  else if chr_code=cjkx_code_base then print_esc("cjkxcode")
  else if chr_code=auto_xsp_code_base then print_esc("xspcode")
  else if chr_code=math_code_base then print_esc("mathcode")
@z

@x
  else if chr_code=lc_code_base then print_esc("lccode")
  else if chr_code=uc_code_base then print_esc("uccode")
  else if chr_code=sf_code_base then print_esc("sfcode")
  else print_esc("delcode");
@y
  else if chr_code=math_code_base+128 then print_esc("omathcode")
  else if chr_code=lc_code_base then print_esc("lccode")
  else if chr_code=uc_code_base then print_esc("uccode")
  else if chr_code=sf_code_base then print_esc("sfcode")
  else if chr_code=del_code_base then print_esc("delcode")
  else print_esc("odelcode");
@z

@x
@<Assignments@>=
def_code: begin @<Let |n| be the largest legal code value, based on |cur_chr|@>;
  p:=cur_chr; scan_char_num; p:=p+cur_val; scan_optional_equals;
  scan_int;
  if ((cur_val<0)and(p<del_code_base))or(cur_val>n) then
    begin print_err("Invalid code ("); print_int(cur_val);
@.Invalid code@>
    if p<del_code_base then print("), should be in the range 0..")
    else print("), should be at most ");
    print_int(n);
    help1("I'm going to use 0 instead of that illegal code value.");@/
    error; cur_val:=0;
    end;
  if p<math_code_base then define(p,data,cur_val)
  else if p<del_code_base then define(p,data,hi(cur_val))
  else word_define(p,cur_val);
  end;
@y
@<Assignments@>=
def_code: begin
  if cur_chr=(del_code_base+128) then begin
    p:=cur_chr-128; scan_ascii_num; p:=p+cur_val; scan_optional_equals;
    scan_int; cur_val1:=cur_val; scan_int; {backwards}
    if (cur_val1>@"FFFFFF) or (cur_val>@"FFFFFF) then
      begin print_err("Invalid code ("); print_int(cur_val1); print(" ");
      print_int(cur_val);
      print("), should be at most ""FFFFFF ""FFFFFF");
      help1("I'm going to use 0 instead of that illegal code value.");@/
      error; cur_val1:=0; cur_val:=0;
      end;
    cur_val1:=(cur_val1 div @"10000)*@"100+(cur_val1 mod @"100);
    cur_val:=(cur_val div @"10000)*@"100+(cur_val mod @"100);
    del_word_define(p,cur_val1,cur_val);
    end
  else begin
    @<Let |m| be the minimal legal code value, based on |cur_chr|@>;
    @<Let |n| be the largest legal code value, based on |cur_chr|@>;
    p:=cur_chr; cur_val1:=p;
    if p=cjkx_code_base then begin scan_char_num; p:=p+cur_val end
    else begin scan_char_num; p:=p+cur_val; end;
    scan_optional_equals; scan_int;
    if ((cur_val<m)and(p<del_code_base))or(cur_val>n) then
    begin print_err("Invalid code ("); print_int(cur_val);
@.Invalid code@>
      if p<del_code_base then
        begin print("), should be in the range "); print_int(m); print("..");
        end
      else print("), should be at most ");
      print_int(n);
      if m=0 then
        begin help1("I'm going to use 0 instead of that illegal code value.");@/
        error; cur_val:=0;
        end
      else
        begin help1("I'm going to use 16 instead of that illegal code value.");@/
        error; cur_val:=16;
        end;
    end;
    if p<math_code_base then define(p,data,cur_val)
    else if cur_val1=math_code_base then begin
      if cur_val=@"8000 then cur_val:=@"80000
      else cur_val:=((cur_val div @"1000)*@"10000)+(cur_val mod @"1000);
      define(p,data,hi(cur_val));
      end
    else if cur_val1=math_code_base+128 then begin
      cur_val:=((cur_val div @"10000) * @"100) + (cur_val mod @"100);
      define(p-128,data,hi(cur_val));
      end
    else if cur_val1=del_code_base then begin
      if cur_val>=0 then begin
        cur_val1:=cur_val div @"1000;
        cur_val1:=(cur_val1 div @"1000)*@"10000 + cur_val1 mod @"1000;
        cur_val:=cur_val mod @"1000;
        del_word_define(p,cur_val1,cur_val); end
      else
        del_word_define(p, -1, cur_val);
      end
    else define(p,data,cur_val);
    end;
  end;
@z

@x
@ @<Let |n| be the largest...@>=
if cur_chr=cat_code_base then n:=max_char_code
@y
@ @<Let |m| be the minimal...@>=
m:=0

@ @<Let |n| be the largest...@>=
if cur_chr=cat_code_base then n:=invalid_char {1byte |max_char_code|}
@z

@x
else if cur_chr=math_code_base then n:=@'100000
@y
else if cur_chr=cjkx_code_base then n:=3
else if cur_chr=math_code_base then n:=@"8000
else if cur_chr=(math_code_base+128) then n:=@"8000000
@z

@x
def_family: begin p:=cur_chr; scan_four_bit_int; p:=p+cur_val;
@y
def_family: begin p:=cur_chr; scan_big_four_bit_int; p:=p+cur_val;
@z

@x
procedure alter_box_dimen;
var c:small_number; {|width_offset| or |height_offset| or |depth_offset|}
@y
procedure alter_box_dimen;
var c:small_number; {|width_offset| or |height_offset| or |depth_offset|}
@!p,q:pointer; {temporary registers}
@z

@x
scan_normal_dimen;
if b<>null then mem[b+c].sc:=cur_val;
end;
@y
scan_normal_dimen;
if b<>null then
  begin q:=b; p:=link(q);
  while p<>null do
    begin if abs(direction)=abs(box_dir(p)) then q:=p;
    p:=link(p);
    end;
  if abs(box_dir(q))<>abs(direction) then
    begin p:=link(b); link(b):=null;
    q:=new_dir_node(q,abs(direction)); list_ptr(q):=null;
    link(q):=p; link(b):=q;
    end;
    mem[q+c].sc:=cur_val;
  end;
end;
@z

@x
def_font: new_font(a);
@y
def_tfont,def_jfont,def_font: new_font(a);
@z

@x
get_r_token; u:=cur_cs;
@y
@<Scan the font encoding specification@>;
get_r_token; u:=cur_cs;
@z

@x
else  begin old_setting:=selector; selector:=new_string;
  print("FONT"); print(u-active_base); selector:=old_setting;
@.FONTx@>
  str_room(1); t:=make_string;
  end;
@y
else  begin old_setting:=selector; selector:=new_string;
  print("FONT");
  if u-active_base<@"80 then print(u-active_base) else print_utf8(u-active_base);
  selector:=old_setting;
@.FONTx@>
  str_room(1); t:=make_string;
  end;
@z

@x
@<Change the case of the token in |p|, if a change is appropriate@>=
t:=info(p);
if t<cs_token_flag+single_base then
  begin c:=t mod 256;
  if equiv(b+c)<>0 then info(p):=t-c+equiv(b+c);
  end
@y
@<Change the case of the token in |p|, if a change is appropriate@>=
t:=info(p);
if (t<cs_token_flag+single_base)and(not check_kanji(t)) then
  begin c:=t mod max_char_val;
  if equiv(b+c)<>0 then info(p):=t-c+equiv(b+c);
  end
@z

@x
@d show_lists_code=3 { \.{\\showlists} }
@y
@d show_lists_code=3 { \.{\\showlists} }
@d show_mode=7 { \.{\\showmode} }
@z

@x
primitive("showlists",xray,show_lists_code);
@!@:show_lists_code_}{\.{\\showlists} primitive@>
@y
primitive("showlists",xray,show_lists_code);
@!@:show_lists_code_}{\.{\\showlists} primitive@>
primitive("showmode",xray,show_mode);
@!@:show_mode_}{\.{\\showmode} primitive@>
@z

@x
  othercases print_esc("show")
@y
  show_mode:print_esc("showmode");
  othercases print_esc("show")
@z

@x
show_code: @<Show the current meaning of a token, then |goto common_ending|@>;
@y
show_code: @<Show the current meaning of a token, then |goto common_ending|@>;
show_mode: @<Show the current japanese processing mode@>;
@z

@x
@!format_engine: ^text_char;
@y
@!w: four_quarters; {four ASCII codes}
@!format_engine: ^text_char;
@z

@x
@!format_engine: ^text_char;
@!dummy_xord: ASCII_code;
@!dummy_xchr: text_char;
@y
@!w: four_quarters; {four ASCII codes}
@!format_engine: ^text_char;
@!dummy_xord: ASCII_code;
@!dummy_xchr: ext_ASCII_code;
@z

@x
libc_free(format_engine);@/
@y
libc_free(format_engine);@/
dump_kanji(fmt_file);
@z

@x
libc_free(format_engine);
@y
libc_free(format_engine);
undump_kanji(fmt_file);
@z

@x
dump_things(str_pool[0], pool_ptr);
@y
for k:=0 to str_ptr do dump_int(str_start[k]);
k:=0;
while k+4<pool_ptr do
  begin dump_four_ASCII; k:=k+4;
  end;
k:=pool_ptr-4; dump_four_ASCII;
@z

@x
undump_things(str_pool[0], pool_ptr);
@y
for k:=0 to str_ptr do undump(0)(pool_ptr)(str_start[k]);
k:=0;
while k+4<pool_ptr do
  begin undump_four_ASCII; k:=k+4;
  end;
k:=pool_ptr-4; undump_four_ASCII;
@z

@x
if eTeX_ex then for k:=int_val to tok_val do dump_int(sa_root[k]);
@y
if eTeX_ex then for k:=int_val to node_recipe_val do dump_int(sa_root[k]);
@z

@x
if eTeX_ex then for k:=int_val to tok_val do
  undump(null)(lo_mem_max)(sa_root[k]);
@y
if eTeX_ex then for k:=int_val to node_recipe_val do
  undump(null)(lo_mem_max)(sa_root[k]);
@z

@x
@ @<Dump regions 5 and 6 of |eqtb|@>=
repeat j:=k;
while j<eqtb_size do
  begin if eqtb[j].int=eqtb[j+1].int then goto found2;
  incr(j);
  end;
l:=eqtb_size+1; goto done2; {|j=eqtb_size|}
found2: incr(j); l:=j;
while j<eqtb_size do
  begin if eqtb[j].int<>eqtb[j+1].int then goto done2;
@y
@ @<Dump regions 5 and 6 of |eqtb|@>=
repeat j:=k;
while j<eqtb_size do
  begin if (eqtb[j].int=eqtb[j+1].int) and@|
    (getintone(eqtb[j])=getintone(eqtb[j+1])) then goto found2;
  incr(j);
  end;
l:=eqtb_size+1; goto done2; {|j=eqtb_size|}
found2: incr(j); l:=j;
while j<eqtb_size do
  begin if (eqtb[j].int<>eqtb[j+1].int)or@|
          (getintone(eqtb[j])<>getintone(eqtb[j+1])) then goto done2;
@z

@x
@<Dump the hash table@>=
@y
@<Dump the hash table@>=
for p:=0 to prim_size do dump_hh(prim[p]);
@z

@x
@ @<Undump the hash table@>=
@y
@ @<Undump the hash table@>=
for p:=0 to prim_size do undump_hh(prim[p]);
@z

@x
font_info:=xmalloc_array(fmemory_word, font_mem_size);
@y
font_info:=xmalloc_array(memory_word, font_mem_size);
@z

@x
@ @<Dump the array info for internal font number |k|@>=
begin
dump_things(font_check[null_font], font_ptr+1-null_font);
@y
@ @<Dump the array info for internal font number |k|@>=
begin
dump_things(font_dir[null_font], font_ptr+1-null_font);
dump_things(font_enc[null_font], font_ptr+1-null_font);
dump_things(font_num_ext[null_font], font_ptr+1-null_font);
dump_things(font_check[null_font], font_ptr+1-null_font);
@z

@x
dump_things(char_base[null_font], font_ptr+1-null_font);
@y
dump_things(ctype_base[null_font], font_ptr+1-null_font);
dump_things(char_base[null_font], font_ptr+1-null_font);
@z

@x
@<Undump the array info for internal font number |k|@>=
begin {Allocate the font arrays}
@y
@<Undump the array info for internal font number |k|@>=
begin {Allocate the font arrays}
font_dir:=xmalloc_array(eight_bits, font_max);
font_enc:=xmalloc_array(eight_bits, font_max);
font_num_ext:=xmalloc_array(integer, font_max);
@z

@x
char_base:=xmalloc_array(integer, font_max);
@y
ctype_base:=xmalloc_array(integer, font_max);
char_base:=xmalloc_array(integer, font_max);
@z

@x
undump_things(font_check[null_font], font_ptr+1-null_font);
@y
undump_things(font_dir[null_font], font_ptr+1-null_font);
undump_things(font_enc[null_font], font_ptr+1-null_font);
undump_things(font_num_ext[null_font], font_ptr+1-null_font);
undump_things(font_check[null_font], font_ptr+1-null_font);
@z

@x
undump_things(char_base[null_font], font_ptr+1-null_font);
@y
undump_things(ctype_base[null_font], font_ptr+1-null_font);
undump_things(char_base[null_font], font_ptr+1-null_font);
@z

@x
  buffer:=xmalloc_array (ASCII_code, buf_size);
@y
  buffer:=xmalloc_array (ASCII_code, buf_size);
  buffer2:=xmalloc_array (ASCII_code, buf_size);
@z

@x
  font_info:=xmalloc_array (fmemory_word, font_mem_size);
@y
  font_info:=xmalloc_array (memory_word, font_mem_size);
@z

@x
fix_date_and_time;@/
@y
last:=ptenc_conv_first_line(loc, last, buffer, buf_size); limit:=last;
fix_date_and_time;@/
random_seed:=(microseconds*1000)+(epochseconds mod 1000000);@/
init_randoms(random_seed);@/
@z

@x
  font_check:=xmalloc_array(four_quarters, font_max);
@y
  font_dir:=xmalloc_array(eight_bits, font_max);
  font_enc:=xmalloc_array(eight_bits, font_max);
  font_num_ext:=xmalloc_array(integer, font_max);
  font_check:=xmalloc_array(four_quarters, font_max);
@z

@x
  char_base:=xmalloc_array(integer, font_max);
@y
  ctype_base:=xmalloc_array(integer, font_max);
  char_base:=xmalloc_array(integer, font_max);
@z

@x
  font_ptr:=null_font; fmem_ptr:=7;
@y
  font_ptr:=null_font; fmem_ptr:=7;
  font_dir[null_font]:=dir_default;
  font_enc[null_font]:=0;
  font_num_ext[null_font]:=0;
@z

@x
  char_base[null_font]:=0; width_base[null_font]:=0;
@y
  ctype_base[null_font]:=0; char_base[null_font]:=0; width_base[null_font]:=0;
@z

@x
@d language_node=4 {|subtype| in whatsits that change the current language}
@y
@d latespecial_node=4 {|subtype| in whatsits that represent \.{\\special} things}
@d language_node=5 {|subtype| in whatsits that change the current language}
@z

@x
@d immediate_code=4 {command modifier for \.{\\immediate}}
@d set_language_code=5 {command modifier for \.{\\setlanguage}}
@y
@d immediate_code=5 {command modifier for \.{\\immediate}}
@d set_language_code=6 {command modifier for \.{\\setlanguage}}
@d epTeX_input_encoding_code=7 {command modifier for \.{\\epTeXinputencoding}}
@d pdf_save_pos_node=epTeX_input_encoding_code+1
@d set_random_seed_code=pdf_save_pos_node+1
@d reset_timer_code=set_random_seed_code+1
@z

@x
primitive("setlanguage",extension,set_language_code);@/
@!@:set_language_}{\.{\\setlanguage} primitive@>
@y
primitive("setlanguage",extension,set_language_code);@/
@!@:set_language_}{\.{\\setlanguage} primitive@>
primitive("epTeXinputencoding",extension,epTeX_input_encoding_code);@/
@!@:epTeX_input_encoding_}{\.{\\epTeXinputencoding} primitive@>
@z

@x
  set_language_code:print_esc("setlanguage");
@y
  set_language_code:print_esc("setlanguage");
  pdf_save_pos_node: print_esc("pdfsavepos");
  set_random_seed_code: print_esc("pdfsetrandomseed");
  reset_timer_code: print_esc("pdfresettimer");
  epTeX_input_encoding_code:print_esc("epTeXinputencoding");
@z

@x
set_language_code:@<Implement \.{\\setlanguage}@>;
@y
set_language_code:@<Implement \.{\\setlanguage}@>;
pdf_save_pos_node: @<Implement \.{\\pdfsavepos}@>;
set_random_seed_code: @<Implement \.{\\pdfsetrandomseed}@>;
reset_timer_code: @<Implement \.{\\pdfresettimer}@>;
epTeX_input_encoding_code:@<Implement \.{\\epTeXinputencoding}@>;
@z

@x
write_stream(tail):=cur_val;
end;
@y
write_stream(tail):=cur_val;
inhibit_glue_flag:=false;
end;
@z

@x
@<Implement \.{\\special}@>=
begin new_whatsit(special_node,write_node_size); write_stream(tail):=null;
p:=scan_toks(false,true); write_tokens(tail):=def_ref;
end
@y
@<Implement \.{\\special}@>=
begin if scan_keyword("shipout") then
begin new_whatsit(latespecial_node,write_node_size); write_stream(tail):=null;
p:=scan_toks(false,false); write_tokens(tail):=def_ref;
end else
begin new_whatsit(special_node,write_node_size); write_stream(tail):=null;
p:=scan_toks(false,true); write_tokens(tail):=def_ref;
end;
inhibit_glue_flag:=false;
end
@z

@x
special_node:begin print_esc("special");
  print_mark(write_tokens(p));
  end;
@y
special_node:begin print_esc("special");
  print_mark(write_tokens(p));
  end;
latespecial_node:begin print_esc("special"); print(" shipout");
  print_mark(write_tokens(p));
  end;
@z

@x
  print_int(what_lhm(p)); print_char(",");
  print_int(what_rhm(p)); print_char(")");
  end;
@y
  print_int(what_lhm(p)); print_char(",");
  print_int(what_rhm(p)); print_char(")");
  end;
pdf_save_pos_node: print_esc("pdfsavepos");
set_random_seed_code: print_esc("pdfsetrandomseed");
reset_timer_code: print_esc("pdfresettimer");
@z

@x
write_node,special_node: begin r:=get_node(write_node_size);
@y
write_node,special_node,latespecial_node: begin r:=get_node(write_node_size);
@z

@x
close_node,language_node: begin r:=get_node(small_node_size);
  words:=small_node_size;
  end;
@y
close_node,language_node: begin r:=get_node(small_node_size);
  words:=small_node_size;
  end;
pdf_save_pos_node:
   r := get_node(small_node_size);
@z

@x
write_node,special_node: begin delete_token_ref(write_tokens(p));
@y
write_node,special_node,latespecial_node: begin delete_token_ref(write_tokens(p));
@z

@x
close_node,language_node: free_node(p,small_node_size);
@y
close_node,language_node: free_node(p,small_node_size);
pdf_save_pos_node: free_node(p, small_node_size);
@z

@x
procedure special_out(@!p:pointer);
var old_setting:0..max_selector; {holds print |selector|}
@!k:pool_pointer; {index into |str_pool|}
begin synch_h; synch_v;@/
old_setting:=selector; selector:=new_string;
show_token_list(link(write_tokens(p)),null,pool_size-pool_ptr);
@y
procedure special_out(@!p:pointer);
label done;
var old_setting:0..max_selector; {holds print |selector|}
@!h:halfword;
@!k:pool_pointer; {index into |str_pool|}
@!q,@!r:pointer; {temporary variables for list manipulation}
@!old_mode:integer; {saved |mode|}
@!s,@!t,@!cw, @!num, @!denom: scaled;
@!bl: boolean;
@!i: small_number;
begin synch_h; synch_v;@/
old_setting:=selector;
if subtype(p)=latespecial_node then
  begin @<Expand macros in the token list
    and make |link(def_ref)| point to the result@>;
    h:=def_ref;
  end
else h:=write_tokens(p);
selector:=new_string;
show_token_list(link(h),null,pool_size-pool_ptr);
@z

@x
pool_ptr:=str_start[str_ptr]; {erase the string}
@y
if read_papersize_special>0 then
  @<Determine whether this \.{\\special} is a papersize special@>;
done: pool_ptr:=str_start[str_ptr]; {erase the string}
if subtype(p)=latespecial_node then
  flush_list(def_ref);
@z

@x
@!d:integer; {number of characters in incomplete current string}
@y
@!k:integer; {loop indices}
@!d:integer; {number of characters in incomplete current string}
@z

@x
  for d:=0 to cur_length-1 do
    begin {|print| gives up if passed |str_ptr|, so do it by hand.}
    print(so(str_pool[str_start[str_ptr]+d])); {N.B.: not |print_char|}
    end;
@y
  for d:=0 to cur_length-1 do
    begin {|print| gives up if passed |str_ptr|, so do it by hand.}
    if so(str_pool[str_start[str_ptr]+d])>=@"100 then
    print_char(so(str_pool[str_start[str_ptr]+d]))
    else print(so(str_pool[str_start[str_ptr]+d])); {N.B.: not |print_char|}
    end;
@z

@x
      runsystem_ret := runsystem(conststringcast(addressof(
                                              str_pool[str_start[str_ptr]])));
@y
      if name_of_file then libc_free(name_of_file);
      name_of_file := xmalloc(cur_length*4+1);
      k := 0;
      for d:=0 to cur_length-1 do
        append_to_name_escape(str_pool[str_start[str_ptr]+d]); {do not remove quote}
      name_of_file[k+1] := 0;
      runsystem_ret := runsystem(conststringcast(name_of_file+1));
@z

@x
special_node:special_out(p);
language_node:do_nothing;
@y
special_node,latespecial_node:special_out(p);
language_node:do_nothing;
pdf_save_pos_node:
  @<Save current position in DVI mode@>;
@z

@x
  begin p:=tail; do_extension; {append a whatsit node}
  out_what(tail); {do the action immediately}
  flush_node_list(tail); tail:=p; link(p):=null;
  end
@y
  begin k:=inhibit_glue_flag;
  p:=tail; do_extension; {append a whatsit node}
  out_what(tail); {do the action immediately}
  flush_node_list(tail); tail:=p; link(p):=null;
  inhibit_glue_flag:=k;
  end
@z

@x
if l<>clang then
  begin new_whatsit(language_node,small_node_size);
@y
if l<>clang then
  begin inhibit_glue_flag:=false;
  new_whatsit(language_node,small_node_size);
@z

@x
if abs(mode)<>hmode then report_illegal_case
else begin new_whatsit(language_node,small_node_size);
@y
if abs(mode)<>hmode then report_illegal_case
else begin inhibit_glue_flag:=false;
  new_whatsit(language_node,small_node_size);
@z

@x
@ @<Finish the extensions@>=
@y
@ @<Declare procedures needed in |do_ext...@>=
procedure eptex_set_input_encoding;
var j,k:integer;
begin
  scan_file_name;
  pack_cur_name;
  if state=token_list then
    begin k:=input_ptr-1; j:=-1;
    while k>=0 do
      begin if input_stack[k].state_field=token_list then decr(k)
      else if input_stack[k].name_field>19 then
        begin j:=input_stack[k].index_field; k:=-1; end
      else begin j:=-(input_stack[k].name_field+1); k:=-1; end
      end
    end
  else if name>19 then j:=index else j:=-(name+1);
  if (j>=0) or (j=-1) or (j=-18) then begin
    k:=true;
    if j>=0 then k:=setinfileenc(input_file[j],stringcast(name_of_file+1))
    else k:=setstdinenc(stringcast(name_of_file+1));
    if k = false then
      begin begin_diagnostic;
      print_nl("Unknown encoding `");
      slow_print(cur_area); slow_print(cur_name); slow_print(cur_ext);
      print("'"); end_diagnostic(false);
      end
    end
  else
    begin begin_diagnostic; j:=-j-1;
    print_ln;
    print_nl("Warning: \epTeXinputencoding is ignored, since I am current reading");
    print_nl("from ");
    if j>=18 then print("a pseudo file created by \scantokens.")
    else begin print("input stream "); print_int(j); print("."); end;
    end_diagnostic(false);
    end
end;

@ @<Implement \.{\\epTeXinputencoding}@>=
eptex_set_input_encoding

@ @<Finish the extensions@>=
@z

@x
primitive("lastnodetype",last_item,last_node_type_code);
@!@:last_node_type_}{\.{\\lastnodetype} primitive@>
@y
primitive("lastnodetype",last_item,last_node_type_code);
@!@:last_node_type_}{\.{\\lastnodetype} primitive@>
primitive("lastnodesubtype",last_item,last_node_subtype_code);
@!@:last_node_subtype_}{\.{\\lastnodesubtype} primitive@>
primitive("lastnodechar",last_item,last_node_char_code);
@!@:last_node_char_}{\.{\\lastnodechar} primitive@>
primitive("lastnodefont",last_item,last_node_font_code);
@!@:last_node_font_}{\.{\\lastnodefont} primitive@>
@z

@x
primitive("eTeXrevision",convert,eTeX_revision_code);@/
@!@:eTeX_revision_}{\.{\\eTeXrevision} primitive@>
@y
primitive("eTeXrevision",convert,eTeX_revision_code);@/
@!@:eTeX_revision_}{\.{\\eTeXrevision} primitive@>
primitive("pdfprimitive",no_expand,1);@/
@!@:pdfprimitive_}{\.{\\pdfprimitive} primitive@>
primitive("pdfstrcmp",convert,pdf_strcmp_code);@/
@!@:pdf_strcmp_}{\.{\\pdfstrcmp} primitive@>
primitive("pdfcreationdate",convert,pdf_creation_date_code);@/
@!@:pdf_creation_date_}{\.{\\pdfcreationdate} primitive@>
primitive("pdffilemoddate",convert,pdf_file_mod_date_code);@/
@!@:pdf_file_mod_date_}{\.{\\pdffilemoddate} primitive@>
primitive("pdffilesize",convert,pdf_file_size_code);@/
@!@:pdf_file_size_}{\.{\\pdffilesize} primitive@>
primitive("pdfmdfivesum",convert,pdf_mdfive_sum_code);@/
@!@:pdf_mdfive_sum_}{\.{\\pdfmdfivesum} primitive@>
primitive("pdffiledump",convert,pdf_file_dump_code);@/
@!@:pdf_file_dump_}{\.{\\pdffiledump} primitive@>
primitive("pdfsavepos",extension,pdf_save_pos_node);@/
@!@:pdf_save_pos_}{\.{\\pdfsavepos} primitive@>
primitive("pdfpagewidth",assign_dimen,dimen_base+pdf_page_width_code);@/
@!@:pdf_page_width_}{\.{\\pdfpagewidth} primitive@>
primitive("pdfpageheight",assign_dimen,dimen_base+pdf_page_height_code);@/
@!@:pdf_page_height_}{\.{\\pdfpageheight} primitive@>
primitive("pdflastxpos",last_item,pdf_last_x_pos_code);@/
@!@:pdf_last_x_pos_}{\.{\\pdflastxpos} primitive@>
primitive("pdflastypos",last_item,pdf_last_y_pos_code);@/
@!@:pdf_last_y_pos_}{\.{\\pdflastypos} primitive@>
primitive("pdfshellescape",last_item,pdf_shell_escape_code);
@!@:pdf_shell_escape_}{\.{\\pdfshellescape} primitive@>
primitive("ifpdfprimitive",if_test,if_pdfprimitive_code);
@!@:if_pdfprimitive_}{\.{\\ifpdfprimitive} primitive@>
primitive("pdfuniformdeviate",convert,uniform_deviate_code);@/
@!@:uniform_deviate_}{\.{\\pdfuniformdeviate} primitive@>
primitive("pdfnormaldeviate",convert,normal_deviate_code);@/
@!@:normal_deviate_}{\.{\\pdfnormaldeviate} primitive@>
primitive("pdfrandomseed",last_item,random_seed_code);
@!@:random_seed_}{\.{\\pdfrandomseed} primitive@>
primitive("pdfsetrandomseed",extension,set_random_seed_code);@/
@!@:set_random_seed_code}{\.{\\pdfsetrandomseed} primitive@>
primitive("pdfelapsedtime",last_item,elapsed_time_code);
@!@:elapsed_time_}{\.{\\pdfelapsedtime} primitive@>
primitive("pdfresettimer",extension,reset_timer_code);@/
@!@:reset_timer_}{\.{\\pdfresettimer} primitive@>
primitive("Uchar",convert,Uchar_convert_code);@/
@!@:Uchar_}{\.{\\Uchar} primitive@>
primitive("Ucharcat",convert,Ucharcat_convert_code);@/
@!@:Ucharcat_}{\.{\\Ucharcat} primitive@>
primitive("nptexnoderecipe",assign_toks,node_recipe_loc);
@!@:nptex_node_recipe_}{\.{\\nptexnoderecipe} primitive@>
@z

@x
last_node_type_code: print_esc("lastnodetype");
@y
last_node_type_code: print_esc("lastnodetype");
last_node_subtype_code: print_esc("lastnodesubtype");
last_node_char_code: print_esc("lastnodechar");
last_node_font_code: print_esc("lastnodefont");
@z

@x
eTeX_version_code: print_esc("eTeXversion");
@y
eTeX_version_code: print_esc("eTeXversion");
pdf_last_x_pos_code:  print_esc("pdflastxpos");
pdf_last_y_pos_code:  print_esc("pdflastypos");
elapsed_time_code: print_esc("pdfelapsedtime");
pdf_shell_escape_code: print_esc("pdfshellescape");
random_seed_code:     print_esc("pdfrandomseed");
@z

@x
eTeX_version_code: cur_val:=eTeX_version;
@y
eTeX_version_code: cur_val:=eTeX_version;
pdf_last_x_pos_code: cur_val := pdf_last_x_pos;
pdf_last_y_pos_code: cur_val := pdf_last_y_pos;
pdf_shell_escape_code:
  begin
  if shellenabledp then begin
    if restrictedshell then cur_val :=2
    else cur_val := 1;
  end
  else cur_val := 0;
  end;
elapsed_time_code: cur_val := get_microinterval;
random_seed_code:  cur_val := random_seed;
@z

@x
primitive("savinghyphcodes",assign_int,int_base+saving_hyph_codes_code);@/
@!@:saving_hyph_codes_}{\.{\\savinghyphcodes} primitive@>
@y
primitive("savinghyphcodes",assign_int,int_base+saving_hyph_codes_code);@/
@!@:saving_hyph_codes_}{\.{\\savinghyphcodes} primitive@>
primitive("readpapersizespecial",assign_int,int_base+read_papersize_special_code);@/
@!@:read_papersize_special_}{\.{\\readpapersizespecial} primitive@>
primitive("suppresslongerror",assign_int,int_base+suppress_long_error_code);@/
@!@:suppress_long_error_}{\.{\\suppresslongerror} primitive@>
primitive("suppressoutererror",assign_int,int_base+suppress_outer_error_code);@/
@!@:suppress_outer_error_}{\.{\\suppressoutererror} primitive@>
primitive("suppressmathparerror",assign_int,int_base+suppress_mathpar_error_code);@/
@!@:suppress_mathpar_error_}{\.{\\suppressmathparerror} primitive@>
@z

@x
saving_hyph_codes_code:print_esc("savinghyphcodes");
@y
saving_hyph_codes_code:print_esc("savinghyphcodes");
read_papersize_special_code:print_esc("readpapersizespecial");
suppress_long_error_code: print_esc("suppresslongerror");
suppress_outer_error_code: print_esc("suppressoutererror");
suppress_mathpar_error_code: print_esc("suppressmathparerror");
@z

@x
font_char_ic_code: begin scan_font_ident; q:=cur_val; scan_char_num;
  if (font_bc[q]<=cur_val)and(font_ec[q]>=cur_val) then
    begin i:=char_info(q)(qi(cur_val));
    case m of
    font_char_wd_code: cur_val:=char_width(q)(i);
    font_char_ht_code: cur_val:=char_height(q)(height_depth(i));
    font_char_dp_code: cur_val:=char_depth(q)(height_depth(i));
    font_char_ic_code: cur_val:=char_italic(q)(i);
    end; {there are no other cases}
    end
  else cur_val:=0;
  end;
@y
font_char_ic_code: begin scan_font_ident; q:=cur_val;
  if font_dir[q]<>dir_default then {Japanese font}
    begin scan_int;
    if cur_val>=0 then
      begin if is_char_kanji(cur_val) then {Japanese Character}
        cur_val:=get_jfm_pos(KANJI(cur_val),q)
      else cur_val:=-1
      end
    else begin
      cur_val:=-(cur_val+1);
      if (font_bc[q]>cur_val)or(font_ec[q]<cur_val) then cur_val:=-1
    end;
    if cur_val<>-1 then
      begin
      i:=orig_char_info(q)(qi(cur_val));
      case m of
      font_char_wd_code: cur_val:=char_width(q)(i);
      font_char_ht_code: cur_val:=char_height(q)(height_depth(i));
      font_char_dp_code: cur_val:=char_depth(q)(height_depth(i));
      font_char_ic_code: cur_val:=char_italic(q)(i);
      end; {there are no other cases}
      end
    else cur_val:=0;
    end
  else begin scan_ascii_num;
    if (font_bc[q]<=cur_val)and(font_ec[q]>=cur_val) then
      begin i:=orig_char_info(q)(qi(cur_val));
      case m of
      font_char_wd_code: cur_val:=char_width(q)(i);
      font_char_ht_code: cur_val:=char_height(q)(height_depth(i));
      font_char_dp_code: cur_val:=char_depth(q)(height_depth(i));
      font_char_ic_code: cur_val:=char_italic(q)(i);
      end; {there are no other cases}
      end
    else cur_val:=0;
    end
  end;
@z

@x
@!LR_ptr:pointer; {stack of LR codes for |hpack|, |ship_out|, and |init_math|}
@y
@!revdisp:scaled; {temporary value of displacement}
@!LR_ptr:pointer; {stack of LR codes for |hpack|, |ship_out|, and |init_math|}
@z

@x
var l:pointer; {the new list}
@y
var l,la:pointer; {the new list}
disp,disp2: scaled; { displacement } disped: boolean;
@z

@x
begin g_order:=glue_order(this_box); g_sign:=glue_sign(this_box);
@y
begin g_order:=glue_order(this_box); g_sign:=glue_sign(this_box);
disp:=revdisp; disped:=false;
@z

@x
done:reverse:=l;
@y
done: {if the beginning node of the new list isn't |disp_node|,
       we insert |disp_node| to fix.}
if (l<>null)and(type(l)<>disp_node) then begin
  p:=get_node(small_node_size); type(p):=disp_node;
  disp_dimen(p):=disp; link(p):=l; reverse:=p;
  end
else reverse:=l;
@z

@x
  q:=link(p); link(p):=l; l:=p; p:=q;
@y
  if font_dir[f]<>dir_default then begin
    q:=link(p); la:=l; l:=p; p:=link(q); link(q):=la;
    end
  else begin q:=link(p); link(p):=l; l:=p; p:=q; end;
@z

@x
othercases goto next_p
@y
disp_node: begin
  disp2:=disp_dimen(p); disp_dimen(p):=disp; disp:=disp2;
  if not disped then disped:=true; end;
othercases goto next_p
@z

@x
  hlist_node,vlist_node: begin r:=get_node(box_node_size);
@y
  dir_node,
  hlist_node,vlist_node: begin r:=get_node(box_node_size);
@z

@x
    mem[r+6]:=mem[p+6]; mem[r+5]:=mem[p+5]; {copy the last two words}
@y
    mem[r+7]:=mem[p+7];
    mem[r+6]:=mem[p+6]; mem[r+5]:=mem[p+5]; {copy the last three words}
    add_glue_ref(space_ptr(r)); add_glue_ref(xspace_ptr(r));
@z

@x
    buffer[last]:=w.b0; buffer[last+1]:=w.b1;
    buffer[last+2]:=w.b2; buffer[last+3]:=w.b3;
@y
    buffer[last]:=w.b0 mod @"100; buffer[last+1]:=w.b1 mod @"100;
    buffer[last+2]:=w.b2 mod @"100; buffer[last+3]:=w.b3 mod @"100;@/
    buffer2[last]:=0; buffer2[last+1]:=0;
    buffer2[last+2]:=0; buffer2[last+3]:=0;
@z

@x
@ @<Handle \.{\\readline} and |goto done|@>=
if j=1 then
  begin while loc<=limit do {current line not yet finished}
    begin cur_chr:=buffer[loc]; incr(loc);
    if cur_chr=" " then cur_tok:=space_token
    @+else cur_tok:=cur_chr+other_token;
@y
@ @<Handle \.{\\readline} and |goto done|@>=
if j=1 then
  begin while loc<=limit do {current line not yet finished}
    begin cur_chr:=fromBUFF(ustringcast(buffer), limit+1, loc);
    loc:=loc+multistrlen(ustringcast(buffer), limit+1,loc);
    cur_tok:=cat_code(cur_chr);
    if (cur_tok=letter)and(cjkx_code(cur_chr)>0) then
      cur_tok:=letter+cjkx_code(cur_chr)*cjk_code_flag
    else if (cur_tok=other_char)and(cjkx_code(cur_chr)>0) then
      cur_tok:=other_kchar
    else cur_tok:=other_char;
    if cur_chr=" " then cur_tok:=space_token
    else cur_tok:=cur_chr+cur_tok*max_char_val;
@z

@x
primitive("iffontchar",if_test,if_font_char_code);
@!@:if_font_char_}{\.{\\iffontchar} primitive@>
@y
primitive("iffontchar",if_test,if_font_char_code);
@!@:if_font_char_}{\.{\\iffontchar} primitive@>
primitive("ifincsname",if_test,if_in_csname_code);
@!@:if_in_csname_}{\.{\\ifincsname} primitive@>
@z

@x
if_font_char_code:print_esc("iffontchar");
@y
if_font_char_code:print_esc("iffontchar");
if_in_csname_code:print_esc("ifincsname");
@z

@x
if_cs_code:begin n:=get_avail; p:=n; {head of the list of characters}
  repeat get_x_token;
@y
if_cs_code:begin n:=get_avail; p:=n; {head of the list of characters}
 e := is_in_csname; is_in_csname := true;
  repeat get_x_token;
@z

@x
  b:=(eq_type(cur_cs)<>undefined_cs);
@y
  b:=(eq_type(cur_cs)<>undefined_cs);
  is_in_csname := e;
@z

@x
  buffer[m]:=info(p) mod @'400; incr(m); p:=link(p);
@y
  if check_kanji(info(p)) then {|wchar_token|}
    begin
    if BYTE1(toBUFF(info(p) mod max_char_val))<>0 then
      begin buffer[m]:=BYTE1(toBUFF(info(p) mod max_char_val)); buffer2[m]:=1; incr(m); end;
    if BYTE2(toBUFF(info(p) mod max_char_val))<>0 then
      begin buffer[m]:=BYTE2(toBUFF(info(p) mod max_char_val)); buffer2[m]:=1; incr(m); end;
    if BYTE3(toBUFF(info(p) mod max_char_val))<>0 then
      begin buffer[m]:=BYTE3(toBUFF(info(p) mod max_char_val)); buffer2[m]:=1; incr(m); end;
    buffer[m]:=BYTE4(toBUFF(info(p) mod max_char_val)); buffer2[m]:=1; incr(m);
    p:=link(p);
    end
  else
    begin buffer[m]:=info(p) mod max_char_val; buffer2[m]:=0; incr(m); p:=link(p);
    end;
@z

@x
if_font_char_code:begin scan_font_ident; n:=cur_val; scan_char_num;
  if (font_bc[n]<=cur_val)and(font_ec[n]>=cur_val) then
    b:=char_exists(char_info(n)(qi(cur_val)))
  else b:=false;
  end;
@y
if_in_csname_code: b := is_in_csname;
if_font_char_code:begin scan_font_ident; n:=cur_val;
  if font_dir[n]<>dir_default then {Japanese font}
    begin scan_int;
    if cur_val>=0 then b:=is_char_kanji(cur_val)
    { In u\pTeX, $\hbox{|is_char_kanji|} = \lambda x\mathpunct{.} x\ge 0$ }
    else begin
      cur_val:=-(cur_val+1);
      b:=(font_bc[n]<=cur_val)and(font_ec[n]>=cur_val)
      end
    end
  else begin scan_ascii_num;
    if (font_bc[n]<=cur_val)and(font_ec[n]>=cur_val) then @/
      b:=char_exists(orig_char_info(n)(qi(cur_val)))
    else b:=false;
    end;
  end;
@z

@x
  else cur_val:=shrink_order(q);
@y
  else cur_val:=shrink_order(q);
  if cur_val>normal then cur_val:=cur_val-1; {compatible to \eTeX}
@z

@x
@ \eTeX\ (in extended mode) supports 32768 (i.e., $2^{15}$) count,
@y
@ \epTeX\ (in extended mode) supports 65536 (i.e., $2^{16}$) count,
@z

@x
Similarly there are 32768 mark classes; the command \.{\\marks}|n|
creates a mark node for a given mark class |0<=n<=32767| (where
@y
Similarly there are 65536 mark classes; the command \.{\\marks}|n|
creates a mark node for a given mark class |0<=n<=65535| (where
@z

@x
not exceed 255 in compatibility mode resp.\ 32767 in extended mode.
@y
not exceed 255 in compatibility mode resp.\ 65535 in extended mode.
@z

@x
max_reg_num:=32767;
max_reg_help_line:="A register number must be between 0 and 32767.";
@y
max_reg_num:=65535;
max_reg_help_line:="A register number must be between 0 and 65535.";
@z

@x
@ There are seven almost identical doubly linked trees, one for the
sparse array of the up to 32512 additional registers of each kind and
one for the sparse array of the up to 32767 additional mark classes.
The root of each such tree, if it exists, is an index node containing 16
pointers to subtrees for 4096 consecutive array elements.  Similar index
nodes are the starting points for all nonempty subtrees for 4096, 256,
and 16 consecutive array elements.  These four levels of index nodes are
followed by a fifth level with nodes for the individual array elements.

Each index node is nine words long.  The pointers to the 16 possible
subtrees or are kept in the |info| and |link| fields of the last eight
words.  (It would be both elegant and efficient to declare them as
array, unfortunately \PASCAL\ doesn't allow this.)
@y
@ There are eight almost identical doubly linked trees, one for the
sparse array of the up to 65280 additional registers of each kind and
one for the sparse array of the up to 65535 additional mark classes.
The root of each such tree, if it exists, is an index node containing 32
pointers to subtrees for $32^5$ consecutive array elements.  Similar index
nodes are the starting points for all nonempty subtrees for $32^4$, $32^3$,
$32^2$, and 32 consecutive array elements.  These five levels of index nodes
are followed by a sixth level with nodes for the individual array elements.

Each index node is 17 words long.  The pointers to the 32 possible
subtrees or are kept in the |info| and |link| fields of the last eight
words.  (It would be both elegant and efficient to declare them as
array, unfortunately \PASCAL\ doesn't allow this.)
@z

@x
@d mark_val=6 {the additional mark classes}
@#
@d dimen_val_limit=@"20 {$2^4\cdot(|dimen_val|+1)$}
@d mu_val_limit=@"40 {$2^4\cdot(|mu_val|+1)$}
@d box_val_limit=@"50 {$2^4\cdot(|box_val|+1)$}
@d tok_val_limit=@"60 {$2^4\cdot(|tok_val|+1)$}
@#
@d index_node_size=9 {size of an index node}
@y
@d mark_val=7 {the additional mark classes}
@#
@d dimen_val_limit=@"40 {$2^5\cdot(|dimen_val|+1)$}
@d mu_val_limit=@"80 {$2^5\cdot(|mu_val|+1)$}
@d box_val_limit=@"A0 {$2^5\cdot(|box_val|+1)$}
@d tok_val_limit=@"C0 {$2^5\cdot(|tok_val|+1)$}
@#
@d index_node_size=17 {size of an index node}
@z

@x
for k:=1 to index_node_size-1 do {clear all 16 pointers}
@y
for k:=1 to index_node_size-1 do {clear all 32 pointers}
@z

@x
@ @<Initialize table...@>=
for i:=int_val to tok_val do sa_root[i]:=null;
@y
@ @<Initialize table...@>=
for i:=int_val to node_recipe_val do sa_root[i]:=null;
@z

@x
We use macros to extract the four-bit pieces from a sixteen-bit register
number or mark class and to fetch or store one of the 16 pointers from
an index node.
@y
We use macros to extract the five-bit pieces from a twenty-five-bit register
number or mark class and to fetch or store one of the 32 pointers from
an index node. (Note that the |hex_dig| macros are mis-named since the conversion
from 4-bit to 5-bit fields for \npTeX!)

@z

@x
@d hex_dig1(#)==# div 4096 {the fourth lowest hexadecimal digit}
@d hex_dig2(#)==(# div 256) mod 16 {the third lowest hexadecimal digit}
@d hex_dig3(#)==(# div 16) mod 16 {the second lowest hexadecimal digit}
@d hex_dig4(#)==# mod 16 {the lowest hexadecimal digit}
@y
@d hex_dig1(#)==# div @"100000 {the fifth lowest 5-bit field}
@d hex_dig2(#)==(# div @"8000) mod @"20 {the fourth lowest 5-bit field}
@d hex_dig3(#)==(# div @"400) mod @"20 {the third lowest 5-bit field}
@d hex_dig4(#)==(# div @"20) mod @"20 {the second lowest 5-bit field}
@d hex_dig5(#)==# mod @"20 {the lowest 5-bit field}
@z

@x
procedure find_sa_element(@!t:small_number;@!n:halfword;@!w:boolean);
  {sets |cur_val| to sparse array element location or |null|}
label not_found,not_found1,not_found2,not_found3,not_found4,exit;
var q:pointer; {for list manipulations}
@!i:small_number; {a four bit index}
begin cur_ptr:=sa_root[t];
if_cur_ptr_is_null_then_return_or_goto(not_found);@/
q:=cur_ptr; i:=hex_dig1(n); get_sa_ptr;
if_cur_ptr_is_null_then_return_or_goto(not_found1);@/
q:=cur_ptr; i:=hex_dig2(n); get_sa_ptr;
if_cur_ptr_is_null_then_return_or_goto(not_found2);@/
q:=cur_ptr; i:=hex_dig3(n); get_sa_ptr;
if_cur_ptr_is_null_then_return_or_goto(not_found3);@/
q:=cur_ptr; i:=hex_dig4(n); get_sa_ptr;
if (cur_ptr=null)and w then goto not_found4;
return;
not_found: new_index(t,null); {create first level index node}
sa_root[t]:=cur_ptr; q:=cur_ptr; i:=hex_dig1(n);
not_found1: new_index(i,q); {create second level index node}
add_sa_ptr; q:=cur_ptr; i:=hex_dig2(n);
not_found2: new_index(i,q); {create third level index node}
add_sa_ptr; q:=cur_ptr; i:=hex_dig3(n);
not_found3: new_index(i,q); {create fourth level index node}
add_sa_ptr; q:=cur_ptr; i:=hex_dig4(n);
not_found4: @<Create a new array element of type |t| with index |i|@>;
link(cur_ptr):=q; add_sa_ptr;
exit:end;
@y
procedure find_sa_element(@!t:small_number;@!n:halfword;@!w:boolean);
  {sets |cur_val| to sparse array element location or |null|}
label not_found,not_found1,not_found2,not_found3,not_found4,not_found5,exit;
var q:pointer; {for list manipulations}
@!i:small_number; {a five bit index}
begin cur_ptr:=sa_root[t];
if_cur_ptr_is_null_then_return_or_goto(not_found);@/
q:=cur_ptr; i:=hex_dig1(n); get_sa_ptr;
if_cur_ptr_is_null_then_return_or_goto(not_found1);@/
q:=cur_ptr; i:=hex_dig2(n); get_sa_ptr;
if_cur_ptr_is_null_then_return_or_goto(not_found2);@/
q:=cur_ptr; i:=hex_dig3(n); get_sa_ptr;
if_cur_ptr_is_null_then_return_or_goto(not_found3);@/
q:=cur_ptr; i:=hex_dig4(n); get_sa_ptr;
if_cur_ptr_is_null_then_return_or_goto(not_found4);@/
q:=cur_ptr; i:=hex_dig5(n); get_sa_ptr;
if (cur_ptr=null)and w then goto not_found5;
return;
not_found: new_index(t,null); {create first level index node}
sa_root[t]:=cur_ptr; q:=cur_ptr; i:=hex_dig1(n);
not_found1: new_index(i,q); {create second level index node}
add_sa_ptr; q:=cur_ptr; i:=hex_dig2(n);
not_found2: new_index(i,q); {create third level index node}
add_sa_ptr; q:=cur_ptr; i:=hex_dig3(n);
not_found3: new_index(i,q); {create fourth level index node}
add_sa_ptr; q:=cur_ptr; i:=hex_dig4(n);
not_found4: new_index(i,q); {create fifth level index node}
add_sa_ptr; q:=cur_ptr; i:=hex_dig5(n);
not_found5: @<Create a new array element of type |t| with index |i|@>;
link(cur_ptr):=q; add_sa_ptr;
exit:end;
@z

@x
@d sa_type(#)==(sa_index(#) div 16) {type part of combined type/index}
@y
@d sa_type(#)==(sa_index(#) div 32) {type part of combined type/index}
@z

@x
sa_index(cur_ptr):=16*t+i; sa_lev(cur_ptr):=level_one
@y
sa_index(cur_ptr):=32*t+i; sa_lev(cur_ptr):=level_one
@z

@x
repeat i:=hex_dig4(sa_index(q)); p:=q; q:=link(p); free_node(p,s);
@y
repeat i:=hex_dig5(sa_index(q)); p:=q; q:=link(p); free_node(p,s);
@z

@x
else  begin n:=hex_dig4(sa_index(q)); q:=link(q); n:=n+16*sa_index(q);
  q:=link(q); n:=n+256*(sa_index(q)+16*sa_index(link(q)));
@y
else  begin n:=hex_dig5(sa_index(q)); q:=link(q); n:=n+32*sa_index(q);
  q:=link(q); n:=n+@"400*(sa_index(q)+32*sa_index(link(q)));
  q:=link(link(q)); n:=n+@"100000*sa_index(q);
@z

@x
begin if l<4 then {|q| is an index node}
@y
begin if l<5 then {|q| is an index node}
@z

@x
@!fill_width:array[0..2] of scaled; {infinite stretch components of
@y
@!fill_width:array[0..3] of scaled; {infinite stretch components of
@z

@x
    if (background[3]=0)and(background[4]=0)and(background[5]=0) then
    begin do_last_line_fit:=true;
    active_node_size:=active_node_size_extended;
    fill_width[0]:=0; fill_width[1]:=0; fill_width[2]:=0;
@y
    if (background[3]=0)and(background[4]=0)and@|
       (background[5]=0)and(background[6]=0) then
    begin do_last_line_fit:=true;
    active_node_size:=active_node_size_extended;
    fill_width[0]:=0; fill_width[1]:=0; fill_width[2]:=0; fill_width[3]:=0;
@z

@x
if (cur_active_width[3]<>fill_width[0])or@|
  (cur_active_width[4]<>fill_width[1])or@|
  (cur_active_width[5]<>fill_width[2]) then goto not_found;
  {infinite stretch of this line not entirely due to |par_fill_skip|}
if active_short(r)>0 then g:=cur_active_width[2]
else g:=cur_active_width[6];
@y
if (cur_active_width[3]<>fill_width[0])or@|
  (cur_active_width[4]<>fill_width[1])or@|
  (cur_active_width[5]<>fill_width[2])or@|
  (cur_active_width[6]<>fill_width[3]) then goto not_found;
  {infinite stretch of this line not entirely due to |par_fill_skip|}
if active_short(r)>0 then g:=cur_active_width[2]
else g:=cur_active_width[7];
@z

@x
begin if -g>cur_active_width[6] then g:=-cur_active_width[6];
b:=badness(-g,cur_active_width[6]);
@y
begin if -g>cur_active_width[7] then g:=-cur_active_width[7];
b:=badness(-g,cur_active_width[7]);
@z

@x
if shortfall>0 then g:=cur_active_width[2]
else if shortfall<0 then g:=cur_active_width[6]
@y
if shortfall>0 then g:=cur_active_width[2]
else if shortfall<0 then g:=cur_active_width[7]
@z

@x
@<Glob...@> =
@!debug_format_file: boolean;
@y
@<Glob...@> =
@!debug_format_file: boolean;

@ @<Set init...@>=
@!debug debug_format_file:=true; @+gubed;
@z

@x
  if eight_bit_p then
    for k:=0 to 255 do
      xprn[k]:=1;
end;
@y
  if eight_bit_p then
    for k:=0 to 255 do
      xprn[k]:=1;
end;
for k:=256 to 511 do begin xchr[k]:=k; xchr[k+256]:=k; end;
@z

@x
  for i:=str_start[s] to str_start[s+1]-1 do
    dummy := more_name(str_pool[i]); {add each read character to the current file name}
@y
  for i:=str_start[s] to str_start[s+1]-1 do
    if str_pool[i]>=@"100 then
      begin str_room(1); append_char(str_pool[i]);
      end
    else
      dummy := more_name(str_pool[i]); {add each read character to the current file name}
@z

@x
@* \[54] System-dependent changes.
@y
@* \[54/\pTeX] System-dependent changes for \pTeX.
This section described extended variables, procesures, functions and so on
for \pTeX.

@<Declare procedures that scan font-related stuff@>=
function get_jfm_pos(@!kcode:KANJI_code;@!f:internal_font_number):eight_bits;
var @!jc:KANJI_code; {temporary register for KANJI}
@!sp,@!mp,@!ep:pointer;
begin@/
if f=null_font then
  begin get_jfm_pos:=kchar_type(null_font)(0); return;
  end;
jc:=toDVI(kcode);
sp:=1; { start position }
ep:=font_num_ext[f]-1; { end position }
if (ep>=1) then { nt is larger than 1; |char_type| is non-empty }
if font_enc[f]=0 then { |kchar_code| are ordered; faster search }
begin if (kchar_code(f)(sp)<=jc)and(jc<=kchar_code(f)(ep)) then
  begin while (sp <= ep) do
    begin mp:=sp+((ep-sp) div 2);
    if jc<kchar_code(f)(mp) then ep:=mp-1
    else if jc>kchar_code(f)(mp) then sp:=mp+1
    else
      begin get_jfm_pos:=kchar_type(f)(mp); return;
      end;
    end;
  end;
end
else { TFM-DVI encoding conversion; whole search }
  begin while (sp <= ep) do
    if jc=kchar_code(f)(sp) then
      begin get_jfm_pos:=kchar_type(f)(sp); return;
      end
    else incr(sp);
  end;
get_jfm_pos:=kchar_type(f)(0);
end;

@ The function |scan_keyword_noexpand| is used to scan a keyword
preceding possibly undefined control sequence.
It is used while scanning \.{\\font} with JFM encoding specification.

@<Declare the function called |scan_keyword_noexpand|@>=
function scan_keyword_noexpand(@!s:str_number):boolean;
label exit;
var p:pointer; {tail of the backup list}
@!q:pointer; {new node being added to the token list via |store_new_token|}
@!k:pool_pointer; {index into |str_pool|}
begin p:=backup_head; link(p):=null; k:=str_start[s];
while k<str_start[s+1] do
  begin get_token; {no expansion}
  if (cur_cs=0)and@|
   ((cur_chr=so(str_pool[k]))or(cur_chr=so(str_pool[k])-"a"+"A")) then
    begin store_new_token(cur_tok); incr(k);
    end
  else if (cur_cmd<>spacer)or(p<>backup_head) then
    begin back_input;
    if p<>backup_head then back_list(link(backup_head));
    scan_keyword_noexpand:=false; return;
    end;
  end;
flush_list(link(backup_head)); scan_keyword_noexpand:=true;
exit:end;

@ @<Scan the font encoding specification@>=
begin jfm_enc:=0;
if scan_keyword_noexpand("in") then
  if scan_keyword_noexpand("jis") then jfm_enc:=1
  else if scan_keyword_noexpand("ucs") then jfm_enc:=2
  else begin
    print_err("Unknown TFM encoding");
@.Unknown TFM encoding@>
    help1("TFM encoding specification is ignored.");@/
    error;
  end;
end

@ Following codes are used to calculate a KANJI width and height.

@<Local variables for dimension calculations@>=
@!t: eight_bits;

@ @<The KANJI width for |cur_jfont|@>=
if direction=dir_tate then
  v:=char_width(cur_tfont)(orig_char_info(cur_tfont)(qi(0)))
else
  v:=char_width(cur_jfont)(orig_char_info(cur_jfont)(qi(0)))

@ @<The KANJI height for |cur_jfont|@>=
if direction=dir_tate then begin
  t:=height_depth(orig_char_info(cur_tfont)(qi(0)));
  v:=char_height(cur_tfont)(t)+char_depth(cur_tfont)(t);
end else begin
  t:=height_depth(orig_char_info(cur_jfont)(qi(0)));
  v:=char_height(cur_jfont)(t)+char_depth(cur_jfont)(t);
end

@ set a kansuji character.

@ @<Put each...@>=
primitive("kansujichar",set_kansuji_char,0);
@!@:kansujichar_}{\.{\\kansujichar} primitive@>

@ @<Cases of |print_cmd_chr|...@>=
set_kansuji_char: print_esc("kansujichar");

@ @<Assignments@>=
set_kansuji_char:
begin p:=cur_chr; scan_int; n:=cur_val; scan_optional_equals; scan_int;
if not is_char_kanji(cur_val) then
  begin print_err("Invalid KANSUJI char (");
  print_hex_safe(cur_val); print_char(")");
@.Invalid KANSUJI char@>
  help1("I'm skipping this control sequences.");@/
  error; return;
  end
else if (n<0)or(n>9) then
  begin print_err("Invalid KANSUJI number ("); print_int(n); print_char(")");
@.Invalid KANSUJI number@>
  help1("I'm skipping this control sequences.");@/
  error; return;
  end
else
  define(kansuji_base+n,n,tokanji(toDVI(cur_val)));
end;

@ @<Fetch kansuji char code from some table@>=
begin scan_int; cur_val_level:=int_val;
  if (cur_val<0)or(cur_val>9) then
    begin print_err("Invalid KANSUJI number ("); print_int(cur_val); print_char(")");
    help1("I'm skipping this control sequences.");@/
    error; return;
    end
  else
    cur_val:=fromDVI(kansuji_char(cur_val));
end

@ |print_kansuji| procedure converts a number to KANJI number.

@ @<Declare procedures needed in |scan_something_internal|@>=
procedure print_kansuji(@!n:integer);
var @!k:0..23; {index to current digit; we assume that $|n|<10^{23}$}
@!cx: KANJI_code; {temporary register for KANJI}
begin k:=0;
  if n<0 then return; {nonpositive input produces no output}
  repeat dig[k]:=n mod 10; n:=n div 10; incr(k);
  until n=0;
  begin while k>0 do
    begin decr(k);
    cx:=kansuji_char(dig[k]);
    print_utf8(fromDVI(cx));
    end;
  end;
end;

@ \pTeX\ inserts a glue specified by \.{\\kanjiskip} between 2byte-characters,
automatically, if \.{\\autospacing}.  This glue is suppressed by
\.{\\noautospacing}.
\.{\\xkanjiskip}, \.{\\noautoxspacing}, \.{\\autoxspacing}, \.{\\xspcode} is
used to control between 2byte and 1byte characters.

@d reset_auto_spacing_code=0
@d set_auto_spacing_code=1
@d reset_auto_xspacing_code=2
@d set_auto_xspacing_code=3
@d reset_enable_cjk_token_code=0
@d set_enable_cjk_token_code=1
@d set_force_cjk_token_code=2

@<Put each...@>=
primitive("autospacing",set_auto_spacing,set_auto_spacing_code);
@!@:auto_spacing_}{\.{\\autospacing} primitive@>
primitive("noautospacing",set_auto_spacing,reset_auto_spacing_code);
@!@:no_auto_spacing_}{\.{\\noautospacing} primitive@>
primitive("autoxspacing",set_auto_spacing,set_auto_xspacing_code);
@!@:auto_xspacing_}{\.{\\autoxspacing} primitive@>
primitive("noautoxspacing",set_auto_spacing,reset_auto_xspacing_code);
@!@:no_auto_xspacing_}{\.{\\noautoxspacing} primitive@>
primitive("enablecjktoken",set_enable_cjk_token,reset_enable_cjk_token_code);
@!@:enable_cjk_token_}{\.{\\enablecjktoken} primitive@>
primitive("disablecjktoken",set_enable_cjk_token,set_enable_cjk_token_code);
@!@:disable_cjk_token_}{\.{\\disablecjktoken} primitive@>
primitive("forcecjktoken",set_enable_cjk_token,set_force_cjk_token_code);
@!@:force_cjk_token_}{\.{\\forcecjktoken} primitive@>

@ @<Cases of |print_cmd_chr|...@>=
set_auto_spacing:begin
  if (chr_code mod 2)=0 then print_esc("noauto") else print_esc("auto");
  if chr_code<2 then print("spacing") else print("xspacing");
end;
set_enable_cjk_token:begin
  if chr_code=0 then print_esc("enable")
  else if chr_code=1 then print_esc("disable") else print_esc("force");
  print("cjktoken");
end;

@ @<Assignments@>=
set_auto_spacing:begin
  if cur_chr<2 then p:=auto_spacing_code
  else begin p:=auto_xspacing_code; cur_chr:=(cur_chr mod 2); end;
  define(p,data,cur_chr);
end;
set_enable_cjk_token: define(enable_cjk_token_code,data,cur_chr);

@ Following codes are used in section 49.

@<Show the current japanese processing mode@>=
begin
  @<Adjust |selector| based on |show_stream|@>
  print_nl("> ");
if auto_spacing>0 then print("auto spacing mode; ")
  else print("no auto spacing mode; ");
print_nl("> ");
if auto_xspacing>0 then print("auto xspacing mode")
  else print("no auto xspacing mode");
goto common_ending;
end

@ The \.{\\inhibitglue} primitive control to insert a glue specified
JFM (Japanese Font Metic) file.  The \.{\\inhibitxspcode} is used to control
inserting a space between 2byte-char and 1byte-char.

@d inhibit_both=0     {disable to insert space before 2byte-char and after it}
@d inhibit_previous=1 {disable to insert space before 2byte-char}
@d inhibit_after=2    {disable to insert space after 2byte-char}
@d inhibit_none=3     {enable to insert space before/after 2byte-char}
@d inhibit_unused=4   {unused entry}
@d no_entry=10000
@d new_pos=0
@d cur_pos=1

@ @<Cases of |main_control| that don't...@>=
  any_mode(inhibit_glue): inhibit_glue_flag:=(cur_chr=0);

@ @<Put each...@>=
primitive("inhibitglue",inhibit_glue,0);
@!@:inhibit_glue_}{\.{\\inhibitglue} primitive@>
primitive("disinhibitglue",inhibit_glue,1);
@!@:dis_inhibit_glue_}{\.{\\disinhibitglue} primitive@>
primitive("inhibitxspcode",assign_inhibit_xsp_code,inhibit_xsp_code_base);
@!@:inhibit_xsp_code_}{\.{\\inhibitxspcode} primitive@>

@ @<Cases of |print_cmd_chr|...@>=
inhibit_glue: if (chr_code>0) then print_esc("disinhibitglue")
  else print_esc("inhibitglue");
assign_inhibit_xsp_code: print_esc("inhibitxspcode");

@ @<Declare procedures needed in |scan_something_internal|@>=
function get_inhibit_pos(c:KANJI_code; n:small_number):pointer;
label done, done1;
var p,pp,s:pointer;
begin s:=calc_pos(c); p:=s; pp:=no_entry;
if n=new_pos then
  begin repeat
  if inhibit_xsp_code(p)=c then goto done;  { found, update there }
  if inhibit_xsp_code(p)=0 then             { no further scan needed }
    begin if pp<>no_entry then p:=pp; goto done; end;
  if inhibit_xsp_type(p)=inhibit_unused then
    if pp=no_entry then pp:=p; { save the nearest unused hash }
  incr(p); if p>1023 then p:=0;
  until s=p;
  p:=pp;
  end
else
  begin repeat
  if inhibit_xsp_code(p)=0 then goto done1;
  if inhibit_xsp_code(p)=c then goto done;
  incr(p); if p>1023 then p:=0;
  until s=p;
done1: p:=no_entry;
  end;
done: get_inhibit_pos:=p;
end;

@ @<Assignments@>=
assign_inhibit_xsp_code:
begin p:=cur_chr; scan_int; n:=cur_val; scan_optional_equals; scan_int;
if is_char_kanji(n) then
  begin j:=get_inhibit_pos(tokanji(n),new_pos);
  if (j<>no_entry)and(cur_val>inhibit_after) then
    begin if global or(cur_level=level_one) then cur_val:=inhibit_unused
      { remove the entry from inhibit table }
    else cur_val:=inhibit_none; end
  else if j=no_entry then
    begin print_err("Inhibit table is full!!");
    help1("I'm skipping this control sequences.");@/
    error; return; end;
  define(inhibit_xsp_code_base+j,cur_val,n);
  end
else
  begin print_err("Invalid KANJI code ("); print_hex_safe(n); print_char(")");
@.Invalid KANJI code@>
  help1("I'm skipping this control sequences.");@/
  error; return;
  end;
end;

@ @<Fetch inhibit type from some table@>=
begin scan_int; q:=get_inhibit_pos(tokanji(cur_val),cur_pos);
cur_val_level:=int_val; cur_val:=inhibit_none;
if q<>no_entry then cur_val:=inhibit_xsp_type(q);
if cur_val>inhibit_none then cur_val:=inhibit_none;
end

@ The \.{\\prebreakpenalty} is used to specified amount of penalties inserted
before the 2byte-char which is first argument of this primitive.
The \.{\\postbreakpenalty} is inserted after the 2byte-char.

@d pre_break_penalty_code=1
@d post_break_penalty_code=2
@d kinsoku_unused_code=3

@<Put each...@>=
primitive("prebreakpenalty",assign_kinsoku,pre_break_penalty_code);
@!@:pre_break_penalty_}{\.{\\prebreakpenalty} primitive@>
primitive("postbreakpenalty",assign_kinsoku,post_break_penalty_code);
@!@:post_break_penalty_}{\.{\\postbreakpenalty} primitive@>

@ @<Cases of |print_cmd_chr|...@>=
assign_kinsoku: case chr_code of
  pre_break_penalty_code: print_esc("prebreakpenalty");
  post_break_penalty_code: print_esc("postbreakpenalty");
  endcases;

@ @<Declare procedures needed in |scan_something_internal|@>=
function get_kinsoku_pos(c:KANJI_code; n:small_number):pointer;
label done, done1;
var p,pp,s:pointer;
begin s:=calc_pos(c); p:=s; pp:=no_entry;
@!debug
print_ln; print("c:="); print_int(c); print(", p:="); print_int(s);
if p+kinsoku_base<0 then
  begin print("p is negative value"); print_ln;
  end;
gubed
if n=new_pos then
  begin repeat
  if kinsoku_code(p)=c then goto done;  { found, update there }
  if kinsoku_type(p)=0 then             { no further scan needed }
    begin if pp<>no_entry then p:=pp; goto done; end;
  if kinsoku_type(p)=kinsoku_unused_code then
    if pp=no_entry then pp:=p; { save the nearest unused hash }
  incr(p); if p>1023 then p:=0;
  until s=p;
  p:=pp;
  end
else
  begin repeat
  if kinsoku_type(p)=0 then goto done1;
  if kinsoku_code(p)=c then goto done;
  incr(p); if p>1023 then p:=0;
  until s=p;
done1: p:=no_entry;
  end;
done: get_kinsoku_pos:=p;
end;

@ @<Assignments@>=
assign_kinsoku:
begin p:=cur_chr; scan_int; n:=cur_val; scan_optional_equals; scan_int;
if is_char_ascii(n) or is_char_kanji(n) then
  begin j:=get_kinsoku_pos(tokanji(n),new_pos);
  if (j<>no_entry)and(cur_val=0)and(global or(cur_level=level_one)) then
    define(kinsoku_base+j,kinsoku_unused_code,0) { remove the entry from KINSOKU table }
  else begin
    if j=no_entry then begin
      print_err("KINSOKU table is full!!");
      help1("I'm skipping this control sequences.");@/
      error; return; end;
    if (p=pre_break_penalty_code)or(p=post_break_penalty_code) then
      begin define(kinsoku_base+j,p,tokanji(n));
      word_define(kinsoku_penalty_base+j,cur_val);
      end
    else confusion("kinsoku");
@:this can't happen kinsoku}{\quad kinsoku@>
    end
  end
else
  begin print_err("Invalid KANJI code for ");
  if p=pre_break_penalty_code then print("pre")
  else if p=post_break_penalty_code then print("post")
  else print_char("?");
  print("breakpenalty ("); print_hex_safe(n); print_char(")");
@.Invalid KANJI code@>
  help1("I'm skipping this control sequences.");@/
  error; return;
  end;
end;

@ @<Fetch breaking penalty from some table@>=
begin scan_int; q:=get_kinsoku_pos(tokanji(cur_val),cur_pos);
cur_val_level:=int_val; cur_val:=0;
if (q<>no_entry)and(m=kinsoku_type(q)) then
    scanned_result(kinsoku_penalty(q))(int_val);
end

@ Following codes are used in |main_control|.

@<Insert kinsoku penalty@>=
begin kp:=get_kinsoku_pos(cx,cur_pos);
if kp<>no_entry then if kinsoku_penalty(kp)<>0 then
  begin if kinsoku_type(kp)=pre_break_penalty_code then
    begin if not is_char_node(cur_q)and(type(cur_q)=penalty_node) then
      penalty(cur_q):=penalty(cur_q)+kinsoku_penalty(kp)
    else
      begin main_p:=link(cur_q); link(cur_q):=new_penalty(kinsoku_penalty(kp));
      subtype(link(cur_q)):=kinsoku_pena; link(link(cur_q)):=main_p;
      end;
    end
  else if kinsoku_type(kp)=post_break_penalty_code then
    begin tail_append(new_penalty(kinsoku_penalty(kp)));
    subtype(tail):=kinsoku_pena;
    end;
  end;
end;

@ @<Insert |pre_break_penalty| of |cur_chr|@>=
begin kp:=get_kinsoku_pos(cur_chr,cur_pos);
if kp<>no_entry then if kinsoku_penalty(kp)<>0 then
  begin if kinsoku_type(kp)=pre_break_penalty_code then
    if not is_char_node(tail)and(type(tail)=penalty_node) then
      penalty(tail):=penalty(tail)+kinsoku_penalty(kp)
    else
      begin tail_append(new_penalty(kinsoku_penalty(kp)));
      subtype(tail):=kinsoku_pena;
      end;
  end;
end;

@ @<Insert |post_break_penalty|@>=
begin kp:=get_kinsoku_pos(cx,cur_pos);
if kp<>no_entry then if kinsoku_penalty(kp)<>0 then
  begin if kinsoku_type(kp)=post_break_penalty_code then
    begin tail_append(new_penalty(kinsoku_penalty(kp)));
    subtype(tail):=kinsoku_pena;
    end;
  end;
end;

@ This is a part of section 32.

The procedure |synch_dir| is used in |hlist_out| and |vlist_out|.

@d dvi_yoko=0
@d dvi_tate=1
@d dvi_dtou=3

@<Glob...@>=
@!dvi_dir:integer; {a \.{DVI} reader program thinks we direct to}
@!cur_dir_hv:integer; {\TeX\ thinks we direct to}
@!page_dir:eight_bits;

@ @<Set init...@>=
page_dir:=dir_yoko;

@ @<Declare procedures needed in |hlist_out|, |vlist_out|@>=
procedure synch_dir;
var tmp:scaled; {temporary resister}
begin
  case cur_dir_hv of
  dir_yoko:
    if dvi_dir<>cur_dir_hv then begin
      synch_h; synch_v; dvi_out(dirchg); dvi_out(dvi_yoko);
      dir_used:=true;
      case dvi_dir of
        dir_tate: begin tmp:=cur_h; cur_h:=-cur_v; cur_v:=tmp end;
        dir_dtou: begin tmp:=cur_h; cur_h:=cur_v; cur_v:=-tmp end;
      endcases;
      dvi_h:=cur_h; dvi_v:=cur_v; dvi_dir:=cur_dir_hv;
    end;
  dir_tate:
    if dvi_dir<>cur_dir_hv then begin
      synch_h; synch_v; dvi_out(dirchg); dvi_out(dvi_tate);
      dir_used:=true;
      case dvi_dir of
        dir_yoko: begin tmp:=cur_h; cur_h:=cur_v; cur_v:=-tmp end;
        dir_dtou: begin cur_v:=-cur_v; cur_h:=-cur_h; end;
      endcases;
      dvi_h:=cur_h; dvi_v:=cur_v; dvi_dir:=cur_dir_hv;
    end;
  dir_dtou:
    if dvi_dir<>cur_dir_hv then begin
      synch_h; synch_v; dvi_out(dirchg); dvi_out(dvi_dtou);
      dir_used:=true;
      case dvi_dir of
        dir_yoko: begin tmp:=cur_h; cur_h:=-cur_v; cur_v:=tmp end;
        dir_tate: begin cur_v:=-cur_v; cur_h:=-cur_h; end;
      endcases;
      dvi_h:=cur_h; dvi_v:=cur_v; dvi_dir:=cur_dir_hv;
    end;
  othercases
    confusion("synch_dir");
  endcases
end;

@ This function is called from |adjust_hlist| to check, whether
a list which pointed |box_p| contains a printing character.
If the list contains such a character, then return `true', otherwise `false'.
If the first matter is a character, |first_char| is stored it.
|last_char| is stored a last character.  If no printing characters exist
in the list, |first_char| and |last_char| is null.
@^recursion@>

Note that |first_char| and |last_char| may be |math_node|.

@<Glob...@>=
@!first_char:pointer; {first printable character}
@!last_char:pointer; {last printable character}
@!find_first_char:boolean; {find for a first printable character?}

@ @<Declare procedures needed in |hlist_out|, |vlist_out|@>=
function check_box(box_p:pointer):boolean;
label done;
var @!p:pointer; {run through the current box}
@!flag:boolean; {found any printable character?}
begin flag:=false; p:=box_p;
while p<>null do
  begin if is_char_node(p) then
    repeat
    if find_first_char then
      begin first_char:=p; find_first_char:=false
      end;
    last_char:=p; flag:=true;
    if font_dir[font(p)]<>dir_default then p:=link(p);
    p:=link(p);
    if p=null then goto done;
    until not is_char_node(p);
  case type(p) of
  hlist_node:
    begin flag:=true;
      if shift_amount(p)=0 then
        begin if check_box(list_ptr(p)) then flag:=true;
        end
      else if find_first_char then find_first_char:=false
        else last_char:=null;
    end;
  ligature_node: if check_box(lig_ptr(p)) then flag:=true;
  ins_node,disp_node,mark_node,adjust_node,whatsit_node,penalty_node:
    do_nothing;
  math_node:
    if (subtype(p)=before)or(subtype(p)=after) then
      begin if find_first_char then
        begin find_first_char:=false; first_char:=p;
        end;
        last_char:=p; flag:=true;
      end
    else do_nothing; {\.{\\beginR} etc.}
  kern_node:
    if subtype(p)=acc_kern then
      begin p:=link(p);
        if is_char_node(p) then
          if font_dir[font(p)]<>dir_default then p:=link(p);
        p:=link(link(p));
        if find_first_char then
          begin find_first_char:=false; first_char:=p;
          end;
        last_char:=p; flag:=true;
        if font_dir[font(p)]<>dir_default then p:=link(p);
        end
    else
      begin flag:=true;
        if find_first_char then find_first_char:=false
        else last_char:=null;
        end;
  othercases begin flag:=true;
    if find_first_char then find_first_char:=false
    else last_char:=null;
    end;
  endcases;
  p:=link(p);
  end;
done: check_box:=flag;
end;

@ Following procedure |adjust_hlist| inserts \.{\\xkanjiskip} between
2byte-char and 1byte-char in hlist which pointed |p|.
Note that the skip is inserted into a place where too difficult to decide
whether inserting or not (i.e, before penalty, after penalty).

If |pf| is true then insert |jchr_widow_penalty| that is penalty for
creating a widow KANJI character line.

@d no_skip=0
@d after_schar=1 {denote after single byte character}
@d after_wchar=2 {denote after double bytes character}

@<Declare procedures needed in |hlist_out|, |vlist_out|@>=
procedure adjust_hlist(p:pointer;pf:boolean);
label exit;
var q,s,t,u,v,x,z:pointer;
  i,k:halfword;
  a: pointer; { temporary pointer for accent }
  insert_skip:no_skip..after_wchar;
  cx:KANJI_code; {temporary register for KANJI character}
  ax:ASCII_code; {temporary register for ASCII character}
  do_ins:boolean; {for inserting |xkanji_skip| into previous (or after) KANJI}
begin if link(p)=null then goto exit;
if auto_spacing>0 then
  begin delete_glue_ref(space_ptr(p)); space_ptr(p):=kanji_skip;
  add_glue_ref(kanji_skip);
  end;
if auto_xspacing>0 then
  begin delete_glue_ref(xspace_ptr(p)); xspace_ptr(p):=xkanji_skip;
  add_glue_ref(xkanji_skip);
  end;
u:=space_ptr(p); add_glue_ref(u);
s:=xspace_ptr(p); add_glue_ref(s);
if not is_char_node(link(p)) then
  if (type(link(p))=glue_node)and(subtype(link(p))=jfm_skip+1) then
  begin v:=link(p); link(p):=link(v);
  fast_delete_glue_ref(glue_ptr(v)); free_node(v,small_node_size);
  end
  else if (type(link(p))=penalty_node)and(subtype(link(p))=kinsoku_pena) then
    begin v:=link(link(p));
    if (not is_char_node(v)) and (type(v)=glue_node)and(subtype(v)=jfm_skip+1) then
      begin link(link(p)):=link(v);
      fast_delete_glue_ref(glue_ptr(v)); free_node(v,small_node_size);
      end
    end;

i:=0; insert_skip:=no_skip; p:=link(p); v:=p; q:=p;
while p<>null do
  begin if is_char_node(p) then
    begin repeat @<Insert a space around the character |p|@>;
      q:=p; p:=link(p); incr(i);
      if (i>5)and pf then
        begin if is_char_node(v) then
        if font_dir[font(v)]<>dir_default then v:=link(v);
        v:=link(v);
        end;
    until not is_char_node(p);
    end
  else
    begin case type(p) of
    hlist_node: @<Insert hbox surround spacing@>;
    ligature_node: @<Insert ligature surround spacing@>;
    penalty_node,disp_node: @<Insert penalty or displace surround spacing@>;
    kern_node: if subtype(p)=explicit then insert_skip:=no_skip
      else if subtype(p)=acc_kern then begin
        { When we insert \.{\\xkanjiskip}, we first ignore accent (and kerns) and
          insert \.{\\xkanjiskip}, then we recover the accent. }
        if q=p then begin t:=link(p);
          { if p is beginning on the list, we have only to ignore nodes. }
          if is_char_node(t) then
            if font_dir[font(t)]<>dir_default then t:=link(t);
          p:=link(link(t));
          if font_dir[font(p)]<>dir_default then
            begin p:=link(p); insert_skip:=after_wchar; end
          else  insert_skip:=after_schar;
          end
        else begin
          a:=p; t:=link(p);
          if is_char_node(t) then
            if font_dir[font(t)]<>dir_default then t:=link(t);
          t:=link(link(t)); link(q):=t; p:=t;
          @<Insert a space around the character |p|@>; incr(i);
          if (i>5)and pf then
            begin if is_char_node(v) then
            if font_dir[font(v)]<>dir_default then v:=link(v);
            v:=link(v);
            end;
          if link(q)<>t then link(link(q)):=a else link(q):=a;
          end;
        end;
    math_node: @<Insert math surround spacing@>;
    mark_node,adjust_node,ins_node,whatsit_node:
      {These nodes are vanished when typeset is done}
      do_nothing;
    othercases insert_skip:=no_skip;
    endcases;
    q:=p; p:=link(p);
    end;
  end;
if not is_char_node(q)and(type(q)=glue_node)and(subtype(q)=jfm_skip+1) then
  begin fast_delete_glue_ref(glue_ptr(q));
  glue_ptr(q):=zero_glue; add_glue_ref(zero_glue);
  end;
delete_glue_ref(u); delete_glue_ref(s);
if (v<>null)and pf and(i>5) then @<Make |jchr_widow_penalty| node@>;
exit:
end;

@ @<Insert a space around the character |p|@>=
if font_dir[font(p)]<>dir_default then
  begin KANJI(cx):=info(link(p)) mod max_char_val;
  if insert_skip=after_schar then @<Insert ASCII-KANJI spacing@>;
  p:=link(p); insert_skip:=after_wchar;
  end
else
  begin ax:=qo(character(p));
  if insert_skip=after_wchar then @<Insert KANJI-ASCII spacing@>;
  if auto_xsp_code(ax)>=2 then
    insert_skip:=after_schar else insert_skip:=no_skip;
  end

@ @<Insert hbox surround spacing@>=
begin find_first_char:=true; first_char:=null; last_char:=null;
if shift_amount(p)=0 then
  begin if check_box(list_ptr(p)) then
    begin if first_char<>null then @<Insert a space before the |first_char|@>;
    if last_char<>null then
      begin @<Insert a space after the |last_char|@>;
      end else insert_skip:=no_skip;
    end else insert_skip:=no_skip;
  end else insert_skip:=no_skip;
end

@ @<Insert a space before the |first_char|@>=
if type(first_char)=math_node then
  begin ax:=qo("0");
  if insert_skip=after_wchar then @<Insert KANJI-ASCII spacing@>;
  end
else if font_dir[font(first_char)]<>dir_default then
  begin KANJI(cx):=info(link(first_char)) mod max_char_val;
  if insert_skip=after_schar then @<Insert ASCII-KANJI spacing@>
  else if insert_skip=after_wchar then @<Insert KANJI-KANJI spacing@>;
  end
else
  begin ax:=qo(character(first_char));
  if insert_skip=after_wchar then @<Insert KANJI-ASCII spacing@>;
  end;

@ @<Insert a space after the |last_char|@>=
if type(last_char)=math_node then
  begin ax:=qo("0");
  if auto_xsp_code(ax)>=2 then
    insert_skip:=after_schar else insert_skip:=no_skip;
  end
else if font_dir[font(last_char)]<>dir_default then
  begin insert_skip:=after_wchar;
  KANJI(cx):=info(link(last_char)) mod max_char_val;
  if is_char_node(link(p))and(font_dir[font(link(p))]<>dir_default) then
    begin @<Append KANJI-KANJI spacing@>; p:=link(p);
    end;
  end
else
  begin ax:=qo(character(last_char));
  if auto_xsp_code(ax)>=2 then
    insert_skip:=after_schar else insert_skip:=no_skip;
  end;

@ @<Insert math surround spacing@>=
begin if (subtype(p)=before)and(insert_skip=after_wchar) then
  begin ax:=qo("0"); @<Insert KANJI-ASCII spacing@>;
  insert_skip:=no_skip;
  end
else if subtype(p)=after then
  begin ax:=qo("0");
  if auto_xsp_code(ax)>=2 then
    insert_skip:=after_schar else insert_skip:=no_skip;
  end
else insert_skip:=no_skip;
end

@ @<Insert ligature surround spacing@>=
begin t:=lig_ptr(p);
if is_char_node(t) then
  begin ax:=qo(character(t));
  if insert_skip=after_wchar then @<Insert KANJI-ASCII spacing@>;
  while link(t)<>null do t:=link(t);
  if is_char_node(t) then
    begin ax:=qo(character(t));
    if auto_xsp_code(ax)>=2 then
      insert_skip:=after_schar else insert_skip:=no_skip;
    end;
  end;
end

@ @<Insert penalty or displace surround spacing@>=
begin if is_char_node(link(p)) then
  begin q:=p; p:=link(p);
  if font_dir[font(p)]<>dir_default then
    begin KANJI(cx):=info(link(p)) mod max_char_val;
    if insert_skip=after_schar then @<Insert ASCII-KANJI spacing@>
    else if insert_skip=after_wchar then @<Insert KANJI-KANJI spacing@>;
    p:=link(p); insert_skip:=after_wchar;
    end
  else
    begin ax:=qo(character(p));
    if insert_skip=after_wchar then @<Insert KANJI-ASCII spacing@>;
    if auto_xsp_code(ax)>=2 then
      insert_skip:=after_schar else insert_skip:=no_skip;
    end;
  end
end

@ @<Insert ASCII-KANJI spacing@>=
begin
  begin x:=get_inhibit_pos(cx,cur_pos);
  if x<>no_entry then
    if (inhibit_xsp_type(x)=inhibit_both)or
       (inhibit_xsp_type(x)=inhibit_previous) then
      do_ins:=false else do_ins:=true
  else do_ins:=true;
  end;
if do_ins then
  begin z:=new_glue(s); subtype(z):=xkanji_skip_code+1;
  link(z):=link(q); link(q):=z; q:=z;
  end;
end

@ @<Insert KANJI-ASCII spacing@>=
begin if (auto_xsp_code(ax) mod 2)=1 then
  begin x:=get_inhibit_pos(cx,cur_pos);
  if x<>no_entry then
    if (inhibit_xsp_type(x)=inhibit_both)or
       (inhibit_xsp_type(x)=inhibit_after) then
      do_ins:=false else do_ins:=true
  else do_ins:=true;
  end
else do_ins:=false;
if do_ins then
  begin z:=new_glue(s); subtype(z):=xkanji_skip_code+1;
  link(z):=link(q); link(q):=z; q:=z;
  end;
end

@ @<Insert KANJI-KANJI spacing@>=
begin z:=new_glue(u); subtype(z):=kanji_skip_code+1;
link(z):=link(q); link(q):=z; q:=z;
end

@ @<Append KANJI-KANJI spacing@>=
begin z:=new_glue(u); subtype(z):=kanji_skip_code+1;
link(z):=link(p); link(p):=z; p:=link(z); q:=z;
end

@ @<Make |jchr_widow_penalty| node@>=
begin q:=v; p:=link(v);
if is_char_node(v)and(font_dir[font(v)]<>dir_default) then
  begin q:=p; p:=link(p);
  end;
t:=q; s:=null;
@<Seek list and make |t| pointing widow penalty position@>;
if s<>null then
  begin s:=link(t);
    if not is_char_node(s)and(type(s)=penalty_node) then
      penalty(s):=penalty(s)+jchr_widow_penalty
    else if jchr_widow_penalty<>0 then
      begin s:=new_penalty(jchr_widow_penalty); subtype(s):=widow_pena;
      link(s):=link(t); link(t):=s; t:=link(s);
      while(not is_char_node(t)) do
        begin if (type(t)=glue_node)or(type(t)=kern_node) then goto exit;
        t:=link(t);
        end;
      z:=new_glue(u); subtype(z):=kanji_skip_code+1;
      link(z):=link(s); link(s):=z;
      end;
  end;
end;

@ @<Seek list and make |t| pointing widow penalty position@>=
k:=0;
while(p<>null) do
begin if is_char_node(p) then
  begin if font_dir[font(p)]<>dir_default then
    begin KANJI(cx):=info(link(p)) mod max_char_val;
    if (info(link(p)) div max_char_val)>0 then begin t:=q; s:=p; end;
    p:=link(p); q:=p;
    end
  else begin k:=k+1;
    if k>1 then begin q:=p; s:=null; end;
    end;
  end
else begin case type(p) of
  penalty_node,mark_node,adjust_node,whatsit_node,
  glue_node,kern_node,math_node,disp_node:
    do_nothing;
  othercases begin q:=p; s:=null; end;
  endcases;
  end;
p:=link(p);
end

@ @<Declare procedures needed in |hlist_out|, |vlist_out|@>=
procedure dir_out;
var @!this_box: pointer; {pointer to containing box}
begin this_box:=temp_ptr;
  temp_ptr:=list_ptr(this_box);
  if (type(temp_ptr)<>hlist_node)and(type(temp_ptr)<>vlist_node) then
    confusion("dir_out");
  case abs(box_dir(this_box)) of
  dir_yoko:
    case abs(box_dir(temp_ptr)) of
    dir_tate: {Tate in Yoko}
      begin cur_v:=cur_v-height(this_box); cur_h:=cur_h+depth(temp_ptr) end;
    dir_dtou: {DtoU in Yoko}
      begin cur_v:=cur_v+depth(this_box); cur_h:=cur_h+height(temp_ptr) end;
    endcases;
  dir_tate:
    case abs(box_dir(temp_ptr)) of
    dir_yoko: {Yoko in Tate}
      begin cur_v:=cur_v+depth(this_box); cur_h:=cur_h+height(temp_ptr) end;
    dir_dtou: {DtoU in Tate}
      begin
        cur_v:=cur_v+depth(this_box)-height(temp_ptr);
        cur_h:=cur_h+width(temp_ptr)
      end;
    endcases;
  dir_dtou:
    case abs(box_dir(temp_ptr)) of
    dir_yoko: {Yoko in DtoU}
      begin cur_v:=cur_v-height(this_box); cur_h:=cur_h+depth(temp_ptr) end;
    dir_tate: {Tate in DtoU}
      begin
        cur_v:=cur_v+depth(this_box)-height(temp_ptr);
        cur_h:=cur_h+width(temp_ptr)
      end;
    endcases;
  endcases;
  cur_dir_hv:=abs(box_dir(temp_ptr));
  if type(temp_ptr)=vlist_node then vlist_out@+else hlist_out;
end;

@ These routines are used to output diagnostic which related direction.

@ @<Basic printing procedures@>=
procedure print_dir(@!dir:eight_bits); {prints |dir| data}
begin if dir=dir_yoko then print_char("Y")
else if dir=dir_tate then print_char("T")
else if dir=dir_dtou then print_char("D")
end;
@#
procedure print_direction_alt(@!d:integer);
var x: boolean;
begin x:=false;
case abs(d) of
dir_yoko: begin print(", yoko"); x:=true; end;
dir_tate: begin print(", tate"); x:=true; end;
dir_dtou: begin print(", dtou"); x:=true; end;
end;
if x then begin if d<0 then print("(math)");
print(" direction"); end;
end;
@#
procedure print_direction(@!d:integer); {print the direction represented by d}
begin case abs(d) of
dir_yoko: print("yoko");
dir_tate: print("tate");
dir_dtou: print("dtou");
end;
if d<0 then print("(math)");
print(" direction");
end;

@ The procedure |set_math_kchar| is same as |set_math_char| which is
written in section 48.

@<Declare act...@>=
procedure set_math_kchar(@!c:integer);
var p:pointer; {the new noad}
begin p:=new_noad; math_type(nucleus(p)):=math_jchar;
character(nucleus(p)):=qi(0);
math_kcode(p):=c; fam(nucleus(p)):=cur_jfam;
if font_dir[fam_fnt(fam(nucleus(p))+cur_size)]=dir_default then
  begin print_err("Not two-byte family");
  help1("IGNORE.");@/
  error;
  end;
type(p):=ord_noad;
link(tail):=p; tail:=p;
end;

@ This section is a part of |main_control|.

@<Append KANJI-character |cur_chr| ...@>=
if is_char_node(tail) then
  begin if not( (last_jchr<>null) and (link(last_jchr)=tail) ) then
    begin cx:=qo(character(tail)); @<Insert |post_break_penalty|@>;
    end;
  end
else if type(tail)=ligature_node then
  begin cx:=qo(character(lig_char(tail))); @<Insert |post_break_penalty|@>;
  end;
if direction=dir_tate then
  begin if font_dir[main_f]=dir_tate then disp:=0
  else if font_dir[main_f]=dir_yoko then disp:=t_baseline_shift-y_baseline_shift
  else disp:=t_baseline_shift;
  main_f:=cur_tfont;
  end
else
  begin if font_dir[main_f]=dir_yoko then disp:=0
  else if font_dir[main_f]=dir_tate then disp:=y_baseline_shift-t_baseline_shift
  else disp:=y_baseline_shift;
  main_f:=cur_jfont;
  end;
@<Append |disp_node| at end of displace area@>;
ins_kp:=false; ligature_present:=false;
cur_l:=qi(get_jfm_pos(KANJI(cur_chr),main_f));
main_i:=orig_char_info(main_f)(qi(0));
goto main_loop_j+3;
@#
main_loop_j+1: space_factor:=1000;
  if main_f<>null_font then
    begin if not disp_called then
      begin prev_node:=tail; tail_append(get_node(small_node_size));
      type(tail):=disp_node; disp_dimen(tail):=0; disp_called:=true
      end;
    fast_get_avail(main_p); font(main_p):=main_f; character(main_p):=cur_l;
    link(tail):=main_p; tail:=main_p; last_jchr:=tail;
    fast_get_avail(main_p);
    if cur_cmd mod cjk_code_flag=other_char then
      info(main_p):=KANJI(cur_chr)+max_char_val
    else
      info(main_p):=KANJI(cur_chr);
    link(tail):=main_p; tail:=main_p;
    cx:=cur_chr; @<Insert kinsoku penalty@>;
  end;
  ins_kp:=false;
again_2:
  get_next;
  main_i:=orig_char_info(main_f)(cur_l);
  case cur_cmd of
    kanji,kana,other_kchar,hangul: begin
      cur_l:=qi(get_jfm_pos(KANJI(cur_chr),main_f)); goto main_loop_j+3;
      end;
    letter,other_char: begin ins_kp:=true; cur_l:=qi(0); goto main_loop_j+3;
      end;
  endcases;
  x_token;
  case cur_cmd of
    kanji,kana,other_kchar,hangul: cur_l:=qi(get_jfm_pos(KANJI(cur_chr),main_f));
    letter,other_char: begin ins_kp:=true; cur_l:=qi(0); end;
    char_given: begin
      if check_echar_range(cur_chr) then
        begin ins_kp:=true; cur_l:=qi(0);
        end
      else cur_l:=qi(get_jfm_pos(KANJI(cur_chr),main_f));
      cur_cmd:=kcat_code(cur_chr);
      end;
    char_num: begin scan_char_num; cur_chr:=cur_val;
      if check_echar_range(cur_chr) then
        begin ins_kp:=true; cur_l:=qi(0);
        end
      else cur_l:=qi(get_jfm_pos(KANJI(cur_chr),main_f));
      cur_cmd:=kcat_code(cur_chr);
      end;
    kchar_given: begin
      cur_l:=qi(get_jfm_pos(KANJI(cur_chr),main_f));
      cur_cmd:=kcat_code(cur_chr);
      end;
    kchar_num: begin scan_char_num; cur_chr:=cur_val;
      cur_l:=qi(get_jfm_pos(KANJI(cur_chr),main_f));
      cur_cmd:=kcat_code(cur_chr);
      end;
    inhibit_glue: begin inhibit_glue_flag:=(cur_chr=0); goto again_2; end;
    othercases begin ins_kp:=max_halfword;
      cur_l:=qi(-1); cur_r:=non_char; lig_stack:=null;
      end;
  endcases;
@#
main_loop_j+3:
  if ins_kp=true then @<Insert |pre_break_penalty| of |cur_chr|@>;
  if main_f<>null_font then
    begin @<Look ahead for glue or kerning@>;
    end
  else inhibit_glue_flag:=false;
  if ins_kp=false then begin { Kanji -> Kanji }
    goto main_loop_j+1;
  end else if ins_kp=true then begin { Kanji -> Ascii }
    {@@<Append |disp_node| at begin of displace area@@>;}
    ins_kp:=false; goto main_loop;
  end else begin { Kanji -> cs }
    {@@<Append |disp_node| at begin of displace area@@>;}
    goto reswitch;
  end;

@ @<Append |disp_node| at begin ...@>=
begin if not is_char_node(tail)and(type(tail)=disp_node) then
  begin if prev_disp=disp then
    begin free_node(tail,small_node_size); tail:=prev_node; link(tail):=null;
    end
  else disp_dimen(tail):=disp;
  end
else
  if disp<>0 or not disp_called then
    begin prev_node:=tail; tail_append(get_node(small_node_size));
    type(tail):=disp_node; disp_dimen(tail):=disp; prev_disp:=disp;
    disp_called:=true
    end;
end;

@ @<Append |disp_node| at end ...@>=
if disp<>0 then
begin if not is_char_node(tail)and(type(tail)=disp_node) then
  begin disp_dimen(tail):=0;
  end
else
  begin prev_node:=tail; tail_append(get_node(small_node_size));
  type(tail):=disp_node; disp_dimen(tail):=0; prev_disp:=disp;
  disp_called:=true
  end;
end;

@ @<Look ahead for glue or kerning@>=
cur_q:=tail;
if inhibit_glue_flag<>true then
  begin
  if cur_l<qi(0) then cur_l:=qi(0) else inhibit_glue_flag:=false;
  if (tail=link(head))and(not is_char_node(tail))and(type(tail)=disp_node) then
    goto skip_loop
  else begin if char_tag(main_i)=gk_tag then
    begin main_k:=glue_kern_start(main_f)(main_i);
    main_j:=font_info[main_k].qqqq;
    if skip_byte(main_j)>stop_flag then {huge glue/kern table rearranged}
      begin main_k:=glue_kern_restart(main_f)(main_j);
        main_j:=font_info[main_k].qqqq;
        end;
    loop@+begin if next_char(main_j)=cur_l then if skip_byte(main_j)<=stop_flag then
      begin if op_byte(main_j)<kern_flag then
        begin gp:=font_glue[main_f]; cur_r:=rem_byte(main_j);
        if gp<>null then
          begin while((type(gp)<>cur_r)and(link(gp)<>null)) do gp:=link(gp);
          gq:=glue_ptr(gp);
          end
        else
          begin gp:=get_node(small_node_size); font_glue[main_f]:=gp;
          gq:=null;
          end;
        if gq=null then
          begin type(gp):=cur_r; gq:=new_spec(zero_glue);
          glue_ptr(gp):=gq;
          main_k:=exten_base[main_f]+qi((qo(cur_r))*3);
          width(gq):=font_info[main_k].sc;
          stretch(gq):=font_info[main_k+1].sc;
          shrink(gq):=font_info[main_k+2].sc;
          add_glue_ref(gq); link(gp):=get_node(small_node_size);
          gp:=link(gp); glue_ptr(gp):=null; link(gp):=null;
          end;
        tail_append(new_glue(gq)); subtype(tail):=jfm_skip+1;
        goto skip_loop;
        end
      else  begin
        tail_append(new_kern(char_kern(main_f)(main_j)));
        goto skip_loop;
        end;
    end;
    if skip_byte(main_j)>=stop_flag then goto skip_loop;
    main_k:=main_k+qo(skip_byte(main_j))+1; {SKIP property}
    main_j:=font_info[main_k].qqqq;
    end;
  end;
  end;
end
else
  begin
  if cur_l<qi(0) then cur_l:=qi(0) else inhibit_glue_flag:=false;
  end;
skip_loop: do_nothing;

@ |print_kanji| and |print_utf8| prints a Unicode character.

@d print_kanji(#)==print_utf8_generic(#,@"100)
@d print_utf8(#)==print_utf8_generic(KANJI(#),0)

@<Basic printing...@>=
procedure print_utf8_generic(@!s:integer; @!f:integer); {prints a single character}
var i: integer;
begin
i:=s mod max_char_val;
if (i<@"20)or((i>=@"80)and(i<@"A0)) then print(i)
else begin s:=toBUFF(i);
  if BYTE1(s)<>0 then print_char(f+BYTE1(s));
  if BYTE2(s)<>0 then print_char(f+BYTE2(s));
  if BYTE3(s)<>0 then print_char(f+BYTE3(s));
                      print_char(f+BYTE4(s));
end;
end;

@ This procedure changes the direction of the page, if |page_contents|
is |empty| and ``recent contributions'' does not contain any boxes,
rules nor insertions.

@<Declare act...@>=
procedure change_page_direction(@!d: halfword);
label done;
var p: pointer; flag:boolean;
begin flag:=(page_contents=empty);
if flag and (head<>tail) then begin
  p:=link(head);
  while p<>null do
    case type(p) of
      hlist_node,vlist_node,dir_node,rule_node,ins_node:
        begin flag:=false; goto done; end;
      { |glue_node|, |kern_node|, |penalty_node| are discarded }
      othercases p:=link(p);
    endcases;
  done: do_nothing;
end;
if flag then begin direction:=d; page_dir:=d; end
else begin
  print_err("Use `"); print_cmd_chr(cur_cmd,d);
  print("' at top of the page");
  help3("You can change the direction of the page only when")
  ("the current page and recent contributions consist of only")
  ("marks and whatsits."); error;
  end;
end;

@ This procedure is used in printing the second line in showing contexts.
This part is not read by |get_next| yet, so we don't know which bytes
are part of Japaense characters when the procedure is called.

@<Basic printing...@>=
procedure print_unread_buffer_with_ptenc(@!f, @!l: integer);
{ print |buffer[f..l-1]| with code conversion }
var @!i,@!j: pool_pointer; @!p: integer;
begin
  i:=f;
  while i<l do begin
    p:=multistrlen(ustringcast(buffer), l, i);
    if p<>1 then
      begin for j:=i to i+p-1 do
        print_char(@"100+buffer[j]);
      i:=i+p; end
    else begin print(buffer[i]); incr(i); end;
  end;
end;

@ The \.{\\currentspacingmode} and \.{\\currentxspacingmode} commands
return the current \pTeX's status of \.{\\(no)autospacing} and
\.{\\(no)autoxspacing} respectively.

@d current_spacing_mode_code=eTeX_int+8 {code for \.{\\currentspacingmode}}
@d current_xspacing_mode_code=eTeX_int+9 {code for \.{\\currentxspacingmode}}

@<Generate all \eTeX...@>=
primitive("currentspacingmode",last_item,current_spacing_mode_code);
@!@:current_spacing_mode_}{\.{\\currentspacingmode} primitive@>
primitive("currentxspacingmode",last_item,current_xspacing_mode_code);
@!@:current_xspacing_mode_}{\.{\\currentxspacingmode} primitive@>

@ @<Cases of |last_item| for |print_cmd_chr|@>=
current_spacing_mode_code: print_esc("currentspacingmode");
current_xspacing_mode_code: print_esc("currentxspacingmode");

@ @<Cases for fetching an integer value@>=
current_spacing_mode_code: cur_val:=auto_spacing;
current_xspacing_mode_code: cur_val:=auto_xspacing;

@ The \.{\\currentcjktoken} command returns the current \upTeX's
status of \.{\\(disable|enable|force)cjktoken}.

@d current_cjk_token_code=eTeX_int+10 {code for \.{\\currentcjktoken}}

@<Generate all \eTeX...@>=
primitive("currentcjktoken",last_item,current_cjk_token_code);
@!@:current_cjk_token_}{\.{\\currentcjktoken} primitive@>

@ @<Cases of |last_item| for |print_cmd_chr|@>=
current_cjk_token_code: print_esc("currentcjktoken");

@ @<Cases for fetching an integer value@>=
current_cjk_token_code: cur_val:=enable_cjk_token;

@* \[54/pdf\TeX] System-dependent changes for {\tt\char"5Cpdfstrcmp}.
@d call_func(#) == begin if # <> 0 then do_nothing end
@d flushable(#) == (# = str_ptr - 1)

@<Glob...@>=
@!epochseconds: integer;
@!microseconds: integer;

@
@d max_integer == @"7FFFFFFF {$2^{31}-1$}

@<Declare procedures that need to be declared forward for \pdfTeX@>=
procedure pdf_error(t, p: str_number);
begin
    normalize_selector;
    print_err("pdfTeX error");
    if t <> 0 then begin
        print(" (");
        print(t);
        print(")");
    end;
    print(": "); print(p);
    succumb;
end;

function get_microinterval:integer;
var s,@!m:integer; {seconds and microseconds}
begin
   seconds_and_micros(s,m);
   if (s-epochseconds)>32767 then
     get_microinterval := max_integer
   else if (microseconds>m)  then
     get_microinterval := ((s-1-epochseconds)*65536)+ (((m+1000000-microseconds)/100)*65536)/10000
   else
     get_microinterval := ((s-epochseconds)*65536)  + (((m-microseconds)/100)*65536)/10000;
end;

@ @<Declare procedures needed in |do_ext...@>=

procedure compare_strings; {to implement \.{\\pdfstrcmp}}
label done;
var s1, s2: str_number;
    i1, i2, j1, j2: pool_pointer;
    c1, c2: integer;
    save_cur_cs: pointer;
begin
    save_cur_cs:=cur_cs; call_func(scan_toks(false, true));
    s1 := tokens_to_string(def_ref);
    delete_token_ref(def_ref);
    cur_cs:=save_cur_cs; call_func(scan_toks(false, true));
    s2 := tokens_to_string(def_ref);
    delete_token_ref(def_ref);
    i1 := str_start[s1];
    j1 := str_start[s1 + 1];
    i2 := str_start[s2];
    j2 := str_start[s2 + 1];
    while (i1 < j1) and (i2 < j2) do begin
        if str_pool[i1]>=@"100 then c1:=str_pool[i1]-@"100 else c1:=str_pool[i1];
        if str_pool[i2]>=@"100 then c2:=str_pool[i2]-@"100 else c2:=str_pool[i2];
        if c1<c2 then begin cur_val := -1; goto done; end
        else if c1>c2 then begin cur_val := 1; goto done; end;
        incr(i1);
        incr(i2);
    end;
    if (i1 = j1) and (i2 = j2) then
        cur_val := 0
    else if i1 < j1 then
        cur_val := 1
    else
        cur_val := -1;
done:
    flush_str(s2);
    flush_str(s1);
    cur_val_level := int_val;
end;

@ Next, we implement \.{\\pdfsavepos} and related primitives.

@<Glob...@>=
@!cur_page_width: scaled; {"physical" width of page being shipped}
@!cur_page_height: scaled; {"physical" height of page being shipped}
@!pdf_last_x_pos: integer;
@!pdf_last_y_pos: integer;

@ @<Implement \.{\\pdfsavepos}@>=
begin
    new_whatsit(pdf_save_pos_node, small_node_size);
    inhibit_glue_flag:=false;
end

@ @<Save current position in DVI mode@>=
begin
  case dvi_dir of
  dir_yoko: begin pdf_last_x_pos := cur_h;  pdf_last_y_pos := cur_v;  end;
  dir_tate: begin pdf_last_x_pos := -cur_v; pdf_last_y_pos := cur_h;  end;
  dir_dtou: begin pdf_last_x_pos := cur_v;  pdf_last_y_pos := -cur_h; end;
  endcases;
  pdf_last_x_pos := pdf_last_x_pos + 4736286;
  pdf_last_y_pos := cur_page_height - pdf_last_y_pos - 4736286;
  {4736286 = 1in, the funny DVI origin offset}
end

@ @<Calculate DVI page dimensions and margins@>=
  if pdf_page_height <> 0 then
    cur_page_height := pdf_page_height
  else if (box_dir(p)=dir_tate)or(box_dir(p)=dir_dtou) then
    cur_page_height := width(p) + 2*v_offset + 2*4736286
  else
    cur_page_height := height(p) + depth(p) + 2*v_offset + 2*4736286;
    {4736286 = 1in, the funny DVI origin offset}
  if pdf_page_width <> 0 then
    cur_page_width := pdf_page_width
  else if (box_dir(p)=dir_tate)or(box_dir(p)=dir_dtou) then
    cur_page_width := height(p) + depth(p) + 2*h_offset + 2*4736286
  else
    cur_page_width := width(p) + 2*h_offset + 2*4736286
    {4736286 = 1in, the funny DVI origin offset}


@ Of course \epTeX\ can produce a \.{DVI} file only, not a PDF file.
A \.{DVI} file does not have the information of the page height,
which is needed to implement \.{\\pdflastypos} correctly.
To keep the information of the page height, I (H.~Kitagawa)
adopted \.{\\pdfpageheight} primitive from pdf\TeX.

In \pTeX (and \hbox{\epTeX}), the papersize special
\.{\\special\{papersize=\<width>,\<height>\}} is commonly used
for specifying page width/height.
If \.{\\readpapersizespecial} is greater than~0, the papersize special also
changes the value of \.{\\pdfpagewidth} and \.{\\pdfpageheight}.
This process is done in the following routine.

{\def\<#1>{\langle\hbox{#1\/}\rangle}
In present implementation, the papersize special $\<special>$,
which can be interpreted by this routine, is defined as follows.
$$\eqalign{%
  \<special> &\longrightarrow \.{papersize=}\<length>\.{,}\<length>\cr
  \<length>  &\longrightarrow \<decimal>
    \<optional~\.{true}>\<physical unit>\cr
  \<decimal> &\longrightarrow \.{.} \mid \<digit>\<decimal> \mid
    \<decimal>\<digit>\cr
}$$}
Note that any space, ``\.{,}'' as a decimal separator, minus~symbol
are neither permitted.

@d ifps(#)==@+if k+(#)>pool_ptr then goto done @+ else @+ if
@d sop(#)==so(str_pool[#])
@f ifps==if

@<Determine whether this \.{\\special} is a papersize special@>=
begin k:=str_start[str_ptr];@/
ifps(10) @,
   (sop(k+0)<>'p')or(sop(k+1)<>'a')or(sop(k+2)<>'p')or
   (sop(k+3)<>'e')@|or(sop(k+4)<>'r')or(sop(k+5)<>'s')or
   (sop(k+6)<>'i')or(sop(k+7)<>'z')@|or(sop(k+8)<>'e')or
   (sop(k+9)<>'=')  then goto done;
k:=k+10;
@<Read dimensions in the argument in the papersize special@>;
ifps(1) @, sop(k)=',' then begin
  incr(k); cw:=s;
  @<Read dimensions in the argument in the papersize special@>;
  if pool_ptr>k then goto done;
  geq_word_define(dimen_base+pdf_page_width_code,cw);
  geq_word_define(dimen_base+pdf_page_height_code,s);@|
  cur_page_height := s; cur_page_width := cw;
end;
end;

@

@d if_ps_unit(#)==if bl then @+ begin @+ ifps(2) sop(k)=(#) @, if_ps_unit_two
@d if_ps_unit_two(#)==and (sop(k+1)=(#)) then begin bl:=false; k:=k+2; if_ps_unit_end
@d if_ps_unit_end(#)==# @+ end @+ end;

@d do_ps_conversion(#)==num:=#; do_ps_conversion_end
@d do_ps_conversion_end(#)==
  s:=xn_over_d(s,num,#); s:=s*unity+((num*t+@'200000*remainder) div #)

@<Read dimensions in the argument in the papersize special@>=
s:=0; t:=0; bl:=true;
while (k<pool_ptr)and bl do
  if (sop(k)>='0')and (sop(k)<='9') then begin s:=10*s+sop(k)-'0'; incr(k); @+end
  else bl:=false;
ifps(1) sop(k)='.' then
  begin incr(k); bl:=true; i:=0; dig[0]:=0;
  while (k<pool_ptr)and bl do begin
    if (sop(k)>='0')and (sop(k)<='9') then
      begin if i<17 then begin dig[i]:=sop(k)-'0'; incr(i); @+end;
      incr(k); end
    else bl:=false;
  end;
  t:=round_decimals(i);
  end;
if k+4>pool_ptr then
  if (sop(k)='t')and(sop(k+1)='r')and(sop(k+2)='u')and(sop(k+3)='e') then
    k:=k+4;
if mag<>1000 then
  begin s:=xn_over_d(s,1000,mag);
  t:=(1000*t+@'200000*remainder) div mag;
  s:=s+(t div @'200000); t:=t mod @'200000;
end;
bl:=true;@/
if_ps_unit('p')('t')(s:=s*unity+t)@/
if_ps_unit('i')('n')(do_ps_conversion(7227)(100))@/
if_ps_unit('p')('c')(do_ps_conversion(12)(1))@/
if_ps_unit('c')('m')(do_ps_conversion(7227)(254))@/
if_ps_unit('m')('m')(do_ps_conversion(7227)(2540))@/
if_ps_unit('b')('p')(do_ps_conversion(7227)(7200))@/
if_ps_unit('d')('d')(do_ps_conversion(1238)(1157))@/
if_ps_unit('c')('c')(do_ps_conversion(14856)(1157))@/
if_ps_unit('s')('p')(do_nothing)

@ Finally, we declare some routine needed for \.{\\pdffilemoddate}.

@<Glob...@>=
@!last_tokens_string: str_number; {the number of the most recently string
created by |tokens_to_string|}

@ @<Declare procedures needed in |do_ext...@>=
procedure scan_pdf_ext_toks;
begin
    call_func(scan_toks(false, true)); {like \.{\\special}}
end;

@ @<Declare procedures that need to be declared forward for \pdfTeX@>=
function tokens_to_string(p: pointer): str_number; {return a string from tokens
list}
begin
    if selector = new_string then
        pdf_error("tokens", "tokens_to_string() called while selector = new_string");
    old_setting:=selector; selector:=new_string;
    show_token_list(link(p),null,pool_size-pool_ptr);
    selector:=old_setting;
    last_tokens_string := make_string;
    tokens_to_string := last_tokens_string;
end;
procedure flush_str(s: str_number); {flush a string if possible}
begin
    if flushable(s) then
        flush_string;
end;

@ @<Set initial values of key variables@>=
  seconds_and_micros(epochseconds,microseconds);
  init_start_time;

@ Negative random seed values are silently converted to positive ones

@<Implement \.{\\pdfsetrandomseed}@>=
begin
  scan_int;
  if cur_val<0 then negate(cur_val);
  random_seed := cur_val;
  init_randoms(random_seed);
end

@ @<Implement \.{\\pdfresettimer}@>=
begin
  seconds_and_micros(epochseconds,microseconds);
end

@ \.{\\nptexnoderecipe}.
@<Cases of |assign_toks| for |print_cmd_chr|@>=
node_recipe_loc: print_esc("nptexnoderecipe");

@* \[54] System-dependent changes.
@z


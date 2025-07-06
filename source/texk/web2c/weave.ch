% weave.ch for C compilation using web2c.
%
%  11/29/82 HWT Original version. This modifies weave to allow a new
%               control sequence:
%                       @=...text...@>   Put ...text... verbatim on a line
%                                        by itself in the Pascal output.
%                                        (argument must fit on one line)
%               This control sequence facilitates putting #include "gcons.h"
%               (for example) in files meant for the pc compiler.
%               Also, there is a command line option, -c, which means that
%               only the modules affected by the change file are to generate
%               TeX output.  (All the limbo stuff still goes to the output
%               file, as does the index and table of contents.)
%  2/12/83 HWT  Brought up for use with version 1.3.  Uses Knuth's new
%               control sequences for verbatim Pascal (as above, without
%               the "on one line" part), and the force_line (@\) primitive.
%               Also, he added stuff to keep track of changed modules, and
%               output enough information that macros can choose only to
%               print changed modules.  This isn't as efficient as my
%               implementation because I avoided outputting the text for
%               non-changed modules altogether, but this feature won't be
%               used too often (just for TeX and TeXware), so Knuth's
%               solution is accepted.
%               The change file changes that used
%               to implement these features have been removed.
%               There is a -x flag to cause WEAVE to omit cross referencing
%               of identifiers, and index and T.of.C. processing.
%               This, too, is unnecessary, for one could simply redefine some
%               WEB macros to avoid the printing, but there are only a couple
%               of easy changes, so they have been made.
%  2/18     HWT Increased stack size to 400 (not for TeX-related programs).
%  3/18     HWT Brought up for Version 1.5.  Made it print newline at end of
%               run.
%  4/13     PC  Merged with Pavel's version, including adding a call to
%               exit() at the end of the program, based upon the value of
%               `history'.
%  4/16     PC  Brought up to version 1.5 released with TeX 0.97 in April 1983
%  6/29     HWT Brought up to version 1.7 released with TeX 0.99 in June 1983,
%		introducing a new change file format
%  7/17	    HWT Brought up to version 2.0 released with TeX 0.999 in July 1983
%  7/29     HWT Brought up to version 2.1
% 11/17     HWT Brought up to version 2.4 released with TeX 1.0.  Made
%		changes to use C routines for I/O, for speedup.
%  1/31     HWT Brought up to version 2.6
%  12/15/85 ETM Brought up to version 2.8
%  03/15/88 ETM Converted for use with WEB to C, and for version 2.9 of Weave.
%  11/30/89 KB  Version 4.
% (more recent changes in the ChangeLog)

@x [0.0] l.43 - WEAVE: print changes only
\def\title{WEAVE}
@y
\let\maybe=\iffalse
\def\title{WEAVE changes for C}
@z

@x [1.1] l.77 - Define my_name
@d banner=='This is WEAVE, Version 4.5'
@y
@d my_name=='weave'
@d banner=='This is WEAVE, Version 4.5'
@z

@x [1.2] l.85 - No global labels, define and call parse_arguments.
calls the `|jump_out|' procedure, which goes to the label |end_of_WEAVE|.

@d end_of_WEAVE = 9999 {go here to wrap it up}
@y
calls the `|jump_out|' procedure.
@z
@x [1.2] l.91
label end_of_WEAVE; {go here to finish}
const @<Constants in the outer block@>@/
type @<Types in the outer block@>@/
var @<Globals in the outer block@>@/
@<Error handling procedures@>@/
procedure initialize;
  var @<Local variables for initialization@>@/
  begin @<Set initial values@>@/
@y
const @<Constants in the outer block@>@/
type @<Types in the outer block@>@/
var @<Globals in the outer block@>@/
@<Define \(|parse_arguments|@>@/
@<Error handling procedures@>@/
procedure initialize;
  var @<Local variables for initialization@>@/
  begin
    kpse_set_program_name (argv[0], my_name);
    parse_arguments;
    @<Set initial values@>@/
@z

@x [1.8] l.186 - Increase constants for tex2pdf, etc.
@!max_bytes=45000; {|1/ww| times the number of bytes in identifiers,
  index entries, and module names; must be less than 65536}
@!max_names=5000; {number of identifiers, index entries, and module names;
  must be less than 10240}
@y
@!max_bytes=65535; {|1/ww| times the number of bytes in identifiers,
  index entries, and module names; must be less than 65536}
@!max_names=10239; {number of identifiers, index entries, and module names;
  must be less than 10240}
@z
@x [1.8] l.190
@!max_modules=2000;{greater than the total number of modules}
@!hash_size=353; {should be prime}
@!buf_size=100; {maximum length of input line}
@!longest_name=400; {module names shouldn't be longer than this}
@!long_buf_size=500; {|buf_size+longest_name|}
@!line_length=80; {lines of \TeX\ output have at most this many characters,
@y
@!max_modules=4000; {greater than the total number of modules}
@!hash_size=8501; {should be prime}
@!buf_size=1000; {maximum length of input line}
@!longest_name=10000; {module names shouldn't be longer than this}
@!long_buf_size=buf_size+longest_name; {C arithmetic in \PASCAL\ constant}
@!line_length=80; {lines of \TeX\ output have at most this many characters,
@z
@x [1.8] l.197
@!max_refs=30000; {number of cross references; must be less than 65536}
@!max_toks=30000; {number of symbols in \PASCAL\ texts being parsed;
  must be less than 65536}
@!max_texts=2000; {number of phrases in \PASCAL\ texts being parsed;
  must be less than 10240}
@!max_scraps=1000; {number of tokens in \PASCAL\ texts being parsed}
@!stack_size=200; {number of simultaneous output levels}
@y
@!max_refs=65535; {number of cross references; must be less than 65536}
@!max_toks=65535; {number of symbols in \PASCAL\ texts being parsed;
  must be less than 65536}
@!max_texts=10239; {number of phrases in \PASCAL\ texts being parsed;
  must be less than 10240}
@!max_scraps=10000; {number of tokens in \PASCAL\ texts being parsed}
@!stack_size=2000; {number of simultaneous output levels}
@z

% [12] The text_char type is used as an array index into xord.  The
% default type `char' produces signed integers, which are bad array
% indices in C.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
@x [2.12] l.307
@d text_char == char {the data type of characters in text files}
@y
@d text_char == ASCII_code {the data type of characters in text files}
@z

@x [2.17] l.488 - enable maximum character set
for i:=1 to @'37 do xchr[i]:=' ';
for i:=@'200 to @'377 do xchr[i]:=' ';
@y
for i:=1 to @'37 do xchr[i]:=chr(i);
for i:=@'200 to @'377 do xchr[i]:=chr(i);
@z

@x [3.20] l.514 - Terminal I/O.
@d print(#)==write(term_out,#) {`|print|' means write on the terminal}
@y
@d term_out==stdout
@d print(#)==write(term_out,#) {`|print|' means write on the terminal}
@z
@x [3.20] l.521
@<Globals...@>=
@!term_out:text_file; {the terminal as an output file}
@y
@z

@x [3.21] l.524 - Don't initialize the terminal.
@ Different systems have different ways of specifying that the output on a
certain file will appear on the user's terminal. Here is one way to do this
on the \PASCAL\ system that was used in \.{TANGLE}'s initial development:
@^system dependencies@>

@<Set init...@>=
rewrite(term_out,'TTY:'); {send |term_out| output to the terminal}
@y
@ Different systems have different ways of specifying that the output on a
certain file will appear on the user's terminal.
@^system dependencies@>

@<Set init...@>=
{nothing need be done}
@z

@x [3.22] l.537 - `break' is `fflush'.
@d update_terminal == break(term_out) {empty the terminal output buffer}
@y
@d update_terminal == fflush(term_out) {empty the terminal output buffer}
@z

@x [3.24] l.546 - Open input files.
@ The following code opens the input files.  Since these files were listed
in the program header, we assume that the \PASCAL\ runtime system has
already checked that suitable file names have been given; therefore no
additional error checking needs to be done. We will see below that
\.{WEAVE} reads through the entire input twice.
@^system dependencies@>

@p procedure open_input; {prepare to read |web_file| and |change_file|}
begin reset(web_file); reset(change_file);
end;
@y
@ The following code opens the input files.
This is called after the filename variables have been set appropriately.
@^system dependencies@>

@p procedure open_input; {prepare to read |web_file| and |change_file|}
begin web_file := kpse_open_file(web_name, kpse_web_format);
  if chg_name then change_file := kpse_open_file(chg_name, kpse_web_format);
end;
@z

@x [3.26] l.569 - Opening the .tex file.
rewrite(tex_file);
@y
rewrite(tex_file,tex_name);
@z

@x [3.28] l.597 - web2c doesn't understand f^.
    begin buffer[limit]:=xord[f^]; get(f);
    incr(limit);
    if buffer[limit-1]<>" " then final_limit:=limit;
    if limit=buf_size then
      begin while not eoln(f) do get(f);
@y
    begin buffer[limit]:=xord[getc(f)];
    incr(limit);
    if buffer[limit-1]<>" " then final_limit:=limit;
    if limit=buf_size then
      begin while not eoln(f) do vgetc(f);
@z

@x [4.33] l.678 - Fix jump_out
@ The |jump_out| procedure just cuts across all active procedure levels
and jumps out of the program. This is the only non-local \&{goto} statement
in \.{WEAVE}. It is used when no recovery from a particular error has
been provided.

Some \PASCAL\ compilers do not implement non-local |goto| statements.
@^system dependencies@>
In such cases the code that appears at label |end_of_WEAVE| should be
copied into the |jump_out| procedure, followed by a call to a system procedure
that terminates the program.
@y
@ The |jump_out| procedure just cuts across all active procedure levels
and jumps out of the program.
It is used when no recovery from a particular error has
been provided.
@z
@x [4.33] l.689
@d fatal_error(#)==begin new_line; print(#); error; mark_fatal; jump_out;
  end

@<Error handling...@>=
procedure jump_out;
begin goto end_of_WEAVE;
end;
@y
@d fatal_error(#)==begin new_line; write(stderr, #);
     error; mark_fatal; jump_out;
	end

@<Error handling...@>=
procedure jump_out;
begin
stat @<Print statistics about memory usage@>;@+tats@;@/
@t\4\4@>{here files should be closed if the operating system requires it}
  @<Print the job |history|@>;
  new_line;
  if (history <> spotless) and (history <> harmless_message) then
    uexit(1)
  else
    uexit(0);
end;
@z

@x [5.37] l.726 - extend 'byte_mem' for "pdftex.web + pdftex-final.ch"
there are programs that need more than 65536 bytes; \TeX\ is one of these.
@y
there are programs that need more than 65536 bytes; \TeX\ is one of these
(and the pdf\TeX\ variant even requires more than twice that amount when
its ``final'' change file is applied).
@z
@x [5.37] l.729
is either 0 or 1. (For generality, the first index is actually allowed to
run between 0 and |ww-1|, where |ww| is defined to be 2; the program will
@y
is either 0, 1 or 2. (For generality, the first index is actually allowed to
run between 0 and |ww-1|, where |ww| is defined to be 3; the program will
@z
@x [5.37] l.734
@d ww=2 {we multiply the byte capacity by approximately this amount}
@y
@d ww=3 {we multiply the byte capacity by approximately this amount}
@z

@x [5.50] l.910 - don't enter xrefs if no_xref set
@d append_xref(#)==if xref_ptr=max_refs then overflow('cross reference')
  else  begin incr(xref_ptr); num(xref_ptr):=#;
    end

@p procedure new_xref(@!p:name_pointer);
label exit;
var q:xref_number; {pointer to previous cross reference}
@!m,@!n: sixteen_bits; {new and previous cross-reference value}
begin if (reserved(p)or(byte_start[p]+1=byte_start[p+ww]))and
@y
If the user has sent the |no_xref| flag (the `\.{-x}' option of the
command line), then it is unnecessary to keep track of cross references
for identifiers.
If one were careful, one could probably make more changes around module
100 to avoid a lot of identifier looking up.

@d append_xref(#)==if xref_ptr=max_refs then overflow('cross reference')
  else  begin incr(xref_ptr); num(xref_ptr):=#;
    end

@p procedure new_xref(@!p:name_pointer);
label exit;
var q:xref_number; {pointer to previous cross-reference}
@!m,@!n: sixteen_bits; {new and previous cross-reference value}
begin if no_xref then return;
if (reserved(p)or(byte_start[p]+1=byte_start[p+ww]))and
@z

@x [9.82] l.1448 - Guard against get_line() when parsing a module name
@p procedure get_line; {inputs the next line}
label restart;
begin restart:if changing then
  @<Read from |change_file| and maybe turn off |changing|@>;
if not changing then
  begin @<Read from |web_file| and maybe turn on |changing|@>;
  if changing then goto restart;
  end;
loc:=0; buffer[limit]:=" ";
end;
@y
@p procedure get_line; {inputs the next line}
label restart;
begin
  if in_module_name then begin
    err_print('! Call to get_line when parsing a module name');
    loc:=limit; {Reset to the |'|'| at the end of the line}
  end else
begin restart:if changing then
  @<Read from |change_file| and maybe turn off |changing|@>;
if not changing then
  begin @<Read from |web_file| and maybe turn on |changing|@>;
  if changing then goto restart;
  end;
loc:=0; buffer[limit]:=" ";
end;
end;
@z

@x [12.124] l.2199
`\.{\\input webmac}'.
@.\\input webmac@>
@.webmac@>
@y
`\.{\\input webmac}'.
@.\\input webmac@>
@.webmac@>

If the user has sent the |pdf_output| flag (the `\.{-p}' option of the
command line), then we use alternative \TeX\ macros from `\.{\\input pwebmac}'.
@.\\input pwebmac@>
@.pwebmac@>
@z
@x [12.124] l.2204
out_ptr:=1; out_line:=1; out_buf[1]:="c"; write(tex_file,'\input webma');
@y
out_ptr:=1; out_line:=1; out_buf[1]:="c";
if pdf_output then write(tex_file,'\input pwebma')
else write(tex_file,'\input webma');
@z

@x [12.127] l.2234 - see https://tug.org/pipermail/tex-live/2023-July/049306.htm
preceded by another backslash. In the latter case, a |"%"| is output at
the break.
@y
preceded by another backslash or a \TeX\ comment marker. In the latter case, a
|'%'| is output at the break.
@z
@x [12.127] l.2248 - deal with malign user input
  if (d="\")and(out_buf[k-1]<>"\") then {in this case |k>1|}
@y
  if (d="\")and(out_buf[k-1]<>"\")and(out_buf[k-1]<>"%") then
    {in this case |k>1|}
@z

@x [15.148] l.3007 - Purify 'reduce' and 'squash'.
@d production(#)==@!debug prod(#) gubed; goto found
@d reduce(#)==red(#); production
@d production_end(#)==@!debug prod(#) gubed; goto found;
  end
@d squash(#)==begin sq(#); production_end
@y
@d production(#)==@!debug prod(#) gubed; goto found; end
@d reduce(#)==begin red(#); production
@d squash(#)==begin sq(#); production
@z

@x [15.151] l.3100 - Special case 'k=0'.
else if cat[pp+1]=simp then squash(pp+1,1,math,0)(4)
@y
else if cat[pp+1]=simp then reduce(pp+1,0,math,0)(4)
@z

@x [15.157] l.3151 - Special case 'k=0'.
squash(pp,1,intro,-3)(14)
@y
reduce(pp,0,intro,-3)(14)
@z

@x [15.161] l.3193 - Special case 'k=0'.
else squash(pp,1,simp,-2)(25)
@y
else reduce(pp,0,simp,-2)(25)
@z

@x [15.162] l.3212 - Special case 'k=0'.
else if cat[pp+1]=simp then squash(pp+1,1,math,0)(35)
@y
else if cat[pp+1]=simp then reduce(pp+1,0,math,0)(35)
@z

@x [15.166] l.3272 - Special case 'k=0'.
squash(pp,1,terminator,-3)(42)
@y
reduce(pp,0,terminator,-3)(42)
@z

@x [15.167] l.3275 - Special case 'k=0'.
if cat[pp+1]=close then squash(pp,1,stmt,-2)(43)
@y
if cat[pp+1]=close then reduce(pp,0,stmt,-2)(43)
@z
@x [15.167] l.3277 - Apply 'squash(...,2,...)'.
  begin app(force); app(backup); app2(pp); reduce(pp,2,intro,-3)(44);
@y
  begin app(force); app(backup); squash(pp,2,intro,-3)(44);
@z

@x [15.169] l.3291 - Special case 'k=0'.
squash(pp,1,stmt,-2)(50)
@y
reduce(pp,0,stmt,-2)(50)
@z

@x [15.170] l.3294 - Special case 'k=0'.
if cat[pp+1]=beginning then squash(pp,1,stmt,-2)(51)
@y
if cat[pp+1]=beginning then reduce(pp,0,stmt,-2)(51)
@z

@x [15.172] l.3325 - Move special case 'k=1' from 'squash' to special case 'k=0' here.
scrap list.
@y
scrap list.  This procedure takes advantage of the simplification that
occurs when |k=0|.
@z
@x [15.172] l.3330
begin cat[j]:=c; trans[j]:=text_ptr; freeze_text;
@y
begin cat[j]:=c;
if k>0 then
  begin
    trans[j]:=text_ptr; freeze_text;
  end;
@z
@x [15.172] l.3337 - Fix spacing.
@<Change |pp| to $\max(|scrap_base|,|pp+d|)$@>;
@y
@<Change |pp| to $\max(|scrap_base|,\,|pp+d|)$@>;
@z

@x [15.173] l.3340 - Fix spacing.
@ @<Change |pp| to $\max(|scrap_base|,|pp+d|)$@>=
@y
@ @<Change |pp| to $\max(|scrap_base|,\,|pp+d|)$@>=
@z

@x [15.174] l.3344 - Rewrite 'squash' to match description in section [148].
@ Similarly, the `|squash|' macro invokes a procedure called `|sq|'. This
procedure takes advantage of the simplification that occurs when |k=1|.
@y
@ Similarly, the `|squash|' macro invokes a procedure called `|sq|', which
combines |app|${}_k$ and |red| for matching numbers~|k|.
@z
@x [15.174] l.3349
var i:0..max_scraps; {index into scrap memory}
begin if k=1 then
  begin cat[j]:=c; @<Change |pp|...@>;
  end
else  begin for i:=j to j+k-1 do
    begin app1(i);
    end;
  red(j,k,c,d);
  end;
@y
begin
  case k of
  1: begin app1(j);@+ end;
  2: begin app2(j);@+ end;
  3: begin app3(j);@+ end;
  othercases confusion('squash')
  endcases;@/
  red(j,k,c,d);
@z

@x [16.185] l.3555
string,verbatim: @<Append a \(string scrap@>;
identifier: @<Append an identifier scrap@>;
TeX_string: @<Append a \TeX\ string scrap@>;
@y
string,verbatim: @<Append \(a \(string scrap@>;
identifier: @<Append \(an identifier scrap@>;
TeX_string: @<Append \(a \TeX\ string scrap@>;
@z

@x [16.189] l.3652
@<Append a \(string scrap@>=
@y
@<Append \(a \(string scrap@>=
@z

@x [16.190] l.3690
@ @<Append a \TeX\ string scrap@>=
@y
@ @<Append \(a \TeX\ string scrap@>=
@z

@x [16.191] l.3697
@ @<Append an identifier scrap@>=
@y
@ @<Append \(an identifier scrap@>=
@z

@x [16.193] l.3731
else_like: begin @<Append |terminator| if not already present@>;
@y
else_like: begin @<Append \(|terminator| if not already present@>;
@z
@x [16.193] l.3734
end_like: begin @<Append |term...@>;
@y
end_like: begin @<Append \(|term...@>;
@z
@x [16.193] l.3752
until_like: begin @<Append |term...@>;
@y
until_like: begin @<Append \(|term...@>;
@z

@x [16.194] l.3762
@<Append |termin...@>=
@y
@<Append \(|termin...@>=
@z

@x [17.202] l.3913 - Guard against get_line() while parsing module name
@ @d cur_end==cur_state.end_field {current ending location in |tok_mem|}
@y
@ The module name Pascal parser re-uses the buffer and |get_next|
infrastructure. However we don't want |get_next| to cause the next source line
to be read with |get_line|, so we set a flag to trigger an error and recover if
this happens.

@d cur_end==cur_state.end_field {current ending location in |tok_mem|}
@z
@x [17.202] l.3919 - Guard against get_line() while parsing module name
@!cur_state:output_state; {|cur_end|, |cur_tok|, |cur_mode|}
@y
@!in_module_name:boolean; {are we scanning a module name?}
@!cur_state:output_state; {|cur_end|, |cur_tok|, |cur_mode|}
@z

@x [17.203] l.3925 - Guard against get_line() while parsing module name
@ @<Set init...@>=stat max_stack_ptr:=0;@+tats
@y
@ @<Set init...@>=@!in_module_name:=false;
stat max_stack_ptr:=0;@+tats
@z

@x [17.214] l.4170 - Guard against get_line() while parsing module name
    buffer[limit]:="|"; output_Pascal;
@y
    buffer[limit]:="|";
    in_module_name:=true; output_Pascal; in_module_name:=false;
@z

@x [18.222] l.4285 - Reject verbatim in TeX part
TeX_string,xref_roman,xref_wildcard,xref_typewriter,module_name:
  begin loc:=loc-2; next_control:=get_next; {skip to \.{@@>}}
  if next_control=TeX_string then
    err_print('! TeX string should be in Pascal text only');
@.TeX string should be...@>
  end;
@y
TeX_string,xref_roman,xref_wildcard,xref_typewriter,module_name,verbatim:
  begin loc:=loc-2; next_control:=get_next; {skip to \.{@@>}}
  if next_control=TeX_string then
    err_print('! TeX string should be in Pascal text only')
@.TeX string should be...@>
  else if next_control=verbatim then
    err_print('! Verbatim string should be in Pascal text only');
@.Verbatim string should be...@>
  end;
@z

@x [19.239] l.4537 - omit index and module names if no_xref set
@<Phase III: Output the cross-reference index@>=
@y
If the user has set the |no_xref| flag (the `\.{-x} option on the
command line), just finish off the page, omitting the index, module
name list, and table of contents.

@<Phase III: Output the cross-reference index@>=
if no_xref then begin
        finish_line;
        out("\"); out5("v")("f")("i")("l")("l");
        out4("\")("e")("n")("d");
        finish_line;
        end
else begin
@z
@x [19.239] l.4551
print('Done.');
@y
end;
print('Done.');
@z

@x [20.258] l.4782 - term_in == stdin, when debugging.
any error stop will set |debug_cycle| to zero.
@y
any error stop will set |debug_cycle| to zero.

@d term_in==stdin
@z
@x [20.258] l.4790
@!term_in:text_file; {the user's terminal as an input file}
@y
@z

@x [20.259] l.4798 - Take out reset(term_in)
reset(term_in,'TTY:','/I'); {open |term_in| as the terminal, don't do a |get|}
@y
@z

@x [21.261] l.4851 - print newline at end of run and exit based upon value of history
print_ln(banner); {print a ``banner line''}
@y
print (banner); {print a ``banner line''}
print_ln (version_string);
@z
@x [21.261] l.4856
end_of_WEAVE:
stat @<Print statistics about memory usage@>;@+tats@;@/
@t\4\4@>{here files should be closed if the operating system requires it}
@<Print the job |history|@>;
end.
@y
jump_out;
end.
@z

@x [22.264] l.4886 - System-dependent changes.
This module should be replaced, if necessary, by changes to the program
that are necessary to make \.{WEAVE} work at a particular installation.
It is usually best to design your change file so that all changes to
previous modules preserve the module numbering; then everybody's version
will be consistent with the printed program. More extensive changes,
which introduce new modules, can be inserted here; then only the index
itself will get a new module number.
@^system dependencies@>
@y
Parse a Unix-style command line.

@d argument_is (#) == (strcmp (long_options[option_index].name, #) = 0)

@<Define \(|parse_arguments|@> =
procedure parse_arguments;
const n_options = 4; {Pascal won't count array lengths for us.}
var @!long_options: array[0..n_options] of getopt_struct;
    @!getopt_return_val: integer;
    @!option_index: c_int_type;
    @!current_option: 0..n_options;
begin
  @<Define the option table@>;
  repeat
    getopt_return_val := getopt_long_only (argc, argv, '', long_options,
                                           address_of (option_index));
    if getopt_return_val = -1 then begin
      do_nothing; {End of arguments; we exit the loop below.}

    end else if getopt_return_val = "?" then begin
      usage (my_name);

    end else if argument_is ('help') then begin
      usage_help (WEAVE_HELP, nil);

    end else if argument_is ('version') then begin
      print_version_and_exit (banner, nil, 'D.E. Knuth', nil);

    end; {Else it was a flag; |getopt| has already done the assignment.}
  until getopt_return_val = -1;

  {Now |optind| is the index of first non-option on the command line.}
  if (optind + 1 > argc) or (optind + 3 < argc) then begin
    write_ln (stderr, my_name, ': Need one to three file arguments.');
    usage (my_name);
  end;

  {Supply |".web"| and |".ch"| extensions if necessary.}
  web_name := extend_filename (cmdline (optind), 'web');
  if optind + 2 <= argc then begin
    if strcmp(char_to_string('-'), cmdline (optind + 1)) <> 0 then
      chg_name := extend_filename (cmdline (optind + 1), 'ch');
  end;

  {Change |".web"| to |".tex"| and use the current directory.}
  if optind + 3 = argc then
    tex_name := extend_filename (cmdline (optind + 2), 'tex')
  else
    tex_name := basename_change_suffix (web_name, '.web', '.tex');
end;

@ Here are the options we allow.  The first is one of the standard GNU options.
@.-help@>

@<Define the option...@> =
current_option := 0;
long_options[current_option].name := 'help';
long_options[current_option].has_arg := 0;
long_options[current_option].flag := 0;
long_options[current_option].val := 0;
incr (current_option);

@ Another of the standard options.
@.-version@>

@<Define the option...@> =
long_options[current_option].name := 'version';
long_options[current_option].has_arg := 0;
long_options[current_option].flag := 0;
long_options[current_option].val := 0;
incr (current_option);

@ Use alternative \TeX\ macros more suited for {\mc PDF} output?
@.-p@>

@<Define the option...@> =
long_options[current_option].name := char_to_string ('p');
long_options[current_option].has_arg := 0;
long_options[current_option].flag := address_of (pdf_output);
long_options[current_option].val := 1;
incr (current_option);

@ Omit cross-referencing?
@.-x@>

@<Define the option...@> =
long_options[current_option].name := char_to_string ('x');
long_options[current_option].has_arg := 0;
long_options[current_option].flag := address_of (no_xref);
long_options[current_option].val := 1;
incr (current_option);

@ @<Global...@> =
@!no_xref:c_int_type;
@!pdf_output:c_int_type;

@ An element with all zeros always ends the list.

@<Define the option...@> =
long_options[current_option].name := 0;
long_options[current_option].has_arg := 0;
long_options[current_option].flag := 0;
long_options[current_option].val := 0;

@ Global filenames.

@<Global...@> =
@!web_name,@!chg_name,@!tex_name:const_c_string;
@z

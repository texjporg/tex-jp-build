% vftovp.ch for C compilation with web2c.
% Written by kb@cs.umb.edu.
% This file is in the public domain.

@x [0] l.18
\def\title{VF\lowercase{to}VP}
@y
\def\title{VF$\,$\lowercase{to}$\,$VP changes for C}
@z

@x [0] WEAVE: print changes only.
\pageno=\contentspagenumber \advance\pageno by 1
@y
\pageno=\contentspagenumber \advance\pageno by 1
\let\maybe=\iffalse
@z

@x [1] Define my_name
@d banner=='This is VFtoVP, Version 1.4' {printed when the program starts}
@y
@d my_name=='vftovp'
@d banner=='This is VFtoVP, Version 1.4' {printed when the program starts}
@z

@x [2] All terminal output goes to stderr, so we can dump the vpl on stdout.
@d print(#)==write(#)
@d print_ln(#)==write_ln(#)
@y
@d print(#)==write(stderr,#)
@d print_ln(#)==write_ln(stderr,#)
@d print_real(#)==fprint_real(stderr,#)
@z

% [2] We need to tell web2c about one special variable.
% Perhaps it would be better to allow @define's
% anywhere in a source file, but that seemed just as painful as this.
@x [2]
@p program VFtoVP(@!vf_file,@!tfm_file,@!vpl_file,@!output);
@y
@p
{Tangle doesn't recognize @@ when it's right after the \.=.}
@\@= @@define var tfm;@>@\

program VFtoVP(@!vf_file,@!tfm_file,@!vpl_file,@!output);
@z

@x still [2] Set up for path reading.
procedure initialize; {this procedure gets things started properly}
  var @!k:integer; {all-purpose index for initialization}
  begin print_ln(banner);@/
@y
@<Define \(p)|parse_arguments|@>
procedure initialize; {this procedure gets things started properly}
  var @!k:integer; {all-purpose index for initialization}
  begin
    kpse_set_program_name (argv[0], my_name);
    kpse_init_prog ('VFTOVP', 0, nil, nil);
    {We |xrealloc| when we know how big the file is.  The 1000 comes
     from the negative lower bound.}
    tfm_file_array := xmalloc_array (byte, 1002);
    parse_arguments;
@z

% [4] No name_length.
% Also, AIX defines `class' in <math.h>, so let's take this opportunity to
% define that away.
% And increase several constants.
@x [4]
@<Constants...@>=
@!tfm_size=30000; {maximum length of |tfm| data, in bytes}
@!vf_size=10000; {maximum length of |vf| data, in bytes}
@!max_fonts=300; {maximum number of local fonts in the |vf| file}
@!lig_size=5000; {maximum length of |lig_kern| program, in words}
@!hash_size=5003; {preferably a prime number, a bit larger than the number
  of character pairs in lig/kern steps}
@!name_length=50; {a file name shouldn't be longer than this}
@!max_stack=50; {maximum depth of \.{DVI} stack in character packets}
@y
@d class == class_var
@<Constants...@>=
@!vf_size=100000; {maximum length of |vf| data, in bytes}
@!max_fonts=300; {maximum number of local fonts in the |vf| file}
@!lig_size=32510; {maximum length of |lig_kern| program, in words}
@!hash_size=32579; {preferably a prime number, a bit larger than the number
  of character pairs in lig/kern steps}
@!max_stack=100; {maximum depth of \.{DVI} stack in character packets}
@z

@x [11] Open the files.
@ On some systems you may have to do something special to read a
packed file of bytes. For example, the following code didn't work
when it was first tried at Stanford, because packed files have to be
opened with a special switch setting on the \PASCAL\ that was used.
@^system dependencies@>

@<Set init...@>=
reset(tfm_file); reset(vf_file);
@y
@ We don't have to do anything special to read a packed file of bytes,
but we do want to use environment variables to find the input files.
@^system dependencies@>

@<Set init...@>=
{See comments at |kpse_find_vf| in \.{kpathsea/tex-file.h} for why we
 don't use it.}
vf_file := kpse_open_file (vf_name, kpse_vf_format);
tfm_file := kpse_open_file (tfm_name, kpse_tfm_format);

if verbose then begin
  print (banner);
  print_ln (version_string);
end;
@z

@x [21] Open VPL file.
@ @<Set init...@>=
rewrite(vpl_file);
@y
@ If an explicit filename isn't given, we write to |stdout|.

@<Set init...@>=
if optind + 3 > argc then begin
  vpl_file := stdout;
end else begin
  vpl_name := extend_filename (cmdline (optind + 2), 'vpl');
  rewrite (vpl_file, vpl_name);
end;
@z

@x [22] `index' is not a good choice of identifier in C.
@<Types...@>=
@!index=0..tfm_size; {address of a byte in |tfm|}
@y
@d index == index_type

@<Types...@>=
@!index=integer; {address of a byte in |tfm|}
@z

@x [23] Make |tfm| be dynamically allocated.
@!tfm:array [-1000..tfm_size] of byte; {the \.{TFM} input data all goes here}
@y
{Kludge here to define |tfm| as a macro which takes care of the negative
 lower bound.  We've defined |tfm| for the benefit of web2c above.}
@=#define tfm (tfmfilearray + 1001);@>@\
@!tfm_file_array: ^byte; {the input data all goes here}
@z

@x [24] abort() should cause a bad exit code.
@d abort(#)==begin print_ln(#);
  print_ln('Sorry, but I can''t go on; are you sure this is a TFM?');
  goto final_end;
  end
@y
@d abort(#)==begin print_ln(#);
  print_ln('Sorry, but I can''t go on; are you sure this is a TFM?');
  uexit(1);
  end
@z

@x [24] Allow arbitrarily large input files.
if 4*lf-1>tfm_size then abort('The file is bigger than I can handle!');
@.The file is bigger...@>
@y
tfm_file_array := xrealloc_array (tfm_file_array, byte, 4 * lf + 1000);
@z

@x [31] Ditto for vf_abort.
@d vf_abort(#)==
  begin print_ln(#);
  print_ln('Sorry, but I can''t go on; are you sure this is a VF?');
  goto final_end;
  end
@y
@d vf_abort(#)==
  begin print_ln(#);
  print_ln('Sorry, but I can''t go on; are you sure this is a VF?');
  uexit(1);
  end
@z

@x [32] Be quiet if not -verbose.
for k:=0 to vf_ptr-1 do print(xchr[vf[k]]);
print_ln(' '); count:=0;
@y
if verbose then begin
  for k:=0 to vf_ptr-1 do print(xchr[vf[k]]);
  print_ln(' ');
end;
count:=0;
@z

@x [35] Be quiet if not -verbose.
@<Print the name of the local font@>;
@y
if verbose then begin
  @<Print the name of the local font@>;
end;
@z

@x [36] Output of real numbers.
print_ln(' at ',(((vf[k]*256+vf[k+1])*256+vf[k+2])/@'4000000)*real_dsize:2:2,
  'pt')
@y
print(' at ');
print_real((((vf[k]*256+vf[k+1])*256+vf[k+2])/@'4000000)*real_dsize, 2, 2);
print_ln('pt')
@z

@x [37] No arbitrary max on cur_name.
@!cur_name:packed array[1..name_length] of char; {external name,
  with no lower case letters}
@y
@!cur_name:^char; {external tfm name}
@z

@x [39] Open another TFM file.
reset(tfm_file,cur_name);
@^system dependencies@>
if eof(tfm_file) then
  print_ln('---not loaded, TFM file can''t be opened!')
@.TFM file can\'t be opened@>
else  begin font_bc:=0; font_ec:=256; {will cause error if not modified soon}
@y
tfm_name := kpse_find_tfm (cur_name);
if not tfm_name then
  print_ln('---not loaded, TFM file ', stringcast(cur_name),
           ' can''t be opened!')
@.TFM file can\'t be opened@>
else begin
  resetbin (tfm_file, tfm_name);
  font_bc:=0; font_ec:=256; {will cause error if not modified soon}
@z

@x [39] Better diagnostics.
    if font_ec>255 then print_ln('---not loaded, bad TFM file!')
@.bad TFM file@>
@y
    if font_ec>255 then
      print_ln('---not loaded, bad TFM file ', stringcast(tfm_name), '!')
@.bad TFM file@>
@z

@x [39] Better diagnostics.
    print_ln('---trouble is brewing, TFM file ended too soon!');
@.trouble is brewing...@>
  end;
@y
    print_ln('---trouble is brewing, TFM file ', stringcast(tfm_name),
             ' ended too soon!');
@.trouble is brewing...@>
    free(tfm_name);
  end;
free(cur_name);
@z

@x [40] Be quiet if not -verbose.
    begin print_ln('Check sum in VF file being replaced by TFM check sum');
@y
    begin
      if verbose then
        print_ln('Check sum in VF file being replaced by TFM check sum');
@z

@x [43] Remove initialization of now-defunct array.
@ @<Set init...@>=
default_directory:=default_directory_name;
@y
@ (No initialization to be done.  Keep this module to preserve numbering.)
@z

@x [44] Don't append `.tfm' here, and keep lowercase.
@ The string |cur_name| is supposed to be set to the external name of the
\.{TFM} file for the current font. This usually means that we need to
prepend the name of the default directory, and
to append the suffix `\.{.TFM}'. Furthermore, we change lower case letters
to upper case, since |cur_name| is a \PASCAL\ string.
@^system dependencies@>

@<Move font name into the |cur_name| string@>=
for k:=1 to name_length do cur_name[k]:=' ';
if a=0 then
  begin for k:=1 to default_directory_name_length do
    cur_name[k]:=default_directory[k];
  r:=default_directory_name_length;
  end
else r:=0;
for k:=font_start[font_ptr]+14 to vf_ptr-1 do
  begin incr(r);
  if r+4>name_length then vf_abort('Font name too long for me!');
@.Font name too long for me@>
  if (vf[k]>="a")and(vf[k]<="z") then
      cur_name[r]:=xchr[vf[k]-@'40]
  else cur_name[r]:=xchr[vf[k]];
  end;
cur_name[r+1]:='.'; cur_name[r+2]:='T'; cur_name[r+3]:='F'; cur_name[r+4]:='M'
@y
@ The string |cur_name| is supposed to be set to the external name of the
\.{TFM} file for the current font.  We do not impose an arbitrary limit
on the filename length.
@^system dependencies@>

@d name_start == (font_start[font_ptr] + 14)
@d name_end == vf_ptr

@<Move font name into the |cur_name| string@>=
r := name_end - name_start;
cur_name := xmalloc_array (char, r);
{|strncpy| might be faster, but it's probably a good idea to keep the
 |xchr| translation.}
for k := name_start to name_end do begin
  cur_name[k - name_start] := xchr[vf[k]];
end;
cur_name[r] := 0; {Append null byte since this is C.}
@z

@x [49] Change strings to C char pointers, so we can initialize them.
@!ASCII_04,@!ASCII_10,@!ASCII_14: packed array [1..32] of char;
  {strings for output in the user's external character set}
@!xchr:packed array [0..255] of char;
@!MBL_string,@!RI_string,@!RCE_string:packed array [1..3] of char;
  {handy string constants for |face| codes}
@y
@!ASCII_04,@!ASCII_10,@!ASCII_14: const_c_string;
  {strings for output in the user's external character set}
@!xchr:packed array [0..255] of char;
@!MBL_string,@!RI_string,@!RCE_string: const_c_string;
  {handy string constants for |face| codes}
@z

@x [50] The Pascal strings are indexed starting at 1, so we pad with a blank.
ASCII_04:=' !"#$%&''()*+,-./0123456789:;<=>?';@/
ASCII_10:='@@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_';@/
ASCII_14:='`abcdefghijklmnopqrstuvwxyz{|}~?';@/
@y
ASCII_04:='  !"#$%&''()*+,-./0123456789:;<=>?';@/
ASCII_10:=' @@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_';@/
ASCII_14:=' `abcdefghijklmnopqrstuvwxyz{|}~?';@/
@z

@x [50]
MBL_string:='MBL'; RI_string:='RI '; RCE_string:='RCE';
@y
MBL_string:=' MBL'; RI_string:=' RI '; RCE_string:=' RCE';
@z

@x [60] How we output the character code depends on |charcode_format|.
begin if font_type>vanilla then
  begin tfm[0]:=c; out_octal(0,1)
  end
else if ((c>="0")and(c<="9"))or@|
   ((c>="A")and(c<="Z"))or@|
   ((c>="a")and(c<="z")) then out(' C ',xchr[c])
else begin tfm[0]:=c; out_octal(0,1);
  end;
@y
begin if (font_type > vanilla) or (charcode_format = charcode_octal) then
  begin tfm[0]:=c; out_octal(0,1)
  end
else if (charcode_format = charcode_ascii) and (c > " ") and (c <= "~")
        and (c <> "(") and (c <> ")") then
  out(' C ', xchr[c])
{default case, use \.C only for letters and digits}
else if ((c>="0")and(c<="9"))or@|
   ((c>="A")and(c<="Z"))or@|
   ((c>="a")and(c<="z")) then out(' C ',xchr[c])
else begin tfm[0]:=c; out_octal(0,1);
  end;
@z

@x [61] Don't output the face code as an integer.
  out(MBL_string[1+(b mod 3)]);
  out(RI_string[1+s]);
  out(RCE_string[1+(b div 3)]);
@y
  put_byte(MBL_string[1+(b mod 3)], vpl_file);
  put_byte(RI_string[1+s], vpl_file);
  put_byte(RCE_string[1+(b div 3)], vpl_file);
@z

@x [100] No progress reports unless verbose.
    incr(chars_on_line);
    end;
  print_octal(c); {progress report}
@y
    if verbose then incr(chars_on_line); {keep |chars_on_line = 0|}
    end;
  if verbose then print_octal(c); {progress report}
@z

@x [112] No nonlocal goto's.
  begin print_ln('Sorry, I haven''t room for so many ligature/kern pairs!');
@.Sorry, I haven't room...@>
  goto final_end;
@y
  begin
  print_ln('Sorry, I haven''t room for so many ligature/kern pairs!');
@.Sorry, I haven't room...@>
  uexit(1);
@z

% still [112] We can't have a function named `f', because of the local
% variable in do_simple_things.  It would be better, but harder, to fix
% web2c.
@x [112]
     r:=f(r,(hash[r]-1)div 256,(hash[r]-1)mod 256);
@y
     r:=lig_f(r,(hash[r]-1)div 256,(hash[r]-1)mod 256);
@z

@x [112]
  out('(INFINITE LIGATURE LOOP MUST BE BROKEN!)'); goto final_end;
@y
  out('(INFINITE LIGATURE LOOP MUST BE BROKEN!)'); uexit(1);
@z

% [116] web2c can't handle these mutually recursive procedures.
% But let's do a fake definition of f here, so that it gets into web2c's
% symbol table...
@x [116]
@p function f(@!h,@!x,@!y:index):index; forward;@t\2@>
  {compute $f$ for arguments known to be in |hash[h]|}
@y
@p
ifdef('notdef')
function lig_f(@!h,@!x,@!y:index):index; begin end;@t\2@>
  {compute $f$ for arguments known to be in |hash[h]|}
endif('notdef')
@z

@x [116]
else eval:=f(h,x,y);
@y
else eval:=lig_f(h,x,y);
@z

@x [117] ... and then really define it now.
@p function f;
@y
@p function lig_f(@!h,@!x,@!y:index):index;
@z

@x [117]
f:=lig_z[h];
@y
lig_f:=lig_z[h];
@z

@x [124] Some cc's can't handle 136 case labels.
    begin o:=vf[vf_ptr]; incr(vf_ptr);
    case o of
@y
    begin o:=vf[vf_ptr]; incr(vf_ptr);
    if (o<=set1+3)or((o>=put1)and(o<=put1+3)) then
      @<Special cases of \.{DVI} instructions to typeset characters@>@;
    else case o of
@z

@x [125] `signed' is a reserved word in ANSI C.
@p function get_bytes(@!k:integer;@!signed:boolean):integer;
@y
@d signed == is_signed {|signed| is a reserved word in ANSI C}
@p function get_bytes(@!k:integer;@!signed:boolean):integer;
@z

@x [126] No nonlocal goto's.
    begin print_ln('Stack overflow!'); goto final_end;
@y
    begin print_ln('Stack overflow!'); uexit(1);
@z

@x [129] This block of code moved outside the case statement.
@ Before we typeset a character we make sure that it exists.

@<Cases...@>=
sixty_four_cases(set_char_0),sixty_four_cases(set_char_0+64),
 four_cases(set1),four_cases(put1):begin if o>=set1 then
@y
@ Before we typeset a character we make sure that it exists.

@<Special cases...@>=
begin if o>=set1 then
@z

@x [129] End of block of code moved outside the case statement.
  end;
@y
  end
@z

@x [131] Eliminate the |final_end| and |exit| labels.
label final_end, exit;
@y
@z
@x [131]
vf_input:=true; return;
final_end: vf_input:=false;
exit: end;
@y
vf_input:=true;
end;
@z
@x [131]
label final_end, exit;
@y
@z
@x [131]
organize:=vf_input; return;
final_end: organize:=false;
exit: end;
@y
organize:=vf_input;
end;
@z

@x [133] Eliminate the |final_end| and |exit| labels.
label final_end,exit;
@y
@z
@x [133]
do_map:=true; return;
final_end: do_map:=false;
exit:end;
@y
do_map:=true;
end;
@z

@x [134] No final newline unless verbose.
print_ln('.');@/
@y
if verbose then print_ln('.');@/
@z

@x [135] System-dependent changes.
This section should be replaced, if necessary, by changes to the program
that are necessary to make \.{VFtoVP} work at a particular installation.
It is usually best to design your change file so that all changes to
previous sections preserve the section numbering; then everybody's version
will be consistent with the printed program. More extensive changes,
which introduce new sections, can be inserted here; then only the index
itself will get a new section number.
@^system dependencies@>
@y
Parse a Unix-style command line.

@d argument_is (#) == (strcmp (long_options[option_index].name, #) = 0)

@<Define \(p)|parse_arguments|@> =
procedure parse_arguments;
const n_options = 4; {Pascal won't count array lengths for us.}
var @!long_options: array[0..n_options] of getopt_struct;
    @!getopt_return_val: integer;
    @!option_index: c_int_type;
    @!current_option: 0..n_options;
begin
  @<Initialize the option variables@>;
  @<Define the option table@>;
  repeat
    getopt_return_val := getopt_long_only (argc, argv, '', long_options,
                                           address_of (option_index));
    if getopt_return_val = -1 then begin
      do_nothing; {End of arguments; we exit the loop below.}

    end else if getopt_return_val = "?" then begin
      usage (my_name);

    end else if argument_is ('help') then begin
      usage_help (VFTOVP_HELP, nil);

    end else if argument_is ('version') then begin
      print_version_and_exit (banner, nil, 'D.E. Knuth', nil);

    end else if argument_is ('charcode-format') then begin
      if strcmp (optarg, 'ascii') = 0 then
        charcode_format := charcode_ascii
      else if strcmp (optarg, 'octal') = 0 then
        charcode_format := charcode_octal
      else
        print_ln ('Bad character code format ', stringcast(optarg), '.');

    end; {Else it was a flag; |getopt| has already done the assignment.}
  until getopt_return_val = -1;

  {Now |optind| is the index of first non-option on the command line.
   We must have one two three remaining arguments.}
  if (optind + 1 <> argc) and (optind + 2 <> argc)
     and (optind + 3 <> argc) then begin
    print_ln (my_name, ': Need one to three file arguments.');
    usage (my_name);
  end;

  vf_name := cmdline (optind);
  if optind + 2 <= argc then begin
    tfm_name := cmdline (optind + 1); {The user specified the TFM name.}
  end else begin
    {User did not specify TFM name; default it from the VF name.}
    tfm_name := basename_change_suffix (vf_name, '.vf', '.tfm');
  end;
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

@ Print progress information?
@.-verbose@>

@<Define the option...@> =
long_options[current_option].name := 'verbose';
long_options[current_option].has_arg := 0;
long_options[current_option].flag := address_of (verbose);
long_options[current_option].val := 1;
incr (current_option);

@ The global variable |verbose| determines whether or not we print
progress information.

@<Glob...@> =
@!verbose: c_int_type;

@ It starts off |false|.

@<Initialize the option...@> =
verbose := false;

@ Here is an option to change how we output character codes.
@.-charcode-format@>

@<Define the option...@> =
long_options[current_option].name := 'charcode-format';
long_options[current_option].has_arg := 1;
long_options[current_option].flag := 0;
long_options[current_option].val := 0;
incr (current_option);

@ We use an ``enumerated'' type to store the information.

@<Type...@> =
@!charcode_format_type = charcode_ascii..charcode_default;

@ @<Const...@> =
@!charcode_ascii = 0;
@!charcode_octal = 1;
@!charcode_default = 2;

@ @<Global...@> =
@!charcode_format: charcode_format_type;

@ It starts off as the default, that is, we output letters and digits as
ASCII characters, everything else in octal.

@<Initialize the option...@> =
charcode_format := charcode_default;

@ An element with all zeros always ends the list.

@<Define the option...@> =
long_options[current_option].name := 0;
long_options[current_option].has_arg := 0;
long_options[current_option].flag := 0;
long_options[current_option].val := 0;

@ Global filenames.

@<Global...@> =
@!tfm_name:c_string;
@!vf_name, @!vpl_name:const_c_string;
@z

@x
procedure print_kanji(@!s:KANJI_code); {prints a single character}
var old_is_print_raw: integer;
begin
old_is_print_raw:=is_print_raw; is_print_raw:=true; 
s:=toBUFF(s mod max_cjk_val);
if BYTE1(s)<>0 then print_char(BYTE1(s));
if BYTE2(s)<>0 then print_char(BYTE2(s));
if BYTE3(s)<>0 then print_char(BYTE3(s));
                    print_char(BYTE4(s));
is_print_raw:=old_is_print_raw;
end;
@y
procedure print_kanji(@!s:KANJI_code); {prints a single character}
var old_is_print_raw: integer;
begin
if s>255 then
  begin old_is_print_raw:=is_print_raw; is_print_raw:=true; 
  print_char(Hi(s)); print_char(Lo(s));
  is_print_raw:=old_is_print_raw;
  end else print_char(s);
end;
@z

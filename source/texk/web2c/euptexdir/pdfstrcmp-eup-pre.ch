@x
procedure print_kanji(@!s:KANJI_code); {prints a single character}
begin
s:=toBUFF(s mod max_cjk_val);
if BYTE1(s)<>0 then print_char_raw(BYTE1(s));
if BYTE2(s)<>0 then print_char_raw(BYTE2(s));
if BYTE3(s)<>0 then print_char_raw(BYTE3(s));
                    print_char_raw(BYTE4(s));
end;
@y
procedure print_kanji(@!s:KANJI_code); {prints a single character}
begin
if s>255 then
  begin print_char_raw(Hi(s)); print_char_raw(Lo(s));
  end else print_char(s);
end;
@z

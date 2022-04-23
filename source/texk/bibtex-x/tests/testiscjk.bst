ENTRY {field}{}{}

FUNCTION {output_entry} {
  "\item " field * write$
      ": " field is.cjk.str$ int.to.str$ * write$
      " " field is.kanji.str$ int.to.str$ * write$
      " hz:"   field is.cjk.str$ #1    & int.to.str$ * write$
      " kn:"   field is.cjk.str$ #2    & int.to.str$ * write$
      " hg:"   field is.cjk.str$ #4    & int.to.str$ * write$
      " bp:"   field is.cjk.str$ #8    & int.to.str$ * write$
      " misc:" field is.cjk.str$ #2048 & int.to.str$ * write$
      newline$
}

FUNCTION {type} {output_entry}

READ

FUNCTION {set_sortkey} {
  field 'sort.key$ :=
}

ITERATE {set_sortkey}

SORT

FUNCTION {output_beg} {
  "\section*{Test result}" write$ newline$
  "\begin{itemize}" write$ newline$
}

FUNCTION {output_end} {
  "\end{itemize}" write$ newline$
  "\endinput" write$ newline$
}

EXECUTE {output_beg}

ITERATE {call.type$}

EXECUTE {output_end}

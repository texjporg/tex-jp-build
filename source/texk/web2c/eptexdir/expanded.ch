@x
@d pdf_strcmp_code          = etex_convert_base+1 {command code for \.{\\pdfstrcmp}}
@d pdf_creation_date_code   = etex_convert_base+2 {command code for \.{\\pdfcreationdate}}
@d pdf_file_mod_date_code   = etex_convert_base+3 {command code for \.{\\pdffilemoddate}}
@d pdf_file_size_code       = etex_convert_base+4 {command code for \.{\\pdffilesize}}
@d pdf_mdfive_sum_code      = etex_convert_base+5 {command code for \.{\\pdfmdfivesum}}
@d pdf_file_dump_code       = etex_convert_base+6 {command code for \.{\\pdffiledump}}
@d uniform_deviate_code     = etex_convert_base+7 {command code for \.{\\pdfuniformdeviate}}
@d normal_deviate_code      = etex_convert_base+8 {command code for \.{\\pdfnormaldeviate}}
@d etex_convert_codes=etex_convert_base+9 {end of \eTeX's command codes}
@d job_name_code=etex_convert_codes {command code for \.{\\jobname}}
@y
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
@d job_name_code=pdf_convert_codes {command code for \.{\\jobname}}
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
  eTeX_revision_code: print_esc("eTeXrevision");
@y
  eTeX_revision_code: print_esc("eTeXrevision");
  expanded_code:      print_esc("expanded");
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
    def_ref := save_def_ref;
    restore_cur_string;
    return;
  end;
@z

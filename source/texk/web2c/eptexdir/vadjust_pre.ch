% add \vadjust pre feature from pdfTeX

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
if adjust_tail<>null then link(adjust_tail):=null;
@y
if adjust_tail<>null then link(adjust_tail):=null;
if pre_adjust_tail<>null then link(pre_adjust_tail):=null;
@z

@x
  ins_node,mark_node,adjust_node: if adjust_tail<>null then
@y
  ins_node,mark_node,adjust_node: if (adjust_tail<>null) or (pre_adjust_tail<> null) then
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

% procedure |push_alignment|
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

% procedure |pop_alignment|
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
  begin adjust_tail:=cur_tail; adjust_hlist(head,false);
@y
  begin adjust_tail:=cur_tail; pre_adjust_tail:=cur_pre_tail;
  adjust_hlist(head,false);
@z

@x
  cur_tail:=adjust_tail; adjust_tail:=null;
@y
  cur_tail:=adjust_tail; adjust_tail:=null;
  cur_pre_tail:=pre_adjust_tail; pre_adjust_tail:=null;
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
adjusted_hbox_group: begin adjust_hlist(head,false);
  adjust_tail:=adjust_head; package(0);
@y
adjusted_hbox_group: begin adjust_hlist(head,false);
  adjust_tail:=adjust_head;
  pre_adjust_tail:=pre_adjust_head; package(0);
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
  d:=split_max_depth; f:=floating_penalty; unsave; decr(save_ptr);
@y
  d:=split_max_depth; f:=floating_penalty; unsave; save_ptr := save_ptr - 2;
@z

@x
      r:=get_node(small_node_size); type(r):=adjust_node;@/
      subtype(r):=0; {the |subtype| is not used}
      adjust_ptr(r):=list_ptr(p); delete_glue_ref(q);
@y
      r:=get_node(small_node_size); type(r):=adjust_node;@/
      adjust_pre(r) := saved(1); {the |subtype| is used for |adjust_pre|}
      adjust_ptr(r):=list_ptr(p); delete_glue_ref(q);
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

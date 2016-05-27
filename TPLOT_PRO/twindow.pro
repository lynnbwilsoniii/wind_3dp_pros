pro twindow,tnum,window=w
@tplot_com
if not keyword_set(tplot_ptrs) then  tplot_ptrs = ptrarr(32)
if not keyword_set(current_num) then current_num = 0
if not keyword_set(tplot_ptrs[current_num]) then $
   tplot_ptrs[current_num] = ptr_new(tplot_vars)
   
if n_elements(tnum) ne 0 then begin
   *(tplot_ptrs[current_num]) = tplot_vars
   if k
endif

old = tplot_vars


if n_elements(w) ne 0 then begin
  tplot_options,window=w
endif

end

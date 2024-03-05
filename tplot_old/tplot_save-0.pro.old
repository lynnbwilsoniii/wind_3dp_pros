;+
;PROCEDURE:  tplot_save , name ,filename=filename, limits=limits
;PURPOSE: 
;   Store tplot data in a file.
;INPUT:  
;   name:   (optional) tplot handle or array of tplot handles to save.  If
;	    no name is supplied, tplot_save will save all defined tplot
;	    handles.
;KEYWORDS:   
;   filename:  file name in which to save data.  A default suffix of .tplot or
;	       .lim will be added to this depending on whether the limits
;              keyword has been set.  If not given, the default file name is
;	       saved.tplot or saved.lim.
;   limits:    will save only limits structures.  No data will be saved.
;SEE ALSO:      "STORE_DATA", "GET_DATA", "TPLOT", "TPLOT_RESTORE"
;
;CREATED BY:    Peter Schroeder
;LAST MODIFICATION:     tplot_save.pro   97/05/14
;
;-
pro tplot_save,handlenames,filename=filename,limits=limits,compress=compress

@tplot_com.pro

;if not keyword_set(handlenames) then handlenames = (data_quants.name)(1:*)
;n = n_elements(handlenames)
;index = fltarr(n)

;;for i=0,n-1 do begin
;  handlename = handlenames(i)
;  index(i) = find_handle(handlename)
;endfor

;index = index(where(index ne 0)) 

names = tnames(handlenames,n,index=index)


origdq = data_quants(index)

if keyword_set(limits) then begin
	dq = origdq
	dq.dh(*) = ptr_new(0)
	filesuf = '.lim'
endif else begin
	dq = origdq
	filesuf = '.tplot'
endelse

if data_type(filename) ne 7 then filename = 'saved'

if n_elements(tplot_vars) gt 0 then tv = tplot_vars else tv = 0
save,dq,tv,file=filename+filesuf,compress=compress
end

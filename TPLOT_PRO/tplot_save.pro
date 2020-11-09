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
;   NO_ADD_EXTENSION:  Set this to prevent the addition of the extension
;   
;SEE ALSO:      "STORE_DATA", "GET_DATA", "TPLOT", "TPLOT_RESTORE"
;
;CREATED BY:    Peter Schroeder
;LAST MODIFICATION:     tplot_save.pro   97/05/14
;
; $LastChangedBy: ali $
; $LastChangedDate: 2020-03-05 13:17:11 -0800 (Thu, 05 Mar 2020) $
; $LastChangedRevision: 28378 $
; $URL: svn+ssh://thmsvn@ambrosia.ssl.berkeley.edu/repos/spdsoft/tags/spedas_4_0/general/tplot/tplot_save.pro $
;-
pro tplot_save,handlenames,filename=filename,limits=limits,compress=compress,no_add_extension=no_add_extension,verbose=verbose

COMPILE_OPT IDL2
@tplot_com.pro


names = tnames(handlenames,n,index=index)
origdq = data_quants[index]
if 1 then begin
  w = where(/null,origdq.dtype eq 3,nw)
  for i=0,nw-1  do begin
    names= [names,tnames(*origdq[w[i]].dh)]
  endfor
  if nw ne 0 then begin
    dprint,'Added variables.  ',names
    names = tnames(names,n,index=index)
    origdq = data_quants[index]
  endif
endif

if keyword_set(limits) then begin
	dq = origdq
	dq.dh[*] = ptr_new(0)
	filesuf = '.lim'
endif else begin
	dq = origdq
	filesuf = '.tplot'
endelse

if keyword_set(no_add_extension) then filesuf=''

if size(/type,filename) ne 7 then filename = 'saved'

if n_elements(tplot_vars) gt 0 then tv = tplot_vars else tv = 0
file_mkdir2,file_dirname(filename)
save,dq,tv,file=filename+filesuf,compress=compress,verbose=verbose
dprint,dlevel=1,'Saved tplot file: '+filename+filesuf
end

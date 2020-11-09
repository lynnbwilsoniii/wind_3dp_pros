;+
;PROCEDURE:  tplot_restore ,filenames=filenames, all=all, sort=sort
;PURPOSE:
;   Restores tplot data, limits, name handles, options, and settings.
;INPUT:
;KEYWORDS:
;   filenames:  file name or array of filenames to restore.  If
;               no file name is chosen and the all keyword is not set,
;		tplot_restore will look for and restore a file called
;		saved.tplot.
;   all: restore all *.tplot files in current directory (or directory specified by directory keyword)
;   directory: specify a directory other than the current working dir for loading ALL tplot files
;   append: append saved data to existing tplot variables
;   sort: sort data by time after loading in
;   get_tvars: load tplot_vars structure (the structure containing tplot
;		options and settings even if such a structure already exists
;		in the current session.  The default is to only load these
;		if no such structure currently exists in the session.
;   restored_varnames=the tplot variable names for the restored data
;SEE ALSO:      "TPLOT_SAVE","STORE_DATA", "GET_DATA", "TPLOT"
;
;CREATED BY:    Peter Schroeder
;LAST MODIFICATION:     Added restore_varnames, 19-jun-2007, jmm
;                       Changed the obsolete IDL routine str_sep to
;                         strsplit. Also added additional output
;						  text.                   21-may-2008, cg
;                       Removed additional output text - Use dprint,debug=3  to restore text.   Nov 2008
;                       Fixed bug on macOS when saving figures of restored data using makepng/makegif/makejpg, 24-jan-2019, egrimes
;
; $LastChangedBy: ali $
; $LastChangedDate: 2020-03-05 14:17:16 -0800 (Thu, 05 Mar 2020) $
; $LastChangedRevision: 28383 $
; $URL: svn+ssh://thmsvn@ambrosia.ssl.berkeley.edu/repos/spdsoft/tags/spedas_4_0/general/tplot/tplot_restore.pro $
;-
pro tplot_restore,filenames=filenames,all=all,append=append,sort=sort,$
  get_tvars=get_tvars,verbose=verbose, restored_varnames=restored_varnames, $
  directory=directory

  COMPILE_OPT IDL2
  @tplot_com.pro

  ;if !d.name eq 'X' then begin
  ;  if !version.os_family eq 'unix' then device,retain=2  ; Unix family does not provide backing store by default
  ;endif

  tplot_quant__define
  if keyword_set(directory) and ~keyword_set(all) then begin
    dprint, dlevel=0, 'Warning: directory keyword only used when /all keyword set'
  endif
  if keyword_set(directory) then begin
    ;First check for a slash
    n = n_elements(directory)
    If(n Eq 0) Then dirslash = '/' Else Begin
      dirslash = directory
      For j = 0, n-1 Do Begin
        temp_string = strtrim(directory[j], 2)
        ll = strmid(temp_string, strlen(temp_string)-1, 1)
        If(ll Ne '/' And ll Ne '\') Then temp_string = temp_string+'/'
        dirslash[j] = temporary(temp_string)
      Endfor
    Endelse
    restore_dir = dirslash
  endif else restore_dir = ''

  if keyword_set(all) then filenames = file_search(restore_dir+'*.tplot')
  if size(/type,filenames) ne 7 then $
    filenames = 'saved.tplot'
  n = n_elements(filenames)
  restored_varnames = ''
  for i=0L, n[0] - 1L do begin
    ;for i=0,n-1 do begin
    fi = file_info(filenames[i])
    if fi.exists eq 0 then begin
      dprint,dlevel=1,'File '+filenames[i]+' Does not exist! Skipping.'
      continue
    endif
    dprint,dlevel=2,'Restoring tplot file: '+filenames[i]
    restore,filenames[i],/relaxed
    if keyword_set(tv) then begin
      chkverb = where(tag_names(tv.options) eq 'VERBOSE',verbosethere)
      if not verbosethere then begin
        optstruct = tv.options
        setstruct = tv.settings
        newopt = create_struct(optstruct,'VERBOSE',0)
        tv = 0
        tv = {options: newopt, settings: setstruct}
        optstruct = 0
        setstruct = 0
        newopt = 0
      endif
    endif
    if (n_elements(tplot_vars) eq 0) or keyword_set(get_tvars) then $
      if keyword_set(tv) then tplot_vars = tv
    if keyword_set(dq) then begin
      for j=0L, n_elements(dq.name) - 1L do begin
        ;  	for j=0,n_elements(dq.name)-1 do begin
        thisdq = dq[j]
        dprint,dlevel=3, 'The tplot variable '+thisdq.name+' is being restored.'
        restored_varnames = [restored_varnames, thisdq.name]
        names = strsplit(thisdq.name,'.')
        if keyword_set(append) then get_data,thisdq.name,ptr=olddata
        if keyword_set(append) and keyword_set(olddata) then begin
          if keyword_set(*thisdq.dh) then begin
            if thisdq.dtype eq 1 then begin
              if ptr_valid((*thisdq.dh).y) then begin
                ;check y dimensions prior to appending, jmm, 2019-11-22
                n1 = size(*olddata.y, /n_dimen)
                n2 = size(*(*thisdq.dh).y, /n_dimen)
                s1 = size(*olddata.y, /dimen)
                s2 = size(*(*thisdq.dh).y, /dimen)
                if n_elements(s1) eq 2 then s12=s1[1]>s2[1]
                if (n1 ne n2) || (n_elements(s1) gt 2 && ~array_equal(s1[1:*], s2[1:*])) then begin
                  dprint, dlevel=1, 'Variable '+thisdq.name+' Y size mismatch; not appended'
                  continue
                endif
                if n_elements(s1) eq 2 && s1[1] ne s2[1] then begin
                  dprint, dlevel=3, 'Variable '+thisdq.name+' Y size mismatch; matching sizes!'
                  oldy=replicate(!values.f_nan,[s1[0],s12])
                  newy=replicate(!values.f_nan,[s2[0],s12])
                  oldy[*,0:s1[1]-1]=*olddata.y
                  newy[*,0:s2[1]-1]=*(*thisdq.dh).y
                  newy = ptr_new([oldy,newy])
                endif else newy = ptr_new([*olddata.y,*(*thisdq.dh).y])
              endif else newy = ptr_new(*olddata.y)
              if ptr_valid((*thisdq.dh).x) then newx = ptr_new([*olddata.x,*(*thisdq.dh).x]) else newx = ptr_new(*olddata.x)
              ptr_free,(*thisdq.dh).x,(*thisdq.dh).y
              oldv = ptr_new()
              str_element,olddata,'v',oldv
              if ptr_valid(oldv) then begin
                ;;  V tag is present
                if ndimen(*oldv) eq 1 then begin
                  ;;  1D --> no need to append
                  if ~array_equal(oldv,(*thisdq.dh).v) then begin
                    oldw=replicate(!values.f_nan,[s1[0],s12])
                    newv=replicate(!values.f_nan,[s2[0],s12])
                    oldw[*,0:s1[1]-1]=replicate(1.,s1[0])#(*oldv)
                    if ndimen(*(*thisdq.dh).v) eq 1 then *(*thisdq.dh).v=replicate(1.,s2[0])#(*(*thisdq.dh).v)
                    newv[*,0:s2[1]-1]=*(*thisdq.dh).v
                    newv = ptr_new([oldw,newv])
                  endif else newv = ptr_new(*oldv)
                endif else begin
                  ;;  2D --> need to append (if present)
                  if (struct_value((*thisdq.dh),'v')) then begin
                    ;;  present --> append
                    if ndimen(*(*thisdq.dh).v) eq 1 then *(*thisdq.dh).v=replicate(1.,s2[0])#(*(*thisdq.dh).v)
                    if s1[1] ne s2[1] then begin
                      oldw=replicate(!values.f_nan,[s1[0],s12])
                      newv=replicate(!values.f_nan,[s2[0],s12])
                      oldw[*,0:s1[1]-1]=*oldv
                      newv[*,0:s2[1]-1]=*(*thisdq.dh).v
                      newv = ptr_new([oldw,newv])
                    endif else newv = ptr_new([*oldv,*(*thisdq.dh).v])
                  endif else begin
                    ;;  not present --> replicate old to make dimensions correct???
                    szdox = size(*olddata.x,/dimensions)
                    szdnx = size(*newx,/dimensions)
                    szdo  = size(*oldv,/dimensions)
                    dumb  = make_array(szdnx[0],szdo[1],TYPE=size(*oldv,/type))
                    avgo  = total(*oldv,1,/nan)/total(finite(*oldv),1,/nan)
                    dumb[0L:(szdox[0] - 1L),*] = *oldv
                    for kk=0L, szdo[1] - 1L do dumb[szdox[0]:(szdnx[0] - 1L),kk] = avgo[kk]
                    newv = ptr_new(dumb)
                  endelse
                endelse
                ;  						if ndimen(*oldv) eq 1 then $
                ;  							newv = ptr_new(*oldv) else $
                ;  							newv = ptr_new([*oldv,*(*thisdq.dh).v])
                if (struct_value((*thisdq.dh),'v')) then ptr_free,(*thisdq.dh).v
                ;  						ptr_free,(*thisdq.dh).v
                newdata={x: newx, y: newy, v: newv}
                ;  					endif else newdata={x: newx, y: newy}
              endif else begin
                ;;  V tag is not present --> Only X and Y tags should be present
                newdata={x: newx, y: newy}
              endelse
              olddata = 0
            endif else begin
              newdata = olddata
              dattags = tag_names(olddata)
              for k = 0,n_elements(dattags)-1 do begin
                str_element,*thisdq.dh,dattags[k],foo
                foo = *foo
                str_element,newdata,dattags[k],[*olddata[k],foo],/add
              endfor
            endelse
            store_data,verbose=verbose,thisdq.name,data=newdata
          endif
        endif else begin
          store_data,verbose=verbose,thisdq.name,data=*thisdq.dh,limit=*thisdq.lh,dlimit=*thisdq.dl,/nostrsw
          dprint,dlevel=3, 'The tplot variable '+thisdq.name+' has been restored.'
        endelse
        if keyword_set(sort) then tplot_sort,thisdq.name
      endfor
      ptr_free,dq.dh,dq.dl,dq.lh
    endif
    dq = 0
    tv = 0
  endfor
  If(n_elements(restored_varnames) Gt 1) Then $
    restored_varnames = restored_varnames[1:*]
end

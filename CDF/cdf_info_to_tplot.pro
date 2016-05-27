;+
; This is a new routine that needs further testing, development, and enhancements.
; PROCEDURE:  cdf2tplot, cdfi
; Purpose:  Creates TPLOT variables from a CDF structure (obtained from "CDF_LOAD_VAR")
; This routine will only work well if the underlying CDF file follows the SPDF standard.
;
; Written by Davin Larson
;
; $LastChangedBy: pcruce $
; $LastChangedDate: 2014-02-28 16:39:25 -0800 (Fri, 28 Feb 2014) $
; $LastChangedRevision: 14473 $
; $URL: svn+ssh://thmsvn@ambrosia.ssl.berkeley.edu/repos/spdsoft/trunk/general/CDF/cdf_info_to_tplot.pro $
;-
pro cdf_info_to_tplot,cdfi,varnames,loadnames=loadnames,  $
        prefix=prefix,midfix=midfix,midpos=midpos,suffix=suffix,newname=newname,  $
        all=all, $
        force_epoch=force_epoch, $
        verbose=verbose,get_support_data=get_support_data,  $
        tplotnames=tplotnames,$
        load_labels=load_labels ;copy labels from labl_ptr_1 in attributes into dlimits
                                      ;resolve labels implemented as keyword to preserve backwards compatibility

dprint,verbose=verbose,dlevel=4,'$Id: cdf_info_to_tplot.pro 14473 2014-03-01 00:39:25Z pcruce $'
tplotnames=''
vbs = keyword_set(verbose) ? verbose : 0


if size(cdfi,/type) ne 8 then begin
    dprint,dlevel=1,verbose=verbose,'Must provide a CDF structure'
    return
endif

if keyword_set(all) or n_elements(varnames) eq 0 then varnames=cdfi.vars.name

nv = cdfi.nv

for i=0,nv-1 do begin
   v=cdfi.vars[i]
   if vbs ge 6 then dprint,verbose=verbose,dlevel=6,v.name
   if ptr_valid(v.dataptr) eq 0 then begin
       dprint,dlevel=5,verbose=verbose,'Invalid data pointer for ',v.name
       continue
   endif
   attr = *v.attrptr
   var_type = struct_value(attr,'var_type',def='')
   depend_time = struct_value(attr,'depend_time',def='time')
   depend_0 = struct_value(attr,'depend_0',def='Epoch')
   depend_1 = struct_value(attr,'depend_1',def='')
   depend_2 = struct_value(attr,'depend_2',def='')
   depend_3 = struct_value(attr,'depend_3',def='')
   depend_4 = struct_value(attr,'depend_4',def='')
   display_type = struct_value(attr,'display_type',def='time_series')
   scaletyp = struct_value(attr,'scaletyp',def='linear')
   fillval = struct_value(attr,'fillval',def=!values.f_nan)
   fieldnam = struct_value(attr,'fieldnam',def=v.name)

   if strcmp(v.datatype,'CDF_TIME_TT2000',/fold_case) then begin
      defsysv,'!CDF_LEAP_SECONDS',exists=exists
  
      if ~keyword_set(exists) then begin
        ;fatal error
        message,'Error. !CDF_LEAP_SECONDS, must be defined to convert CDFs with TT2000 times.  Try calling cdf_leap_second_init'
     endif
     
    *(v.dataptr) =time_double(*(v.dataptr),/tt2000)     ; convert to UNIX_time but without leap seconds
    cdfi.vars[i].datatype = 'CDF_S1970'
     
     if !CDF_LEAP_SECONDS.preserve_tt2000 then begin
       *(v.dataptr) =add_tt2000_offset(*v.dataptr)   ; convert to UNIX epoch, but leave the offset in.
     endif 
     
     continue
     
   endif

   if (strcmp(v.datatype,'CDF_EPOCH',/fold_case) || strcmp(v.datatype,'CDF_EPOCH16',/fold_case) || (strcmp( v.name , 'Epoch',5, /fold_case) && (v.datatype ne 'CDF_S1970')))  then begin
       *(v.dataptr) =time_double(/epoch, *(v.dataptr) )     ; convert to UNIX_time
       cdfi.vars[i].datatype = 'CDF_S1970'
       continue
   endif

   if finite(fillval) and keyword_set(v.dataptr) and (v.type eq 4 or v.type eq 5) then begin
       w = where(*v.dataptr eq fillval,nw)
       if nw gt 0 then (*v.dataptr)[w] = !values.f_nan
   endif

;   plottable_data = strcmp( var_type , 'data',/fold_case)

;   if keyword_set(get_support_data) then plottable_data or= strcmp( var_type, 'support',7,/fold_case)

   plottable_data= total(/preserve,v.name eq varnames) ne 0
   plottable_data = plottable_data and v.recvary

   if plottable_data eq 0 then begin
      dprint,dlevel=6,verbose=verbose,'Skipping variable: "'+v.name+'" ('+var_type+')'
      continue
   endif

   j = (where(strcmp(cdfi.vars.name , depend_time,/fold_case),nj))[0]
   if nj gt 0 then tvar = cdfi.vars[j]  else  begin
     j = (where(strcmp(cdfi.vars.name ,depend_0,/fold_case),nj))[0]
     if nj gt 0 then tvar = cdfi.vars[j]
   endelse

   if nj eq 0 then begin
      dprint,verbose=verbose,dlevel=6,'Skipping variable: "'+v.name+'" ('+var_type+')'
      continue
   endif

   j = (where(strcmp(cdfi.vars.name , depend_1,/fold_case),nj))[0]
   if nj gt 0 then var_1 = cdfi.vars[j]

   j = (where(strcmp(cdfi.vars.name , depend_2,/fold_case),nj))[0]
   if nj gt 0 then var_2 = cdfi.vars[j]

   j = (where(strcmp(cdfi.vars.name , depend_3,/fold_case),nj))[0]
   if nj gt 0 then var_3 = cdfi.vars[j]

   j = (where(strcmp(cdfi.vars.name , depend_4,/fold_case),nj))[0]
   if nj gt 0 then var_4 = cdfi.vars[j]

   spec = strcmp(display_type,'spectrogram',/fold_case)
   log  = strcmp(scaletyp,'log',3,/fold_case)

   if ptr_valid(tvar.dataptr) and ptr_valid(v.dataptr) then begin

     if size(/n_dimens,*v.dataptr) ne v.ndimen +1 then begin    ; Cluge for (lost) trailing dimension of 1
;in rare circumstances, var_2 may not exist here, jmm, 17-mar-2009,
;          var_1 = var_2        ;bpif  v.name eq 'thb_sir_001'
          if(keyword_set(var_2)) then var_1 = var_2 else var_1 = 0 ;bpif  v.name eq 'thb_sir_001'
          var_2 = 0
     endif
     cdfstuff={filename:cdfi.filename,gatt:cdfi.g_attributes,vname:v.name,vatt:attr}
     units = struct_value(attr,'units',default='')
     if keyword_set(var_2) then data = {x:tvar.dataptr,y:v.dataptr,v1:var_1.dataptr, v2:var_2.dataptr} $
     else if keyword_set(var_1) then data = {x:tvar.dataptr,y:v.dataptr, v:var_1.dataptr}  $
     else data = {x:tvar.dataptr,y:v.dataptr}
     
     dlimit = {cdf:cdfstuff,spec:spec,log:log}
     if keyword_set(units) then str_element,/add,dlimit,'ysubtitle','['+units+']'
     
     if keyword_set(load_labels) then begin
       labl_ptr_1 = struct_value(attr,'labl_ptr_1',default='')
       if keyword_set(labl_ptr_1) then begin
         labl_idx = where(cdfi.vars.name eq labl_ptr_1,c)
         if c eq 1 then begin
           if ptr_valid(cdfi.vars[labl_idx].dataptr) then begin
             str_element,/add,dlimit,'labels',*cdfi.vars[labl_idx].dataptr
           endif
         endif
       endif
     endif
     
     tn = v.name
;     if keyword_set(newname) then begin;;  bug here
;        tn = newname[i]
;     endif
     if keyword_set(midfix) then begin
        if size(/type,midpos) eq 7 then str_replace,tn,midpos,midfix    $
        else    tn = strmid(tn,0,midpos) + midfix + strmid(tn,midpos)
     endif
     if keyword_set(prefix) then tn = prefix+tn
     if keyword_set(suffix) then tn = tn+suffix
     store_data,tn,data=data,dlimit=dlimit, verbose=verbose
     tplotnames = keyword_set(tplotnames) ? [tplotnames,tn] : tn
   endif
   var_1=0
   var_2=0
   var_3=0
   var_4=0
endfor

end


;+
;PROCEDURE:  add_magf,dat,source
;PURPOSE:
;    Adds magnetic field vector [Bx,By,Bz] to a 3d structure.
;    The new structure element will be a 3 element vector 
;    with the tag name 'magf'.
;INPUT:
;    dat:   3D data structure        (i.e. from 'GET_EL')
;    [source] : (String) handle of magnetic field data.
;Notes:
;       Magnetic field data must be loaded first.  
;       See 'GET_MFI'
;-
pro add_magf,dat,source,average=average,gap_thresh=gap_thresh
if not keyword_set(source) then begin
   answer = ''
   source = (tnames('wi_B3 wi_B wi_Bhkp',/all))[0]
   read,answer,prompt='Source of magnetic field data; (default is '+source+')? '
   if keyword_set(answer) then source = answer
endif
nan=!values.f_nan
if keyword_set(average) then begin
   t = dat.trange
   b = tsample(source,t,/average)
endif else begin
   t = (dat.time+dat.end_time)/2
   b = data_cut(source,t,count=count,gap_thresh=gap_thresh)
   if count eq 0 then begin
     print,'Unable to determine magnetic field vector using: ',source
     b = [nan,nan,nan]
   endif
endelse
add_str_element,dat,'magf',b
end

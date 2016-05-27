;+
;PROCEDURE:  add_sc_pos,dat,source
;PURPOSE:  
;       Adds orbital data to a 3d data structure.
;       The new structure element will be a three element vector [x,y,z]
;       with the tag name 'sc_pos'.
;INPUT:
;    dat:   3D structure (obtained from get_??() routines)
;           e.g. "GET_EL"
;Notes:
;       Orbit data must be loaded first.  
;       See "GET_ORBIT"
;-
pro add_sc_pos,dat,source
if not keyword_set(source) then begin
   answer = ''
   source = 'wi_pos'
   read,answer,prompt='Source of magnetic field data; (default is '+source+')? '
   if keyword_set(answer) then source = answer
endif 

t = (dat.time+dat.end_time)/2
orbit = data_cut(source,t,count=count)
if count ne 0 then add_str_element,dat,'sc_pos',orbit  $
else print,'Unable to determine spacecraft position vector using: ',source

end

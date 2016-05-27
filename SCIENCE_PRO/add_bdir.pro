;+
;PROCEDURE:  add_bdir,dat,source
;PURPOSE:
;    Adds magnetic field direction [theta,phi] to a 3d structure
;    The new structure element will be a two element vector [theta,phi]
;    with the tag name 'bdir'.
;INPUT:
;    dat:   3D data structure        (i.e. from 'GET_EL')
;    [source] : String index that points to magnetic field data.
;Notes:
;    	Magnetic field data must be loaded first.  
;	See 'GET_MFI'
;-
pro add_bdir,dat,source
if not keyword_set(source) then source = 'Bexp'
t = (dat.time+dat.end_time)/2
b = data_cut(source,t)
cart_to_sphere,b(0),b(1),b(2),r,th,ph
bdir = [th,ph]
str_element,/add,dat,'bdir',bdir

end

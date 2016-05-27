; +
;PROCEDURE:  add_vsw,dat,source
;PURPOSE:  
;       Adds solar wind velocity [Vx,Vy,Vz] to a 3d data structure.
;       The new structure element will be a three element vector [Vx,Vy,Vz]
;       with the tag name 'vsw'.
;INPUT:
;     dat:   3D structure (obtained from get_??() routines)
;  source:   string; name of tplot structure that holds vsw data.
;           
;Notes:
;       Proton moment data must be loaded first.  
;       If 'source' is present, it will use proton moment data source
;       Else it will perform a velocity moment on the structure to get 'vd'
;Example:
;    add_vsw,eldat,'Vp'
; -
pro add_vsw,dat,source

case data_type(source) of
   0:           vd=!values.f_nan
   7:           vd = data_cut(source,(dat.time+dat.end_time)/2)
   8:           vd = data_cut(source,(dat.time+dat.end_time)/2)
   else:        vd = source
endcase

dat.vsw = vd
;add_str_element,dat,'vsw',vd

end

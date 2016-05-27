;+
;Procedure: 
;  get_convect_vel
;Purpose:
;  generates convection velocity:  -((V x B) x B)/B^2

pro get_convect_vel,vel=vel,mag=mag,newname=name
if data_type(vel) ne 7 then begin
  vel=''
  read,vel,prompt='Velocity name? '
endif

if data_type(mag) ne 7 then begin
  mag=''
  read,mag,prompt='Field direction name? '
endif

get_data,vel,ptr=vp
v = *vp.y

b = data_cut(mag,*vp.x)

help,v,b

b2 = total(b*b,2)
e = crossp2(b,v)
vc = crossp2(e,b)
vc = vc / (b2 # replicate(1.,3))

if not keyword_set(name) then name=vel+'_conv'

store_data,name,data={x:vp.x, y:vc}


end

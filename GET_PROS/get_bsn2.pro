;+
;PROGRAM:	get_bsn2,PNAME=pname,BNAME=bname,VNAME=vname,BOW=bow,
;			intpos=intpos
;
;INPUT OPTIONS 
;	pname:	string,		Name of orbital position structure
;				Default is 'wi_pos'
;	bname:	string,		Name of magnetic field structure  
;				Default is 'wi_B3'
;	vname:  string,		Name of solar wind velocity structure
;				Default is 'wi_pm_Vp'
;	bow:	structure	Bow Shock parameters
;				Default bow={standoff:23.5,eccentricity:1.15,x_offset:3.0}
;PURPOSE:
;	Generates tplot structures for intersection of Bow Shock and s/c B-field line.
;	Generates the following structures:
;               th_bn: the angle (in degrees) between shock normal and the
;                       field line that passes through the spacecraft
;               l1: the distance along the field line to the shock
;               l2: the distance from a point that is missdist from the
;                       spacecraft in x to the tangent point
;               d,m: the distance along x from the spacecraft to a point
;                       where the B field line would be tangent to the
;                       bow shock.  A positive d means that the field
;                       line has already intersected the shock.  A positive
;			m indicates that the field line has not yet intersected
;                       the shock.
;       All distances are in Re. l1 and l2 are negative if the field line is
;	anti-parallel to the vector connecting the spacecraft and the point
;	of field line intersection.
;OPTIONAL OUTPUT:
;	intpos:	array of position vectors giving points where bow shock
;		intersects B field line that passes through spacecraft
;CREATED BY:
;	P.Schroeder
;LAST MODIFICATION:
;	@(#)get_bsn2.pro	1.5 02/04/17
;-
pro get_bsn2,PNAME=pname,BNAME=bname,VNAME=vname,BOW=bow,intpos=intpos

if not keyword_set(pname) then pname='wi_pos'
if not keyword_set(bname) then bname='wi_B3'
;if not keyword_set(vel) then vel=3.e5
if not keyword_set(vname) then vname='wi_pm_Vp'

if keyword_set(bow)  then begin
   if data_type(bow) ne 8 then $
          bow={standoff:23.5,eccentricity:1.15,x_offset:3.0}
endif else begin
          bow={standoff:23.5,eccentricity:1.15,x_offset:3.0}
endelse

get_data,bname,data=bfld
pos=data_cut(pname,bfld.x)
vp=data_cut(vname,bfld.x)

px=pos(*,0)
py=pos(*,1)
pz=pos(*,2)
bx=bfld.y(*,0)
by=bfld.y(*,1)
bz=bfld.y(*,2)
vx=vp(*,0)
vy=vp(*,1)
vz=vp(*,2)
vmag = sqrt(vx^2+vy^2+vz^2)

bsnarr = cal_bsn2(px,py,pz,bx,by,bz,vmag,bow=bow)
intpos = bsnarr.intpos

str_element,/add,bsnarr,'time',bfld.x

nam='bsn'
store_data,nam,data=bsnarr
str_th_bn = {ytitle:"!4h!X!DBn!U",max_value:1.e19,yrange:[0.,180.],ystyle:1,misc:bow}
store_data,nam+'.TH_BN',dlim=str_th_bn
str_l = {ytitle:"L",max_value:1.e19,yrange:[-200.,200.],misc:bow}
store_data,nam+'.L',dlim=str_l
str_lc = {ytitle:"LC",max_value:1.e19,yrange:[-200.,200.],misc:bow}
store_data,nam+'.LC',dlim=str_lc
str_lm = {ytitle:"LM",max_value:1.e19,yrange:[-200.,200.],misc:bow}
store_data,nam+'.LM',dlim=str_lm
str_d = {ytitle:"D",max_value:1.e19,yrange:[0.,200.],misc:bow}
store_data,nam+'.D',dlim=str_d
str_m = {ytitle:"M",max_value:1.e19,yrange:[0.,200.],misc:bow}
store_data,nam+'.M',dlim=str_m
str_vc = {ytitle:"Vc",max_value:1.e19,yrange:[-20000.,20000.],misc:bow}
store_data,nam+'.VC',dlim=str_vc
str_intpos = {ytitle:"Intpos",max_value:1.e19,misc:bow}
store_data,nam+'.INTPOS',dlim=str_intpos
str_intpos = {ytitle:"normal",max_value:1.e19,misc:bow}
str_normal = {ytitle:"norm",misc:bow}
store_data,nam+'.NORMAL',dlim=str_normal

print,'number of points = ',n_elements(bfld.x)

return
end

; +
;PROCEDURE:  accum_df2d,dat,VLIM=vlim,NGRID=ngrid,MINCNT=mincnt
;PURPOSE:  
;	Adds 2D pitch angle distribution (df2d, vx2d, vy2d) to a 3d structure
;	Also adds dat.df2dz, dat.vx2dz, dat.vy2dz to dat structure.
;
;	df2d, vx2d and vy2d are the interpolated two dimensional 
;	distribution function and velocity in the x-y plane.
;	df2d is generated from df by folding pitch angles with vy>0
;	and vy<0 to opposite sides of vy in df2d to allow some 
;	measure of non-gyrotropic distributions.
;	df2dz, vx2dz and vy2dz are interpolated to the x-z plane.
;
;	"x" is along the magnetic field, the "x-y" plane is defined
;	to contain the magnetic field and the drift velocity,
;	and the reference frame is transformed to the drift frame.
;
;INPUT:
;	dat:		3D structure (obtained from get_??() routines)
;			e.g. "GET_PH"
;KEYWORDS:
;	mincnt:		If present, this minimum count level gets
;			added to all angle bins.  Used to smooth
;			noisy contour plots.  
;			Default : mincnt=0.  (You may want to use mincnt=.5)
;	vlim		Velocity (km/s) limit for the vx2d, vy2d arrays
;			vx2d,vy2d arrays have 101 elements from -vlim to +vlim
;			Default is vlim=2500. for pesah
;			Default is vlim=2500. for eesal
;Notes:
;    	Magnetic field direction must be present in dat, dat.magf.  
;	See "GET_MFI"
;	See "ADD_MAGF"
;    	Drift velocity must be present in dat, dat.vsw.  
;	See "GET_PMOM" and "ADD_VSW"
;
;	Currently all velocities are assumed non-relativistic.
;
;Created by: Davin Larson   1995-10-08
;Modified from routine by J.P.McFadden  9-15-95
; -
pro accum_df2d, dat, df2d,VLIM=vlim,NGRID=ngrid,MINCNT=mincnt

if data_type(df2d) ne 8 then begin
    df2d = dat
endif

if not keyword_set(mincnt) then mincnt=0.
if not keyword_set(vlim) then vlim = max(sqrt(2*dat.energy/dat.mass)) $
else vlim = float(vlim)

str_element,dat,'magf',val=magfield
str_element,dat,'vsw',val=vsw
str_element,dat,'bins',val=bins

nbins=dat.nbins
nenergy=dat.nenergy

case ndimen(bins) of
   -1 or 0: ind = indgen(nenergy*nbins)
    1:      ind = where(replicate(1,nenergy) # bins)
    2:      ind = where(bins)
endcase

ndat = conv_units(dat,'df')
df_dat = ndat.data(ind)

;Relativistic velocity:  (momentum/mass)  (km/s)
; vmag=(2.*ndat.energy(ind)/dat.mass)^.5 ; Not relativistic!
vmag = velocity(ndat.energy(ind),mass,/mom)

theta = ndat.theta(ind)
phi = ndat.phi(ind)

nd = n_elements(ind)

sphere_to_cart,vmag,theta,phi,vx,vy,vz

vel = [[vx],[vy],[vz]]
vel = vel - replicate(1.,nd) # vsw

rot = rot_mat(magfield,vsw)
vd2d=reform(vsw # rot)

newvel = vel # rot


cart_to_sphere,newvel(*,0),newvel(*,1),newvel(*,2),vmag,theta,phi

newphi = 0.
sphere_to_cart,vmag,theta,newphi,vperp_dat,dummy,vpar_dat

add_str_element,dat,'vsw2d',vd2d
add_str_element,dat,'df_dat',df_dat
add_str_element,dat,'vperp_dat',vperp_dat
add_str_element,dat,'vpar_dat',vpar_dat
add_str_element,dat,'phi_dat',phi

vperp_dat = [vperp_dat,-vperp_dat]
vpar_dat = [vpar_dat,vpar_dat]
df_dat   = [df_dat,df_dat]

triangulate, vpar_dat, vperp_dat, tr

if not keyword_set(ngrid) then ngrid = 50
gs=[vlim,vlim]/ngrid
xylim=[-1*vlim,-1*vlim,vlim,vlim]

df2d  = trigrid(vpar_dat, vperp_dat, df_dat, tr, gs, xylim)
;vpar2d  = trigrid(vpar_dat, vperp_dat, vpar_dat, tr, gs, xylim)
;vperp2d = trigrid(vpar_dat, vperp_dat, vperp_dat, tr, gs, xylim)
vpar2d  = -1.*vlim+gs(0)*findgen(fix((2.*vlim)/gs(0))+1)
vperp2d = -1.*vlim+gs(1)*findgen(fix((2.*vlim)/gs(1))+1)
add_str_element,dat,'df2d',df2d
add_str_element,dat,'vpar2d',vpar2d
add_str_element,dat,'vperp2d',vperp2d

end

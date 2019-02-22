;+
;*****************************************************************************************
;
;  FUNCTION :   trans_vframe_htr.pro
;  PURPOSE  :   This routine transforms a 3DP data structure into the solar wind frame
;                 and rotates the resultant data into two new coordinate bases defined
;                 by the HTR MFI B-field data and VSW IDL structure tag.
;
;  CALLED BY:   
;               df_htr_contours_3d.pro
;
;  CALLS:
;               conv_units.pro
;               timestamp_3dp_angle_bins.pro
;               velocity.pro
;               interp.pro
;               my_crossp_2.pro
;               str_element.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               DAT        :  3DP data structure either from get_??.pro
;                               with defined structure tag quantities for VSW and
;                               MAGF
;               BGSE_HTR   :  HTR B-field structure of format:
;                               {X:Unix Times, Y:[K,3]-Element Vector}
;               SPRATE     :  Scalar defining the spin rate [deg/s] of the Wind
;                               spacecraft
;
;  EXAMPLES:    
;               NA
;
;  KEYWORDS:    
;               VLIM       :  Limit for x-y velocity axes over which to plot data
;                               [Default = max vel. from energy bin values]
;               NGRID      :  # of isotropic velocity grids to use to triangulate the data
;                               [Default = 50L]
;
;   CHANGED:  1)  Now removes energies < 1.3 * (SC Pot)            [02/22/2012   v1.1.0]
;
;   NOTES:      
;               1)  HTR = High Time Resolution
;               2)  MFI = Magnetic Field Investigation
;               3)  This routine is only verified for EESA Low so far!!!
;
;   CREATED:  02/01/2012
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  02/22/2012   v1.1.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

PRO trans_vframe_htr,dat,bgse_htr,sprate,VLIM=vlim,NGRID=ngrid

;-----------------------------------------------------------------------------------------
; => Define some constants and dummy variables
;-----------------------------------------------------------------------------------------
f        = !VALUES.F_NAN
d        = !VALUES.D_NAN
;-----------------------------------------------------------------------------------------
; => Check input
;-----------------------------------------------------------------------------------------
IF (N_PARAMS() NE 3) THEN RETURN
data     = conv_units(dat[0],'df')     ; => convert to phase space density
sprated  = sprate[0]

IF NOT KEYWORD_SET(ngrid) THEN ngrid = 20L
IF NOT KEYWORD_SET(vlim) THEN BEGIN
  vlim = MAX(SQRT(2*data.ENERGY/data.MASS),/NAN)
ENDIF ELSE BEGIN
  vlim = FLOAT(vlim)
ENDELSE
xylim    = [-1*vlim,-1*vlim,vlim,vlim]
dgs      = vlim/5e1
gs       = [dgs,dgs]
dumb1d   = REPLICATE(d,101L)
dumb2d   = REPLICATE(d,101L,101L)
;-----------------------------------------------------------------------------------------
; => Check for finite vector in VSW IDL structure tags
;-----------------------------------------------------------------------------------------
v_vsws   = REFORM(dat[0].VSW)
test_v   = TOTAL(FINITE(v_vsws)) NE 3
; => If only test_v = TRUE, then use Sun Direction
IF (test_v) THEN BEGIN
  v_vsws     = [1.,0.,0.]
  dat[0].VSW = v_vsws
ENDIF
;-----------------------------------------------------------------------------------------
; => Determine the time stamps for each angle bin
;-----------------------------------------------------------------------------------------
; [N,M]-Element array
;    N = # of energy bins
;    M = # of angle bins
t_3dp    = timestamp_3dp_angle_bins(data,sprated[0])
;-----------------------------------------------------------------------------------------
; => Define DAT structure parameters
;-----------------------------------------------------------------------------------------
n_e      = data.NENERGY            ; => # of energy bins
n_a      = data.NBINS              ; => # of angle bins
ind_2d   = INDGEN(n_e,n_a)         ; => original indices of angle bins

energy   = data.ENERGY             ; => Energy bin values [eV]
; => Shift energies by SC-Potential
energy  -= data.SC_POT[0]
df_dat   = data.DATA               ; => Data values [data.UNITS_NAME]

phi      = data.PHI                ; => Azimuthal angle (from sun direction) [deg]
dphi     = data.DPHI               ; => Uncertainty in phi
theta    = data.THETA              ; => Poloidal angle (from ecliptic plane) [deg]
dtheta   = data.DTHETA             ; => Uncertainty in theta

tacc     = data.DT                 ; => Accumulation time [s] of each angle bin
t0       = data.TIME[0]            ; => Unix time at start of 3DP sample period
t1       = data.END_TIME[0]        ; => Unix time at end of 3DP sample period
del_t    = t1[0] - t0[0]           ; => Total time of data sample
;-----------------------------------------------------------------------------------------
; => Reform 2D arrays into 1D
;-----------------------------------------------------------------------------------------
phi_1d   = REFORM(phi,n_e*n_a)
the_1d   = REFORM(theta,n_e*n_a)
dat_1d   = REFORM(df_dat,n_e*n_a)
ener_1d  = REFORM(energy,n_e*n_a)
ind_1d   = REFORM(ind_2d,n_e*n_a)
t3dp_1d  = REFORM(t_3dp,n_e*n_a)
;-----------------------------------------------------------------------------------------
; => Remove data associated with negative energies
;-----------------------------------------------------------------------------------------
low_en   = WHERE(ener_1d LE 0. OR ener_1d LT scpot[0]*1.3,lwe)
IF (lwe GT 0L) THEN BEGIN
  dat_1d[low_en]  = f
  ener_1d[low_en] = f
  phi_1d[low_en]  = f
  the_1d[low_en]  = f
ENDIF
;-----------------------------------------------------------------------------------------
; => Define 3DP velocities in solar wind frame
;-----------------------------------------------------------------------------------------
; => Magnitude of velocities from energy (km/s)
vmag      = velocity(ener_1d,data[0].MASS[0],/TRUE)
coth      = COS(data.THETA*!DPI/18d1)
sith      = SIN(data.THETA*!DPI/18d1)
coph      = COS(data.PHI*!DPI/18d1)
siph      = SIN(data.PHI*!DPI/18d1)
; => Define directions
mvel      = DBLARR(n_e*n_a,3L)
mvel[*,0] = vmag*coth*coph            ; => Define X-Velocity per energy per data bin
mvel[*,1] = vmag*coth*siph            ; => Define Y-Velocity per energy per data bin
mvel[*,2] = vmag*sith                 ; => Define Z-Velocity per energy per data bin
; => Subtract off solar wind speed
swfv      = DBLARR(n_e*n_a,3L)
swfv[*,0] = mvel[*,0] - v_vsws[0]
swfv[*,1] = mvel[*,1] - v_vsws[1]
swfv[*,2] = mvel[*,2] - v_vsws[2]
; => Define new magnitudes
nvmag     = SQRT(TOTAL(swfv^2,2,/NAN))
;-----------------------------------------------------------------------------------------
; => Define BGSE_HTR structure parameters
;-----------------------------------------------------------------------------------------
htr_t    = bgse_htr.X        ; => Unix times
htr_b    = bgse_htr.Y        ; => GSE B-field [nT]
; => Interpolate HTR MFI data to 3dp angle bin times
magfx    = interp(htr_b[*,0],htr_t,t3dp_1d,/NO_EXTRAP)
magfy    = interp(htr_b[*,1],htr_t,t3dp_1d,/NO_EXTRAP)
magfz    = interp(htr_b[*,2],htr_t,t3dp_1d,/NO_EXTRAP)
bmag     = SQRT(magfx^2 + magfy^2 + magfz^2)
; => define corresponding unit vectors
umagfx   = magfx/bmag
umagfy   = magfy/bmag
umagfz   = magfz/bmag
umagf    = [[umagfx],[umagfy],[umagfz]]
;-----------------------------------------------------------------------------------------
; => Define rotation to plane containing Bo and Vsw
;-----------------------------------------------------------------------------------------
v1       = umagf
; => Calculate Rotation Vectors
uvsw     = v_vsws/SQRT(TOTAL(v_vsws^2,/NAN))      ; => Normalize
esw      = -1d0*my_crossp_2(uvsw,v1,/NOM)         ;  -(Vsw x Bo) = Bo x Vsw
uesw     = esw/(SQRT(TOTAL(esw^2,2L,/NAN)) # REPLICATE(1d0,3L))
exbsw    = -1d0*my_crossp_2(v1,uesw,/NOM)         ;  -Bo x (Bo x Vsw)
uexb     = exbsw/(SQRT(TOTAL(exbsw^2,2L,/NAN)) # REPLICATE(1d0,3L))
v2       = uexb                                   ;  -Bo x (Bo x Vsw) = Esw x Bo
v3       = uesw                                   ;  -(Vsw x Bo) = Esw
; => Define rotation matrices
rot_vbp  = DBLARR(n_e*n_a,3L,3L)
rot_vbp[*,0,*] = v1
rot_vbp[*,1,*] = v2
rot_vbp[*,2,*] = v3
; => Transpose the last two dimensions
rot_vbp  = TRANSPOSE(rot_vbp,[0,2,1])
;-----------------------------------------------------------------------------------------
; => Define 2nd rotation matrices
;-----------------------------------------------------------------------------------------
v1       = umagf                                  ;   Bo
v2       = uesw                                   ;   Bo x Vsw = - (Vsw x Bo)
v3       = uexb                                   ;  -Bo x (Bo x Vsw) = Esw x Bo
; => Define rotation matrices
rot_ebp  = DBLARR(n_e*n_a,3L,3L)
rot_ebp[*,0,*] = v1
rot_ebp[*,1,*] = v2
rot_ebp[*,2,*] = v3
; => Transpose the last two dimensions
rot_ebp  = TRANSPOSE(rot_ebp,[0,2,1])
;-----------------------------------------------------------------------------------------
; => Rotate 3DP velocities into 2 new planes
;-----------------------------------------------------------------------------------------
swv1     = DBLARR(n_e*n_a,3L)  ; => velocities in 1st plane
swv2     = DBLARR(n_e*n_a,3L)  ; => velocities in 2nd plane
FOR j=0L, n_e*n_a - 1L DO BEGIN
  swv1[j,*] = REFORM(REFORM(rot_vbp[j,*,*]) ## REFORM(swfv[j,*]))
  swv2[j,*] = REFORM(REFORM(rot_ebp[j,*,*]) ## REFORM(swfv[j,*]))
ENDFOR
;-----------------------------------------------------------------------------------------
; => Triangulate data in these planes
;-----------------------------------------------------------------------------------------
ffp1     = dat_1d
vel2dx_1 = REFORM(swv1[*,0])
vel2dy_1 = SQRT(TOTAL(swv1[*,1:2]^2,2,/NAN))*REFORM(swv1[*,1])/ABS(REFORM(swv1[*,1]))
vel2dz_1 = SQRT(TOTAL(swv1[*,1:2]^2,2,/NAN))*REFORM(swv1[*,2])/ABS(REFORM(swv1[*,2]))

ffp2     = dat_1d
vel2dx_2 = REFORM(swv2[*,0])
vel2dy_2 = SQRT(TOTAL(swv2[*,1:2]^2,2,/NAN))*REFORM(swv2[*,1])/ABS(REFORM(swv2[*,1]))
vel2dz_2 = SQRT(TOTAL(swv2[*,1:2]^2,2,/NAN))*REFORM(swv2[*,2])/ABS(REFORM(swv2[*,2]))
;-----------------------------------------------------------------------------------------
; => ONLY Finite data is allowed in TRIANGULATE.PRO and TRIGRID.PRO
;-----------------------------------------------------------------------------------------
indx   = WHERE(FINITE(ffp1) EQ 1 AND ffp1 GE 0.,cnt)
IF (cnt GT 0L) THEN BEGIN
  vel2dx_1 = vel2dx_1[indx]
  vel2dy_1 = vel2dy_1[indx]
  vel2dz_1 = vel2dz_1[indx]
  ffp1     = ffp1[indx]
  ;---------------------------------------------------------------------------------------
  ; => X-Y Plane projection
  ;---------------------------------------------------------------------------------------
  TRIANGULATE, vel2dx_1, vel2dy_1, tr, bound
  df2d_1   = TRIGRID(vel2dx_1,vel2dy_1,ffp1,tr,gs,xylim)
  ;---------------------------------------------------------------------------------------
  ; => X-Z Plane projection
  ;---------------------------------------------------------------------------------------
  TRIANGULATE, vel2dx_1, vel2dz_1, tr
  df2dz_1  = TRIGRID(vel2dx_1,vel2dz_1,ffp1,tr,gs,xylim)
  vx2dz_1  = TRIGRID(vel2dx_1,vel2dz_1,vel2dx_1,tr,gs,xylim)
  vy2dz_1  = TRIGRID(vel2dx_1,vel2dz_1,vel2dz_1,tr,gs,xylim)
  ;---------------------------------------------------------------------------------------
  ; => Force regularly grided velocities (for contour plots)
  ;---------------------------------------------------------------------------------------
  vx2d_1   = -1e0*vlim[0] + gs[0]*FINDGEN(FIX((2e0*vlim[0])/gs[0]) + 1L)
  vy2d_1   = -1e0*vlim[0] + gs[1]*FINDGEN(FIX((2e0*vlim[0])/gs[1]) + 1L)
ENDIF ELSE BEGIN
  MESSAGE,'No finite data for plane 1',/CONTINUE,/INFORMATIONAL
  df2d_1   = dumb2d
  vx2d_1   = dumb1d
  vy2d_1   = dumb1d
  df2dz_1  = dumb2d
  vx2dz_1  = dumb2d
  vy2dz_1  = dumb2d
ENDELSE

indx   = WHERE(FINITE(ffp2) EQ 1 AND ffp2 GE 0.,cnt)
IF (cnt GT 0L) THEN BEGIN
  vel2dx_2 = vel2dx_2[indx] 
  vel2dy_2 = vel2dy_2[indx]
  vel2dz_2 = vel2dz_2[indx]
  ffp2     = ffp2[indx]
  ;---------------------------------------------------------------------------------------
  ; => X-Y Plane projection
  ;---------------------------------------------------------------------------------------
  TRIANGULATE, vel2dx_2, vel2dy_2, tr, bound
  df2d_2   = TRIGRID(vel2dx_2,vel2dy_2,ffp2,tr,gs,xylim)
  ;---------------------------------------------------------------------------------------
  ; => X-Z Plane projection
  ;---------------------------------------------------------------------------------------
  TRIANGULATE, vel2dx_2, vel2dz_2, tr
  df2dz_2  = TRIGRID(vel2dx_2,vel2dz_2,ffp2,tr,gs,xylim)
  vx2dz_2  = TRIGRID(vel2dx_2,vel2dz_2,vel2dx_2,tr,gs,xylim)
  vy2dz_2  = TRIGRID(vel2dx_2,vel2dz_2,vel2dz_2,tr,gs,xylim)
  ;---------------------------------------------------------------------------------------
  ; => Force regularly grided velocities (for contour plots)
  ;---------------------------------------------------------------------------------------
  vx2d_2   = -1e0*vlim[0] + gs[0]*FINDGEN(FIX((2e0*vlim[0])/gs[0]) + 1L)
  vy2d_2   = -1e0*vlim[0] + gs[1]*FINDGEN(FIX((2e0*vlim[0])/gs[1]) + 1L)
ENDIF ELSE BEGIN
  MESSAGE,'No finite data for plane 2',/CONTINUE,/INFORMATIONAL
  df2d_2   = dumb2d
  vx2d_2   = dumb1d
  vy2d_2   = dumb1d
  df2dz_2  = dumb2d
  vx2dz_2  = dumb2d
  vy2dz_2  = dumb2d
ENDELSE
;-----------------------------------------------------------------------------------------
; => Create new data structure
;-----------------------------------------------------------------------------------------
tags0    = ['PLANE_1','PLANE_2']
tags1    = ['DF2D','VX2D','VY2D','VX_PTS','VY_PTS','VZ_PTS','DF2DZ','VX2DZ','VY2DZ']
p1_str   = CREATE_STRUCT(tags1,df2d_1,vx2d_1,vy2d_1,vel2dx_1,vel2dy_1,vel2dz_1,$
                               df2dz_1,vx2dz_1,vy2dz_1)
p2_str   = CREATE_STRUCT(tags1,df2d_2,vx2d_2,vy2d_2,vel2dx_2,vel2dy_2,vel2dz_2,$
                               df2dz_2,vx2dz_2,vy2dz_2)
new_str  = CREATE_STRUCT(tags0,p1_str,p2_str)
;-----------------------------------------------------------------------------------------
; => Add new data to original structure
;-----------------------------------------------------------------------------------------
str_element,dat,'NEW_DFS',new_str,/ADD_REPLACE
str_element,dat,'ROT_MAT_P1',rot_vbp,/ADD_REPLACE
str_element,dat,'ROT_MAT_P2',rot_ebp,/ADD_REPLACE
;-----------------------------------------------------------------------------------------
; => Return new/altered data structure
;-----------------------------------------------------------------------------------------

RETURN
END
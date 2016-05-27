;+
;*****************************************************************************************
;
;  PROCEDURE:   rotate_3dp_htr_structure.pro
;  PURPOSE  :   Rotates a 3DP data structure into coordinate system defined by user
;                 defined keyword inputs.  The routine adds tags to the input structure
;                 that define triangulated data in three plane projections.  The routine
;                 uses high time resolution (HTR) magnetic field data for each
;                 [Energy,Theta,Phi]-data point to reduce aliasing from a rapidly
;                 rotating magnetic field.
;                 The new structure tags are:
;                   VX2D[VY2D]  :  Regularly gridded velocities to use as X[Y]-axis
;                                    input for contour plot outputs
;                   DF2D_JK     :  Regularly gridded phase space densities projected
;                                    onto the JK-Plane [e.g. XY-Plane]
;                   VELX_JK     :  Horizontal axis velocities (actual data) that can be
;                                    projected onto contours to show where actual data
;                                    points were observed in JK-Plane
;                   VELY_JK     :  Vertical axis velocities (actual data) that can be
;                                    projected onto contours to show where actual data
;                                    points were observed in JK-Plane
;                   VELZ_JK     :  Velocities orthogonal to plane containing DF2D_JK
;                   ROT_MAT     :  [3,3]-Element array defining the rotation matrix to
;                                    convert from the input basis to new rotated basis
;                   ROT_MAT_Z   :  [3,3]-Element array defining the rotation matrix to
;                                    convert from the input basis to the YZ-Projection
;
;  CALLED BY:   
;               contour_3d_htr_1plane.pro
;
;  CALLS:
;               test_wind_vs_themis_esa_struct.pro
;               dat_3dp_str_names.pro
;               conv_units.pro
;               tplot_struct_format_test.pro
;               timestamp_3dp_angle_bins.pro
;               energy_to_vel.pro
;               interp.pro
;               rot_matrix_array_dfs.pro
;               rotate_and_triangulate_dfs.pro
;               str_element.pro
;               extract_tags.pro
;
;  REQUIRES:    
;               1)  THEMIS TDAS IDL libraries or UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               DAT        :  3DP data structure either from get_??.pro
;                               with defined structure tag quantities for VSW
;               BGSE_HTR   :  HTR B-field structure of format:
;                               {X:Unix Times, Y:[K,3]-Element Vector}
;               VECTOR2    :  3-Element vector to be used to define the plane made with
;                               BGSE_HTR  [Default = {0.,1.,0.} but Vsw is more physical]
;               SPRATE     :  Scalar defining the spin rate [deg/s] of the spacecraft
;                               [Default = 120.0  (i.e. 3s spin period)]
;
;  EXAMPLES:    
;               
;
;  KEYWORDS:    
;               VLIM       :  Limit for x-y velocity axes over which to plot data
;                               [Default = max vel. from energy bin values]
;
;   CHANGED:  1)  Fixed an indexing error in the equivalent cal_rot.pro rotation
;                   matrix definition section                      [07/09/2012   v1.1.0]
;             2)  Now calls rot_matrix_array_dfs.pro, rotate_and_triangulate_dfs.pro,
;                   and extract_tags.pro and no longer calls my_crossp_2.pro and
;                   removed obsolete keyword NGRID
;                                                                  [08/08/2012   v1.2.0]
;
;   NOTES:      
;               1)  This routine modifies the input structure, DAT, so make sure
;                     you make a copy of the original prior to calling.
;               2)  To be useful, the data should be transformed into the solar wind
;                     frame prior to calling this routine.
;               3)  See also:  rotate_3dp_structure.pro
;               4)  This routine is only verified for EESA Low so far!!!
;
;   CREATED:  05/24/2012
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  08/08/2012   v1.2.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

PRO rotate_3dp_htr_structure,dat,bgse_htr,vector2,sprate,VLIM=vlim

;-----------------------------------------------------------------------------------------
; => Define some constants and dummy variables
;-----------------------------------------------------------------------------------------
f          = !VALUES.F_NAN
d          = !VALUES.D_NAN
; => Dummy error messages
notstr_msg     = 'Must be an IDL structure...'
nottplot_mssg  = 'Not an appropriate TPLOT structure...'
notel_mssg     = 'This routine is only verified for EESA Low so far!!!'
;-----------------------------------------------------------------------------------------
; => Check DAT input
;-----------------------------------------------------------------------------------------
test0      = test_wind_vs_themis_esa_struct(dat,/NOM)
test       = (test0.(0) + test0.(1)) NE 1
IF (test) THEN BEGIN
  MESSAGE,notstr_msg,/INFORMATIONAL,/CONTINUE
  RETURN
ENDIF

data       = dat[0]
; => convert to phase space density
IF (test0.(0)) THEN BEGIN
  ;-------------------------------------------
  ; Wind
  ;-------------------------------------------
  ; => Check which instrument is being used
  strns   = dat_3dp_str_names(data[0])
  IF (SIZE(strns,/TYPE) NE 8) THEN BEGIN
    RETURN
  ENDIF
  shnme   = STRLOWCASE(STRMID(strns.SN[0],0L,2L))
  CASE shnme[0] OF
    'el' : BEGIN
      data   = conv_units(data,'df')
    END
    ELSE : BEGIN
      MESSAGE,notel_mssg[0],/INFORMATIONAL,/CONTINUE
      RETURN
    END
  ENDCASE
ENDIF ELSE BEGIN
  ;-------------------------------------------
  ; Not a Wind 3DP structure
  ;-------------------------------------------
  MESSAGE,notel_mssg[0],/INFORMATIONAL,/CONTINUE
  RETURN
ENDELSE
;-----------------------------------------------------------------------------------------
; => Check BGSE_HTR structure format
;-----------------------------------------------------------------------------------------
test  = tplot_struct_format_test(bgse_htr,/YVECT)
IF (NOT test) THEN BEGIN
  MESSAGE,nottplot_mssg,/INFORMATIONAL,/CONTINUE
  RETURN
ENDIF
;-----------------------------------------------------------------------------------------
; => Check VECTOR2 and SPRATE
;-----------------------------------------------------------------------------------------
IF (N_ELEMENTS(vector2) NE 3) THEN vec2    = [0.,1.,0.] ELSE vec2    = REFORM(vector2)
IF (N_ELEMENTS(sprate)  NE 1) THEN sprated = 120d0      ELSE sprated = REFORM(sprate[0])
;-----------------------------------------------------------------------------------------
; => Check keywords
;-----------------------------------------------------------------------------------------
IF NOT KEYWORD_SET(vlim) THEN BEGIN
  vlim = MAX(SQRT(2*data[0].ENERGY/data[0].MASS),/NAN)
ENDIF ELSE BEGIN
  vlim = FLOAT(vlim)
ENDELSE
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
kk       = n_e*n_a
ind_2d   = INDGEN(n_e,n_a)         ; => original indices of angle bins

energy   = data.ENERGY             ; => Energy bin values [eV]
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
;      K = N * M
;-----------------------------------------------------------------------------------------
phi_1d   = REFORM(phi,kk)
the_1d   = REFORM(theta,kk)
dat_1d   = REFORM(df_dat,kk)
ener_1d  = REFORM(energy,kk)
ind_1d   = REFORM(ind_2d,kk)
t3dp_1d  = REFORM(t_3dp,kk)
;-----------------------------------------------------------------------------------------
; => Define 3DP velocities in solar wind frame
;-----------------------------------------------------------------------------------------
; => Magnitude of velocities from energy (km/s)
nvmag     = energy_to_vel(ener_1d,data[0].MASS[0])
coth      = COS(the_1d*!DPI/18d1)
sith      = SIN(the_1d*!DPI/18d1)
coph      = COS(phi_1d*!DPI/18d1)
siph      = SIN(phi_1d*!DPI/18d1)
; => Define directions
swfv      = DBLARR(kk,3L)              ;  [K,3]-Element array
swfv[*,0] = nvmag*coth*coph            ; => Define X-Velocity per energy per data bin
swfv[*,1] = nvmag*coth*siph            ; => Define Y-Velocity per energy per data bin
swfv[*,2] = nvmag*sith                 ; => Define Z-Velocity per energy per data bin
;-----------------------------------------------------------------------------------------
; => Define BGSE_HTR structure parameters
;-----------------------------------------------------------------------------------------
htr_t    = bgse_htr.X        ; => Unix times
htr_b    = bgse_htr.Y        ; => GSE B-field [nT]
; => Interpolate HTR MFI data to 3dp angle bin times
magfx    = interp(htr_b[*,0],htr_t,t3dp_1d,/NO_EXTRAP)  ;; [K]-Element array
magfy    = interp(htr_b[*,1],htr_t,t3dp_1d,/NO_EXTRAP)  ;; [K]-Element array
magfz    = interp(htr_b[*,2],htr_t,t3dp_1d,/NO_EXTRAP)  ;; [K]-Element array
bmag     = SQRT(magfx^2 + magfy^2 + magfz^2)            ;; [K]-Element array
; => define corresponding unit vectors
umagfx   = magfx/bmag
umagfy   = magfy/bmag
umagfz   = magfz/bmag
umagf    = [[umagfx],[umagfy],[umagfz]]                 ;; [K,3]-Element array
;-----------------------------------------------------------------------------------------
; => Define rotation to plane containing Bo and Vsw
;-----------------------------------------------------------------------------------------
v1       = umagf
v2       = vec2/NORM(vec2)  ;; normalize
v2d       = REPLICATE(1d0,kk) # v2      ;; [K,3]-Element array
;;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;; => Define rotation matrices equivalent to cal_rot.pro
;;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
rotm      = rot_matrix_array_dfs(v1,v2d,/CAL_ROT)  ;;  [K,3,3]-element array
;;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;; => Define rotation matrices equivalent to rot_mat.pro
;;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
rotz      = rot_matrix_array_dfs(v1,v2d)           ;;  [K,3,3]-element array
;;----------------------------------------------------------------------------------------
;; => Rotate velocities into new coordinate basis and triangulate
;;----------------------------------------------------------------------------------------
r_vels    = rotate_and_triangulate_dfs(swfv,dat_1d,rotm,rotz,VLIM=vlim)
;; => Regularly gridded velocities (for contour plots)
vx2d      = r_vels.VX2D
vy2d      = r_vels.VY2D

str_xy    = r_vels.PLANE_XY
str_xz    = r_vels.PLANE_XZ
str_yz    = r_vels.PLANE_YZ
;; => Add these parameters to the ESA data structure
str_element,data,'VX2D',vx2d,/ADD_REPLACE
str_element,data,'VY2D',vy2d,/ADD_REPLACE

extract_tags,data,str_xy
extract_tags,data,str_xz
extract_tags,data,str_yz
;; => X-Y and X-Z Plane projection rotation
str_element,data,'ROT_MAT',rotm,/ADD_REPLACE
;; => Y-Z Plane projection rotation
str_element,data,'ROT_MAT_Z',rotz,/ADD_REPLACE
;;----------------------------------------------------------------------------------------
;; => Return altered data structure to user
;;----------------------------------------------------------------------------------------
dat       = data

RETURN
END

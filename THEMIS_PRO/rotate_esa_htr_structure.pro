;+
;*****************************************************************************************
;
;  PROCEDURE:   rotate_esa_htr_structure.pro
;  PURPOSE  :   Rotates a THEMIS ESA data structure into coordinate system defined by
;                 user defined keyword inputs.  The routine adds tags to the input
;                 structure that define triangulated data in three plane projections.
;                 The routine uses high time resolution (HTR) magnetic field data
;                 for each [Energy,Theta,Phi]-data point to reduce aliasing from
;                 a rapidly rotating magnetic field.
;
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
;               
;
;  CALLS:
;               test_themis_esa_struc_format.pro
;               conv_units.pro
;               tplot_struct_format_test.pro
;               timestamp_esa_angle_bins.pro
;               rotate_esa_thetaphi_to_gse.pro
;               interp.pro
;               energy_to_vel.pro
;               rot_matrix_array_dfs.pro
;               rotate_and_triangulate_dfs.pro
;               str_element.pro
;               extract_tags.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               DAT        :  Scalar structure associated with a known THEMIS ESA Burst
;                               data structure
;                               [see get_th?_pe%b.pro, ? = a-f, % = i,e]
;               TI_ESA     :  [E,A]-Element array of timestamps [Unix] associated with
;                               the [THETA,PHI]-angle bins in DAT
;               BGSE_HTR   :  Magnetic field TPLOT structure of format:
;                               {X:Unix Times, Y:[K,3]-Element Vector}
;                               in GSE coordinates
;               VECTOR2    :  [3]-Element vector to be used to define the plane made
;                               with BGSE_HTR
;                               [Default = {0.,1.,0.} but Vsw is more physical]
;
;  EXAMPLES:    
;               
;
;  KEYWORDS:    
;               VLIM       :  Limit for x-y velocity axes over which to plot data
;                               [Default = max vel. from energy bin values]
;
;   CHANGED:  1)  Continued writing routine                        [08/08/2012   v1.0.0]
;
;   NOTES:      
;               1)  The routine assumes that DAT has been modified by:
;                     modify_themis_esa_struc.pro
;                     rotate_esa_thetaphi_to_gse.pro
;                       prior to calling
;                         => GSE coordinates
;               2)  To be useful, the data should be transformed into the solar wind
;                     frame prior to calling this routine.
;               3)  See also:  rotate_3dp_structure.pro or rotate_3dp_htr_structure.pro
;
;   CREATED:  08/07/2012
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  08/08/2012   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

PRO rotate_esa_htr_structure,data,ti_esa,bgse_htr,vector2,VLIM=vlim

;;----------------------------------------------------------------------------------------
;; => Define some constants and dummy variables
;;----------------------------------------------------------------------------------------
f          = !VALUES.F_NAN
d          = !VALUES.D_NAN
;; => Dummy error messages
notstr_msg     = 'Must be an IDL structure...'
nottplot_mssg  = 'Not an appropriate TPLOT structure...'
notel_mssg     = 'This routine is only verified for THEMIS ESA!'
;;----------------------------------------------------------------------------------------
;; => Check input structure format
;;----------------------------------------------------------------------------------------
IF (N_PARAMS() NE 4) THEN RETURN
str       = data[0]   ;; => in case it is an array of structures of the same format
IF (SIZE(str,/TYPE) NE 8L) THEN BEGIN
  MESSAGE,notstr_mssg,/INFORMATIONAL,/CONTINUE
  RETURN
ENDIF
test      = test_themis_esa_struc_format(str,/NOM) NE 1
IF (test) THEN RETURN

dat       = data[0]
;;----------------------------------------------------------------------------------------
;; => Convert to phase (velocity) space density
;;----------------------------------------------------------------------------------------
dat       = conv_units(dat,'df')
;;----------------------------------------------------------------------------------------
;; => Check VECTOR2
;;----------------------------------------------------------------------------------------
IF (N_ELEMENTS(vector2) NE 3) THEN vec2    = [0.,1.,0.] ELSE vec2    = REFORM(vector2)
;;----------------------------------------------------------------------------------------
;; => Check BGSE_HTR structure format
;;----------------------------------------------------------------------------------------
test  = tplot_struct_format_test(bgse_htr,/YVECT)
IF (NOT test) THEN BEGIN
  MESSAGE,nottplot_mssg,/INFORMATIONAL,/CONTINUE
  RETURN
ENDIF
;;----------------------------------------------------------------------------------------
;; => Check keywords
;;----------------------------------------------------------------------------------------
IF NOT KEYWORD_SET(vlim) THEN BEGIN
  vlim = MAX(SQRT(2*data[0].ENERGY/data[0].MASS),/NAN)
ENDIF ELSE BEGIN
  vlim = FLOAT(vlim)
ENDELSE
;;----------------------------------------------------------------------------------------
;; => Define the time stamps for each angle bin
;;----------------------------------------------------------------------------------------
;; [E,A]-Element array
;;    E = # of energy bins
;;    A = # of angle bins
;;    K = E * A
t_esa    = ti_esa
IF (N_ELEMENTS(t_esa) LE 1L) THEN RETURN
;;----------------------------------------------------------------------------------------
;; => Define DAT structure parameters
;;----------------------------------------------------------------------------------------
n_e      = dat.NENERGY             ;; => # of energy bins [ = E]
n_a      = dat.NBINS               ;; => # of angle bins  [ = A]
kk       = n_e*n_a
ind_2d   = INDGEN(n_e,n_a)         ; => original indices of angle bins

energy   = dat.ENERGY              ; => Energy bin values [eV]
df_dat   = dat.DATA                ; => Data values [data.UNITS_NAME]

phi      = dat.PHI                 ; => Azimuthal angle (from sun direction) [deg]
dphi     = dat.DPHI                ; => Uncertainty in phi
theta    = dat.THETA               ; => Poloidal angle (from ecliptic plane) [deg]
dtheta   = dat.DTHETA              ; => Uncertainty in theta

tacc     = dat.DT                  ; => Accumulation time [s] of each angle bin
t0       = dat.TIME[0]             ; => Unix time at start of 3DP sample period
t1       = dat.END_TIME[0]         ; => Unix time at end of 3DP sample period
del_t    = t1[0] - t0[0]           ; => Total time of data sample
;;----------------------------------------------------------------------------------------
;; => Reform 2D arrays into 1D
;;      K = E * A
;;----------------------------------------------------------------------------------------
phi_1d   = REFORM(phi,kk)
the_1d   = REFORM(theta,kk)
dat_1d   = REFORM(df_dat,kk)
ener_1d  = REFORM(energy,kk)
ind_1d   = REFORM(ind_2d,kk)
tesa_1d  = REFORM(t_esa,kk)
;;----------------------------------------------------------------------------------------
;; => Define BGSE_HTR structure parameters
;;----------------------------------------------------------------------------------------
htr_t     = bgse_htr.X        ; => Unix times
htr_b     = bgse_htr.Y        ; => GSE B-field [nT]
;; => Interpolate HTR MFI data to 3dp angle bin times
magfx     = interp(htr_b[*,0],htr_t,tesa_1d,/NO_EXTRAP)  ;; [K]-Element array
magfy     = interp(htr_b[*,1],htr_t,tesa_1d,/NO_EXTRAP)  ;; [K]-Element array
magfz     = interp(htr_b[*,2],htr_t,tesa_1d,/NO_EXTRAP)  ;; [K]-Element array
bmag      = SQRT(magfx^2 + magfy^2 + magfz^2)            ;; [K]-Element array
;; => define corresponding unit vectors
umagfx    = magfx/bmag
umagfy    = magfy/bmag
umagfz    = magfz/bmag
umagf     = [[umagfx],[umagfy],[umagfz]]                 ;; [K,3]-Element array
;;----------------------------------------------------------------------------------------
;; => Convert [Energies,Angles]  -->  Velocities
;;----------------------------------------------------------------------------------------
;; => Magnitude of velocities from energy (km/s)
nvmag     = energy_to_vel(ener_1d,dat[0].MASS[0])
coth      = COS(the_1d*!DPI/18d1)
sith      = SIN(the_1d*!DPI/18d1)
coph      = COS(phi_1d*!DPI/18d1)
siph      = SIN(phi_1d*!DPI/18d1)
;; => Define directions
swfv      = DBLARR(kk,3L)              ;;  [K,3]-Element array
swfv[*,0] = nvmag*coth*coph            ;; => Define X-Velocity per energy per data bin
swfv[*,1] = nvmag*coth*siph            ;; => Define Y-Velocity per energy per data bin
swfv[*,2] = nvmag*sith                 ;; => Define Z-Velocity per energy per data bin
;;----------------------------------------------------------------------------------------
;; => Define rotation to plane containing Bo and Vsw
;;----------------------------------------------------------------------------------------
v1        = umagf                       ;; [K,3]-Element array
v2        = vec2/NORM(vec2)             ;; normalize
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
str_element,dat,'VX2D',vx2d,/ADD_REPLACE
str_element,dat,'VY2D',vy2d,/ADD_REPLACE

extract_tags,dat,str_xy
extract_tags,dat,str_xz
extract_tags,dat,str_yz
;; => X-Y and X-Z Plane projection rotation
str_element,dat,'ROT_MAT',rotm,/ADD_REPLACE
;; => Y-Z Plane projection rotation
str_element,dat,'ROT_MAT_Z',rotz,/ADD_REPLACE
;;----------------------------------------------------------------------------------------
;; => Return altered data structure to user
;;----------------------------------------------------------------------------------------
data      = dat

RETURN
END


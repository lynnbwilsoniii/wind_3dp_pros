;+
;*****************************************************************************************
;
;  FUNCTION :   correct_vshn_ushn.pro
;  PURPOSE  :   This routine takes the "corrected" shock normal vector solution
;                 and estimates the "corrected" shock normal speeds.
;
;  CALLED BY:   
;               find_coplanarity_from_rhsolns.pro
;
;  CALLS:
;               NA
;
;  REQUIRES:    
;               NA
;
;  INPUT:
;               N_VEC     :  [3]-Element [float/double] array defining the unit normal
;                              vector to use for the projections
;
;  EXAMPLES:    
;               test = correct_vshn_ushn(n_vec,V_UP=v_up,N_UP=n_up,V_DN=v_dn,N_DN=n_dn)
;
;  KEYWORDS:    
;               V_UP      :  [N,3]-Element [float/double] array defining the upstream
;                              bulk flow velocity vectors, Vsw_{up} [km/s, ICB]
;               N_UP      :  [N]-Element [float/double] array defining the upstream
;                              plasma number densities, No_{up} [cm^(-3)]
;               V_DN      :  [N,3]-Element [float/double] array defining the downstream
;                              bulk flow velocity vectors, Vsw_{dn} [km/s, ICB]
;               N_DN      :  [N]-Element [float/double] array defining the downstream
;                              plasma number densities, No_{dn} [cm^(-3)]
;
;   CHANGED:  1)  NA [MM/DD/YYYY   v1.0.0]
;
;   NOTES:      
;               
;
;  REFERENCES:  
;               1)  Vinas, A.F. and J.D. Scudder (1986), "Fast and Optimal Solution to
;                      the 'Rankine-Hugoniot Problem'," J. Geophys. Res. 91, pp. 39-58.
;               2)  A. Szabo (1994), "An improved solution to the 'Rankine-Hugoniot'
;                      problem," J. Geophys. Res. 99, pp. 14,737-14,746.
;               3)  Koval, A. and A. Szabo (2008), "Modified 'Rankine-Hugoniot' shock
;                      fitting technique:  Simultaneous solution for shock normal and
;                      speed," J. Geophys. Res. 113, pp. A10110.
;
;   CREATED:  04/25/2013
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  04/25/2013   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION correct_vshn_ushn,n_vec,V_UP=v_up,N_UP=n_up,V_DN=v_dn,N_DN=n_dn

;;----------------------------------------------------------------------------------------
;; => Define some constants and dummy variables
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
epsilon        = [-1d0,0d0,1d0]
;; => Dummy error messages
badnin_msg     = 'Incorrect number of inputs!'
noinpt_msg     = 'No input supplied!  Using default values...'
noteni_msg     = 'Not enough input supplied!  Using default values...'
badbvu_msg     = 'BVUP must be an [N,3]-element vector...'
badbvd_msg     = 'BVDN must be an [N,3]-element vector...'
badbvs_msg     = 'BVUP and BVDN must have the same dimensions and be [N,3]-element vectors...'
badnvc_msg     = 'N_VEC must be an [3]-element vectors...'
badvvu_msg     = 'V_UP must be an [N,3]-element vector...'
badvvd_msg     = 'V_DN must be an [N,3]-element vector...'
badnnu_msg     = 'N_UP must be an [N]-element array...'
badnnd_msg     = 'N_DN must be an [N]-element array...'
;; => Dummy variable
dumb3          = REPLICATE(d,3)
;; => Dummy return structure
tags           = ['V_SHN_UP','U_SHN_UP','U_SHN_DN']
dummy_rmats    = CREATE_STRUCT(tags,dumb3,dumb3,dumb3)
;;----------------------------------------------------------------------------------------
;; => Check for input
;;----------------------------------------------------------------------------------------
IF (N_PARAMS() NE 1) THEN BEGIN
  ;;  Incorrect number of inputs!
  MESSAGE,badnin_msg[0],/INFORMATIONAL,/CONTINUE
  RETURN,dummy_rmats
ENDIF

test           = (N_ELEMENTS(v_up) EQ 0) OR (N_ELEMENTS(n_up) EQ 0) OR $
                 (N_ELEMENTS(v_dn) EQ 0) OR (N_ELEMENTS(n_dn) EQ 0)
IF (test) THEN BEGIN
  ;;  Incorrect number of inputs!
  MESSAGE,noinpt_msg[0],/INFORMATIONAL,/CONTINUE
  RETURN,dummy_rmats
ENDIF
;;----------------------------------------------------------------------------------------
;;  Check input format
;;----------------------------------------------------------------------------------------
n_vv           = REFORM(n_vec)
test           = (N_ELEMENTS(n_vv) NE 3)
IF (test) THEN BEGIN
  ;; => bad input format
  MESSAGE,badnvc_msg[0],/INFORMATIONAL,/CONTINUE
  RETURN,dummy_rmats
ENDIF

;; => Determine if user wants to "correct" Vshn and Ushn
szn_vup        = SIZE(v_up,/N_DIMENSIONS)
szn_vdn        = SIZE(v_dn,/N_DIMENSIONS)
szn_nup        = SIZE(n_up,/N_DIMENSIONS)
szn_ndn        = SIZE(n_dn,/N_DIMENSIONS)
szd_vup        = SIZE(v_up,/DIMENSIONS)
szd_vdn        = SIZE(v_dn,/DIMENSIONS)
szd_nup        = SIZE(n_up,/DIMENSIONS)
szd_ndn        = SIZE(n_dn,/DIMENSIONS)

;;  Check V_UP and V_DN formats
testV_up       = (N_ELEMENTS(v_up) LE 3) OR ((N_ELEMENTS(v_up) MOD 3) NE 0) OR (szn_vup NE 2)
testV_dn       = (N_ELEMENTS(v_dn) LE 3) OR ((N_ELEMENTS(v_dn) MOD 3) NE 0) OR (szn_vdn NE 2)
test           = testV_up OR testV_dn
IF (test) THEN BEGIN
  ;; => bad input format
  IF (testV_up) THEN MESSAGE,badvvu_msg[0],/INFORMATIONAL,/CONTINUE
  IF (testV_dn) THEN MESSAGE,badvvd_msg[0],/INFORMATIONAL,/CONTINUE
  RETURN,dummy_rmats
ENDIF
;;  Reform so arrays are [N,3]-Elements
vsw_up         = REFORM(v_up)
vsw_dn         = REFORM(v_dn)
testV_up       = (szd_vup[1] NE 3)
testV_dn       = (szd_vdn[1] NE 3)
IF (testV_up) THEN vsw_up = TRANSPOSE(vsw_up)
IF (testV_dn) THEN vsw_dn = TRANSPOSE(vsw_dn)
szd_vup        = SIZE(vsw_up,/DIMENSIONS)
szd_vdn        = SIZE(vsw_dn,/DIMENSIONS)

;;  Check N_UP and N_DN formats
testN_up       = (N_ELEMENTS(n_up) NE szd_vup[0]) OR (szn_nup NE 1)
testN_dn       = (N_ELEMENTS(n_dn) NE szd_vdn[0]) OR (szn_ndn NE 1)
test           = testN_up OR testN_dn
IF (test) THEN BEGIN
  ;; => bad input format
  IF (testN_up) THEN MESSAGE,badnnu_msg[0],/INFORMATIONAL,/CONTINUE
  IF (testN_dn) THEN MESSAGE,badnnd_msg[0],/INFORMATIONAL,/CONTINUE
  RETURN,dummy_rmats
ENDIF
den_up         = REFORM(n_up) # REPLICATE(1d0,3)
den_dn         = REFORM(n_dn) # REPLICATE(1d0,3)
;;----------------------------------------------------------------------------------------
;;  Determine "corrected" Vshn and Ushn
;;----------------------------------------------------------------------------------------
;;  Upstream Avg. Vshn [km/s]
Vshn_up        = REPLICATE(d,3)
;;  Upstream Avg. Ushn [km/s]
Ushn_up        = REPLICATE(d,3)
;;  Downstream Avg. Ushn [km/s]
Ushn_dn        = REPLICATE(d,3)

;;  Define ∆[N] = <N>_dn - <N>_up
del_N          = den_dn - den_up
;;  Define ∆[N Vsw] = (<N>_dn * <Vsw>_dn) - (<N>_up * <Vsw>_up)
del_NV         = (den_dn*vsw_dn) - (den_up*vsw_up)
;;  Define ∆[N Vsw]/∆[N]
del_ratio      = del_NV/del_N
;;----------------------------------------------
;;  Define Vshn = (∆[N Vsw]/∆[N]) . n
;;----------------------------------------------
all_vshn       = n_vv[0]*del_ratio[*,0] + n_vv[1]*del_ratio[*,1] + n_vv[2]*del_ratio[*,2]
nv             = 1d0*N_ELEMENTS(all_vshn)
Vshn_up[0]     = MEAN(all_vshn,/NAN)
Vshn_up[1]     = STDDEV(all_vshn,/NAN)
Vshn_up[2]     = STDDEV(all_vshn,/NAN)/SQRT(nv[0])
;;----------------------------------------------
;;  Define Ushn = [Vsw - (Vshn n)] . n
;;----------------------------------------------
vn_up          = n_vv[0]*vsw_up[*,0] + n_vv[1]*vsw_up[*,1] + n_vv[2]*vsw_up[*,2]
vn_dn          = n_vv[0]*vsw_dn[*,0] + n_vv[1]*vsw_dn[*,1] + n_vv[2]*vsw_dn[*,2]
all_ushn_up    = vn_up - Vshn_up[0]
all_ushn_dn    = vn_dn - Vshn_up[0]
;;  Upstream
Ushn_up[0]     = MEAN(all_ushn_up,/NAN)
Ushn_up[1]     = STDDEV(all_ushn_up,/NAN)
Ushn_up[2]     = STDDEV(all_ushn_up,/NAN)/SQRT(nv[0])
;;  Downstream
Ushn_dn[0]     = MEAN(all_ushn_dn,/NAN)
Ushn_dn[1]     = STDDEV(all_ushn_dn,/NAN)
Ushn_dn[2]     = STDDEV(all_ushn_dn,/NAN)/SQRT(nv[0])
;;----------------------------------------------------------------------------------------
;;  Define return structure
;;----------------------------------------------------------------------------------------
tags           = ['V_SHN_UP','U_SHN_UP','U_SHN_DN']
struc          = CREATE_STRUCT(tags,Vshn_up,Ushn_up,Ushn_dn)
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN,struc
END


;+
;*****************************************************************************************
;
;  FUNCTION :   find_coplanarity_from_rhsolns.pro
;  PURPOSE  :   This routine takes the solutions from an initial Rankine-Hugoniot
;                 analysis and tries to improve those results by imposing the constraint
;                 of co-planarity.  Meaning, the routine adjusts the user's estimate
;                 of the shock normal vector and average upstream/downstream magnetic
;                 field vectors so that the rotation matrix to(from) the NCB(ICB)
;                 represents an orthonormal rotation.  In general, the results from
;                 my Rankine-Hugoniot analysis may not give an orthonormal basis for
;                 the NCB.  This routine attempts to correct that and improve the
;                 estimates for the shock normal vector and speeds.
;
;  CALLED BY:   
;               NA
;
;  CALLS:
;               correct_vshn_ushn.pro
;
;  REQUIRES:    
;               NA
;
;  INPUT:
;               N_VEC     :  [3]-Element [float/double] array defining the unit normal
;                              vector to use for the projections
;                              { Default = [1,0,0] }
;               DNVEC     :  [3]-Element [float/double] array defining the uncertainty
;                              in N_VEC
;                              { Default = [0.1,0.1,0.1] }
;               BVUP      :  [N,3]-Element [float/double] array defining the upstream
;                              magnetic field vectors, Bo_{up} [nT, ICB]
;                              { Default = [1,1,0] }
;               BVDN      :  [N,3]-Element [float/double] array defining the downstream
;                              magnetic field vectors, Bo_{dn} [nT, ICB]
;                              { Default = [2,3,0] }
;
;  EXAMPLES:    
;               ;;  Just find the new shock normal vector and rotation matrix
;               test = find_coplanarity_from_rhsolns(n_vec,dnvec,bvup,bvdn)
;               
;               ;;  To add the corrected shock normal speeds, use the following:
;               test = find_coplanarity_from_rhsolns(n_vec,dnvec,bvup,bvdn,V_UP=v_up,$
;                                                    N_UP=n_up,V_DN=v_dn,N_DN=n_dn)
;
;  KEYWORDS:    
;               V_UP      :  [N,3]-Element [float/double] array defining the upstream
;                              bulk flow velocity vectors, Vsw_{up} [km/s, ICB]
;               N_UP      :  [N]-Element [float/double] array defining the upstream
;                              plasma number densities, No_{up} [cm^(-3)]
;               V_DN      :  [N,3]-Element [float/double] array defining the downstream
;                              bulk flow velocity vectors, Vsw_{dn} [km/s, ICB]
;               N_DN      :  [N]-Element [float/double] array defining the downstream
;                              plasma number densities, No_{dn} [cm^(-3)]
;
;   CHANGED:  1)  NA [MM/DD/YYYY   v1.0.0]
;
;   NOTES:      
;               1)  Definitions
;                     ICB  :  Input Coordinate Basis (e.g., GSE)
;                     NIF  :  Normal Incidence Frame
;                     SCF  :  SpaceCraft Frame
;                     NCB  :  Normal Incidence Frame Coordinate Basis
;                     SRF  :  Shock Rest Frame
;               2)  There are implicit assumptions in the estimation of both the NIF
;                     and the current density.  The assumptions are:
;                       A)  the shock front can be characterized as a planar stationary
;                             surface with a well defined temporal location
;                       B)  the Rankine-Hugoniot conservation relations hold without
;                             the addition of sources/sinks [e.g., reflected ions,
;                             anomalous resistivity, heat flux considerations, etc.]
;                       C)  the stationary solutions give a shock velocity which is
;                             constant, thus allowing one to convert temporal abscissa
;                             to spatial abscissa
;                       D)  the current density can be entirely characterized by the
;                             curl of the magnetic field divided by the permeability
;                             of free space
;                               => use spatial abscissa to estimate part of two
;                                    components of the current density
;
;  REFERENCES:  
;               1)  Scudder, J.D., A. Mangeney, C. Lacombe, C.C. Harvey, T.L. Aggson,
;                      R.R. Anderson, J.T. Gosling, G. Paschmann, and C.T. Russell
;                      (1986a) "The Resolved Layer of a Collisionless, High ß,
;                      Supercritical, Quasi-Perpendicular Shock Wave 1:
;                      Rankine-Hugoniot Geometry, Currents, and Stationarity,"
;                      J. Geophys. Res. Vol. 91, pp. 11,019-11,052.
;               2)  Scudder, J.D., A. Mangeney, C. Lacombe, C.C. Harvey, T.L. Aggson
;                      (1986b) "The Resolved Layer of a Collisionless, High ß,
;                      Supercritical, Quasi-Perpendicular Shock Wave 2:
;                      Dissipative Fluid Electrodynamics," J. Geophys. Res. Vol. 91,
;                      pp. 11,053-11,073.
;               3)  Scudder, J.D., A. Mangeney, C. Lacombe, C.C. Harvey, C.S. Wu,
;                      R.R. Anderson (1986c) "The Resolved Layer of a Collisionless,
;                      High ß, Supercritical, Quasi-Perpendicular Shock Wave 3:
;                      Vlasov Electrodynamics," J. Geophys. Res. Vol. 91,
;                      pp. 11,075-11,097.
;               4)  Paschmann, G. and P.W. Daly (1998), "Analysis Methods for Multi-
;                      Spacecraft Data," ISSI Scientific Report, Noordwijk, 
;                      The Netherlands., Int. Space Sci. Inst.
;
;   CREATED:  04/25/2013
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  04/25/2013   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION find_coplanarity_from_rhsolns,n_vec,dnvec,bvup,bvdn,V_UP=v_up,N_UP=n_up,$
                                       V_DN=v_dn,N_DN=n_dn

;;----------------------------------------------------------------------------------------
;; => Define some constants and dummy variables
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
epsilon        = [-1d0,0d0,1d0]
;; => Dummy error messages
badnin_msg     = 'Incorrect number of inputs!'
noinpt_msg     = 'No input supplied!  Using default values...'
noteni_msg     = 'Not enough input supplied!  Using default values...'
badbvu_msg     = 'BVUP must be an [N,3]-element vector...'
badbvd_msg     = 'BVDN must be an [N,3]-element vector...'
badbvs_msg     = 'BVUP and BVDN must have the same dimensions and be [N,3]-element vectors...'
badnvc_msg     = 'N_VEC and DNVEC must be [3]-element vectors...'
badvvu_msg     = 'V_UP must be an [N,3]-element vector...'
badvvd_msg     = 'V_DN must be an [N,3]-element vector...'
badnnu_msg     = 'N_UP must be an [N]-element array...'
badnnd_msg     = 'N_DN must be an [N]-element array...'
;; => Dummy rotation matrix
irot           = IDENTITY(3,/DOUBLE)  ;; 3x3 matrix
dumb3          = REPLICATE(d,3)
;; => Dummy return structure
tags           = ['V_SHN_UP','U_SHN_UP','U_SHN_DN']
dumbs          = CREATE_STRUCT(tags,dumb3,dumb3,dumb3)
tags           = ['R_NCB_2_ICB','R_ICB_2_NCB','NEW_NVEC','BO_AVG_UP','BO_AVG_DN','SPEEDS']
dummy_rmats    = CREATE_STRUCT(tags,irot,irot,dumb3,dumb3,dumb3,dumbs)
;;----------------------------------------------------------------------------------------
;; => Check for input
;;----------------------------------------------------------------------------------------
IF (N_PARAMS() NE 4) THEN BEGIN
  ;;  Incorrect number of inputs!
  MESSAGE,badnin_msg[0],/INFORMATIONAL,/CONTINUE
  RETURN,dummy_rmats
ENDIF
;;----------------------------------------------------------------------------------------
;; => Check input format
;;----------------------------------------------------------------------------------------
B_up           = REFORM(bvup)
B_dn           = REFORM(bvdn)
n_vv           = REFORM(n_vec)
d_nv           = REFORM(dnvec)
;;  Make sure N_VEC and DNVEC are [3]-Element arrays
test_n         = (N_ELEMENTS(n_vv) NE 3)
testdn         = (N_ELEMENTS(d_nv) NE 3)
test           = test_n OR testdn
IF (test) THEN BEGIN
  ;;  bad input format
  MESSAGE,badnvc_msg[0],/INFORMATIONAL,/CONTINUE
  RETURN,dummy_rmats
ENDIF

;;  Make sure BVUP and BVDN are [N,3]-Element arrays
szn_bup        = SIZE(B_up,/N_DIMENSIONS)
szn_bdn        = SIZE(B_dn,/N_DIMENSIONS)
testBu         = (N_ELEMENTS(B_up) LE 3) OR ((N_ELEMENTS(B_up) MOD 3) NE 0) OR (szn_bup NE 2)
testBd         = (N_ELEMENTS(B_dn) LE 3) OR ((N_ELEMENTS(B_up) MOD 3) NE 0) OR (szn_bdn NE 2)
test           = testBu OR testBd
IF (test) THEN BEGIN
  ;;  bad input format
  IF (testBu) THEN MESSAGE,badbvu_msg[0],/INFORMATIONAL,/CONTINUE
  IF (testBd) THEN MESSAGE,badbvd_msg[0],/INFORMATIONAL,/CONTINUE
  RETURN,dummy_rmats
ENDIF

szd_bup        = SIZE(B_up,/DIMENSIONS)
szd_bdn        = SIZE(B_dn,/DIMENSIONS)
test           = (szd_bup[0] NE szd_bdn[0]) OR (szd_bup[1] NE szd_bdn[1])
IF (test) THEN BEGIN
  ;;  bad input format
  MESSAGE,badbvs_msg[0],/INFORMATIONAL,/CONTINUE
  RETURN,dummy_rmats
ENDIF

test           = (szd_bup[1] NE 3) OR (szd_bup[1] NE szd_bdn[1])
testBu         = (szd_bup[1] NE 3)
testBd         = (szd_bdn[1] NE 3)
IF (testBu) THEN B_up = TRANSPOSE(B_up)
IF (testBd) THEN B_dn = TRANSPOSE(B_dn)
;;----------------------------------------------------------------------------------------
;;  Define ICB vectors
;;----------------------------------------------------------------------------------------
;;  Upstream Avg. B-fields [nT]
bo__up         = REPLICATE(d,3L)
dbo_up         = REPLICATE(d,3L)
;;  Downstream Avg. B-fields [nT]
bo__dn         = REPLICATE(d,3L)
dbo_dn         = REPLICATE(d,3L)
FOR j=0L, 2L DO BEGIN
  bo__up[j]  = MEAN(B_up[*,j],/NAN)
  dbo_up[j]  = STDDEV(B_up[*,j],/NAN)
  bo__dn[j]  = MEAN(B_dn[*,j],/NAN)
  dbo_dn[j]  = STDDEV(B_dn[*,j],/NAN)
ENDFOR
;;----------------------------------------------------------------------------------------
;;  Vary the parameters and normalize
;;    i.e.,  Q -> Qo + [-1, 0, +1] * ∂Q
;;----------------------------------------------------------------------------------------
bb__up         = REPLICATE(d,3,3)
bb__dn         = REPLICATE(d,3,3)
nn__sh         = REPLICATE(d,3,3)
FOR j=0L, 2L DO BEGIN
  bb__up[*,j] = bo__up + epsilon[j]*dbo_up
  bb__dn[*,j] = bo__dn + epsilon[j]*dbo_dn
  nn__sh[*,j] =   n_vv + epsilon[j]*d_nv
ENDFOR
;;  Define |Q|
bmg_up         = REPLICATE(1d0,3L) # SQRT(TOTAL(bb__up^2,1,/NAN))
bmg_dn         = REPLICATE(1d0,3L) # SQRT(TOTAL(bb__dn^2,1,/NAN))
nmg_sh         = REPLICATE(1d0,3L) # SQRT(TOTAL(nn__sh^2,1,/NAN))
;;  Normalize the vectors
bn__up         = bb__up/bmg_up
bn__dn         = bb__dn/bmg_dn
nnn_sh         = nn__sh/nmg_sh
;;----------------------------------------------------------------------------------------
;;  Define NCB vectors
;;     X' = n
;;     Y' = (b2 x b1)
;;     Z' = n x (b2 x b1)
;;----------------------------------------------------------------------------------------
;;  X'-vector
xvec_ncb       = REBIN(nnn_sh,3,3,3)      ;;  [3,3,3]-Element array

;;----------------------------------------------
;;  Y'- and Z'-vectors
;;----------------------------------------------
;;    => Compute Y' = (b2 x b1)
b2_x_b1        = REPLICATE(d,3,3,3)
b2xb1mg        = REPLICATE(d,3,3,3)
;;    => Compute Z' = n x (b2 x b1)
nxy_vec        = REPLICATE(d,3,3,3)
nxy_mag        = REPLICATE(d,3,3,3)
FOR j=0L, 2L DO BEGIN
  FOR k=0L, 2L DO BEGIN
    ;;  Y'-vector
    b2xb1          = CROSSP(bn__dn[*,k],bn__up[*,j])
    ymag           = SQRT(TOTAL(b2xb1^2,/NAN))
    b2_x_b1[*,j,k] = b2xb1
    b2xb1mg[*,j,k] = ymag[0]
    ;;  Z'-vector
    xvecn          = REFORM(xvec_ncb[*,j,k])
    yvecn          = b2xb1/ymag[0]
    X_x_Y          = CROSSP(xvecn,yvecn)
    zmag           = SQRT(TOTAL(X_x_Y^2,/NAN))
    nxy_vec[*,j,k] = X_x_Y
    nxy_mag[*,j,k] = zmag[0]
  ENDFOR
ENDFOR
;;  Normalize vectors
yvec_ncb       = b2_x_b1/b2xb1mg
zvec_ncb       = nxy_vec/nxy_mag
;;----------------------------------------------------------------------------------------
;;  Define rotation matrices from NCB to ICB
;;----------------------------------------------------------------------------------------
rot_ncb_icb    = REPLICATE(d,3,3,3,3)  ;;  Rotation Matrix from NCB to ICB
rot_icb_ncb    = REPLICATE(d,3,3,3,3)  ;;  Rotation Matrix from ICB to NCB
FOR j=0L, 2L DO BEGIN
  FOR k=0L, 2L DO BEGIN
    xvnor = REFORM(xvec_ncb[*,j,k])
    yvnor = REFORM(yvec_ncb[*,j,k])
    zvnor = REFORM(zvec_ncb[*,j,k])
    t_rot = TRANSPOSE([[xvnor],[yvnor],[zvnor]])
    a_rot = LA_INVERT(t_rot,/DOUBLE,STATUS=stat)
    rot_ncb_icb[*,*,j,k] = t_rot
    IF (stat[0] EQ 0) THEN rot_icb_ncb[*,*,j,k] = a_rot
  ENDFOR
ENDFOR
;;----------------------------------------------------------------------------------------
;;  Minimize |1 - Det(R)|
;;----------------------------------------------------------------------------------------
det_rot        = REPLICATE(d,3,3)
FOR j=0L, 2L DO BEGIN
  FOR k=0L, 2L DO BEGIN
    r_rot = REFORM(rot_icb_ncb[*,*,j,k])
    t_det = LA_DETERM(r_rot,/CHECK,/DOUBLE)
    IF (t_det[0] NE 0) THEN det_rot[j,k] = t_det[0]
  ENDFOR
ENDFOR
;;  Define |1 - Det(R)|
min_det        = ABS(1d0 - det_rot)
;;  Find minimum and determine indices
mn_dr          = MIN(min_det,ln,/NAN)
mn_ind         = ARRAY_INDICES(min_det,ln)
;;----------------------------------------------------------------------------------------
;;  Define "best" results for
;;    - shock normal vector [GSE basis]
;;    - Avg. upstream and downstream B-field vectors
;;    - rotation matrix (from NCB to ICB)
;;----------------------------------------------------------------------------------------
;;  Define rotation matrices
r_ncb_icb      = REFORM(rot_ncb_icb[*,*,mn_ind[0],mn_ind[1]])
r_icb_ncb      = REFORM(rot_icb_ncb[*,*,mn_ind[0],mn_ind[1]])
;;  Define n
n_sh           = REFORM(xvec_ncb[*,mn_ind[0],mn_ind[1]])
;;  Define <B>_up and <B>_dn
bavg_up        = REFORM(bb__up[*,mn_ind[0]])
bavg_dn        = REFORM(bb__dn[*,mn_ind[1]])
;;----------------------------------------------------------------------------------------
;;  Determine if user wants to "correct" Vshn and Ushn
;;----------------------------------------------------------------------------------------
new_nv         = n_sh
cor_struc      = correct_vshn_ushn(new_nv,V_UP=v_up,N_UP=n_up,V_DN=v_dn,N_DN=n_dn)
;;----------------------------------------------------------------------------------------
;;  Define return structure
;;----------------------------------------------------------------------------------------
tags           = ['R_NCB_2_ICB','R_ICB_2_NCB','NEW_NVEC','BO_AVG_UP','BO_AVG_DN','SPEEDS']
rmats          = CREATE_STRUCT(tags,r_ncb_icb,r_icb_ncb,n_sh,bavg_up,bavg_dn,cor_struc)
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN,rmats
END

;+
;*****************************************************************************************
;
;  FUNCTION :   timestamp_3dp_angle_bins.pro
;  PURPOSE  :   This routine determines the Unix time stamps associated with each angle
;                 bin in a 3DP IDL data structure.
;
;  CALLED BY:   
;               NA
;
;  CALLS:
;               test_3dp_struc_format.pro
;               dat_3dp_str_names.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               DAT     :  3DP data structure(s) either from get_??.pro
;                            [?? = el, elb, phb, sf, etc.]
;               SPRATE  :  Scalar defining the spin rate [deg/s] of the Wind spacecraft
;
;  EXAMPLES:    
;               NA
;
;  KEYWORDS:    
;               NA
;
;   CHANGED:  1)  Fixed time stamp calculation offsets            [01/14/2012   v1.1.0]
;             2)  Fixed a typo                                    [01/17/2012   v1.1.1]
;             3)  Corrected issue with forcing (0 ≤ ø ≤ 360)      [08/07/2012   v1.2.0]
;
;   NOTES:      
;               1)  See also:  PLOT_MAP.PRO and MAKE_3DMAP.PRO
;               2)  In the Wind/3DP IDL data structures, the angles associated with the
;                     structure tags THETA and PHI are the midpoints of the range of
;                     angles involved in each data point.  
;               3)  This routine is only verified for EESA Low so far!!!
;
;   CREATED:  01/13/2012
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  08/07/2012   v1.2.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION timestamp_3dp_angle_bins,dat,sprate

;-----------------------------------------------------------------------------------------
; => Define some constants and dummy variables
;-----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
notstr_mssg    = 'Must be an IDL structure...'
badstr_mssg    = 'Not an appropriate 3DP structure...'
notel_mssg     = 'This routine is only verified for EESA Low so far!!!'
;-----------------------------------------------------------------------------------------
; => Check input
;-----------------------------------------------------------------------------------------
IF (N_PARAMS() LE 1) THEN RETURN,0b
data  = dat[0]   ; => in case it is an array of structures of the same format
test  = test_3dp_struc_format(data)

IF (NOT test) THEN BEGIN
  MESSAGE,notstr_mssg,/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF

strns   = dat_3dp_str_names(data[0])
shnme   = STRLOWCASE(STRMID(strns.SN[0],0L,2L))
IF (shnme[0] NE 'el') THEN BEGIN
  MESSAGE,notel_mssg,/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF

sprated = sprate[0]
;-----------------------------------------------------------------------------------------
; => Define 3DP structure parameters
;-----------------------------------------------------------------------------------------
n_e     = data.NENERGY      ; => # of energy bins
n_a     = data.NBINS        ; => # of angle bins
ind_2d  = INDGEN(n_e,n_a)   ; => Original indices of angle bins
; => The following are [ N_E, N_A ]-element arrays
theta   = data.THETA        ; => Poloidal angle (from ecliptic plane) [deg]
phi     = data.PHI          ; => Azimuthal angle (from sun direction) [deg]
dphi    = data.DPHI         ; => Uncertainty in phi
dtheta  = data.DTHETA       ; => Uncertainty in theta

tacc    = data.DT           ; => Accumulation time [s] of each angle bin
t0      = data.TIME[0]      ; => Unix time at start of 3DP sample period
t1      = data.END_TIME[0]  ; => Unix time at end of 3DP sample period
del_t   = t1[0] - t0[0]     ; => Total time of data sample
;-----------------------------------------------------------------------------------------
; => Reform 2D arrays into 1D
;-----------------------------------------------------------------------------------------
;phi_1d  = REFORM(phi,n_e*n_a)
;the_1d  = REFORM(theta,n_e*n_a)
;ind_1d  = REFORM(ind_2d,n_e*n_a)
;-----------------------------------------------------------------------------------------
; => Associate time stamps with each angle bin
;-----------------------------------------------------------------------------------------
min_phi = phi - dphi/2d0
max_phi = phi + dphi/2d0
min_the = theta - dtheta/2d0
max_the = theta + dtheta/2d0
;-----------------------------------------------------------------------------------------
; => Find the start phi-angle of the sample and the difference w/rt it
;-----------------------------------------------------------------------------------------
phi_00    = phi[0,0]                ; => 1st GSE azimuthal angle sampled
; => Shift the rest of the angles so that phi_00 = 0d0
sh_phi    = phi - phi_00[0]
; => Adjust negative values so they are > 360
shphi36   = sh_phi
;;  subtract smallest angle
shphi36  -= MIN(shphi36,/NAN)
; => Define time diff. [s] from middle of first data point
d_t_phi   = shphi36/sprated[0]
; => These times are actually 1/2 an accumulation time from the true start time of each bin
d_t_trp   = d_t_phi + tacc/2d0
; => Define the associated time stamps for each angle bin
ti_angs   = t0[0] + d_t_trp
;-----------------------------------------------------------------------------------------
;  LBW III 01/14/2012
;
;phi_min = MIN(min_phi,/NAN,i_pn)
;d_phi   = phi - phi_min[0]
; => Define time diff. [s] from middle of first data point
;d_t_phi = d_phi/sprated[0]
; => Define the associated time stamps for each angle bin
;ti_angs = t0[0] + d_t_phi
;-----------------------------------------------------------------------------------------
; => Return time stamps to user
;-----------------------------------------------------------------------------------------

RETURN,ti_angs
END
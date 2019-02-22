;+
;*****************************************************************************************
;
;  FUNCTION :   htr_3dp_pad.pro
;  PURPOSE  :   Calculates the pitch-angles for a 3DP distribution using 
;                 High Time Resolution (HTR) magnetic field data.
;
;  CALLED BY:   
;               NA
;
;  CALLS:
;               test_3dp_struc_format.pro
;               dat_3dp_str_names.pro
;               tplot_struct_format_test.pro
;               sphere_to_cart.pro
;               xyz_to_polar.pro
;               interp.pro
;               my_crossp_2.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               DAT        :  3DP data structure(s) either from get_??.pro
;                               [?? = el, elb, phb, sf, etc.]
;               TIME_ANGS  :  [N,M]-Element array of Unix times associated with the
;                               [N,M]-element arrays found in DAT (e.g. DAT.THETA)
;                                 [N = # of energy bins, M = # of angle bins]
;               BGSE_HTR   :  HTR B-field structure of format:
;                               {X:Unix Times, Y:[K,3]-Element Vector}
;
;  EXAMPLES:    
;               NA
;
;  KEYWORDS:    
;               CALCROT    :  If set, routine calculates the rotation matrices to convert
;                               from input basis vector, V, to field-aligned basis with
;                               X'  //  Magnetic Field (Bo)
;                               Y'  //  -Bo x (Bo x V)
;               ROTMATS    :  Set to a named variable to return rotation matrices
;               BTHE       :  Set to a named variable to return the poloidal angles
;                               of the B-field vector
;               BPHI       :  Set to a named variable to return the azimuthal angles
;                               of the B-field vector
;
;   CHANGED:  1)  Fixed a typo                                       [01/17/2012   v1.0.1]
;             2)  Added keywords:  CALCROT, ROTMATS, BTHE, and BPHI  [01/17/2012   v1.1.0]
;
;   NOTES:      
;               1)  This routine is only verified for EESA Low so far!!!
;               2)  HTR B-field = High Time Resolution Magnetic Field
;
;   CREATED:  01/14/2012
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  01/17/2012   v1.1.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION htr_3dp_pad,dat,time_angs,bgse_htr,CALCROT=calcrot,ROTMATS=rotmats, $
                         BTHE=bthe,BPHI=bphi

;-----------------------------------------------------------------------------------------
; => Define some constants and dummy variables
;-----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN

badinp_mssg    = 'Incorrect input format:  TIME_ANGS'
notstr_mssg    = 'Must be an IDL structure...'
nottplot_mssg  = 'Not an appropriate TPLOT structure...'
badstr_mssg    = 'Not an appropriate 3DP structure...'
notel_mssg     = 'This routine is only verified for EESA Low so far!!!'
;-----------------------------------------------------------------------------------------
; => Check input
;-----------------------------------------------------------------------------------------
IF (N_PARAMS() LE 1) THEN RETURN,0b
data  = dat[0]   ; => in case it is an array of structures of the same format

; => Check DAT structure format
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

; => Check BGSE_HTR structure format
test  = tplot_struct_format_test(bgse_htr,/YVECT)
IF (NOT test) THEN BEGIN
  MESSAGE,nottplot_mssg,/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
;-----------------------------------------------------------------------------------------
; => Check time stamp format
;-----------------------------------------------------------------------------------------
n_e     = data.NENERGY      ; => # of energy bins
n_a     = data.NBINS        ; => # of angle bins
t_3dp   = time_angs

szt     = SIZE(t_3dp,/DIMENSIONS)
test0   = (szt[0] NE n_e) AND (szt[0] NE n_a)
test1   = (szt[1] NE n_e) AND (szt[1] NE n_a)
test    = test0 OR test1
IF (test) THEN BEGIN
  MESSAGE,badinp_mssg,/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF

; => know it's an NxM or MxN
test    = (szt[0] NE n_e)
IF (test) THEN BEGIN
  ; => user input [M,N]-Element array, so transpose it
  t_3dp   = TRANSPOSE(t_3dp)
ENDIF
;-----------------------------------------------------------------------------------------
; => Define DAT structure parameters
;-----------------------------------------------------------------------------------------
ind_2d  = INDGEN(n_e,n_a)         ; => original indices of angle bins

energy  = data.ENERGY       ; => Energy bin values [eV]
df_dat  = data.DATA         ; => Data values [data.UNITS_NAME]

phi     = data.PHI          ; => Azimuthal angle (from sun direction) [deg]
dphi    = data.DPHI         ; => Uncertainty in phi
theta   = data.THETA        ; => Poloidal angle (from ecliptic plane) [deg]
dtheta  = data.DTHETA       ; => Uncertainty in theta

tacc    = data.DT           ; => Accumulation time [s] of each angle bin
t0      = data.TIME[0]      ; => Unix time at start of 3DP sample period
t1      = data.END_TIME[0]  ; => Unix time at end of 3DP sample period
del_t   = t1[0] - t0[0]     ; => Total time of data sample
;-----------------------------------------------------------------------------------------
; => Reform 2D arrays into 1D
;-----------------------------------------------------------------------------------------
phi_1d  = REFORM(phi,n_e*n_a)
the_1d  = REFORM(theta,n_e*n_a)
ind_1d  = REFORM(ind_2d,n_e*n_a)
t3dp_1d = REFORM(t_3dp,n_e*n_a)

; => convert polar angles to unit vectors
sphere_to_cart,1.,the_1d,phi_1d,sx,sy,sz
;-----------------------------------------------------------------------------------------
; => Define BGSE_HTR structure parameters
;-----------------------------------------------------------------------------------------
htr_t   = bgse_htr.X        ; => Unix times
htr_b   = bgse_htr.Y        ; => GSE B-field [nT]
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
; => calculate the poloidal and azimuthal angles [deg]
xyz_to_polar,umagf,THETA=bthe_1d,PHI=bphi_1d
; => Reform 1D arrays into a 2D arrays
bthe     = REFORM(bthe_1d,n_e,n_a)
bphi     = REFORM(bphi_1d,n_e,n_a)
;-----------------------------------------------------------------------------------------
; => Calculate the pitch-angles
;-----------------------------------------------------------------------------------------
; => calculate the dot products
b_dot_s  = umagfx*sx + umagfy*sy + umagfz*sz
; => define corresponding pitch angles [deg]
pa_htr   = ACOS(b_dot_s)*18d1/!DPI
;-----------------------------------------------------------------------------------------
; => Calculate the rotation matrices
;-----------------------------------------------------------------------------------------
IF KEYWORD_SET(calcrot) THEN BEGIN
  ; => Reform 1D arrays into a 2D arrays
  umagfx2d = REFORM(umagfx,n_e,n_a)
  umagfy2d = REFORM(umagfy,n_e,n_a)
  umagfz2d = REFORM(umagfz,n_e,n_a)
  umagf_2d = [[[umagfx2d]],[[umagfy2d]],[[umagfz2d]]]
  sx_2d    = REFORM(sx,n_e,n_a)
  sy_2d    = REFORM(sy,n_e,n_a)
  sz_2d    = REFORM(sz,n_e,n_a)
  sv_2d    = [[[sx_2d]],[[sy_2d]],[[sz_2d]]]
  rotmats  = DBLARR(n_e,n_a,3,3)
  FOR j=0L, n_e - 1L DO BEGIN
    sv_00    = REFORM(sv_2d[j,*,*])
    bv_00    = REFORM(umagf_2d[j,*,*])
    ; => Calculate Row C
    row_c    = my_crossp_2(bv_00,sv_00,/NOM)
    ; => Renormalize
    row_c   /= (SQRT(TOTAL(row_c^2,2L,/NAN)) # REPLICATE(1d0,3L))
    ; => Calculate Row B
    row_b    = -1d0*my_crossp_2(bv_00,row_c,/NOM)
    ; => Renormalize
    row_b   /= (SQRT(TOTAL(row_b^2,2L,/NAN)) # REPLICATE(1d0,3L))
    FOR k=0L, n_a - 1L DO BEGIN
      ; => Define Matrix Inverse
      invmat      = DBLARR(3,3)
      invmat[0,*] = bv_00[k,*]
      invmat[1,*] = row_b[k,*]
      invmat[2,*] = row_c[k,*]
      ; => Define Rotation Matrix
      mrot        = INVERT(invmat)
      rotmats[j,k,*,*] = mrot
    ENDFOR
  ENDFOR
ENDIF
;-----------------------------------------------------------------------------------------
; => Reform 1D pitch-angles into a 2D array and return to user
;-----------------------------------------------------------------------------------------
pahtr_2d = REFORM(pa_htr,n_e,n_a)

RETURN,pahtr_2d
END
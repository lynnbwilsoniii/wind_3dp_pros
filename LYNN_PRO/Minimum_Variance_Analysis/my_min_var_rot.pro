;+
;*****************************************************************************************
;
;  FUNCTION :  my_min_var_rot.pro
;  PURPOSE  :  Calculates the minimum variance matrix of some vector array of a 
;               particular input field along with uncertainties and angular 
;               rotation from original coordinate system.
;
;  CALLED BY:   
;               NA
;
;  INCLUDES:
;               NA
;
;  CALLS:
;               lbw_minvar.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               FIELD      :  [N,3]- or [3,N]-Element [numeric] array of 3-vectors upon
;                               which the minimum variance analysis will be applied
;
;  EXAMPLES:    
;               [calling sequence]
;               test = my_min_var_rot(field [,RANGE=range] [,/NOMSSG] $
;                                     [,BKG_FIELD=bkg_field] [,/OFFSET])
;
;  KEYWORDS:    
;               RANGE      :  [2]-Element [long] array defining the start and end point
;                               indices of an interval for performing MVA
;                               [ Default = [0L,N - 1L] ]
;               NOMSSG     :  If set, TPLOT will NOT print out the index and TPLOT handle
;                               of the variables being plotted
;               BKG_FIELD  :  [3]-Element vector for the background field to dot with
;                               MV-Vector produced in program
;                               [Default = DC(smoothed) value of input FIELD]
;               OFFSET     :  If set, program removes the average offset of each
;                               component to avoid offsets influencing the MVA
;
;   CHANGED:  1)  Changed calculation for angle of prop. w/ respect to B-field
;                   to the method defined directly above
;                                                                   [09/29/2008   v1.0.2]
;             2)  Corrected theta_{kB} calculation
;                                                                   [10/05/2008   v1.0.3]
;             3)  Changed theta_{kB} calculation, added calculation of minimum variance
;                   eigenvector error, and changed return structure
;                                                                   [01/20/2009   v1.1.0]
;             4)  Fixed theta_kB calc. (forgot to normalize B-field)
;                                                                   [01/22/2009   v1.1.1]
;             5)  Added keywords:  NOMSSG and BKG_FIELD
;                                                                   [12/04/2009   v1.2.0]
;             6)  Fixed a typo in definition of GN variable
;                                                                   [12/08/2009   v1.2.1]
;             7)  Changed format of output for theta_kB
;                                                                   [09/23/2010   v1.2.2]
;             8)  Added keyword :  OFFSET
;                                                                   [03/10/2011   v1.3.0]
;             9)  Added a semi-colon to printed output
;                                                                   [05/27/2011   v1.3.1]
;            10)  Cleaned up, updated Man. page, and
;                   now calls lbw_minvar.pro instead of min_var.pro and
;                   now calls is_a_3_vector.pro, is_a_number.pro
;                                                                   [12/11/2015   v1.4.0]
;
;   NOTES:      
;      ===============================================================================
;      *******************************************************************************
;       Error Analysis from: A.V. Khrabrov and B.U.O. Sonnerup, JGR Vol. 103, 1998.
;
;      avsra = WHERE(tsall LE timesta+30.d0 AND tsall GE timesta-30.d0,avsa)
;      myrotma = MIN_VAR(myavgmax[avsra],myavgmay[avsra],myavgmaz[avsra],EIG_VALS=myeiga)
;
;       dphi[i,j] = +/- SQRT(lam_3*(lam_[i]+lam_[j]-lam_3)/((K-1)*(lam_[i] - lam_[j])^2))
;
;       dphi = angular standard deviation (radians) of vector x[i] toward/away from 
;               vector x[j]
;      *******************************************************************************
;        Hoppe et. al. [1981] :
;            lam_3 : Max Variance
;            lam_2 : Intermediate Variance
;            lam_1 : MInimum Variance
;
;              [Assume isotropic "noise" in signals]
;            Variance due to signal (along MAX VARIANCE) : lam_1 - lam_3
;            Variance due to signal (along INT VARIANCE) : lam_2 - lam_3
;
;            Maximum Angular Change (along MIN VARIANCE) : th_min = ATAN(lam_3/(lam_2 - lam_3))
;            Maximum Angular Change (along MAX VARIANCE) : th_max = ATAN(lam_3/(lam_1 - lam_2))
;
;        -The direction of maximum variance in the plane of maximum variance is determined
;          by the size of the difference between the two variances in this plane compared
;          to noise.
;
;        -EXAMPLES/ARGUMENTS
;          IF lam_2 = lam_3   => th_min is NOT DEFINED AND th_max is NOT DEFINED
;          IF lam_2 = 2*lam_3 => th_min = !PI/4
;          IF lam_2 = 2*lam_3 => th_min = !PI/30
;
;          IF lam_1 = lam_2 >> lam_3 => Minimum Variance Direction is still well defined!
;
;      *******************************************************************************
;        Mazelle et. al. [2003] :
;              Same Min. Var. variable definitions
;
;             th_min = SQRT((lam_3*lam_2)/(N-1)/(lam_2 - lam_3)^2)
;              {where : N = # of vectors measured, or # of data samples}
;      *******************************************************************************
;      ===============================================================================
;
;  REFERENCES:  
;               1)  G. Paschmann and P.W. Daly "Analysis Methods for Multi-Spacecraft
;                     Data," ISSI Scientific Report, Noordwijk, The Netherlands.,
;                     Int. Space Sci. Inst., 1998.
;               2)  J.C. Samson and J.V. Olson, "Some Comments on the Descriptions of
;                      the Polarization States of Waves," Geophys. J. Astr. Soc. 61,
;                      pp. 115-129, 1980.
;               3)  J.D. Means, "Use of the Three-Dimensional Covariance Matrix in
;                      Analyzing the Polarization Properties of Plane Waves,"
;                      J. Geophys. Res. 77(28), pg 5551-5559, 1972.
;               4)  H. Kawano and T. Higuchi "The bootstrap method in space physics:
;                     Error estimation for the minimum variance analysis," Geophys.
;                     Res. Lett. 22(3), pp. 307-310, 1995.
;               5)  A.V. Khrabrov and B.U.… Sonnerup "Error estimates for minimum
;                     variance analysis," J. Geophys. Res. 103(A4), pp. 6641-6651,
;                     1998.
;
;   CREATED:  06/29/2008
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  12/11/2015   v1.4.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION my_min_var_rot,field,RANGE=range,NOMSSG=nom,BKG_FIELD=bkg_field,OFFSET=offset

;;----------------------------------------------------------------------------------------
;;  Define dummy variables
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
tags           = ['FIELD','MV_FIELD','THETA_Kb','DTHETA','EIGENVALUES','DEIG_VALS',$
                  'EIGENVECTORS','DMIN_VEC']
dumf           = REPLICATE(f,10L,3L)
dumth          = f
dumeig         = REPLICATE(f,3L)
dumrot         = REPLICATE(f,3L,3L)
dum            = CREATE_STRUCT(tags,dumf,dumf,dumth,dumth,dumeig,dumeig,dumrot,dumeig)
;;----------------------------------------------------------------------------------------
;;  Check input
;;----------------------------------------------------------------------------------------
test           = (is_a_3_vector(field,V_OUT=d1,NOMSSG=nom) EQ 0)
IF (test[0]) THEN RETURN,dum      ;;  Bad input
test           = (N_ELEMENTS(d1[*,0]) LT 3)
IF (test[0]) THEN BEGIN
  bad_mssg = 'Incorrect input format: V1 (Must be [N,3] or [3,N] element array)'
  IF ~KEYWORD_SET(nomssg) THEN MESSAGE,bad_mssg[0],/INFORMATIONAL,/CONTINUE
  RETURN,dum
ENDIF
mdime          = SIZE(d1,/DIMENSIONS)     ;;  # of elements in each dimension of data
gn             = mdime[0]                 ;;  # of 3-vectors
d              = REFORM(d1)
;;----------------------------------------------------------------------------------------
;;  Check keywords
;;----------------------------------------------------------------------------------------
;;  Check RANGE
test           = (N_ELEMENTS(range) EQ 2) AND is_a_number(range,/NOMSSG)
IF (test[0]) THEN test = (range[0] NE range[1])
IF (test[0]) THEN BEGIN
  s              = MIN(range)
  e              = MAX(range)
ENDIF ELSE BEGIN
  s              = 0L
  e              = gn[0] - 1L
ENDELSE
myn            = e[0] - s[0]      ;;  # of elements used in MVA calculation
;;  Check OFFSET
test           = (N_ELEMENTS(offset) GT 0) AND KEYWORD_SET(offset)
sd             = d                ;;  New data array
IF (test[0]) THEN BEGIN
  ;;  Remove component offsets from data prior to performing MVA
  ;;    *** Useful if data was not filtered prior to calling ***
  avx      = MEAN(d[s[0]:e[0],0],/NAN,/DOUBLE)
  avy      = MEAN(d[s[0]:e[0],1],/NAN,/DOUBLE)
  avz      = MEAN(d[s[0]:e[0],2],/NAN,/DOUBLE)
  sd[*,0] -= avx[0]
  sd[*,1] -= avy[0]
  sd[*,2] -= avz[0]
ENDIF
;;  Check BKG_FIELD
test           = (is_a_3_vector(bkg_field,V_OUT=dcmag,NOMSSG=nom) EQ 0)
IF (test[0]) THEN BEGIN
  avbx    = MEAN(d[s:e,0],/NAN,/DOUBLE)
  avby    = MEAN(d[s:e,1],/NAN,/DOUBLE)
  avbz    = MEAN(d[s:e,2],/NAN,/DOUBLE)
  avmag   = SQRT(avbx^2 + avby^2 + avbz^2)
  dcmag   = [avbx[0]/avmag[0],avby[0]/avmag[0],avbz[0]/avmag[0]]
ENDIF ELSE BEGIN
  dcmag   = REFORM(dcmag[0,*])     ;;  Only keep first 3-vector [in case user entered multiple]
  ;;  Normalize background field
  avmag   = SQRT(TOTAL(dcmag^2,/NAN))
  dcmag   = dcmag/avmag[0]
ENDELSE
;;----------------------------------------------------------------------------------------
;;  Perform MVA
;;----------------------------------------------------------------------------------------
;;  Define rotation matrix from input coordinate basis to MVA basis
rotmat         = lbw_minvar(sd[s:e,0],sd[s:e,1],sd[s:e,2],EIG_VALS=myeiga)
;;  Define eigenvalues from MVA
lb_a1          = myeiga[2]         ;;  Max Variance eigenvalue, l_1
lb_a2          = myeiga[1]         ;;  Int Variance eigenvalue, l_2
lb_a3          = myeiga[0]         ;;  Min Variance eigenvalue, l_3
lams           = [lb_a1[0],lb_a2[0],lb_a3[0]]
;;----------------------------------------------------------------------------------------
;;  Calculate uncertainties in eigenvalues
;;
;;    Æl_{i}  =  ± [ 2 l_{min} (2 l_{i} - l_{min})/(N - 1) ]^(1/2)
;;----------------------------------------------------------------------------------------
dlb_a1         = 0d0               ;;  Uncertainty in Max, lb_a1
dlb_a2         = 0d0               ;;  Uncertainty in Int, lb_a2
dlb_a3         = 0d0               ;;  Uncertainty in Min, lb_a3
dlb_a1         = SQRT(2d0*lb_a3[0]*(2d0*lb_a1[0] - lb_a3[0])/(myn[0] - 1L))
dlb_a2         = SQRT(2d0*lb_a3[0]*(2d0*lb_a2[0] - lb_a3[0])/(myn[0] - 1L))
dlb_a3         = SQRT(2d0*lb_a3[0]*(2d0*lb_a3[0] - lb_a3[0])/(myn[0] - 1L))
dlams          = [dlb_a1[0],dlb_a2[0],dlb_a3[0]]
;;----------------------------------------------------------------------------------------
;;  Calculate uncertainties in eigen vector angles
;;
;;    Æ¿_{i,j}  =  ± [ l_{min} (l_{i} + l_{j} - l_{min})/(N - 1)/(l_{i} - l_{j})^2 ]^(1/2)
;;----------------------------------------------------------------------------------------
dphi           = DBLARR(3,3)       ;;  Matrix of angles (rad) between relative eigenvectors
FOR i=0L, 2L DO BEGIN
  numer     = lams[2]*(lams[i] + lams - lams[2])
  denom     = (myn[0] - 1L)*(lams[i] - lams)^2
  dphi[i,*] = SQRT(numer/denom)
ENDFOR
;;----------------------------------------------------------------------------------------
;;  Determine the uncertainty in the minimum variance eigenvector
;;
;;    Æk  = ± ( f_o e_{max} + f_1 e_{mid} )
;;  where e_{j} is the j-th eigen vector and f_o and f_1 are given by:
;;    f_o = [Æl_{min}/(l_{max} - l_{min})]^(1/2)
;;    f_1 = [Æl_{min}/(l_{mid} - l_{min})]^(1/2)
;;----------------------------------------------------------------------------------------
dmin_eig       = REPLICATE(0d0,3)           ;;  Uncertainty in the minimum variance eigenvector
f_0            = SQRT(dlb_a3[0]/(lb_a1[0] - lb_a3[0]))
f_1            = SQRT(dlb_a3[0]/(lb_a2[0] - lb_a3[0]))
dmin_eig       = rotmat[*,2]*f_0[0] + rotmat[*,1]*f_1[0]
;;----------------------------------------------------------------------------------------
;;  Rotate data
;;----------------------------------------------------------------------------------------
mvmfi          = d # rotmat                 ;;  [N,3]-Element array of B-fields [MVA basis]
bxmv           = mvmfi[*,0]                 ;;  rotated X B-field
bymv           = mvmfi[*,1]                 ;;  rotated Y B-field
bzmv           = mvmfi[*,2]                 ;;  rotated Z B-field
;;----------------------------------------------------------------------------------------
;;  Calculate wave normal angle and uncertainty
;;
;;    dtheta_kB = ± [ (l_{min} l_{mid})/(N - 1)/(l_{mid} - l_{min})^2 ]^(1/2)
;;----------------------------------------------------------------------------------------
khat           = REFORM(rotmat[*,0])
kmag           = SQRT(TOTAL(khat^2,/NAN))
;;  Renormalize k-vector just in case
khat           = khat/kmag[0]
;;  Calculate (k . Bo)/|Bo|
b_dot_s        = (khat[0]*dcmag[0] + khat[1]*dcmag[1] + khat[2]*dcmag[2])
;;  Calculate the angle between the two vectors
theta_kb_0     = ACOS(b_dot_s[0])*18d1/!DPI
theta_kbs      = 18d1 - theta_kb_0[0]         ;;  Supplemental angle
;;  Calculate the uncertainty in the angle between the two vectors
numer          = lams[2]*lams[1]
denom          = (myn[0] - 1L)*(lams[2] - lams[1])^2
dthetakb       = SQRT(numer[0]/denom[0])
;;  Keep only the value < 90 degrees
theta_kb       = theta_kb_0[0] < theta_kbs[0]
;;----------------------------------------------------------------------------------------
;;  Print relevant values
;;----------------------------------------------------------------------------------------
IF ~KEYWORD_SET(nom) THEN BEGIN
  mineigf = '("; ","<",f8.5,",",f8.5,",",f8.5,"> +/- <",f8.5,",",f8.5,",",f8.5,">")'
  PRINT,';The eigenvalues (usual routine) are:'
  PRINT,'; '+STRTRIM(lb_a1[0],2)+' +/- '+STRTRIM(dlb_a1[0],2)
  PRINT,'; '+STRTRIM(lb_a2[0],2)+' +/- '+STRTRIM(dlb_a2[0],2)
  PRINT,'; '+STRTRIM(lb_a3[0],2)+' +/- '+STRTRIM(dlb_a3[0],2)
  PRINT,';'
  thkb_form   = '(f15.3)'
  thkb_outstr = STRTRIM(STRING(theta_kb[0],FORMAT=thkb_form[0]),2L)+' +/- '+$
                STRTRIM(STRING(dthetakb[0],FORMAT=thkb_form[0]),2L)+' degrees'
  PRINT,';The angle between DC-Field and the k-vector is :'
  PRINT,';       '+thkb_outstr[0]
  PRINT,';'
  PRINT,';The eigenvalues ratios are:'
  PRINT,';',myeiga[1]/myeiga[0],myeiga[2]/myeiga[1]
  PRINT,';The Minimum Variance eigenvector is:'
  PRINT,rotmat[*,0],dmin_eig,FORMAT=mineigf
  PRINT,';'
ENDIF
;;----------------------------------------------------------------------------------------
;;  Define output structure
;;----------------------------------------------------------------------------------------
tags           = ['FIELD','MV_FIELD','THETA_KB','DTHETA','EIGENVALUES','DEIG_VALS',$
                  'EIGENVECTORS','DMIN_VEC']
mymin          = CREATE_STRUCT(tags,field,mvmfi,theta_kb,dthetakb,lams,dlams, $
                                    rotmat,dmin_eig)
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN,mymin
END



;;;----------------------------------------------------------------------------------------
;;;  Make sure data is an [n,3]-element array
;;;----------------------------------------------------------------------------------------
;;d1             = REFORM(field)            ;;  Prevent any [1,n] or [n,1] array from going on
;mdime          = SIZE(d1,/DIMENSIONS)     ;;  # of elements in each dimension of data
;ndime          = SIZE(mdime,/N_ELEMENTS)  ;;   determine if 2D array or 1D array
;gs1            = WHERE(mdime EQ 3L,g1,COMPLEMENT=bn1)
;CASE gs1[0] OF
;  0L   : BEGIN
;    IF (ndime[0] GT 1L) THEN BEGIN
;      d  = TRANSPOSE(d1)
;      gn = mdime[1]
;    ENDIF ELSE BEGIN
;      d  = REFORM(d1)
;      gn = mdime[0]
;    ENDELSE
;  END
;  1L   : BEGIN
;    d  = REFORM(d1)
;    gn = mdime[0]
;  END
;  ELSE : BEGIN
;    MESSAGE,'Incorrect input format: V1 (Must be [N,3] or [3,N] element array)',/INFORMATIONAL,/CONTINUE
;    RETURN,dum
;  END
;ENDCASE
;;;----------------------------------------------------------------------------------------
;;;  Determine data range
;;;----------------------------------------------------------------------------------------
;IF KEYWORD_SET(range) THEN BEGIN
;  myn = range[1] - range[0]  ;;  number of elements used for min. var. calc.
;  IF (myn LE gn AND range[0] GE 0 AND range[1] LE gn) THEN BEGIN
;    s = range[0]
;    e = range[1]
;  ENDIF ELSE BEGIN
;    print,'Too many elements demanded in keyword: RANGE (mmvr)'
;    s   = 0
;    e   = gn - 1L
;    myn = gn
;  ENDELSE
;ENDIF ELSE BEGIN
;  s   = 0
;  e   = gn - 1L
;  myn = gn
;ENDELSE

;FOR i=0L, 2L DO BEGIN
;  FOR j=0L, 2L DO BEGIN
;    dphi[i,j] = SQRT(lams[2]*(lams[i]+lams[j]-lams[2])/((myn-1L)*(lams[i]-lams[j])^2 ))
;  ENDFOR
;ENDFOR

;factor1        = 0d0
;factor2        = 0d0
;factor3        = 0d0
;factor1        = ((2d0*lb_a3^2)/(myn - 1L))^(1d0/4d0)
;factor2        = 1d0/ SQRT(lb_a1 - lb_a3)
;factor3        = 1d0/ SQRT(lb_a2 - lb_a3)
;
;dmin_eig       = factor1*(rotmat[*,2]*factor2 + rotmat[*,1]*factor3)
;IF KEYWORD_SET(bkg_field) THEN BEGIN
;  dcmag   = REFORM(bkg_field)
;  avmag   = SQRT(TOTAL(dcmag^2,/NAN))
;  dcmag   = dcmag/avmag[0]
;ENDIF ELSE BEGIN
;  avbx    = MEAN(d[s:e,0],/NAN,/DOUBLE)
;  avby    = MEAN(d[s:e,1],/NAN,/DOUBLE)
;  avbz    = MEAN(d[s:e,2],/NAN,/DOUBLE)
;  avmag   = SQRT(avbx^2 + avby^2 + avbz^2)
;  dcmag   = [avbx[0]/avmag[0],avby[0]/avmag[0],avbz[0]/avmag[0]]
;ENDELSE
;dthetakb   = SQRT((lb_a3*lb_a2)/(myn - 1L)/(lb_a2 - lb_a3)^2)*18d1/!DPI 
;IF KEYWORD_SET(nom) THEN GOTO,JUMP_SKIP
;;=========================================================================================
;JUMP_SKIP:
;;=========================================================================================
;mymin = CREATE_STRUCT('FIELD',field,'MV_FIELD',mvmfi,'THETA_Kb',theta_kb,     $
;                      'DTHETA',dthetakb,'EIGENVALUES',lams,'DEIG_VALS',dlams, $
;                      'EIGENVECTORS',rotmat,'DMIN_VEC',dmin_eig)

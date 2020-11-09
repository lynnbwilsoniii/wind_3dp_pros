;+
;*****************************************************************************************
;
;  PROCEDURE:   wrapper_lbw_model_bs_param_calc.pro
;  PURPOSE  :   This is a wrapping routine for lbw_model_bs_find_l.pro and
;                 lbw_calc_bs_param.pro which first calculates the aberrated
;                 coordinates of the last bow shock crossing, then corrects to
;                 find the semi-latus rectum of such a bow shock.  After a proper
;                 model is determined, the magnetic field is projected to the
;                 bow shock for calculating local shock normal angles etc.
;
;  CALLED BY:   
;               NA
;
;  INCLUDES:
;               NA
;
;  CALLS:
;               is_a_3_vector.pro
;               mag__vec.pro
;               lbw_model_bs_find_l.pro
;               num2int_str.pro
;               lbw_calc_bs_param.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               NA
;
;  EXAMPLES:    
;               [calling sequence]
;               wrapper_lbw_model_bs_param_calc [,POS=pos] [,MAGF=magf] [,VSW=vsw] [,BOW=bow]      $
;                                               [,SCATSH=scatsh] [,ITMAX=itmax] [,L_OUT=l_out]     $
;                                               [,ABC=abc] [,SIGOUT=sigout] [,BSN=bsn] [,LSN=lsh]  $
;                                               [,SHPOS=shpos] [,SHNORM=shnorm] [,CONNECT=connect] $
;                                               [,SCPOSAB=ab_pos] [,SCATSAB=scatsab] [,SHN_SC=shn_sc]
;
;  KEYWORDS:    
;               ***  INPUTS  ***
;               POS      :  [N,3]-Element [numeric] array of spacecraft positions
;                             [Re, GSE] in non-aberrated coordinates
;               MAGF     :  [N,3]-Element [numeric] array of magnetic field 3-vectors
;                             [nT, GSE] in non-aberrated coordinates
;               VSW      :  [N,3]-Element [numeric] array of non-aberrated solar wind
;                             velocities [km/s, GSE]
;               BOW      :  [K]-Element [structure] array each with the format
;                             {STANDOFF:L,ECCENTRICITY:ecc,X_OFFSET:X0}
;                             where:
;                             L   = standoff parameter or semi-latus rectum [Re]
;                               [Default:  L = b^2/a = 23.3]
;                             ecc = eccentricity of shock [unitless]
;                               [Default:  ecc = c/a = 1.16]
;                             X0  = focus location [Re]
;                               [Default:  X0 = 3]
;               SCATSH   :  [K,3]-Element [numeric] array of spacecraft positions
;                             [Re, GSE] in non-aberrated coordinates corresponding to the
;                             last crossing of the bow shock
;               ITMAX    :  Scalar [long] defining the maximum number of iterations allowed
;                             before software quits attempting further calculation of
;                             the hyperboloid parameters
;                             [Default = 20]
;               ***  OUTPUT  ***
;               !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
;               ***  [all the following changed on output]  ***
;               !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
;               BOW      :  Set to a named variable to return the structures used to
;                             create the model bow shocks in aberrated coordinates
;               L_OUT    :  Set to a named variable that will return the numerical solution
;                             for the semi-latus rectum and an associated uncertainty.
;                             L_OUT[K,0]  :  value of L [Re]
;                             L_OUT[K,1]  :  uncertainty in the value of L [Re]
;               ABC      :  Set to a named variable that will return the numerical solution
;                             for the hyperboloid of two-sheets parameters a, b, and c
;                             ABC[K,0]    :  value of a [Re] or the semi-major axis
;                             ABC[K,1]    :  value of b [Re] or the semi-minor axis
;                             ABC[K,2]    :  value of c [Re] or the center displacement
;               SIGOUT  :  Set to a named variable that will return the one-sigma values
;                            of the new ABC values derived from weights that assume
;                            a ~1 km positional uncertainty (or ~0.016% uncertainty)
;               BSN      :  Set to a named variable to return the angle [deg] between the
;                             shock normal and field line that passes through the SC
;               LSN      :  " " the distance along the field line to the shock [Re]
;               SHPOS    :  " " the position at the shock B-field intersection
;               SHNORM   :  " " the shock normal vector at the shock B-field intersection
;               CONNECT  :  " " a logic parameter that defines whether the SC is
;                             magnetically connected to the shock
;                             [0 = unconnected, 1 = connected]
;               SCPOSAB  :  " " [N,3]-element array of aberrated SC positions [Re, Abr.]
;               SCATSAB  :  " " [K,3]-element array of aberrated SC positions [Re, Abr.]
;                             near location of SC crossing of bow shock
;               SHN_SC   :  " " [K,3]-element array of shock normal vectors near location
;                             of SC crossing of bow shock
;               STATUS   :  Set to a named variable that will return the status of the fit
;                             where the following values are defined as:
;                               0  :  success
;                               1  :  fail --> chi-squared increasing without bound
;                               2  :  fail --> failed to converge in ITMAX iterations
;               CHISQ    :  Set to a named variable that will return the chi-square
;                             goodness-of-fit statistic with W_i weights and d DOF given by
;                               chi^2 = 1/d ∑_i W_i (f_i - fit_i)^2
;                             for the comparison between model bow shock and data
;               ITER     :  Set to a named variable that will return the actual number of
;                             iterations performed to find the proper value of L
;               YERROR   :  Set to a named variable that will return the standard error
;                             between the fit and actual data values given by:
;                                YERROR = [1/n ∑_i (fit_i - f_i)^2]^(1/2)
;                                     n = N_ELEMENTS(f) - 3L
;
;   CHANGED:  1)  NA
;                                                                   [MM/DD/YYYY   v1.0.0]
;
;   NOTES:      
;               1)  Definitions
;                     SC    = spacecraft
;                     r     = L/[1 + ecc*Cos(theta)]
;                     L     = semi-latus rectum
;                           = b^2/a
;                     e     = eccentricity
;                           = c/a
;                             { a^2 + b^2    for hyperbola
;                     c^2   = {
;                             { a^2 - b^2    for ellipse
;                     Rss   = xo + L/(1 + e) = bow shock standoff distance along x'
;               2)  hyperbolic bow shock, see JGR 1981, p.11401, Slavin Fig.7
;                     1 = [(x - X0 - c)/a]^2 + [(y/b)]^2 + [(z/b)]^2
;                     Note it should be the folowing for a hyperboloid of two-sheets
;                     0 = 1 - [(x - X0 - c)/a]^2 + [(y/b)]^2 + [(z/b)]^2
;               3)  Numerically solve the following:
;                     0 = 1 - [(x - X0 - c)/a]^2 + [(y/b)]^2 + [(z/b)]^2
;                   Then inverts the resulting fit parameters a, b, and c to find L
;               4)  Default hyperbola parameters used:
;                     L   = 23.3 R_E
;                     e   = 1.16
;                     xo  = 3.0 R_E
;                     c   = [a^2 + b^2]^(1/2) = L*e/(e^2 - 1) = 83.8
;                     a   = L/(e^2 - 1)                       = 72.87
;                     b   = L/(e^2 - 1)^.5                    = 41.38
;                     Rss = 13.8 R_E
;
;  REFERENCES:  
;               0)  https://en.wikipedia.org/wiki/Semi-major_and_semi-minor_axes
;               1)  https://en.wikipedia.org/wiki/Hyperboloid
;               2)  http://mathworld.wolfram.com/Two-SheetedHyperboloid.html
;               3)  Slavin, J.A. and R.E. Holzer "Solar wind flow about the terrestrial
;                      planets. I - Modeling bow shock position and shape,"
;                      J. Geophys. Res. 86(A13), pp. 11,401-11,418,
;                      doi:10.1029/JA086iA13p11401, 1981.
;               4)  https://harrisgeospatial.com/docs/CURVEFIT.html
;
;   CREATED:  09/30/2020
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  09/30/2020   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

PRO wrapper_lbw_model_bs_param_calc,POS=pos,MAGF=magf,VSW=vsw,BOW=bow,SCATSH=scatsh,ITMAX=itmax,  $
                                    L_OUT=l_out,ABC=abc,SIGOUT=sigout,BSN=bsn,LSN=lsh,SHPOS=shpos,$
                                    SHNORM=shnorm,CONNECT=connect,SCPOSAB=ab_pos,                 $
                                    SCATSAB=scatsab,SHN_SC=shn_sc,STATUS=status,ITER=niter,       $
                                    CHISQ=chisq,YERROR=yerror

;;----------------------------------------------------------------------------------------
;;  Define dummy variables
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
missing        = d[0]
;;  Define the mean orbital speed of Earth [km/s]
vel_earth      = 29.7854d0
;;  Define mean equatorial radius [m]
R_E_m          = 6.3781366d6
R_E            = R_E_m[0]*1d-3         ;;  m --> km
;;  Define an average aberration angle [rad] for a 450 km/s solar wind speed
def_vsw        = 450d0                     ;;  Default Vsw magnitude [km/s]
avg_alpha      = ATAN(vel_earth[0],450d0)  ;;  roughly 3.8 degrees
;;----------------------------------------------------------------------------------------
;;  Check keywords
;;----------------------------------------------------------------------------------------
;;  Check POS
test           = (is_a_3_vector(pos ,V_OUT=posi ,/NOMSSG) EQ 0)
IF (test[0]) THEN BEGIN
  posi_on        = 0b
ENDIF ELSE BEGIN
  posi_on        = 1b
ENDELSE
;;  Check MAGF
test           = (is_a_3_vector(magf,V_OUT=bvec ,/NOMSSG) EQ 0)
IF (test[0]) THEN BEGIN
  bvec_on        = 0b
ENDIF ELSE BEGIN
  bvec_on        = 1b
ENDELSE
IF (posi_on[0] AND bvec_on[0]) THEN BEGIN
  npts           = N_ELEMENTS(posi[*,0]) < N_ELEMENTS(bvec[*,0])
  upp            = npts[0] - 1L
  posi           = posi[0L:upp[0],*]
  bvec           = bvec[0L:upp[0],*]
ENDIF ELSE BEGIN
  ;;  Only one is on --> shut off both
  bvec_on        = 0b
  posi_on        = 0b
  npts           = 1L
ENDELSE
;;  Check VSW
test           = (is_a_3_vector(vsw ,V_OUT=vswo ,/NOMSSG) EQ 0)
IF (test[0]) THEN BEGIN
  vswo = REPLICATE(def_vsw[0],npts[0],3L)
ENDIF
;;  Check SCATSH
test           = (is_a_3_vector(scatsh,V_OUT=scbscr,/NOMSSG) EQ 0)
IF (test[0]) THEN BEGIN
  shn_at_sc      = 0b
  kpts           = 1L
ENDIF ELSE BEGIN
  shn_at_sc      = 1b
  kpts           = N_ELEMENTS(scbscr[*,0])
ENDELSE
;;  Check BOW
IF (SIZE(bow,/TYPE) NE 8) THEN BEGIN
  bow            = REPLICATE({STANDOFF:23.3,ECCENTRICITY:1.16,X_OFFSET:3.0},kpts[0])
ENDIF ELSE BEGIN
  gtag           = ['STANDOFF','ECCENTRICITY','X_OFFSET']
  itag           = STRUPCASE(TAG_NAMES(bow))
  test           = (TOTAL(gtag EQ itag) LT 3)
  IF (test[0]) THEN BEGIN
    bow            = REPLICATE({STANDOFF:23.3,ECCENTRICITY:1.16,X_OFFSET:3.0},kpts[0])
  ENDIF ELSE BEGIN
    nb             = N_ELEMENTS(bow)
    IF (nb[0] NE kpts[0]) THEN bow = REPLICATE(bow[0],kpts[0])
  ENDELSE
ENDELSE
;;----------------------------------------------------------------------------------------
;;  Calculate aberration angle
;;----------------------------------------------------------------------------------------
vmag           = mag__vec(vswo,/NAN)
alpha0         = ATAN(vel_earth[0],vmag)*18d1/!DPI
test0          = (ABS(alpha0) GE 80d0) OR (FINITE(alpha0) EQ 0)
bad_alpha      = WHERE(test0,bda,COMPLEMENT=good_alpha,NCOMPLEMENT=gda)
IF (gda[0] EQ 0) THEN BEGIN
  ;;  no good Vsw inputs
  alpha = avg_alpha[0]
ENDIF ELSE BEGIN
  alpha = MEDIAN(alpha0[good_alpha])*!DPI/18d1
  IF (FINITE(alpha[0]) EQ 0) THEN alpha = avg_alpha[0]
ENDELSE
;;----------------------------------------------------------------------------------------
;;  Define rotation matrix from original basis to aberrated basis
;;----------------------------------------------------------------------------------------
abrot          = [[1d0*COS(alpha[0]), -1d0*SIN(alpha[0]), 0d0], $
                  [1d0*SIN(alpha[0]),  1d0*COS(alpha[0]), 0d0], $
                  [        0d0      ,        0d0       ,  1d0]  ]
scrot          = TRANSPOSE(abrot)                                  ;;  Rotate from aberrated to original input basis
IF (shn_at_sc[0]) THEN BEGIN
  ;;--------------------------------------------------------------------------------------
  ;;  Calculate correct L values
  ;;--------------------------------------------------------------------------------------
  ;;  Aberrate the SC position at the bow shock
  ab_scatbs      = (abrot ## scbscr)
  ;;  Define dummy arrays
  lnew           = REPLICATE(d,kpts[0],2L)
  abco           = REPLICATE(d,kpts[0],3L)
  sigo           = abco
  stt0           = REPLICATE(0L,kpts[0])
  nitr           = stt0
  chsq           = lnew[*,0]
  yerr           = chsq
  IF (posi_on[0] AND bvec_on[0]) THEN BEGIN
    ;;  Define dummy arrays
    bsn            = REPLICATE(d,kpts[0],npts[0])
    lsh            = bsn
    shpos          = REPLICATE(d,kpts[0],npts[0],3L)
    shnorm         = shpos
    connect        = REPLICATE(0b,kpts[0],npts[0])
    scposab        = shpos
    shn_sc         = REPLICATE(d,kpts[0],3L)
  ENDIF
  FOR k=0L, kpts[0] - 1L DO BEGIN
    ;;------------------------------------------------------------------------------------
    ;;  Make sure to clear parameters in case of multiple calls
    ;;------------------------------------------------------------------------------------
    IF (N_ELEMENTS(lout) EQ 1) THEN dumb = TEMPORARY(lout)
    IF (N_ELEMENTS(abc0) EQ 3) THEN dumb = TEMPORARY(abc0)
    IF (N_ELEMENTS(sig0) EQ 3) THEN dumb = TEMPORARY(sig0)
    IF (SIZE(stat,/TYPE) NE 0) THEN dumb = TEMPORARY(stat)
    ;;------------------------------------------------------------------------------------
    ;;  Define guess L value and corresponding SC position (aberrated)
    ;;------------------------------------------------------------------------------------
    lguess         = bow[k].STANDOFF[0]
    kxyz           = REFORM(ab_scatbs[k,*])
    lbw_model_bs_find_l,lguess[0],kxyz,L_OUT=lout,ABC=abc0,SIGOUT=sig0,ITMAX=itmax,$
                        STATUS=stat,ITER=iter,YERROR=yerr0,CHISQ=chsq0
    stt0[k]        = stat[0]
    nitr[k]        = iter[0]
    IF (stat[0] EQ 0) THEN BEGIN
      ;;----------------------------------------------------------------------------------
      ;;  Success
      ;;----------------------------------------------------------------------------------
      lnew[k,*]      = lout
      abco[k,*]      = abc0
      sigo[k,*]      = sig0
      chsq[k]        = chsq0[0]
      yerr[k]        = yerr0[0]
      ;;  Update BOW structure
      bow[k].STANDOFF = lout[0]
    ENDIF ELSE BEGIN
      IF (stat[0] EQ 2) THEN BEGIN
        ;;--------------------------------------------------------------------------------
        ;;  Maybe the routine needed more iterations
        ;;--------------------------------------------------------------------------------
        cc             = 1L
        oiter          = iter[0]
        true           = 1b
        WHILE (true[0]) DO BEGIN
          ;;  Iterate until Status =/= 2
          lguess         = lout[0]
          kxyz           = REFORM(ab_scatbs[k,*])
          ;;  Make sure to clear parameters in case of multiple calls
          IF (N_ELEMENTS(lout) EQ 1) THEN dumb = TEMPORARY(lout)
          IF (N_ELEMENTS(abc0) EQ 3) THEN dumb = TEMPORARY(abc0)
          IF (N_ELEMENTS(sig0) EQ 3) THEN dumb = TEMPORARY(sig0)
          IF (SIZE(stat,/TYPE) NE 0) THEN dumb = TEMPORARY(stat)
          lbw_model_bs_find_l,lguess[0],kxyz,L_OUT=lout,ABC=abc0,SIGOUT=sig0,ITMAX=itmax,$
                              STATUS=stat,ITER=iter,YERROR=yerr0,CHISQ=chsq0
          true           = (stat[0] EQ 2)
          oiter         += iter[0]
          cc            += true[0]
        ENDWHILE
        stt0[k]        = stat[0]
        nitr[k]        = oiter[0]
        IF (stat[0] EQ 0) THEN BEGIN
          nextra         = oiter[0] - itmax[0]
          nexstr         = num2int_str(nextra)
          MESSAGE,';;  Total extra iterations required = '+nexstr[0],/INFORM,/CONTINUE
          ;;  Success
          lnew[k,*]      = lout
          abco[k,*]      = abc0
          sigo[k,*]      = sig0
          chsq[k]        = chsq0[0]
          yerr[k]        = yerr0[0]
          ;;  Update BOW structure
          bow[k].STANDOFF = lout[0]
        ENDIF
      ENDIF
    ENDELSE
    IF (posi_on[0] AND bvec_on[0]) THEN BEGIN
      ;;----------------------------------------------------------------------------------
      ;;  Only procede to call lbw_calc_bs_param.pro if these keywords are set
      ;;----------------------------------------------------------------------------------
      ;;  Make sure to clear parameters in case of multiple calls
      IF (N_ELEMENTS(bsn0)   EQ    npts[0]) THEN dumb = TEMPORARY(bsn0)
      IF (N_ELEMENTS(lsn)    EQ    npts[0]) THEN dumb = TEMPORARY(lsn)
      IF (N_ELEMENTS(shpos0) EQ 3L*npts[0]) THEN dumb = TEMPORARY(shpos0)
      IF (N_ELEMENTS(shnor0) EQ 3L*npts[0]) THEN dumb = TEMPORARY(shnor0)
      IF (N_ELEMENTS(conn0)  EQ    npts[0]) THEN dumb = TEMPORARY(conn0)
      IF (N_ELEMENTS(ab_pos) EQ 3L*npts[0]) THEN dumb = TEMPORARY(ab_pos)
      IF (N_ELEMENTS(shnsc)  EQ         3L) THEN dumb = TEMPORARY(shnsc)
      bwin           = bow[k]
      lbw_calc_bs_param,posi,bvec,BOW=bwin,VSW=vswo,BSN=bsn0,LSN=lsn,SHPOS=shpos0,$
                        SHNORM=shnor0,CONNECT=conn0,SCPOSAB=ab_pos,SCATSH=kxyz,SHN_SC=shnsc
      ;;  Define output
      IF (N_ELEMENTS(bsn0)   EQ    npts[0]) THEN bsn[k,*]         = bsn0
      IF (N_ELEMENTS(lsn)    EQ    npts[0]) THEN lsh[k,*]         = lsn
      IF (N_ELEMENTS(shpos0) EQ 3L*npts[0]) THEN shpos[k,*,*]     = shpos0
      IF (N_ELEMENTS(shnor0) EQ 3L*npts[0]) THEN shnorm[k,*,*]    = shnor0
      IF (N_ELEMENTS(conn0)  EQ    npts[0]) THEN connect[k,*]     = BYTE(conn0)
      IF (N_ELEMENTS(ab_pos) EQ 3L*npts[0]) THEN scposab[k,*,*]   = ab_pos
      IF (N_ELEMENTS(shnsc)  EQ         3L) THEN shn_sc[k,*]      = shnsc
    ENDIF
  ENDFOR
  ;;--------------------------------------------------------------------------------------
  ;;  Define output keywords
  ;;--------------------------------------------------------------------------------------
  l_out          = lnew
  abc            = abco
  sigout         = sigo
  scatsab        = ab_scatbs
  status         = stt0
  niter          = nitr
  chisq          = chsq
  yerror         = yerr
ENDIF ELSE BEGIN
  ;;--------------------------------------------------------------------------------------
  ;;  Use given BOW structure
  ;;--------------------------------------------------------------------------------------
  IF (posi_on[0] AND bvec_on[0]) THEN BEGIN
    ;;  Only procede to call lbw_calc_bs_param.pro if these keywords are set
    bow            = bow[0]
    lbw_calc_bs_param,posi,bvec,BOW=bow,VSW=vswo,BSN=bsn,LSN=lsh,SHPOS=shpos,SHNORM=shnorm,$
                      CONNECT=connect,STRUCT=struct,SCPOSAB=ab_pos
  ENDIF
ENDELSE
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN
END



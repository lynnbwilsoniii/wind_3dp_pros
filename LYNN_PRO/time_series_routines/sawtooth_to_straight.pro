;+
;*****************************************************************************************
;
;  FUNCTION :   sawtooth_to_straight.pro
;  PURPOSE  :   This routine takes an array of periodic data that cycles through a range
;                 of values, by rolling over at some maximum/minimum value, and converts
;                 the data into a "straight," continuous set of data.
;
;  CALLED BY:   
;               NA
;
;  CALLS:
;               t_interval_find.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               SAWT       :  [N]-Element [double/float] array of values that cycle
;                               between a maximum and minimum value [e.g., phase angles
;                               in a periodic wave]
;
;  EXAMPLES:    
;               ;;  Define a sawtooth wave with period 1/400, duration 400, and
;               ;;    unit amplitude
;               nn    = 16384L
;               per   = 1d0/4d2
;               dur   = 4d2
;               tt    = DINDGEN(nn)/(per[0]*(nn - 1L))  ;;  timestamps for sawtooth
;               xx    = 2d0*(tt/per[0] - FLOOR(tt/per[0] + 1d0/2d0))
;               test  = sawtooth_to_straight(xx,MAXABS=1d0)
;               ;;  Now check slope
;               dt    = tt - SHIFT(tt,1)
;               dx    = test - SHIFT(test,1)
;               dxdt  = dx/dt
;               dxran = [MIN(dxdt,/NAN),MAX(dxdt,/NAN)]
;               perc  = (dxran[1] - dxran[0])/MEAN(dxran,/NAN)*1d2
;               PRINT,';;',dxran[0],dxran[1],perc[0]
;               ;;      -19.150000      -19.148750   -0.0065276317
;
;  KEYWORDS:    
;               MAXABS     :  Scalar [double/float] defining the maximum absolute value
;                               of the input SAWT.
;                               [Default = MAX(ABS(SAWT - MEAN(SAWT,/NAN)),/NAN)]
;               TOLERANCE  :  Scalar [double/float] defining the maximum change between
;                               two adjacent values of SAWT before considering the
;                               change to be the end of a cycle or a rollover point
;                               [Default = MAXABS/2d0]
;
;   CHANGED:  1)  Finished writing routine, beta version
;                   (i.e., it works for well defined and formatted input)
;                                                                   [09/10/2013   v1.0.0]
;
;   NOTES:      
;               1)  Common examples for MAXABS are:  2d0*!DPI (radians); 36d1 (degrees);
;                                                    1 (cycles); etc.
;               2)  Input should be periodically varying so that it has a cyclic and
;                     discontinuous behavior.  If the input is period and continuous,
;                     then the output will be meaningless.
;
;  REFERENCES:  
;               
;
;   CREATED:  09/10/2013
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  09/10/2013   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION sawtooth_to_straight,sawt,MAXABS=maxabs,TOLERANCE=tolerance

;;----------------------------------------------------------------------------------------
;;  Define dummy variables
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
zeros          = [1,0]
;;  Error messages
noinput_mssg   = 'No input was supplied...'
nosawt_mssg    = 'Input was not cyclical...'
;;----------------------------------------------------------------------------------------
;;  Check input
;;----------------------------------------------------------------------------------------
test           = (N_PARAMS() NE 1) OR (N_ELEMENTS(sawt) EQ 0)
IF (test) THEN BEGIN
  MESSAGE,noinput_mssg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0
ENDIF
phi            = REFORM(sawt)
np             = N_ELEMENTS(phi)
pind           = DINDGEN(np)
;;  Determine shift so all values are > 0
IF (MIN(phi,/NAN) LT 0) THEN phi_0 = ABS(MIN(phi,/NAN)) ELSE phi_0 = 0d0
;;----------------------------------------------------------------------------------------
;;  Check keywords
;;----------------------------------------------------------------------------------------
test           = (N_ELEMENTS(maxabs) EQ 0)
IF (test) THEN mxval = MAX(ABS(phi - MEAN(phi,/NAN)),/NAN) ELSE mxval = maxabs[0]
;;  Adjust max value accordingly
test           = (N_ELEMENTS(tolerance) EQ 0)
IF (test) THEN tol = mxval[0]/2d0 ELSE tol = tolerance[0]
;IF (test) THEN tol = (mxval[0] + phi_0[0])/2d0 ELSE tol = tolerance[0]
;;----------------------------------------------------------------------------------------
;;  Define the relative changes in input
;;----------------------------------------------------------------------------------------
d_phi          = phi - SHIFT(phi,1)
d_phi[0]       = 0
;;  Make sure ø varies
unq            = UNIQ(d_phi[1L:(np - 1L)],SORT(d_phi[1L:(np - 1L)]))
test           = (N_ELEMENTS(unq) LT 2)
IF (test) THEN BEGIN
  ;;  Input was a straight line
  MESSAGE,'0: '+nosawt_mssg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0
ENDIF
;;----------------------------------------------------------------------------------------
;;  Determine where ∆ø < 0 and ∆ø ≥ 0
;;----------------------------------------------------------------------------------------
;;  Assume slopes have more points than cyclical jumps/rollovers
test_zer       = [TOTAL(d_phi LT 0),TOTAL(d_phi GT 0)]
test_neg       = (test_zer[0] GT test_zer[1])   ;;  TRUE --> - slopes, + jumps
test           = (test_zer[0] EQ 0) OR (test_zer[1] EQ 0)
IF (test) THEN BEGIN
  ;;  Input only had one-way slope --> Input was not cyclical
  MESSAGE,'1: '+nosawt_mssg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0
ENDIF
;;  Define sign to add to output
IF (test_neg) THEN neg_sl = 1 ELSE neg_sl = 0
;;  Make sure changes are greater than tolerance
t_fac          = (FIX((d_phi GT tol[0]) EQ 1) - FIX((d_phi LT (-tol[0])) EQ 1))
t_fac         += (1L - neg_sl[0])
d_phi         *= zeros[t_fac]  ;;  removes intervals of constant small slope
;;  Retest input
test           = (d_phi NE 0)
good_jumps     = WHERE(test,gdjump,COMPLEMENT=good_slopes,NCOMPLEMENT=gdslope)
;;----------------------------------------------------------------------------------------
;;  Find intervals
;;----------------------------------------------------------------------------------------
test           = (gdjump LT gdslope)   ;;  TRUE --> - slopes = jumps
IF (test) THEN gind = good_slopes ELSE gind = good_jumps

ints           = t_interval_find(pind[gind],GAP_THRESH=1d0)
;;  Make sure more than one interval was found
test           = (N_ELEMENTS(ints) LE 2)
IF (test) THEN BEGIN
  ;;  Input only had one-way slope --> Input was not cyclical
  MESSAGE,'3: '+nosawt_mssg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0
ENDIF
;;  Define indices of intervals [relative to ø]
gpind          = gind[ints]
n_int          = N_ELEMENTS(ints[*,0])
;;----------------------------------------------------------------------------------------
;;  Redefine intervals [i.e., expand them by ±1]
;;----------------------------------------------------------------------------------------
i_ind          = LINDGEN(n_int)
low            = i_ind[1L:(n_int - 1L)]
hig            = i_ind[0L:(n_int - 2L)]
gpind[low,0L] -= 1L
;gpind[hig,1L] += 1L
;;  Determine # of elements per interval
diff_gp        = gpind[*,0] - SHIFT(gpind[*,1],1)
diff_gp[0]     = 0
n_gp           = (gpind[*,1] - gpind[*,0]) + 1L
;;----------------------------------------------------------------------------------------
;;  Define straight line output
;;----------------------------------------------------------------------------------------
;;  Change slope if necessary
IF (neg_sl) THEN phi *= -1
;;  Remove offset if necessary
phi           += phi_0[0]
;;  Adjust max value accordingly
mxval         += phi_0[0]
;;  Initialize straight line variable
straight       = phi
FOR j=1L, n_int - 1L DO BEGIN
  last  = j - 1L  ;;  last interval
  ;;  Define the indices of the "last" interval
  l_ind = LINDGEN(n_gp[last]) + gpind[last,0]
  ;;  Define the indices of the "current" interval
  c_ind = LINDGEN(n_gp[j]) + (gpind[last,1] + 1L)
  ;;  Check for overlaps
  check = (MIN(c_ind,/NAN) - MAX(l_ind,/NAN))
  ;;  Define maximum from last interval
  last_val  = MAX(straight[l_ind],/NAN)
  IF (check GT 0) THEN BEGIN
    ;;  No overlap --> "straighten" data
    mxlas0  = last_val[0]
    modmax  = mxval[0] - (mxlas0[0] MOD mxval[0])      ;;  Distance from rollover
    mxlast  = modmax[0] + mxlas0[0]
    ;;  Adjust line
    straight[c_ind] += mxlast[0]
  ENDIF
ENDFOR
;;  Remove offset introduced at beginning
straight -= phi_0[0]
;;  Invert if negative slopes
IF (neg_sl) THEN straight *= -1
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN,straight
END

;;  .compile sawtooth_to_straight
;;  test = sawtooth_to_straight(ph,MAXABS=36d1)

;;  x = lindgen(np)
;;  se = x[0L:5000L]
;;  plot,x[se],straight[se],/ylog,/nodata,/xstyle,/ystyle
;;    oplot,x[se],straight[se],psym=3,color= 50
;;    oplot,x[reform(gpind[*,0])],[0,last_val],psym=2,color=250
;;    oplot,x[reform(gpind[*,0])],straight[reform(gpind[*,0])],psym=4,color=150
;;    oplot,x[reform(gpind[*,1])],straight[reform(gpind[*,1])],psym=5,color=200

;;  x = lindgen(np)
;;  se = x[0L:5000L]
;;  plot,x[se],straight[se],/nodata,/xstyle,/ystyle
;;    oplot,x[se],straight[se],psym=3,color= 50
;;    oplot,x[reform(gpind[*,0])],[0,last_val],psym=2,color=250
;;    oplot,x[reform(gpind[*,0])],straight[reform(gpind[*,0])],psym=4,color=150
;;    oplot,x[reform(gpind[*,1])],straight[reform(gpind[*,1])],psym=5,color=200

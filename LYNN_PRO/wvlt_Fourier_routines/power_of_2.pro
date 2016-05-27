;+
;*****************************************************************************************
;
;  FUNCTION :   power_of_2.pro
;  PURPOSE  :   Pads a [M]-Element input array with zeros to make it a [2^n]-Element
;                 array for use in FFT calculations.  Thus if one inputs:
;                 [2^a] < M < [2^b], the output will be a 2^(b+1) unless b > or = 18.
;                 In this case, the output will be just a [2^b]-Element array, unless
;                 otherwise specified.
;
;  CALLED BY:   
;               fft_power_calc.pro
;
;  CALLS:
;               power_of_2.pro
;
;  REQUIRES:    
;               NA
;
;  INPUT:
;               SIGNAL   :  An N-Element array of data [Float,Double,Complex, or 
;                             DComplex]
;
;  EXAMPLES:    
;               
;
;  KEYWORDS:    
;               FORCE_N  :  Set to a scalar power of 2 to force program to return 
;                             an array with this desired number of elements 
;                             [e.g.  FORCE_N = 2L^12]
;
;   CHANGED:  1)  Fixed syntax error
;                                                                  [12/03/2008   v1.0.1]
;             2)  Fixed an indexing issue
;                                                                  [02/25/2008   v1.0.2]
;             3)  Renamed and cleaned up
;                                                                  [08/10/2009   v2.0.0]
;             4)  Fixed a typo (routine tried to call old named version) and
;                   cleaned up man page and routine
;                                                                  [05/28/2014   v2.1.0]
;
;   NOTES:      
;               
;
;  REFERENCES:  
;               1)  Harris, F.J. "On the Use of Windows for Harmonic Analysis with the
;                      Discrete Fourier Transform," Proc. IEEE Vol. 66, No. 1,
;                      pp. 51-83, (1978).
;               2)  Paschmann, G. and P.W. Daly "Analysis Methods for Multi-Spacecraft
;                      Data," ISSI Scientific Report, Noordwijk, The Netherlands.,
;                      Int. Space Sci. Inst, (1998).
;               3)  Torrence, C. and G.P. Compo "A Practical Guide to Wavelet Analysis,"
;                      Bull. Amer. Meteor. Soc. 79, pp. 61-78, (1998).
;               4)  Donnelly, D. and B. Rust "The Fast Fourier Transform for
;                      Experimentalists, Part I:  Concepts," Comput. Sci. & Eng. 7(2),
;                      pp. 80-88, (2005).
;               5)  Donnelly, D. and B. Rust "The Fast Fourier Transform for
;                      Experimentalists, Part II:  Convolutions," Comput. Sci.
;                      & Eng. 7(4), pp. 92-95, (2005).
;               6)  Rust, B. and D. Donnelly "The Fast Fourier Transform for
;                      Experimentalists, Part III:  Classical Spectral Analysis,"
;                      Comput. Sci. & Eng. 7(5), pp. 74-78, (2005).
;               7)  Rust, B. and D. Donnelly "The Fast Fourier Transform for
;                      Experimentalists, Part IV:  Autoregressive Spectral Analysis,"
;                      Comput. Sci. & Eng. 7(6), pp. 85-90, (2005).
;               8)  Donnelly, D. "The Fast Fourier Transform for Experimentalists,
;                      Part V:  Filters," Comput. Sci. & Eng. 8(1), pp. 92-95, (2006).
;
;   CREATED:  11/20/2008
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  05/28/2014   v2.1.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION power_of_2,signal,FORCE_N=force_n

;;----------------------------------------------------------------------------------------
;;  Check system limits first
;;----------------------------------------------------------------------------------------
mem            = !VERSION.MEMORY_BITS
IF (mem GE 32) THEN BEGIN
  IF (mem EQ 32) THEN twolim = 30L ELSE twolim = 62L
ENDIF ELSE BEGIN
  twolim = 20L
ENDELSE
;;----------------------------------------------------------------------------------------
;;  Check data next
;;----------------------------------------------------------------------------------------
signal         = REFORM(signal)
ns             = N_ELEMENTS(signal)
tp             = SIZE(signal,/TYPE)
chck           = WHERE([4L,5L,6L,9L] EQ tp,ck)
IF (ck EQ 0L) THEN BEGIN
  MESSAGE,"Incorrect input format!",/INFORMATIONAL,/CONTINUE
  RETURN,signal
ENDIF ELSE BEGIN
  CASE chck[0] OF
    0   : BEGIN
      zero = 0.0
    END
    1   : BEGIN
      zero = 0d0
    END
    2   : BEGIN
      zero = COMPLEX(0.0)
    END
    3   : BEGIN
      zero = DCOMPLEX(0d0)
    END
  ENDCASE
ENDELSE
;;----------------------------------------------------------------------------------------
;;  Construct powers of 2 up to 2^18  [18 elements]
;;----------------------------------------------------------------------------------------
twopow = [1L,2L,3L,4L,5L,6L,7L,8L,9L,10L,11L,12L,13L,14L,15L,16L,17L,18L]
twoarr = 2L^(twopow)
;;----------------------------------------------------------------------------------------
;;  User predefined a specific number desired for output
;;----------------------------------------------------------------------------------------
IF KEYWORD_SET(force_n) THEN BEGIN             ;;  User wants specific value
  fon   = (ROUND(force_n))[0]
;;  LBW III  [05/28/2014   v2.1.0]
;  fon   = ROUND(force_n)
  tpn   = FLOAT(ALOG(fon)/(ALOG(2)))
  test  = (tpn - FLOAT(twopow)) EQ 0.0           ;;  Check to see if fon is a power of 2
;;  LBW III  [05/28/2014   v2.1.0]
;  test  = tpn - FLOAT(twopow) EQ 0.0           ;;  Check to see if fon is a power of 2
  gtest = WHERE(test EQ 1,gpn)
  lowz  = WHERE(twoarr LE fon,lwz)
  higz  = WHERE(twoarr GE fon,hgz)
  IF (fon GE ns) THEN BEGIN                    ;;  Value is relevant
    IF (lwz GT 0L AND hgz GT 0L) THEN BEGIN    ;;   2 < fon < 2^18
      IF (gpn GT 0L) THEN BEGIN                ;;  fon IS a power of 2
        dn = fon - ns
        nn = fon
      ENDIF ELSE BEGIN                         ;;  fon is NOT a power of 2
        numz = MIN(higz,/NAN)
        pn   = twopow[numz]
        dn   = 2L^(pn) - ns
        nn   = 2L^(pn)
      ENDELSE
    ENDIF ELSE BEGIN                           ;;   2 > fon or fon > 2^18
      IF (fon GT MAX(twoarr,/NAN)) THEN BEGIN  ;;   fon > 2^18L
        IF (tpn GT twolim) THEN BEGIN          ;;   fon > 2^30L  => if 32 bits, problem!
          pn = twolim
          nn = 2L^(pn)
          IF (nn LT ns) THEN BEGIN
            MESSAGE,"Input array has too many elements!",/INFORMATIONAL,/CONTINUE
            RETURN,signal
          ENDIF
          dn = nn - ns
        ENDIF ELSE BEGIN  ;;   2^18 < fon < 2^30
          pn = LONG(tpn) + 1L
          dn = 2L^(pn) - ns
          nn = 2L^(pn)
        ENDELSE
      ENDIF ELSE BEGIN                         ;;   2 > fon => USELESS!!!, check ns
        gsignal = power_of_2(signal)
;;  LBW III  [05/28/2014   v2.1.0]
;        gsignal = my_power_of_2(signal)
        RETURN,gsignal
      ENDELSE
    ENDELSE
  ENDIF ELSE BEGIN
    MESSAGE,"Why would you try to downsize?",/INFORMATIONAL,/CONTINUE
  ENDELSE
  IF (dn NE 0L) THEN BEGIN  ;;  In case someone tried to force array to have ns output els.
    new_signal = [signal,REPLICATE(zero,dn)]
  ENDIF ELSE BEGIN
    new_signal = signal
  ENDELSE
  RETURN,new_signal
ENDIF
;;----------------------------------------------------------------------------------------
;;  Determine number of zeros to pad data with
;;----------------------------------------------------------------------------------------
lowz           = WHERE(twoarr LE ns,lwz)
higz           = WHERE(twoarr GT ns,hgz)
numz           = MIN(higz,/NAN) > 0
IF (lwz EQ 18L AND hgz EQ 0L) THEN BEGIN  ;;  ns > 2^18
    test  = ns/4L > 1L
    test2 = ns > [(2L^18),(2L^19),(2L^20),(2L^21),(2L^22),(2L^22),(2L^23),(2L^24),$
                  (2L^25),(2L^26),(2L^27),(2L^28),(2L^29)]
    tchck = WHERE(test2 NE ns,gsmall)
    IF (gsmall EQ 0) THEN BEGIN   ;;  ns > 2L^29 => pukes...
      MESSAGE,"Why did you enter more than a 32 bit number?",/INFORMATIONAL,/CONTINUE
       new_signal = REPLICATE(zero,ns)
       RETURN,new_signal
    ENDIF ELSE BEGIN   ;;  ns < 2L^29
       dn = test2[tchck[0]] - ns
       nn = test2[tchck[0]]
    ENDELSE
ENDIF ELSE BEGIN           ;;   2 < ns < 2^18
  IF (lwz EQ 0L AND hgz EQ 0L) THEN BEGIN  ;;   2 > ns or ns < 2^18
    test  = ns/4L > 1L
    test2 = ns/(2L^18) > 2L
    CASE test OF
      1L   : BEGIN
        MESSAGE,"Not enough data points!",/INFORMATIONAL,/CONTINUE
        RETURN,signal
      END
      ELSE : BEGIN
        CASE test2 OF
          2L   : BEGIN  ;;  Wasn't greater than 2^19
            dn = 2L^19 - ns
            nn = 2L^19
          END
          ELSE : BEGIN
            pn = ROUND(ALOG(test2)/(ALOG(2d0)))
            dn = 2L^(18L + pn + 1L) - ns
            nn = 2L^(18L + pn + 1L)
          END
        ENDCASE
      END
    ENDCASE
  ENDIF ELSE BEGIN           ;;   2 < ns < 2^18
    pn = twopow[numz]
    dn = 2L^(pn) - ns
    nn = 2L^(pn)
  ENDELSE
ENDELSE

new_signal = [signal,REPLICATE(zero,dn)]
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN,new_signal
END

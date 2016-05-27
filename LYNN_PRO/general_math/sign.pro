;+
;*****************************************************************************************
;
;  FUNCTION :   sign.pro
;  PURPOSE  :   Returns the unit sign of an input array of data
;
;  CALLED BY:   
;               NA
;
;  CALLS:
;               NA
;
;  REQUIRES:    
;               NA
;
;  INPUT:
;               XX     :  N-Element array of x-data to be put into bins
;
;  EXAMPLES:    
;               ;-------------------------------------------------------------------------
;               ; => Get the sign of a real valued input
;               ;-------------------------------------------------------------------------
;               x  = DINDGEN(5)*2d0*!DPI/4 - !DPI ; => -Pi < x < +Pi
;               ss = sign(x)
;               PRINT,';',ss
;               ;     -1.00000     -1.00000      0.00000      1.00000      1.00000
;               ;-------------------------------------------------------------------------
;               ; => Get the sign of a complex valued input
;               ;-------------------------------------------------------------------------
;               x  = DINDGEN(5)*2d0*!DPI/4 - !DPI ; => -Pi < x < +Pi
;               y  = SIN(x)
;               xx = DCOMPLEX(x,y)
;               ss = sign(xx,/CMPLX)
;               PRINT,';  ',ss[0]
;               ;  (     -1.00000,     -1.00000)
;
;  KEYWORDS:    
;               CMPLX  :  If set, routine assumes input XX is a complex array of data
;                           and so will return a complex array of signs
;
;   CHANGED:  1)  NA [MM/DD/YYYY   v1.0.0]
;
;   NOTES:      
;               
;
;   CREATED:  04/20/2011
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  04/20/2011   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION sign,xx,CMPLX=cmplx

;-----------------------------------------------------------------------------------------
; => Define dummy variables
;-----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN

IF KEYWORD_SET(cmplx) THEN cc = 1 ELSE cc = 0
IF KEYWORD_SET(cc)    THEN rr = 0 ELSE rr = 1
;-----------------------------------------------------------------------------------------
; => Check input
;-----------------------------------------------------------------------------------------
xo  = REFORM(xx)
nx  = N_ELEMENTS(xo)

CASE 1 OF
  rr  :  BEGIN
    ; => Input is real
    ss = FLOAT(LONG(xx GT 0.) - (xx LT 0.))
    RETURN,ss
  END
  cc  :  BEGIN
    ; => Input is complex
    re  = REAL_PART(xx)
    im  = IMAGINARY(xx)
    sr  = FLOAT(LONG(re GT 0.) - (re LT 0.))
    si  = FLOAT(LONG(im GT 0.) - (im LT 0.))
    RETURN,COMPLEX(sr,si)
  END
ENDCASE

END
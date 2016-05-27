
; => Check the format of the input

FUNCTION error_prop_form,u,v

IF (N_PARAMS() LT 2) THEN v = REPLICATE(d,SIZE(u,/DIMENSIONS))
uo    = u
vo    = v
szu   = SIZE(uo,/DIMENSIONS)
szv   = SIZE(vo,/DIMENSIONS)
test0 = ((szu[0] EQ 2) OR (szu[1] EQ 2)) AND ((szv[0] EQ 2) OR (szv[1] EQ 2))
IF (N_ELEMENTS(szu) NE 2 OR N_ELEMENTS(szv) NE 2 OR ~test0) THEN BEGIN
  errmssg = 'Incorrect input format:  Must be [N,2]-Element arrays!'
  MESSAGE,errmssg,/INFORMATIONAL,/CONTINUE
  check = 0
ENDIF ELSE check = 1
IF (szu[0] EQ 2 AND szu[1] NE 2) THEN uo = TRANSPOSE(uo)
IF (szv[0] EQ 2 AND szv[1] NE 2) THEN vo = TRANSPOSE(vo)
szu   = SIZE(uo,/DIMENSIONS)
szv   = SIZE(vo,/DIMENSIONS)
test0 = (szu[0] NE szv[0])
IF (test0) THEN BEGIN
  errmssg = 'Incorrect input format:  1st dimension of input must have same # of elements!'
  MESSAGE,errmssg,/INFORMATIONAL,/CONTINUE
  check = 0
ENDIF ELSE check = 1
;-----------------------------------------------------------------------------------------
; => format arrays and return to user
;-----------------------------------------------------------------------------------------
IF (check EQ 0) THEN BEGIN
  RETURN,0
ENDIF ELSE BEGIN
  u = uo
  v = vo
ENDELSE

RETURN,[1,1]
END

;+
;*****************************************************************************************
;
;  FUNCTION :   error_prop_mult.pro
;  PURPOSE  :   Calculates the standard propagation of errors given an input set of data
;                 for up to six variables.
;
;  CALLED BY:   
;               NA
;
;  CALLS:
;               error_prop_form.pro
;
;  REQUIRES:    
;               NA
;
;  INPUT:
;               U  :  [N,2]-Element array of data where U[*,0] is the data and U[*,1]
;                       is the uncertainty in the data
;               V  :  [N,2]-Element array of data where V[*,0] is the data and V[*,1]
;                       is the uncertainty in the data
;               [The rest of the inputs have the same format, but are optional]
;
;  EXAMPLES:    
;               NA
;
;  KEYWORDS:    
;               NA
;
;   CHANGED:  1)  NA [MM/DD/YYYY   v1.0.0]
;
;   NOTES:      
;               
;
;  REFERENCES:  
;               1)  John R. Taylor (1997), "An Introduction to Error Analysis:  The
;                      Study of Uncertainties in Physical Measurements,"
;                      University Science Books.
;
;   CREATED:  05/01/2011
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  05/01/2011   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION error_prop_mult,u,v,w,x,y,z

;-----------------------------------------------------------------------------------------
; => Define dummy variables
;-----------------------------------------------------------------------------------------
f          = !VALUES.F_NAN
d          = !VALUES.D_NAN
;-----------------------------------------------------------------------------------------
; => Check input
;-----------------------------------------------------------------------------------------
IF (N_PARAMS() LT 2) THEN BEGIN
  errmssg = 'At least two input arrays must be present!'
  MESSAGE,errmssg,/INFORMATIONAL,/CONTINUE
  RETURN,0
ENDIF
; => Check input format
uo    = u
vo    = v
test  = error_prop_form(uo,vo)
IF (N_ELEMENTS(test) EQ 1) THEN RETURN,0
; => Now we know they are okay, we can proceed to check the other inputs
szu   = SIZE(uo,/DIMENSIONS)
nn    = szu[0]
yu    = 1
yv    = 1
;-----------------------------------------------------------------------------------------
; => Create dummy variables to replicate input if not given
;-----------------------------------------------------------------------------------------
wo    = REPLICATE(d,nn,2)
xo    = REPLICATE(d,nn,2)
yo    = REPLICATE(d,nn,2)
zo    = REPLICATE(d,nn,2)
yw    = 1 & yx = 1 & yy = 1 & yz = 1
CASE N_PARAMS() OF
  2  :  BEGIN
    yw = 0 & yx = 0 & yy = 0 & yz = 0
  END
  3  :  BEGIN
    ; => Check format of w
    u1   = uo
    tesw = error_prop_form(u1,w)
    IF (N_ELEMENTS(tesw) EQ 1) THEN yw = 0 ELSE wo = w
    yx   = 0 & yy = 0 & yz = 0
  END
  4  :  BEGIN
    ; => Check format of w
    u1   = uo
    tesw = error_prop_form(u1,w)
    IF (N_ELEMENTS(tesw) EQ 1) THEN yw = 0 ELSE wo = w
    ; => Check format of x
    u1   = uo
    tesw = error_prop_form(u1,x)
    IF (N_ELEMENTS(tesw) EQ 1) THEN yx = 0 ELSE xo = x
    yy   = 0 & yz = 0
  END
  5  :  BEGIN
    ; => Check format of w
    u1   = uo
    tesw = error_prop_form(u1,w)
    IF (N_ELEMENTS(tesw) EQ 1) THEN yw = 0 ELSE wo = w
    ; => Check format of x
    u1   = uo
    tesw = error_prop_form(u1,x)
    IF (N_ELEMENTS(tesw) EQ 1) THEN yx = 0 ELSE xo = x
    ; => Check format of y
    u1   = uo
    tesw = error_prop_form(u1,y)
    IF (N_ELEMENTS(tesw) EQ 1) THEN yy = 0 ELSE yo = y
    yz   = 0
  END
  6  :  BEGIN
    ; => Check format of w
    u1   = uo
    tesw = error_prop_form(u1,w)
    IF (N_ELEMENTS(tesw) EQ 1) THEN yw = 0 ELSE wo = w
    ; => Check format of x
    u1   = uo
    tesw = error_prop_form(u1,x)
    IF (N_ELEMENTS(tesw) EQ 1) THEN yx = 0 ELSE xo = x
    ; => Check format of y
    u1   = uo
    tesw = error_prop_form(u1,y)
    IF (N_ELEMENTS(tesw) EQ 1) THEN yy = 0 ELSE yo = y
    ; => Check format of z
    u1   = uo
    tesw = error_prop_form(u1,z)
    IF (N_ELEMENTS(tesw) EQ 1) THEN yz = 0 ELSE zo = z
  END
ENDCASE
;-----------------------------------------------------------------------------------------
; => Calculate the error propagation for q = u . v . w . x . y . z
;-----------------------------------------------------------------------------------------
ggy  = WHERE([yu,yv,yw,yx,yy,yz],gy)
sum  = TOTAL([yu,yv,yw,yx,yy,yz])
tags = ['T0','T1','T2','T3','T4','T5']
j    = 0
dat  = CREATE_STRUCT(tags,uo[*,j],vo[*,j],wo[*,j],xo[*,j],yo[*,j],zo[*,j])
j    = 1
del  = CREATE_STRUCT(tags,uo[*,j],vo[*,j],wo[*,j],xo[*,j],yo[*,j],zo[*,j])

CASE sum[0] OF
  2  :  BEGIN
    qo   = dat.(0)*dat.(1)
    dqo  = qo*SQRT((del.(0)/dat.(0))^2 + (del.(1)/dat.(1))^2)
  END
  3  :  BEGIN
    d0   = dat.(ggy[0]) & d1  = dat.(ggy[1]) & d2  = dat.(ggy[2])
    dd0  = del.(ggy[0]) & dd1 = del.(ggy[1]) & dd2 = del.(ggy[2])
    qo   = d0*d1*d2
    
    
    dqo  = qo*SQRT((dd0/d0)^2 + (dd1/d1)^2 + (dd2/d2)^2)
  END
  4  :  BEGIN
    d0   = dat.(ggy[0]) & d1  = dat.(ggy[1]) & d2  = dat.(ggy[2]) & d3  = dat.(ggy[3])
    dd0  = del.(ggy[0]) & dd1 = del.(ggy[1]) & dd2 = del.(ggy[2]) & dd3 = del.(ggy[3])
    qo   = d0*d1*d2*d3
    dqo  = qo*SQRT((dd0/d0)^2 + (dd1/d1)^2 + (dd2/d2)^2 + (dd3/d3)^2)
  END
  5  :  BEGIN
    d0   = dat.(ggy[0]) & d1  = dat.(ggy[1]) & d2  = dat.(ggy[2]) & d3  = dat.(ggy[3])
    dd0  = del.(ggy[0]) & dd1 = del.(ggy[1]) & dd2 = del.(ggy[2]) & dd3 = del.(ggy[3])
    d4   = dat.(ggy[4])
    dd4  = del.(ggy[4])
    qo   = d0*d1*d2*d3*d4
    dqo  = qo*SQRT((dd0/d0)^2 + (dd1/d1)^2 + (dd2/d2)^2 + (dd3/d3)^2 + (dd4/d4)^2)
  END
  6  :  BEGIN
    d0   = dat.(ggy[0]) & d1  = dat.(ggy[1]) & d2  = dat.(ggy[2]) & d3  = dat.(ggy[3])
    dd0  = del.(ggy[0]) & dd1 = del.(ggy[1]) & dd2 = del.(ggy[2]) & dd3 = del.(ggy[3])
    d4   = dat.(ggy[4]) & d5  = dat.(ggy[5])
    dd4  = del.(ggy[4]) & dd5 = del.(ggy[5])
    qo   = d0*d1*d2*d3*d4*d5
    dqo  = qo*SQRT((dd0/d0)^2 + (dd1/d1)^2 + (dd2/d2)^2 + (dd3/d3)^2 + (dd4/d4)^2 + (dd5/d5)^2)
  END
ENDCASE
;-----------------------------------------------------------------------------------------
; => Return dq = q*[ (du/u)^2 + (dv/v)^2 + (dw/w)^2 + (dx/x)^2 + (dy/y)^2 + (dz/z)^2 ]
;-----------------------------------------------------------------------------------------

RETURN,dqo
END















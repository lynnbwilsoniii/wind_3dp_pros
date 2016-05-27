;+
;*****************************************************************************************
;
;  FUNCTION :   exponential_round.pro
;  PURPOSE  :   Takes a scalar or array of exponential numbers and returns the 
;                 exponentials with rounded leading factors.  For example, if one
;                 sends in 1.13383934d-6, the program will return 1.0000000e-06.
;                 This is useful for determining tick values for log-scaled plots
;                 or contour levels.
;
;  CALLED BY:   
;               contour_3dp_plot_limits.pro
;
;  CALLS: 
;               roundsig.pro
;               interp.pro
;
;  REQUIRES:    
;               NA
;
;  INPUT:
;               XX      :  N-Element array of single or double precision values
;
;  EXAMPLES:    
;               NA
;
;  KEYWORDS:    
;               SIGFIG  :  Scalar long/integer defining the number of significant
;                            figures to round factors to
;
;   CHANGED:  1)  Fixed issue arising from too many similar leading factors
;                                                                  [09/01/2009   v1.0.1]
;             2)  Changed exponent calculation and removed while loop
;                                                                  [09/18/2009   v1.1.0]
;             3)  Altered the number of times the program can be re-called
;                                                                  [09/23/2009   v1.2.0]
;             4)  Added error handling to attempt to deal with non-finite input
;                                                                  [05/05/2010   v1.3.0]
;             5)  Got rid of error message for non-finite input
;                                                                  [05/12/2010   v1.3.1]
;             6)  Updated man page, changed factor calculation and many more things,
;                   and added keyword:  SIGFIG                     [06/21/2010   v1.4.0]
;
;   NOTES:      
;               1)  This program is most useful if XX is a range of data values
;
;   CREATED:  08/31/2009
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  06/21/2010   v1.4.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION exponential_round,xx,SIGFIG=sigfig

;-----------------------------------------------------------------------------------------
; => Define some constants and dummy variables
;-----------------------------------------------------------------------------------------
f            = !VALUES.F_NAN
d            = !VALUES.D_NAN
dform        = '(e17.8)'
stags        = ['FACTORS','EXPONENTS','ROUNDED_EXP']
logic_return = 0

IF (N_ELEMENTS(sigfig) NE 1) THEN sigs = 2 ELSE sigs = LONG(sigfig[0])
;-----------------------------------------------------------------------------------------
; => Check input
;-----------------------------------------------------------------------------------------
new_x    = REFORM(xx)
dtype    = SIZE(new_x,/TYPE)
IF (dtype EQ 5) THEN ten = 1d1 ELSE ten = 1e1

negative = WHERE(new_x LT 0.,bneg,COMPLEMENT=positive,NCOMPLEMENT=gpos)
zeros    = WHERE(new_x EQ 0.,bzer,COMPLEMENT=nonzero,NCOMPLEMENT=gnon)
IF (bneg NE 0) THEN new_x[negative] = 1.
;-----------------------------------------------------------------------------------------
; => Determine leading factor and exponent
;-----------------------------------------------------------------------------------------
nx       = N_ELEMENTS(new_x)
factor   = FLTARR(nx)      ; => Multiplicative factor for powers of 10
exponent = FLTARR(nx)      ; => Powers of 10

temp     = ALOG10(ABS(new_x))
texpo    = FLOOR(temp - sigs)
efactor  = temp - texpo
pow_10   = ten^(texpo + sigs)
tfacs    = new_x/pow_10

factor   = roundsig(tfacs,SIGFIG=sigs)
exponent = ALOG10(pow_10)
ret_exp  = factor*ten^(exponent)
;-----------------------------------------------------------------------------------------
; => Return data to user
;-----------------------------------------------------------------------------------------
nexpo  = CREATE_STRUCT(stags,DOUBLE(factor),exponent,ret_exp)
RETURN,nexpo
END

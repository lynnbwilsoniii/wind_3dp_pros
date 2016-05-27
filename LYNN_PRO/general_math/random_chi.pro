;+
;*****************************************************************************************
;
;  FUNCTION :   random_gamma.pro
;  PURPOSE  :   Generate a gamma-distribution of random variables.
;
;  CALLED BY:   
;               random_chi.pro
;
;  CALLS:
;               NA
;
;  REQUIRES:    
;               NA
;
;  INPUT:
;               SEED   :  The seed for the random number generation
;               ALPHA  :  Scalar shape parameter of gamma distribution
;               GBETA  :  Scalar shape parameter of gamma distribution
;               NRAND  :  [Optional] Scalar defining the number of random numbers to use
;                          [Default = 1]
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
;               1)  Gamma distribution with:  alpha = Dof/2, beta = 1/2
;                      => chi-squared distribution
;
;   CREATED:  09/12/2011
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  09/12/2011   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION random_gamma,seed,alpha,gbeta,nrand

;-----------------------------------------------------------------------------------------
; => Define dummy variables
;-----------------------------------------------------------------------------------------
f          = !VALUES.F_NAN
d          = !VALUES.D_NAN
;-----------------------------------------------------------------------------------------
; => Check input
;-----------------------------------------------------------------------------------------
IF (N_PARAMS() LT 3) THEN RETURN,d
IF (alpha[0] LE 0 OR gbeta[0] LE 0) THEN BEGIN
  errmsg = 'ALPHA and BETA must both be greater than zero.'
  MESSAGE,errmsg[0],/INFORMATIONAL,/CONTINUE
  RETURN,d
ENDIF
IF (N_ELEMENTS(nrand) EQ 0) THEN nr = 1 ELSE nr = nrand[0]

IF (alpha[0] LE 1) THEN BEGIN
  alpha   += 1
  alfshift = 1
ENDIF ELSE BEGIN
  alfshift = 0
ENDELSE
;-----------------------------------------------------------------------------------------
; => define parameters
;-----------------------------------------------------------------------------------------
dd     = alpha[0] - 1d0/3d0
cc     = 1d0/SQRT(9d0*dd[0])
gammad = DBLARR(nr)
nempty = nr[0]
emptyd = LINDGEN(nr[0])
;-----------------------------------------------------------------------------------------
; => define gamma distribution
;-----------------------------------------------------------------------------------------
REPEAT BEGIN
    x   = RANDOMN(seed, nempty)
    v   = 1 + cc[0]*x
    bad = WHERE(v LE 0, nbad)
    WHILE (nbad GT 0) DO BEGIN
        x2     = RANDOMN(seed, nbad)
        x[bad] = x2
        v[bad] = 1 + cc[0]*x2
        bad2   = WHERE(v[bad] LE 0, nbad2)
        IF (nbad2 GT 0) THEN bad = bad[bad2]
        nbad   = bad2
    ENDWHILE
    v      = v^3
    unif   = RANDOMU(seed, nempty)
    factor = 5d-1*x^2 + dd[0] - dd[0]*v + dd[0]*ALOG(v)
    u      = WHERE(ALOG(unif) LT factor,nu,COMPLEMENT=empty1)
    IF (nu GT 0) THEN gammad[emptyd[u]] = dd[0]*v[u]
    nempty = nempty - nu
    IF (nempty NE 0) THEN emptyd = emptyd[empty1]
ENDREP UNTIL (nempty EQ 0)

IF (alfshift) THEN BEGIN
    alpha -= 1
    gammad = gammad*(RANDOMU(seed,nr[0]))^(1d0/alpha)
ENDIF
; => Normalize gamma distribution
gammad /= gbeta[0]
;-----------------------------------------------------------------------------------------
; => Return gamma distribution
;-----------------------------------------------------------------------------------------

RETURN,gammad
END


;+
;*****************************************************************************************
;
;  FUNCTION :   random_chi.pro
;  PURPOSE  :   Generate a chi-squared distribution of random variables.
;
;  CALLED BY:   
;               NA
;
;  CALLS:
;               random_gamma.pro
;
;  REQUIRES:    
;               NA
;
;  INPUT:
;               SEED  :  The seed for the random number generation
;               DOF   :  Scalar defining the degrees of freedom
;               NRAND :  [Optional] Scalar defining the number of random numbers to use
;                          [Default = 1]
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
;   CREATED:  09/12/2011
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  09/12/2011   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION random_chi,seed,dof,nrand

;-----------------------------------------------------------------------------------------
; => Define dummy variables
;-----------------------------------------------------------------------------------------
f          = !VALUES.F_NAN
d          = !VALUES.D_NAN
;-----------------------------------------------------------------------------------------
; => Check input
;-----------------------------------------------------------------------------------------
IF (N_PARAMS() LT 2) THEN RETURN,d
IF (N_ELEMENTS(nrand) EQ 0) THEN nr = 1 ELSE nr = nrand[0]
; => Define the shape parameter of gamma distribution
alpha      = dof[0]/2d0
gbeta      = 5d-1
;-----------------------------------------------------------------------------------------
; => Generate chi-squared dist.
;-----------------------------------------------------------------------------------------
chisqr     = random_gamma(seed,alpha,gbeta,nr)
;-----------------------------------------------------------------------------------------
; => Return chi-squared
;-----------------------------------------------------------------------------------------

RETURN,chisqr
END
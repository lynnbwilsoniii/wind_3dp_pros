;+
;*****************************************************************************************
;
;  FUNCTION :   wrapper_pl_cor.pro
;  PURPOSE  :   This is the main level routine which utilizes the rest of the routines
;                 relevant the calculation of the dead time and efficiency corrections
;                 for the PESA Low detector onboard the Wind spacecraft.
;
;  CALLED BY:   
;               
;
;  CALLS:
;               check_input_cor_pl.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               PL_DENS     :  [N]-Element array of densities [cm^(-3)] from
;                                PESA Low 8x8 array on-board moments that have
;                                not been corrected
;               VSW_MAG     :  [N]-Element array of Vsw magnitudes [km/s]
;               VTI_O       :  [N]-Element array of ion thermal speeds [km/s]
;               DENS_TRUE   :  [N]-Element array of densities [cm^(-3)] from
;                                Wind/SWE which represent the "true" ion density
;
;  EXAMPLES:    
;               
;
;  KEYWORDS:    
;               EFFICIENCY  :  Set to a named variable to return the scalar estimate
;                                of the absolute counting efficiency of the
;                                PESA Low MCP
;               DEADTIME    :  Set to a named variable to return the scalar estimate
;                                of the detector dead time [seconds]
;
;   CHANGED:  1)  NA [MM/DD/YYYY   v1.0.0]
;
;   NOTES:      
;               1)  MCP = multi-channel plate
;               2)  The dead time for PESA Low is not a fixed preamp electronic
;                     dead time, so it is not one microsecond as one might guess
;                     since the instrument paper says the Wind/3DP detector uses
;                     a 2 MHz counter.
;
;  REFERENCES:  
;               1)  Wuest, M., D.S. Evans, and R. von Steiger (2007), "Calibration of
;                      Particle Instruments in Space Physics," ISSI/ESA Publications
;                      Division, Keplerlaan 1, 2200 AG Noordwijk, The Netherlands.
;                      [Chapter 4.4.5 primarily]
;               2)  Lin et al., (1995), "A Three-Dimensional Plasma and Energetic
;                      particle investigation for the Wind spacecraft," Space Sci. Rev.
;                      Vol. 71, pp. 125.
;               3)  Levenberg-Marquardt Method in any Numerical Recipes book
;
;   CREATED:  07/20/2011
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  07/20/2011   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

PRO wrapper_pl_cor,pl_dens,vsw_mag,dens_true,vti_o, $
                   EFFICIENCY=efficiency,DEADTIME=deadtime

;-----------------------------------------------------------------------------------------
; => Define dummy variables
;-----------------------------------------------------------------------------------------
f          = !VALUES.F_NAN
d          = !VALUES.D_NAN
; => define initial guesses for 2 unknowns
eff0       = 0.60                     ; => theory of ion MCPs suggest this as upper limit
tau0       = 1d-3                     ; => deadtime of a 2 MHz clock
imat       = IDENTITY(2,/DOUBLE)      ; => 2x2 Identity Matrix
lambda0    = 1d-3                     ; => Initial start lambda
nn         = 100L
IF ~KEYWORD_SET(nmax) THEN nmax = nn ELSE nmax = LONG(nmax[0])
;-----------------------------------------------------------------------------------------
; => Check input
;-----------------------------------------------------------------------------------------
nio        = REFORM(pl_dens)          ; => PESA Low ion Densities [cm^(-3)]
vswm       = REFORM(vsw_mag)          ; => PESA Low Vsw [km/s]
vti        = REFORM(vti_o)            ; => PESA Low ion thermal speed [km/s]
nit        = REFORM(dens_true)        ; => Wind/SWE ion Densities [cm^(-3)]
check      = check_input_cor_pl(nio,vswm,nit,vti)
IF (check[0] EQ 0) THEN BEGIN
  errmsg = 'Incorrect input format...'
  MESSAGE,errmsg[0],/INFORMATIONAL,/CONTINUE
  RETURN
ENDIF
;-----------------------------------------------------------------------------------------
; => Calculate initial chi^2, beta, and alpha
;-----------------------------------------------------------------------------------------
chi_sq0      = merit_func_pl_calc(nio,vswm,nit,vti,eff0,tau0)
beta_str0    = beta_calc_pl_cor(nio,vswm,nit,vti,eff0,tau0)
alpha_str0   = alpha_calc_pl_cor(nio,vswm,nit,vti,eff0,tau0)

beta_0       = [beta_str0.D_EFF[0],beta_str0.D_TAU[0]]
alpha_0      = DBLARR(2,2)
alpha_0      = [[alpha_str0.D_EFF_EFF[0],alpha_str0.D_EFF_TAU[0]],$
                [alpha_str0.D_TAU_EFF[0],alpha_str0.D_TAU_TAU[0]]]
;alpha_0      = [[alpha_str0.D_EFF_EFF[0],alpha_str0.D_TAU_EFF[0]],$
;                [alpha_str0.D_EFF_TAU[0],alpha_str0.D_TAU_TAU[0]]]

alpha_p0     = alpha_0 + lambda0[0]*imat                  ; => alpha' in NM book
; => Solve for delta_a
delta_a0     = CRAMER(alpha_p0,beta_0,/DOUBLE)
chi_sq1      = merit_func_pl_calc(nio,vswm,nit,vti,eff0[0]+delta_a0[0],tau0[0]+delta_a0[1])
; => Define values to update each iteration
eff1       = eff0
tau1       = tau0
old_chisq  = chi_sq0[0]
stop
true       = 1
jj         = 0
gg         = 0
WHILE (true) DO BEGIN
  diff_chi   = (chi_sq1[0] - old_chisq[0]) GE 0
  CASE diff_chi[0] OF
    1 : BEGIN
      ; Failure
      ; 1)  increase lambda and try again
      ; 2)  solve for delta_a
      lambda0     *= 1d1
      alpha_p0     = alpha_0 + lambda0[0]*imat
      delta_a0     = CRAMER(alpha_p0,beta_0,/DOUBLE)
      chi_sq1      = merit_func_pl_calc(nio,vswm,nit,vti,eff1[0]+delta_a0[0],tau1[0]+delta_a0[1])
    END
    0 : BEGIN
      ; Success
      ; => decrease lambda and try again
      ; 1)  decrease lambda
      ; 2)  redefine new unknown guesses
      ; 3)  solve for new alpha, beta, and delta_a
      lambda0     *= 1d1
      eff1        += delta_a0[0]
      tau1        += delta_a0[1]
      old_chisq    = chi_sq1[0]
      ; => Find new alpha and beta
      alpha_str0   = alpha_calc_pl_cor(nio,vswm,nit,vti,eff1,tau1)
      beta_str0    = beta_calc_pl_cor(nio,vswm,nit,vti,eff1,tau1)
      beta_0       = [beta_str0.D_EFF[0],beta_str0.D_TAU[0]]
      alpha_0      = [[alpha_str0.D_EFF_EFF[0],alpha_str0.D_EFF_TAU[0]],$
                      [alpha_str0.D_TAU_EFF[0],alpha_str0.D_TAU_TAU[0]]]
      ; => Find new delta_a
      bad_beta     = (TOTAL(beta_0) EQ 0) OR (TOTAL(FINITE(beta_0)) EQ 0)
      bad_alpha    = (TOTAL(alpha_0) EQ 0) OR (TOTAL(FINITE(alpha_0)) EQ 0)
      IF (bad_beta OR bad_alpha) THEN BEGIN
        true = 0
        GOTO,JUMP_END
      ENDIF ELSE BEGIN
        alpha_p0     = alpha_0 + lambda0[0]*imat
        delta_a0     = CRAMER(alpha_p0,beta_0,/DOUBLE)
        chi_sq1      = merit_func_pl_calc(nio,vswm,nit,vti,eff1[0]+delta_a0[0],tau1[0]+delta_a0[1])
      ENDELSE
    END
  ENDCASE
  ; => Define condition for stopping:
  ;      1)  |delta_chisq| < 0.001
  ;      2)  delta_chisq < 0    [i.e. chi^2 decreased]
  
  true   = (((ABS(chi_sq1[0] - old_chisq[0]) LE 0.001) AND diff_chi[0]) OR (jj GT nmax)) NE 1
  ;=======================================================================================
  JUMP_END:
  ;=======================================================================================
  jj += true
  IF (true EQ 0) THEN PRINT,STRTRIM(jj,2)+' iterations performed...'
  IF (true EQ 0) THEN PRINT,STRTRIM(gg,2)+' chi^2 shifts...'
ENDWHILE

; => Use the following method to find the shifts in the 2 unknowns for each iteration
;
;     delta_a = 
;
;    dela0     = CRAMER(alpha+lammat,betak,/DOUBLE)

stop





RETURN
END
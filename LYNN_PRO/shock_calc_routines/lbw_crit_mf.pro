;*****************************************************************************************
;
;  FUNCTION :   lbw_crit_mf_u1x.pro
;  PURPOSE  :   Determines solution to normalized upstream Ux
;                 This is Equation (9) in MPPulupa_Critical_Mach_Notes.pdf
;
;  CALLED BY:   
;               lbw_crit_mf.pro
;
;  INCLUDES:
;               NA
;
;  CALLS:
;               NA
;
;  REQUIRES:    
;               NA
;
;  INPUT:
;               G    :  Scalar [numeric] defining the polytrope index [unitless]
;               B1   :  Scalar [numeric] defining the upstream plasma beta [unitless]
;               TH1  :  Scalar [numeric] defining the upstream shock normal angle [rad]
;               TH2  :  Scalar [numeric] defining the downstream " "
;               U2X  :  Scalar [numeric] defining the normalized downstream X bulk speed
;                         u_2x = U_2x/V_2 [unitless]
;               U2Z  :  Scalar [numeric] defining the normalized downstream Z bulk speed
;                         u_2z = U_2z/V_2 [unitless]
;
;  EXAMPLES:    
;               [calling sequence]
;               u_1x = lbw_crit_mf_u1x(g, b1, th1, th2, u2x, u2z)
;
;  KEYWORDS:    
;               NA
;
;   CHANGED:  1)  Cleaned up a little and renamed to lbw_crit_mf_u1x.pro from crit_mf_u1x.pro
;                                                                   [02/18/2019   v1.0.1]
;
;   NOTES:      
;               NA
;
;  REFERENCES:  
;               NA
;
;   ADAPTED FROM: crit_mf_u1x.pro    BY: Marc Pulupa
;   CREATED:  ??/??/????
;   CREATED BY:  Marc Pulupa
;    LAST MODIFIED:  02/18/2019   v1.0.1
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************

FUNCTION lbw_crit_mf_u1x, g, b1, th1, th2, u2x, u2z

;;----------------------------------------------------------------------------------------
;;  Determine solution to normalized upstream Ux
;;----------------------------------------------------------------------------------------
;;  term0 = 2*( Tan(th2)*Cos(th1)^2 - Sin(th1)*Cos(th1) )
term0          = 2e0*(TAN(th2)*COS(th1)^2e0 - SIN(th1)*COS(th1))
;;  term1 = (u_2x/u_2z)*Tan(th2) - 1
term1          = u2x/u2z*TAN(th2) - 1e0
;;  term2 = beta_1*Tan(th1)
term2          = b1*TAN(th1)
term3          = term0*term1/term2
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN, (term3)^(1e0/2e0)
END
;  return, (2.*(TAN(th2)*COS(th1)^2. - SIN(th1)*COS(th1))*(u2x/u2z*TAN(th2) - 1.)/ $
;           ( b1*TAN(th1) ))^(1./2)


;*****************************************************************************************
;
;  FUNCTION :   lbw_crit_mf_u2z.pro
;  PURPOSE  :   Determines solution to normalized downstream Uz
;                 This is Equation (12) in MPPulupa_Critical_Mach_Notes.pdf
;
;  CALLED BY:   
;               lbw_crit_mf_rh4.pro
;               lbw_crit_mf.pro
;
;  INCLUDES:
;               NA
;
;  CALLS:
;               NA
;
;  REQUIRES:    
;               NA
;
;  INPUT:
;               G    :  Scalar [numeric] defining the polytrope index [unitless]
;               B1   :  Scalar [numeric] defining the upstream plasma beta [unitless]
;               TH1  :  Scalar [numeric] defining the upstream shock normal angle [rad]
;               TH2  :  Scalar [numeric] defining the downstream " "
;               U2X  :  Scalar [numeric] defining the normalized downstream X bulk speed
;                         u_2x = U_2x/V_2 [unitless]
;
;  EXAMPLES:    
;               [calling sequence]
;               u_2z = lbw_crit_mf_u2z(g, b1, th1, th2, u2x)
;
;  KEYWORDS:    
;               NA
;
;   CHANGED:  1)  Cleaned up a little and renamed to lbw_crit_mf_u1z.pro from crit_mf_u2z.pro
;                                                                   [02/18/2019   v1.0.1]
;
;   NOTES:      
;               NA
;
;  REFERENCES:  
;               NA
;
;   ADAPTED FROM: crit_mf_u2z.pro    BY: Marc Pulupa
;   CREATED:  ??/??/????
;   CREATED BY:  Marc Pulupa
;    LAST MODIFIED:  02/18/2019   v1.0.1
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************

FUNCTION lbw_crit_mf_u2z, g, b1, th1, th2, u2x

;;----------------------------------------------------------------------------------------
;;  Define some trig values
;;----------------------------------------------------------------------------------------
s1             = SIN(th1) & c1 = COS(th1) & t1 = TAN(th1)
s2             = SIN(th2) & c2 = COS(th2) & t2 = TAN(th2)
;;----------------------------------------------------------------------------------------
;;  Determine solution to normalized downstream Uz
;;----------------------------------------------------------------------------------------
;;  term0 = u_2x*Tan(th2) - (u_2x^2 + 1)*Tan(th1)/u_2x
term0          = u2x*t2 - (u2x^2e0 + 1e0)*t1/u2x
;;  term1 = Cos(th1)^2 * Tan(th2)^2 - beta_1 - Sin(th1)^2
term1          = c1^2e0*t2^2e0 - b1 - s1^2e0
;;  term2 = 2*( Tan(th2)*Cos(th1)^2 - Sin(th1)*Cos(th1) )
term2          = 2e0*(t2*c1^2e0 - s1*c1)
;;  term3 = 1 + Tan(th1)*term1/term2
term3          = 1e0 + t1*term1/term2
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN,term0/term3
END
;  return, (u2x*t2-(u2x^2+1.)*t1/u2x)/ $
;          (1+(t1*(c1^2*t2^2-s1^2-b1))/(2*(t2*c1^2-s1*c1)))


;*****************************************************************************************
;
;  FUNCTION :   lbw_crit_mf_cf.pro
;  PURPOSE  :   Determines the solution to the upstream critical Mach number
;                 This is Equation (16) in MPPulupa_Critical_Mach_Notes.pdf
;                 divided by u_1x
;
;  CALLED BY:   
;               lbw_crit_mf.pro
;
;  INCLUDES:
;               NA
;
;  CALLS:
;               NA
;
;  REQUIRES:    
;               NA
;
;  INPUT:
;               G    :  Scalar [numeric] defining the polytrope index [unitless]
;               B1   :  Scalar [numeric] defining the upstream plasma beta [unitless]
;               TH1  :  Scalar [numeric] defining the upstream shock normal angle [rad]
;
;  EXAMPLES:    
;               [calling sequence]
;               mf_cf = lbw_crit_mf_cf(g, b1, th1)
;
;  KEYWORDS:    
;               NA
;
;   CHANGED:  1)  Cleaned up a little and renamed to lbw_crit_mf_cf.pro from crit_mf_cf.pro
;                                                                   [02/18/2019   v1.0.1]
;
;   NOTES:      
;               NA
;
;  REFERENCES:  
;               NA
;
;   ADAPTED FROM: crit_mf_cf.pro    BY: Marc Pulupa
;   CREATED:  ??/??/????
;   CREATED BY:  Marc Pulupa
;    LAST MODIFIED:  02/18/2019   v1.0.1
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************

FUNCTION lbw_crit_mf_cf, g, b1, th1

;;----------------------------------------------------------------------------------------
;;  Determine solution to upstream critical Mach number
;;----------------------------------------------------------------------------------------
;;  term0 = ( 2 + gamma*beta_1 )/( 2*beta_1 )
term0          = (2e0 + g*b1)/(2e0*b1)
;;  term1 = ( 2*gamma/beta_1 )*Cos(th1)^2
term1          = 2e0*g*COS(th1)^2e0/b1
;;  term2 = [ {( 2 + gamma*beta_1 )/( 2*beta_1 )}^2 - {( 2*gamma/beta_1 )*Cos(th1)^2} ]^(1/2)
;;        = [term0^2 - term1]^(1/2)
term2          = SQRT(term0^2e0 - term1)
term3          = SQRT(term0 + term2)
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN,term3
END
;  return, SQRT((2+g*b1)/(2*b1) $
;               +(((2+g*b1)/(2*b1))^2 $
;                 -2*g/b1*COS(th1)^2)^(1./2))


;*****************************************************************************************
;
;  FUNCTION :   lbw_crit_mf_rh4.pro
;  PURPOSE  :   Determine normalized RH4
;                 This is Equation (4) in MPPulupa_Critical_Mach_Notes.pdf
;
;  CALLED BY:   
;               lbw_crit_mf.pro
;
;  INCLUDES:
;               NA
;
;  COMMON BLOCKS:
;               LBW_CRIT_MF_COM
;
;  CALLS:
;               lbw_crit_mf_u2z.pro
;
;  REQUIRES:    
;               NA
;
;  INPUT:
;               TH2  :  Scalar [numeric] defining the downstream shock normal angle [rad]
;
;  EXAMPLES:    
;               [calling sequence]
;               mf_rh4 = lbw_crit_mf_rh4(th2)
;
;  KEYWORDS:    
;               NA
;
;   CHANGED:  1)  Cleaned up a little and renamed to lbw_crit_mf_rh4.pro from crit_mf_rh4.pro
;                                                                   [02/18/2019   v1.0.1]
;
;   NOTES:      
;               NA
;
;  REFERENCES:  
;               NA
;
;   ADAPTED FROM: crit_mf_rh4.pro    BY: Marc Pulupa
;   CREATED:  ??/??/????
;   CREATED BY:  Marc Pulupa
;    LAST MODIFIED:  02/18/2019   v1.0.1
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************

FUNCTION lbw_crit_mf_rh4,th2

;;----------------------------------------------------------------------------------------
;;  Define common block
;;----------------------------------------------------------------------------------------
COMMON lbw_crit_mf_com, g, b1, th1, u2x, teti2
;;----------------------------------------------------------------------------------------
;;  Define some trig values
;;----------------------------------------------------------------------------------------
s1             = SIN(th1) & c1 = COS(th1) & t1 = TAN(th1)
s2             = SIN(th2) & c2 = COS(th2) & t2 = TAN(th2)
;;  Check u_2x value
IF (u2x LE 0) THEN BEGIN
  ;;  Initialize u_2x
  u2x_old = u2x
  IF (u2x EQ -1) THEN BEGIN
    ;;  Use u_2x = 3*Cos(th2)*[1/(Tr2 + 1)]^(1/2) from Table for Foreshock** critical Mach number
    u2x = 3e0*c2*SQRT(1e0/(teti2 + 1e0))
  ENDIF ELSE BEGIN
    ;;  Use u_2x = 3*Cos(th2)*[g/(Tr2 + 1)]^(1/2) from Table for Foreshock(K85) critical Mach number
    IF (u2x EQ -2) THEN u2x = 3e0*c2*SQRT(g/(teti2 + 1e0))
  ENDELSE
ENDIF ELSE u2x_old = u2x
;;  Calculate u_2z
u2z            = lbw_crit_mf_u2z(g, b1, th1, th2, u2x)
;;  Determine normalized RH4
;;  term0 = beta_1*gamma/(gamma - 1) + 2*Sin(th1)^2 - 2*Cos(th1)*Sin(th1)*Tan(th2)
term0          = b1*g/(g - 1e0) + 2e0*s1^2e0 - 2e0*c1*s1*t2
;;  term1a = Tan(th2)*Cos(th1)^2 - Sin(th1)*Cos(th1)
term1a         = t2*c1^2e0 - s1*c1
;;  term1b = (u_2x/u_2z)*Tan(th2) - 1
term1b         = u2x*t2/u2z - 1e0
;;  term1 = (term1a*term1b)/Tan(th1)
term1          = term1a*term1b/t1
;;  term2a = -2*Tan(th1)*[Tan(th2)*Cos(th1)^2 - Sin(th1)*Cos(th1)]
term2a         = -2e0*t1*(t2*c1^2e0 - s1*c1)
;;  term2b = u_2z*(u_2x*Tan(th2) - u_2z)
term2b         = u2z*(u2x*t2 - u2z)
;;  term2c = gamma/(gamma - 1) + [u_2x^2 + u_2z^2]/2
term2c         = g/(g - 1e0) + (u2x^2e0 + u2z^2e0)/2e0
term2          = term2a*term2c/term2b
rh4            = term0 + term1 + term2
;;  Reset u_2x
u2x            = u2x_old
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN,rh4
END
;  rh4 = b1*g/(g-1) $
;        +(t2*c1^2-s1*c1)*(u2x*t2/u2z-1.)/t1 $
;        +2*s1^2 $
;        -2*t1*(t2*c1^2-s1*c1)/(u2z*(u2x*t2-u2z))*(g/(g-1.)+u2x^2/2.+u2z^2/2.) $
;        -2*s1*c1*t2


;*****************************************************************************************
;
;  FUNCTION :   lbw_crit_mf_thz1.pro
;  PURPOSE  :   Determines the result of Equations (13) or (15) from
;                 MPPulupa_Critical_Mach_Notes.pdf
;
;  CALLED BY:   
;               lbw_crit_mf.pro
;
;  INCLUDES:
;               NA
;
;  COMMON BLOCKS:
;               LBW_CRIT_MF_COM
;
;  CALLS:
;               NA
;
;  REQUIRES:    
;               NA
;
;  INPUT:
;               NA
;
;  EXAMPLES:    
;               [calling sequence]
;               mf_thz1 = lbw_crit_mf_thz1()
;
;  KEYWORDS:    
;               NA
;
;   CHANGED:  1)  Cleaned up a little and renamed to lbw_crit_mf_thz1.pro from crit_mf_thz1.pro
;                                                                   [02/18/2019   v1.0.1]
;
;   NOTES:      
;               NA
;
;  REFERENCES:  
;               NA
;
;   ADAPTED FROM: crit_mf_thz1.pro    BY: Marc Pulupa
;   CREATED:  ??/??/????
;   CREATED BY:  Marc Pulupa
;    LAST MODIFIED:  02/18/2019   v1.0.1
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************

FUNCTION lbw_crit_mf_thz1

;;----------------------------------------------------------------------------------------
;;  Define common block
;;----------------------------------------------------------------------------------------
COMMON lbw_crit_mf_com, g, b1, th1, u2x, teti2
;;----------------------------------------------------------------------------------------
;;  Define some trig values
;;----------------------------------------------------------------------------------------
s1             = SIN(th1) & c1 = COS(th1) & t1 = TAN(th1)
;;----------------------------------------------------------------------------------------
;;  Determine if solving Equation (13) or Equation (15)
;;----------------------------------------------------------------------------------------
;;  Check u_2x value to define coefficients for root finding
IF (u2x GT 0) THEN BEGIN
  ;;  Return TH2 from Equation (13)
  thz = ATAN(TAN(th1)*(u2x^2e0 + 1e0)/u2x^2e0)
  RETURN, thz
ENDIF ELSE IF (u2x EQ -1) THEN BEGIN
  ;;  Use u_2x = [1/(Tr2 + 1)]^(1/2) from Table for Second critical Mach number
  coeffs = [t1*(1e0 + (teti2 + 1e0)/9e0),-1e0,(teti2 + 1e0)/9e0*t1]
ENDIF ELSE IF (u2x EQ -2) THEN BEGIN
  ;;  Use u_2x = [g/(Tr2 + 1)]^(1/2) from Table for Second(K85)* critical Mach number
  coeffs = [t1*(1e0 + (teti2 + 1e0)/(9e0*g)),-1e0,(teti2 + 1e0)/(9e0*g)*t1]
ENDIF
;;  Numerically solve Equation (15)
roots          = FZ_ROOTS(coeffs)
real_roots     = WHERE(IMAGINARY(roots) LT (MACHAR()).EPS,real_count)
IF (real_count[0] EQ 0) THEN RETURN,0e0
;;  Define roots for theta
thz            = ATAN(REAL_PART(roots[real_roots]))
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN,thz
END


;*****************************************************************************************
;
;  FUNCTION :   lbw_crit_mf_thz2.pro
;  PURPOSE  :   Determines the numerical result of Equation (15) from
;                 MPPulupa_Critical_Mach_Notes.pdf for different u_2x
;
;  CALLED BY:   
;               lbw_crit_mf.pro
;
;  INCLUDES:
;               NA
;
;  COMMON BLOCKS:
;               LBW_CRIT_MF_COM
;
;  CALLS:
;               NA
;
;  REQUIRES:    
;               NA
;
;  INPUT:
;               NA
;
;  EXAMPLES:    
;               [calling sequence]
;               mf_thz2 = lbw_crit_mf_thz2()
;
;  KEYWORDS:    
;               NA
;
;   CHANGED:  1)  Cleaned up a little and renamed to lbw_crit_mf_thz2.pro from crit_mf_thz2.pro
;                                                                   [02/18/2019   v1.0.1]
;
;   NOTES:      
;               NA
;
;  REFERENCES:  
;               NA
;
;   ADAPTED FROM: crit_mf_thz2.pro    BY: Marc Pulupa
;   CREATED:  ??/??/????
;   CREATED BY:  Marc Pulupa
;    LAST MODIFIED:  02/18/2019   v1.0.1
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************

FUNCTION lbw_crit_mf_thz2

;;----------------------------------------------------------------------------------------
;;  Define common block
;;----------------------------------------------------------------------------------------
COMMON lbw_crit_mf_com, g, b1, th1, u2x, teti2
;;----------------------------------------------------------------------------------------
;;  Define some trig values
;;----------------------------------------------------------------------------------------
s1             = SIN(th1) & c1 = COS(th1) & t1 = TAN(th1)
;;----------------------------------------------------------------------------------------
;;  Determine if solving Equation (13) or Equation (15)
;;----------------------------------------------------------------------------------------
;;  Check u_2x value to define coefficients for root finding
IF (u2x GT 0) THEN BEGIN
  ;;  Numerically solve Equation (15) with u_2x = u_2x
  coeffs = [-2e0*(u2x^2e0 + 1e0)/u2x^2e0*t1, $
             2e0*(u2x^2e0 + 1e0)/u2x^2e0 - b1/c1^2e0 - t1^2e0, $
             0e0,1e0]
ENDIF ELSE IF (u2x EQ -1) THEN BEGIN
  ;;  Use u_2x = [1/(Tr2 + 1)]^(1/2) from Table for Second critical Mach number
  coeffs = [-2e0*(1e0 + (teti2 + 1e0)/9e0)*t1,                   $
             2e0*(1e0 + (teti2 + 1e0)/9e0) - b1/c1^2e0 - t1^2e0, $
            -2e0*((teti2 + 1e0)/9e0*t1),                         $
             1e0 + 2e0*(teti2 + 1e0)/9e0]
ENDIF ELSE IF (u2x EQ -2) THEN BEGIN
  ;;  Use u_2x = [g/(Tr2 + 1)]^(1/2) from Table for Second(K85)* critical Mach number
  coeffs = [-2e0*(1e0 + (teti2 + 1e0)/(9e0*g))*t1,                   $
             2e0*(1e0 + (teti2 + 1e0)/(9e0*g)) - b1/c1^2e0 - t1^2e0, $
            -2e0*((teti2 + 1e0)/(9e0*g)*t1),                         $
             1e0 + 2e0*(teti2 + 1e0)/(9e0*g)]
ENDIF
;;  Numerically solve Equation (15)
roots          = FZ_ROOTS(coeffs)
real_roots     = WHERE(IMAGINARY(roots) LT (MACHAR()).EPS,real_count)
IF (real_count[0] EQ 0) THEN RETURN,0e0
;;  Define roots for theta
thz            = ATAN(REAL_PART(roots[real_roots]))
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN,thz
END

;+
;*****************************************************************************************
;
;  FUNCTION :   lbw_crit_mf.pro
;  PURPOSE  :   Calculates the MHD and whistler critical Mach numbers.
;
;  CALLED BY:   
;               NA
;
;  INCLUDES:
;               lbw_crit_mf_u1x.pro
;               lbw_crit_mf_u2z.pro
;               lbw_crit_mf_cf.pro
;               lbw_crit_mf_rh4.pro
;               lbw_crit_mf_thz1.pro
;               lbw_crit_mf_thz2.pro
;
;  COMMON BLOCKS:
;               LBW_CRIT_MF_COM
;
;  CALLS:
;               lbw_crit_mf.pro
;               lbw_crit_mf_thz1.pro
;               lbw_crit_mf_thz2.pro
;               lbw_genarr.pro
;               lbw_crit_mf_rh4.pro
;               lbw_zbrent.pro
;               lbw_crit_mf_u2z.pro
;               lbw_crit_mf_u1x.pro
;               lbw_crit_mf_cf.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               GAMMA     :  Scalar [numeric] defining the polytrope index [unitless]
;               BETA1     :  Scalar [numeric] defining the upstream plasma beta [unitless]
;               THETA1    :  Scalar [numeric] defining the upstream shock normal angle [rad]
;
;  EXAMPLES:    
;               [calling sequence]
;               mcr = lbw_crit_mf(gamma, beta1, theta1 [,/SILENT] [,/VERBOSE] [,TYPE=type] $
;                                 [,TRIAL=trial] [,TETI2_IN=teti2_in] [,U2X_IN=u2x_in]     $
;                                 [,N_RAT=n_rat] [,B_RAT=b_rat]
;
;  KEYWORDS:    
;               SILENT    :  If set, routine will not inform user of steps being performed
;               VERBOSE   :  
;               TYPE      :  Scalar [string] defining the type of critical Mach number
;                              for which to solve with allowed inputs:
;                                1   :  first or Mcr1
;                                2   :  second or Mcr2
;                                2G  :  (K85 style) second
;                                F   :  foreshock
;                                FG  :  (K85 style) foreshock
;                                W   :  (low beta) linear whistler [phase]
;                                WN  :  (low beta) nonlinear whistler
;                                WG  :  (low beta) linear whistler [group]
;                                WB  :  (K85 style) whistler
;               TRIAL     :  Scalar [integer] value for program use mostly
;               TETI2_IN  :  Scalar [numeric] value of user-defined T_e2/T_i2
;               U2X_IN    :  Scalar [numeric] value of user-defined normalized upstream Ux
;               N_RAT     :  Set to a named variable to return the shock compression ratio
;               B_RAT     :  Set to a named variable to return the magnetic compression ratio
;
;   CHANGED:  1)  Cleaned up a little and renamed to lbw_crit_mf.pro from crit_mf.pro
;                                                                   [02/18/2019   v1.0.1]
;
;   NOTES:      
;               1)  The critical Mach numbers are defined as:
;    Type          U_2x                u_2x                             Notes
;  ======================================================================================
;  First           C_s2              g^(1/2)              U_2x is downstream sound speed
;  Second          C_i2           [1/(Tr2 + 1)]^(1/2)     U_2x is downstream thermal
;                                                         speed, ion reflection present
;  Second(K85)*    C_i2           [g/(Tr2 + 1)]^(1/2)     " "
;  Foreshock**   3 C_i2 Cos(th2)  3 Cos(th2)*U_2nd0       Significant escape upstream
;                                                         of downstream ions
;  Foreshock(K85)  " "            3 Cos(th2)*U_2nd*       " "
;
;  g      = polytrope index
;  V_j    = [kB T_j / m]^(1/2)
;  beta_j = 8 π n_j * kB * T_j/B_j^2
;  C_sj   = [g kB T_j / M]^(1/2)
;  V_Aj   = B_j/[4π M n_j]^(1/2)
;  Vmsj   = [C_sj^2 + V_Aj^2]^(1/2)
;  V_fj^2 = [ Vmsj^2 + [ Vmsj^4 - 4 C_sj^2 V_Aj^2 Cos(th1)^2 ]^(1/2) ]/2
;  B_jx   = B_j Cos(thj)
;  B_jz   = B_j Sin(thj)
;
;  Tr2    = T_e2/T_i2
;  U_2nd0 = [1/(Tr2 + 1)]^(1/2)
;  U_2nd* = [g/(Tr2 + 1)]^(1/2)
;
;  u_jx   = U_jx/V_j
;  u_jz   = U_jz/V_j
;  v      = V_2/V_1
;
;  REFERENCES:  
;               1)  Edmiston, J.P. and C.F. Kennel "A parametric survey of the first
;                      critical Mach number for a fast MHD shock.," J. Plasma Phys.
;                      Vol. 32, pp. 429-–441, 1984.
;               2)  Kennel, C.F., J.P. Edmiston, and T. Hada "A quarter century of
;                      collisionless shock research," Geophysical Monograph Series
;                      Vol. 34, pp. 1-–36, 1985.
;               3)  Krasnoselskikh, V.V., B. Lembege, P. Savoini, and V.V. Lobzin
;                      "Nonstationarity of strong collisionless quasi-perpendicular
;                      shocks: Theory and full particle numerical simulations,"
;                      Phys. Plasmas Vol. 9, pp. 1192--1209, 2002.
;
;   ADAPTED FROM: crit_mf.pro    BY: Marc Pulupa
;   CREATED:  ??/??/????
;   CREATED BY:  Marc Pulupa
;    LAST MODIFIED:  02/18/2019   v1.0.1
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION lbw_crit_mf,gamma,beta1,theta1,SILENT=silent,VERBOSE=verbose,TYPE=type,$
                     TRIAL=trial,TETI2_IN=teti2_in,U2X_IN=u2x_in,N_RAT=n_rat,   $
                     B_RAT=b_rat

;;----------------------------------------------------------------------------------------
;;  Define some constants and dummy variables
;;----------------------------------------------------------------------------------------
;;  Atomic
me             = 9.1093835600d-31         ;;  Electron mass [kg, 2014 CODATA/NIST]
mp             = 1.6726218980d-27         ;;  Proton mass [kg, 2014 CODATA/NIST]
mp2me          = mp[0]/me[0]
;;  Check TRIAL setting
IF NOT KEYWORD_SET(trial) THEN trial = 0
;;----------------------------------------------------------------------------------------
;;  Define common block
;;----------------------------------------------------------------------------------------
COMMON lbw_crit_mf_com, g, b1, th1, u2x, teti2
;;----------------------------------------------------------------------------------------
;;  Compute trials, if desired
;;----------------------------------------------------------------------------------------
IF (trial EQ 2) THEN BEGIN
  db  = 0.05
  dt  = 0.5/!RADEG
  mf0 = lbw_crit_mf(gamma,beta1+db,theta1,TYPE=type,TRIAL=3,             $
                SILENT=KEYWORD_SET(silent),VERBOSE=KEYWORD_SET(verbose), $
                TETI2_IN=teti2,N_RAT=n_rat0,B_RAT=b_rat0)
  mf1 = lbw_crit_mf(gamma,beta1-db,theta1,TYPE=type,TRIAL=3,             $
                SILENT=keyword_set(silent),VERBOSE=KEYWORD_SET(verbose), $
                TETI2_IN=teti2,N_RAT=n_rat1,B_RAT=b_rat1)
  mf2 = lbw_crit_mf(gamma,beta1,theta1+dt,TYPE=type,TRIAL=3,             $
                SILENT=KEYWORD_SET(silent),VERBOSE=KEYWORD_SET(verbose), $
                TETI2_IN=teti2,N_RAT=n_rat2,B_RAT=b_rat2)
  mf3 = lbw_crit_mf(gamma,beta1,theta1-dt,TYPE=type,TRIAL=3,             $
                SILENT=KEYWORD_SET(silent),VERBOSE=KEYWORD_SET(verbose), $
                TETI2_IN=teti2,N_RAT=n_rat3,B_RAT=b_rat3)
  IF NOT KEYWORD_SET(silent) THEN PRINT,'Using neighbor method'
  IF FINITE(mf0) AND FINITE(mf1) AND FINITE(mf2) AND FINITE(mf3) THEN BEGIN
    mf    = MEAN([mf0, mf1, mf2, mf3])
    b_rat = MEAN([b_rat0, b_rat1, b_rat2, b_rat3])
    n_rat = MEAN([n_rat0, n_rat1, n_rat2, n_rat3])
    RETURN, mf
  ENDIF
ENDIF
;;----------------------------------------------------------------------------------------
;;  Redefine parameters and set values in common block
;;----------------------------------------------------------------------------------------
g              = gamma[0]
b1             = beta1[0]
th1            = theta1[0]
;;----------------------------------------------------------------------------------------
;;  Determine form for u_2x
;;----------------------------------------------------------------------------------------
;;  Check U2X_IN setting
IF NOT KEYWORD_SET(u2x_in) THEN BEGIN
   IF NOT KEYWORD_SET(teti2_in) THEN teti2 = 0e0 ELSE teti2 = teti2_in
   IF NOT KEYWORD_SET(type) THEN type = '1'
   type = STRUPCASE(STRCOMPRESS(STRING(type[0]),/REMOVE_ALL))
   ;;  Determine form of u_2x
   CASE type[0] OF
     '1'  : u2x = SQRT(g)
     '2'  : u2x = SQRT(1e0/(teti2 + 1e0))
     '2G' : u2x = SQRT(g)*SQRT(1e0/(teti2 + 1e0))
     'F'  : u2x = -1
     'FG' : u2x = -2
     ELSE : u2x = !VALUES.F_NAN
   ENDCASE
   ;;  Determine form label for outputs
   CASE type[0] OF
     '1'  : longtype = 'first'
     '2'  : longtype = 'second'
     '2G' : longtype = '(K85 style) second'
     'F'  : longtype = 'foreshock'
     'W'  : longtype = '(low beta) whistler'
     'WN' : longtype = '(low beta) nonlinear whistler'
     'WG' : longtype = '(low beta) group velocity whistler'
     'WB' : longtype = 'whistler'
     ELSE : longtype = ''
   ENDCASE
   IF NOT KEYWORD_SET(silent) THEN BEGIN
      IF (longtype NE '') THEN PRINT,'Solving for '+longtype[0]+' critical fast Mach number...'
   ENDIF
ENDIF ELSE BEGIN
   teti2 = 0.
   u2x   = u2x_in
   IF NOT KEYWORD_SET(silent) THEN PRINT,'Solving for user input u2x = '+STRCOMPRESS(STRING(u2x),/REMOVE_ALL)+'...'
ENDELSE
;;----------------------------------------------------------------------------------------
;;  Calculate critical Mach number
;;----------------------------------------------------------------------------------------
IF FINITE(u2x[0]) THEN BEGIN
  ;;  User is looking for standard critical Mach numbers
  epsilon= (MACHAR()).EPS    ;;  Make sure to use SINGLE precision here!
  IF (g LE 1e0) THEN BEGIN
    ;;  Invalid polytrope index input --> Return NaN
    IF NOT KEYWORD_SET(silent) THEN PRINT,'Gamma must be greater than 1!'
    RETURN, !VALUES.D_NAN
  ENDIF
  IF (b1[0] LE 1e-5) THEN BEGIN
    ;;  Invalid plasma beta input --> limit to minimum
    IF NOT KEYWORD_SET(silent) THEN PRINT,'Plasma beta must be greater than 1e-5!'
    b1 = 1e-5
  ENDIF
  ;;  Check upstream shock normal angle values
  IF (th1[0] GE 0.999*!DPI/2) THEN th1 = 0.999*!DPI/2d0
  IF (th1[0] LE 0.001*!DPI/2) THEN th1 = 0.001*!DPI/2d0
  th1         = DOUBLE(th1[0])
  ;;  Numerically determine values for upstream and downstream shock normal angles
  angles_00   = [th1,lbw_crit_mf_thz1(),lbw_crit_mf_thz2(),!DPI/2]
  angles_01   = angles_00[WHERE(angles_00 GE th1 AND angles_00 LE !DPI/2)]
  angles_02   = angles_01[SORT(angles_01)]
  angles      = angles_02[UNIQ(angles_02)]
  n_intervals = N_ELEMENTS(angles) - 1L
  IF (type[0] EQ 'F' OR type[0] EQ 'FG' AND trial[0] GT 0) THEN BEGIN
    ;;  Iterate to find # of test trials
    tmp_angles = angles
    FOR i=0L, n_intervals[0] - 1L DO BEGIN
      low       = tmp_angles[i] + 10*epsilon[0]
      upp       = tmp_angles[i+1] - 10*epsilon[0]
      n_test    = 500
      th2_test  = lbw_genarr(n_test[0],low[0],upp[0])
      rh4_test  = lbw_crit_mf_rh4(th2_test)
      sign_change                = (rh4_test GE 0) * SHIFT(rh4_test LT 0, 1) + $
                                   (rh4_test GE 0) * SHIFT(rh4_test LT 0,-1)
      sign_change[0]             = 0
      sign_change[n_test[0] - 1] = 0
      sc_ind = WHERE(sign_change EQ 1)
      IF (sc_ind[0] GE 0) THEN BEGIN
        angles = [angles,th2_test[sc_ind - 1],th2_test[sc_ind]]
      ENDIF
    ENDFOR
    angles      = angles[SORT(angles)]
    angles      = angles[UNIQ(angles)]
    n_intervals = N_ELEMENTS(angles) - 1L
  ENDIF
  th2_trials = REPLICATE(!VALUES.D_NAN,n_intervals[0])
  FOR i=0L, n_intervals[0] - 1L DO BEGIN
    ;;------------------------------------------------------------------------------------
    ;;  Numerically solve Equation (4) in MPPulupa_Critical_Mach_Notes.pdf
    ;;------------------------------------------------------------------------------------
    low       = angles[i] + 10*epsilon[0]
    upp       = angles[i+1] - 10*epsilon[0]
    !QUIET    = 1     ;; --> ignore messages
    th2_trial = lbw_zbrent(low[0],upp[0],FUNC_NAME='lbw_crit_mf_rh4', $
                           MAX_ITERATIONS=1e9,TOLERANCE=1e-10)
    !QUIET = 0
    IF (th2_trial NE low[0]) THEN th2_trials[i] = th2_trial
  ENDFOR
  finite_th2 = WHERE(FINITE(th2_trials),th2_fincount)
  IF (th2_fincount[0] GE 1) THEN th2s = th2_trials[finite_th2] ELSE th2s = 0e0
  IF NOT KEYWORD_SET(silent) THEN BEGIN
    ;;  Plot to test results
    th2_test = lbw_genarr(1000,th1[0],!DPI/2d0)
    PLOT, th2_test*!RADEG,lbw_crit_mf_rh4(th2_test),YRANGE=[-4,4]
    OPLOT,[angles*!RADEG],[FLTARR(N_ELEMENTS(angles))],PSYM=2
    OPLOT,[th2s*!RADEG],[FLTARR(N_ELEMENTS(th2s))],PSYM=4
  ENDIF
  IF ((type[0] EQ 'F' OR type[0] EQ 'FG') AND trial[0] EQ 0 AND beta1[0] GT 0.7) THEN BEGIN
    ;;------------------------------------------------------------------------------------
    ;;  Now that result is refined, re-call and try again
    ;;------------------------------------------------------------------------------------
    mf = lbw_crit_mf(gamma,beta1,theta1,TYPE=type,TRIAL=1,                    $
                     SILENT=KEYWORD_SET(silent),VERBOSE=KEYWORD_SET(verbose), $
                     TETI2_IN=teti2,N_RAT=n_rat,B_RAT=b_rat)
    ;;  Return to user
    RETURN, mf
  ENDIF
  IF (th2_fincount[0] EQ 0 AND (type[0] EQ 'F' OR type[0] EQ 'FG') AND trial[0] EQ 1) THEN BEGIN
    ;;------------------------------------------------------------------------------------
    ;;  Try small osciallations about the current value to get a better result
    ;;------------------------------------------------------------------------------------
    mf = lbw_crit_mf(gamma,beta1,theta1,TYPE=type,TRIAL=2,                    $
                     SILENT=KEYWORD_SET(silent),VERBOSE=KEYWORD_SET(verbose), $
                     TETI2_IN=teti2,N_RAT=n_rat,B_RAT=b_rat)
    ;;  Return to user
    RETURN,mf
  ENDIF
  IF (th2_fincount[0] EQ 0) THEN BEGIN
    ;;  Invalid solution --> Return NaN
    IF NOT KEYWORD_SET(silent) THEN PRINT,'Cannot find solution!'
    n_rat = !VALUES.F_NAN
    b_rat = !VALUES.F_NAN
    RETURN, !VALUES.F_NAN
  ENDIF
  IF (type[0] EQ 'F' ) THEN u2x = 3e0*COS(th2s)*SQRT(1e0/(teti2 + 1e0))
  IF (type[0] EQ 'FG') THEN u2x = 3e0*COS(th2s)*SQRT(g/(teti2 + 1e0))
  ;;--------------------------------------------------------------------------------------
  ;;  Calculate critical Mach number parameters
  ;;--------------------------------------------------------------------------------------
  ;;  Calculate u_2z
  u2zs = lbw_crit_mf_u2z(g, b1, th1, th2s, u2x)
  ;;  Calculate u_1x
  u1xs = lbw_crit_mf_u1x(g, b1, th1, th2s, u2x, u2zs)
  ;;  Calculate normalized critical Mach number
  cf   = lbw_crit_mf_cf(g, b1, th1)
  ;;  Define critical Mach number
  mfs  = u1xs/cf
  IF (type[0] NE 'F' and type[0] NE 'FG') THEN BEGIN
    ;;  Determine form depending on beta
    IF (b1 LT 0.1) THEN BEGIN
       th2 = MAX(th2s,sol_ind,/NAN)
       mf  = mfs[sol_ind]
    ENDIF ELSE BEGIN
       mf  = MAX(mfs,sol_ind,/NAN)
       th2 = th2s[sol_ind]
    ENDELSE
  ENDIF ELSE BEGIN
    th2 = MAX(th2s,sol_ind,/NAN)
    mf  = mfs[sol_ind]
  ENDELSE
  u2z   = u2zs[sol_ind]
  u1x   = u1xs[sol_ind]
  ;;  Numerically estimate n_2/n_1 and B_2/B_1
  ;;    (last equations on page 1 of MPPulupa_Critical_Mach_Notes.pdf)
  n_rat = (TAN(th2) - u2z/SQRT(g))/TAN(th1)
  b_rat = COS(th1)/COS(th2)
  IF NOT FINITE(u1x) THEN BEGIN
    ;;  Invalid solution --> Return NaN
    IF NOT KEYWORD_SET(silent) THEN PRINT,'Cannot find solution!'
    n_rat = !VALUES.F_NAN
    b_rat = !VALUES.F_NAN
    RETURN, !VALUES.F_NAN
  ENDIF
  IF (mf[0] LT 1.001) THEN BEGIN
    ;;  Ignore values slightly above 1.0 and redefine as 1.0
    mf    = 1.
    n_rat = 1.
    b_rat = 1.
  ENDIF
  IF (n_rat LT 1e0 AND n_rat GT 0.5) THEN n_rat = 1e0
  IF (b_rat LT 1e0 AND b_rat GT 0.5) THEN b_rat = 1e0
  IF NOT KEYWORD_SET(silent) THEN BEGIN
    IF KEYWORD_SET(verbose) THEN BEGIN
       outf = '(3(A10,F8.3))'
       PRINT, ''
       PRINT, 'Input Parameters:'
       PRINT, 'gamma:', g[0],'beta:',b1[0],'theta1:',th1[0]*!RADEG,FORMAT=outf
       IF (type[0] NE '1') THEN PRINT,'te2/ti2:',teti2[0],FORMAT=outf
       PRINT,''
       PRINT,'Results:'
       PRINT,'theta2:',th2[0]*!RADEG,'u2z:',u2z[0],FORMAT=outf
       PRINT,'n2/n1:',n_rat[0],'b2/b1:',b_rat[0],FORMAT=outf
       PRINT,'u1x:',u1x[0],'cf:',cf[0],'Mf*:',mf[0],FORMAT=outf
    ENDIF ELSE BEGIN
       PRINT,'Mf* = '+STRCOMPRESS(STRING(mf[0]),/REMOVE_ALL)
    ENDELSE
  ENDIF
  ;;--------------------------------------------------------------------------------------
  ;;  Return to user
  ;;--------------------------------------------------------------------------------------
  RETURN,mf[0]
ENDIF ELSE BEGIN
  ;;  User is looking for whistler critical Mach number
  mu    = 1/SQRT(mp2me[0])                 ;;  Square root of mass ratio
  csca2 = gamma[0]*beta1[0]/2e0
  cfca2 = (1e0 + csca2[0])/2e0 + (((1e0 + csca2[0])/2e0)^2e0 - csca2[0]*COS(theta1[0])^2e0)^(1e0/2e0)
  CASE type[0] OF
    'W'  : mf = 1e0/(2e0*mu[0])*ABS(COS(theta1[0]))
    'WN' : mf = 1e0/(mu[0])*SQRT(27e0/64e0)*ABS(COS(theta1[0]))
    'WG' : mf = 1e0/SQRT(2e0*mu[0])*ABS(COS(theta1[0]))
    'WB' : mf = 1e0/(2e0*mu[0])*ABS(COS(theta1[0]))/SQRT(cfca2[0])
    ELSE : mf = -1
  ENDCASE
  ;;  Define output keywords N_RAT and B_RAT
  n_rat = !VALUES.D_NAN
  b_rat = !VALUES.D_NAN
  IF (mf[0] LT 0) THEN BEGIN
    ;;  Invalid input --> Output NaN
    IF NOT KEYWORD_SET(silent) THEN BEGIN
      PRINT,'Mach number type unrecognized.'
      PRINT,'Available types: "1", "2", "2G", "W", "WG", "WN", "WB", "F", "FG"'
    ENDIF
    ;;  Return to user
    RETURN, !VALUES.D_NAN
  ENDIF ELSE BEGIN
    IF NOT KEYWORD_SET(silent) THEN PRINT,'Mf* = '+STRCOMPRESS(STRING(mf[0]),/REMOVE_ALL)
    ;;  Return to user
    RETURN, mf
  ENDELSE
ENDELSE
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

END
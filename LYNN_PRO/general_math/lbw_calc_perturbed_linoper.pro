;+
;*****************************************************************************************
;
;  FUNCTION :   lbw_calc_perturbed_linoper.pro
;  PURPOSE  :   This routine perturbs two input arrays, using the user-defined
;                 uncertainties, then performs a linear operation (i.e., multiplication,
;                 division, addition, or subtraction) on the perturbed inputs, then
;                 returns the perturbed resulting array.
;
;  CALLED BY:   
;               NA
;
;  INCLUDES:
;               NA
;
;  CALLS:
;               lbw_perturb_input.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               IN1   :  [I,J,K,...N]-Element [numeric] array of input-1 values to be
;                          perturbed and then operated on
;               IN2   :  [I,J,K,...N]-Element [numeric] array of input-2 values to be
;                          perturbed and then operated on
;               DI1   :  [I,J,K,...N]-Element [numeric] array of uncertainty-1 values to
;                          use to perturb IN1
;               DI2   :  [I,J,K,...N]-Element [numeric] array of uncertainty-2 values to
;                          use to perturb IN2
;
;  EXAMPLES:    
;               [calling sequence]
;               i12_p = lbw_calc_perturbed_linoper(in1,in2,di1,di2 [,/MUL] [,/DIV] [,/ADD] $
;                                                  [,/SUB] [,NSIG=nsig] [,/NAN] [,/PERM])
;
;               ;;  *****************************
;               ;;  Examples
;               ;;  *****************************
;               ;;  Do not permute output
;               xx             = dindgen(5) + 1d0
;               dx             = 1d-1*xx
;               yy             = xx*2d0
;               dy             = 5d-2*yy
;               xy_p           = lbw_calc_perturbed_linoper(xx,yy,dx,dy,/ADD,NSIG=1)
;               PRINT, xx + yy
;                      3.0000000       6.0000000       9.0000000       12.000000       15.000000
;               PRINT, TRANSPOSE(xy_p)
;                      2.8000000       5.6000000       8.4000000       11.200000       14.000000
;                      3.0000000       6.0000000       9.0000000       12.000000       15.000000
;                      3.2000000       6.4000000       9.6000000       12.800000       16.000000
;               
;               ;;  Permute output
;               xx             = dindgen(5) + 1d0
;               dx             = 1d-1*xx
;               yy             = xx*2d0
;               dy             = 5d-2*yy
;               xy_p           = lbw_calc_perturbed_linoper(xx,yy,dx,dy,/ADD,NSIG=1,/PERM)
;               HELP,xy_p
;               XY_P            DOUBLE    = Array[3, 3, 5]
;               PRINT, TRANSPOSE(xy_p,[2,0,1])
;                      2.8000000       5.6000000       8.4000000       11.200000       14.000000
;                      2.9000000       5.8000000       8.7000000       11.600000       14.500000
;                      3.0000000       6.0000000       9.0000000       12.000000       15.000000
;
;                      2.9000000       5.8000000       8.7000000       11.600000       14.500000
;                      3.0000000       6.0000000       9.0000000       12.000000       15.000000
;                      3.1000000       6.2000000       9.3000000       12.400000       15.500000
;
;                      3.0000000       6.0000000       9.0000000       12.000000       15.000000
;                      3.1000000       6.2000000       9.3000000       12.400000       15.500000
;                      3.2000000       6.4000000       9.6000000       12.800000       16.000000
;
;  KEYWORDS:    
;               MUL   :  If set, then routine will multiply the perturbed intpus
;                          [Default = FALSE]
;               DIV   :  If set, then routine will divide (IN1/IN2) the perturbed intpus
;                          [Default = FALSE]
;               ADD   :  If set, then routine will add the perturbed intpus
;                          [Default = FALSE]
;               SUB   :  If set, then routine will subtract (IN1-IN2) the perturbed intpus
;                          [Default = TRUE]
;               NSIG  :  Scalar [integer/long] defining the number of sigma by which to
;                          perturb input.  The output result will have two extra dimensions
;                          prepended to the input array each with (2*NSIG + 1) elements.
;                          Values between 1 and 6 are allow.
;                          [Default = 1]
;               NAN   :  If set, operations apply the standard rules about NaNs
;                          [Default = FALSE]
;               PERM  :  If set, routine will permute the perturbed results otherwise
;                          not.  If TRUE, then the output will have two extra dimensions
;                          otherwise only one.
;                          [Default = FALSE]
;
;   CHANGED:  1)  NA
;                                                                   [MM/DD/YYYY   v1.0.0]
;
;   NOTES:      
;               0)  Try not to kill your computer by providing arrays that ar too large
;                     --> Try to satisfy:  N_ELEMENTS(IN1) ≤ 100,000,000
;               1)  XXX operator priority order (in case multiple are set)
;                     1  :  SUB
;                     2  :  ADD
;                     3  :  MUL
;                     4  :  DIV
;
;  REFERENCES:  
;               NA
;
;   CREATED:  02/17/2022
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  02/17/2022   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION lbw_calc_perturbed_linoper,in1,in2,di1,di2,MUL=mul,DIV=div,ADD=add,$
                                    SUB=sub,NSIG=nsig,NAN=nan,PERM=per

;;----------------------------------------------------------------------------------------
;;  Constants
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
;;  Define defaults
def_sub_on     = 1b
def_add_on     = 0b
def_mul_on     = 0b
def_div_on     = 0b
def_nan_on     = 0b
def_per_on     = 0b
;;  Dummy error messages
no_inpt__mssg  = 'User must supply IN? and DI? as [I,J,K,...N]-element [numeric] arrays...'
;;----------------------------------------------------------------------------------------
;;  Check input
;;----------------------------------------------------------------------------------------
test           = (N_PARAMS() LT 4) OR (N_ELEMENTS(in1) EQ 0) OR (N_ELEMENTS(in2) EQ 0) OR $
                 (N_ELEMENTS(di1) EQ 0) OR (N_ELEMENTS(di2) EQ 0)
IF (test[0]) THEN BEGIN
  MESSAGE,no_inpt__mssg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
IF (SIZE(in1,/N_DIMENSIONS) EQ 0) THEN in1 = [in1]
IF (SIZE(in2,/N_DIMENSIONS) EQ 0) THEN in2 = [in2]
IF (SIZE(di1,/N_DIMENSIONS) EQ 0) THEN di1 = [di1]
IF (SIZE(di2,/N_DIMENSIONS) EQ 0) THEN di2 = [di2]
szdi1          = SIZE(in1,/DIMENSIONS)
szni1          = SIZE(in1,/N_DIMENSIONS)
szdi2          = SIZE(in2,/DIMENSIONS)
szni2          = SIZE(in2,/N_DIMENSIONS)
;;----------------------------------------------------------------------------------------
;;  Perturb input and verify results
;;----------------------------------------------------------------------------------------
in1_p          = lbw_perturb_input(in1,di1,NSIG=nsig)
in2_p          = lbw_perturb_input(in2,di2,NSIG=nsig)
;;  Check output of perturbing routine
szdp1          = SIZE(in1_p,/DIMENSIONS)
szdp2          = SIZE(in2_p,/DIMENSIONS)
sznp1          = SIZE(in1_p,/N_DIMENSIONS)
sznp2          = SIZE(in2_p,/N_DIMENSIONS)
test           = (sznp1[0] NE (szni1[0] + 1L)) OR (sznp2[0] NE (szni2[0] + 1L)) OR $
                 (TOTAL(szdp1) NE TOTAL(szdp2)) OR (TOTAL(szdp1[1L:*]) NE TOTAL(szdi1))
IF (test[0]) THEN BEGIN
  MESSAGE,"Perturbed output has incorrect dimensions --> exiting without operation",/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
;;----------------------------------------------------------------------------------------
;;  Check keywords
;;----------------------------------------------------------------------------------------
;;  Check SUB
IF ~KEYWORD_SET(sub) THEN sub_on = 0b ELSE sub_on = def_sub_on[0]
;;  Check ADD
IF  KEYWORD_SET(add) THEN add_on = 1b ELSE add_on = def_add_on[0]
;;  Check MUL
IF  KEYWORD_SET(mul) THEN mul_on = 1b ELSE mul_on = def_mul_on[0]
;;  Check DIV
IF  KEYWORD_SET(div) THEN div_on = 1b ELSE div_on = def_div_on[0]
;;  Check NAN
IF  KEYWORD_SET(nan) THEN nan_on = 1b ELSE nan_on = def_nan_on[0]
;;  Check PERM
IF  KEYWORD_SET(per) THEN per_on = 1b ELSE per_on = def_per_on[0]
;;  Make sure only one of the XXX operators is on
check_on       = [sub_on[0],add_on[0],mul_on[0],div_on[0]]
goodx_on       = WHERE(check_on,gdx_on,COMPLEMENT=badx_on,NCOMPLEMENT=bdx_on)
check_on[*]    = 0b
CASE gdx_on[0] OF
  1     :  BEGIN
    check_on[goodx_on[0]] = 1b
  END
  2     :  BEGIN
    ;;  2 are set --> check priority
    check_on[goodx_on[0]] = 1b
  END
  3     :  BEGIN
    ;;  2 are set --> check priority
    check_on[goodx_on[0]] = 1b
  END
  ELSE  :  BEGIN
    ;;  Either none are on or all are on --> Use default [SUB]
    check_on              = [def_sub_on[0],def_add_on[0],def_mul_on[0],def_div_on[0]]
  END
ENDCASE
;;  Redefine logic variables
sub_on         = check_on[0]
add_on         = check_on[1]
mul_on         = check_on[2]
div_on         = check_on[3]
plsb_on        = (sub_on[0] OR add_on[0])
;;----------------------------------------------------------------------------------------
;;  Calculate perturbed operation
;;----------------------------------------------------------------------------------------
CASE 1 OF
  sub_on[0]  :  BEGIN
    in2_p         *= -1d0
  END
  div_on[0]  :  BEGIN
    in2_p          = 1d0/TEMPORARY(in2_p)
  END
  ELSE       :  ;;  Do nothing
ENDCASE
;;  Reform arrays
ns             = N_ELEMENTS(in1_p[*,0])                   ;;  P
nt             = N_ELEMENTS(in1)                          ;;  N
rin1p          = REFORM(in1_p,ns[0],nt[0])                ;;  [P,N]-Element array
rin2p          = REFORM(in2_p,ns[0],nt[0])
;;  Calculate
IF (per_on[0]) THEN BEGIN
  ;;  Permute output
  output         = REPLICATE(d,ns[0],ns[0],nt[0])
  ones           = REPLICATE(1d0,ns[0])
  FOR i=0L, ns[0] - 1L DO BEGIN
    arr_1          = ones # REFORM(rin1p[i,*])
    rin_2          = [[[arr_1]],[[rin2p]]]                    ;;  [P,N,2]-Element array
    IF (plsb_on[0]) THEN output[i,*,*] = TOTAL(rin_2,3L,NAN=nan_on[0]) ELSE output[i,*,*] = PRODUCT(rin_2,3L,NAN=nan_on[0])
  ENDFOR
ENDIF ELSE BEGIN
  ;;  Do not permute output
  rin_2          = [[[rin1p]],[[rin2p]]]                    ;;  [P,N,2]-Element array
  IF (plsb_on[0]) THEN output = TOTAL(rin_2,3L,NAN=nan_on[0]) ELSE output = PRODUCT(rin_2,3L,NAN=nan_on[0])
ENDELSE
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN,output
END




































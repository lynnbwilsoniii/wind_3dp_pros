;+
;*****************************************************************************************
;
;  PROCEDURE:   beam_fit_fit_prompts.pro
;  PURPOSE  :   This routine prompts the user with options regarding the beam fitting
;                 constraints, limits, etc.
;
;  CALLED BY:   
;               beam_fit_fit_wrapper.pro
;
;  CALLS:
;               delete_variable.pro
;               beam_fit_gen_prompt.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               PARAM      :  [6]-Element array [float/double] containing the following
;                               quantities:
;                                 PARAM[0] = Number Density [cm^(-3)]
;                                 PARAM[1] = Parallel Thermal Speed [km/s]
;                                 PARAM[2] = Perpendicular Thermal Speed [km/s]
;                                 PARAM[3] = Parallel Drift Speed [km/s]
;                                 PARAM[4] = Perpendicular Drift Speed [km/s]
;                                 PARAM[5] = *** Not Used Here ***
;               READ_IN    :  Scalar [string] defining the option selected by user
;                                  to define new action to take
;
;  EXAMPLES:    
;               NA
;
;  KEYWORDS:    
;               ***  INPUT   ***
;               PARINFO    :  [6]-Element array [structure] where the i-th contains
;                               the following tags and definitions:
;                                 VALUE    =  Scalar value defined by PARAM[i]
;                                 FIXED    =  TRUE   -->  parameter constrained
;                                             FALSE  -->  parameter unconstrained
;                                 LIMITED  =  [2]-Element defining the lower/upper
;                                             bound on PARAM[i]
;                                 LIMITS   =  [2]-Element defining the if the lower/upper
;                                             bound defined by LIMITED is imposed(TRUE)
;                                             otherwise LIMITS has no effect
;                                 TIED     =  Scalar [string] that should not be changed
;                                             by user
;               INDEX_OUT  :  Scalar [long] defining which element of PARAM the user
;                               wishes to change, constrain, limit, etc.
;
;  KEYWORDS:    
;               ***  OUTPUT  ***
;               !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
;               ***  [all the following changed on output]  ***
;               !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
;               READ_OUT   :  Set to a named variable to return a string containing the
;                               last command line input.  This is used by the overhead
;                               routine to determine whether user left the program by
;                               quitting or if the program finished
;               VALUE_OUT  :  Set to a named variable to return the NEW value for the
;                               changed variable associated with the changed parameter
;               OLD_VALUE  :  Set to a named variable to return the OLD value for the
;                               changed variable
;               CONSTRAIN  :  [6]-Element [byte] array defining which elements of PARAM
;                               user will not allow to vary
;                               [i.e. where TRUE => constrain]
;               LIMITED    :  [2]-Element [byte] array defining whether the fitting
;                               routine will limit the upper/lower bound
;               LIMITS     :  [2]-Element [float/double] array defining the upper/lower
;                               bound to place on a parameter
;               CHANGE     :  [6]-Element [byte] array defining which elements of PARAM
;                               the user has changed
;
;   CHANGED:  1)  Continued to write routine                       [09/03/2012   v1.0.0]
;             2)  Added error handling to change the values in VALUE if the user defines
;                   new LIMITS values that do not encompass the current value in VALUE
;                                                                  [09/04/2012   v1.1.0]
;             3)  Added keyword:  INDEX_OUT
;                                                                  [09/07/2012   v1.2.0]
;             4)  Now resets READ_PAUSE input
;                                                                  [09/11/2012   v1.2.1]
;             5)  Now prints out current values/settings more frequently
;                                                                  [09/17/2012   v1.3.0]
;             6)  Routine no longer prints out index list after user types 'q' to quit
;                                                                  [09/21/2012   v1.4.0]
;             7)  Now prints out values after each input
;                                                                  [10/09/2012   v1.4.1]
;
;   NOTES:      
;               1)  User should not call this routine
;               2)  See also:  mpfit.pro, mpfit2dfun.pro, and mpfitfun.pro
;               3)  The output keywords CONSTRAIN through CHANGE refer to structure tags
;                     in the PARINFO keyword input in mpfit2dfun.pro
;
;   CREATED:  09/01/2012
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  10/09/2012   v1.4.1
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

PRO beam_fit_fit_prompts,param,read_in,PARINFO=parinfo,                             $
                         READ_OUT=read_out,VALUE_OUT=value_out,OLD_VALUE=old_value, $
                         CONSTRAIN=constrain,LIMITED=limited,LIMITS=limits,         $
                         CHANGE=change,INDEX_OUT=index_out

;;----------------------------------------------------------------------------------------
;; => Define some constants and dummy variables
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
;; => Initialize outputs
read_out       = ''
constrain      = REPLICATE(0b,6)
limited        = [0b,0b]
limits         = [0d0,0d0]
change         = REPLICATE(0b,6)
unit_str       = [' [cm^(-3)]',' [km/s]',' [km/s]',' [km/s]',' [km/s]',' [N/A]']
parm_str       = ['No','V_TB_X','V_TB_Y','V_BX','V_BY','N/A']
name_str       = [' (# density)',' (para. thermal speed)',' (perp. thermal speed)', $
                  ' (para. drift speed)',' (perp. drift speed)','(N/A)']
effect_str     = ", changes "+["peak of DF):  ","FWHM of yellow cut):  ",        $
                               "FWHM of blue   cut):  ",                         $
                               "the location of yellow peak):  ",                $
                               "the location of blue   peak):  ","nothing):  "   ]

enter_def_str  = "Enter the index associated with the parameter defined above to "
enter_suff     = ["change the value:  ","impose a constraint:  ",$
                  "remove a constraint:  ","impose limits:  ","remove limits:  "]
enter_par_str  = enter_def_str[0]+enter_suff

pind           = STRTRIM(STRING(LINDGEN(6),FORMAT='(I1.1)'),2L)
param_str      = "PARAM["+pind+"]"
param_is__lim  = param_str+" is currently limited..."
param_not_lim  = param_str+" is not currently limited..."
param_is__con  = param_str+" is currently constrained..."
param_not_con  = param_str+" is not currently constrained..."
;;----------------------------------------------------------------------------------------
;; => Define string outputs
;;----------------------------------------------------------------------------------------
def_suff       = " (y/n)?  "
;;--------------------------------------------------
;; => Want to change? strings
;;--------------------------------------------------
def_pref       = "Do you wish to manually change "
yesno_chstr    = def_pref[0]+parm_str+name_str+def_suff[0]
;; => Enter change: strings
def_pref       = "Enter a value for "
def_midf       = " (format = XXXX.xxx"
enter_chstr    = def_pref[0]+parm_str+unit_str+def_midf[0]+effect_str
;;--------------------------------------------------
;; => Want to impose limits? strings
;;--------------------------------------------------
def_pref_l     = "Do you wish to impose limits on lower bound for "
def_pref_u     = "Do you wish to impose limits on upper bound for "
yn_low_ilstr   = def_pref_l[0]+parm_str+name_str+def_suff[0]
yn_upp_ilstr   = def_pref_u[0]+parm_str+name_str+def_suff[0]
;; => Enter impose limits: strings
def_pref_l     = "Enter a lower bound for "
def_pref_u     = "Enter a upper bound for "
def_midf       = " (format = XXXX.xxx"
enter_ilstr_l  = def_pref_l[0]+parm_str+unit_str+def_midf[0]+"):  "
enter_ilstr_u  = def_pref_u[0]+parm_str+unit_str+def_midf[0]+"):  "
;; => Want to remove limits? strings
def_pref       = "Do you wish to remove limits on "
yesno_rlstr    = def_pref[0]+parm_str+name_str+def_suff[0]
;; => Want to remove upper/lower limits? strings
def_pref_l     = "Do you wish to remove limits on lower bound for "
def_pref_u     = "Do you wish to remove limits on upper bound for "
yn_low_rlstr   = def_pref_l[0]+parm_str+name_str+def_suff[0]
yn_upp_rlstr   = def_pref_u[0]+parm_str+name_str+def_suff[0]
;;--------------------------------------------------
;; => Want to impose constraints? strings
;;--------------------------------------------------
def_pref       = "Do you wish to impose constraints on "
yesno_icstr    = def_pref[0]+parm_str+name_str+def_suff[0]
;; => Want to remove constraints? strings
def_pref       = "Do you wish to remove constraints on "
yesno_rcstr    = def_pref[0]+parm_str+name_str+def_suff[0]
;;----------------------------------------------------------------------------------------
;; => Check input
;;----------------------------------------------------------------------------------------
test           = (N_ELEMENTS(param) NE 6) OR (N_PARAMS() LT 1)
IF (test) THEN RETURN     ;; nothing supplied, so leave
;; => Case Logic:  determines action
test           = (N_ELEMENTS(read_in) EQ 1) AND (SIZE(read_in,/TYPE) EQ 7L)
IF (test) THEN BEGIN
  read_pause = read_in[0]
  jump_skips = 1          ;;  User knows what they want to do
ENDIF ELSE BEGIN
  read_pause = ''
  jump_skips = 0
ENDELSE
read_in        = read_pause[0]
;; => Define original input structures
old_value      = parinfo
;;----------------------------------------------------------------------------------------
;; => Define 'current value' strings
;;----------------------------------------------------------------------------------------
;param_sval     = STRTRIM(STRING(param,FORMAT='(f25.3)'),2L)
param_sval     = STRTRIM(STRING(parinfo[*].VALUE[0],FORMAT='(f25.3)'),2L)
pro_out_val    = "The current setting for PARINFO.VALUE = "+param_sval+unit_str
limit_0_str    = STRTRIM(STRING(parinfo[*].LIMITS[0],FORMAT='(f25.3)'),2L)
limit_1_str    = STRTRIM(STRING(parinfo[*].LIMITS[1],FORMAT='(f25.3)'),2L)
pro_out_lim    = "The current limit range is = "+limit_0_str+"-"+limit_1_str+unit_str
;;----------------------------------------------------------------------------------------
;; => Start
;;----------------------------------------------------------------------------------------
IF (jump_skips) THEN GOTO,JUMP_SKIP_START
;;========================================================================================
JUMP_PAUSE:
;;========================================================================================
;;----------------------------------------------------------------------------------------
;; => Print out current values
;;----------------------------------------------------------------------------------------
n_parm         = parinfo[*].VALUE
param_str      = STRCOMPRESS(STRING([n_parm,ABS(n_parm[2]/n_parm[1])^2],FORMAT='(f25.4)'),/REMOVE_ALL)
pro_out        = ['The current fit results are:','',                      $
                  'Beam Density [cm^(-3)]              = '+param_str[0],  $
                  'Beam Para. Thermal Speed [km/s]     = '+param_str[1],  $
                  'Beam Perp. Thermal Speed [km/s]     = '+param_str[2],  $
                  'Beam Para. Drift Speed [km/s]       = '+param_str[3],  $
                  'Beam Perp. Drift Speed [km/s]       = '+param_str[4],  $
                  'Beam Temp. Anisotropy [Tperp/Tpara] = '+param_str[6]   ]
info_out       = beam_fit_gen_prompt(PRO_OUT=pro_out,FORM_OUT=7)
;; => Prompt for input
PRINT,""
READ,read_pause,PROMPT="Enter command (type '?' for help or 'q' to leave) :"
PRINT,""
;;========================================================================================
JUMP_SKIP_START:
;;========================================================================================
test_r = ((read_pause NE ''        ) AND (read_pause NE '?'       ) AND $
          (read_pause NE 'change'  ) AND (read_pause NE 'debug'   ) AND $
          (read_pause NE 'const'   ) AND (read_pause NE 'uncon'   ) AND $
          (read_pause NE 'limit'   ) AND (read_pause NE 'q'       ) AND $
          (read_pause NE 'unlim'   )    )

IF (test_r) THEN GOTO,JUMP_PAUSE  ;; => Invalid input... try again

IF (read_pause EQ '') THEN BEGIN
  ;; => Try again with the same index
  GOTO,JUMP_PAUSE  ;; => Invalid input... try again
ENDIF

IF (read_pause EQ '?') THEN BEGIN
  ;; => List all optional values of READ_PAUSE
  read_pause = ''
  PRINT,""
  PRINT,"+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
  PRINT,"-------------- BEAM_FIT_FIT_PROMPTS COMMANDS ----------------"
  PRINT,""
  PRINT,"q          quit [Enter at any time to leave program]"
  PRINT,"change     change one of the values in PARAM"
  PRINT,"const      constrain/force one of the values in PARAM"
  PRINT,"uncon      remove constraint on one of the values in PARAM"
  PRINT,"limit      impose limits on one of the values in PARAM"
  PRINT,"unlim      remove limits on one of the values in PARAM"
  PRINT,""
  PRINT,"-------------------------------------------------------------"
  PRINT,"+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
  PRINT,""
  GOTO,JUMP_PAUSE
ENDIF

;;----------------------------------------------------------------------------------------
;; => Define prompt string for parameter element user wishes to alter
;;----------------------------------------------------------------------------------------
CASE STRLOWCASE(read_pause[0]) OF
  'change'   : BEGIN
    ;;------------------------------------------------------------------------------------
    ;; => Change VALUE
    ;;------------------------------------------------------------------------------------
    index_str      = enter_par_str[0]           ;; prompts for parameter index
  END
  'const'    : BEGIN
    ;;------------------------------------------------------------------------------------
    ;; => Change FIXED
    ;;------------------------------------------------------------------------------------
    index_str      = enter_par_str[1]
  END
  'uncon'    : BEGIN
    ;;------------------------------------------------------------------------------------
    ;; => Change FIXED
    ;;------------------------------------------------------------------------------------
    index_str      = enter_par_str[2]
  END
  'limit'    : BEGIN
    ;;------------------------------------------------------------------------------------
    ;; => Change LIMITED and LIMITS
    ;;------------------------------------------------------------------------------------
    index_str      = enter_par_str[3]
  END
  'unlim'    : BEGIN
    ;;------------------------------------------------------------------------------------
    ;; => Change LIMITED and LIMITS
    ;;------------------------------------------------------------------------------------
    index_str      = enter_par_str[4]
  END
  'q'        : BEGIN
    ;;------------------------------------------------------------------------------------
    ;; => Quit so reset defaults
    ;;------------------------------------------------------------------------------------
    ;; => Define output
    read_out   = 'q'
    ;; => Nothing else changes, so return
    RETURN
  END
  'debug'    : BEGIN
    ;;------------------------------------------------------------------------------------
    ;; => Debugging option
    ;;------------------------------------------------------------------------------------
    PRINT,''
    errmssg = 'Debugging error handling => STOP'
    MESSAGE,errmssg,/INFORMATIONAL,/CONTINUE
    STOP
  END
ENDCASE

;; => Print out indices
PRINT,""
PRINT,""
PRINT,"    Enter a value between 0-4 corresponding to the following"
PRINT,"definitions of the indices for PARAM:"
PRINT,""
PRINT,"    0  =  Number Density [cm^(-3)]"
PRINT,"    1  =  Parallel Thermal Speed [km/s]"
PRINT,"    2  =  Perpendicular Thermal Speed [km/s]"
PRINT,"    3  =  Parallel Drift Speed [km/s]"
PRINT,"    4  =  Perpendicular Drift Speed [km/s]"
PRINT,"    5  =  *** Not Used Here ***"
PRINT,""

test           = (N_ELEMENTS(index_str) EQ 0)
IF (test) THEN BEGIN
  ;; somehow input string was not defined => try again
  delete_variable,index_str,test
  ;; Jump back
  GOTO,JUMP_PAUSE
ENDIF

test           = (index_str EQ '')
IF (test) THEN BEGIN
  ;; somehow input string was not defined => try again
  delete_variable,index_str,test
  ;; Jump back
  GOTO,JUMP_PAUSE
ENDIF
;;----------------------------------------------------------------------------------------
;; => Determine parameter element user wishes to alter
;;----------------------------------------------------------------------------------------
test           = (N_ELEMENTS(index_out) EQ 0)
IF (test) THEN BEGIN
  ;; Prompt user for index
  index_out      = -1
  true           = 1
ENDIF ELSE BEGIN
  ;; Check user supplied index
  index_out      = index_out[0]
  true           = (index_out[0] LT 0L) OR (index_out[0] GT 4L)
ENDELSE
;; => Determine the index of the parameter to change
WHILE (true) DO BEGIN
  index_out      = ABS(beam_fit_gen_prompt(STR_OUT=index_str,FORM_OUT=3))
  true           = (index_out[0] LT 0L) OR (index_out[0] GT 4L)
ENDWHILE
;;----------------------------------------------------------------------------------------
;; => Test user option
;;----------------------------------------------------------------------------------------
CASE STRLOWCASE(read_pause[0]) OF
  'change'   : BEGIN
    ;;------------------------------------------------------------------------------------
    ;; => Change VALUE
    ;;------------------------------------------------------------------------------------
    ;; => Set/Reset outputs
    read_pause     = ''
    read_out       = ''    ;; output value of decision
    value_out      = f
    ;; => Define prompt strings
    pro_out        = pro_out_val[index_out[0]]
    yesno_str      = yesno_chstr[index_out[0]]    ;; Asks user if they wish to change VALUE
    enter_str      = enter_chstr[index_out[0]]  ;; prompts for new value
    WHILE (read_out NE 'n' AND read_out NE 'y' AND read_out NE 'q') DO BEGIN
      read_out       = beam_fit_gen_prompt(STR_OUT=yesno_str,FORM_OUT=7)
      IF (read_out EQ 'debug') THEN STOP
    ENDWHILE
    ;; => Check if user wishes to quit
    IF (read_out EQ 'q') THEN RETURN
    ;; => If yes, then prompt for value
    IF (read_out EQ 'y') THEN BEGIN
      value_out            = beam_fit_gen_prompt(STR_OUT=enter_str,PRO_OUT=pro_out,FORM_OUT=5)
      change[index_out[0]] = 1b
    ENDIF ELSE BEGIN
      value_out            = param[index_out[0]]
    ENDELSE
    ;; => Change VALUE in i-th element of PARINFO
    parinfo[index_out[0]].VALUE = value_out
    ;; => Set/Reset outputs
    delete_variable,index_out
    ;; => See if user wants to do something else
    GOTO,JUMP_PAUSE
  END
  'const'    : BEGIN
    ;;------------------------------------------------------------------------------------
    ;; => Change FIXED
    ;;------------------------------------------------------------------------------------
    index_str      = enter_par_str[1]
    ;; => Set/Reset outputs
    read_pause     = ''
    read_out       = ''    ;; output value of decision
    value_out      = f
    ;; => Define procedure string
    pro_out0       = pro_out_val[index_out[0]]
    pro_out1       = pro_out_lim[index_out[0]]
    IF (parinfo[index_out[0]].FIXED) THEN BEGIN
      pro_out = [pro_out0,pro_out1,"",param_is__con[index_out[0]]]
    ENDIF ELSE BEGIN
      pro_out = [pro_out0,pro_out1,"",param_not_con[index_out[0]]]
    ENDELSE
    ;; => Define prompt strings
    yesno_str      = yesno_icstr[index_out[0]]    ;; Asks user if they wish to constrain VALUE
    WHILE (read_out NE 'n' AND read_out NE 'y' AND read_out NE 'q') DO BEGIN
      read_out       = beam_fit_gen_prompt(STR_OUT=yesno_str,PRO_OUT=pro_out,FORM_OUT=7)
      IF (read_out EQ 'debug') THEN STOP
    ENDWHILE
    ;; => Check if user wishes to quit
    IF (read_out EQ 'q') THEN RETURN
    ;; => If yes, then change value
    IF (read_out EQ 'y') THEN BEGIN
      constrain[index_out[0]]     = 1b
      ;; => Change FIXED in i-th element of PARINFO
      parinfo[index_out[0]].FIXED = 1b
      ;; => Inform user of change
      change[index_out[0]]        = 1b
    ENDIF
    ;; => Set/Reset outputs
    delete_variable,index_out
    ;; => See if user wants to do something else
    GOTO,JUMP_PAUSE
  END
  'uncon'    : BEGIN
    ;;------------------------------------------------------------------------------------
    ;; => Change FIXED
    ;;------------------------------------------------------------------------------------
    index_str      = enter_par_str[2]
    ;; => Set/Reset outputs
    read_pause     = ''
    read_out       = ''    ;; output value of decision
    value_out      = f
    ;; => Define procedure string
    pro_out0       = pro_out_val[index_out[0]]
    pro_out1       = pro_out_lim[index_out[0]]
    IF (parinfo[index_out[0]].FIXED) THEN BEGIN
      pro_out = [pro_out0,pro_out1,"",param_is__con[index_out[0]]]
    ENDIF ELSE BEGIN
      pro_out = [pro_out0,pro_out1,"",param_not_con[index_out[0]]]
    ENDELSE
    ;; => Define prompt strings
    yesno_str      = yesno_rcstr[index_out[0]]    ;; Asks user if they wish to remove constraint
    WHILE (read_out NE 'n' AND read_out NE 'y' AND read_out NE 'q') DO BEGIN
      read_out       = beam_fit_gen_prompt(STR_OUT=yesno_str,PRO_OUT=pro_out,FORM_OUT=7)
      IF (read_out EQ 'debug') THEN STOP
    ENDWHILE
    ;; => Check if user wishes to quit
    IF (read_out EQ 'q') THEN RETURN
    ;; => If yes, then change value
    IF (read_out EQ 'y') THEN BEGIN
      constrain[index_out[0]]     = 0b
      ;; => Change FIXED in i-th element of PARINFO
      parinfo[index_out[0]].FIXED = 0b
      ;; => Inform user of change
      change[index_out[0]]        = 1b
    ENDIF
    ;; => Set/Reset outputs
    delete_variable,index_out
    ;; => See if user wants to do something else
    GOTO,JUMP_PAUSE
  END
  'limit'    : BEGIN
    ;;------------------------------------------------------------------------------------
    ;; => Change LIMITED and LIMITS
    ;;------------------------------------------------------------------------------------
    index_str      = enter_par_str[3]
    ;; => Set/Reset outputs
    read_pause     = ''
    read_out       = ''    ;; output value of decision
    liml_out       = 0.
    limu_out       = 0.
    ;; => Define procedure string
    pro_out0       = pro_out_val[index_out[0]]
    pro_out1       = pro_out_lim[index_out[0]]
    IF (parinfo[index_out[0]].LIMITED[0] OR parinfo[index_out[0]].LIMITED[1]) THEN BEGIN
      pro_out = [pro_out0,pro_out1,"",param_is__lim[index_out[0]]]
    ENDIF ELSE BEGIN
      pro_out = [pro_out0,pro_out1,"",param_not_lim[index_out[0]]]
    ENDELSE
    ;; => Define prompt strings
    yesno_str      = yn_low_ilstr[index_out[0]]    ;; Asks user if they wish to impose lower bound limits
    WHILE (read_out NE 'n' AND read_out NE 'y' AND read_out NE 'q') DO BEGIN
      read_out       = beam_fit_gen_prompt(STR_OUT=yesno_str,PRO_OUT=pro_out,FORM_OUT=7)
      IF (read_out EQ 'debug') THEN STOP
    ENDWHILE
    ;; => Check if user wishes to quit
    IF (read_out EQ 'q') THEN RETURN
    IF (read_out EQ 'y') THEN lim_low = 1b ELSE lim_low = 0b
    ;; => Set/Reset outputs
    read_out       = ''    ;; output value of decision
    ;; => Define prompt strings
    yesno_str      = yn_upp_ilstr[index_out[0]]    ;; Asks user if they wish to impose upper bound limits
    WHILE (read_out NE 'n' AND read_out NE 'y' AND read_out NE 'q') DO BEGIN
      read_out       = beam_fit_gen_prompt(STR_OUT=yesno_str,FORM_OUT=7)
      IF (read_out EQ 'debug') THEN STOP
    ENDWHILE
    ;; => Check if user wishes to quit
    IF (read_out EQ 'q') THEN RETURN
    IF (read_out EQ 'y') THEN lim_upp = 1b ELSE lim_upp = 0b
    old_lims             = parinfo[index_out[0]].LIMITS
    old_limd             = parinfo[index_out[0]].LIMITED
    limited              = [0b,0b]
    limits               = [0e0,0e0]
    ;; => If yes, then prompt for values and impose limits
    IF (lim_low OR lim_upp) THEN BEGIN
      ;; => Inform user of change
      change[index_out[0]] = 1b
      IF (lim_low) THEN BEGIN
        enter_str            = enter_ilstr_l[index_out[0]]  ;; prompts for new lower bound
        value_low            = beam_fit_gen_prompt(STR_OUT=enter_str,FORM_OUT=5)
        ;; => Define outputs
        limited[0]           = 1b
        limits[0]            = value_low[0]
      ENDIF ELSE BEGIN
        ;; => Use currently set limits
        limited[0]           = old_limd[0]
        limits[0]            = old_lims[0]
      ENDELSE
      IF (lim_upp) THEN BEGIN
        enter_str            = enter_ilstr_u[index_out[0]]  ;; prompts for new upper bound
        value_upp            = beam_fit_gen_prompt(STR_OUT=enter_str,FORM_OUT=5)
        ;; => Define outputs
        limited[1]           = 1b
        limits[1]            = value_upp[0]
      ENDIF ELSE BEGIN
        ;; => Use currently set limits
        limited[1]           = old_limd[1]
        limits[1]            = old_lims[1]
      ENDELSE
    ENDIF ELSE BEGIN
      ;; => Define outputs
      limited              = parinfo[index_out[0]].LIMITED
      limits               = parinfo[index_out[0]].LIMITS
    ENDELSE
    ;; => Sort results just in case user entered backwards
    IF (lim_low AND lim_upp) THEN BEGIN
      sp                   = SORT(limits)
      limits               = limits[sp]
      limited              = limited[sp]
    ENDIF
    ;; => Change LIMITED in i-th element of PARINFO
    parinfo[index_out[0]].LIMITED = limited
    ;; => Change LIMITS in i-th element of PARINFO
    parinfo[index_out[0]].LIMITS  = limits
    ;;------------------------------------------------------------------------------------
    ;;  Make sure new range in LIMITS overlaps with value in VALUE
    ;;------------------------------------------------------------------------------------
    old_val        = parinfo[index_out[0]].VALUE
    test           = ((old_val LT limits[0]) AND limited[0]) OR $
                     ((old_val GT limits[1]) AND limited[1])
    IF (test) THEN BEGIN
      ;;  Determine which, if any, limit is set
      check          = WHERE(limited,gch)
      CASE gch[0] OF
        1L   :  BEGIN
          ;; only one side is limited
          CASE check[0] OF
            0L   :  BEGIN
              IF (old_val LT limits[0]) THEN old_val = limits[0] + 0.05*ABS(limits[0])
            END
            1L   :  BEGIN
              IF (old_val GT limits[1]) THEN old_val = limits[1] - 0.05*ABS(limits[1])
            END
          ENDCASE
        END
        2L   :  BEGIN
          ;;  both sides limited => Use Avg. if necessary
          test           = ((limits[0] EQ 0.0) AND (limits[1] EQ 0.0)) EQ 0
          IF (test) THEN BEGIN
            old_val        = (limits[0] + limits[1])/2d0
          ENDIF
        END
        ELSE :  ;; do nothing
      ENDCASE
    ENDIF
    parinfo[index_out[0]].VALUE = old_val
    ;; => Set/Reset outputs
    delete_variable,index_out
    ;; => See if user wants to do something else
    GOTO,JUMP_PAUSE
  END
  'unlim'    : BEGIN
    ;;------------------------------------------------------------------------------------
    ;; => Change LIMITED and LIMITS
    ;;------------------------------------------------------------------------------------
    index_str      = enter_par_str[4]
    ;; => Set/Reset outputs
    read_pause     = ''
    read_out       = ''    ;; output value of decision
    value_out      = 0b
    ;; => Define procedure string
    pro_out0       = pro_out_val[index_out[0]]
    pro_out1       = pro_out_lim[index_out[0]]
    IF (parinfo[index_out[0]].LIMITED[0] OR parinfo[index_out[0]].LIMITED[1]) THEN BEGIN
      pro_out = [pro_out0,pro_out1,"",param_is__lim[index_out[0]]]
    ENDIF ELSE BEGIN
      pro_out = [pro_out0,pro_out1,"",param_not_lim[index_out[0]]]
    ENDELSE
    ;; => Define prompt strings
    yesno_str      = yn_low_rlstr[index_out[0]]    ;; Asks user if they wish to remove lower bound limits
    WHILE (read_out NE 'n' AND read_out NE 'y' AND read_out NE 'q') DO BEGIN
      read_out       = beam_fit_gen_prompt(STR_OUT=yesno_str,PRO_OUT=pro_out,FORM_OUT=7)
      IF (read_out EQ 'debug') THEN STOP
    ENDWHILE
    ;; => Check if user wishes to quit
    IF (read_out EQ 'q') THEN RETURN
    IF (read_out EQ 'y') THEN lim_low = 0b ELSE lim_low = 1b
    ;; => Set/Reset outputs
    read_out       = ''    ;; output value of decision
    ;; => Define prompt strings
    yesno_str      = yn_upp_rlstr[index_out[0]]    ;; Asks user if they wish to remove upper bound limits
    WHILE (read_out NE 'n' AND read_out NE 'y' AND read_out NE 'q') DO BEGIN
      read_out       = beam_fit_gen_prompt(STR_OUT=yesno_str,FORM_OUT=7)
      IF (read_out EQ 'debug') THEN STOP
    ENDWHILE
    ;; => Check if user wishes to quit
    IF (read_out EQ 'q') THEN RETURN
    IF (read_out EQ 'y') THEN lim_upp = 0b ELSE lim_upp = 1b
    old_lims             = parinfo[index_out[0]].LIMITS
    old_limd             = parinfo[index_out[0]].LIMITED
    ;; => Define outputs
    limited              = [lim_low,lim_upp]
    limits               = (parinfo[index_out[0]].LIMITS)*FLOAT(limited)
    ;; => Change LIMITED in i-th element of PARINFO
    parinfo[index_out[0]].LIMITED = limited
    ;; => Change LIMITS in i-th element of PARINFO
    parinfo[index_out[0]].LIMITS  = limits
    ;; => Inform user of change
    gdiff                = (TOTAL(limits - old_lims) GT 0) OR (TOTAL(limited - old_limd) GT 0)
    change[index_out[0]] = gdiff[0]
    ;;------------------------------------------------------------------------------------
    ;;  Make sure new range in LIMITS overlaps with value in VALUE
    ;;------------------------------------------------------------------------------------
    old_val        = parinfo[index_out[0]].VALUE
    test           = ((old_val LT limits[0]) AND limited[0]) OR $
                     ((old_val GT limits[1]) AND limited[1])
    IF (test) THEN BEGIN
      ;;  Determine which, if any, limit is set
      check          = WHERE(limited,gch)
      CASE gch[0] OF
        1L   :  BEGIN
          ;; only one side is limited
          CASE check[0] OF
            0L   :  IF (old_val LT limits[0]) THEN old_val = limits[0] + 0.05*ABS(limits[0])
            1L   :  IF (old_val GT limits[1]) THEN old_val = limits[1] - 0.05*ABS(limits[1])
          ENDCASE
        END
        2L   :  BEGIN
          ;;  both sides limited => Use Avg. if necessary
          test           = ((limits[0] EQ 0.0) AND (limits[1] EQ 0.0)) EQ 0
          IF (test) THEN BEGIN
            old_val        = (limits[0] + limits[1])/2d0
          ENDIF
        END
        ELSE :  ;; do nothing
      ENDCASE
    ENDIF
    parinfo[index_out[0]].VALUE = old_val
    ;; => Set/Reset outputs
    delete_variable,index_out
    ;; => See if user wants to do something else
    GOTO,JUMP_PAUSE
  END
  'q'        : BEGIN
    ;;------------------------------------------------------------------------------------
    ;; => Quit so reset defaults
    ;;------------------------------------------------------------------------------------
    ;; => Define output
    read_pause     = ''
    read_out       = 'q'
    ;; => Set/Reset outputs
    delete_variable,index_out
    ;; => Nothing else changes, so return
    RETURN
  END
  'debug'    : BEGIN
    ;;------------------------------------------------------------------------------------
    ;; => Debugging option
    ;;------------------------------------------------------------------------------------
    ;; => Set/Reset outputs
    delete_variable,index_out
    read_pause     = ''
    PRINT,''
    errmssg        = 'Debugging error handling => STOP'
    MESSAGE,errmssg,/INFORMATIONAL,/CONTINUE
    STOP
  END
ENDCASE
;;----------------------------------------------------------------------------------------
;; => Return to user
;;----------------------------------------------------------------------------------------

RETURN
END

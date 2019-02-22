;+
;*****************************************************************************************
;
;  PROCEDURE:   resistivity_calc_wrapper.pro
;  PURPOSE  :   This is a wrapping routine for TPLOT data with the routine
;                 resistivity_calculation.pro.
;
;  CALLED BY:   
;               NA
;
;  CALLS:
;               tnames.pro
;               get_data.pro
;               tplot_struct_format_test.pro
;               interp.pro
;               resistivity_calculation.pro
;               resistivity_calc_wrapper.pro
;
;  REQUIRES:    
;               1)  THEMIS TDAS IDL libraries or UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               NE_NAME   :  Scalar [string,long] defining the TPLOT handle to use for
;                              the particle number density [cm^(-3)]
;               TE_NAME   :  Scalar [string,long] defining the TPLOT handle to use for
;                              the electron temperature [eV]
;
;  EXAMPLES:    
;               
;
;  KEYWORDS:    
;               DE_NAME   :  Scalar [string,long] defining the TPLOT handle to use for
;                              the wave electric field amplitudes [mV/m]
;                              [Routine expects this to be vector components on input]
;               BO_NAME   :  Scalar [string,long] defining the TPLOT handle to use for
;                              the ambient magnetic field magnitudes [nT]
;               TI_NAME   :  Scalar [string,long] defining the TPLOT handle to use for
;                              the ion temperature [eV]
;               VD_NAME   :  Scalar [string,long] defining the TPLOT handle to use for
;                              the electron-ion relative drift speed [km/s]
;                              [Routine expects this to be vector components on input]
;               R_STRUCT  :  Set to a named variable to return the data structure
;                              returned by resistivity_calculation.pro
;
;   CHANGED:  1)  Finished man page                                [12/17/2012   v1.0.1]
;
;   NOTES:      
;               
;
;   CREATED:  04/10/2012
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  12/17/2012   v1.0.1
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

PRO resistivity_calc_wrapper,ne_name,te_name,DE_NAME=de_name,BO_NAME=bo_name,$
                             TI_NAME=ti_name,VD_NAME=vd_name,R_STRUCT=r_struct

;-----------------------------------------------------------------------------------------
; => Constants
;-----------------------------------------------------------------------------------------
f          = !VALUES.F_NAN
d          = !VALUES.D_NAN
; => Dummy error messages
noinpt_msg = 'No input supplied...'
notstr_msg = 'Must be a [2]-element string array...'
nofint_msg = 'No finite data...'
nottpn_msg = 'not a valid TPLOT handle'
badin__msg = 'IN_NAMES must be an [N]-element string array of valid TPLOT handles...'
badout_msg = 'OUT_NAMES must be an [N,3]-element string array of valid TPLOT handles...'
; => EXECUTE string prefixes and suffixes
ex_mid     = ['de_name[0]','bo_name[0]','ti_name[0]','vd_name[0]']
ex_suf     = ['de_dat','bo_dat','ti_dat','vd_dat']
gexstring  = 'get_data,'+ex_mid+',DATA='+ex_suf
exstr_00   = ex_suf+' = 0'
;-----------------------------------------------------------------------------------------
; => Check input
;-----------------------------------------------------------------------------------------
IF (N_PARAMS() LT 2) THEN BEGIN
  ; => no input???
  MESSAGE,noinpt_msg[0],/INFORMATIONAL,/CONTINUE
  RETURN
ENDIF
;; => Make sure NE_NAME and TE_NAME are valid and existing TPLOT handles
check = tnames(ne_name)
IF (check[0] EQ '') THEN BEGIN
  ; => user gave improper input:  IN_NAMES
  MESSAGE,'NE_NAME is '+nottpn_msg[0],/INFORMATIONAL,/CONTINUE
  RETURN
ENDIF
check = tnames(te_name)
IF (check[0] EQ '') THEN BEGIN
  ; => user gave improper input:  IN_NAMES
  MESSAGE,'TE_NAME is '+nottpn_msg[0],/INFORMATIONAL,/CONTINUE
  RETURN
ENDIF
;-----------------------------------------------------------------------------------------
; => Get density and temperature
;-----------------------------------------------------------------------------------------
get_data,ne_name[0],DATA=ne_dat
get_data,te_name[0],DATA=te_dat
test   = (SIZE(ne_dat,/TYPE) NE 8L) OR (SIZE(te_dat,/TYPE) NE 8L)
IF (test) THEN BEGIN
  ; => user gave improper input:  IN_NAMES
  MESSAGE,nofint_msg[0],/INFORMATIONAL,/CONTINUE
  RETURN
ENDIF
form_ne  = tplot_struct_format_test(ne_dat) NE 1
form_te  = tplot_struct_format_test(te_dat) NE 1
IF (form_ne OR form_te) THEN BEGIN
  ; => bad input???
  MESSAGE,nottpn_msg[0],/INFORMATIONAL,/CONTINUE
  RETURN
ENDIF
;-----------------------------------------------------------------------------------------
; => Check keywords
;-----------------------------------------------------------------------------------------
test_all = [KEYWORD_SET(de_name),KEYWORD_SET(bo_name),$
            KEYWORD_SET(ti_name),KEYWORD_SET(vd_name)]
sum_all  = TOTAL(test_all)
good_all = WHERE(test_all,gdall,COMPLEMENT=bad_all,NCOMPLEMENT=bdall)

CASE sum_all[0] OF
  0    : BEGIN
    ;; 0 keywords set
    de_dat = 0
    bo_dat = 0
    ti_dat = 0
    vd_dat = 0
  END
  1    : BEGIN
    ;; 1 keywords set
    result   = EXECUTE(gexstring[good_all[0]])
    IF (result EQ 0) THEN BEGIN
      ;; did not work => set value to zero
      result = EXECUTE(exstr_00[good_all[0]])
    ENDIF
    ;; define non-set keyword values to 0
    result0  = EXECUTE(exstr_00[bad_all[0]])
    result1  = EXECUTE(exstr_00[bad_all[1]])
    result2  = EXECUTE(exstr_00[bad_all[2]])
  END
  2    : BEGIN
    ;; 2 keywords set
    FOR j=0L, 1L DO BEGIN
      result   = EXECUTE(gexstring[good_all[j]])
      IF (result EQ 0) THEN result = EXECUTE(exstr_00[good_all[j]])
    ENDFOR
    ;; define non-set keyword values to 0
    result0  = EXECUTE(exstr_00[bad_all[0]])
    result1  = EXECUTE(exstr_00[bad_all[1]])
  END
  3    : BEGIN
    ;; 3 keywords set
    FOR j=0L, 2L DO BEGIN
      result   = EXECUTE(gexstring[good_all[j]])
      IF (result EQ 0) THEN result = EXECUTE(exstr_00[good_all[j]])
    ENDFOR
    ;; define non-set keyword values to 0
    result0  = EXECUTE(exstr_00[bad_all[0]])
  END
  4    : BEGIN
    ;; 4 keywords set
    FOR j=0L, 3L DO BEGIN
      result   = EXECUTE(gexstring[good_all[j]])
      IF (result EQ 0) THEN result = EXECUTE(exstr_00[good_all[j]])
    ENDFOR
  END
  ELSE : BEGIN
    ;; how did this happen???
    de_dat = 0
    bo_dat = 0
    ti_dat = 0
    vd_dat = 0
  END
ENDCASE
;-----------------------------------------------------------------------------------------
; => Create structure containing new results
;-----------------------------------------------------------------------------------------
tags     = 'T'+STRING(LINDGEN(4L),FORMAT='(I2.2)')
test_all = [(SIZE(de_dat,/TYPE) EQ 8L),(SIZE(bo_dat,/TYPE) EQ 8L),$
            (SIZE(ti_dat,/TYPE) EQ 8L),(SIZE(vd_dat,/TYPE) EQ 8L)]
good_all = WHERE(test_all,gdall,COMPLEMENT=bad_all,NCOMPLEMENT=bdall)
dat_strc = CREATE_STRUCT(tags,de_dat,bo_dat,ti_dat,vd_dat)
;-----------------------------------------------------------------------------------------
; => Define density and temperature values
;-----------------------------------------------------------------------------------------
;; => define density values
n_ex     = ne_dat.X
n_ey     = ne_dat.Y
n_ne     = N_ELEMENTS(n_ex)
;; => define temperature values
t_ex     = te_dat.X
t_ey     = te_dat.Y
n_te     = N_ELEMENTS(t_ex)
;-----------------------------------------------------------------------------------------
; => Calculate resistivities
;-----------------------------------------------------------------------------------------
CASE gdall[0] OF
  0    : BEGIN
    ;;------------------------------------------------------------------------------------
    ;; 0 keywords set
    ;;------------------------------------------------------------------------------------
    ;; => interpolate so they share abscissa
    IF (n_ne GT n_te) THEN BEGIN
      ;; => use Te abscissa
      n_e = interp(n_ey,n_ex,t_ex,/NO_EXTRAP)
      t_e = t_ey
      abc = t_ex
    ENDIF ELSE BEGIN
      ;; => use Ne abscissa
      n_e = n_ey
      t_e = interp(t_ey,t_ex,n_ex,/NO_EXTRAP)
      abc = n_ex
    ENDELSE
    ;; => Calculate resistivity
    r_struct = resistivity_calculation(n_e,t_e)
    ;; => Add corresponding abscissa to structure
    str_element,r_struct,'ABSCISSA',abc,/ADD_REPLACE
    RETURN
  END
  1    : BEGIN
    ;;------------------------------------------------------------------------------------
    ;; 1 keywords set
    ;;------------------------------------------------------------------------------------
    IF (good_all[0] NE 0) THEN BEGIN
      ;; => routine expects E-field wave amplitudes first...
      resistivity_calc_wrapper,ne_name,te_name,R_STRUCT=r_struct
      RETURN
    ENDIF ELSE BEGIN
      ;; => check dE format
      form  = tplot_struct_format_test(de_dat,/YVECT) NE 1
      IF (form) THEN BEGIN
        resistivity_calc_wrapper,ne_name,te_name,R_STRUCT=r_struct
        RETURN
      ENDIF
      ;; => define dE values
      dE_x     = de_dat.X
      dE_y     = de_dat.Y
      n_dE     = N_ELEMENTS(dE_x)
      ;; => use dE abscissa
      d_e      = SQRT(TOTAL(dE_y^2,2L,/NAN))  ;  |dE|  [mV/m]
      n_e      = interp(n_ey,n_ex,dE_x,/NO_EXTRAP)
      t_e      = interp(t_ey,t_ex,dE_x,/NO_EXTRAP)
    ENDELSE
    ;; => Calculate resistivity
    r_struct = resistivity_calculation(n_e,t_e,d_e)
    ;; => Add corresponding abscissa to structure
    str_element,r_struct,'ABSCISSA',dE_x,/ADD_REPLACE
    RETURN
  END
  2    : BEGIN
    ;;------------------------------------------------------------------------------------
    ;; 2 keywords set
    ;;------------------------------------------------------------------------------------
    test     = (good_all[0] NE 0) OR (good_all[1] NE 1)
    IF (test) THEN BEGIN
      ;; => routine expects dE first, then Bo
      test     = (good_all[0] NE 0)
      IF (test) THEN BEGIN
        ;; => routine expects dE first
        resistivity_calc_wrapper,ne_name,te_name,R_STRUCT=r_struct
        RETURN
      ENDIF ELSE BEGIN
        ;; => dE used correctly
        resistivity_calc_wrapper,ne_name,te_name,DE_NAME=de_name,R_STRUCT=r_struct
        RETURN
      ENDELSE
    ENDIF ELSE BEGIN
      ;; => check dE format
      form  = tplot_struct_format_test(de_dat,/YVECT) NE 1
      IF (form) THEN BEGIN
        resistivity_calc_wrapper,ne_name,te_name,R_STRUCT=r_struct
        RETURN
      ENDIF
      ;; => check Bo format
      form  = tplot_struct_format_test(bo_dat) NE 1
      IF (form) THEN BEGIN
        resistivity_calc_wrapper,ne_name,te_name,DE_NAME=de_name,R_STRUCT=r_struct
        RETURN
      ENDIF
      ;; => define dE values
      dE_x     = de_dat.X
      dE_y     = de_dat.Y
      n_dE     = N_ELEMENTS(dE_x)
      d_e      = SQRT(TOTAL(dE_y^2,2L,/NAN))  ;  |dE|  [mV/m]
      ;; => define Bo values
      Bo_x     = bo_dat.X
      Bo_y     = bo_dat.Y
      n_Bo     = N_ELEMENTS(Bo_x)
      ;; => use dE abscissa
      n_e      = interp(n_ey,n_ex,dE_x,/NO_EXTRAP)
      t_e      = interp(t_ey,t_ex,dE_x,/NO_EXTRAP)
      b_o      = interp(Bo_y,Bo_x,dE_x,/NO_EXTRAP)
    ENDELSE
    ;; => Calculate resistivity
    r_struct = resistivity_calculation(n_e,t_e,d_e,b_o)
    ;; => Add corresponding abscissa to structure
    str_element,r_struct,'ABSCISSA',dE_x,/ADD_REPLACE
    RETURN
  END
  3    : BEGIN
    ;;------------------------------------------------------------------------------------
    ;; 3 keywords set
    ;;------------------------------------------------------------------------------------
    test     = (good_all[0] NE 0) OR (good_all[1] NE 1) OR (good_all[2] NE 2)
    IF (test) THEN BEGIN
      ;; => routine expects dE first, then Bo, then Ti
      test     = (good_all[0] NE 0) OR (good_all[1] NE 1)
      IF (test) THEN BEGIN
        ;; => routine expects dE first, then Bo
        test     = (good_all[0] NE 0)
        IF (test) THEN BEGIN
          ;; => routine expects dE first
          resistivity_calc_wrapper,ne_name,te_name,R_STRUCT=r_struct
          RETURN
        ENDIF ELSE BEGIN
          ;; => dE used correctly
          resistivity_calc_wrapper,ne_name,te_name,DE_NAME=de_name,R_STRUCT=r_struct
          RETURN
        ENDELSE
      ENDIF ELSE BEGIN
        ;; => dE and Bo used correctly
        resistivity_calc_wrapper,ne_name,te_name,DE_NAME=de_name,BO_NAME=bo_name,$
                                 R_STRUCT=r_struct
        RETURN
      ENDELSE
    ENDIF ELSE BEGIN
      ;; => check dE format
      form  = tplot_struct_format_test(de_dat,/YVECT) NE 1
      IF (form) THEN BEGIN
        resistivity_calc_wrapper,ne_name,te_name,R_STRUCT=r_struct
        RETURN
      ENDIF
      ;; => check Bo format
      form  = tplot_struct_format_test(bo_dat) NE 1
      IF (form) THEN BEGIN
        resistivity_calc_wrapper,ne_name,te_name,DE_NAME=de_name,R_STRUCT=r_struct
        RETURN
      ENDIF
      ;; => check Ti format
      form  = tplot_struct_format_test(ti_dat) NE 1
      IF (form) THEN BEGIN
        resistivity_calc_wrapper,ne_name,te_name,DE_NAME=de_name,BO_NAME=bo_name,$
                                 R_STRUCT=r_struct
        RETURN
      ENDIF
      ;; => define dE values
      dE_x     = de_dat.X
      dE_y     = de_dat.Y
      n_dE     = N_ELEMENTS(dE_x)
      d_e      = SQRT(TOTAL(dE_y^2,2L,/NAN))  ;  |dE|  [mV/m]
      ;; => define Bo values
      Bo_x     = bo_dat.X
      Bo_y     = bo_dat.Y
      n_Bo     = N_ELEMENTS(Bo_x)
      ;; => define Ti values
      t_ix     = ti_dat.X
      t_iy     = ti_dat.Y
      n_ti     = N_ELEMENTS(t_ix)
      ;; => use dE abscissa
      n_e      = interp(n_ey,n_ex,dE_x,/NO_EXTRAP)
      t_e      = interp(t_ey,t_ex,dE_x,/NO_EXTRAP)
      b_o      = interp(Bo_y,Bo_x,dE_x,/NO_EXTRAP)
      t_i      = interp(t_iy,t_ix,dE_x,/NO_EXTRAP)
    ENDELSE
    ;; => Calculate resistivity
    r_struct = resistivity_calculation(n_e,t_e,d_e,b_o,t_i)
    ;; => Add corresponding abscissa to structure
    str_element,r_struct,'ABSCISSA',dE_x,/ADD_REPLACE
    RETURN
  END
  4    : BEGIN
    ;;------------------------------------------------------------------------------------
    ;; 4 keywords set
    ;;------------------------------------------------------------------------------------
    ;; => check dE format
    form  = tplot_struct_format_test(de_dat,/YVECT) NE 1
    IF (form) THEN BEGIN
      resistivity_calc_wrapper,ne_name,te_name,R_STRUCT=r_struct
      RETURN
    ENDIF
    ;; => check Bo format
    form  = tplot_struct_format_test(bo_dat) NE 1
    IF (form) THEN BEGIN
      resistivity_calc_wrapper,ne_name,te_name,DE_NAME=de_name,R_STRUCT=r_struct
      RETURN
    ENDIF
    ;; => check Ti format
    form  = tplot_struct_format_test(ti_dat) NE 1
    IF (form) THEN BEGIN
      resistivity_calc_wrapper,ne_name,te_name,DE_NAME=de_name,BO_NAME=bo_name,$
                               R_STRUCT=r_struct
      RETURN
    ENDIF
    ;; => check Vd format
    form  = tplot_struct_format_test(vd_dat,/YVECT) NE 1
    IF (form) THEN BEGIN
      resistivity_calc_wrapper,ne_name,te_name,DE_NAME=de_name,BO_NAME=bo_name,$
                               TI_NAME=ti_name,R_STRUCT=r_struct
      RETURN
    ENDIF
    ;; => define dE values
    dE_x     = de_dat.X
    dE_y     = de_dat.Y
    n_dE     = N_ELEMENTS(dE_x)
    d_e      = SQRT(TOTAL(dE_y^2,2L,/NAN))  ;  |dE|  [mV/m]
    ;; => define Bo values
    Bo_x     = bo_dat.X
    Bo_y     = bo_dat.Y
    n_Bo     = N_ELEMENTS(Bo_x)
    ;; => define Ti values
    t_ix     = ti_dat.X
    t_iy     = ti_dat.Y
    n_ti     = N_ELEMENTS(t_ix)
    ;; => define Vd values
    Vd_x     = vd_dat.X
    Vd_y     = vd_dat.Y
    n_Vd     = N_ELEMENTS(Vd_x)
    V_dm     = SQRT(TOTAL(Vd_y^2,2L,/NAN))  ;  |Vd|  [km/s]
    ;; => use dE abscissa
    n_e      = interp(n_ey,n_ex,dE_x,/NO_EXTRAP)
    t_e      = interp(t_ey,t_ex,dE_x,/NO_EXTRAP)
    b_o      = interp(Bo_y,Bo_x,dE_x,/NO_EXTRAP)
    t_i      = interp(t_iy,t_ix,dE_x,/NO_EXTRAP)
    v_d      = interp(Vd_y,Vd_x,dE_x,/NO_EXTRAP)
    ;; => Calculate resistivity
    r_struct = resistivity_calculation(n_e,t_e,d_e,b_o,t_i,v_d)
    ;; => Add corresponding abscissa to structure
    str_element,r_struct,'ABSCISSA',dE_x,/ADD_REPLACE
    RETURN
  END
  ELSE : BEGIN
    ;;------------------------------------------------------------------------------------
    ;; Default:  0 keywords set
    ;;------------------------------------------------------------------------------------
    ;; => interpolate so they share abscissa
    IF (n_ne GT n_te) THEN BEGIN
      ;; => use Te abscissa
      n_e = interp(n_ey,n_ex,t_ex,/NO_EXTRAP)
      t_e = t_ey
      abc = t_ex
    ENDIF ELSE BEGIN
      ;; => use Ne abscissa
      n_e = n_ey
      t_e = interp(t_ey,t_ex,n_ex,/NO_EXTRAP)
      abc = n_ex
    ENDELSE
    ;; => Calculate resistivity
    r_struct = resistivity_calculation(n_e,t_e)
    ;; => Add corresponding abscissa to structure
    str_element,r_struct,'ABSCISSA',abc,/ADD_REPLACE
    RETURN
  END
ENDCASE
;-----------------------------------------------------------------------------------------
; => Return result
;-----------------------------------------------------------------------------------------

RETURN
END
;+
;*****************************************************************************************
;
;  FUNCTION :   define_particle_charge.pro
;  PURPOSE  :   This routine takes a velocity distribution function, in the form of an
;                 IDL structure, and determines the sign of the charge associated with
;                 the type of particle associated with the input distribution.
;
;  CALLED BY:   
;               spec3d.pro
;               transform_vframe_3d.pro
;
;  INCLUDES:
;               NA
;
;  CALLS:
;               test_wind_vs_themis_esa_struct.pro
;               dat_3dp_str_names.pro
;               str_element.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               DAT        :  Scalar [structure] associated with a known THEMIS ESA or
;                               SST data structure
;                               [e.g., see get_th?_p*@b.pro, ? = a-f, * = e,s @ = e,i]
;                               or a Wind/3DP data structure
;                               [see get_?.pro, ? = el, elb, pl, ph, eh, etc.]
;
;  EXAMPLES:    
;               charge = define_particle_charge(dat,E_SHIFT=e_shift)
;
;  KEYWORDS:    
;               E_SHIFT    :  Set to a dummy variable to return the energy [eV] shift
;                               associated with the DAT
;
;   CHANGED:  1)  Now routine can handle THEMIS SST data structures
;                                                                  [11/16/2015   v1.1.0]
;
;   NOTES:      
;               1)  This routine should get the charge from both THEMIS ESA/SST and
;                     Wind/3DP structures
;               2)  The E_SHIFT keyword is only relevant for EESA data structures from
;                     the Wind/3DP instrument
;
;  REFERENCES:  
;               NA
;
;   CREATED:  10/02/2014
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  11/16/2015   v1.1.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION define_particle_charge,dat,E_SHIFT=e_shift

;;----------------------------------------------------------------------------------------
;;  Define some constants and dummy variables
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
e_shift        = 0e0            ;;  Default value to be changed if valid input
charge         = 0b             ;;  Default value to be changed if valid input
def_uconv_r_th = ['thm_convert_esa_units_lbwiii','thm_convert_sst_units_lbwiii']
;;  Dummy error messages
notstr_mssg    = 'Input must be an IDL structure...'
notvdf_msg     = 'Input must be a velocity distribution function as an IDL structure...'
not3dp_msg     = 'Input must be an ion velocity distribution IDL structure from Wind/3DP...'
badthm_msg     = 'If THEMIS ESA structures used, then they must be modified using modify_themis_esa_struc.pro'
;;----------------------------------------------------------------------------------------
;;  Check input
;;----------------------------------------------------------------------------------------
test           = (N_PARAMS() EQ 0) OR (N_ELEMENTS(dat) EQ 0)
IF (test[0]) THEN RETURN,0b
str            = dat[0]   ;;  in case it is an array of structures of the same format
IF (SIZE(str,/TYPE) NE 8L) THEN BEGIN
  IF ~KEYWORD_SET(nom) THEN MESSAGE,notstr_mssg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF

test0          = test_wind_vs_themis_esa_struct(str,/NOM)
test1          = test_wind_vs_themis_esa_struct(str,/NOM,/PAD)
test           = ((test0.(0) + test0.(1)) NE 1) AND ((test1.(0) + test1.(1)) NE 1)
IF (test[0]) THEN BEGIN
  MESSAGE,notvdf_msg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
;;----------------------------------------------------------------------------------------
;;  Determine instrument (i.e., ESA or 3DP) and define electric charge
;;----------------------------------------------------------------------------------------
IF (test0.(0) OR test1.(0)) THEN BEGIN
  ;;-------------------------------------------
  ;; Wind
  ;;-------------------------------------------
  ;;  Check which instrument is being used
  strns   = dat_3dp_str_names(str[0])
  IF (SIZE(strns,/TYPE) NE 8) THEN BEGIN
    ;;  Neither Wind/3DP nor THEMIS/ESA VDF
    MESSAGE,'1: '+not3dp_msg[0],/INFORMATIONAL,/CONTINUE
    RETURN,0b
  ENDIF
  shnme   = STRLOWCASE(STRMID(strns.SN[0],0L,2L))
  shnme2  = STRMID(shnme[0],0L,1L)
  CASE shnme2[0] OF
    'p'  :  BEGIN      ;;  PESA --> +1
      charge  = 1e0
    END
    'e'  :  BEGIN      ;;  EESA --> -1
      charge = -1e0
      ;;  Check for energy shift in data structure
      str_element,str,'E_SHIFT',e_shift
    END
    's'  :  BEGIN      ;;  SST  --> +1 {for Open}, -1 {for Foil}
      test    = (shnme[0] EQ 'sf')
      IF (test[0]) THEN charge = -1e0 ELSE charge = 1e0
    END
    ELSE : BEGIN
      ;;  How did this happen?
      MESSAGE,'2: '+not3dp_msg[0],/INFORMATIONAL,/CONTINUE
      RETURN,0b
    END
  ENDCASE
ENDIF ELSE BEGIN
  ;;-------------------------------------------
  ;; THEMIS
  ;;-------------------------------------------
  ;;  make sure the structure has been modified
  temp_proc = STRLOWCASE(str[0].UNITS_PROCEDURE)
  test_un   = (temp_proc[0] NE def_uconv_r_th[0]) AND (temp_proc[0] NE def_uconv_r_th[1])
;  test_un = STRLOWCASE(str[0].UNITS_PROCEDURE) NE 'thm_convert_esa_units_lbwiii'
  IF (test_un[0]) THEN BEGIN
    MESSAGE,badthm_msg[0],/INFORMATIONAL,/CONTINUE
    RETURN,0b
  ENDIF
  ;;  Define the charge
  charge  = str[0].CHARGE
ENDELSE
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN,charge[0]
END

;+
;*****************************************************************************************
;
;  FUNCTION :   modify_themis_esa_struc.pro
;  PURPOSE  :   This routine takes an ESA structure produced by the THEMIS routines and
;                 modifies it so that it is compatible with UMN Modified Wind/3DP IDL
;                 Library plotting routines.
;
;  CALLED BY:   
;               NA
;
;  CALLS:
;               test_themis_esa_struc_format.pro
;               str_element.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               DAT      :  [N]-Element array of THEMIS ESA data structures
;
;  EXAMPLES:    
;               NA
;
;  KEYWORDS:    
;               NA
;
;   CHANGED:  1)  Now allows arrays of ESA structures on input     [03/29/2012   v1.1.0]
;             2)  Corrected the accumulation time variable associated with tag DT
;                                                                  [08/07/2012   v1.2.0]
;
;   NOTES:      
;               1)  This routine modifies the input, so make sure you have a copy
;               2)  Some of the structure tags are added so that the structure will
;                     cause test_3dp_struc_format.pro to return TRUE
;
;   CREATED:  03/14/2012
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  08/07/2012   v1.2.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

PRO modify_themis_esa_struc,dat

;;----------------------------------------------------------------------------------------
;; => Define some constants and dummy variables
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
notstr_mssg    = 'Must be an IDL structure...'
;;----------------------------------------------------------------------------------------
;; => Check input
;;----------------------------------------------------------------------------------------
IF (N_PARAMS() EQ 0) THEN RETURN
str  = dat[0]   ; => in case it is an array of structures of the same format
IF (SIZE(str,/TYPE) NE 8L) THEN BEGIN
  MESSAGE,notstr_mssg,/INFORMATIONAL,/CONTINUE
  RETURN
ENDIF
test = test_themis_esa_struc_format(str,/NOM) NE 1
IF (test) THEN RETURN
;;----------------------------------------------------------------------------------------
;; => Create a dummy structure to replicate
;;----------------------------------------------------------------------------------------
dummy = dat[0]
szd   = SIZE(dummy.DT_ARR,/DIMENSIONS)              ;; {[E]-Element,[A]-Element} array
nst   = N_ELEMENTS(dat)                             ;; # of structures
; => Add new tags to dummy structure
str_element,dummy,'VSW',REPLICATE(d,3L),/ADD_REPLACE
str_element,dummy,'DT',REPLICATE(f,szd),/ADD_REPLACE
str_element,dummy,'DEADTIME',REPLICATE(f,szd),/ADD_REPLACE
data  = REPLICATE(dummy[0],nst)
;;----------------------------------------------------------------------------------------
;; => Modify input
;;----------------------------------------------------------------------------------------
FOR j=0L, nst - 1L DO BEGIN
  temp     = dat[j]
  ;;--------------------------------------------------------------------------------------
  ;; => Calculate correct accumulation time from data
  ;;--------------------------------------------------------------------------------------
  tacc     = FLOAT(temp[0].INTEG_T[0]*temp[0].DT_ARR)   ;; [E,A]-Element array
  ;; => use my modified unit conversion routine so we don't need TDAS libraries
  str_element,temp,'UNITS_PROCEDURE','thm_convert_esa_units_lbwiii',/ADD_REPLACE
  ;; => add the Vsw structure tag
  str_element,temp,'VSW',temp.VELOCITY,/ADD_REPLACE
  ;; => Change project name to include spacecraft
  nprojnm  = temp.PROJECT_NAME[0]+'-'+STRUPCASE(temp.SPACECRAFT[0])
  str_element,temp,'PROJECT_NAME',nprojnm[0],/ADD_REPLACE
  ;; => copy accumulation times array with new tag
  str_element,temp,'DT',tacc,/ADD_REPLACE
  ;; => create an array of dead times
  deadtime = REPLICATE(temp[0].DEAD[0],szd)
  str_element,temp,'DEADTIME',deadtime,/ADD_REPLACE
  ;; => define new data structure element
  data[j]  = temp[0]
ENDFOR
;; => Redefine original input structures
dat = data
;;----------------------------------------------------------------------------------------
;; => Return
;;----------------------------------------------------------------------------------------

RETURN
END
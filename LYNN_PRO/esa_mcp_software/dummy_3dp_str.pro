;+
;*****************************************************************************************
;
;  FUNCTION :   dummy_3dp_str.pro
;  PURPOSE  :   Returns a dummy structure appropriate for replicating and preventing
;                 conflicting data structure errors.
;
;  CALLED BY: 
;               get_3dp_structs.pro
;
;  CALLS:
;               dat_3dp_str_names.pro
;               dummy_eesa_sst_struct.pro
;               dummy_pesa_struct.pro
;
;  REQUIRES:    NA
;
;  INPUT:
;               NAME   : [string] Specify the type of structure you wish to 
;                          get the data for [i.e. 'el','eh','elb',etc.]
;
;  EXAMPLES:
;               dubm = my_dummy_str('elb')
;
;  KEYWORDS:  
;               INDEX  :  [long] Array of indicies associated w/ data structs
;
;   CHANGED:  1)  Added the keyword INDEX                 [08/18/2008   v1.0.5]
;             2)  Updated man page                        [03/18/2009   v1.0.6]
;             3)  Changed program my_str_names.pro to dat_3dp_str_names.pro
;                   and renamed                           [08/10/2009   v2.0.0]
;
;   CREATED:  06/16/2008
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  08/10/2009   v2.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION dummy_3dp_str,name,INDEX=index

;-----------------------------------------------------------------------------------------
; -Determine Str. Name
;-----------------------------------------------------------------------------------------
gname = dat_3dp_str_names(name)
myn   = gname.LC
chnn  = STRCOMPRESS(STRLOWCASE(myn),/REMOVE_ALL)
check = [STRPOS(chnn,'eesa'),STRPOS(chnn,'ssto'),STRPOS(chnn,'sstf'),$
         STRPOS(chnn,'pesa')]
gche  = WHERE(check NE -1,gch)
mysn  = gname.SN
;-----------------------------------------------------------------------------------------
; => Get dummy data structure
;-----------------------------------------------------------------------------------------
IF (gch GT 0) THEN BEGIN
  IF (gche[0] LE 2) THEN BEGIN
    dumb = dummy_eesa_sst_struct(mysn)
  ENDIF ELSE BEGIN
    dumb = dummy_pesa_struct(mysn,INDEX=index)
  ENDELSE
ENDIF ELSE BEGIN
  MESSAGE,'Incorrect input format:  '+name,/INFORMATIONAL,/CONTINUE
  RETURN,name
ENDELSE

RETURN,dumb
END

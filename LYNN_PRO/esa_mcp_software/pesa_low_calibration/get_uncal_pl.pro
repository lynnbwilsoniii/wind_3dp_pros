;+
;*****************************************************************************************
;
;  FUNCTION :   get_uncal_pl.pro
;  PURPOSE  :   Gets PESA Low moments that have not been calibrated.
;
;  CALLED BY:   
;               cal_pl_mcp_eff.pro
;
;  CALLS:
;               get_pl_cal.pro
;               gettime.pro
;               dummy_3dp_str.pro
;               str_element.pro
;
;  REQUIRES:    
;               1)  External Windlib libraries
;               2)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               NA
;
;  EXAMPLES:    
;               NA
;
;  KEYWORDS:    
;               TRANGE  :  [Double] 2 element array specifying the range over 
;                            which to get data structures [Unix time]
;
;   CHANGED:  1)  NA [MM/DD/YYYY   v1.0.0]
;
;   NOTES:      
;               1)  User should not call this routine
;
;   CREATED:  06/08/2011
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  06/08/2011   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION get_uncal_pl,TRANGE=trange

;-----------------------------------------------------------------------------------------
; => Determine if any data is available
;-----------------------------------------------------------------------------------------
myto  = get_pl_cal(/TIMES)              ; => Str. moment times
gmto  = WHERE(FINITE(myto) AND myto GT 0,gmt)
IF (gmt GT 0) THEN BEGIN
  myto = myto[gmto]
ENDIF ELSE BEGIN
  MESSAGE,'No data is loaded...',/INFORMATIONAL,/CONTINUE
  RETURN,0
ENDELSE

;IF ~KEYWORD_SET(trange) THEN tra = [MIN(myto,/NAN),MAX(myto,/NAN)] ELSE tra = trange
IF KEYWORD_SET(trange) THEN BEGIN
  IF (N_ELEMENTS(trange) GT 2) THEN trange = [MIN(myto,/NAN),MAX(myto,/NAN)]
  bad_tr    = WHERE(myto GE trange[0] AND myto LE trange[1],bdtr)
  IF (bdtr EQ 0) THEN BEGIN
    badtrmssg = 'There are no valid '+myn+' structures in that time range!'
    MESSAGE,badtrmssg,/INFORMATIONAL,/CONTINUE
    RETURN,0
  ENDIF
  ;---------------------------------------------------------------------------------------
  ; -get range of index values for calling the get_??.pro routines
  ;---------------------------------------------------------------------------------------
  irange = LONG(interp(FINDGEN(gmt),myto,gettime(trange)))
  irange = (irange < (gmt - 1L)) > 0
  irange = [MIN(irange,/NAN),MAX(irange,/NAN)]
  istart = irange[0]
  ;---------------------------------------------------------------------------------------
  ; -make sure structure times don't over reach time range
  ;---------------------------------------------------------------------------------------
  trch   = MIN(trange,/NAN) - MIN(myto[istart:irange[1]],/NAN)
  IF (trch GT 0d0) THEN BEGIN
    TRUE      = 1
    FALSE     = 0
    searching = TRUE
    cc        = istart
    WHILE(searching) DO BEGIN
      trch   = MIN(trange,/NAN) - myto[cc]
      IF (trch GT 0d0 AND ABS(trch) GT 2.5d0) THEN BEGIN
;      IF (trch GT 0d0 AND ABS(trch) GT 2.5d0 AND cc LT gmt - 1L) THEN BEGIN
        searching = TRUE
        cc += 1L
      ENDIF ELSE BEGIN
        searching = FALSE
      ENDELSE
    ENDWHILE
    istart = cc
    myto   = myto[istart:irange[1]]
  ENDIF ELSE BEGIN
    myto = myto[istart:irange[1]]
  ENDELSE
  gmt    = N_ELEMENTS(myto)
  idx    = LINDGEN(gmt) + istart
  myopt  = LONG([2,47,0])
ENDIF ELSE BEGIN
  istart = 0L
  irange = [istart,N_ELEMENTS(myto) - 1L]
  idx    = LINDGEN(gmt) + istart
  myopt  = LONG([2,-1,0])
ENDELSE
;-----------------------------------------------------------------------------------------
; => Test structure for CHARGE tag name
;-----------------------------------------------------------------------------------------
test_tag = CALL_FUNCTION('get_pl_cal',INDEX=idx[0])
tags_tt  = TAG_NAMES(test_tag)
gtags    = WHERE(STRLOWCASE(tags_tt) EQ 'charge',gtg)
IF (gtg GT 0) THEN log_ch = 1 ELSE log_ch = 0
;-----------------------------------------------------------------------------------------
; => Get dummy structure for replicating
;-----------------------------------------------------------------------------------------
dumb     = dummy_3dp_str('pl',INDEX=idx)
mypts    = N_ELEMENTS(myto)
mvi      = INTARR(mypts)
;-----------------------------------------------------------------------------------------
; => Get PESA Low structures
;-----------------------------------------------------------------------------------------
etemp    = dumb
str_element,etemp,'COUNTS',etemp.data,/ADD_REPLACE
str_element,etemp,'MAGF',REPLICATE(!VALUES.F_NAN,3),/ADD_REPLACE
str_element,etemp,'VSW',REPLICATE(!VALUES.F_NAN,3),/ADD_REPLACE
str_element,etemp,'SC_POT',!VALUES.F_NAN,/ADD_REPLACE
IF (log_ch) THEN str_element,etemp,'CHARGE',charge,/ADD_REPLACE

pl_all   = REPLICATE(etemp,mypts)
FOR k=0L, mypts - 1L DO BEGIN
  tth = CALL_FUNCTION('get_pl_cal',INDEX=idx[k])
  IF NOT tth.valid THEN BEGIN
    tth = etemp
  ENDIF
  str_element,tth,'COUNTS',tth.data,/ADD_REPLACE
  str_element,tth,'MAGF',REPLICATE(!VALUES.F_NAN,3),/ADD_REPLACE
  str_element,tth,'VSW',REPLICATE(!VALUES.F_NAN,3),/ADD_REPLACE
  str_element,tth,'SC_POT',!VALUES.F_NAN,/ADD_REPLACE
  IF (log_ch) THEN str_element,tth,'CHARGE',1,/ADD_REPLACE
  pl_all[k] = tth[0]
ENDFOR
;-----------------------------------------------------------------------------------------
; => Keep only valid PESA Low structures
;-----------------------------------------------------------------------------------------
good = WHERE(pl_all.VALID,gd)
IF (gd GT 0) THEN pl_all = pl_all[good] ELSE pl_all = 0

RETURN,pl_all
END


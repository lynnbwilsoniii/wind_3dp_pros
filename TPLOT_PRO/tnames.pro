;+
;*****************************************************************************************
;
;  FUNCTION :   tnames.pro
;  PURPOSE  :   Returns an array of "TPLOT" names specified by the input filters.  
;                 This routine accepts wildcard characters.
;
;  CALLED BY:   
;               NA
;
;  CALLS:
;               tplot_com.pro
;               str_element.pro
;               strfilter.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               S            :  Can be any of the following inputs
;                                 1)  Scalar match string (e.g. '*B3*') used by
;                                       STRMATCH.PRO etc.
;                                 2)  [N]-Element string array of TPLOT handles
;                                 3)  [N]-Element integer/long array of TPLOT numbers
;               N            :  Scalar defining the number of matched strings
;
;  EXAMPLES:    
;               ; => To get all the TPLOT handles associated with wi_*, do the following:
;               nam = tnames('wi_*')
;
;  KEYWORDS:    
;               INDEX        :  Set to a named variable to return the indices of the
;                                 TPLOT names desired/returned
;               ALL          :  If set, all TPLOT names are returned
;               TPLOT        :  If set, all TPLOT names are returned
;               CREATE_TIME  :  Set to a named variable to return the times in which
;                                 the TPLOT variables were created
;               TRANGE       :  Set to a named variable to return the time ranges
;                                 of the TPLOT variables in question
;               DTYPE        :  Set to a named variable to return the data types of
;                                 the TPLOT variables in question
;               DATAQUANTS   :  If set, then the entire array of current stored TPLOT 
;                                 data quantities is returned
;
;   CHANGED:  1)  Davin Larson changed something...                [11/01/2002   v1.0.8]
;             2)  Re-wrote and cleaned up                          [08/16/2009   v1.1.0]
;             3)  Fixed a typo in man page                         [08/19/2009   v1.1.1]
;             4)  THEMIS software update includes:
;                 a)  Altered syntax with TPLOT keyword handling
;                 b)  Forced ind to be a scalar if only 1 element
;                 c)  Added keyword:  DATAQUANTS
;                                                                  [09/08/2009   v1.2.0]
;             5)  Cleaned up a little and added some comments      [08/04/2011   v1.2.1]
;
;   NOTES:      
;               
;
;   CREATED:  Feb 1999
;   CREATED BY:  Davin Larson
;    LAST MODIFIED:  08/04/2011   v1.2.1
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION tnames,s,n,INDEX=ind,ALL=all,TPLOT=tplot,CREATE_TIME=create_time, $
                    TRANGE=trange,DTYPE=dtype,DATAQUANTS=dataquants

;-----------------------------------------------------------------------------------------
; => Load common blocks
;-----------------------------------------------------------------------------------------
@tplot_com
;-----------------------------------------------------------------------------------------
; => Check keywords
;-----------------------------------------------------------------------------------------
IF KEYWORD_SET(tplot) THEN BEGIN
   s   = ''
   str_element,tplot_vars,'SETTINGS.VARNAMES',s
;   s   = tplot_vars.SETTINGS.VARNAMES
   all = 1
ENDIF

ndq = N_ELEMENTS(data_quants) - 1L
n   = 0
ind = 0

IF (ndq GT 0) THEN BEGIN
  ;---------------------------------------------------------------------------------------
  ; => Data found
  ;   => Define parameters
  ;---------------------------------------------------------------------------------------
  names = data_quants.NAME
  styp  = SIZE(s,/TYPE)
  sdim  = SIZE(s,/N_DIMENSIONS)
  IF (styp EQ 0L) THEN s = '*'  ; return all names
  styp  = SIZE(s,/TYPE)
  CASE styp[0] OF
    7L   : BEGIN
      ; => String input
      IF (sdim EQ 0) THEN sa = STRSPLIT(s,' ',/EXTRACT) ELSE sa = s
      IF (NOT KEYWORD_SET(all)) THEN BEGIN
        ind = strfilter(names[1:*],sa,COUNT=n,/INDEX) + 1L
      ENDIF ELSE BEGIN
        FOR i=0L, N_ELEMENTS(sa) - 1L DO BEGIN
          sel = strfilter(names[1:*],sa[i],/INDEX)
          IF (i EQ 0) THEN ind = sel ELSE ind = [ind,sel]  ; => LBW III  08/04/2011
;        ind = (i EQ 0) ? sel : [ind,sel]
        ENDFOR
        ind += 1L
        w    = WHERE(ind GT 0,n)
        IF (n NE 0) THEN BEGIN
          ; => good values found
          ind = ind[w]
        ENDIF ELSE BEGIN
          ; => no good values found
          ind = 0
        ENDELSE
      ENDELSE
    END
    ELSE : BEGIN
      IF (styp[0] LE 5L) THEN BEGIN
        ; => Number input
        i = ROUND(s)
        w = WHERE(i GE 1L AND i LE ndq,n)
        IF (n NE 0) THEN ind = i[w]
      ENDIF ELSE BEGIN
        ; => Unknown input
        RETURN,''
      ENDELSE
    END
  ENDCASE
ENDIF
;-----------------------------------------------------------------------------------------
; => Return
;-----------------------------------------------------------------------------------------
create_time = 0
trange      = 0
dtype       = 0
IF (n EQ 0) THEN RETURN, ''
IF (N_ELEMENTS(ind) EQ 1) THEN ind = ind[0]
create_time = data_quants[ind].CREATE_TIME
trange      = data_quants[ind].TRANGE
dtype       = data_quants[ind].DTYPE
IF KEYWORD_SET(dataquants) THEN RETURN, data_quants[ind]
RETURN,names[ind]
END
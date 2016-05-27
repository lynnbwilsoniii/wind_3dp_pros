;+
;*****************************************************************************************
;
;  FUNCTION :   my_ytitle_tplot.pro
;  PURPOSE  :   Determines what the appropriate Y-title should be from the given
;                 tplot name/index and added tags.  
;
;         Note:  **The program was designed for spectra data plots, so it may not
;                 work well for other types of tplot variables.**
;
;  CALLED BY: 
;
;  CALLS:
;               tnames.pro
;               get_data.pro
;
;  REQUIRES:    NA
;
;  INPUT:
;               NAME   : [string] Specify the TPLOT variable you wish to alter the
;                           YTITLE for
;
;  EXAMPLES:
;               yttl = my_ytitle_tplot('el_pads',TAG1='[Smoothed]')
;               yttl = my_ytitle_tplot('el_pads-2-0:1',TAG1='6.9-17.0!Uo!N')
;
;  KEYWORDS:  
;               TAG[N]  :  A string defined by user to be added to the previously
;                            defined ytitle, where N = 1, 2, 3, or 4
;               LOCTAG  :  A 4-element long array specifying the order in which
;                            the added labels {i.e. TAG[N]} should be added
;                            [0 = 1st thing in ytitle string, 1 = 2nd "", etc.]
;                            => IF NOT set, default = [0,1,2,3,4]
;
;   CHANGED:  1)  Fixed label issue     [08/18/2008   v1.0.7]
;             2)  Updated man page      [03/19/2009   v1.0.8]
;
;   CREATED:  06/21/2008
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  03/19/2009   v1.0.8
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION my_ytitle_tplot,name,TAG1=tag1,TAG2=tag2,TAG3=tag3,TAG4=tag4,$
                        LOCTAG=loctag

;*****************************************************************************************
; -See if TPLOT name exists and if so, get data and plot limit structures
;*****************************************************************************************
IF (SIZE(name,/TYPE) GT 1L AND SIZE(name,/TYPE) LT 8L) THEN BEGIN
  IF (SIZE(name,/TYPE) EQ 7L) THEN BEGIN
    get_data,name,DATA=d,DLIM=dlim,LIM=lim
  ENDIF ELSE BEGIN
    name = (tnames(ROUND(name)))[0]
    get_data,name,DATA=d,DLIM=dlim,LIM=lim
  ENDELSE
ENDIF ELSE BEGIN
  PRINT,'Incorrect name entry!'
  RETURN,name
ENDELSE
sname = STRMID(name,0,3)
;*****************************************************************************************
; -Check order of tags when making the new ytitle
;*****************************************************************************************
IF KEYWORD_SET(loctag) THEN BEGIN
  dimloc = SIZE(loctag,/DIMENSIONS)
  typloc = SIZE(loctag,/TYPE)
  nloc   = N_ELEMENTS(loctag)
  IF (nloc NE 5L OR dimloc NE 5L) THEN BEGIN
    PRINT,'Bad location tag definition!'
    PRINT,'Using default, loctag = [0L,1L,2L,3L,4L]'
    loctag = [0L,1L,2L,3L,4L]
  ENDIF ELSE BEGIN
    IF (typloc GT 1L AND typloc LT 6L) THEN BEGIN
      loctag = ROUND(loctag)
      badloc = WHERE(loctag LT 0L OR loctag GT 4L,bdlc)
      IF (bdlc GT 0) THEN BEGIN
        PRINT,'Using default, loctag = [0L,1L,2L,3L,4L]'
        loctag = [0L,1L,2L,3L,4L]
      ENDIF
    ENDIF ELSE BEGIN
      PRINT,'Using default, loctag = [0L,1L,2L,3L,4L]'
      loctag = [0L,1L,2L,3L,4L]
    ENDELSE
  ENDELSE
ENDIF ELSE BEGIN
  loctag = [0L,1L,2L,3L,4L]
ENDELSE
IF (KEYWORD_SET(tag1) AND SIZE(tag1,/TYPE) EQ 7) THEN ny1 = tag1 ELSE ny1 = ''
IF (KEYWORD_SET(tag2) AND SIZE(tag2,/TYPE) EQ 7) THEN ny2 = tag2 ELSE ny2 = ''
IF (KEYWORD_SET(tag3) AND SIZE(tag3,/TYPE) EQ 7) THEN ny3 = tag3 ELSE ny3 = ''
IF (KEYWORD_SET(tag4) AND SIZE(tag4,/TYPE) EQ 7) THEN ny4 = tag4 ELSE ny4 = ''

newyttd = ''
newyttl = ''
IF (SIZE(dlim,/TYPE) EQ 8L) THEN BEGIN
  dtags = TAG_NAMES(dlim)
  gdtgs = WHERE(dtags EQ 'YTITLE',gdt)
  IF (gdt GT 0) THEN BEGIN
    newyttd = dlim.(gdtgs[0])
    newyarr = [newyttd,ny1,ny2,ny3,ny4]
  ENDIF ELSE BEGIN
    newyttd = ''
  ENDELSE
ENDIF
IF (SIZE(lim,/TYPE) EQ 8L) THEN BEGIN
  ltags = TAG_NAMES(lim)
  gltgs = WHERE(ltags EQ 'YTITLE',glt)
  IF (glt GT 0) THEN BEGIN
    newyttl = lim.(gltgs[0])
    newyarr = [newyttl,ny1,ny2,ny3,ny4]
    newyarr = newyarr[loctag]
  ENDIF ELSE BEGIN
    newyttl = ''
  ENDELSE
ENDIF

gyttle = WHERE([newyttd,newyttl] NE '',gytt)
IF (gytt EQ 0) THEN BEGIN
  mtags = TAG_NAMES(d)
  gmtgs = WHERE(mtags EQ 'YTITLE',gmt)
  IF (gmt GT 0 AND newyttd EQ '' AND newyttl EQ '') THEN BEGIN
    stryttl = d.(gmtgs[0])
    newyarr = [stryttl,ny1,ny2,ny3,ny4]
    newyarr = newyarr[loctag]
    yttle   = newyarr[0]+newyarr[1]+newyarr[2]+newyarr[3]+newyarr[4]
  ENDIF ELSE BEGIN
    gflux = WHERE(mtags EQ 'V' OR mtags EQ 'V1',gfl)
    IF (gfl GT 0) THEN BEGIN
      yttle = sname+'!C'+'(#cm!U-2!Ns!U-1!Nsr!U-1!NeV!U-1!N)'
      RETURN,yttle
    ENDIF ELSE BEGIN
      yttle = sname
      RETURN,yttle
    ENDELSE
  ENDELSE
ENDIF ELSE BEGIN
  CASE gyttle[0] OF
    0 : yttle = newyarr[0]+newyarr[1]+newyarr[2]+newyarr[3]+newyarr[4]
    1 : yttle = newyarr[0]+newyarr[1]+newyarr[2]+newyarr[3]+newyarr[4]
    ELSE : BEGIN
      gflux = WHERE(mtags EQ 'V' OR mtags EQ 'V1',gfl)
      IF (gfl GT 0) THEN BEGIN
        yttle = sname+'!C'+'(#cm!U-2!Ns!U-1!Nsr!U-1!NeV!U-1!N)'
        RETURN,yttle
      ENDIF ELSE BEGIN
        yttle = sname
        RETURN,yttle
      ENDELSE
    END
  ENDCASE
ENDELSE
;*****************************************************************************************
; -Make sure we haven't produced multiples of words or the length of each 
;   line isn't too long
;*****************************************************************************************
yttlen    = STRLEN(yttle)
TRUE      = 1
FALSE     = 0
searching = TRUE
cc        = 0L
bb        = 0L
suby1     = yttle
posis     = REPLICATE(-1L,10)
posie     = REPLICATE(-1L,10)
posis[0]  = 0L
posie[0]  = 0L
WHILE(searching) DO BEGIN
  strch1    = STREGEX(suby1,'!C',LENGTH=len1,/FOLD_CASE)
  IF (strch1 GT 0) THEN searching = TRUE ELSE BREAK
  cc        = cc + 1L
  bb        = cc - 1L
  posis[cc] = posis[bb] + posie[bb]
  posie[cc] = posie[bb] + (strch1 + len1) > posie[bb]
  suby1     = STRMID(yttle,posie[cc])
ENDWHILE

CASE cc OF
  1 : BEGIN
    tlens      = LONARR(cc+1L) ; -string lengths of each tier in ytitle
    tlens[1]   = yttlen - posie[1]
    tlens[0]   = (posie[1] - posis[1]) - 2L
    substr     = STRARR(2) ; -strings for each tier
    FOR i=0L,cc DO substr[i] = STRTRIM(STRMID(yttle,posie[i],tlens[i]),2)
    sublen     = ABS([tlens[0],tlens[1]])
    tooshort   = WHERE(sublen LT MAX(tlens,/NAN),tsho)
    CASE tooshort[0] OF
      0 : yttle = substr[1]+'!C'+substr[0]
      1 : yttle = substr[0]+'!C'+substr[1]
      ELSE : yttle = yttle
    ENDCASE
  END  
  2 : BEGIN
    tlens      = LONARR(cc+1L) ; -string lengths of each tier in ytitle
    tlens[2]   = yttlen - posie[2]
    tlens[0:1] = (posie[1:2] - posis[1:2]) - 2L
    substr     = STRARR(3) ; -strings for each tier
    FOR i=0L,cc DO substr[i] = STRTRIM(STRMID(yttle,posie[i],tlens[i]),2)
    sublen     = ABS([(tlens[2]+tlens[1]),(tlens[2]+tlens[0]),(tlens[1]+tlens[0])])
    tooshort   = WHERE(sublen LT MAX(tlens,/NAN),tsho)
    CASE tooshort[0] OF
      0 : yttle = substr[0]+'!C'+substr[1]+' '+substr[2]
      1 : yttle = substr[0]+' '+substr[2]+'!C'+substr[1]
      2 : yttle = substr[0]+' '+substr[1]+'!C'+substr[2]
      ELSE : yttle = yttle
    ENDCASE
  END
  ELSE : yttle = yttle
ENDCASE
;*****************************************************************************************
;fluxch   = STREGEX(substr,'flux',/EXTRACT,/FOLD_CASE)
;snamch   = STREGEX(substr,sname,/EXTRACT,/FOLD_CASE)
;nflch    = N_ELEMENTS(fluxch)
;nsnch    = N_ELEMENTS(snamch)
;IF (nflch GT 1L) THEN BEGIN
;ENDIF
;IF (nsnch GT 1L) THEN BEGIN
;ENDIF
;stop
;*****************************************************************************************
RETURN,yttle
END

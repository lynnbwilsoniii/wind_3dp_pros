;+
;*****************************************************************************************
;
;  FUNCTION :   pesa_low_data_ramp_adjust.pro
;  PURPOSE  :   Due to the low time resolution of the Wind 3DP particle detector, the
;                 first value downstream of a shock (or other sharp gradient) can be
;                 up to slightly less than 3 seconds after the actual gradient.  This
;                 routine adds an extra data point that corresponds to the first
;                 downstream data point but at a time immediately following the
;                 gradient.  It also allows for adding an extra value immediately
;                 upstream if no burst data is available.
;
;  CALLED BY:   
;               NA
;
;  CALLS:
;               tnames.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               TIME       :  Scalar Unix time used as the abscissa value for new data
;                               value added immediately following a sharp change in
;                               background parameters
;               TPLOT_N    :  [N]-Element array of TPLOT Handles (string or indices)
;
;  EXAMPLES:    
;               
;
;  KEYWORDS:    
;               NEW_NAMES  :  Scalar suffix to apply to the new TPLOT names after
;                               adding the extra point
;               ADD_UP     :  If set, program adds an extra value immediately upstream
;                               of the shock ramp
;
;   CHANGED:  1)  NA [MM/DD/YYYY   v1.0.0]
;
;   NOTES:      
;               1)  This routine will result in an irreversible change to the desired
;                     TPLOT variables if NEW_NAMES keyword is not used
;
;   CREATED:  08/16/2011
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  08/16/2011   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

PRO pesa_low_data_ramp_adjust,time,tplot_n,NEW_NAMES=new_suffx,ADD_UP=add_up

;-----------------------------------------------------------------------------------------
; => Check input
;-----------------------------------------------------------------------------------------
tp_nm = tnames(tplot_n)
IF (tp_nm[0] EQ '') THEN RETURN
tramp = time_double(time[0])
;-----------------------------------------------------------------------------------------
; => Check keywords
;-----------------------------------------------------------------------------------------
IF KEYWORD_SET(new_suffx) THEN BEGIN
  IF (SIZE(new_suffx[0],/TYPE) NE 7) THEN nsuff = '' ELSE nsuff = new_suffx[0]
ENDIF ELSE BEGIN
  nsuff = ''
ENDELSE


;-----------------------------------------------------------------------------------------
; => Get data and add extra value
;-----------------------------------------------------------------------------------------
ntp   = N_ELEMENTS(tp_nm)
FOR i=0L, ntp - 1L DO BEGIN
  get_data,tp_nm[i],DATA=test,DLIMITS=dlim0,LIMITS=lim0
  good  = WHERE(test.X GT tramp[0],gd)
  goodu = WHERE(test.X LT tramp[0],gdu)
  ; => create new structure with same format as the old one
  extract_tags,testn,test
  IF (gd GT 0) THEN BEGIN
    ;-------------------------------------------------------------------------------------
    ; => Add extra values at time TRAMP
    ;-------------------------------------------------------------------------------------
    ntimes = test.X
    ndata  = test.Y
    IF (KEYWORD_SET(add_up) AND gdu GT 0) THEN BEGIN
      ; => add upstream point
      nts    = [ntimes,tramp[0]-1d-2,tramp[0]+1d-2]
    ENDIF ELSE BEGIN
      ; => no upstream point
      nts    = [ntimes,tramp[0]+1d-2]
    ENDELSE
    ndim   = SIZE(ndata,/N_DIMENSIONS)
    sp     = SORT(nts)
    nts    = nts[sp]
    CASE ndim[0] OF
      1    : BEGIN
        ; => 1D Array
        IF (KEYWORD_SET(add_up) AND gdu GT 0) THEN BEGIN
          ; => add upstream point
          nds = [ndata,ndata[goodu[0]],ndata[good[0]]]
        ENDIF ELSE BEGIN
          ; => no upstream point
          nds = [ndata,ndata[good[0]]]
        ENDELSE
        nds = nds[sp]
      END
      2    : BEGIN
        ; => 2D Array
        IF (KEYWORD_SET(add_up) AND gdu GT 0) THEN BEGIN
          ; => add upstream point
          nds = [ndata,ndata[goodu[0],*],ndata[good[0],*]]
        ENDIF ELSE BEGIN
          ; => no upstream point
          nds = [ndata,ndata[good[0],*]]
        ENDELSE
        nds = nds[sp,*]
      END
      3    : BEGIN
        ; => 3D Array
        IF (KEYWORD_SET(add_up) AND gdu GT 0) THEN BEGIN
          ; => add upstream point
          nds = [ndata,ndata[goodu[0],*,*],ndata[good[0],*,*]]
        ENDIF ELSE BEGIN
          ; => no upstream point
          nds = [ndata,ndata[good[0],*,*]]
        ENDELSE
        nds = nds[sp,*,*]
      END
      ELSE : BEGIN
        ; => Use original values
        nts = ntimes
        nds = ndata
      END
    ENDCASE
    ; => Replace times and data quantities
    str_element,testn,'X',nts,/ADD_REPLACE
    str_element,testn,'Y',nds,/ADD_REPLACE
    ; => Send new data back to TPLOT possibly with new name
    store_data,tp_nm[i]+nsuff[0],DATA=testn,DLIMITS=dlim0,LIMITS=lim0
  ENDIF ELSE BEGIN
    ;-------------------------------------------------------------------------------------
    ; => Do not add extra values after time TRAMP
    ;-------------------------------------------------------------------------------------
    IF (KEYWORD_SET(add_up) AND gdu GT 0) THEN BEGIN
      ; => Add point prior to ramp
      ntimes = test.X
      ndata  = test.Y
      ndim   = SIZE(ndata,/N_DIMENSIONS)
      nts    = [ntimes,tramp[0]-1d-2]
      sp     = SORT(nts)
      nts    = nts[sp]
      IF (ndim[0] EQ 1) THEN BEGIN
        ; => 1D Array
        nds = [ndata,ndata[goodu[0]]]
        nds = nds[sp]
      ENDIF ELSE BEGIN
        IF (ndim[0] EQ 2) THEN BEGIN
          ; => 2D Array
          nds = [ndata,ndata[goodu[0],*]]
          nds = nds[sp,*]
        ENDIF ELSE BEGIN
          IF (ndim[0] EQ 3) THEN BEGIN
            ; => 3D Array
            nds = [ndata,ndata[goodu[0],*,*]]
            nds = nds[sp,*,*]
          ENDIF ELSE BEGIN
            nts = ntimes
            nds = ndata
          ENDELSE
        ENDELSE
      ENDELSE
    ENDIF ELSE BEGIN
      ; => Do nothing
      nts = ntimes
      nds = ndata
    ENDELSE
    ; => Replace times and data quantities
    str_element,testn,'X',nts,/ADD_REPLACE
    str_element,testn,'Y',nds,/ADD_REPLACE
    ; => Send new data back to TPLOT possibly with new name
    store_data,tp_nm[i]+nsuff[0],DATA=testn,DLIMITS=dlim0,LIMITS=lim0
  ENDELSE
  ;---------------------------------------------------------------------------------------
  ; => Reset variables
  ;---------------------------------------------------------------------------------------
  test   = 0
  testn  = 0
  dlim0  = 0
  lim0   = 0
ENDFOR
;-----------------------------------------------------------------------------------------
; => Return
;-----------------------------------------------------------------------------------------

RETURN
END
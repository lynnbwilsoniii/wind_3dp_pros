;+
;*****************************************************************************************
;
;  FUNCTION :   plot_freq_ticks.pro
;  PURPOSE  :   Creates a power spectrum plot structure specifically for 
;                 plot_vector_mv_data.pro.
;
;  CALLED BY: 
;               plot_vector_mv_data.pro
;
;  CALLS:       
;               NA
;
;  REQUIRES:    
;               NA
;
;  INPUT:
;               FRA   :  2-Element array w/ values 0.0001 < vals < 1000000.0
;
;  EXAMPLES:    
;               NA
;
;  KEYWORDS:    
;               XLOG  :  Same usage as for PLOT.PRO etc.
;
;   CHANGED:  1)  Changed tick marks to account for higher frequencies 
;                                                                  [06/08/2009   v1.1.0]
;             2)  Updated man page
;                   and renamed from my_plot_mv_htr_tick.pro       [08/12/2009   v2.0.0]
;             3)  Increased resolution of tick marks for better output and added
;                   keyword:  XLOG
;                                                                  [09/22/2010   v2.1.0]
;
;   CREATED:  12/30/2008
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  09/22/2010   v2.1.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION plot_freq_ticks,fra,XLOG=xlog

;-----------------------------------------------------------------------------------------
; -Define some freq. tick values/names
;-----------------------------------------------------------------------------------------
ftick_nl = ['0.0001','0.001','0.01','0.1','0.2','0.5','1.0','2.0','5.0',    $
            '10.0','20.0','50.0','100.0','200.0','500.0','1000.0']
ftick_vl = [1e-4,1e-3,1e-2,1e-1,2e-1,5e-1,1e0,2e0,5e0,1e1,2e1,5e1,1e2,      $
            2e2,5e2,1e3]

ftick_n0 = ['0.0001','0.001','0.01','0.1','0.2','0.5','1.0','2.0','5.0',    $
            '10.0','20.0','30.0','40.0','50.0','60.0','70.0','80.0','90.0', $
            '100.0','200.0','300.0','400.0','500.0','600.0','700.0','800.0',$
            '900.0','1000.0']
ftick_v0 = [1e-4,1e-3,1e-2,1e-1,2e-1,5e-1,1e0,2e0,5e0,1e1,2e1,3e1,4e1,5e1,$
            6e1,7e1,8e1,9e1,1e2,2e2,3e2,4e2,5e2,6e2,7e2,8e2,9e2,1e3]
n_fvn    = N_ELEMENTS(ftick_n0)
;-----------------------------------------------------------------------------------------
; -Determine range if high frequency then skip to end
;-----------------------------------------------------------------------------------------
freqyra = fra
IF (freqyra[1] GE 1e3) THEN BEGIN
  ftick_v = [1e-4,1e-3,1e-2,1e-1,1e0,1e1,1e2,1e3,1e4,1e5,1e6]
  ftick_n = ['0.0001','0.001','0.01','0.1','1.0','10.0',$
             '100.0','1000.0','10000.0','100000.0','1000000.0']
  n_fvn   = N_ELEMENTS(ftick_n)
  lftv    = WHERE(ftick_v LE freqyra[0],lfv)
  hftv    = WHERE(ftick_v LE freqyra[1],hfv)
  IF (lfv GT 0L AND hfv GT 0L) THEN BEGIN
    ftick_s  = MAX(hftv,/NAN) - MAX(lftv,/NAN) + 1L
    test_up  = freqyra[1]/(ftick_v[MAX(hftv,/NAN)])*1d2 GT 9d1
    test_dn  = freqyra[0]/(ftick_v[MAX(lftv,/NAN)])*1d2 GT 1d2
    IF (test_up) THEN hfel = MAX(hftv,/NAN) + 1L ELSE hfel = MAX(hftv,/NAN)
    IF (test_dn) THEN lfel = MAX(lftv,/NAN) + 1L ELSE lfel = MAX(lftv,/NAN)
    hfel = hfel[0] > lfel[0]
    lfel = lfel[0] < hfel[0]
    IF (hfel EQ lfel) THEN BEGIN
      lfel -= 1
      hfel += 1
    ENDIF
    mftick_n = ftick_n[lfel:hfel]
    mftick_v = ftick_v[lfel:hfel]
    IF ~KEYWORD_SET(xlog) THEN BEGIN
      x_log    = 1L
      x_min    = 9L
    ENDIF ELSE BEGIN
      x_log    = xlog[0]
      IF (x_log EQ 1) THEN x_min = 9L ELSE x_min = 5L
    ENDELSE
    GOTO,JUMP_SKIP
  ENDIF ELSE BEGIN
    IF (hfv GT 0L AND hftv[0] GT 0L) THEN garr = [hftv[0] - 1L,hftv[0]]
    IF (lfv GT 0L AND lftv[0] LT n_fvn - 1L) THEN garr = [lftv[0],lftv[0] + 1L]
    g_arr = WHERE(garr GE 0L,g_a)
    IF (g_a GT 0L) THEN BEGIN
      mftick_n = ftick_n[garr]
      mftick_v = ftick_v[garr]
      IF ~KEYWORD_SET(xlog) THEN BEGIN
        x_log    = 1L
        x_min    = 9L
      ENDIF ELSE BEGIN
        x_log    = xlog[0]
        IF (x_log EQ 1) THEN x_min = 9L ELSE x_min = 5L
      ENDELSE
      GOTO,JUMP_SKIP
    ENDIF
  ENDELSE
ENDIF
;-----------------------------------------------------------------------------------------
; -Determine range for lower frequencies
;-----------------------------------------------------------------------------------------
ltickv  = ABS(ALOG10(MIN(freqyra,/NAN)))
htickv  = ABS(ALOG10(MAX(freqyra,/NAN)))
v_range = (MAX(freqyra,/NAN) - MIN(freqyra,/NAN))*1d-1 LE 1d0  ; -xrange < decade
v_ra10  = LONG(ABS(htickv - ltickv))
CASE v_ra10 OF
  0    :  BEGIN
    ; => X-range < 1 decade
    IF ~KEYWORD_SET(xlog) THEN BEGIN
      x_log    = 0L
      x_min    = 5L
    ENDIF ELSE BEGIN
      x_log    = xlog[0]
      IF (x_log EQ 1) THEN x_min = 9L ELSE x_min = 5L
    ENDELSE
  END
  ELSE :  BEGIN
    IF ~KEYWORD_SET(xlog) THEN BEGIN
      x_log    = 0L
      x_min    = 5L
    ENDIF ELSE BEGIN
      x_log    = xlog[0]
      IF (x_log EQ 1) THEN x_min = 9L ELSE x_min = 5L
    ENDELSE
    ; => X-range > 1 decade
    IF (v_ra10 LT 2L) THEN BEGIN
      ; => X-range < 2 decades
      x_log = x_log
      x_min = x_min
    ENDIF ELSE BEGIN
      ; => X-range > 2 decades
      ;   => Force to Log-Scale
      x_log = 1L
      x_min = 9L
    ENDELSE
  END
ENDCASE

CASE x_log OF
  0    :  BEGIN
    ; => Use tick marks appropriate for Linear scale
    ftick_v  = ftick_v0
    ftick_n  = ftick_n0
  END
  ELSE :  BEGIN
    ; => Use tick marks appropriate for Log scale
    ftick_v  = ftick_vl
    ftick_n  = ftick_nl
  END
ENDCASE


lftv    = WHERE(ftick_v LE freqyra[0],lfv)
hftv    = WHERE(ftick_v LE freqyra[1],hfv)
IF (lfv GT 0L AND hfv GT 0L) THEN BEGIN
  ftick_s  = MAX(hftv,/NAN) - MAX(lftv,/NAN) + 1L
  mftick_n = ftick_n[MAX(lftv,/NAN):MAX(hftv,/NAN)]
  mftick_v = ftick_v[MAX(lftv,/NAN):MAX(hftv,/NAN)]
ENDIF ELSE BEGIN
  IF (hfv GT 0L) THEN BEGIN
    lftv     = 0L
    mftick_n = ftick_n[hftv]
    mftick_v = ftick_v[hftv]
    IF (freqyra[0] LT 9e-4) THEN freqyra[0] = 9.9e-4
  ENDIF ELSE BEGIN
    lftv     = 0L
    hftv     = LINDGEN(n_fvn)
    mftick_n = ftick_n
    mftick_v = ftick_v
  ENDELSE
ENDELSE

test_floor = MAX(lftv,/NAN) - 1L
test_ceil  = n_fvn - MAX(hftv,/NAN)
;-----------------------------------------------------------------------------------------
; -Force to be on proper scale
;-----------------------------------------------------------------------------------------
test_nu  = (MAX(hftv,/NAN) - MAX(lftv,/NAN))/3L LT 1L
test_ra  = MAX(lftv,/NAN) GE (MAX(hftv,/NAN) - 1L)

test_L = MAX(lftv,/NAN) GE 1L
test_H = test_ceil GT test_floor
testLH = WHERE([test_L,test_H] GT 0L, tLH)
IF (test_ra) THEN BEGIN  ; -mftick_s = 0 or 1
  IF (tLH GT 1L) THEN BEGIN ; -add extra to high end
    IF (test_nu AND test_ceil GT 1L) THEN BEGIN  ; -add 2 extra to high end
      mftick_n = ftick_n[MAX(lftv,/NAN):MAX(hftv+2L,/NAN)]
      mftick_v = ftick_v[MAX(lftv,/NAN):MAX(hftv+2L,/NAN)]
    ENDIF ELSE BEGIN
      IF (test_nu) THEN BEGIN ; -add extra to low end
        mftick_n = ftick_n[MAX(lftv-1L,/NAN):MAX(hftv,/NAN)]
        mftick_v = ftick_v[MAX(lftv-1L,/NAN):MAX(hftv,/NAN)]
      ENDIF
    ENDELSE
  ENDIF ELSE BEGIN
    CASE testLH[0] OF
      0    :  BEGIN ; -add extra to low end
        mftick_n = ftick_n[MAX(lftv-1L,/NAN):MAX(hftv,/NAN)]
        mftick_v = ftick_v[MAX(lftv-1L,/NAN):MAX(hftv,/NAN)]
      END
      1    :  BEGIN ; -add extra to high end [lftv = 0]
        mftick_n = ftick_n[MAX(lftv,/NAN):MAX(hftv+1L,/NAN)]
        mftick_v = ftick_v[MAX(lftv,/NAN):MAX(hftv+1L,/NAN)]
      END
      ELSE :  BEGIN ; [lftv = 0, and MAX(hftv,/NAN) = n_fvn]
        mftick_n = ftick_n
        mftick_v = ftick_v
      END
    ENDCASE
  ENDELSE
ENDIF ELSE BEGIN
  IF (test_nu) THEN BEGIN  ; -add extra
    IF (test_ceil GE 1L) THEN BEGIN  ; -add 1 extra to high end
      mftick_n = ftick_n[MAX(lftv,/NAN):MAX(hftv+1L,/NAN)]
      mftick_v = ftick_v[MAX(lftv,/NAN):MAX(hftv+1L,/NAN)]
      
    ENDIF ELSE BEGIN ; -add extra to low end
      mftick_n = ftick_n[MAX(lftv-1L,/NAN):MAX(hftv,/NAN)]
      mftick_v = ftick_v[MAX(lftv-1L,/NAN):MAX(hftv,/NAN)]
    ENDELSE
  ENDIF ELSE BEGIN
    mftick_n = mftick_n
    mftick_v = mftick_v
  ENDELSE
ENDELSE
;=========================================================================================
JUMP_SKIP:
;=========================================================================================
freqyra  = [MIN(mftick_v)/1.05,MAX(mftick_v)*1.05]
mftick_s = N_ELEMENTS(mftick_n) - 1L
;*****************************************************************************************
; 
;*****************************************************************************************
p_str = CREATE_STRUCT('XMINOR',x_min,'XLOG',x_log,'XTICKNAME',mftick_n,'XTICKS',mftick_s,$
                      'XTICKV',mftick_v,'XSTYLE',1,'YSTYLE',1,'XRANGE',freqyra);,'',,)

RETURN,p_str
END
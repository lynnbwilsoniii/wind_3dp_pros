;+
;*****************************************************************************************
;
;  FUNCTION :   fft_movie_plot.pro
;  PURPOSE  :   Plots the FFT snapshots of the input time series for fft_movie.pro
;
;  CALLED BY:   
;               fft_movie.pro
;
;  CALLS:
;               fft_movie_psd.pro
;               my_windowf.pro
;               power_of_2.pro
;               vector_bandpass.pro
;               extract_tags.pro
;               str_element.pro
;               tplot_struct_format_test.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               TIME        :  N-Element array of times [seconds]
;               DATA        :  N-Element array of data [units]
;               WLEN        :  Scalar defining the # of elements to use in each
;                                snapshot/(time window) of the shifting FFT
;               WSHIFT      :  Scalar defining the # points to shift the 
;                                snapshot/(time window) after each FFT is calculated
;
;  EXAMPLES:    
;               NA
;
;  KEYWORDS:    
;               MOVIENAME   :  Scalar string defining the name of the movie created
;                                by the program
;               SCREEN      :  If set, program plots snapshots to X-Window display,
;                                otherwise movies are generated from PNG captures 
;                                of Z buffer plots
;               FULLSERIES  :  If set, program creates plots of full time series
;                                range instead of zoomed-in plots of time ranges
;               [XY]SIZE    :  Scalar values defining the size of the output windows
;                                Defaults:  
;                                          [800 x 600]     : if plotting to screen
;                                          [10.2" x 6.99"] : if plotting to PS files
;               FFT_ARRAY   :  Set to a named variable to return the windowed FFT
;               NO_INTERP   :  If set, data is not interpolated to save time when
;                                creating a movie
;               EX_FREQS    :  Structure with a TPLOT format containing:
;                          { X:([N]-Unix Times),Y:([N,M]-Element array of frequencies) }
;                                to overplot on the FFT power spectra
;                                [e.g. the cyclotron frequency]
;                                [IF N = 1, then use the same value for all windows]
;               EX_LABS     :  M-Element string array of labels for the frequency
;                                inputs given by the EX_FREQS keyword
;               FRANGE      :  2-Element float array defining the freq. range
;                                to use when plotting the power spec (Hz)
;                                [min, max]
;               PRANGE      :  2-Element float array defining the power spectrum
;                                Y-Axis range to use [min, max]
;               WSTRUCT     :  Set to a plot structure with relevant info for waveform
;                                plot [Used by PLOT.PRO with _EXTRA keyword]
;               FSTRUCT     :  Set to a plot structure with relevant info for power
;                                spectrum plot [Used by PLOT.PRO with _EXTRA keyword]
;               READ_WIN    :   If set, program uses windowing for FFT calculation
;               FORCE_N     :  Set to a scalar (best if power of 2) to force the program
;                                my_power_of_2.pro return an array with this desired
;                                number of elements [e.g.  FORCE_N = 2L^12]
;               IMAGE_DIR   :  Scalar string defining the directory path where plots
;                                will be stored.
;
;   CHANGED:  1)  NA [MM/DD/YYYY   v1.0.0]
;
;   NOTES:      
;               1)  This routine should not be called by user.
;
;  REFERENCES:  
;               1)  Paschmann, G. and P.W. Daly (1998), "Analysis Methods for Multi-
;                      Spacecraft Data," ISSI Scientific Report, Noordwijk, 
;                      The Netherlands., Int. Space Sci. Inst.
;
;   CREATED:  06/15/2011
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  06/15/2011   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

PRO fft_movie_plot,time,data,wlen,wshift,MOVIENAME=moviename,SCREEN=screen,   $
                   FULLSERIES=fullseries,XSIZE=xsize,YSIZE=ysize,FFT_ARRAY=fft_array, $
                   NO_INTERP=no_interp,EX_FREQS=ex_freqs,EX_LABS=ex_labs,             $
                   FRANGE=frange,PRANGE=prange,WSTRUCT=wstruct,FSTRUCT=fstruct,       $
                   READ_WIN=read_win,FORCE_N=force_n,IMAGE_DIR=imgdir

;-----------------------------------------------------------------------------------------
; => Define dummy variables
;-----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
;-----------------------------------------------------------------------------------------
;  ----SET UP THE PLOT WINDOW----
;-----------------------------------------------------------------------------------------
xyzp_win       = {X:!X,Y:!Y,Z:!Z,P:!P}

start_time     = SYSTIME(1)
!P.MULTI       = [0,1,2]
old_chars      = !P.CHARSIZE
; => Set color scale
SET_PLOT,'X'
;-----------------------------------------------------------------------------------------
; => Set up the window or Z buffer
;-----------------------------------------------------------------------------------------
IF KEYWORD_SET(fullseries) THEN BEGIN
  !P.MULTI = [0,1,2]
ENDIF ELSE BEGIN
  !P.MULTI = [0,2,1]
ENDELSE
;-----------------------------------------------------------------------------------------
;  ----DEFINE SOME USABLE COLORS----
;-----------------------------------------------------------------------------------------
; => Load current colors [*_orig] so they can be reset after done with routine
COMMON colors, r_orig, g_orig, b_orig, r_curr, g_curr, b_curr
r_orig0 = r_orig
g_orig0 = g_orig
b_orig0 = b_orig
;-----------------------------------------------------------------------------------------
; => plot to screen or z buffer (default)
;-----------------------------------------------------------------------------------------
IF KEYWORD_SET(screen) THEN BEGIN
  SET_PLOT,'X'
  !P.CHARSIZE = 0.8
  WINDOW,XSIZE=xsize,YSIZE=ysize
ENDIF ELSE BEGIN
  SET_PLOT,'Z'
  DEVICE,SET_PIXEL_DEPTH=24,SET_RESOLUTION=[xsize,ysize]
  !P.CHARSIZE  = 0.65
  !P.CHARTHICK = 1.2
ENDELSE
DEVICE,DECOMPOSED=0
LOADCT,39,/SILENT
;-----------------------------------------------------------------------------------------
; => Determine colors
;-----------------------------------------------------------------------------------------
IF ~KEYWORD_SET(screen) THEN BEGIN
  fcolor = 190
  fftcol = 220
  pcolor = 120
ENDIF ELSE BEGIN
  fcolor = 200
  fftcol = 220
  pcolor = 150
ENDELSE
;-----------------------------------------------------------------------------------------
; => Check input
;-----------------------------------------------------------------------------------------
np             = N_ELEMENTS(time)
npoints        = np[0]
nsteps         = (np[0] - wlen[0])/wshift[0]
; => timestep is the average delay time between data points
x              = LINDGEN(np - 1L)
y              = x + 1L
del_t          = time[y] - time[x]
timestep       = MEAN(del_t,/NAN)

;-----------------------------------------------------------------------------------------
; => Calculate power spectrum
;-----------------------------------------------------------------------------------------
psd_fft        = fft_movie_psd(time,data,wlen[0],wshift[0],READ_WIN=read_win,$
                               FORCE_N=force_n,FRANGE=frange,PRANGE=prange)
; => Define initial start/end elements
startpoint     = psd_fft.START_END_0[0]
endpoint       = psd_fft.START_END_0[1]
; => Define freqs [Hz] and power spectrum [units^2/Hz]
nfreqbins      = psd_fft.FREQS
subpower       = psd_fft.POWER_SPEC
; => Define freqs [Hz] and power spectrum [units^2/Hz] XY-Axes ranges
fra_0          = psd_fft.FRANGE
powra          = psd_fft.PRANGE
; => Return FFT_ARRAY keyword to user if set
fft_array      = subpower
;-----------------------------------------------------------------------------------------
; => set up the timeseries plot range
;-----------------------------------------------------------------------------------------
ymax          = MAX(ABS(data),/nan)
plotyrange    = [-1.1*ymax,1.1*ymax]
;-----------------------------------------------------------------------------------------
; => for the sake of speedy movie output, we're going to plot an interpolated
;     array when we're working with the full series
;-----------------------------------------------------------------------------------------
IF KEYWORD_SET(no_interp) THEN BEGIN
  scale      = 1
  small_time = time
  small_data = data
ENDIF ELSE BEGIN
  scale      = 10
  small_time = INTERPOL(time,npoints[0]/scale[0])
  small_data = INTERPOL(data,npoints[0]/scale[0])
ENDELSE
;-----------------------------------------------------------------------------------------
; => Plot structure for waveform
;-----------------------------------------------------------------------------------------
yttl  = 'Amplitude [units]'
xttl  = 'Time [s]'
wstr  = {YTITLE:yttl,XTITLE:xttl,XSTYLE:1,YSTYLE:1,NODATA:1,XMINOR:9}
extract_tags,wstr,wstruct
IF (TOTAL(TAG_NAMES(wstruct) EQ 'YRANGE',/NAN) EQ 0) THEN BEGIN
  str_element,wstr,'YRANGE',plotyrange,/ADD_REPLACE
ENDIF ELSE BEGIN
  plotyrange = wstruct.YRANGE
ENDELSE
; => Plot structure for power spectrum
yttl  = 'Wave Power [units!U2!N'+'/Hz]'
xttl  = 'Frequency [Hz]'
fstr  = {YRANGE:powra,YTITLE:yttl,XTITLE:xttl,XSTYLE:1,YSTYLE:1,$
         NODATA:1,YMINOR:9,XMINOR:9,YLOG:1,XRANGE:fra_0}
extract_tags,fstr,fstruct

thick_ness = 1.0
;-----------------------------------------------------------------------------------------
; => Plot Data
;-----------------------------------------------------------------------------------------
; => Reset start/end points
startpoint = LONG(0)
endpoint   = LONG(startpoint + wlen[0] - 1L)
nsub       = (endpoint[0] - startpoint[0]) + 1L                  ; => # of elements in subarray

FOR j=1L, nsteps - 1L DO BEGIN
  gels          = LINDGEN(nsub) + startpoint[0]
  ; => Define start and end points
  startpoint    = MIN(gels,/NAN)
  endpoint      = MAX(gels,/NAN)
  ; => Check elements
  IF (MAX(gels,/NAN) GE np) THEN BEGIN
    bad = WHERE(gels GE np,bd,COMPLEMENT=good,NCOMPLEMENT=gd)
    IF (gd GT 0) THEN BEGIN
      gels       = gels[good]
      fels       = fels[good]
      dn_el0     = MIN(fels,/NAN)
      up_el0     = MAX(fels,/NAN)
      startpoint = MIN(gels,/NAN)
      endpoint   = MAX(gels,/NAN)
    ENDIF ELSE BEGIN
      ; => None of the elements can be used
      GOTO,JUMP_SKIP
    ENDELSE
  ENDIF ELSE BEGIN
    dn_el0 = 0
    up_el0 = startpoint[0]/scale[0] - 1L
  ENDELSE
  st_rat        = startpoint[0]/scale[0]
  en_rat        = endpoint[0]/scale[0]
  ; => Get the current starting time in the overall data for plot label
  stringtime    = STRING(startpoint[0]*timestep[0],FORMAT='(f6.2)')
  stringcount   = STRING(j,FORMAT='(i4.4)')
  ; => Sub series time range test
  n_small       = N_ELEMENTS(small_time) - 1L
  test0         = (st_rat[0] GT 0 AND st_rat[0] LT n_small[0])
  time_ra       = [MIN(small_time[gels],/NAN),MAX(small_time[gels],/NAN)]
  ;---------------------------------------------------------------------------------------
  ; => Plot data
  ;---------------------------------------------------------------------------------------
  IF KEYWORD_SET(fullseries) THEN BEGIN
    PLOT,small_time,small_data,_EXTRA=wstr,TITLE=stringtime+' (s)'
  ENDIF ELSE BEGIN
    str_element,wstr,'XRANGE',time_ra,/ADD_REPLACE
    PLOT,small_time,small_data,_EXTRA=wstr,TITLE=stringtime+' (s)'
  ENDELSE
  ; => Sub series highlighted [Range not shown in FFT]
  IF (test0) THEN BEGIN
    OPLOT,small_time[dn_el0:up_el0],small_data[dn_el0:up_el0],$
          COLOR=pcolor,THICK=thick_ness
  ENDIF ELSE BEGIN
    OPLOT,small_time,small_data,COLOR=pcolor,THICK=thick_ness
  ENDELSE
  ;---------------------------------------------------------------------------------------
  ; => Highlight FFT window
  ;---------------------------------------------------------------------------------------
  IF KEYWORD_SET(fullseries) THEN BEGIN
    dn_el1 = st_rat[0]
    up_el1 = en_rat[0] - 1L
    dn_el2 = en_rat[0]
    up_el2 = npoints/scale - 1L
    test1  = (st_rat[0] LT en_rat[0]) AND (en_rat[0] LE n_small)
    test2  = (en_rat[0]   LT npoints/scale - 1L) AND (npoints/scale - 1L LE n_small)
    IF (test1) THEN BEGIN
      OPLOT,small_time[dn_el1:up_el1],small_data[dn_el1:up_el1],$
            COLOR=fftcol,THICK=thick_ness
      ; => Overplot lines to highlight box limits
      OPLOT,[small_time[dn_el1],small_time[dn_el1]],plotyrange,$
            COLOR=fftcol,THICK=thick_ness
      OPLOT,[small_time[up_el1],small_time[up_el1]],plotyrange,$
            COLOR=fftcol,THICK=thick_ness
    ENDIF
    IF (test2) THEN BEGIN
      OPLOT,small_time[dn_el2:up_el2],small_data[dn_el2:up_el2],$
            COLOR=pcolor,THICK=thick_ness
    ENDIF
  ENDIF
  ;---------------------------------------------------------------------------------------
  ; => Plot zero line
  ;---------------------------------------------------------------------------------------
  zeros = REPLICATE(0e0,N_ELEMENTS(small_time))
  OPLOT,small_time,zeros,THICK=1.0
  ;---------------------------------------------------------------------------------------
  ; => Plot power spectrum
  ;---------------------------------------------------------------------------------------
  PLOT,nfreqbins,subpower[j,*],_EXTRA=fstr
  OPLOT,nfreqbins,subpower[j,*],THICK=2.0;,COLOR=fftcol
  ;---------------------------------------------------------------------------------------
  ; => Overplot frequencies if set
  ;---------------------------------------------------------------------------------------
  IF KEYWORD_SET(ex_freqs) THEN BEGIN
    szt   = tplot_struct_format_test(ex_freqs)
    IF (szt) THEN BEGIN
      freqs = REFORM(ex_freqs.Y)      ; => Frequencies [Hz]
      ftims = REFORM(ex_freqs.X)      ; => Corresponding times [s]
      szf   = SIZE(freqs,/DIMENSIONS)
      ndf   = N_ELEMENTS(szf)
      nfrq  = N_ELEMENTS(freqs[dn_el1:up_el1,0])  ; => Assume user entered data correctly
      IF (ndf GT 1) THEN mfrq = N_ELEMENTS(freqs[0,*]) ELSE mfrq = 1
      IF KEYWORD_SET(ex_labs) THEN BEGIN
        labels = REFORM(ex_labs)
        nlabs  = N_ELEMENTS(labels)
        IF (nlabs NE mfrq) THEN GOTO,JUMP_LABELS
        mxwdth = MAX(STRLEN(labels),/NAN)
      ENDIF ELSE BEGIN
        JUMP_LABELS:
        labels = STRARR(mfrq)
        FOR jj=0L, mfrq - 1L DO labels[jj] = 'f!D'+STRTRIM(jj,2)+'!N'
        mxwdth = MAX(STRLEN(labels),/NAN)
      ENDELSE
      pmxposi = powra[1] + 2d-1*ABS(powra[1])
      
      IF (mfrq GT 1) THEN BEGIN
        ; => More than one frequency per time range
        FOR kk=0L, mfrq - 1L DO BEGIN
          avgfrq  = MEAN(freqs[dn_el1:up_el1,kk],/NAN)
          labwdth = STRLEN(labels[kk]) EQ mxwdth[0]
          IF (labwdth) THEN lshift = 1d-1 ELSE lshift = 5d-2
          frqposi = avgfrq[0] - lshift[0]*ABS(avgfrq[0])
          ; => Overplot vertical lines for extra frequencies
          OPLOT,[avgfrq[0],avgfrq[0]],[powra],THICK=2.0,COLOR=fcolor
          ; => Output labels for extra frequencies
          XYOUTS,frqposi[0],pmxposi[0],labels[0],/DATA,CHARSIZE=0.75,CHARTHICK=1.0,COLOR=fcolor
        ENDFOR
      ENDIF ELSE BEGIN
        ; => Only one frequency per time range
        avgfrq  = MEAN(freqs[dn_el1:up_el1],/NAN)
        labwdth = STRLEN(labels[0]) EQ mxwdth[0]
        IF (labwdth) THEN lshift = 1d-1 ELSE lshift = 5d-2
        frqposi = avgfrq[0] - lshift[0]*ABS(avgfrq[0])
        ; => Overplot vertical lines for extra frequencies
        OPLOT,[avgfrq[0],avgfrq[0]],[powra],THICK=2.0,COLOR=fcolor
        ; => Output labels for extra frequencies
        XYOUTS,frqposi[0],pmxposi[0],labels[0],/DATA,CHARSIZE=0.75,CHARTHICK=1.0,COLOR=fcolor
      ENDELSE
    ENDIF
  ENDIF
  ;---------------------------------------------------------------------------------------
  ; => Write to PNG file
  ;---------------------------------------------------------------------------------------
  WRITE_PNG,imgdir+'/'+stringcount+'.png',TVRD(TRUE=1)
  IF (j EQ 1) THEN BEGIN
    ;-------------------------------------------------------------------------------------
    ; => Plot blank time series data
    ;-------------------------------------------------------------------------------------
    PLOT,time,data,_EXTRA=wstr,TITLE=stringtime+' (ms)'
    ;-------------------------------------------------------------------------------------
    ; => Plot blank power spectrum
    ;-------------------------------------------------------------------------------------
    PLOT,nfreqbins,subpower[j,*],_EXTRA=fstr
    WRITE_PNG,'blank_plot.png',TVRD(TRUE=1)
  ENDIF
  ;=======================================================================================
  JUMP_SKIP:
  ;=======================================================================================
  startpoint  += wshift[0]
  endpoint    += wshift[0]
  IF (j MOD 100 EQ 0) THEN PRINT,'stepcount:',j
ENDFOR
;-----------------------------------------------------------------------------------------
; => Return plot window to original state
;-----------------------------------------------------------------------------------------
!X          = xyzp_win.X
!Y          = xyzp_win.Y
!Z          = xyzp_win.Z
!P          = xyzp_win.P
!P.CHARSIZE = old_chars
!P.MULTI    = 0
; => Reset plot
SET_PLOT,'X'
; => Reset color table if changed
IF (KEYWORD_SET(r_orig0) AND KEYWORD_SET(g_orig0) AND KEYWORD_SET(b_orig0)) THEN BEGIN
  TVLCT,r_orig0,g_orig0,b_orig0
ENDIF

RETURN
END

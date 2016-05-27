;+
;*****************************************************************************************
;
;  FUNCTION :   plot_vector_mv_data.pro
;  PURPOSE  :   Takes HTR MFI data and plots the data in original coordinates, minimum
;                 variance coordinates, their respective power spectrum plots (spectral
;                 density), and (if explicitly desired) the estimates of current.  Then
;                 the data is plotted as hodograms to look for polarizations in both
;                 the original coordinates and minimum variance coordinates.
;
;  CALLED BY: 
;               vector_mv_plot.pro
;
;  CALLS:  
;               my_colors2.pro       ; => Common block
;               my_time_string.pro
;               plot_time_ticks.pro
;               file_name_times.pro
;               plot_vector_hodo_scale.pro
;               fft_power_calc.pro
;               vector_bandpass.pro
;               plot_freq_ticks.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:       
;               T1     :  Unix times associated with B-field data [DBLARR]
;               B1     :  B-field (nT) data [DBLARR]
;
;  EXAMPLES:    
;               NA
;
;  KEYWORDS:  
;               DATE      :  ['MMDDYY'] Date of interest
;               FSAVE     :  If set, the device is set to 'ps' thus saving file as a 
;                              *.eps file.  If NOT set, then the device is left as 'x'
;                              making it possible to plot to the screen for checking and
;                              user manipulation.
;               ROTBF     :  [DBLARR] B-field Rotated into Min. Var. frame (nT)
;               RANGE     :  2-element array defining the start and end point elements
;                              to use for plotting the data
;               READ_B    :  If set, scales B-field by its magnitude and shifts it by
;                              the average of the scaled field => roughly averages field
;                              to zero leaving only the fluctuations which are what
;                              we are concerned with.
;               MID_RA    :  [DOUBLE] Time (s of day) associated with the center of
;                              shock ramp
;               READ_WIN  :  If set, program uses windowing for FFT calculation
;               PLOT_CNT  :  Plot number for the session
;               READ_L    :  If set, FFT power spec. is plotted w/ Freq. on a log-scale
;               UNITS     :  Set to a named variable for returning the units of the
;                              data being plotted
;               NORMALIZE :  Set to a named variable for returning plot axis label
;                              information
;               HODO_SCL  :  Set to a named variable for returning axis scales
;               SLOW_P    :  Set to watch hodogram plots plot more slowly for determining 
;                              direction of polarization, among other things
;               T_STEP    :  Set to a value which indicates the rate at which the hodograms
;                              are plotted when the keyword SLOW_P is set
;               EIGA      :  Set to a 3-element array which has the 3 eigenvalues from the
;                              MV analysis [max,mid,min]
;               SAT       :  Defines which satellite ('A', 'B', or 'W' to use)
;                              [Default = 'W']
;               FCUTOFF   :  Set to a two element array specifying the range of 
;                              frequencies to use in power spectrum plots if data has
;                              been bandpass-filtered
;               COORD     :  Defines which coordinate system to use for plot labels
;                              ['RTN' or 'GSE', Default = 'GSE']
;               FIELD     :  Set to a scalar string defining whether the input is a
;                              magnetic ('B') or electric ('E') field 
;                              [Default = 'B']
;               THICK     :  Scalar used for corresponding PLOT.PRO or OPLOT.PRO keyword
;                              [Default = !P.THICK]
;               VVERSION  :  Scalar string for version output for vector_mv_plot.pro
;               SUFFX     :  Scalar string user defines which is appended onto the default
;                              PS file name if saved
;
;   CHANGED:  1)  Added keywords to return plot title information [09/11/2008   v1.0.1]
;             2)  Added hodogram plotting capabilities            [09/11/2008   v1.0.2]
;             3)  Added keyword: SLOW_P                           [09/11/2008   v1.0.3]
;             4)  Added keyword: T_STEP                           [09/12/2008   v1.0.4]
;             5)  Completely re-wrote hodogram plotting part      [09/18/2008   v1.1.0]
;             6)  Added keyword: EIGA                             [09/18/2008   v1.1.1]
;             7)  Changed functionality of fft_power_calc.pro     [09/29/2008   v1.1.2]
;             8)  Added keyword: SAT                              [09/30/2008   v1.1.3]
;             9)  Changed B-scale logic (0 seemed to = 1 for some reason)
;                                                                 [10/16/2008   v1.1.4]
;            10)  Fixed syntax and typo                           [11/04/2008   v1.1.5]
;            11)  Changed functionality of fft_power_calc.pro     [11/20/2008   v1.2.0]
;            12)  Added keyword: FCUTOFF                          [11/20/2008   v1.2.1]
;            13)  Fixed tick label issue on power spec.           [11/21/2008   v1.2.2]
;            14)  Fixed eigenvalue ratio output issue             [11/21/2008   v1.2.3]
;            15)  Fixed tick label issue for low freq.            [11/24/2008   v1.2.4]
;            16)  Changed charsizes in plots                      [12/11/2008   v1.2.5]
;            17)  Changed tick labels for very low freq.          [12/16/2008   v1.2.6]
;            18)  Changed tick labels                             [12/18/2008   v1.2.7]
;            18)  Changed tick label classification               [12/19/2008   v1.2.8]
;            19)  Added keyword: COORD                            [12/30/2008   v1.2.9]
;            20)  Updated man page                                [02/12/2009   v1.2.10]
;            21)  Changed input to Unix times (among other syntax issues)
;                                                                 [05/24/2009   v1.3.0]
;            22)  Fixed syntax error                              [05/25/2009   v1.3.1]
;            23)  Changed some syntax [no functional changes]     [05/25/2009   v1.3.2]
;            24)  Removed the current plotting stuff              [06/03/2009   v2.0.0]
;            25)  Changed power spectrum Y-Range calc             [06/08/2009   v2.0.1]
;            26)  Changed power spectrum X-Range calc             [06/08/2009   v2.0.2]
;            27)  Added keyword: FIELD                            [07/16/2009   v2.0.3]
;            28)  Changed power spectrum Y-Range calc             [07/16/2009   v2.0.4]
;            29)  Changed program my_htr_bandpass.pro to vector_bandpass.pro
;                   and my_plot_mv_htr_tick.pro to plot_freq_ticks.pro
;                   and htr_plot_ticks_2.pro to plot_time_ticks.pro
;                   and my_plot_scale.pro to plot_vector_hodo_scale.pro
;                   and removed keyword:  CURR
;                   and renamed from my_plot_mv_htr_data.pro      [08/12/2009   v3.0.0]
;            30)  Changed usage of plot_freq_ticks.pro            [09/22/2010   v3.1.0]
;            31)  Changed file name on output                     [09/23/2010   v3.2.0]
;            32)  Fixed issue with color table                    [09/24/2010   v3.2.1]
;            33)  Added option that tests whether the ~/output directory exists in
;                   the user's working IDL directory              [11/16/2010   v3.3.0]
;            34)  Added keyword:  THICK and fixed up some other things
;                   no longer depends upon my_str_date.pro
;                                                                 [03/04/2011   v3.4.0]
;            35)  Added keyword:  VVERSION and changed output slightly in addition
;                   to now calling file_name_times.pro            [03/10/2011   v3.5.0]
;            36)  Added keyword:  SUFFX                           [05/27/2011   v3.5.1]
;            37)  Changed the maximum # of plot counts to 9999 from 99
;                                                                 [06/01/2011   v3.5.2]
;
;   NOTES:      
;               1)  User should not call this routine
;
;   CREATED:  08/26/2008
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  06/01/2011   v3.5.2
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

PRO plot_vector_mv_data,t1,b1,DATE=date,FSAVE=fsave,ROTBF=rotbf,RANGE=range, $
                        READ_B=read_b,MID_RA=mid_ra,READ_WIN=read_win,       $
                        PLOT_CNT=pscount,READ_L=read_l,UNITS=units,          $
                        NORMALIZE=normalize,HODO_SCL=hodo_scl,SLOW_P=slow,   $
                        T_STEP=step,EIGA=eiga,SAT=sat,FCUTOFF=fcutoff,       $
                        COORD=crd,FIELD=field,THICK=thick,VVERSION=vversion, $
                        SUFFX=suffx

;-----------------------------------------------------------------------------------------
; ----DEFINE SOME USABLE COLORS----
;-----------------------------------------------------------------------------------------
@my_colors2.pro
chcolors = [6,2,4,1]
IF NOT KEYWORD_SET(vversion) THEN vers2 = '' ELSE vers2 = vversion[0]
version  = vers2[0]+" and  plot_vector_mv_data.pro :  06/01/2011   v3.5.2"
;-----------------------------------------------------------------------------------------
; -Get date and times associated with data
;-----------------------------------------------------------------------------------------
mts     = my_time_string(t1,UNIX=1,/NOMSSG,PREC=4)
tx      = mts.UNIX                ; => Unix time
ts      = mts.SOD                 ; => Seconds of day
tc      = mts.TIME_C              ; => Time ['HH:MM:SS.xxxx'] => ALREADY between s and e - 1L
ymdb    = mts.DATE_TIME           ; => 'YYYY-MM-DD/hh:mm:ss.xxxx'
zdate   = STRMID(ymdb[0],0L,10L)  ; => 'YYYY-MM-DD'

d       = REFORM(b1)              ; -Prevent any [1,n] or [n,1] array from going on
mdime   = SIZE(d,/DIMENSIONS)     ; -# of elements in each dimension of data
ndime   = SIZE(mdime,/N_ELEMENTS) ; - determine if 2D array or 1D array

g3 = WHERE(mdime EQ 3L,gg,COMPLEMENT=b3)
CASE g3[0] OF
  0L   : BEGIN
    m1 = TRANSPOSE(d)
  END
  1L   : BEGIN
    m1 = REFORM(d)
  END
  ELSE : BEGIN
    MESSAGE,'What did you enter?',/INFORMATIONAL,/CONTINUE
    RETURN
  END
ENDCASE
mg = SQRT(TOTAL(m1^2,2L,/NAN))                   ; => Magnitude of vector
gn = mdime[b3[0]]                                ; => # of data points
;-----------------------------------------------------------------------------------------
; => Define data range
;-----------------------------------------------------------------------------------------
IF KEYWORD_SET(range) THEN BEGIN
  myn = range[1] - range[0]  ; -number of elements used for min. var. calc.
  IF (myn LE gn AND range[0] GE 0 AND range[1] LE gn) THEN BEGIN
    s = range[0]
    e = range[1]
  ENDIF ELSE BEGIN
    MESSAGE,'Too many elements demanded in keyword: RANGE',/INFORMATIONAL,/CONTINUE
    s   = 0
    e   = gn - 1L
    myn = gn
  ENDELSE
ENDIF ELSE BEGIN
  s   = 0
  e   = gn - 1L
  myn = gn
ENDELSE
ntc     = N_ELEMENTS(tc[s:e])    ; => # of points in desired range
npoints = N_ELEMENTS(tx)         ; => # of points
;-----------------------------------------------------------------------------------------
; => Define coordinate system, plot number for this session, and satellite
;-----------------------------------------------------------------------------------------
IF NOT KEYWORD_SET(crd) THEN coord = 'GSE' ELSE coord = crd
IF NOT KEYWORD_SET(field) THEN fld = 'B' ELSE fld = STRUPCASE(field)

CASE fld[0] OF
  'B'  : BEGIN
    xwin_inst = 'MFI'
    unit_temp = ' (nT)'
  END
  'E'  : BEGIN
    xwin_inst = 'EFI'
    unit_temp = ' (mV/m)'
  END
  ELSE : BEGIN
    MESSAGE,'Incorrect keyword format: FIELD',/INFORMATIONAL,/CONTINUE
    MESSAGE,'Using default = B',/INFORMATIONAL,/CONTINUE
    xwin_inst = 'MFI'
    unit_temp = ' (nT)'
  END
ENDCASE

IF KEYWORD_SET(suffx)   THEN sffxx   = suffx[0]        ELSE sffxx   = ''
IF KEYWORD_SET(pscount) THEN pscount = pscount         ELSE pscount = 0
IF KEYWORD_SET(sat)     THEN sn      = STRLOWCASE(sat) ELSE sn      = 'w'
CASE sn OF
  'w'  : BEGIN
    fbna     = 'WI_HTR'
    sat_titl = 'Wind HTR '+xwin_inst
  END
  'a'  : BEGIN
    fbna     = 'STA_'
    sat_titl = 'STEREO-A HTR '+xwin_inst
    curr     = 0  ; -make sure user doesn't try this
  END
  'b'  : BEGIN
    fbna     = 'STB_'
    sat_titl = 'STEREO-B HTR '+xwin_inst
    curr     = 0
  END
  ELSE : BEGIN
    MESSAGE,'Incorrect keyword format: SAT',/INFORMATIONAL,/CONTINUE
    MESSAGE,'Using default = W',/INFORMATIONAL,/CONTINUE
    fbna     = 'WI_HTR'
    sat_titl = 'Wind HTR '+xwin_inst
  END
ENDCASE
;-----------------------------------------------------------------------------------------
; -Determine plot labels
;-----------------------------------------------------------------------------------------
myticks  = plot_time_ticks(tc[s:e],tx[s:e],NTS=4)
fnscet   = ''   ; -['YYYY-MM-DD_HHMMxSS.ssss-HHMMxSS.ssss']
temp     = file_name_times([tx[s],tx[e]],PREC=4,FORMFN=1)
fnscet   = temp.F_TIME[0]+'_'+temp.F_TIME[1]

;time_fsn = STRMID(ymdb[s],11L,2L)+STRMID(ymdb[s],14L,2L)+'x'+STRMID(ymdb[s],17L)+$
;           '_'+STRMID(ymdb[e],11L,2L)+STRMID(ymdb[e],14L,2L)+'x'+STRMID(ymdb[e],17L)
;fnscet   = zdate[0]+'_'+time_fsn[0]
;fnscet   = ''   ; -['YYYY-MM-DD_00000.0-00000.0']
;fnscet   = zdate+'_'+STRTRIM(STRING(FORMAT='(G15.7)',ts[s]),2)+'-'+$
;           STRTRIM(STRING(FORMAT='(G15.7)',ts[e]),2)
;-----------------------------------------------------------------------------------------
; -Add eigenvalue ratios to file name
;-----------------------------------------------------------------------------------------
mnout_pref = '!7k!3'+'!D2!N/!7k!3'+'!D3!N = '
mxout_pref = '!7k!3'+'!D1!N/!7k!3'+'!D2!N = '
eidef      = '!7k!3'+'!D3!N = Min Var.,'+'!C'+'!7k!3'+'!D2!N = Mid. Var.,'+'!C'+'!7k!3'+$
             '!D1!N = Max. Var.'
sfmnfn     = ''     ; => _LamMidMin-XX.xxx = value for ratio of Mid to Min Eig. Val.
sfmxfn     = ''     ; => _LamMidMin-XX.xxx = value for ratio of Max to Mid Eig. Val.
basename   = ''     ; => file name on output when saving to PS file
; => e.g. 'WI_HTRMFI_MV_YYYY-MM-DD_HHMMxSS.ssss-HHMMxSS.ssss_LamMidMin-10.123_LamMaxMid-1.123'

IF KEYWORD_SET(eiga) THEN BEGIN
  maxmid = eiga[0]/eiga[1]
  midmin = eiga[1]/eiga[2]
  smxmd  = STRTRIM(STRING(FORMAT='(f12.3)',maxmid),2)
  smdmn  = STRTRIM(STRING(FORMAT='(f12.3)',midmin),2)
  sfmnfn = '_LamMidMin-'+smdmn[0]
  sfmxfn = '_LamMaxMid-'+smxmd[0]
  mnout  = mnout_pref[0]+smdmn
  mxout  = mxout_pref[0]+smxmd
ENDIF ELSE BEGIN
  sfmnfn = ''
  sfmxfn = ''
  mnout  = mnout_pref[0]+'NA'
  mxout  = mxout_pref[0]+'NA'
ENDELSE
eigout   = [mnout,mxout,eidef]
basename = fbna+xwin_inst+'_MV_'+fnscet[0]+sfmnfn[0]+sfmxfn[0]+sffxx[0]
;-----------------------------------------------------------
PRINT,';Plot Index Range: '+STRTRIM(s,2)+'-'+STRTRIM(e,2)+' ('+STRTRIM(e-s+1L,2)+' vectors)'
PRINT,';Plot Range: ',STRTRIM(tc[s],2)+'-'+STRTRIM(tc[e],2)
PRINT,';'
PRINT,';Or: ',STRTRIM(ts[s],2)+'-'+STRTRIM(ts[e],2)
PRINT,';'
IF KEYWORD_SET(mid_ra) THEN BEGIN
  PRINT,';Middle of Ramp : ',STRTRIM(mid_ra,2)
ENDIF
;-----------------------------------------------------------------------------------------
; => Check if rotated field was input
;-----------------------------------------------------------------------------------------
IF KEYWORD_SET(rotbf) THEN BEGIN
  mv1 = REFORM(rotbf)
  mvd = SIZE(mv1,/DIMENSIONS)                    ; -# of elements in each dimension of data
  gvd = WHERE(mvd EQ 3L,gvg,COMPLEMENT=bvd)
  CASE gvd[0] OF
    0L   : BEGIN
      mv = TRANSPOSE(mv1)
    END
    1L   : BEGIN
      mv = REFORM(mv1)
    END
    ELSE : BEGIN
      MESSAGE,'Incorrect keyword format:  ROTBF [MUST be an (N,3)-element array]',/INFORMATIONAL,/CONTINUE
      mv = m1
    END
  ENDCASE
ENDIF ELSE BEGIN
  mv = m1
ENDELSE
;-----------------------------------------------------------------------------------------
; -Determine whether to scale B-field or not
;-----------------------------------------------------------------------------------------
IF KEYWORD_SET(read_b) THEN BEGIN
  IF (read_b NE 0) THEN rbb = 1b ELSE rbb = 0b
ENDIF ELSE BEGIN
  rbb = 0b
ENDELSE
;-----------------------------------------------------------------------------------------
; => Find vector field scales
;-----------------------------------------------------------------------------------------
IF (rbb) THEN BEGIN
  my_bscale1 = mg[s:e]
  my_bscale2 = mg[0:npoints-1]
  basename   = basename+'_N'
  myfield1   = plot_vector_hodo_scale(m1,/LSCALE,RANGE=[s,e])
  myfield2   = plot_vector_hodo_scale(mv,/LSCALE,RANGE=[s,e])
  newfield1  = myfield1.N_FIELD
  newfield2  = myfield2.N_FIELD
  hrange     = myfield2.PLOT_RANGE
  unit_lab   = ''
  f_lab      = '/|'+fld[0]+'|'
ENDIF ELSE BEGIN
  my_bscale1 = 1.0
  my_bscale2 = 1.0
  basename   = basename
  myfield1   = plot_vector_hodo_scale(m1,RANGE=[s,e])
  myfield2   = plot_vector_hodo_scale(mv,RANGE=[s,e])
  newfield1  = myfield1.N_FIELD
  newfield2  = myfield2.N_FIELD
  hrange     = myfield2.PLOT_RANGE
  unit_lab   = unit_temp
  f_lab      = ''
ENDELSE
units     = unit_lab   ; -Return units as keyword
normalize = f_lab      ; -Return B-field scale as keyword
hodo_scl  = hrange     ; -Return plot range information
;-set up the time series plot range
mvy       = hrange
;-----------------------------------------------------------------------------------------
; -Make sure plot settings are still set
;-----------------------------------------------------------------------------------------
ocharsize = !P.CHARSIZE
IF KEYWORD_SET(fsave) THEN BEGIN
  SET_PLOT,'PS'
  fileps1     =  'output/'+basename+'_'+STRING(pscount,FORMAT='(I4.4)')+'.ps'
  fileps_hodo = 'output/'+basename+'_HODO_'+STRING(pscount,FORMAT='(I4.4)')+'.ps'
  PRINT,'PostScript plot saved: '+fileps1
  DEVICE,/LANDSCAPE,/INCHES,/COLOR,XSIZE=10.0,YSIZE=6.5,$
         XOFFSET=1.0,YOFFSET=10.5,FILENAME=fileps1
  !P.CHARSIZE = 1.5
ENDIF ELSE BEGIN
  SET_PLOT,'X'
  IF (!D.WINDOW) EQ -1 THEN BEGIN
    WINDOW,4,TITLE='HTR-'+xwin_inst+'/-MV coords',XSIZE=750,YSIZE=375,XPOS=450,RETAIN=2
    WINDOW,6,TITLE='HTR-'+xwin_inst+'/-MV HODO'  ,XSIZE=200,YSIZE=500,XPOS=90, RETAIN=2
    !P.CHARSIZE = 2.2
  ENDIF
  WSET,4
  WSHOW,4
ENDELSE
;-----------------------------------------------------------------------------------------
; -Set up vars for power spectrum
;-----------------------------------------------------------------------------------------
evlength = tx[e] - tx[s]
nsps     = (npoints - 1L)/evlength
nfbins   = 1L + e - s
;-----------------------------------------------------------
my_fft_b = fft_power_calc(tx,m1[*,0],READ_WIN=read_win,RANGE=[s,e])
power_bx = my_fft_b.POWER_X   ; -FFT power (dB) for the X-HTR MFI data
freqbins = my_fft_b.FREQ      ; -Freq. bins (Hz) assoc. with power specs
pow_ysx  = my_fft_b.POWER_RA  ; -Y-scale for plotting power specs

my_fft_b = fft_power_calc(tx,m1[*,1],READ_WIN=read_win,RANGE=[s,e])
power_by = my_fft_b.POWER_X   ; -FFT power (dB) for the Y-HTR MFI data
pow_ysy  = my_fft_b.POWER_RA  ; -Y-scale for plotting power specs

my_fft_b = fft_power_calc(tx,m1[*,2],READ_WIN=read_win,RANGE=[s,e])
power_bz = my_fft_b.POWER_X   ; -FFT power (dB) for the Z-HTR MFI data
pow_ysz  = my_fft_b.POWER_RA  ; -Y-scale for plotting power specs
pow_ysb  = minmax([pow_ysx,pow_ysy,pow_ysz])
;-----------------------------------------------------------
my_fft_v = fft_power_calc(tx,mv[*,0],READ_WIN=read_win,RANGE=[s,e])
power_vx = my_fft_v.POWER_X   ; -FFT power (dB) for the X-HTR MFI data
freqbinv = my_fft_v.FREQ      ; -Freq. bins (Hz) assoc. with power specs
pow_ysvx = my_fft_v.POWER_RA  ; -Y-scale for plotting power specs

my_fft_v = fft_power_calc(tx,mv[*,1],READ_WIN=read_win,RANGE=[s,e])
power_vy = my_fft_v.POWER_X   ; -FFT power (dB) for the Y-HTR MFI data
pow_ysvy = my_fft_v.POWER_RA  ; -Y-scale for plotting power specs

my_fft_v = fft_power_calc(tx,mv[*,2],READ_WIN=read_win,RANGE=[s,e])
power_vz = my_fft_v.POWER_X   ; -FFT power (dB) for the Z-HTR MFI data
pow_ysvz = my_fft_v.POWER_RA  ; -Y-scale for plotting power specs
pow_ysv  = minmax([pow_ysvx,pow_ysvy,pow_ysvz])
;-----------------------------------------------------------
power_pl = [power_bx,power_by,power_bz,power_vx,power_vy,power_vz]
gpran    = [MIN(power_pl,/NAN)*1.1,MAX(power_pl,/NAN)]

IF (gpran[1] LT 0d0) THEN gpran[1] = gpran[1]/1.1 ELSE gpran[1] = gpran[1]*1.1

IF KEYWORD_SET(fcutoff) THEN BEGIN
  freqyra = REFORM(fcutoff)
  goodfr  = WHERE(freqbins LE freqyra[1] AND freqbins GE freqyra[0],gdr)
ENDIF ELSE BEGIN
  freqyra = [freqbins[1],MAX(freqbins,/NAN)]
  gdr     = N_ELEMENTS(freqbins)
  goodfr  = LINDGEN(gdr)
ENDELSE
;-----------------------------------------------------------------------------------------
; => Smooth out spikes to get a better estimate of plot ranges by making up a sample rate
;      and performing a bandpass filter to remove high frequencies...
; => negative low freq inclues zero freq.
;-----------------------------------------------------------------------------------------
sepx  = [[power_bx],[power_by],[power_bz]]
smpx  = vector_bandpass(sepx,1d3,-1d-9,3d2,/MIDF) 
IF (gdr GT 0L) THEN BEGIN
  smp1  = smpx[goodfr,*]
ENDIF ELSE BEGIN
  smp1  = smpx
ENDELSE
pxmin = MIN(smp1,/NAN) - 1d-1*ABS(MIN(smp1,/NAN))
pxmax = MAX(smp1,/NAN) + 1d-1*ABS(MAX(smp1,/NAN))
gpran = [pxmin,pxmax]
;-----------------------------------------------------------------------------------------
IF (gpran[0] LT -16d1) THEN gpran[0] = -17d1
powy = MAX(ABS(gpran),/NAN)
;-----------------------------------------------------------------------------------------
; -Define some freq. tick values/names
;-----------------------------------------------------------------------------------------
freq_struct = plot_freq_ticks(freqyra,XLOG=read_l)
freqyra     = freq_struct.XRANGE
;-----------------------------------------------------------------------------------------
; -Define plot settings
;-----------------------------------------------------------------------------------------
!P.MULTI      = [0,3,3,0,0]  ;!p.multi[# of plots to keep, columns, rows]
!P.BACKGROUND = white
!P.COLOR      = black
;-----------------------------------------------------------------------------------------
; -Define plot labels
;-----------------------------------------------------------------------------------------
coordlab = ' ['+coord+']'
vec_lab  = ['x','y','z']
sc_title = 'SCET: '+tc[s]+' - '+tc[e]   ; -'SCET: HH:MM:SS.xxx - HH:MM:SS.xxx'
co1_titl = 'MIN VAR coords.'
co2_titl = coord+' coords.'
co3_titl = 'Date: '+zdate
st_title = 'TIME RANGE: '+STRTRIM(STRING(FORMAT='(G15.7)',ts[s]),2)+$
           ' - '+STRTRIM(STRING(FORMAT='(G15.7)',ts[e]),2)
pspecttl = STRUPCASE(vec_lab)+'-Power vs. Frequency'
; => Determine labels for each plot case
FOR j = 0L, 2L DO BEGIN
  CASE j OF
    0 : BEGIN
      ydat1 = newfield1[0:(npoints-1),0]  ; -Plot X-Component [GSE Coords]
      ydat2 = newfield2[0:(npoints-1),0]  ; -Plot X-Component [MVA Coords]
      pow_r = power_bx                    ; => GSE FFT Power
      pow_v = power_vx                    ; => MVA FFT Power
      pttl1 = sat_titl
      pttl2 = sc_title
    END
    1 : BEGIN
      ydat1 = newfield1[0:(npoints-1),1]  ; -Plot Y-Component
      ydat2 = newfield2[0:(npoints-1),1]
      pow_r = power_by
      pow_v = power_vy
      pttl1 = co2_titl
      pttl2 = co1_titl
    END
    2 : BEGIN
      ydat1 = newfield1[0:(npoints-1),2]  ; -Plot Z-Component
      ydat2 = newfield2[0:(npoints-1),2]
      pow_r = power_bz
      pow_v = power_vz
      pttl1 = co3_titl
      pttl2 = st_title
    END
  ENDCASE
  source  = fld[0]+'!D'+vec_lab[j]+'!N'+f_lab+coordlab+unit_lab
  source2 = fld[0]+'!D'+vec_lab[j]+'!N'+f_lab+' [MV]'+unit_lab
  xminor  = !X.MINOR
  pttl3   = pspecttl[j]  ; => Power spectrum plot titles
  ;---------------------------------------------------------------------------------------
  ; -Plot Vectors in Original Basis
  ;---------------------------------------------------------------------------------------
  ytitle_temp = source
  PLOT,tx[s:e],ydat1[s:e],TITLE=pttl1,_EXTRA=myticks.EX,/XSTYLE,YSTYLE=17,$
    YRANGE=[-1*mvy,mvy],YTITLE=ytitle_temp,/NODATA
    OPLOT,tx[s:e],ydat1[s:e],COLOR=128,THICK=thick
  ;---------------------------------------------------------------------------------------
  ; -Plot corrected mV
  ;---------------------------------------------------------------------------------------
  ytitle_temp = source2
  PLOT,tx[s:e],ydat2[s:e],TITLE=pttl2,_EXTRA=myticks.EX,/XSTYLE,YSTYLE=17,$
    YRANGE=[-1*mvy,mvy],YTITLE=ytitle_temp,/NODATA
    OPLOT,tx[s:e],ydat2[s:e],COLOR=chcolors[j],THICK=thick
  ;---------------------------------------------------------------------------------------
  ; -Plot fft
  ;---------------------------------------------------------------------------------------
  PLOT,freqbins,pow_r,TITLE=pttl3,_EXTRA=freq_struct,             $
    YTITLE="dB",XTITLE="Freq. (Hz)",/NODATA,YRANGE=gpran,         $
    TICKLEN=0.05,XTICKLAYOUT=0,YMINOR=5L,YMARGIN=[4,4]
    OPLOT,freqbins,pow_r,COLOR=128,THICK=thick            ; => GSE FFT [gray  scale]
    OPLOT,freqbinv,pow_v,COLOR=chcolors[j],THICK=thick    ; => MVA FFT [color scale]
  ;-----------------------------------------------------------
  IF KEYWORD_SET(eiga) THEN BEGIN
    xc     = freqyra       ; => X-Data range of previous plot window
    dxc    = ABS(xc[1] - xc[0])
    IF KEYWORD_SET(fsave) THEN BEGIN
      yc     = gpran       ; => Y-Data " "
      dyc    = ABS(yc[1] - yc[0])
      IF (read_l) THEN xloc = 2d0*xc[0] ELSE xloc = xc[0] + dxc[0]/5d0
      yloc   = yc[0] + 1d-1*dyc
      IF (j EQ 2L) THEN yloc   = yc[0] + 40d-2*dyc
    ENDIF ELSE BEGIN
      yc     = !Y.CRANGE   ; => Y-Data " "
      dyc    = ABS(yc[1] - yc[0])
      xloc   = xc[0] + 3d-2*dxc
      yloc   = yc[0] + 1d-1*dyc
      IF (xc[0] LT 1d-3 AND dxc gt 1d-1) THEN xloc = 15d-4  ; -Special case?
      IF (j EQ 2L) THEN yloc   = yc[0] + 30d-2*dyc
    ENDELSE
    XYOUTS,xloc,yloc,eigout[j],/DATA,COLOR=chcolors[j]
  ENDIF
  ;-----------------------------------------------------------
  !X.MINOR = xminor
ENDFOR
IF KEYWORD_SET(fsave) THEN BEGIN
  timeS = SYSTIME(0)
  outstr  = version[0]+','+'!C'+'output at: '+timeS[0]+' For '+sc_title[0]
  XYOUTS,0.25,0.0020,outstr,CHARSIZE=.7,/NORMAL,ALIGNMENT=0.0
;  XYOUTS,0.34,0.004,version+', output at: '+timeS,CHARSIZE=.7,/NORMAL
  DEVICE,/CLOSE_FILE
  !P.MULTI = 0
  SET_PLOT,'X'
  !P.CHARSIZE = 2.2
ENDIF
;-----------------------------------------------------------------------------------------
; -Determine/Set-up windows
;-----------------------------------------------------------------------------------------
IF KEYWORD_SET(fsave) THEN BEGIN
  SET_PLOT,'PS'
  PRINT,"PostScript plot saved: "+fileps_hodo
  DEVICE,/LANDSCAPE,/INCHES,/COLOR,XSIZE=10.0,YSIZE=6.50,XOFFSET=1.5,YOFFSET=10.5,$
         FILENAME=fileps_hodo
  !P.MULTI    = [0,3,2,0,0]   ; -Plot left-right, top-bottom
  !P.CHARSIZE = 1.5
  hchar       = !P.CHARSIZE
ENDIF ELSE BEGIN
;-----------------------------------------------------------------------------------------
;  =>Set up the hodogram window
;-----------------------------------------------------------------------------------------
  SET_PLOT,'X'
  WSET, 6
  WSHOW,6
  !P.CHARSIZE = 2.2
  !P.MULTI    = [0,2,3,0,1]   ; -Plot top-bottom, left-right
  hchar       = !P.CHARSIZE
ENDELSE
;-----------------------------------------------------------------------------------------
; -Plot Hodograms
;-----------------------------------------------------------------------------------------
coord = [coordlab,' [MV]']
ttles = [fld[0]+'!Dy!N vs '+fld[0]+'!Dx!N',$
         fld[0]+'!Dz!N vs '+fld[0]+'!Dx!N',$
         fld[0]+'!Dz!N vs '+fld[0]+'!Dy!N']
bstr  = [fld[0]+'!Dx!N',fld[0]+'!Dy!N',fld[0]+'!Dz!N']
;-----------------------------------------------------------------------------------------
; -Plot By vs. Bx in Min. Var. Coords.
;-----------------------------------------------------------------------------------------
IF KEYWORD_SET(slow) THEN BEGIN
  slow           = 1
  stop_slow_plot = ''
ENDIF ELSE BEGIN
  slow           = 0
  stop_slow_plot = ''
ENDELSE

FOR k=0L, 1L DO BEGIN     ; -Coordinate System index [i.e. GSE or MV]
  CASE k OF
    0 : BEGIN
      mydat = newfield1  ; -[GSE]
      mcc   = 128
    END
    1 : BEGIN
      mydat = newfield2  ; -[MV]
      mcc   = chcolors[0]
    END
  ENDCASE
  FOR j=0L, 2L DO BEGIN   ; -Coord. index [i.e. X, Y, or Z]
    title_temp2 = ttles[j] + coord[k]
    mcolor      = mcc
    CASE j OF
      0 : BEGIN
        xbf  = mydat[0:(npoints-1L),0]   ; -data to be plotted on X-axis in GSE coords.
        ybf  = mydat[0:(npoints-1L),1]   ; -" " Y-axis " "
        xttl = bstr[0] + f_lab + coord[k] + unit_lab  ; = X-axis title
        yttl = bstr[1] + f_lab + coord[k] + unit_lab  ; = Y-axis title
      END
      1 : BEGIN
        xbf = mydat[0:(npoints-1L),0]   ; -data to be plotted on X-axis in GSE coords.
        ybf = mydat[0:(npoints-1L),2]   ; -" " Y-axis " "
        xttl = bstr[0] + f_lab + coord[k] + unit_lab
        yttl = bstr[2] + f_lab + coord[k] + unit_lab
      END
      2 : BEGIN
        xbf = mydat[0:(npoints-1L),1]   ; -data to be plotted on X-axis in GSE coords.
        ybf = mydat[0:(npoints-1L),2]   ; -" " Y-axis " "
        xttl = bstr[1]+f_lab+coord[k]+unit_lab
        yttl = bstr[2]+f_lab+coord[k]+unit_lab
      END
    ENDCASE
    ;-------------------------------------------------------------------------------------
    ; -Plot hodograms
    ;-------------------------------------------------------------------------------------
    IF (k EQ 0L AND j EQ 1L) THEN title_temp2 = '!7D!3 = start,  !9V!3 = end'
    PLOT,xbf[s:e],ybf[s:e],XTITLE=xttl,YTITLE=yttl,XSTYLE=1,YSTYLE=1, $
        XRANGE=[-1d0*mvy,mvy],YRANGE=[-1d0*mvy,mvy],TITLE=title_temp2,$
        /NODATA,CHARSIZE=hchar
    IF (slow EQ 1 AND k EQ 1) THEN BEGIN
      PLOTS,xbf[s],ybf[s],COLOR=mcolor,THICK=thick
      OPLOT,[xbf[s]],[ybf[s]],PSYM=5,SYMSIZE=2.0
      OPLOT,[xbf[e]],[ybf[e]],PSYM=4,SYMSIZE=2.0
      scc = s + 1L
      WHILE (scc LE e AND stop_slow_plot NE 's') DO BEGIN
        PLOTS,xbf[scc],ybf[scc],COLOR=mcolor,/CONTINUE,THICK=thick
        WAIT,step
        scc += 1L     ; =>same as: scc = scc + 1L but more memory efficient
        stop_slow_plot = GET_KBRD(0)
      ENDWHILE
      stop_slow_plot = ''
    ENDIF ELSE BEGIN
      OPLOT,xbf[s:e],ybf[s:e],COLOR=mcolor,THICK=thick
      OPLOT,[xbf[s]],[ybf[s]],PSYM=5,SYMSIZE=2.0
      OPLOT,[xbf[e]],[ybf[e]],PSYM=4,SYMSIZE=2.0
    ENDELSE
  ENDFOR
ENDFOR
;-----------------------------------------------------------------------------------------
; -End plotting routine
;-----------------------------------------------------------------------------------------
IF KEYWORD_SET(fsave) THEN BEGIN
  pscount = pscount + 1L
  timeS   = SYSTIME(0)
  outstr  = version[0]+','+'!C'+'output at: '+timeS[0]+' For '+sc_title[0]
  XYOUTS,0.23,0.0010,outstr,CHARSIZE=.7,/NORMAL,ALIGNMENT=0.0
;  XYOUTS,0.25,0.996,sc_title,CHARSIZE=.7,/NORMAL
  DEVICE,/CLOSE_FILE
  !P.CHARSIZE = ocharsize
ENDIF

END
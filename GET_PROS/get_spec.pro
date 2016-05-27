;+
;*****************************************************************************************
;
;  FUNCTION :   get_spec.pro
;  PURPOSE  :   Creates "TPLOT" variable by summing 3D data over selected angle bins.
;
;  CALLED BY:   
;               NA
;
;  CALLS:
;               dat_3dp_str_names.pro
;               dat_3dp_energy_bins.pro
;               get_??.pro
;               str_element.pro
;               store_data.pro
;               interp.pro
;               gettime.pro
;               minmax.pro
;               wind_3dp_units.pro
;               conv_units.pro
;               time_string.pro
;               sub3d.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               DATA_STR  :  [string] Specify the type of structure you wish to 
;                               get the data for [i.e. 'el','eh','elb',etc.]
;
;  EXAMPLES:    
;               
;
;  KEYWORDS:    
;               BINS      :  Keyword telling which data bins to sum over
;               GAP_TIME  :  Time gap big enough to signify a data gap (def 200)
;               NO_DATA   :  Returns 1 if no_data else returns 0
;               UNITS     :  Convert to these units if included
;               NAME      :  New name of the Data Quantity
;               BKG       :  A 3d data structure containing the background counts.
;               MISSING   :  Value for bad data.
;               TRANGE    :  [Double] 2 element array specifying the range over 
;                              which to get data structures [Unix time]
;               FLOOR     :  Sets the minimum value of any data point to sqrt(bkg).
;               DAT_ARR   :  N-Element array of data structures from get_??.pro
;                              [?? = 'el','eh','elb',etc.]
;               KEV       :  If set, energy bin units are changed to keV instead of eV
;               _EXTRA    :  
;
;   CHANGED:  1)  REE - added bkg subtraction                     [10/05/1995   v1.0.?]
;             2)  JML - now uses index feature of get_* to walk through the data
;                                                                 [04/09/1996   v1.0.?]
;             3)  ??? - Mods plus clean up.                       [05/06/1996   v1.0.?]
;             4)  ??? - did something                             [04/17/2002   v1.0.48]
;             5)  Updated man page and cleaned up 
;                   and added keyword:  DAT_ARR                   [11/23/2010   v1.1.0]
;             6)  Fixed issue where stored energy array was 1-D when it's supposed to be
;                   2-D                                           [11/29/2010   v1.1.1]
;
;   NOTES:      
;               1)  "LOAD_3DP_DATA" must be called first to load up WIND data.
;
;   CREATED:  ??/??/????
;   CREATED BY:  Jasper Halekas
;    LAST MODIFIED:  11/29/2010   v1.1.1
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

PRO get_spec,data_str,         $
        BINS     = bins,       $
        GAP_TIME = gap_time,   $
        NO_DATA  = no_data,    $
        UNITS    = units,      $
        NAME     = name,       $
        BKG      = bkg,        $
        MISSING  = missing,    $
        TRANGE   = trange,     $
        FLOOR    = floor,      $
        DAT_ARR  = dat_arr,    $
        KEV      = kev,        $
        _EXTRA   = e

;*****************************************************************************************
ex_start = SYSTIME(1)
;*****************************************************************************************
;-----------------------------------------------------------------------------------------
; => Create dummy variables
;-----------------------------------------------------------------------------------------
f      = !VALUES.F_NAN
d      = !VALUES.D_NAN
;-----------------------------------------------------------------------------------------
; => Make sure data_str is in the correct format
;-----------------------------------------------------------------------------------------
strns    = dat_3dp_str_names(data_str)
data_str = strns.SN
routine  = 'get_'+data_str
;-----------------------------------------------------------------------------------------
; => get an example data structure
;-----------------------------------------------------------------------------------------
IF NOT KEYWORD_SET(dat_arr) THEN BEGIN  ; -> Need to get data structures
  dat   = CALL_FUNCTION(routine,INDEX=0,_EXTRA=e)
  times = CALL_FUNCTION(routine,/TIMES,_EXTRA=e)
ENDIF ELSE BEGIN                        ; -> Data structures given on input
  dat   = dat_arr[0]
  times = REFORM(dat_arr.TIME)
ENDELSE
ytitle  = data_str + 'spec'

n_e     = dat.NENERGY   ; => # of energy bins
nbins   = dat.NBINS     ; => # of data bins
IF KEYWORD_SET(bins) EQ 0 THEN str_element,dat,'BINS',bins

IF (N_ELEMENTS(bins) EQ nbins*n_e) THEN BEGIN
  bins     = TOTAL(bins,1,/NAN) GT 0
  binsindx = WHERE(bins EQ 0,binscnt)
  IF (binscnt EQ 0) THEN bins = 0
ENDIF
;-----------------------------------------------------------------------------------------
; => Determine data structure start times
;-----------------------------------------------------------------------------------------
IF (N_ELEMENTS(times) EQ 1 AND times[0] EQ 0) THEN BEGIN
  PRINT,'No valid data in timerange.'
  store_data,ytitle,DAT=0
  RETURN
ENDIF
;-----------------------------------------------------------------------------------------
; => determine if data structures are valid
;-----------------------------------------------------------------------------------------
firstvalid = -1
IF (dat.VALID EQ 1) THEN firstvalid = 0
i = 0
WHILE (firstvalid EQ -1) DO BEGIN
  IF (i EQ N_ELEMENTS(times)) THEN BEGIN
    PRINT,'No valid data in timerange.'
    store_data,ytitle,DAT=0
    RETURN
  ENDIF
  IF NOT KEYWORD_SET(dat_arr) THEN BEGIN
    dat = CALL_FUNCTION(routine,INDEX=i,_EXTRA=e)
  ENDIF ELSE BEGIN
    dat = dat_arr[i]
  ENDELSE
  IF (dat.VALID EQ 1) THEN firstvalid = i
  i = i + 1
ENDWHILE

nenergy = dat.NENERGY   ; => # of energy bins
;-----------------------------------------------------------------------------------------
; => determine index range
;-----------------------------------------------------------------------------------------
max = N_ELEMENTS(times)
istart = 0
IF KEYWORD_SET(trange) THEN BEGIN
  irange = FIX(interp(FINDGEN(max),times,gettime(trange)))
  PRINT,irange
  irange = (irange < (max - 1)) > 0
  irange = minmax(irange)
  istart = irange[0]
  times  = times[istart:irange[1]]
  PRINT,'Index range: ',irange
  max    = N_ELEMENTS(times)
ENDIF
;-----------------------------------------------------------------------------------------
; => define dummy arrays
;-----------------------------------------------------------------------------------------
data    = FLTARR(max,nenergy)
energy  = FLTARR(max,nenergy)

; => Determine default energy bin values
my_ena  = dat_3dp_energy_bins(dat)
energy0 = REFORM(REPLICATE(1e0,max) # my_ena.ALL_ENERGIES)
;-----------------------------------------------------------------------------------------
; => determine units
;-----------------------------------------------------------------------------------------
IF NOT KEYWORD_SET(units) THEN units = 'eflux'
temp   = wind_3dp_units(units)
gunits = temp.G_UNIT_NAME      ; => e.g. 'flux'
punits = temp.G_UNIT_P_NAME    ; => e.g. ' (# cm!U-2!Ns!U-1!Nsr!U-1!NeV!U-1!N)'

dat   = conv_units(dat,gunits)
count = dat.NBINS
IF NOT KEYWORD_SET(bins) THEN ind = INDGEN(dat.NBINS) ELSE ind = WHERE(bins,count)
IF (count NE dat.NBINS) THEN ytitle = ytitle+'_'+STRTRIM(count,2)
IF KEYWORD_SET(bkg) THEN ytitle = ytitle+'b'
IF KEYWORD_SET(name) EQ 0 THEN name = ytitle ELSE ytitle = name
ytitle = ytitle+'!C'+'('+punits+')'

IF (gunits EQ 'counts') THEN norm = 1 ELSE norm = count

IF NOT KEYWORD_SET(missing) THEN missing = f
;-----------------------------------------------------------------------------------------
; => calculate spectra
;-----------------------------------------------------------------------------------------
mid_times = times
FOR i=0L, max - 1L DO BEGIN
  IF NOT KEYWORD_SET(dat_arr) THEN BEGIN
    dat = CALL_FUNCTION(routine,INDEX=i+istart,_EXTRA=e)
  ENDIF ELSE BEGIN
    dat = dat_arr[i+istart]
  ENDELSE
  
  IF (dat.VALID NE 0) THEN BEGIN
    nfindx = WHERE(FINITE(dat.DATA) NE 1,cnt)
    IF (cnt NE 0) THEN dat.DATA(nfindx) = 0.
    IF (times[i] NE dat.TIME) THEN PRINT, time_string(dat.TIME), dat.TIME - times[i]
    IF KEYWORD_SET(bkg) THEN dat = sub3d(dat,bkg)
    dat          = conv_units(dat,gunits)
    data[i,*]    = TOTAL(dat.DATA[*,ind],2,/NAN)/norm
    energy[i,*]  = TOTAL(dat.ENERGY[*,ind],2,/NAN)/count
    mid_times[i] = dat.TIME + (dat.END_TIME - dat.TIME)/2d
  ENDIF ELSE BEGIN
    data[i,*]   = missing
    energy[i,*] = missing
  ENDELSE
ENDFOR
;-----------------------------------------------------------------------------------------
; => convert units if necessary
;-----------------------------------------------------------------------------------------
IF KEYWORD_SET(kev) THEN BEGIN
  energy = energy/1e3
  nrgs   = REFORM(energy(firstvalid,*))
  labels = STRTRIM(ROUND(nrgs), 2)+' keV'
ENDIF ELSE BEGIN
  nrgs   = REFORM(energy(firstvalid,*))
  labels = STRTRIM(ROUND(nrgs) ,2)+' eV'
ENDELSE

delta = energy - SHIFT(energy,1,0)
w     = WHERE(delta,c)
IF (c EQ 0) THEN BEGIN
  energy = energy0
ENDIF
;-----------------------------------------------------------------------------------------
; => send data to TPLOT
;-----------------------------------------------------------------------------------------
;message,/info,'Not running smoothspikes'
;smoothspikes,times
colors  = LINDGEN(nenergy)*(250L - 30L)/(nenergy - 1L) + 30L
shname  = STRMID(STRLOWCASE(strns.SN),0L,2L)
IF (shname EQ 'sf' OR shname EQ 'so') THEN colors = REVERSE(colors)

datastr = {X:mid_times,Y:data,V:energy};    ylog:1,labels:labels,panel_size:2.}
store_data,name,DATA=datastr,DLIM={YLOG:1,LABELS:labels,PANEL_SIZE:2.,$
                                   YTITLE:ytitle,COMMENT:'Units: '+gunits}
options,name,'COLORS',colors
;*****************************************************************************************
ex_time = SYSTIME(1) - ex_start
MESSAGE,STRING(ex_time)+' seconds execution time.',/cont,/info
;*****************************************************************************************
RETURN
END

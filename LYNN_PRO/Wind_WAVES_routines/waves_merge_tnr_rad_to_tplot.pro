;+
;*****************************************************************************************
;
;  PROCEDURE:   waves_merge_tnr_rad_to_tplot.pro
;  PURPOSE  :   Loads the data from the Wind WAVES radio receiver instrument suite
;                 and sends each receiver set to TPLOT then grabs all the data and
;                 merges it into a single TPLOT variable for later use.
;
;  CALLED BY:   
;               NA
;
;  INCLUDES:
;               NA
;
;  CALLS:
;               get_power_of_ten_ticks.pro
;               get_valid_trange.pro
;               is_a_number.pro
;               test_plot_axis_range.pro
;               waves_tnr_rad_to_tplot.pro
;               tnames.pro
;               t_get_struc_unix.pro
;               struct_value.pro
;               t_resample_tplot_struc.pro
;               delete_variable.pro
;               lbw_calc_yrange.pro
;               num2flt_str.pro
;               str_element.pro
;               store_data.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;               2)  ASCII files found at:
;                     https://solar-radio.gsfc.nasa.gov/wind/data_products.html
;
;  INPUT:
;               NA
;
;  EXAMPLES:    
;               [calling sequence]
;               waves_merge_tnr_rad_to_tplot [,FLOW=flow0] [,FUPP=fupp0] [,TRANGE=trange] $
;                                            [,TDATE=tdate] [,FSMTH=fsmth] [,ZRANGE=zrange]
;
;               ;;  Example
;               sodt           = '00:00:00.000'
;               eodt           = '23:59:59.999'
;               t0             = '1998-02-03'+'/'+sodt[0]
;               t1             = '1998-02-06'+'/'+sodt[0]
;               t              = [t0[0],t1[0]]
;               tran           = time_double(t)
;               flow           = 4d0
;               fupp           = 14d3
;               waves_merge_tnr_rad_to_tplot,FLOW=flow,FUPP=fupp,TRANGE=tran,/FSMTH,ZRANGE=[9.5d-1,1d1]
;
;  KEYWORDS:    
;               FLOW      :  Scalar [float] frequency [kHz] that defines the lower
;                              bound of the frequency spectrum
;                                [Default = 4.0]
;               FUPP      :  Scalar [float] frequency [kHz] that defines the upper
;                              bound of the frequency spectrum
;                                [Default = 13825.0]
;               TRANGE    :  [2]-Element [double] array specifying the time range from
;                              which the user desires to get data [Unix time]
;               TDATE     :  Scalar [string] defining the date of interest of the form:
;                              'YYYY-MM-DD' [MM=month, DD=day, YYYY=year]
;               FSMTH     :  If set, routine will smooth the data using a boxcar average
;                              of 3 points in both the X and Y dimensions
;                                [Default = FALSE]
;               ZRANGE    :  [2]-Element [numeric] array specifying the range of values
;                              to use for the decibel scale or Z-Axis
;                                [ Default = [0.1,500.] ]
;
;   CHANGED:  1)  NA
;                                                                   [MM/DD/YYYY   v1.0.0]
;
;   NOTES:      
;               1)  See man-page of either waves_tnr_file_read.pro or
;                     waves_rad_file_read.pro for documentation of WAVES ASCII
;                     files
;               ==================================================================
;               = -Documentation on WAVES TNR, RAD1&2 ASCII file documentation   =
;               =   PROVIDED BY:  Michael L. Kaiser (Michael.kaiser@nasa.gov)    =
;               ==================================================================
;               2)  Be careful when using the NODCBLS keyword as there are often times
;                     when the background level in the ASCII files is set to 0e0 for
;                     RAD1 and RAD2.
;
;  REFERENCES:  
;               1)  Bougeret, J.-L., M.L. Kaiser, P.J. Kellogg, R. Manning, K. Goetz,
;                      S.J. Monson, N. Monge, L. Friel, C.A. Meetre, C. Perche,
;                      L. Sitruk, and S. Hoang (1995) "WAVES:  The Radio and Plasma
;                      Wave Investigation on the Wind Spacecraft," Space Sci. Rev.
;                      Vol. 71, pp. 231-263, doi:10.1007/BF00751331.
;
;   CREATED:  03/06/2019
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  03/06/2019   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

PRO waves_merge_tnr_rad_to_tplot,FLOW=flow0,FUPP=fupp0,TRANGE=trange,TDATE=tdate, $
                                 FSMTH=fsmth,ZRANGE=zrange

;;----------------------------------------------------------------------------------------
;;  Define Constants and dummy variables
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
;;  dummy error messages
nodatamssg     = 'No data found --> Returning without output.'
;;----------------------------------------------------------------------------------------
;;  Define some defaults
;;----------------------------------------------------------------------------------------
ylgg           = 1b                                ;;  Logic for YLOG keyword in PLOT
ymin           = 9L                                ;;  Default number of Y-axis minor tick marks
min_flow       = 4d0
max_fhig       = 13.825d3
mnmx_zra       = [1d-1,5d2]
;;  Plotting defaults
ytun           = 'kHz'                             ;;  Base unit for Y-Axis data
yttp           = 'Frequency'                       ;;  Type of data plotted on Y-Axis
def_yttl       = 'WAVES '+yttp[0]+'['+ytun[0]+']'
def_zttl       = 'dB [above bkgd]'
def_ztks       = 5L
;;  Define time stamp for each column in WAVES ASCII files
min_per_day    = 1440L
waves_t_sod    = DINDGEN(min_per_day[0])*6d1       ;;  Seconds of day
;;  WAVES defaults
tick_struc     = get_power_of_ten_ticks([1d-1,1d6])
;;  Dummy TNR parameters
def_nf__tnr    = 96L
def_fr__tnr    = [4d0,245.146d0]
def_df__tnr    = 0.188144d-1
def_ch1_tnr    = 0L
def_ch2_tnr    = LONG((ALOG10(def_fr__tnr[1]) - ALOG10(def_fr__tnr[0]))/def_df__tnr[0]) + 1L
def_ff__tnr    = 1d1^(DINDGEN(def_nf__tnr[0])*def_df__tnr[0] + ALOG10(def_fr__tnr[0]))
;;  Dummy RAD1 parameters
def_nf_rad1    = 256L
def_fr_rad1    = [20d0,1040d0]
def_df_rad1    = 4d0
def_ch1rad1    = 0L
def_ch2rad1    = LONG((def_fr_rad1[1] - def_fr_rad1[0])/def_df_rad1[0])
def_ff_rad1    = DINDGEN(def_nf_rad1[0])*def_df_rad1[0] + def_fr_rad1[0]
;;  Dummy RAD1 parameters
def_nf_rad2    = 256L
def_fr_rad2    = [1.075d3,13.825d3]
def_df_rad2    = 0.050d0*1d3
def_ch1rad2    = 0L
def_ch2rad2    = LONG((def_fr_rad2[1] - def_fr_rad2[0])/def_df_rad2[0])
def_ff_rad2    = DINDGEN(def_nf_rad2[0])*def_df_rad2[0] + def_fr_rad2[0]
;;  Dummy LIMITS structure
def__lim       = {YSTYLE:1,YMINOR:ymin[0],PANEL_SIZE:2.0,XMINOR:5,XTICKLEN:0.04,YTICKLEN:0.01}
def_dlim       = {YTITLE:def_yttl[0],YLOG:ylgg[0],ZLOG:1,MIN_VALUE:0.01,ZTITLE:def_zttl[0],ZTICKS:def_ztks[0]}
;;----------------------------------------------------------------------------------------
;;  Check keywords
;;----------------------------------------------------------------------------------------
;;  Check TDATE and TRANGE
time_ra        = get_valid_trange(TDATE=tdate,TRANGE=trange)
tran           = time_ra.UNIX_TRANGE
tdates         = time_ra.DATE_TRANGE        ;;  'YYYY-MM-DD'  e.g., '2009-07-13'
mdates         = STRMID(tdates,5,2)+STRMID(tdates,8,2)+STRMID(tdates,2,2)
mdate          = mdates[0]                  ;;  'MMDDYY'  e.g., '071309'
;;  Check FLOW and FHIGH
IF (is_a_number(flow0,/NOMSSG)) THEN fl = DOUBLE(flow0[0]) ELSE fl = min_flow[0]
IF (is_a_number(fupp0,/NOMSSG)) THEN fu = DOUBLE(fupp0[0]) ELSE fu = max_fhig[0]
;;  Make sure frequency ranges are appropriate
fl             = (fl[0] < fu[0]) > (min_flow[0]*0.95)
fu             = (fu[0] > fl[0]) < (max_fhig[0]*1.05)
;;  Check FSMTH
IF KEYWORD_SET(fsmth) THEN smth_on = 1b ELSE smth_on = 0b
;;  Check ZRANGE
testz          = test_plot_axis_range(zrange,/NOMSSG)
IF (testz[0]) THEN mnmx_zra = zrange
;;----------------------------------------------------------------------------------------
;;  Load WAVES data into TPLOT
;;----------------------------------------------------------------------------------------
yscl           = 'lin'
waves_tnr_rad_to_tplot,FLOW=fl,FHIGH=fu,YSCL=yscl,TRANGE=tran
;;----------------------------------------------------------------------------------------
;;  Get WAVES data fram TPLOT
;;----------------------------------------------------------------------------------------
tnr__tpn       = tnames('TNR_'+mdate[0])
rad1_tpn       = tnames('RAD1_'+mdate[0])
rad2_tpn       = tnames('RAD2_'+mdate[0])
get_data,tnr__tpn[0],DATA=tnr__struc,DLIMIT=dlim__tnr,LIMIT=lim__tnr
get_data,rad1_tpn[0],DATA=rad1_struc,DLIMIT=dlim_rad1,LIMIT=lim_rad1
get_data,rad2_tpn[0],DATA=rad2_struc,DLIMIT=dlim_rad2,LIMIT=lim_rad2
test           = (SIZE(tnr__struc,/TYPE) NE 8) OR (SIZE(rad1_struc,/TYPE) NE 8) OR $
                 (SIZE(rad2_struc,/TYPE) NE 8)
IF (test[0]) THEN BEGIN
  ;;  No WAVES files were found
  MESSAGE,nodatamssg[0],/INFORMATIONAL,/CONTINUE
  RETURN
ENDIF
;;----------------------------------------------------------------------------------------
;;  Define parameters
;;----------------------------------------------------------------------------------------
;;  Define time stamps
unix__tnr      = t_get_struc_unix(tnr__struc,TSHFT_ON=tnr__tshft_on)     ;;  [N]-Element array of Unix times
unix_rad1      = t_get_struc_unix(rad1_struc,TSHFT_ON=rad1_tshft_on)     ;;  [K]-Element array of Unix times
unix_rad2      = t_get_struc_unix(rad2_struc,TSHFT_ON=rad2_tshft_on)     ;;  [J]-Element array of Unix times
n__tnr         = N_ELEMENTS(unix__tnr)
dumb_y_rad12   = REPLICATE(d,n__tnr[0],def_nf_rad1[0])
;;  First define V tag data, as t_resample_tplot_struc.pro will ignore it being that it's 1D and not 2D
freq_rad1      = struct_value(rad1_struc,'V',DEFAULT=0d0)                ;;  [FT]-Element array of frequencies [kHz]
freq_rad2      = struct_value(rad2_struc,'V',DEFAULT=0d0)                ;;  [FT]-Element array of frequencies [kHz]
;;  Interpolate to TNR time stamps
rad1_str_at_t  = t_resample_tplot_struc(rad1_struc,unix__tnr,/NO_EXTRAPOLATE,/IGNORE_INT)
rad2_str_at_t  = t_resample_tplot_struc(rad2_struc,unix__tnr,/NO_EXTRAPOLATE,/IGNORE_INT)
;;  Redefine output
test           = (SIZE(rad1_str_at_t,/TYPE) NE 8) OR (SIZE(rad2_str_at_t,/TYPE) NE 8)
IF (test[0]) THEN BEGIN
  IF (SIZE(rad1_str_at_t,/TYPE) NE 8) THEN BEGIN
    rad1_str_at_t = {X:unix__tnr,Y:dumb_y_rad12,V:def_ff_rad1,SPEC:1}
  ENDIF
  IF (SIZE(rad2_str_at_t,/TYPE) NE 8) THEN BEGIN
    rad2_str_at_t = {X:unix__tnr,Y:dumb_y_rad12,V:def_ff_rad2,SPEC:1}
  ENDIF
ENDIF
rad1_stru1     = rad1_str_at_t
rad2_stru1     = rad2_str_at_t
;;  Clean up
delete_variable,rad1_str_at_t,rad2_str_at_t,dumb_y_rad12
;;  Define data arrays [dB]
data__tnr      = struct_value(tnr__struc,'Y',DEFAULT=0d0)                ;;  [N,FT]-Element array of decibels above background
data_rad1      = struct_value(rad1_stru1,'Y',DEFAULT=0d0)                ;;  [N,FT]-Element array of decibels above background
data_rad2      = struct_value(rad2_stru1,'Y',DEFAULT=0d0)                ;;  [N,FT]-Element array of decibels above background
;;  Define frequency arrays [kHz]
freq__tnr      = struct_value(tnr__struc,'V',DEFAULT=0d0)                ;;  [FT]-Element array of frequencies [kHz]
;;----------------------------------------------------------------------------------------
;;  Merge data and frequency arrays
;;----------------------------------------------------------------------------------------
nf__tnr        = N_ELEMENTS(freq__tnr)
nf_rad1        = N_ELEMENTS(freq_rad1)
nf_rad2        = N_ELEMENTS(freq_rad2)
nf__all        = nf__tnr[0] + nf_rad1[0] + nf_rad2[0]
dumb_y         = REPLICATE(d,n__tnr[0],nf__all[0])
dumb_v         = REPLICATE(d,nf__all[0])
;;  Define frequency array
dumb_v         = [freq__tnr,freq_rad1,freq_rad2]
;;  Define data array
lh             = [0L,(nf__tnr[0] - 1L)]
ind            = fill_range(lh[0],lh[1],DIND=1)
dumb_y[*,ind]  = data__tnr
lh             = nf__tnr[0] + [0L,(nf_rad1[0] - 1L)]
ind            = fill_range(lh[0],lh[1],DIND=1)
dumb_y[*,ind]  = data_rad1
lh             = nf__tnr[0] + nf_rad1[0] + [0L,(nf_rad2[0] - 1L)]
ind            = fill_range(lh[0],lh[1],DIND=1)
dumb_y[*,ind]  = data_rad2
;;  Sort by frequency
sp             = SORT(dumb_v)
dumb_v         = dumb_v[sp]
dumb_y         = dumb_y[*,sp]
IF (smth_on[0]) THEN BEGIN
  temp = dumb_y
  bad  = WHERE(FINITE(dumb_y) EQ 0 OR dumb_y LE 0,bd)
  IF (bd[0] GT 0) THEN temp[bad] = d
  dumb_y = SMOOTH(temp,3L,/EDGE_ZERO,/EDGE_TRUNCATE,/NAN,MISSING=0d0)
ENDIF
;;----------------------------------------------------------------------------------------
;;  Define TPLOT output variables
;;----------------------------------------------------------------------------------------
wav_struc      = {X:unix__tnr,Y:dumb_y,V:dumb_v,SPEC:1}
wav_tpn        = 'Wind_WAVES_radio_spectra'
yran           = lbw_calc_yrange(dumb_v,PERC_EX=1d-1,MIN_VALUE=min_flow[0],MAX_VALUE=max_fhig[0])
zran           = lbw_calc_yrange(dumb_y,PERC_EX= 0d0,MIN_VALUE=mnmx_zra[0],MAX_VALUE=mnmx_zra[1],/LOG)
;;  Check for YTICKV
def_ytickv     = tick_struc.YTICKV
def_ytickn     = tick_struc.YTICKNAME
good_ytv       = WHERE(yran[0] LE def_ytickv AND yran[1] GE def_ytickv,gd_ytv)
IF (gd_ytv[0] GT 0) THEN BEGIN
  ytickv   = def_ytickv[good_ytv]
  ytickn   = def_ytickn[good_ytv]
ENDIF ELSE BEGIN
  ytickv   = yran*[1.02,0.98]
  ytickn   = num2flt_str(ytickv,NUM_DEC=1)
ENDELSE
yticks         = N_ELEMENTS(ytickv) - 1L
;;  Define LIMITS structures
wav__lim       = def__lim
wav_dlim       = def_dlim
str_element,wav_dlim,   'YTICKV',ytickv,/ADD_REPLACE
str_element,wav_dlim,'YTICKNAME',ytickn,/ADD_REPLACE
str_element,wav_dlim,   'YTICKS',yticks,/ADD_REPLACE
str_element,wav_dlim,   'YRANGE',  yran,/ADD_REPLACE
str_element,wav_dlim,   'ZRANGE',  zran,/ADD_REPLACE
;;----------------------------------------------------------------------------------------
;;  Send to TPLOT
;;----------------------------------------------------------------------------------------
store_data,wav_tpn[0],DATA=wav_struc,DLIMIT=wav_dlim,LIMIT=wav__lim
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN
END













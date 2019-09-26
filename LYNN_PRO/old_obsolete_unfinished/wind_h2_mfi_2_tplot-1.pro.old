;+
;*****************************************************************************************
;
;  PROCEDURE:   wind_h2_mfi_2_tplot.pro
;  PURPOSE  :   This is a wrapping routine for cdf2tplot.pro specific to the Wind MFI
;                 H2 CDF files from CDAWeb (i.e., the high time resolution data).  The
;                 user-specified CDF variables are sent to TPLOT and the TPLOT handles
;                 are re-named and options are set accordingly.
;
;  CALLED BY:   
;               NA
;
;  INCLUDES:
;               NA
;
;  CALLS:
;               get_os_slash.pro
;               is_a_number.pro
;               get_valid_trange.pro
;               add_os_slash.pro
;               general_find_files_from_trange.pro
;               cdf2tplot.pro
;               get_data.pro
;               store_data.pro
;               trange_clip_data.pro
;               mag__vec.pro
;               sample_rate.pro
;               str_element.pro
;               extract_tags.pro
;               options.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;               2)  MFI H2 CDF files from
;                     http://cdaweb.gsfc.nasa.gov/
;
;  INPUT:
;               NA
;
;  EXAMPLES:    
;               [calling sequence]
;               wind_h2_mfi_2_tplot [,/LOAD_GSE] [,/LOAD_GSM]                   $
;                                   [,TDATE=tdate] [,TRANGE=trange]
;
;  KEYWORDS:    
;               LOAD_GSE  :  If set, routine loads all the variables in the GSE
;                              coordinate basis
;                              [Default = TRUE]
;               LOAD_GSM  :  If set, routine loads all the variables in the GSM
;                              coordinate basis
;                              [Default = FALSE]
;               TDATE     :  Scalar [string] defining the date of interest of the form:
;                              'YYYY-MM-DD' [MM=month, DD=day, YYYY=year]
;                              [Default = prompted by get_valid_trange.pro]
;               TRANGE    :  [2]-Element [double] array specifying the Unix time
;                              range for which to limit the data in DATA
;                              [Default = prompted by get_valid_trange.pro]
;
;   CHANGED:  1)  Now correctly removes data outside time range and
;                   now calls trange_clip_data.pro and
;                   can now handle TSHIFT structure tag for TPLOT structures
;                                                                   [04/21/2016   v1.1.0]
;
;   NOTES:      
;               1)  This routine should be used in place of read_wind_htr_mfi.pro
;
;  REFERENCES:  
;               1)  Lepping et al., (1995), "The Wind Magnetic Field Investigation,"
;                      Space Sci. Rev. Vol. 71, pp. 207-229.
;               2)  Harten, R. and K. Clark (1995), "The Design Features of the GGS
;                      Wind and Polar Spacecraft," Space Sci. Rev. Vol. 71, pp. 23-40.
;               3)  Koval, A. and A. Szabo (2013), "Magnetic Field Turbulence Spectra
;                      Observed By The Wind Spacecraft," Proc. 13th Intl. Solar Wind
;                      Conf. Vol. 1539, pp. 211-214, doi:10.1063/1.4811025.
;
;   CREATED:  04/13/2016
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  04/21/2016   v1.1.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

PRO wind_h2_mfi_2_tplot,LOAD_GSE=load_gse,LOAD_GSM=load_gsm,TDATE=tdate,TRANGE=trange

;;----------------------------------------------------------------------------------------
;;  Constants
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
slash          = get_os_slash()       ;;  '/' for Unix, '\' for Windows
;;  CDF Variable names
epoch_names    = ['EPOCH']
b_v_gse_names  = ['BGSE']
b_v_gsm_names  = ['BGSM']
;;  Define TPLOT handles associated with all of these
sc             = 'Wind'
scpref         = sc[0]+'_'
coord_gse      = 'gse'
coord_gsm      = 'gsm'
coord_mag      = 'mag'
coord_gseu     = STRUPCASE(coord_gse[0])
coord_gsmu     = STRUPCASE(coord_gsm[0])
b_v_gse_tpns   = scpref[0]+'B_htr_'+coord_gse[0]
b_v_gsm_tpns   = scpref[0]+'B_htr_'+coord_gsm[0]
;;  Define YTITLEs and YSUBTITLEs associated with all of these
yttl_b_gse_tpn = 'B [nT, '+coord_gseu[0]+']'
ysub_b_gse_tpn = '[HTR Res.]'       ;;  change later
yttl_b_gsm_tpn = 'B [nT, '+coord_gsmu[0]+']'
ysub_b_gsm_tpn = ysub_b_gse_tpn
;;  Define units and coordinates associated with all of these
unit_b_gse_tpn = 'nT'
unit_b_gsm_tpn = unit_b_gse_tpn
coor_b_gse_tpn = coord_gse[0]
coor_b_gsm_tpn = coord_gsm[0]
;;----------------------------------------------------------------------------------------
;;  Defaults
;;----------------------------------------------------------------------------------------
def____gse     = 1b
def____gsm     = 0b
;;  Default CDF file location
def_cdfloc     = '.'+slash[0]+'wind_3dp_pros'+slash[0]+'wind_data_dir'+slash[0]+$
                 'HTR_MFI_CDF'+slash[0]
;;  Default TPLOT stuff
vec_str        = ['x','y','z']
vec_col        = [250,200,75]
mag_str        = [vec_str,'mag']
mag_col        = [vec_col,25L]
def__lim       = {YSTYLE:1,PANEL_SIZE:2.,XMINOR:5,XTICKLEN:0.04,YTICKLEN:0.01}
def_dlim       = {LOG:0,SPEC:0,COLORS:50L,LABELS:'1',LABFLAG:-1}
;;----------------------------------------------------------------------------------------
;;  Check keywords
;;----------------------------------------------------------------------------------------
;;  Check LOAD_GSE
test           = ~KEYWORD_SET(load_gse) AND (N_ELEMENTS(load_gse) GT 0)
IF (test[0]) THEN gse_on = 0b ELSE gse_on = def____gse[0]
;;  Check LOAD_GSM
test           = KEYWORD_SET(load_gsm) AND (N_ELEMENTS(load_gsm) GT 0)
IF (test[0]) THEN gsm_on = 1b ELSE gsm_on = def____gsm[0]
;;  Check TDATE and TRANGE
test           = ((N_ELEMENTS(tdate) GT 0) AND (SIZE(tdate,/TYPE) EQ 7)) OR $
                 ((N_ELEMENTS(trange) EQ 2) AND is_a_number(trange,/NOMSSG))
IF (test[0]) THEN BEGIN
  ;;  At least one is set --> use that one
  test           = ((N_ELEMENTS(tdate) GT 0) AND (SIZE(tdate,/TYPE) EQ 7))
  IF (test[0]) THEN time_ra = get_valid_trange(TDATE=tdate) ELSE time_ra = get_valid_trange(TRANGE=trange)
ENDIF ELSE BEGIN
  ;;  Prompt user and ask user for date/times
  time_ra        = get_valid_trange(TDATE=tdate,TRANGE=trange)
ENDELSE
;;  Define dates and time ranges
tra            = time_ra.UNIX_TRANGE
tdates         = time_ra.DATE_TRANGE        ;;  'YYYY-MM-DD'  e.g., '2009-07-13'
tdate          = tdates[0]                  ;;  Redefine TDATE on output
;;  Convert TDATEs to format used by CDF files [e.g., 'YYYYMMDD']
fdates         = STRMID(tdates,0L,4L)+STRMID(tdates,5L,2L)+STRMID(tdates,8L,2L)
;;----------------------------------------------------------------------------------------
;;  See if user wants to load anything
;;----------------------------------------------------------------------------------------
test           = ~gse_on[0] AND ~gsm_on[0]
IF (test[0]) THEN BEGIN
  errmsg = 'User shut off all coordinate systems:  Using default [GSE] coordinates...'
  MESSAGE,errmsg[0],/INFORMATIONAL,/CONTINUE
  gse_on = 1b
ENDIF
;;----------------------------------------------------------------------------------------
;;  Define CDF file location
;;----------------------------------------------------------------------------------------
DEFSYSV,'!wind3dp_umn',EXISTS=exists
IF ~KEYWORD_SET(exists) THEN BEGIN
  cdfdir = add_os_slash(FILE_EXPAND_PATH(def_cdfloc[0]))
ENDIF ELSE BEGIN
  cdfdir = !wind3dp_umn.WIND_HTR_MFI_CDF_DIR
  IF (cdfdir[0] EQ '') THEN cdfdir = add_os_slash(FILE_EXPAND_PATH(def_cdfloc[0]))
ENDELSE
;;----------------------------------------------------------------------------------------
;;  Get CDF files within time range
;;----------------------------------------------------------------------------------------
date_form      = 'YYYYMMDD'
files          = general_find_files_from_trange(cdfdir[0],date_form[0],TRANGE=tra)
test           = (SIZE(files,/TYPE) NE 7)
IF (test[0]) THEN BEGIN
  errmsg = 'Exiting without loading any TPLOT variables...'
  MESSAGE,errmsg[0],/INFORMATIONAL,/CONTINUE
  RETURN
ENDIF
test           = (files[0] EQ '')
IF (test[0]) THEN BEGIN
  errmsg = 'Exiting without loading any TPLOT variables...'
  MESSAGE,errmsg[0],/INFORMATIONAL,/CONTINUE
  RETURN
ENDIF
;;----------------------------------------------------------------------------------------
;;  Determine which CDF variables to load
;;----------------------------------------------------------------------------------------
IF (~gse_on[0]) THEN BEGIN
  ;;  Shutoff CDF variables associated with GSE coordinates
  b_v_gse_names[0]  = ''
ENDIF
IF (~gsm_on[0]) THEN BEGIN
  ;;  Shutoff CDF variables associated with GSM coordinates
  b_v_gsm_names[0]  = ''
ENDIF
;;----------------------------------------------------------------------------------------
;;  Define all parameters
;;----------------------------------------------------------------------------------------
;;  CDF variable names
cdf_vars       = [b_v_gse_names,b_v_gsm_names]
;;  TPLOT handles
all_tpns       = [b_v_gse_tpns,b_v_gsm_tpns]
;;  TPLOT YTITLEs
all_yttls      = [yttl_b_gse_tpn,yttl_b_gsm_tpn]
;;  TPLOT YSUBTITLEs
all_ysubs      = [ysub_b_gse_tpn,ysub_b_gsm_tpn]
;;  Data units
all_units      = [unit_b_gse_tpn,unit_b_gsm_tpn]
;;  Coordinate basis
all_coord      = [coor_b_gse_tpn,coor_b_gsm_tpn]
;;  Determine which variables to load
good_vars      = WHERE(cdf_vars NE '',gd_vars)
IF (gd_vars[0] EQ 0) THEN BEGIN
  errmsg = 'User wants to load no CDF variables:  Exiting without loading any TPLOT variables...'
  MESSAGE,errmsg[0],/INFORMATIONAL,/CONTINUE
  RETURN
ENDIF
g_cdf_vars     = STRLOWCASE(cdf_vars[good_vars])
g_all_tpns     = all_tpns[good_vars]
g_all_yttls    = all_yttls[good_vars]
g_all_ysubs    = all_ysubs[good_vars]
g_all_units    = all_units[good_vars]
g_all_coord    = all_coord[good_vars]
ng             = gd_vars[0]
;;----------------------------------------------------------------------------------------
;;  Load CDF variables into TPLOT
;;----------------------------------------------------------------------------------------
;;  Load data into TPLOT
cdf2tplot,FILES=files,VARFORMAT=STRUPCASE(g_cdf_vars),VARNAMES=varnames,$
          TPLOTNAMES=tplotnames,/CONVERT_INT1_TO_INT2
test           = (tplotnames[0] EQ '')
IF (test[0]) THEN BEGIN
  errmsg = 'User did not load any data into TPLOT...'
  MESSAGE,errmsg[0],/INFORMATIONAL,/CONTINUE
  RETURN
ENDIF
;;  Check if order of VARNAMES differs from input
nv             = N_ELEMENTS(varnames)          ;;  # of variables loaded
FOR j=0L, nv[0] - 1L DO BEGIN
  good0 = WHERE(STRLOWCASE(varnames[j]) EQ g_cdf_vars,gd0)
  IF (gd0 EQ 0) THEN CONTINUE         ;;  Move on to next iteration
  IF (j EQ 0) THEN gindv = good0[0] ELSE gindv = [gindv,good0[0]]
  good0 = WHERE(STRLOWCASE(tplotnames[j]) EQ g_cdf_vars,gd0)
  IF (gd0 EQ 0) THEN CONTINUE         ;;  Move on to next iteration
  IF (j EQ 0) THEN gindt = good0[0] ELSE gindt = [gindt,good0[0]]
ENDFOR
;;  Re-order inputs
o_cdf_vars     = g_cdf_vars[gindv]
o_all_tpns     = g_all_tpns[gindt]
o_all_yttls    = g_all_yttls[gindt]
o_all_ysubs    = g_all_ysubs[gindt]
o_all_units    = g_all_units[gindt]
o_all_coord    = g_all_coord[gindt]
;;----------------------------------------------------------------------------------------
;;  Rename TPLOT handles and remove originals
;;----------------------------------------------------------------------------------------
ntpn           = N_ELEMENTS(tplotnames)
FOR j=0L, ntpn[0] - 1L DO BEGIN
  ;;  Reset TSHIFT variable
  IF (N_ELEMENTS(tshift) GT 0) THEN dumb = TEMPORARY(tshift)
;  get_data,tplotnames[j],DATA=temp,DLIM=dlim,LIM=lim
  get_data,tplotnames[j],DATA=temp0,DLIM=dlim,LIM=lim
  ;;  Remove original
  store_data,DELETE=tplotnames[j]
  ;;  Define elements within time range
  temp   = trange_clip_data(temp0,TRANGE=tra,PREC=3)
  test   = (SIZE(temp,/TYPE) NE 8)
  IF (test[0]) THEN BEGIN
    ;;  No data within time range
    errmsg = 'No data within TRANGE for TPLOT variable '+o_all_tpns[j]
    MESSAGE,errmsg[0],/INFORMATIONAL,/CONTINUE
    CONTINUE
  ENDIF
  ;;  Define vector and magnitudes
  t_tim  = temp.X
  t_vec  = temp.Y
  str_element,data,'TSHIFT',tshift
  t_mag  = mag__vec(t_vec,/NAN)
  ;;  Remove "bad" data points (i.e., those with |B| > 40000 nT)
  test   = (ABS(t_vec[*,0]) GE 4d4) OR (ABS(t_vec[*,1]) GE 4d4) OR $
           (ABS(t_vec[*,2]) GE 4d4) OR (ABS(t_mag) GE 4d4)
  bad    = WHERE(test,bd)
  IF (bd GT 0 AND o_all_units[j] EQ 'nT') THEN BEGIN
    t_vec[bad,*] = f
    t_mag[bad]   = f
  ENDIF
  ;;  Determine sample rate [sps] and define YSUBTITLE
  smrate  = sample_rate(t_tim,GAP_THRESH=1d0/5d0,/AVE)
  strsmr  = STRTRIM(STRING(FORMAT='(f15.2)',smrate[0]),2L)
  ysubt   = '['+strsmr[0]+' sps Res.]'
  t_out  = [[t_vec],[t_mag]]
  struc  = temp
  str_element,struc,'Y',t_out,/ADD_REPLACE
;  struc  = {X:temp.X,Y:t_out}
  ;;  Check for TSHIFT
;  IF (N_ELEMENTS(tshift) GT 0) THEN str_element,struc,'TSHIFT',tshift[0],/ADD_REPLACE  ;;  Add TSHIFT (if present)
  str_element,dlim,            'YTITLE',o_all_yttls[j],/ADD_REPLACE      ;;  Add Y-axis title
  str_element,dlim,         'YSUBTITLE',      ysubt[0],/ADD_REPLACE      ;;  Add Y-axis subtitle
  str_element,dlim,    'DATA_ATT.UNITS',o_all_units[j],/ADD_REPLACE      ;;  Add units to data attributes structure
  str_element,dlim,'DATA_ATT.COORD_SYS',o_all_coord[j],/ADD_REPLACE      ;;  Add coordinate basis
  extract_tags,dlim,def_dlim,EXCEPT_TAGS=['COLORS','LABELS']
  extract_tags,lim,def__lim
  ;;  Send data back to TPLOT
  store_data,o_all_tpns[j],DATA=struc,DLIM=dlim,LIM=lim
  options,o_all_tpns[j],COLORS=mag_col,LABELS=mag_str,/DEF
ENDFOR
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN
END
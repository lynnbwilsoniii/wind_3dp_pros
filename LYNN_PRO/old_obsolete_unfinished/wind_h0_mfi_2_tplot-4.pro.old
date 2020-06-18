;+
;*****************************************************************************************
;
;  PROCEDURE:   wind_h0_mfi_2_tplot.pro
;  PURPOSE  :   This is a wrapping routine for cdf2tplot.pro specific to the Wind MFI
;                 H0 CDF files from CDAWeb.  The user-specified CDF variables are sent
;                 to TPLOT and the TPLOT handles are re-named and options are set
;                 accordingly.
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
;               2)  MFI H0 CDF files from
;                     http://cdaweb.gsfc.nasa.gov/
;
;  INPUT:
;               NA
;
;  EXAMPLES:    
;               [calling sequence]
;               wind_h0_mfi_2_tplot [,/B1HOUR] [,/B1MIN] [,/B3SEC] [,/SCPOSI]   $
;                                   [,/LOAD_GSE] [,/LOAD_GSM]                   $
;                                   [,TDATE=tdate] [,TRANGE=trange]
;
;  KEYWORDS:    
;               B1HOUR    :  If set, routine loads 1 hour resolution magnetic field
;                              data [nT] and sends results to TPLOT
;                              [Default = FALSE]
;               B1MIN     :  If set, routine loads 1 minute resolution magnetic field
;                              data [nT] and sends results to TPLOT
;                              [Default = FALSE]
;               B3SEC     :  If set, routine loads 3 second resolution magnetic field
;                              data [nT] and sends results to TPLOT
;                              [Default = TRUE]
;               SCPOSI    :  If set, routine loads the spacecraft position [Re] at every
;                              resolution selected by the user for the magnetic fields
;                              [Default = FALSE]
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
;   CHANGED:  1)  Continued to write routine
;                                                                   [04/08/2016   v1.0.0]
;             2)  Continued to write routine
;                                                                   [04/08/2016   v1.0.0]
;             3)  Finished writing routine
;                                                                   [04/13/2016   v1.0.0]
;             4)  Fixed a bug that switched 1 min and 1 hour resolution TPLOT handles
;                   and now correctly removes data outside time range and now calls
;                   sample_rate.pro and trange_clip_data.pro
;                                                                   [04/21/2016   v1.1.0]
;
;   NOTES:      
;               1)  This routine should be used in place of read_wind_mfi.pro
;
;  REFERENCES:  
;               1)  Lepping et al., (1995), "The Wind Magnetic Field Investigation,"
;                      Space Sci. Rev. Vol. 71, pp. 207-229.
;               2)  Harten, R. and K. Clark (1995), "The Design Features of the GGS
;                      Wind and Polar Spacecraft," Space Sci. Rev. Vol. 71, pp. 23-40.
;
;   CREATED:  04/08/2016
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  04/21/2016   v1.1.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

PRO wind_h0_mfi_2_tplot,B1HOUR=b1hour,B1MIN=b1min,B3SEC=b3sec,SCPOSI=scposi,$
                        LOAD_GSE=load_gse,LOAD_GSM=load_gsm,                $
                        TDATE=tdate,TRANGE=trange

;;----------------------------------------------------------------------------------------
;;  Constants
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
slash          = get_os_slash()       ;;  '/' for Unix, '\' for Windows
;;  CDF Variable names
epoch_names    = ['EPOCH','EPOCH1','EPOCH3']
b_v_gse_names  = ['BGSE','B1GSE','B3GSE']
b_v_gsm_names  = ['BGSM','B1GSM','B3GSM']
scpos_gse_nms  = ['PGSE','P1GSE','']
scpos_gsm_nms  = ['PGSM','P1GSM','']
;;  Define TPLOT handles associated with all of these
sc             = 'Wind'
scpref         = sc[0]+'_'
coord_gse      = 'gse'
coord_gsm      = 'gsm'
coord_mag      = 'mag'
coord_gseu     = STRUPCASE(coord_gse[0])
coord_gsmu     = STRUPCASE(coord_gsm[0])
b_v_gse_tpns   = scpref[0]+'B_'+['1min','1hr','3sec']+'_'+coord_gse[0]
b_v_gsm_tpns   = scpref[0]+'B_'+['1min','1hr','3sec']+'_'+coord_gsm[0]
scpos_gse_tpn  = scpref[0]+'SCPos_'+['1min','1hr','']+'_'+coord_gse[0]
scpos_gsm_tpn  = scpref[0]+'SCPos_'+['1min','1hr','']+'_'+coord_gsm[0]
;b_v_gse_tpns   = scpref[0]+'B_'+['1hr','1min','3sec']+'_'+coord_gse[0]
;b_v_gsm_tpns   = scpref[0]+'B_'+['1hr','1min','3sec']+'_'+coord_gsm[0]
;scpos_gse_tpn  = scpref[0]+'SCPos_'+['1hr','1min','']+'_'+coord_gse[0]
;scpos_gsm_tpn  = scpref[0]+'SCPos_'+['1hr','1min','']+'_'+coord_gsm[0]
;;  Define YTITLEs and YSUBTITLEs associated with all of these
yttl_b_gse_tpn = REPLICATE('B [nT, '+coord_gseu[0]+']',3L)
ysub_b_gse_tpn = '['+['1min','1hr','3sec']+' Res.]'
;ysub_b_gse_tpn = '['+['1hr','1min','3sec']+' Res.]'
yttl_b_gsm_tpn = REPLICATE('B [nT, '+coord_gsmu[0]+']',3L)
ysub_b_gsm_tpn = ysub_b_gse_tpn
yttl_p_gse_tpn = REPLICATE('SC Pos. [Re, '+coord_gseu[0]+']',3L)
ysub_p_gse_tpn = ysub_b_gse_tpn
yttl_p_gsm_tpn = REPLICATE('SC Pos. [Re, '+coord_gsmu[0]+']',3L)
ysub_p_gsm_tpn = ysub_b_gse_tpn
;;  Define units and coordinates associated with all of these
unit_b_gse_tpn = REPLICATE('nT',3L)
unit_b_gsm_tpn = unit_b_gse_tpn
unit_p_gse_tpn = REPLICATE('Re',3L)
unit_p_gsm_tpn = unit_p_gse_tpn
coor_b_gse_tpn = REPLICATE(coord_gse[0],3L)
coor_b_gsm_tpn = REPLICATE(coord_gsm[0],3L)
coor_p_gse_tpn = REPLICATE(coord_gse[0],3L)
coor_p_gsm_tpn = REPLICATE(coord_gsm[0],3L)
;;----------------------------------------------------------------------------------------
;;  Defaults
;;----------------------------------------------------------------------------------------
def_b1hour     = 0b
def__b1min     = 0b
def__b3sec     = 1b
def_scposi     = 0b
def__scvel     = 0b
def____gse     = 1b
def____gsm     = 0b
;;  Default CDF file location
def_cdfloc     = '.'+slash[0]+'wind_3dp_pros'+slash[0]+'wind_data_dir'+slash[0]+$
                 'MFI_CDF'+slash[0]
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
;;  Check B1HOUR
test           = KEYWORD_SET(b1hour) AND (N_ELEMENTS(b1hour) GT 0)
IF (test[0]) THEN mag1h_on = 1b ELSE mag1h_on = def_b1hour[0]
;;  Check B1MIN
test           = KEYWORD_SET(b1min) AND (N_ELEMENTS(b1min) GT 0)
IF (test[0]) THEN mag1m_on = 1b ELSE mag1m_on = def__b1min[0]
;;  Check B3SEC
test           = ~KEYWORD_SET(b3sec) AND (N_ELEMENTS(b3sec) GT 0)
IF (test[0]) THEN mag3s_on = 0b ELSE mag3s_on = def__b3sec[0]
;;  Check SCPOSI
test           = KEYWORD_SET(scposi) AND (N_ELEMENTS(scposi) GT 0)
IF (test[0]) THEN scpos_on = 1b ELSE scpos_on = def_scposi[0]
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
test           = ~mag1h_on[0] AND ~mag1m_on[0] AND ~mag3s_on[0] AND ~scpos_on[0]
IF (test[0]) THEN BEGIN
  errmsg = 'User shut off all CDF variables:  Exiting without loading any TPLOT variables...'
  MESSAGE,errmsg[0],/INFORMATIONAL,/CONTINUE
  RETURN
ENDIF
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
  cdfdir = !wind3dp_umn.WIND_MFI_CDF_DIR
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
cdf_vars       = ''
IF (~mag1h_on[0]) THEN BEGIN
  ;;  Shutoff CDF variables associated with 1 hour Avg. B-field data
  epoch_names[1]    = ''
  b_v_gse_names[1]  = ''
  b_v_gsm_names[1]  = ''
  scpos_gse_nms[1]  = ''
  scpos_gsm_nms[1]  = ''
ENDIF
IF (~mag1m_on[0]) THEN BEGIN
  ;;  Shutoff CDF variables associated with 1 minute Avg. B-field data
  epoch_names[0]    = ''
  b_v_gse_names[0]  = ''
  b_v_gsm_names[0]  = ''
  scpos_gse_nms[0]  = ''
  scpos_gsm_nms[0]  = ''
ENDIF
IF (~mag3s_on[0]) THEN BEGIN
  ;;  Shutoff CDF variables associated with 3 second Avg. B-field data
  epoch_names[2]    = ''
  b_v_gse_names[2]  = ''
  b_v_gsm_names[2]  = ''
  scpos_gse_nms[2]  = ''
  scpos_gsm_nms[2]  = ''
ENDIF
IF (~scpos_on[0]) THEN BEGIN
  ;;  Shutoff CDF variables associated with spacecraft positions
  scpos_gse_nms[*]  = ''
  scpos_gsm_nms[*]  = ''
ENDIF
IF (~gse_on[0]) THEN BEGIN
  ;;  Shutoff CDF variables associated with GSE coordinates
  b_v_gse_names[*]  = ''
  scpos_gse_nms[*]  = ''
ENDIF
IF (~gsm_on[0]) THEN BEGIN
  ;;  Shutoff CDF variables associated with GSM coordinates
  b_v_gsm_names[*]  = ''
  scpos_gsm_nms[*]  = ''
ENDIF
;;----------------------------------------------------------------------------------------
;;  Define all parameters
;;----------------------------------------------------------------------------------------
;;  CDF variable names
cdf_vars       = [b_v_gse_names,b_v_gsm_names,scpos_gse_nms,scpos_gsm_nms]
;;  TPLOT handles
all_tpns       = [b_v_gse_tpns,b_v_gsm_tpns,scpos_gse_tpn,scpos_gsm_tpn]
;;  TPLOT YTITLEs
all_yttls      = [yttl_b_gse_tpn,yttl_b_gsm_tpn,yttl_p_gse_tpn,yttl_p_gsm_tpn]
;;  TPLOT YSUBTITLEs
all_ysubs      = [ysub_b_gse_tpn,ysub_b_gsm_tpn,ysub_p_gse_tpn,ysub_p_gsm_tpn]
;;  Data units
all_units      = [unit_b_gse_tpn,unit_b_gsm_tpn,unit_p_gse_tpn,unit_p_gsm_tpn]
;;  Coordinate basis
all_coord      = [coor_b_gse_tpn,coor_b_gsm_tpn,coor_p_gse_tpn,coor_p_gsm_tpn]
;;  Determine which variables to load
good_vars      = WHERE(cdf_vars NE '',gd_vars)
IF (gd_vars[0] EQ 0) THEN BEGIN
  errmsg = 'User wants to load no CDF variables:  Exiting without loading any TPLOT variables...'
  MESSAGE,errmsg[0],/INFORMATIONAL,/CONTINUE
  RETURN
ENDIF
g_cdf_vars     = cdf_vars[good_vars]                 ;;  Case sensitive
;g_cdf_vars     = STRLOWCASE(cdf_vars[good_vars])
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
cdf2tplot,FILES=files,VARFORMAT=g_cdf_vars,VARNAMES=varnames,$
          TPLOTNAMES=tplotnames,/CONVERT_INT1_TO_INT2
;cdf2tplot,FILES=files,VARFORMAT=STRUPCASE(g_cdf_vars),VARNAMES=varnames,$
;          TPLOTNAMES=tplotnames,/CONVERT_INT1_TO_INT2
test           = (tplotnames[0] EQ '')
IF (test[0]) THEN BEGIN
  errmsg = 'User did not load any data into TPLOT...'
  MESSAGE,errmsg[0],/INFORMATIONAL,/CONTINUE
  RETURN
ENDIF
;;  Check if order of VARNAMES differs from input
nv             = N_ELEMENTS(varnames)          ;;  # of variables loaded
FOR j=0L, nv[0] - 1L DO BEGIN
  good0 = WHERE(varnames[j] EQ g_cdf_vars,gd0)
;  good0 = WHERE(STRLOWCASE(varnames[j]) EQ g_cdf_vars,gd0)
  IF (gd0 EQ 0) THEN CONTINUE         ;;  Move on to next iteration
  IF (j EQ 0) THEN gindv = good0[0] ELSE gindv = [gindv,good0[0]]
  good0 = WHERE(tplotnames[j] EQ g_cdf_vars,gd0)
;  good0 = WHERE(STRLOWCASE(tplotnames[j]) EQ g_cdf_vars,gd0)
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
  diff    = ABS(SHIFT(t_tim,-1) - t_tim)
  smrate  = sample_rate(t_tim,GAP_THRESH=diff[0]*1.1,/AVE)
  spperi  = 1d0/smrate[0]
  strsmr  = STRTRIM(STRING(FORMAT='(f15.1)',spperi[0]),2L)
  ysubt   = '[Res.: '+strsmr[0]+' sec]'
  t_out  = [[t_vec],[t_mag]]
  struc  = temp
  str_element,struc,'Y',t_out,/ADD_REPLACE
;  struc  = {X:temp.X,Y:t_out}
  str_element,dlim,            'YTITLE',o_all_yttls[j],/ADD_REPLACE      ;;  Add Y-axis title
  str_element,dlim,         'YSUBTITLE',      ysubt[0],/ADD_REPLACE      ;;  Add Y-axis subtitle
;  str_element,dlim,         'YSUBTITLE',o_all_ysubs[j],/ADD_REPLACE      ;;  Add Y-axis subtitle
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


;+
;*****************************************************************************************
;
;  PROCEDURE:   wind_at_predict_cdf2tplot.pro
;  PURPOSE  :   This routine reads in the CDF files containing the AT data for the
;                 Wind attitude prediction files and sends the results to TPLOT.
;
;  CALLED BY:   
;               NA
;
;  INCLUDES:
;               NA
;
;  CALLS:
;               get_os_slash.pro
;               test_file_path_format.pro
;               get_valid_trange.pro
;               general_find_files_from_trange.pro
;               cdf2tplot.pro
;               tnames.pro
;               get_data.pro
;               store_data.pro
;               trange_clip_data.pro
;               options.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;               2)  Wind AT attitude prediction CDF files from
;                     http://cdaweb.gsfc.nasa.gov/
;
;  INPUT:
;               NA
;
;  EXAMPLES:    
;               [calling sequence]
;               wind_at_predict_cdf2tplot [,TDATE=tdate] [,TRANGE=trange]
;
;  KEYWORDS:    
;               TDATE     :  Scalar [string] defining the date of interest of the form:
;                              'YYYY-MM-DD' [MM=month, DD=day, YYYY=year]
;                              [Default = prompted by get_valid_trange.pro]
;               TRANGE    :  [2]-Element [double] array specifying the Unix time
;                              range for which to limit the data in DATA
;                              [Default = prompted by get_valid_trange.pro]
;
;   CHANGED:  1)  NA
;                                                                   [MM/DD/YYYY   v1.0.0]
;
;   NOTES:      
;               NA
;
;  REFERENCES:  
;               NA
;
;   CREATED:  06/15/2020
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  06/15/2020   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

PRO wind_at_predict_cdf2tplot,TDATE=tdate,TRANGE=trange

;;----------------------------------------------------------------------------------------
;;  Constants
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
slash          = get_os_slash()       ;;  '/' for Unix, '\' for Windows
;;  Define some defaults and dummy variables
sc             = 'Wind'
scpref         = sc[0]+'_'
;;  Define some coordinate strings
coord_gci      = 'gci'
coord_gse      = 'gse'
coord_gsm      = 'gsm'
;;  Define the default TPLOT names chosen by cdf2tplot.pro
def_tpnames    = ['BODY_SPIN_RATE','GCI_R_ASCENSION','GCI_DECLINATION','GSE_R_ASCENSION','GSE_DECLINATION','GSM_R_ASCENSION','GSM_DECLINATION']
;;  Define the new TPLOT names chosen by me
rascdec_pref   = ['rascension_','declination_']
new_tpnames    = scpref[0]+[' ','spin_rate',rascdec_pref+coord_gci[0],rascdec_pref+coord_gse[0],rascdec_pref+coord_gsm[0]]
;;  Default CDF file location
test           = test_file_path_format('.',EXISTS=exists,DIR_OUT=idl_work_dir)
test           = test_file_path_format(idl_work_dir[0]+'wind_3dp_pros'+slash[0],EXISTS=exists,DIR_OUT=umn_3dp_dir)
test           = test_file_path_format(umn_3dp_dir[0]+'wind_data_dir'+slash[0]+'Wind_attitude_predict'+slash[0],EXISTS=exists,DIR_OUT=def_cdfloc)
;;----------------------------------------------------------------------------------------
;;  Check keywords
;;----------------------------------------------------------------------------------------
;;  Check TDATE and TRANGE
time_ra        = get_valid_trange(TDATE=tdate,TRANGE=trange)
;;  Define dates and time ranges
tra            = time_ra.UNIX_TRANGE
tdates         = time_ra.DATE_TRANGE        ;;  'YYYY-MM-DD'  e.g., '2009-07-13'
tdate          = tdates[0]                  ;;  Redefine TDATE on output
;;  Convert TDATEs to format used by CDF files [e.g., 'YYYYMMDD']
fdates         = STRMID(tdates,0L,4L)+STRMID(tdates,5L,2L)+STRMID(tdates,8L,2L)
;;----------------------------------------------------------------------------------------
;;  Define CDF file location
;;----------------------------------------------------------------------------------------
DEFSYSV,'!wind3dp_umn',EXISTS=exists
IF ~KEYWORD_SET(exists) THEN BEGIN
  cdfdir = add_os_slash(FILE_EXPAND_PATH(def_cdfloc[0]))
ENDIF ELSE BEGIN
  cdfdir = !wind3dp_umn.WIND_DATA_DIR[0]+'Wind_attitude_predict'+slash[0]
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
;;  Load CDF variables into TPLOT
;;----------------------------------------------------------------------------------------
;;  Load data into TPLOT
cdf2tplot,FILES=files,VARFORMAT='*',VARNAMES=varnames,TPLOTNAMES=tplotnames,/CONVERT_INT1_TO_INT2
test           = (tplotnames[0] EQ '') OR ((tnames())[0] EQ '')
IF (test[0]) THEN BEGIN
  errmsg = 'User did not load any data into TPLOT...'
  MESSAGE,errmsg[0],/INFORMATIONAL,/CONTINUE
  RETURN
ENDIF
;;----------------------------------------------------------------------------------------
;;  Rename TPLOT handles and remove originals
;;----------------------------------------------------------------------------------------
ntpn           = N_ELEMENTS(tplotnames)
FOR j=0L, ntpn[0] - 1L DO BEGIN
  get_data,tplotnames[j],DATA=temp0,DLIM=dlim,LIM=lim
  IF (SIZE(temp0,/TYPE) NE 8) THEN CONTINUE
  ;;  Remove original
  store_data,DELETE=tplotnames[j]
  IF (STRLOWCASE(tplotnames[j]) EQ 'time_pb5') THEN CONTINUE     ;;  Remove unnecessary and antiquated time stamp
  ;;  Define elements within time range
  temp   = trange_clip_data(temp0,TRANGE=tra,PREC=3)
  test   = (SIZE(temp,/TYPE) NE 8)
  IF (test[0]) THEN BEGIN
    ;;  No data within time range
    errmsg = 'No data within TRANGE for TPLOT variable '+o_all_tpns[j]
    MESSAGE,errmsg[0],/INFORMATIONAL,/CONTINUE
    CONTINUE
  ENDIF
  ;;  Define variables
  store_data,new_tpnames[j],DATA=temp,DLIM=dlim,LIM=lim
ENDFOR
;;  Fix TPLOT options
options,new_tpnames,'YRANGE'
options,new_tpnames,'YRANGE',/DEFAULT
options,new_tpnames,'YSUBTITLE'
options,new_tpnames,YSUBTITLE='[WI_AT_PRE CDF]',/DEFAULT
options,new_tpnames[1],YTITLE='Spin Rate [rpm]',/DEFAULT
options,new_tpnames[2],YTITLE='Right Ascension [rad, '+STRUPCASE(coord_gci[0])+']',/DEFAULT
options,new_tpnames[3],YTITLE='Declination [rad, '+STRUPCASE(coord_gci[0])+']',/DEFAULT
options,new_tpnames[4],YTITLE='Right Ascension [rad, '+STRUPCASE(coord_gse[0])+']',/DEFAULT
options,new_tpnames[5],YTITLE='Declination [rad, '+STRUPCASE(coord_gse[0])+']',/DEFAULT
options,new_tpnames[6],YTITLE='Right Ascension [rad, '+STRUPCASE(coord_gsm[0])+']',/DEFAULT
options,new_tpnames[7],YTITLE='Declination [rad, '+STRUPCASE(coord_gsm[0])+']',/DEFAULT
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN
END



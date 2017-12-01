;+
;*****************************************************************************************
;
;  PROCEDURE:   wind_emfits_e0_2_tplot.pro
;  PURPOSE  :   This is a wrapping routine for cdf2tplot.pro specific to the Wind 3DP
;                 EMFITS_E0 CDF files from CDAWeb.  The user-specified CDF variables are
;                 sent to TPLOT and the TPLOT handles are re-named and options are set
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
;               t_get_struc_unix.pro
;               options.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;               2)  3DP EMFITS_E0 CDF files from
;                     http://cdaweb.gsfc.nasa.gov/
;
;  INPUT:
;               NA
;
;  EXAMPLES:    
;               [calling sequence]
;               wind_emfits_e0_2_tplot [,TDATE=tdate] [,TRANGE=trange]
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
;               0)  Harten, R. and K. Clark "The Design Features of the GGS Wind and
;                      Polar Spacecraft," Space Sci. Rev. Vol. 71, pp. 23--40, 1995.
;               1)  Carlson et al., "An instrument for rapidly measuring plasma
;                      distribution functions with high resolution," Adv. Space Res.
;                      2, pp. 67--70, 1983.
;               2)  Curtis et al., "On-board data analysis techniques for space plasma
;                      particle instruments," Rev. Sci. Inst. 60, pp. 372--380, 1989.
;               3)  Lin et al., "A Three-Dimensional Plasma and Energetic particle
;                      investigation for the Wind spacecraft," Space Sci. Rev.
;                      71, pp. 125--153, 1995.
;               4)  Paschmann, G. and P.W. Daly "Analysis Methods for Multi-Spacecraft
;                      Data," ISSI Scientific Report, Noordwijk, The Netherlands.,
;                      Intl. Space Sci. Inst., 1998.
;
;   CREATED:  10/20/2017
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  10/20/2017   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

PRO wind_emfits_e0_2_tplot,TDATE=tdate,TRANGE=trange

;;----------------------------------------------------------------------------------------
;;  Constants
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
slash          = get_os_slash()       ;;  '/' for Unix, '\' for Windows
;;  Define old/default TPLOT handles
old_tpns       = ['N_e_dens_wi_3dp','T_e_par_wi_3dp','T_e_perp_wi_3dp','Q_e_par_wi_3dp',$
                  'V_e_xyz_gse_wi_3dp','Quality0_wi_3dp']
;;  Define new TPLOT handles
new_tpns       = ['Ne_3dp','Te_pape_3dp','Te_anis_3dp','Te_totl_3dp','Qe_para_3dp',     $
                  'Ve_3dp_gse','Quality_Flag_3dp']
n_nt           = N_ELEMENTS(new_tpns)
new_yttls      = ['Ne [cm^(-3), 3DP]','Te [eV, FACs, 3DP]','Tperp/Tpara [3DP]','Te [eV, Avg, 3DP]','Qe_para [µW m^(-2), 3DP]','Ve [km/s, GSE, 3DP]','Quality Flag']
te_labs_str    = ['tot','para','perp']
vec_str        = ['x','y','z']
vec_col        = [250,200,30]
;;----------------------------------------------------------------------------------------
;;  Defaults
;;----------------------------------------------------------------------------------------
;;  Default CDF file location
def_cdfloc     = '.'+slash[0]+'wind_3dp_pros'+slash[0]+'wind_data_dir'+slash[0]+$
                 'data1'+slash[0]+'wind'+slash[0]+'3dp'+slash[0]+'emfits_e0'+slash[0]
;;----------------------------------------------------------------------------------------
;;  Check keywords
;;----------------------------------------------------------------------------------------
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
tran           = time_ra.UNIX_TRANGE
tdates         = time_ra.DATE_TRANGE        ;;  'YYYY-MM-DD'  e.g., '2009-07-13'
tdate          = tdates[0]                  ;;  Redefine TDATE on output
;;  Convert TDATEs to format used by CDF files [e.g., 'YYYYMMDD']
fdates         = STRMID(tdates,0L,4L)+STRMID(tdates,5L,2L)+STRMID(tdates,8L,2L)
;;----------------------------------------------------------------------------------------
;;  Define CDF file location
;;----------------------------------------------------------------------------------------
cdfdir         = add_os_slash(FILE_EXPAND_PATH(def_cdfloc[0]))
;DEFSYSV,'!wind3dp_umn',EXISTS=exists
;IF ~KEYWORD_SET(exists) THEN BEGIN
;  cdfdir = add_os_slash(FILE_EXPAND_PATH(def_cdfloc[0]))
;ENDIF ELSE BEGIN
;  cdfdir = !wind3dp_umn.WIND_DATA1
;  IF (cdfdir[0] EQ '') THEN BEGIN
;    cdfdir = add_os_slash(FILE_EXPAND_PATH(def_cdfloc[0]))
;  ENDIF ELSE BEGIN
;    cdfdir = cdfdir[0]+'swe'+slash[0]+'h1'+slash[0]
;  ENDELSE
;ENDELSE
;;----------------------------------------------------------------------------------------
;;  Get CDF files within time range
;;----------------------------------------------------------------------------------------
date_form      = 'YYYYMMDD'
files          = general_find_files_from_trange(cdfdir[0],date_form[0],TRANGE=tran)
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
cdf2tplot,FILES=files,VARFORMAT='*',VARNAMES=varnames,$
          TPLOTNAMES=tplotnames,/CONVERT_INT1_TO_INT2
;;----------------------------------------------------------------------------------------
;;  Rename TPLOT handles and remove originals
;;----------------------------------------------------------------------------------------
;;  Get Ne
get_data,old_tpns[0],DATA=temp_ne,DLIMIT=dlim_ne,LIMIT=lim_ne
;;  Get Te_para
get_data,old_tpns[1],DATA=temp_Ta,DLIMIT=dlim_Ta,LIMIT=lim_Ta
;;  Get Te_perp
get_data,old_tpns[2],DATA=temp_Tp,DLIMIT=dlim_Tp,LIMIT=lim_Tp
;;  Get Qe_para
get_data,old_tpns[3],DATA=temp_Qe,DLIMIT=dlim_Qe,LIMIT=lim_Qe
;;  Get Ve
get_data,old_tpns[4],DATA=temp_Ve,DLIMIT=dlim_Ve,LIMIT=lim_Ve
;;  Get QF
get_data,old_tpns[5],DATA=temp_QF,DLIMIT=dlim_QF,LIMIT=lim_QF
;;  Remove originals
store_data,DELETE=old_tpns
;;--------------------------------------
;;  Define new
;;--------------------------------------
;;  Store Ne [cm^(-3)]
;;  Define elements within time range
temp           = trange_clip_data(temp_ne,TRANGE=tran,PREC=3)
store_data,new_tpns[0],DATA=temp,DLIMIT=dlim_ne,LIMIT=lim_ne
;;  Store [Te_para,Te_perp]
tempa          = trange_clip_data(temp_Ta,TRANGE=tran,PREC=3)
tempb          = trange_clip_data(temp_Tp,TRANGE=tran,PREC=3)
unix           = t_get_struc_unix(tempa)
te_pape        = [[tempa.Y],[tempb.Y]]
struc          = {X:unix,Y:te_pape}
store_data,new_tpns[1],DATA=struc,DLIMIT=dlim_Ta,LIMIT=lim_Ta
;;  Store Te_perp/Te_para
tanis          = tempb.Y/tempa.Y
struc          = {X:unix,Y:tanis}
store_data,new_tpns[2],DATA=struc,DLIMIT=dlim_Ta,LIMIT=lim_Ta
;;  Store Te_tot [eV]
te_tot         = (2d0*tempb.Y + tempa.Y)/3d0
struc          = {X:unix,Y:te_tot}
store_data,new_tpns[3],DATA=struc,DLIMIT=dlim_Ta,LIMIT=lim_Ta
;;  Store Qe_para [µW m^(-2)]
temp           = trange_clip_data(temp_Qe,TRANGE=tran,PREC=3)
store_data,new_tpns[4],DATA=temp,DLIMIT=dlim_Qe,LIMIT=lim_Qe
;;  Store Ve [km/s]
temp           = trange_clip_data(temp_Ve,TRANGE=tran,PREC=3)
store_data,new_tpns[5],DATA=temp,DLIMIT=dlim_Ve,LIMIT=lim_Ve
;;  Store Quality Flag [0-10; 0 = worst, 10 = best]
temp           = trange_clip_data(temp_QF,TRANGE=tran,PREC=3)
store_data,new_tpns[6],DATA=temp,DLIMIT=dlim_Ve,LIMIT=lim_Ve
;;----------------------------------------------------------------------------------------
;;  Fix options
;;----------------------------------------------------------------------------------------
;;  Remove any old/bad options
options,new_tpns,'LABELS'
options,new_tpns,'COLORS'
options,new_tpns,'YRANGE'
options,new_tpns,'YTITLE'
options,new_tpns,'YSUBTITLE'
;;  Correct options
options,new_tpns[1],LABELS=te_labs_str[1:2],COLORS=vec_col[0:1],/DEF
options,new_tpns[5],LABELS=vec_str,COLORS=vec_col,/DEF
FOR j=0L, n_nt[0] - 1L DO options,new_tpns[j],YTITLE=new_yttls[j],/DEF
options,new_tpns[[0,2,3,4,6]],COLORS= 50,/DEF
options,new_tpns[0],LABELS='Ne',/DEF
options,new_tpns[2],LABELS='T_anis',/DEF
options,new_tpns[3],LABELS='T_avg',/DEF
options,new_tpns[4],LABELS='Qe',/DEF
options,new_tpns[6],LABELS='Flag: 10 = best',/DEF
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN
END






















































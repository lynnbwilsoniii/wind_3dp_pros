;+
;*****************************************************************************************
;
;  PROCEDURE:   themis_load_fgm_esa_inst.pro
;  PURPOSE  :   This routine loads the state, FGM, and ESA data into TPLOT.  The routine
;                 also returns arrays of particle distributions if desired.
;
;  CALLED BY:   
;               load_save_themis_fgm_esa_batch.pro
;               load_thm_fields_save_tplot_batch.pro
;
;  INCLUDES:
;               NA
;
;  CALLS:
;               thm_init.pro
;               tplot_options.pro
;               time_range_define.pro
;               timespan.pro
;               timerange.pro
;               thm_load_state.pro
;               thm_load_fgm.pro
;               tnames.pro
;               array_where.pro
;               options.pro
;               get_data.pro
;               store_data.pro
;               mag__vec.pro
;               sample_rate.pro
;               str_element.pro
;               cotrans.pro
;               thm_load_esa.pro
;               thm_cotrans.pro
;               thm_load_esa_pkt.pro
;               thm_part_dist_array.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;               2)  THEMIS TDAS or SPEDAS IDL libraries
;
;  INPUT:
;               NA
;
;  EXAMPLES:    
;               [calling sequence]
;               themis_load_fgm_esa_inst [,DATE=date] [,TRANGE=trange] [,PROBE=probe]   $
;                                        [,/LOAD_EESA_DF] [,/LOAD_IESA_DF]              $
;                                        [,ESA_BF_TYPE=esa_df_type]                     $
;                                        [,EESA_DF_OUT=eesa_out] [,IESA_DF_OUT=iesa_out]
;
;  KEYWORDS:    
;               ***************
;               ***  INPUT  ***
;               ***************
;               DATE          :  Scalar [string] defining the date of interest of the form:
;                                  'MMDDYY' [MM=month, DD=day, YY=year]
;               TRANGE        :  [2]-Element [double] array specifying the Unix time
;                                  range for which to define/constrain data
;               PROBE         :  Scalar [string] defining the THEMIS probe for which to
;                                  load data
;                                  [Default = 'a']
;               LOAD_EESA_DF  :  If set, routine loads calibrated EESA [Burst,Full] data
;                                  structures with THETA/PHI angles and VELOCITY/MAGF
;                                  data in DSL coordinates
;                                  [Returned through EESA_DF_OUT keyword]
;               LOAD_IESA_DF  :  If set, routine loads calibrated IESA [Burst,Full] data
;                                  structures with THETA/PHI angles and VELOCITY/MAGF
;                                  data in DSL coordinates
;                                  [Returned through IESA_B_OUT keyword]
;               ESA_BF_TYPE   :  Scalar string defining the type of data structures to
;                                  return in the [EESA,IESA]_DF_OUT keywords
;                                    'full'   =  Full DFs are returned
;                                    'burst'  =  Burst DFs are returned
;                                    'both'   =  Both types of DFs are returned
;                                    [Default = 'full']
;               ****************
;               ***  OUTPUT  ***
;               ****************
;               EESA_DF_OUT   :  Set to a named variable to return the EESA [Burst,Full]
;                                  data pointer array
;               IESA_DF_OUT   :  Set to a named variable to return the IESA [Burst,Full]
;                                  data pointer array
;
;   CHANGED:  1)  Updated Man. page and cleaned up routine
;                                                                   [12/05/2014   v1.1.0]
;             2)  Added XYZ-GSE positions as tick marks instead of L-Shell, MLT, etc.
;                                                                   [12/09/2014   v1.1.1]
;             3)  Fixed a few bugs caught by S.E. Dorfman and updated routine and
;                   updated Man. page and
;                   now calls mag__vec.pro
;                                                                   [12/04/2015   v1.2.0]
;             4)  Added a few items to the possible Level 2 ESA velocity moments loaded
;                   into TPLOT
;                                                                   [01/07/2016   v1.2.1]
;
;   NOTES:      
;               1)  Would help to type the following prior to running this routine:
;                     @comp_lynn_pros
;                     if running SPEDAS software
;               2)  Only loads one probe at a time
;
;  REFERENCES:  
;               1)  McFadden, J.P., C.W. Carlson, D. Larson, M. Ludlam, R. Abiad,
;                      B. Elliot, P. Turin, M. Marckwordt, and V. Angelopoulos
;                      "The THEMIS ESA Plasma Instrument and In-flight Calibration,"
;                      Space Sci. Rev. 141, pp. 277-302, (2008).
;               2)  McFadden, J.P., C.W. Carlson, D. Larson, J.W. Bonnell,
;                      F.S. Mozer, V. Angelopoulos, K.-H. Glassmeier, U. Auster
;                      "THEMIS ESA First Science Results and Performance Issues,"
;                      Space Sci. Rev. 141, pp. 477-508, (2008).
;               3)  Auster, H.U., K.-H. Glassmeier, W. Magnes, O. Aydogar, W. Baumjohann,
;                      D. Constantinescu, D. Fischer, K.H. Fornacon, E. Georgescu,
;                      P. Harvey, O. Hillenmaier, R. Kroth, M. Ludlam, Y. Narita,
;                      R. Nakamura, K. Okrafka, F. Plaschke, I. Richter, H. Schwarzl,
;                      B. Stoll, A. Valavanoglou, and M. Wiedemann "The THEMIS Fluxgate
;                      Magnetometer," Space Sci. Rev. 141, pp. 235-264, (2008).
;               4)  Angelopoulos, V. "The THEMIS Mission," Space Sci. Rev. 141,
;                      pp. 5-34, (2008).
;               5)  Cully, C.M., R.E. Ergun, K. Stevens, A. Nammari, and J. Westfall
;                      "The THEMIS Digital Fields Board," Space Sci. Rev. 141,
;                      pp. 343-355, (2008).
;               6)  Roux, A., O. Le Contel, C. Coillot, A. Bouabdellah, B. de la Porte,
;                      D. Alison, S. Ruocco, and M.C. Vassal "The Search Coil
;                      Magnetometer for THEMIS," Space Sci. Rev. 141,
;                      pp. 265-275, (2008).
;               7)  Le Contel, O., A. Roux, P. Robert, C. Coillot, A. Bouabdellah,
;                      B. de la Porte, D. Alison, S. Ruocco, V. Angelopoulos,
;                      K. Bromund, C.C. Chaston, C.M. Cully, H.U. Auster,
;                      K.-H. Glassmeier, W. Baumjohann, C.W. Carlson, J.P. McFadden,
;                      and D. Larson "First Results of the THEMIS Search Coil
;                      Magnetometers," Space Sci. Rev. 141, pp. 509-534, (2008).
;
;   CREATED:  08/10/2012
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  01/07/2016   v1.2.1
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

PRO themis_load_fgm_esa_inst,DATE=date,TRANGE=trange,PROBE=probe,LOAD_EESA_DF=loadeesa, $
                             EESA_DF_OUT=eesa_out,LOAD_IESA_DF=loadiesa,                $
                             IESA_DF_OUT=iesa_out,ESA_BF_TYPE=esa_df_type

;;****************************************************************************************
ex_start       = SYSTIME(1)
;;****************************************************************************************
FORWARD_FUNCTION time_range_define, timerange, tnames, array_where, mag__vec, $
                 sample_rate, thm_part_dist_array
;;----------------------------------------------------------------------------------------
;;  Define some constants and dummy variables
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
ma             = 6.6446572300d-27         ;;  Alpha particle mass [kg, 2014 CODATA/NIST]
me             = 9.1093835600d-31         ;;  Electron mass [kg, 2014 CODATA/NIST]
mn             = 1.6749274710d-27         ;;  Neutron mass [kg, 2014 CODATA/NIST]
mp             = 1.6726218980d-27         ;;  Proton mass [kg, 2014 CODATA/NIST]
c              = 2.9979245800d+08         ;;  Speed of light in vacuum [m s^(-1), 2014 CODATA/NIST]
qq             = 1.6021766208d-19         ;;  Fundamental charge [C, 2014 CODATA/NIST]
epo            = 8.8541878170d-12         ;;  Permittivity of free space [F m^(-1), 2014 CODATA/NIST]
muo            = !DPI*4.00000d-07         ;;  Permeability of free space [N A^(-2) or H m^(-1), 2014 CODATA/NIST]
kB             = 1.3806485200d-23         ;;  Boltzmann Constant [J K^(-1), 2014 CODATA/NIST]
K_eV           = qq[0]/kB[0]              ;;  Temp. associated with 1 eV of energy [11,604.5221 K/eV, 2014 CODATA/NIST --> K_eV*energy{eV} = Temp{K}]
R_Ea__m        = 6.3781366d06             ;;  Earth's Mean Equatorial Radius [m, 2015 AA values]
R_E            = R_Ea__m[0]*1d-3          ;;  m --> km
;;  Define some default strings
coord_ssl      = 'ssl'
coord_dsl      = 'dsl'
coord_gse      = 'gse'
coord_gsm      = 'gsm'
coord_mag      = 'mag'
vec_str        = ['x','y','z']
vec_col        = [250,150, 50]
;;  Dummy error messages
nottpn_msg     = 'Not valid TPLOT handles...'
notprb_msg     = 'Not valid probe name...'
nofgmd_msg     = 'No FGM data for '
;;  Initialize THEMIS software
thm_init
;;  Force software to print out all relevant information
!themis.VERBOSE = 2
tplot_options,'VERBOSE',2
;;----------------------------------------------------------------------------------------
;;  Define some defaults
;;----------------------------------------------------------------------------------------
tplot_options,'XMARGIN',[ 20, 15]
tplot_options,'YMARGIN',[ 5, 5]
probes         = ['a','b','c','d','e']
;;----------------------------------------------------------------------------------------
;;  Date/Times/Probes
;;----------------------------------------------------------------------------------------
time_ra        = time_range_define(DATE=date,TRANGE=trange)
tra            = time_ra.TR_UNIX
tdates         = time_ra.TDATE_SE  ;;  e.g. '2009-07-13'
fdate          = time_ra.FDATE_SE  ;;  e.g. '07-13-2009'
tdate          = tdates[0]
;;  Set timespan/timerange
dur            = 1.0               ;;  # of days
timespan,tdate[0],dur[0],/DAY
IF ~KEYWORD_SET(trange) THEN tr = timerange() ELSE tr = tra
trs            = tr + [-1d0,1d0]*6d2  ;;  use longer time range for state and support data
;;----------------------------------------------------------------------------------------
;;  Define probe
;;----------------------------------------------------------------------------------------
IF ~KEYWORD_SET(probe) THEN probe0 = 'a' ELSE probe0 = probe[0]
sc0            = STRMID(STRLOWCASE(probe0[0]),0L,1L)
good           = WHERE(sc0[0] EQ probes,gd)
IF (gd EQ 0) THEN BEGIN
  ;;  use default
  MESSAGE,notprb_msg[0],/INFORMATIONAL,/CONTINUE
  PRINT,''
  PRINT,'Using default [a]...'
  sc = 'a'
ENDIF ELSE BEGIN
  sc = sc0[0]
ENDELSE
;;----------------------------------------------------------------------------------------
;; Load state data (position, spin, etc.)
;;----------------------------------------------------------------------------------------
thm_load_state,PROBE=sc[0],/GET_SUPPORT_DATA,TRANGE=trs,VERBOSE=0
;;----------------------------------------------------------------------------------------
;; Load level 2 magnetic field data
;;----------------------------------------------------------------------------------------
mode           = 'fg?'
thm_load_fgm,PROBE=sc[0],DATATYPE=mode[0],LEVEL=2,COORD='all',TRANGE=tr,VERBOSE=0

;;  fix colors and labels
pref           = 'th'+sc[0]+'_fg*'
names          = tnames(pref[0])
IF (names[0] EQ '') THEN BEGIN
  ;;  use default
  MESSAGE,nofgmd_msg[0]+tdate[0]+' for probe '+sc[0],/INFORMATIONAL,/CONTINUE
  RETURN
ENDIF
hed_nm         = tnames('*_hed')
good_nm        = array_where(names,hed_nm,/N_UNIQ,NCOMP1=comp1,NCOMP2=comp2)
names          = names[comp1]
options,names,COLORS=vec_col,LABELS=vec_str,/DEF
;options,names,'COLORS',[250,150, 50],/DEF
;options,names,'LABELS',['x','y','z'],/DEF
;;-----------------------------------------------------
;;  Create |B| TPLOT variable
;;-----------------------------------------------------
fcifac         = qq[0]*1d-9/(2d0*!DPI*mp[0])
fcefac         = qq[0]*1d-9/(2d0*!DPI*me[0])
;coord          = 'dsl'
coord          = coord_dsl[0]
mode           = 'fg'+['s','l','h']
FOR j=0L, 2L DO BEGIN
  name0   = 'th'+sc[0]+'_'+mode[j]+'_'+coord[0]
  name1   = 'th'+sc[0]+'_'+mode[j]+'_mag'
  get_data,name0[0],DATA=temp,DLIM=dlim,LIM=lim
  ;;  Bug caught by SED
  IF (SIZE(temp,/TYPE) NE 8) THEN CONTINUE     ;;  Skip to next iteration if no TPLOT handle loaded
  bmag    = mag__vec(temp.Y,/NAN)
;  bmag    = SQRT(TOTAL(temp.Y^2,2,/NAN))
  temp2   = {X:temp.X,Y:bmag}
  store_data,name1[0],DATA=temp2
  ;;  define temporary YTITLE
  yttl0   = 'th'+STRMID(sc[0],0L,1L)+' |B| ['+mode[j]+', nT]'
  options,name1[0],'YTITLE',yttl0[0],/DEF
  ;;-----------------------------------------------------
  ;;  Create [fci,flh,fce] TPLOT variable
  ;;-----------------------------------------------------
  ;;  [fci,flh,fce] from 'fg?'
  fci_l   = fcifac[0]*bmag
  fce_l   = fcefac[0]*bmag
  flh_l   = SQRT(fci_l*fce_l)
  freqs   = [[fci_l],[flh_l],[fce_l]]
  fcs_l_n = 'th'+sc[0]+'_'+mode[j]+'_fci_flh_fce'
  store_data,fcs_l_n[0],DATA={X:temp.X,Y:freqs}
  ;;  fix colors and labels
  options,fcs_l_n[0],COLORS=[265,275,285],LABELS=['fci','flh','fce'],/DEF
  options,fcs_l_n[0],'COLORS'
;  options,fcs_l_n[0],'COLORS',[265,275,285],/DEF
;  options,fcs_l_n[0],'LABELS',['fci','flh','fce'],/DEF
ENDFOR
;;-----------------------------------------------------
;;  Fix the Y-Axis Titles
;;-----------------------------------------------------
mode           = 'fg'+['s','l','h']
coord          = [coord_dsl[0],coord_gse[0],coord_gsm[0],coord_mag[0]]
;coord          = ['dsl','gse','gsm','mag']
modeu          = STRUPCASE(mode)
coordu         = STRUPCASE(coord)
FOR j=0L, 2L DO BEGIN                                ;;  Loop over 3-vector components
  FOR k=0L, 3L DO BEGIN                              ;;  Loop over coordinates
    pref    = 'th'+sc[0]+'_'+mode[j]+'_'+coord[k]
    names   = tnames(pref[0])
    get_data,names[0],DATA=temp,DLIM=dlim,LIM=lim
    ;;  Bug caught by SED
    IF (SIZE(temp,/TYPE) NE 8) THEN CONTINUE         ;;  Skip to next iteration if no TPLOT handle loaded
    smrate  = sample_rate(temp.X,GAP_THRESH=2d0,/AVE)
    strsmr  = STRTRIM(STRING(FORMAT='(f15.2)',smrate[0]),2L)
    yttl    = 'B ['+modeu[j]+', '+coordu[k]+', nT]'
    ysubt   = '[th'+sc[0]+' '+strsmr[0]+' sps, L2]'
    str_element,dlim,'YTITLE',yttl[0],/ADD_REPLACE
    str_element,dlim,'YSUBTITLE',ysubt[0],/ADD_REPLACE
    store_data,names[0],DATA=temp,DLIM=dlim,LIM=lim
  ENDFOR
ENDFOR
;;----------------------------------------------------------------------------------------
;;  Calculate Radial Distance (Re), Magnetic Local Time (MLT), Magnetic Latitude (MLAT), 
;;      L-Shell, and Invariant Latitude (ILAT)
;;----------------------------------------------------------------------------------------
pos_gsm        = 'th'+sc[0]+'_state_pos_gsm'
pos__sm        = 'th'+sc[0]+'_state_pos__sm'
;;  Bug caught by SED
test           = (tnames(pos_gsm[0]) NE '') OR (tnames(pos__sm[0]) NE '')
IF (test[0]) THEN BEGIN
  ;;  Radial Distance (Re)
  get_data,pos_gsm[0],DATA=temp,DLIM=dlim,LIM=lim
  gsmposi        = temp.Y
  rad_dist       = mag__vec(gsmposi,/NAN)/R_E[0]
;  rad_dist       = SQRT(TOTAL(gsmposi^2,2,/NAN))/R_E[0]
  ;;  Rotate:  GSM --> SM
  cotrans,pos_gsm[0],pos__sm[0],/GSM2SM
  posnm          = pos__sm[0]
  get_data,posnm[0],DATA=temp,DLIM=dlim,LIM=lim
  th_pos_time    = temp.X
  th_pos_vec__sm = temp.Y
  th_pos_rad__sm = mag__vec(th_pos_vec__sm,/NAN)
;  th_pos_rad__sm = SQRT(TOTAL(th_pos_vec__sm^2,2,/NAN))
  ;;-----------------------------------------------------
  ;;  MLT (hours)
  ;;-----------------------------------------------------
  t_x            = th_pos_vec__sm[*,0]
  t_y            = th_pos_vec__sm[*,1]
  t_z            = th_pos_vec__sm[*,2]
  th_mlt         = ATAN(t_y/t_x)*18d1/!DPI/15d0 + 12d0
  ;;  Check for negative X-SM coordinate points
  low_tmp        = WHERE(th_pos_vec__sm[*,0] LT 0d0,lwtp)
  IF (lwtp GT 0L) THEN th_mlt[low_tmp] = (ATAN(t_y[low_tmp]/t_x[low_tmp]) + !DPI)*18d1/(!DPI*15d0) + 12d0
  ;;  make sure LT 24
  th_mlt         = th_mlt MOD 24d0
  ;;-----------------------------------------------------
  ;;  MLAT (deg)
  ;;-----------------------------------------------------
  t_ratio        = t_z/th_pos_rad__sm
  th_mlat        = ATAN(t_ratio)*18d1/!DPI
  ;;-----------------------------------------------------
  ;;  L-Shell (Re)
  ;;-----------------------------------------------------
  cmlat          = COS(th_mlat*!DPI/18d1)
  th_lshell      = th_pos_rad__sm/(R_E[0]*cmlat^2)
  ;;-----------------------------------------------------
  ;;  ILAT (deg)
  ;;-----------------------------------------------------
  irt_lsh        = SQRT(1d0/th_lshell)
  th_ilat        = ACOS(irt_lsh)*18d1/!DPI
  ;;  send to TPLOT
  pref           = 'th'+sc[0]+'_'
  store_data,pref[0]+'_Rad',DATA={X:th_pos_time,Y:rad_dist}
  store_data,pref[0]+'_MLT',DATA={X:th_pos_time,Y:th_mlt}
  store_data,pref[0]+'MLAT',DATA={X:th_pos_time,Y:th_mlat}
  store_data,pref[0]+'_LSH',DATA={X:th_pos_time,Y:th_lshell}
  store_data,pref[0]+'ILAT',DATA={X:th_pos_time,Y:th_ilat}
  ;;  Modify options
  pref           = 'th'+sc[0]+'_'
  tpref          = 'th'+sc[0]+' '
  options,pref[0]+'_Rad','YTITLE',tpref[0]+'|R| [Re]',/DEF
  options,pref[0]+'_MLT','YTITLE',tpref[0]+'MLT [Hr]',/DEF
  options,pref[0]+'MLAT','YTITLE',tpref[0]+'MLAT [Deg]',/DEF
  options,pref[0]+'_LSH','YTITLE',tpref[0]+'LShell [Re]',/DEF
  options,pref[0]+'ILAT','YTITLE',tpref[0]+'ILAT [Deg]',/DEF
  ;;-----------------------------------------------------
  ;;  Add SC position to TPLOT plots
  ;;-----------------------------------------------------
  pos_gse        = 'th'+sc[0]+'_state_pos_'+coord_gse[0]
  get_data,pos_gse[0],DATA=temp,DLIM=dlim,LIM=lim
  gseposi        = temp.Y/R_E[0]  ;; convert to Re
  store_data,pos_gse[0]+'_'+vec_str[0],DATA={X:temp.X,Y:gseposi[*,0]},DLIM=dlim,LIM=lim
  store_data,pos_gse[0]+'_'+vec_str[1],DATA={X:temp.X,Y:gseposi[*,1]},DLIM=dlim,LIM=lim
  store_data,pos_gse[0]+'_'+vec_str[2],DATA={X:temp.X,Y:gseposi[*,2]},DLIM=dlim,LIM=lim
  ;;  Redefine options
  options,pos_gse[0]+'_'+vec_str[0],'YTITLE',tpref[0]+'X-GSE [Re]',/DEF
  options,pos_gse[0]+'_'+vec_str[1],'YTITLE',tpref[0]+'Y-GSE [Re]',/DEF
  options,pos_gse[0]+'_'+vec_str[2],'YTITLE',tpref[0]+'Z-GSE [Re]',/DEF
  options,pos_gse[0]+'_'+vec_str[*],'YTITLE'
  options,pos_gse[0]+'_'+vec_str[*],'COLORS'
  options,pos_gse[0]+'_'+vec_str[*],'COLORS',/DEF
  options,pos_gse[0]+'_'+vec_str[*],'LABELS'
  options,pos_gse[0]+'_'+vec_str[*],'LABELS',/DEF
  ;;  Add positions to tick mark labels
  names          = REVERSE([pref[0]+'_Rad',pos_gse[0]+'_'+vec_str])
  tplot_options,VAR_LABEL=names
ENDIF
;;----------------------------------------------------------------------------------------
;;  Load ESA packet info for structures
;;----------------------------------------------------------------------------------------
thm_load_esa_pkt,PROBE=sc[0],TRANGE=trs,VERBOSE=0
;;----------------------------------------------------------------------------------------
;;  Load ESA data
;;----------------------------------------------------------------------------------------
;dtype_esc      = ' pee?_density pee?_avgtemp pee?_sc_pot '
;dtype_isc      = ' pei?_density pei?_avgtemp pei?_sc_pot '
mid_strs       = ['density','avgtemp','sc_pot','magt3','ptens']
dtype_esc      = ' '+STRJOIN(['pee?_'+mid_strs],' ',/SINGLE)+' '
dtype_isc      = ' '+STRJOIN(['pei?_'+mid_strs],' ',/SINGLE)+' '
dtype_vsc      = ' pee?_velocity_dsl pei?_velocity_dsl '
;;  Load level 2 densities, temps, velocities, and SC potentials
thm_load_esa,PROBE=sc[0],DATAT=dtype_esc[0],LEVEL=2,VERBOSE=0,TRANGE=tr
thm_load_esa,PROBE=sc[0],DATAT=dtype_isc[0],LEVEL=2,VERBOSE=0,TRANGE=tr
thm_load_esa,PROBE=sc[0],DATAT=dtype_vsc[0],LEVEL=2,VERBOSE=0,TRANGE=tr
;;-----------------------------------------------------
;;  Remove YLOG and fix YTITLE and YSUBTITLE
;;-----------------------------------------------------
pref           = 'th'+sc[0]+'_'
frbsuf         = ['b','r','f']
frbytt         = ['Burst','Reduced','Full']
ei_mid         = ['e','i']
emid           = 'pee'+frbsuf
imid           = 'pei'+frbsuf
dens_sx        = '_density'
temp_sx        = '_avgtemp'
dens_en        = pref[0]+emid+dens_sx[0]
dens_in        = pref[0]+imid+dens_sx[0]
temp_en        = pref[0]+emid+temp_sx[0]
temp_in        = pref[0]+imid+temp_sx[0]
;;  Remove YLOG settings for density and temp
options,[dens_en,dens_in,temp_en,temp_in],'YLOG'
options,[dens_en,dens_in,temp_en,temp_in],'YLOG',/DEF
options,[dens_en,dens_in,temp_en,temp_in],'LOG'
options,[dens_en,dens_in,temp_en,temp_in],'LOG',/DEF
;;  Fix YTITLE for density and temp
dens_aa        = [[dens_en],[dens_in]]
temp_aa        = [[temp_en],[temp_in]]
options,[dens_en,dens_in,temp_en,temp_in],'YTITLE'
options,[dens_en,dens_in,temp_en,temp_in],'YTITLE',/DEF
options,[dens_en,dens_in,temp_en,temp_in],'YSUBTITLE'
options,[dens_en,dens_in,temp_en,temp_in],'YSUBTITLE',/DEF
FOR j=0L, 2L DO BEGIN
  FOR k=0L, 1L DO BEGIN
    ;;  Density
    ytt0  = 'N!D'+ei_mid[k]+'!N ['+frbytt[j]+']'
    ysub0 = '[th'+sc[0]+', cm!U-3!N'+', All Qs]'
    options,dens_aa[j,k],YTITLE=ytt0[0],YSUBTITLE=ysub0[0],/DEF
    ;;  Temperature
    ytt0  = 'T!D'+ei_mid[k]+'!N ['+frbytt[j]+']'
    ysub0 = '[th'+sc[0]+', Avg., eV, All Qs]'
    options,temp_aa[j,k],YTITLE=ytt0[0],YSUBTITLE=ysub0[0],/DEF
;    options,dens_aa[j,k],'YTITLE',ytt0[0],/DEF
;    options,dens_aa[j,k],'YSUBTITLE',ysub0[0],/DEF
;    options,temp_aa[j,k],'YTITLE',ytt0[0],/DEF
;    options,temp_aa[j,k],'YSUBTITLE',ysub0[0],/DEF
  ENDFOR
ENDFOR
;;-----------------------------------------------------
;;  Rotate:  DSL --> GSE
;;-----------------------------------------------------
partn          = ['e','i']
coords         = [coord_dsl[0],coord_gse[0]]
;coords         = ['dsl','gse']
in_suffe       = 'pe'+partn[0]+['b','r','f']+'_velocity_'+coords[0]
out_suffe      = 'pe'+partn[0]+['b','r','f']+'_velocity_'+coords[1]
in_suffi       = 'pe'+partn[1]+['b','r','f']+'_velocity_'+coords[0]
out_suffi      = 'pe'+partn[1]+['b','r','f']+'_velocity_'+coords[1]
in_name        = 'th'+sc[0]+'_'+[[in_suffe],[in_suffi]]
out_name       = 'th'+sc[0]+'_'+[[out_suffe],[out_suffi]]
FOR j=0L, 1L DO BEGIN
  FOR k=0L, 2L DO BEGIN
    in_n = tnames(in_name[k,j])
    outn = out_name[k,j]
    ;;  Bug caught by SED
    IF (in_n[0] EQ '') THEN CONTINUE
    thm_cotrans,in_n[0],outn[0],IN_COORD=coords[0],OUT_COORD=coords[1],VERBOSE=0
;    thm_cotrans,in_name[k,j],out_name[k,j],IN_COORD=coords[0],OUT_COORD=coords[1],VERBOSE=0
  ENDFOR
ENDFOR
;;  fix colors and labels
names          = tnames([REFORM(in_name,3*2),REFORM(out_name,3*2)])
options,names,COLORS=vec_col,LABELS=vec_str,/DEF
;options,names,'COLORS',[250,150, 50],/DEF
;options,names,'LABELS',['x','y','z'],/DEF
;;-----------------------------------------------------
;;  Rotate:  GSE --> GSM
;;-----------------------------------------------------
partn          = ['e','i']
coords         = [coord_gse[0],coord_gsm[0]]
;coords         = ['gse','gsm']
in_suffe       = 'pe'+partn[0]+['b','r','f']+'_velocity_'+coords[0]
out_suffe      = 'pe'+partn[0]+['b','r','f']+'_velocity_'+coords[1]
in_suffi       = 'pe'+partn[1]+['b','r','f']+'_velocity_'+coords[0]
out_suffi      = 'pe'+partn[1]+['b','r','f']+'_velocity_'+coords[1]
in_name        = 'th'+sc[0]+'_'+[[in_suffe],[in_suffi]]
out_name       = 'th'+sc[0]+'_'+[[out_suffe],[out_suffi]]
FOR j=0L, 1L DO BEGIN
  FOR k=0L, 2L DO BEGIN
    in_n = tnames(in_name[k,j])
    outn = out_name[k,j]
    ;;  Bug caught by SED
    IF (in_n[0] EQ '') THEN CONTINUE
    thm_cotrans,in_n[0],outn[0],IN_COORD=coords[0],OUT_COORD=coords[1],VERBOSE=0
;    thm_cotrans,in_name[k,j],out_name[k,j],IN_COORD=coords[0],OUT_COORD=coords[1],VERBOSE=0
  ENDFOR
ENDFOR
;;  fix colors and labels
names          = tnames([REFORM(in_name,3*2),REFORM(out_name,3*2)])
options,names,COLORS=vec_col,LABELS=vec_str,/DEF
;options,names,'COLORS',[250,150, 50],/DEF
;options,names,'LABELS',['x','y','z'],/DEF

dens_nm        = tnames('*b_density')
temp_nm        = tnames('*b_avgtemp')
IF (dens_nm[0] NE '') THEN options,dens_nm,'YLOG',0,/DEF
IF (temp_nm[0] NE '') THEN options,temp_nm,'YLOG',0,/DEF
;options,dens_nm,'YLOG',0,/DEF
;options,temp_nm,'YLOG',0,/DEF
;;----------------------------------------------------------------------------------------
;;  Load ESA DFs if desired
;;----------------------------------------------------------------------------------------
IF ~KEYWORD_SET(esa_df_type) THEN esa_df_type = 'full'

CASE esa_df_type[0] OF
  'full'  : BEGIN
    df_type = ['f']
  END
  'burst' : BEGIN
    df_type = ['b']
  END
  'both'  : BEGIN
    df_type = ['f','b']
  END
  ELSE    : BEGIN
    ;;  use default
    df_type = ['f']
  END
ENDCASE

IF KEYWORD_SET(loadeesa) THEN BEGIN
  ;;-----------------------------------------------------
  ;;  Load EESA DFs
  ;;-----------------------------------------------------
  prefn   = 'th'+sc[0]
  formt   = prefn[0]+'_pee'+df_type
  velname = formt+'_velocity_dsl'
  magname = prefn[0]+'_fgl_dsl'
  IF (N_ELEMENTS(formt) GT 1) THEN BEGIN
    datatypes   = 'pee'+df_type
    ;;-----------------------------------------------------
    ;;  load Full and Burst
    ;;-----------------------------------------------------
    peef_df_arr = thm_part_dist_array(FORMAT=formt[0],TRANGE=tr,MAG_DATA=magname[0],$
                                      VEL_DATA=velname[0],DATATYPE=datatypes[0])
    peeb_df_arr = thm_part_dist_array(FORMAT=formt[1],TRANGE=tr,MAG_DATA=magname[0],$
                                      VEL_DATA=velname[1],DATATYPE=datatypes[1])
    ;;  create output structure
    str_element,eesa_out,'FULL', peef_df_arr,/ADD_REPLACE
    str_element,eesa_out,'BURST',peeb_df_arr,/ADD_REPLACE
  ENDIF ELSE BEGIN
    datatypes   = 'pee'+df_type[0]
    ;;-----------------------------------------------------
    ;;  load Full or Burst
    ;;-----------------------------------------------------
    peeq_df_arr = thm_part_dist_array(FORMAT=formt[0],TRANGE=tr,MAG_DATA=magname[0],$
                                      VEL_DATA=velname[0],DATATYPE=datatypes[0])
    IF (df_type[0] EQ 'f') THEN BEGIN
      ;;  Full loaded
      str_element,eesa_out,'FULL',peeq_df_arr,/ADD_REPLACE
      str_element,eesa_out,'BURST',0,/ADD_REPLACE
    ENDIF ELSE BEGIN
      ;;  Burst loaded
      str_element,eesa_out,'FULL',0,/ADD_REPLACE
      str_element,eesa_out,'BURST',peeq_df_arr,/ADD_REPLACE
    ENDELSE
  ENDELSE
ENDIF ELSE BEGIN
  str_element,eesa_out,'FULL', 0,/ADD_REPLACE
  str_element,eesa_out,'BURST',0,/ADD_REPLACE
ENDELSE

IF KEYWORD_SET(loadiesa) THEN BEGIN
  ;;-----------------------------------------------------
  ;;  Load IESA DFs
  ;;-----------------------------------------------------
  prefn   = 'th'+sc[0]
  formt   = prefn[0]+'_pei'+df_type
  velname = formt+'_velocity_dsl'
  magname = prefn[0]+'_fgl_dsl'
  IF (N_ELEMENTS(formt) GT 1) THEN BEGIN
    datatypes   = 'pei'+df_type
    ;;-----------------------------------------------------
    ;;  load Full and Burst
    ;;-----------------------------------------------------
    peif_df_arr = thm_part_dist_array(FORMAT=formt[0],TRANGE=tr,MAG_DATA=magname[0],$
                                      VEL_DATA=velname[0],DATATYPE=datatypes[0])
    peib_df_arr = thm_part_dist_array(FORMAT=formt[1],TRANGE=tr,MAG_DATA=magname[0],$
                                      VEL_DATA=velname[1],DATATYPE=datatypes[1])
    ;;  create output structure
    str_element,iesa_out,'FULL', peif_df_arr,/ADD_REPLACE
    str_element,iesa_out,'BURST',peib_df_arr,/ADD_REPLACE
  ENDIF ELSE BEGIN
    datatypes   = 'pee'+df_type[0]
    ;;-----------------------------------------------------
    ;;  load Full or Burst
    ;;-----------------------------------------------------
    peiq_df_arr = thm_part_dist_array(FORMAT=formt[0],TRANGE=tr,MAG_DATA=magname[0],$
                                      VEL_DATA=velname[0],DATATYPE=datatypes[0])
    IF (df_type[0] EQ 'f') THEN BEGIN
      ;;  Full loaded
      str_element,iesa_out,'FULL',peiq_df_arr,/ADD_REPLACE
      str_element,iesa_out,'BURST',0,/ADD_REPLACE
    ENDIF ELSE BEGIN
      ;;  Burst loaded
      str_element,iesa_out,'FULL',0,/ADD_REPLACE
      str_element,iesa_out,'BURST',peiq_df_arr,/ADD_REPLACE
    ENDELSE
  ENDELSE
ENDIF ELSE BEGIN
  str_element,iesa_out,'FULL', 0,/ADD_REPLACE
  str_element,iesa_out,'BURST',0,/ADD_REPLACE
ENDELSE
;;----------------------------------------------------------------------------------------
;;  Define default options
;;----------------------------------------------------------------------------------------
nnw            = tnames()
options,nnw,'YSTYLE',1
options,nnw,'PANEL_SIZE',2.
options,nnw,'XMINOR',5
options,nnw,'XTICKLEN',0.04
options,nnw,'YTICKLEN',0.01
;;  Remove color table from default options
options,tnames(),'COLOR_TABLE',/DEF
options,tnames(),'COLOR_TABLE'
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------
;;****************************************************************************************
ex_time        = SYSTIME(1) - ex_start[0]
MESSAGE,STRING(ex_time[0])+' seconds execution time.',/CONTINUE,/INFORMATIONAL
;;****************************************************************************************

RETURN
END

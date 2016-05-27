;+
;*****************************************************************************************
;
;  PROCEDURE:   wind_swe_h1_to_tplot.pro
;  PURPOSE  :   This routine reads in the CDF files containing the H1 data for the
;                 Wind/SWE Faraday Cups instrument and sends the results to TPLOT.
;
;  CALLED BY:   
;               NA
;
;  CALLS:
;               get_greek_letter.pro
;               get_os_slash.pro
;               wind_3dp_umn_init.pro
;               loadallcdf.pro
;               str_element.pro
;               store_data.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;               2)  H1 CDF files for the Wind SWE Faraday Cups instrument obtained from
;                     CDAWeb at:
;                       http://cdaweb.gsfc.nasa.gov
;
;  INPUT:
;               NA
;
;  EXAMPLES:    
;               NA
;
;  KEYWORDS:    
;               TRANGE      :  [2]-Element [double] array specifying the time range over
;                                which to load Wind data [Unix time]
;               MASTERFILE  :  Scalar [string] defining the name of the master file list
;                                which provides the routine with the file paths and names
;                                of the relevant CDF files.  If setfileenv.pro has not
;                                been run, then user must specify the file path name in
;                                addition to the master file name.
;                                [Default = 'wi_h1_swe_files']
;               LOAD_SIGMA  :  If set, routine will load the one-sigma uncertainties in
;                                addition to nonlinear fit values.
;                                [Default = FALSE]
;               NO_PROTONS  :  If set, routine will not load the data associated with the
;                                proton velocity moments from the nonlinear fits
;                                [Default = FALSE]
;               NO_ALPHAS   :  If set, routine will not load the data associated with the
;                                alpha-particle velocity moments from the nonlinear fits
;                                [Default = FALSE]
;               NO_SWE_B    :  If set, routine will not load the data associated with the
;                                magnetic fields used to define parallel/perpendicular
;                                [Default = FALSE]
;
;   CHANGED:  1)  Updated NOTES and REFERENCES in Man. page
;                                                                   [01/27/2014   v1.0.0]
;
;   NOTES:      
;               1)  If user loaded data using load_3dp_data.pro or called the routine
;                     setfileenv.pro, then an environment variable would have been
;                     created with the name 'WI_H1_SWE_FILES'.  If already present,
;                     then setting MASTERFILE='wi_h1_swe_files' would be enough for the
;                     routine to find the CDF files.  If not, then the user must
;                     specify the full file path to the CDF files.
;               2)  The thermal speeds are "most probable speeds" speeds, not rms
;               3)  The velocity due to the Earth's orbit about the sun has been removed
;                     from the bulk flow velocities.  This means that ~29.064 km/s has
;                     been subtracted from the Y-GSE component.
;               4)  The nonlinear fits provided in the H1 files do NOT contain the higher
;                     resolution calculations used in Maruca&Kasper, [2013].
;
;  REFERENCES:  
;               1)  K.W. Ogilvie et al., "SWE, A Comprehensive Plasma Instrument for the
;                     Wind Spacecraft," Space Science Reviews Vol. 71, pp. 55-77,
;                     doi:10.1007/BF00751326, 1995.
;               2)  J.C. Kasper et al., "Physics-based tests to identify the accuracy of
;                     solar wind ion measurements:  A case study with the Wind
;                     Faraday Cups," Journal of Geophysical Research Vol. 111,
;                     pp. A03105, doi:10.1029/2005JA011442, 2006.
;               3)  B.A. Maruca and J.C. Kasper "Improved interpretation of solar wind
;                     ion measurements via high-resolution magnetic field data,"
;                     Advances in Space Research Vol. 52, pp. 723-731,
;                     doi:10.1016/j.asr.2013.04.006, 2013.
;
;   CREATED:  01/24/2014
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  01/24/2014   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

PRO wind_swe_h1_to_tplot,TRANGE=trange,MASTERFILE=masterfile,LOAD_SIGMA=load_sigma,$
                         NO_PROTONS=no_protons,NO_ALPHAS=no_alphas,NO_SWE_B=no_swe_b

;;----------------------------------------------------------------------------------------
;;  Constants/Dummy Variables
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
xyz_str        = ['x','y','z']
xyz_col        = [250,150, 50]
vel_sub_str    = ['mag',xyz_str]
vth_sub_str    = ['_avg','para','perp']
species        = ['p','a']
spec_ysub      = ['Protons','Alphas']
coord_gse      = 'gse'
coord_gseu     = STRUPCASE(coord_gse[0])
vel_subscs     = ['bulk','Th']
vel___pref     = 'V_'+vel_subscs+'_'
vel_p_pref     = vel___pref+species[0]+'_'
vel_a_pref     = vel___pref+species[1]+'_'
magf_pref      = 'B_for_SWE_'+coord_gseu[0]
dens_tpn_pa    = 'N_'+species+'_SWE'

;;  Define Greek symbol string outputs
mu____str      = get_greek_letter('mu')
delta_str      = get_greek_letter('delta')
Delta_str      = STRUPCASE(delta_str[0])
alpha_str      = get_greek_letter('alpha')

;;  Define default plot limits structures
ltags          = ['YSTYLE','PANEL_SIZE','XMINOR','XTICKLEN','YTICKLEN']
def_lim        = CREATE_STRUCT(ltags,1,2.,5,0.04,0.01)
dtags          = ['YTITLE','YSUBTITLE','COLORS','LABELS']
def_dlim       = CREATE_STRUCT(dtags,'','',50,'')
;;----------------------------------------------------------------------------------------
;;  Define strings for output symbols/representations of various parameters
;;----------------------------------------------------------------------------------------
;;  Define subscripts
specs_subscrpt = [species[0],alpha_str[0]]
Vbulk_subscrpt = vel_subscs[0]+','+specs_subscrpt
VTher_subscrpt = vel_subscs[1]+','+specs_subscrpt
Vpgse_subscrpt = Vbulk_subscrpt[0]+'-'+xyz_str
Vagse_subscrpt = Vbulk_subscrpt[1]+'-'+xyz_str
VTpPa_subscrpt = VTher_subscrpt[0]+'-'+vth_sub_str[1]
VTpPe_subscrpt = VTher_subscrpt[0]+'-'+vth_sub_str[2]
VTaPa_subscrpt = VTher_subscrpt[1]+'-'+vth_sub_str[1]
VTaPe_subscrpt = VTher_subscrpt[1]+'-'+vth_sub_str[2]
;;  Define density strings
Ntot__p_string = 'N!D'+specs_subscrpt[0]+'!N'
Ntot__a_string = 'N!D'+specs_subscrpt[1]+'!N'
;;  Define bulk flow speed strings
Vbulk_p_string = 'V!D'+Vbulk_subscrpt[0]+'!N'
Vbulk_a_string = 'V!D'+Vbulk_subscrpt[1]+'!N'
;;  Define bulk flow velocity strings
Vbgse_p_string = 'V!D'+Vpgse_subscrpt+'!N'
Vbgse_a_string = 'V!D'+Vagse_subscrpt+'!N'
;;  Define Avg. thermal speed strings
VTh___p_string = 'V!D'+VTher_subscrpt[0]+'!N'
VTh___a_string = 'V!D'+VTher_subscrpt[1]+'!N'
;;  Define Para. thermal speed strings
VThPa_p_string = 'V!D'+VTpPa_subscrpt[0]+'!N'
VThPa_a_string = 'V!D'+VTaPa_subscrpt[0]+'!N'
;;  Define Perp. thermal speed strings
VThPe_p_string = 'V!D'+VTpPe_subscrpt[0]+'!N'
VThPe_a_string = 'V!D'+VTaPe_subscrpt[0]+'!N'
;;  Define magnetic field strings
Bgse____string = 'B!D'+coord_gse[0]+',SWE!N'
;;----------------------------------------------------------------------------------------
;;  Define units string outputs
;;----------------------------------------------------------------------------------------
vel_units      = 'km/s'
den_units      = 'cm!U-3!N'
mag_units      = 'nT'
;;----------------------------------------------------------------------------------------
;;  Define string outputs inside brackets, e.g., '[ {info}, {units} ]'
;;----------------------------------------------------------------------------------------
swe_pref       = '[SWE, '
Ntot__brack    = swe_pref[0]+den_units[0]+']'
Vel___brack    = swe_pref[0]+vel_units[0]+']'
Bgse__brack    = swe_pref[0]+mag_units[0]+', GSE]'
Vgse__brack    = swe_pref[0]+vel_units[0]+', GSE]'
;;----------------------------------------------------------------------------------------
;;  Define Y-Titles [for Plots]
;;----------------------------------------------------------------------------------------
;;  Protons
Ntot__p_yttl   = Ntot__p_string[0]+' '+Ntot__brack[0]
Vbulk_p_yttl   = Vbulk_p_string[0]+' '+Vel___brack[0]
Vbgse_p_yttl   =    Vbgse_p_string+' '+Vgse__brack[0]
VTh___p_yttl   = VTh___p_string[0]+' '+Vel___brack[0]
VThPa_p_yttl   = VThPa_p_string[0]+' '+Vel___brack[0]
VThPe_p_yttl   = VThPe_p_string[0]+' '+Vel___brack[0]
;;  Alphas
Ntot__a_yttl   = Ntot__a_string[0]+' '+Ntot__brack[0]
Vbulk_a_yttl   = Vbulk_a_string[0]+' '+Vel___brack[0]
Vbgse_a_yttl   =    Vbgse_a_string+' '+Vgse__brack[0]
VTh___a_yttl   = VTh___a_string[0]+' '+Vel___brack[0]
VThPa_a_yttl   = VThPa_a_string[0]+' '+Vel___brack[0]
VThPe_a_yttl   = VThPe_a_string[0]+' '+Vel___brack[0]
;;  B-field
Bgse____yttl   = Bgse____string[0]+' '+Bgse__brack[0]
;;----------------------------------------------------------------------------------------
;;  Define system variable parameters
;;----------------------------------------------------------------------------------------
mdir           = FILE_EXPAND_PATH('')
slash          = get_os_slash()         ;;  '/' for Unix, '\' for Windows
;;  Check for trailing '/' or '\'
ll             = STRMID(mdir, STRLEN(mdir) - 1L,1L)
test_ll        = (ll[0] NE slash[0])
IF (test_ll) THEN mdir = mdir[0]+slash[0]

;;  Make sure system variable has been initialized
DEFSYSV,'!wind3dp_umn',EXISTS=exists
IF NOT KEYWORD_SET(exists) THEN BEGIN
  wind_3dp_umn_init
ENDIF
;;----------------------------------------------------------------------------------------
;;  Define defaults
;;----------------------------------------------------------------------------------------
defdir         = !wind3dp_umn.WIND_DATA1[0]     ;;  e.g., '~/wind_3dp_pros/wind_data_dir/data1/wind/'
def_swe_dir    = defdir[0]+'swe'+slash[0]
def_h1_dir     = def_swe_dir[0]+'h1'+slash[0]
def_master     = 'wi_h1_swe_files'
test           = GETENV(STRUPCASE(def_master[0])) EQ ''
IF (test) THEN SETENV,'WI_H1_SWE_FILES='+def_h1_dir[0]+'????'+slash[0]+'wi_h1_swe*.cdf'

test           = (N_ELEMENTS(masterfile) EQ 0) OR (SIZE(masterfile,/TYPE) NE 7L) OR $
                 ~KEYWORD_SET(masterfile)
IF (test) THEN fmaster = def_master[0] ELSE fmaster = masterfile[0]

;;  All relevant CDF names
cdf_time_names = ['Epoch','year','doy']
;cdf_time_names = ['Epoch','year','doy','time']
cdf_pron_names = ['Proton_V_nonlin'    ,$
                  'Proton_VX_nonlin'   ,$
                  'Proton_VY_nonlin'   ,$
                  'Proton_VZ_nonlin'   ,$
                  'Proton_W_nonlin'    ,$
                  'Proton_Wperp_nonlin',$
                  'Proton_Wpar_nonlin' ,$
                  'Proton_Np_nonlin'    ]
tpn_pron_names = [vel_p_pref[0]+vel_sub_str+'_'+coord_gseu[0],vel_p_pref[1]+vth_sub_str,dens_tpn_pa[0]]
cdf_pros_names = ['Proton_sigmaV_nonlin'    ,$
                  'Proton_sigmaVX_nonlin'   ,$
                  'Proton_sigmaVY_nonlin'   ,$
                  'Proton_sigmaVZ_nonlin'   ,$
                  'Proton_sigmaW_nonlin'    ,$
                  'Proton_sigmaWperp_nonlin',$
                  'Proton_sigmaWpar_nonlin' ,$
                  'Proton_sigmaNp_nonlin'    ]
tpn_pros_names = tpn_pron_names+'_1sigma'
cdf_alpn_names = ['Alpha_V_nonlin'     ,$
                  'Alpha_VX_nonlin'    ,$
                  'Alpha_VY_nonlin'    ,$
                  'Alpha_VZ_nonlin'    ,$
                  'Alpha_W_nonlin'     ,$
                  'Alpha_Wperp_nonlin' ,$
                  'Alpha_Wpar_nonlin'  ,$
                  'Alpha_Na_nonlin'     ]
tpn_alpn_names = [vel_a_pref[0]+vel_sub_str+'_'+coord_gseu[0],vel_a_pref[1]+vth_sub_str,dens_tpn_pa[1]]
cdf_alps_names = ['Alpha_sigmaV_nonlin'     ,$
                  'Alpha_sigmaVX_nonlin'    ,$
                  'Alpha_sigmaVY_nonlin'    ,$
                  'Alpha_sigmaVZ_nonlin'    ,$
                  'Alpha_sigmaW_nonlin'     ,$
                  'Alpha_sigmaWperp_nonlin' ,$
                  'Alpha_sigmaWpar_nonlin'  ,$
                  'Alpha_sigmaNa_nonlin'     ]
tpn_alps_names = tpn_alpn_names+'_1sigma'
cdf_magf_names = ['BX','BY','BZ']
tpn_magf_names = magf_pref

all_cdf_names  = cdf_time_names
;;  Check if user wants to load 1-sigma uncertainties
test_sig       = (N_ELEMENTS(load_sigma) EQ 0) OR ~KEYWORD_SET(load_sigma)
IF (test_sig) THEN BEGIN
  cdf_prot_names = cdf_pron_names
  cdf_alph_names = cdf_alpn_names
  tpn_prot_names = tpn_pron_names
  tpn_alph_names = tpn_alpn_names
ENDIF ELSE BEGIN
  cdf_prot_names = [cdf_pron_names,cdf_pros_names]
  cdf_alph_names = [cdf_alpn_names,cdf_alps_names]
  tpn_prot_names = [tpn_pron_names,tpn_pros_names]
  tpn_alph_names = [tpn_alpn_names,tpn_alps_names]
ENDELSE
;;  Check if user doesn't want to load proton moments
test_np        = (N_ELEMENTS(no_protons) EQ 0) OR ~KEYWORD_SET(no_protons)
IF (test_np) THEN BEGIN
  all_cdf_names  = [all_cdf_names,cdf_prot_names]
  all_tpn_names  = tpn_prot_names
ENDIF
;;  Check if user doesn't want to load alpha-particle moments
test_na        = (N_ELEMENTS(no_alphas) EQ 0) OR ~KEYWORD_SET(no_alphas)
IF (test_na) THEN BEGIN
  all_cdf_names  = [all_cdf_names,cdf_alph_names]
  all_tpn_names  = [all_tpn_names,tpn_alph_names]
ENDIF
;;  Check if user doesn't want to load the magnetic fields used for moments
test_nb        = (N_ELEMENTS(no_swe_b) EQ 0) OR ~KEYWORD_SET(no_swe_b)
IF (test_na) THEN BEGIN
  all_cdf_names  = [all_cdf_names,cdf_magf_names]
  all_tpn_names  = [all_tpn_names,tpn_magf_names]
ENDIF
;;----------------------------------------------------------------------------------------
;;  Load SWE data
;;----------------------------------------------------------------------------------------
loadallcdf,TIME_RANGE=trange,MASTERFILE=fmaster,CDFNAMES=all_cdf_names,DATA=data

IF (SIZE(data,/TYPE) NE 8) THEN RETURN                         ;;  no data returned...

IF (N_TAGS(data) LT N_ELEMENTS(all_cdf_names)) THEN RETURN     ;;  something went wrong...
;;----------------------------------------------------------------------------------------
;;  Define parameters
;;----------------------------------------------------------------------------------------
unix           = data.TIME
d_tags         = STRLOWCASE(TAG_NAMES(data))
;;----------------------------------------------------------------------------------------
;;  Test Protons
;;----------------------------------------------------------------------------------------
IF (test_np) THEN BEGIN
  cdf_tags       = STRLOWCASE(cdf_pron_names)
  tplot_nms      = tpn_pron_names
  np             = N_ELEMENTS(tplot_nms)
  ;;--------------------------------------------------------------------------------------
  ;;  Send Proton moments to TPLOT
  ;;--------------------------------------------------------------------------------------
  FOR j=0L, np - 1L DO BEGIN
    good = WHERE(d_tags EQ cdf_tags[j],gd)
    ;;  Reset DLIM
    dlim = def_dlim
    IF (gd GT 0) THEN BEGIN
      tp_name = tplot_nms[j]
      CASE cdf_tags[j] OF
        'proton_v_nonlin'      :  BEGIN        ;;  Proton bulk flow velocity magnitude [km/s]
          tpstruc = {X:unix,Y:data.PROTON_V_NONLIN}
          yttl    = Vbulk_p_yttl[0]
          labs    = 'V'+vel_sub_str[0]
        END
        'proton_vx_nonlin'     :  BEGIN        ;;  " " X-GSE component [km/s]
          tpstruc = {X:unix,Y:data.PROTON_VX_NONLIN}
          yttl    = Vbgse_p_yttl[0]
          labs    = 'V'+xyz_str[0]
        END
        'proton_vy_nonlin'     :  BEGIN        ;;  " " Y-GSE component [km/s]
          tpstruc = {X:unix,Y:data.PROTON_VY_NONLIN}
          yttl    = Vbgse_p_yttl[1]
          labs    = 'V'+xyz_str[1]
        END
        'proton_vz_nonlin'     :  BEGIN        ;;  " " Z-GSE component [km/s]
          tpstruc = {X:unix,Y:data.PROTON_VZ_NONLIN}
          yttl    = Vbgse_p_yttl[2]
          labs    = 'V'+xyz_str[2]
        END
        'proton_w_nonlin'      :  BEGIN        ;;  Proton Avg. thermal speed [km/s]
          tpstruc = {X:unix,Y:data.PROTON_W_NONLIN}
          yttl    = VTh___p_yttl[0]
          labs    = 'V'+vel_subscs[1]+vth_sub_str[0]
        END
        'proton_wperp_nonlin'  :  BEGIN        ;;  Proton Perp. thermal speed [km/s]
          tpstruc = {X:unix,Y:data.PROTON_WPERP_NONLIN}
          yttl    = VThPe_p_yttl[0]
          labs    = 'V'+vel_subscs[1]+vth_sub_str[2]
        END
        'proton_wpar_nonlin'   :  BEGIN        ;;  Proton Para. thermal speed [km/s]
          tpstruc = {X:unix,Y:data.PROTON_WPAR_NONLIN}
          yttl    = VThPa_p_yttl[0]
          labs    = 'V'+vel_subscs[1]+vth_sub_str[1]
        END
        'proton_np_nonlin'     :  BEGIN        ;;  Proton number density [cm^(-3)]
          tpstruc = {X:unix,Y:data.PROTON_NP_NONLIN}
          yttl    = Ntot__p_yttl[0]
          labs    = 'N'+species[0]
        END
        ELSE                   :  BEGIN
          ;;  No match
          tp_name = ''
          yttl    = ''
          labs    = ''
        END
      ENDCASE
      ;;  Alter DLIM
      IF (yttl[0] NE '') THEN str_element,dlim,'YTITLE',yttl[0],/ADD_REPLACE
      IF (yttl[0] NE '') THEN str_element,dlim,'YSUBTITLE','['+spec_ysub[0]+']',/ADD_REPLACE
      IF (labs[0] NE '') THEN str_element,dlim,'LABELS',labs[0],/ADD_REPLACE
      ;;  Make sure TPLOT handle is defined before sending to TPLOT
      test  = (tp_name[0] NE '')
      IF (test) THEN store_data,tp_name[0],DATA=tpstruc,DLIM=dlim,LIM=def_lim
    ENDIF
  ENDFOR
  ;;--------------------------------------------------------------------------------------
  ;;  Remove "bad" data points if present
  ;;--------------------------------------------------------------------------------------
  tn0 = tnames('V_Th_p__avg')
  IF (tn0[0] NE '') THEN BEGIN
    get_data,tn0[0],DATA=temp,DLIM=dlim,LIM=lim
    bad = WHERE(ABS(temp.Y) GT 1d3,bd)
    IF (bd GT 0) THEN BEGIN
      tplot_nms      = tpn_pron_names
      np             = N_ELEMENTS(tplot_nms)
      FOR j=0L, np - 1L DO BEGIN
        tn0 = tnames(tplot_nms[j])
        IF (tn0[0] NE '') THEN BEGIN
          get_data,tn0[0],DATA=temp,DLIM=dlim,LIM=lim
          szy = SIZE(temp.Y,/N_DIMENSIONS)
          CASE szy[0] OF
            1 : temp.Y[bad]   = f
            2 : temp.Y[bad,*] = f
          ENDCASE
          store_data,tn0[0],DATA=temp,DLIM=dlim,LIM=lim
        ENDIF
      ENDFOR
    ENDIF
  ENDIF
  ;;--------------------------------------------------------------------------------------
  ;;--------------------------------------------------------------------------------------
  IF (test_sig EQ 0) THEN BEGIN
    ;;------------------------------------------------------------------------------------
    ;;  Send 1-sigma uncertainties to TPLOT
    ;;------------------------------------------------------------------------------------
    cdf_tags       = STRLOWCASE(cdf_pros_names)
    tplot_nms      = tpn_pros_names
    np             = N_ELEMENTS(tplot_nms)
    FOR j=0L, np - 1L DO BEGIN
      good = WHERE(d_tags EQ cdf_tags[j],gd)
      ;;  Reset DLIM
      dlim = def_dlim
      IF (gd GT 0) THEN BEGIN
        tp_name = tplot_nms[j]
        CASE cdf_tags[j] OF
          'proton_sigmav_nonlin'      :  BEGIN        ;;  Proton bulk flow velocity magnitude [km/s]
            tpstruc = {X:unix,Y:data.PROTON_SIGMAV_NONLIN}
            yttl    = delta_str[0]+Vbulk_p_yttl[0]
            labs    = delta_str[0]+'V'+vel_sub_str[0]
          END
          'proton_sigmavx_nonlin'     :  BEGIN        ;;  " " X-GSE component [km/s]
            tpstruc = {X:unix,Y:data.PROTON_SIGMAVX_NONLIN}
            yttl    = delta_str[0]+Vbgse_p_yttl[0]
            labs    = delta_str[0]+'V'+xyz_str[0]
          END
          'proton_sigmavy_nonlin'     :  BEGIN        ;;  " " Y-GSE component [km/s]
            tpstruc = {X:unix,Y:data.PROTON_SIGMAVY_NONLIN}
            yttl    = delta_str[0]+Vbgse_p_yttl[1]
            labs    = delta_str[0]+'V'+xyz_str[1]
          END
          'proton_sigmavz_nonlin'     :  BEGIN        ;;  " " Z-GSE component [km/s]
            tpstruc = {X:unix,Y:data.PROTON_SIGMAVZ_NONLIN}
            yttl    = delta_str[0]+Vbgse_p_yttl[2]
            labs    = delta_str[0]+'V'+xyz_str[2]
          END
          'proton_sigmaw_nonlin'      :  BEGIN        ;;  Proton Avg. thermal speed [km/s]
            tpstruc = {X:unix,Y:data.PROTON_SIGMAW_NONLIN}
            yttl    = delta_str[0]+VTh___p_yttl[0]
            labs    = delta_str[0]+'V'+vel_subscs[1]+vth_sub_str[0]
          END
          'proton_sigmawperp_nonlin'  :  BEGIN        ;;  Proton Perp. thermal speed [km/s]
            tpstruc = {X:unix,Y:data.PROTON_SIGMAWPERP_NONLIN}
            yttl    = delta_str[0]+VThPe_p_yttl[0]
            labs    = delta_str[0]+'V'+vel_subscs[1]+vth_sub_str[2]
          END
          'proton_sigmawpar_nonlin'   :  BEGIN        ;;  Proton Para. thermal speed [km/s]
            tpstruc = {X:unix,Y:data.PROTON_SIGMAWPAR_NONLIN}
            yttl    = delta_str[0]+VThPa_p_yttl[0]
            labs    = delta_str[0]+'V'+vel_subscs[1]+vth_sub_str[1]
          END
          'proton_sigmanp_nonlin'     :  BEGIN        ;;  Proton number density [cm^(-3)]
            tpstruc = {X:unix,Y:data.PROTON_SIGMANP_NONLIN}
            yttl    = delta_str[0]+Ntot__p_yttl[0]
            labs    = delta_str[0]+'N'+species[0]
          END
          ELSE                        :  BEGIN
            ;;  No match
            tp_name = ''
            yttl    = ''
            labs    = ''
          END
        ENDCASE
        ;;  Alter DLIM
        IF (yttl[0] NE '') THEN str_element,dlim,'YTITLE',yttl[0],/ADD_REPLACE
        IF (yttl[0] NE '') THEN str_element,dlim,'YSUBTITLE','['+spec_ysub[0]+']',/ADD_REPLACE
        IF (labs[0] NE '') THEN str_element,dlim,'LABELS',labs[0],/ADD_REPLACE
        ;;  Make sure TPLOT handle is defined before sending to TPLOT
        test  = (tp_name[0] NE '')
        IF (test) THEN store_data,tp_name[0],DATA=tpstruc,DLIM=dlim,LIM=def_lim
      ENDIF
    ENDFOR
  ENDIF
ENDIF
;;----------------------------------------------------------------------------------------
;;  Test Alpha-Particles
;;----------------------------------------------------------------------------------------
IF (test_na) THEN BEGIN
  cdf_tags       = STRLOWCASE(cdf_alpn_names)
  tplot_nms      = tpn_alpn_names
  np             = N_ELEMENTS(tplot_nms)
  ;;--------------------------------------------------------------------------------------
  ;;  Send Alpha-Particle moments to TPLOT
  ;;--------------------------------------------------------------------------------------
  FOR j=0L, np - 1L DO BEGIN
    good = WHERE(d_tags EQ cdf_tags[j],gd)
    ;;  Reset DLIM
    dlim = def_dlim
    IF (gd GT 0) THEN BEGIN
      tp_name = tplot_nms[j]
      CASE cdf_tags[j] OF
        'alpha_v_nonlin'      :  BEGIN        ;;  Alpha-Particle bulk flow velocity magnitude [km/s]
          tpstruc = {X:unix,Y:data.ALPHA_V_NONLIN}
          yttl    = Vbulk_a_yttl[0]
          labs    = 'V'+vel_sub_str[0]
        END
        'alpha_vx_nonlin'     :  BEGIN        ;;  " " X-GSE component [km/s]
          tpstruc = {X:unix,Y:data.ALPHA_VX_NONLIN}
          yttl    = Vbgse_a_yttl[0]
          labs    = 'V'+xyz_str[0]
        END
        'alpha_vy_nonlin'     :  BEGIN        ;;  " " Y-GSE component [km/s]
          tpstruc = {X:unix,Y:data.ALPHA_VY_NONLIN}
          yttl    = Vbgse_a_yttl[1]
          labs    = 'V'+xyz_str[1]
        END
        'alpha_vz_nonlin'     :  BEGIN        ;;  " " Z-GSE component [km/s]
          tpstruc = {X:unix,Y:data.ALPHA_VZ_NONLIN}
          yttl    = Vbgse_a_yttl[2]
          labs    = 'V'+xyz_str[2]
        END
        'alpha_w_nonlin'      :  BEGIN        ;;  Alpha-Particle Avg. thermal speed [km/s]
          tpstruc = {X:unix,Y:data.ALPHA_W_NONLIN}
          yttl    = VTh___a_yttl[0]
          labs    = 'V'+vel_subscs[1]+vth_sub_str[0]
        END
        'alpha_wperp_nonlin'  :  BEGIN        ;;  Alpha-Particle Perp. thermal speed [km/s]
          tpstruc = {X:unix,Y:data.ALPHA_WPERP_NONLIN}
          yttl    = VThPe_a_yttl[0]
          labs    = 'V'+vel_subscs[1]+vth_sub_str[2]
        END
        'alpha_wpar_nonlin'   :  BEGIN        ;;  Alpha-Particle Para. thermal speed [km/s]
          tpstruc = {X:unix,Y:data.ALPHA_WPAR_NONLIN}
          yttl    = VThPa_a_yttl[0]
          labs    = 'V'+vel_subscs[1]+vth_sub_str[1]
        END
        'alpha_np_nonlin'     :  BEGIN        ;;  Alpha-Particle number density [cm^(-3)]
          tpstruc = {X:unix,Y:data.ALPHA_NP_NONLIN}
          yttl    = Ntot__a_yttl[0]
          labs    = 'N'+species[1]
        END
        ELSE                   :  BEGIN
          ;;  No match
          tp_name = ''
          yttl    = ''
          labs    = ''
        END
      ENDCASE
      ;;  Alter DLIM
      IF (yttl[0] NE '') THEN str_element,dlim,'YTITLE',yttl[0],/ADD_REPLACE
      IF (yttl[0] NE '') THEN str_element,dlim,'YSUBTITLE','['+spec_ysub[1]+']',/ADD_REPLACE
      IF (labs[0] NE '') THEN str_element,dlim,'LABELS',labs[0],/ADD_REPLACE
      ;;  Make sure TPLOT handle is defined before sending to TPLOT
      test  = (tp_name[0] NE '')
      IF (test) THEN store_data,tp_name[0],DATA=tpstruc,DLIM=dlim,LIM=def_lim
    ENDIF
  ENDFOR
  ;;--------------------------------------------------------------------------------------
  ;;--------------------------------------------------------------------------------------
  IF (test_sig EQ 0) THEN BEGIN
    ;;------------------------------------------------------------------------------------
    ;;  Send 1-sigma uncertainties to TPLOT
    ;;------------------------------------------------------------------------------------
    cdf_tags       = STRLOWCASE(cdf_alps_names)
    tplot_nms      = tpn_alps_names
    np             = N_ELEMENTS(tplot_nms)
    FOR j=0L, np - 1L DO BEGIN
      good = WHERE(d_tags EQ cdf_tags[j],gd)
      ;;  Reset DLIM
      dlim = def_dlim
      IF (gd GT 0) THEN BEGIN
        tp_name = tplot_nms[j]
        CASE cdf_tags[j] OF
          'alpha_sigmav_nonlin'      :  BEGIN        ;;  Alpha-Particle bulk flow velocity magnitude [km/s]
            tpstruc = {X:unix,Y:data.ALPHA_SIGMAV_NONLIN}
            yttl    = delta_str[0]+Vbulk_a_yttl[0]
            labs    = delta_str[0]+'V'+vel_sub_str[0]
          END
          'alpha_sigmavx_nonlin'     :  BEGIN        ;;  " " X-GSE component [km/s]
            tpstruc = {X:unix,Y:data.ALPHA_SIGMAVX_NONLIN}
            yttl    = delta_str[0]+Vbgse_a_yttl[0]
            labs    = delta_str[0]+'V'+xyz_str[0]
          END
          'alpha_sigmavy_nonlin'     :  BEGIN        ;;  " " Y-GSE component [km/s]
            tpstruc = {X:unix,Y:data.ALPHA_SIGMAVY_NONLIN}
            yttl    = delta_str[0]+Vbgse_a_yttl[1]
            labs    = delta_str[0]+'V'+xyz_str[1]
          END
          'alpha_sigmavz_nonlin'     :  BEGIN        ;;  " " Z-GSE component [km/s]
            tpstruc = {X:unix,Y:data.ALPHA_SIGMAVZ_NONLIN}
            yttl    = delta_str[0]+Vbgse_a_yttl[2]
            labs    = delta_str[0]+'V'+xyz_str[2]
          END
          'alpha_sigmaw_nonlin'      :  BEGIN        ;;  Alpha-Particle Avg. thermal speed [km/s]
            tpstruc = {X:unix,Y:data.ALPHA_SIGMAW_NONLIN}
            yttl    = delta_str[0]+VTh___a_yttl[0]
            labs    = delta_str[0]+'V'+vel_subscs[1]+vth_sub_str[0]
          END
          'alpha_sigmawperp_nonlin'  :  BEGIN        ;;  Alpha-Particle Perp. thermal speed [km/s]
            tpstruc = {X:unix,Y:data.ALPHA_SIGMAWPERP_NONLIN}
            yttl    = delta_str[0]+VThPe_a_yttl[0]
            labs    = delta_str[0]+'V'+vel_subscs[1]+vth_sub_str[2]
          END
          'alpha_sigmawpar_nonlin'   :  BEGIN        ;;  Alpha-Particle Para. thermal speed [km/s]
            tpstruc = {X:unix,Y:data.ALPHA_SIGMAWPAR_NONLIN}
            yttl    = delta_str[0]+VThPa_a_yttl[0]
            labs    = delta_str[0]+'V'+vel_subscs[1]+vth_sub_str[1]
          END
          'alpha_sigmanp_nonlin'     :  BEGIN        ;;  Alpha-Particle number density [cm^(-3)]
            tpstruc = {X:unix,Y:data.ALPHA_SIGMANP_NONLIN}
            yttl    = delta_str[0]+Ntot__a_yttl[0]
            labs    = delta_str[0]+'N'+species[1]
          END
          ELSE                        :  BEGIN
            ;;  No match
            tp_name = ''
            yttl    = ''
            labs    = ''
          END
        ENDCASE
        ;;  Alter DLIM
        IF (yttl[0] NE '') THEN str_element,dlim,'YTITLE',yttl[0],/ADD_REPLACE
        IF (yttl[0] NE '') THEN str_element,dlim,'YSUBTITLE','['+spec_ysub[1]+']',/ADD_REPLACE
        IF (labs[0] NE '') THEN str_element,dlim,'LABELS',labs[0],/ADD_REPLACE
        ;;  Make sure TPLOT handle is defined before sending to TPLOT
        test  = (tp_name[0] NE '')
        IF (test) THEN store_data,tp_name[0],DATA=tpstruc,DLIM=dlim,LIM=def_lim
      ENDIF
    ENDFOR
  ENDIF
ENDIF
;;----------------------------------------------------------------------------------------
;;  Test B-field
;;----------------------------------------------------------------------------------------
IF (test_na) THEN BEGIN
  cdf_tags       = STRLOWCASE(cdf_magf_names)
  tplot_nms      = tpn_magf_names
  np             = N_ELEMENTS(tplot_nms)
  test           = [(d_tags EQ cdf_tags[0]),(d_tags EQ cdf_tags[1]),(d_tags EQ cdf_tags[2])]
  good           = WHERE(test,gd)
  IF (gd EQ 3) THEN BEGIN
    bx      = data.(good[0])
    by      = data.(good[1])
    bz      = data.(good[2])
    bgse    = [[bx],[by],[bz]]
    tp_name = tplot_nms[0]
    tpstruc = {X:unix,Y:bgse}
    yttl    = Bgse____yttl[0]
    labs    = 'B'+xyz_str
    cols    = xyz_col
    ysub    = '[B used for SWE]'
    ;;  Reset DLIM
    dlim    = def_dlim
    ;;  Alter DLIM
    str_element,dlim,'YTITLE',yttl[0],/ADD_REPLACE
    str_element,dlim,'YSUBTITLE',ysub[0],/ADD_REPLACE
    str_element,dlim,'LABELS',labs,/ADD_REPLACE
    str_element,dlim,'COLORS',cols,/ADD_REPLACE
    ;;  Make sure TPLOT handle is defined before sending to TPLOT
    test    = (tp_name[0] NE '')
    IF (test) THEN store_data,tp_name[0],DATA=tpstruc,DLIM=dlim,LIM=def_lim
  ENDIF
ENDIF
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN
END

;;  ['Epoch','year','doy','Proton_V_nonlin','Proton_sigmaV_nonlin','Proton_VX_nonlin','Proton_sigmaVX_nonlin','Proton_VY_nonlin','Proton_sigmaVY_nonlin','Proton_VZ_nonlin','Proton_sigmaVZ_nonlin','Proton_W_nonlin','Proton_sigmaW_nonlin','Proton_Wperp_nonlin','Proton_sigmaWperp_nonlin','Proton_Wpar_nonlin','Proton_sigmaWpar_nonlin','EW_flowangle','SigmaEW_flowangle','NS_flowangle','SigmaNS_flowangle','Proton_Np_nonlin','Proton_sigmaNp_nonlin','Alpha_V_nonlin','Alpha_sigmaV_nonlin','Alpha_VX_nonlin','Alpha_sigmaVX_nonlin','Alpha_VY_nonlin','Alpha_sigmaVY_nonlin','Alpha_VZ_nonlin','Alpha_sigmaVZ_nonlin','Alpha_W_nonlin','Alpha_sigmaW_nonlin','Alpha_Wperp_nonlin','Alpha_sigmaWperp_nonlin','Alpha_Wpar_nonlin','Alpha_sigmaWpar_nonlin','Alpha_Na_nonlin','Alpha_sigmaNa_nonlin','ChisQ_DOF_nonlin','Peak_doy','sigmaPeak_doy','Proton_V_moment','Proton_VX_moment','Proton_VY_moment','Proton_VZ_moment','Proton_W_moment','Proton_Wperp_moment','Proton_Wpar_moment','Proton_Np_moment','BX','BY','BZ','Ang_dev','dev','xgse','ygse','zgse']
;;cdf_prot_names = ['Proton_V_nonlin'    ,'Proton_sigmaV_nonlin'    ,$
;;                  'Proton_VX_nonlin'   ,'Proton_sigmaVX_nonlin'   ,$
;;                  'Proton_VY_nonlin'   ,'Proton_sigmaVY_nonlin'   ,$
;;                  'Proton_VZ_nonlin'   ,'Proton_sigmaVZ_nonlin'   ,$
;;                  'Proton_W_nonlin'    ,'Proton_sigmaW_nonlin'    ,$
;;                  'Proton_Wperp_nonlin','Proton_sigmaWperp_nonlin',$
;;                  'Proton_Wpar_nonlin' ,'Proton_sigmaWpar_nonlin' ,$
;;                  'Proton_Np_nonlin'   ,'Proton_sigmaNp_nonlin'    ]
;;cdf_alph_names = ['Alpha_V_nonlin'     ,'Alpha_sigmaV_nonlin'     ,$
;;                  'Alpha_VX_nonlin'    ,'Alpha_sigmaVX_nonlin'    ,$
;;                  'Alpha_VY_nonlin'    ,'Alpha_sigmaVY_nonlin'    ,$
;;                  'Alpha_VZ_nonlin'    ,'Alpha_sigmaVZ_nonlin'    ,$
;;                  'Alpha_W_nonlin'     ,'Alpha_sigmaW_nonlin'     ,$
;;                  'Alpha_Wperp_nonlin' ,'Alpha_sigmaWperp_nonlin' ,$
;;                  'Alpha_Wpar_nonlin'  ,'Alpha_sigmaWpar_nonlin'  ,$
;;                  'Alpha_Na_nonlin'    ,'Alpha_sigmaNa_nonlin'     ]


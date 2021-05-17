;+
;*****************************************************************************************
;
;  BATCH    :   example_load_Wind_mfi_swe_3dp_waves_data_batch.pro
;  PURPOSE  :   Loads data and creates setup for the crib sheet labeled
;                 example_load_Wind_mfi_swe_3dp_waves_data_crib.pro
;
;  CALLED BY:   
;               example_load_Wind_mfi_swe_3dp_waves_data_crib.pro
;
;  INCLUDES:
;               NA
;
;  CALLS:
;               time_double.pro
;               load_constants_fund_em_atomic_c2014_batch.pro
;               load_constants_extra_part_co2014_ci2015_batch.pro
;               load_constants_astronomical_aa2015_batch.pro
;               test_file_path_format.pro
;               get_valid_trange.pro
;               general_load_and_save_wind_3dp_data.pro
;               test_tplot_handle.pro
;               add_scpot.pro
;               add_magf2.pro
;               add_vsw2.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               NA
;
;  EXAMPLES:    
;               [calling sequence]
;               Usage:  Copy the following in the command line [*** AFTER changing the directory path accordingly ***]
;               @/Users/lbwilson/Desktop/swidl-0.1/wind_3dp_pros/wind_3dp_cribs/example_load_Wind_mfi_swe_3dp_waves_data_batch.pro
;
;  KEYWORDS:    
;               NA
;
;   CHANGED:  1)  Added Man. page
;                                                                   [05/11/2021   v1.0.1]
;
;   NOTES:      
;               NA
;
;  REFERENCES:  
;               NA
;
;   CREATED:  05/10/2021
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  05/11/2021   v1.0.1
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

;;----------------------------------------------------------------------------------------
;;  Constants
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN

start_of_day   = '00:00:00.000000'
end___of_day   = '23:59:59.999999'
tdate0         = '1997-08-14'
tdate1         = '1998-05-01'
tt_01          = [tdate0[0],tdate1[0]]+'/'+start_of_day[0]
tran           = time_double(tt_01)
sc             = 'Wind'
scpref         = sc[0]+'_'
;;  Get fundamental and astronomical
@load_constants_fund_em_atomic_c2014_batch.pro
@load_constants_extra_part_co2014_ci2015_batch.pro
@load_constants_astronomical_aa2015_batch.pro
;;  Conversion factors
;;    Energy and Temperature
f_1eV          = qq[0]/hh[0]              ;;  Freq. associated with 1 eV of energy [ Hz --> f_1eV*energy{eV} = freq{Hz} ]
eV2J           = hh[0]*f_1eV[0]           ;;  Energy associated with 1 eV of energy [ J --> J_1eV*energy{eV} = energy{J} ]
eV2K           = qq[0]/kB[0]              ;;  Temp. associated with 1 eV of energy [11,604.5221 K/eV, 2014 CODATA/NIST --> eV2K*energy{eV} = Temp{K}]
K2eV           = kB[0]/qq[0]              ;;  Energy associated with 1 K Temp. [8.6173303 x 10^(-5) eV/K, 2014 CODATA/NIST --> K2eV*Temp{K} = energy{eV}]
;;  Frequency factors
wcefac         = 1d-9*qq[0]/me[0]
fcefac         = wcefac[0]/(2d0*!DPI)
neinvf         = (2d0*!DPI)^2d0*epo[0]*me[0]/qq[0]^2d0
wpefac         = SQRT(1d6*qq[0]^2d0/(me[0]*epo[0]))
fpefac         = wpefac[0]/(2d0*!DPI)
;;  Speed factors
vtefac         = SQRT(2d0*eV2J[0]/me[0])*1d-3
;;  Define some coordinate strings
coord_dsl      = 'dsl'
coord_gse      = 'gse'
coord_gsm      = 'gsm'
coord_fac      = 'fac'
coord_mag      = 'mag'
coord_gseu     = STRUPCASE(coord_gse[0])
vec_str        = ['x','y','z']
vec_col        = [250,150, 50]
xyz_str        = vec_str
xyz_col        = vec_col
tensor_str     = ['x'+vec_str,'y'+vec_str[1:2],'zz']
nonmom_suffs   = ['_nonlin','_moms']
swesuff        = '_SWE'
;;  Defaults
badbins        = [00, 02, 04, 06, 08, 09, 10, 11, 13, 15, 17, 19, $
                   20, 21, 66, 68, 70, 72, 74, 75, 76, 77, 79, 81, $
                   83, 85, 86, 87]
;;  Define relevant directories
test           = test_file_path_format(slash[0]+'Users'+slash[0]+'lbwilson'+slash[0],EXISTS=exists,DIR_OUT=home_dir)
test           = test_file_path_format(home_dir[0]+'Desktop'+slash[0]+'temp_idl'+slash[0],EXISTS=exists,DIR_OUT=tidl_dir)
tpnsav_dir     = tidl_dir[0]+'wind_eesa_low_response_stuff'+slash[0]+'tplot_save'+slash[0]
;;----------------------------------------------------------------------------------------
;;  Define and times/dates Probe from input
;;----------------------------------------------------------------------------------------
;;  Check for TDATE and/or TRANGE
time_ra        = get_valid_trange(TDATE=tdate,TRANGE=trange)
trange         = time_ra.UNIX_TRANGE
tdate          = time_ra.DATE_TRANGE[0]
ddate          = STRMID(tdate[0],5L,2L)+STRMID(tdate[0],8L,2L)+STRMID(tdate[0],2L,2L)
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Load MFI, 3DP, and orbit data
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
general_load_and_save_wind_3dp_data,TRANGE=trange,/LOAD_EESA,/LOAD_PESA,/NO_CLEANT, $
                                    EESA_OUT=eesa_out,PESA_OUT=pesa_out,/NO_SAVE,   $
                                    /LOAD_WAVES,/LOAD_SWEFC
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Define structures
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
IF (SIZE(pesa_out.PL_,/TYPE) NE 8) THEN npl_ = 0 ELSE npl_ = N_ELEMENTS(pesa_out.PL_)
IF (SIZE(pesa_out.PLB,/TYPE) NE 8) THEN nplb = 0 ELSE nplb = N_ELEMENTS(pesa_out.PLB)
IF (SIZE(pesa_out.PH_,/TYPE) NE 8) THEN nph_ = 0 ELSE nph_ = N_ELEMENTS(pesa_out.PH_)
IF (SIZE(pesa_out.PHB,/TYPE) NE 8) THEN nphb = 0 ELSE nphb = N_ELEMENTS(pesa_out.PHB)
IF (SIZE(eesa_out.EL_,/TYPE) NE 8) THEN nel_ = 0 ELSE nel_ = N_ELEMENTS(eesa_out.EL_)
IF (SIZE(eesa_out.ELB,/TYPE) NE 8) THEN nelb = 0 ELSE nelb = N_ELEMENTS(eesa_out.ELB)
IF (SIZE(eesa_out.EH_,/TYPE) NE 8) THEN neh_ = 0 ELSE neh_ = N_ELEMENTS(eesa_out.EH_)
IF (SIZE(eesa_out.EHB,/TYPE) NE 8) THEN nehb = 0 ELSE nehb = N_ELEMENTS(eesa_out.EHB)
;;  Define structures
IF (npl_[0] EQ 0) THEN apl_ = 0 ELSE apl_ = pesa_out.PL_
IF (nplb[0] EQ 0) THEN aplb = 0 ELSE aplb = pesa_out.PLB
IF (nph_[0] EQ 0) THEN aph_ = 0 ELSE aph_ = pesa_out.PH_
IF (nphb[0] EQ 0) THEN aphb = 0 ELSE aphb = pesa_out.PHB
IF (nel_[0] EQ 0) THEN ael_ = 0 ELSE ael_ = eesa_out.EL_
IF (nelb[0] EQ 0) THEN aelb = 0 ELSE aelb = eesa_out.ELB
IF (neh_[0] EQ 0) THEN aeh_ = 0 ELSE aeh_ = eesa_out.EH_
IF (nehb[0] EQ 0) THEN aehb = 0 ELSE aehb = eesa_out.EHB
;;  Determine which TPLOT handle to use for estimate of spacecraft potential [eV]
IF (tnames('sc_pot_3') EQ '') THEN scp_tpn0 = 'sc_pot_2' ELSE scp_tpn0 = 'sc_pot_3'
test           = test_tplot_handle(scp_tpn0[0],TPNMS=scp_tpn)
IF (~test[0]) THEN STOP
;;  Define MFI TPLOT handles
new_wibmag_tpn = scpref[0]+'magf_3s_'+coord_mag[0]
new_wibgse_tpn = scpref[0]+'magf_3s_'+coord_gse[0]
test           = test_tplot_handle(new_wibgse_tpn[0],TPNMS=bgse_tpn)
IF (~test[0]) THEN STOP
;;  Define Vsw TPLOT handles
pmom_tpns      = scpref[0]+['Np','Tp','Vp','T3p']
test           = test_tplot_handle(pmom_tpns[2],TPNMS=Vsw_3dp_onbrd)
IF (~test[0]) THEN v3dp_onbrd_on = 0b ELSE v3dp_onbrd_on = 1b
test           = test_tplot_handle('V_sw2',TPNMS=Vsw_3dp_ground)
IF (~test[0]) THEN v3dp_grndd_on = 0b ELSE v3dp_grndd_on = 1b
test           = test_tplot_handle(scpref[0]+'Vbulk_'+coord_gse[0]+swesuff[0]+nonmom_suffs[0],TPNMS=Vsw_swe_ground)
IF (~test[0]) THEN vswe_grndd_on = 0b ELSE vswe_grndd_on = 1b
IF (~v3dp_onbrd_on[0] AND ~v3dp_grndd_on[0] AND ~vswe_grndd_on[0]) THEN STOP
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Assign time-dependent parameters
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Add preliminary SC potential [eV]
IF (npl_[0] GT 0) THEN add_scpot,apl_,scp_tpn[0]
IF (nplb[0] GT 0) THEN add_scpot,aplb,scp_tpn[0]
IF (nph_[0] GT 0) THEN add_scpot,aph_,scp_tpn[0]
IF (nphb[0] GT 0) THEN add_scpot,aphb,scp_tpn[0]
IF (nel_[0] GT 0) THEN add_scpot,ael_,scp_tpn[0]
IF (nelb[0] GT 0) THEN add_scpot,aelb,scp_tpn[0]
IF (neh_[0] GT 0) THEN add_scpot,aeh_,scp_tpn[0]
IF (nehb[0] GT 0) THEN add_scpot,aehb,scp_tpn[0]

IF (npl_[0] GT 0) THEN add_scpot,apl_,scp_tpn[0],/LEAVE_ALONE
IF (nplb[0] GT 0) THEN add_scpot,aplb,scp_tpn[0],/LEAVE_ALONE
IF (nph_[0] GT 0) THEN add_scpot,aph_,scp_tpn[0],/LEAVE_ALONE
IF (nphb[0] GT 0) THEN add_scpot,aphb,scp_tpn[0],/LEAVE_ALONE
IF (nel_[0] GT 0) THEN add_scpot,ael_,scp_tpn[0],/LEAVE_ALONE
IF (nelb[0] GT 0) THEN add_scpot,aelb,scp_tpn[0],/LEAVE_ALONE
IF (neh_[0] GT 0) THEN add_scpot,aeh_,scp_tpn[0],/LEAVE_ALONE
IF (nehb[0] GT 0) THEN add_scpot,aehb,scp_tpn[0],/LEAVE_ALONE
;;  Add B [nT, GSE]
IF (npl_[0] GT 0) THEN add_magf2,apl_,bgse_tpn[0]
IF (nplb[0] GT 0) THEN add_magf2,aplb,bgse_tpn[0]
IF (nph_[0] GT 0) THEN add_magf2,aph_,bgse_tpn[0]
IF (nphb[0] GT 0) THEN add_magf2,aphb,bgse_tpn[0]
IF (nel_[0] GT 0) THEN add_magf2,ael_,bgse_tpn[0]
IF (nelb[0] GT 0) THEN add_magf2,aelb,bgse_tpn[0]
IF (neh_[0] GT 0) THEN add_magf2,aeh_,bgse_tpn[0]
IF (nehb[0] GT 0) THEN add_magf2,aehb,bgse_tpn[0]

IF (npl_[0] GT 0) THEN add_magf2,apl_,bgse_tpn[0],/LEAVE_ALONE
IF (nplb[0] GT 0) THEN add_magf2,aplb,bgse_tpn[0],/LEAVE_ALONE
IF (nph_[0] GT 0) THEN add_magf2,aph_,bgse_tpn[0],/LEAVE_ALONE
IF (nphb[0] GT 0) THEN add_magf2,aphb,bgse_tpn[0],/LEAVE_ALONE
IF (nel_[0] GT 0) THEN add_magf2,ael_,bgse_tpn[0],/LEAVE_ALONE
IF (nelb[0] GT 0) THEN add_magf2,aelb,bgse_tpn[0],/LEAVE_ALONE
IF (neh_[0] GT 0) THEN add_magf2,aeh_,bgse_tpn[0],/LEAVE_ALONE
IF (nehb[0] GT 0) THEN add_magf2,aehb,bgse_tpn[0],/LEAVE_ALONE
;;  Add Vsw [km/s, GSE]
;;  Check if 3DP on board is available
IF (v3dp_onbrd_on[0]) THEN vgse_tpn = Vsw_3dp_onbrd[0]
IF (v3dp_onbrd_on[0]) THEN IF (npl_[0] GT 0) THEN add_vsw2,apl_,vgse_tpn[0]
IF (v3dp_onbrd_on[0]) THEN IF (nplb[0] GT 0) THEN add_vsw2,aplb,vgse_tpn[0]
IF (v3dp_onbrd_on[0]) THEN IF (nph_[0] GT 0) THEN add_vsw2,aph_,vgse_tpn[0]
IF (v3dp_onbrd_on[0]) THEN IF (nphb[0] GT 0) THEN add_vsw2,aphb,vgse_tpn[0]
IF (v3dp_onbrd_on[0]) THEN IF (nel_[0] GT 0) THEN add_vsw2,ael_,vgse_tpn[0]
IF (v3dp_onbrd_on[0]) THEN IF (nelb[0] GT 0) THEN add_vsw2,aelb,vgse_tpn[0]
IF (v3dp_onbrd_on[0]) THEN IF (neh_[0] GT 0) THEN add_vsw2,aeh_,vgse_tpn[0]
IF (v3dp_onbrd_on[0]) THEN IF (nehb[0] GT 0) THEN add_vsw2,aehb,vgse_tpn[0]

IF (vswe_grndd_on[0]) THEN vgse_tpn = Vsw_swe_ground[0] ELSE IF (v3dp_grndd_on[0]) THEN vgse_tpn = Vsw_3dp_ground[0] ELSE vgse_tpn = Vsw_3dp_onbrd[0]
IF (npl_[0] GT 0) THEN IF (v3dp_onbrd_on[0]) THEN add_vsw2,apl_,vgse_tpn[0],/LEAVE_ALONE ELSE add_vsw2,apl_,vgse_tpn[0]
IF (nplb[0] GT 0) THEN IF (v3dp_onbrd_on[0]) THEN add_vsw2,aplb,vgse_tpn[0],/LEAVE_ALONE ELSE add_vsw2,aplb,vgse_tpn[0]
IF (nph_[0] GT 0) THEN IF (v3dp_onbrd_on[0]) THEN add_vsw2,aph_,vgse_tpn[0],/LEAVE_ALONE ELSE add_vsw2,aph_,vgse_tpn[0]
IF (nphb[0] GT 0) THEN IF (v3dp_onbrd_on[0]) THEN add_vsw2,aphb,vgse_tpn[0],/LEAVE_ALONE ELSE add_vsw2,aphb,vgse_tpn[0]
IF (nel_[0] GT 0) THEN IF (v3dp_onbrd_on[0]) THEN add_vsw2,ael_,vgse_tpn[0],/LEAVE_ALONE ELSE add_vsw2,ael_,vgse_tpn[0]
IF (nelb[0] GT 0) THEN IF (v3dp_onbrd_on[0]) THEN add_vsw2,aelb,vgse_tpn[0],/LEAVE_ALONE ELSE add_vsw2,aelb,vgse_tpn[0]
IF (neh_[0] GT 0) THEN IF (v3dp_onbrd_on[0]) THEN add_vsw2,aeh_,vgse_tpn[0],/LEAVE_ALONE ELSE add_vsw2,aeh_,vgse_tpn[0]
IF (nehb[0] GT 0) THEN IF (v3dp_onbrd_on[0]) THEN add_vsw2,aehb,vgse_tpn[0],/LEAVE_ALONE ELSE add_vsw2,aehb,vgse_tpn[0]

IF (npl_[0] GT 0) THEN add_vsw2,apl_,vgse_tpn[0],/LEAVE_ALONE
IF (nplb[0] GT 0) THEN add_vsw2,aplb,vgse_tpn[0],/LEAVE_ALONE
IF (nph_[0] GT 0) THEN add_vsw2,aph_,vgse_tpn[0],/LEAVE_ALONE
IF (nphb[0] GT 0) THEN add_vsw2,aphb,vgse_tpn[0],/LEAVE_ALONE
IF (nel_[0] GT 0) THEN add_vsw2,ael_,vgse_tpn[0],/LEAVE_ALONE
IF (nelb[0] GT 0) THEN add_vsw2,aelb,vgse_tpn[0],/LEAVE_ALONE
IF (neh_[0] GT 0) THEN add_vsw2,aeh_,vgse_tpn[0],/LEAVE_ALONE
IF (nehb[0] GT 0) THEN add_vsw2,aehb,vgse_tpn[0],/LEAVE_ALONE







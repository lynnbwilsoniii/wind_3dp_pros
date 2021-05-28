;+
;*****************************************************************************************
;
;  CRIBSHEET:   example_load_Wind_mfi_swe_waves_3dp_spectra_crib.pro
;  PURPOSE  :   Illustrates example of how to call a companion batch file to load
;                 particle spectra then plot
;
;  CALLED BY:   
;               NA
;
;  INCLUDES:
;               NA
;
;  CALLS:
;               time_double.pro
;               example_load_Wind_mfi_swe_waves_3dp_spectra_0_batch.pro
;               example_load_Wind_mfi_swe_waves_3dp_spectra_1_batch.pro
;               tnames.pro
;               tplot.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               NA
;
;  EXAMPLES:    
;               [calling sequence]
;               ***  Enter the commands below by hand  ***
;
;  KEYWORDS:    
;               NA
;
;   CHANGED:  1)  NA
;                                                                   [MM/DD/YYYY   v1.0.0]
;
;   NOTES:      
;               NA
;
;  REFERENCES:  
;               1)  Lavraud, B., and D.E. Larson "Correcting moments of in situ particle
;                      distribution functions for spacecraft electrostatic charging,"
;                      J. Geophys. Res. 121, pp. 8462--8474, doi:10.1002/2016JA022591,
;                      2016.
;               2)  Meyer-Vernet, N., and C. Perche "Tool kit for antennae and thermal
;                      noise near the plasma frequency," J. Geophys. Res. 94(A3),
;                      pp. 2405--2415, doi:10.1029/JA094iA03p02405, 1989.
;               3)  Meyer-Vernet, N., K. Issautier, and M. Moncuquet "Quasi-thermal noise
;                      spectroscopy: The art and the practice," J. Geophys. Res. 122(8),
;                      pp. 7925--7945, doi:10.1002/2017JA024449, 2017.
;               4)  Paschmann, G. and P.W. Daly (1998), "Analysis Methods for Multi-
;                      Spacecraft Data," ISSI Scientific Report, Noordwijk, 
;                      The Netherlands., Int. Space Sci. Inst.
;               5)  Lin et al., "A Three-Dimensional Plasma and Energetic particle
;                      investigation for the Wind spacecraft," Space Sci. Rev.
;                      71, pp. 125--153, 1995.
;               6)  Bougeret, J.-L., M.L. Kaiser, P.J. Kellogg, R. Manning, K. Goetz,
;                      S.J. Monson, N. Monge, L. Friel, C.A. Meetre, C. Perche,
;                      L. Sitruk, and S. Hoang "WAVES:  The Radio and Plasma Wave
;                      Investigation on the Wind Spacecraft," Space Sci. Rev. 71,
;                      pp. 231--263, doi:10.1007/BF00751331, 1995.
;               7)  M. Wüest, D.S. Evans, and R. von Steiger "Calibration of Particle
;                      Instruments in Space Physics," ESA Publications Division,
;                      Keplerlaan 1, 2200 AG Noordwijk, The Netherlands, 2007.
;               8)  M. Wüest, et al., "Review of Instruments," ISSI Sci. Rep. Ser.
;                      Vol. 7, pp. 11--116, 2007.
;
;   CREATED:  05/28/2021
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  05/28/2021   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

;;  Defaults and general variables
def__lim       = {YSTYLE:1,YMINOR:10L,PANEL_SIZE:2.0,XMINOR:5,XTICKLEN:0.04}
def_dlim       = {LOG:0,SPEC:0,COLORS:50L,LABELS:'1',LABFLAG:-1}
;;----------------------------------------------------------------------------------------
;;  Define Date/Time Range
;;----------------------------------------------------------------------------------------
;;  Define some good SEP event dates
;;    ***  Be careful with memory as this long of an interval will load >19 GB of data  ***
tdate0         = '1998-04-23'
tdate1         = '1998-05-03'

;;  Define time range
start_of_day   = '00:00:00.000000'
end___of_day   = '23:59:59.999999'
tra_t          = [tdate0[0]+'/'+start_of_day[0],tdate1[0]+'/'+end___of_day[0]]
trange         = time_double(tra_t)
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Load MFI, 3DP, and orbit data
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Note:  ***  Change the following directory path accordingly  ***
;;  Enter the following, by hand, from the command line
ex_start       = SYSTIME(1)
@/Users/lbwilson/Desktop/swidl-0.1/wind_3dp_pros/wind_3dp_cribs/example_load_Wind_mfi_swe_waves_3dp_spectra_0_batch.pro
MESSAGE,STRING( SYSTIME(1) - ex_start[0])+' seconds execution time.',/CONTINUE,/INFORMATIONAL
;;  Call 2nd batch file
ex_start       = SYSTIME(1)
@/Users/lbwilson/Desktop/swidl-0.1/wind_3dp_pros/wind_3dp_cribs/example_load_Wind_mfi_swe_waves_3dp_spectra_1_batch.pro
MESSAGE,STRING( SYSTIME(1) - ex_start[0])+' seconds execution time.',/CONTINUE,/INFORMATIONAL

;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Plot MFI and 3DP omnidirectional spectra
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Define TPLOT handles for omnidirectional spectra
elomni_fac     = tnames( tpn_str_eesa_l.OMNI.SPEC_TPLOT_NAME[0])            ;;  EESA Low  (electrons, ~  3 ≤ E ≤  1,200 eV)
ehomni_fac     = tnames(tpn_str_eesa_hc.OMNI.SPEC_TPLOT_NAME[0])            ;;  EESA High (electrons, ~100 ≤ E ≤ 30,000 eV)
plomni_fac     = tnames( tpn_str_pesa_l.OMNI.SPEC_TPLOT_NAME[0])            ;;  PESA Low  (     ions, ~100 ≤ E ≤ 10,000 eV)
phomni_fac     = tnames(tpn_str_pesa_hc.OMNI.SPEC_TPLOT_NAME[0])            ;;  PESA High (     ions, ~500 ≤ E ≤ 30,000 eV)
sfomni_fac     = tnames( tpn_str_sst_fc.OMNI.SPEC_TPLOT_NAME[0])            ;;  SST Foil  (electrons, ~ 20 ≤ E ≤    500 keV)
soomni_fac     = tnames( tpn_str_sst_oc.OMNI.SPEC_TPLOT_NAME[0])            ;;  SST Open  (  protons, ~ 70 ≤ E ≤  6,500 keV)

nna            = [new_wibmag_tpn[0],new_wibgse_tpn[0],elomni_fac[0],ehomni_fac[0],$
                  plomni_fac[0],phomni_fac[0],sfomni_fac[0],soomni_fac[0]]
tplot,nna,TRANGE=trange


;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Clean up omnidirectional spectra
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Kill "bad" data interval in EESA Low
kill_data_tr,NAMES=elomni_fac[0],NKILL=1,TRA_KILLED=tra_killed
PRINT,';;  '+time_string(tra_killed.(0)[0],PREC=3)+'  --  '+time_string(tra_killed.(0)[1],PREC=3)
;;  1998-04-24/19:31:44.000  --  1998-04-24/19:33:02.000

;;  Use the EESA Low time to kill the same "bad" interval seen in PESA Low and High
kill_data_tr,tra_killed.(0),NAMES=[plomni_fac[0],phomni_fac[0]]

;;  Kill specific energy bins only (e.g., one bin has a "spike" but others do not)
;;    -->  EESA Low:  Highest energy starts at 0th bin, lowest at 12th bin [# of energy bins depends upon date and allowed energy range]
kill_data_tr,NAMES=elomni_fac[0],NKILL=1,IND_2D=[0,1]
kill_data_tr,NAMES=elomni_fac[0],NKILL=1,IND_2D=[2,3,4,5]
kill_data_tr,NAMES=elomni_fac[0],NKILL=1,IND_2D=[0]
kill_data_tr,NAMES=elomni_fac[0],NKILL=1,IND_2D=[1]
kill_data_tr,NAMES=elomni_fac[0],NKILL=1,IND_2D=[2]
kill_data_tr,NAMES=elomni_fac[0],NKILL=1,IND_2D=[3]
kill_data_tr,NAMES=elomni_fac[0],NKILL=1,IND_2D=[4]
kill_data_tr,NAMES=elomni_fac[0],NKILL=1,IND_2D=[5]
kill_data_tr,NAMES=elomni_fac[0],NKILL=1,IND_2D=[6]
kill_data_tr,NAMES=elomni_fac[0],NKILL=1,IND_2D=[7]
kill_data_tr,NAMES=elomni_fac[0],NKILL=1,IND_2D=[8]
kill_data_tr,NAMES=elomni_fac[0],NKILL=1,IND_2D=[9]
kill_data_tr,NAMES=elomni_fac[0],NKILL=1,IND_2D=[10]
kill_data_tr,NAMES=elomni_fac[0],NKILL=1,IND_2D=[11]
kill_data_tr,NAMES=elomni_fac[0],NKILL=1,IND_2D=[12]

;;    -->  EESA High:  Highest energy starts at 0th bin, lowest at 13th bin [# of energy bins depends upon date and allowed energy range]
kill_data_tr,NAMES=ehomni_fac[0],NKILL=1,IND_2D=[0,1,2]
kill_data_tr,NAMES=ehomni_fac[0],NKILL=1,IND_2D=[4,5,6,7,8]
kill_data_tr,NAMES=ehomni_fac[0],NKILL=1,IND_2D=[4,5]
kill_data_tr,NAMES=ehomni_fac[0],NKILL=1,IND_2D=[0]
kill_data_tr,NAMES=ehomni_fac[0],NKILL=1,IND_2D=[1]
kill_data_tr,NAMES=ehomni_fac[0],NKILL=1,IND_2D=[2]
kill_data_tr,NAMES=ehomni_fac[0],NKILL=1,IND_2D=[3]
kill_data_tr,NAMES=ehomni_fac[0],NKILL=1,IND_2D=[4]
kill_data_tr,NAMES=ehomni_fac[0],NKILL=1,IND_2D=[5]
kill_data_tr,NAMES=ehomni_fac[0],NKILL=1,IND_2D=[6]
kill_data_tr,NAMES=ehomni_fac[0],NKILL=1,IND_2D=[7]
kill_data_tr,NAMES=ehomni_fac[0],NKILL=1,IND_2D=[8]
kill_data_tr,NAMES=ehomni_fac[0],NKILL=1,IND_2D=[10]
kill_data_tr,NAMES=ehomni_fac[0],NKILL=1,IND_2D=[11]
kill_data_tr,NAMES=ehomni_fac[0],NKILL=1,IND_2D=[12]
kill_data_tr,NAMES=ehomni_fac[0],NKILL=1,IND_2D=[13]

;;    -->  SST Foil:  Highest energy starts at 6th bin, lowest at 0th bin
kill_data_tr,NAMES=sfomni_fac[0],NKILL=1,IND_2D=[0]
kill_data_tr,NAMES=sfomni_fac[0],NKILL=1,IND_2D=[1]
kill_data_tr,NAMES=sfomni_fac[0],NKILL=1,IND_2D=[2]
kill_data_tr,NAMES=sfomni_fac[0],NKILL=1,IND_2D=[3]
kill_data_tr,NAMES=sfomni_fac[0],NKILL=1,IND_2D=[4]
kill_data_tr,NAMES=sfomni_fac[0],NKILL=1,IND_2D=[5]
kill_data_tr,NAMES=sfomni_fac[0],NKILL=1,IND_2D=[6]

;;    -->  SST Open:  Highest energy starts at 8th bin, lowest at 0th bin
kill_data_tr,NAMES=soomni_fac[0],NKILL=1,IND_2D=[0]
kill_data_tr,NAMES=soomni_fac[0],NKILL=1,IND_2D=[1]
kill_data_tr,NAMES=soomni_fac[0],NKILL=1,IND_2D=[2]
kill_data_tr,NAMES=soomni_fac[0],NKILL=1,IND_2D=[3]
kill_data_tr,NAMES=soomni_fac[0],NKILL=1,IND_2D=[4]
kill_data_tr,NAMES=soomni_fac[0],NKILL=1,IND_2D=[5]
kill_data_tr,NAMES=soomni_fac[0],NKILL=1,IND_2D=[6]
kill_data_tr,NAMES=soomni_fac[0],NKILL=1,IND_2D=[7]
kill_data_tr,NAMES=soomni_fac[0],NKILL=1,IND_2D=[8]




















;+
;*****************************************************************************************
;
;  FUNCTION :   estimate_scpot_wind_eesa_low.pro
;  PURPOSE  :   This routine attempts to estimate the spacecraft potential from
;                 the given EESA Low particle velocity distribution functions (VDFs).
;
;  CALLED BY:   
;               NA
;
;  INCLUDES:
;               NA
;
;  CALLS:
;               load_constants_fund_em_atomic_c2014_batch.pro
;               load_constants_extra_part_co2014_ci2015_batch.pro
;               test_wind_vs_themis_esa_struct.pro
;               tplot_struct_format_test.pro
;               lbw_window.pro
;               t_resample_tplot_struc.pro
;               lbw_spec3d.pro
;               sign.pro
;               moments_3d_new.pro
;               lbw_scpot_el.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               AEL_       :  [N]-Element [numeric] array of IDL data structures from
;                               the Wind/3DP EESA Low instrument in survey mode
;                               [see get_el.pro]
;               ***  Optional Inputs  ***
;               AELB       :  [M]-Element [numeric] array of IDL data structures from
;                               the Wind/3DP EESA Low instrument in burst mode
;                               [see get_elb.pro]
;
;  EXAMPLES:    
;               [calling sequence]
;               scpot_str = estimate_scpot_wind_eesa_low(ael_ [,aelb] [,NETNR=netnr] $
;                                                 [,SCPMIN=scpmin] [,SCPMAX=scpmax] [,/NOMSSG])
;
;  KEYWORDS:    
;               NETNR      :  Scalar [TPLOT structure] containing the electron number
;                               density [cm^(-3)] estimated from the WAVES TNR data
;                               with the following tags and formats:
;                                 X  :  [K]-Element [double] array of Unix times
;                                 Y  :  [K,2]-Element [numeric] array of Ne values [low/upp]
;               SCPMIN     :  Scalar [numeric] defining a lower bound on the spacecraft
;                               potential [eV] value allowed from any calculation
;                               [Default = 0.1]
;               SCPMAX     :  Scalar [numeric] defining a upper bound on the spacecraft
;                               potential [eV] value allowed from any calculation
;                               [Default = 30]
;               NOMSSG     :  If set, routine will not inform user of elapsed computational
;                               time [s]
;                               [Default = FALSE]
;
;   CHANGED:  1)  Finished writing and cleaned up and
;                   renamed from temp_estimate_scpot_wind_eesa_low.pro to
;                   estimate_scpot_wind_eesa_low.pro
;                                                                   [10/28/2020   v1.1.0]
;             2)  Fixed an issue that sometimes occurs when E_min > phi_sc
;                                                                   [11/02/2020   v1.1.1]
;             3)  Fixed an issue if the user inputs the incorrect format for the Y tag
;                   for the NETNR input structure and added some more comments
;                                                                   [05/11/2021   v1.1.2]
;             4)  Corrected an issue where input VDF had null or NaN values for MAGF tag
;                   causing lbw_spec3d.pro to return null outputs.  Now sets dummy vector
;                   of [1,0,0] since the spacecraft potential doesn't really care about
;                   MAGF (at least not enough to matter here)
;                                                                   [11/01/2024   v1.1.3]
;
;   NOTES:      
;               1)  See also:
;                     get_el.pro
;                     get_elb.pro
;                     lbw_spec3d.pro
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
;               9)  Wilson III, L.B., et al., "Electron energy partition across
;                      interplanetary shocks: I. Methodology and Data Product,"
;                      Astrophys. J. Suppl. 243(8), doi:10.3847/1538-4365/ab22bd, 2019a.
;              10)  Wilson III, L.B., et al., "Electron energy partition across
;                      interplanetary shocks: II. Statistics,"
;                      Astrophys. J. Suppl. 245(24), doi:10.3847/1538-4365/ab5445, 2019b.
;              11)  Wilson III, L.B., et al., "Electron energy partition across
;                      interplanetary shocks: III. Analysis,"
;                      Astrophys. J., Accepted Mar. 4, 2020.
;              12)  Wilson III, L.B., et al., "A Quarter Century of Wind Spacecraft
;                      Discoveries," Rev. Geophys. 59(2), pp. e2020RG000714,
;                      doi:10.1029/2020RG000714, 2021.
;              13)  Wilson III, L.B., et al., "The need for accurate measurements of
;                      thermal velocity distribution functions in the solar wind,"
;                      Front. Astron. Space Sci. 9, pp. 1063841,
;                      doi:10.3389/fspas.2022.1063841, 2022.
;              14)  Wilson III, L.B., et al., "Spacecraft floating potential measurements
;                      for the Wind spacecraft," Astrophys. J. Suppl. 269(52), pp. 10,
;                      doi:10.3847/1538-4365/ad0633, 2023.
;
;   CREATED:  10/27/2020
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  11/01/2024   v1.1.3
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION estimate_scpot_wind_eesa_low,ael_,aelb,NETNR=netnr,SCPMIN=scpmin,SCPMAX=scpmax,NOMSSG=nomssg

ex_start       = SYSTIME(1)
;;----------------------------------------------------------------------------------------
;;  Define some constants and dummy variables
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
@load_constants_fund_em_atomic_c2014_batch.pro
@load_constants_extra_part_co2014_ci2015_batch.pro
def_scpmin     = 1d-1
def_scpmax     = 3d1
;;  Energy and Temperature
f_1eV          = qq[0]/hh[0]          ;;  Freq. associated with 1 eV of energy [ Hz --> f_1eV*energy{eV} = freq{Hz} ]
eV2J           = hh[0]*f_1eV[0]       ;;  Energy associated with 1 eV of energy [ J --> J_1eV*energy{eV} = energy{J} ]
eV2K           = qq[0]/kB[0]          ;;  Temp. associated with 1 eV of energy [11,604.5221 K/eV, 2014 CODATA/NIST --> K_eV*energy{eV} = Temp{K}]
K2eV           = kB[0]/qq[0]          ;;  Energy associated with 1 K Temp. [8.6173303 x 10^(-5) eV/K, 2014 CODATA/NIST --> eV_K*Temp{K} = energy{eV}]
;;  Define the cut pitch-angle ranges for averaging
cutran         = 22.5d0
cut_mids       = [22.5d0,9d1,157.5d0]   ;;  Default mid angles [deg] about which to define a range over which to average
cut_lows       = cut_mids - cutran[0]
cut_high       = cut_mids + cutran[0]
;;  Define some plot stuff for lbw_spec3d.pro
units          = 'eflux'
esa_eran       = [1e0,1.2e3]
esa_yran       = [1e4,4e8]
esa_lim        = {XRANGE:esa_eran,YRANGE:esa_yran,XLOG:1,YLOG:1,XSTYLE:1,YSTYLE:1}
;;  Error messages
noinput_mssg   = 'No input was supplied...'
badstr_mssg    = 'Not an appropriate 3DP structure...'
;;----------------------------------------------------------------------------------------
;;  Check input
;;----------------------------------------------------------------------------------------
IF (N_PARAMS() LT 1) THEN BEGIN
  MESSAGE,noinput_mssg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
IF (N_PARAMS() LT 2) THEN aelb = 0
;;  Check DAT structure format
test0          = test_wind_vs_themis_esa_struct(ael_,/NOM)
test           = (test0.(0) + test0.(1)) NE 1
IF (test[0]) THEN BEGIN
  MESSAGE,badstr_mssg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
nel_           = N_ELEMENTS(ael_)
IF (SIZE(aelb,/TYPE) EQ 8) THEN BEGIN
  test0          = test_wind_vs_themis_esa_struct(aelb,/NOM)
  test           = (test0.(0) + test0.(1)) NE 1
  IF (test[0]) THEN BEGIN
    nelb           = 0L
    aelb           = 0
  ENDIF ELSE BEGIN
    ;;  EESA Low Burst set too!
    nelb           = N_ELEMENTS(aelb)
  ENDELSE
ENDIF ELSE nelb = 0L
;;----------------------------------------------------------------------------------------
;;  Check keywords
;;----------------------------------------------------------------------------------------
;;  Check NETNR
IF (tplot_struct_format_test(netnr,/NOMSSG)) THEN BEGIN
  ne_tnr_on      = 1b
  net_str        = netnr
  szdnety        = SIZE(net_str.Y,/N_DIMENSIONS)
  IF (szdnety[0] EQ 2) THEN BEGIN
    szddety        = SIZE(net_str.Y,/DIMENSIONS)
    IF (szddety[1] NE 2) THEN BEGIN
      ;;  Incorrect input format for NETNR keyword!!!
      MESSAGE,"Incorrect input format for NETNR keyword:  Must be [N,2]-element array!",/INFORMATIONAL,/CONTINUE
      ne_tnr_on      = 0b
    ENDIF
  ENDIF ELSE BEGIN
    ;;  Incorrect input format for NETNR keyword!!!
    MESSAGE,"Incorrect input format for NETNR keyword:  Must be 2D array!",/INFORMATIONAL,/CONTINUE
    ne_tnr_on      = 0b
  ENDELSE
ENDIF ELSE BEGIN
  ne_tnr_on      = 0b
ENDELSE
;;  Check SCPMIN
IF (is_a_number(scpmin,/NOMSSG)) THEN scp_min = 1d0*scpmin[0] ELSE scp_min = def_scpmin[0]
;;  Check SCPMIN
IF (is_a_number(scpmax,/NOMSSG)) THEN scpot_max = 1d0*scpmax[0] ELSE scpot_max = def_scpmax[0]
;;----------------------------------------------------------------------------------------
;;  Open 1 plot window
;;----------------------------------------------------------------------------------------
dev_name                = STRLOWCASE(!D[0].NAME[0])
os__name                = STRLOWCASE(!VERSION.OS_FAMILY)       ;;  'unix' or 'windows'
;;  Check device settings
test_xwin               = (dev_name[0] EQ 'x') OR (dev_name[0] EQ 'win')
IF (test_xwin[0]) THEN BEGIN
  ;;  Proper setting --> find out which windows are already open
  DEVICE,WINDOW_STATE=wstate
ENDIF ELSE BEGIN
  ;;  Switch to proper device
  IF (os__name[0] EQ 'windows') THEN SET_PLOT,'win' ELSE SET_PLOT,'x'
  ;;  Determine which windows are already open
  DEVICE,WINDOW_STATE=wstate
ENDELSE
DEVICE,GET_SCREEN_SIZE=s_size
wsz                     = LONG(MIN(s_size*7d-1))
xywsz                   = [wsz[0],LONG(wsz[0]*1.375d0)]
win_ttl                 = '1D EESA Low Spectra'
win_str                 = {RETAIN:2,XSIZE:xywsz[0],YSIZE:xywsz[1],TITLE:win_ttl[0],XPOS:10,YPOS:10}
lbw_window,WIND_N=5L,NEW_W=1b,_EXTRA=win_str,/CLEAN
;;----------------------------------------------------------------------------------------
;;  Define params
;;----------------------------------------------------------------------------------------
IF (nelb[0] GT 0) THEN BEGIN
  ;;  Survey and burst data available
  all_el         = [ael_,aelb]
  n_el           = N_ELEMENTS(all_el)
ENDIF ELSE BEGIN
  all_el         = ael_
  n_el           = N_ELEMENTS(all_el)
ENDELSE
;;  Sort by time
st_el          = all_el.TIME
sp             = SORT(st_el)
all_el         = TEMPORARY(all_el[sp])
st_el          = all_el.TIME
en_el          = all_el.END_TIME
se_el          = [[st_el],[en_el]]
;;  Define number of energy and angle bins
n_e            = all_el[0].NENERGY
n_a            = all_el[0].NBINS
szed           = SIZE(all_el.ENERGY,/DIMENSIONS)
good           = WHERE(szed EQ n_el[0],gd)
ebins_l        = MEAN(MEAN(all_el.ENERGY,/NAN,DIMENSION=(good[0] + 1L)),/NAN,DIMENSION=2L)
;;----------------------------------------------------------------------------------------
;;  Remove NaNs or all-zeros from MAGF tag
;;----------------------------------------------------------------------------------------
test0          = ((FINITE(all_el.MAGF[0]) EQ 0) AND (FINITE(all_el.MAGF[1]) EQ 0) AND (FINITE(all_el.MAGF[2]) EQ 0))
test1          = ((ABS(all_el.MAGF[0]) EQ 0) AND (ABS(all_el.MAGF[1]) EQ 0) AND (ABS(all_el.MAGF[2]) EQ 0))
bad            = WHERE(test0 OR test1,bd)
IF (bd[0] GT 0) THEN BEGIN
  ;;  Some MAGF tags had bad values --> replace
  dumbvec        = [1e0,0e0,0e0]
  FOR k=0L, 2L DO all_el[bad].MAGF[k] = dumbvec[k]
ENDIF
;;----------------------------------------------------------------------------------------
;;  Resample NETNR to EESA Low times (if present)
;;----------------------------------------------------------------------------------------
IF (ne_tnr_on[0]) THEN BEGIN
  ;;  Interpolate NETNR to EL times
  net_at_elst    = t_resample_tplot_struc(net_str,st_el,/NO_EXTRAPOLATE,/IGNORE_INT)
  net_at_elen    = t_resample_tplot_struc(net_str,en_el,/NO_EXTRAPOLATE,/IGNORE_INT)
  IF (SIZE(net_at_elst,/TYPE) NE 8 OR SIZE(net_at_elen,/TYPE) NE 8) THEN ne_tnr_on      = 0b
ENDIF
;;----------------------------------------------------------------------------------------
;;  Define new energy bin array with more bins
;;----------------------------------------------------------------------------------------
ne2            = 121L
mnmx_en        = [MIN(ebins_l,/NAN),MAX(ebins_l,/NAN)]
l10_mnx        = ALOG10(mnmx_en)
l10_exe        = DINDGEN(ne2[0])*(l10_mnx[1] - l10_mnx[0])/(ne2[0] - 1L) + l10_mnx[0]
ext_ens        = 1d1^l10_exe
;;----------------------------------------------------------------------------------------
;;  Loop through to find SC potential
;;----------------------------------------------------------------------------------------
;;  Array dimensions are defined as:
;;    N  :  # of EESA Low VDFs (combined survey and burst VDFs)
;;    3  :  # of pitch-angle average directions, i.e., parallel, perpendicular, and anti-parallel
;;    2  :  [lower,upper] bounds corresponding to the [lower,upper] bounds of the total electron density provided on input
scpot_pcurv    = REPLICATE(d,n_el[0],3L,2L)                      ;;  SC potential [eV] from positive curvature test
scpot_mxnfE    = scpot_pcurv                                     ;;  " " from the inflection point where df/dE < 0 --> df/dE > 0
scpot_mnxcr    = scpot_pcurv                                     ;;  " " from minimum/maximum of curvature --> bounds on SC potential
scpot_mnf_E    = scpot_pcurv[*,*,0L]                             ;;  " " from minimum in f_j(E)
scpot_vmoms    = REPLICATE(d,n_el[0],4L)                         ;;  " " from inverting the velocity moment calculations [*** Requires NETNR to be properly set ***]
FOR jj=0L, n_el[0] - 1L DO BEGIN
  ;;--------------------------------------------------------------------------------------
  ;;  Reset variables
  ;;--------------------------------------------------------------------------------------
  pang           = 1b
  df___de        = REPLICATE(d,ne2[0],3L)
  d2f_de2        = df___de
  IF (N_ELEMENTS(xdat) GT 0) THEN dumb = TEMPORARY(xdat)
  IF (N_ELEMENTS(ydat) GT 0) THEN dumb = TEMPORARY(ydat)
  ;;--------------------------------------------------------------------------------------
  ;;  Define EL structure
  ;;--------------------------------------------------------------------------------------
  dat            = all_el[jj]
;  ;;  Check MAGF tag
;  IF ((TOTAL(FINITE(dat[0].MAGF)) NE 3) OR (TOTAL(ABS(dat[0].MAGF) EQ 0) EQ 3)) THEN dat[0].MAGF = [1e0,0e0,0e0]
  ;;  Plot data
  WSET,5L
  WSHOW,5L
  lbw_spec3d,dat,LIMITS=esa_lim,UNITS=units,PITCHANGLE=pang,RM_PHOTO_E=0b,XDAT=xdat,YDAT=ydat
  ;;--------------------------------------------------------------------------------------
  ;;  Check output
  ;;--------------------------------------------------------------------------------------
  szxd           = SIZE(xdat,/DIMENSIONS)
  szyd           = SIZE(xdat,/DIMENSIONS)
  szpd           = SIZE(pang,/DIMENSIONS)
  testx          = (TOTAL(szxd EQ n_e[0]) EQ 1) AND (TOTAL(szxd EQ n_a[0]) EQ 1)
  testy          = (TOTAL(szyd EQ n_e[0]) EQ 1) AND (TOTAL(szyd EQ n_a[0]) EQ 1)
  testp          = (TOTAL(szpd EQ n_a[0]) EQ 1)
  test           = testx[0] AND testy[0] AND testp[0]
  IF (~test[0]) THEN CONTINUE                    ;;  Something is wrong --> skip to next iteration
  ;;--------------------------------------------------------------------------------------
  ;;  Define elements satisfying pitch-angle ranges
  ;;--------------------------------------------------------------------------------------
  good_para_esa  = WHERE((pang LE cut_high[0]) AND (pang GE cut_lows[0]),gd_para)
  good_perp_esa  = WHERE((pang LE cut_high[1]) AND (pang GE cut_lows[1]),gd_perp)
  good_anti_esa  = WHERE((pang LE cut_high[2]) AND (pang GE cut_lows[2]),gd_anti)
  test           = (gd_para[0] GT 0) AND (gd_perp[0] GT 0) AND (gd_anti[0] GT 0)
  IF (~test[0]) THEN CONTINUE                    ;;  Something is wrong --> skip to next iteration
  ;;  Average over these ranges
  Avgf_para_esa  = MEAN(ydat[*,good_para_esa],DIMENSION=2L,/NAN)
  Avgf_perp_esa  = MEAN(ydat[*,good_perp_esa],DIMENSION=2L,/NAN)
  Avgf_anti_esa  = MEAN(ydat[*,good_anti_esa],DIMENSION=2L,/NAN)
  Avgf_papean_e  = [[Avgf_para_esa],[Avgf_perp_esa],[Avgf_anti_esa]]
  ;;--------------------------------------------------------------------------------------
  ;;  Increase energy resolution to improve gradient calculations
  ;;--------------------------------------------------------------------------------------
  l10_avgf__all  = ALOG10(Avgf_papean_e)
  l10_avgf_para  = INTERPOL(l10_avgf__all[*,0L],ALOG10(ebins_l),ALOG10(ext_ens))
  l10_avgf_perp  = INTERPOL(l10_avgf__all[*,1L],ALOG10(ebins_l),ALOG10(ext_ens))
  l10_avgf_anti  = INTERPOL(l10_avgf__all[*,2L],ALOG10(ebins_l),ALOG10(ext_ens))
  Newf_para_esa  = 1d1^l10_avgf_para
  Newf_perp_esa  = 1d1^l10_avgf_perp
  Newf_anti_esa  = 1d1^l10_avgf_anti
  ;;  Make sure values don't exceed original ones (i.e., remove unphysical extrapolations)
  bad_para       = WHERE(Newf_para_esa LT MIN(Avgf_papean_e[*,0L],/NAN),bd_para)
  bad_perp       = WHERE(Newf_perp_esa LT MIN(Avgf_papean_e[*,1L],/NAN),bd_perp)
  bad_anti       = WHERE(Newf_anti_esa LT MIN(Avgf_papean_e[*,2L],/NAN),bd_anti)
  IF (bd_para[0] GT 0) THEN Newf_para_esa[bad_para] = MIN(Avgf_papean_e[*,0L],/NAN)
  IF (bd_perp[0] GT 0) THEN Newf_perp_esa[bad_perp] = MIN(Avgf_papean_e[*,1L],/NAN)
  IF (bd_anti[0] GT 0) THEN Newf_anti_esa[bad_anti] = MIN(Avgf_papean_e[*,2L],/NAN)
  bad_para       = WHERE(Newf_para_esa GT MAX(Avgf_papean_e[*,0L],/NAN),bd_para)
  bad_perp       = WHERE(Newf_perp_esa GT MAX(Avgf_papean_e[*,1L],/NAN),bd_perp)
  bad_anti       = WHERE(Newf_anti_esa GT MAX(Avgf_papean_e[*,2L],/NAN),bd_anti)
  IF (bd_para[0] GT 0) THEN Newf_para_esa[bad_para] = MAX(Avgf_papean_e[*,0L],/NAN)
  IF (bd_perp[0] GT 0) THEN Newf_perp_esa[bad_perp] = MAX(Avgf_papean_e[*,1L],/NAN)
  IF (bd_anti[0] GT 0) THEN Newf_anti_esa[bad_anti] = MAX(Avgf_papean_e[*,2L],/NAN)
  Newf_papean_e  = [[Newf_para_esa],[Newf_perp_esa],[Newf_anti_esa]]
  ;;--------------------------------------------------------------------------------------
  ;;  Define slope and curvature of f(E) with respect to E
  ;;--------------------------------------------------------------------------------------
  FOR k=0L, 2L DO BEGIN
    slope          = DERIV(ext_ens,Newf_papean_e[*,k])              ;;  df/dE
    curva          = DERIV(ext_ens,slope)                           ;;  d/dE (df/dE)
    df___de[*,k]   = slope
    d2f_de2[*,k]   = curva
  ENDFOR
  ;;--------------------------------------------------------------------------------------
  ;;  First make sure E_min < phi_sc
  ;;--------------------------------------------------------------------------------------
  ;;  df/dE < 0 for first few energy bins
  test_para      = (df___de[0L:1L,0L] LT 0)  AND (FINITE(df___de[0L:1L,0L]) AND FINITE(ext_ens[0L:1L]))
  test_perp      = (df___de[0L:1L,1L] LT 0)  AND (FINITE(df___de[0L:1L,1L]) AND FINITE(ext_ens[0L:1L]))
  test_anti      = (df___de[0L:1L,2L] LT 0)  AND (FINITE(df___de[0L:1L,2L]) AND FINITE(ext_ens[0L:1L]))
  good_para      = WHERE(test_para,gd_para)
  good_perp      = WHERE(test_perp,gd_perp)
  good_anti      = WHERE(test_anti,gd_anti)
  test           = (gd_para[0] GT 0) OR (gd_perp[0] GT 0) OR (gd_anti[0] GT 0)
  IF (test[0]) THEN BEGIN
    ;;------------------------------------------------------------------------------------
    ;;------------------------------------------------------------------------------------
    ;;------------------------------------------------------------------------------------
    ;;  E_min < phi_sc
    ;;------------------------------------------------------------------------------------
    ;;------------------------------------------------------------------------------------
    ;;------------------------------------------------------------------------------------
    ;;  Try to find "kink" in f vs E
    sign_para      = sign(df___de[*,0L])
    sign_perp      = sign(df___de[*,1L])
    sign_anti      = sign(df___de[*,2L])
    ind            = DINDGEN(ne2[0]) + 1d0
    dsdi_para      = DERIV(ind,sign_para)
    dsdi_perp      = DERIV(ind,sign_perp)
    dsdi_anti      = DERIV(ind,sign_anti)
    test_para      = (dsdi_para GT 0)  AND (FINITE(dsdi_para) AND FINITE(ext_ens)) AND (ext_ens LE scpot_max[0])
    test_perp      = (dsdi_perp GT 0)  AND (FINITE(dsdi_perp) AND FINITE(ext_ens)) AND (ext_ens LE scpot_max[0])
    test_anti      = (dsdi_anti GT 0)  AND (FINITE(dsdi_anti) AND FINITE(ext_ens)) AND (ext_ens LE scpot_max[0])
    good_para      = WHERE(test_para,gd_para)
    good_perp      = WHERE(test_perp,gd_perp)
    good_anti      = WHERE(test_anti,gd_anti)
    ;;------------------------------------------------------------------------------------
    ;;  Find inflection point
    ;;------------------------------------------------------------------------------------
    IF (gd_para[0] GT 0) THEN BEGIN
      low            = (MIN(good_para) > 1L) < (ne2[0] - 1L)
      gind_para      = low[0] + [-1L,1L]
      scpot_mxnfE[jj,0L,*] = ext_ens[gind_para]
    ENDIF
    IF (gd_perp[0] GT 0) THEN BEGIN
      low            = (MIN(good_perp) > 1L) < (ne2[0] - 1L)
      gind_perp      = low[0] + [-1L,1L]
      scpot_mxnfE[jj,1L,*] = ext_ens[gind_perp]
    ENDIF
    IF (gd_anti[0] GT 0) THEN BEGIN
      low            = (MIN(good_anti) > 1L) < (ne2[0] - 1L)
      gind_anti      = low[0] + [-1L,1L]
      scpot_mxnfE[jj,2L,*] = ext_ens[gind_anti]
    ENDIF
    ;;------------------------------------------------------------------------------------
    ;;  Find positive curvature below SCPot_max
    ;;------------------------------------------------------------------------------------
    test_para      = (d2f_de2[*,0] GT 0) AND (FINITE(d2f_de2[*,0]) AND FINITE(ext_ens)) AND (ext_ens LE scpot_max[0])
    test_perp      = (d2f_de2[*,1] GT 0) AND (FINITE(d2f_de2[*,1]) AND FINITE(ext_ens)) AND (ext_ens LE scpot_max[0])
    test_anti      = (d2f_de2[*,2] GT 0) AND (FINITE(d2f_de2[*,2]) AND FINITE(ext_ens)) AND (ext_ens LE scpot_max[0])
    good_para      = WHERE(test_para,gd_para)
    good_perp      = WHERE(test_perp,gd_perp)
    good_anti      = WHERE(test_anti,gd_anti)
    IF (gd_para[0] GT 0) THEN scpot_pcurv[jj,0L,*] = ([MIN(ext_ens[good_para],/NAN),MAX(ext_ens[good_para],/NAN)] > scp_min[0]) < scpot_max[0]
    IF (gd_perp[0] GT 0) THEN scpot_pcurv[jj,1L,*] = ([MIN(ext_ens[good_perp],/NAN),MAX(ext_ens[good_perp],/NAN)] > scp_min[0]) < scpot_max[0]
    IF (gd_anti[0] GT 0) THEN scpot_pcurv[jj,2L,*] = ([MIN(ext_ens[good_anti],/NAN),MAX(ext_ens[good_anti],/NAN)] > scp_min[0]) < scpot_max[0]
    test           = (gd_para[0] GT 0) AND (gd_perp[0] GT 0) AND (gd_anti[0] GT 0)
    IF (~test[0]) THEN CONTINUE                    ;;  Something is wrong --> skip to next iteration
    ;;------------------------------------------------------------------------------------
    ;;  Find minimum/maximum of curvature --> bounds on SC potential
    ;;------------------------------------------------------------------------------------
    ebins_00       = [ext_ens[good_para],ext_ens[good_perp],ext_ens[good_anti]]
    mnmx_eran      = [MIN(ebins_00,/NAN),MAX(ebins_00,/NAN)]
    test_para      = ((ext_ens LE mnmx_eran[1]) AND (ext_ens GE mnmx_eran[0])) AND (FINITE(d2f_de2[*,0]) AND FINITE(ext_ens))
    test_perp      = ((ext_ens LE mnmx_eran[1]) AND (ext_ens GE mnmx_eran[0])) AND (FINITE(d2f_de2[*,1]) AND FINITE(ext_ens))
    test_anti      = ((ext_ens LE mnmx_eran[1]) AND (ext_ens GE mnmx_eran[0])) AND (FINITE(d2f_de2[*,2]) AND FINITE(ext_ens))
    good_para      = WHERE(test_para,gd_para)
    good_perp      = WHERE(test_perp,gd_perp)
    good_anti      = WHERE(test_anti,gd_anti)
    IF (gd_para[0] GT 0) THEN BEGIN
      mnslop_para    = MIN(ABS(df___de[good_para,0L]),lnspara,/NAN)
      mncurv_para    =     MIN(d2f_de2[good_para,0L], ln_para,/NAN)
      mxcurv_para    =     MAX(d2f_de2[good_para,0L], lx_para,/NAN)
      mnmx_para      = ([ext_ens[good_para[ln_para[0]]], ext_ens[good_para[lx_para[0]]]]).SORT()
      scpot_mnxcr[jj,0L,*] = (mnmx_para > scp_min[0]) < scpot_max[0]
      ;;----------------------------------------------------------------------------------
      ;;  Use bounds to find minima in f_j(E)
      ;;----------------------------------------------------------------------------------
      test_para      = ((ext_ens LE mnmx_para[1]) AND (ext_ens GE mnmx_para[0])) AND (FINITE(Newf_papean_e[*,0]) AND FINITE(ext_ens))
      good_para      = WHERE(test_para,gd_para)
      IF (gd_para[0] GT 0) THEN BEGIN
        minf_e_para    = MIN(Newf_papean_e[good_para,0L],ln_para,/NAN)
        scpot_mnf_E[jj,0L] = (ext_ens[good_para[ln_para[0]]] > scp_min[0]) < scpot_max[0]
      ENDIF
    ENDIF
    IF (gd_perp[0] GT 0) THEN BEGIN
      mnslop_perp    = MIN(ABS(df___de[good_perp,0L]),lnsperp,/NAN)
      mncurv_perp    =     MIN(d2f_de2[good_perp,0L], ln_perp,/NAN)
      mxcurv_perp    =     MAX(d2f_de2[good_perp,0L], lx_perp,/NAN)
      mnmx_perp      = ([ext_ens[good_perp[ln_perp[0]]], ext_ens[good_perp[lx_perp[0]]]]).SORT()
      scpot_mnxcr[jj,1L,*] = (mnmx_perp > scp_min[0]) < scpot_max[0]
      ;;----------------------------------------------------------------------------------
      ;;  Use bounds to find minima in f_j(E)
      ;;----------------------------------------------------------------------------------
      test_perp      = ((ext_ens LE mnmx_perp[1]) AND (ext_ens GE mnmx_perp[0])) AND (FINITE(Newf_papean_e[*,1]) AND FINITE(ext_ens))
      good_perp      = WHERE(test_perp,gd_perp)
      IF (gd_perp[0] GT 0) THEN BEGIN
        minf_e_perp    = MIN(Newf_papean_e[good_perp,1L],ln_perp,/NAN)
        scpot_mnf_E[jj,1L] = (ext_ens[good_perp[ln_perp[0]]] > scp_min[0]) < scpot_max[0]
      ENDIF
    ENDIF
    IF (gd_anti[0] GT 0) THEN BEGIN
      mnslop_anti    = MIN(ABS(df___de[good_anti,0L]),lnsanti,/NAN)
      mncurv_anti    =     MIN(d2f_de2[good_anti,0L], ln_anti,/NAN)
      mxcurv_anti    =     MAX(d2f_de2[good_anti,0L], lx_anti,/NAN)
      mnmx_anti      = ([ext_ens[good_anti[ln_anti[0]]], ext_ens[good_anti[lx_anti[0]]]]).SORT()
      scpot_mnxcr[jj,2L,*] = (mnmx_anti > scp_min[0]) < scpot_max[0]
      ;;----------------------------------------------------------------------------------
      ;;  Use bounds to find minima in f_j(E)
      ;;----------------------------------------------------------------------------------
      test_anti      = ((ext_ens LE mnmx_anti[1]) AND (ext_ens GE mnmx_anti[0])) AND (FINITE(Newf_papean_e[*,2]) AND FINITE(ext_ens))
      good_anti      = WHERE(test_anti,gd_anti)
      IF (gd_anti[0] GT 0) THEN BEGIN
        minf_e_anti    = MIN(Newf_papean_e[good_anti,2L],ln_anti,/NAN)
        scpot_mnf_E[jj,2L] = (ext_ens[good_anti[ln_anti[0]]] > scp_min[0]) < scpot_max[0]
      ENDIF
    ENDIF
    ;;------------------------------------------------------------------------------------
    ;;  Check if user wants to use velocity moments to find SC potential
    ;;------------------------------------------------------------------------------------
    IF (ne_tnr_on[0]) THEN BEGIN
      net_lu_st      = REFORM(net_at_elst.Y[jj,*])            ;;  Ne [cm^(-3)]  {low,upp} at start of EL
      net_lu_en      = REFORM(net_at_elen.Y[jj,*])            ;;  Ne [cm^(-3)]  {low,upp} at end   of EL
      mom_l__st      = moments_3d_new(dat,TRUE_DENS=net_lu_st[0],MAGDIR=dat[0].MAGF)
      mom_u__st      = moments_3d_new(dat,TRUE_DENS=net_lu_st[1],MAGDIR=dat[0].MAGF)
      mom_l__en      = moments_3d_new(dat,TRUE_DENS=net_lu_en[0],MAGDIR=dat[0].MAGF)
      mom_u__en      = moments_3d_new(dat,TRUE_DENS=net_lu_en[1],MAGDIR=dat[0].MAGF)
      IF (SIZE(mom_l__st,/TYPE) EQ 8) THEN scpot_vmoms[jj,0L] = (mom_l__st[0].SC_POT[0] > scp_min[0]) < scpot_max[0]
      IF (SIZE(mom_u__st,/TYPE) EQ 8) THEN scpot_vmoms[jj,1L] = (mom_u__st[0].SC_POT[0] > scp_min[0]) < scpot_max[0]
      IF (SIZE(mom_l__en,/TYPE) EQ 8) THEN scpot_vmoms[jj,2L] = (mom_l__en[0].SC_POT[0] > scp_min[0]) < scpot_max[0]
      IF (SIZE(mom_u__en,/TYPE) EQ 8) THEN scpot_vmoms[jj,3L] = (mom_u__en[0].SC_POT[0] > scp_min[0]) < scpot_max[0]
    ENDIF
  ENDIF ELSE BEGIN
    ;;------------------------------------------------------------------------------------
    ;;------------------------------------------------------------------------------------
    ;;------------------------------------------------------------------------------------
    ;;  E_min > phi_sc  --> Can't use the above methods
    ;;------------------------------------------------------------------------------------
    ;;------------------------------------------------------------------------------------
    ;;------------------------------------------------------------------------------------
    phi_sc_guess         = 99d-2*MIN(ext_ens,/NAN)
    IF (ne_tnr_on[0]) THEN BEGIN
      ;;----------------------------------------------------------------------------------
      ;;  Check if user wants to use velocity moments to find SC potential
      ;;    [***  Less reliable if anodes are not properly calibrated  ***]
      ;;----------------------------------------------------------------------------------
      net_lu_st      = REFORM(net_at_elst.Y[jj,*])            ;;  Ne [cm^(-3)]  {low,upp} at start of EL
      net_lu_en      = REFORM(net_at_elen.Y[jj,*])            ;;  Ne [cm^(-3)]  {low,upp} at end   of EL
      mom_l__st      = moments_3d_new(dat,TRUE_DENS=net_lu_st[0],MAGDIR=dat[0].MAGF)
      mom_u__st      = moments_3d_new(dat,TRUE_DENS=net_lu_st[1],MAGDIR=dat[0].MAGF)
      mom_l__en      = moments_3d_new(dat,TRUE_DENS=net_lu_en[0],MAGDIR=dat[0].MAGF)
      mom_u__en      = moments_3d_new(dat,TRUE_DENS=net_lu_en[1],MAGDIR=dat[0].MAGF)
      IF (SIZE(mom_l__st,/TYPE) EQ 8) THEN scpot_vmoms[jj,0L] = (mom_l__st[0].SC_POT[0] > scp_min[0]) < scpot_max[0]
      IF (SIZE(mom_u__st,/TYPE) EQ 8) THEN scpot_vmoms[jj,1L] = (mom_u__st[0].SC_POT[0] > scp_min[0]) < scpot_max[0]
      IF (SIZE(mom_l__en,/TYPE) EQ 8) THEN scpot_vmoms[jj,2L] = (mom_l__en[0].SC_POT[0] > scp_min[0]) < scpot_max[0]
      IF (SIZE(mom_u__en,/TYPE) EQ 8) THEN scpot_vmoms[jj,3L] = (mom_u__en[0].SC_POT[0] > scp_min[0]) < scpot_max[0]
      ;;----------------------------------------------------------------------------------
      ;;  Use model to estimate phi_sc [eV]
      ;;----------------------------------------------------------------------------------
      sc_pot_0       = lbw_scpot_el(dat,DENS=[net_lu_st,net_lu_en],SC_POT_2=sc_pot_se)
      IF (sc_pot_0[0] GT 0) THEN BEGIN
        ;;--------------------------------------------------------------------------------
        ;;  Routine returned a valid result --> use
        ;;--------------------------------------------------------------------------------
        lower                = sc_pot_0[0] < phi_sc_guess[0]
        upper                = sc_pot_0[0] > phi_sc_guess[0]
        scpot_pcurv[jj,*,0L] = scp_min[0] < lower[0]
        scpot_pcurv[jj,*,1L] = upper[0] > scp_min[0]
        scpot_mxnfE[jj,*,0L] = scp_min[0] < lower[0]
        scpot_mxnfE[jj,*,1L] = upper[0] > scp_min[0]
        scpot_mnxcr[jj,*,0L] = scp_min[0] < lower[0]
        scpot_mnxcr[jj,*,1L] = upper[0] > scp_min[0]
        test                 = (TOTAL(FINITE(sc_pot_se)) EQ 4) AND (TOTAL(sc_pot_se GT 0) EQ 4)
        IF (test[0]) THEN scpot_mnf_E[jj,*] = MEDIAN(sc_pot_se) < upper[0] ELSE scpot_mnf_E[jj,*] = phi_sc_guess[0]
      ENDIF ELSE BEGIN
        ;;--------------------------------------------------------------------------------
        ;;  Routine did not return a valid result --> use dummy defaults
        ;;--------------------------------------------------------------------------------
        scpot_pcurv[jj,*,0L] = scp_min[0] < phi_sc_guess[0]
        scpot_pcurv[jj,*,1L] = phi_sc_guess[0] > scp_min[0]
        scpot_mxnfE[jj,*,0L] = scp_min[0] < phi_sc_guess[0]
        scpot_mxnfE[jj,*,1L] = phi_sc_guess[0] > scp_min[0]
        scpot_mnxcr[jj,*,0L] = scp_min[0] < phi_sc_guess[0]
        scpot_mnxcr[jj,*,1L] = phi_sc_guess[0] > scp_min[0]
        scpot_mnf_E[jj,*]    = phi_sc_guess[0]
      ENDELSE
      ;;----------------------------------------------------------------------------------
      ;;  Make sure lower and upper bounds are unique
      ;;----------------------------------------------------------------------------------
      IF (scpot_pcurv[jj,0L,0L] EQ scpot_pcurv[jj,0L,1L]) THEN BEGIN
        scpot_pcurv[jj,0L,*] = scpot_pcurv[jj,0L,*]*[9d-1,1.1d0]
        scpot_pcurv[jj,*,0L] = scpot_pcurv[jj,0L,0L]
        scpot_pcurv[jj,*,1L] = scpot_pcurv[jj,0L,1L]
      ENDIF
      IF (scpot_mxnfE[jj,0L,0L] EQ scpot_mxnfE[jj,0L,1L]) THEN BEGIN
        scpot_mxnfE[jj,0L,*] = scpot_mxnfE[jj,0L,*]*[9d-1,1.1d0]
        scpot_mxnfE[jj,*,0L] = scpot_mxnfE[jj,0L,0L]
        scpot_mxnfE[jj,*,1L] = scpot_mxnfE[jj,0L,1L]
      ENDIF
      IF (scpot_mnxcr[jj,0L,0L] EQ scpot_mnxcr[jj,0L,1L]) THEN BEGIN
        scpot_mnxcr[jj,0L,*] = scpot_mnxcr[jj,0L,*]*[9d-1,1.1d0]
        scpot_mnxcr[jj,*,0L] = scpot_mnxcr[jj,0L,0L]
        scpot_mnxcr[jj,*,1L] = scpot_mnxcr[jj,0L,1L]
      ENDIF
    ENDIF ELSE BEGIN
      scpot_pcurv[jj,*,0L] = scp_min[0]
      scpot_pcurv[jj,*,1L] = phi_sc_guess[0]
      scpot_mxnfE[jj,*,0L] = scp_min[0]
      scpot_mxnfE[jj,*,1L] = phi_sc_guess[0]
      scpot_mnxcr[jj,*,0L] = scp_min[0]
      scpot_mnxcr[jj,*,1L] = phi_sc_guess[0]
      scpot_mnf_E[jj,*]    = phi_sc_guess[0]
    ENDELSE
  ENDELSE
ENDFOR
;;----------------------------------------------------------------------------------------
;;  Define output
;;----------------------------------------------------------------------------------------
tags           = ['UNIX','ALL_EL','SCPOT_'+['POS_CURV','DFDE_INFLECT','MINMAX_CURV','MIN_F_E','VEL_MOMS']]
struc          = CREATE_STRUCT(tags,se_el,all_el,scpot_pcurv,scpot_mxnfE,scpot_mnxcr,scpot_mnf_E,scpot_vmoms)
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------
ex_time        = SYSTIME(1) - ex_start[0]
IF ~KEYWORD_SET(nomssg) THEN MESSAGE,STRING(ex_time[0])+' seconds execution time.',/CONTINUE,/INFORMATIONAL

RETURN,struc[0]
END





















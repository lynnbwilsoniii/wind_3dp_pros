;+
;*****************************************************************************************
;
;  FUNCTION :   correct_default_gf_wind_3dp_eesa_low.pro
;  PURPOSE  :   This routine starts with known total electron densities from the upper
;                 hybrid line and known spacecraft potentials from the "kinks" in the
;                 electron spectra (when Emin < phi_sc) to correct the default
;                 corrections to the optical geometric factor provided in get_el?.pro.
;                 The routine increases or decreases the default GF until the numerically
;                 integrated number density is within THRESH [%] of the known total
;                 electron densities from the upper hybrid line.  This routine is not
;                 meant to calculate phi_sc for cases when Emin > phi_sc, so only
;                 pass electron velocity distribution functions (VDFs) that satisfy
;                 Emin < phi_sc.
;
;  CALLED BY:   
;               NA
;
;  INCLUDES:
;               NA
;
;  CALLS:
;               test_wind_vs_themis_esa_struct.pro
;               tplot_struct_format_test.pro
;               is_a_number.pro
;               conv_vdfidlstr_2_f_vs_vxyz_thm_wi.pro
;               lbw_nintegrate_3d_vdf.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               IN_EL    :  [N]-Element [structure] array of electron VDFs in the form
;                             of IDL data structures returned from get_el.pro and/or
;                             get_elb.pro
;               NET_STR  :  Scalar [TPLOT structure] containing the total electron
;                             densities from the upper hybrid line where both the X and Y
;                             tags should have [N]-elements already interpolated to the
;                             IN_EL time stamps
;
;  EXAMPLES:    
;               [calling sequence]
;               empgf = correct_default_gf_wind_3dp_eesa_low(in_el,net_str [,THRESH=thresh] $
;                                                            [,VLIM=vlim] [,NGRID=ngrid])
;
;  KEYWORDS:    
;               THRESH   :  Scalar [numeric] defining the threshold [%] to which the
;                             numerically integrated number densities must match the
;                             total electron densities from the upper hybrid line.
;                             Enter values as whole numeric values, not fractions, e.g.,
;                             6.5% would be entered as THRESH=6.5.  The routine will
;                             prevent the user from using values below 2% or above
;                             15%.
;                             [Default = 6.5]
;               VLIM     :  Scalar [numeric] defining the velocity [km/s] limit for x-y
;                             velocity axes over which to plot data
;                             [Default = 15,000 km/s]
;               NGRID    :  Scalar [numeric] defining the number of grid points in each
;                             direction to use when triangulating the data.  The input
;                             will be limited to values between 30 and 300.
;                             [Default = 121]
;
;   CHANGED:  1)  NA
;                                                                   [MM/DD/YYYY   v1.0.0]
;
;   NOTES:      
;               1)  This routine assumes user has already properly determined phi_sc
;                     for each VDF and has interpolated the total electron densities
;                     from the upper hybrid line to the electron VDF time stamps
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
;   CREATED:  12/28/2021
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  12/28/2021   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION correct_default_gf_wind_3dp_eesa_low,in_el,net_str,THRESH=thresh,VLIM=vlim,NGRID=ngrid

ex_start       = SYSTIME(1)
;;----------------------------------------------------------------------------------------
;;  Constants and Defaults
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
;;  Define default 3DP EESA Low optical geometric factor (GF)
def_anode_eff  = [0.977,1.019,0.990,1.125,1.154,0.998,0.977,1.005]
;;  Define some default parameters
def_ngrid      = 121L                                     ;;  Define # of grid points for Delaunay triangulation
def_vlim       = 15d3                                     ;;  Default speed limit = 15,000 km/s
min_vlim       = 10d3                                     ;;  Minimum speed limit = 10,000 km/s
def_thrsh      = 6.5d0                                    ;;  Default threshold = 6.5%
vec1           = [1d0,0d0,0d0]
vec2           = [0d0,1d0,0d0]
vframe         = [0d0,0d0,0d0]
;;  Dummy error messages
badstr_mssg    = 'Not an appropriate 3DP structure...'
baddfor_msg    = 'Incorrect input format:  NET_STR must be an IDL TPLOT structure'
;;----------------------------------------------------------------------------------------
;;  Check input
;;----------------------------------------------------------------------------------------
;;  Check IN_EL structure format
test0          = test_wind_vs_themis_esa_struct(in_el,/NOM)
IF (test0.(0)[0] NE 1) THEN BEGIN
  MESSAGE,badstr_mssg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
;;  Check if TPLOT structure
test           = tplot_struct_format_test(net_str,TEST__V=test__v,TEST_V1_V2=test_v1_v2,$
                                          TEST_DY=test_dy,/NOMSSG)
;test           = tplot_struct_format_test(data,TEST__V=test__v,TEST_V1_V2=test_v1_v2,/NOMSSG)
IF (test[0] EQ 0) THEN BEGIN
  MESSAGE,baddfor_msg,/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
;;----------------------------------------------------------------------------------------
;;  Check keywords
;;----------------------------------------------------------------------------------------
;;  Check THRESH
IF (is_a_number(thresh,/NOMSSG) EQ 0) THEN thresh = def_thrsh[0] ELSE thresh = ABS(thresh[0])
thresh         = (thresh[0] > 2d0) < 15d0
;;  Check VLIM
IF (is_a_number(vlim,/NOMSSG) EQ 0) THEN vlim = def_vlim[0] ELSE vlim = ABS(vlim[0])
IF (vlim[0] LE min_vlim[0]) THEN vlim = def_vlim[0]
;;  Check NGRID
IF (is_a_number(ngrid,/NOMSSG) EQ 0) THEN ngrid = def_ngrid[0] ELSE ngrid = (LONG(ngrid[0]) > 30L) < 300L
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Iteratively adjust default GF until integrated Ne matches WAVES Ne
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Define parameters
cal_el_        = in_el
net_wv_        = net_str
ncel           = N_ELEMENTS(cal_el_)
empir_eff      = REPLICATE(d,ncel[0],N_ELEMENTS(def_anode_eff))
thrsh          = thresh[0]
nupd           = LONG(5d-2*ncel[0]) > 3L            ;;  Number of VDFs to go through before informing user of time elapsed

FOR j=0L, ncel[0] - 1L DO BEGIN
  ;;--------------------------------------------------------------------------------------
  ;;  Define variables for this loop
  ;;--------------------------------------------------------------------------------------
  dat0c          = cal_el_[j]
  netwv          = net_wv_.Y[j]
  IF (FINITE(netwv[0]) EQ 0) THEN CONTINUE
  ;;  Define anodes associated with different poloidal angles
  anode          = BYTE((90 - dat0c[0].THETA)/22.5)
  ;;--------------------------------------------------------------------------------------
  ;;  Initialize relative GF corrections
  ;;--------------------------------------------------------------------------------------
  relgeom_el     = 4*def_anode_eff
  dat0c.GF       = relgeom_el[anode]
  ;;--------------------------------------------------------------------------------------
  ;;  Remove data below phi_sc
  ;;--------------------------------------------------------------------------------------
  temp           = dat0c[0].DATA
  bad            = WHERE(dat0c[0].ENERGY LE 1.0e0*dat0c[0].SC_POT,bd)
  IF (bd[0] GT 0) THEN temp[bad] = f
  dat0c[0].DATA  = temp
  dat0f          = dat0c
  ;;  Convert f(E,theta,phi) to f(vx,vy,vz)
  datcfvxyz      = conv_vdfidlstr_2_f_vs_vxyz_thm_wi(dat0f)
  ;;--------------------------------------------------------------------------------------
  ;;  Numerically integrate to find Ne [cm^(-3)]
  ;;--------------------------------------------------------------------------------------
  mag_dir        = REFORM(dat0c[0].MAGF)
  vels           = datcfvxyz.VELXYZ
  data           = datcfvxyz.VDF
  ffit_momc      = lbw_nintegrate_3d_vdf(vels,data,VLIM=vlim,NGRID=ngrid,/SLICE2D,              $
                                         VFRAME=vframe,/ELECTRON,MAG_DIR=mag_dir,VEC1=vec1,     $
                                         VEC2=vec2,/N_S_ONLY)
  ;;--------------------------------------------------------------------------------------
  ;;  Verify output
  ;;--------------------------------------------------------------------------------------
  IF (SIZE(ffit_momc,/TYPE) NE 8) THEN CONTINUE
  IF (FINITE(ffit_momc[0].N_S[0]) EQ 0) THEN CONTINUE
  ;;--------------------------------------------------------------------------------------
  ;;  Calculate percent difference between integrated Ne and that from upper hybrid line
  ;;--------------------------------------------------------------------------------------
  diff_perc      = ABS(ffit_momc[0].N_S[0] - netwv[0])/netwv[0]*1d2
  IF (diff_perc[0] LE thrsh[0]) THEN BEGIN
    ;;------------------------------------------------------------------------------------
    ;;  Good enough --> Define empirical GF correction and move on
    ;;------------------------------------------------------------------------------------
    empir_eff[j,*] = relgeom_el/4d0
    CONTINUE
  ENDIF ELSE BEGIN
    ;;------------------------------------------------------------------------------------
    ;;  Not good enough yet --> Adjust accordingly
    ;;------------------------------------------------------------------------------------
    ;;  Check whether to increase or decrease current GF estimate
    ;;    (Ne,int > Ne,fuh) --> increase ELSE decrease
    ;;    The reason being that this correction term is in the denominator of the
    ;;    unit conversion from counts to phase space density.  Thus, increasing the
    ;;    GF estimate will decrease the resultant Ne,int.
    yes_inc        = ffit_momc[0].N_S[0] GT netwv[0]
    fact           = ([9d-1,11d-1])[yes_inc[0]]
    true           = 0b
    REPEAT BEGIN
      ;;----------------------------------------------------------------------------------
      ;;  Iteratively adjust the GF estimate until Ne,int is within THRESH of Ne,fuh
      ;;----------------------------------------------------------------------------------
      ;;  Multiply by factor
      relgeom_el    *= fact[0]
      dat0c.GF       = relgeom_el[anode]
      dat0f          = dat0c
      datcfvxyz      = conv_vdfidlstr_2_f_vs_vxyz_thm_wi(dat0f)
      mag_dir        = REFORM(dat0c[0].MAGF)
      vels           = datcfvxyz.VELXYZ
      data           = datcfvxyz.VDF
      ffit_momc      = lbw_nintegrate_3d_vdf(vels,data,VLIM=vlim,NGRID=ngrid,/SLICE2D,              $
                                             VFRAME=vframe,/ELECTRON,MAG_DIR=mag_dir,VEC1=vec1,     $
                                             VEC2=vec2,/N_S_ONLY)
      ;;----------------------------------------------------------------------------------
      ;;  Verify output
      ;;----------------------------------------------------------------------------------
      IF (SIZE(ffit_momc,/TYPE) NE 8) THEN BREAK
      IF (FINITE(ffit_momc[0].N_S[0]) EQ 0) THEN BREAK
      ;;----------------------------------------------------------------------------------
      ;; Calculate percent difference between Ne,int and Ne,fuh
      ;;----------------------------------------------------------------------------------
      diff_perc      = ABS(ffit_momc[0].N_S[0] - netwv[0])/netwv[0]*1d2
      IF (diff_perc[0] LE thrsh[0]) THEN BEGIN
        ;;  Good enough --> Define empirical GF correction and move on
        empir_eff[j,*] = relgeom_el/4d0
        true = 1b
      ENDIF ELSE BEGIN
        ;;  Not good enough yet --> Adjust accordingly
        yes_inc        = ffit_momc[0].N_S[0] GT netwv[0]
        fact           = ([9d-1,11d-1])[yes_inc[0]]
      ENDELSE
    ENDREP UNTIL true[0]
  ENDELSE
  ;;--------------------------------------------------------------------------------------
  ;;  Update user on status
  ;;--------------------------------------------------------------------------------------
  IF ((j[0] MOD nupd[0]) EQ 0) THEN PRINT,'j = ',j[0],',  '+STRING(SYSTIME(1) - ex_start[0])+' elapsed seconds...'
ENDFOR
;;----------------------------------------------------------------------------------------
;;  Print total running time
;;----------------------------------------------------------------------------------------
ex_time        = SYSTIME(1) - ex_start[0]
MESSAGE,STRING(ex_time[0])+' seconds execution time.',/CONTINUE,/INFORMATIONAL
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN,empir_eff
END


































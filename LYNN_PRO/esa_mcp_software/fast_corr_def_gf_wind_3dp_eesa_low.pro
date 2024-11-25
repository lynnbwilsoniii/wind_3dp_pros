;+
;*****************************************************************************************
;
;  FUNCTION :   fast_corr_def_gf_wind_3dp_eesa_low.pro
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
;                             IN_EL time stamps [# cm^(-3)]
;
;  EXAMPLES:    
;               [calling sequence]
;               empgf = fast_corr_def_gf_wind_3dp_eesa_low(in_el,net_str [,THRESH=thresh] $
;                                                          [,VLIM=vlim] [,NGRID=ngrid])
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
;   CHANGED:  1)  Removed unnecessary overhead of get_rotated_and_triangulated_vdf.pro and
;                   rotate_and_triangulate_dfs.pro and no calls slice2d_vdf.pro
;                   directly
;                                                                   [05/14/2024   v1.1.0]
;             2)  No longer calls slice2d_vdf.pro, just implements necessary algorithms
;                                                                   [05/14/2024   v1.2.0]
;             3)  Forgot to remove get_rotated_and_triangulated_vdf.pro from adjustment
;                   loop and cleaned up a few minor things
;                                                                   [10/15/2024   v1.2.1]
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
;               9)  Wilson III, L.B., et al., "The Statistical Properties of Solar Wind
;                      Temperature Parameters Near 1 au," Astrophys. J. Suppl. 236(2),
;                      pp. 41, doi:10.3847/1538-4365/aab71c, 2018.
;              10)  Wilson III, L.B., et al., "Electron energy partition across
;                      interplanetary shocks: I. Methodology and Data Product,"
;                      Astrophys. J. Suppl. 243(8), doi:10.3847/1538-4365/ab22bd, 2019a.
;              11)  Wilson III, L.B., et al., "Electron energy partition across
;                      interplanetary shocks: II. Statistics,"
;                      Astrophys. J. Suppl. 245(24), doi:10.3847/1538-4365/ab5445, 2019b.
;              12)  Wilson III, L.B., et al., "Electron energy partition across
;                      interplanetary shocks: III. Analysis,"
;                      Astrophys. J., Accepted Mar. 4, 2020.
;              13)  Wilson III, L.B., et al., "A Quarter Century of Wind Spacecraft
;                      Discoveries," Rev. Geophys. 59(2), pp. e2020RG000714,
;                      doi:10.1029/2020RG000714, 2021.
;              14)  Wilson III, L.B., et al., "The need for accurate measurements of
;                      thermal velocity distribution functions in the solar wind,"
;                      Front. Astron. Space Sci. 9, pp. 1063841,
;                      doi:10.3389/fspas.2022.1063841, 2022.
;              15)  Wilson III, L.B., et al., "Spacecraft floating potential measurements
;                      for the Wind spacecraft," Astrophys. J. Suppl. 269(52), pp. 10,
;                      doi:10.3847/1538-4365/ad0633, 2023.
;              16)  Wilson III, L.B., et al., "Erratum: 'The Statistical Properties of
;                      Solar Wind Temperature Parameters Near 1 au'," Astrophys. J. Suppl.
;                      269(62), pp. 12, doi:10.3847/1538-4365/ad07de, 2023.
;
;   CREATED:  05/09/2024
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  10/15/2024   v1.2.1
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION fast_corr_def_gf_wind_3dp_eesa_low,in_el,net_str,THRESH=thresh,VLIM=vlim,NGRID=ngrid

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
vec1           = [1d0,0d0,0d0]                            ;;  Do not rotate from input GSE coordinates
vec2           = [0d0,1d0,0d0]                            ;;  Do not rotate from input GSE coordinates
vframe         = [0d0,0d0,0d0]                            ;;  Use spacecraft frame of reference
slice_on       = 1b                                       ;;  Use 2D slice routine algorithm
toler          = 1d-6                                     ;;  Tolerance for jitter
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
;;  Define velocity grid and integration factors
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
nm             = ngrid[0]
nc             = nm[0]/2L
smax           = DOUBLE(vlim[0])
delv           = smax[0]/nc[0]
v_st           = -1d0*smax[0]
v1dgrid        = DINDGEN(nm[0])*delv[0] + v_st[0]
x              = v1dgrid
y              = v1dgrid
z              = v1dgrid
;;  Define range and increment
nx             = N_ELEMENTS(x)
xran           = [MIN(x,/NAN),MAX(x,/NAN)]
yran           = [MIN(y,/NAN),MAX(y,/NAN)]
zran           = [MIN(z,/NAN),MAX(z,/NAN)]
dx             = (xran[1] - xran[0])/(nx[0] - 1L)
dy             = (yran[1] - yran[0])/(nx[0] - 1L)
dz             = (zran[1] - zran[0])/(nx[0] - 1L)
;;  Construct Simpson's 1/3 Rule 1D coefficients
sc             = REPLICATE(1d0,nx[0])
sc[1:(nx[0] - 2L):2] *= 4d0              ;;  Start at 2nd element and every other element should be 4
sc[2:(nx[0] - 3L):2] *= 2d0              ;;  Start at 3rd element and every other element should be 2
sc[(nx[0] - 1L)]      = 1d0              ;;  Make sure last element is 1
;;  Construct Simpson's 1/3 Rule 2D coefficients
scx            = sc # REPLICATE(1d0,nx[0])
scy            = REPLICATE(1d0,nx[0]) # sc
;;  Convert to 3D
scx3d          = REBIN(scx,nx[0],nx[0],nx[0])
scy3d          = TRANSPOSE(scx3d,[2,0,1])      ;;  equivalent to   scy3d = REBIN(scy,nx[0],nx[0],nx[0])
scz3d          = TRANSPOSE(scy3d,[0,2,1])
scxyz          = scx3d*scy3d*scz3d
;;  Define h-factors for 3D Simpson's 1/3 Rule
hfac           = dx[0]*dy[0]*dz[0]/(3d0*3d0*3d0)
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Define jittered velocities (avoids colinear problems)
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
nne            = in_el[0].NENERGY[0]
nna            = in_el[0].NBINS[0]
kk             = nne[0]*nna[0]
jitter         = REPLICATE(d,kk[0],3L)
FOR j=0L, 2L DO jitter[*,j] = 2d0*(RANDOMU(seed,kk[0],/DOUBLE) - 5d-1)*toler[0]
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Define parameters used later
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
cal_el_        = in_el
net_wv_        = net_str
ncel           = N_ELEMENTS(cal_el_)
empir_eff      = REPLICATE(d,ncel[0],N_ELEMENTS(def_anode_eff))
thrsh          = thresh[0]
nupd           = LONG(5d-2*ncel[0]) > 3L            ;;  Number of VDFs to go through before informing user of time elapsed
;;  Begin Loop
FOR j=0L, ncel[0] - 1L DO BEGIN
  ;;--------------------------------------------------------------------------------------
  ;;  Reset variables
  ;;--------------------------------------------------------------------------------------
  rt_struc       = 0
  fxyz_3d        = 0
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
  ;;  Get 3D VDF
  ;;--------------------------------------------------------------------------------------
  mag_dir        = REFORM(dat0c[0].MAGF)
  vels           = datcfvxyz.VELXYZ + jitter
  data           = datcfvxyz.VDF
  ;;--------------------------------------------------------------------------------------
  ;;  Remove non-finite values
  ;;--------------------------------------------------------------------------------------
  test_vdf       = FINITE(data)
  test           = FINITE(vels[*,0]) AND FINITE(vels[*,1]) AND $
                   FINITE(vels[*,2]) AND test_vdf
  good_in        = WHERE(test,gd_in,COMPLEMENT=bad_in,NCOMPLEMENT=bd_in)
  IF (gd_in[0] GT 0) THEN BEGIN
    ;;------------------------------------------------------------------------------------
    ;;------------------------------------------------------------------------------------
    ;;  Define proper input
    ;;------------------------------------------------------------------------------------
    ;;------------------------------------------------------------------------------------
    v_in           = TRANSPOSE(vels[good_in,*])
    f_in           = REFORM(data[good_in])
    fin_max        = MAX(ABS(data),/NAN)
    fin_min        = MIN(ABS(data),/NAN)
    ;;------------------------------------------------------------------------------------
    ;;  Find convex hull and associated tetrahedron indices using Delaunay triangulation
    ;;------------------------------------------------------------------------------------
    QHULL,v_in,tetra,/DELAUNAY
    ;;------------------------------------------------------------------------------------
    ;;  Generate 3D f(vx,vy,vz)
    ;;------------------------------------------------------------------------------------
    fxyz_3d        = QGRID3(v_in,f_in,tetra,DELTA=delv[0],DIMENSION=nm[0],MISSING=d,START=v_st[0])
    ;;------------------------------------------------------------------------------------
    ;;  Remove data that is larger or smaller than input limits
    ;;------------------------------------------------------------------------------------
    bad_fxyz       = WHERE(fxyz_3d GT fin_max[0] OR fxyz_3d LT fin_min[0],bd_fxyz)
    IF (bd_fxyz[0] GT 0) THEN fxyz_3d[bad_fxyz] = d
  ENDIF ELSE BEGIN
    ;;------------------------------------------------------------------------------------
    ;;------------------------------------------------------------------------------------
    ;;  No finite velocities or data --> inform user and continue
    ;;------------------------------------------------------------------------------------
    ;;------------------------------------------------------------------------------------
    PRINT,'No finite data for j = ',j[0]
    CONTINUE
  ENDELSE
  ;;--------------------------------------------------------------------------------------
  ;;--------------------------------------------------------------------------------------
  ;;--------------------------------------------------------------------------------------
  ;;  Calculate initial number density [# cm^(-3)]
  ;;--------------------------------------------------------------------------------------
  ;;--------------------------------------------------------------------------------------
  ;;--------------------------------------------------------------------------------------
  ff             = fxyz_3d
  n_s_tot        = TOTAL(hfac[0]*TOTAL(TOTAL(scxyz*ff,3,/NAN),2,/NAN),/NAN)
  ;;--------------------------------------------------------------------------------------
  ;;  Calculate percent difference between integrated Ne and that from upper hybrid line
  ;;--------------------------------------------------------------------------------------
  diff_perc      = ABS(n_s_tot[0] - netwv[0])/netwv[0]*1d2
  IF (diff_perc[0] LE thrsh[0]) THEN BEGIN
    ;;------------------------------------------------------------------------------------
    ;;------------------------------------------------------------------------------------
    ;;------------------------------------------------------------------------------------
    ;;  Good enough --> Define empirical GF correction and move on
    ;;------------------------------------------------------------------------------------
    ;;------------------------------------------------------------------------------------
    ;;------------------------------------------------------------------------------------
    empir_eff[j,*] = relgeom_el/4d0
    CONTINUE
  ENDIF ELSE BEGIN
    ;;------------------------------------------------------------------------------------
    ;;------------------------------------------------------------------------------------
    ;;------------------------------------------------------------------------------------
    ;;  Not good enough yet --> Adjust accordingly
    ;;------------------------------------------------------------------------------------
    ;;------------------------------------------------------------------------------------
    ;;------------------------------------------------------------------------------------
    ;;  Check whether to increase or decrease current GF estimate
    ;;    (Ne,int > Ne,fuh) --> increase ELSE decrease
    ;;    The reason being that this correction term is in the denominator of the
    ;;    unit conversion from counts to phase space density.  Thus, increasing the
    ;;    GF estimate will decrease the resultant Ne,int.
    yes_inc        = n_s_tot[0] GT netwv[0]
    fact           = ([9d-1,11d-1])[yes_inc[0]]
    true           = 0b
    ;;************************************************************************************
    ;;************************************************************************************
    ;;************************************************************************************
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
      vels           = datcfvxyz.VELXYZ + jitter
      data           = datcfvxyz.VDF
      ;;----------------------------------------------------------------------------------
      ;;  Remove non-finite values
      ;;----------------------------------------------------------------------------------
      test_vdf       = FINITE(data)
      test           = FINITE(vels[*,0]) AND FINITE(vels[*,1]) AND $
                       FINITE(vels[*,2]) AND test_vdf
      good_in        = WHERE(test,gd_in,COMPLEMENT=bad_in,NCOMPLEMENT=bd_in)
      IF (gd_in[0] GT 0) THEN BEGIN
        ;;--------------------------------------------------------------------------------
        ;;  Define proper input
        ;;--------------------------------------------------------------------------------
        v_in           = TRANSPOSE(vels[good_in,*])
        f_in           = REFORM(data[good_in])
        fin_max        = MAX(ABS(data),/NAN)
        fin_min        = MIN(ABS(data),/NAN)
        ;;--------------------------------------------------------------------------------
        ;;  Find convex hull and associated tetrahedron indices using Delaunay triangulation
        ;;--------------------------------------------------------------------------------
        QHULL,v_in,tetra,/DELAUNAY
        ;;--------------------------------------------------------------------------------
        ;;  Generate 3D f(vx,vy,vz)
        ;;--------------------------------------------------------------------------------
        fxyz_3d        = QGRID3(v_in,f_in,tetra,DELTA=delv[0],DIMENSION=nm[0],MISSING=d,START=v_st[0])
        ;;--------------------------------------------------------------------------------
        ;;  Remove data that is larger or smaller than input limits
        ;;--------------------------------------------------------------------------------
        bad_fxyz       = WHERE(fxyz_3d GT fin_max[0] OR fxyz_3d LT fin_min[0],bd_fxyz)
        IF (bd_fxyz[0] GT 0) THEN fxyz_3d[bad_fxyz] = d
      ENDIF ELSE BEGIN
        ;;--------------------------------------------------------------------------------
        ;;  No finite velocities or data --> inform user and continue
        ;;--------------------------------------------------------------------------------
        PRINT,'No finite data for j = ',j[0]
        CONTINUE
      ENDELSE
;      rt_struc       = get_rotated_and_triangulated_vdf(vels,data,VLIM=smax[0],NGRID=nm[0],  $
;                                                        SLICE2D=slice_on[0],VFRAME=vframe,   $
;                                                        VEC1=vec1,VEC2=vec2,F3D_QH=fxyz_3d)
;      ;;----------------------------------------------------------------------------------
;      ;;  Verify output
;      ;;----------------------------------------------------------------------------------
;      IF (SIZE(rt_struc,/TYPE) NE 8) THEN BREAK
      ;;----------------------------------------------------------------------------------
      ;;  Calculate number density
      ;;----------------------------------------------------------------------------------
      ff             = fxyz_3d
      n_s_tot        = TOTAL(hfac[0]*TOTAL(TOTAL(scxyz*ff,3,/NAN),2,/NAN),/NAN)
      ;;----------------------------------------------------------------------------------
      ;; Calculate percent difference between Ne,int and Ne,fuh
      ;;----------------------------------------------------------------------------------
      diff_perc      = ABS(n_s_tot[0] - netwv[0])/netwv[0]*1d2
      IF (diff_perc[0] LE thrsh[0]) THEN BEGIN
        ;;--------------------------------------------------------------------------------
        ;;  Good enough --> Define empirical GF correction and move on
        ;;--------------------------------------------------------------------------------
        empir_eff[j,*] = relgeom_el/4d0
        true = 1b
      ENDIF ELSE BEGIN
        ;;--------------------------------------------------------------------------------
        ;;  Not good enough yet --> Adjust accordingly
        ;;--------------------------------------------------------------------------------
        yes_inc        = n_s_tot[0] GT netwv[0]
        fact           = ([9d-1,11d-1])[yes_inc[0]]
      ENDELSE
    ENDREP UNTIL true[0]
    ;;************************************************************************************
    ;;************************************************************************************
    ;;************************************************************************************
  ENDELSE
  ;;--------------------------------------------------------------------------------------
  ;;--------------------------------------------------------------------------------------
  ;;--------------------------------------------------------------------------------------
  ;;  Update user on status
  ;;--------------------------------------------------------------------------------------
  ;;--------------------------------------------------------------------------------------
  ;;--------------------------------------------------------------------------------------
  IF ((j[0] MOD nupd[0]) EQ 0) THEN PRINT,'j = ',j[0],',  '+STRING(SYSTIME(1) - ex_start[0])+' elapsed seconds...'
ENDFOR
;;----------------------------------------------------------------------------------------
;;  Print total running time
;;----------------------------------------------------------------------------------------
ex_time        = SYSTIME(1) - ex_start[0]
MESSAGE,STRING(ex_time[0])+' seconds execution time.',/CONTINUE,/INFORMATIONAL
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------

RETURN,empir_eff
END


































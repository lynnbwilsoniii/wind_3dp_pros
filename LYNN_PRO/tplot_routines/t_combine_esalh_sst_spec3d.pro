;*****************************************************************************************
;
;  FUNCTION :   sub_combine_elhs_vframe_trans.pro
;  PURPOSE  :   This is a subroutine used to transform an input array of VDFs to a new
;                 reference frame, if so desired by the user.
;
;  CALLED BY:   
;               t_combine_esalh_sst_spec3d.pro
;
;  INCLUDES:
;               NA
;
;  CALLS:
;               conv_units.pro
;               struct_value.pro
;               is_a_3_vector.pro
;               transform_vframe_3d_array.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               DAT         :  [N]-Element [structure] array of VDFs from one of the
;                                ESAs or SSTs on Wind or THEMIS
;
;  EXAMPLES:    
;               [calling sequence]
;               struc = sub_combine_elhs_vframe_trans(dat [,FRCCNTS=frac_cnts] $
;                                   [,RM_PHOTO_E=rmscpot] [,SC_FRAME=scframe]  $
;                                   [,UNITS=gunits] [,TTLE_EXT=ttle_ext]       $
;                                   [,VFRAME=vframe] [,RMSC_SUFFX=rmsc_suffx])
;
;  KEYWORDS:    
;               **********************************
;               ***       DIRECT  INPUTS       ***
;               **********************************
;               FRCCNTS     :  If set, routine will allow for fractional counts in the
;                                unit conversion routine
;                                [Default = (set by calling routine)]
;               RM_PHOTO_E  :  If set, routine will remove data below the spacecraft
;                                potential defined by the structure tag SC_POT and
;                                shift the corresponding energy bins by
;                                CHARGE*SC_POT
;                                [Default = (set by calling routine)]
;               SC_FRAME    :  If set, routine will fit the data in the spacecraft frame
;                                of reference rather than the eVDF's bulk flow frame
;                                [Default  :  (set by calling routine)]
;               UNITS       :  Scalar [string] defining the units to use for the
;                                vertical axis of the plot and the outputs YDAT and DYDAT
;                                [Default = (set by calling routine)]
;
;               **********************************
;               ***     ALTERED ON OUTPUT      ***
;               **********************************
;               TTLE_EXT    :  Set to a named variable to return a scalar [string] that
;                                informs the user of the reference frame of the output
;                                data structures
;                                  'SCF'  :  spacecraft frame
;                                  'SWF'  :  bulk flow rest frame
;               VFRAME      :  Set to a named variable to return an [N,3]-element array
;                                of 3-vector velocities used to transform DAT into a
;                                new reference frame
;               RMSC_SUFFX  :  Set to a named variable to return a scalar [string] that
;                                informs the user of whether the output structure
;                                accounted for the spacecraft potential or not
;                                  'RM-SCPot'  :  Removed photoelectrons
;                                  'KP-SCPot'  :  Kept photoelectrons
;
;   CHANGED:  1)  Continued to write routine
;                                                                   [10/04/2022   v1.0.0]
;             2)  Finished writing subroutine
;                                                                   [10/04/2022   v1.0.0]
;             3)  Fixed an issue with input of plot LIMITS structures
;                                                                   [10/07/2022   v1.0.1]
;
;   NOTES:      
;               0)  This routine should not be called directly by a user as it has no
;                     error handling
;
;  REFERENCES:  
;               NA
;
;   CREATED:  10/03/2022
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  10/07/2022   v1.0.1
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************

FUNCTION sub_combine_elhs_vframe_trans,dat,FRCCNTS=frac_cnts,RM_PHOTO_E=rmscpot,$
                                       SC_FRAME=scframe,UNITS=gunits,           $
                                       TTLE_EXT=ttle_ext,VFRAME=vframe,         $  ;;  Outputs
                                       RMSC_SUFFX=rmsc_suffx

;;----------------------------------------------------------------------------------------
;;  Transform (if desired) into bulk flow rest frame
;;----------------------------------------------------------------------------------------
IF ~ARG_PRESENT(rmscpot) THEN rmscpot = 0b         ;;  Give it a value if calling routine did not
;;  Convert to phase space density [] --> bc it's a Lorentz invariant (well f(v) d^3x d^3v is)
dat0           = dat
nvdf0          = N_ELEMENTS(dat0)
tdatl_sw       = conv_units(dat0,'df',FRACTIONAL_COUNTS=frac_cnts)
 IF (scframe[0]) THEN BEGIN
  ;;--------------------------------------------------------------------------------------
  ;;  Leave alone --> No frame transformation
  ;;--------------------------------------------------------------------------------------
  ttle_ext       = 'SCF'      ;;  string to add to plot title indicating reference frame shown
  datl           = tdatl_sw
ENDIF ELSE BEGIN
  ;;--------------------------------------------------------------------------------------
  ;;  Transform into bulk flow frame
  ;;--------------------------------------------------------------------------------------
  ttle_ext       = 'SWF'
  temp_vsw       = struct_value(dat0,'VSW',DEFAULT=[0d0,0d0,0d0])
  temp_vel       = struct_value(dat0,'VELOCITY',DEFAULT=[0d0,0d0,0d0])
  test_vsw       = (N_ELEMENTS(temp_vsw) NE 3L*nvdf0[0]) AND (N_ELEMENTS(temp_vel) NE 3L*nvdf0[0])
  IF (test_vsw[0]) THEN BEGIN
    ;;  No bulk flow structure tag present --> compute in SCF
    ttle_ext       = 'SCF'
    datl           = tdatl_sw
  ENDIF ELSE BEGIN
    ;;  At least one of them is okay --> Test
    IF (N_ELEMENTS(temp_vsw) NE 3L*nvdf0[0]) THEN BEGIN
      ;;  'VELOCITY' structure tag is present
      test           = is_a_3_vector(temp_vel,V_OUT=vframe,/NOMSSG)
    ENDIF ELSE BEGIN
      ;;  'VSW' structure tag is present
      test           = is_a_3_vector(temp_vsw,V_OUT=vframe,/NOMSSG)
    ENDELSE
    ;;  Check results
    IF (~test[0]) THEN BEGIN
      ;;  Input had the correct # of elements but wasn't a 3-vector --> compute in SCF
      ttle_ext       = 'SCF'
      datl           = tdatl_sw
    ENDIF ELSE BEGIN
      ;;  Lorentz transform to bulk flow reference frame
      ttle_ext       = 'SWF'
      datl           = transform_vframe_3d_array(tdatl_sw,vframe)
      ;;  Shut off RM_PHOTO_E keyword in case set (Trans. routine already removes this)
      IF (rmscpot[0]) THEN rmscpot = 0b
    ENDELSE
  ENDELSE
ENDELSE
;;----------------------------------------------------------------------------------------
;;  Define file and title suffix associated with removal of photoelectrons
;;----------------------------------------------------------------------------------------
IF (rmscpot[0] OR scframe[0] EQ 0) THEN BEGIN
  rmsc_suffx  = 'RM-SCPot'       ;;  Removed photo electrons
ENDIF ELSE BEGIN
  rmsc_suffx  = 'KP-SCPot'       ;;  Kept photo electrons
ENDELSE
;;----------------------------------------------------------------------------------------
;;  Convert into desired output units
;;----------------------------------------------------------------------------------------
struc          = conv_units(datl,gunits[0],FRACTIONAL_COUNTS=frac_cnts)
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------

RETURN,struc
END


;*****************************************************************************************
;
;  FUNCTION :   sub_combine_elhs_calc_pads.pro
;  PURPOSE  :   This is a subroutine used to compute the pitch-angle distributions (PADs)
;                 of an input array of VDFs
;
;  CALLED BY:   
;               t_combine_esalh_sst_spec3d.pro
;
;  INCLUDES:
;               NA
;
;  CALLS:
;               define_particle_charge.pro
;               xyz_to_polar.pro
;               pangle.pro
;               struct_value.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               DAT         :  [N]-Element [structure] array of VDFs from one of the
;                                ESAs or SSTs on Wind or THEMIS
;
;  EXAMPLES:    
;               [calling sequence]
;               struc = sub_combine_elhs_calc_pads(dat [,PA_SETT=pa_sett] [,VECTOR=vecdir] $
;                                                      [,RM_PHOTO_E=rmscpot] [,GOOD_BINS=lbins])
;
;  KEYWORDS:    
;               PA_SETT     :  [3]-Element [numeric] logic array informing routine of the
;                                settings for the P_ANGLE, SUNDIR, and VECTOR keywords in
;                                calling routine
;               VECTOR      :  [3]-Element [float/double] array defining the vector
;                                direction about which to define the angular distributions
;                                for plotting
;                                [Default  :  (set by calling routine)]
;               RM_PHOTO_E  :  If set, routine will remove data below the spacecraft
;                                potential defined by the structure tag SC_POT and
;                                shift the corresponding energy bins by
;                                CHARGE*SC_POT
;                                [Default = (set by calling routine)]
;               GOOD_BINS   :  [N]-Element [byte] array defining which low energy ESA
;                                solid angle bins should be used [i.e., BINS[good] = 1b]
;                                and which bins should not be [i.e., BINS[bad] = 0b].
;                                [Default = (set by calling routine)]
;
;   CHANGED:  1)  Continued to write routine
;                                                                   [10/04/2022   v1.0.0]
;             2)  Finished writing subroutine
;                                                                   [10/04/2022   v1.0.0]
;             3)  Fixed an issue with input of plot LIMITS structures
;                                                                   [10/07/2022   v1.0.1]
;
;   NOTES:      
;               0)  This routine should not be called directly by a user as it has no
;                     error handling
;
;  REFERENCES:  
;               NA
;
;   CREATED:  10/03/2022
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  10/07/2022   v1.0.1
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************

FUNCTION sub_combine_elhs_calc_pads,dat,PA_SETT=pa_sett,VECTOR=vecdir,RM_PHOTO_E=rmscpot,$
                                        GOOD_BINS=lbins

;;----------------------------------------------------------------------------------------
;;  Define some constants and dummy variables
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Define relevant parameters
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
IF ~ARG_PRESENT(rmscpot) THEN rmscpot = 0b         ;;  Give it a value if calling routine did not
dat0           = dat
nvdf0          = N_ELEMENTS(dat0)
n_en0          = dat0[0].NENERGY[0]
n_sa0          = dat0[0].NBINS[0]
nn_all         = [nvdf0[0],n_en0[0],n_sa0[0]]
;;  Define sign of charge and check for energy shift
charge         = define_particle_charge(dat0[0],E_SHIFT=e_shift)
;;  Define midpoint Unix times
unix_l         = (dat0.TIME + dat0.END_TIME)/2d0
;;  Define dummy arrays
ener_l         = REPLICATE(d,nvdf0[0],n_en0[0],n_sa0[0])
ydat_l         = ener_l
pang_l         = REPLICATE(d,nvdf0[0],n_sa0[0])
;;  Define pitch-angle setting variables
pang           = pa_sett[0]
sun_d          = pa_sett[1]
vecon          = pa_sett[2]
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Compute PADs
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
FOR j=0L, nn_all[0] - 1L DO BEGIN
  ;;--------------------------------------------------------------------------------------
  ;;  Reset variables
  ;;--------------------------------------------------------------------------------------
  pang0          = pang[0]
  gbins          = lbins
  struc          = dat0[j]
  ;;--------------------------------------------------------------------------------------
  ;;  Calculate pitch-angles with respect to relevant vector
  ;;--------------------------------------------------------------------------------------
  ener0          = struc[0].ENERGY
  data0          = struc[0].DATA
  phi0           = MEAN(struc[0].PHI,/NAN,DIMENSION=1)
  the0           = MEAN(struc[0].THETA,/NAN,DIMENSION=1)
  CASE 1 OF
    pang[0]   :  BEGIN
      ;;  Use Bo
      rvec           = struc[0].MAGF
    END
    sun_d[0]  :  BEGIN
      ;;  Use Sun direction
      rvec           = [-1d0,0d0,0d0]
    END
    vecon[0]  :  BEGIN
      ;;  Use user-defined vector
      rvec           = vecdir
    END
    ELSE      :  BEGIN
      ;;  Shouldn't happen --> debug
      STOP
    END
  ENDCASE
  ;;  Convert relevant vector to spherical coordinate angles
  xyz_to_polar,rvec,THETA=vth0,PHI=vph0
  ;;  Compute pitch-angles
  pang0          = pangle(the0,phi0,vth0,vph0)
  ;;--------------------------------------------------------------------------------------
  ;;  Remove spacecraft potential, if desired
  ;;--------------------------------------------------------------------------------------
  IF (rmscpot[0]) THEN BEGIN
    ;;  User wants to remove spacecraft potential
    scpot          = struct_value(struc,'SC_POT',DEFAULT=0d0)
    ;;  Get particle charge and energy shift
    oldener        = ener0
    tempenr        = (oldener + e_shift[0]) + (scpot[0]*charge[0])
    bad            = WHERE(tempenr LE 0e0 OR oldener LE 1d0*scpot[0],bd)
    IF (bd[0] GT 0) THEN BEGIN
      ener0[bad]     = f
      data0[bad]     = f
    ENDIF
  ENDIF
  ;;--------------------------------------------------------------------------------------
  ;;  Need to sort pitch-angles
  ;;--------------------------------------------------------------------------------------
  sp             = SORT(pang0)
  ener_0         = ener0[*,sp]
  data_0         = data0[*,sp]
  pang_0         = pang0[sp]
  ;;--------------------------------------------------------------------------------------
  ;;  Define outputs
  ;;--------------------------------------------------------------------------------------
  ener_l[j,*,*]  = ener_0
  ydat_l[j,*,*]  = data_0
  pang_l[j,*]    = pang_0
ENDFOR
;;----------------------------------------------------------------------------------------
;;  Define output structure
;;----------------------------------------------------------------------------------------
ostru          = {X:unix_l,Y:ydat_l,V1:ener_l,V2:pang_l}
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------

RETURN,ostru
END


;*****************************************************************************************
;
;  FUNCTION :   sub_combine_elhs_avg_pads.pro
;  PURPOSE  :   This is a subroutine used to average over the pitch-angle distributions
;                 (PADs) computed in sub_combine_elhs_calc_pads.pro, where the averaging
;                 is done over user-defined pitch-angle bins.
;
;  CALLED BY:   
;               t_combine_esalh_sst_spec3d.pro
;
;  INCLUDES:
;               NA
;
;  CALLS:
;               t_get_struc_unix.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               DATA        :  Scalar [TPLOT structure] of PADs from the data in UNITS
;               POIS        :  Scalar [TPLOT structure] of Poisson statistics of PADs
;               PARA        :  [K,2]-Element [numeric] array defining the {start,end}
;                                values of the user-defined pitch-angle bins
;
;  EXAMPLES:    
;               [calling sequence]
;               padav = sub_combine_elhs_avg_pads(data,pois,para)
;
;  KEYWORDS:    
;               NA
;
;   CHANGED:  1)  Fixed an issue with input of plot LIMITS structures
;                                                                   [10/07/2022   v1.0.1]
;
;   NOTES:      
;               0)  This routine should not be called directly by a user as it has no
;                     error handling
;
;  REFERENCES:  
;               NA
;
;   CREATED:  10/04/2022
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  10/07/2022   v1.0.1
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************

FUNCTION sub_combine_elhs_avg_pads,data,pois,para

;;----------------------------------------------------------------------------------------
;;  Define some constants and dummy variables
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Define relevant parameters
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
cut_low        = REFORM(para[*,0L])
cut_upp        = REFORM(para[*,1L])
n_pa           = N_ELEMENTS(cut_low)                                 ;;  # of pitch-angle averages
unix_l         = t_get_struc_unix(data,TSHFT_ON=tshft_on)            ;;  [N]-Element array of Unix times
nvdf0          = N_ELEMENTS(unix_l)                                  ;;  # of VDFs
n_en0          = N_ELEMENTS(data.Y[0,*,0])                           ;;  # of energies
nn_all         = [nvdf0[0],n_en0[0],n_pa[0]]
;;  Define dummary variables
struc          = data[0]
strup          = pois[0]
dumb_l         = REPLICATE(d,n_en0[0],n_pa[0])
yavg_l         = REPLICATE(d,nvdf0[0],n_en0[0],n_pa[0])
;;  First average energies for each VDF, as they should not change by solid-angle
ener_l         = MEAN(struc.V1,/NAN,DIMENSION=3)                     ;;  [N,E]-element array
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Average over pitch-angles
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
FOR j=0L, nn_all[0] - 1L DO BEGIN
  pang_0         = REFORM(struc.V2[j,*])
  data_0         = REFORM(struc.Y[j,*,*])                      ;;  [E,A]-element array
  pois_0         = REFORM(strup.Y[j,*,*])                      ;;  [E,A]-element array
  ;;  First check the signal-to-noise ratio (SNR)
  ratio          = ABS(data_0/pois_0)
  bad            = WHERE(ratio LE 1d0 OR FINITE(ratio) EQ 0,bd)
  IF (bd[0] GT 0) THEN data_0[bad] = d
  temp           = dumb_l
  FOR k=0L, n_pa[0] - 1L DO BEGIN
    ;;  Find observed PAs within user-defined ranges
    good           = WHERE(pang_0 GE cut_low[k] AND pang_0 LE cut_upp[k],gd)
    IF (gd[0] GT 1) THEN BEGIN
      ;;  PAs were found
      dumb           = MEAN(REFORM(data_0[*,good]),/NAN,DIMENSION=2)
      IF (N_ELEMENTS(dumb) EQ nn_all[1]) THEN temp[*,k] = dumb
    ENDIF ELSE BEGIN
      ;;  Check if just one element was found
      IF (gd[0] EQ 1) THEN temp[*,k] = data_0[*,good[0]]
    ENDELSE
  ENDFOR
  ;;  Fill array
  yavg_l[j,*,*]  = temp
ENDFOR
;;----------------------------------------------------------------------------------------
;;  Define return structure
;;----------------------------------------------------------------------------------------
pang_av        = MEAN(para,/NAN,DIMENSION=2)
pang_l0        = REPLICATE(1d0,nvdf0[0]) # pang_av
out_str        = {X:unix_l,Y:yavg_l,V1:ener_l,V2:pang_l0}
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------

RETURN,out_str
END


;*****************************************************************************************
;
;  FUNCTION :   sub_combine_elhs_get_tplot_parm.pro
;  PURPOSE  :   This is a subroutine used to generate relevant TPLOT metadata
;
;  CALLED BY:   
;               t_combine_esalh_sst_spec3d.pro
;
;  INCLUDES:
;               NA
;
;  CALLS:
;               t_get_struc_unix.pro
;               is_a_number.pro
;               calc_1var_stats.pro
;               test_plot_axis_range.pro
;               num2flt_str.pro
;               extract_tags.pro
;               str_element.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               DATA        :  Scalar [TPLOT structure] of PADs from the data in UNITS
;               PARA        :  [K,2]-Element [numeric] array defining the {start,end}
;                                values of the user-defined pitch-angle bins
;
;  EXAMPLES:    
;               [calling sequence]
;               tpn_stuff = sub_combine_elhs_get_tplot_pard(data,para [,SPEC=spec]        $
;                                     [,UNITN=gunits] [,UNITT=punits] [,PARTICLE=species] $
;                                     [,TTLE_PRE=yttl_pref] [,INST_PRE=inst_pref]         $
;                                     [,MID_TOUT=mid_out] [,SCPREF=scpref]                $
;                                     [,FSUFFX=fsuffx] [,TTLE_EXT=ttle_ext]               $
;                                     [,DATA_MIN=data_min] [,DATA_MAX=data_max]           $
;                                     [,LIM_DATA=lim_data])
;
;  KEYWORDS:    
;               SPEC        :  If set, routine will tell TPLOT to use a spectrogram
;                                instead of a stacked line plot
;                                [Default = FALSE]
;               UNITN       :  Scalar [string] defining the units to use for the
;                                TPLOT handle
;                                [Default = (set by calling routine)]
;               UNITT       :  Scalar [string] defining the units to use for the
;                                plot title
;                                [Default = (set by calling routine)]
;               PARTICLE    :  Scalar [string] defining the particle species
;                                [Default = (set by calling routine)]
;               TTLE_PRE    :  Scalar [string] defining the plot title prefix
;                                [Default = (set by calling routine)]
;               INST_PRE    :  Scalar [string] defining the instrument prefix to use for
;                                the TPLOT handle
;                                [Default = (set by calling routine)]
;               MID_TOUT    :  Scalar [string] defining the middle part of the TPLOT handle
;                                [Default = (set by calling routine)]
;               SCPREF      :  Scalar [string] defining the spacecraft-dependent TPLOT
;                                handle prefix
;                                [Default = (set by calling routine)]
;               FSUFFX      :  Scalar [string] defining the PAD-dependent TPLOT
;                                handle suffix
;                                [Default = (set by calling routine)]
;               TTLE_EXT    :  Scalar [string] defining the reference frame of the data
;                                [Default = (set by calling routine)]
;               DATA_MIN    :  Scalar [numeric] defining the maximum allowed value of the
;                                low energy ESA data in UNITS to consider when computing
;                                plot ranges for TPLOT
;                                [Default = (smaller of 95% of 5th percentile and 1% of MEDIAN)]
;               DATA_MAX    :  Scalar [numeric] defining the maximum allowed value of the
;                                low energy ESA data in UNITS to consider when computing
;                                plot ranges for TPLOT
;                                [Default = (larger of 170% of 95th percentile and 1% of MAX)]
;               LIM_DATA    :  Scalar [structure] defining the plot limits structure
;                                [Default = (set by calling routine)]
;
;   CHANGED:  1)  Finished writing solid draft of routine
;                                                                   [10/04/2022   v1.0.0]
;             2)  Fixed an issue with input of plot LIMITS structures
;                                                                   [10/07/2022   v1.0.1]
;
;   NOTES:      
;               0)  This routine should not be called directly by a user as it has no
;                     error handling
;               1)  Still working on how to handle user-defined energy range for stacked
;                     line plots
;
;  REFERENCES:  
;               NA
;
;   CREATED:  10/04/2022
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  10/07/2022   v1.0.1
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************

FUNCTION sub_combine_elhs_get_tplot_pard,data,para,SPEC=spec,UNITN=gunits,UNITT=punits,$
                                         PARTICLE=species,TTLE_PRE=yttl_pref,          $
                                         INST_PRE=inst_pref,MID_TOUT=mid_out,          $
                                         SCPREF=scpref,FSUFFX=fsuffx,TTLE_EXT=ttle_ext,$
                                         DATA_MIN=data_min,DATA_MAX=data_max,          $
                                         LIM_DATA=lim_data

;;----------------------------------------------------------------------------------------
;;  Define some constants and dummy variables
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Define relevant parameters
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
cut_low        = REFORM(para[*,0L])
cut_upp        = REFORM(para[*,1L])
yavg_all       = data.Y
n_pa           = N_ELEMENTS(cut_low)                                 ;;  # of pitch-angle averages
unix_l         = t_get_struc_unix(data,TSHFT_ON=tshft_on)            ;;  [N]-Element array of Unix times
nvdf0          = N_ELEMENTS(unix_l)                                  ;;  # of VDFs
n_en0          = N_ELEMENTS(yavg_all[0,*,0])                         ;;  # of energies
dtags          = STRLOWCASE(TAG_NAMES(data))
IF (TOTAL(dtags EQ 'v') EQ 1) THEN BEGIN
  sznd           = SIZE(data.V,/N_DIMENSIONS)
  IF (sznd[0] EQ 2) THEN new_ener = MEAN(data.V,/NAN,DIMENSION=1) ELSE new_ener = REFORM(data.V)
ENDIF ELSE BEGIN
  IF (TOTAL(dtags EQ 'v1') EQ 1) THEN BEGIN
    sznd           = SIZE(data.V1,/N_DIMENSIONS)
    IF (sznd[0] EQ 2) THEN new_ener = MEAN(data.V1,/NAN,DIMENSION=1) ELSE new_ener = REFORM(data.V1)
  ENDIF ELSE BEGIN
    ;;  Something is wrong --> debug
    STOP
  ENDELSE
ENDELSE
out_ener       = 1d-3*new_ener
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Check keywords
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Check DATA_MIN and DATA_MAX
conlim         = 90d-2
tests          = [(is_a_number(data_min,/NOMSSG) EQ 0),(is_a_number(data_max,/NOMSSG) EQ 0)]
IF (tests[0] OR tests[1]) THEN onvs = calc_1var_stats(yavg_all,/NAN,CONLIM=conlim[0],PERCENTILES=perc,/POSITIVE)
IF (tests[0] AND tests[1]) THEN BEGIN
  ;;  Calculate one-variable stats on all data to determine plot range
  ymin_all       = (95d-2*perc[0]) < ( 1d-2*onvs[3])
  ymax_all       = (17d-1*perc[1]) > ( 1d-2*onvs[1])
ENDIF ELSE BEGIN
  ;;  At least one of them is set
  IF (~tests[0] AND ~tests[1]) THEN BEGIN
    ;;  Both are set
    ymin_all       = ABS(data_min[0])
    ymax_all       = ABS(data_max[0])
  ENDIF ELSE BEGIN
    ;;  Only one is set
    IF (~tests[0]) THEN BEGIN
      ;;  DATA_MIN = TRUE
      ymin_all       = ABS(data_min[0])
      ymax_all       = (17d-1*perc[1]) > ( 1d-2*onvs[1])
    ENDIF ELSE BEGIN
      ;;  DATA_MAX = TRUE
      ymin_all       = (95d-2*perc[0]) < ( 1d-2*onvs[3])
      ymax_all       = ABS(data_max[0])
    ENDELSE
  ENDELSE
ENDELSE
;;  Make sure the range isn't rubbish
t_dran         = [ymin_all[0],ymax_all[0]]
IF (test_plot_axis_range(t_dran,/NOMSSG) EQ 0L) THEN BEGIN
  ;;  It is rubbish --> Try to fix it
  t_dran         = [(MIN(yavg_all,/NAN) > 1d-30),(MAX(yavg_all,/NAN) < 1d20)]
  IF (test_plot_axis_range(t_dran,/NOMSSG) EQ 0L) THEN BEGIN
    MESSAGE,'No finite data in all PA bins...',/INFORMATIONAL,/CONTINUE
    RETURN,0b
  ENDIF
ENDIF
;;  Check LIM_DATA
IF (SIZE(lim_data,/TYPE) EQ 8L) THEN limit_on = 1b ELSE limit_on = 0b
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Define output values and structures
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Define TPLOT relevant stuff
yttl_omni      = yttl_pref[0]+punits[0]+'!C'+'['+species[0]+', '+ttle_ext[0]+']'
pad_tpn        = num2flt_str(para[*,0],NUM_CHAR=8,NUM_DEC=0)+'--'+num2flt_str(para[*,1],NUM_CHAR=8,NUM_DEC=0)
pad_ttl        = num2flt_str(para[*,0],NUM_CHAR=8,NUM_DEC=1)+'--'+num2flt_str(para[*,1],NUM_CHAR=8,NUM_DEC=1)
padysub        = '['+pad_ttl+' deg]'
yttl_pads      = yttl_omni[0]+'!C'+padysub
ener_labv      = new_ener
ener_labs      = REPLICATE('',n_en0[0])
xlog__all      = 0b
IF (spec[0]) THEN BEGIN
  ;;  User wants output as spectra, i.e., Y = energy, X = time, Z = UNITS
  zttl_omni      = yttl_omni[0]
  zttl_pads      = REPLICATE(zttl_omni[0],n_pa[0])
  yttl_omni      = 'Energy [keV]'
  yttl_pads      = yttl_omni[0]+'!C'+padysub
  zran__all      = [ymin_all[0],ymax_all[0]]
  yran__all      = [MIN(out_ener,/NAN),MAX(out_ener,/NAN)]*[95d-2,105d-2]
  ylog__all      = 1b
  zlog__all      = 1b
ENDIF ELSE BEGIN
  ;;  User wants output as stacked line plot, i.e., Y = UNITS, X = time, lines = energies
  zttl_omni      = ''
  zttl_pads      = REPLICATE('',n_pa[0])
  yran__all      = [ymin_all[0],ymax_all[0]]
  zran__all      = REPLICATE(d,2L)
  good           = WHERE(out_ener GE 1d0,gd,COMPLEMENT=bad,NCOMPLEMENT=bd)
  IF (gd[0] GT 0) THEN ener_labs[good] = num2flt_str(1d-3*ener_labv[good],NUM_CHAR=8,NUM_DEC=1)+' keV'
  IF (bd[0] GT 0) THEN ener_labs[bad]  = num2flt_str(ener_labv[bad] ,NUM_CHAR=8,NUM_DEC=1)+' eV'
  ylog__all      = 1b
  zlog__all      = 0b
ENDELSE
IF (ylog__all[0]) THEN yminor = 9L ELSE yminor = 10L
IF (zlog__all[0]) THEN zminor = 9L ELSE zminor =  0L
ener_col       = LINDGEN(n_en0[0])*(250L - 30L)/(n_en0[0] - 1L) + 30L
;;----------------------------------------------------------------------------------------
;;  Initialize omnidirectional and PADs TPLOT DLIMITS structures
;;----------------------------------------------------------------------------------------
tdlimo         = {XLOG:xlog__all[0],YLOG:ylog__all[0],ZLOG:zlog__all[0],YTITLE:yttl_omni[0],$
                  ZTITLE:zttl_omni[0],YRANGE:yran__all,ZRANGE:zran__all}
IF (limit_on[0]) THEN BEGIN
  ;;  Get user-defined plot limits info as well
  extract_tags,tdlimo,lim_data,EXCEPT=['XRANGE','YRANGE','ZRANGE','ERANGE','XLOG']
  eran_user      = struct_value(lim_data,'ERANGE',DEFAULT=[d,d])
  IF (test_plot_axis_range(eran_user,/NOMSSG)) THEN BEGIN
    ;;  User apparently wants to limit energy range
    IF (spec[0]) THEN BEGIN
      ;;  Change YRANGE of spectrograms
      str_element,tdlimo,'YRANGE',eran_user*1d-3,/ADD_REPLACE
    ENDIF ELSE BEGIN
      ;;  Change output of data, labels, and colors
      ;;    *** need to implement this in the future ***
    ENDELSE
  ENDIF
ENDIF
IF (spec[0]) THEN BEGIN
  str_element,tdlimo,'ZTICKS',5L,/ADD_REPLACE
ENDIF ELSE BEGIN
  str_element,tdlimo,'LABELS',ener_labs,/ADD_REPLACE
  str_element,tdlimo,'COLORS',ener_col,/ADD_REPLACE
  str_element,tdlimo,'LABFLAG',1,/ADD_REPLACE
ENDELSE
tdlimp0        = tdlimo
;;  Define TPLOT handle for omnidirectional average and pitch-angles
tplot_nmo      = scpref[0]+species[0]+'_'+inst_pref[0]+mid_out[0]+'_'+gunits[0]+fsuffx[0]+'_'+ttle_ext[0]
tplot_pad      = tplot_nmo[0]+'_'+pad_tpn
;;----------------------------------------------------------------------------------------
;;  Define output structure
;;----------------------------------------------------------------------------------------
out_str        = {DLIM_OMNI:tdlimo,TPN_OMNI:tplot_nmo[0],TPN_PADS:tplot_pad,$
                  YTTL_PADS:yttl_pads,ZTTL_PADS:zttl_pads,OUT_ENER:out_ener}
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------

RETURN,out_str
END


;+
;*****************************************************************************************
;
;  PROCEDURE:   t_combine_esalh_sst_spec3d.pro
;  PURPOSE  :   This routine generates a [UNITS] vs time spectra as a stacked line plot
;                 from the distributions measured by three separate instruments.  The data
;                 are regridded in both energy and time to make them uniform.
;
;  CALLED BY:   
;               NA
;
;  INCLUDES:
;               sub_combine_elhs_vframe_trans.pro
;               sub_combine_elhs_calc_pads.pro
;               sub_combine_elhs_avg_pads.pro
;               sub_combine_elhs_get_tplot_pard.pro
;
;  CALLS:
;               test_wind_vs_themis_esa_struct.pro
;               define_particle_charge.pro
;               dat_3dp_str_names.pro
;               dat_themis_esa_str_names.pro
;               extract_tags.pro
;               test_plot_axis_range.pro
;               str_element.pro
;               is_a_number.pro
;               is_a_3_vector.pro
;               wind_3dp_units.pro
;               format_esa_bins_keyword.pro
;               get_valid_trange.pro
;               sub_combine_elhs_vframe_trans.pro
;               sub_combine_elhs_calc_pads.pro
;               sub_combine_elhs_avg_pads.pro
;               sub_combine_elhs_get_tplot_pard.pro
;               store_data.pro
;               t_resample_tplot_struc.pro
;               roundsig.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               DAT_ESAL    :  [N]-Element [structure] array associated with a known low
;                                energy ESA data structure from Wind/3DP
;                                [see get_?.pro, ? = el, elb, pl, or plb]
;               DAT_ESAH    :  [M]-Element [structure] array associated with a known high
;                                energy ESA data structure from Wind/3DP
;                                [see get_?.pro, ? = eh, ehb, ph, or phb]
;               DAT_SST     :  [K]-Element [structure] array associated with a known SST
;                                data structure from Wind/3DP
;                                [see get_?.pro, ? = sf, sfb, so, sob]
;
;  EXAMPLES:    
;               [calling sequence]
;               t_combine_esalh_sst_spec3d,dat_esal,dat_esah,dat__sst [,LIM_ESAL=lim_esal] $
;                              [,LIM_ESAH=lim_esah] [,LIM_SST=lim__sst] [,ESAL_ERAN=leran] $
;                              [,ESAH_ERAN=heran] [,SST_ERAN=seran] [,SC_FRAME=sc_frame]   $
;                              [,CUT_RAN=cut_ran] [,P_ANGLE=p_angle] [,SUNDIR=sundir]      $
;                              [,VECTOR=vec] [,UNITS=units] [,ESAL_BINS=lbins]             $
;                              [,ESAH_BINS=hbins] [,SST_BINS=sbins] [,ONE_C=one_c]         $
;                              [,RM_PHOTO_E=rm_photo_e] [,NUM_PA=num_pa] [,MIDN=midn]      $
;                              [,TRANGE=trange] [,SPEC=spec] [,LDAT_MIN=ldat_min]          $
;                              [,HDAT_MIN=hdat_min] [,SDAT_MIN=sdat_min]                   $
;                              [,LDAT_MAX=ldat_max] [,HDAT_MAX=hdat_max]                   $
;                              [,SDAT_MAX=sdat_max] [,XDAT_ESAL=xdat_esal]                 $
;                              [,YDAT_ESAL=ydat_esal] [,XDAT_ESAH=xdat_esah]               $
;                              [,YDAT_ESAH=ydat_esah] [,XDAT_SST=xdat__sst]                $
;                              [,YDAT_SST=ydat__sst] [,XDAT_ALL=xdat_all]                  $
;                              [,YDAT_ALL=ydat__all] [,ONEC_ALL=onec_all]                  $
;                              [,OUT_STR=out_str]
;
;  KEYWORDS:    
;               **********************************
;               ***       DIRECT  INPUTS       ***
;               **********************************
;               LIM_ESAL    :  Scalar [structure] used for plotting the low energy ESA
;                                distribution that may contain any combination of the
;                                following structure tags or keywords accepted by
;                                PLOT.PRO:
;                                  XLOG,   YLOG,   ZLOG,
;                                  XRANGE, YRANGE, ZRANGE,
;                                  XTITLE, YTITLE,
;                                  TITLE, POSITION, REGION, etc.
;                                  (see IDL documentation for a description)
;                                The structure is passed to lbw_spec3d.pro through the
;                                LIMITS keyword.
;               LIM_ESAH    :  Scalar [structure] used for plotting the high energy ESA
;                                distribution with the same notes as for LIM_ESAL
;               LIM_SST     :  Scalar [structure] used for plotting the SST distribution
;                                that may contain any combination of the following
;                                structure tags or keywords accepted by PLOT.PRO:
;                                  XLOG,   YLOG,   ZLOG,
;                                  XRANGE, YRANGE, ZRANGE,
;                                  XTITLE, YTITLE,
;                                  TITLE, POSITION, REGION, etc.
;                                  (see IDL documentation for a description)
;                                The structure is passed to lbw_spec3d.pro through the
;                                LIMITS keyword.
;               ESAL_ERAN   :  [2]-Element [float/double] array defining the range of
;                                energies [eV] over which the low energy ESA data
;                                will be plotted
;                                [Default  :  [1,1500]]
;               ESAH_ERAN   :  [2]-Element [float/double] array defining the range of
;                                energies [eV] over which the high energy ESA data
;                                will be plotted
;                                [Default  :  [100,30000]]
;               SST_ERAN    :  [2]-Element [float/double] array defining the range of
;                                energies [keV] over which the ESA data will be plotted
;                                [Default  :  [30,500]]
;               SC_FRAME    :  If set, routine will fit the data in the spacecraft frame
;                                of reference rather than the eVDF's bulk flow frame
;                                [Default  :  FALSE]
;               CUT_RAN     :  Scalar [numeric] defining the range of angles [deg] about a
;                                center angle to use when averaging to define the spectra
;                                along a given direction
;                                [Default  :  22.5]
;               P_ANGLE     :  If set, routine will use the MAGF tag within DAT_ESA and
;                                DAT_SST to define the angular distributions for plotting
;                                (i.e., here it would be a pitch-angle distribution)
;                                [Default  :  TRUE]
;               SUNDIR      :  If set, routine will use the unit vector [-1,0,0] as the
;                                direction about which to define the angular distributions
;                                for plotting
;                                [Default  :  FALSE]
;               VECTOR      :  [3]-Element [float/double] array defining the vector
;                                direction about which to define the angular distributions
;                                for plotting
;                                [Default  :  determined by P_ANGLE and SUNDIR settings]
;               UNITS       :  Scalar [string] defining the units to use for the
;                                vertical axis of the plot and the outputs YDAT and DYDAT
;                                [Default = 'flux' or number flux]
;               ESAL_BINS   :  [N]-Element [byte] array defining which low energy ESA
;                                 solid angle bins should be plotted [i.e.,
;                                 BINS[good] = 1b] and which bins should not be plotted
;                                 [i.e., BINS[bad] = 0b].  One can also define bins as
;                                 an array of indices that define which solid angle bins
;                                 to plot.  If this is the case, then on output, BINS
;                                 will be redefined to an array of byte values
;                                 specifying which bins are TRUE or FALSE.
;                                 [Default:  ESAL_BINS[*] = 1b]
;               ESAH_BINS   :  [N]-Element [byte] array defining which low energy ESA
;                                 solid angle bins should be plotted [i.e.,
;                                 BINS[good] = 1b] and which bins should not be plotted
;                                 [i.e., BINS[bad] = 0b].  One can also define bins as
;                                 an array of indices that define which solid angle bins
;                                 to plot.  If this is the case, then on output, BINS
;                                 will be redefined to an array of byte values
;                                 specifying which bins are TRUE or FALSE.
;                                 [Default:  ESAH_BINS[*] = 1b]
;               SST_BINS    :  [N]-Element [byte] array defining which SST solid angle bins
;                                 should be plotted [i.e., BINS[good] = 1b] and which
;                                 bins should not be plotted [i.e., BINS[bad] = 0b].
;                                 One can also define bins as an array of indices that
;                                 define which solid angle bins to plot.  If this is the
;                                 case, then on output, BINS will be redefined to an
;                                 array of byte values specifying which bins are TRUE or
;                                 FALSE.
;                                 [Default:  BINS[*] = 1b]
;               ONE_C       :  If set, routine computes one-count levels as well and
;                                outputs an average on the plot (but returns the full
;                                array of points on output from lbw_spec3d.pro)
;                                [Default = FALSE]
;               RM_PHOTO_E  :  If set, routine will remove data below the spacecraft
;                                potential defined by the structure tag SC_POT and
;                                shift the corresponding energy bins by
;                                CHARGE*SC_POT
;                                [Default = FALSE]
;               NUM_PA      :  Scalar [integer] that defines the number of pitch-angle
;                                bin end points to calculate for the resulting
;                                distribution.  The number of pitch-angle bins will
;                                actually be equal to (NUM_PA - 1)
;                                [Default = 8]
;               MIDN        :  Scalar [string] defining the mid-part of the TPLOT handle
;                                for the energy spectra
;                                [Default : '??_ener_spec', ?? = 'el','eh','elb',etc.]
;               TRANGE      :  [2]-Element [double] array of Unix times specifying the
;                                time range over which to calculate spectra
;                                [Default : [MIN(DAT.TIME),MAX(DAT.END_TIME)] ]
;               SPEC        :  If set, routine will tell TPLOT to use a spectrogram
;                                instead of a stacked line plot
;                                [Default = FALSE]
;               LDAT_MIN    :  Scalar [numeric] defining the maximum allowed value of the
;                                low energy ESA data in UNITS to consider when computing
;                                plot ranges for TPLOT
;                                [Default = (smaller of 95% of 5th percentile and 1% of MEDIAN)]
;               HDAT_MIN    :  Scalar [numeric] defining the maximum allowed value of the
;                                high energy ESA data in UNITS to consider when computing
;                                plot ranges for TPLOT
;                                [Default = (smaller of 95% of 5th percentile and 1% of MEDIAN)]
;               SDAT_MIN    :  Scalar [numeric] defining the maximum allowed value of the
;                                SST data in UNITS to consider when computing plot
;                                ranges for TPLOT
;                                [Default = (smaller of 95% of 5th percentile and 1% of MEDIAN)]
;               LDAT_MAX    :  Scalar [numeric] defining the maximum allowed value of the
;                                low energy ESA data in UNITS to consider when computing
;                                plot ranges for TPLOT
;                                [Default = (larger of 170% of 95th percentile and 1% of MAX)]
;               HDAT_MAX    :  Scalar [numeric] defining the maximum allowed value of the
;                                high energy ESA data in UNITS to consider when computing
;                                plot ranges for TPLOT
;                                [Default = (larger of 170% of 95th percentile and 1% of MAX)]
;               SDAT_MAX    :  Scalar [numeric] defining the maximum allowed value of the
;                                SST data in UNITS to consider when computing plot
;                                ranges for TPLOT
;                                [Default = (larger of 170% of 95th percentile and 1% of MAX)]
;
;               **********************************
;               ***     ALTERED ON OUTPUT      ***
;               **********************************
;               XDAT_ESAL   :  Set to a named variable to return the low energy ESA X
;                                data used in the spectra plot.
;                                [XDAT output from lbw_spec3d.pro]
;               YDAT_ESAL   :  Set to a named variable to return the low energy ESA Y
;                                data used in the spectra plot
;                                [YDAT output from lbw_spec3d.pro]
;               XDAT_ESAH   :  Set to a named variable to return the high energy ESA X
;                                data used in the spectra plot.
;                                [XDAT output from lbw_spec3d.pro]
;               YDAT_ESAH   :  Set to a named variable to return the high energy ESA Y
;                                data used in the spectra plot
;                                [YDAT output from lbw_spec3d.pro]
;               XDAT_SST    :  Set to a named variable to return the ESA X data
;                                used in the spectra plot
;                                [XDAT output from lbw_spec3d.pro]
;               YDAT_SST    :  Set to a named variable to return the ESA Y data
;                                used in the spectra plot
;                                [YDAT output from lbw_spec3d.pro]
;               XDAT_ALL    :  Set to a named variable to return the combined X data
;                                used in the spectra plot
;               YDAT_ALL    :  Set to a named variable to return the combined Y data
;                                used in the spectra plot
;               ONEC_ALL    :  Set to a named variable to return the combined one-count
;                                levels computed from the input distributions
;               P_ANGLE     :  Routine will alter on output to an array of pitch-angle
;                                mid-points [deg] used in the merged data product, if
;                                user set the keyword properly on input
;               OUT_STR     :  Set to a named variable to return a structure containing
;                                all the relevant parameters and metadata from this
;                                routine
;
;   CHANGED:  1)  Continued to write routine
;                                                                   [09/30/2022   v1.0.0]
;             2)  Continued to write routine
;                                                                   [10/03/2022   v1.0.0]
;             3)  Continued to write routine
;                                                                   [10/03/2022   v1.0.0]
;             4)  Continued to write routine
;                                                                   [10/04/2022   v1.0.0]
;             5)  Finished writing solid draft of routine
;                                                                   [10/04/2022   v1.0.0]
;             6)  Fixed an issue with input of plot LIMITS structures
;                                                                   [10/07/2022   v1.0.1]
;
;   NOTES:      
;               ***  Still writing routine  ***
;
;               0)  For Wind 3DP electrons, remember to remove the following solid angle
;                     bins prior to plotting to avoid "bad" data:
;
;                     [personal communication with Marc P. Pulupa, 2012]
;                     EESA HIGH
;                       badbins = [00, 02, 04, 06, 08, 09, 10, 11, 13, 15, 17, 19, $
;                                   20, 21, 66, 68, 70, 72, 74, 75, 76, 77, 79, 81, $
;                                   83, 85, 86, 87]
;
;                     SST Foil
;                       ***  Yes, remove  ***
;                       [personal communication with Linghua Wang, 2010]
;                       badbins = [07, 08, 09, 15, 31, 32, 33]
;
;                       ***  Don't remove  ***
;                       [personal communication with Davin Larson, 2011]
;                       badbins = [20, 21, 22, 23, 44, 45, 46, 47]
;                   For Wind 3DP ions, remember to remove the following solid angle
;                     bins prior to plotting to avoid "bad" data:
;
;                     SST Open
;                       ***  Yes, remove  ***
;                       [personal communication with Linghua Wang, 2010]
;                       sun_dir_bins   = [7,8,9,15,31,32,33]         ;;  7 bins
;                       noisy_bins     = [0,1,24,25]                 ;;  4 bins
;                       badbins        = [sun_dir_bins,noisy_bins]
;               1)  Make sure to be careful in use of VECTOR, SUNDIR, and P_ANGLE keywords
;                     If none are set, the routine will default to P_ANGLE
;               2)  Make sure to be careful in use of CUT_RAN and NUM_PA keywords
;                     If none are set, the routine will default to CUT_RAN and define
;                     NUM_PA = 4L
;               3)  Routine assumes user has run rougintes like pesa_high_bad_bins.pro on
;                     PESA High VDFs, for instance, prior to calling this routine
;               4)  Still working on how to handle user-defined energy range for stacked
;                     line plots
;
;  REFERENCES:  
;               1)  Carlson et al., (1983), "An instrument for rapidly measuring
;                      plasma distribution functions with high resolution,"
;                      Adv. Space Res. Vol. 2, pp. 67-70.
;               2)  Curtis et al., (1989), "On-board data analysis techniques for
;                      space plasma particle instruments," Rev. Sci. Inst. Vol. 60,
;                      pp. 372.
;               3)  Lin et al., (1995), "A Three-Dimensional Plasma and Energetic
;                      particle investigation for the Wind spacecraft," Space Sci. Rev.
;                      Vol. 71, pp. 125.
;               4)  Paschmann, G. and P.W. Daly (1998), "Analysis Methods for Multi-
;                      Spacecraft Data," ISSI Scientific Report, Noordwijk, 
;                      The Netherlands., Int. Space Sci. Inst.
;               5)  McFadden, J.P., C.W. Carlson, D. Larson, M. Ludlam, R. Abiad,
;                      B. Elliot, P. Turin, M. Marckwordt, and V. Angelopoulos
;                      "The THEMIS ESA Plasma Instrument and In-flight Calibration,"
;                      Space Sci. Rev. 141, pp. 277-302, (2008).
;               6)  McFadden, J.P., C.W. Carlson, D. Larson, J.W. Bonnell,
;                      F.S. Mozer, V. Angelopoulos, K.-H. Glassmeier, U. Auster
;                      "THEMIS ESA First Science Results and Performance Issues,"
;                      Space Sci. Rev. 141, pp. 477-508, (2008).
;               7)  Auster, H.U., K.-H. Glassmeier, W. Magnes, O. Aydogar, W. Baumjohann,
;                      D. Constantinescu, D. Fischer, K.H. Fornacon, E. Georgescu,
;                      P. Harvey, O. Hillenmaier, R. Kroth, M. Ludlam, Y. Narita,
;                      R. Nakamura, K. Okrafka, F. Plaschke, I. Richter, H. Schwarzl,
;                      B. Stoll, A. Valavanoglou, and M. Wiedemann "The THEMIS Fluxgate
;                      Magnetometer," Space Sci. Rev. 141, pp. 235-264, (2008).
;               8)  Angelopoulos, V. "The THEMIS Mission," Space Sci. Rev. 141,
;                      pp. 5-34, (2008).
;               9)  Wilson III, L.B., et al., "Relativistic Electrons Produced by
;                      Foreshock Disturbances Observed Upstream of Earth's Bow Shock,"
;                      Phys. Rev. Lett. 117(21), pp. 215101,
;              10)  L.B. Wilson III, et al., "Electron energy partition across
;                      interplanetary shocks: I. Methodology and Data Product,"
;                      Astrophys. J. Suppl. 243(8), doi:10.3847/1538-4365/ab22bd, 2019a.
;              11)  L.B. Wilson III, et al., "Electron energy partition across
;                      interplanetary shocks: II. Statistics," Astrophys. J. Suppl. 245(24),
;                      doi:10.3847/1538-4365/ab5445, 2019b.
;              12)  L.B. Wilson III, et al., "Electron energy partition across
;                      interplanetary shocks: III. Analysis," Astrophys. J. 893(22),
;                      doi:10.3847/1538-4357/ab7d39, 2020.
;              13)  L.B. Wilson III, et al., "A Quarter Century of Wind Spacecraft
;                      Discoveries," Rev. Geophys. 59(2), pp. e2020RG000714,
;                      doi:10.1029/2020RG000714, 2021.
;
;   CREATED:  09/29/2022
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  10/07/2022   v1.0.1
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

PRO t_combine_esalh_sst_spec3d,dat_esal,dat_esah,dat__sst,                                $
                                   LIM_ESAL=lim_esal,LIM_ESAH=lim_esah,LIM_SST=lim__sst,  $
                                   ESAL_ERAN=leran,ESAH_ERAN=heran,SST_ERAN=seran,        $
                                   SC_FRAME=sc_frame,CUT_RAN=cut_ran,P_ANGLE=p_angle,     $
                                   SUNDIR=sundir,VECTOR=vec,UNITS=units,                  $
                                   ESAL_BINS=lbins,ESAH_BINS=hbins,SST_BINS=sbins,        $
                                   ONE_C=one_c,RM_PHOTO_E=rm_photo_e,NUM_PA=num_pa,       $
                                   MIDN=midn,TRANGE=trange,SPEC=spec,                     $
                                   LDAT_MIN=ldat_min,HDAT_MIN=hdat_min,SDAT_MIN=sdat_min, $
                                   LDAT_MAX=ldat_max,HDAT_MAX=hdat_max,SDAT_MAX=sdat_max, $
                                   XDAT_ESAL=xdat_esal,YDAT_ESAL=ydat_esal,               $    ;;  Output
                                   XDAT_ESAH=xdat_esah,YDAT_ESAH=ydat_esah,               $
                                   XDAT_SST=xdat__sst,YDAT_SST=ydat__sst,                 $
                                   XDAT_ALL=xdat_all,YDAT_ALL=ydat__all,                  $
                                   ONEC_ALL=onec_all,OUT_STR=out_str

;;----------------------------------------------------------------------------------------
;;  Define some constants and dummy variables
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
lim0           = {XSTYLE:1,YSTYLE:1,YMINOR:9,XLOG:1,YLOG:1}
tlim_          = {XSTYLE:1,YSTYLE:1,PANEL_SIZE:2e0,XTICKLEN:0.04,YTICKLEN:0.01}
def_esaleran   = [1d0,1.5d3]            ;;  Default ESA low energy range [eV]
def_esaheran   = [10d1,25d3]            ;;  Default ESA high energy range [eV]
def_sst_eran   = [30d0,50d1]*1d3        ;;  Default SST energy range [eV]
def_cut_aran   = 22.5d0                 ;;  Default angular range [deg] of acceptance for averaging
cut_mids       = [22.5d0,9d1,157.5d0]   ;;  Default mid angles [deg] about which to define a range over which to average
def_midn       = '_ener_spec'
frac_cnts      = 0b                     ;;  logic to use to determine whether to allow fractional counts in unit conversion (THEMIS ESA only)
;;  Define all allowed units strings
all_units      = ['counts','flux','eflux','e2flux','e3flux','df','rate','crate']
;;  Dummy error messages
noinpt_msg     = 'User must supply three velocity distribution functions as IDL structures...'
notstr_msg     = 'DAT_ESAL, DAT_ESAH, and DAT_SST must be IDL structures...'
notvdf_msg     = 'DAT_ESAL, DAT_ESAH, and DAT_SST must be velocity distribution functions as an IDL structures...'
diffsc_msg     = 'DAT_ESAL, DAT_ESAH, and DAT_SST must come from the same spacecraft...'
badvdf_msg     = 'Input must be an IDL structure with similar format to Wind/3DP or THEMIS/ESA...'
not3dp_msg     = 'Input must be a velocity distribution IDL structure from Wind/3DP...'
notthm_msg     = 'Input must be a velocity distribution IDL structure from THEMIS/ESA...'
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Check input
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
IF (N_PARAMS() LT 3) THEN BEGIN
  MESSAGE,noinpt_msg[0],/INFORMATIONAL,/CONTINUE
  RETURN
ENDIF
test           = (SIZE(dat_esal,/TYPE) NE 8L OR N_ELEMENTS(dat_esal) LT 1) OR $
                 (SIZE(dat_esah,/TYPE) NE 8L OR N_ELEMENTS(dat_esah) LT 1) OR $
                 (SIZE(dat__sst,/TYPE) NE 8L OR N_ELEMENTS(dat__sst) LT 1)
IF (test[0]) THEN BEGIN
  MESSAGE,notstr_msg[0],/INFORMATIONAL,/CONTINUE
  RETURN
ENDIF
;;  Check to make sure distributions have the correct format
test_esa0      = test_wind_vs_themis_esa_struct(dat_esal[0],/NOM)
test_esa1      = test_wind_vs_themis_esa_struct(dat_esah[0],/NOM)
test_sst0      = test_wind_vs_themis_esa_struct(dat__sst[0],/NOM)
test           = ((test_esa0.(0) + test_esa0.(1)) NE 1) OR $
                 ((test_esa1.(0) + test_esa1.(1)) NE 1) OR $
                 ((test_sst0.(0) + test_sst0.(1)) NE 1)
IF (test[0]) THEN BEGIN
  MESSAGE,notvdf_msg[0],/INFORMATIONAL,/CONTINUE
  RETURN
ENDIF
;;  Make sure the distributions come from the same spacecraft (i.e., no mixing!)
test           = (test_esa0.(0) EQ test_sst0.(0)) AND (test_esa0.(1) EQ test_sst0.(1)) $
                 AND (test_esa1.(0) EQ test_sst0.(0)) AND (test_esa1.(1) EQ test_sst0.(1))
IF (test[0] EQ 0) THEN BEGIN
  MESSAGE,diffsc_msg[0],/INFORMATIONAL,/CONTINUE
  RETURN
ENDIF
;;----------------------------------------------------------------------------------------
;;  Define new variables for structures
;;----------------------------------------------------------------------------------------
dat0           = dat_esal
dat1           = dat_esah
dat2           = dat__sst
dap0           = dat0
dap1           = dat1
dap2           = dat2
dap0.DATA      = SQRT(dat0.DATA)        ;;  Define Poisson statistics
dap1.DATA      = SQRT(dat1.DATA)
dap2.DATA      = SQRT(dat2.DATA)
temp0          = dap0.DATA
temp1          = dap1.DATA
temp2          = dap2.DATA
bad0           = WHERE(temp0 LE 0 OR FINITE(temp0) EQ 0,bd0)
bad1           = WHERE(temp1 LE 0 OR FINITE(temp1) EQ 0,bd1)
bad2           = WHERE(temp2 LE 0 OR FINITE(temp2) EQ 0,bd2)
IF (bd0[0] GT 0) THEN temp0[bad0] = 1e0
IF (bd1[0] GT 0) THEN temp1[bad1] = 1e0
IF (bd2[0] GT 0) THEN temp2[bad2] = 1e0
dap0.DATA      = temp0
dap1.DATA      = temp1
dap2.DATA      = temp2
;;  Define # of VDFs, # of solid-angle bins, and # of energy bins
nvdf0          = N_ELEMENTS(dat0)
nvdf1          = N_ELEMENTS(dat1)
nvdf2          = N_ELEMENTS(dat2)
n_sa0          = dat0[0].NBINS[0]
n_sa1          = dat1[0].NBINS[0]
n_sa2          = dat2[0].NBINS[0]
n_en0          = dat0[0].NENERGY[0]
n_en1          = dat1[0].NENERGY[0]
n_en2          = dat2[0].NENERGY[0]
;;  Define sign of particle charge and energy shift
charge         = define_particle_charge(dat0[0],E_SHIFT=e_shift)
species        = (['electrons','ions'])[charge[0] GT 0]
;;  Define default TRANGE for later
tra_min        = MIN([dat0.TIME,dat1.TIME,dat2.TIME],/NAN)
tra_max        = MAX([dat0.END_TIME,dat1.END_TIME,dat2.END_TIME],/NAN)
;;----------------------------------------------------------------------------------------
;;  Determine spacecraft and instruments
;;----------------------------------------------------------------------------------------
IF (test_esa0.(0)) THEN BEGIN
  ;;--------------------------------------------------------------------------------------
  ;;  Wind
  ;;--------------------------------------------------------------------------------------
  mission        = 'Wind'
  strn0          = dat_3dp_str_names(dat0[0])
  strn1          = dat_3dp_str_names(dat1[0])
  strn2          = dat_3dp_str_names(dat2[0])
  IF (SIZE(strn0,/TYPE) NE 8 OR SIZE(strn1,/TYPE) NE 8 OR SIZE(strn2,/TYPE) NE 8) THEN BEGIN
    ;;  Neither Wind/3DP nor THEMIS/ESA VDF
    MESSAGE,not3dp_msg[0],/INFORMATIONAL,/CONTINUE
    RETURN
  ENDIF
  instnmmode_l   = strn0.LC[0]         ;;  e.g., 'Eesa Low Burst'
  instnmmode_h   = strn1.LC[0]         ;;  e.g., 'Eesa High Burst'
  instnmmode_s   = strn2.LC[0]         ;;  e.g., 'SST Foil Burst'
  inst_shnme_l   = strn0.SN[0]         ;;  e.g., 'elb'
  inst_shnme_h   = strn1.SN[0]         ;;  e.g., 'ehb'
  inst_shnme_s   = strn2.SN[0]         ;;  e.g., 'sfb'
  yttl_pref      = 'Wind 3DP'
  ;;  Define spacecraft prefix for TPLOT handles
  scpref         = mission[0]+'_'
  inst_pref      = inst_shnme_l[0]+'_'+inst_shnme_h[0]+'_'+inst_shnme_s[0]
ENDIF ELSE BEGIN
  IF (test_esa0.(1)) THEN BEGIN
    ;;------------------------------------------------------------------------------------
    ;;  THEMIS
    ;;------------------------------------------------------------------------------------
    mission        = 'THEMIS'
    strn0          = dat_themis_esa_str_names(dat0[0])
    strn1          = dat_themis_esa_str_names(dat1[0])
    strn2          = dat_themis_esa_str_names(dat2[0])
    IF (SIZE(strn0,/TYPE) NE 8 OR SIZE(strn1,/TYPE) NE 8 OR SIZE(strn2,/TYPE) NE 8) THEN BEGIN
      ;;  Neither Wind/3DP nor THEMIS/ESA VDF
      MESSAGE,not3dp_msg[0],/INFORMATIONAL,/CONTINUE
      RETURN
    ENDIF
    probe          = STRUPCASE(dat0[0].SPACECRAFT[0])  ;;  e.g., 'C'
    mission        = mission[0]+'-'+probe[0]
    temp           = strn0.LC[0]                  ;;  e.g., 'IESA 3D Burst Distribution'
    tposi          = STRPOS(temp[0],'Distribution') - 1L
    instnmmode_l   = STRMID(temp[0],0L,tposi[0])  ;;  e.g., 'IESA 3D Burst'
    instnmmode_h   = instnmmode_l                 ;;  THEMIS doesn't have 2 ESAs spanning different energy ranges
    temp           = strn2.LC[0]                  ;;  e.g., 'SST Ion Burst Distribution'
    tposi          = STRPOS(temp[0],'Distribution') - 1L
    instnmmode_s   = STRMID(temp[0],0L,tposi[0])  ;;  e.g., 'SST Ion Burst'
    inst_shnme_l   = strn0.SN[0]                  ;;  e.g., 'peib'
    inst_shnme_h   = strn1.SN[0]                  ;;  e.g., 'peib'
    inst_shnme_s   = strn2.SN[0]                  ;;  e.g., 'psib'
    frac_cnts      = 1b
    yttl_pref      = 'THEMIS ESA+SST'
    ;;  Define spacecraft prefix for TPLOT handles
    scpref         = 'THM'+probe[0]+'_'
    inst_pref      = inst_shnme_l[0]+'_'+inst_shnme_s[0]
  ENDIF ELSE BEGIN
    ;;------------------------------------------------------------------------------------
    ;;  Other mission?
    ;;------------------------------------------------------------------------------------
    ;;  Not handling any other missions yet  [Need to know the format of their distributions]
    MESSAGE,badvdf_msg[0],/INFORMATIONAL,/CONTINUE
    RETURN
  ENDELSE
ENDELSE
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Check keywords
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Check LIM_ESAL, LIM_ESAH, and LIM_SST
IF (SIZE(lim_esal,/TYPE) EQ 8L) THEN extract_tags,liml_str,lim_esal
extract_tags,liml_str,lim0       ;;  Add defaults to ESA low energy structure
IF (SIZE(lim_esah,/TYPE) EQ 8L) THEN extract_tags,limh_str,lim_esah
extract_tags,limh_str,lim0       ;;  Add defaults to ESA high energy structure
IF (SIZE(lim__sst,/TYPE) EQ 8L) THEN extract_tags,lims_str,lim__sst
extract_tags,lims_str,lim0       ;;  Add defaults to SST structure
;;  Check ESAL_ERAN, ESAH_ERAN, and SST_ERAN
IF (test_plot_axis_range(leran,/NOMSSG) EQ 0L) THEN eran_esl = def_esaleran ELSE eran_esl = leran
IF (test_plot_axis_range(heran,/NOMSSG) EQ 0L) THEN eran_esh = def_esaheran ELSE eran_esh = heran
IF (test_plot_axis_range(seran,/NOMSSG) EQ 0L) THEN eran_sst = def_sst_eran ELSE eran_sst = seran
;;  Add XRANGE for each structure (for lbw_spec3d.pro)
str_element,liml_str,'ERANGE',eran_esl,/ADD_REPLACE
str_element,limh_str,'ERANGE',eran_esh,/ADD_REPLACE
str_element,lims_str,'ERANGE',eran_sst,/ADD_REPLACE
;;  Check SC_FRAME
IF KEYWORD_SET(sc_frame) THEN scframe = 1b ELSE scframe = 0b
;;  Check CUT_RAN
IF (is_a_number(cut_ran,/NOMSSG) EQ 0) THEN cutran = def_cut_aran[0] ELSE cutran = cut_ran[0]
;;  Check NUM_PA
IF (KEYWORD_SET(num_pa)) THEN BEGIN
  IF (is_a_number(num_pa,/NOMSSG)) THEN BEGIN
    ;;  User defined the number of pitch-angles --> Redefine CUT_RAN
    num_pa         = LONG(num_pa[0]) > 3L
    del_pa         = 18d1/(num_pa[0] - 1L)           ;;  Width of pitch-angle bins
    pabinend       = DINDGEN(num_pa[0])*del_pa[0]
    indl           = LINDGEN(num_pa[0] - 1L)
    indh           = indl + 1L
    cut_lows       = pabinend[indl]
    cut_high       = pabinend[indh]
  ENDIF ELSE BEGIN
    ;;  User did not correctly define the number of pitch-angles --> define from CUT_RAN
    num_pa         = 4L
    cut_lows       = cut_mids - cutran[0]
    cut_high       = cut_mids + cutran[0]
  ENDELSE
ENDIF ELSE BEGIN
  ;;  User did not define the number of pitch-angles --> define from CUT_RAN
  num_pa         = 4L
  cut_lows       = cut_mids - cutran[0]
  cut_high       = cut_mids + cutran[0]
ENDELSE
;;  Make sure values are not < 0 or > 180
cut_lows       = cut_lows > 0d0
cut_high       = cut_high < 18d1
;;  Check P_ANGLE
IF KEYWORD_SET(p_angle) THEN pang = 1b ELSE pang = 0b
;;  Check SUNDIR
IF KEYWORD_SET(sundir) THEN sun_d = 1b ELSE sun_d = 0b
;;----------------------------------------------------------------------------------------
;;  Check VECTOR
;;----------------------------------------------------------------------------------------
IF (is_a_3_vector(vec,V_OUT=v_out,/NOMSSG)) THEN BEGIN
  ;;  User set VECTOR keyword properly --> use for PAD calculations
  vecdir         = v_out
  fsuffx         = '_vecdir'
  sun_d          = 0b
  pang           = 0b
  vecon          = 1b
ENDIF ELSE BEGIN
  ;;  VECTOR not set --> check if P_ANGLE or SUNDIR was set
  test           = pang[0] OR sun_d[0]
  IF (test[0]) THEN BEGIN
    ;;  Either P_ANGLE and/or SUNDIR was set --> define direction to use (i.e., force the other to FALSE)
    IF (pang[0]) THEN BEGIN
      ;;  Use MAGF for pitch-angles
      sun_d          = 0b
      fsuffx         = '_Bvec'
    ENDIF ELSE BEGIN
      ;;  Use sun direction for pitch-angles
      pang           = 0b
      fsuffx         = '_sundir'
    ENDELSE
    vecon          = 0b
    vecdir         = 0b
  ENDIF ELSE BEGIN
    ;;  None of the directions were set --> default to P_ANGLE
    fsuffx         = '_Bvec'
    pang           = 1b
    sun_d          = 0b
    vecon          = 0b
    vecdir         = 0b
  ENDELSE
ENDELSE
;;  Define all PAD settings for later reference
pa_sett        = [pang[0],sun_d[0],vecon[0]]
;;----------------------------------------------------------------------------------------
;;  Check UNITS
;;----------------------------------------------------------------------------------------
temp           = wind_3dp_units(units)
gunits         = temp.G_UNIT_NAME      ;;  e.g., 'flux'
units          = gunits[0]             ;;  redefine UNITS incase it changed
punits         = temp.G_UNIT_P_NAME    ;;  e.g., ' (# cm!U-2!Ns!U-1!Nsr!U-1!NeV!U-1!N)'
;;  Define default min/max values based on units
CASE gunits[0] OF
  'flux'    :  BEGIN
    ;;  # cm^(-2) s^(-1) sr^(-1) eV^(-1)
    def_dat_min    = 1d-10
    def_dat_max    = 1d12
  END
  'eflux'   :  BEGIN
    ;;  eV cm^(-2) s^(-1) sr^(-1) eV^(-1)
    def_dat_min    = 1d-8
    def_dat_max    = 1d14
  END
  'df'      :  BEGIN
    ;;  # cm^(-3) km^(-3) s^(+3)
    def_dat_min    = 1d-24
    def_dat_max    = 1d2
  END
  'counts'  :  BEGIN
    ;;  #
    def_dat_min    = 1d0
    def_dat_max    = 1d4
  END
  'rate'    :  BEGIN
    ;;  # s^(-1) [uncorrected]
    def_dat_min    = 1d-4
    def_dat_max    = 1d5
  END
  'crate'   :  BEGIN
    ;;  # s^(-1) [corrected]
    def_dat_min    = 1d-4
    def_dat_max    = 1d5
  END
  ELSE      :  BEGIN
    ;;  Assume default number flux range
    def_dat_min    = 1d-10
    def_dat_max    = 1d12
  END
ENDCASE
;;----------------------------------------------------------------------------------------
;;  Check ESAL_BINS, ESAH_BINS, and SST_BINS
;;----------------------------------------------------------------------------------------
bstr           = format_esa_bins_keyword(dat0,BINS=lbins)
IF (SIZE(bstr,/TYPE) NE 8) THEN lbins = REPLICATE(1b,dat0[0].NBINS)
bstr           = format_esa_bins_keyword(dat1,BINS=hbins)
IF (SIZE(bstr,/TYPE) NE 8) THEN hbins = REPLICATE(1b,dat1[0].NBINS)
bstr           = format_esa_bins_keyword(dat2,BINS=sbins)
IF (SIZE(bstr,/TYPE) NE 8) THEN sbins = REPLICATE(1b,dat2[0].NBINS)
;;  Check ONE_C keyword
IF KEYWORD_SET(one_c) THEN log_1c = 1b ELSE log_1c = 0b
;;  Check RM_PHOTO_E keyword
IF KEYWORD_SET(rm_photo_e) THEN rmscpot = 1b ELSE rmscpot = 0b
IF (charge[0] GT 0) THEN rmscpot = 0b     ;;  Don't bother removing phi_sc for ions
;;  Check MIDN
IF (SIZE(midn,/TYPE) EQ 7) THEN BEGIN
  ;;  It is set --> Make sure the format is okay
  IF (IDL_VALIDNAME(midn,/CONVERT_SPACES) NE '') THEN mid_out = midn[0] ELSE mid_out = def_midn[0]
ENDIF ELSE BEGIN
  ;;  Not set --> overwrite
  mid_out        = def_midn[0]
ENDELSE
;;  Check TRANGE
IF (test_plot_axis_range(trange,/NOMSSG) EQ 0) THEN trange = [tra_min[0],tra_max[0]]
tra_struc      = get_valid_trange(TRANGE=trange,PRECISION=3L)
tra_unix       = tra_struc.UNIX_TRANGE
IF (test_plot_axis_range(tra_unix,/NOMSSG) EQ 0) THEN tra_unix = [tra_min[0],tra_max[0]]
;;  Check SPEC keyword
IF KEYWORD_SET(spec) THEN spec_on = 1b ELSE spec_on = 0b
;;  Check LDAT_MIN, HDAT_MIN, and SDAT_MIN
IF (is_a_number(ldat_min,/NOMSSG) EQ 0) THEN ldatmin = def_dat_min[0] ELSE ldatmin = ABS(ldat_min[0])
IF (is_a_number(hdat_min,/NOMSSG) EQ 0) THEN hdatmin = def_dat_min[0] ELSE hdatmin = ABS(hdat_min[0])
IF (is_a_number(sdat_min,/NOMSSG) EQ 0) THEN sdatmin = def_dat_min[0] ELSE sdatmin = ABS(sdat_min[0])
;;  Check LDAT_MAX, HDAT_MAX, and SDAT_MAX
IF (is_a_number(ldat_max,/NOMSSG) EQ 0) THEN ldatmax = def_dat_max[0] ELSE ldatmax = ABS(ldat_max[0])
IF (is_a_number(hdat_max,/NOMSSG) EQ 0) THEN hdatmax = def_dat_max[0] ELSE hdatmax = ABS(hdat_max[0])
IF (is_a_number(sdat_max,/NOMSSG) EQ 0) THEN sdatmax = def_dat_max[0] ELSE sdatmax = ABS(sdat_max[0])
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Transform (if desired) into bulk flow rest frame
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
oldrmscp       = rmscpot[0]
tdatl_sw       = sub_combine_elhs_vframe_trans(dat0,FRCCNTS=frac_cnts[0],RM_PHOTO_E=rmscpot, $
                                               SC_FRAME=scframe[0],UNITS=gunits[0],          $
                                               TTLE_EXT=ttle_ext,VFRAME=vframel,             $
                                               RMSC_SUFFX=rmsc_suffx)
tdath_sw       = sub_combine_elhs_vframe_trans(dat1,SC_FRAME=scframe[0],UNITS=gunits[0],VFRAME=vframeh)
tdats_sw       = sub_combine_elhs_vframe_trans(dat2,SC_FRAME=scframe[0],UNITS=gunits[0],VFRAME=vframes)
;;  Now do the same on the Poisson statistics
tdapl_sw       = sub_combine_elhs_vframe_trans(dap0,FRCCNTS=frac_cnts[0],RM_PHOTO_E=oldrmscp, $
                                               SC_FRAME=scframe[0],UNITS=gunits[0])
tdaph_sw       = sub_combine_elhs_vframe_trans(dap1,SC_FRAME=scframe[0],UNITS=gunits[0])
tdaps_sw       = sub_combine_elhs_vframe_trans(dap2,SC_FRAME=scframe[0],UNITS=gunits[0])
IF (charge[0] GT 0) THEN rmsc_suffx  = ''      ;;  Shut off for ions
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Compute PAD spectra and save output
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Define midpoint times
unix_l         = (tdatl_sw.TIME + tdatl_sw.END_TIME)/2d0
unix_h         = (tdath_sw.TIME + tdath_sw.END_TIME)/2d0
unix_s         = (tdats_sw.TIME + tdats_sw.END_TIME)/2d0
;;  Define dummy arrays
ener_l         = REPLICATE(d,nvdf0[0],n_en0[0],n_sa0[0])
ener_h         = REPLICATE(d,nvdf1[0],n_en1[0],n_sa1[0])
ener_s         = REPLICATE(d,nvdf2[0],n_en2[0],n_sa2[0])
ydat_l         = ener_l
ydat_h         = ener_h
ydat_s         = ener_s
pang_l         = REPLICATE(d,nvdf0[0],n_sa0[0])
pang_h         = REPLICATE(d,nvdf1[0],n_sa1[0])
pang_s         = REPLICATE(d,nvdf2[0],n_sa2[0])
IF (log_1c[0]) THEN BEGIN
  ;;  Yes, calculate one-count levels
  ydat1c_l       = 1b
  ydat1c_h       = 1b
  ydat1c_s       = 1b
ENDIF ELSE BEGIN
  ydat1c_l       = 0b
  ydat1c_h       = 0b
  ydat1c_s       = 0b
  yd1c_l         = ener_l
  yd1c_h         = ener_h
  yd1c_s         = ener_s
ENDELSE
;;----------------------------------------------------------------------------------------
;;  Define TPLOT structures
;;----------------------------------------------------------------------------------------
nn_all         = [nvdf0[0],n_en0[0],n_sa0[0]]
struc_l        = sub_combine_elhs_calc_pads(tdatl_sw,PA_SETT=pa_sett,VECTOR=vecdir,RM_PHOTO_E=rmscpot,GOOD_BINS=lbins)
struc_h        = sub_combine_elhs_calc_pads(tdath_sw,PA_SETT=pa_sett,VECTOR=vecdir,RM_PHOTO_E=rmscpot,GOOD_BINS=hbins)
struc_s        = sub_combine_elhs_calc_pads(tdats_sw,PA_SETT=pa_sett,VECTOR=vecdir,RM_PHOTO_E=rmscpot,GOOD_BINS=sbins)
;;  Repeat for Poisson statistics
strup_l        = sub_combine_elhs_calc_pads(tdapl_sw,PA_SETT=pa_sett,VECTOR=vecdir,RM_PHOTO_E=rmscpot,GOOD_BINS=lbins)
strup_h        = sub_combine_elhs_calc_pads(tdaph_sw,PA_SETT=pa_sett,VECTOR=vecdir,RM_PHOTO_E=rmscpot,GOOD_BINS=hbins)
strup_s        = sub_combine_elhs_calc_pads(tdaps_sw,PA_SETT=pa_sett,VECTOR=vecdir,RM_PHOTO_E=rmscpot,GOOD_BINS=sbins)
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Average over pitch-angles
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
pang_ra        = [[cut_lows],[cut_high]]
strav_l0       = sub_combine_elhs_avg_pads(struc_l,strup_l,pang_ra)
strav_h0       = sub_combine_elhs_avg_pads(struc_h,strup_h,pang_ra)
strav_s0       = sub_combine_elhs_avg_pads(struc_s,strup_s,pang_ra)
n_pa           = N_ELEMENTS(cut_lows)                                 ;;  # of pitch-angle averages
pang_av        = MEAN(pang_ra,/NAN,DIMENSION=2)
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Send to TPLOT
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Get TPLOT stuff
tpn_stuff0     = sub_combine_elhs_get_tplot_pard(strav_l0,pang_ra,SPEC=spec_on,UNITN=gunits, $
                                           UNITT=punits,PARTICLE=species,TTLE_PRE=yttl_pref, $
                                           INST_PRE=inst_shnme_l,MID_TOUT=mid_out,           $
                                           SCPREF=scpref,FSUFFX=fsuffx,TTLE_EXT=ttle_ext,    $
                                           DATA_MIN=ldatmin,DATA_MAX=ldatmax,LIM_DATA=liml_str)
tpn_stuff1     = sub_combine_elhs_get_tplot_pard(strav_h0,pang_ra,SPEC=spec_on,UNITN=gunits, $
                                           UNITT=punits,PARTICLE=species,TTLE_PRE=yttl_pref, $
                                           INST_PRE=inst_shnme_h,MID_TOUT=mid_out,           $
                                           SCPREF=scpref,FSUFFX=fsuffx,TTLE_EXT=ttle_ext,    $
                                           DATA_MIN=hdatmin,DATA_MAX=hdatmax,LIM_DATA=limh_str)
tpn_stuff2     = sub_combine_elhs_get_tplot_pard(strav_s0,pang_ra,SPEC=spec_on,UNITN=gunits, $
                                           UNITT=punits,PARTICLE=species,TTLE_PRE=yttl_pref, $
                                           INST_PRE=inst_shnme_s,MID_TOUT=mid_out,           $
                                           SCPREF=scpref,FSUFFX=fsuffx,TTLE_EXT=ttle_ext,    $
                                           DATA_MIN=sdatmin,DATA_MAX=sdatmax,LIM_DATA=lims_str)
IF (SIZE(tpn_stuff0,/TYPE) NE 8 OR SIZE(tpn_stuff1,/TYPE) NE 8 OR SIZE(tpn_stuff2,/TYPE) NE 8) THEN STOP
;;----------------------------------------------------------------------------------------
;;  Send low energy ESA PADs to TPLOT
;;----------------------------------------------------------------------------------------
struc          =   strav_l0
tpn_stuff      = tpn_stuff0
nvdf           =      nvdf0[0]

tdlimp0        = tpn_stuff.DLIM_OMNI
tplot_nmo      = tpn_stuff.TPN_OMNI
tplot_pad      = tpn_stuff.TPN_PADS
yttl_pads      = tpn_stuff.YTTL_PADS
zttl_pads      = tpn_stuff.ZTTL_PADS
out_ener0      = tpn_stuff.OUT_ENER
out_ener       = REPLICATE(1d0,nvdf[0]) # out_ener0
FOR k=0L, n_pa[0] - 1L DO BEGIN
  ;;  Setup DLIMITS and TPLOT structure
  tdlimp         = tdlimp0
  str_element,tdlimp,'YTITLE',yttl_pads[k],/ADD_REPLACE
  str_element,tdlimp,'ZTITLE',zttl_pads[k],/ADD_REPLACE
  temp           = {X:struc.X,Y:REFORM(struc.Y[*,*,k]),V:out_ener,SPEC:spec_on[0]}
  ;;  Send to TPLOT
  store_data,tplot_pad[k],DATA=temp,DLIMITS=tdlimp,LIMITS=tlim_
ENDFOR
;;  Define output string array of TPLOT handles
tpn_lpad       = tplot_pad
;;----------------------------------------------------------------------------------------
;;  Send high energy ESA PADs to TPLOT
;;----------------------------------------------------------------------------------------
struc          =   strav_h0
tpn_stuff      = tpn_stuff1
nvdf           =      nvdf1[0]

tdlimp0        = tpn_stuff.DLIM_OMNI
tplot_nmo      = tpn_stuff.TPN_OMNI
tplot_pad      = tpn_stuff.TPN_PADS
yttl_pads      = tpn_stuff.YTTL_PADS
zttl_pads      = tpn_stuff.ZTTL_PADS
out_ener0      = tpn_stuff.OUT_ENER
out_ener       = REPLICATE(1d0,nvdf[0]) # out_ener0
FOR k=0L, n_pa[0] - 1L DO BEGIN
  ;;  Setup DLIMITS and TPLOT structure
  tdlimp         = tdlimp0
  str_element,tdlimp,'YTITLE',yttl_pads[k],/ADD_REPLACE
  str_element,tdlimp,'ZTITLE',zttl_pads[k],/ADD_REPLACE
  temp           = {X:struc.X,Y:REFORM(struc.Y[*,*,k]),V:out_ener,SPEC:spec_on[0]}
  ;;  Send to TPLOT
  store_data,tplot_pad[k],DATA=temp,DLIMITS=tdlimp,LIMITS=tlim_
ENDFOR
;;  Define output string array of TPLOT handles
tpn_hpad       = tplot_pad
;;----------------------------------------------------------------------------------------
;;  Send SST PADs to TPLOT
;;----------------------------------------------------------------------------------------
struc          =   strav_s0
tpn_stuff      = tpn_stuff2
nvdf           =      nvdf2[0]

tdlimp0        = tpn_stuff.DLIM_OMNI
tplot_nmo      = tpn_stuff.TPN_OMNI
tplot_pad      = tpn_stuff.TPN_PADS
yttl_pads      = tpn_stuff.YTTL_PADS
zttl_pads      = tpn_stuff.ZTTL_PADS
out_ener0      = tpn_stuff.OUT_ENER
out_ener       = REPLICATE(1d0,nvdf[0]) # out_ener0
FOR k=0L, n_pa[0] - 1L DO BEGIN
  ;;  Setup DLIMITS and TPLOT structure
  tdlimp         = tdlimp0
  str_element,tdlimp,'YTITLE',yttl_pads[k],/ADD_REPLACE
  str_element,tdlimp,'ZTITLE',zttl_pads[k],/ADD_REPLACE
  temp           = {X:struc.X,Y:REFORM(struc.Y[*,*,k]),V:out_ener,SPEC:spec_on[0]}
  ;;  Send to TPLOT
  store_data,tplot_pad[k],DATA=temp,DLIMITS=tdlimp,LIMITS=tlim_
ENDFOR
;;  Define output string array of TPLOT handles
tpn_spad       = tplot_pad
;;  Merge three arrays of TPLOT handles
tpn_opad       = [[tpn_lpad],[tpn_hpad],[tpn_spad]]
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Interpolate to a common time stamp
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
unix           = unix_l
;;  Interpolate
strav_l        = t_resample_tplot_struc(strav_l0,unix,/NO_EXTRAPOLATE,/IGNORE_INT)
strav_h        = t_resample_tplot_struc(strav_h0,unix,/NO_EXTRAPOLATE,/IGNORE_INT)
strav_s        = t_resample_tplot_struc(strav_s0,unix,/NO_EXTRAPOLATE,/IGNORE_INT)
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Merge and regrid in energy
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
yavg_l         = strav_l.Y             ;;  [N,E,A]-Element array
yavg_h         = strav_h.Y             ;;  [N,F,A]-Element array
yavg_s         = strav_s.Y             ;;  [N,G,A]-Element array
ener_l         = strav_l.V1            ;;  [N,E]-Element array
ener_h         = strav_h.V1            ;;  [N,F]-Element array
ener_s         = strav_s.V1            ;;  [N,G]-Element array
n_ena0         = n_en0[0] + n_en1[0] + n_en2[0]
nvdf           = N_ELEMENTS(yavg_l[*,0,0])
yavg_a0        = REPLICATE(d,nvdf[0],n_ena0[0],n_pa[0])         ;;  [N,H,A]-Element array {where H = (E + F + G)}
ener_a0        = REPLICATE(d,nvdf[0],n_ena0[0])                 ;;  [N,H]-Element array   {where H = (E + F + G)}
l10ytmp        = yavg_a0                                        ;;  Dummy variable for later
ind0           = LINDGEN(n_en0[0]) + 0L
ind1           = LINDGEN(n_en1[0]) + MAX(ind0) + 1L
ind2           = LINDGEN(n_en2[0]) + MAX(ind1) + 1L
;;  Fill arrays
yavg_a0[*,ind0,*] = yavg_l
yavg_a0[*,ind1,*] = yavg_h
yavg_a0[*,ind2,*] = yavg_s
ener_a0[*,ind0]   = ener_l
ener_a0[*,ind1]   = ener_h
ener_a0[*,ind2]   = ener_s
;;----------------------------------------------------------------------------------------
;;  Define new energy grid, uniform in logarithmic space
;;----------------------------------------------------------------------------------------
eran_all       = [MIN(ener_a0,/NAN),MAX(ener_a0,/NAN)] > 1d-2
test           = (test_plot_axis_range(eran_all,/NOMSSG) EQ 0L)
IF (test[0]) THEN eran_all = [MIN([eran_esl,eran_esh,eran_sst],/NAN),MAX([eran_esl,eran_esh,eran_sst],/NAN)]
eran_all       = roundsig(eran_all,SIG=1) > 1d-2
l10erana       = ALOG10(eran_all)
dx             = (MAX(l10erana,/NAN) - MIN(l10erana,/NAN))/(n_ena0[0] - 1L)
l10eners       = DINDGEN(n_ena0[0])*dx[0] + MIN(l10erana,/NAN)
new_ener       = 1d1^(l10eners)
;;----------------------------------------------------------------------------------------
;;  Interpolate to new energies
;;----------------------------------------------------------------------------------------
l10yavg        = ALOG10(yavg_a0)
l10ener        = ALOG10(ener_a0)
FOR j=0L, nvdf[0] - 1L DO BEGIN
  ;;  First sort by energy, in ascending order
  temp           = REFORM(ener_a0[j,*])
  sp             = SORT(temp)
  l10y           = REFORM(l10yavg[j,sp,*])
  l10e           = REFORM(l10ener[j,sp])
  FOR k=0L, n_pa[0] - 1L DO BEGIN
    ;;  First smooth the merged data to reduce the overlap discontinuities
    l10smth        = SMOOTH(REFORM(l10y[*,k]),3L,/NAN,/EDGE_TRUNCATE)
    ;;  Linearly interpolate to new energy grid
    l10ytmp[j,*,k] = INTERPOL(l10smth,REFORM(l10e[*]),l10eners,/NAN)
  ENDFOR
ENDFOR
;;  Define new output data
yavg_all       = 1d1^(l10ytmp)                                ;;  All PADs in one array
yavg_omn       = MEAN(yavg_all,/NAN,DIMENSION=3)              ;;  Ominidirectional average
out_ener       = 1d-3*new_ener
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Define output values and structures
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
tener          = REPLICATE(1d0,nvdf[0]) # new_ener
struc_avg      = {X:unix,Y:yavg_all,V1:tener,V2:strav_l.V2}
all_dat_min    = MIN([ldatmin[0],hdatmin[0],sdatmin[0]],/NAN)
all_dat_max    = MAX([ldatmax[0],hdatmax[0],sdatmax[0]],/NAN)
tpn_stuffa     = sub_combine_elhs_get_tplot_pard(struc_avg,pang_ra,SPEC=spec_on,UNITN=gunits, $
                                           UNITT=punits,PARTICLE=species,TTLE_PRE=yttl_pref,  $
                                           INST_PRE=inst_pref,MID_TOUT=mid_out,               $
                                           SCPREF=scpref,FSUFFX=fsuffx,TTLE_EXT=ttle_ext,     $
                                           DATA_MIN=all_dat_min,DATA_MAX=all_dat_max)
tpn_stuff      = tpn_stuffa
tdlimp0        = tpn_stuff.DLIM_OMNI
tplot_nmo      = tpn_stuff.TPN_OMNI
tplot_pad      = tpn_stuff.TPN_PADS
yttl_pads      = tpn_stuff.YTTL_PADS
zttl_pads      = tpn_stuff.ZTTL_PADS
out_ener0      = tpn_stuff.OUT_ENER
out_ener       = REPLICATE(1d0,nvdf[0]) # out_ener0
;;  Define TPLOT structures and send to TPLOT
t_str_omnidir  = {X:unix,Y:yavg_omn,V:out_ener,SPEC:spec_on[0]}
store_data,tplot_nmo[0]+'_omni',DATA=t_str_omnidir,DLIMITS=tdlimp0,LIMITS=tlim_
t_str_pad_all  = {X:unix,Y:yavg_all,V1:out_ener,V2:strav_l.V2,SPEC:spec_on[0]}
store_data,tplot_nmo[0]+'_pads',DATA=t_str_pad_all,DLIMITS=tdlimp0,LIMITS=tlim_
t_struc        = {OMNI:t_str_omnidir,ALLPAD:t_str_pad_all}
d_limit        = {OMNI:tdlimp0,ALLPAD:tdlimp0}
FOR k=0L, n_pa[0] - 1L DO BEGIN
  ;;  Send to TPLOT
  tdlimp         = tdlimp0
  str_element,tdlimp,'YTITLE',yttl_pads[k],/ADD_REPLACE
  str_element,tdlimp,'ZTITLE',zttl_pads[k],/ADD_REPLACE
  temp           = {X:unix,Y:REFORM(yavg_all[*,*,k]),V:out_ener,SPEC:spec_on[0]}
  store_data,tplot_pad[k],DATA=temp,DLIMITS=tdlimp,LIMITS=tlim_
  ;;  Add to output structure
  kstr           = 'k'+num2int_str(k[0],NUM_CHAR=3L,/ZERO_PAD)
  str_element,t_struc,kstr[0],  temp,/ADD_REPLACE
  str_element,d_limit,kstr[0],tdlimp,/ADD_REPLACE
ENDFOR
tpn_nall       = [tplot_nmo[0]+['_omni','_pads'],tplot_pad]
;;----------------------------------------------------------------------------------------
;;  Define output keyword values
;;----------------------------------------------------------------------------------------
p_angle        = pang_av
xdat_esal      = ener_l
xdat_esah      = ener_h
xdat__sst      = ener_s
ydat_esal      = ydat_l
ydat_esah      = ydat_h
ydat__sst      = ydat_s
;;  Define merged output
xdat__all      = new_ener
ydat__all      = yavg_all
;;----------------------------------------------------------------------------------------
;;  Define output structure with relevant stuff
;;----------------------------------------------------------------------------------------
tags           = ['TPLOT_STR','TPLOT_NMS','PA_RANS','PA_SET_PSV','DLIMITS','TPNM_SEP_INSTS']
out_str        = CREATE_STRUCT(tags,t_struc,tpn_nall,pang_ra,[pang[0],sun_d[0],vecon[0]],$
                               d_limit,tpn_opad)
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------

RETURN
END































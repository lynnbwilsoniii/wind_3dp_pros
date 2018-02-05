;+
;*****************************************************************************************
;
;  PROCEDURE:   plot_esalh_sst_combined_spec3d.pro
;  PURPOSE  :   This routine plots a combined 3D spectra of from two lower energy ESA and
;                 a higher energy SST as a 1D plot of UNITS vs. Energy.
;
;  CALLED BY:   
;               NA
;
;  INCLUDES:
;               NA
;
;  CALLS:
;               test_wind_vs_themis_esa_struct.pro
;               test_plot_axis_range.pro
;               struct_value.pro
;               plot_esa_sst_combined_spec3d.pro
;               lbw_window.pro
;               extract_tags.pro
;               str_element.pro
;               get_power_of_ten_ticks.pro
;               popen.pro
;               pclose.pro
;
;  REQUIRES:    
;               1)  THEMIS TDAS 8.0 or SPEDAS 1.0 (or greater) IDL libraries; or
;               2)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               DAT_ESAL   :  Scalar [structure] associated with a known low energy ESA
;                               data structure from Wind/3DP
;                               [see get_?.pro, ? = el, elb, pl, or plb]
;               DAT_ESAH   :  Scalar [structure] associated with a known high energy ESA
;                               data structure from Wind/3DP
;                               [see get_?.pro, ? = eh, ehb, ph, or phb]
;               DAT_SST    :  Scalar [structure] associated with a known SST
;                               data structure from Wind/3DP
;                               [see get_?.pro, ? = sf, sfb, so, sob]
;
;  EXAMPLES:    
;               [calling sequence]
;               plot_esalh_sst_combined_spec3d,dat_esal,dat_esah,dat_sst [,LIM_ESAL=lim_esal] $
;                                             [,LIM_ESAH=lim_esah] [,LIM_SST=lim_sst]         $
;                                             [,ESAL_ERAN=esaleran] [,ESAH_ERAN=esaheran]     $
;                                             [,SST_ERAN=sst_eran] [,/SC_FRAME]               $
;                                             [,CUT_RAN=cut_ran] [,/P_ANGLE]                  $
;                                             [,/SUNDIR] [,VECTOR=vec] [,UNITS=units]         $
;                                             [,ESAL_BINS=esalbins] [,ESAH_BINS=esahbins]     $
;                                             [,SST_BINS=sst_bins] [,EX_SUFFX=ex_suffx]       $
;                                             [,LEG_SFFX=leg_sffx] [,ONE_C=one_c]             $
;                                             [,RM_PHOTO_E=rm_photo_e] [,EX_LINE=ex_line]     $
;                                             [,XDAT_ESAL=xdat_esal] [,YDAT_ESAL=ydat_esal]   $
;                                             [,XDAT_ESAH=xdat_esah] [,YDAT_ESAH=ydat_esah]   $
;                                             [,XDAT_SST=xdat_sst] [,YDAT_SST=ydat_sst]       $
;                                             [,XDAT_ALL=xdat_all] [,YDAT_ALL=ydat_all]       $
;                                             [,ONEC_ALL=onec_all]
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
;               EX_SUFFX    :  Scalar [string] defining an extra suffix to attach to the
;                                 PS output file name
;                                 Note:  routine will automatically add '_' before adding
;                                        EX_SUFFX to default file name
;                                 [Default:  '']
;               LEG_SFFX    :  Scalar [string] defining an extra suffix to attach to the
;                                 legend labels for the three cut directions
;                                 Note:  routine will automatically add ' ' before adding
;                                        LEG_SFFX to default legend labels
;                                 [Default:  '']
;               ONE_C       :  If set, routine computes one-count levels as well and
;                                outputs an average on the plot (but returns the full
;                                array of points on output from lbw_spec3d.pro)
;                                [Default = FALSE]
;               RM_PHOTO_E  :  If set, routine will remove data below the spacecraft
;                                potential defined by the structure tag SC_POT and
;                                shift the corresponding energy bins by
;                                CHARGE*SC_POT
;                                [Default = FALSE]
;               EX_LINE     :  Scalar [structure] defining the value and label of an
;                                extra vertical line to output on the final plots.  The
;                                structure must have the following tags:
;                                  NSTR  :  Scalar [string] defining the label
;                                  NVAL  :  Scalar [numeric] defining the value or
;                                             location [eV]
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
;
;   CHANGED:  1)  Continued to write routine
;                                                                   [02/05/2018   v1.0.0]
;             2)  Finished writing routine and added keyword ONEC_ALL
;                                                                   [02/05/2018   v1.0.0]
;
;   NOTES:      
;               1)  This routine is meant to be a wrapper for
;                     plot_esa_sst_combined_spec3d.pro so as to combine plots for both
;                     low and high energy ESAs and SST data into one plot
;               2)  Try to keep the string LEG_SFFX short and simple
;               3)  For Wind 3DP electrons, remember to remove the following solid angle
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
;               9)  Ni, B., Y. Shprits, M. Hartinger, V. Angelopoulos, X. Gu, and
;                      D. Larson "Analysis of radiation belt energetic electron phase
;                      space density using THEMIS SST measurements: Cross‐satellite
;                      calibration and a case study," J. Geophys. Res. 116, A03208,
;                      doi:10.1029/2010JA016104, 2011.
;              10)  Turner, D.L., V. Angelopoulos, Y. Shprits, A. Kellerman, P. Cruce,
;                      and D. Larson "Radial distributions of equatorial phase space
;                      density for outer radiation belt electrons," Geophys. Res. Lett.
;                      39, L09101, doi:10.1029/2012GL051722, 2012.
;
;   CREATED:  02/02/2018
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  02/05/2018   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

PRO plot_esalh_sst_combined_spec3d,dat_esal,dat_esah,dat_sst,                            $
                                   LIM_ESAL=lim_esal,LIM_ESAH=lim_esah,LIM_SST=lim_sst,  $
                                   ESAL_ERAN=esaleran,ESAH_ERAN=esaheran,                $
                                   SST_ERAN=sst_eran,SC_FRAME=sc_frame,                  $
                                   CUT_RAN=cut_ran,P_ANGLE=p_angle,SUNDIR=sundir,        $
                                   VECTOR=vec,UNITS=units,ESAL_BINS=esalbins,            $
                                   ESAH_BINS=esahbins,SST_BINS=sst_bins,                 $
                                   EX_SUFFX=ex_suffx,LEG_SFFX=leg_sffx,ONE_C=one_c,      $
                                   RM_PHOTO_E=rm_photo_e,EX_LINE=ex_line,                $
                                   XDAT_ESAL=xdat_esal,YDAT_ESAL=ydat_esal,              $    ;;  Output
                                   XDAT_ESAH=xdat_esah,YDAT_ESAH=ydat_esah,              $
                                   XDAT_SST=xdat_sst,YDAT_SST=ydat_sst,                  $
                                   XDAT_ALL=xdat_all,YDAT_ALL=ydat_all,                  $
                                   ONEC_ALL=onec_all

;;----------------------------------------------------------------------------------------
;;  Define some constants and dummy variables
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
lim0           = {XSTYLE:1,YSTYLE:1,XMINOR:9,YMINOR:9,XMARGIN:[10,10],YMARGIN:[5,5],XLOG:1,YLOG:1}
vec_cols       = [250,175,100]
vec_coll       = vec_cols
vec_colh       = [225,150, 75]
vec_colt       = [200, 50, 25]
def_esaleran   = [1d0,1.5d3]            ;;  Default ESAL energy range [eV]
def_esaheran   = [10d1,25d3]            ;;  Default ESAH energy range [eV]
def_sst_eran   = [30d0,50d1]*1d3        ;;  Default SST energy range [eV]
dumb_exline    = {NSTR:'',NVAL:0d0}     ;;  Default EX_LINE setting
;;  Define popen structure
popen_str      = {PORT:1,UNITS:'inches',XSIZE:8.5,YSIZE:8.5,ASPECT:1}
;;  Dummy error messages
noinpt_msg     = 'User must supply three velocity distribution functions as IDL structures...'
notstr_msg     = 'DAT_ESAL, DAT_ESAH, and DAT_SST must be IDL structures...'
notvdf_msg     = 'DAT_ESAL, DAT_ESAH, and DAT_SST must be velocity distribution functions as an IDL structures...'
diffsc_msg     = 'DAT_ESAL, DAT_ESAH, and DAT_SST must come from the same spacecraft...'
badvdf_msg     = 'Input must be an IDL structure with similar format to Wind/3DP or THEMIS/ESA...'
;;----------------------------------------------------------------------------------------
;;  Check input
;;----------------------------------------------------------------------------------------
IF (N_PARAMS() LT 2) THEN BEGIN
  MESSAGE,noinpt_msg[0],/INFORMATIONAL,/CONTINUE
  RETURN
ENDIF
test           = (SIZE(dat_esal,/TYPE) NE 8L OR N_ELEMENTS(dat_esal) LT 1) OR $
                 (SIZE(dat_esah,/TYPE) NE 8L OR N_ELEMENTS(dat_esah) LT 1) OR $
                 (SIZE(dat_sst,/TYPE) NE 8L OR N_ELEMENTS(dat_sst) LT 1)
IF (test[0]) THEN BEGIN
  MESSAGE,notstr_msg[0],/INFORMATIONAL,/CONTINUE
  RETURN
ENDIF
;;  Check to make sure distributions have the correct format
test_esa0      = test_wind_vs_themis_esa_struct(dat_esal[0],/NOM)
test_esa1      = test_wind_vs_themis_esa_struct(dat_esah[0],/NOM)
test_sst0      = test_wind_vs_themis_esa_struct(dat_sst[0],/NOM)
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
IF (test_esa0.(0)) THEN BEGIN
  ;;--------------------------------------------------------------------------------------
  ;;  Wind
  ;;--------------------------------------------------------------------------------------
  mission      = 'Wind'
ENDIF ELSE BEGIN
  IF (test_esa0.(1)) THEN BEGIN
    ;;------------------------------------------------------------------------------------
    ;;  THEMIS
    ;;------------------------------------------------------------------------------------
    mission      = 'THEMIS'
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
;;  Check keywords
;;----------------------------------------------------------------------------------------
;;  Check UNITS
test           = (N_ELEMENTS(units) EQ 0) OR (SIZE(units,/TYPE) NE 7)
IF (test[0]) THEN gunits = 'flux' ELSE gunits = units[0]
;;  Check LEG_SFFX
test           = (N_ELEMENTS(leg_sffx) EQ 0) OR (SIZE(leg_sffx,/TYPE) NE 7)
IF (test[0]) THEN legsuffx = '' ELSE legsuffx = leg_sffx[0]
;;  Check ESAL_ERAN, ESAH_ERAN, and SST_ERAN
test           = (test_plot_axis_range(esaleran,/NOMSSG) EQ 0L)
IF (test[0]) THEN eran_esal = def_esaleran ELSE eran_esal = esaleran
test           = (test_plot_axis_range(esaheran,/NOMSSG) EQ 0L)
IF (test[0]) THEN eran_esah = def_esaheran ELSE eran_esah = esaheran
test           = (test_plot_axis_range(sst_eran,/NOMSSG) EQ 0L)
IF (test[0]) THEN eran_sst = def_sst_eran ELSE eran_sst = sst_eran
;;  Check EX_LINE
test           = (N_ELEMENTS(ex_line) EQ 0) OR (SIZE(ex_line,/TYPE) NE 8)
IF (test[0]) THEN BEGIN
  extra_line = dumb_exline
ENDIF ELSE BEGIN
  nlab           = struct_value(ex_line,'NSTR',DEFAULT='',INDEX=indnstr)
  nval           = struct_value(ex_line,'NVAL',DEFAULT=0d0,INDEX=indnval)
  test           = (SIZE(nlab,/TYPE) NE 7) OR (is_a_number(nval,/NOMSSG) EQ 0)
  IF (test[0]) THEN extra_line = dumb_exline ELSE extra_line = {NSTR:nlab[0],NVAL:nval[0]}
ENDELSE
;;----------------------------------------------------------------------------------------
;;  Plot results
;;----------------------------------------------------------------------------------------
;;  Plot E[P]ESA Low with E[P]ESA High
plot_esa_sst_combined_spec3d,dat_esal,dat_esah,LIM_ESA=lim_esal,LIM_SST=lim_esah, $
                             ESA_ERAN=eran_esal,SST_ERAN=eran_esah,             $
                             SC_FRAME=sc_frame,CUT_RAN=cut_ran,P_ANGLE=p_angle, $
                             SUNDIR=sundir,VECTOR=vec,UNITS=units,              $
                             ESA_BINS=esalbins,SST_BINS=esahbins,               $
                             EX_SUFFX=ex_suffx,LEG_SFFX=legsuffx,ONE_C=one_c,   $
                             RM_PHOTO_E=rm_photo_e,EX_LINE=ex_line,             $
                             XDAT_ESA=xdat_esal,YDAT_ESA=ydat_esal,             $    ;;  Output
                             XDAT_SST=xdat_esah,YDAT_SST=ydat_esah,             $
                             XDAT_ALL=xdat_all0,YDAT_ALL=ydat_all0,             $
                             ONEC_ALL=onec_all0,FILE_NAME=fnamelh,PLIMITS=pstrlh
;;  Plot E[P]ESA High with SST Foil[Open]
plot_esa_sst_combined_spec3d,dat_esaH,dat_sst,LIM_ESA=lim_esaH,LIM_SST=lim_sst, $
                             ESA_ERAN=eran_esah,SST_ERAN=eran_sst,              $
                             SC_FRAME=sc_frame,CUT_RAN=cut_ran,P_ANGLE=p_angle, $
                             SUNDIR=sundir,VECTOR=vec,UNITS=units,              $
                             ESA_BINS=esahbins,SST_BINS=sst_bins,               $
                             EX_SUFFX=ex_suffx,LEG_SFFX=legsuffx,ONE_C=one_c,   $
                             RM_PHOTO_E=rm_photo_e,EX_LINE=ex_line,             $
                             XDAT_ESA=xdat_esah,YDAT_ESA=ydat_esah,             $    ;;  Output
                             XDAT_SST=xdat_sst,YDAT_SST=ydat_sst,               $
                             XDAT_ALL=xdat_all1,YDAT_ALL=ydat_all1,             $
                             ONEC_ALL=onec_all1,FILE_NAME=fnamehs,PLIMITS=pstrhs
;;----------------------------------------------------------------------------------------
;;  Open final window for plotting
;;----------------------------------------------------------------------------------------
DEVICE,WINDOW_STATE=w_state
wttles         = mission[0]+' '+['ESAL+ESAH+SST']
w_struc        = {RETAIN:2,XSIZE:800,YSIZE:800,TITLE:wttles[0]}
wnum           = 4L
lbw_window,WIND_N=wnum[0],_EXTRA=w_struc
;;----------------------------------------------------------------------------------------
;;  Define X[Y]-data for plot outputs
;;----------------------------------------------------------------------------------------
xdat_all_esal  = xdat_all0.ESA         ;;  ESAL Energies [eV]
ydat_all_esal  = ydat_all0.ESA         ;;  ESAL Data [UNITS[0]]
xdat_all_esah  = xdat_all0.SST         ;;  ESAH Energies [eV]
ydat_all_esah  = ydat_all0.SST         ;;  ESAH Data [UNITS[0]]
xdat_all_sst   = xdat_all1.SST         ;;  SST  Energies [eV]
ydat_all_sst   = ydat_all1.SST         ;;  SST  Data [UNITS[0]]
;;  Check one-count settings
log_1clh       = 0b
log_1chs       = 0b
test           = (SIZE(onec_all0,/TYPE) EQ 8L)
IF (test[0]) THEN BEGIN
  onec_esal      = onec_all0.ESA       ;;  ESAL one-count levels [UNITS[0]]
  onec_esah      = onec_all0.SST       ;;  ESAH one-count levels [UNITS[0]]
  log_1clh       = 1b
ENDIF
test           = (SIZE(onec_all1,/TYPE) EQ 8L)
IF (test[0]) THEN BEGIN
  onec_sste      = onec_all1.SST       ;;  SST  one-count levels [UNITS[0]]
  log_1chs       = 1b
ENDIF
;;----------------------------------------------------------------------------------------
;;  Define X[Y]DAT_ALL and ONEC_ALL outputs
;;----------------------------------------------------------------------------------------
xdat_all_esa   = [xdat_all_esal,xdat_all_esah]
ydat_all_esa   = [ydat_all_esal,ydat_all_esah]
;xdat_all_esa   = [xdat_all0.ESA,xdat_all0.SST]
;ydat_all_esa   = [ydat_all0.ESA,ydat_all0.SST]
IF (log_1clh[0]) THEN onec_all_esa = [onec_esal,onec_esah] ELSE onec_all_esa = 0
IF (log_1chs[0]) THEN onec_all_sst = onec_sste             ELSE onec_all_sst = 0
xdat_all       = {ESA:xdat_all_esa,SST:xdat_all_sst}
ydat_all       = {ESA:ydat_all_esa,SST:ydat_all_sst}
onec_all       = {ESA:onec_all_esa,SST:onec_all_sst}
;;----------------------------------------------------------------------------------------
;;  Get plot stuff from LIMITS structures
;;----------------------------------------------------------------------------------------
;;  Start with default structure
extract_tags,lim_str,lim0
;;  Get [X,Y]RANGE from LIMITS structures
esa_xran       = struct_value(pstrlh,'XRANGE',INDEX=indexr)
sst_xran       = struct_value(pstrhs,'XRANGE',INDEX=indsxr)
esa_yran       = struct_value(pstrlh,'YRANGE',INDEX=indeyr)
sst_yran       = struct_value(pstrhs,'YRANGE',INDEX=indsyr)
;;  Define [X,Y]RANGE
xran_out       = esa_xran
xran_out[0]    = xran_out[0] < sst_xran[0]
xran_out[1]    = xran_out[1] > sst_xran[1]
yran_out       = esa_yran
yran_out[0]    = yran_out[0] < sst_yran[0]
yran_out[1]    = yran_out[1] > sst_yran[1]
;;  Add [X,Y]RANGE to plot limits structure
str_element,lim_str,'XRANGE',xran_out,/ADD_REPLACE
str_element,lim_str,'YRANGE',yran_out,/ADD_REPLACE
;;  Get tick marks
xtick          = get_power_of_ten_ticks(xran_out)
ytick          = get_power_of_ten_ticks(yran_out)
;;  Add [X,Y]TICKNAME, [X,Y]TICKV, and [X,Y]TICKS to plot limits structure
str_element,lim_str,'YTICKNAME',ytick.YTICKNAME,/ADD_REPLACE
str_element,lim_str,   'YTICKV',   ytick.YTICKV,/ADD_REPLACE
str_element,lim_str,   'YTICKS',   ytick.YTICKS,/ADD_REPLACE
str_element,lim_str,'XTICKNAME',xtick.XTICKNAME,/ADD_REPLACE
str_element,lim_str,   'XTICKV',   xtick.XTICKV,/ADD_REPLACE
str_element,lim_str,   'XTICKS',   xtick.XTICKS,/ADD_REPLACE
;;  Get [,X,Y]TITLE from LIMITS structures
esa_xtle       = struct_value(pstrlh,'XTITLE',INDEX=indext)
esa_ytle       = struct_value(pstrlh,'YTITLE',INDEX=indeyt)
esa_ttle       = struct_value(pstrlh,'TITLE',INDEX=indett)
sst_ttle0      = struct_value(pstrhs,'TITLE',INDEX=indstt)
sst_ttles      = STRSPLIT(sst_ttle0,'!C',/EXTRACT)
p_title        = esa_ttle[0]+'!C'+sst_ttles[1]
;;  Add [,X,Y]TITLE to LIMITS structures
str_element,lim_str,'XTITLE',esa_xtle[0],/ADD_REPLACE
str_element,lim_str,'YTITLE',esa_ytle[0],/ADD_REPLACE
str_element,lim_str, 'TITLE', p_title[0],/ADD_REPLACE
;;  Get file name
esa_fnames     = STRSPLIT(fnamelh,'para-',/EXTRACT,/REGEX)
sst_fnames     = STRSPLIT(fnamehs,'_sfb-',/EXTRACT,/REGEX)
fname          = esa_fnames[0]+'sfb-'+sst_fnames[1]
;;  Define fsuffx
temp           = STRSPLIT(fnamelh,'_',/EXTRACT)
fsuffx         = '_'+temp[N_ELEMENTS(temp) - 1L]
;;----------------------------------------------------------------------------------------
;;  Define power-law lines
;;----------------------------------------------------------------------------------------
fo_facs        = [1d0,1d1,1d1]
IF (gunits[0] EQ 'df') THEN fo_facs = [1d-2,1d-1,1d0]
f_at_xo        = yran_out[1]
a_o_2          = f_at_xo[0]*(xran_out[0])^2*fo_facs[0]
a_o_3          = f_at_xo[0]*(xran_out[0])^3*fo_facs[1]
a_o_4          = f_at_xo[0]*(xran_out[0])^4*fo_facs[2]

fplaw_2        = a_o_2[0]*xran_out^(-2d0)        ;;  f(E) ~ E^(-2)
fplaw_3        = a_o_3[0]*xran_out^(-3d0)        ;;  f(E) ~ E^(-3)
fplaw_4        = a_o_4[0]*xran_out^(-4d0)        ;;  f(E) ~ E^(-4)
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Plot combined spectra
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
legends        = ['Para.','Perp.','Anti.']+' Avg.: '+STRMID(fsuffx[0],1)+' '+legsuffx[0]
leg_fpl        = ['Dashed:  f(E) ~ E^(-2)','Dash-Dot:  f(E) ~ E^(-3)','Dash-Dot-Dot:  f(E) ~ E^(-4)']
plw_cols       = [ 30, 125, 200]
xyfacs         = [55d-2,105d-2,35d-2]
xposi          = [0.12,0.15]
yposi          = [0.34,0.31,0.28,0.24,0.21,0.18]
thck           = 2.0
psyml          = 4                      ;;  diamond symbol
psymh          = 5                      ;;  triangle symbol
psyms          = 6                      ;;  square symbol
;psym           = -6                     ;;  square symbol and connect points with solid lines
symz           = 2.0
lsty           = [1L,2L,3L,4L]          ;;  LINESTYLE values
ecol           = [200L,100L, 30L]       ;;  COLOR values
;;  Define some parameters for XYOUTS
xxloc          = [xyfacs[0]*eran_esal[1],xyfacs[0]*eran_esah[0],xyfacs[1]*eran_sst[0],xyfacs[1]*extra_line.NVAL[0]]
yyloc          = [xyfacs[2]*yran_out[1],xyfacs[2]*yran_out[1],xyfacs[2]*yran_out[1],xyfacs[2]*yran_out[1]]
vllab          = ['ESAL','ESAH','SST',extra_line.NSTR[0]]
align          = 0
;;  Define some parameters for XYOUTS
WSET,wnum[0]
WSHOW,wnum[0]
;;----------------------------------------------------------------------------------------
;;  Initialize Plot
;;----------------------------------------------------------------------------------------
PLOT,xdat_all_esa[*,0],ydat_all_esa[*,0],/NODATA,_EXTRA=lim_str
  FOR j=0L, 2L DO BEGIN
    ;;------------------------------------------------------------------------------------
    ;;  Plot EESA data
    ;;------------------------------------------------------------------------------------
    OPLOT,xdat_all_esal[*,j],ydat_all_esal[*,j],COLOR=vec_coll[j],PSYM=psyml[0],SYMSIZE=symz[0],THICK=thck[0]
    OPLOT,xdat_all_esah[*,j],ydat_all_esah[*,j],COLOR=vec_colh[j],PSYM=psymh[0],SYMSIZE=symz[0],THICK=thck[0]
    ;;------------------------------------------------------------------------------------
    ;;  Plot SSTe data
    ;;------------------------------------------------------------------------------------
    OPLOT,xdat_all_sst[*,j],ydat_all_sst[*,j],COLOR=vec_colt[j],PSYM=psyms[0],SYMSIZE=symz[0],THICK=thck[0]
    ;;------------------------------------------------------------------------------------
    ;;  Plot one-count data
    ;;------------------------------------------------------------------------------------
    IF (log_1clh[0]) THEN BEGIN
      OPLOT,xdat_all_esal[*,j],onec_esal[*,j],COLOR=vec_coll[j],LINESTYLE=lsty[0]
      OPLOT,xdat_all_esaH[*,j],onec_esaH[*,j],COLOR=vec_colh[j],LINESTYLE=lsty[1]
    ENDIF
    IF (log_1chs[0]) THEN OPLOT,xdat_all_sst[*,j],onec_sste[*,j],COLOR=vec_colt[j],LINESTYLE=lsty[2]
  ENDFOR
  ;;--------------------------------------------------------------------------------------
  ;;  Plot energy range limits
  ;;--------------------------------------------------------------------------------------
  OPLOT,[eran_esal[0],eran_esal[0]],yran_out,COLOR=ecol[0],LINESTYLE=lsty[1]
  OPLOT,[eran_esal[1],eran_esal[1]],yran_out,COLOR=ecol[0],LINESTYLE=lsty[1]
  OPLOT,[eran_esah[0],eran_esah[0]],yran_out,COLOR=ecol[1],LINESTYLE=lsty[2]
  OPLOT,[eran_esah[1],eran_esah[1]],yran_out,COLOR=ecol[1],LINESTYLE=lsty[2]
  OPLOT,[ eran_sst[0], eran_sst[0]],yran_out,COLOR=ecol[2],LINESTYLE=lsty[3]
  OPLOT,[ eran_sst[1], eran_sst[1]],yran_out,COLOR=ecol[2],LINESTYLE=lsty[3]
  ;;--------------------------------------------------------------------------------------
  ;;  Output power-laws
  ;;--------------------------------------------------------------------------------------
  OPLOT,xran_out,fplaw_2,LINESTYLE=lsty[1],THICK=thck[0],COLOR=plw_cols[0]
  OPLOT,xran_out,fplaw_3,LINESTYLE=lsty[2],THICK=thck[0],COLOR=plw_cols[1]
  OPLOT,xran_out,fplaw_4,LINESTYLE=lsty[3],THICK=thck[0],COLOR=plw_cols[2]
  ;;--------------------------------------------------------------------------------------
  ;;  Output EX_LINE
  ;;--------------------------------------------------------------------------------------
  OPLOT,[extra_line.NVAL[0],extra_line.NVAL[0]],yran_out,COLOR=ecol[2],LINESTYLE=lsty[1],THICK=thck[0]
  ;;--------------------------------------------------------------------------------------
  ;;  Output legend
  ;;--------------------------------------------------------------------------------------
  XYOUTS,xxloc[0],yyloc[0],vllab[0],COLOR=ecol[0],/DATA,ALIGNMENT=align[0]                    ;;  ESAL energy range labels
  XYOUTS,xxloc[1],yyloc[1],vllab[1],COLOR=ecol[1],/DATA,ALIGNMENT=align[0]                    ;;  ESAH energy range labels
  XYOUTS,xxloc[2],yyloc[2],vllab[2],COLOR=ecol[2],/DATA,ALIGNMENT=align[0]                    ;;  SST  energy range labels
  OPLOT,[xxloc[0]],[yyloc[0]*0.65],COLOR=ecol[0],PSYM=psyml[0],SYMSIZE=symz[0],THICK=thck[0]  ;;  ESAL Symbol
  OPLOT,[xxloc[1]],[yyloc[1]*0.65],COLOR=ecol[1],PSYM=psymh[0],SYMSIZE=symz[0],THICK=thck[0]  ;;  ESAH Symbol
  OPLOT,[xxloc[2]],[yyloc[2]*0.65],COLOR=ecol[2],PSYM=psyms[0],SYMSIZE=symz[0],THICK=thck[0]  ;;  SST  Symbol
  XYOUTS,xposi[0],yposi[0],legends[0],COLOR=vec_cols[0],/NORMAL,ALIGNMENT=align[0]            ;;  Para label
  XYOUTS,xposi[0],yposi[1],legends[1],COLOR=vec_cols[1],/NORMAL,ALIGNMENT=align[0]            ;;  Perp label
  XYOUTS,xposi[0],yposi[2],legends[2],COLOR=vec_cols[2],/NORMAL,ALIGNMENT=align[0]            ;;  Anti label
  XYOUTS,xposi[0],yposi[3],leg_fpl[0],COLOR=plw_cols[0],/NORMAL,ALIGNMENT=align[0]            ;;  f(E) ~ E^(-2) label
  XYOUTS,xposi[0],yposi[4],leg_fpl[1],COLOR=plw_cols[1],/NORMAL,ALIGNMENT=align[0]            ;;  f(E) ~ E^(-3) label
  XYOUTS,xposi[0],yposi[5],leg_fpl[2],COLOR=plw_cols[2],/NORMAL,ALIGNMENT=align[0]            ;;  f(E) ~ E^(-4) label

;;----------------------------------------------------------------------------------------
;;  Save plot of combined spectra
;;----------------------------------------------------------------------------------------
thck           = 3.0
symz           = 1.0
popen,fname[0],_EXTRA=popen_str
  ;;--------------------------------------------------------------------------------------
  ;;  Initialize Plot
  ;;--------------------------------------------------------------------------------------
  PLOT,xdat_all_esa[*,0],ydat_all_esa[*,0],/NODATA,_EXTRA=lim_str
    FOR j=0L, 2L DO BEGIN
      ;;----------------------------------------------------------------------------------
      ;;  Plot EESA data
      ;;----------------------------------------------------------------------------------
      OPLOT,xdat_all_esal[*,j],ydat_all_esal[*,j],COLOR=vec_coll[j],PSYM=psyml[0],SYMSIZE=symz[0],THICK=thck[0]
      OPLOT,xdat_all_esah[*,j],ydat_all_esah[*,j],COLOR=vec_colh[j],PSYM=psymh[0],SYMSIZE=symz[0],THICK=thck[0]
      ;;----------------------------------------------------------------------------------
      ;;  Plot SSTe data
      ;;----------------------------------------------------------------------------------
      OPLOT,xdat_all_sst[*,j],ydat_all_sst[*,j],COLOR=vec_colt[j],PSYM=psyms[0],SYMSIZE=symz[0],THICK=thck[0]
      ;;----------------------------------------------------------------------------------
      ;;  Plot one-count data
      ;;----------------------------------------------------------------------------------
      IF (log_1clh[0]) THEN BEGIN
        OPLOT,xdat_all_esal[*,j],onec_esal[*,j],COLOR=vec_coll[j],LINESTYLE=lsty[0]
        OPLOT,xdat_all_esaH[*,j],onec_esaH[*,j],COLOR=vec_colh[j],LINESTYLE=lsty[1]
      ENDIF
      IF (log_1chs[0]) THEN OPLOT,xdat_all_sst[*,j],onec_sste[*,j],COLOR=vec_colt[j],LINESTYLE=lsty[2]
    ENDFOR
    ;;------------------------------------------------------------------------------------
    ;;  Plot energy range limits
    ;;------------------------------------------------------------------------------------
    OPLOT,[eran_esal[0],eran_esal[0]],yran_out,COLOR=ecol[0],LINESTYLE=lsty[1]
    OPLOT,[eran_esal[1],eran_esal[1]],yran_out,COLOR=ecol[0],LINESTYLE=lsty[1]
    OPLOT,[eran_esah[0],eran_esah[0]],yran_out,COLOR=ecol[1],LINESTYLE=lsty[2]
    OPLOT,[eran_esah[1],eran_esah[1]],yran_out,COLOR=ecol[1],LINESTYLE=lsty[2]
    OPLOT,[ eran_sst[0], eran_sst[0]],yran_out,COLOR=ecol[2],LINESTYLE=lsty[3]
    OPLOT,[ eran_sst[1], eran_sst[1]],yran_out,COLOR=ecol[2],LINESTYLE=lsty[3]
    ;;------------------------------------------------------------------------------------
    ;;  Output power-laws
    ;;------------------------------------------------------------------------------------
    OPLOT,xran_out,fplaw_2,LINESTYLE=lsty[1],THICK=thck[0],COLOR=plw_cols[0]
    OPLOT,xran_out,fplaw_3,LINESTYLE=lsty[2],THICK=thck[0],COLOR=plw_cols[1]
    OPLOT,xran_out,fplaw_4,LINESTYLE=lsty[3],THICK=thck[0],COLOR=plw_cols[2]
    ;;------------------------------------------------------------------------------------
    ;;  Output EX_LINE
    ;;------------------------------------------------------------------------------------
    OPLOT,[extra_line.NVAL[0],extra_line.NVAL[0]],yran_out,COLOR=ecol[2],LINESTYLE=lsty[1],THICK=thck[0]
    ;;------------------------------------------------------------------------------------
    ;;  Output legend
    ;;------------------------------------------------------------------------------------
    XYOUTS,xxloc[0],yyloc[0],vllab[0],COLOR=ecol[0],/DATA,ALIGNMENT=align[0]                    ;;  ESAL energy range labels
    XYOUTS,xxloc[1],yyloc[1],vllab[1],COLOR=ecol[1],/DATA,ALIGNMENT=align[0]                    ;;  ESAH energy range labels
    XYOUTS,xxloc[2],yyloc[2],vllab[2],COLOR=ecol[2],/DATA,ALIGNMENT=align[0]                    ;;  SST energy range labels
    OPLOT,[xxloc[0]],[yyloc[0]*0.65],COLOR=ecol[0],PSYM=psyml[0],SYMSIZE=symz[0],THICK=thck[0]  ;;  ESAL Symbol
    OPLOT,[xxloc[1]],[yyloc[1]*0.65],COLOR=ecol[1],PSYM=psymh[0],SYMSIZE=symz[0],THICK=thck[0]  ;;  ESAH Symbol
    OPLOT,[xxloc[2]],[yyloc[2]*0.65],COLOR=ecol[2],PSYM=psyms[0],SYMSIZE=symz[0],THICK=thck[0]  ;;  SST  Symbol
    XYOUTS,xposi[0],yposi[0],legends[0],COLOR=vec_cols[0],/NORMAL,ALIGNMENT=align[0]            ;;  Para label
    XYOUTS,xposi[0],yposi[1],legends[1],COLOR=vec_cols[1],/NORMAL,ALIGNMENT=align[0]            ;;  Perp label
    XYOUTS,xposi[0],yposi[2],legends[2],COLOR=vec_cols[2],/NORMAL,ALIGNMENT=align[0]            ;;  Anti label
    XYOUTS,xposi[0],yposi[3],leg_fpl[0],COLOR=plw_cols[0],/NORMAL,ALIGNMENT=align[0]            ;;  f(E) ~ E^(-2) label
    XYOUTS,xposi[0],yposi[4],leg_fpl[1],COLOR=plw_cols[1],/NORMAL,ALIGNMENT=align[0]            ;;  f(E) ~ E^(-3) label
    XYOUTS,xposi[0],yposi[5],leg_fpl[2],COLOR=plw_cols[2],/NORMAL,ALIGNMENT=align[0]            ;;  f(E) ~ E^(-4) label
pclose
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN
END

















Last Modification =>  2010-03-03/18:28:41 UTC
;+
;*****************************************************************************************
;
;  FUNCTION :   add_df2d_to_ph.pro
;  PURPOSE  :   Calculates an estimate of the reduced distribution function and adds
;                 the tags to the input data structure.
;
;  CALLED BY:   NA
;
;  CALLS:
;               dat_3dp_str_names.pro
;               cart_to_sphere.pro
;               cal_rot.pro
;               str_element.pro
;               data_velocity_transform.pro
;
;  REQUIRES:    NA
;
;  INPUT:
;               DAT        :  3DP data structure either from get_eh.pro etc.
;
;  EXAMPLES:
;
;  KEYWORDS:  
;               VLIM       :  Limit for x-y velocity axes over which to plot data
;                               [Default = max vel. from energy bin values]
;               NGRID      :  # of isotropic velocity grids to use to triangulate the data
;                               [Default = 50L]
;               VBROT      :  Set to a named variable to return the rotation matrix used to
;                               rotate the velocities into the Vector1 x Vector2 plane
;               VECTOR1    :  3-Element vector to be used for parallel axis 
;                               [Default = dat.MAGF or Magnetic Field Vector]
;               VECTOR2    :  3-Element vector to be used to define the plane made with 
;                               VECTOR1  [Default = dat.VSW or Solar Wind Velocity]
;               NSMOOTH    :  Scalar # of points over which to smooth the DF
;                               [Default = 3]
;               VXB_PLANE  :  If set, tells program to plot the DF in the plane defined
;                               by the (V x B) and B x (V x B) directions
;                               [Default:  plane defined by V and B directions set by
;                                           VSW and MAGF structure tags of DAT]
;
;   CHANGED:  1)  Added tag name BDIR to output structure     [03/25/2009   v1.0.1]
;             2)  Fixed syntax error with vel2dx variable     [03/25/2009   v1.0.2]
;             3)  Added keyword:  VBROT and changed default # of grids
;                                                             [03/26/2009   v1.0.3]
;             4)  Changed the triangulation points            [04/08/2009   v1.0.4]
;             5)  Changed tags added to structure to include actual points where
;                   data was calculated for house keeping and honesty
;                                                             [04/08/2009   v1.0.5]
;             6)  Changed bad bin indexing                    [04/08/2009   v1.0.6]
;             7)  Fixed "glitch" with 56 bin PH structures    [04/08/2009   v1.0.7]
;             8)  Changed bad bin indexing to include the "mirror" bins of the original
;                   bad data bins                             [04/16/2009   v1.0.8]
;             9)  Fixed "glitch" with 97 bin PH structures    [04/26/2009   v1.0.9]
;            10)  Added program:  my_pesa_high_bad_bins.pro   [04/26/2009   v1.1.0]
;            11)  Eliminated the statements that removed the thermal core for 
;                   the distribution cuts (parallel/perp.) and changed calling of
;                   my_velocity.pro to velocity.pro           [06/21/2009   v1.1.1]
;            12)  Added keywords:  VECTOR1 and VECTOR2        [06/24/2009   v1.2.0]
;            13)  Added program:  data_velocity_transform.pro [06/24/2009   v2.0.0]
;            14)  Changed program my_str_names.pro to dat_3dp_str_names.pro
;                                                             [08/05/2009   v2.1.0]
;            15)  Updated man page                            [08/07/2009   v2.1.1]
;            16)  Updated man page                            [08/10/2009   v2.1.2]
;            17)  Added keyword:  NSMOOTH                     [08/27/2009   v2.1.3]
;            18)  Changed minor syntax issue                  [08/31/2009   v2.1.4]
;            19)  Added error handling to deal with situations where dat.VSW or
;                   dat.MAGF were either all = 0.0 or = !VALUES.F_NAN
;                                                             [09/23/2009   v2.1.5]
;            20)  Added keyword:  VXB_PLANE                   [03/03/2010   v2.2.0]
;
;   NOTES:      
;               1)  Make sure that the structure tags MAGF and VSW have finite 
;                    values
;               2)  This program is adapted from software by K. Meziane
;
;   CREATED:  03/24/2009
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  03/03/2010   v2.2.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-


Last Modification =>  2009-08-05/13:53:02 UTC
;+
;*****************************************************************************************
;
;  FUNCTION :   add_df2dp_2.pro
;  PURPOSE  :   Adds 2D pitch angle distribution (df2d, vx2d, vy2d) to a 3d structure
;                 and it also adds dat.df2dz, dat.vx2dz, dat.vy2dz to dat structure.
;                 
;                 Definitions:
;                 1)  df2d, vx2d and vy2d are the interpolated two dimensional 
;                       distribution function and velocity in the x-y plane.
;                 2)  df2d is generated from df by folding pitch angles with vy > 0
;                       and vy < 0 to opposite sides of vy in df2d to allow some
;                       measure of non-gyrotropic distributions.
;                 3)  df2dz, vx2dz and vy2dz are interpolated to the x-z plane.
;                 4)  "x" is along the magnetic field, the "x-y" plane is defined
;                       to contain the magnetic field and the drift velocity,
;                       and the reference frame is transformed to the drift frame.
;
;  CALLED BY: 
;               my_cont2d.pro
;               my_cont3d.pro
;
;  CALLS:
;               conv_units.pro
;               str_element.pro
;               velocity.pro
;               sphere_to_cart.pro
;               rot_mat.pro
;               cart_to_sphere.pro
;
;  REQUIRES:    NA
;
;  INPUT:
;               DAT     :  3DP data structure either from spec plots 
;                            (i.e. get_padspec.pro) or from pad.pro, get_el.pro, 
;                            get_sf.pro, etc.
;
;  EXAMPLES:    NA
;
;  KEYWORDS:  
;               VLIM    :  Limit for x-y velocity axes over which to plot data
;                            [Default = max vel. from energy bin values]
;               NGRID   :  # of isotropic velocity grids to use to triangulate the data
;                            [Default = 50L]
;               MINCNT  :  If present, this min count level gets added to all angle
;                            bins to smooth out noisy contour plots
;                            [Default = 0]
;
;   CHANGED:  1)  Original program created by Davin         [08/10/1995   v1.0.0]
;             2)  Modified by J.P. McFadden                 [09/15/1995   v1.1.0]
;             3)  Changed minor syntax and indexing issues  [12/31/2007   v1.1.1]
;             4)  Rewrote entire program                    [03/22/2009   v1.2.0]
;             5)  Changed program my_velocity.pro to velocity.pro
;                                                           [08/05/2009   v1.3.0]
;
;   ADAPTED FROM:   add_df2dp.pro  BY:  Davin Larson
;   CREATED:  10/08/1995
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  08/05/2009   v1.3.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-


Last Modification =>  2009-08-28/12:42:00 UTC
;+
;*****************************************************************************************
;
;  FUNCTION :   add_magf2.pro
;  PURPOSE  :   Adds the magnetic field vector (nT) to an array of 3DP data
;                 structures obtained from get_??.pro (e.g. ?? = el, eh, sf, phb, etc.)
;                 with the tag name MAGF.  This program is vectorized and at least
;                 an order of magnitude faster than add_magf.pro for inputs being
;                 arrays of 3DP data structures.
;
;  CALLED BY:   NA
;
;  CALLS:
;               get_data.pro
;               interp.pro
;
;  REQUIRES:    
;               Magnetic field data must be loaded first...
;
;  INPUT:
;               DAT    :  An array of 3DP data structures
;               SOURCE :  A string or TPLOT data structure specifying the data to use for
;                           magnetic field vector (nT) estimates
;                           [TPLOT Structure Format:  {X:(N-Unix Times),Y:[N,3]-Vectors}]
;
;  EXAMPLES:
;               elb = my_3dp_str_call_2('elb',TRANGE=tr)
;               de  = elb.DATA
;               add_scpot,de,'wi_B3(GSE)'
;
;  KEYWORDS:    NA
;
;   CHANGED:  1)  Rewrote entire program to vectorize as many operations as possible
;                   for increased speed                        [11/06/2008   v2.0.0]
;             2)  Changed function INTERPOL.PRO to interp.pro  [11/07/2008   v2.0.1]
;             3)  Updated man page                             [06/17/2009   v2.0.2]
;             4)  Rewrote to optimize a few parts and clean up some cludgy parts
;                                                              [06/22/2009   v2.1.0]
;             5)  Changed a little syntax                      [08/28/2009   v2.1.1]
;
;   ADAPTED FROM: add_magf.pro  BY: Davin Larson
;   CREATED:  04/27/2008
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  08/28/2009   v2.1.1
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-


Last Modification =>  2009-08-28/12:34:59 UTC
;+
;*****************************************************************************************
;
;  FUNCTION :   add_scpot.pro
;  PURPOSE  :   Adds the spacecraft potential (eV) to an array of 3DP data structures
;                 obtained from get_??.pro (e.g. ?? = el, eh, sf, phb, etc.)
;                 with the tag name SC_POT.
;
;  CALLED BY:   NA
;
;  CALLS:
;               get_data.pro
;               interp.pro   By:  Davin Larson
;
;  REQUIRES:    Proton/Ion moments must be loaded first with associated TPLOT variables
;                 or data structure to use to estimate the spacecraft potential
;
;
;  INPUT:
;               DAT    :  An array of 3DP data structures
;               SOURCE :  A string or 3DP data structure specifying the data to use for
;                           spacecraft potential estimates
;                           [TPLOT Structure Format:  {X:(N-Unix Times),Y:[N]-Scalars}]
;
;  EXAMPLES:
;               elb = my_3dp_str_call_2('elb',TRANGE=tr)
;               de  = elb.DATA
;               add_scpot,de,'sc_pot'  ; -If 'sc_pot' is a TPLOT variable
;
;  KEYWORDS:    NA
;
;   CHANGED:  1)  Rewrote entire program to resemble add_magf2.pro
;                   for increased speed                        [11/06/2008   v2.0.0]
;             2)  Changed function INTERPOL.PRO to interp.pro  [11/07/2008   v2.0.1]
;             3)  Updated man page                             [06/17/2009   v2.0.2]
;             4)  Rewrote to optimize a few parts and clean up some cludgy parts
;                                                              [06/22/2009   v2.1.0]
;             5)  Changed a little syntax                      [07/13/2009   v2.1.1]
;             6)  Fixed a syntax error                         [07/13/2009   v2.1.2]
;             7)  Changed a little syntax                      [08/28/2009   v2.1.3]
;
;   ADAPTED FROM: add_magf.pro and add_vsw.pro  BY: Davin Larson
;   CREATED:  04/27/2008
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  08/28/2009   v2.1.3
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-


Last Modification =>  2009-08-28/12:28:19 UTC
;+
;*****************************************************************************************
;
;  FUNCTION :   add_vsw2.pro
;  PURPOSE  :   Adds the solar wind velocity vector (km/s) to an array of 3DP data
;                 structures obtained from get_??.pro (e.g. ?? = el, eh, sf, phb, etc.)
;                 with the tag name VSW.
;
;  CALLED BY:   NA
;
;  CALLS:
;               get_data.pro
;               interp.pro   By:  Davin Larson
;
;  REQUIRES:    Proton/Ion moments must be loaded first with associated TPLOT variables
;                 or data structure to use as the solar wind velocity
;
;  INPUT:
;               DAT    :  An array of 3DP data structures
;               SOURCE :  A string or TPLOT data structure specifying the data to use for
;                           solar wind velocity estimates
;                           [TPLOT Structure Format:  {X:(N-Unix Times),Y:[N,3]-Vectors}]
;
;  EXAMPLES:
;               elb = my_3dp_str_call_2('elb',TRANGE=tr)
;               de  = elb.DATA
;               add_scpot,de,'Vp'
;
;  KEYWORDS:    NA
;
;   CHANGED:  1)  Rewrote entire program to resemble add_magf2.pro
;                   for increased speed                        [11/06/2008   v2.0.0]
;             2)  Changed function INTERPOL.PRO to interp.pro  [11/07/2008   v2.0.1]
;             3)  Updated man page                             [06/17/2009   v2.0.2]
;             4)  Rewrote to optimize a few parts and clean up some cludgy parts
;                                                              [06/22/2009   v2.1.0]
;             5)  Fixed syntax error                           [08/28/2009   v2.1.1]
;
;   ADAPTED FROM: add_vsw.pro  BY: Davin Larson
;   CREATED:  04/27/2008
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  08/28/2009   v2.1.1
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-


Last Modification =>  2011-03-26/01:20:23 UTC
;+
;*****************************************************************************************
;
;  FUNCTION :  array_where.pro
;  PURPOSE  :  This program finds the good elements of two different arrays which do not
;                 share the same number of elements but have overlapping values (i.e.
;                 x = findgen(20), y = [1.,5.,7.,35.], => find which elements of 
;                 each match... x_el = [1,6,8], y_el = [0,1,2]).  This is good when
;                 the WHERE.PRO function doesn't work well (e.g. two different 
;                 arrays with different numbers of elements but containing
;                 overlapping values of interest).  The program will also return the
;                 complementary elements for each array if desired.
;
;  CALLED BY:   
;               NA
;
;  CALLS:       
;               NA
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               ARR1      :  N-Element array of type S
;               ARR2      :  M-Element array of type S(+/-1,0)
;                              [Note:  S = the type code and can be 2-5 or 7]
;
;  EXAMPLES:
;               x = findgen(20)
;               y = [1.,5.,7.,35.]
;               gtest = array_where(x,y)
;               print, gtest
;                    1           5           7
;                    0           1           2
;
;  KEYWORDS:  
;               NGOOD     :  Set to a named variable to return the number of 
;                              matching values
;               N_UNIQ    :  If set, program will NOT find just the unique elements of
;                              the arrays in question
;               NCOMP1    :  Set to a named variable to return the complementary 
;                              elements to that of the (my_array_where(x,y))[*,0]
;               NCOMP2    :  Set to a named variable to return the complementary 
;                              elements to that of the (my_array_where(x,y))[*,1]
; **Obselete**  NO_UNIQ1  :  If set, program will not find ONLY the unique elements of
;                              the first array in question
; **Obselete**  NO_UNIQ1  :  If set, program will not find ONLY the unique elements of
;                              the second array in question
;
;   CHANGED:  1)  Added keywords:  NO_UNIQ[1,2]            [04/27/2009   v1.0.1]
;             2)  Rewrote and removed cludgy code          [04/28/2009   v2.0.0]
;             3)  Fixed syntax issue for strings           [04/29/2009   v2.0.1]
;             4)  Got rid of separate unique keyword calling reducing to only one
;                   keyword:  NO_UNIQ                      [06/15/2009   v3.0.0]
;             5)  Added keywords:  NCOMP1 and NCOMP2       [09/29/2009   v3.1.0]
;             6)  Changed place where unique elements are determined... alters results
;                                                          [10/22/2009   v3.2.0]
;             7)  Fixed a rare indexing issue (only occurred once in over 100
;                   different runs on varying input)       [02/19/2010   v3.2.1]
;             8)  Vectorized with help from program where_array.pro written by
;                   Stephen Strebel 07/30/1994 and changed name to array_where.pro
;                                                          [10/22/2010   v4.0.0]
;             9)  Added default definitions for NCOMP1 and NCOMP2 when no overlapping
;                   elements exist                         [03/25/2011   v4.1.0]
;
;   NOTES:      
;               1)  It is rarely the case that you don't want to set the keyword N_UNIQ
;
;   CREATED:  04/27/2009
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  03/25/2011   v4.1.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-


Last Modification =>  2011-04-25/13:01:29 UTC
;+
;*****************************************************************************************
;
;  FUNCTION :   calc_padspecs.pro
;  PURPOSE  :   Creates particle spectra "TPLOT" variables by summing 3DP data over
;                 selected angle bins.  The output is a series of TPLOT variables
;                 including the raw data (e.g. 'nel_pads'), pitch-angle separated
;                 data (e.g. 'nel_pads-2-0:1'), smoothed/cleaned pitch-angle separated
;                 data (e.g. 'nel_pads-2-0:1_cln'), and shifted&normalized pitch-angle
;                 separated data (e.g. 'nel_pads-2-0:1_cln_shn').
;
;  CALLED BY:   
;               NA
;
;  CALLS:
;               dat_3dp_str_names.pro
;               wind_3dp_units.pro
;               get_padspecs.pro
;               energy_params_3dp.pro
;               get_data.pro
;               dat_3dp_energy_bins.pro
;               store_data.pro
;               options.pro
;               my_3dp_plot_labels.pro
;               reduce_pads.pro
;               clean_spec_spikes.pro
;               spec_vec_data_shift.pro
;               omni_z_pads.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               NAME       :  [string] Specify the type of structure you wish to 
;                               get the data for [i.e. 'el','eh','elb',etc.]
;
;  EXAMPLES:
;               elbspec = calc_padspecs('elb',TRANGE=tr)
;
;  KEYWORDS:  
;               EBINS      :  [array,scalar] specifying which energy bins to create 
;                               particle spectra plots for
;               VSW        :  [string,tplot index] specifying a solar wind velocity
;               TRANGE     :  [Double] 2 element array specifying the range over 
;                               which to get data structures for
;               DAT_ARR    :  N-Element array of data structures from get_??.pro
;                               [?? = 'el','eh','elb',etc.]
;               DAT_SHFT   :  If set, new TPLOT variables are created of the data shifted
;                               vertically on the Y-Axis to avoid overlaps (for easier
;                               viewing of data)
;               DAT_NORM   :  If set, new TPLOT variables are created of the data shifted
;                               and normalized [Note:  If this keyword is set, it
;                               overrides the DAT_SHFT keyword]
;               DAT_CLN    :  If set, new TPLOT variables are created of the data smoothed
;                               over a width determined by the type of data (i.e. 'el'
;                               needs less smoothing than 'sf') and the number of data
;                               points
;               G_MAGF     :  If set, tells program that the structures in DAT_ARR 
;                               already have the magnetic field added to them thus 
;                               preventing this program from calling add_magf2.pro 
;                               again.
;               NUM_PA     :  Number of pitch-angles to sum over 
;                               [Default = defined by instrument]
;               UNITS      :  Wind/3DP data units for particle data include:
;                               'df','counts','flux','eflux',etc.
;                                [Default = 'flux']
;               RANGE_AVG  :  Two element double array specifying the time range
;                               (Unix time) to use for constructing an average to
;                               normalize the data by when using the keyword DAT_NORM
;               NO_KILL    :  If set, get_padspecs.pro will NOT call the routine
;                               sst_foil_bad_bins.pro
;
;   CHANGED:  1)  Altered return TPLOT variables             [07/10/2008   v1.2.31]
;             2)  Updated man page                           [03/18/2009   v1.2.32]
;             3)  Added keyword:  DAT_ARR                    [04/24/2009   v1.3.0]
;             4)  Added keywords: DAT_SHFT, DAT_NORM, and DAT_CLN
;                                                            [04/24/2009   v1.3.1]
;             5)  Added keyword:  G_MAGF                     [04/26/2009   v1.3.2]
;             6)  Changed program my_str_names.pro to dat_3dp_str_names.pro
;                   and my_3dp_energy_bins.pro to dat_3dp_energy_bins.pro
;                   and my_energy_params.pro to energy_params_3dp.pro
;                   and my_get_padspec_5.pro to get_padspecs.pro
;                   and renamed from my_padspec_4.pro        [08/11/2009   v2.1.0]
;             7)  Changed program my_clean_spikes_2.pro to clean_spec_spikes.pro
;                   and my_data_shift_2.pro to spec_vec_data_shift.pro
;                   and added keyword:  NUM_PA
;                   and z_pads_2.pro to omni_z_pads.pro      [08/12/2009   v2.2.0]
;             8)  Fixed syntax error                         [09/09/2009   v2.2.1]
;             9)  Added keywords:  UNITS and RANGE_AVG
;                   and now depends on wind_3dp_units.pro    [09/30/2009   v2.3.0]
;            10)  Fixed typo in calling get_data.pro and added keyword:
;                   NO_KILL                                  [08/13/2010   v2.3.1]
;            11)  Forgot to actually add RANGE_AVG to calling sequence
;                                                            [11/01/2010   v2.4.0]
;            12)  Fixed a typo with EBINS                    [04/25/2011   v2.4.1]
;
;   CREATED:  ??/??/????
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  04/25/2011   v2.4.1
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-


Last Modification =>  2009-10-08/15:21:50 UTC
;+
;*****************************************************************************************
;
;  FUNCTION :   clean_spec_spikes.pro
;  PURPOSE  :   Removes data spikes and smooths out the result by smoothing and
;                 interpolating spectra data gaps.
;
;  CALLED BY:   NA
;
;  CALLS:
;               get_data.pro
;               ytitle_tplot.pro
;               store_data.pro
;               dat_3dp_energy_bins.pro
;               tnames.pro
;               ylim.pro
;
;  REQUIRES:    NA
;
;  INPUT:
;               NAME      :  [String] A defined TPLOT variable name with associated spectra
;                              data separated by pitch-angle as TPLOT variables
;                              [e.g. 'nelb_pads']
;
;  EXAMPLES:
;            clean_spec_spikes,'nsf_pads',NSMOOTH=5,ESMOOTH=[0,2,12],NEW_NAME='nsf_test'
;               => results are smoothed over 5 data points for every energy except
;                  3 highest energies are smoothed over 12 points
;
;  KEYWORDS:  
;               NEW_NAME  :  New string name for returned TPLOT variable
;               NSMOOTH   :  # of data points to smooth over (default = 3)
;               THRESH    :  Old keyword from original version
;               ESMOOTH   :  Array for weighted smoothing (e.g. [0,2,10]) in the cases 
;                              where the higher energies have more fluctuations/noise
;                              due to the crude background approximations or 
;                              counting statistics
;                              [Example smooths 3 highest energies over 10 points]
;
;   CHANGED:  1)  NA                                         [07/10/2008   v1.2.21]
;             2)  Updated man page                           [03/19/2009   v1.2.22]
;             3)  Changed program my_3dp_energy_bins.pro to dat_3dp_energy_bins.pro
;                                                            [08/05/2009   v1.3.0]
;             4)  Renamed and cleaned up                     [08/10/2009   v2.0.0]
;             5)  Changed some minor syntax                  [09/21/2009   v2.0.1]
;             6)  Changed program my_ytitle_tplot.pro to ytitle_tplot.pro
;                                                            [10/07/2008   v2.1.0]
;             7)  Fixed order of energy bin labels for SST data 
;                                                            [10/08/2008   v2.1.1]
;
;   ADAPTED FROM: clean_spikes.pro    BY: Davin Larson
;   CREATED:  04/05/2008
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  10/08/2008   v2.1.1
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-


Last Modification =>  2011-04-12/23:51:28 UTC
;+
;*****************************************************************************************
;
;  FUNCTION :   cold_plasma_etob_ratio.pro
;  PURPOSE  :   This program estimates the ratio of the electric to magnetic energy
;                 densities using cold plasma theory.
;
;  CALLED BY:   
;               
;
;  CALLS:
;               cold_plasma_params.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               MAGFO  :  Scalar ambient magnetic field magnitude (nT)
;               DENS   :  Scalar plasma density [cm^(-3)]
;
;  EXAMPLES:    
;               
;
;  KEYWORDS:    
;               FREQF  :  Scalar wave frequency (Hz)
;               ANGLE  :  Scalar wave propagation angle with respect to the magnetic
;                           field (degrees)
;               NDAT   :  Scalar number of values to create for dummy frequencies or
;                           angles  [Default = 100]
;               MAGF   :  Scalar wave amplitude (nT) used to estimate E-field amplitude
;               ELECF  :  Scalar wave amplitude (mV/m) used to estimate B-field amplitude
;
;   CHANGED:  1)  NA [MM/DD/YYYY   v1.0.0]
;
;   NOTES:      
;               1)  If MAGF or ELECF keywords are set, then program will return estimate
;                     of corresponding wave amplitude in mV/m or nT, respectively.
;               2)  Theory is taken from:
;                    -Stix, T.H. (1962), The Theory of Plasma Waves, McGraw-Hill.
;                    -Mosier, S.R. and D.A. Gurnett (1971), Theory of the Injun 5 Very-
;                         Low-Frequency Poynting Flux Measurements, J. Geophys. Res.
;                         Vol. 76, pp. 972-977.
;                    -Lengyel-Frey, D. et al. (1994), An analysis of whistler waves at
;                         interplanetary shocks, J. Geophys. Res. Vol. 99, pp. 13,325.
;               3)  Default return is the ratio of the E-field energy density to the
;                     B-field energy density [i.e. ratio of Eq. 4 to 3 from 
;                     Lengyel-Frey et al. 1994]
;
;   CREATED:  04/12/2011
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  04/12/2011   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-


Last Modification =>  2011-04-22/13:44:43 UTC
;+
;*****************************************************************************************
;
;  FUNCTION :   cold_plasma_params.pro
;  PURPOSE  :   Calculates cold plasma Stix parameters assuming an electron-proton
;                 quasi-neutral plasma.
;
;  CALLED BY:   
;               NA
;
;  CALLS:
;               NA
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               MAGF   :  1-Element array of magnetic field magnitudes (nT)
;               DENS   :  " " plasma densities [cm^(-3)]
;
;  EXAMPLES:    
;               test = cold_plasma_params(magf,dens,freqf,angle)
;
;  KEYWORDS:    
;               FREQF  :  " " wave frequencies (Hz)
;               ANGLE  :  " " wave propagation angles with respect to the magnetic
;                           field (degrees)
;               NDAT   :  Scalar number of values to create for dummy frequencies or
;                           angles
;
;   CHANGED:  1)  Fixed typo in calculation of n_Alfven and allowed frequencies
;                   to extend beyond the electron cyclotron frequency
;                                                              [09/22/2010   v1.1.0]
;             2)  Added the resonance cone angle to output     [09/28/2010   v1.2.0]
;             3)  Fixed typo with resonance cone angle calc.   [09/29/2010   v1.2.1]
;             4)  Changed keyword ANGLE variable to "angles" to prevent program from
;                   possibly changing the value of an input variable
;                                                              [04/22/2011   v1.2.2]
;
;   NOTES:      
;               1)  Set only one of the keywords at a time or at least make sure
;                     they have the same number of elements
;
;   CREATED:  09/20/2010
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  04/22/2011   v1.2.2
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-


Last Modification =>  2011-05-11/02:27:14 UTC
;+
;*****************************************************************************************
;
;  FUNCTION :   stix_params_1962_1d.pro
;  PURPOSE  :   Calculates the cold plasma parameters from Stix, [1962].
;
;  CALLED BY:   
;               cold_plasma_params_2d.pro
;
;  CALLS:
;               NA
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               MAGF   :  N-Element array of magnetic field magnitudes (nT)
;               DENS   :  " " plasma densities [cm^(-3)]
;               FREQW  :  N-Element array of wave frequencies (rad/s)
;
;  EXAMPLES:    
;               NA
;
;  KEYWORDS:    
;               NA
;
;   CHANGED:  1)  Fixed a typo where wce was not < 0               [05/10/2011   v1.0.1]
;
;   NOTES:      
;               1)  User should not call this routine
;
;   CREATED:  04/15/2011
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  05/10/2011   v1.0.1
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-
;+
;*****************************************************************************************
;
;  FUNCTION :   stix_params_1962_2d.pro
;  PURPOSE  :   Calculates the cold plasma parameters from Stix, [1962].
;
;  CALLED BY:   
;               cold_plasma_params_2d.pro
;
;  CALLS:
;               NA
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               MAGF   :  N-Element array of magnetic field magnitudes (nT)
;               DENS   :  " " plasma densities [cm^(-3)]
;               FREQW  :  M-Element array of wave frequencies (rad/s)
;
;  EXAMPLES:    
;               NA
;
;  KEYWORDS:    
;               NA
;
;   CHANGED:  1)  Fixed a typo where wce was not < 0               [05/10/2011   v1.0.1]
;
;   NOTES:      
;               1)  User should not call this routine
;
;   CREATED:  04/15/2011
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  05/10/2011   v1.0.1
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-
;+
;*****************************************************************************************
;
;  FUNCTION :   cold_plasma_params_2d.pro
;  PURPOSE  :   Calculates cold plasma Stix parameters assuming an electron-proton
;                 quasi-neutral plasma.
;
;  CALLED BY:   
;               NA
;
;  CALLS:
;               stix_params_1962_1d.pro
;               stix_params_1962_2d.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               MAGF   :  N-Element array of magnetic field magnitudes (nT)
;               DENS   :  " " plasma densities [cm^(-3)]
;
;  EXAMPLES:    
;               ; => Assume:  |B|   = 10 nT
;               ;             n_o   = 7 cm^(-3)
;               ;             freq  = 85 Hz
;               ;             theta = 20 degrees
;               ;             [typical solar wind parameters]
;               test = cold_plasma_params_2d(10.,7.,FREQF=85.,ANGLE=20.)
;
;  KEYWORDS:    
;               FREQF  :  M-Element array of wave frequencies (Hz)
;               ANGLE  :  L-Element array of wave propagation angles with respect to
;                           the magnetic field (degrees)
;               NDAT   :  Scalar number of values to create for dummy frequencies or
;                           angles if FREQF or ANGLE not set [Default = 100]
;               ONED   :  If set, all parameters are assumed to have the same number of
;                           elements and MAGF[j] corresponds to DENS[j] and FREQF[j] and
;                           ANGLE[j] => all returned values with be 1-Dimensional arrays
;
;   CHANGED:  1)  Fixed a typo where wce was not < 0               [05/10/2011   v1.0.1]
;
;   NOTES:      
;               1)  If MAGF and DENS have more than one element, then they must have
;                     the same number of elements.  The program assumes that they
;                     correspond to the same place/time measurement and will use them
;                     as such.
;               2)  FREQF and ANGLE can have different numbers of elements, but be 
;                     careful so you don't run out of memory as the return values
;                     can be [NF x NN x NA]-Element Arrays
;  REFERENCES:
;               **[GB2005]**
;               Gurnett, D. A., and A. Bhattacharjee (2005), "Introduction to Plasma
;                 Physics: With Space and Laboratory Applications," ISBN 0521364833. 
;                 Cambridge, UK: Cambridge University Press.
;               **[S1962]**
;               Stix, T. H. (1962), The Theory of Plasma Waves, McGraw-Hill.
;               
;
;   CREATED:  04/15/2011
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  05/10/2011   v1.0.1
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-


Last Modification =>  2011-03-22/23:15:55 UTC
;+
;*****************************************************************************************
;
;  FUNCTION :   whistler_params_calc.pro
;  PURPOSE  :   Calculates the cold plasma resonance energy estimate given a 
;                 magnetic field strength, plasma density, wave frequency, 
;                 and propagation angle.
;
;  CALLED BY:   
;               cold_plasma_whistler_params.pro
;
;  CALLS:
;               NA
;
;  REQUIRES:    
;               NA
;
;  INPUT:
;               MAGF         :  N-Element array of magnetic field magnitudes (nT)
;               DENS         :  " " plasma density [cm^(-3)]
;               FREQF        :  M-Element array of wave frequencies (Hz)
;               ANGLE        :  " " wave propagation angle with respect to the magnetic
;                                 field (degrees)
;
;  EXAMPLES:    
;               test = whistler_params_calc(magf,dens,freqf,angle,WAVE_LENGTH=wave_l,$
;                                           V_PHASE=vphase,ERES_LAND=eres_lan,       $
;                                           ERES_NCYC=eres_nor,ERES_ACYC=eres_ano)
;
;  KEYWORDS:    
;               WAVE_LENGTH  :  Set to a named variable to return the wave lengths (km)
;               V_PHASE      :  " " phase speeds (km/s)
;               ERES_LAND    :  " " Landau resonant energies (eV)
;               ERES_NCYC    :  " " normal cyclotron resonant energies (eV)
;               ERES_ACYC    :  " " anomalous cyclotron resonant energies (eV)
;
;   CHANGED:  1)  NA [MM/DD/YYYY   v1.0.0]
;
;   NOTES:      
;               1)  User should not call this routine
;
;   CREATED:  03/22/2011
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  03/22/2011   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-
;+
;*****************************************************************************************
;
;  FUNCTION :   cold_plasma_whistler_params.pro
;  PURPOSE  :   Given the ambient magnetic field strength, plasma density, wave
;                 frequency, and propagation angle the program will return a
;                 cold plasma estimate of a whistler wave phase velocity,
;                 Landau, normal, and anomalous cyclotron resonance energies,
;                 and an estimated wavelength.
;
;  CALLED BY:   
;               NA
;
;  CALLS:
;               whistler_params_calc.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               MAGF   :  N-Element array of magnetic field magnitudes (nT)
;               DENS   :  " " plasma densities [cm^(-3)]
;               FREQF  :  " " wave frequencies (Hz)
;               ANGLE  :  " " wave propagation angles with respect to the magnetic
;                           field (degrees)
;
;  EXAMPLES:    
;               test = cold_plasma_whistler_params(magf,dens,freqf,angle)
;
;  KEYWORDS:    
;               NA
;
;   CHANGED:  1)  Added calculation to allow for different number of elements for
;                   each type of input                          [03/22/2011   v1.1.0]
;
;   NOTES:      
;               1)  These calculations are in the high density limit or:
;                     Ωce << Ωpe
;
;   CREATED:  05/01/2010
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  03/22/2011   v1.1.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-


Last Modification =>  2010-03-19/15:21:13 UTC
;+
;*****************************************************************************************
;
;  FUNCTION :   colinear_test.pro
;  PURPOSE  :   Tests whether the 3 arrays of N-elements have any co-linear data points.
;                 If given three points A, B, and C and one wishes to triangulate these
;                 points, the process cannot be done if they are co-linear.  To test
;                 whether the points are co-linear, simply determine if the points
;                 consist of linear combinations of the other points.  Meaning, IF
;                 (vector AB is a real multiple of the vector BC) OR 
;                 (vector AB is a real multiple of the vector AC)
;                 THEN they are co-linear.  The default the numerical threshold used to
;                 test this in the program is 10^(-12).
;
;  CALLED BY:   
;               plot3d.pro
;
;  CALLS:
;               NA
;
;  REQUIRES:    
;               NA
;
;  INPUT:
;               X1      :  1st N-element array corresponding the 1st component of
;                            either the cartesian or spherical coordinate systems
;               X2      :  2nd N-element array corresponding the 2nd component of
;                            either the cartesian or spherical coordinate systems
;               X3      :  3rd N-element array corresponding the 3rd component of
;                            either the cartesian or spherical coordinate systems
;
;  EXAMPLES:    
;               
;
;  KEYWORDS:    
;               SPHERE  :  If set, program assumes input is in spherical coordinates
;                            corresponding to:
;                            X1  :  SQRT(x^2 + y^2 + z^2)          [ = r]
;                            X2  :  ATAN(y,x)                      [ = phi]
;                            X3  :  ACOS(z/SQRT(x^2 + y^2 + z^2))  [ = theta]
;
;   CHANGED:  1)  NA [MM/DD/YYYY   v1.0.0]
;
;   NOTES:      
;               1)  If input is spherical, make sure the angles (X2 and X3) are in 
;                     radians
;
;   CREATED:  03/19/2010
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  03/19/2010   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-


Last Modification =>  2009-10-15/01:31:42 UTC
;+
;*****************************************************************************************
;
;  FUNCTION :   contour_2d_eesa_plots.pro
;  PURPOSE  :   This is a wrapping program for a number of other programs which
;                 allows the user to plot the distribution function (DF) both with
;                 and without assumed gyrotropy for the Eesa detector data.
;
;  CALLED BY:   
;               NA
;
;  CALLS:
;               my_str_date.pro
;               get_el.pro
;               get_elb.pro
;               get_3dp_structs.pro
;               eesa_data_4.pro
;               moments_array_3dp.pro
;               eh_cont3d.pro
;               one_count_level.pro
;               cont2d.pro
;               interp.pro
;               my_time_string.pro
;
;  REQUIRES:    
;               UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               NA
;
;  EXAMPLES:    
;               NA
;
;  KEYWORDS:    
;               DATE     :  [string] 'MMDDYY' [MM=month, DD=day, YY=year]
;               VLIM     :  Limit for x-y velocity axes over which to plot data
;                             [Default = max vel. from energy bin values (km/s)]
;               NGRID    :  # of isotropic velocity grids to use to triangulate the data
;                             [Default = 20L]
;               V_TH     :  If set, program will output of thermal velocity on plot
;               GNORM    :  If set, program will overplot the projection of the shock
;                             normal vector on the contour plot
;               HEAT_F   :  If set, program will overplot the projection of the 
;                             heat flux vector  on the contour plot
;               TRANGE   :  [Double] 2-Element array specifying the time range over 
;                              which to get data structures for [Unix time]
;               NOLOAD   :  If set, program does not attempt to call the programs
;                             get_??.pro because it assumes you've already
;                             loaded the relevant electron data.  [use on iMac]
;               ELM      :  N-Element array of Eesa Low 3DP moment structures.  
;                             This keyword is intended to be used in association 
;                             with the NOLOAD keyword specifically for users with
;                             IDL save files on a non-SunMachine computer.
;               ELBM     :  N-Element array of Eesa Low Burst 3DP moment structures.
;                             This keyword is intended to be used in association 
;                             with the NOLOAD keyword specifically for users with
;                             IDL save files on a non-SunMachine computer.
;               EL_DIR   :  Scalar string defining the directory where you want the 
;                             Eesa Low plots to be saved
;               ELB_DIR  :  Scalar string defining the directory where you want the 
;                             Eesa Low Burst plots to be saved
;
;   CHANGED:  1)  Added one count level outputs to eh_cont3d.pro plots
;                                                                  [10/14/2009   v1.1.0]
;
;   NOTES:      
;               
;
;   CREATED:  09/09/2009
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  10/14/2009   v1.1.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-


Last Modification =>  2010-10-13/14:54:53 UTC
;+
;*****************************************************************************************
;
;  FUNCTION :   contour_3dp_plot_limits.pro
;  PURPOSE  :   Creates a default limit structure for plotting a contour of the
;                 distribution function (DF) for a 3DP particle structure.  The program
;                 assumes you wish to plot the parallel and perpendicular cuts of
;                 the DF below the contour plot and that you've already ran the 
;                 3DP particle structure through the program add_df2d_to_ph.pro to
;                 calculate the distribution function.
;
;  CALLED BY: 
;               my_ph_cont2d.pro
;               eh_cont3d.pro
;
;  CALLS:
;               str_element.pro
;               extract_tags.pro
;               dat_3dp_str_names.pro
;               roundsig.pro
;               minmax.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               DAT      :  3DP data structure either from get_eh.pro etc.
;
;  EXAMPLES:
;
;  KEYWORDS:  
;               VLIM     :  Limit for x-y velocity axes over which to plot data
;                             [Default = max vel. from energy bin values]
;               NGRID    :  # of isotropic velocity grids to use to triangulate the data
;                             [Default = 20L]
;               DFMIN    :  Set to a scalar value defining the lower limit on the DF 
;                             you wish to plot (s^3/km^3/cm^3)
;                             [Default = 1e-14 (for PH)]
;               CMIN     :  Set to a scalar value defining the lowests color index to
;                             start with [Default = 30L (=purple if loadct,39)]
;               DFRA     :  2-Element array specifying a DF range (s^3/km^3/cm^3) for the
;                             cuts of the contour plot
;               MAGNETO  :  If set, tells program that the data was taken in the
;                              magnetosphere, thus to alter the upper and lower 
;                              limits on the distributions
;
;   CHANGED:  1)  Fixed syntax error                         [07/13/2009   v1.0.1]
;             2)  Fixed contour labeling issue for EL(B)     [07/18/2009   v1.0.2]
;             3)  Changed program my_str_names.pro to dat_3dp_str_names.pro
;                                                            [08/10/2009   v1.1.0]
;             4)  Changed contour level and Y-Range determination scheme
;                                                            [08/27/2009   v1.2.0]
;             5)  Changed plot axis labels                   [08/28/2009   v1.2.1]
;             6)  Fixed plot axis ranges                     [08/31/2009   v1.2.2]
;             7)  Now calls exponential_round.pro to alter the contour level labels
;                                                            [08/31/2009   v1.2.3]
;             8)  Changed contour level determination        [09/18/2009   v1.2.4]
;             9)  Changed case statement regarding conditional structure names used
;                                                            [09/23/2009   v1.3.0]
;            10)  Fixed a typo in min-max axis range calc.   [11/03/2009   v1.3.1]
;            11)  Changed min-max axis range calc.           [11/12/2009   v1.3.2]
;            12)  Added keyword:  MAGNETO                    [12/10/2009   v1.4.0]
;            13)  Fixed issue with DFRA keyword              [09/16/2010   v1.4.1]
;            14)  Now calls roundsig.pro instead of exponential_round.pro
;                                                            [10/01/2010   v1.5.0]
;            15)  Updated man page                           [10/13/2010   v1.5.1]
;
;   CREATED:  06/24/2009
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  10/13/2010   v1.5.1
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-


Last Modification =>  2010-08-03/23:44:10 UTC
;+
;*****************************************************************************************
;
;  FUNCTION :   coord_trans_geos.pro
;  PURPOSE  :   Returns the transformation matricies for converting from one
;                 coordinate system to another, given the dates and times desired.  The
;                 relevant coordinate system transformations do not require position
;                 vectors, thus the list of possible coordinates is limited.
;
;  CALLED BY:   
;               
;
;  CALLS:
;               my_str_date.pro
;               doy_convert.pro
;               eulerf.pro        => Located at bottom of program
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               NA
;
;  EXAMPLES:    
;               date = '082896'
;               time = '16:44:57.8160'   ; => UTC time, or 16:46:00 in TT
;               coord_trans_geos,DATE=date,UT_TIME=time,ROT_MAT=rot_mat
;
;  KEYWORDS:    
;               DATE       :  [string] 'MMDDYY' [MM=month, DD=day, YY=year]
;               UT_TIME    :  String defining the UT of interest for determining the
;                               Julian Day ['HH:MM:SS.ssss']
;               TIME_DATE  :  String defining date AND time of interest
;                               ['YYYY-MM-DD/HH:MM:SS']
;               ROT_MAT    :  Set to a named variable in which to return the
;                               rotation matricies structure
;
;   CHANGED:  1)  NA [MM/DD/YYYY   v1.0.0]
;
;   NOTES:      
;               See coord_trans_documentation.txt for explanation of each 
;                 coordinate system.  Calculations come from the paper:
;
;                  M. Fränz and D. Harper (2002), "Heliospheric Coordinate Systems," 
;                    Planetary and Space Science, Vol. 50, pages 217-233.
;               *******************************
;               **List of acronyms in program**
;               *******************************
;               TAI      :  International Atomic Time
;               UTC      :  Coordinated Universal Time
;               UT1      :  Universal Time, defined by mean solar day
;               TDB      :  Barycentric Dynamical Time
;                             Defined as:  TDB = UTC + 32.184 + ∆A
;                             {where: ∆A = leap seconds elapsed to date}
;               **********************************
;               **List of definitions in program**
;               **********************************
;               subterrestrial pt. = Apparent center of the visible disk, from Earth,
;                                      of the Sun whose heliocentric longitude is the
;                                      apparent longitude of the Earth (defined in
;                                      Sect. 3.2.1 of Fränz)
;
;               1)  Corrections to Fränz and Harper [2002] show that the numerical
;                     example in Appendix B should have said 16:46:00 TT, NOT
;                     16:46:00 UTC
;               2)  For higher precision expansions, look at:
;                     Explanatory Supplement to the Astronomical Ephemeris (ESAE)
;                       http://aa.usno.navy.mil/data/
;                     and the Astronomical Almanac (AA)
;                       http://asa.usno.navy.mil/
;               3)  e_0J2000 = 23.439279444444 degrees as of 2009 (AA)
;                     [Fränz and Harper use: 23.439291111111]
;               4)  See also:  
;                     J.L. Simon et. al. (1994), "Numerical Expressions for precession
;                       formulae and mean elements for the Moon and the planets," 
;                       Astron. Astrophys. Vol. 282, pages 663-683.
;               5)  See also:  
;                     J.H. Lieske et. al. (1977), "Expressions for the Precession
;                       Quantities Based upon the IAU (1976) System of Astronomical
;                       Constants," Astron. Astrophys. Vol. 58, pages 1-16.
;
;   CREATED:  08/03/2010
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  08/03/2010   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-
;+
;*****************************************************************************************
;
;  FUNCTION :  eulerf.pro
;  PURPOSE  :  Given three angles, this program will return the Euler matrix for those
;                input angles [Note: Make sure to define the units using the keywords].
;                The format is specific to match the format given in the Fränz paper
;                cited below.
;
;  CALLED BY:   NA
;
;  CALLS:       NA
;
;  REQUIRES:    NA
;
;  INPUT:
;               OMEGA  :  First rotation angle about original z-axis
;               THETA  :  Second rotation angle about X'-Axis
;               PHI    :  Third rotation angle about Z"-Axix
;
;  EXAMPLES:
;
;  KEYWORDS:
;               DEG : If set, tells program the angles are in degrees (default)
;               RAD : If set, tells program the angles are in radians
;
;   CHANGED:  1)  Updated man page                               [09/15/2009   v1.0.1]
;
;  NOTES:  
;               See coord_trans_documentation.txt for explanation of each 
;                 coordinate system.  Calculations come from the paper:
;
;                  M. Fränz and D. Harper, "Heliospheric Coordinate Systems," 
;                    Planetary and Space Science Vol. 50, 217-233, (2002).
;
;   CREATED:  07/22/2009
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  09/15/2009   v1.0.1
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-


Last Modification =>  2010-10-25/15:53:08 UTC
;+
;*****************************************************************************************
;
;  FUNCTION :   spread.pro
;  PURPOSE  :   Spread out a vector into a matrix along, treating vector as a column
;                 unless the row keyword is used. 
;                 [Based on the F90 intrinsic SPREAD]
;
;  CALLED BY:   
;               curveint.pro
;
;  CALLS:
;               
;
;  REQUIRES:    
;               NA
;
;  INPUT:
;               VEC  :  M-Element array of points to spread out into a matrix
;               N    :  Scalar defining the number of points to use in column/row
;
;  EXAMPLES:    
;               
;
;  KEYWORDS:    
;               ROW  :  If set, the program uses row-major formating
;
;   CHANGED:  1)  Added man page and vectorized                   [10/25/2010   v1.0.1]
;
;   NOTES:      
;               
;
;   CREATED:  10/22/2010
;   CREATED BY:  J.R. Woodroffe
;    LAST MODIFIED:  10/25/2010   v1.0.1
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-
;+
;*****************************************************************************************
;
;  FUNCTION :   curveint.pro
;  PURPOSE  :   Find the intersection of two arbitrary curves.
;
;  CALLED BY:   
;               NA
;
;  CALLS:
;               spread.pro
;
;  REQUIRES:    
;               NA
;
;  INPUT:
;               XX0  :  N-Element array of abcissa values for YY0
;               YY0  :  N-Element array of dependent values associated with XX0
;               XX1  :  M-Element array of abcissa values for YY1
;               YY1  :  M-Element array of dependent values associated with XX1
;
;  EXAMPLES:    
;               xa  = 2d0*!DPI*DINDGEN(50L)/49L
;               xb  = 4d0*DINDGEN(100L)/99L
;               ya  = SIN(xa)
;               zb  = -1d-1 + 5d-1*xb - 5d-2*xb^2 + 25d-4*xb^3
;               res = curveint(xa,ya,xb,zb)
;               PRINT, res
;                      2.2270945
;
;  KEYWORDS:    
;               NA
;
;   CHANGED:  1)  Added man page                                  [10/25/2010   v1.0.1]
;
;   NOTES:      
;               1)  J.R. Woodroffe originally stated that the result of this routine
;                     for the example was 2.22709 and that the analytical result should
;                     be 2.22611, thus a relative error of 0.04 percent.  I receive
;                     the value 2.2270945 which confirms J.R. Woodroffe's result.
;
;   CREATED:  10/22/2010
;   CREATED BY:  J.R. Woodroffe
;    LAST MODIFIED:  10/25/2010   v1.0.1
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-


Last Modification =>  2009-10-13/13:44:18 UTC
;+
;*****************************************************************************************
;
;  FUNCTION :   dat_3dp_energy_bins.pro
;  PURPOSE  :   Determine energy bins one wants to use for generalized input.  The 
;                 program returns a data structure containing the start and end
;                 elements for the desired energy bins (if EBINS is set, else the
;                 default is [0,# of energies - 1]) and the "actual" energies
;                 associated with the data structure D2.
;
;  CALLED BY:   NA
;
;  CALLS:
;               get_data.pro
;               pesa_high_bad_bins.pro
;
;  REQUIRES:    NA
;
;  INPUT:
;               D2 :  3DP data structure either from spec plots (i.e. get_padspec.pro)
;                        or from pad.pro, get_el.pro, get_sf.pro, etc.
;
;  EXAMPLES:
;
;               3dp> my_get_padspec,'el', bsource='wi_B3(GSE)',num_pa=16,ENBINS=10
;               3dp> get_data,'el_pads', data = dat, dlim=dlim,lim=lim
;
;               3dp> my_ens = dat_3dp_energy_bins(dat,EBINS=10)
;               3dp> help, my_ens,/str
;               ** Structure <aa96b8>, 2 tags, length=48, data length=48, refs=1:
;                  E_BINS          LONG      Array[2]
;                  ENERGIES        FLOAT     Array[10]
;
;
;               3dp> print, my_ens.e_bins
;                          0           9
;               3dp> print, my_ens.ALL_ENERGIES 
;                     1122.55      768.461      528.102      363.049      249.577
;                     171.631      118.545      82.1101      57.0127      39.9383
;
;               {The following give the same results as above}
;
;               3dp> my_ens1 = dat_3dp_energy_bins(dat,EBINS=[0,9])
;               3dp> my_ens2 = dat_3dp_energy_bins(dat,EBINS=lindgen(10))
;
;               {Or try the following...}
;
;               3dp> tt = dat.x[0]
;               3dp> el = get_el(tt)
;               3dp> my_ens3 = dat_3dp_energy_bins(el,EBINS=10)
;
;  KEYWORDS:  
;               EBINS : number of energy bins wanted (e.g. 10 or [0,9] or [2,11])
;                         which mark high -> low energy bins where bin 9 has a 
;                         lower energy associated with it than bin 0 (sf and so 
;                         reverse)  {i.e. [high #,low #]}
;
;   CHANGED:  1)  Fixed a possible issue which occurs with Pesa High
;                  data energy values                     [11/07/2008   v1.0.5]
;             2)  Added program:  my_pesa_high_bad_bins.pro which is more
;                  efficient at dealing with Change 1)    [04/26/2009   v1.0.6]
;             3)  Rewrote and renamed with more comments  [07/20/2009   v2.0.0]
;             4)  Fixed syntax error when in EBINS keyword usage/calcs
;                                                         [08/31/2009   v2.0.1]
;             5)  Changed my_pesa_high_bad_bins.pro to pesa_high_bad_bins.pro
;                                                         [10/13/2009   v2.1.0]
;
;   CREATED:  06/06/2008
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  10/13/2009   v2.1.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-


Last Modification =>  2009-09-18/19:02:24 UTC
;+
;*****************************************************************************************
;
;  FUNCTION :   dat_3dp_str_names.pro
;  PURPOSE  :   Returns the associated structure name for the input.  Enter a
;                 string to get the "formal" name associated with a particular
;                 detector (i.e. 'elb' -> 'Eesa Low Burst') or a structure to 
;                 get a two or three letter string associated with structure
;                 (i.e. dat = get_el() => result = 'el').
;
;  CALLED BY:   NA
;
;  CALLS:       NA
;
;  REQUIRES:    NA
;
;  INPUT:
;               DAT : [string,structure] associated with a known 3DP data structure
;                       {i.e. el = get_el() => dat = el, or dat = 'Eesa Low'}
;
;  EXAMPLES:
;               el   = get_el(t)
;               strn = dat_3dp_str_names(el)
;               print,strn.LC
;               => 'Eesa Low'
;
;               strn = dat_3dp_str_names('elb')
;               print,strn.LC
;               => 'Eesa Low Burst'
;
;  KEYWORDS:  NA
;
;   CHANGED:  1)  Updated 'man' page                      [11/11/2008   v1.0.3]
;             2)  Rewrote and renamed with more comments  [07/20/2009   v2.0.0]
;             3)  Fixed some small typos in comments      [08/05/2009   v2.0.1]
;             4)  Fixed syntax error when sending in structures
;                                                         [08/31/2009   v2.1.0]
;             5)  Fixed an issue which arose when sending PAD structures
;                                                         [09/18/2009   v2.1.1]
;
;   CREATED:  07/05/2008
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  09/18/2009   v2.1.1
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-


Last Modification =>  2011-04-20/20:48:18 UTC
;+
;*****************************************************************************************
;
;  FUNCTION :   data_envelope_find.pro
;  PURPOSE  :   Determines the upper and lower bounds of an envelope of data.
;                ** Unfinished! **
;
;  CALLED BY:   
;               
;
;  CALLS:
;               
;
;  REQUIRES:    
;               
;
;  INPUT:
;               XX      :  N-Element array of x-data
;               YY      :  N-Element array of y-data
;
;  EXAMPLES:    
;               
;
;  KEYWORDS:    
;-------------------
;               SM      :  Scalar defining the number of points over which to determine
;                            the local max/min values for the envelope
;                            [Default and MIN = 10]
;-------------------
;               LENGTH  :  Scalar defining the # of elements in XX to treat as a
;                            single bin
;                            [Default and MIN = 10% of N]
;               OFFSET  :  Scalar defining the # of elements to shift each time
;                            the program recalculates the distribution in a bin
;                            [Default = 1/4 of LENGTH]
;               THRESH  :  Scalar defining the tolerance one allows when determining the
;                            local upper/lower bound that exceeds 2 STDEV
;                            [Default =  5%]
;
;   CHANGED:  1)  NA [MM/DD/YYYY   v1.0.0]
;
;   NOTES:      
;               1)  STDEV   = Standard Deviation [std = STDDEV(X)]
;               2)  STDEVMN = Std. Dev. of the Mean = STDDEV(X)/SQRT(N)
;
;   CREATED:  04/19/2011
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  04/19/2011   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-


Last Modification =>  2011-05-23/21:57:26 UTC
;+
;*****************************************************************************************
;
;  FUNCTION :   data_velocity_transform.pro
;  PURPOSE  :   Calculates an estimate of the reduced distribution function and adds
;                 the tags to a copy of the input data structure then returns to
;                 "add_df2d_to_ph.pro".  The data is transformed into the solar wind
;                 frame first and rotated into a coordinate system defined by a plane
;                 created between two vectors of interest [Default = (Vsw x B)].
;                 If the input structure is from the Pesa High instrument, the 
;                 "known" data glitches are removed (see "pesa_high_bad_bins.pro")
;                 before data is transformed or rotated.  The glitches are also
;                 removed to prevent an alteration of the energy bin values.  If the
;                 input structure is from the Eesa Low instrument, the spacecraft
;                 potential estimate is subtracted from the energies of the particles
;                 before transforming into the solar wind frame.
;
;  CALLED BY: 
;               add_df2d_to_ph.pro
;
;  CALLS:
;               dat_3dp_str_names.pro
;               dat_3dp_energy_bins.pro
;               pesa_high_bad_bins.pro
;               convert_ph_units.pro
;               conv_units.pro
;               cart_to_sphere.pro
;               cal_rot.pro
;               velocity.pro
;               str_element.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               DAT      :  3DP data structure either from get_ph.pro etc.
;
;  EXAMPLES:
;
;  KEYWORDS:  
;               VLIM     :  Limit for x-y velocity axes over which to plot data
;                             [Default = max vel. from energy bin values]
;               NGRID    :  # of isotropic velocity grids to use to triangulate the data
;                             [Default = 50L]
;               ROT_MAT  :  [3,3]-Element matrix used to rotate data into a new desired
;                             plane of projection [Default = plane defined by (Vsw x B)]
;               NSMOOTH  :  Scalar # of points over which to smooth the DF
;                             [Default = 3]
;
;   CHANGED:  1)  Fixed syntax error                              [07/13/2009   v1.0.1]
;             2)  Fixed possible negative DF-Value issue          [07/18/2009   v1.0.2]
;             3)  Changed program my_3dp_energy_bins.pro to dat_3dp_energy_bins.pro
;                   and my_str_names.pro to dat_3dp_str_names.pro
;                                                                 [08/05/2009   v1.1.0]
;             4)  Added keyword:  NSMOOTH                    
;                   and my_pesa_high_bad_bins.pro to pesa_high_bad_bins.pro
;                   and altered spacing for TRIGRID.PRO           [08/27/2009   v1.2.0]
;             5)  Changed minor syntax issue                      [08/31/2009   v1.2.1]
;             6)  Updated 'man' page                              [10/05/2008   v1.2.2]
;             7)  Changed calculation of parallel/perp. cuts      [04/12/2010   v1.3.0]
;             8)  Added error handling for moments produced by the Mac OS X shared
;                   object library which produces anomalous data spikes
;                                                                 [02/18/2011   v1.4.0]
;             9)  Fixed typo in return tags:  DF2DZ, VX2DZ, and VY2DZ
;                                                                 [05/23/2011   v1.4.1]
;
;   NOTES:      
;               1)  This program is adapted from software by K. Meziane
;
;   CREATED:  06/24/2009
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  05/23/2011   v1.4.1
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-


Last Modification =>  2011-02-16/21:43:50 UTC
;+
;*****************************************************************************************
;
;  FUNCTION :   dfdx.pro
;  PURPOSE  :   Calculates the numerical derivative to 2nd order of an input function
;                 f = f(x) with respect to x.
;
;  CALLED BY:   
;               NA
;
;  CALLS:
;               NA
;
;  REQUIRES:    
;               NA
;
;  INPUT:
;               X       :  N-Element array of independent variable
;               FX      :  N-Element array of dependent variable
;
;  EXAMPLES:    
;               x   = DINDGEN(100)*2d0*!DPI/99 - !DPI
;               y   = SIN(x)
;               dy  = COS(x)
;               dy2 = dfdx(x,y)
;               dy3 = dfdx(x,y,/LINEND)
;               PRINT, MAX(ABS(dy2 - dy),/NAN), MAX(ABS(dy3 - dy),/NAN)
;                   0.0013407742   0.00067119796
;
;  KEYWORDS:    
;               LINEND  :  If set, use a one sided linear approximation for end points
;
;   CHANGED:  1)  NA [MM/DD/YYYY   v1.0.0]
;
;   NOTES:      
;               1)  This should be more accurate than the built-in DERIV.PRO
;
;   CREATED:  02/16/2011
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  02/16/2011   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-


Last Modification =>  2011-04-22/13:33:33 UTC
;+
;*****************************************************************************************
;
;  FUNCTION :   directory_path_check.pro
;  PURPOSE  :   This is a simple wrapping routine with error handling used to evaluate
;                 a directory path.
;
;  CALLED BY:   
;               wind_3dp_save_file_get.pro
;
;  CALLS:
;               NA
;
;  REQUIRES:    
;               NA
;
;  INPUT:
;               DIREC     :  Scalar string defining the full path to the directory
;                              user wishes to check/verify
;
;  EXAMPLES:    
;               mdir = FILE_EXPAND_PATH('')  ; => Default IDL working directory
;               test = directory_path_check(mdir[0])
;
;  KEYWORDS:    
;               BASE_DIR  :  Scalar string defining the full path to the directory of
;                              interest
;               SUB_DIR   :  Scalar string defining the the subdirectory user wishes
;                              to focus on
;                           [format matches that of SUBDIRECTORY keyword in FILEPATH.PRO]
;               GET_NEW   :  If set, program will let user define new file path
;                              to desired directory IF the input directory is
;                              determined to be invalid
;
;   CHANGED:  1)  Fixed an issue that occurs if one enters a full file path with
;                   the SUB_DIR keyword instead of just the subdirectory name
;                                                                  [04/22/2011   v1.0.1]
;
;   NOTES:      
;               1)  When using the SUB_DIR keyword, one need only add the extra path
;                     to that specific directory from the directory defined by the
;                     BASE_DIR keyword
;
;   CREATED:  03/25/2011
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  04/22/2011   v1.0.1
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-


Last Modification =>  2009-07-20/21:29:58 UTC
;+
;*****************************************************************************************
;
;  FUNCTION :   distfunc_template.pro
;  PURPOSE  :   Create a dummy distribution function structure or array to prevent
;                 the code from breaking upon multiple callings of the program
;                 my_distfunc.pro.  The returned structure is template which
;                 can be used as a reference or an empty structure for
;                 error handling.
;
;  CALLED BY:  
;               distfunc.pro
;
;  CALLS:
;               velocity.pro
;
;  REQUIRES:    NA
;
;  INPUT:
;               VPAR     :  An array of data corresponding to either the energy or 
;                             parallel(wrt B-field) velocity associated with the data
;               VPERP    :  An array of data corresponding to either the angle or the
;                             perpendicular velocity associated with the data
;
;  EXAMPLES:
;               test    = distfunc(dat.ENERGY,dat.ANGLE,MASS=dat.MASS,DF=dat.DATA)
;               test    = distfunc(vpar,vperp,PARAM=dfpar) 
;               
;               df_temp = distfunc_template(vpar,vperp,PARAM=dfpar)
;               dfpar   = distfunc(vx0,vy0,df=df0)   
;                   => Create structure dfpar using values of df0 known at the 
;                         positions of vx0,vy0 as a structure
;               df_new  = distfunc(vx_new,vy_new,par=dfpar)   
;                   => returns interpolated values of df at the new points as an array
;
;  KEYWORDS:  
;               DF       :  [float] Array of data from my_pad_dist.pro
;               PARAM    :  A 3D data structure with the tag names VX0, VY0, and DFC
;               MASS     :  [float] Value representing the mass of particles for the
;                             distribution of interest [eV/(km/sec)^2]
;
;   CHANGED:  1)  Fixed syntax error                   [07/10/2008   v1.0.1]
;             2)  Updated man page                     [02/25/2009   v1.0.2]
;             3)  Changed return values and robustness [02/25/2009   v1.0.3]
;             4)  Updated man page                     [06/22/2009   v1.0.4]
;             5)  Changed name from my_distfunc_template.pro to distfunc_template.pro
;                                                      [07/20/2009   v1.1.0]
;
;   ADAPTED FROM: distfunc.pro  BY: Davin Larson
;   CREATED:  02/05/2008
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  07/20/2009   v1.1.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-


Last Modification =>  2009-10-13/23:54:13 UTC
;+
;*****************************************************************************************
;
;  FUNCTION :   div_diff_add_tplot.pro
;  PURPOSE  :   Creates a new TPLOT variable defined by the ratio/difference/addition of 
;                 two TPLOT variables of either vector or scalar form.  Note, this
;                 program will NOT deal with multi-dimensional plots like particle
;                 spectra which have structures with V and V1, V2 as tag names.
;
;  CALLED BY:  
;               NA
;
;  CALLS:
;               store_data.pro
;               options.pro
;               tnames.pro
;               get_data.pro
;               interp.pro
;
;  REQUIRES:    
;               UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               N1             :  A string or scalar associated with a TPLOT variable
;               N2             :  A string or scalar associated with a TPLOT variable
;
;  EXAMPLES:    
;               ; => To divide two TPLOT variables, do the following:
;               tpn1 = tnames(1)
;               tpn2 = tnames(2)
;               div_diff_add_tplot,tpn1,tpn2,/DIVIDE,NEW_NAME=tpn1+'_'+tpn2
;
;  KEYWORDS:  
;               NEW_NAME       :  String defining the new TPLOT name to use when
;                                   storing data in TPLOT
;               DIVIDE         :  If set, creates new tplot_variable of n1/n2
;               DIFF           :  If set, creates new tplot_variable of n1 - n2
;               ADD            :  If set, creates new tplot_variable of n1 + n2
;               INTERP_THRESH  :  Scalar that determines the threshold for data output
;                                   to avoid data spikes when interpolating data
;
;   CHANGED:  1)  Fixed a labeling issue                      [04/24/2009   v1.0.1]
;             2)  Renamed from my_div_diff_add_tplot.pro      [10/13/2009   v2.0.0]
;
;   CREATED:  03/12/2009
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  10/13/2009   v2.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-


Last Modification =>  2011-02-02/13:52:03 UTC
;+
;*****************************************************************************************
;
;  FUNCTION :   doy_convert.pro
;  PURPOSE  :   Converts different types of input into:
;                   1) day-of-year (DOY)
;                   2) year-month-day
;                   3) year ['YYYY'], month ['MM'], day['DD'] separated
;                   4) Julian Day
;                   5) Unix Time for both UTC and TBD
;                   6) etc.
;
;  CALLED BY:   
;               orbit_eulerang.pro
;
;  CALLS:
;               time_struct.pro
;               my_str_date.pro
;               time_double.pro
;               my_time_string.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               NA
;
;  EXAMPLES:    
;               date = '082696'
;               utc  = '16:44:57.8160'
;               doy  = doy_convert(DATE=date,UT_TIME=utc,JULIAN=jjd)
;               PRINT,jjd[0],FORMAT='(f25.8)'
;                        2450322.19861111
;
;  KEYWORDS:    
;               YEAR       :  'YYYY'   [e.g. '1996']
;               MONTH      :  'MM'     [e.g. '04', for April]
;               DAY        :  'DD'     [e.g. '25']
;               DATE       :  'MMDDYY' [e.g. '040396', for April 3rd, 1996]
;               DOY        :  [string,long,float,dbl]'DOY' [e.g. '93', for April 3rd 
;                               in non-leap year, '94' if a leap year]
;               JULIAN     :  Set to a named variable to return the Julian Day
;               UT_TIME    :  String defining the UTC of interest for determining the
;                               Julian Day ['HH:MM:SS.ssss']
;               UNIX_TIME  :  Set to a double specifying the Unix time of interest
;
;  NOTES:  
;               *******************************
;               **List of acronyms in program**
;               *******************************
;               TAI      :  International Atomic Time
;               UTC      :  Coordinated Universal Time [UTC = TAI - (leap seconds)]
;               TT       :  Terrestrial Time [TT = TAI + 32.184(s)]
;               TDB      :  Barycentric Dynamical Time
;                             Defined as:  TDB = UTC + 32.184 + ∆A
;                             {where: ∆A = leap seconds elapsed to date}
;               1)  The difference between ephemeris time, TBD, and TT is < 2 ms
;               2)  The difference between UTC and UT1 is < 0.1 s
;
;   CHANGED:  1)  Altered manner in which program calcs DOY [09/23/2008   v1.0.2]
;             2)  Updated man page                          [07/20/2009   v1.0.3]
;             3)  Added keyword:  UT_TIME and UNIX_TIME     [07/22/2009   v1.1.0]
;             4)  Changed output to include:  UTC, TBD, and leap seconds in Unix time
;                   and just seconds and UTC and TBD as strings
;                   and changed program time_string.pro to my_time_string.pro
;                                                           [09/15/2009   v1.2.0]
;             5)  Removed time messages returned by my_time_string.pro
;                                                           [04/28/2010   v1.2.1]
;             6)  Changed determination of date/time using UNIX_TIME keyword
;                                                           [08/03/2010   v1.3.0]
;             7)  Added correction to TDT time to calculate the real TDB times
;                                                           [02/01/2011   v1.4.0]
;             8)  Fixed a typo in DOY calculation           [02/02/2011   v1.5.0]
;
;   CREATED:  07/21/2008
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  02/02/2011   v1.5.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-


Last Modification =>  2009-08-10/18:45:20 UTC
;+
;*****************************************************************************************
;
;  FUNCTION :   dummy_3dp_str.pro
;  PURPOSE  :   Returns a dummy structure appropriate for replicating and preventing
;                 conflicting data structure errors.
;
;  CALLED BY: 
;               get_3dp_structs.pro
;
;  CALLS:
;               dat_3dp_str_names.pro
;               dummy_eesa_sst_struct.pro
;               dummy_pesa_struct.pro
;
;  REQUIRES:    NA
;
;  INPUT:
;               NAME   : [string] Specify the type of structure you wish to 
;                          get the data for [i.e. 'el','eh','elb',etc.]
;
;  EXAMPLES:
;               dubm = my_dummy_str('elb')
;
;  KEYWORDS:  
;               INDEX  :  [long] Array of indicies associated w/ data structs
;
;   CHANGED:  1)  Added the keyword INDEX                 [08/18/2008   v1.0.5]
;             2)  Updated man page                        [03/18/2009   v1.0.6]
;             3)  Changed program my_str_names.pro to dat_3dp_str_names.pro
;                   and renamed                           [08/10/2009   v2.0.0]
;
;   CREATED:  06/16/2008
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  08/10/2009   v2.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-


Last Modification =>  2009-08-10/18:35:06 UTC
;+
;*****************************************************************************************
;
;  FUNCTION :   dummy_eesa_sst_struct.pro
;  PURPOSE  :   Returns either an Eesa or SST dummy structure appropriate for 
;                 replicating.
;
;  CALLED BY: 
;               dummy_3dp_str.pro
;
;  CALLS:
;               dat_3dp_str_names.pro
;
;  REQUIRES:    
;               NA
;
;  INPUT:
;               NAME   : [string] Specify the type of structure you wish to 
;                          get the data for [i.e. 'el','eh','elb',etc.]
;
;  EXAMPLES:    
;               NA
;
;  KEYWORDS:    
;               NA
;
;   CHANGED:  1)  Added program my_str_names.pro          [08/18/2008   v1.0.2]
;             2)  Updated man page                        [03/19/2009   v1.0.3]
;             3)  Changed program my_str_names.pro to dat_3dp_str_names.pro
;                   and renamed                           [08/10/2009   v2.0.0]
;
;   CREATED:  06/16/2008
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  08/10/2009   v2.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-


Last Modification =>  2009-08-10/18:28:55 UTC
;+
;*****************************************************************************************
;
;  FUNCTION :   dummy_pesa_struct.pro
;  PURPOSE  :   Returns either a Pesa Low or Pesa High dummy structure appropriate for 
;                 replicating.
;
;  CALLED BY: 
;               dummy_3dp_str.pro
;
;  CALLS:
;               dat_3dp_str_names.pro
;               get_??.pro (?? = eh,elb,pl,plb,ph,phb...)
;               get_ph_mapcode.pro
;               get_phb_mapcode.pro
;               pesa_high_dummy_str.pro
;
;  REQUIRES:    NA
;
;  INPUT:
;               NAME   : [string] Specify the type of structure you wish to 
;                          get the data for [i.e. 'el','eh','elb',etc.]
;
;  EXAMPLES:    NA
;
;  KEYWORDS:  
;               INDEX  :  [long] Array of indicies associated w/ data structs
;
;   CHANGED:  1)  Added keyword: INDEX                    [08/18/2008   v1.0.5]
;             2)  Updated man page                        [03/19/2009   v1.0.6]
;             3)  Changed program my_str_names.pro to dat_3dp_str_names.pro
;                   and renamed                           [08/10/2009   v2.0.0]
;
;   CREATED:  06/16/2008
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  08/10/2009   v2.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-


Last Modification =>  2009-08-05/12:50:53 UTC
;+
;*****************************************************************************************
;
;  FUNCTION :   eesa_data_4.pro
;  PURPOSE  :   Takes an array of 3DP moment structures and converts them to
;                 the solar wind reference frame, calculates the pitch-angle
;                 distributions (PADs) and then the full distribution functions.
;                 It returns a structure which has arrays of PADs, DFs, and the
;                 solar wind reference frame 3DP moments.
;
;  CALLED BY: 
;               my_3dp_structs.pro  (or directly by user)
;
;  CALLS:
;               convert_vframe.pro
;               pad.pro
;               distfunc.pro
;               extract_tags.pro
;
;  REQUIRES:    NA
;
;  INPUT:
;               D2  :  An array of 3DP moment structures from either EESA High or
;                        EESA Low (this includes the burst samples too).
;
;  EXAMPLES:
;               eldat = my_3dp_str_call_2('el' ,TRANGE=tr3)
;               ael   = eldat.DATA
;               moms  = eesa_data_4(ael)
;
;  KEYWORDS:  
;               ESTEPS :  Energy bins to use [2-Element array corresponding to first and
;                           last energy bin element or an array of energy bin elements]
;               NUM_PA :  Number of pitch-angles to sum over (Default = 8L)
;               SPIKES :  If set, tells program to look for data spikes and eliminate them
;
;   CHANGED:  1)  got rid of pointers by creating dummy structures
;                  {Need pointers for DISTFUNC.PRO though}
;                  Now calls MY_PAD_DIST.PRO instead of pad.pro and
;                  MY_DISTFUNC.PRO instead of distfunc.pro
;             2)  Changed syntax and updated man page  [11/07/2008   v1.1.22]
;             3)  Updated man page                     [03/21/2009   v1.1.23]
;             4)  Added keywords:  ESTEPS and NUM_PA   [03/21/2009   v1.2.0]
;             5)  Added keyword:  SPIKES               [03/21/2009   v1.2.1]
;             6)  Changed programs called:  convert_vframe.pro, pad.pro, and distfunc.pro
;                                                      [08/05/2009   v2.0.0]
;
;   ADAPTED FROM:   eesa_data_3.pro  BY: Lynn B. Wilson III
;   CREATED:  03/10/2007
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  08/05/2009   v2.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-


Last Modification =>  2009-09-29/21:08:37 UTC
;+
;*****************************************************************************************
;
;  FUNCTION :   eesa_pesa_low_to_psfile.pro
;  PURPOSE  :   This program plots the various quantities produced by the program
;                 eesa_pesa_low_to_tplot.pro and saves them as PS files.
;
;  CALLED BY:   
;               eesa_pesa_low_to_tplot.pro
;
;  CALLS:
;               tnames.pro
;               options.pro
;               get_data.pro
;               time_double.pro
;               my_time_string.pro
;               popen.pro
;               tplot.pro
;               pclose.pro
;
;  REQUIRES:    
;               TPLOT variables created by pesa_low_moment_calibrate.pro and/or
;                 moments_array_3dp.pro
;
;  INPUT:
;               NA
;
;  EXAMPLES:    
;               NA
;
;  KEYWORDS:    
;               DATE      :  [string] 'MMDDYY' [MM=month, DD=day, YY=year]
;               TRANGE    :  [Double] 2-Element array specifying the time range 
;                              of the data to plot for PS files [Unix time]
;               NOMSSG    :  If set, TPLOT will NOT print out the index and TPLOT handle
;                              of the variables being plotted
;
;   CHANGED:  1)  NA [MM/DD/YYYY   v1.0.0]
;
;   NOTES:      
;               1)  This program is meant to be specifically called by 
;                     eesa_pesa_low_to_tplot.pro
;
;   CREATED:  09/29/2009
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  09/29/2009   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-


Last Modification =>  2010-03-07/22:37:28 UTC
;+
;*****************************************************************************************
;
;  FUNCTION :   eesa_pesa_low_to_tplot.pro
;  PURPOSE  :   The purpose of this program is to take an input array of Eesa and/or Pesa
;                 Low data structures (only modified by having previously added the
;                 magnetic field, solar wind velocity, and spacecraft potential to the
;                 structures before calling this routine) and calculate the moments
;                 of the distribution function.  The output depends on a few of the
;                 optional keywords, specifically TO_TPLOT and TO_SAVE.  If TO_TPLOT
;                 is set, then the program creates TPLOT variables for both the Pesa
;                 Low moments and Eesa Low moments.  The Eesa Low moments are calculated
;                 in the spacecraft frame, solar wind frame, and for the halo and core
;                 of the distribution.  The Pesa Low moments are calibrated if in the
;                 presence of a shock.
;
;  CALLED BY:   
;               NA
;
;  CALLS:
;               my_str_date.pro
;               read_shocks_jck_database.pro
;               my_time_string.pro
;               time_string.pro
;               time_double.pro
;               pesa_low_moment_calibrate.pro
;               moments_array_3dp.pro
;               eesa_data_4.pro
;               tnames.pro
;               store_data.pro
;               options.pro
;               eesa_pesa_low_to_psfile.pro
;               my_array_where.pro
;
;  REQUIRES:    
;               UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               NA
;
;  EXAMPLES:    
;               NA
;
;  KEYWORDS:    
;               DATE      :  [string] 'MMDDYY' [MM=month, DD=day, YY=year]
;               TRANGE    :  [Double] 2-Element array specifying the time range over 
;                              which to get data structures for [Unix time]
;               PLM       :  N-Element array of Pesa Low 3DP moment structures.  
;                              This keyword is intended to be used if Pesa Low moments
;                              are available for given time period.
;               PLBM      :  N-Element array of Pesa Low Burst 3DP moment structures.
;                              This keyword is intended to be used if Pesa Low Burst
;                              moments are available for given time period.
;               ELM       :  N-Element array of 3DP Eesa particle data structures from a 
;                              non-burst mode program (e.g. get_el.pro)
;               ELBM      :  M-Element array of 3DP Eesa particle data structuresfrom a 
;                              burst mode program (e.g. get_elb.pro)
;               G_MAGF    :  If set, tells program that the structures in PLM or PLBM
;                              already have the magnetic field added to them thus 
;                              preventing this program from calling add_magf2.pro 
;                              again.
;               TO_TPLOT  :  If set, data quantities are sent to TPLOT
;               TO_SAVE   :  If set, quantities are plotted and saved as PS files
;               SUFFX     :  Scalar string to differentiate TPLOT handles if program
;                              called multiple times
;
;   CHANGED:  1)  Finished writing program and added new program called
;                   eesa_pesa_low_to_psfile.pro for PS files      [09/29/2009   v1.0.1]
;             2)  Fixed issue with 02/11/2000 events              [12/01/2009   v1.1.0]
;             3)  Added information for 10/11/2001, 10/21/2001, 10/25/2001, and
;                   11/24/2001                                    [02/10/2010   v1.2.0]
;             4)  Fixed issue when entering only PLM and ELM but NOT PLBM and ELBM
;                                                                 [02/10/2010   v1.3.0]
;             5)  Added information for 04/23/1998, 04/30/1998, and 05/15/1998
;                                                                 [03/07/2010   v1.4.0]
;
;   NOTES:      
;               1)  At least one of the PLM, PLBM, ELM, or ELBM keywords MUST be set
;
;   CREATED:  09/28/2009
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  03/07/2010   v1.4.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-


Last Modification =>  2011-05-21/00:01:01 UTC
;+
;*****************************************************************************************
;
;  FUNCTION :   eh_cont3d.pro
;  PURPOSE  :   Produces a contour plot of the distribution function (DF) with parallel
;                 and perpendicular cuts shown.  The program is specifically for Eesa
;                 High(Burst) data structures.  {Though I imagine it could be easily
;                 altered to accomodate such structures.}  The contour plot does NOT
;                 assume gyrotropy, so the features in the DF may illustrate 
;                 anisotropies more easily.
;
;  CALLED BY:   
;               NA
;
;  CALLS:
;               str_element.pro
;               extract_tags.pro
;               add_df2d_to_ph.pro
;               contour_3dp_plot_limits.pro
;
;  REQUIRES:    
;               UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               DAT        :  3DP data structure either from get_??.pro
;                               with defined structure tag quantities for VSW and
;                               MAGF
;
;  EXAMPLES:    
;               to      = time_double('1996-04-03/09:47:00')
;               dat     = get_eh(to)
;               str_element,dat,'VSW',REPLICATE(!VALUES.F_NAN,3),/ADD_REPLACE
;               add_magf2,dat,'wi_B3(GSE)'
;               ehm     = moments_3d(dat)
;               dat.VSW = ehm.VELOCITY
;               ..................................
;               :  Plot in electron rest frame   :
;               ..................................
;               eh_cont3d,dat,VLIM=6d4,NGRID=20,/SM_CUTS,NSMOOTH=5
;
;  KEYWORDS:    
;               VLIM       :  Limit for x-y velocity axes over which to plot data
;                               [Default = max vel. from energy bin values]
;               NGRID      :  # of isotropic velocity grids to use to triangulate the data
;                               [Default = 30L]
;               NNORM      :  3-Element unit vector for shock normal direction
;               EX_VEC     :  3-Element unit vector for another quantity like heat flux or 
;                               a wave vector
;               EX_VN      :  A string name associated with EX_VEC
;               SM_CUTS    :  If set, program plots the smoothed cuts of the DF
;                               [Note:  Smoothed to the minimum # of points]
;               DFMIN      :  Set to a scalar value defining the lower limit on the DF 
;                               you wish to plot (s^3/km^3/cm^3)
;                               [Default = 1e-14 (for PH)]
;               NSMOOTH    :  Scalar # of points over which to smooth the DF
;                               [Default = 3]
;               ONE_C      :  If set, program makes a copy of the input array, redefines
;                               the data points equal to 1.0, and then calculates the 
;                               parallel cut and overplots it as the One Count Level
;               DFRA       :  2-Element array specifying a DF range (s^3/km^3/cm^3) for the
;                               cuts of the contour plot
;               CUT_YLIM   :  2-Element array specifying the Y-Axis range for the
;                               parallel/perpendicular cuts plot
;               NDAT       :  Set to a named variable to return the altered data structure
;                               returned by add_df2d_to_ph.pro
;               MAGNETO    :  If set, tells contour_3dp_plot_limits.pro that the data
;                               was taken in the magnetosphere, thus to alter the upper
;                               and lower limits on the distributions
;               VXB_PLANE  :  If set, tells program to plot the DF in the plane defined
;                               by the (V x B) and B x (V x B) directions
;                               [Default:  plane defined by V and B directions set by
;                                           VSW and MAGF structure tags of DAT]
;               VCIRC      :  Scalar value to plot as a circle of constant speed on the
;                               contour plot (km/s) [gyrospeed is useful]
;
;   CHANGED:  1)  Changed plot labels to 1000 km/s              [08/28/2009   v1.0.1]
;             2)  Changed size of usersym output                [08/31/2009   v1.0.2]
;             3)  Added keyword:  ONE_C                         [08/31/2009   v1.1.0]
;             4)  Added keyword:  DFRA and CUT_YLIM             [09/23/2009   v1.2.0]
;             5)  Added keyword:  NDAT                          [09/23/2009   v1.3.0]
;             6)  Updated man page                              [10/14/2009   v1.4.0]
;             7)  Added keyword:  MAGNETO                       [12/10/2009   v1.5.0]
;             8)  Added some error handling if bad data structure passed to program
;                                                               [02/25/2010   v1.6.0]
;             9)  Added keyword:  VXB_PLANE and VCIRC           [03/03/2010   v1.7.0]
;            10)  Changed usage of DFRA keyword                 [09/16/2010   v1.7.1]
;            11)  Changed order of plotting so that the small blue dots are below 
;                   contours                                    [05/20/2011   v1.7.2]
;
;   NOTES:      
;               1)  Make sure that the structure tags MAGF and VSW have finite 
;                    values
;
;   CREATED:  08/27/2009
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  05/20/2011   v1.7.2
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-


Last Modification =>  2009-08-10/17:01:31 UTC
;+
;*****************************************************************************************
;
;  FUNCTION :   energy_params_3dp.pro
;  PURPOSE  :   Returns default #'s of pitch-angles, # of energy bins (-1), and energy
;                 values relative to the type of structure being called for each
;                 instrument.
;
;  CALLED BY:   NA
;
;  CALLS:       NA
;
;  REQUIRES:    NA
;
;  INPUT:  
;               NAME  :  [string,structure] associated with a known 3DP data structure
;                          {i.e. el = get_el() => dat = el, or dat = 'Eesa Low'}
;
;  EXAMPLES:    
;               name = 'pl'
;               myen = energy_params_3dp(name)
;
;               or
;
;               name = get_pl(t)
;               myen = energy_params_3dp(name)
;
;  KEYWORDS:    NA
;
;   CHANGED:  1)  Updated man page                        [11/11/2008   v1.0.2]
;             2)  Changed mynpa for EH and EHB            [02/09/2009   v1.0.3]
;             3)  Rewrote and renamed with more comments  [07/20/2009   v2.0.0]
;             4)  Updated man page                        [08/10/2009   v2.0.1]
;
;   CREATED:  04/10/2008
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  08/10/2009   v2.0.1
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-


Last Modification =>  2009-10-08/17:28:34 UTC
;+
;*****************************************************************************************
;
;  FUNCTION :   energy_remove_split.pro
;  PURPOSE  :   Separates or removes desired energy level data to avoid overlaps
;                and/or bad data which is not removed by other means in stacked
;                spectra plots.  One can remove energy bins (i.e. individual lines)
;                or separate them to form two new TPLOT variables.  This can be
;                very useful for SST data since the low and high energy bins often
;                overlap in flux at times and it can be useful to view them separately.
;
;  CALLED BY:   
;               NA
;
;  CALLS:
;               get_data.pro
;               store_data.pro
;               dat_3dp_energy_bins.pro
;               tnames.pro
;               ytitle_tplot.pro
;               wind_3dp_units.pro
;               options.pro
;               ylim.pro
;
;  REQUIRES:    
;               TPLOT variables associated particle spectra data
;
;  INPUT:
;               NAME       :  [string] Specify the TPLOT name you wish to have the
;                               program remove/split energy bins for
;
;  EXAMPLES:    
;               energy_remove_split,'npl_pads',NEW_NAME1='npl_low',$
;                                   NEW_NAME2='npl_high',/SPLIT,ENERGIES=[0,3]
;               energy_remove_split,'nso_pads_omni',NEW_NAME1='nso_pads_omni_E0-3',$
;                                   ENERGIES=[0,3]
;
;              {Both of the above examples separate the highest 4 energies from
;                the rest, the first case creating two new tplot variables, 
;                the second making only 1 new tplot variable WITHOUT the
;                highest 4 energies.  **Note that entering the scalar value of 
;                4 or LINDGEN(4) would have given the same result for both.**}
;               
;
;  KEYWORDS:    
;               NEW_NAME1  :  New string tplot name for low energies
;               NEW_NAME2  :  {IFF SPLIT set} tplot name for high energies 
;               SPLIT      :  1)  If set, the energy bins defined are removed from
;                                   the initial data structure and put into a
;                                   new data structure which is named NEW_NAME2 and
;                                   the rest of the energy bins are put in NEW_NAME1
;                             2)  If NOT set, the energy bins defined will be 
;                                   completely removed from the tplot variable NAME
;               ENERGIES   :  [Long,Int] array or scaler defining the energy 
;                               levels which are to be either removed or
;                               stored as a new tplot variable separate
;                               from the input name
;
;   CHANGED:  1)  Added program my_ytitle_tplot.pro             [06/22/2008   v1.1.18]
;             2)  Updated man page                              [03/18/2009   v1.1.19]
;             3)  Changed program my_3dp_energy_bins.pro to dat_3dp_energy_bins.pro
;                   and renamed from my_energy_remove_2.pro     [08/11/2009   v2.0.0]
;             4)  Output options for dat_3dp_energy_bins.pro changed, thus requiring a
;                   slightly different syntax                   [08/12/2009   v2.0.1]
;             5)  Rewrote most of program                       [09/30/2009   v3.0.0]
;             6)  Changed program my_ytitle_tplot.pro to ytitle_tplot.pro
;                                                               [10/07/2008   v3.1.0]
;             7)  Fixed order of energy bin labels for SST data [10/08/2008   v3.1.1]
;             8)  Now calls wind_3dp_units.pro and Y-Title now has units
;                                                               [10/08/2008   v3.2.0]
;
;   CREATED:  06/12/2008
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  10/08/2008   v3.2.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-


Last Modification =>  2011-05-01/21:14:27 UTC
;+
;*****************************************************************************************
;
;  FUNCTION :   error_prop_mult.pro
;  PURPOSE  :   Calculates the standard propagation of errors given an input set of data
;                 for up to six variables.
;
;  CALLED BY:   
;               NA
;
;  CALLS:
;               error_prop_form.pro
;
;  REQUIRES:    
;               NA
;
;  INPUT:
;               U  :  [N,2]-Element array of data where U[*,0] is the data and U[*,1]
;                       is the uncertainty in the data
;               V  :  [N,2]-Element array of data where V[*,0] is the data and V[*,1]
;                       is the uncertainty in the data
;               [The rest of the inputs have the same format, but are optional]
;
;  EXAMPLES:    
;               NA
;
;  KEYWORDS:    
;               NA
;
;   CHANGED:  1)  NA [MM/DD/YYYY   v1.0.0]
;
;   NOTES:      
;               
;
;  REFERENCES:  
;               1)  John R. Taylor (1997), "An Introduction to Error Analysis:  The
;                      Study of Uncertainties in Physical Measurements,"
;                      University Science Books.
;
;   CREATED:  05/01/2011
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  05/01/2011   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-


Last Modification =>  2009-09-15/16:43:42 UTC
;+
;*****************************************************************************************
;
;  FUNCTION :  eulerf.pro
;  PURPOSE  :  Given three angles, this program will return the Euler matrix for those
;                input angles [Note: Make sure to define the units using the keywords].
;                The format is specific to match the format given in the Fr�nz paper
;                cited below.
;
;  CALLED BY:   NA
;
;  CALLS:       NA
;
;  REQUIRES:    NA
;
;  INPUT:
;               OMEGA  :  First rotation angle about original z-axis
;               THETA  :  Second rotation angle about X'-Axis
;               PHI    :  Third rotation angle about Z"-Axix
;
;  EXAMPLES:
;
;  KEYWORDS:
;               DEG : If set, tells program the angles are in degrees (default)
;               RAD : If set, tells program the angles are in radians
;
;   CHANGED:  1)  Updated man page                               [09/15/2009   v1.0.1]
;
;  NOTES:  
;               See coord_trans_documentation.txt for explanation of each 
;                 coordinate system.  Calculations come from the paper:
;
;                  M. Fr�nz and D. Harper, "Heliospheric Coordinate Systems," 
;                    Planetary and Space Science Vol. 50, 217-233, (2002).
;
;   CREATED:  07/22/2009
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  09/15/2009   v1.0.1
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-


Last Modification =>  2011-02-15/21:24:24 UTC
;+
;*****************************************************************************************
;
;  FUNCTION :   eulermat.pro
;  PURPOSE  :   Given three angles, this program will return the Euler matrix for those
;                 input angles.  The rotation convention is the following:
;                   1)  rotation by WW about original Z-Axis to new K' coordinates
;                   2)  rotation by TT about X'-Axis to new K" coordinates
;                   3)  rotation by PP about Z"-Axis to new K''' coordinates
;
;  CALLED BY:   
;               NA
;
;  CALLS:
;               NA
;
;  REQUIRES:    
;               NA
;
;  INPUT:
;               PSI  :  Scalar rotation angle about the Z"-Axis
;               PHI  :  Scalar rotation angle about the Z-Axis
;               THE  :  Scalar rotation angle about the X'-Axis
;
;  EXAMPLES:    
;               ;++++++++++++++++++++++++++++++++++++++
;               ; => Rotate 30 degrees about the Z-Axis
;               ;++++++++++++++++++++++++++++++++++++++
;               angle = 3d1
;               zrot  = eulermat(0d0,angle,0d0,/DEG)
;               ;++++++++++++++++++++++++++++++++++++++
;               ; => Rotate 30 degrees about the X-Axis
;               ;++++++++++++++++++++++++++++++++++++++
;               angle = 3d1
;               xrot  = eulermat(0d0,0d0,angle,/DEG)
;               ;++++++++++++++++++++++++++++++++++++++
;               ; => Rotate 30 degrees about the Y-Axis
;               ;++++++++++++++++++++++++++++++++++++++
;               angle = 3d1
;               yrot  = eulermat(0d0,-9d1,0d0,/DEG) ## eulermat(0d0,9d1,angle,/DEG)
;
;  KEYWORDS:    
;               DEG  :  If set, angles are assumed to be in degrees [Default]
;               RAD  :  If set, angles are assumed to be in radians
;
;   CHANGED:  1)  Fixed up man page                                 [05/10/2007   v1.0.2]
;             2)  Added keyword:  DEG                               [05/11/2007   v1.0.3]
;             3)  Added keyword:  RAD                               [05/11/2007   v1.0.4]
;             4)  Fixed a typo in output message                    [09/23/2008   v1.0.5]
;             5)  Cleaned up                                        [02/15/2011   v1.1.0]
;
;   NOTES:      
;               1)  Default units for angles are degrees
;
;   CREATED:  04/30/2007
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  02/15/2011   v1.1.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-


Last Modification =>  2010-10-26/10:59:50 UTC
;+
;*****************************************************************************************
;
;  FUNCTION :   excited_cold_lhw.pro
;  PURPOSE  :   Attempts to calculate the wave normal surface for an arbitrary propagation
;                 angle with respect to the magnetic field.  The program also calculates
;                 some parameters determined by Bell and Ngo, [1990] 
;                 {see reference below} to determine possible propagation surfaces for
;                 different wave properties and environments (i.e. density and B-field
;                 strength).
;
;  CALLED BY:   
;               NA
;
;  CALLS:
;               cold_plasma_params.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               MAGF   :  1-Element array of magnetic field magnitudes [nT]
;               DENS   :  " " plasma densities [cm^(-3)]
;               F0(1)  :  Lower(Upper) frequency bound [Hz]
;
;  EXAMPLES:    
;               no        = 14.147
;               bo        = 17.279
;               f0        = 150.0
;               f1        = 200.0
;               ndat      = 1000L
;               kvec      = [-0.07895,-0.99658, 0.02448]
;               bvec      = [0.053,0.979,-0.197]
;               nvec      = [-0.655,0.040,-0.754]
;               test      = excited_cold_lhw(bo,no,f0,f1,NDAT=ndat,NVEC=nvec,BVEC=bvec,KVEC=kvec)
;               ; => Determine wave propagation angle with respect to magnetic field
;               kvec      = kvec/NORM(kvec)
;               bvec      = bvec/NORM(bvec)
;               thkb      = ACOS(my_dot_prod(kvec,bvec,/NOM))
;               PRINT, thkb*18d1/!DPI
;                      169.94078
;               ; => Now define wave normal surfaces
;               nsurf0    = test.NSURF_STIX92.FLOW
;               nsurf1    = test.NSURF_STIX92.FHIGH
;               ; => remember the angle is from z-axis, NOT x-axis so rotate!
;               anglew    = DINDGEN(ndat)*(2d0*!DPI)/(ndat - 1L) + !DPI/2d0
;               ; => Now plot wave normal surface with k-vector overplotted
;               WINDOW,0,RETAIN=2,XSIZE=850,YSIZE=800
;               xyra = [-1.1*MAX(ABS(nsurf0),/NAN),1.1*MAX(ABS(nsurf0),/NAN)]
;               pstr = {POLAR:1,NODATA:1,YRANGE:xyra,XRANGE:xyra,XSTYLE:1,YSTYLE:1}
;               PLOT,REFORM(ABS(nsurf0[*,0])),anglew,_EXTRA=pstr
;                 OPLOT,REFORM(ABS(nsurf0[*,0])),anglew,/POLAR,COLOR=30
;                 OPLOT,[0d0,xyra[1]],[0d0,!DPI/2d0 - thkb[0]],/POLAR,COLOR=250
;               
;
;  KEYWORDS:    
;               NDAT   :  Scalar number of values to create for dummy frequencies or
;                           angles
;               CHI    :  Scalar angle (deg) that defines the angle between the ambient
;                           magnetic field vector and the surface of the density irreg.
;                           [e.g. for a shock surface, chi = 90 - theta_Bn]
;               NVEC   :  3-Element array corresponding to the unit vector normal
;                           to the density irreg. surface
;               BVEC   :  3-Element array corresponding to the magnetic field unit 
;                           vector
;               KVEC   :  3-Element array corresponding to the wave propagation
;                           unit vector
;
;   CHANGED:  1)  Fixed a typo in n^2 root finding loop            [10/26/2010   v1.0.1]
;
;   NOTES:      
;               1)  The calculations in this program are referenced to either:
;                   A.
;                     T.F. Bell and H.D. Ngo (1990), "Electrostatic Lower Hybrid Waves
;                       Excited by Electromagnetic Whistler Mode Waves Scattering from
;                       Planar Magnetic-Field-Aligned Plasma Density Irregularities,"
;                       J. Geophys. Res. Vol. 95, pg. 149-172.
;                   B.
;                     T.H. Stix (1992), "Waves in Plasmas," Springer-Verlag,
;                       New York, Inc.
;               2)  The keywords NVEC, BVEC, and KVEC must be used together if used
;                     at all
;               3)  Coordinate system is as follows:
;                     X'  =  parallel to normal vector of density irreg. plane
;                     Z'  =  parallel to ambient magnetic field
;                     Y'  =  (Z x X)
;
;   CREATED:  10/22/2010
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  10/26/2010   v1.0.1
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-


Last Modification =>  2010-06-21/14:21:19 UTC
;+
;*****************************************************************************************
;
;  FUNCTION :   exponential_round.pro
;  PURPOSE  :   Takes a scalar or array of exponential numbers and returns the 
;                 exponentials with rounded leading factors.  For example, if one
;                 sends in 1.13383934d-6, the program will return 1.0000000e-06.
;                 This is useful for determining tick values for log-scaled plots
;                 or contour levels.
;
;  CALLED BY:   
;               contour_3dp_plot_limits.pro
;
;  CALLS: 
;               roundsig.pro
;               interp.pro
;
;  REQUIRES:    
;               NA
;
;  INPUT:
;               XX      :  N-Element array of single or double precision values
;
;  EXAMPLES:    
;               NA
;
;  KEYWORDS:    
;               SIGFIG  :  Scalar long/integer defining the number of significant
;                            figures to round factors to
;
;   CHANGED:  1)  Fixed issue arising from too many similar leading factors
;                                                                  [09/01/2009   v1.0.1]
;             2)  Changed exponent calculation and removed while loop
;                                                                  [09/18/2009   v1.1.0]
;             3)  Altered the number of times the program can be re-called
;                                                                  [09/23/2009   v1.2.0]
;             4)  Added error handling to attempt to deal with non-finite input
;                                                                  [05/05/2010   v1.3.0]
;             5)  Got rid of error message for non-finite input
;                                                                  [05/12/2010   v1.3.1]
;             6)  Updated man page, changed factor calculation and many more things,
;                   and added keyword:  SIGFIG                     [06/21/2010   v1.4.0]
;
;   NOTES:      
;               1)  This program is most useful if XX is a range of data values
;
;   CREATED:  08/31/2009
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  06/21/2010   v1.4.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-


Last Modification =>  2009-02-25/15:41:27 UTC
;+
;*****************************************************************************************
;
;  FUNCTION : fft_bandpass.pro
;  PURPOSE  :  The program returns the FFT filtered data, separated into low 
;               and high frequency bands (defined by user in program).  The data
;               is then used to calculate new power specturms and new frequency bin
;               values.  
;
;  CALLS:  fft_power_calc.pro
;
;  REQUIRES:  NA
;
;  INPUT:
;             TX   :   Time array (s) associated with input signal
;             EF   :   Input signal(data) which is to be filtered/split into
;                        low/high frequency bands
;
;  EXAMPLES:  flow_high = fft_bandpass(ef,tx,LOWF_CUT=5.)  ; -to separate at 5 kHz
;
;  KEYWORDS:
;             LOWF_CUT  :  Set to a value that is between the low and high
;                           frequency (kHz) limits of your frequency array.  If
;                           you set to 'q', a dummy structure will be returned 
;                           of the same form as the actual structure returned 
;                           when data is input correctly. 
;             BANDPASS  :  Set to a 2-Element array corresponding to a frequency
;                           range (kHz) that tells the program to separate from the
;                           rest of the data.  If this keyword is set, it will return
;                           the data within the frequency range as the 'LOWF_*' tags
;                           and the data outside the frequency range as the 
;                           'HIGHF_*' tags in the structure.
;
;   CHANGED:  1)  Fixed frequency bin separation          [09/09/2008   v1.0.10]
;             2)  Changed auto frequency and time scaling [09/10/2008   v1.0.10]
;             3)  Added keyword bandpass                  [09/11/2008   v1.0.11]
;             4)  Fixed reverse FFT calc for low Freq.    [02/25/2009   v1.0.12]
;
;   CREATED:  08/21/2008
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  02/25/2009   v1.0.12
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-


Last Modification =>  2011-05-23/21:50:15 UTC
;+
;*****************************************************************************************
;
;  FUNCTION :   fft_movie.pro
;  PURPOSE  :   Outputs a MPEG movie (.mov), of a sliding FFT of a timeseries data.
;
;  CALLED BY:   
;               NA
;
;  CALLS:
;               my_windowf.pro
;               power_of_2.pro
;               vector_bandpass.pro
;               extract_tags.pro
;               tplot_struct_format_test.pro
;
;  REQUIRES:    
;               1)  ffmpeg for Unix
;               2)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               TIME        :  N-Element array of times [seconds]
;               TIMESERIES  :  N-Element array of data [units]
;               FFTLENGTH   :  Scalar number of points of timeseries data to be used in 
;                                each FFT
;               FFTSTEP     :  Scalar number of points to shift FFT window
;                                [Default = 0.05*FFTLENGTH]
;
;  EXAMPLES:    
;               ==================================================================
;               ; => Look at a Sawtooth Wave
;               ==================================================================
;               sr         = 1d0/0.092009201d0          ; => Sample rate (Hz)
;               tt         = DINDGEN(2L^14)/sr + 1d0    ; => Times (s)
;               tsaw       = tt
;               xsaw       = 2d0*(tsaw/5d1 - FLOOR(tsaw/5d1 + 5d-1))
;               fftlength  = 1024L
;               fftstep    = 4L
;               frange     = [1e-3,2e0]                 ; => Frequency Range (Hz)
;               fft_movie,tsaw,xsaw,fftlength,fftstep,/SCREEN,FRANGE=frange
;
;  KEYWORDS:    
;               MOVIENAME   :  Scalar string defining the name of the movie created
;                                by the program
;               SCREEN      :  If set, program plots snapshots to X-Window display,
;                                otherwise movies are generated from PNG captures 
;                                of Z buffer plots
;               FULLSERIES  :  If set, program creates plots of full time series
;                                range instead of zoomed-in plots of time ranges
;               [XY]SIZE    :  Scalar values defining the size of the output windows
;                                Defaults:  
;                                          [800 x 600]     : if plotting to screen
;                                          [10.2" x 6.99"] : if plotting to PS files
;               FFT_ARRAY   :  Set to a named variable to return the windowed FFT
;               NO_INTERP   :  If set, data is not interpolated to save time when
;                                creating a movie
;               EX_FREQS    :  Structure with a TPLOT format containing:
;                          { X:([N]-Unix Times),Y:([N,M]-Element array of frequencies) }
;                                to overplot on the FFT power spectra
;                                [e.g. the cyclotron frequency]
;                                [IF N = 1, then use the same value for all windows]
;               EX_LABS     :  M-Element string array of labels for the frequency
;                                inputs given by the EX_FREQS keyword
;               FRANGE      :  2-Element float array defining the freq. range
;                                to use when plotting the power spec (Hz)
;                                [min, max]
;               PRANGE      :  2-Element float array defining the power spectrum
;                                Y-Axis range to use [min, max]
;               WSTRUCT     :  Set to a plot structure with relevant info for waveform
;                                plot [Used by PLOT.PRO with _EXTRA keyword]
;               FSTRUCT     :  Set to a plot structure with relevant info for power
;                                spectrum plot [Used by PLOT.PRO with _EXTRA keyword]
;
;   CHANGED:  1)  NA [MM/DD/YYYY   v1.0.0]
;
;   NOTES:      
;               1)  Need to have ImageMagick with ffmpeg prior to running this routine
;               2)  If you use EX_FREQS, make sure the times in the X structure tag
;                     overlap with the input TIME
;
;   CREATED:  05/23/2011
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  05/23/2011   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-


Last Modification =>  2009-08-10/22:06:44 UTC
;+
;*****************************************************************************************
;
;  FUNCTION :   fft_power_calc.pro
;  PURPOSE  :    Returns the FFT power spectrum from an input array of vectors.  
;                  The power spectrum can be calculated using windowing by setting
;                  the keyword READ_WIN.  The frequency bins (Hz) associated with
;                  the power spectrum are returned too, along with a Y-scale 
;                  estimate for plotting routines.
;
;  CALLS:  
;               my_windowf.pro
;               power_of_2.pro
;
;  REQUIRES:    NA
;
;  INPUT:       
;               TT     :  times (s) associated with vector data [DBLARR]
;               DAT    :  [n] array of vectors
;
;  EXAMPLES:    NA
;
;  KEYWORDS:  
;               READ_WIN :   If set, program uses windowing for FFT calculation
;               RANGE    :   2-element array defining the start and end point elements
;                              to use for plotting the data
;               FORCE_N  :  Set to a scalar (best if power of 2) to force the program
;                              my_power_of_2.pro return an array with this desired
;                              number of elements [e.g.  FORCE_N = 2L^12]
;               SAMP_RA  :  Set to a scalar defining the sample rate of data if odd time
;                              series is sent in (make sure units are consistent)
;
;   CHANGED:  1)  Forced 1D data entry          [09/25/2008   v1.2.0]
;             2)  Changed logic statement       [09/29/2008   v1.2.1]
;             3)  Fixed prime # issue near 2^15 [11/04/2008   v1.2.2]
;             4)  Fixed indexing issue in 3)    [11/05/2008   v1.2.3]
;             5)  Changed output to return ONLY arrays that have powers of 2 for 
;                  # of elements                [11/20/2008   v3.0.0]
;             6)  Fixed scaling issue in 5)     [11/21/2008   v3.0.1]
;             7)  Fixed windowing issue in 6)   [11/21/2008   v3.0.2]
;             8)  Fixed scaling issue in 7)     [11/22/2008   v3.0.3]
;             9)  Changed output structure      [11/22/2008   v3.1.0]
;             10) Added KEYWORD:   FORCE_N      [11/22/2008   v3.1.1]
;             11) Changed some syntax           [12/03/2008   v3.1.2]
;             12) Added KEYWORD:   SAMP_RA      [04/06/2009   v3.1.3]
;             13) Changed program my_power_of_2.pro to power_of_2.pro
;                                               [08/10/2009   v3.2.0]
;
;   CREATED:  08/26/2008
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  08/10/2009   v3.2.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-


Last Modification =>  2009-09-17/14:59:09 UTC
;+
;*****************************************************************************************
;
;  FUNCTION :   field_rot.pro
;  PURPOSE  :   Calculates a rotation matrix used to rotate into field-aligned
;                 coordinates.  The first vector will be rotated to the new
;                 z'-axis and the second vector will rotate to the x'z'-plane
;
;  CALLED BY:   NA
;
;  CALLS:
;               my_crossp_2.pro
;
;  REQUIRES:    NA
;
;  INPUT:
;               T1  :  [n,3] or [3,n] element array of vectors
;                        {where : n=1, or 2, or 3,...}
;               T2  :  [n,3] or [3,n] element array of vectors
;
;  EXAMPLES:
;               x      = FLTARR(3,5)
;               x[0,*] = FINDGEN(5)*1.28*!PI - 34.2*(FINDGEN(5)+12.2)
;               x[1,*] = FINDGEN(5)*12.28*!PI - 3.2*(FINDGEN(5)+1.2)
;               x[2,*] = FINDGEN(5)*120.28*!PI - 78.2*(FINDGEN(5)+0.2)
;               x2     = [2.4,-33.11,29.8]
;               y2     = REPLICATE(1.,5) # x2
;               z      = field_rot(x,y2)
;
;  KEYWORDS:
;               NOMSSG  :  If set, the program will NOT print out a message about the
;                            running time of the program.  This is particularly useful
;                            when calling the program multiple times in a loop.
;
;   CHANGED:  1)  Eliminated dependence on my_magnitudes.pro [09/11/2008   v1.1.11]
;             2)  Changed normalization and rotation method [same functionality]
;                                                            [09/11/2008   v1.2.0]
;             3)  Fixed an error in my math                  [09/19/2008   v1.2.1]
;             4)  Updated man page                           [03/22/2009   v1.2.2]
;             5)  Added keyword:  NOMSSG                     [04/17/2009   v1.2.3]
;             6)  Changed some syntax and removed dependency on my_dimen_force.pro
;                                                            [09/17/2009   v1.3.0]
;
;   CREATED:  06/10/2008
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  09/17/2009   v1.3.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-


Last Modification =>  2011-03-02/22:36:57 UTC
;+
;*****************************************************************************************
;
;  FUNCTION :   file_name_times.pro
;  PURPOSE  :   Returns strings of UT time stamps in a format that is suitable for
;                 file saving.  For example, if you wanted to save a data plot
;                 that showed data for 1995-01-01/10:00:00.101 UT, the program
;                 would produce a string of the form:
;                 '1995-01-01_1000x00.101'
;
;  CALLED BY:   
;               NA
;
;  CALLS:
;               my_time_string.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               TT    :  N-Element array of UT[string] or Unix[double] times
;
;  EXAMPLES:    
;               tnrt = '1998-09-24/21:40:00'
;               PRINT, file_name_times(tnrt[0],PREC=5)
;               { 1998-09-24_214000.00000
;               1998-09-24/21:40:00.00000
;                  9.0667320e+08
;               21:40:00.00000
;               1998-09-24
;               }
;
;  KEYWORDS:    
;               PREC    :  Scalar defining the number of decimal places to use for the
;                            fractional seconds
;                            [Default = 4, limit to 6 or less]
;               FORMFN  :  Scalar integer defining the output form of the F_TIME tag
;                            For the following SCET:  '2000-04-10/15:10:33.013'
;                            1 = '2000-04-10_1510x33.013'  [Default]
;                            2 = '2000-04-10_1510-33x013'
;
;   CHANGED:  1)  Fixed typo in FTIME calculation                [10/25/2010   v1.0.1]
;             2)  Added keyword:  FORMFN                         [03/02/2011   v1.1.0]
;
;   NOTES:      
;               
;
;   CREATED:  10/13/2010
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  03/02/2011   v1.1.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-


Last Modification =>  2009-09-14/22:07:56 UTC
;+
;*****************************************************************************************
;
;  FUNCTION :   floating_fft_power_spec.pro
;  PURPOSE  :   Calculates the floating FFT of an input signal and returns a structure
;                 containing the dynamic power spectrum.  The calculation assumes a
;                 half overlap of the floating FFT windows.
;
;  CALLED BY:   
;               fft_window_spec.pro
;
;  CALLS:
;               fft_power_calc.pro
;
;  REQUIRES:  
;               NA
;
;  INPUT:
;               TT  :  Time (s) associated with EE
;               EE  :  N-Element array of data to be used for floating FFT
;               WX  :  Fractional Width of the window to use for floating FFT
;                        window (try to make this so that the resulting window
;                        has 2^N elements, where N is an integer)
;
;  EXAMPLES:
;               NA
;
;  KEYWORDS:  
;               NA
;
;   CHANGED:  1)  Fixed array size/element issue for TPLOT        [09/27/2008   v1.0.1]
;             2)  Eliminated fft_power_calc.pro dependence        [10/07/2008   v1.1.0]
;             3)  Changed freq. bin # calculation                 [10/16/2008   v1.1.1]
;             4)  Changed windowf.pro to my_windowf.pro           [10/16/2008   v1.1.2]
;             5)  Changed floating FFT window width calc          [10/27/2008   v1.2.0]
;             6)  Fixed some syntax errors                        [11/02/2008   v1.2.1]
;             7)  Changed floating FFT window calc                [11/02/2008   v1.3.0]
;             8)  Fixed an indexing issue                         [11/03/2008   v1.3.1]
;             9)  Re-wrote program                                [04/06/2009   v2.0.0]
;            10)  Renamed from my_float_fft_spec.pro              [09/10/2009   v3.0.0]
;            11)  Added generalized forced number of points to compute in FFT
;                                                                 [09/14/2009   v3.0.1]
;
;   CREATED:  09/25/2008
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  09/14/2009   v3.0.1
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-


Last Modification =>  2009-09-10/22:16:39 UTC
;+
;*****************************************************************************************
;
;  FUNCTION :   format_structure.pro
;  PURPOSE  :   Determines the data types and formats of a format statement then returns
;                 a structure with all the relevant information regarding the format
;                 statement [possibly useful for reading in multiple files].
;
;  CALLED BY:
;               tds_hk_ascii_sort.pro
;
;  CALLS:
;               NA
;
;  REQUIRES:
;               NA
;
;  INPUT:
;               MFORMS  :  Format of file to be read in and sorted
;                          [must have form of:  '(12a20,...)' aka typical format 
;                           statement]
;
;  EXAMPLES:
;               NA
;
;  KEYWORDS:
;               NA
;
;   CHANGED:  1)  Renamed from my_format_structure.pro              [09/10/2009   v2.0.0]
;
;   CREATED:  03/17/2009
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  09/10/2009   v2.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-


Last Modification =>  2011-04-20/15:07:19 UTC
;+
;*****************************************************************************************
;
;  FUNCTION :   fourier_filter.pro
;  PURPOSE  :   Performs a Fourier filter where the return result is a low-pass filter
;                 with NKEEP-Fourier modes.
;
;  CALLED BY:   
;               NA
;
;  CALLS:
;               power_of_2.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               XX      :  N-Element array of data to be filtered
;               NKEEP   :  Scalar defining the number of Fourier frequency bins to keep
;                            when performing the low-pass filter
;
;  EXAMPLES:    
;               ; => keep lowest 10 frequencies and pad with zeros
;               test = fourier_filter(xx,10L,/PAD)
;
;  KEYWORDS:    
;               PAD     :  If set, program pads the input array with zeros
;
;   CHANGED:  1)  Fixed an issue that occurred when N was an odd # [04/20/2011   v1.0.1]
;
;   NOTES:      
;               
;
;   CREATED:  04/19/2011
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  04/20/2011   v1.0.1
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-


Last Modification =>  2011-02-18/18:00:04 UTC
;+
;*****************************************************************************************
;
;  FUNCTION :   get_3dp_structs.pro
;  PURPOSE  :   This program retrieves the data structures from the 3DP Wind binary
;                 files associated with the user input name (e.g. 'el').  It then
;                 alters the structures slightly to prevent conflicting data structure
;                 errors when using them in other programs.  It also eliminates
;                 structures which have dat.VALID = 0 from the array of structures
;                 returned to the user.  The output structure consists of an array of
;                 start and end times associated with the 3DP structures (Unix times)
;                 and an array of 3DP data structures.  WindLib rotates the data into
;                 GSE coordinates before the user is allowed to do anything with the
;                 structures, thus when adding magnetic fields or velocities to the
;                 data structures, make sure they are in GSE coordinates.
;
;  CALLED BY:   
;               NA
;
;  CALLS:
;               dat_3dp_str_names.pro
;               interp.pro
;               gettime.pro
;               dummy_3dp_str.pro
;               str_element.pro
;               get_??.pro (?? = eh,elb,pl,plb,ph,phb...)
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               MYN1    : [string] Specify the type of structure you wish to 
;                           get the data for [i.e. 'el','eh','elb',etc.]
;
;  EXAMPLES:    
;               tr  = time_double(['1996-04-06/10:00:00','1996-04-07/10:00:00'])
;               dat = get_3dp_structs('el',TRANGE=tr)
;               els = dat.DATA    ; -All Eesa Low structures in given time range
;
;  KEYWORDS:    
;               TRANGE  :  [Double] 2 element array specifying the range over 
;                            which to get data structures [Unix time]
;
;   CHANGED:  1)  Altered calling method for 3DP structures [08/18/2008   v1.1.20]
;             2)  Updated man page                          [03/18/2009   v1.1.21]
;             3)  Changed program my_dummy_str.pro to dummy_3dp_str.pro
;                   and my_str_names.pro to dat_3dp_str_names.pro
;                   and renamed                             [08/10/2009   v2.0.0]
;             3)  Changed some minor syntax ordering and added error handling for events
;                   with no structures available            [08/20/2009   v2.0.1]
;             4)  Changed to accomodate new structure formats that involve the tag
;                   name CHARGE                             [08/28/2009   v2.1.0]
;             5)  Fixed an indexing issue that only arose under very rare conditions
;                                                           [02/18/2011   v2.1.1]
;
;   NOTES:      
;               
;
;   CREATED:  04/10/2008
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  02/18/2011   v2.1.1
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-


Last Modification =>  2010-11-29/16:11:44 UTC
;+
;*****************************************************************************************
;
;  FUNCTION :   get_padspecs.pro
;  PURPOSE  :   Creates a particle spectra "TPLOT" variable by summing 3DP data over 
;                 selected angle bins.  The output is a structure which has the format:
;
;               {YTITLE:[string],X:[times(n)],Y:[data(n,m,l)],V1:[energy(n,m)],
;                V2:[pangls(n,l)],'YLOG':1,'PANEL_SIZE':2.0}
;               WHERE:  n = # of 3D data structures
;                       m = # of energy bins in each 3D data structure
;                       l = # of pitch-angles chosen by the keyword NUM_PA
;
;  CALLED BY: 
;               calc_padspecs.pro
;               write_padspec_ascii.pro
;
;  CALLS:
;               dat_3dp_str_names.pro
;               gettime.pro
;               interp.pro
;               minmax.pro
;               get_3dp_structs.pro
;               pesa_high_str_fill.pro
;               add_magf2.pro
;               dat_3dp_energy_bins.pro
;               sst_foil_bad_bins.pro
;               data_cut.pro
;               convert_vframe.pro
;               str_element.pro
;               conv_units.pro
;               pad.pro
;               store_data.pro
;
;  REQUIRES:  
;               "LOAD_3DP_DATA" must be called first to load up WIND data.
;
;  INPUT:
;               DATA_STR  :  [string] Specify the type of structure you wish to 
;                               get the data for [i.e. 'el','eh','elb',etc.]
;
;  EXAMPLES:
;               get_padspecs,name,BSOURCE='wi_B3(GSE)',NUM_PA=mynpa,vsource=vsw,$
;                            UNITS=gunits,TRANGE=trange,DAT_ARR=dat_arr,        $
;                            G_MAGF=g_magf,STORE_RE=store_re
;
;  KEYWORDS:  
;               BINS      :  -Keyword telling which data bins to sum over
;               GAP_TIME  :  -Time gap big enough to signify a data gap (def 200)
;               NO_DATA   :  -Returns 1 if no_data else returns 0
;               UNITS     :  -Convert to these units if included
;               NAME      :  -New name of the Data Quantity
;               BKG       :  -A 3d data structure containing the background counts.
;               MISSING   :  -Value for bad data.
;               BSOURCE   :  -String associated with TPLOT variable for magnetic field
;               VSOURCE   :  -String associated with TPLOT variable for solar wind
;                              velocity vector
;               ETHRESH   :  -A threshold for the energy bins to use
;               TRANGE    :  [Double] 2 element array specifying the range over 
;                              which to get data structures [Unix time]
;               NUM_PA    :  Number of pitch-angles to sum over 
;                              [Default = defined by instrument]
;               FLOOR     :  -Sets the minimum value of any data point to sqrt(bkg).
;               BKGBINS   :  -Array of energy which bins to sum over
;               ENBINS    :  -A 2-element array, single integer/long, or an array
;                              of values specifying which energy bins to use when
;                              creating the pitch-angle distributions (PADs)
;               STORE_RE  :  -If set, the function will return the data structure to
;                              the user, but will NOT store that data as a TPLOT
;                              variable.  Set as a named variable for returning data.
;               DAT_ARR   :  N-Element array of data structures from get_??.pro
;                              [?? = 'el','eh','elb',etc.]
;               G_MAGF    :  If set, tells program that the structures in DAT_ARR 
;                              already have the magnetic field added to them thus 
;                              preventing this program from calling add_magf2.pro 
;                              again.
;               NO_KILL   :  If set, get_padspecs.pro will NOT call the routine
;                              sst_foil_bad_bins.pro
;
;  CHANGED:   1)  Changed the functionality/robustness            [08/18/2008   v1.2.35]
;             2)  Altered manner in which pads are dealt with for 
;                   EESA High                                     [02/09/2009   v1.2.36]
;             3)  Updated man page                                [03/18/2009   v1.2.37]
;             4)  Added keyword:  DAT_ARR                         [04/24/2009   v1.3.0]
;             5)  Rewrote most of program                         [04/24/2009   v2.0.0]
;             6)  Changed my_pesa_high_str_fill.pro calling sequence
;                                                                 [04/26/2009   v2.0.1]
;             7)  Added keyword:  G_MAGF                          [04/26/2009   v2.0.2]
;             8)  Fixed syntax error                              [04/30/2009   v2.0.3]
;             9)  Fixed syntax error                              [06/01/2009   v2.0.4]
;            10)  Changed program my_3dp_energy_bins.pro to dat_3dp_energy_bins.pro
;                   and my_str_names.pro to dat_3dp_str_names.pro
;                                                                 [08/05/2009   v2.1.0]
;            11)  Changed program my_pad_dist.pro to pad.pro
;                   and renamed from get_padspec_5.pro            [08/10/2009   v2.2.0]
;            12)  Changed program my_3dp_str_call_2.pro to get_3dp_structs.pro
;                                                                 [08/12/2009   v2.3.0]
;            13)  Updated 'man' page                              [10/05/2008   v2.3.1]
;            14)  Changed program my_pesa_high_str_fill.pro to pesa_high_str_fill.pro
;                   and added program:  sst_foil_bad_bins.pro     [02/13/2010   v2.4.0]
;            15)  Added keyword:  NO_KILL                         [02/25/2010   v2.5.0]
;            16)  Added some error handling to deal with BINS keyword
;                                                                 [11/23/2010   v2.5.1]
;            17)  Fixed typo in previous addition                 [11/29/2010   v2.5.2]
;
;   ADAPTED FROM: get_padspec.pro    BY: Davin Larson
;   CREATED:  ??/??/????
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  11/29/2010   v2.5.2
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-


Last Modification =>  2010-04-18/23:48:42 UTC
;+
;*****************************************************************************************
;
;  FUNCTION :   grid_data_contour.pro
;  PURPOSE  :   Takes three arrays of irregularly gridded data and produces a contour
;                 plot of the results.
;
;  CALLED BY:   
;               NA
;
;  CALLS:
;               roundsig.pro
;               popen.pro
;               pclose.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               X        :  N-Element array of abscissa values of X-coordinate for 
;                             F(x,y) [i.e. x data]
;               Y        :  N-Element array of abscissa values of Y-coordinate for 
;                             F(x,y) [i.e. y data]
;               F        :  N-Element array of the values of the function at points 
;                             (x[i],y[i])  [i.e. z data]
;
;  EXAMPLES:    
;               grid_data_contour,x,y,f,NLEVELS=10,TITLE='Contour Plot'
;
;  KEYWORDS:    
;               NLEVELS  :  Scalar long/integer defining the number of contour levels
;               TITLE    :  Scalar string defining the plot title
;               XTITLE   :  Scalar string defining X-Axis plot title
;               YTITLE   :  Scalar string defining Y-Axis plot title
;               FNAME    :  If set, defines file name of PS file (if FSAVE set)
;               FSAVE    :  If set, program saves plot to PS file
;               XRANGE   :  2-Element array defining X-Axis data range to plot
;               YRANGE   :  2-Element array defining Y-Axis data range to plot
;               XLOG     :  If set, X-Axis is plotted on a log-scale
;               YLOG     :  If set, Y-Axis is plotted on a log-scale
;
;   CHANGED:  1)  Fixed typo in NLEVELS keyword               [04/18/2010   v1.0.1]
;
;   NOTES:      
;               
;
;   CREATED:  04/15/2010
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  04/18/2010   v1.0.1
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-


Last Modification =>  2009-08-28/19:39:45 UTC
;+
;*****************************************************************************************
;
;  FUNCTION :   hodo_plot.pro
;  PURPOSE  :   Takes two arrays of data which represent two components of a 3D vector
;                 and plots 9 hodograms, evenly distributing the number of points on
;                 each.
;
;  CALLED BY:   
;               wi_tdss_hodo.pro
;               etc.
;
;  CALLS:
;               NA
;
;  REQUIRES:    
;               NA
;
;  INPUT:
;               V1       :  N-Element array for one component of a vector array of data
;               V2       :  N-Element array for one component of a vector array of data
;                             (obviously not the same as V1)
;
;  EXAMPLES:    
;               NA
;
;  KEYWORDS:    
;               XYSCALE  :  Scalar value used to force the XY-Axes to a specified
;                             scale that may depend on another component not
;                             used in this specific plot. 
;                             [Default = MAX(ABS([V1,V2]),/NAN)]
;               FNAME    :  Scalar string used to define the file name one wishes to
;                             name the file when saving
;               XTTL     :  Scalar string defining the X-Axis Title
;                             [Default = 'Component-X']
;               YTTL     :  Scalar string defining the Y-Axis Title
;               VECNAME  :  Scalar string defining the vector name
;                             [Default = 'Component']
;               VNAMES   :  3-Element string array used to define the vector components
;                             to use when labeling plots/axes
;                             [Default = ('x','y','z')]
;               UNITS    :  Scalar string defining the units, if relevant, for the
;                             data being plotted
;                             [Default = '']
;               CHAN1    :  ['x','y','z'] for Channel [1,2,3] respectively, corresponding
;                             to the data being plotted on the X-Axis AND the first 
;                             necessary data input
;               CHAN2    :  ['x','y','z'] for Channel [1,2,3] respectively, corresponding
;                             to the data being plotted on the Y-Axis AND the second
;                             necessary data input
;                             **[CHAN1 Default = 'x', CHAN2 Default = 'y']**
;               TITLES   :  9-Element string array defining the plot titles to use
;                             [Default = string array specifying which elements
;                              are being plotted]
;               FSAVE    :  If set, the device is set to 'ps' thus saving file as a 
;                             *.ps file.  If NOT set, then the device is left as 'x'
;                             making it possible to plot to the screen for checking and
;                             user manipulation.
;
;   CHANGED:  1)  Updated man page                            [08/10/2009   v1.0.1]
;             2)  Forgot to include use of UNITS keyword      [08/28/2009   v1.0.2]
;
;   CREATED:  08/04/2009
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  08/28/2009   v1.0.2
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-


Last Modification =>  2010-03-15/20:02:54 UTC
;+
;*****************************************************************************************
;
;  FUNCTION :   hodo_rot_vecs.pro
;  PURPOSE  :   This program takes two input angles, a start and end angle, and creates
;                 an array of angles in between these two angles at the specified
;                 times given by the user.  The angle arrays are created by linear
;                 interpolation and the user is returned a structure with both
;                 interpolated data and rotated interpolated data.  The structure
;                 also contains the rotation matricies used.
;
;  CALLED BY:   
;               tds_bfield.pro
;
;  CALLS:
;               interp.pro
;               my_dot_prod.pro
;
;  REQUIRES:    
;               NA
;
;  INPUT:
;               TDS_T   :  [N,V]-Element array of TDS event times (Unix)
;               TDS_SA  :  N-Element array of start angles to rotate VEC1 by (deg)
;               TDS_EA  :  N-Element array of end angles to rotate VEC1 by (deg)
;
;  EXAMPLES:    
;               NA
;
;  KEYWORDS:    
;               VEC1    :  Structure of vector data with format:  
;                           {X:[M-Element Unix time],Y:[M,3]-Element vector array}
;
;   NOTES:
;               If keyword VEC1 is not set, program will return a structure that
;                 contains the rotation matricies one would use to rotate a vector
;                 by those specified angles.
;
;   CHANGED:  1)  Updated man page                             [08/03/2009   v1.0.1]
;             2)  Added program:  my_dot_prod.pro and fixed rotation matrix 
;                   multiplication algorithm [previous version produced the correct
;                   rotated fields for the first data point, but the rest were copies
;                   of the first... NOT slowly varying values as originally desired]
;                                                              [10/21/2009   v2.0.0]
;             3)  Added program:  eulermat.pro and changed rotation matrix calculation
;                                                              [03/11/2010   v2.1.0]
;             4)  Fixed syntax typo which affected ONLY single TDS_T event inputs
;                                                              [03/15/2009   v2.1.1]
;
;   CREATED:  08/02/2009
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  03/15/2009   v2.1.1
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-


Last Modification =>  2010-02-01/22:59:34 UTC
;+
;*****************************************************************************************
;
;  FUNCTION :   kill_data_tr.pro
;  PURPOSE  :   Interactively kills data between two times defined by user either with
;                 the cursor or inputs D1 and D2 by setting the data to NaNs.
;
;  CALLED BY:   
;               NA
;
;  CALLS:
;               tplot_com.pro
;               str_element.pro
;               ctime.pro
;               gettime.pro
;               tplot.pro
;               get_data.pro
;               store_data.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               D1[2]       :  Scalar string or double, see TIME_STRUCT.PRO for 
;                               formats
;
;  EXAMPLES:    
;               ..................................................................
;               :  If data is plotted already in TPLOT that you wish to destroy  :
;               :    and you wish to use the cursors to set the times to kill    :
;               ..................................................................
;               kill_data_tr
;               ..................................................................
;               :  If data is plotted already in TPLOT that you wish to destroy  :
;               :    and you wish to define the time range with a scalar         :
;               ..................................................................
;               t1 = '2000-04-05/12:30:45.633'
;               t2 = '2000-04-05/12:33:46.543'
;               kill_data_tr,t1,t1
;               ..................................................................
;               :  If data is plotted already in TPLOT that you wish to destroy  :
;               :    and you wish to define the time range with a double         :
;               ..................................................................
;               t1 = time_double('2000-04-05/12:30:45.633')
;               t2 = time_double('2000-04-05/12:33:46.543')
;               kill_data_tr,t1,t1
;               ..................................................................
;               :  If data is not plotted in TPLOT already, then define which    :
;               :    TPLOT handles to use                                        :
;               ..................................................................
;               kill_data_tr,NAMES=tnames([1,3,5])
;
;  KEYWORDS:    
;               NAMES      :  N-Element string array of TPLOT handles/names
;
;   CHANGED:  1)  NA [MM/DD/YYYY   v1.0.0]
;
;   NOTES:      
;               1)  Make sure you either define the TPLOT handles to be "killed" or
;                     make sure the ones you want "killed" are currently plotted
;                     before running this program!
;               2)  It would be wise to create a copy of the data you wish to kill
;                     to avoid destroying data that you want back.
;
;   CREATED:  02/01/2010
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  02/01/2010   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-


Last Modification =>  2009-08-05/16:11:30 UTC
;+
;*****************************************************************************************
;
;  FUNCTION :   load_3dp_wrapper.pro
;  PURPOSE  :   This is a wrapping program for load_3dp_data.pro which loads Wind
;                 data from the 3-Dimensional Plasma Instrument (3DP) for a given
;                 date and time range.
;
;  CALLED BY:   
;               NA
;
;  CALLS:
;               my_str_date.pro
;               my_time_string.pro
;               load_3dp_data.pro
;
;  REQUIRES:    
;               WindLib Libraries and the following shared objects:
;                 wind3dp_lib_ls32.so
;                 wind3dp_lib_ss32.so
;
;  INPUT:
;               NA
;
;  EXAMPLES:    
;               NA
;
;  KEYWORDS:    
;               DATE      :  [string] date of 3DP data desired ('MMDDYY')
;               QUALITY   :  [integer] specifying the quality of data 
;                              [Default = 2]
;               DURATION  :  [float,integer,long] amount of data in hours 
;                              [Default = 24]
;               TRANGE    :  [Double] 2-Element array specifying the time range over 
;                              which to get data structures for [Unix time]
;               MEMSIZE   :  Option that allows one to allocate more memory for IDL
;
;   CHANGED:  1)  NA [MM/DD/YYYY   v1.0.0]
;
;   CREATED:  08/05/2009
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  08/05/2009   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-


Last Modification =>  2009-09-29/20:06:54 UTC
;+
;*****************************************************************************************
;
;  FUNCTION :   moments_array_3dp.pro
;  PURPOSE  :   This is a wrapping program for moments_3d.pro and it includes the option
;                 to calculate the heat flux vector in GSE or FACs.  Set the appropriate
;                 keywords one wishes to return for relevant quantities.  Note that if
;                 user sends in an array for survey sampled data (e.g. Eesa Low) AND
;                 burst sampled data (e.g. Eesa Low Burst), the data will be sorted
;                 and combined into one set of arrays.
;
;  CALLED BY:   
;               NA
;
;  CALLS:
;               dat_3dp_energy_bins.pro
;               moments_3d.pro
;               tnames.pro
;               store_data.pro
;               options.pro
;
;  REQUIRES:    
;               UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               NA
;
;  EXAMPLES:    
;               NA
;
;  KEYWORDS:    
;               PLM       :  N-Element array of 3DP particle data structures from a 
;                              non-burst mode program (e.g. get_el.pro)
;               PLBM      :  M-Element array of 3DP particle data structuresfrom a 
;                              burst mode program (e.g. get_elb.pro)
;               AVGTEMP   :  Set to a named variable to return an array of average 
;                              temperatures dependent on energy bins used, density, 
;                              etc. [eV] {[M+N]-Element array}
;               T_PERP    :  Set to a named variable to return an array of perpendicular
;                              (to the magnetic field) temperatures [eV] 
;                              {[M+N]-Element array}
;               T_PARA    :  Set to a named variable to return an array of parallel
;                              (to the magnetic field) temperatures [eV]
;                              {[M+N]-Element array}
;               V_THERM   :  Set to a named variable to return an array of average 
;                              thermal speeds [km/s] {[M+N]-Element array}
;               VELOCITY  :  Set to a named variable to return an [(M+N),3]-element
;                              array of average velocity vectors [km/s]
;               PRESSURE  :  Set to a named variable to return an [M+N]-element
;                              array of average dynamic pressures [eV cm^(-3)]
;               DENSITY   :  Set to a named variable to return an [M+N]-element
;                              array of average particle densities [# cm^(-3)]
;               SC_POT    :  [M+N]-Element array defining the spacecraft potential (eV)
;               MAGDIR    :  [M+N,3]-Element vector array defining the magnetic
;                              field (nT) associated with the data structure
;                              [Note:  This can be useful if one wishes to calculate
;                                 moments with respect to some other vector direction]
;               ERANGE    :  Set to a [M+N,2]-Element array specifying the first and
;                              last elements of the energy bins desired to be used for
;                              calculating the moments
;               MOMS      :  Set to a named variable to return an array of particle
;                              moment structures
;               TO_TPLOT  :  If set, data quantities are sent to TPLOT
;               SUFFX     :  Scalar string to differentiate TPLOT handles if program
;                              called multiple times
;
;   CHANGED:  1)  Added a few comments to explain logic statement  
;                   and added keyword END_TIME to output structure MOMS
;                                                                 [09/28/2009   v1.0.1]
;             2)  Added density to output TPLOT handles and keyword:  DENSITY
;                                                                 [09/29/2009   v1.1.0]
;
;   NOTES:      
;               1)  The MAGDIR keyword can be useful if one wishes to calculate
;                     moments with respect to some other vector direction (e.g. shock
;                     normal vector)
;               2)  For the electrostatic analyzers, the first energy bin corresponds
;                     to the highest energy while the SST energy bins are reversed.
;                     Thus if one wished to worry about ONLY the 5 highest energies for
;                     an Eesa Low Burst sample, set ERANGE=[0,4].
;               3)  The keywords, ERANGE and MAGDIR can be a 2-element and 3-element
;                     array, respectively, if one wants to consider set values over
;                     the entire set of particle structures.
;
;   CREATED:  08/20/2009
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  09/29/2009   v1.1.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-


Last Modification =>  2009-08-05/14:25:57 UTC
;+
;*****************************************************************************************
;
;  FUNCTION :   my_3dp_plot_labels.pro
;  PURPOSE  :   Generates plot labels and positions for semi-arbitrary data
;                 structures (PAD structures and spec structures created by
;                 pad.pro or my_pad_dist.pro and get_padspec.pro or 
;                 my_get_padspec_5.pro or the results of reduce_dimen.pro and
;                 reduce_pads.pro).  The structure returned contains information
;                 about the TPLOT variable labels and their positions in the
;                 plot window, relative to the data.
;
;  CALLED BY:   
;               my_padplot_both.pro
;
;  CALLS:
;               get_data.pro
;
;  REQUIRES:    NA
;
;  INPUT:
;               D2  :  A data structure produced from a 3DP moment structure or
;                        multiple 3DP moment structures with one of the following
;                        formats:
;                        1)  {X:time,Y:[n,3]}         <-> vector TPLOT variable
;                        2)  {X:time,Y:[n,m],V:[n,m]} <-> Spectra at one PA
;                        3)  {X:time,Y:[n,m,l],V1:[n,m],V2[n,l],SPEC:[0,1]}
;                          [Where:  n = # of time steps, m = # of energy bins, 
;                                   and l = # of PA's]
;                        4)  PAD produced by pad.pro or my_pad_dist.pro
;
;  EXAMPLES:    NA
;
;  KEYWORDS:  
;               NAMEN  : name associated with structure for identifying anonymous 
;                         structures (e.g. name='magf' for B-field data)
;                         {list : magf,velo,temp,qflu,dens}
;
;   CHANGED:  1)  Updated 'man' page                              [11/11/2008   v1.0.2]
;             2)  Fixed label issue [only a problem if PAD structures had NaNs in
;                    energy or pitch-angle bins => usually NOT a problem for EL]
;                                                                 [12/08/2008   v1.0.3]
;             3)  Updated man page and changed some minor syntax  [08/05/2009   v1.1.0]
;
;   CREATED:  05/12/2008
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  08/05/2009   v1.1.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-


Last Modification =>  2010-02-20/00:32:47 UTC
;+
;*****************************************************************************************
;
;  FUNCTION :  my_array_where.pro
;  PURPOSE  :  This program finds the good elements of two different arrays which do not
;                 share the same number of elements but have overlapping values (i.e.
;                 x = findgen(20), y = [1.,5.,7.,35.], => find which elements of 
;                 each match... x_el = [1,6,8], y_el = [0,1,2]).  This is good when
;                 the WHERE.PRO function doesn't work well (e.g. two different 
;                 arrays with different numbers of elements but containing
;                 overlapping values of interest).  The program will also return the
;                 complementary elements for each array if desired.
;
;  CALLED BY:   
;               my_dpu_ur8_shift.pro
;               wind_fix_scet.pro
;               eesa_pesa_low_to_tplot.pro
;
;  CALLS:       NA
;
;  REQUIRES:    NA
;
;  INPUT:
;               ARR1      :  N-Element array of type S
;               ARR2      :  M-Element array of type S(+/-1,0)
;                              [Note:  S = the type code and can be 2-5 or 7]
;
;  EXAMPLES:
;               x = findgen(20)
;               y = [1.,5.,7.,35.]
;               gtest = my_array_where(x,y)
;               print, gtest
;                    1           5           7
;                    0           1           2
;
;  KEYWORDS:  
;               NGOOD     :  Set to a named variable to return the number of 
;                              matching values
;               N_UNIQ    :  If set, program will NOT find just the unique elements of
;                              the arrays in question
;               NCOMP1    :  Set to a named variable to return the complementary 
;                              elements to that of the (my_array_where(x,y))[*,0]
;               NCOMP2    :  Set to a named variable to return the complementary 
;                              elements to that of the (my_array_where(x,y))[*,1]
; **Obselete**  NO_UNIQ1  :  If set, program will not find ONLY the unique elements of
;                              the first array in question
; **Obselete**  NO_UNIQ1  :  If set, program will not find ONLY the unique elements of
;                              the second array in question
;
;   CHANGED:  1)  Added keywords:  NO_UNIQ[1,2]            [04/27/2009   v1.0.1]
;             2)  Rewrote and removed cludgy code          [04/28/2009   v2.0.0]
;             3)  Fixed syntax issue for strings           [04/29/2009   v2.0.1]
;             4)  Got rid of separate unique keyword calling reducing to only one
;                   keyword:  NO_UNIQ                      [06/15/2009   v3.0.0]
;             5)  Added keywords:  NCOMP1 and NCOMP2       [09/29/2009   v3.1.0]
;             6)  Changed place where unique elements are determined... alters results
;                                                          [10/22/2009   v3.2.0]
;             7)  Fixed a rare indexing issue (only occurred once in over 100
;                   different runs on varying input)       [02/19/2010   v3.2.1]
;
;   NOTES:      
;               1)  It is rarely the case that you don't want to set the keyword N_UNIQ
;
;   CREATED:  04/27/2009
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  02/19/2010   v3.2.1
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-


Last Modification =>  2009-04-15/19:49:26 UTC
;+
;*****************************************************************************************
;
;  FUNCTION :   my_bilorentzian_dist.pro
;  PURPOSE  :   Creates a Bi-Lorentzian Distribution Function (LDF) from an user defined
;                 amplitude, thermal speed, and array of velocities to define the LDF
;                 at.  The only note to be careful of is to make sure the thermal
;                 speed and array of velocities are in the same units.
;                 [See Thomsen et. al. (1983), JGR Vol. 88, pg. 3035-3045]
;
;  CALLED BY: 
;               my_eesa_df_flattop.pro
;               my_eesa_df_adjust.pro
;               my_eesa_dist_fit.pro
;
;  CALLS:       NA
;
;  REQUIRES:    NA
;
;  INPUT:
;               AMP    :  Maximum amplitude of distribution function desired (units)
;               VELPA  :  N-Element array of parallel velocities (units) 
;               VELPE  :  N-Element array of perpendicular velocities (units) 
;               VTHER  :  2-Element array defining the thermal speeds [para,perp]
;
;  EXAMPLES:
;               n  = 24L
;               vv = (DINDGEN(2*n+1)/n-1) * 2d4
;               vt = 3d3
;               am = 1d-14
;               ldist = my_lorentzian_dist(am,vv,vt,MPOW=2)
;               IDL> help, ldist
;               LDIST            DOUBLE    = Array[49]
;
;  KEYWORDS:  
;               MPOW   :  Power of Lorentzian (Default = 2 for solar wind)
;
;   CHANGED:  1)  NA [MM/DD/YYYY   v1.0.0]
;
;   CREATED:  04/15/2009
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  04/15/2009   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-


Last Modification =>  2009-06-04/12:25:40 UTC
;+
;*****************************************************************************************
;
;  FUNCTION :   my_bimaxwellian_dist.pro
;  PURPOSE  :   Creates a Bi-Maxwellian Distribution Function (MDF) from an user 
;                 defined amplitude, thermal speed, and array of velocities to define 
;                 the MDF at.  The only note to be careful of is to make sure the
;                 thermal speed and array of velocities are in the same units.
;
;  CALLED BY: 
;               my_eesa_df_flattop.pro
;               my_eesa_df_adjust.pro
;               my_eesa_dist_fit.pro
;
;  CALLS:       NA
;
;  REQUIRES:    NA
;
;  INPUT:
;               AMP    :  Maximum amplitude of distribution function desired (units)
;               VELPA  :  N-Element array of parallel velocities (units) 
;               VELPE  :  N-Element array of perpendicular velocities (units) 
;               VTHER  :  2-Element defining the thermal speed [para,perp]
;
;  EXAMPLES:
;               n  = 24L
;               vv = (DINDGEN(2*n+1)/n-1) * 2d4
;               vv = REPLICATE(1.,2*n+1) # vv
;               vt = [3d3,3.5d3]
;               am = 1d-14
;               ldist = my_gaussian_dist(am,vv,vt,MPOW=2)
;               IDL> help, ldist
;               LDIST            DOUBLE    = Array[49]
;
;  KEYWORDS:  
;               MPOW   :  Power of Gaussian (Default = 2 for normal Maxwellian)
;                          **[must be an even number > or = 2]**
;               DRIFT  :  Set to a scaler defining the drift speed of the Maxwellian
;
;   CHANGED:  1)  NA                                          [04/15/2009   v1.0.0]
;             2)  Changed how program deals with odd powers   [06/04/2009   v1.0.1]
;
;   CREATED:  04/15/2009
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  06/04/2009   v1.0.1
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-


Last Modification =>  2009-09-16/14:12:29 UTC
;+
;*****************************************************************************************
;
;  FUNCTION :   my_box.pro
;  PURPOSE  :   Attempts to generate the axes one desires for plotting in IDL.
;
;  CALLED BY: 
;               mplot.pro
;
;  CALLS:
;               str_element.pro
;               minmax.pro
;               extract_tags.pro
;               plot_positions.pro
;               xlim.pro
;               ylim.pro
;
;  REQUIRES:    
;               NA
;
;  INPUT:
;               X         :  X-axis data array
;               Y         :  Y-axis data array
;               LIMITS    :  A structure containing plot information with
;                             tags defined by the allowable tags found in
;                             the IDL plot.pro etc. routines.
;
;  EXAMPLES:    
;               NA
;
;  KEYWORDS:  
;               MPOSI     :  Set to a named variable to receive back the
;                             position coords. of the plot region.
;               COL_SCALE :  If set, the position of the entire graph is 
;                             adjusted to accommodate a color scale on the
;                             right side
;               RE_DRAW   :  Used to keep track of which plot we're using in 
;                              the plot region
;
;   CHANGED:  1)  Fixed some syntax issues                  [08/29/2008   v1.0.4]
;             2)  Updated man page                          [06/03/2009   v1.0.5]
;             3)  Changed program my_plot_scale.pro to plot_vector_hodo_scale.pro
;                   and my_plot_positions.pro to plot_positions.pro
;                                                           [09/10/2009   v2.0.0]
;             4)  Changed program plot_vector_hodo_scale.pro to minmax.pro
;                                                           [09/16/2009   v2.1.0]
;
;   ADAPTED FROM: box.pro  BY:  ?
;   CREATED:  08/28/2008
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  09/16/2009   v2.1.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-


Last Modification =>  2009-12-04/20:19:33 UTC
;+
;*****************************************************************************************
;
;  FUNCTION :   my_crossp_2.pro
;  PURPOSE  :   Calculates the cross product of two vectors or arrays of vectors and 
;                 returns an array with the same dimensions as the larger of the two
;                 input vectors.  The IDL built-in, CROSSP.PRO, requires the user to
;                 use only single vectors whereas this program allows for [N,3] or
;                 [3,N]-element input arrays.
;
;  CALLED BY: 
;               field_rot.pro
;
;  CALLS:
;               NA
;
;  REQUIRES:
;               NA
;
;  INPUT:
;               T1  :  [n,3] or [3,n] element array of vectors
;                        {where : n=1, or 2, or 3,...}
;               T2  :  [n,3] or [3,n] element array of vectors
;
;  EXAMPLES:
;               x = FINDGEN(3,n)
;               y = FINDGEN(n,3)
;               z = my_crossp_2(x,y)  ; -Returns a [n,3]-Element vector
;
;  KEYWORDS:
;               NOMSSG  :  If set, the program will NOT print out a message about the
;                            running time of the program.  This is particularly useful
;                            when calling the program multiple times in a loop.
;
;   CHANGED:  1)  Vectorized and changed indexing issue      [09/16/2008   v1.1.13]
;             2)  Updated man page                           [03/22/2009   v1.1.14]
;             3)  Added keyword:  NOMSSG                     [04/17/2009   v1.1.15]
;             4)  Changed some syntax and removed dependency on my_dimen_force.pro
;                                                            [09/17/2009   v1.2.0]
;             5)  Fixed a typo [no functional changes]       [12/04/2009   v1.2.1]
;
;   CREATED:  06/10/2008
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  12/04/2009   v1.2.1
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-


Last Modification =>  2009-12-04/20:18:35 UTC
;+
;*****************************************************************************************
;
;  FUNCTION :  my_dot_prod.pro
;  PURPOSE  :  Calculates the single(double) precission dot product of two 
;               [n,3] or [3,n]-Element vectors, producing n-scalar dot products.
;
;  CALLED BY:
;               NA
;
;  CALLS:
;               NA
;
;  REQUIRES:
;               NA
;
;  INPUT:
;               V1      :  [N,3] or [3,N] element array {where : N=1, or 2, or 3,...}
;               V2      :  [N,3] or [3,N] element array
;
;  EXAMPLES:
;               x = FINDGEN(3,n)
;               y = FINDGEN(n,3)
;               z = my_dot_prod(x,y)  ; -Returns a [n]-Element scalar
;
;  KEYWORDS:  
;               NOMSSG  :  If set, the program will NOT print out a message about the
;                            running time of the program.  This is particularly useful
;                            when calling the program multiple times in a loop.
;
;   CHANGED:  1)  "Fixed" issue of 3x3 array (assumes [n,3]-vector)
;                                                            [12/17/2008   v1.0.1]
;             2)  Changed some syntax and removed dependency on my_dimen_force.pro
;                   and added keyword:  NOMSSG
;                                                            [09/17/2009   v1.1.0]
;             3)  Fixed a typo [no functional changes]       [12/04/2009   v1.1.1]
;
;   CREATED:  09/15/2008
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  12/04/2009   v1.1.1
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-


Last Modification =>  2009-03-17/22:46:14 UTC
;+
;*****************************************************************************************
;
;  FUNCTION :   my_format_structure.pro
;  PURPOSE  :   Determines the data types and formats of a format statement then returns
;                 a structure with all the relevant information regarding the format
;                 statement [possibly useful for reading in multiple files].
;
;  CALLED BY:   NA
;
;  CALLS:       NA
;
;  REQUIRES:    NA
;
;  INPUT:
;               MFORMS  :  Format of file to be read in and sorted
;                          [must have form of:  '(12a20,...)' aka typical format 
;                           statement]
;
;  EXAMPLES:    NA
;
;  KEYWORDS:    NA
;
;   CHANGED:  1)  NA [MM/DD/YYYY   v1.0.0]
;
;   CREATED:  03/17/2009
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  03/17/2009   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-


Last Modification =>  2009-06-04/12:24:58 UTC
;+
;*****************************************************************************************
;
;  FUNCTION :   my_gaussian_dist.pro
;  PURPOSE  :   Creates a Gaussian Distribution Function (GDF) from an user defined
;                 amplitude, thermal speed, and array of velocities to define the GDF
;                 at.  The only note to be careful of is to make sure the thermal
;                 speed and array of velocities are in the same units.
;
;  CALLED BY: 
;               my_eesa_df_flattop.pro
;               my_eesa_df_adjust.pro
;               my_eesa_dist_fit.pro
;
;  CALLS:       NA
;
;  REQUIRES:    NA
;
;  INPUT:
;               AMP    :  Maximum amplitude of distribution function desired (units)
;               VELS   :  N-element array of velocities (units) 
;               VTHER  :  Scalar defining the thermal speed
;
;  EXAMPLES:
;               n  = 24L
;               vv = (DINDGEN(2*n+1)/n-1) * 2d4
;               vt = 3d3
;               am = 1d-14
;               ldist = my_gaussian_dist(am,vv,vt,MPOW=2)
;               IDL> help, ldist
;               LDIST            DOUBLE    = Array[49]
;
;  KEYWORDS:  
;               MPOW   :  Power of Gaussian (Default = 2 for normal Gaussian)
;                          **[must be an even number > or = 2]**
;               DRIFT  :  Set to a scaler defining the drift speed of the Maxwellian
;
;   CHANGED:  1)  Added keyword:  DRIFT                       [04/15/2009   v1.1.0]
;             2)  Changed how program deals with odd powers   [06/04/2009   v1.1.1]
;
;   CREATED:  02/17/2009
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  06/04/2009   v1.1.1
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-


Last Modification =>  2011-03-31/21:37:22 UTC
;+
;*****************************************************************************************
;
;  FUNCTION :   my_histogram.pro
;  PURPOSE  :   Program returns a structure with all the relevant plot and data 
;                 information needed to make a histogram plot.  The structure
;                 contains substructures which are as follows:
;                   1)  REC   =  contains locations of the corners of the histogram
;                                  rectangles used in plotting with POLYFILL.PRO
;                   2)  CPLOT =  contains a plot structure for counts
;                   3)  PPLOT =  contains a plot structure for percentages
;                 [Note:  CPLOT and PPLOT are used in the plot rountine as follows:
;                          _EXTRA=myhist.PPLOT or _EXTRA=myhist.CPLOT, where
;                          _EXTRA is a keyword in PLOT.PRO]
;
;  CALLED BY:
;               my_histogram_plot.pro
;
;  CALLS:
;               my_histogram_bins.pro
;
;  REQUIRES:    NA
;
;  INPUT:
;               M1      :  An N-Element array of data to be used for the histogram
;
;  EXAMPLES:    NA
;
;  KEYWORDS:  
;               NBINS   :  A scalar used to define the number of bins used to make the
;                            histogram [Default = 8]
;               DRANGE  :  Set to a 2-Element array to force bins to be determined by
;                            the range given in array instead of data
;                            [Useful for plotting multiple things on the same scales]
;               YRANGEC :  A scalar used to define the max y-range value for counts
;               YRANGEP :  A scalar used to define the max y-range value for percent
;                            [Best results if both YRANGEC and YRANGEP are set]
;               PREC    :  Scalar defining the precision of the X-Axis bin range labels
;                            [Default = 2 for 8 bins or less, 1 for >8 bins]
;
;   CHANGED:  1)  Changed the YRANGE for the percentage data [01/13/2009   v1.0.1]
;             2)  Changed the XRANGE for both plots          [01/13/2009   v1.0.2]
;             3)  Added keyword : DRANGE                     [01/24/2009   v1.0.3]
;             4)  Added keywords: YRANGEC and YRANGEP        [01/24/2009   v1.0.4]
;             5)  Fixed possible issue if one enters a 2-Element array for either
;                   keyword YRANGEC or YRANGEP               [06/03/2009   v1.0.5]
;             6)  Added keyword :  PREC                      [03/31/2011   v1.0.6]
;
;   CREATED:  01/05/2009
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  03/31/2011   v1.0.6
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-


Last Modification =>  2011-03-31/21:36:51 UTC
;+
;*****************************************************************************************
;
;  FUNCTION :   my_histogram_bins.pro
;  PURPOSE  :   Creates and returns a structure which defines the tickmark names and 
;                 heights associated with a histogram of absolute counts and a 
;                 histogram of percentages.
;
;  CALLED BY:   
;               my_histogram.pro
;
;  CALLS:       NA
;
;  REQUIRES:    NA
;
;  INPUT:
;               M1      :  An N-Element array of data to be used for the histogram
;
;  EXAMPLES:
;               hist_data = my_histogram_bins(m1,NBINS=8L,DRANGE=[10.,20.])
;
;  KEYWORDS:  
;               NBINS   :  A scalar used to define the number of bins used to make the
;                            histogram [Default = 8]
;               DRANGE  :  Set to a 2-Element array to force bins to be determined by
;                            the range given in array instead of data
;                            [Useful for plotting multiple things on the same scales]
;               PREC    :  Scalar defining the precision of the X-Axis bin range labels
;                            [Default = 2 for 8 bins or less, 1 for >8 bins]
;
;   CHANGED:  1)  Added keyword: DRANGE                        [01/24/2009   v1.0.1]
;             2)  Dealt with negative numbers                  [06/03/2009   v1.0.2]
;             3)  Fixed issue with DRANGE                      [04/11/2010   v1.1.0]
;             4)  Changed the bin label format statements      [05/12/2010   v1.1.1]
;             5)  Added keyword :  PREC                        [03/31/2011   v1.1.2]
;
;   CREATED:  01/05/2009
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  03/31/2011   v1.1.2
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-


Last Modification =>  2011-03-31/22:21:44 UTC
;+
;*****************************************************************************************
;
;  FUNCTION :   my_histogram_plot.pro
;  PURPOSE  :   Creates a histogram plot from a 1D input data array.
;
;  CALLED BY:   NA
;
;  CALLS:
;               my_histogram.pro
;
;  REQUIRES:    NA
;
;  INPUT:
;               M1        :  An N-Element array of data to be used for the histogram
;
;  EXAMPLES:    NA
;
;  KEYWORDS:  
;               NBINS     :  A scalar used to define the number of bins used to make the
;                              histogram [Default = 8]
;               YTTL      :  Set to a string defining the desired Y-Axis Title
;               XTTL      :  Set to a string defining the desired X-Axis Title
;               TTLE      :  Set to a string defining the desired plot title
;               DRANGE    :  Set to a 2-Element array to force bins to be determined by
;                              the range given in array instead of data
;                              [Useful for plotting multiple things on the same scales]
;               YRANGEC   :  A scalar used to define the max y-range value for counts
;               YRANGEP   :  A scalar used to define the max y-range value for percent
;                              [Best results if both YRANGEC and YRANGEP are set]
;               BARCOLOR  :  A scalar defining the color of the bars
;               PREC      :  Scalar defining the precision of the X-Axis bin range labels
;                              [Default = 2 for 8 bins or less, 1 for >8 bins]
;
;   CHANGED:  1)  Updated man page and fixed device issue  [01/09/2009   v1.0.1]
;             2)  Added output which defines number of points analyzed
;                                                          [01/13/2009   v1.0.2]
;             3)  Added keyword : DRANGE                   [01/24/2009   v1.0.3]
;             4)  Added keywords: YRANGEC and YRANGEP      [01/24/2009   v1.0.4]
;             5)  Changed # output for DRANGE alterations  [04/30/2009   v1.0.5]
;             6)  Changed string output when DRANGE set    [06/03/2009   v1.0.6]
;             7)  Added keyword :  BARCOLOR                [06/04/2009   v1.0.7]
;             8)  Added keyword :  PREC                    [03/31/2011   v1.0.8]
;
;   CREATED:  01/05/2009
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  03/31/2011   v1.0.8
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-


Last Modification =>  2009-02-17/22:23:01 UTC
;+
;*****************************************************************************************
;
;  FUNCTION :   my_kappa_dist.pro
;  PURPOSE  :   Creates a kappa Distribution Function (KDF) from an user defined
;                 amplitude, thermal speed, and array of velocities to define the KDF
;                 at.  The only note to be careful of is to make sure the thermal
;                 speed and array of velocities are in the same units.
;                 [See Thomsen et. al. (1983), JGR Vol. 88, pg. 3035-3045]
;
;  CALLED BY: 
;               my_eesa_df_flattop.pro
;               my_eesa_df_adjust.pro
;               my_eesa_dist_fit.pro
;
;  CALLS:       NA
;
;  REQUIRES:    NA
;
;  INPUT:
;               AMP    :  Maximum amplitude of distribution function desired (units)
;               VELS   :  N-element array of velocities (units) 
;               VTH    :  Scalar defining the thermal speed
;
;  EXAMPLES:
;               n  = 24L
;               vv = (DINDGEN(2*n+1)/n-1) * 2d4
;               vt = 3d3
;               am = 1d-14
;               kdist = my_kappa_dist(am,vv,vt,KAPPA=2)
;               IDL> help, kdist
;               KDIST            DOUBLE    = Array[49]
;
;  KEYWORDS:  
;               MPOW   :  Power of Kappa Distribution (Default = 3 for solar wind)
;                           **[Note:  kappa > 3/2 ALWAYS!]**
;
;   CHANGED:  1)  NA [MM/DD/YYYY   v1.0.0]
;
;   CREATED:  02/17/2009
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  02/17/2009   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-


Last Modification =>  2009-02-17/22:17:16 UTC
;+
;*****************************************************************************************
;
;  FUNCTION :   my_lorentzian_dist.pro
;  PURPOSE  :   Creates a Lorentzian Distribution Function (LDF) from an user defined
;                 amplitude, thermal speed, and array of velocities to define the LDF
;                 at.  The only note to be careful of is to make sure the thermal
;                 speed and array of velocities are in the same units.
;                 [See Thomsen et. al. (1983), JGR Vol. 88, pg. 3035-3045]
;
;  CALLED BY: 
;               my_eesa_df_flattop.pro
;               my_eesa_df_adjust.pro
;               my_eesa_dist_fit.pro
;
;  CALLS:       NA
;
;  REQUIRES:    NA
;
;  INPUT:
;               AMP    :  Maximum amplitude of distribution function desired (units)
;               VELS   :  N-element array of velocities (units) 
;               VTHER  :  Scalar defining the thermal speed
;
;  EXAMPLES:
;               n  = 24L
;               vv = (DINDGEN(2*n+1)/n-1) * 2d4
;               vt = 3d3
;               am = 1d-14
;               ldist = my_lorentzian_dist(am,vv,vt,MPOW=2)
;               IDL> help, ldist
;               LDIST            DOUBLE    = Array[49]
;
;  KEYWORDS:  
;               MPOW   :  Power of Lorentzian (Default = 2 for solar wind)
;
;   CHANGED:  1)  NA [MM/DD/YYYY   v1.0.0]
;
;   CREATED:  02/17/2009
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  02/17/2009   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-


Last Modification =>  2011-03-10/17:21:33 UTC
;+
;*****************************************************************************************
;
;  FUNCTION :  my_min_var_rot.pro
;  PURPOSE  :  Calculates the minimum variance matrix of some vector array of a 
;               particular input field along with uncertainties and angular 
;               rotation from original coordinate system.
;
;==-----------------------------------------------------------------------------
;*******************************************************************************
; Error Analysis from: A.V. Khrabrov and B.U.O. Sonnerup, JGR Vol. 103, 1998.
;
;
;avsra = WHERE(tsall LE timesta+30.d0 AND tsall GE timesta-30.d0,avsa)
;myrotma = MIN_VAR(myavgmax[avsra],myavgmay[avsra],myavgmaz[avsra],EIG_VALS=myeiga)
;
; dphi[i,j] = +/- SQRT(lam_3*(lam_[i]+lam_[j]-lam_3)/((K-1)*(lam_[i] - lam_[j])^2))
;
; dphi = angular standard deviation (radians) of vector x[i] toward/away from 
;         vector x[j]
;*******************************************************************************
;  Hoppe et. al. [1981] :
;      lam_3 : Max Variance
;      lam_2 : Intermediate Variance
;      lam_1 : MInimum Variance
;
;        [Assume isotropic "noise" in signals]
;      Variance due to signal (along MAX VARIANCE) : lam_1 - lam_3
;      Variance due to signal (along INT VARIANCE) : lam_2 - lam_3
;
;      Maximum Angular Change (along MIN VARIANCE) : th_min = ATAN(lam_3/(lam_2 - lam_3))
;      Maximum Angular Change (along MAX VARIANCE) : th_max = ATAN(lam_3/(lam_1 - lam_2))
;
;  -The direction of maximum variance in the plane of maximum variance is determined
;    by the size of the difference between the two variances in this plane compared
;    to noise.
;
;  -EXAMPLES/ARGUMENTS
;    IF lam_2 = lam_3   => th_min is NOT DEFINED AND th_max is NOT DEFINED
;    IF lam_2 = 2*lam_3 => th_min = !PI/4
;    IF lam_2 = 2*lam_3 => th_min = !PI/30
;
;    IF lam_1 = lam_2 >> lam_3 => Minimum Variance Direction is still well defined!
;
;
;*******************************************************************************
;  Mazelle et. al. [2003] :
;        Same Min. Var. variable definitions
;
;       th_min = SQRT((lam_3*lam_2)/(N-1)/(lam_2 - lam_3)^2)
;        {where : N = # of vectors measured, or # of data samples}
;*******************************************************************************
;==-----------------------------------------------------------------------------
;
;  CALLS:  
;               min_var.pro
;
;  INPUT:
;               FIELD  :  some [n,3] or [3,n] array of vectors
;
;  EXAMPLES:
;
;  KEYWORDS:  
;               RANGE      :  2-element array defining the start and end point elements
;                               to use for calculating the min. var.
;               NOMSSG     :  If set, TPLOT will NOT print out the index and TPLOT handle
;                               of the variables being plotted
;               BKG_FIELD  :  [3]-Element vector for the background field to dot with
;                               MV-Vector produced in program
;                               [Default = DC(smoothed) value of input FIELD]
;               OFFSET     :  If set, program removes the average offset of each
;                               component to avoid offsets influencing the MVA
;
;   CHANGED:  1)  Changed calculation for angle of prop. w/ respect to B-field
;                   to the method defined directly above     [09/29/2008   v1.0.2]
;             2)  Corrected theta_{kB} calculation           [10/05/2008   v1.0.3]
;             3)  Changed theta_{kB} calculation, added calculation of minimum variance
;                   eigenvector error, and changed return structure 
;                                                            [01/20/2009   v1.1.0]
;             4)  Fixed theta_kB calc. (forgot to normalize B-field) 
;                                                            [01/22/2009   v1.1.1]
;             5)  Added keywords:  NOMSSG and BKG_FIELD      [12/04/2009   v1.2.0]
;             6)  Fixed a typo in definition of GN variable  [12/08/2009   v1.2.1]
;             7)  Changed format of output for theta_kB      [09/23/2010   v1.2.2]
;             8)  Added keyword :  OFFSET                    [03/10/2011   v1.3.0]
;
;   CREATED:  06/29/2008
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  03/10/2011   v1.3.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-


Last Modification =>  2011-03-03/00:59:14 UTC
;+
;*****************************************************************************************
;
;  FUNCTION :   my_padplot_both.pro
;  PURPOSE  :   Produces two plots from an input pitch-angle distribution (PAD)
;                 function produced by the program my_pad_dist.pro or pad.pro.
;                 The first plot has the units of particle flux while the second
;                 is in the units of energy flux.  If the structure is "good,"
;                 no array of labels or colors are necessary because the program
;                 should take care of that for you.  I also eliminated the use 
;                 mplot.pro due to its inability to automate the plot labels and
;                 locations in an acceptable manner.  I also included/altered the
;                 keyword associated with specifying energy bins because it was 
;                 not clear how the program wanted you to format the input.  So 
;                 I eliminated the need to specify how the energy bins should be
;                 entered making that keyword more robust.
;
;  CALLED BY:   
;               NA
;
;  CALLS:
;               str_element.pro
;               wind_3dp_units.pro
;               conv_units.pro
;               dat_3dp_energy_bins.pro
;               dat_3dp_str_names.pro
;               trange_str.pro
;               my_3dp_plot_labels.pro
;
;  REQUIRES:    
;               UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               TEMPDAT  :   Structure containing pitch angle distribution (PAD) data. 
;                              (Obtained from "pad.pro" routine)
;
;  EXAMPLES:    
;               .....................................................................
;               : =>> Plot the PAD in Flux and Energy Flux vs pitch angle for the 9 :
;               :       highest energies                                            :
;               .....................................................................
;               my_padplot,pad,UNITS='flux',EBINS=[0,8]
;
;  KEYWORDS:    
;               LIMITS   :  Limit structure. (see "xlim" , "YLIM" or "OPTIONS")
;                             The limit structure can have the following elements:
;               UNITS    :  Units to be plotted in [convert to given data units 
;                             before plotting]
;               LABEL    :  Set to print labels for each energy step.
;               COLOR    :  Array of colors to be used for each bin
;               EBINS    :  2-Element array specifying which energy bins to plot
;                             {e.g. [0,9] plots the 10 highest energy bins for the
;                              Eesa and Pesa instruments and SST instruments}
;               SCPOT    :  Scalar denoting the spacecraft (SC) potential (POT) 
;                             estimate for the PAD being plotted (eV)
;               VTHERM   :  Scalar denoting the Thermal Velocity for PAD (km/s)
;
;   CHANGED:  1)  Fixed indexing issue when EBINS[0] Not = 0 [12/08/2008   v1.2.22]
;             2)  Made program capable of handling any unit input and altered method
;                   for determining plot labels              [01/29/2009   v1.2.23]
;             3)  Changed color output                       [07/30/2009   v1.2.24]
;             4)  Changed program my_3dp_energy_bins.pro to dat_3dp_energy_bins.pro
;                   and my_str_names.pro to dat_3dp_str_names.pro
;                                                            [08/05/2009   v1.3.0]
;             5)  Changed charsize constraints to keep within 0.9 < char < 1.1
;                   and output plot structure format and output
;                                                            [09/18/2009   v1.3.1]
;             6)  Updated man page
;                   and now calls wind_3dp_units.pro         [10/14/2009   v1.4.0]
;             7)  Fixed an issue with plot ranges if ymin = 0.0 and changed
;                   energy bin label positions slightly      [03/02/2011   v1.4.1]
;
;   NOTES:      
;               1)  The following keywords are obselete:  MULTI and OVERPLOT
;
; ADAPTED FROM: padplot.pro    BY: Davin Larson
;   CREATED:  ??/??/????
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  03/02/2011   v1.4.1
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-


Last Modification =>  2009-09-09/22:01:43 UTC
;+
;*****************************************************************************************
;
;  FUNCTION :   my_ph_cont2d.pro
;  PURPOSE  :   Produces a contour plot of the distribution function (DF) with parallel
;                 and perpendicular cuts shown.  The program is specifically for Pesa
;                 High(Burst) data structures, NOT Eesa data.  {Though I imagine it
;                 could be easily altered to accomodate such structures.}
;
;  CALLED BY:   NA
;
;  CALLS:
;               str_element.pro
;               extract_tags.pro
;               add_df2d_to_ph.pro
;               contour_3dp_plot_limits.pro
;
;  REQUIRES:    NA
;
;  INPUT:
;               DAT      :  3DP data structure either from spec plots 
;                             (i.e. get_padspec.pro) or from pad.pro, get_el.pro, 
;                             get_sf.pro, etc.
;
;  EXAMPLES:
;               to  = time_double('1996-04-03/09:47:00')
;               dat = get_phb(to)
;               str_element,dat,'VSW',REPLICATE(!VALUES.F_NAN,3),/ADD_REPLACE
;               add_magf2,dat,'wi_B3(GSE)'
;               add_vsw2,dat,'V_sw2'
;               ....................................
;               :  Plot in solar wind rest frame   :
;               ....................................
;               my_ph_cont2d,dat,VLIM=6d4,NGRID=20,/SM_CUTS,NSMOOTH=5
;
;  KEYWORDS:  
;               VLIM     :  Limit for x-y velocity axes over which to plot data
;                             [Default = max vel. from energy bin values]
;               NGRID    :  # of isotropic velocity grids to use to triangulate the data
;                             [Default = 20L]
;               NNORM    :  3-Element unit vector for shock normal direction
;               EX_VEC   :  3-Element unit vector for another quantity like heat flux or 
;                             a wave vector
;               EX_VN    :  A string name associated with EX_VEC
;               SM_CUTS  :  If set, program plots the smoothed cuts of the DF
;                             [Note:  Smoothed to the minimum # of points]
;               DFMIN    :  Set to a scalar value defining the lower limit on the DF 
;                             you wish to plot (s^3/km^3/cm^3)
;                             [Default = 1e-14 (for PH)]
;
;   CHANGED:  1)  Changed plot output slightly               [04/14/2009   v1.0.1]
;             2)  Added keywords:  EX_VEC and EX_VN          [04/14/2009   v1.0.2]
;             3)  Changed plot range for cuts                [04/16/2009   v1.0.3]
;             4)  Fixed issue when null distribution cuts occur
;                                                            [05/27/2009   v1.0.4]
;             5)  Changed plot range for cuts                [06/21/2009   v1.0.5]
;             6)  Added program:  contour_3dp_plot_limits.pro
;                                                            [06/24/2009   v1.1.0]
;             7)  Added keyword:  SM_CUTS                    [06/24/2009   v1.1.1]
;             8)  Fixed syntax error                         [07/13/2009   v1.1.2]
;             9)  Added keyword:  DFMIN                      [07/13/2009   v1.1.3]
;            10)  Added a commented out section to alter the distributions if the UV
;                   contamination is too strong to observe useful aspects of the
;                   distribution cuts                        [08/07/2009   v1.1.4]
;            11)  Updated man page and Added keyword:  NSMOOTH
;                                                            [08/27/2009   v1.2.0]
;            12)  Changed plot labels to 1000 km/s           [08/28/2009   v1.2.1]
;
;   CREATED:  04/08/2009
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  08/28/2009   v1.2.1
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-


Last Modification =>  2010-11-16/19:02:18 UTC
;+
;*****************************************************************************************
;
;  FUNCTION :   my_str_date.pro
;  PURPOSE  :   Creates a structure of dates in different formats:
;                 S_DATE : 'MMDDYY'
;                 DATE   : 'YYYYMMDD'
;                 TDATE  : 'YYYY-MM-DD'
;                 L_YYYY : 'YYYY'
;                 YY     : 'YY'
;                 MM     : 'MM'
;                 DD     : 'DD'
;
;  CALLED BY:   
;               NA
;
;  CALLS:       
;               NA
;
;  REQUIRES:   
;                NA
;
;  INPUT:       
;               NA
;
;  EXAMPLES:
;               date   = '021096'
;               mydate = my_str_date(DATE=date)
;               mdate  = mydate.DATE    ; => '19960210'
;               or
;               year   = '96'
;               month  = '02'
;               day    = '10'
;               mydate = my_str_date(YEAR=year,MONTH=month,DAY=day)
;               mdate  = mydate.DATE    ; => '19960210'
;
;  KEYWORDS:  
;               YEAR    :  'YYYY'   [e.g. '1996']
;               MONTH   :  'MM'     [e.g. '04', for April]
;               DAY     :  'DD'     [e.g. '25', for the 25th]
;               DATE    :  N-Element array of dates 'MMDDYY' [MM=month, DD=day, YY=year]
;
;   CHANGED:  1)  Altered output slightly              [07/21/2008   v1.0.1]
;             2)  Updated man page and altered output:  Added new tag to structure
;                                                      [04/07/2009   v1.0.2]
;             3)  Now accepts arrays of dates          [05/01/2009   v2.0.0]
;             4)  Fixed issue when entering dates prior to 1990, though program will
;                   only be valid until 2060... at which point new software will be
;                   necessary                          [11/16/2010   v2.1.0]
;
;   CREATED:  06/05/2008
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  11/16/2010   v2.1.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-


Last Modification =>  2011-05-24/19:29:04 UTC
;+
;*****************************************************************************************
;
;  FUNCTION :   my_time_string.pro
;  PURPOSE  :  Creates a structure of times with strings of the form ('HH:MM:SS.sss') 
;                 and ('HHMMSS.sss'), time arrays in seconds of day, unix time, and
;                 epoch times.
;
;  CALLED BY:   
;               NA
;
;  CALLS:
;               epoch2unix.pro
;               time_double.pro
;               my_str_date.pro
;               time_struct.pro
;               unix2epoch.pro
;               string_replace_char.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               RT2       :  N-Element array of times in one of the following forms:
;                            1 = 'YYYY-MM-DD/HH:MM:SS[.ssss]'
;                            2 = 'MM/DD/YYYY HH:MM:SS[.ssss]'
;                            3 = 'MMDDYY HH:MM:SS[.ssss]'
;                            4 = 'HH:MM:SS.ssss'
;                            5 = 'HH:MM:SS'
;                            6 = 'YYYY/MM/DD hh:mm:ss[.xxxx...]'
;                            7 = Seconds of day (SOD) [float or double]
;                            8 = Unix time            [double]
;                            9 = Epoch time           [double]
;
;  EXAMPLES:    
;               
;
;  KEYWORDS:    
;               FORM      :  
;                            1 = Assumes ['YYYY-MM-DD/HH:MM:SS[.ssss]'] {Default}
;                            2 = Assumes ['MM/DD/YYYY HH:MM:SS[.ssss]'] 
;                            3 = Assumes ['MMDDYY HH:MM:SS[.ssss]']
;                            4 = Assumes ['HH:MM:SS.ssss']
;                            5 = Assumes ['HH:MM:SS']
;                            6 = Returns ['YYYY/MM/DD hh:mm:ss[.xxxx...]']
;                              but assumes input ['YYYY-MM-DD/HH:MM:SS[.ssss]']
;                               => FORM:6 is to change FORM:1 into a time_string.pro or
;                                    time_double.pro format-friendly string
;                      ...................................................................
;                      :   Define a format for string inputs which tells the             :
;                      :   program the locations of each element of the string           :
;                      :=>  {MON:0L,DAY:3L,YEAR:6L,HH:11L,MM:14L,SS:17L,MS:20L}          :
;                      :    for 'MM/DD/YYYY HH:MM:SS.ssss'                               :
;                      ...................................................................
;               SECONDS   :  Specifies the type of input given is in seconds
;                              of day => forces you to only get data in terms of one day
;               UNIX      :  Tells the program the times are in unix times
;               EPOCH     :  Time is in epoch format
;               STR       :  Tells program that input is a string of one of the forms:
;                              1)  ['YYYY-MM-DD/HH:MM:SS'] => can get unix and epoch times
;                              2)  ['MM/DD/YYYY HH:MM:SS'] => can get unix and epoch times
;                              3)  ['MMDDYY HH:MM:SS']     => can get unix and epoch times
;                              4)  ['HH:MM:SS.ssss']       => can ONLY get sec. of day
;                              5)  ['HH:MM:SS']            => can ONLY get sec. of day
;                              [Note: Forms 1-3 could have '.sss[s]' added on potentially]
;               TO_UNIX   :  Tells program to ONLY return an associated unix time
;               TO_SOD    :  Tells program to ONLY return seconds of day 
;               TO_EPOCH  :  Tells program to ONLY return an associated EPOCH time
;               TO_YMD    :  Tells program to ONLY return an array of form 
;                              ['YYYY-MM-DD/HH:MM:SS.ssss']
;               DATE      :  [string] 'MMDDYY' [MM=month, DD=day, YY=year]  ONLY send in
;                              this parameter when your array is in seconds of day to allow
;                              program to find other useful times (i.e. unix)
;               PREC      :  Scalar defining the number of decimal places to use for the
;                              fractional seconds
;                              [Default = 4, limit to 6 or less]
;
;   CHANGED:  1)  Changed manner in which to handle milliseconds if 
;                  a form is given, but data doesn't have millisecond
;                  data [09/04/2008   v1.1.1]
;             2)  Complete re-write                          [09/04/2008   v2.0.0]
;             3)  Changed output                             [09/05/2008   v2.0.1]
;             4)  Added keyword DATE                         [09/11/2008   v2.0.2]
;             5)  Changed order of Case statement for speed  [09/24/2008   v2.0.3]
;                 [increased speed by factor of 1.22961 from v2.0.2]
;             6)  Added function time_struct.pro             [09/24/2008   v2.0.4]
;                 [increased speed by factor of 2.33970 from v2.0.2]
;             7)  Removed function my_time_to_epoch.pro      [09/24/2008   v2.0.5]
;                 [increased speed by factor of 2.74314 from v2.0.2]
;             8)  my_str_date.pro output changed => changed indexing in my_time_string.pro
;                                                            [05/25/2009   v2.0.6]
;             9)  Added keyword:  NOMSSG                     [05/25/2009   v2.0.7]
;            10)  Changed precision of milliseconds          [07/16/2009   v2.1.0]
;            11)  Added keyword:  PREC                       [01/31/2010   v2.2.0]
;            12)  Fixed a typo                               [02/01/2010   v2.2.1]
;            13)  Fixed a typo                               [02/09/2010   v2.3.0]
;            14)  Added FORM = 6 (not a functionality issue)
;                                                            [05/29/2010   v2.3.1]
;            15)  Fixed issue with keyword PREC that occasionally became a problem
;                   and now calls string_replace_char.pro
;                   and updated man page and cleaned up program a little
;                                                            [10/15/2010   v2.4.0]
;            16)  Fixed an issue with keyword PREC that only affected string inputs
;                   of FORM=1, where user wished to change precision
;                                                            [05/24/2011   v2.4.1]
;
;   NOTES:      
;               1)  The keywords STR and FORM must be used together
;               2)  If input is a string, tell the program what the format is
;               3)  If input is a double, inform program if it is Epoch, SOD, or Unix
;
;   CREATED:  03/26/2008
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  05/24/2011   v2.4.1
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-


Last Modification =>  2008-10-16/17:22:43 UTC
;+
;*****************************************************************************************
;
;  FUNCTION :   my_windowf.pro
;  PURPOSE  :   Creates an array of data corresponding to a Hanning or Hamming window
;                 depending on user defined input (IWINDW) for FFT power spectrum
;                 analysis
;
;  CALLED BY:   NA
;
;  CALLS:       NA
;
;  REQUIRES:    NA
;
;  INPUT:
;               NSAMPLES  :  [n-1]-Data points
;               IWINDW    :  Set to 1 = Hamming window
;                            Set to 2 = Hanning window
;               WINDOWARR :  An n-element empty array to be filled by program with
;                              the corresponding Hanning(Hamming) window determined
;                              by the user
;
;  EXAMPLES:    NA
;
;  KEYWORDS:    NA
;
;   CHANGED:  1)  Vectorized a few calculations and changed syntax [10/16/2008   v1.0.0]
;
;   ADAPTED FROM:  windowf.pro  BY:  Kris Kersten,  Sept. 2007
;   CREATED:  10/16/2008
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  10/16/2008   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-


Last Modification =>  2009-03-19/20:48:42 UTC
;+
;*****************************************************************************************
;
;  FUNCTION :   my_ytitle_tplot.pro
;  PURPOSE  :   Determines what the appropriate Y-title should be from the given
;                 tplot name/index and added tags.  
;
;         Note:  **The program was designed for spectra data plots, so it may not
;                 work well for other types of tplot variables.**
;
;  CALLED BY: 
;
;  CALLS:
;               tnames.pro
;               get_data.pro
;
;  REQUIRES:    NA
;
;  INPUT:
;               NAME   : [string] Specify the TPLOT variable you wish to alter the
;                           YTITLE for
;
;  EXAMPLES:
;               yttl = my_ytitle_tplot('el_pads',TAG1='[Smoothed]')
;               yttl = my_ytitle_tplot('el_pads-2-0:1',TAG1='6.9-17.0!Uo!N')
;
;  KEYWORDS:  
;               TAG[N]  :  A string defined by user to be added to the previously
;                            defined ytitle, where N = 1, 2, 3, or 4
;               LOCTAG  :  A 4-element long array specifying the order in which
;                            the added labels {i.e. TAG[N]} should be added
;                            [0 = 1st thing in ytitle string, 1 = 2nd "", etc.]
;                            => IF NOT set, default = [0,1,2,3,4]
;
;   CHANGED:  1)  Fixed label issue     [08/18/2008   v1.0.7]
;             2)  Updated man page      [03/19/2009   v1.0.8]
;
;   CREATED:  06/21/2008
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  03/19/2009   v1.0.8
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-


Last Modification =>  2009-09-13/20:33:17 UTC
;+
;*****************************************************************************************
;
;  FUNCTION :   no_label.pro
;  PURPOSE  :   This function used to stop labeling of tick marks for plotting over a
;                 previous plot.
;
;  CALLED BY:   
;               oplot_tplot_spec.pro
;
;  CALLS:
;               NA
;
;  REQUIRES:    
;               NA
;
;  INPUT:
;               AXIS   :  The plot axis number (0=X, 1=Y, 2=Z)
;               INDEX  :  Tick mark index [indices start at zero]
;               T      :  Data value at tick mark [Double]
;
;  EXAMPLES:    
;               ; => To suppress X-Axis labels
;               x = FINDGEN(20)*(2d0*!DPI)/19L
;               y = SIN(x)
;               PLOT, x, y, XTICKFORMAT='no_label'
;
;  KEYWORDS:    
;               NA
;
;   CHANGED:  1)  NA [MM/DD/YYYY   v1.0.0]
;
;   NOTES:      
;               1)  This program assumes the [XYZ]TICKUNITS keyword[s] is[are] 
;                     NOT specified
;
;   CREATED:  09/13/2009
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  09/13/2009   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-


Last Modification =>  2009-08-12/12:49:37 UTC
;+
;*****************************************************************************************
;
;  FUNCTION :   omni_z_pads.pro
;  PURPOSE  :   This program gets rid of bad PAD data so one doesn't waste time
;                 sorting through all the different energy bins trying to get rid
;                 of the ones with the most data gaps.  The program returns the 
;                 calibrated data as a TPLOT variable for later use.
;
;  CALLED BY: 
;               calc_padspecs.pro
;
;  CALLS:
;               tnames.pro
;               get_data.pro
;               store_data.pro
;               options.pro
;               clean_spec_spikes.pro
;               spec_vec_data_shift.pro
;               ylim.pro
;
;  REQUIRES:    NA
;
;  INPUT:
;               NN1   :  [String] A defined TPLOT variable name with associated spectra
;                          data separated by pitch-angle as TPLOT variables
;                          [e.g. 'nelb_pads']
;
;  EXAMPLES:
;               zdat = z_pads_2('nelb_pads',LABS=mylabs,PANGS=myangs)
;
;  KEYWORDS:  
;               LABS  :  [string] Specifying the energy bin labels for plotting
;               PANGS :  [string] Specifying the pitch-angles to look at
;
;   CHANGED:  1)  Changed omni spectra calc                         [08/18/2008   v1.1.37]
;             2)  Updated man page                                  [03/19/2009   v1.1.38]
;             3)  Changed program my_str_names.pro to dat_3dp_str_names.pro
;                   and my_clean_spikes_2.pro to clean_spec_spikes.pro
;                   and my_data_shift_2.pro to spec_vec_data_shift.pro
;                   and renamed from z_pads_2.pro                   [08/12/2009   v2.0.0]
;
;   CREATED:  ??/??/????
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  08/12/2009   v2.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-


Last Modification =>  2009-08-11/15:42:02 UTC
;+
;*****************************************************************************************
;
;  FUNCTION :   one_count_level.pro
;  PURPOSE  :   This program calculates the one count level of a 3D particle distribution
;                 given a particle moment with the same format as those returned
;                 by the Wind/3DP get_??.pro programs.  
;
;  CALLED BY:   
;               cont2d.pro
;
;  CALLS:
;               dat_3dp_str_names.pro
;               velocity.pro
;               convert_ph_units.pro
;               convert_vframe.pro
;               pad.pro
;               distfunc.pro
;               extract_tags.pro
;               add_df2d_to_ph.pro
;
;  REQUIRES:    
;               NA
;
;  INPUT:
;               DAT  :  A 3D data structure produced by get_??.pro that has NOT been
;                         altered other than adding velocity frame (Tag VSW), magnetic
;                         field (Tag MAGF), and spacecraft potential (Tag SC_POT) data
;                         to the structure.
;                         [?? = el, eh, elb, ehb, ph, etc.]
;
;  EXAMPLES:    
;               t    = '1995-04-04/09:45:00'
;               td   = time_double(t)
;               el   = get_el(td)
;               add_vsw2,el,'[TPLOT Name for Vsw]'
;               add_magf2,el,'[TPLOT Name for B-field data]'
;               add_scpot,el,'[TPLOT Name for SC Potential]'
;               onct = one_count_level(el)
;
;  KEYWORDS:    
;               VLIM     :  Limit for x-y axes over which to plot data
;               NGRID    :  # of isotropic velocity grids to use to triangulate the data
;                             [Default = 20L]
;               NUM_PA   :  Number of pitch-angles to sum over (Default = 24L)
;               
;
;   CHANGED:  1)  NA [MM/DD/YYYY   v1.0.0]
;
;   CREATED:  08/10/2009
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  08/10/2009   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-


Last Modification =>  2010-07-14/14:35:29 UTC
;+
;*****************************************************************************************
;
;  FUNCTION :   oplot_tplot_spec.pro
;  PURPOSE  :   This program provides the ability to plot lines over a spectrogram
;                 plot in TPLOT interactively.  
;
;  CALLED BY:   
;               NA
;
;  CALLS:
;               tnames.pro
;               tplot.pro
;               get_data.pro
;               extract_tags.pro
;               str_element.pro
;               no_label.pro
;
;  REQUIRES:    
;               TPLOT libraries
;
;  INPUT:
;               NAMES      :  N-Element string array of TPLOT handles/names
;               OP_NAMES   :  M-Element string array of TPLOT handles/names
;
;  EXAMPLES:    
;               .......................................
;               :         Get data into TPLOT         :
;               .......................................
;               ex     = rot_tds_ef.(0)[*,0]    ; => Parallel E-field [N-element array]
;               utx    = REFORM(tds_unx[0,*])   ; => Unix time        [N-element array]
;               time   = '20000406_1632-09x380'
;               store_data,'Epara_'+time[0],DATA={X:utx,Y:ex}
;               paname = 'Epara_'+time[0]+'_wavelet'
;               wavelet_to_tplot,utx,ex,NEW_NAME=paname,SIGNIF=signif,CONE=cone,        $
;                                       PERIOD=period,FFT_THEOR=fft_theor,SCALES=scales,$
;                                       CONF_95LEV=conf_95lev
;               options,paname,'ZRANGE',[1e-1,1e3]
;               options,'Epara_'+time[0],'YRANGE',[-21e0,21e0]
;               options,paname,'YRANGE',[15e1,6e4]
;               op_names = 'Conf_Level_95'
;               store_data,op_names,DATA={X:utx,Y:conf_95lev,V:1d0/period,SPEC:1}
;               options,op_names,'LEVEL',1.0
;               options,op_names,'C_ANNOT','95%'
;               options,op_names,'ZRANGE',[5e-1,1e0]
;               options,op_names,'YTITLE','95% Confidence Level'+'!C'+'(anything > 1.0)'
;               store_data,'Cone_of_Influence',DATA={X:utx,Y:1d0/cone}
;               op_names = ['Conf_Level_95','Cone_of_Influence']
;               options,op_names,'YLOG',1
;               options,op_names,'YRANGE',[15e1,6e4]
;               nnw = tnames()
;               options,nnw,"YSTYLE",1
;               options,nnw,"PANEL_SIZE",2.
;               options,nnw,'XMINOR',5
;               options,nnw,'XTICKLEN',0.04
;               ......................................
;               : Plot OP_NAMES over PANAME in TPLOT :
;               ......................................
;               ltag = ['LEVELS','C_ANNOTATION','YLOG','C_THICK']
;               lims = CREATE_STRUCT(ltag,1.0,'95%',1,1.5)
;               oplot_tplot_spec,panames,op_names,LIMITS=lims
;
;  KEYWORDS:    
;               OPLOT_IND  :  Not sure yet...
;               LIMITS     :  A plot limits structure with tags associated with the
;                               keywords for the built-in IDL plotting routines.
;               TRANGE     :  2-Element double-array of Unix times specifying the time
;                               range you wish to plot
;               NOMSSG     :  If set, TPLOT will NOT print out the index and TPLOT handle
;                               of the variables being plotted
;
;   CHANGED:  1)  Added keyword:  NOMSSG                     [10/16/2009   v1.1.0]
;             2)  Changed manner in which program determines plot structure info
;                                                            [05/25/2010   v1.2.0]
;             3)  Added capacity to deal with different colors for overplotted lines
;                                                            [07/14/2010   v1.3.0]
;
;   NOTES:      
;               1)  At the moment, the program assumes that NAMES can be an N-element
;                     array of spectrogram and non-spectrogram plots in column form to
;                     plot over.  It also assumes that OP_NAMES is an M-element
;                     TPLOT handle that can either be line plots or a 2D contour plots.
;               2)  If the number of spec plots does NOT equal the number of elements in
;                     OP_NAMES, then program assumes you wish to plot ALL of OP_NAMES
;                     over ONLY the LAST spectrogram plot.
;
;   CREATED:  09/13/2009
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  07/14/2010   v1.3.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-


Last Modification =>  2011-04-21/03:11:21 UTC
;+
;*****************************************************************************************
;
;  FUNCTION :   colinear_chull.pro
;  PURPOSE  :   In case of colinear data sets, this program will calculate the
;                 effective convex hull of the input.
;                 [though it is essentially meaningless for colinear data]
;
;  CALLED BY:   
;               outer_perimeter_chull.pro
;
;  CALLS:
;               sign.pro
;               array_where.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               XX        :  N-Element array of x-data
;               YY        :  N-Element array of y-data
;
;  EXAMPLES:    
;               
;
;  KEYWORDS:    
;               CHULL     :  Set to a named variable to return the indices of the
;                              convex hull [counterclockwise order]
;
;   CHANGED:  1)  NA [MM/DD/YYYY   v1.0.0]
;
;   NOTES:      
;               1)  User should not call this routine
;
;   CREATED:  04/20/2011
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  04/20/2011   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-
;+
;*****************************************************************************************
;
;  FUNCTION :   outer_perimeter_chull.pro
;  PURPOSE  :   This routines calculates the convex hull of an input set of data in
;                 addition to determining only the outermost data points.
;
;  CALLED BY:   
;               NA
;
;  CALLS:
;               colinear_chull.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               XX        :  N-Element array of x-data
;               YY        :  N-Element array of y-data
;
;  EXAMPLES:    
;               
;
;  KEYWORDS:    
;               CHULL     :  Set to a named variable to return the indices of the
;                              convex hull [counterclockwise order]
;               OUTERPTS  :  Set to a named variable to return the indices of only the
;                              outermost points of the XY-scatter of data
;
;   CHANGED:  1)  NA [MM/DD/YYYY   v1.0.0]
;
;   NOTES:      
;               1)  Assumptions:
;                     A)  The mean of the {x,y} set of positions [defined as:  <{x,y}>]
;                           is located inside the convex hull of the set of points
;                     B)  The positions {x_m[i],y_m[i]} correspond to the maximum magnitude
;                           distances from the <{x,y}>
;                           => r_m[i] = |{(<x> - x_m[i]), (<y> - y_m[i])}|
;                           which are assumed to exist on the convex hull
;                     C)  The data must be on an irregular grid to work
;
;   CREATED:  04/20/2011
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  04/20/2011   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-


Last Modification =>  2009-08-05/12:46:00 UTC
;+
;*****************************************************************************************
;
;  FUNCTION :   pad_template.pro
;  PURPOSE  :   Create a dummy PAD structure to prevent code breaking upon
;                 multiple callings of the program my_pad_dist.pro.
;
;  CALLED BY:   
;               pad.pro
;
;  CALLS:       NA
;
;  REQUIRES:    NA
;
;  INPUT:
;               DAT  :  A 3d data structure such as those gotten from get_el,get_pl,etc.
;                         [e.g. "get_el"]
;                         Note:  If dat is not a 3DP data structure, NaNs, zeros, and
;                                  null strings replace quantities like dat.NENERGY
;
;  EXAMPLES:    NA
;
;  KEYWORDS:  
;               NUM_PA :  Number of pitch-angles to sum over (Default = 8L)
;               ESTEPS :  Energy bins to use [an array of energy bin elements defined in
;                           pad.pro]
;
;   CHANGED:  1)  Added keyword ESTEPS                 [12/08/2008   v2.0.0]
;             2)  Changed name from my_pad_template.pro to pad_template.pro
;                   and altered a few things           [07/20/2009   v2.1.0]
;             3)  Fixed a syntax issue                 [08/05/2009   v2.1.1]
;
;   CREATED:  04/20/2008
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  08/05/2009   v2.1.1
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-


Last Modification =>  2009-10-08/18:17:01 UTC
;+
;*****************************************************************************************
;
;  FUNCTION :   padspec_ascii_to_tplot.pro
;  PURPOSE  :   Gets particle moment spectra from the ASCII files written by
;                 write_padspec_ascii.pro by calling read_padspec_wrapper.pro.  
;                 read_padspec_wrapper.pro reads in the data and returns a TPLOT
;                 formatted structure.  Then padspec_ascii_to_tplot.pro splits the 
;                 returned structure into various Pitch-Angles (PA's) Distributions 
;                 (PADs).  The PAD's are then sent through other programs which either 
;                 smooth the data using IDL's SMOOTH.PRO or they normalize and shift the
;                 data for a more dramatic illustration of relative changes in particle
;                 [UNITS].  The manipulation is similar to that done by 
;                 calc_padspecs.pro, but does not require the Wind/3DP CDF libraries.
;                 Often times the particle spectra can appear very "noisy" which 
;                 prevents one from seeing the important structure which may or may not
;                 exist in the data.  So smoothing is done to allow one to see the
;                 relative structure and to eliminate "bad" or "null" data in some cases
;                 (read IDL's page on SMOOTH.PRO).  The program is MUCH faster than
;                 calling calc_padspecs.pro without pre-loaded Wind/3DP data structures
;                 (i.e. the DAT_ARR not set).  Also, since this program ONLY loads data
;                 from ASCII files and not entire data structures, much longer periods
;                 of time can be loaded than with calc_padspecs.pro for the same
;                 computer.  Though the ASCII files can often exceed 30 MB in size,
;                 they still rarely take longer than 30 seconds to load and manipulate
;                 into TPLOT variables (compared to the often excessive 300+ seconds
;                 get_padspecs.pro may require to load all the 3DP moments, and add
;                 magnetic field data to them, then create PADs, and then create one 
;                 TPLOT variable).  The write_padspec_ascii.pro program may take a while
;                 to write two weeks worth of ASCII files, but it is a passive process
;                 that can be done on a separate machine while the user works elsewhere.
;                 However, once the ASCII files are written, one can load all the data
;                 as often as they want in a relatively short period of time.
;
;  CALLED BY:   
;               NA
;
;  CALLS:
;               my_str_date.pro
;               dat_3dp_str_names.pro
;               wind_3dp_units.pro
;               read_padspec_wrapper.pro
;               store_data.pro
;               options.pro
;               reduce_pads.pro
;               clean_spec_spikes.pro
;               spec_vec_data_shift.pro
;               tnames.pro
;
;  REQUIRES:    
;               ASCII files created by write_padspec_ascii.pro
;
;  INPUT:
;               NAME       :  [string] Specify the type of structure you wish to 
;                               get the data for [i.e. 'el','eh','elb',etc.]
;
;  EXAMPLES:    
;               .............................................................
;               : If we want to get all the SST Foil data for 1996-04-03,   :
;               : in units of energy flux,                                  :
;               : with extra TPLOT variables of normalized eflux,           :
;               : and extra TPLOT variables of cleaned/smoothed eflux, then :
;               .............................................................
;               date  = '040396'
;               name  = 'sf'
;               units = 'eflux'
;               datn  = 1
;               datcl = 1
;               padspec_ascii_to_tplot,name,DAT_NORM=datn,DAT_CLN=datcl,$
;                                           DATE=date,UNITS=units
;
;  KEYWORDS:    
;               EBINS      :  [array,scalar] specifying which energy bins to create 
;                               particle spectra plots for
;               TRANGE     :  [Double] 2 element array specifying the range over 
;                               which to get data structures for
;               DATE       :  Scalar string (e.g. 'MMDDYY') specifying the date of interest
;               DAT_SHFT   :  If set, new TPLOT variables are created of the data shifted
;                               vertically on the Y-Axis to avoid overlaps (for easier
;                               viewing of data)
;               DAT_NORM   :  If set, new TPLOT variables are created of the data shifted
;                               and normalized [Note:  If this keyword is set, it
;                               overrides the DAT_SHFT keyword]
;               DAT_CLN    :  If set, new TPLOT variables are created of the data smoothed
;                               over a width determined by the type of data (i.e. 'el'
;                               needs less smoothing than 'sf') and the number of data
;                               points
;               UNITS      :  Wind/3DP data units for particle data include:
;                               'df','counts','flux','eflux',etc.
;                                [Default = 'flux']
;               RANGE_AVG  :  Two element double array specifying the time range
;                               (Unix time) to use for constructing an average to
;                               normalize the data by when using the keyword DAT_NORM
;
;   CHANGED:  1)  Program now normalizes the cleaned separated PAD specs
;                                                                   [09/24/2009   v1.1.0]
;             2)  Minor syntax touch-ups                            [09/30/2009   v1.1.1]
;             3)  Changed TPLOT storing such that TPLOT handles now contain the
;                   units of the spectra data for loading multiple unit types for
;                   comparison                                      [10/07/2008   v1.2.0]
;             3)  Changed TPLOT Y-Axis title determination          [10/08/2008   v1.3.0]
;
;   NOTES:      
;               1)  All new TPLOT variables will have suffixes that inform the user of
;                     type of stacked particle data present, including any combination
;                     of the following:
;                     '_cln'  :  Cleaned/Smoothed data      [Use DAT_CLN]
;                     '_sh'   :  Vertically shifted data    [Use DAT_SHFT]
;                     '_n'    :  Normalized by data in time range defined by 
;                                  the RANGE_AVG keyword    [Use DAT_NORM]
;
;   CREATED:  09/21/2009
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  10/08/2008   v1.3.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-


Last Modification =>  2009-08-12/12:45:56 UTC
;+
;*****************************************************************************************
;
;  FUNCTION :  padspecs_reader.pro
;  PURPOSE  :  Reads in ASCII files produced by my_padspec_writer.pro and returns a data
;               structure to my_padspec_rw.pro where the data is manipulated.  [This 
;               program should NOT be called by the user directly.]
;
;  CALLED BY:   
;               padspecs_to_tplot.pro
;
;  CALLS:
;               my_str_date.pro
;               dat_3dp_str_names.pro
;               dat_3dp_energy_bins.pro
;               my_3dp_plot_labels.pro
;
;  REQUIRES:    
;               ASCII files created by my_padspec_writer.pro
;
;  INPUT:
;               NAME    : [string] Specify the type of structure you wish to 
;                          get the data for [i.e. 'el','eh','elb',etc.]
;
;  EXAMPLES:    NA
;
;  KEYWORDS:  
;               EBINS   : [array,scalar] specifying which energy bins to create 
;                            particle spectra plots for
;               TRANGE  :  [Double] 2 element array specifying the range over 
;                            which to get data structures for
;               DATE    : [string] 'MMDDYY' specifying the date of interest
;
;   CHANGED:  1)  Changed structure formats                 [08/18/2008   v1.0.3]
;             2)  Changed 'man' page                        [09/15/2008   v1.0.4]
;             3)  Changed syntax                            [11/07/2008   v1.0.5]
;             4)  Fixed string conversion issue with NaN's in files
;                                                           [11/10/2008   v1.0.6]
;             5)  Changed indexing issue                    [11/10/2008   v1.0.7]
;             6)  Fixed typo                                [11/14/2008   v1.0.8]
;             7)  Fixed indexing issue                      [11/26/2008   v1.0.9]
;     [Note:  v1.0.9 only affects results where ONLY 1 file/name is called]
;             8)  Changed array definition to account for non-default sized
;                  ascii files where the PAs or Energies are different
;                                                           [02/25/2009   v1.0.10]
;             9)  Fixed syntax issue                        [05/04/2009   v1.1.0]
;            10)  Changed program my_3dp_energy_bins.pro to dat_3dp_energy_bins.pro
;                   and my_str_names.pro to dat_3dp_str_names.pro
;                   and renamed from my_padspec_reader.pro  [08/12/2009   v2.0.0]
;
;   CREATED:  08/12/2008
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  08/12/2009   v2.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-


Last Modification =>  2009-08-12/12:38:45 UTC
;+
;*****************************************************************************************
;
;  FUNCTION :   padspecs_to_tplot.pro
;  PURPOSE  :   Gets particle moment spectra from the ASCII files written by
;                 my_padspec_writer.pro by calling my_padspec_reader.pro.  This 
;                 program reads in the data and splits the returned structure into
;                 various Pitch-Angles (PA's) Distributions (PADs).  The PAD's are 
;                 then sent through other programs which either smooth the data
;                 using IDL's SMOOTH.PRO or they normalize and shift the data for
;                 a more dramatic illustration of relative changes in particle flux.
;                 The manipulation is similar to that done by my_padspec_4.pro but 
;                 there is an added TPLOT variable which my_padspec_4.pro deletes,
;                 "*_cln".  These TPLOT variables are the resultant data after is
;                 has ONLY been smoothed.  Often times the particle spectra can appear
;                 very "noisy" which prevents one from seeing the important structure
;                 which may or may not exist in the data.  So smoothing is done to
;                 allow one to see the relative structure and to eliminate "bad" or
;                 "null" data in some cases (read IDL's page on SMOOTH.PRO).
;                 The program is MUCH faster than trying to use my_padspec_4.pro on
;                 a machine capable of handling the 3DP shared object libraries because
;                 it only calls ASCII files for ONLY the data of interest.
;                 The original method of calling spectra data required loading 
;                 multiple days of 3DP data, which can be computationally 
;                 cumbersome and require a lot of patience.  Though the ASCII
;                 files can often exceed 30 MB in size, they still rarely take longer
;                 than 30 seconds to load and manipulate into TPLOT variables
;                 (compared to the often excessive 300+ seconds get_padspec.pro
;                 may require to load all the 3DP moments, add magnetic field data
;                 to them, create PADs, and then create one TPLOT variable).
;                 Though my_padspec_writer.pro can take upwards of 400 seconds
;                 (Blade Sun Machine with 2 GBs of RAM), it is a passive thing which
;                 can be done while the user is working on something else.  Once
;                 the ASCII file is written, however, one never needs to load
;                 said 3DP data again for this particular type of data.
;
;  CALLED BY:   NA
;
;  CALLS:    
;               my_str_date.pro
;               dat_3dp_str_names.pro
;               padspecs_reader.pro
;               store_data.pro
;               options.pro
;               ylim.pro
;               clean_spec_spikes.pro
;               spec_vec_data_shift.pro
;               reduce_pads.pro
;               z_pads_2.pro
;
;  REQUIRES:    ASCII Files produced by my_padspec_writer.pro
;
;  INPUT:
;               NAME    : [string] Specify the type of structure you wish to 
;                           get the data for [i.e. 'el','eh','elb',etc.]
;
;  EXAMPLES:
;               t      = ['1997-01-08/00:00:00','1997-01-12/00:00:00']
;               trange = time_double(t)
;               date   = '011097'
;               my_padspec_rw,'sf',EBINS=[0,6],TRANGE=trange,DATE=date
;
;  KEYWORDS:  
;               EBINS   : [array,scalar] specifying which energy bins to create 
;                           particle spectra plots for
;               TRANGE  :  [Double] 2 element array specifying the range over 
;                           which to get data structures for
;               DATE    : [string] 'MMDDYY' specifying the date of interest
;
;
;   CHANGED:  1)  Changed to accomodate different operating systems [08/18/2008   v1.0.2]
;             2)  Changed 'man' page                                [09/15/2008   v1.0.3]
;             3)  Updated 'man' page                                [11/11/2008   v1.0.4]
;             4)  Fixed syntax issue                                [05/04/2009   v1.0.5]
;             5)  Changed program my_str_names.pro to dat_3dp_str_names.pro
;                   and my_padspec_reader.pro to padspecs_reader.pro
;                   and my_clean_spikes_2.pro to clean_spec_spikes.pro
;                   and my_data_shift_2.pro to spec_vec_data_shift.pro
;                   and renamed from my_padspec_rw.pro              [08/12/2009   v2.0.0]
;
;   CREATED:  08/13/2008
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  08/12/2009   v2.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-


Last Modification =>  2009-08-12/12:29:34 UTC
;+
;*****************************************************************************************
;
;  FUNCTION :   padspecs_writer.pro
;  PURPOSE  :   Creates an ASCII file associated with any given pitch-angle (PA)
;                 spectra you desire from the 3DP instruments.  The files are 
;                 printed with repeating time values because of the 3-D input 
;                 array format.  So each row is the data and energy bin values
;                 for every PA at a given time.  Thus if one has 15 PA's, then
;                 the first 15 rows will represent data at a single time stamp
;                 but at different PA's.  The column represents the data in each
;                 energy bin, row is the PA, and every 15 rows (in this example)
;                 a new time step occurs.  The last columns are the energy bin
;                 values determined by the routine, my_3dp_energy_bins.pro.
;                 This program is useful for loading large time periods with 
;                 a lot of 3DP moments because it allows one to create ASCII files
;                 which don't require WindLib to run, thus saving on RAM and time.
;                 The output is the same result one might get from the routine
;                 get_padspecs.pro.  The only thing done to the data is a separation
;                 into PA's and unit conversion to flux from counts.
;
;  CALLED BY:   NA
;
;  CALLS:
;               dat_3dp_str_names.pro
;               get_padspecs.pro
;               energy_params_3dp.pro
;               get_data.pro
;               dat_3dp_energy_bins.pro
;               my_3dp_plot_labels.pro
;
;  REQUIRES:    
;               Wind 3DP AND magnetic field data MUST be loaded first
;
;  INPUT:
;               NAME    :  [string] Specify the type of structure you wish to 
;                            get the data for [i.e. 'el','eh','elb',etc.]
;
;  EXAMPLES:    print, my_padspec_writer('sf',TRANGE=trange)
;
;  KEYWORDS:  
;               EBINS   :  [array,scalar] specifying which energy bins to create 
;                            particle spectra plots for
;               VSW     :  [string,tplot index] specifying a solar wind velocity
;               TRANGE  :  [Double] 2 element array specifying the range over 
;                            which to get data structures [Unix time]
;               NUM_PA  :  Number of pitch-angles to sum over (Default = 8L)
;
;   CHANGED:  1)  Changed structure formats                 [08/13/2008   v1.0.2]
;             2)  Changed 'man' page                        [09/15/2008   v1.0.3]
;             3)  Updated 'man' page                        [11/11/2008   v1.0.4]
;             4)  Added keyword:  NUM_PA                    [02/25/2009   v1.1.0]
;             5)  Changed program my_3dp_energy_bins.pro to dat_3dp_energy_bins.pro
;                   and my_str_names.pro to dat_3dp_str_names.pro
;                   and my_get_padspec_5.pro to get_padspecs.pro
;                   and my_energy_params.pro to energy_params_3dp.pro
;                   and renamed from my_padspec_writer.pro  [08/12/2009   v2.0.0]
;
;   CREATED:  08/12/2008
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  08/12/2009   v2.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-


Last Modification =>  2011-04-19/23:48:53 UTC
;+
;*****************************************************************************************
;
;  FUNCTION :   partition_data.pro
;  PURPOSE  :   Partitions data into [LENGTH]-element segments with 
;                 [LENGTH - OFFSET]-element overlaps to create a new array of data
;                 that has been binned along one axis.
;
;  CALLED BY:   
;               NA
;
;  CALLS:
;               NA
;
;  REQUIRES:    
;               NA
;
;  INPUT:
;               XX      :  N-Element array of x-data to be put into bins
;               LENGTH  :  Scalar defining the # of elements in XX to treat as a
;                            single bin
;               OFFSET  :  Scalar defining the # of elements to shift each time
;                            the program recalculates the distribution in a bin
;
;  EXAMPLES:    
;               yy      = [1,2,3,4,5,6,7,8,9]
;               length  = 4
;               offset  = 2
;               test    = partition_data(yy, length, offset)
;               PRINT, test[*,*,0]
;                      1.0000000       2.0000000       3.0000000       4.0000000
;                      3.0000000       4.0000000       5.0000000       6.0000000
;                      5.0000000       6.0000000       7.0000000       8.0000000
;
;  KEYWORDS:    
;               YY      :  N-Element array of y-data to be put into bins
;
;   CHANGED:  1)  Vectorized a few things and cleaned up a bit      [04/19/2011   v1.0.0]
;
;   NOTES:      
;               1)  Make sure that LENGTH < N, where N = # of elements in YY
;               2)  If only one argument is passed, then the program assumes it to be
;                     an array of data
;
;   CREATED:  04/19/2011
;   CREATED BY:  Jesse Woodroffe
;    LAST MODIFIED:  04/19/2011   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-


Last Modification =>  2011-02-22/20:07:58 UTC
;+
;*****************************************************************************************
;
;  FUNCTION :   pesa_high_bad_bins.pro
;  PURPOSE  :   This program kills off all the data bins which have a "glitch" in the
;                 energy bin values AND the data.  This prevents the Pesa High
;                 structures from producing false or irrelevant data at these points.
;                 Note, however, that the Pesa High instrument is plagued with UV
;                 and solar wind contamination so it should be dealt with carefully.
;
;  CALLED BY:   
;               add_df2d_to_ph.pro
;               pesa_high_str_fill.pro
;               dat_3dp_energy_bins.pro
;               plot3d.pro
;
;  CALLS:
;               dat_3dp_str_names.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               DAT     :  3DP data structure(s) either from get_ph.pro or get_phb.pro
;
;  EXAMPLES:    
;               to  = time_double('1995-04-03/05:40:00')
;               ph  = get_ph(to)
;               pesa_high_bad_bins,ph
;
;  KEYWORDS:    
;               NA
;
;   CHANGED:  1)  Removed program:  my_3dp_energy_bins.pro        [04/26/2009   v1.0.1]
;             2)  Changed program my_str_names.pro to dat_3dp_str_names.pro
;                   and renamed                                   [08/10/2009   v2.0.0]
;             3)  Updated 'man' page                              [10/05/2008   v2.0.1]
;             4)  Updated 'man' page                              [02/13/2010   v2.0.2]
;             5)  Added error handling for moments produced by the Mac OS X shared
;                   object library which produces anomalous data spikes
;                                                                 [02/18/2011   v2.1.0]
;             6)  Fixed an issue with new error handling for arrays of PH structures
;                                                                 [02/22/2011   v2.1.1]
;
;   NOTES:      
;               1)  dat.UNITS_NAME = 'Counts' when this routine is called
;               2)  Though I refer to these bad data bins as a "glitch" it is actually
;                     due to a double-sweep mode and UV light contamination.  It can
;                     be easily identified if you plot the sun direction on contour
;                     plots of the phase space density for multiple consecutive 
;                     distributions.  As you scroll through the plots, you will see
;                     a beam-like feature that follows the sun direction.  Even after
;                     removing these "bad" bins, this feature may still exist in your
;                     plots, so be careful.
;               3)  The Mac OS X shared object library issue only seems to affect the
;                     Pesa High distributions.  Anomalous data points with counts
;                     in the tens to hundreds of millions can be found when you use
;                     get_3dp_structs.pro, get_ph.pro, or get_phb.pro on a Mac 
;                     machine with intell processor.  I am assuming there is a formatting
;                     issue in the compiler that causes a NaN to be translated as
;                     some large number (typical vales are roughly 1.91e+07 or greater).
;
;   CREATED:  04/26/2009
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  02/22/2011   v2.1.1
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-


Last Modification =>  2010-04-27/14:12:54 UTC
;+
;*****************************************************************************************
;
;  FUNCTION :   pesa_high_dummy_str.pro
;  PURPOSE  :   Returns a Pesa High dummy data structure for structure replication.
;
;  CALLED BY: 
;               dummy_pesa_struct.pro
;
;  CALLS:       NA
;
;
;  REQUIRES:    NA
;
;  INPUT:
;               NSTR     :  [string] Name of structure [i.e. 'Pesa High']
;               NBINS    :  [long] # of data bins
;               MAPCODE  :  [long] Converted Hex # associated with NBINS
;
;  EXAMPLES:    NA
;
;  KEYWORDS:    NA
;
;   CHANGED:  1)  Updated man page               [03/19/2009   v1.0.1]
;             2)  Updated man page               [04/27/2010   v1.0.2]
;
;   CREATED:  08/18/2008
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  04/27/2010   v1.0.2
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-


Last Modification =>  2011-05-05/22:15:48 UTC
;+
;*****************************************************************************************
;
;  FUNCTION :   pesa_high_moment_calibrate.pro
;  PURPOSE  :   This program calls the ion moments from the PESA High detector on the
;                 Wind spacecrafts 3DP instrument.  The data is interpolated to
;                 eliminate data gaps and data glitch unique to the PESA high detector.
;
;  CALLED BY:   
;               NA
;
;  CALLS:
;               my_str_date.pro
;               get_ph.pro
;               get_phb.pro
;               get_3dp_structs.pro
;               tnames.pro
;               pesa_high_dummy_str.pro
;               pesa_high_bad_bins.pro
;               dat_3dp_energy_bins.pro
;               str_element.pro
;               mom3d.pro
;               interp.pro
;               store_data.pro
;               options.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               NA
;
;  EXAMPLES:    
;               
;
;  KEYWORDS:    
;               DATE      :  [string] 'MMDDYY' [MM=month, DD=day, YY=year]
;               TRANGE    :  [Double] 2-Element array specifying the time range over 
;                              which to get data structures for [Unix time]
;               NOLOAD    :  If set, program does not attempt to call the program
;                              get_moment3d.pro because it assumes you've already
;                              loaded the relevant ion data.  [use on iMac]
;               PHM       :  N-Element array of Pesa High 3DP moment structures.  
;                              This keyword is intended to be used in association 
;                              with the NOLOAD keyword specifically for users with
;                              IDL save files on a non-SunMachine computer.
;               PHBM      :  N-Element array of Pesa High Burst 3DP moment structures.
;                              This keyword is intended to be used in association 
;                              with the NOLOAD keyword specifically for users with
;                              IDL save files on a non-SunMachine computer.
;               G_MAGF    :  If set, tells program that the structures in PLM or PLBM
;                              already have the magnetic field added to them thus 
;                              preventing this program from calling add_magf2.pro 
;                              again.
;               BNAME     :  Scalar string defining the TPLOT name of the B-field
;                              times you wish to interpolate the positions to
;                              [Default = 'wi_B3(GSE)']
;
;   CHANGED:  1)  Fixed typo when NOLOAD is not set               [08/05/2010   v1.0.1]
;             2)  Fixed typo associated with NOLOAD keyword       [08/10/2010   v1.0.2]
;             3)  Added keyword:  BNAME                           [04/16/2011   v1.0.3]
;             4)  Fixed typo in BNAME default                     [05/05/2011   v1.0.4]
;
;   NOTES:      
;               
;
;   CREATED:  04/27/2010
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  05/05/2011   v1.0.4
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-


Last Modification =>  2010-04-09/21:35:46 UTC
;+
;*****************************************************************************************
;
;  FUNCTION :   pesa_high_str_fill.pro
;  PURPOSE  :   The purpose of this program is to combine multiple Pesa High structures
;                 from the Wind 3DP instrument when one calls data from multiple days.
;                 The result is often that there are data structures with differing
;                 mapcodes on different days.  So in an attempt to automate the process
;                 of calling multiple days, this program attempts to elliminate that
;                 problem.  It creates an 
;
;
;               MAPCODE      HEX CODE       # of Data bins
;               ==========================================
;               54436L        'D4A4'              121
;               54526L        'D4FE'               97
;               54764L        'D5EC'               56
;               54971L        'D6BB'               65
;               54877L        'D65D'               88
;
;  CALLED BY: 
;               get_padspecs.pro
;
;  CALLS:
;               pesa_high_bad_bins.pro
;               dat_3dp_str_names.pro
;               pesa_high_dummy_str.pro
;               str_element.pro
;
;  REQUIRES:    NA
;
;  INPUT:
;               NDATA    :  Set to a named variable to be returned as an N-element array 
;                             of Pesa High structures of one format to be filled by up to
;                             three other structures of other formats
;                           **[Different mapcodes lead to different #'s of data bins]**
;
;  EXAMPLES:    NA
;
;  KEYWORDS:  
;               DUM1     :  N-Element array of Pesa High(Burst) data structures
;               DUM2     :  Same as DUM1
;               DUM3     :  Same as DUM1
;               NAME     :  [string] Specify the type of structure you wish to 
;                             use [i.e. 'el','eh','elb',etc.]
;
;   CHANGED:  1)  Removed Inputs: MAPCODE, NDAT, and NAME     [04/26/2009   v1.1.0]
;             2)  Added keyword:  NAME                        [04/26/2009   v1.1.1]
;             3)  Fixed a minor syntax error                  [06/25/2009   v1.1.2]
;             4)  Changed program my_str_names.pro to dat_3dp_str_names.pro
;                   and renamed                               [08/10/2009   v2.0.0]
;             5)  Fixed a minor syntax error with DATA_NAME tag
;                                                             [04/09/2010   v2.0.1]
;
;   CREATED:  04/24/2009
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  04/09/2010   v2.0.1
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-


Last Modification =>  2011-05-05/22:16:14 UTC
;+
;*****************************************************************************************
;
;  FUNCTION :   pesa_low_moment_calibrate.pro
;  PURPOSE  :   This program calls the ion moments from the PESA Low detector on the
;                 Wind spacecrafts 3DP instrument.  The data is interpolated to
;                 eliminate data gaps and if near a shock, the downstream can be
;                 re-calibrated according to the "known" compression ratio determined
;                 by J.C. Kasper or by examination of the plasma line from WAVES.
;
;  CALLED BY:   
;               NA
;
;  CALLS:
;               my_str_date.pro
;               get_pl.pro
;               get_plb.pro
;               tnames.pro
;               moments_3d.pro
;               get_moment3d.pro
;               store_data.pro
;               get_data.pro
;               interp.pro
;               sc_pot.pro
;
;  REQUIRES:    
;               LOAD_3DP_DATA must be ran first or user must supply 3DP data structures
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               NA
;
;  EXAMPLES:    
;               RESTORE,mfile[0]
;               date = '040396'
;               pesa_low_moment_calibrate,DATE=date,/NOLOAD,PLM=apl,PLBM=aplb
;               **[Note:  apl and aplb were in the IDL save file, mfile[0] ]**
;
;  KEYWORDS:    
;               DATE      :  [string] 'MMDDYY' [MM=month, DD=day, YY=year]
;               TRANGE    :  [Double] 2-Element array specifying the time range over 
;                              which to get data structures for [Unix time]
;               NOLOAD    :  If set, program does not attempt to call the program
;                              get_moment3d.pro because it assumes you've already
;                              loaded the relevant ion data.  [use on iMac]
;               PLM       :  N-Element array of Pesa Low 3DP moment structures.  
;                              This keyword is intended to be used in association 
;                              with the NOLOAD keyword specifically for users with
;                              IDL save files on a non-SunMachine computer.
;               PLBM      :  N-Element array of Pesa Low Burst 3DP moment structures.
;                              This keyword is intended to be used in association 
;                              with the NOLOAD keyword specifically for users with
;                              IDL save files on a non-SunMachine computer.
;               COMPRESS  :  Scalar defining the shock compression ratio if the desired
;                              data is in/around a shock => used to calibrate ion
;                              ion density and SC potential
;               MIDRA     :  If COMPRESS is set, set to a scalar defining the Unix
;                              time associated with the middle of the shock ramp
;                              to differentiate between upstream and downstream
;                              [Default = middle of ion moment time range]
;               G_MAGF    :  If set, tells program that the structures in PLM or PLBM
;                              already have the magnetic field added to them thus 
;                              preventing this program from calling add_magf2.pro 
;                              again.
;               BNAME     :  Scalar string defining the TPLOT name of the B-field
;                              times you wish to interpolate the positions to
;                              [Default = 'wi_B3(GSE)']
;
;   CHANGED:  1)  Renamed and updated man page                    [08/05/2009   v2.0.0]
;             2)  Changed some minor syntax                       [08/26/2009   v2.0.1]
;             3)  Fixed syntax error                              [08/28/2009   v2.0.2]
;             4)  Fixed a possible issue                          [09/09/2009   v2.0.3]
;             5)  Fixed syntax error with indexing when TRANGE is not set
;                                                                 [09/14/2009   v2.0.4]
;             6)  Added keyword:  G_MAGF                          [09/23/2009   v2.0.5]
;             7)  Changed SC Pot calibration for 02/11/2000       [12/02/2009   v2.0.6]
;             8)  Changed SC Pot calibration for 04/30/1998 and 05/15/1998
;                                                                 [03/07/2010   v2.1.0]
;             9)  Changed color assignments on vector quantities  [04/27/2010   v2.1.1]
;            10)  Added keyword:  BNAME                           [04/16/2011   v2.1.2]
;            11)  Fixed typo in BNAME default                     [05/05/2011   v2.1.3]
;
;   CREATED:  08/05/2009
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  05/05/2011   v2.1.3
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-


Last Modification =>  2010-09-22/21:56:39 UTC
;+
;*****************************************************************************************
;
;  FUNCTION :   plot_freq_ticks.pro
;  PURPOSE  :   Creates a power spectrum plot structure specifically for 
;                 plot_vector_mv_data.pro.
;
;  CALLED BY: 
;               plot_vector_mv_data.pro
;
;  CALLS:       
;               NA
;
;  REQUIRES:    
;               NA
;
;  INPUT:
;               FRA   :  2-Element array w/ values 0.0001 < vals < 1000000.0
;
;  EXAMPLES:    
;               NA
;
;  KEYWORDS:    
;               XLOG  :  Same usage as for PLOT.PRO etc.
;
;   CHANGED:  1)  Changed tick marks to account for higher frequencies 
;                                                                  [06/08/2009   v1.1.0]
;             2)  Updated man page
;                   and renamed from my_plot_mv_htr_tick.pro       [08/12/2009   v2.0.0]
;             3)  Increased resolution of tick marks for better output and added
;                   keyword:  XLOG
;                                                                  [09/22/2010   v2.1.0]
;
;   CREATED:  12/30/2008
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  09/22/2010   v2.1.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-


Last Modification =>  2011-03-09/23:41:07 UTC
;+
;*****************************************************************************************
;
;  FUNCTION :   plot_keyword_lists.pro
;  PURPOSE  :   This routine returns a string array of acceptable keywords for different
;                 types of plotting routines in IDL.  Use the keywords defined below
;                 to tell the program which type of plot you will be using.
;
;  CALLED BY:   
;               plot_struct_format_test.pro
;
;  CALLS:
;               NA
;
;  REQUIRES:    
;               NA
;
;  INPUT:
;               NA
;
;  EXAMPLES:    
;               ;+++++++++++++++++++++++++++++++++++++++++++++
;               ; => Get list of keywords accepted by PLOT.PRO
;               ;+++++++++++++++++++++++++++++++++++++++++++++
;               test = plot_keyword_lists(/PLOT)
;
;  KEYWORDS:    
;               OPLOT       :  If set, returns the keywords accepted by OPLOT
;               PLOT        :  If set, returns the keywords accepted by PLOT
;               SPLOT       :  If set, returns the keywords accepted by PLOTS
;               CONTOUR     :  If set, returns the keywords accepted by CONTOUR
;               AXIS        :  If set, returns the keywords accepted by AXIS
;               SCALE3      :  If set, returns the keywords accepted by SCALE3
;               SURFACE     :  If set, returns the keywords accepted by SURFACE
;               SHADE_SURF  :  If set, returns the keywords accepted by SHADE_SURF
;
;   CHANGED:  1)  NA [MM/DD/YYYY   v1.0.0]
;
;   NOTES:      
;               
;
;   CREATED:  03/09/2011
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  03/09/2011   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-


Last Modification =>  2011-03-09/23:40:10 UTC
;+
;*****************************************************************************************
;
;  FUNCTION :   plot_struct_format_test.pro
;  PURPOSE  :   This program can help the user define plot routine keyword structures.
;
;  CALLED BY:   
;               NA
;
;  CALLS:
;               plot_keyword_lists.pro
;               array_where.pro
;               struct_new_el_add.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               STRUCT      :  IDL structure with tags acceptable by one of the
;                                IDL plotting routines listed below in the keywords.
;
;  OUTPUT:
;               [1,0]       :  For use of any ONE keyword except REMOVE_BAD and EXCEPT
;               IDL Struct  :  For use of REMOVE_BAD or EXCEPT with appropriate plot
;                                type keyword
;
;  EXAMPLES:    
;               oldstr = {XRANGE:[0.,1.],YTITLE:'Dependent Data',XSTYLE:1}
;               ;+++++++++++++++++++++++++++++++++++
;               ; => Example of using EXCEPT keyword
;               ;+++++++++++++++++++++++++++++++++++
;               test = plot_struct_format_test(oldstr,EXCEPT='YTITLE',/PLOT)
;               ;++++++++++++++++++++++++++++++++++++++++
;               ; => Example of using REMOVE_BAD keyword
;               ;++++++++++++++++++++++++++++++++++++++++
;               oldstr = {XRANGE:[0.,1.],YTITLE:'Dependent Data',ZEBRA:1}
;               test   = plot_struct_format_test(oldstr,/REMOVE_BAD,/PLOT)
;
;  KEYWORDS:    
;               OPLOT       :  If set, tells IDL to use the keywords associated with 
;                                OPLOT
;               PLOT        :  If set, tells IDL to use the keywords associated with 
;                                PLOT
;               SPLOT       :  If set, tells IDL to use the keywords associated with 
;                                PLOTS
;               CONTOUR     :  If set, tells IDL to use the keywords associated with 
;                                CONTOUR
;               AXIS        :  If set, tells IDL to use the keywords associated with 
;                                AXIS
;               SCALE3      :  If set, tells IDL to use the keywords associated with 
;                                SCALE3
;               SURFACE     :  If set, tells IDL to use the keywords associated with 
;                                SURFACE
;               SHADE_SURF  :  If set, tells IDL to use the keywords associated with 
;                                SHADE_SURF
;               REMOVE_BAD  :  If set, routine removes bad keyword values from return
;                                structure
;               EXCEPT      :  String array of keywords to exclude from return
;                                structure
;
;   CHANGED:  1)  NA [MM/DD/YYYY   v1.0.0]
;
;   NOTES:      
;               1)  See IDL documentation for more information about acceptable keywords
;                     for each relevant plotting routine.
;               2)  The appropriate IDL structure format should match what one would
;                     pass to any of the above listed plotting routines using
;                     _EXTRA=[structure].
;
;   CREATED:  03/09/2011
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  03/09/2011   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-


Last Modification =>  2009-08-12/14:21:17 UTC
;+
;*****************************************************************************************
;
;  FUNCTION :   plot_time_ticks.pro
;  PURPOSE  :   Returns a structure to be used in plotting routines which have a time
;                 dependent axis and user desires UT Time displays.
;
;  CALLED BY: 
;               plot_vector_mv_data.pro
;
;  CALLS:       
;               NA
;
;  REQUIRES:    
;               NA
;
;  INPUT:
;               T1   :  N-Element Time Array ['HH:MM:SS.ssss']
;               T2   :  N-Element Double Array (Doesn't really matter if consistent)
;
;  EXAMPLES:    
;               NA
;
;  KEYWORDS:  
;               NTS  :  Scalar indicating the number of tick marks desired on 
;                         the particular axis of interest [Default = 7]
;                         Set equal to one less than desired number, thus the default
;                         value would result in 8 tick marks
;
;   CHANGED:  1)  Updated Man Page                         [11/05/2008   v1.0.5]
;             2)  Added comments and altered syntax        [12/06/2008   v1.0.6]
;             3)  Updated Man Page                         [05/24/2009   v1.1.0]
;             4)  Updated man page
;                   and renamed from htr_plot_ticks_2.pro  [08/12/2009   v2.0.0]
;
;   CREATED:  05/10/2008
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  08/12/2009   v2.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-


Last Modification =>  2009-09-16/13:50:10 UTC
;+
;*****************************************************************************************
;
;  FUNCTION :   plot_vector_hodo_scale.pro
;  PURPOSE  :   Program determines the relative plot scales associated with an input
;                 array of data.  The scales are determined by all three components
;                 of your input vector array.  So the component with the maximum
;                 absolute magnitude will determine your plot scales to be used.
;
;  CALLED BY: 
;               plot_vector_mv_data.pro
;               my_box.pro
;
;  CALLS:
;               NA
;
;  REQUIRES:    
;               NA
;
;  INPUT:
;               V1      :  An [N,3] or [3,N] array of vectors
;
;  EXAMPLES:
;               NA
;
;  KEYWORDS:  
;               LSCALE  :  If set, program subtracts off the average of the normalized
;                            data to center it about zero when plotting
;               RANGE   :  Set to a 2-element array defining the start and end elements
;                            of the input data array, V1
;
;   CHANGED:  1)  Updated man page                               [02/12/2009   v1.0.1]
;             2)  Updated man page
;                   and no longer calls my_dimen_force.pro
;                   and renamed from my_plot_scale.pro           [08/12/2009   v2.0.0]
;             3)  Fixed typo in RETURN statement on line 73      [09/16/2009   v2.0.1]
;
;   CREATED:  06/29/2008
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  09/16/2009   v2.0.1
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-


Last Modification =>  2011-03-10/22:08:15 UTC
;+
;*****************************************************************************************
;
;  FUNCTION :   plot_vector_mv_data.pro
;  PURPOSE  :   Takes HTR MFI data and plots the data in original coordinates, minimum
;                 variance coordinates, their respective power spectrum plots (spectral
;                 density), and (if explicitly desired) the estimates of current.  Then
;                 the data is plotted as hodograms to look for polarizations in both
;                 the original coordinates and minimum variance coordinates.
;
;  CALLED BY: 
;               vector_mv_plot.pro
;
;  CALLS:  
;               my_colors2.pro       ; => Common block
;               my_time_string.pro
;               plot_time_ticks.pro
;               file_name_times.pro
;               plot_vector_hodo_scale.pro
;               fft_power_calc.pro
;               vector_bandpass.pro
;               plot_freq_ticks.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:       
;               T1     :  Unix times associated with B-field data [DBLARR]
;               B1     :  B-field (nT) data [DBLARR]
;
;  EXAMPLES:    
;               NA
;
;  KEYWORDS:  
;               DATE      :  ['MMDDYY'] Date of interest
;               FSAVE     :  If set, the device is set to 'ps' thus saving file as a 
;                              *.eps file.  If NOT set, then the device is left as 'x'
;                              making it possible to plot to the screen for checking and
;                              user manipulation.
;               ROTBF     :  [DBLARR] B-field Rotated into Min. Var. frame (nT)
;               RANGE     :  2-element array defining the start and end point elements
;                              to use for plotting the data
;               READ_B    :  If set, scales B-field by its magnitude and shifts it by
;                              the average of the scaled field => roughly averages field
;                              to zero leaving only the fluctuations which are what
;                              we are concerned with.
;               MID_RA    :  [DOUBLE] Time (s of day) associated with the center of
;                              shock ramp
;               READ_WIN  :  If set, program uses windowing for FFT calculation
;               PLOT_CNT  :  Plot number for the session
;               READ_L    :  If set, FFT power spec. is plotted w/ Freq. on a log-scale
;               UNITS     :  Set to a named variable for returning the units of the
;                              data being plotted
;               NORMALIZE :  Set to a named variable for returning plot axis label
;                              information
;               HODO_SCL  :  Set to a named variable for returning axis scales
;               SLOW_P    :  Set to watch hodogram plots plot more slowly for determining 
;                              direction of polarization, among other things
;               T_STEP    :  Set to a value which indicates the rate at which the hodograms
;                              are plotted when the keyword SLOW_P is set
;               EIGA      :  Set to a 3-element array which has the 3 eigenvalues from the
;                              MV analysis [max,mid,min]
;               SAT       :  Defines which satellite ('A', 'B', or 'W' to use)
;                              [Default = 'W']
;               FCUTOFF   :  Set to a two element array specifying the range of 
;                              frequencies to use in power spectrum plots if data has
;                              been bandpass-filtered
;               COORD     :  Defines which coordinate system to use for plot labels
;                              ['RTN' or 'GSE', Default = 'GSE']
;               FIELD     :  Set to a scalar string defining whether the input is a
;                              magnetic ('B') or electric ('E') field 
;                              [Default = 'B']
;               THICK     :  Scalar used for corresponding PLOT.PRO or OPLOT.PRO keyword
;                              [Default = !P.THICK]
;               VVERSION  :  Scalar string for version output for vector_mv_plot.pro
;
;   CHANGED:  1)  Added keywords to return plot title information [09/11/2008   v1.0.1]
;             2)  Added hodogram plotting capabilities            [09/11/2008   v1.0.2]
;             3)  Added keyword: SLOW_P                           [09/11/2008   v1.0.3]
;             4)  Added keyword: T_STEP                           [09/12/2008   v1.0.4]
;             5)  Completely re-wrote hodogram plotting part      [09/18/2008   v1.1.0]
;             6)  Added keyword: EIGA                             [09/18/2008   v1.1.1]
;             7)  Changed functionality of fft_power_calc.pro     [09/29/2008   v1.1.2]
;             8)  Added keyword: SAT                              [09/30/2008   v1.1.3]
;             9)  Changed B-scale logic (0 seemed to = 1 for some reason)
;                                                                 [10/16/2008   v1.1.4]
;            10)  Fixed syntax and typo                           [11/04/2008   v1.1.5]
;            11)  Changed functionality of fft_power_calc.pro     [11/20/2008   v1.2.0]
;            12)  Added keyword: FCUTOFF                          [11/20/2008   v1.2.1]
;            13)  Fixed tick label issue on power spec.           [11/21/2008   v1.2.2]
;            14)  Fixed eigenvalue ratio output issue             [11/21/2008   v1.2.3]
;            15)  Fixed tick label issue for low freq.            [11/24/2008   v1.2.4]
;            16)  Changed charsizes in plots                      [12/11/2008   v1.2.5]
;            17)  Changed tick labels for very low freq.          [12/16/2008   v1.2.6]
;            18)  Changed tick labels                             [12/18/2008   v1.2.7]
;            18)  Changed tick label classification               [12/19/2008   v1.2.8]
;            19)  Added keyword: COORD                            [12/30/2008   v1.2.9]
;            20)  Updated man page                                [02/12/2009   v1.2.10]
;            21)  Changed input to Unix times (among other syntax issues)
;                                                                 [05/24/2009   v1.3.0]
;            22)  Fixed syntax error                              [05/25/2009   v1.3.1]
;            23)  Changed some syntax [no functional changes]     [05/25/2009   v1.3.2]
;            24)  Removed the current plotting stuff              [06/03/2009   v2.0.0]
;            25)  Changed power spectrum Y-Range calc             [06/08/2009   v2.0.1]
;            26)  Changed power spectrum X-Range calc             [06/08/2009   v2.0.2]
;            27)  Added keyword: FIELD                            [07/16/2009   v2.0.3]
;            28)  Changed power spectrum Y-Range calc             [07/16/2009   v2.0.4]
;            29)  Changed program my_htr_bandpass.pro to vector_bandpass.pro
;                   and my_plot_mv_htr_tick.pro to plot_freq_ticks.pro
;                   and htr_plot_ticks_2.pro to plot_time_ticks.pro
;                   and my_plot_scale.pro to plot_vector_hodo_scale.pro
;                   and removed keyword:  CURR
;                   and renamed from my_plot_mv_htr_data.pro      [08/12/2009   v3.0.0]
;            30)  Changed usage of plot_freq_ticks.pro            [09/22/2010   v3.1.0]
;            31)  Changed file name on output                     [09/23/2010   v3.2.0]
;            32)  Fixed issue with color table                    [09/24/2010   v3.2.1]
;            33)  Added option that tests whether the ~/output directory exists in
;                   the user's working IDL directory              [11/16/2010   v3.3.0]
;            34)  Added keyword:  THICK and fixed up some other things
;                   no longer depends upon my_str_date.pro
;                                                                 [03/04/2011   v3.4.0]
;            35)  Added keyword:  VVERSION and changed output slightly in addition
;                   to now calling file_name_times.pro            [03/10/2011   v3.5.0]
;
;   NOTES:      
;               1)  User should not call this routine
;
;   CREATED:  08/26/2008
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  03/10/2011   v3.5.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-


Last Modification =>  2010-05-23/22:58:10 UTC
;+
;*****************************************************************************************
;
;  FUNCTION :   polar_histogram_bins.pro
;  PURPOSE  :   Creates and returns a structure which defines the XY-Coordinates of
;                 a wedge in polar space (see example below) for points A through D.
;                 The structure also contains the counts in each bin defined by the 
;                 number of radii and angles that fall in that area.
;
;
;            C
;           /          D
;          /        .
;         B       .
;        /      A
;       /    .
;      /  .
;
;  CALLED BY:   
;               
;
;  CALLS:
;               NA
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               RAD     :  An N-Element array of radii to be used for the histogram
;               THETA   :  " " of angles (deg)
;
;  EXAMPLES:    
;               bin_vals = polar_histogram_bins(rad,theta,NBIN_R=20,NBIN_T=20)
;
;  KEYWORDS:    
;               XRANGE   :  A scalar used to define the max x-range value for X-Axis
;               YRANGE   :  A scalar used to define the max y-range value for Y-Axis
;               NBIN_R   :  A scalar used to define the number of bins in the radial
;                             direction [Default = 8]
;               NBIN_T   :  A scalar used to define the number of bins in the azimuthal
;                             direction [Default = 8]
;               DATA     :  N-Element array of data at the polar coordinates of
;                             RAD and THETA
;               THETA_R  :  If set, program uses input thetas to determine the range
;                             of angles to consider
;                             [Default = 0 to 360 degrees]
;               POLAR    :  If set, XRANGE is assumed to be the range for radial 
;                             distance and YRANGE is assumed to be the range for
;                             the polar angles
;
;   CHANGED:  1)  Added keywords:  DATA, THETA_R, and POLAR         [05/23/2010   v1.1.0]
;
;   NOTES:      
;               
;
;   CREATED:  05/03/2010
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  05/23/2010   v1.1.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-


Last Modification =>  2010-05-23/22:54:55 UTC
;+
;*****************************************************************************************
;
;  FUNCTION :   polar_histogram_plot.pro
;  PURPOSE  :   Creates a polar histogram plot from radial and azimuthal inputs.
;
;  CALLED BY:   
;               NA
;
;  CALLS:
;               polar_histogram_bins.pro
;               bytescale.pro
;               draw_color_scale.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               RAD     :  An N-Element array of radii to be used for the histogram
;               THETA   :  " " of angles (deg)
;
;  EXAMPLES:    
;               
;
;  KEYWORDS:    
;               XTTL     :  Set to a string defining the desired X-Axis Title
;               YTTL     :  Set to a string defining the desired Y-Axis Title
;               ZTTL     :  Set to a string defining the desired Z-Axis Title
;               TTLE     :  Set to a string defining the desired plot title
;               XRANGE   :  A 2-Element array used to define the x-range
;               YRANGE   :  A 2-Element array used to define the y-range
;               ZRANGE   :  A 2-Element array used to define the z-range
;               NBIN_R   :  A scalar used to define the number of bins in the radial
;                             direction [Default = 8]
;               NBIN_T   :  A scalar used to define the number of bins in the azimuthal
;                             direction [Default = 8]
;               NODATC   :  A scalar defining the color to use where no data is present
;                             [Default = 255B (white)]
;               BDDATC   :  A scalar defining the color to use where bad data is present
;                             [Default = 0B (black)]
;               LABELS   :  If set, program outputs histogram heights onto polar plot
;                             [Use if quantitative analysis is necessary...]
;               DATA     :  N-Element array of data at the polar coordinates of
;                             RAD and THETA
;               THETA_R  :  If set, program uses input thetas to determine the range
;                             of angles to consider
;                             [Default = 0 to 360 degrees]
;               POLAR    :  If set, XRANGE is assumed to be the range for radial 
;                             distance and YRANGE is assumed to be the range for
;                             the polar angles
;
;   CHANGED:  1)  Added keyword:  LABELS                            [05/18/2010   v1.1.0]
;             2)  Added keywords:  DATA, THETA_R, and POLAR         [05/23/2010   v1.2.0]
;
;   NOTES:      
;               
;
;   CREATED:  05/03/2010
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  05/23/2010   v1.2.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-


Last Modification =>  2009-08-10/22:01:38 UTC
;+
;*****************************************************************************************
;
;  FUNCTION :   power_of_2.pro
;  PURPOSE  :   Pads a [M]-Element input array with zeros to make it a [2^n]-Element
;                 array for use in FFT calculations.  Thus if one inputs:
;                 [2^a] < M < [2^b], the output will be a 2^(b+1) unless b > or = 18.
;                 In this case, the output will be just a [2^b]-Element array, unless
;                 otherwise specified.
;
;  CALLED BY:   NA
;
;  CALLS:       NA
;
;  REQUIRES:    NA
;
;  INPUT:
;               SIGNAL   :  An N-Element array of data [Float,Double,Complex, or 
;                             DComplex]
;
;  EXAMPLES:    NA
;
;  KEYWORDS:  
;               FORCE_N  :  Set to a scalar power of 2 to force program to return 
;                             an array with this desired number of elements 
;                             [e.g.  FORCE_N = 2L^12]
;
;   CHANGED:  1)  Fixed syntax error                         [12/03/2008   v1.0.1]
;             2)  Fixed an indexing issue                    [02/25/2008   v1.0.2]
;             3)  Renamed and cleaned up                     [08/10/2009   v2.0.0]
;
;   CREATED:  11/20/2008
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  08/10/2009   v2.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-


Last Modification =>  2011-03-12/00:21:10 UTC
;+
;*****************************************************************************************
;
;  FUNCTION :   read_gen_ascii.pro
;  PURPOSE  :   Reads in any generic ASCII file and returns every line as an array
;                 of strings.
;
;  CALLED BY:   
;               NA
;
;  CALLS:
;               NA
;
;  REQUIRES:    
;               NA
;
;  INPUT:
;               FILE         :  Scalar string for full path with file name
;
;  EXAMPLES:    
;               
;
;  KEYWORDS:    
;               REMOVE_NULL  :  If set, program removes null strings
;
;   CHANGED:  1)  NA [MM/DD/YYYY   v1.0.0]
;
;   NOTES:      
;               1)  A return value of '' means there was an error
;
;   CREATED:  03/11/2011
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  03/11/2011   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-


Last Modification =>  2009-10-05/19:56:24 UTC
;+
;*****************************************************************************************
;
;  FUNCTION :  read_padspec_ascii.pro
;  PURPOSE  :  Reads in ASCII files produced by my_padspec_writer.pro and returns a data
;               structure to my_padspec_rw.pro where the data is manipulated.  [This 
;               program should NOT be called by the user directly.]
;
;  CALLED BY:   
;               read_padspec_wrapper.pro
;
;  CALLS:
;               my_str_date.pro
;               dat_3dp_str_names.pro
;               wind_3dp_units.pro
;               dat_3dp_energy_bins.pro
;               my_3dp_plot_labels.pro
;               str_element.pro
;
;  REQUIRES:    
;               ASCII files created by write_padspec_ascii.pro
;
;  INPUT:
;               NAME      :  [string] Specify the type of structure you wish to 
;                              get the data for [i.e. 'el','eh','elb',etc.]
;
;  EXAMPLES:    NA
;
;  KEYWORDS:  
;               EBINS     :  [array,scalar] specifying which energy bins to create 
;                              particle spectra plots for
;               TRANGE    :  [Double] 2 element array specifying the range over 
;                              which to get data structures for
;               DATE      :  Scalar string (e.g. 'MMDDYY') specifying the date of interest
;               FILENAME  :  Scalar string defining the full file name and path
;               F_FORMAT  :  Scalar string defining the read format statement
;               UNITS     :  Wind/3DP data units for particle data include:
;                              'df','counts','flux','eflux',etc.
;                               [Default = 'flux']
;
;   CHANGED:  1)  Changed structure formats                       [08/18/2008   v1.0.3]
;             2)  Changed 'man' page                              [09/15/2008   v1.0.4]
;             3)  Changed syntax                                  [11/07/2008   v1.0.5]
;             4)  Fixed string conversion issue with NaN's in files
;                                                                 [11/10/2008   v1.0.6]
;             5)  Changed indexing issue                          [11/10/2008   v1.0.7]
;             6)  Fixed typo                                      [11/14/2008   v1.0.8]
;             7)  Fixed indexing issue                            [11/26/2008   v1.0.9]
;             8)  Changed array definition to account for non-default sized
;                  ascii files where the PAs or Energies are different
;                                                                 [02/25/2009   v1.0.10]
;             9)  Fixed syntax issue                              [05/04/2009   v1.1.0]
;            10)  Changed program my_str_names.pro to dat_3dp_str_names.pro
;                   and my_3dp_energy_bins.pro to dat_3dp_energy_bins.pro
;                   and my_energy_params.pro to energy_params_3dp.pro
;                   and my_get_padspec_5.pro to get_padspecs.pro
;                   and added keywords:  FILENAME and F_FORMAT
;                   and added program:  wind_3dp_units.pro
;                   and renamed from my_padspec_reader.pro        [09/19/2009   v2.0.0]
;            11)  Changed return structure format                 [09/21/2009   v2.0.1]
;            12)  Added keyword:  UNITS                           [09/21/2009   v2.1.0]
;            13)  Updated 'man' page                              [10/05/2008   v2.1.1]
;
;   NOTES:      
;               1)  v1.0.9 only affected results where ONLY 1 file was called
;               2)  This program should NOT be called by user!
;               3)  The program kind of "requires" the F_FORMAT keyword be set
;               4)  This program only reads in one file at a time now
;               5)  The new return structure format includes the units of the data 
;                     being returned to user
;
;   CREATED:  08/12/2008
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  10/05/2008   v2.1.1
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-


Last Modification =>  2009-10-05/19:54:57 UTC
;+
;*****************************************************************************************
;
;  FUNCTION :   read_padspec_wrapper.pro
;  PURPOSE  :   This is a wrapping program for read_padspec_ascii.pro.
;
;  CALLED BY:   
;               padspec_ascii_to_tplot.pro
;
;  CALLS:
;               my_str_date.pro
;               dat_3dp_str_names.pro
;               wind_3dp_units.pro
;               read_padspec_ascii.pro
;               dat_3dp_energy_bins.pro
;               my_3dp_plot_labels.pro
;               str_element.pro
;
;  REQUIRES:    
;               ASCII files created by write_padspec_ascii.pro
;
;  INPUT:
;               NAME    :  [string] Specify the type of structure you wish to 
;                            get the data for [i.e. 'el','eh','elb',etc.]
;
;  EXAMPLES:    
;               date  = '040396'
;               dat   = read_padspec_wrapper('sf',DATE=date)
;
;  KEYWORDS:    
;               EBINS   :  [array,scalar] specifying which energy bins to create 
;                            particle spectra plots for
;               TRANGE  :  [Double] 2 element array specifying the range over 
;                            which to get data structures for
;               DATE    :  Scalar string (e.g. 'MMDDYY') specifying the date of interest
;               UNITS   :  Wind/3DP data units for particle data include:
;                            'df','counts','flux','eflux',etc.
;                             [Default = 'flux']
;
;   CHANGED:  1)  Fixed a typo                                    [09/20/2009   v1.0.1]
;             2)  Changed return structure format                 [09/21/2009   v1.0.2]
;             3)  Added keyword:  UNITS                           [09/21/2009   v1.1.0]
;             4)  Updated 'man' page                              [10/05/2008   v1.1.1]
;
;   NOTES:      
;               1)  This program calls read_padspec_ascii.pro ONCE for each file
;
;   CREATED:  09/19/2009
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  10/05/2008   v1.1.1
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-


Last Modification =>  2010-11-16/17:25:59 UTC
;+
;*****************************************************************************************
;
;  FUNCTION :   read_shocks_jck_database.pro
;  PURPOSE  :   Reads in file created by write_shocks_jck_database.pro and returns a
;                 structure containing all the relevant information determined by
;                 Justin C. Kasper at:  http://www.cfa.harvard.edu/shocks/wi_data/
;
;  NOTES:
;               Methods Used by J.C. Kasper:
;                 [See Viñas and Scudder, JGR Vol. 91, pg. 39-58, (1986)]
;                 [and Szabo, JGR Vol. 99, pg. 14,737-14,746, (1994)]
;                 [and Russell et. al., JGR Vol. 88, pg. 9941-9947, (1983)]
;               MC   :  Magnetic Coplanarity    (Viñas and Scudder, [1986])
;               VC   :  Velocity Coplanarity    (Viñas and Scudder, [1986])
;               MX1  :  Mixed Mode Normal 1     (Russell et. al., [1983])
;               MX2  :  Mixed Mode Normal 2     (Russell et. al., [1983])
;               MX3  :  Mixed Mode Normal 3     (Russell et. al., [1983])
;               RH08 :  Rankine-Hugoniot 8 Eqs  (Viñas and Scudder, [1986])
;               RH09 :  Rankine-Hugoniot 8 Eqs  (Viñas and Scudder, [1986])
;               RH10 :  Rankine-Hugoniot 10 Eqs (Viñas and Scudder, [1986])
;               
;               Shock Speed :  Shock velocity dotted into the normal vector
;                                 [ = |Vsh \dot norm| ]
;               Flow Speed  :  |Vsw \dot norm| - |Vsh \dot norm| = dV (on JCK's site)
;               Compression Ratio   :  Downstream density over Upstream density
;               Shock Normal Angle  :  Theta_Bn = ArcCos( (B \dot norm)/|B|)
;
;  CALLED BY:   NA
;
;  CALLS:       NA
;
;  REQUIRES:  
;               ASCII file created by write_shocks_jck_database.pro
;
;  INPUT:       NA
;
;  EXAMPLES:
;               test = read_shocks_jck_database()
;
;  KEYWORDS:    NA
;
;   CHANGED:  1)  Fixed indexing error in Mach numbers              [04/08/2009   v1.0.1]
;             2)  Changed HTML file locations, thus the search syntax changed
;                   and renamed from my_all_shocks_read.pro to 
;                   read_shocks_jck_database.pro
;                                                                   [09/16/2009   v2.0.0]
;             3)  Changed read statement format and output          [11/16/2010   v2.1.0]
;
;   NOTES:      
;               1)  Initialize the IDL directories with start_umn_3dp.pro prior
;                     to use.
;
;   CREATED:  04/07/2009
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  11/16/2010   v2.1.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-


Last Modification =>  2011-03-05/00:21:46 UTC
;+
;*****************************************************************************************
;
;  FUNCTION :   fix_bfield_data.pro
;  PURPOSE  :   Removes data spikes and zeroed values from the Wind MFI data.
;
;  CALLED BY:   
;               read_wind_mfi.pro
;
;  CALLS:
;               interp.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               UNIX    :  N-Element array of Unix times
;               FIELD   :  [N,3]-Element array of B-field data
;
;  EXAMPLES:    
;               NA
;
;  KEYWORDS:    
;               THRESH  :  Scalar value defining the maximum absolute value for the
;                            any B-field component [Default = 3d4]
;
;   CHANGED:  1)  NA [MM/DD/YYYY   v1.0.0]
;
;   NOTES:      
;               1)  User should not call this routine
;
;   CREATED:  02/25/2011
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  02/25/2011   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-
;+
;*****************************************************************************************
;
;  FUNCTION :  read_wind_mfi.pro
;  PURPOSE  :  Reads in 3-second Magnetic Field Instrument (MFI) data from 
;               the Wind spacecraft and returns a structure composed of the
;               the GSE magnetic field, its magnitude, and the times 
;               associated with the data in seconds of day (default tag is in
;               unix time).
;
;  CALLS:  
;               my_str_date.pro
;               time_double.pro
;               read_cdf.pro
;               epoch2unix.pro
;               my_time_string.pro
;               interp.pro
;               fix_bfield_data.pro
;
;  REQUIRES:  
;               wi_h0_mfi_files_2
;               'wi_h0_mfi_YYYYMMDD.cdf'
;
;  INPUT:       
;               NA
;
;  KEYWORDS:  
;               DATE    :  [string] 'MMDDYY' [MM=month, DD=day, YY=year]
; **Obselete**  ALLF    :  If set, the entire day or time range desired is 
;                            retrieved instead of just a selected hour around
;                            the event.
;               TRANGE  :  [Double] 2 element array specifying the range over 
;                            which to get data structures [Unix time]
;
;   CHANGED:  1)  Added keyword:  ALLF                        [09/03/2008   v1.1.2]
;             2)  Fixed an indexing issue and typo            [11/18/2008   v1.1.3]
;                  *[Only affected output for DATE='021100']*
;             3)  Fixed an interpolation abscissa issue       [11/18/2008   v1.1.4]
;                  *[Only affected output for DATE='021100']*
;             4)  Added keyword:  TRANGE                      [04/06/2009   v1.2.0]
;             5)  Fixed syntax issue with ALLF keyword        [05/04/2009   v1.2.1]
;             6)  Fixed syntax issue of array vs scalar values of dates
;                                                             [05/06/2009   v1.2.2]
;             7)  Changed some syntax but not functionality   [07/27/2009   v1.2.3]
;             8)  No longer prints out annoying message from CDF_VARGET.PRO
;                  % CDF_VARGET: Function completed but: VIRTUAL_RECORD_DATA: ....
;                                                             [08/03/2009   v1.2.4]
;             9)  Eliminated dependence on ab_aeterno_7.pro   [09/01/2009   v1.2.5]
;            10)  Changed the manner in which data spikes are dealt with
;                                                             [09/02/2009   v1.2.6]
;            11)  Returned !QUIET to its default setting after calling read_cdf.pro
;                                                             [09/03/2009   v1.2.7]
;            12)  Changed location of CDF files and file searching algorithm
;                   and changed program my_shock_times.pro to read_shocks_jck_database.pro
;                                                             [09/16/2009   v1.3.0]
;            13)  Changed smoothing of NaNs to component by component
;                                                             [09/26/2009   v1.4.0]
;            14)  Fixed syntax issue of program redefining the DATE keyword
;                                                             [10/22/2009   v1.4.1]
;            15)  Fixed some error handling and freeing of pointers
;                                                             [10/22/2009   v1.4.2]
;            16)  Fixed a typo when both DATE and TRANGE keywords were set, specifically
;                   when the date for the start time is before the date defined by
;                   the DATE keyword                          [11/11/2009   v1.5.0]
;            17)  Changed output to include GSE and GSM satellite positions
;                                                             [01/07/2010   v1.6.0]
;            18)  Changed output to include 3s GSM B-field data
;                                                             [04/26/2010   v1.7.0]
;            19)  Fixed a mistake for the time stamp associated with the spacecraft
;                   positions and added routine fix_bfield_data.pro
;                                                             [02/25/2011   v2.0.0]
;            20)  Removed run-time statement produced by my_time_string.pro
;                                                             [03/04/2011   v2.0.1]
;
;   NOTES:      
;               1)  Initialize the IDL directories with start_umn_3dp.pro prior
;                     to use.
;
;   CREATED:  02/10/2008
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  03/04/2011   v2.0.1
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-


Last Modification =>  2010-02-09/15:09:24 UTC
;+
;*****************************************************************************************
;
;  FUNCTION :   read_wind_orbit.pro
;  PURPOSE  :   This program reads in an ASCII file created by SPDF Data Orbit Services
;                 and returns a data structure that contains the GSE Cartesian and
;                 sperical coordinates, L-Shell, and invariant latitude.
;
;  CALLED BY:   
;               NA
;
;  CALLS:
;               my_str_date.pro
;               my_time_string.pro
;
;  REQUIRES:    
;               ASCII Files created by SPDF Data Orbit Services at:
;                   http://spdf.gsfc.nasa.gov/data_orbits.html
;               Format of output must be:
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;GROUP 1    Satellite   Resolution   Factor
;            wind          720         1
;
;           Start Time           Stop Time 
;           2001 327  0.00000    2001 329  0.00000
;
;
; Coord/            Min/Max      Range Filter          Filter
;Component   Output Markers    Minimum     Maximum    Mins/Maxes
;GSE X        YES      -         -           -             -   
;GSE Y        YES      -         -           -             -   
;GSE Z        YES      -         -           -             -   
;GSE Lat      YES      -         -           -             -   
;GSE Lon      YES      -         -           -             -   
;
;
;Addtnl             Min/Max      Range Filter          Filter
;Options     Output Markers    Minimum     Maximum    Mins/Maxes
;L_Value      YES      -         -           -             -   
;InvarLat     YES      -         -           -             -   
;
;Output - File: 
;         lines per page: 0
; 
;Formats and units:
;    Day/Time format: YY/MM/DD HH:MM:SS
;    Degrees/Hemisphere format: Decimal degrees with 2 place(s).
;        Longitude 0 to 360, latitude -90 to 90.
;    Distance format: Kilometers with 3 place(s).
;
;wind
;       Time                           GSE (km)                         GSE                DipInvLat
;yy/mm/dd hh:mm:ss        X               Y               Z          Lat   Long   DipL-Val   (Deg)  
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;
;
;  INPUT:
;               NA
;
;  EXAMPLES:    
;               read_wind_orbit,DATE='040900',DATA=data
;
;  KEYWORDS:    
;               DATE     :  [string] 'MMDDYY' [MM=month, DD=day, YY=year]
;               DATA     :  Set to a named variable to be returned as a structure
;                             containing all the useful data
;
;   CHANGED:  1)  Changed read statement and added program my_format_structure.pro
;                   to allow for different input ASCII files     [07/21/2009   v1.1.0]
;             2)  Changed location of ASCII files and file searching algorithm
;                                                                [09/16/2009   v1.2.0]
;             3)  Changed program my_format_structure.pro to format_structure.pro
;                                                                [11/12/2009   v1.3.0]
;             4)  Fixed a typo                                   [02/09/2010   v1.4.0]
;
;   NOTES:      
;               1)  Initialize the IDL directories with start_umn_3dp.pro prior
;                     to use.
;
;   CREATED:  07/20/2009
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  02/09/2010   v1.4.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-


Last Modification =>  2009-09-16/21:46:56 UTC
;+
;*****************************************************************************************
;
;  FUNCTION :   read_write_jck_database.pro
;  PURPOSE  :   Copy and paste the source code to the webpages of the data base created
;                 by Justin C. Kasper at http://www.cfa.harvard.edu/shocks/wi_data/ and
;                 keep them as ASCII files labeled as:
;                     source_MM-DD-YYYY_SSSSS.5_FF.html
;                     {where:  SSSSS = seconds of day, MM = month, DD = day, YYYY = year}
;                 The program iteratively reads in the ASCII files and retrieves the 
;                 relevant information from them (since each has a consistent format).
;                 The returned data is a structure containing all the relevant 
;                 data quantities from the method used by J.C. Kasper.
;
;  NOTES:
;               Methods Used by J.C. Kasper:  
;                 [See Viñas and Scudder, JGR Vol. 91, pg. 39-58, (1986)]
;                 [and Szabo, JGR Vol. 99, pg. 14,737-14,746, (1994)]
;                 [and Russell et. al., JGR Vol. 88, pg. 9941-9947, (1983)]
;               MC   :  Magnetic Coplanarity    (Viñas and Scudder, [1986])
;               VC   :  Velocity Coplanarity    (Viñas and Scudder, [1986])
;               MX1  :  Mixed Mode Normal 1     (Russell et. al., [1983])
;               MX2  :  Mixed Mode Normal 2     (Russell et. al., [1983])
;               MX3  :  Mixed Mode Normal 3     (Russell et. al., [1983])
;               RH08 :  Rankine-Hugoniot 8 Eqs  (Viñas and Scudder, [1986])
;               RH09 :  Rankine-Hugoniot 8 Eqs  (Viñas and Scudder, [1986])
;               RH10 :  Rankine-Hugoniot 10 Eqs (Viñas and Scudder, [1986])
;               
;               Shock Speed :  Shock velocity dotted into the normal vector
;                                 [ = |Vsh \dot norm| ]
;               Flow Speed  :  |Vsw \dot norm| - |Vsh \dot norm| = dV (on JCK's site)
;               Compression Ratio   :  Downstream density over Upstream density
;               Shock Normal Angle  :  Theta_Bn = ArcCos( (B \dot norm)/|B|)
;
;  CALLED BY:   
;               write_shocks_jck_database.pro
;
;  CALLS:       NA
;
;  REQUIRES:  
;               ASCII files created by user in a directory which the user defines and
;                 then must alter the file path defined by the variable mdir in this
;                 code.
;
;  INPUT:       NA
;
;  EXAMPLES:    
;               read_write_jck_database,ALL_STR=all_str
;
;  KEYWORDS:
;               ALL_STR  :  Set to a named variable to return the data from the ASCII
;                             files from J.C. Kasper's website.
;
;   CHANGED:  1)  Changed some syntax regarding none RH?? methods [04/02/2009   v1.0.1]
;             2)  Changed line 266 of source_03-04-1998_39766.5_FF.html because
;                   the RH solutions do not converge, so it now uses MX2 instead
;                                                                 [04/02/2009   v1.0.2]
;             3)  Updated notes section with extra stuff          [04/07/2009   v1.0.3]
;             4)  Changed HTML file locations, thus the search syntax changed
;                   and renamed from my_jck_database_read_write.pro to 
;                   read_write_jck_database.pro
;                                                                 [09/16/2009   v2.0.0]
;
;   NOTES:      
;               1)  Initialize the IDL directories with start_umn_3dp.pro prior
;                     to use.
;
;   CREATED:  04/01/2009
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  09/16/2009   v2.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-


Last Modification =>  2011-04-22/13:23:07 UTC
;+
;*****************************************************************************************
;
;  FUNCTION :   readme_file_info.pro
;  PURPOSE  :   Returns most recent modification time for associated files.
;
;  CALLED BY:   
;               readme_update_ascii.pro
;
;  CALLS:
;               NA
;
;  REQUIRES:    
;               NA
;
;  INPUT:
;               FILE  :  String array for full path to files with file names
;
;  EXAMPLES:    
;               NA
;
;  KEYWORDS:    
;               NA
;
;   CHANGED:  1)  Fixed a typo in determination of YEAR          [03/14/2011   v1.0.1]
;             2)  Now this is in its own file [used to be with readme_update_ascii.pro]
;                                                                [04/22/2011   v1.1.0]
;
;   NOTES:      
;               
;
;   CREATED:  03/11/2011
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  04/22/2011   v1.1.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-


Last Modification =>  2011-04-22/13:21:57 UTC
;+
;*****************************************************************************************
;
;  FUNCTION :   readme_update_ascii.pro
;  PURPOSE  :   This routine creates a list of manual pages for the routines in the
;                 user specified directory.
;
;  CALLED BY:   
;               NA
;
;  CALLS:
;               directory_path_check.pro
;               readme_file_info.pro
;               read_gen_ascii.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               NA
;
;  EXAMPLES:    
;               NA
;
;  KEYWORDS:    
;               BASE_DIR  :  Scalar string defining the full path to the directory where
;                              you wish to start searching for *.pro files
;               SUB_DIR   :  Scalar string defining the the directory where
;                              you wish to find the relevant *.pro files and create
;                              a README list of manual pages
;                           [format matches that of SUBDIRECTORY keyword in FILEPATH.PRO]
;               FINFO     :  If set, routine prints time of last modification with
;                              manual page print out
;
;   CHANGED:  1)  Cleaned up algorithm                          [03/14/2011   v1.1.0]
;             2)  Now program calls directory_path_check.pro and
;                   readme_file_info.pro is no longer part of this file
;                                                               [04/22/2011   v1.2.0]
;
;   NOTES:      
;               1)  This program will only search for files ending with *.pro,
;                     thus you should not try to create a readme list of crib sheets
;               2)  This program is kind of kludgy
;               3)  The FINFO reports the UTC time of last modification, but the man
;                     page may suggest a slightly earlier date.  The issue is simply
;                     that the dates in the man pages are local time and the program
;                     keyword options reports UTC.
;
;   CREATED:  03/11/2011
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  04/22/2011   v1.2.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-


Last Modification =>  2010-02-17/22:48:35 UTC
;+
;*****************************************************************************************
;
;  FUNCTION :   self_write_3dp_dfs.pro
;  PURPOSE  :   
;
;  CALLED BY:   
;               
;
;  CALLS:
;               
;
;  REQUIRES:    
;               
;
;  INPUT:
;               
;
;  EXAMPLES:    
;               
;
;  KEYWORDS:    
;               NUM_PA  :  Number of pitch-angles to sum over (Default = 8L)
;               BURST   :  If set redefines the name of the string associated with
;                            the particle data structures to 'aelb'
;                            [Default = 'ael']
;               INTERP  :  If set, program will write a string to tell 
;                            convert_vframe.pro to interpolate the data that was
;                            removed by converting into the solar wind frame and
;                            taking into account the spacecraft potential
;
;   CHANGED:  1)  NA [MM/DD/YYYY   v1.0.0]
;
;   NOTES:      
;               
;
;   CREATED:  02/17/2010
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  02/17/2010   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-


Last Modification =>  2011-04-21/00:28:47 UTC
;+
;*****************************************************************************************
;
;  FUNCTION :   sign.pro
;  PURPOSE  :   Returns the unit sign of an input array of data
;
;  CALLED BY:   
;               NA
;
;  CALLS:
;               NA
;
;  REQUIRES:    
;               NA
;
;  INPUT:
;               XX     :  N-Element array of x-data to be put into bins
;
;  EXAMPLES:    
;               ;-------------------------------------------------------------------------
;               ; => Get the sign of a real valued input
;               ;-------------------------------------------------------------------------
;               x  = DINDGEN(5)*2d0*!DPI/4 - !DPI ; => -Pi < x < +Pi
;               ss = sign(x)
;               PRINT,';',ss
;               ;     -1.00000     -1.00000      0.00000      1.00000      1.00000
;               ;-------------------------------------------------------------------------
;               ; => Get the sign of a complex valued input
;               ;-------------------------------------------------------------------------
;               x  = DINDGEN(5)*2d0*!DPI/4 - !DPI ; => -Pi < x < +Pi
;               y  = SIN(x)
;               xx = DCOMPLEX(x,y)
;               ss = sign(xx,/CMPLX)
;               PRINT,';  ',ss[0]
;               ;  (     -1.00000,     -1.00000)
;
;  KEYWORDS:    
;               CMPLX  :  If set, routine assumes input XX is a complex array of data
;                           and so will return a complex array of signs
;
;   CHANGED:  1)  NA [MM/DD/YYYY   v1.0.0]
;
;   NOTES:      
;               
;
;   CREATED:  04/20/2011
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  04/20/2011   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-


Last Modification =>  2011-04-20/14:32:31 UTC
;+
;*****************************************************************************************
;
;  FUNCTION :   smear_data_plot.pro
;  PURPOSE  :   This program produces a series of data points surrounding the input
;                 data to produce the effect of "discrete smearing" of the data points.
;
;  CALLED BY:   
;               NA
;
;  CALLS:
;               NA
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;               2)  User must have plotted some data with !D.NAME = 'X' prior to running
;                     this routine
;
;  INPUT:
;               XX      :  N-Element array of x-data
;               YY      :  N-Element array of y-data
;
;  EXAMPLES:    
;               nn   = 100L
;               xx   = DINDGEN(nn)*2d0*!DPI/(nn - 1L)
;               yy   = COS(xx)
;               PLOT,xx,yy,/NODATA,/XSTYLE,/YSTYLE,XTITLE='x (rad)',YTITLE='COS(x)'
;                 OPLOT,xx,yy,PSYM=3
;               test = smear_data_plot(xx,yy,NS=2L,/CIRCLE,/OPLT)
;
;  KEYWORDS:    
;               NS      :  Scalar defining the number of points to add in the surrounding
;                            area to act as a smear.
;                            [Default = 1]
;               SQUARE  :  If set, program adds NS-rows of points in a square lattice
;                            around initial point
;                            [Default]
;               CIRCLE  :  If set, program adds NS-concentric circles of points
;                            around initial point
;               OPLT    :  If set, program will overplot the extra points in the current
;                            plot window
;
;   CHANGED:  1)  Finished writing and cleaning up the program [04/20/2011   v1.0.0]
;
;   NOTES:      
;               1)  Below is an example of [NS=1] square-smearing which just adds
;                     points in square around the initial point at [i,j]
;
;                  [(i-1),(j+1)]  [i,(j+1)]  [(i+1),(j+1)]
;
;                    [(i-1),j]      [i,j]      [(i+1),j]
;
;                  [(i-1),(j-1)]  [i,(j-1)]  [(i+1),(j-1)]
;
;
;   CREATED:  04/19/2011
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  04/20/2011   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-


Last Modification =>  2009-10-07/23:01:50 UTC
;+
;*****************************************************************************************
;
;  FUNCTION :   spec_2dim_shift.pro
;  PURPOSE  :   Shifts stacked spectra plots and normalizes data (if desired)
;                 {for spec structures w/ pitch-angle data separated already}
;
;  CALLED BY: 
;               spec_vec_data_shift.pro
;
;  CALLS:
;               get_data.pro
;               dat_3dp_energy_bins.pro
;               ytitle_tplot.pro
;               ylim.pro
;               options.pro
;               store_data.pro
;
;  REQUIRES:    NA
;
;  INPUT:
;               DAT        :  3D data structure of the form =>
;                               {YTITLE:[string],X:[times(N)],Y:[data(N,M)],$
;                                     V:[energy(N,M)]}
;                               where:  N = # of time steps
;                                       M = # of energy bins
;               NAME       :  Scalar string for corresponding TPLOT variable name with
;                               associated spectra (or vector) data separated by 
;                               pitch-angle or component as TPLOT variables 
;                               [e.g. 'nsf_pads-2-0:1_N']
;
;  EXAMPLES:    NA
;
;  KEYWORDS:  
;               NEW_NAME   :  New string name for returned TPLOT variable
;               DATN       :  If set, data is returned normalized by 
;                               the AVG. for each energy bin
;                               [i.e. still a stacked spectra plot but normalized]
;               DATS       :  If set, data is shifted to avoid overlaps
;               WSHIFT     :  Performs a weighted shift of only the specified 
;                               energy bins {e.g. 1st 3 -> lowest energies [0,2]}
;               RANGE_AVG  :  Two element double array specifying the time range
;                               (Unix time) to use for constructing an average to
;                               normalize the data by when using the keyword DATN
;
;   CHANGED:  1)  NA                                         [07/10/2008   v1.0.1]
;             2)  Updated man page                           [03/19/2009   v1.0.2]
;             3)  Changed program my_3dp_energy_bins.pro to dat_3dp_energy_bins.pro
;                   and renamed from my_2dim_spec_shift.pro  [08/10/2009   v2.0.0]
;             4)  Added keyword:  RANGE_AVG                  [09/19/2009   v2.1.0]
;             5)  Changed program my_ytitle_tplot.pro to ytitle_tplot.pro
;                   and now calls get_data.pro
;                                                            [10/07/2008   v2.2.0]
;
;   CREATED:  06/13/2008
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  10/07/2008   v2.2.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-


Last Modification =>  2009-10-07/22:58:12 UTC
;+
;*****************************************************************************************
;
;  FUNCTION :   spec_3dim_shift.pro
;  PURPOSE  :   Shifts stacked spectra plots and normalizes data (if desired)
;                 {for spec structures w/ pitch-angle data not separated yet}
;
;  CALLED BY: 
;               spec_vec_data_shift.pro
;
;  CALLS:
;               get_data.pro
;               dat_3dp_energy_bins.pro
;               ytitle_tplot.pro
;               ylim.pro
;               options.pro
;               store_data.pro
;
;  REQUIRES:    
;               NA
;
;  INPUT:
;               DAT        :  3D data structure of the form =>
;                               {YTITLE:[string],X:[times(N)],Y:[data(N,M,L)],$
;                                    V1:[energy(N,M)],V2:[pangls(N,L)],'YLOG':1  ,$
;                                    PANEL_SIZE:2.0}
;                               where:  N = # of time steps
;                                       M = # of energy bins
;                                       L = # of pitch angles
;               NAME       :  Scalar string for corresponding TPLOT variable name with
;                               associated spectra (or vector) data separated by 
;                               pitch-angle or component as TPLOT variables 
;                               [e.g. 'nelb_pads']
;
;  EXAMPLES:    
;               NA
;
;  KEYWORDS:  
;               NEW_NAME   :  New string name for returned TPLOT variable
;               DATN       :  If set, data is returned normalized by 
;                               the AVG. for each energy bin
;                               [i.e. still a stacked spectra plot but normalized]
;               DATS       :  If set, data is shifted to avoid overlaps
;               WSHIFT     :  Performs a weighted shift of only the specified 
;                               energy bins {e.g. 1st 3 -> lowest energies [0,2]}
;               RANGE_AVG  :  Two element double array specifying the time range
;                               (Unix time) to use for constructing an average to
;                               normalize the data by when using the keyword DATN
;
;   CHANGED:  1)  NA                                         [07/10/2008   v1.0.1]
;             2)  Updated man page                           [03/19/2009   v1.0.2]
;             3)  Changed program my_3dp_energy_bins.pro to dat_3dp_energy_bins.pro
;                   and renamed from my_3dim_spec_shift.pro  [08/10/2009   v2.0.0]
;             4)  Added keyword:  RANGE_AVG                  [09/19/2009   v2.1.0]
;             5)  Changed program my_ytitle_tplot.pro to ytitle_tplot.pro
;                   and now calls get_data.pro
;                                                            [10/07/2008   v2.2.0]
;
;   CREATED:  06/13/2008
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  10/07/2008   v2.2.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-


Last Modification =>  2009-09-19/16:23:46 UTC
;+
;*****************************************************************************************
;
;  FUNCTION :   spec_vec_data_shift.pro
;  PURPOSE  :   Shifts (vertically) and/or normalizes the data to look at relative
;                 changes in particle spectra or vectors.  The normalization and shifting
;                 are done with respect to each component (i.e. each line) of the data
;                 individually.  A range of data for normalization purposes can be 
;                 chosen to allow one to normalize by an upstream (with respect to a
;                 shock) average as opposed to the entire data set.
;
;  CALLED BY:   
;               NA
;
;  CALLS:
;               get_data.pro
;               str_element.pro
;               spec_2dim_shift.pro
;               spec_3dim_shift.pro
;               vec_2dim_shift.pro
;               tnames.pro
;
;  REQUIRES:    
;               NA
;
;  INPUT:
;               NAME       :  Scalar string for corresponding TPLOT variable name with
;                               associated spectra (or vector) data separated by 
;                               pitch-angle or component as TPLOT variables 
;                               [e.g. 'nelb_pads']
;
;  EXAMPLES:
;               ........................
;               : {normalize the data} :
;               ........................
;               spec_vec_data_shift,'nsf_pads',/DATN,NEW_NAME='nsf_pads_n'
;               ..............................
;               : {shift 4 highest energies} :
;               ..............................
;               spec_vec_data_shift,'npl_pads',NEW_NAME='npl_pads_wsh',WSHIFT=[0,3]
;               ................................................
;               : {normalize AND shift data to avoid overlaps} :
;               ................................................
;               spec_vec_data_shift,'nel_pads',/DATN,/DATS,NEW_NAME='nel_pads_sh_n'
;
;  KEYWORDS:  
;               NEW_NAME   :  New string name for returned TPLOT variable
;               DATN       :  If set, data is returned normalized by 
;                               the AVG. for each energy bin
;                               [i.e. still a stacked spectra plot but normalized]
;               DATS       :  If set, data is shifted to avoid overlaps
;               WSHIFT     :  Performs a weighted shift of only the specified 
;                               energy bins {e.g. 1st 3 -> lowest energies [0,2]}
;               RANGE_AVG  :  Two element double array specifying the time range
;                               (Unix time) to use for constructing an average to
;                               normalize the data by when using the keyword DATN
;
;   CHANGED:  1)  NA                                         [06/24/2008   v1.2.26]
;             2)  Updated man page                           [03/19/2009   v1.2.27]
;             3)  Changed program my_2dim_spec_shift.pro to spec_2dim_shift.pro
;                   and my_3dim_spec_shift.pro to spec_3dim_shift.pro
;                   and my_2dim_vec_shift.pro to vec_2dim_shift.pro
;                   and renamed from my_data_shift_2.pro     [08/10/2009   v2.0.0]
;             4)  Added keyword:  RANGE_AVG                  [09/19/2009   v2.1.0]
;
;   CREATED:  ??/??/????
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  09/19/2009   v2.1.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-


Last Modification =>  2010-03-05/22:10:08 UTC
;+
;*****************************************************************************************
;
;  FUNCTION :   specplot_wrapper.pro
;  PURPOSE  :   This is a wrapping program meant to create a useable interface between
;                 specplot.pro and the user without going through TPLOT or requiring
;                 the use of UNIX times as the X-Axis variable.
;
;  CALLED BY:   
;               NA
;
;  CALLS:
;               str_element.pro
;               plot_positions.pro
;               box.pro
;               specplot.pro
;
;  REQUIRES:    
;               UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               X             :  X-axis values => Dimension N.
;               Y             :  Y-axis values => Dimension M. or [N,M]
;               Z             :  Color axis values:  Dimension [N,M].
;
;  EXAMPLES:    
;               NA
;
;  KEYWORDS:    
;               LIMITS        :  A structure that may contain any combination of the 
;                                  following elements:
;=========================================================================================
;                                  ALL plot keywords such as:
;                                  XLOG,   YLOG,   ZLOG,
;                                  XRANGE, YRANGE, ZRANGE,
;                                  XTITLE, YTITLE,
;                                  TITLE, POSITION, REGION  etc. (see IDL
;                                    documentation for a description)
;                                  The following elements can be included in 
;                                    LIMITS to effect DRAW_COLOR_SCALE:
;                                      ZTICKS, ZRANGE, ZTITLE, ZPOSITION, ZOFFSET
; **[Note: Program deals with these by itself, so just set them if necessary and let 
;           it do the rest.  Meaning, if you know what the tick marks should be on 
;           your color bar, define them under the ZTICK[V,NAME,S] keywords in the 
;           structure ahead of time.]**
;=========================================================================================
;               DATA          :  A structure that provides an alternate means of
;                                   supplying the data and options.  This is the 
;                                   method used by "TPLOT".
;               MULTIPLOTS    :  Not finished yet, but it is intended to allow one to
;                                  plot as many plots as necessary while only using this
;                                  routine to plot the specific spectrograms desired
;
;   CHANGED:  1)  NA [MM/DD/YYYY   v1.0.0]
;
;   NOTES:      
;               1)  If using the DATA keyword, then make sure you use it in the following
;                     manner:
;                     X-Axis Values:  label with X structure tag
;                     Y-Axis Values:  label with V structure tag
;                     Z-Axis Values:  label with Y structure tag
;
;   CREATED:  03/05/2010
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  03/05/2010   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-


Last Modification =>  2010-02-25/15:12:36 UTC
;+
;*****************************************************************************************
;
;  FUNCTION :   sst_foil_bad_bins.pro
;  PURPOSE  :   This program kills off all the data bins which are generally "bad" for
;                 the SST Foil detector on the Wind/3DP particle detector suite.
;
;  CALLED BY:   
;               plot3d.pro
;               get_padspecs.pro
;
;  CALLS:
;               NA
;
;  REQUIRES:    
;               UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               DAT        :  3DP data structure(s) either from get_sf.pro or get_sfb.pro
;
;  EXAMPLES:    
;               NA
;
;  KEYWORDS:    
;               KILL_SMGF  :  If set, not only are the "bad" bins removed from the
;                               SST Foil data structures, the bins with small
;                               geometry factors are removed too (see note below)
;
;   CHANGED:  1)  Added keyword:  KILL_SMGF                        [02/25/2010   v1.1.0]
;
;   NOTES:      
;               1)  Linghua Wang at Berkeley SSL explained that generally the following
;                     bins were "bad:"  [7,8,9,15,31,32,33]
;                     and the following have very small geometry factors making them
;                     generally excluded from data processing:
;                     [20,21,22,23,44,45,46,47]
;
;   CREATED:  02/13/2010
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  02/25/2010   v1.1.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-


Last Modification =>  2011-04-11/21:17:36 UTC
;+
;*****************************************************************************************
;
;  FUNCTION :   string_replace_char.pro
;  PURPOSE  :   Replaces designated character with user defined character.
;
;  CALLED BY:   
;               NA
;
;  CALLS:
;               NA
;
;  REQUIRES:    
;               NA
;
;  INPUT:
;               STRS      :  N-Element string array which, on input, contain the
;                              string OLD_CHAR which you wish to replace with
;                              NEW_CHAR
;               OLD_CHAR  :  Scalar string specifying the specific character in each
;                              element of STRS that you wish to replace with NEW_CHAR
;               NEW_CHAR  :  Scalar string that replaces OLD_CHAR
;
;  EXAMPLES:    
;               ; => Replace '/' with ' '
;               strs     = '2001-11-14/01:14:06.127 UT'
;               old_char = '/'
;               new_char = ' '
;               PRINT, string_replace_char(strs,old_char,new_char)
;                 2001-11-14 01:14:06.127 UT
;
;               ; => Or replace '-' with '/'
;               strs     = '2001-11-14/01:14:06.127 UT'
;               old_char = '-'
;               new_char = '/'
;               PRINT, string_replace_char(strs,old_char,new_char)
;                 2001/11/14/01:14:06.127 UT
;
;  KEYWORDS:    
;               NA
;
;   CHANGED:  1)  Added error handling to check input string and each individual string
;                   if input is an array of strings                [10/15/2010   v1.1.0]
;             2)  Fixed an issue that occurred when user passed a null string as the
;                   new string to replace the old string           [03/25/2011   v1.1.1]
;             3)  Fixed an issue that occurred when user passed '[' string value as the
;                   old string which has issues with STRMATCH      [04/11/2011   v1.1.2]
;
;   NOTES:      
;               1)  Do NOT use '*' in either OLD_CHAR or NEW_CHAR
;
;   CREATED:  07/14/2010
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  04/11/2011   v1.1.2
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-


Last Modification =>  2011-04-26/15:57:01 UTC
;+
;*****************************************************************************************
;
;  FUNCTION :   struct_new_el_add.pro
;  PURPOSE  :   Adds or replaces existing elements of an IDL structure.
;
;  CALLED BY:   
;               NA
;
;  CALLS:
;               array_where.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               NEWTAG     :  Scalar string defining the structure tag to add to OLDSTR
;               NEWVAL     :  Value associated with NEWTAG
;               OLDSTR     :  Scalar IDL structure
;
;  OUTPUT:
;               NEWSTRUCT  :  Set to a named variable for this routine to return the
;                               new IDL structure
;
;  EXAMPLES:    
;               oldstr = {X:dindgen(100),y:dindgen(100,3)}
;               newtag = 'V'
;               newval = findgen(100)
;               struct_new_el_add,newtag,newval,oldstruct,newstruct
;               HELP, newstruct,/STR
;
;** Structure <4400db8>, 3 tags, length=3600, data length=3600, refs=1:
;   X               DOUBLE    Array[100]
;   Y               DOUBLE    Array[100, 3]
;   V               FLOAT     Array[100]
;
;  KEYWORDS:    
;               GOLD_T     :  N-Element array of structure tags found in OLDSTR to use
;                               when creating NEWSTRUCT
;
;   CHANGED:  1)  Fixed a typo dealing with use of GOLD_T [04/26/2011   v1.0.1]
;
;   NOTES:      
;               
;
;   CREATED:  03/09/2011
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  04/26/2011   v1.0.1
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-


Last Modification =>  2009-10-01/19:07:53 UTC
;+
;*****************************************************************************************
;
;  FUNCTION :   threshplot.pro
;  PURPOSE  :   This program plots the results of zero_crossings.pro in an easily
;                 viewable format.
;
;  CALLED BY:   
;               NA
;
;  CALLS:
;               zero_crossings.pro
;               minmax.pro
;
;  REQUIRES:    
;               NA
;
;  INPUT:
;               TIMES   :  N-Element array of times associated with DATA
;               DATA    :  N-Element array of data that presumably fluctuates about zero
;
;  EXAMPLES:    
;               threshplot,times,data,THRESH=0.25
;
;  KEYWORDS:    
;               THRESH  :  Scalar percentage of the maximum absolute value of the input
;                            DATA you wish to consider as a threshold deviation from
;                            zero before considering the change a "zero-crossing"
;
;   CHANGED:  1)  Fixed typo                                        [09/18/2009   v1.0.1]
;             2)  Added keywords:  TITLE, YTITLE, YRANGE0, YRANGE1  [09/18/2009   v1.1.0]
;             3)  Changed some syntax and cleaned up a few things   [10/01/2009   v1.1.1]
;
;   NOTES:      
;               1)  This program is a direct adaptation of a routine by K. Kersten,
;                     threshplot.pro version ?.?.?.  
;               2)  Though it is NOT necessary to have your TIMES input array in any
;                     particular set of units, one should be careful to note that the
;                     output frequency will change depending on the input units, of
;                     course.
;
;   CREATED:  09/17/2009
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  10/01/2009   v1.1.1
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-


Last Modification =>  2009-08-10/17:07:59 UTC
;+
;*****************************************************************************************
;
;  FUNCTION :   tplot_3dp_names_labels.pro
;  PURPOSE  :   This program creates a structure of TPLOT names, labels, and Y-titles for
;                  a given particle type [Default = 'e' which is electron].
;
;  CALLED BY: 
;               my_3dptplot_names_options.pro
;
;  CALLS:       NA
;
;  REQUIRES:    NA
;
;  INPUT:       NA
;
;  EXAMPLES:
;               tplabs = my_3dptplot_names_labels(PARTICLE='e')
;               tplabs = my_3dptplot_names_labels(PARTICLE='i')
;               tplabs = my_3dptplot_names_labels(PARTICLE='a')
;
;  KEYWORDS:  
;               PARTICLE   :  Required if anything BUT MAGF is set to assign a particle
;                               species to the labels (i.e. alpha-particles will be 
;                               labeled with "a")
;                               1) "a" = alpha-particles, 2) "i" = ions,
;                               3) "e" = electrons, 4) "p" = protons
;                               [Default = "e"]
;
;   CHANGED:  1)  Fixed TPLOT labels and return structure [03/02/2009   v1.0.1]
;             2)  Fixed TPLOT labels and return structure [03/02/2009   v1.0.2]
;             3)  Rewrote and renamed with more comments  [08/05/2009   v2.0.0]
;
;   CREATED:  03/01/2009
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  08/05/2009   v2.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-


Last Modification =>  2010-10-19/13:29:59 UTC
;+
;*****************************************************************************************
;
;  FUNCTION :   tplot_struct_format_test.pro
;  PURPOSE  :   Tests an IDL structure to determine if it has the necessary structure 
;                 tags etc. to be compatible with TPLOT.
;
;  CALLED BY:   
;               vector_mv_plot.pro
;
;  CALLS:
;               NA
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               STRUCT  :  An IDL structure
;
;  EXAMPLES:    
;               ; => Example of BAD structure
;               struct = {A:lindgen(20),B:dindgen(10)}
;               test   = tplot_struct_format_test(struct)
;               print, test
;                    0
;               ; => Example of a GOOD structure
;               struct = {X:dindgen(20),Y:findgen(20)}
;               test   = tplot_struct_format_test(struct)
;               print, test
;                    1
;               ; => Example of a vector structure
;               struct = {X:dindgen(20),Y:findgen(20,3)}
;               test   = tplot_struct_format_test(struct,/YVECT)
;               print, test
;                    1
;
;  KEYWORDS:    
;               YNDIM   :  Scalar defining the number of dimensions desired in the
;                            struct.Y array, if present
;               YVECT   :  If set, program determines if struct.Y is an 
;                            [N,3]-Element array
;
;   CHANGED:  1)  Added error handling in case user entered a null variable
;                                                                 [10/19/2010   v1.1.0]
;
;   NOTES:      
;               
;
;   CREATED:  09/23/2010
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  10/19/2010   v1.1.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-


Last Modification =>  2009-09-19/15:54:30 UTC
;+
;*****************************************************************************************
;
;  FUNCTION :   vec_2dim_shift.pro
;  PURPOSE  :   Shifts vectors in plots and normalizes data (if desired)
;                 {for vector structures [e.g. 'wi_B3(GSE)', 'Vp', etc.]}
;                 and, if labels already present, returns new labels if 
;                 selected vector-components were shifted.
;
;  CALLED BY: 
;               spec_vec_data_shift.pro
;
;  CALLS:
;               store_data.pro
;               options.pro
;
;  REQUIRES:    NA
;
;  INPUT:
;               DAT        :  3D data structure of the form =>
;                               {X:[times([N]-Elements)],Y:[data([N,3]-Elements)]}
;               NAME       :  Scalar string for corresponding TPLOT variable name with
;                               associated spectra (or vector) data separated by 
;                               pitch-angle or component as TPLOT variables 
;                               [e.g. 'wi_B3(GSE)']
;
;  EXAMPLES:
;
;  KEYWORDS:  
;               NEW_NAME   :  New string name for returned TPLOT variable
;               DATN       :  If set, data is returned normalized by 
;                               the AVG. for each energy bin
;                               [i.e. still a stacked spectra plot but normalized]
;               DATS       :  If set, data is shifted to avoid overlaps
;               WSHIFT     :  Performs a weighted shift of only the specified 
;                               energy bins {e.g. 1st 3 -> lowest energies [0,2]}
;               RANGE_AVG  :  Two element double array specifying the time range
;                               (Unix time) to use for constructing an average to
;                               normalize the data by when using the keyword DATN
;
;   CHANGED:  1)  NA                                         [06/15/2008   v1.0.1]
;             2)  Updated man page                           [03/19/2009   v1.0.2]
;             3)  Cleaned up syntax and comments
;                   and renamed from my_padspec_4.pro        [08/10/2009   v2.0.0]
;             4)  Added keyword:  RANGE_AVG                  [09/19/2009   v2.1.0]
;
;   NOTES:      
;               1)  User should NOT call this program directly, use spec_vec_data_shift.pro
;
;   CREATED:  06/15/2008
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  09/19/2009   v2.1.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-


Last Modification =>  2011-04-26/17:20:08 UTC
;+
;*****************************************************************************************
;
;  FUNCTION :   no_label2.pro
;  PURPOSE  :   This function used to stop labeling of tick marks for plotting over a
;                 previous plot.
;
;*****************************************************************************************
;-
;+
;*****************************************************************************************
;
;  FUNCTION :   vector_3d_plot.pro
;  PURPOSE  :   This routine plots the 3D vector ray from an input of {x,y,z} components.
;
;  CALLED BY:   
;               NA
;
;  CALLS:
;               plot_struct_format_test.pro
;               struct_new_el_add.pro
;               no_label2.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               [X,Y,Z]0   :  N-Element array of [X,Y,Z]-Component data for the
;                               vector {X,Y,Z}
;
;  EXAMPLES:    
;               kvec0       = [-0.37503, 0.18313, 0.90874]
;               min_vec0    = [-0.29717, 0.49649, 0.81559]
;               mid_vec0    = [ 0.95034, 0.23649,-0.20231]
;               max_vec0    = [ 0.09244,-0.83520, 0.54212]
;               xvec        = [kvec0[0],min_vec0[0],mid_vec0[0],max_vec0[0]] 
;               yvec        = [kvec0[1],min_vec0[1],mid_vec0[1],max_vec0[1]]
;               zvec        = [kvec0[2],min_vec0[2],mid_vec0[2],max_vec0[2]]
;               vecname     = ['k-Vector','MinVar','MidVar','MaxVar']
;               limit       = {TITLE:'MVA in GSE',XTITLE:'X-GSE',YTITLE:'Y-GSE',ZTITLE:'Z-GSE'}
;               vector_3d_plot,xvec,yvec,zvec,LIMIT=limit,VECNAME=vecname,CHANGECOL=45
;
;  KEYWORDS:    
;               LIMIT      :  IDL limit structure used with PLOT.PRO keyword _EXTRA
;                               [see IDL documentation for more details]
;               VECNAME    :  Scalar string defining the vector name(s)
;                               [Default = 'VEC-j', where j=0,1,...,N-1]
;               CHANGECOL  :  If set, program will change the color table to a new one
;                               [Scalar value ]
;               NO_PROJ    :  If set, program will not plot the XY-projections of the
;                               vectors
;               AXESROT    :  2-Element array of rotation angles [degrees] about the
;                               X-Axis and then the Z-Axis
;                               [e.g. axesrot=[20.,-120.]]
;
;   CHANGED:  1)  Added keyword:  NO_PROJ and fixed a typo in plotting routine
;                   so the program now plots normalized vectors     [03/10/2011   v1.1.0]
;             2)  Moved color table location search to inside IF statement in case
;                   user does not want program to waste time searching for a file
;                   they may not have                               [03/11/2011   v1.1.1]
;             3)  Program now calls struct_new_el_add.pro and no longer has one set
;                   of rotation angles, rather a set that depend on the input vector
;                   projections relative to each plane              [04/26/2011   v1.2.0]
;
;   NOTES:      
;               
;
;   CREATED:  03/09/2011
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  04/26/2011   v1.2.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-


Last Modification =>  2009-08-10/21:58:42 UTC
;+
;*****************************************************************************************
;
;  FUNCTION :   vector_bandpass.pro
;  PURPOSE  :   This program does a bandpass filter on the input data using IDL's
;                 built-in FFT.PRO routine.  The data is first padded with zeroes
;                 to ensure the number of elements remains an integer power of 2.
;                 The user defines the input vector array of data, the sample rate, 
;                 and frequency range(s) before running the program, then tells the 
;                 program whether a low-pass (i.e. only return low frequency 
;                 signals), high-pass, or middle frequency bandpass filter.  The 
;                 program eliminates the postitive AND negative frequency bins in 
;                 frequency space to ensure symmetry before performing the inverse 
;                 FFT on the data.
;
;  CALLED BY:   NA
;
;  CALLS: 
;               power_of_2.pro
;
;  REQUIRES:    NA
;
;  INPUT:
;               DAT    :  [N,3]-Array of magnetic or electric field data
;               SR     :  Scalar defining the sample rate (mHz, Hz, kHz, etc. doesn't
;                           matter as long as everything is consistent)
;               LF     :  Scalar defining the low frequency cutoff (Default = 0)
;                          [Note:  MUST be same units as SR]
;               HF     :  Scalar defining the high frequency cutoff (Default = Nyquist)
;                          [Note:  MUST have same units as SR AND LF]
;
;  EXAMPLES: 
;                 htr_mfi2tplot,DATE=date
;                 get_data,'WIND_B3_HTR(GSE,nT)',DATA=mag
;                 magf  = mag.Y
;                 tt    = mag.X                        ; -Unix time (s since 01/01/1970)
;                 nt    = N_ELEMENTS(tx)
;                 evl   = MAX(tt,/NAN) - MIN(tt,/NAN)  ; -Event length (s)
;                 nsps  = ((nt - 1L)/evl)              ; -Approx Sample Rate (Hz)
;                 lfmf1 = vector_bandpass(magf,nsps,15d-2,15d-1,/LOWF)
;
;  KEYWORDS:  
;               LOWF   :  If set, program returns low-pass filtered data with freqs
;                           below LF
;               MIDF   :  If set, program returns bandpass filtered data with freqs
;                           between LF and HF  **[Default]**
;               HIGHF  :  If set, program returns high-pass filtered data with freqs
;                           above HF
;
;   CHANGED:  1)  Fixed Low Freq. bandpass to get rid of artificial 
;                   zero frequency bin created by FFT calc.  [01/14/2009   v1.0.1]
;             2)  Fixed case where NaN's are in data         [01/18/2009   v1.0.2]
;             3)  Changed program my_power_of_2.pro to power_of_2.pro
;                   and renamed                              [08/10/2009   v2.0.0]
;
;   CREATED:  12/30/2009
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  08/10/2009   v2.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-


Last Modification =>  2011-03-10/22:07:56 UTC
;+
;*****************************************************************************************
;
;  FUNCTION :   list_read_options.pro
;  PURPOSE  :   Prints to screen all the optional values allowed for user input
;                 and their purpose.
;
;  CALLED BY:   
;               vector_mv_plot.pro
;
;  CALLS:
;               NA
;
;  REQUIRES:    
;               NA
;
;  INPUT:
;               NA
;
;  EXAMPLES:    
;               list_read_options
;
;  KEYWORDS:    
;               NA
;
;   CHANGED:  1)  NA [MM/DD/YYYY   v1.0.0]
;
;   NOTES:      
;               1)  This should NOT be called by user
;
;   CREATED:  03/04/2011
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  03/04/2011   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-
;+
;*****************************************************************************************
;
;  FUNCTION :   change_tr_lrtr.pro
;  PURPOSE  :   Determines the new elements to use depending upon the different
;                 time range/scaling desired by user.
;
;  CALLED BY:   
;               vector_mv_plot.pro
;
;  CALLS:
;               my_time_string.pro
;               time_double.pro
;               change_tr_lrtr.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               SS0    :  Scalar defining the current start element
;               EE0    :  Scalar defining the current end   element
;               UNIX   :  N-Element array of Unix times
;
;  EXAMPLES:    
;               s0   = 0L
;               e0   = N_ELEMENTS(tx) - 1L
;               ;++++++++++++++++++++++++++++++++++++++++++++++
;               ; => Change the end element
;               ;++++++++++++++++++++++++++++++++++++++++++++++
;               rels = change_tr_lrtr(s0,e0,tx,LEFT=0,RIGHT=1,TR=0,ZOOMT=0)
;               s1   = rels[0]
;               e1   = rels[1]
;               ;++++++++++++++++++++++++++++++++++++++++++++++
;               ; => Change the start element
;               ;++++++++++++++++++++++++++++++++++++++++++++++
;               lels = change_tr_lrtr(s0,e0,tx,LEFT=1,RIGHT=0,TR=0,ZOOMT=0)
;               s1   = lels[0]
;               e1   = lels[1]
;               ;++++++++++++++++++++++++++++++++++++++++++++++
;               ; => Change the both the start and end elements
;               ;++++++++++++++++++++++++++++++++++++++++++++++
;               bels = change_tr_lrtr(s0,e0,tx,LEFT=0,RIGHT=0,TR=1,ZOOMT=0)
;               s1   = bels[0]
;               e1   = bels[1]
;
;  KEYWORDS:    
;               LEFT   :  If set, program will adjust the start elment
;                           from user a defined start time
;               RIGHT  :  If set, program will adjust the end   element
;                           from user a defined end time
;               TR     :  If set, program will adjust the both start and end elements
;                           from user defined start and end times
;               ZOOMT  :  If set, program will adjust the time range by zooming by
;                           a power of 4, 8, or 10 [user selects]
;
;   CHANGED:  1)  NA [MM/DD/YYYY   v1.0.0]
;
;   NOTES:      
;               1)  This should NOT be called by user
;
;   CREATED:  03/04/2011
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  03/04/2011   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-
;+
;*****************************************************************************************
;
;  FUNCTION :   vector_mv_plot.pro
;  PURPOSE  :   Plots the High Time Resolution (HTR) magnetic field data from
;                 the Wind spacecraft in GSE and minimum variance coordinates.  The
;                 program will also output plots of the field-aligned and 
;                 perpendicular current density estimates if desired.
;
;  CALLS:  
;               my_str_date.pro
;               my_loadct2.pro
;               my_colors2.pro       ; => Common block
;               my_time_string.pro
;               tplot_struct_format_test.pro
;               my_min_var_rot.pro
;               plot_vector_mv_data.pro
;               list_read_options.pro
;               change_tr_lrtr.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:       
;               NA
;
;  EXAMPLES:
;               NA
;
;  KEYWORDS:  
;               DATE    :  Scalar string ('MMDDYY' [MM=month, DD=day, YY=year])
;               MYMAG   :  User defined [n,3]-element array of vector field data with
;                            associated Unix time as part of a structure with tags 
;                            X = time 
;                            Y = [N,3]-field.
;               FCUTOFF :  Set to a two element array specifying the range of 
;                            frequencies to use in power spectrum plots if data has
;                            been bandpass-filtered
;               SAT     :  Defines which satellite ('A', 'B', or 'W' to use)
;                              [Default = 'W' corresponding to Wind]
;               COORD   :  Defines which coordinate system to use for plot labels
;                            ['RTN' or 'GSE' or 'SC', Default = 'GSE']
;               FIELD   :  Set to a scalar string defining whether the input is a
;                            magnetic ('B') or electric ('E') field 
;                            [Default = 'B']
;               DCBKGF  :  Structure of format {X:Unix Times, Y:[N,3]-Element Vector}
;                            DCBKGF should contain the background/ambient vector field
;                            data that you wish to use as a reference direction (i.e.
;                            DC B-field) when comparing to the MV-direction
;               STATS   :  Set to a named variable to return the relevant information
;                            for each plot you save
;
;   CHANGED:  1)  Added keywords to return plot title information from
;                  my_plot_mv_htr_data.pro                        [09/11/2008   v1.0.1]
;             2)  Changed functionality of keywords in my_plot_mv_htr_data.pro
;                  and added htr_fa_maxwells_2.pro dependence if keyword
;                  CURR is set                                    [09/11/2008   v1.0.2]
;             3)  Changed functionality of in my_plot_mv_htr_data.pro 
;                                                                 [09/18/2008   v1.0.3]
;             4)  Changed functionality of in my_plot_mv_htr_data.pro 
;                  (Added keyword, EIGA)                          [09/18/2008   v1.0.4]
;             5)  Updated Man. Page                               [10/16/2008   v1.0.5]
;             6)  Updated Output                                  [10/26/2008   v1.0.6]
;             7)  Added Keyword: MYMAG                            [10/27/2008   v1.0.7]
;             8)  Fixed/Changed power spectrum calcs => Alters plots!
;                                                                 [11/20/2008   v1.1.0]
;             9)  Added Keyword: FCUTOFF                          [11/20/2008   v1.1.1]
;            10)  Added keyword: SAT                              [12/30/2008   v1.1.2]
;            10)  Added keyword: COORD                            [12/30/2008   v1.1.2]
;            11)  Updated times to be compatible with Unix times (changed other syntax)
;                                                                 [05/24/2009   v1.2.0]
;            12)  Changed some syntax [no functional changes]     [05/25/2009   v1.2.1]
;            13)  Added new JUMP point: JUMP_SAVE                 [06/03/2009   v1.3.0]
;            14)  Changed initial charsize when plotting          [07/16/2009   v1.3.1]
;            15)  Added keyword: FIELD                            [07/16/2009   v1.3.2]
;            16)  Changed program my_plot_mv_htr_data.pro to plot_vector_mv_data.pro
;                   and removed keyword:  CURR
;                   and renamed from htr_mv_plot.pro              [08/12/2009   v2.0.0]
;            17)  Fixed type with 'tr' option                     [09/22/2010   v2.1.0]
;            18)  Added keyword:  DCBKGF and changed output options for
;                   plot_vector_mv_data.pro                       [09/23/2010   v2.2.0]
;            19)  Fixed issue with color table                    [09/24/2010   v2.2.1]
;            20)  Added some error handling with time range options and added two new
;                   options which allow one to change the start/end time independently
;                   and added keyword:  STATS
;                                                                 [10/20/2010   v2.3.0]
;            21)  Fixed typo with keyword DCBKGF error handling   [11/12/2010   v2.3.1]
;            22)  Removed all dependencies on HTR MFI data programs
;                                                                 [11/16/2010   v2.4.0]
;            23)  Added new options and now calls change_tr_lrtr.pro 
;                   and list_read_options.pro [seen above]        [03/04/2011   v2.5.0]
;            24)  Fixed typo with option 'thick'                  [03/08/2011   v2.5.1]
;            25)  Fixed typo with options 'ps' and changed 'sc' so that scaling the
;                   B-field allows you to perform MVA after you remove DC offsets
;                   in the data                                   [03/10/2011   v2.5.2]
;
;   NOTES:      
;               1)  MYMAG keyword must be set and used with the correct format.
;
;   CREATED:  08/26/2008
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  03/10/2011   v2.5.2
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-


Last Modification =>  2011-05-11/02:48:22 UTC
;+
;*****************************************************************************************
;
;  FUNCTION :   wave_normal_angle_cold.pro
;  PURPOSE  :   Calculates the wave normal angle from cold plasma theory using the
;                 two perpendicular components of the electric field, solving Eq. 1-31
;                 from Stix, [1962].
;
;  CALLED BY:   
;               
;
;  CALLS:
;               
;
;  REQUIRES:    
;               
;
;  INPUT:
;               EP1    :  M-Element array of perpendicular electric fields (mV/m)
;                           corresponding to Ex in Eq. 1-31 from Stix, [1962]
;               EP2    :  M-Element array of perpendicular electric fields (mV/m)
;                           corresponding to Ey in Eq. 1-31 from Stix, [1962]
;               MAGF   :  N-Element array of magnetic field magnitudes (nT)
;               DENS   :  " " plasma densities [cm^(-3)]
;
;  EXAMPLES:    
;               
;
;  KEYWORDS:    
;               FREQF  :  K-Element array of wave frequencies (Hz)
;               NDAT   :  Scalar number of values to create for dummy frequencies or
;                           angles if FREQF or ANGLE not set [Default = 100 (= L)]
;               ONED   :  If set, all parameters are assumed to have the same number of
;                           elements and MAGF[j] corresponds to DENS[j] and FREQF[j] and
;                           ANGLE[j] => all returned values with be 1-Dimensional arrays
;
;   CHANGED:  1)  NA [MM/DD/YYYY   v1.0.0]
;
;   NOTES:      
;               1)  If MAGF and DENS have more than one element, then they must have
;                     the same number of elements.  The program assumes that they
;                     correspond to the same place/time measurement and will use them
;                     as such.
;               
;
;  REFERENCES:  
;               1)  Stix, T.H. (1962), "The Theory of Plasma Waves,"
;                      McGraw-Hill Book Company, USA.
;               2)  Gurnett, D. A., and A. Bhattacharjee (2005), "Introduction to
;                      Plasma Physics:  With Space and Laboratory Applications,"
;                      ISBN 0521364833. Cambridge, UK: Cambridge University Press.
;
;   CREATED:  05/10/2011
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  05/10/2011   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-


Last Modification =>  2006-11-15/20:00:14 UTC
;+
; NAME:   WAVE_SIGNIF
;
; PURPOSE:   Compute the significance levels for a wavelet transform.
;       
;
; CALLING SEQUENCE:
;
;      result = WAVE_SIGNIF(y,dt,scale,sigtest)
;
;
; INPUTS:
;
;    Y = the time series, or, the VARIANCE of the time series.
;        (If this is a single number, it is assumed to be the variance...)
;
;    DT = amount of time between each Y value, i.e. the sampling time.
;
;    SCALE = the vector of scale indices, from previous call to WAVELET.
;
;    SIGTEST = 0, 1, or 2.    If omitted, then assume 0.
;
;          If 0 (the default), then just do a regular chi-square test,
;       		 i.e. Eqn (18) from Torrence & Compo.
;          If 1, then do a "time-average" test, i.e. Eqn (23).
;       		 In this case, DOF should be set to NA, the number
;       		 of local wavelet spectra that were averaged together.
;       		 For the Global Wavelet Spectrum, this would be NA=N,
;       		 where N is the number of points in your time series.
;          If 2, then do a "scale-average" test, i.e. Eqns (25)-(28).
;       		 In this case, DOF should be set to a
;       		 two-element vector [S1,S2], which gives the scale
;       		 range that was averaged together.
;       		 e.g. if one scale-averaged scales between 2 and 8,
;                     then DOF=[2,8].
;
;
; OUTPUTS:
;
;    result = significance levels as a function of SCALE,
;             or if /CONFIDENCE, then confidence intervals
;
;
; OPTIONAL KEYWORD INPUTS:
;
;    MOTHER = A string giving the mother wavelet to use.
;            Currently, 'Morlet','Paul','DOG' (derivative of Gaussian)
;            are available. Default is 'Morlet'.
;
;    PARAM = optional mother wavelet parameter.
;            For 'Morlet' this is k0 (wavenumber), default is 6.
;            For 'Paul' this is m (order), default is 4.
;            For 'DOG' this is m (m-th derivative), default is 2.
;
;    LAG1 = LAG 1 Autocorrelation, used for SIGNIF levels. Default is 0.0
;
;    SIGLVL = significance level to use. Default is 0.95
;
;    DOF = degrees-of-freedom for signif test.
;          IF SIGTEST=0, then (automatically) DOF = 2 (or 1 for MOTHER='DOG')
;          IF SIGTEST=1, then DOF = NA, the number of times averaged together.
;          IF SIGTEST=2, then DOF = [S1,S2], the range of scales averaged.
;
;   	 Note: IF SIGTEST=1, then DOF can be a vector (same length as SCALEs),
;   		   in which case NA is assumed to vary with SCALE.
;   		   This allows one to average different numbers of times
;   		   together at different scales, or to take into account
;   		   things like the Cone of Influence.
;   		   See discussion following Eqn (23) in Torrence & Compo.
;
;    GWS = global wavelet spectrum. If input then this is used
;          as the theoretical background spectrum,
;          rather than white or red noise.
;
;    CONFIDENCE = if set, then return a Confidence INTERVAL.
;                 For SIGTEST=0,2 this will be two numbers, the lower & upper.
;                 For SIGTEST=1, this will return an array (J+1)x2,
;                 where J+1 is the number of scales.
;
;
; OPTIONAL KEYWORD OUTPUTS:
;
;    PERIOD = the vector of "Fourier" periods (in time units) that corresponds
;           to the SCALEs.
;
;    FFT_THEOR = output theoretical red-noise spectrum as fn of PERIOD.
;
;
;----------------------------------------------------------------------------
;
; EXAMPLE:
;
;    IDL> wave = WAVELET(y,dt,PERIOD=period,SCALE=scale)
;    IDL> signif = WAVE_SIGNIF(y,dt,scale)
;    IDL> signif = REBIN(TRANSPOSE(signif),ntime,nscale)
;    IDL> CONTOUR,ABS(wave)^2/signif,time,period, $
;           LEVEL=1.0,C_ANNOT='95%'
;
;
;----------------------------------------------------------------------------
; Copyright (C) 1995-1998, Christopher Torrence and Gilbert P. Compo,
; University of Colorado, Program in Atmospheric and Oceanic Sciences.
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties whatsoever.
;
; Notice: Please acknowledge the use of the above software in any publications:
;    ``Wavelet software was provided by C. Torrence and G. Compo,
;      and is available at URL: http://paos.colorado.edu/research/wavelets/''.
;
;----------------------------------------------------------------------------
;-


Last Modification =>  2009-12-07/16:37:27 UTC
;+
; NAME:   WAVELET
;
; PURPOSE:   Compute the WAVELET transform of a 1D time series.
;
;
; CALLING SEQUENCE:
;
;      wave = WAVELET(Y,DT)
;
;
; INPUTS:
;
;    Y = the time series of length N.
;
;    DT = amount of time between each Y value, i.e. the sampling time.
;
;
; OUTPUTS:
;
;    WAVE is the WAVELET transform of Y. This is a complex array
;    of dimensions (N,J+1). FLOAT(WAVE) gives the WAVELET amplitude,
;    ATAN(IMAGINARY(WAVE),FLOAT(WAVE)) gives the WAVELET phase.
;    The WAVELET power spectrum is ABS(WAVE)^2.
;
;
; OPTIONAL KEYWORD INPUTS:
;
;    S0 = the smallest scale of the wavelet.  Default is 2*DT.
;
;    DJ = the spacing between discrete scales. Default is 0.125.
;         A smaller # will give better scale resolution, but be slower to plot.
;
;    J = the # of scales minus one. Scales range from S0 up to S0*2^(J*DJ),
;        to give a total of (J+1) scales. Default is J = (LOG2(N DT/S0))/DJ.
;
;    MOTHER = A string giving the mother wavelet to use.
;            Currently, 'Morlet','Paul','DOG' (derivative of Gaussian)
;            are available. Default is 'Morlet'.
;
;    PARAM = optional mother wavelet parameter.
;            For 'Morlet' this is k0 (wavenumber), default is 6.
;            For 'Paul' this is m (order), default is 4.
;            For 'DOG' this is m (m-th derivative), default is 2.
;
;    PAD = if set, then pad the time series with enough zeroes to get
;         N up to the next higher power of 2. This prevents wraparound
;         from the end of the time series to the beginning, and also
;         speeds up the FFT's used to do the wavelet transform.
;         This will not eliminate all edge effects (see COI below).
;
;    LAG1 = LAG 1 Autocorrelation, used for SIGNIF levels. Default is 0.0
;
;    SIGLVL = significance level to use. Default is 0.95
;
;    VERBOSE = if set, then print out info for each analyzed scale.
;
;    RECON = if set, then reconstruct the time series, and store in Y.
;            Note that this will destroy the original time series,
;            so be sure to input a dummy copy of Y.
;
;    FFT_THEOR = theoretical background spectrum as a function of
;                Fourier frequency. This will be smoothed by the
;                wavelet function and returned as a function of PERIOD.
;
;
; OPTIONAL KEYWORD OUTPUTS:
;
;    PERIOD = the vector of "Fourier" periods (in time units) that corresponds
;           to the SCALEs.
;
;    SCALE = the vector of scale indices, given by S0*2^(j*DJ), j=0...J
;            where J+1 is the total # of scales.
;
;    COI = if specified, then return the Cone-of-Influence, which is a vector
;        of N points that contains the maximum period of useful information
;        at that particular time.
;        Periods greater than this are subject to edge effects.
;        This can be used to plot COI lines on a contour plot by doing:
;            IDL>  CONTOUR,wavelet,time,period
;            IDL>  PLOTS,time,coi,NOCLIP=0
;
;    YPAD = returns the padded time series that was actually used in the
;         wavelet transform.
;
;    DAUGHTER = if initially set to 1, then return the daughter wavelets.
;         This is a complex array of the same size as WAVELET. At each scale
;         the daughter wavelet is located in the center of the array.
;
;    SIGNIF = output significance levels as a function of PERIOD
;
;    FFT_THEOR = output theoretical background spectrum (smoothed by the
;                wavelet function), as a function of PERIOD.
;
;
; [ Defunct INPUTS:
; [   OCT = the # of octaves to analyze over.           ]
; [         Largest scale will be S0*2^OCT.             ]
; [         Default is (LOG2(N) - 1).                   ]
; [   VOICE = # of voices in each octave. Default is 8. ]
; [          Higher # gives better scale resolution,    ]
; [          but is slower to plot.                     ]
; ]
;
;----------------------------------------------------------------------------
;
; EXAMPLE:
;
;    IDL> ntime = 256
;    IDL> y = RANDOMN(s,ntime)       ;*** create a random time series
;    IDL> dt = 0.25
;    IDL> time = FINDGEN(ntime)*dt   ;*** create the time index
;    IDL>
;    IDL> wave = WAVELET(y,dt,PERIOD=period,COI=coi,/PAD,SIGNIF=signif)
;    IDL> nscale = N_ELEMENTS(period)
;    IDL> LOADCT,39
;    IDL> CONTOUR,ABS(wave)^2,time,period, $
;       XSTYLE=1,XTITLE='Time',YTITLE='Period',TITLE='Noise Wavelet', $
;       YRANGE=[MAX(period),MIN(period)], $   ;*** Large-->Small period
;       /YTYPE, $                             ;*** make y-axis logarithmic
;       NLEVELS=25,/FILL
;    IDL>
;    IDL> signif = REBIN(TRANSPOSE(signif),ntime,nscale)
;    IDL> CONTOUR,ABS(wave)^2/signif,time,period, $
;           /OVERPLOT,LEVEL=1.0,C_ANNOT='95%'
;    IDL> PLOTS,time,coi,NOCLIP=0   ;*** anything "below" this line is dubious
;
;
;----------------------------------------------------------------------------
; Copyright (C) 1995-1998, Christopher Torrence and Gilbert P. Compo,
; University of Colorado, Program in Atmospheric and Oceanic Sciences.
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties whatsoever.
;
; Notice: Please acknowledge the use of the above software in any publications:
;    ``Wavelet software was provided by C. Torrence and G. Compo,
;      and is available at URL: http://paos.colorado.edu/research/wavelets/''.
;
; Reference: Torrence, C. and G. P. Compo, 1998: A Practical Guide to
;            Wavelet Analysis. <I>Bull. Amer. Meteor. Soc.</I>, 79, 61-78.
;
; Please send a copy of such publications to either C. Torrence or G. Compo:
;  Dr. Christopher Torrence               Dr. Gilbert P. Compo
;  Advanced Study Program                 NOAA/CIRES Climate Diagnostics Center
;  National Center for Atmos. Research    Campus Box 216
;  P.O. Box 3000                          University of Colorado
;  Boulder CO 80307--3000, USA.           Boulder CO 80309-0216, USA.
;  E-mail: torrence@ucar.edu              E-mail: gpc@cdc.noaa.gov
;----------------------------------------------------------------------------
;-


Last Modification =>  2009-12-07/19:23:15 UTC
;+
;*****************************************************************************************
;
;  FUNCTION :   morlet2d.pro
;  PURPOSE  :   Calculates the Morlet wavelet transform.
;
;  CALLED BY:   
;               wavelet2d.pro
;
;  CALLS:
;               NA
;
;  REQUIRES:    
;               NA
;
;  INPUT:
;               K0         :  Scalar defining the k0 (wavenumber) [Default is 6]
;               SCALE      :  M-Element array of wavelet time scales
;               K          :  N-Element array of wavelet wavenumbers
;               PERIOD     :  Set to a named variable to the vector of "Fourier" 
;                               periods (in time units) that corresponds to the SCALEs.
;               COI        :  Set to a named variable to return the Cone-of-Influence
;                               e-folding parameter
;               DOFMIN     :  Set to a named variable to return the minimum degrees
;                               of freedom
;               CDELTA     :  Set to a named variable to return reconstruction factor
;               PSI0       :  Set to a named variable to return a constant equal to
;                               1/Pi^(0.25) for normalization
;
;  EXAMPLES:    
;               morletw = morlet2d(6d0,scales,kk,period1,coifac,dof,Cdel,psi00)
;
;  KEYWORDS:    
;               NA
;
;   CHANGED:  1)  The new calculations are vectorized eliminating the
;                   the FOR loop, thus speeding up the calculation for 
;                   large input time series arrays              [12/07/2009   v1.1.0]
;
;   NOTES:      
;               1)  User should not call this function directly
;
;   CREATED:  12/07/2009
;   CREATED BY:  Dr. Christopher Torrence and Dr. Gilbert P. Compo
;    LAST MODIFIED:  12/07/2009   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-
;+
;*****************************************************************************************
;
;  FUNCTION :   wavelet2d.pro
;  PURPOSE  :   This program computes the wavelet transform of a 1D time series.  The
;                 2D in the name is specifically referring to the vectorization done
;                 in order to speed up the calculation when using large arrays of data.
;
;  CALLED BY:   
;               wavelet_to_tplot.pro
;
;  CALLS:
;               morlet2d.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;               2)  Software produced by Dr. Christopher Torrence and 
;                     Dr. Gilbert P. Compo.
;
; OUTPUTS:
;               WAVE is the WAVELET transform of Y. This is a complex array
;               of dimensions (N,J+1). FLOAT(WAVE) gives the WAVELET amplitude,
;               ATAN(IMAGINARY(WAVE),FLOAT(WAVE)) gives the WAVELET phase.
;               The WAVELET power spectrum is ABS(WAVE)^2.
;
;  INPUT:
;               Y          :  N-Element array of data (time series)
;               DT         :  Scalar defining the sample period
;
;  EXAMPLES:    
;
;    IDL> ntime = 256
;    IDL> y = RANDOMN(s,ntime)       ;*** create a random time series
;    IDL> dt = 0.25
;    IDL> time = FINDGEN(ntime)*dt   ;*** create the time index
;    IDL>
;    IDL> wave = WAVELET2D(y,dt,PERIOD=period,COI=coi,/PAD,SIGNIF=signif)
;    IDL> nscale = N_ELEMENTS(period)
;    IDL> LOADCT,39
;    IDL> CONTOUR,ABS(wave)^2,time,period, $
;       XSTYLE=1,XTITLE='Time',YTITLE='Period',TITLE='Noise Wavelet', $
;       YRANGE=[MAX(period),MIN(period)], $   ;*** Large-->Small period
;       /YTYPE, $                             ;*** make y-axis logarithmic
;       NLEVELS=25,/FILL
;    IDL>
;    IDL> signif = REBIN(TRANSPOSE(signif),ntime,nscale)
;    IDL> CONTOUR,ABS(wave)^2/signif,time,period, $
;           /OVERPLOT,LEVEL=1.0,C_ANNOT='95%'
;    IDL> PLOTS,time,coi,NOCLIP=0   ;*** anything "below" this line is dubious
;
;    ; => To plot the cone of influence, do the following...
;    IDL>  CONTOUR,wavelet,time,period
;    IDL>  PLOTS,time,coi,NOCLIP=0
;               
;
;  KEYWORDS:    
;               S0         :  Scalar defining the smallest scale of the wavelet.  
;                               [Default is 2*DT]
;               DJ         :  Scalar defining the spacing between discrete scales. 
;                               [Default is 0.125]  
;                               A smaller # will give better scale resolution, but be 
;                               slower to plot.
;               J          :  Scalar defining the # of scales minus one. Scales range 
;                               from S0 up to S0*2^(J*DJ), to give a total of (J+1) 
;                               scales. Default is J = (LOG2(N DT/S0))/DJ.
;               MOTHER     :  Scalar string giving the mother wavelet to use.
;                               Currently, 'Morlet','Paul','DOG' (derivative of Gaussian)
;                               are available. Default is 'Morlet'.
;               PARAM      :  Optional mother wavelet parameter.
;                               'Morlet' : this is k0 (wavenumber), default is 6.
;                               'Paul'   : this is m (order), default is 4.
;                               'DOG'    : this is m (m-th derivative), default is 2.
;               PAD        :  If set, then pad the time series with enough zeroes 
;                               to get N up to the next higher power of 2. This 
;                               prevents wrap around from the end of the time series 
;                               to the beginning, and also speeds up the FFT's used 
;                               to do the wavelet transform.  This will not eliminate 
;                               all edge effects (see COI below).
;               LAG1       :  LAG 1 Autocorrelation, used for SIGNIF levels. 
;                               [Default is 0.0]
;               SIGLVL     :  Significance level to use. [Default is 0.95]
;               VERBOSE    :  If set, then print out info for each analyzed scale.
;               RECON      :  If set, then reconstruct the time series, and store in Y.  
;                               Note that this will destroy the original time series, 
;                               so be sure to input a dummy copy of Y.
;               FFT_THEOR  :  Set to the theoretical background spectrum as a function 
;                               of Fourier frequency. This will be smoothed by the 
;                               wavelet function and returned as a function of PERIOD.
;
; OPTIONAL KEYWORD OUTPUTS:
;               PERIOD     :  Set to a named variable to the vector of "Fourier" 
;                               periods (in time units) that corresponds to the SCALEs.
;               SCALE      :  Set to a named variable to the vector of scale indices, 
;                               given by S0*2^(j*DJ), j=0...J where J+1 is the 
;                               total # of scales.
;               COI        :  Set to a named variable to return the Cone-of-Influence, 
;                               which is a vector of N points that contains the 
;                               maximum period of useful information at that 
;                               particular time.  Periods greater than this are 
;                               subject to edge effects.
;               YPAD       :  Set to a named variable to return the padded time 
;                               series that was actually used in the wavelet 
;                               transform.
;               DAUGHTER   :  Set to a named variable to 
;               SIGNIF     :  Set to a named variable to output significance levels 
;                               as a function of PERIOD
;               FFT_THEOR  :  Set to a named variable to output theoretical background 
;                               spectrum (smoothed by the wavelet function), as a 
;                               function of PERIOD.
;               
;
;   CHANGED:  1)  The new calculations are vectorized eliminating the
;                   the FOR loop, thus speeding up the calculation for 
;                   large input time series arrays              [12/07/2009   v1.1.0]
;
;   NOTES:      
;
; [ Defunct INPUTS:
; [   OCT = the # of octaves to analyze over.           ]
; [         Largest scale will be S0*2^OCT.             ]
; [         Default is (LOG2(N) - 1).                   ]
; [   VOICE = # of voices in each octave. Default is 8. ]
; [          Higher # gives better scale resolution,    ]
; [          but is slower to plot.                     ]
; ]
;
;=========================================================================================
; Copyright (C) 1995-1998, Christopher Torrence and Gilbert P. Compo,
; University of Colorado, Program in Atmospheric and Oceanic Sciences.
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties whatsoever.
;
; Notice: Please acknowledge the use of the above software in any publications:
;    ``Wavelet software was provided by C. Torrence and G. Compo,
;      and is available at URL: http://paos.colorado.edu/research/wavelets/''.
;
; Reference: Torrence, C. and G. P. Compo, 1998: A Practical Guide to
;            Wavelet Analysis. <I>Bull. Amer. Meteor. Soc.</I>, 79, 61-78.
;
; Please send a copy of such publications to either C. Torrence or G. Compo:
;  Dr. Christopher Torrence               Dr. Gilbert P. Compo
;  Advanced Study Program                 NOAA/CIRES Climate Diagnostics Center
;  National Center for Atmos. Research    Campus Box 216
;  P.O. Box 3000                          University of Colorado
;  Boulder CO 80307--3000, USA.           Boulder CO 80309-0216, USA.
;  E-mail: torrence@ucar.edu              E-mail: gpc@cdc.noaa.gov
;=========================================================================================
;
;   CREATED:  12/07/2009
;   CREATED BY:  Dr. Christopher Torrence and Dr. Gilbert P. Compo
;    LAST MODIFIED:  12/07/2009   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-


Last Modification =>  2011-05-11/16:27:50 UTC
;+
;*****************************************************************************************
;
;  FUNCTION :   wavelet_to_tplot.pro
;  PURPOSE  :   This is a small wrapping program for the program wavelet.pro written
;                 by Dr. Christopher Torrence and Dr. Gilbert P. Compo.  The citation
;                 information is shown below.  The program takes a time array and
;                 data array, performs a wavelet transform on them, then sends the
;                 power spectrum to TPLOT for analysis.
;
;  CALLED BY:   
;               NA
;
;  CALLS:
;               wavelet.pro
;               wavelet2d.pro
;
;  REQUIRES:    
;               Software produced by Dr. Christopher Torrence and Dr. Gilbert P. Compo.
;
;  INPUT:
;               TT  :  N-Element array of Unix times
;               DD  :  N-Element array of data
;
;  EXAMPLES:    
;               nscet = '1998/08/26 06:40:26.120 UT'
;               ntime = STRMID(nscet,0,4)+'-'+STRMID(nscet,5,2)+'-'+STRMID(nscet,8,2)+ $
;                       '_'+STRMID(nscet,11,2)+STRMID(nscet,14,2)
;               utx   = REFORM(tds_unx[j,*])            ; => Unix time
;               bperp = REFORM(rot_shn_bfields[*,j,0])  ; => Perp. B-field
;               store_data,'Bperp_'+ntime+'_FIXED',DATA={X:utx,Y:bperp}
;               nname = 'Bperp_'+ntime+'_wavelet'
;               wavelet_to_tplot,utx,bperp1,NEW_NAME=nname,/KILL_CONE
;               options,'Bperp_'+ntime,'YTITLE','B!D'+'!9x!3'+'!N (nT)'
;               options,'Bperp_'+ntime,'COLORS',50
;               options,nname,'YRANGE',[2e0,1e3]        ; => 2.0 to 1000 Hz
;               options,nname,'ZRANGE',[1e-1,1e3]
;               mxbf = MAX(ABS(rot_shn_bfields[*,j,*]),/NAN)
;               ; => Make component plot have symmetric Y-Axis range about zero
;               options,'Bperp_'+ntime,'YRANGE',[-1e0*mxbf,mxbf]*1.05
;               ; => Fix all TPLOT variables to match output from this PRO
;               nnw = tnames()
;               options,nnw,"YSTYLE",1
;               options,nnw,"PANEL_SIZE",2.
;               options,nnw,'XMINOR',5
;               options,nnw,'XTICKLEN',0.04
;
;  KEYWORDS:    
;               ORDER        :  Set to one of the following values [3,24,6] for the
;                                 order # (i.e. base wavenumber for Morlet) of the
;                                 Morlet wavelet family
;                                 [Default = 6 for Morlet and forced to 4(Paul) 2(DOG)]
;               DSCALE       :  Set to a value (logarithmic units) defining the spacing
;                                 between scale values 
;                                 [Default = 0.125]
;               NSCALE       :  Set to a scalar defining the total # of scales to use
;                                 in constructing the wavelet
;                                 [Default = (ALOG10(N/2)/ALOG10(2))/DSCALE + 1]
;               START_SCALE  :  Set to a scalar value defining the starting scale 
;                                 for the spacing used in constructing the wavelet
;                                 scales.  This is also the smallest scale of the wavelet.
;                                 [Default = 2*sample_period]
;               NEW_NAME     :  Scalar string defining new TPLOT handle to use for 
;                                 wavelet power spectrum
;               KILL_CONE    :  If set, program kills all data outside of the cone of 
;                                 influence determined by wavelet.pro
;               SIGNIF       :  Set to a named variable to output significance 
;                                 levels as a function of PERIOD
;               PERIOD       :  Set to a named variable to output the vector of 
;                                 "Fourier" periods (in time units) that corresponds
;                                 to the SCALEs.
;               FFT_THEOR    :  Set to a named variable to output theoretical 
;                                 background spectrum (smoothed by the wavelet function),
;                                 as a function of PERIOD.
;               MOTHER       :  A scalar string defining the mother wavelet to use.
;                                 Currently, 'Morlet','Paul','DOG' (derivative of 
;                                 Gaussian) are available. 
;                                 [Default = 'Morlet'.]
;               SCALES       :  Set to a named variable to return the wavelet scales
;               CONE         :  Set to a named variable to return the cone of influence
;                                 array
;               CONF_95LEV   :  Set to a named variable to return the 95% confidence
;                                 confidence level to test the significance of the data
;
;=========================================================================================
; Copyright (C) 1995-1998, Christopher Torrence and Gilbert P. Compo,
; University of Colorado, Program in Atmospheric and Oceanic Sciences.
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties whatsoever.
;
; Notice: Please acknowledge the use of the above software in any publications:
;    ``Wavelet software was provided by C. Torrence and G. Compo,
;      and is available at URL: http://paos.colorado.edu/research/wavelets/''.
;
; Reference: Torrence, C. and G. P. Compo, 1998: A Practical Guide to
;            Wavelet Analysis. <I>Bull. Amer. Meteor. Soc.</I>, 79, 61-78.
;
; Please send a copy of such publications to either C. Torrence or G. Compo:
;  Dr. Christopher Torrence               Dr. Gilbert P. Compo
;  Advanced Study Program                 NOAA/CIRES Climate Diagnostics Center
;  National Center for Atmos. Research    Campus Box 216
;  P.O. Box 3000                          University of Colorado
;  Boulder CO 80307--3000, USA.           Boulder CO 80309-0216, USA.
;  E-mail: torrence@ucar.edu              E-mail: gpc@cdc.noaa.gov
;=========================================================================================
;
;   NOTES:
;             1)  It's probably wise to set the KILL_CONE to avoid analysis based upon
;                   artificial data.
;             2)  Note that the input time must be in Unix times but the array of data
;                   can be in any units one wishes
;             3)  Anything over 40,000 points will take a while on most machines so be
;                   patient...
;                    _________________________________________________________________
;                   |Note:  For a Morlet wavelet, scales = 1.03 T, where T = Fourier  |
;                   |        period.                                                  |
;                   |_________________________________________________________________|
;
;   CHANGED:  1)  Added Z-Axis tick label options                 [08/13/2009   v1.0.1]
;             2)  Updated man page                                [09/10/2009   v1.0.2]
;             3)  Corrected frequency calculation to account for the non-equivalent
;                   relationship between Fourier periods and wavelet periods
;                   and added keywords:  SIGNIF, PERIOD, FFT_THEOR, and MOTHER
;                                                                 [09/11/2009   v1.0.3]
;             4)  Changed handling of the ORDER keyword
;                   and added keywords:  SCALES and CONE          [09/11/2009   v1.0.4]
;             5)  Added keyword:  CONF_95LEV
;                   and now program sends COI and 95% CL to TPLOT [09/13/2009   v1.0.5]
;             6)  Changed some minor syntax [no functionality changes]
;                                                                 [10/01/2009   v1.0.6]
;             7)  Changed program called when using a Morlet wavelet to wavelet2d.pro
;                   for faster calculations                       [12/07/2009   v1.1.0]
;             8)  When arrays get too large, the 2D vectorized method runs into issues
;                   with memory, so it will not be used           [12/08/2009   v1.1.1]
;             9)  Now routine returns physical units [e.g. units^2/Hz]
;                                                                 [05/05/2011   v1.1.2]
;            10)  Changed when program normalizes by N to avoid issues with significance
;                   level calculations                            [05/11/2011   v1.1.3]
;
;   CREATED:  08/12/2009
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  05/11/2011   v1.1.3
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-


Last Modification =>  2011-03-26/01:23:39 UTC
;+
;*****************************************************************************************
;
;  FUNCTION :   wind_3dp_save_file_get.pro
;  PURPOSE  :   Restores and returns IDL save files to user and user can return only
;                 data within a specified time range if memory is an issue.
;
;  CALLED BY:   
;               NA
;
;  CALLS:
;               my_str_date.pro
;               directory_path_check.pro
;               array_where.pro
;
;  REQUIRES:    
;               
;
;  INPUT:
;               NA
;
;  EXAMPLES:    
;               
;
;  KEYWORDS:    
;               DATE    :  [string] 'MMDDYY' [MM=month, DD=day, YY=year]
;               EESA    :  Set to a named variable to return a structure with all
;                            EESA structures relevant to date of interest
;               PESA    :  Set to a named variable to return a structure with all
;                            EESA structures relevant to date of interest
;               SSTF    :  Set to a named variable to return a structure with all
;                            SST Foil structures relevant to date of interest
;               SSTO    :  Set to a named variable to return a structure with all
;                            SST Open structures relevant to date of interest
;               TRANGE  :  [Double] 2 element array specifying the time range for
;                            the data you wish to return [Unix time]
;
;   CHANGED:  1)  NA [MM/DD/YYYY   v1.0.0]
;
;   NOTES:      
;               
;
;   CREATED:  03/25/2011
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  03/25/2011   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-


Last Modification =>  2009-10-08/15:09:35 UTC
;+
;*****************************************************************************************
;
;  FUNCTION :   wind_3dp_units.pro
;  PURPOSE  :   Creates a structure containing all the relevant Wind/3DP particle
;                 data unit formats/names.  The program returns both all the of the
;                 names and an optional desired name.
;
;  CALLED BY:   
;               write_padspec_ascii.pro
;
;  CALLS:
;               NA
;
;  REQUIRES:    
;               NA
;
;  INPUT:
;               UNITS   :  Scalar string associated with a specific Wind/3DP unit name
;                            1)  'counts' = # of registered counts in the detector
;                            2)  'flux'   = number flux
;                            3)  'eflux'  = energy flux
;                            4)  'e2flux' = energy-squared flux
;                            5)  'e3flux' = energy-cubed flux
;                            6)  'df'     = distribution function (phase-space density)
;                            7)  'rate'   = effectively counts per integration time
;                            8)  'crate'  = count rate ? (similar to rate, see:
;                                             convert_esa_units.pro etc. )
;
;  EXAMPLES:    
;               unstr = wind_3dp_units()
;
;  KEYWORDS:    
;               SEARCH  :  If set, program assumes that the input UNITS is NOT
;                            simply a string matching a possible unit string, rather
;                            a concatenated mess of strings that has a possible
;                            unit string embedded within
;
;   CHANGED:  1)  Added the keyword:  SEARCH                   [10/08/2008   v1.1.0]
;
;   NOTES:      
;               ..................................................................
;               : {Let [ ] imply the units of whatever is contained in brackets} :
;               ..................................................................
;               1) [flux]   = # per area per time per solid angle per energy
;               1) [eflux]  = energy * [flux]
;               1) [e2flux] = (energy * energy) * [flux]
;               1) [e3flux] = (energy * energy * energy) * [flux]
;               1) [df]     = # per volume per momentum-cubed
;               1) [rate]   = # per integration time
;               1) [crate]  = # per scaled integration time
;
;   CREATED:  09/19/2009
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  10/08/2008   v1.1.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-


Last Modification =>  2010-02-25/20:20:32 UTC
;+
;*****************************************************************************************
;
;  FUNCTION :   write_padspec_ascii.pro
;  PURPOSE  :   Creates an ASCII file associated with any given pitch-angle (PA)
;                 spectra you desire from the 3DP instruments.  The files are 
;                 printed with repeating time values because of the 3-D input 
;                 array format.  So each row is the data and energy bin values
;                 for every PA at a given time.  Thus if one has 15 PA's, then
;                 the first 15 rows will represent data at a single time stamp
;                 but at different PA's.  The column represents the data in each
;                 energy bin, row is the PA, and every 15 rows (in this example)
;                 a new time step occurs.  The last columns are the energy bin
;                 values determined by the routine, dat_3dp_energy_bins.pro.
;                 This program is useful for loading large time periods with 
;                 a lot of 3DP moments because it allows one to create ASCII files
;                 which don't require WindLib to run, thus saving on RAM and time.
;                 The output is the same result one might get from the routine
;                 get_padspecs.pro.  The only thing done to the data is 
;                 a separation into PA's and unit conversion to flux from counts.
;
;  CALLED BY:   NA
;
;  CALLS:
;               dat_3dp_str_names.pro
;               wind_3dp_units.pro
;               get_padspecs.pro
;               energy_params_3dp.pro
;               get_data.pro
;               dat_3dp_energy_bins.pro
;               my_3dp_plot_labels.pro
;
;  REQUIRES:    
;               Wind 3DP AND magnetic field data MUST be loaded first
;
;  INPUT:
;               NAME     :  [string] Specify the type of structure you wish to 
;                             get the data for [i.e. 'el','eh','elb',etc.]
;
;  EXAMPLES:    
;               ...................................................
;               : Produce energy flux spectra with 8 pitch-angles :
;               ...................................................
;               write_padspec_ascii,'sf',TRANGE=trange,BSOURCE='wi_B3(GSE)',NUM_PA=8L
;                                        UNITS='eflux'
;
;  KEYWORDS:  
;               EBINS    :  [array,scalar] specifying which energy bins to create 
;                             particle spectra plots for
;               VSW      :  [string,tplot index] specifying a solar wind velocity
;               TRANGE   :  [Double] 2 element array specifying the range over 
;                             which to get data structures [Unix time]
;               NUM_PA   :  Number of pitch-angles to sum over (Default = 8L)
;               DAT_ARR  :  N-Element array of data structures from get_??.pro
;                              [?? = 'el','eh','elb',etc.]
;               BSOURCE  :  Scalar string associated with TPLOT variable defining the 
;                              relevant magnetic field data to use for calculation of 
;                              pitch-angles
;               UNITS    :  Wind/3DP data units for particle data include:
;                             'df','counts','flux','eflux',etc.
;                              [Default = 'flux']
;               G_MAGF   :  If set, tells program that the structures in DAT_ARR 
;                             already have the magnetic field added to them thus 
;                             preventing this program from calling add_magf2.pro 
;                             again.
;               NO_KILL  :  If set, get_padspecs.pro will NOT call the routine
;                             sst_foil_bad_bins.pro
;
;   CHANGED:  1)  Changed structure formats                       [08/13/2008   v1.0.2]
;             2)  Changed 'man' page                              [09/15/2008   v1.0.3]
;             3)  Updated 'man' page                              [11/11/2008   v1.0.4]
;             4)  Added keyword:  NUM_PA                          [02/25/2009   v1.1.0]
;             5)  Changed program my_str_names.pro to dat_3dp_str_names.pro
;                   and my_3dp_energy_bins.pro to dat_3dp_energy_bins.pro
;                   and my_energy_params.pro to energy_params_3dp.pro
;                   and my_get_padspec_5.pro to get_padspecs.pro
;                   and added keywords:  DAT_ARR, BSOURCE, G_MAGF, and UNITS
;                   and added program:  wind_3dp_units.pro
;                   and renamed from my_padspec_writer.pro        [09/19/2009   v2.0.0]
;             6)  Changed file naming to allow for the units to become part of the 
;                   file name for easier sorting and finding      [09/21/2009   v2.0.1]
;             7)  Added keyword:  NO_KILL                         [02/25/2010   v2.1.0]
;
;   CREATED:  08/12/2008
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  02/25/2010   v2.1.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-


Last Modification =>  2010-11-16/17:21:23 UTC
;+
;*****************************************************************************************
;
;  FUNCTION :   write_shocks_jck_database.pro
;  PURPOSE  :   Creates a formatted ASCII file of containing all the relevant data from
;                 the data base created by Justin C. Kasper at 
;                 http://www.cfa.harvard.edu/shocks/wi_data/
;
;  NOTES:
;               Methods Used by J.C. Kasper:
;                 [See Viñas and Scudder, JGR Vol. 91, pg. 39-58, (1986)]
;                 [and Szabo, JGR Vol. 99, pg. 14,737-14,746, (1994)]
;                 [and Russell et. al., JGR Vol. 88, pg. 9941-9947, (1983)]
;               MC   :  Magnetic Coplanarity    (Viñas and Scudder, [1986])
;               VC   :  Velocity Coplanarity    (Viñas and Scudder, [1986])
;               MX1  :  Mixed Mode Normal 1     (Russell et. al., [1983])
;               MX2  :  Mixed Mode Normal 2     (Russell et. al., [1983])
;               MX3  :  Mixed Mode Normal 3     (Russell et. al., [1983])
;               RH08 :  Rankine-Hugoniot 8 Eqs  (Viñas and Scudder, [1986])
;               RH09 :  Rankine-Hugoniot 8 Eqs  (Viñas and Scudder, [1986])
;               RH10 :  Rankine-Hugoniot 10 Eqs (Viñas and Scudder, [1986])
;               
;               Shock Speed :  Shock velocity dotted into the normal vector
;                                 [ = |Vsh \dot norm| ]
;               Flow Speed  :  |Vsw \dot norm| - |Vsh \dot norm| = dV (on JCK's site)
;               Compression Ratio   :  Downstream density over Upstream density
;               Shock Normal Angle  :  Theta_Bn = ArcCos( (B \dot norm)/|B|)
;
;  CALLED BY:   NA
;
;  CALLS:
;               read_write_jck_database.pro
;               my_time_string.pro
;
;  REQUIRES:    
;               ASCII files of source code (see my_jck_database_read_write.pro)
;
;  INPUT:       NA
;
;  EXAMPLES:    NA
;
;  KEYWORDS:    NA
;
;   CHANGED:  1)  Fixed dates so they have the format of YYYY-MM-DD [04/06/2009   v1.0.1]
;             2)  Initially forgot Wind location                    [04/07/2009   v1.0.2]
;             3)  Added notes to explain the definition of vars.    [04/07/2009   v1.0.3]
;             4)  Changed HTML file locations, thus the search syntax changed
;                   and changed program my_jck_database_read_write.pro 
;                   to read_write_jck_database.pro and renamed from 
;                   my_all_shocks_write.pro to write_shocks_jck_database.pro
;                                                                   [09/16/2009   v2.0.0]
;             5)  Changed output format                             [11/16/2010   v2.1.0]
;
;   NOTES:      
;               1)  Initialize the IDL directories with start_umn_3dp.pro prior
;                     to use.
;
;   CREATED:  04/04/2009
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  11/16/2010   v2.1.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-


Last Modification =>  2009-10-07/22:15:24 UTC
;+
;*****************************************************************************************
;
;  FUNCTION :   ytitle_tplot.pro
;  PURPOSE  :   Returns either the set Y-Axis title for the given input TPLOT handle
;                 or alters the predefined TPLOT handle Y-Title by adding a
;                 desired string onto the end of the original.
;
;  CALLED BY:   
;               energy_remove_split.pro
;               clean_spec_spikes.pro
;               spec_2dim_shift.pro
;               spec_3dim_shift.pro
;
;  CALLS:
;               tnames.pro
;               get_data.pro
;
;  REQUIRES:    
;               NA
;
;  INPUT:
;               NAME     :  Scalar string specifying the TPLOT handle for which one
;                             wants to find or alter the corresponding Y-Title
;
;  EXAMPLES:    
;               NA
;
;  KEYWORDS:    
;               EX_STR   :  Scalar or array of strings to add onto the existing Y-Axis
;                             title.  If EX_STR is a 2-element array, then the end 
;                             result will be:  
;                                  yttl0 = dat.YTITLE
;                                  yttl1 = yttl0+'!C'+ex_str[0]+'!C'+ex_str[1]
;               PRE_STR  :  Scalar string to add as prefix to existing Y-Title
;                             [Note:  No '!C' is added]
;
;   CHANGED:  1)  NA [MM/DD/YYYY   v1.0.0]
;
;   NOTES:      
;               1)  Be careful NOT to add too much onto the Y-Axis title if using
;                     the EX_STR keyword.  Doing so may negatively alter margins
;                     or produce outputs without Y-Axis titles.
;
;   CREATED:  10/07/2008
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  10/07/2008   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-


Last Modification =>  2009-10-29/22:49:35 UTC
;+
;*****************************************************************************************
;
;  FUNCTION :   zero_crossings.pro
;  PURPOSE  :   This program attempts to count zero-crossings of an input array of DATA
;                 which is presumably some sort of semi-periodic function of input time
;                 array, TIMES.  The program returns the calculated/estimated frequency
;                 from the zero-crossings, the number of zero-crossings, and the 
;                 indices of those zero-crossings.
;
;  CALLED BY:   
;               NA
;
;  CALLS:
;               NA
;
;  REQUIRES:    
;               NA
;
;  INPUT:
;               TIMES   :  N-Element array of times associated with DATA
;               DATA    :  N-Element array of data that presumably fluctuates about zero
;
;  EXAMPLES:    
;               NA
;
;  KEYWORDS:    
;               THRESH  :  Scalar percentage of the maximum absolute value of the input
;                            DATA you wish to consider as a threshold deviation from
;                            zero before considering the change a "zero-crossing"
;               NOMSSG  :  If set, the program will NOT print out a message about the
;                            variables in the program.
;
;   CHANGED:  1)  Added keyword:  THRESH                          [09/17/2009   v1.0.1]
;             2)  Changed order of input so TIMES is first        [09/17/2009   v1.0.2]
;             3)  Changed a lot of things                         [09/17/2009   v1.1.0]
;             4)  Fixed typo                                      [09/18/2009   v1.1.1]
;             5)  Changed GOTO statement to avoid infinite loop if thresh = 0.25 wasn't
;                   large enough                                  [10/29/2009   v1.2.0]
;
;   NOTES:      
;               1)  This program is a direct adaptation of a subset of the routine
;                     thresh_lff.pro version 0.1.0 by K. Kersten.  The original
;                     program was embedded in a SWAVES TDS rountine.  This is an
;                     attempt to generalize the small zero-crossing counting aspect
;                     of that larger program for use outside of the SWAVES TDS
;                     routine, thresh_lff.pro.
;               2)  Though it is NOT necessary to have your TIMES input array in any
;                     particular set of units, one should be careful to note that the
;                     output frequency will change depending on the input units, of
;                     course.
;
;   CREATED:  09/16/2009
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  10/29/2009   v1.2.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-



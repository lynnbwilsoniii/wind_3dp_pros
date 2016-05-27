Last Modification =>  2008-06-23/22:24:02 UTC
;+
;PROCEDURE:  add_bdir,dat,source
;PURPOSE:
;    Adds magnetic field direction [theta,phi] to a 3d structure
;    The new structure element will be a two element vector [theta,phi]
;    with the tag name 'bdir'.
;INPUT:
;    dat:   3D data structure        (i.e. from 'GET_EL')
;    [source] : String index that points to magnetic field data.
;Notes:
;    	Magnetic field data must be loaded first.  
;	See 'GET_MFI'
;-


Last Modification =>  2009-06-21/23:18:35 UTC
;+
;*****************************************************************************************
;
;  FUNCTION :   cart_to_sphere.pro
;  PURPOSE  :   Transforms from cartesian to spherical coordinates.
;
;  CALLED BY: 
;               xyz_to_polar.pro
;               add_df2dp.pro
;               add_df2d_to_ph.pro
;
;  CALLS:       NA
;
;  REQUIRES:    NA
;
;  INPUT:
;               X            :  N-Element array of cartesian X-component data points
;               Y            :  N-Element array of cartesian Y-component data points
;               Z            :  N-Element array of cartesian Z-component data points
;               R            :  Named variable to return the radial magnitudes in 
;                                 spherical coordinates
;               THETA        :  Named variable to return the poloidal angles (deg)
;               PHI          :  Named variable to return the azimuthal angles (deg)
;
;  EXAMPLES:
;
;  KEYWORDS:  
;               PH_0_360     :  IF > 0, 0 <= PHI <= 360
;                               IF = 0, -180 <= PHI <= 180
;                               IF < 0, ***if negative, best guess phi range returned***
;               PH_HIST      :  2-Element array of max and min values for PHI
;                                 [e.g. IF PH_0_360 NOT set and PH_HIST=[-220,220] THEN
;                                   if d(PHI)/dt is positive near 180, then
;                                   PHI => PHI+360 when PHI passes the 180/-180 
;                                   discontinuity until phi reaches 220.]
;               CO_LATITUDE  :  If set, THETA returned between 0.0 and 180.0 degrees
;               MIN_VALUE    :  ? Not really sure ?
;               MAX_VALUE    :  ? Not really sure ?
;
;   CHANGED:  1)  Davin Larson changed something...       [04/17/2002   v1.0.13]
;             2)  Re-wrote and cleaned up                 [06/21/2009   v1.1.0]
;
;   CREATED:  ??/??/????
;   CREATED BY:  Davin Larson
;    LAST MODIFIED:  06/21/2009   v1.1.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-


Last Modification =>  2009-08-05/12:17:45 UTC
;+
;*****************************************************************************************
;
;  FUNCTION :   conv_units.pro
;  PURPOSE  :   This is a wrapping program for the unit conversion programs for Wind
;                 3DP particle distribution structures.
;
;  CALLED BY: 
;               plot3d.pro
;               add_df2dp.pro
;               mom_sum.pro
;               moments_3d.pro
;
;  CALLS:
;               convert_esa_units.pro
;               convert_ph_units.pro
;               convert_sf_units.pro
;               convert_so_units.pro
;               convert_sst_units.pro
;
;  REQUIRES:    NA
;
;  INPUT:
;               DATA      :  A 3DP data structure returned by get_??.pro
;               UNITS     :  A scalar string defining the units to convert to
;                              One of the following are allowed:
;                              1)  'counts'  ; => # per data bin per energy bin
;                              2)  'rate'    ; => (s)
;                              3)  'crate'   ; => (s) scaled rate
;                              4)  'eflux'   ; => energy flux
;                              5)  'flux'    ; => number flux
;                              6)  'df'      ; => distribution function units
;
;  EXAMPLES:    NA
;
;  KEYWORDS:  
;               SCALE     :  Set to a named variable to return the conversion factor
;                              array used to scale the data
;
;   CHANGED:  1)  Davin Larson changed something...       [??/??/????   v1.0.?]
;             2)  Re-wrote and cleaned up                 [06/22/2009   v1.1.0]
;             3)  Fixed syntax issue if data is an array of structures
;                                                         [08/05/2009   v1.1.1]
;
;   CREATED:  ??/??/????
;   CREATED BY:  Davin Larson
;    LAST MODIFIED:  08/05/2009   v1.1.1
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-


Last Modification =>  2009-09-19/20:09:46 UTC
;+
;*****************************************************************************************
;
;  FUNCTION :   convert_esa_units.pro
;  PURPOSE  :   Converts the units of the data array of Eesa data structures.  The data
;                 associated with data.DATA is rescaled to the new units and
;                 data.UNITS_NAME is changed to the appropriate units.
;
;  CALLED BY: 
;               conv_units.pro
;
;  CALLS:
;               convert_flux_units.pro
;
;  REQUIRES:    NA
;
;  INPUT:
;               DATA      :  A 3DP data structure returned by get_e?.pro
;               UNITS     :  A scalar string defining the units to convert to
;                              One of the following are allowed:
;                              1)  'counts'  ; => # per data bin per energy bin
;                              2)  'rate'    ; => [s^(-1)]
;                              3)  'crate'   ; => [s^(-1)] scaled rate
;                              4)  'eflux'   ; => energy flux
;                              5)  'flux'    ; => number flux
;                              6)  'df'      ; => distribution function units
;
;  EXAMPLES:    NA
;
;  KEYWORDS:  
;               SCALE     :  Set to a named variable to return the conversion factor
;                              array used to scale the data
;
;   CHANGED:  1)  Davin Larson changed something...       [??/??/????   v1.0.?]
;             2)  Re-wrote and cleaned up                 [06/22/2009   v1.1.0]
;             3)  Added error handling for unit conversion to E2FLUX or E3FLUX etc.
;                   which is not handled by convert_flux_units.pro
;                                                         [07/30/2009   v1.1.1]
;             4)  Updated 'man' page
;                   and fixed syntax issue if data is an array of structures
;                                                         [09/19/2009   v1.2.0]
;
;   CREATED:  ??/??/????
;   CREATED BY:  Davin Larson
;    LAST MODIFIED:  09/19/2009   v1.2.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-


Last Modification =>  2009-08-06/00:05:44 UTC
;+
;*****************************************************************************************
;
;  FUNCTION :   convert_flux_units.pro
;  PURPOSE  :   Converts the units of the data array of Eesa data structures.  The data
;                 associated with data.DATA is rescaled to the new units and
;                 data.UNITS_NAME is changed to the appropriate units.
;
;  CALLED BY: 
;               convert_esa_units.pro
;
;  CALLS:       NA
;
;  REQUIRES:    NA
;
;  INPUT:
;               DATA      :  A 3DP data structure returned by get_??.pro 
;               UNITS     :  A scalar string defining the units to convert to
;                              One of the following are allowed:
;                              1)  'eflux'   ; => energy flux
;                              2)  'flux'    ; => number flux
;                              3)  'df'      ; => distribution function units
;
;  EXAMPLES:    NA
;
;  KEYWORDS:  
;               SCALE     :  Set to a named variable to return the conversion factor
;                              array used to scale the data
;
;   CHANGED:  1)  Davin Larson changed something...       [??/??/????   v1.0.?]
;             2)  Re-wrote and cleaned up                 [06/22/2009   v1.1.0]
;             3)  Fixed syntax issue if data is an array of structures
;                                                         [08/05/2009   v1.1.1]
;
;   CREATED:  ??/??/????
;   CREATED BY:  Davin Larson
;    LAST MODIFIED:  08/05/2009   v1.1.1
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-


Last Modification =>  2009-08-25/22:36:18 UTC
;+
;*****************************************************************************************
;
;  FUNCTION :   convert_ph_units.pro
;  PURPOSE  :   Converts the units of the data array of ph data structures.  The data
;                 associated with data.DATA is rescaled to the new units and
;                 data.UNITS_NAME is changed to the appropriate units.
;
;  CALLED BY:   NA
;
;  CALLS:
;               str_element.pro
;
;  COMMON BLOCKS: 
;               get_ph_com.pro
;
;  REQUIRES:    NA
;
;  INPUT:
;               DATA      :  A ph data structure returned by get_ph.pro
;               UNITS     :  A scalar string defining the units to convert to
;                              One of the following are allowed:
;                              1)  'counts'  ; => # per data bin per energy bin
;                              2)  'rate'    ; => (s)
;                              3)  'crate'   ; => (s) scaled rate
;                              4)  'eflux'   ; => energy flux
;                              5)  'flux'    ; => number flux
;                              6)  'df'      ; => distribution function units
;
;  EXAMPLES:
;               ph = get_ph(t[0])
;               convert_ph_units,ph,'eflux'  ; => Convert to energy flux units
;
;  KEYWORDS:  
;               DEADTIME  :  A double specifying a "deadtime" (the interval during
;                              which a channel plate detector is turned off to 
;                              record an event)  [Default = 1d-6]
;               SCALE     :  Set to a named variable to return the conversion factor
;                              array used to scale the data
;
;   CHANGED:  1)  Frank Marcoline changed something...    [04/21/1997   v1.0.1]
;             2)  Re-wrote and cleaned up                 [06/21/2009   v1.1.0]
;             3)  Fixed a syntax error                    [06/24/2009   v1.1.1]
;             4)  Fixed syntax issue if data is an array of structures
;                                                         [08/25/2009   v1.1.2]
;
;   ADAPTED FROM:  other convert_*_units.pro procedures
;   CREATED:  ??/??/????
;   CREATED BY:  Frank Marcoline
;    LAST MODIFIED:  08/25/2009   v1.1.2
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-


Last Modification =>  2009-08-05/12:27:59 UTC
;+
;*****************************************************************************************
;
;  FUNCTION :   convert_sf_units.pro
;  PURPOSE  :   Converts units of data from the SST-Foil instrument of the Wind/3DP
;                 particle detector suite.
;
;  CALLED BY: 
;               conv_units.pro
;
;  CALLS:
;               convert_flux_units.pro
;
;  REQUIRES:    NA
;
;  INPUT:
;               DATA      :  A 3DP data structure returned by get_sf.pro
;               UNITS     :  A scalar string defining the units to convert to
;                              One of the following are allowed:
;                              1)  'counts'  ; => # per data bin per energy bin
;                              2)  'rate'    ; => (s)
;                              3)  'crate'   ; => (s) scaled rate
;                              4)  'eflux'   ; => energy flux
;                              5)  'uflux'   ; => number flux
;                              6)  'flux'    ; => number flux (w/ efficiency)
;                              7)  'df'      ; => distribution function units
;
;  EXAMPLES:    NA
;
;  KEYWORDS:  
;               SCALE     :  Set to a named variable to return the conversion factor
;                              array used to scale the data
;
;   CHANGED:  1)  Davin Larson changed something...       [??/??/????   v1.0.?]
;             2)  Re-wrote and cleaned up                 [06/22/2009   v1.1.0]
;             3)  Fixed syntax issue if data is an array of structures
;                                                         [08/05/2009   v1.1.1]
;
;   CREATED:  ??/??/????
;   CREATED BY:  Davin Larson
;    LAST MODIFIED:  08/05/2009   v1.1.1
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-


Last Modification =>  2009-08-05/12:28:01 UTC
;+
;*****************************************************************************************
;
;  FUNCTION :   convert_so_units.pro
;  PURPOSE  :   Converts units of data from the SST-Open instrument of the Wind/3DP
;                 particle detector suite.
;
;  CALLED BY: 
;               conv_units.pro
;
;  CALLS:
;               convert_flux_units.pro
;
;  REQUIRES:    NA
;
;  INPUT:
;               DATA      :  A 3DP data structure returned by get_so.pro
;               UNITS     :  A scalar string defining the units to convert to
;                              One of the following are allowed:
;                              1)  'counts'  ; => # per data bin per energy bin
;                              2)  'rate'    ; => (s)
;                              3)  'crate'   ; => (s) scaled rate
;                              4)  'eflux'   ; => energy flux
;                              5)  'flux'    ; => number flux 
;                              6)  'df'      ; => distribution function units
;
;  EXAMPLES:    NA
;
;  KEYWORDS:  
;               SCALE     :  Set to a named variable to return the conversion factor
;                              array used to scale the data
;
;   CHANGED:  1)  Davin Larson changed something...       [??/??/????   v1.0.?]
;             2)  Re-wrote and cleaned up                 [06/22/2009   v1.1.0]
;             3)  Fixed syntax issue if data is an array of structures
;                                                         [08/05/2009   v1.1.1]
;
;   CREATED:  ??/??/????
;   CREATED BY:  Davin Larson
;    LAST MODIFIED:  08/05/2009   v1.1.1
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-


Last Modification =>  2009-06-22/13:51:59 UTC
;+
;*****************************************************************************************
;
;  FUNCTION :   convert_sst_units.pro
;  PURPOSE  :   Converts data units for data from the SST instruments.
;
;  CALLED BY: 
;               conv_units.pro
;
;  CALLS:       NA
;
;  REQUIRES:    NA
;
;  INPUT:
;               DATA      :  A 3DP data structure returned by get_??.pro
;               UNITS     :  A scalar string defining the units to convert to
;                              One of the following are allowed:
;                              1)  'counts'  ; => # per data bin per energy bin
;                              2)  'ncounts' ; => related to geometry factor
;                              3)  'rate'    ; => (s)
;                              4)  'nrate'   ; => (s) scaled rate
;                              5)  'eflux'   ; => energy flux
;                              6)  'flux'    ; => number flux
;                              7)  'fluxe'   ; => number flux efficiency
;                              8)  'df'      ; => distribution function units
;
;  EXAMPLES:    NA
;
;  KEYWORDS:  
;               SCALE     :  Set to a named variable to return the conversion factor
;                              array used to scale the data
;
;  NOTES:
;               There are two structure tag names in this routine which I cannot
;                 find anywhere in the 3DP TPLOT software (GEOM and EFF) which may
;                 be simply typos.  Regardless, this program will NOT work unless
;                 those are added to the structure before running.
;
;   CHANGED:  1)  Davin Larson changed something...       [08/22/1996   v1.0.10]
;             2)  Re-wrote and cleaned up                 [06/22/2009   v1.1.0]
;
;   CREATED:  ??/??/1995
;   CREATED BY:  Davin Larson
;    LAST MODIFIED:  06/22/2009   v1.1.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-


Last Modification =>  2009-08-26/01:10:33 UTC
;+
;*****************************************************************************************
;
;  FUNCTION :   transform_velocity.pro
;  PURPOSE  :   Transforms arrays of velocities (theta's and phi's) by subtracting off
;                 an input velocity (deltav)
;
;  CALLED BY: 
;               convert_vframe.pro
;
;  CALLS:       NA
;
;  REQUIRES:    NA
;
;  INPUT:
;               MVEL      :  Array of velocity magnitudes (km/s)
;               THETA     :  Array of theta (deg) values
;               PHI       :  Array of phi (deg) values
;               DELTAV    :  [vx,vy,vz]  (transformation velocity, km/s)
;
;  EXAMPLES:
;               transform_velocity,vel,theta, phi,deltav
;
;  KEYWORDS:  
;               V[X,Y,Z]  :  Returns the transformed velocity in each direction (km/s)
;
;   CHANGED:  1)  NA                    [09/19/2008   v1.0.11]
;             2)  Updated man page      [03/20/2009   v1.0.12]
;             3)  Updated man page      [06/21/2009   v1.0.13]
;
;   CREATED:  ??/??/????
;   CREATED BY:  Davin Larson
;    LAST MODIFIED:  06/21/2009   v1.0.13
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-
;+
;*****************************************************************************************
;
;  FUNCTION :   convert_vframe.pro
;  PURPOSE  :   Takes a 3DP data structure and recalculates the relevant parameters after
;                 transforming into another reference frame defined by the input
;                 velocity supplied by the user.  The returned structure is in units of 
;                 distribution function (DF) which are (s^3 cm^-3 km^-3).
;
;  CALLED BY:   NA
;
;  CALLS:
;               conv_units.pro
;               str_element.pro
;               dat_3dp_energy_bins.pro
;               velocity.pro
;               transform_velocity.pro
;               interp.pro
;
;  REQUIRES:    NA
;
;  INPUT:
;               TDATA        :  A 3D data structure
;               VFRAME       :  A vector [Vx,Vy,Vz] for the Solar Wind velocity (km/s)
;
;  EXAMPLES:
;               el_str  = my_convert_vframe(ael,vsw,/INTERP)
;
;  KEYWORDS:  
;               EVALUES      :  An array of energy bin values (eV)
;               E_SHIFT      :  Amount of energy to shift data by (eV)
;               SC_POT       :  Estimate of spacecraft potential (eV)
;               INTERPOLATE  :  If set, data is interpolated at structure times
;                                 and at original energy estimates
;               EXTRAPOLATE  :  If set, data is extrapolated below min EVALUES
;               ETHRESH      :  Threshold energy for interpolation.
;               BINS         :  Data bins to use to calculate derivative of DF
;               DFDV         :  Velocity derivative of DF (averaged)
;
;   CHANGED:  1)  NA                                         [02/11/2001   v1.0.21]
;             2)  Now use my_velocity.pro                    [06/11/2008   v1.1.10]
;             3)  Updated man page                           [03/20/2009   v1.1.11]
;             4)  Changed keyword INTERP to INTERPO to avoid syntax errors
;                                                            [04/13/2009   v1.1.12]
;             5)  Updated man page                           [06/21/2009   v1.0.13]
;             6)  Fixed syntax error produced when re-writing program and
;                  now calls program:  dat_3dp_energy_bins.pro instead of average.pro
;                                                            [08/25/2009   v1.1.0]
;
;   ADAPTED FROM:  convert_vframe.pro    BY: Davin Larson
;   CREATED:  ??/??/????
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  08/25/2009   v1.1.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-


Last Modification =>  2008-06-23/22:24:02 UTC
;+
;FUNCTION:	heatflux
;PURPOSE:	Calulates heatlux from a 3dimensional data structure such as
;		those generated by get_el,get_pl,etc. 
;		e.g. "get_el"
;INPUT:		
;	dat:	A 3d data structure.
;KEYWORDS:
;	esteprange:	the energy step range to use, default is full range
;CREATED BY:	Davin Larson
;LAST MODIFICATION:	@(#)heatflux.pro	1.5 95/10/06
;-


Last Modification =>  2009-09-18/20:43:54 UTC
;+
;*****************************************************************************************
;
;  FUNCTION :   make_3dmap.pro
;  PURPOSE  :   Program returns a 2-dimensional array of bin values that reflect
;                 the 3D mapping.
;
;  CALLED BY: 
;               plot3d.pro
;
;  CALLS:
;               str_element.pro
;
;  REQUIRES:    NA
;
;  INPUT:
;               DAT      :  A 3DP data structure
;               NX       :  X-Dimension of output array
;               NY       :  Y-" "
;
;  EXAMPLES:    NA
;
;  KEYWORDS:  
;               HIGHEST  :  If set, force the highest bin number to prevail for 
;                             overlapping bins.
;
;  NOTES:
;               1)  If there are any overlapping bins, then the lowest bin number 
;                     will win, unless the HIGHEST keyword is set.
;               2)  theta +/- dtheta should be in the range:  -90 to +90 degrees
;
;   CHANGED:  1)  Davin Larson changed something...       [10/22/1999   v1.0.7]
;             2)  Re-wrote and cleaned up                 [06/22/2009   v1.1.0]
;             3)  Fixed typo                              [09/18/2009   v1.1.1]
;
;   CREATED:  02/08/1996
;   CREATED BY:  Davin Larson
;    LAST MODIFIED:  09/18/2009   v1.1.1
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-


Last Modification =>  2008-06-23/22:24:02 UTC
;+
;Program:	mat_diag, p, EIG_VAL= eig_val, EIG_VEC= eig_vec
;INPUT:	
;	p	6-element vector [Pxx, Pyy, Pzz, Pxy, Pxz, Pyz] of a
;		symmetric matrix
;OUTPUT:
;	eig_val, eig_vec
;PURPOSE:
;	Diagonalize a 3x3 symmetric matrix
;	Returns the eigenvalues and eigenvectors.
;	The eigenvalues are the diagnonal elements of the matrix
;	The eigenvectors are the associated principle axis. 
;NOTES:	
;	The first eigenvalue (eig_val(0)) and eigenvector (eig_vec(*,0))
;	are the distinguisheable eigenvalue and the major (symmetry) axis,
;	respectively.  
;	The "degenerate" eigenvalues are sorted such that the 2nd eigenvalue
;	is smaller than the third one.
;CREATED BY:
;	Tai Phan (95-9-15)
;LAST MODIFICATION:
;	95-9-29		Tai Phan
;-


Last Modification =>  2008-06-23/22:24:02 UTC
;+
;FUNCTION:  omni3d
;PURPOSE:  produces an omnidirectional spectrum structure by summing
; over the non-zero bins in the keyword bins.
; this structure can be plotted with "spec3d"
;
;CREATED BY:	Davin Larson
;LAST MODIFICATION:	@(#)omni3d.pro	1.12 02/04/17
;
; WARNING:  This is a very crude structure; use at your own risk.
;-


Last Modification =>  2011-03-03/00:36:23 UTC
;+
;*****************************************************************************************
;
;  FUNCTION :   pad.pro
;  PURPOSE  :   Creates a pitch-angle distribution (PAD) from a 3DP data structure
;                 specifically for use in distfunc.pro
;
;  CALLED BY:   NA
;
;  CALLS:
;               xyz_to_polar.pro
;               dat_3dp_energy_bins.pro
;               pangle.pro
;               pad_template.pro
;               add_magf.pro
;
;  REQUIRES:    NA
;
;  INPUT:
;               DAT    :  A 3d data structure such as those gotten from get_el,
;                           get_pl,etc. [e.g. "get_el"]
;
;  EXAMPLES:
;               pd = pad(el,NUM_PA=17L,ESTEPS=[0L,12L])
;
;  KEYWORDS:  
;               BDIR   :  Add B-field direction
;               MAGF   :  B-field vector to use for PAD calculation (if not already part
;                           dat structure)
;               ESTEPS :  Energy bins to use [2-Element array corresponding to first and
;                           last energy bin element or an array of energy bin elements]
;               BINS   :  Data bins to sum over  {e.g. [2,87] => 3rd to last data bin}
;               NUM_PA :  Number of pitch-angles to sum over (Default = 8L)
;               SPIKES :  If set, tells program to look for data spikes and eliminate them
;
;   CHANGED:  1)  Davin Larson changed something...          [04/17/2002   v1.0.21]
;             2)  Vectorized most of the calculations        [02/10/2008   v1.2.0]
;             3)  Created dummy structures to return when no finite 
;                   data is found [calls my_pad_template.pro]   
;                                                            [03/17/2008   v2.0.0]
;             4)  Forced ONLY positive results to be returned, otherwise 
;                   set to !VALUES.F_NAN                     [04/05/2008   v2.1.0]
;             5)  Fixed indexing issue for ESTEPS keyword  
;                   [calls my_3dp_energy_bins.pro]           [12/08/2008   v2.1.10]
;             6)  Try to correct for data spikes             [01/29/2009   v2.1.11]
;             7)  Added keyword:  SPIKES                     [02/08/2009   v2.1.12]
;             8)  Updated man page                           [06/22/2009   v2.2.0]
;             9)  Fixed syntax error                         [07/13/2009   v2.2.1]
;            10)  Changed called program my_pad_template.pro to pad_template.pro
;                                                            [07/20/2009   v2.2.2]
;            11)  Changed program my_3dp_energy_bins.pro to dat_3dp_energy_bins.pro
;                                                            [08/05/2009   v2.3.0]
;            12)  Fixed syntax error                         [08/05/2009   v2.3.1]
;            13)  Now allows for the use of SST Foil inputs  [09/18/2009   v2.4.0]
;            14)  Changed error message outputs slightly     [03/02/2011   v2.4.1]
;
;   CREATED:  ??/??/????
;   CREATED BY:  Davin Larson
;    LAST MODIFIED:  03/02/2011   v2.4.1
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-


Last Modification =>  2008-06-23/22:24:02 UTC
;+
;PROCEDURE: padplot,pad
;   Plots pad data vs pitch angle.
;INPUTS:
;   pad   - structure containing pitch angle distribution (PAD) data. 
;           (Obtained from "pad()" routine)
;KEYWORDS:
;   LIMITS - limit structure. (see "xlim" , "YLIM" or "OPTIONS")
;      The limit structure can have the following elements:
;      UNITS:  units to be plotted in.
;      ALL PLOT and OPLOT keywords.
;   UNITS  - convert to given data units before plotting
;   MULTI  - Set to the number of plots desired across the page.
;   OPLOT  - Overplots last plot if set.
;   LABEL  - set to print labels for each energy step.
;
;SEE ALSO:	"spec3d"
;
;CREATED BY:	Davin Larson
;LAST MODIFICATION:	@(#)padplot.pro	1.18 09/19/2007
;  Modified By: Lynn B. Wilson III
;
;-


Last Modification =>  2009-06-22/15:18:03 UTC
;+
;*****************************************************************************************
;
;  FUNCTION :   pangle.pro
;  PURPOSE  :   Computes pitch-angle given two sets of theta and phi (first two 
;                 are typically from data and second two from B-field direction) and
;                 returns the pitch-angles with the same dimensions as the input THETA
;                 and PHI.
;
;  CALLED BY: 
;               pad.pro
;               my_pad_dist.pro
;
;  CALLS:
;               xyz_to_polar.pro
;               sphere_to_cart.pro
;
;  REQUIRES:    NA
;
;  INPUT:
;               THETA    :  N-Element array of poloidal angles (deg)
;               PHI      :  N-Element array of azimuthal angles (deg)
;               B_THETA  :  N-Element array of 2nd poloidal angles (deg) with which
;                             to calibrate the first set with
;               B_PHI    :  N-Element array of 2nd azimuthal angles (deg) with which
;                             to calibrate the first set with
;
;  EXAMPLES:
;
;  KEYWORDS:  
;               VEC      :  Set to a 3-element cartesian vector array to calculate the
;                             values for B_THETA and B_PHI
;
;   CHANGED:  1)  Davin Larson changed something...       [11/28/1995   v1.0.4]
;             2)  Re-wrote and cleaned up                 [06/22/2009   v1.1.0]
;
;   CREATED:  ??/??/????
;   CREATED BY:  Davin Larson
;    LAST MODIFIED:  06/22/2009   v1.1.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-


Last Modification =>  2010-11-01/19:36:11 UTC
;+
;*****************************************************************************************
;
;  FUNCTION :   plot3d.pro
;  PURPOSE  :   Creates a series of 3D Map projections (one for each energy step) of the
;                 data structure given by user.
;
;  CALLED BY:   NA
;
;  CALLS:
;               plot3d_com.pro
;               plot3d_options.pro
;               dat_3dp_str_names.pro
;               dat_3dp_energy_bins.pro
;               wind_3dp_units.pro
;               pesa_high_bad_bins.pro
;               sst_foil_bad_bins.pro
;               convert_ph_units.pro
;               conv_units.pro
;               str_element.pro
;               xyz_to_polar.pro
;               dimen1.pro
;               make_3dmap.pro
;               minmax.pro
;               colinear_test.pro
;               bytescale.pro
;               smooth_periodic.pro
;               ndimen.pro
;               time_stamp.pro
;               draw_color_scale.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               DAT        :  A 3DP data structure
;               LATITUDE   :  The latitude of the center of the plot (semi-optional)
;               LONGITUDE  :  The longitude of the center of the plot (semi-optional)
;
;  EXAMPLES:
;               => To plot in Distribution Function units with center along anti-B-Dir.
;               plot3d,dat,BNCENTER=-1,EBINS=LINDGEN(12L),UNITS='df'
;
;  KEYWORDS:  
;               BINS        :  N-Element array of indices defining the data bins to use
;                                for auto-scaling the Z-Range of the plot
;               TBINS       :  Bin totals ??
;               BNCENTER    :  If < 0, latitude,longitude are set so -B direction at
;                                center of plot;  If > 0, then +B at center
;               LABELS      :  If set, alters color labels ??
;               SMOOTH      :  If set, program attempts to smooth over edges by resizing
;                                the data array and rebining the data
;                                [0 = none, 2 is typical]
;               EBINS       :   Energy bins to use [2-Element array corresponding to
;                                first and last energy bin element or an array of 
;                                energy bin elements]
;               SUM_EBINS   :  Specifies how many bins to sum, starting with EBINS.  If
;                                SUM_EBINS is a scaler, that number of bins is summed for
;                                each bin in EBINS.  If SUM_EBINS is an array, then each
;                                array element will hold the number of bins to sum
;                                starting at each bin in EBINS.  In the array case,
;                                EBINS and SUM_EBINS  must have the same number
;                                of elements.
;               PTLIMIT     :  Set to a named variable for returning the plot limits
;                                of the 3D maps
;               PTMAP       :  Set to a 2D array defining the 3D map from the theta's
;                                and phi's of the original data structure
;               MAPNAME     :  One of the following strings: 
;                                'mol', 'cyl', 'ort', 'ait', 'ham','gno', or 'mer'
;                                [See MAP_SET.PRO syntax for more]
;               UNITS       :  [String] Units for data to be plotted in
;                                [Default = 'eflux' or energy flux]
;               SETLIM      :  If set, the program calculates the plot limits of the 
;                                3D maps and returns the limits in the keyword
;                                PTLIMIT
;               PROC3D      :  Set to the name of another program to use for plotting
;                                3D maps of the data
;               ZRANGE      :  2-Element array defining the range of the data values
;               ZERO        :  If set, forces min range of data to zero
;               TITLE       :  String used to override default plot title
;               NOTITLE     :  If set, no plot title is created
;               NOCOLORBAR  :  If set, no color bar is produced
;               NOBORDER    :  If set, supresses the plot border
;               SPIKES      :  If set, tells program to look for data spikes
;                                and eliminate them [Specifically for Eesa High Dists.]
;               ONE_ZRA     :  If set, all maps are set to the same overall data range
;                                [By default, program ranges color bar by overall data
;                                 range, but each plot is scaled to the data in ONLY 
;                                 that plot]
;               EX_VEC      :  3-Element array of an extra vector to output onto the 3D
;                                projection map
;               STACK       :  Set to a 2-Element array defining the 
;                                [# of columns, # of rows] to plot  
;                                {Controls => !P.MULTI[1:2]}
;               ROW_MAJOR   :  If set, the program plots top to bottom, left to right
;                                {Controls => !P.MULTI[4]}
;               NOERASE     :  If set, program will NOT erase plots already existing
;                                in the current window set
;                                {Controls => !P.MULTI[0]}
;               KILL_SMGF   :  If set, not only are the "bad" bins removed from the
;                                SST Foil data structures, the bins with small
;                                geometry factors are removed too 
;                                (see sst_foil_bad_bins.pro)
;
;   CHANGED:  1)  Davin Larson changed something...       [04/17/2002   v1.0.43]
;             2)  Altered a few minor things              [03/11/2008   v1.0.44]
;             3)  Re-wrote and cleaned up                 [03/21/2009   v1.1.0]
;             3)  Fixed a syntax error                    [03/22/2009   v1.1.1]
;             4)  Fixed triangulation issue               [03/22/2009   v1.1.2]
;             5)  Added keyword: SPIKES and program my_str_names.pro
;                                                         [03/22/2009   v1.2.0]
;             6)  Re-wrote program draw_color_scale.pro
;                                                         [03/22/2009   v1.2.1]
;             7)  Updated man page                        [06/21/2009   v1.2.2]
;             8)  Changed program my_3dp_energy_bins.pro to dat_3dp_energy_bins.pro
;                   and my_str_names.pro to dat_3dp_str_names.pro
;                                                         [08/05/2009   v1.3.0]
;             9)  Fixed a syntax error and changed unit conversion for
;                   Pesa High dists.                      [08/31/2009   v1.3.1]
;            10)  Changed X-Margin in plotting routine    
;                   and changed plot titles a little      [09/03/2009   v1.3.2]
;            11)  Added keyword:  ONE_ZRA                 [09/03/2009   v1.4.0]
;            12)  Changed font sizes and X-Margins        [09/24/2009   v1.4.1]
;            13)  Changed functionality of ONE_ZRA and ZRANGE
;                   and fixed missing assignment of ZRANGE_3D from plot3d_com.pro
;                                                         [09/25/2009   v1.4.2]
;            14)  Changed handling of UNITS keyword
;                   and added program:  wind_3dp_units.pro
;                                                         [09/25/2009   v1.5.0]
;            15)  Added keyword:  EX_VEC
;                   and fixed neglected issue with ZRANGE [09/26/2009   v1.6.0]
;            16)  Added program:  sst_foil_bad_bins.pro   [02/13/2010   v1.7.0]
;            17)  Added keyword:  KILL_SMGF               [02/25/2010   v1.8.0]
;            18)  Added error checking for co-linear error in TRIANGULATE.PRO
;                   with program colinear_test.pro [not finished yet...]
;                                                         [03/22/2010   v1.8.1]
;            19)  Fixed issue of plotting sun direction if VSW structure tag set to
;                   REPLICATE(!VALUES.F_NAN,3)            [11/01/2010   v1.8.2]
;
;   NOTES:      
;               1)  By default, program ranges color bar by overall data range,
;                     but each plot is scaled to the data in ONLY that plot.  Each
;                     will change its title if ONE_ZRA not set to allow the user to
;                     determine the relative scale versus the color bar scale.
;               2)  Prior to running program, it is useful to use the following options:
;                    ..........................................................
;                    :plot3d_options,MAP='ham',LOG =1,TRIANGULATE=1,COMPRESS=1:
;                    ..........................................................
;               3)  If sending in Pesa High or SST Foil data structures, don't alter
;                     them prior to input
;
;   CREATED:  ??/??/????
;   CREATED BY:  Davin Larson
;    LAST MODIFIED:  11/01/2010   v1.8.2
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-


Last Modification =>  2008-06-23/22:24:02 UTC
;+
;COMMON BLOCK:	plot3d_com
;PURPOSE:	Common block for "PLOT#D" routines
;CREATED BY:	Davin Larson
;LAST MODIFICATION:	@(#)plot3d_com.pro	1.8 95/11/07
;SEE ALSO:   "PLOT3D" and "PLOT3D_OPTIONS"
;-


Last Modification =>  2009-09-25/17:08:26 UTC
;+
;*****************************************************************************************
;
;  FUNCTION :   plot3d_options.pro
;  PURPOSE  :   This program sets up the default options for the plot3d.pro routine.
;
;  CALLED BY:   
;               plot3d.pro
;
;  CALLS:
;               plot3d_com.pro
;
;  REQUIRES:    
;               NA
;
;  INPUT:
;               NA
;
;  EXAMPLES:    
;              ..........................................................................
;              :=> To use the Hammer-Aitoff equal area projection, a logarithmic        :
;              :     Z-Axis range, triangulation, full map resolution, and              :
;              :     an output with grid lines every 30 degrees both latitudinally and  :
;              :     longitudinally, do the following                                   :
;              ..........................................................................
;               plot3d_options,MAP='ham',LOG =1,TRIANGULATE=1,COMPRESS=1,GRID=[30.,30.]
;
;  KEYWORDS:    
;               MAP          :  Scalar string corresponding to one the 3D map projections
;                                 allowed by the IDL built-in MAP_SET.PRO, which include:
;                                 [Default = 'ait']
;                                 'ait'  :  Aitoff projection
;                                 'cyl'  :  Cylindrical equidistant projection
;                                 'gno'  :  Gnomonic projection
;                                 'ham'  :  Hammer-Aitoff (equal area projection)
;                                 'lam'  :  Lambert's azimuthal equal area projection
;                                 'mer'  :  Mercator projection
;                                 'mol'  :  Mollweide projection
;                                 'ort'  :  Orthographic projection
;               SMOOTH       :  If set, data is rebinned and smoothed
;               GRID         :  2-Element array defining the grid spacing of the lines 
;                                 created by the IDL built-in MAP_GRID.PRO [degrees]
;                                 [Default = [45.,45.] ]
;               LOG          :  If set, color scale is on a log-scale, else linear
;                                 [Default = 0]
;               COMPRESS     :  Scalar integer defining map resolution controlled by the
;                                 COMPRESS keyword in the IDL built-in MAP_IMAGE.PRO
;                                 [Default = 1 which solves the inverse map 
;                                   transformation for every pixel of the output image]
;               TRIANGULATE  :  If set, plot3d.pro will use spherical triangulation
;                                 [Default = 0]
;               LATITUDE     :  Scalar value defining the center latitude of the map
;                                 projection to use as the observed center when plotted
;                                 [Default = 0]
;               LONGITUDE    :  Same as LATITUDE keyword, but for longitude
;                                 [Default = 180]
;               ZRANGE       :  ??
;
;   CHANGED:  1)  Davin Larson changed something...             [09/24/1996   v1.0.10]
;             2)  Fixed syntax with keyword functionalities:  GRID and ZRANGE
;                   and cleaned up and updated Man. page        [09/25/2009   v1.1.0]
;
;   NOTES:      
;               1)  Both LATITUDE and LONGITUDE are in degrees
;
;   CREATED:  ??/??/????
;   CREATED BY:  Davin Larson
;    LAST MODIFIED:  09/25/2009   v1.1.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-


Last Modification =>  2008-06-23/22:24:02 UTC
;+
;PROCEDURE: scat_plot, xname, yname
;PURPOSE:
;   Produces a scatter plot of selected tplot variables.
;   Colors are scaled according to zname, if present
;INPUTS:
;   xname:    xvariable name
;   yname:    yvariable name
;   zname:    if present, color variable name
;KEYWORDS:
;       TRANGE:  two element vector giving start and end time.
;   limits:     a structure with plotting keywords
;   begin_time:   time at which to start plot
;   end_time: time at which to end plot
;
;CREATED BY:    Davin Larson
;LAST MODIFICATION: @(#)scat_plot.pro   1.13 02/04/17
;-


Last Modification =>  2009-09-25/16:54:36 UTC
;+
;*****************************************************************************************
;
;  FUNCTION :   enlarge_periodic.pro
;  PURPOSE  :   Enlarges a 2D matrix by N-elements on each side assuming spherical
;                 boundary conditions.
;
;  CALLED BY:   
;               smooth_periodic.pro
;
;  CALLS:
;               NA
;
;  REQUIRES:    
;               NA
;
;  INPUT:
;               ORIG_IMAGE  :  2-Dimensional Matrix on the surface of a sphere to be
;                                enlarged
;               N           :  Scalar defining the number of elements to enlarge
;                                ORIG_IMAGE by on each side
;
;  EXAMPLES:    
;               NA
;
;  KEYWORDS:    
;               NA
;
;   CHANGED:  1)  Davin Larson changed something...             [10/04/1995   v1.0.5]
;             2)  Re-wrote and cleaned up
;                   and removed dependence on dimen.pro and data_type.pro
;                                                               [09/25/2009   v1.1.0]
;
;   NOTES:      
;               1)  This should not be called by user
;
;   CREATED:  ??/??/????
;   CREATED BY:  Davin Larson
;    LAST MODIFIED:  09/25/2009   v1.1.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-
;+
;*****************************************************************************************
;
;  FUNCTION :   smooth_periodic.pro
;  PURPOSE  :   Uses box car smoothing of a surface with sperical periodic boundary
;                 conditions.
;
;  CALLED BY:   
;               plot3d.pro
;
;  CALLS:
;               enlarge_periodic.pro
;
;  REQUIRES:    
;               NA
;
;  INPUT:
;               OLD_IMAGE   :  2-Dimensional Matrix on the surface of a sphere to be
;                                smoothed
;               N           :  Scalar defining the size of boxcar averaging window
;
;  EXAMPLES:    
;               
;
;  KEYWORDS:    
;               NA
;
;   CHANGED:  1)  Davin Larson changed something...             [10/04/1995   v1.0.5]
;             2)  Re-wrote and cleaned up
;                   and removed dependence on dimen.pro
;                   and added NAN and EDGE_TRUNCATE keywords to SMOOTH.PRO call
;                                                               [09/25/2009   v1.1.0]
;
;   NOTES:      
;               
;
;   CREATED:  ??/??/????
;   CREATED BY:  Davin Larson
;    LAST MODIFIED:  09/25/2009   v1.1.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-


Last Modification =>  2010-11-01/20:04:38 UTC
;+
;*****************************************************************************************
;
;  FUNCTION :   spec3d.pro
;  PURPOSE  :   Plots the energy spectra for each data bin in a 3DP structure.
;
;  CALLED BY:   
;               NA
;
;  CALLS:
;               
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               TEMPDAT     :  A 3DP data structure from get_??.pro
;
;  EXAMPLES:    
;               
;
;  KEYWORDS:    
;               LIMITS      :  A structure that may contain any combination of the 
;                                following elements:
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
;               UNITS       :  [String] Units for data to be plotted in
;                                [Default = 'eflux' or energy flux]
;               COLOR       :  Set to a named variable to return the colors shown in plot
;               BDIR        :  Obselete
;               PHI         :  Set to a named variable to return the azimuthal angles
;                                used in plot
;               THETA       :  Set to a named variable to return the poloidal angles
;                                used in plot
;               PITCHANGLE  :  If set, color scale defined by angles closest to
;                                B-field direction
;               VECTOR      :  3-Element array specifying the vector to define the color
;                                scale
;               SUNDIR      :  If set, program defines VECTOR as the sun direction
;               A_COLOR     :  ??
;               LABEL       :  If set, plot shows bin labels
;               X[Y]DAT     :  
;               DYDAT       :  
;               BINS        :  N-Element array of data bins to be plotted
;               VELOCITY    :  If set, X-axis is in units of km/s instead of eV
;               OVERPLOT    :  If set, plots over existing plot
;
;   CHANGED:  1)  Davin Larson changed something...       [06/??/1995   v1.0.24]
;             2)  Altered a few minor things              [07/23/2007   v1.0.25]
;             3)  Re-wrote and cleaned up                 [11/01/2010   v1.1.0]
;
;   NOTES:      
;               
;
;   CREATED:  ??/??/????
;   CREATED BY:  Davin Larson
;    LAST MODIFIED:  11/01/2010   v1.1.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-


Last Modification =>  2009-09-14/21:59:04 UTC
;+
;*****************************************************************************************
;
;  FUNCTION :   specplot.pro
;  PURPOSE  :   Creates a spectrogram plot from given input.  User defines axes
;                 labels and positions in the keyword LIMITS.
;
;  CALLED BY: 
;               tplot.pro
;
;  CALLS:
;               extract_tags.pro
;               str_element.pro
;               makegap.pro
;               dimen.pro
;               specplot.pro
;               minmax.pro
;               interp.pro
;               dimen2.pro
;               bytescale.pro
;               box.pro
;               draw_color_scale.pro
;
;  REQUIRES:    NA
;
;  INPUT:
;               X :  X-axis values => Dimension N.
;               Y :  Y-axis values => Dimension M.  (Future update will allow (N,M))
;               Z :  Color axis values:  Dimension (N,M).
;
;  EXAMPLES:
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
;               DATE          :  [string] 'MMDDYY'
;               TIME          :  [string] ['HH:MM:SS.xxx'] associated with time of 
;                                  TDS event
;               PS_RESOLUTION :  Post Script resolution.  Default is 60.
;               COLOR_POS     :  Same as output of plot positions, but this specifies
;                                  the position(s) of the color bar(s) [normalized
;                                  coords.] => Define as a named variable to be
;                                  returned by program {see: my_plot_positions.pro}
;               NO_INTERP     :  If set, do no x or y interpolation.
;               X_NO_INTERP   :  Prevents interpolation along the x-axis.
;               Y_NO_INTERP   :  Prevents interpolation along the y-axis.
;               OVERPLOT      :  If non-zero, then data is plotted over last plot.
;               OVERLAY       :  If non-zero, then data is plotted on top of data 
;                                  from last plot.
;               IGNORE_NAN    :  If non-zero, ignore data points that are not finite.
;               DATA          :  A structure that provides an alternate means of
;                                   supplying the data and options.  This is the 
;                                   method used by "TPLOT".
;
;   NOTES:
;               1)  The arrays x and y MUST be monotonic!  (increasing or decreasing)
;               2)  The default is to interpolate in both the x and y dimensions.
;               3)  Data gaps can be included by setting the z values to !VALUES.F_NAN.
;               4)  If ZLOG is set then non-positive zvalues are treated as missing data.
;
;  SEE ALSO:
;               xlim.pro
;               ylim.pro
;               zlim.pro
;               options.pro
;               tplot.pro
;               draw_color_scale.pro
;
;   CHANGED:  1)  Davin Larson changed something...       [11/01/2002   v1.0.?]
;             2)  Re-wrote and cleaned up                 [06/10/2009   v1.1.0]
;             3)  Changed some minor syntax stuff         [06/11/2009   v1.1.1]
;             4)  Fixed a typo which occured when Y input had 2-Dimensions
;                                                         [09/14/2009   v1.1.2]
;
;   CREATED:  ??/??/????
;   CREATED BY:  Davin Larson
;    LAST MODIFIED:  09/14/2009   v1.1.2
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-


Last Modification =>  2009-06-21/22:33:04 UTC
;+
;*****************************************************************************************
;
;  FUNCTION :   sphere_to_cart.pro
;  PURPOSE  :   Transforms from a spherical to a cartesian coordinate system.
;
;  CALLED BY: 
;               add_df2dp.pro
;               add_df2d_to_ph.pro
;
;  CALLS:       NA
;
;  REQUIRES:    NA
;
;  INPUT:
;               R      :  N-Element array of radial magnitudes in spherical coordinates
;               THETA  :  N-Element array of poloidal angles (deg)
;               PHI    :  N-Element array of azimuthal angles (deg)
;               X      :  Named variable to return the cartesian X-component
;               Y      :  Named variable to return the cartesian Y-component
;               Z      :  Named variable to return the cartesian Z-component
;
;  EXAMPLES:    NA
;
;  KEYWORDS:  
;               VEC    :  Set to a named variable to return the [N,3]-element
;                           cartesian vector array
;
;  NOTES:
;               -90 < theta < 90   (latitude not co-lat)  
;
;   CHANGED:  1)  Davin Larson changed something...       [11/01/2002   v1.0.6]
;             2)  Re-wrote and cleaned up                 [06/21/2009   v1.1.0]
;
;   CREATED:  ??/??/????
;   CREATED BY:  Davin Larson
;    LAST MODIFIED:  06/21/2009   v1.1.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-


Last Modification =>  2008-06-23/22:24:02 UTC
;+
;FUNCTION: sub3d
;PURPOSE: Takes two 3D structures and returns a single 3D structure
;  whose data is the difference of the two.
;  This routine is useful for subtracting background counts.
;  Integration period is considered if units are in counts.
;INPUTS: d1,d2  each must be 3D structures obtained from the get_?? routines
;	e.g. "get_el"
;RETURNS: single 3D structure
;
;CREATED BY:	Davin Larson
;LAST MODIFICATION:  04/04/2008  v1.11
;    MODIFIED BY: Lynn B. Wilson III
;
;Notes: This is a very crude subroutine. Use at your own risk.
;-


Last Modification =>  2008-06-23/22:24:02 UTC
;+
;FUNCTION: sum3d
;PURPOSE: Takes two 3D structures and returns a single 3D structure
;  whose data is the sum of the two
;INPUTS: d1,d2  each must be 3D structures obtained from the get_?? routines
;	e.g. "get_el"
;RETURNS: single 3D structure
;
;CREATED BY:	Davin Larson
;LAST MODIFICATION:	@(#)sum3d.pro	1.8 02/04/17
;
;Notes: This is a very crude subroutine. Use at your own risk.
;-


Last Modification =>  2008-06-23/22:24:02 UTC
;+
;PROCEDURE: sym.pro
;PURPOSE: ASSIGN USERSYM WITH SYMBOL
;
;USAGE: SYM, PSYM = PSYM,SYMSIZE = SYMSIZE,NOFILL=NOFILL,_EXTRA=E
;
; PSYM:
;    1 = CIRCLE
;    4 = DIAMOND
;    5 = TRIANGLE
;    6 = SQUARE
;
;-


Last Modification =>  2008-06-23/22:24:02 UTC
;+
;FUNCTION:	symm3d
;PURPOSE:	Returns [theta,phi]  given a 3d data struct
;INPUT:
;	dat:	A 3d data structure such as those generated by get_el,get_pl,etc
;		e.g. "get_el"
;KEYWORDS:
;	esteps:		energy steps to use
;
;CREATED BY:	Davin Larson
;LAST MODIFICATION:	@(#)symm3d.pro	1.5 95/10/06
;
;-


Last Modification =>  2008-06-23/22:24:02 UTC
;+
;FUNCTION:	symmetry_dir
;PURPOSE:	Calculates symmetry direction
;INPUT:
;	Pt:	array of pts
;KEYWORDS:
;	none
;
;CREATED BY:	Davin Larson
;LAST MODIFICATION:	@(#)symmetry_dir.pro	1.3 95/08/24
;-


Last Modification =>  2008-06-23/22:24:02 UTC
;+
;PROCEDURE:  units
;PURPOSE:    adds the tag 'units' to the structure "struct"
;INPUTS: 
;   struct:  structure to be added to.  (Created if non-existent)
;   units:     string containing units name.
;Typical usage:
;   units,lim,'Counts'
;
;CREATED BY:	Davin Larson
;LAST MODIFICATION: 	@(#)units.pro	1.4 02/04/17
;-


Last Modification =>  2009-09-26/18:20:59 UTC
;+
;*****************************************************************************************
;
;  FUNCTION :   xyz_to_polar.pro
;  PURPOSE  :   Calculates the radial magnitude, theta and phi given a 3 vector
;
;  CALLED BY:   NA
;
;  CALLS:
;               xyz_to_polar.pro
;               get_data.pro
;               str_element.pro
;               store_data.pro
;               cart_to_sphere.pro
;
;  REQUIRES:    NA
;
;  INPUT:
;               DATA         :  Several options are allowed for the input xyz vec.
;                                 String:  TPLOT name to get data to use
;                                 Structure:  data.Y is assumed to contain [[x],[y],[z]]
;                                 [N,3]-Element Array:  [[x],[y],[z]]
;                                 [Note:  Returns values through the keywords with the
;                                    same data type as the input.]
;
;  EXAMPLES:
;               ******************
;               **Passing Arrays**
;               ******************
;               x   = FINDGEN(100)
;               y   = 2*x
;               z   = x-20
;               vec = [[x],[y],[z]]
;               xyz_to_polar,vec,MAGNITUDE=mag  ; => mag will be the magnitude
;               **********************
;               **Passing Structures**
;               **********************
;               dat = {YTITLE:'Vector',X:FINDGEN(100),Y:vec}
;               xyz_to_polar,dat,MAGNITUDE=mag,THETA=th,PHI=ph
;                        ; => mag, th, and ph will all be structures
;               *******************
;               **Passing Strings**
;               *******************
;               xyz_to_polar,'Vp'
;                        ; => new TPLOT quantities, 'Vp_mag','Vp_th','Vp_ph' will be 
;                               created
;
;  KEYWORDS:  
;               MAGNITUDE    :  Named variable to return the radial magnitude
;               THETA        :  Named variable to return the poloidal angles (deg)
;               PHI          :  Named variable to return the azimuthal angles (deg)
;               TAGNAME      :  String defining the structure tag name to use
;               MAX_VALUE    :  Named variable to return the 
;               MIN_VALUE    :  Named variable to return the 
;               MISSING      :  Set to the value you wish to replace "bad" data with
;               CLOCK        :  If set, when calling cart_to_sphere.pro set the 
;                                 Y-Parameter to its negative
;               CO_LATITUDE  :  If set, THETA returned between 0.0 and 180.0 degrees
;               PH_0_360     :  IF > 0, 0 <= PHI <= 360
;                               IF = 0, -180 <= PHI <= 180
;                               IF < 0, ***if negative, best guess phi range returned***
;               PH_HIST      :  2-Element array of max and min values for PHI
;                                 [e.g. IF PH_0_360 NOT set and PH_HIST=[-220,220] THEN
;                                   if d(PHI)/dt is positive near 180, then
;                                   PHI => PHI+360 when PHI passes the 180/-180 
;                                   discontinuity until phi reaches 220.]
;
;   CHANGED:  1)  Davin Larson changed something...       [??/??/????   v1.0.?]
;             2)  Re-wrote and cleaned up                 [06/21/2009   v1.1.0]
;             3)  Fixed typo in re-write                  [09/26/2009   v1.1.1]
;
;   CREATED:  ??/??/????
;   CREATED BY:  Davin Larson
;    LAST MODIFIED:  09/26/2009   v1.1.1
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-



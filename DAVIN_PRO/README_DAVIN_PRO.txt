Last Modification =>  2008-06-23/22:23:12 UTC
;+
;FUNCTION:	accum_pad,dat,apad
;PURPOSE:	makes a data pad from a 3d structure
;INPUT:	
;	dat:	A 3d data structure such as those gotten from get_el,get_pl,etc.
;		e.g. "get_el"
;KEYWORDS:
;	bdir:	Add B direction
;	esteps:	Energy steps to use
;	bins:	bins to sum over
;	num_pa:	number of the pad
;
;CREATED BY:	Davin Larson
;LAST MODIFICATION:	%W% %E%
;-


Last Modification =>  2008-06-23/22:23:12 UTC
;+
;PROCEDURE: add_all
;PURPOSE:
;  adds user defined structure elements to the 3d structures.
;USAGE:
;  add_all,dat,add
;INPUT:
;  dat:  A (3d) data structure.
;  add:  a structure such as:  {vsw:'Vp' , magf:'B3',  sc_pos:'pos'}
;RESULTS:
;  for the above example, the elements, vsw, magf, and sc_pos are
;  added to the dat structure.  The values are obtained from the tplot
;  variables 'Vp', 'B3' and 'pos' respectively.
;-


Last Modification =>  2008-06-23/22:23:12 UTC
;+
;PROCEDURE: add_data, n1,n2
;PURPOSE:
;   Creates a tplot variable that adds two tplot variables.
;INPUT: n1,n2  tplot variable names (strings)
;-


Last Modification =>  2009-11-11/16:46:22 UTC
;+
;*****************************************************************************************
;
;  FUNCTION :   add_df2dp.pro
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
;               cont3d.pro
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
;   CHANGED:  1)  Davin Larson created                      [10/08/1995   v1.0.0]
;             2)  Modified by J.P. McFadden                 [09/15/1995   v1.1.0]
;             3)  Changed minor syntax and indexing issues  [01/23/2008   v1.1.1]
;             4)  Re-wrote and cleaned up                   [06/21/2009   v1.2.0]
;             5)  Fixed a typo                              [11/11/2009   v1.2.1]
;
;   CREATED:  10/08/1995
;   CREATED BY:  Davin Larson
;    LAST MODIFIED:  11/11/2009   v1.2.1
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-


Last Modification =>  2008-06-23/22:23:13 UTC
;+
;PROCEDURE:  add_magf,dat,source
;PURPOSE:
;    Adds magnetic field vector [Bx,By,Bz] to a 3d structure.
;    The new structure element will be a 3 element vector 
;    with the tag name 'magf'.
;INPUT:
;    dat:   3D data structure        (i.e. from 'GET_EL')
;    [source] : (String) handle of magnetic field data.
;Notes:
;       Magnetic field data must be loaded first.  
;       See 'GET_MFI'
;-


Last Modification =>  2008-06-23/22:23:13 UTC
;+
;PROCEDURE:  add_sc_pos,dat,source
;PURPOSE:  
;       Adds orbital data to a 3d data structure.
;       The new structure element will be a three element vector [x,y,z]
;       with the tag name 'sc_pos'.
;INPUT:
;    dat:   3D structure (obtained from get_??() routines)
;           e.g. "GET_EL"
;Notes:
;       Orbit data must be loaded first.  
;       See "GET_ORBIT"
;-


Last Modification =>  2008-06-23/22:23:13 UTC
;+
;PROCEDURE:   add_str_element, struct, tag_name, value
;PURPOSE:
;  Obsolete.
;Replacement procedure:
;  str_element,/add, struct,tag_name,value 
;PURPOSE:   add an element to a structure (or change an element)
;SEE ALSO:
;  "str_element"
;Warning:
;  This procedure is slow when adding elements to large structures.
;
;CREATED BY:	Davin Larson
;LAST MODIFICATION:	@(#)add_str_element.pro	1.19 97/05/30
;
;-


Last Modification =>  2008-06-23/22:23:13 UTC
;+
;PROCEDURE: ang_data, n1,n2
;PURPOSE:
;   Creates a tplot variable that is the angle between two tplot variables.
;INPUT: n1,n2  tplot variable names (strings)
;   These should each be 3 element vectors
;-


Last Modification =>  2008-06-23/22:23:13 UTC
;+
;FUNCTION average(array,d [,STDEV=stdev] [,/NAN])
;PURPOSE:
;   Returns the average value of an array.
;   The input array can be an array of structures
;   Similar to TOTAL, but returns the average over the given dimension.
;   Also returns standard deviation via an optional keyword argument.
;   Works with structures only if d eq 0
;-


Last Modification =>  2008-06-23/22:23:13 UTC
;+
;FUNCTION average_hist(d,x [,STDEV=stdev])
;returns the average of d binned according to x
;USAGE:
;assuming:
;  x = randomu(seed,1000)*10
;  y = 10-.1*x^2 + randomn(seed,1000)
;  d = y
;   avg = average_hist(d,x,xbins=xc)
;   avg = average_hist(d,x,xbins=xc,range=[2,8],binsize=.25)
;  plot,x,y,psym=3
;  oplot,xc,avg,psym=-4
;NOTE:  d can be an array of structures:
;  d=replicate({x:0.,y:0.},1000)
;  d.x = x
;  d.y = y
;  plot,d.x,d.y,psym=3
;  avg = average_hist(d,d.x)
;  oplot,avg.x,avg.y,psym=-4
;-


Last Modification =>  2008-06-23/22:23:13 UTC
;+
;PROCEDURE: avg_data, name, res
;PURPOSE:
;   Creates a new tplot variable that is the time average of original.
;INPUT: name  tplot variable names (strings)
;-


Last Modification =>  2008-06-23/22:23:13 UTC
;+
;PROCEDURE:
;   bkg_file,bkg [,filename]
;PURPOSE:
;   saves and restores background data files.
;   if filename is not a string then a filename is generated automatically.
;INPUT:
;   bkg:  a 3d background data structure.
;   filename:  optional filename.
;KEYWORDS:  One must be set!
;   SAVE:   set to save files.
;   RESTORE:set to restore files.
;-


Last Modification =>  2008-08-27/21:40:40 UTC
;+
;FUNCTION:  bytescale(array)
;PURPOSE:   Takes an array or image and scales it to bytes
;INPUT:     array of numeric values.
;KEYWORDS:
;   RANGE:  Two element vector specifying the range of array to be used.
;        Defaults to the min and max values in the array.
;   ZERO:   Forces range(0) to zero
;   TOP:    Maximum byte value  (default is !d.table_size-2)
;   BOTTOM: Minimum byte value  (default is 1)
;   MIN_VALUE: autoranging ignores all numbers below this value
;   MAX_VALUE: autoranging ignores all numbers above this value
;   MISSING:  Byte value for missing data. (values outside of MIN_VALUE,
;     MAX_VALUE range)  If the value is less than 0 then !p.background is used.
;   LOG:    sets logrithmic scaling
;
;CREATED BY:	Davin Larson
;LAST MODIFICATION:	@(#)bytescale.pro	1.22 02/04/17
;-


Last Modification =>  2011-02-15/22:01:54 UTC
;+
;*****************************************************************************************
;
;  FUNCTION :   cont2d.pro
;  PURPOSE  :   Produces a contour plot of the distribution function with parallel and 
;                 perpendicular cuts shown.  One can also, with appropriate keywords,
;                 output thermal velocities, temperatures, heat flux vectors, and 
;                 temperature anisotropies.
;
;  CALLS:  
;               str_element.pro
;               minmax.pro
;               extract_tags.pro
;               add_df2dp_2.pro
;               get_colors.pro
;               distfunc.pro
;               dat_3dp_str_names.pro
;               trange_str.pro
;               read_shocks_jck_database.pro
;               my_time_string.pro
;               mom_sum.pro
;               mom_translate.pro
;               rot_mat.pro
;               data_cut.pro
;               get_plot_state.pro
;               one_count_level.pro
;               moments_3d.pro
;
;  INPUT:
;               DFPAR    :  3D data structure retrieved from get_??(el,elb,eh,pl, etc.)
;
;  KEYWORDS:  
;               VLIM     :  Velocity limit for x-y axes over which to plot data [km/s]
;               NGRID    :  # of isotropic velocity grids to use to triangulate the data
;                             [Default = 30L]
;               REDF     :  Option to plot red line for reduced dist. funct. on cut plot
;               CPD      :  Set to a scalar to define contours per decade
;               LIM      :  Set to plot limit structure [i.e. _EXTRA=lim in PLOT.PRO etc.]
;               NOCOLOR  :  If set, contour plot is output in gray-scale
;               VOUT     :  Set to a named variable to be returned on output specifying
;                             the velocities used to calculate the DFs
;               FILL     :  If set, contours are filled in with colors
;               CCOLORS  :  Obselete?
;               PLOT1    :  Set to a named variable to return the plot state structure
;               MYONEC   :  Allows one to print the data point in 'df' units
;                             corresponding to one count (thus below this, data can
;                             not be trusted).  The input should be the data structure
;                             corresponding to the desired structure being plotted, BUT
;                             it should be the un-manipulated version (i.e. in the
;                             spacecraft frame).  cont2d.pro will use the routine
;                             one_count_level.pro and return the parallel cut of the
;                             1-Count Level for that distribution.
;               V_TH     :  If set, program calculates and outputs the thermal speed
;                             for the input distribution [km/s]
;               MYDIST   :  Structure with format of returned structure from 
;                             distfunc.pro
;               ANI_TEMP :  If set, program calculates and outputs the Temperature 
;                             anisotropy for the input distribution
;               HEAT_F   :  If set, program calculates and outputs the projection of
;                             the heat flux vector to be overplotted on the 2D contour
;                             DF plot
;               GNORM    :  Set to a 3-element unit vector corresponding to the shock
;                             normal vector in GSE coordinates
;               DFRA     :  2-Element array specifying a DF range (s^3/km^3/cm^3) for the
;                             cuts of the distribution function
;
;  CHANGED:  1)  Changed vlim to a keyword                 [04/10/2007   v1.1.?]
;            2)  Added keywords: VLIM, MYONEC, V_TH
;            3)  Improved error handling to prevent code breaking or segmentation faults
;            4)  Added the projection of the Solar Wind velocity on contour plots
;            5)  Changed color scale/scheme  {best results when ngrid=24}
;            6)  Changed plot positions and labels
;            7)  No longer calls distfunc.pro, now calls my_distfunc.pro
;            8)  Forced aspect ratio=1 for PS files
;            9)  Plotting options and output were altered to make parallel and
;                  perpendicular cuts of the contours an automatic result
;           10)  Added keywords: MYDIST, ANI_TEMP, HEAT_F  [08/11/2008   v1.1.48]
;           11)  Changed one count calculation             [02/25/2009   v1.1.49]
;           12)  Updated man page                          [02/25/2009   v1.1.50]
;           13)  Changed color calculation                 [02/25/2009   v1.1.51]
;           14)  Changed one count to allow for structures [02/26/2009   v1.1.52]
;           15)  Made some minor alterations, no functionality effects though
;                                                          [03/20/2009   v1.1.53]
;           16)  Added program add_df2dp.pro back to pro   [03/20/2009   v1.1.54]
;           17)  Changed contour levels calculation        [03/20/2009   v1.1.55]
;           18)  Changed add_df2dp.pro to add_df2dp_2.pro  [03/22/2009   v1.1.56]
;           19)  Changed calling of field_rot.pro          [04/17/2009   v1.1.57]
;           20)  Changed Y-Axis labels for cut-plot        [05/15/2009   v1.1.58]
;           21)  Added keyword: GNORM                      [05/15/2009   v1.1.59]
;           22)  Added programs: my_all_shocks_read.pro, my_time_string.pro, and 
;                  rot_mat.pro                             [05/15/2009   v1.2.0]
;           23)  Changed usage of HEAT_F keyword           [05/20/2009   v1.2.1]
;           24)  Added program:  my_mom3d.pro              [05/20/2009   v1.2.1]
;           25)  Added programs :  my_mom_sum.pro and my_mom_translate.pro
;                  Removed program:  my_mom3d.pro          [05/20/2009   v1.2.2]
;           26)  Fixed minor syntax error when GNORM set   [06/17/2009   v1.2.3]
;           27)  Added color-coded output definitions for GNORM and HEAT_F keywords
;                                                          [06/17/2009   v1.2.4]
;           28)  Changed plot labels and colors            [07/30/2009   v1.2.5]
;           29)  Changed treatment of one count level      [07/30/2009   v1.3.0]
;           30)  Fixed plot label on DF cut plot           [07/31/2009   v1.3.1]
;           31)  Changed program my_str_names.pro to dat_3dp_str_names.pro
;                  and my_distfunc.pro to distfunc.pro
;                  and my_convert_vframe.pro to convert_vframe.pro
;                  and my_pad_dist.pro to pad.pro
;                                                          [08/05/2009   v2.0.0]
;           32)  Changed functionality of GNORM keyword slightly by allowing one to
;                  enter a 3-element vector to avoid calling my_all_shocks_read.pro
;                  multiple times                          [08/10/2009   v2.0.1]
;           33)  Changed functionality of MYONEC keyword:  Now enter the original
;                  particle structure after adding 'VSW', 'MAGF', and 'SC_POT'
;                  before transferring into any other reference frame
;                  [Now calls one_count_level.pro]         [08/10/2009   v2.1.0]
;           34)  Fixed syntax error in MYONEC calculation  [08/11/2009   v2.1.1]
;           35)  Changed some minor message outputs        [08/13/2009   v2.1.2]
;           36)  Changed programs:
;                  and my_all_shocks_read.pro to read_shocks_jck_database.pro
;                                                          [09/16/2009   v2.1.3]
;           37)  Altered comments regarding the use of MYONEC keyword
;                                                          [12/02/2009   v2.1.4]
;           38)  Altered comments and functionality regarding the keywords
;                  V_TH, ANI_TEMP, HEAT_F, and GNORM       [02/17/2010   v2.1.5]
;           39)  Fixed a typo with Y-Axis labels for the parallel/perpendicular cuts
;                                                          [02/21/2010   v2.2.0]
;           40)  Changed color of parallel cut output and added keyword:  DFRA
;                                                          [06/21/2010   v2.3.0]
;           41)  Changed contour levels calculation slightly to depend upon
;                  DFRA keyword                            [10/01/2010   v2.4.0]
;           42)  Removed dependence on field_rot.pro       [02/15/2011   v2.5.0]
;
;   NOTES:
;           **[changed plotting so that the plots will be automatically square]**
;
;  ADAPTED FROM: cont2d.pro  BY:  Davin Larson
;  CREATED:  04/10/2007
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  02/15/2011   v2.5.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-


Last Modification =>  2009-08-05/13:56:03 UTC
;+
;*****************************************************************************************
;
;  FUNCTION :   cont3d.pro
;  PURPOSE  :   Produces a contour plot of the distribution function with parallel and 
;                 perpendicular cuts shown.  One can also, with appropriate keywords,
;                 output contours of constant speed. 
;
;  CALLED BY:   NA
;
;  CALLS:
;               get_colors.pro
;               add_df2dp.pro
;               distfunc.pro
;               str_element.pro
;               trange_str.pro
;               minmax_range.pro
;               minmax.pro
;               extract_tags.pro
;               draw_color_scale.pro
;
;  REQUIRES:    NA
;
;  INPUT:
;               DAT  :  3D data structure retrieved from get_??(el,elb,eh,pl, etc.)
;
;  EXAMPLES:
;
;  KEYWORDS:  
;               NEWDAT    :  Set to a named variable to return the new structure created
;                              by add_df2dp.pro
;               OPTIONS   :  Set to plot limit structure [i.e. _EXTRA=lim in PLOT.PRO etc.]
;               DPOINTS   :  Obselete?
;               CIRCLES   :  Set to an array defining circles of constant velocity
;               NCIRCLES  :  Set to a scalar defining the # of constant velocity 
;                              circles you wish to output on the DF contours
;               VLIM      :  Limit for x-y axes over which to plot data
;                              [Default = max vel. from energy bin values]
;               NGRID     :  # of isotropic velocity grids to use to triangulate the data
;                              [Default = 30L]
;               CPD       :  Set to a scalar to define contours per decade
;               UNITS     :  [String] Units to be plotted in [convert to given data units
;                              before plotting]
;               XR        :  Obselete?
;               YR        :  Obselete?
;
;   CHANGED:  1)  Davin Larson changed something...       [??/??/????   v1.0.?]
;             2)  Re-wrote and cleaned up                 [06/21/2009   v1.1.0]
;             3)  Changed program my_distfunc.pro to distfunc.pro
;                                                         [08/05/2009   v1.2.0]
;
;   CREATED:  ??/??/????
;   CREATED BY:  Davin Larson
;    LAST MODIFIED:  08/05/2009   v1.2.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-


Last Modification =>  2008-06-23/22:23:13 UTC
;+
;PROCEDURE:
;   dat_file,dat [,filename]
;PURPOSE:
;   saves and restores 3d data files.
;   if filename is not a string then a filename is generated automatically.
;INPUT:
;   dat:  a 3d background data structure.
;   filename:  optional filename.
;KEYWORDS:  One must be set!
;   SAVE:   set to save files.
;   RESTORE:set to restore files.
;   DIR:  (string) Directory to use. Default is current directory
;-


Last Modification =>  2008-06-23/22:23:13 UTC
;+
;PROCEDURE: deriv_data, n1,n2
;PURPOSE:
;   Creates a tplot variable that is the derivative of a tplot variable.
;INPUT: n1  tplot variable names (strings)
;-


Last Modification =>  2008-06-23/22:23:13 UTC
;+
;FUNCTION:   dgen(n)
;PURPOSE:  returns an array of n doubles that are scaled between two limits.
;INPUT:   n:  number of data points.   (uses 100 if no value is passed)
;KEYWORDS:  one of the next 3 keywords should be set:
;   XRANGE:  uses !x.crange (current x limits) for the scaling.
;   YRANGE:  uses !y.crange (current y limits) for the scaling.
;   RANGE:   user selectable range.
;   LOG:     user selectable log scale (Used with RANGE)
;EXAMPLES:
;  x = dgen(/x)  ; Returns 100 element array of points evenly distributed along
;                ; the x-axis.
;-


Last Modification =>  2008-06-23/22:23:13 UTC
;+
;PROCEDURE: dif_data, n1,n2
;PURPOSE:
;   Creates a tplot variable that is the difference of two tplot variables.
;INPUT: n1,n2  tplot variable names (strings)
;-


Last Modification =>  2009-07-20/21:32:14 UTC
;+
;*****************************************************************************************
;
;  FUNCTION :   distfunc.pro
;  PURPOSE  :   Interpolates distribution function in a smooth manner returning a
;                 data structure with the velocities parallel and perpendicular to the
;                 magnetic field for each given data point.
;
;  CALLED BY:   NA
;
;  CALLS:
;               velocity.pro
;               distfunc.pro
;               distfunc_template.pro
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
;               test  = distfunc(dat.ENERGY,dat.ANGLE,MASS=dat.MASS,DF=dat.DATA)
;               test  = distfunc(vpar,vperp,PARAM=dfpar) 
;               
;               dfpar = distfunc(vx0,vy0,df=df0)   
;                   => Create structure dfpar using values of df0 known at the 
;                         positions of vx0,vy0 as a structure
;               df_new = distfunc(vx_new,vy_new,par=dfpar)   
;                   => returns interpolated values of df at the new points as an array
;
;  KEYWORDS:  
;               TEMPLATE :  used to create a template of what data structure 
;                            should look like if sending in an array of structures 
;                            with possible bad data
;               DF       :  [float] Array of data from my_pad_dist.pro
;               PARAM    :  A 3D data structure with the tag names VX0, VY0, and DFC
;               MASS     :  [float] Value representing the mass of particles for the
;                             distribution of interest [eV/(km/sec)^2]
;               DEBUG    :  Forces program to stop before returning for debugging
;
;   CHANGED:  1)  Davin Larson changed something...          [??/??/????   v1.0.?]
;             2)  Got rid of pointers                        [09/15/2007   v1.1.0]
;             3)  Forced a universal array size to be returned if DF is set
;                  {prevents conflicting data structures when multiple calls 
;                    to this program are made}               [11/20/2007   v1.2.0]
;             4)  Created a dummy structure template for returning if no data
;                  is finite or available for error handling in multiple calls
;                  [calls my_distfunc_template.pro]          [02/05/2008   v1.3.9]
;             5)  Updated man page                           [02/25/2009   v1.3.10]
;             6)  Changed return values and robustness       [02/25/2009   v1.3.11]
;             7)  Nothing functional changed                 [04/08/2009   v1.3.12]
;             8)  Updated man page and cleaned up            [06/22/2009   v1.4.0]
;             9)  Changed my_distfunc_template.pro to distfunc_template.pro
;                                                            [07/20/2009   v1.4.1]
;
;   CREATED:  ??/??/????
;   CREATED BY:  Davin Larson
;    LAST MODIFIED:  07/20/2009   v1.4.1
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-


Last Modification =>  2008-06-23/22:23:13 UTC
;+
;NAME:
;    distfunc
;FUNCTION: distfunc(vpar,vperp,param=dfpar) 
;  or      distfunc(energy,angle,mass=mass,param=dfpar)
;PURPOSE:
;   Interpolates distribution function in a smooth manner.
;USAGE:
;   dfpar = distfunc(vx0,vy0,df=df0)   ; Create structure dfpar using
;     values of df0 known at the positions of vx0,vy0
;   df_new = distfunc(vx_new,vy_new,par=dfpar)
;     return interpolated values of df at the new points.
;
;KEYWORDS:
;   template :  used to create a template of what data structure should look like
;                if sending in an array of structures with possible bad data
;
;
; LAST MODIFIED: 11/28/2007
; MODIFIED BY:  Lynn B. Wilson III  {error handling}
;
;*****************************************************************************
;3dp> help, dfpar,/str
;** Structure <e26fe8>, 21 tags, length=8272, data length=8262, refs=1:
;   PROJECT_NAME    STRING    'Wind 3D Plasma'
;   DATA_NAME       STRING    'Eesa Low PAD'
;   VALID           INT              1
;   UNITS_NAME      STRING    'df'
;   TIME            DOUBLE       8.2363067e+08
;   END_TIME        DOUBLE       8.2363067e+08
;   INTEG_T         DOUBLE           3.0690110
;   NBINS           INT              8
;   NENERGY         INT             15
;   DATA            FLOAT     Array[15, 8]
;   ENERGY          FLOAT     Array[15, 8]
;   ANGLES          FLOAT     Array[15, 8]
;   DENERGY         FLOAT     Array[15, 88]
;   BTH             FLOAT           22.8193
;   BPH             FLOAT           20.0945
;   GF              FLOAT     Array[15, 8]
;   DT              FLOAT     Array[15, 8]
;   GEOMFACTOR      DOUBLE       0.00039375000
;   MASS            DOUBLE       5.6856591e-06
;   UNITS_PROCEDURE STRING    'convert_esa_units'
;   DEADTIME        FLOAT     Array[15, 8]
;*****************************************************************************
;-


Last Modification =>  2008-06-23/22:23:13 UTC
;+
;PROCEDURE: div_data, n1,n2
;PURPOSE:
;   Creates a tplot variable that is the ratio of two other tplot variables.
;INPUT: n1,n2  tplot variable names (strings)
;-


Last Modification =>  2008-06-23/22:23:13 UTC
;+
;FUNCTION:
;  w = enclosed(x,y [cx,cy],NCIRCS=NCIRCS,COUNT=COUNT)
;PURPOSE:
; Returns the indices of a set of x,y points that are inside a contour.
;INPUT:  x,y:    data set of points.  (x and y must be the same dimension)
;        cx,cy:  vector of x,y pairs that describe a closed contour. 
;        if cx,cy are not provided then the cursor is used to obtain it.
;OUTPUT:
;    W:  Array of indices of x (& y) that are within the contour cx,cy.
;    NCIRCS: Same dimension as x (& y); integer array giving the number
;        of times each point is encircled.
;    COUNT:  Size of array W
;-


Last Modification =>  2008-06-23/22:23:13 UTC
;+
;FUNCTION EXPONENTIAL
;USAGE:
;  y = exponential(x,par=p)
;-


Last Modification =>  2008-06-23/22:23:13 UTC
;+
; NAME:
;       FIT
;
; PURPOSE:
;       Non-linear least squares fit to a user defined function.
;       This procedure is an improved version of CURVEFIT that allows fitting
;       to a subset of the function parameters.
;       The function may be any non-linear function.
;       If available, partial derivatives can be calculated by
;       the user function, else this routine will estimate partial derivatives
;       with a forward difference approximation.
;
; CATEGORY:
;       E2 - Curve and Surface Fitting.
;
; CALLING SEQUENCE:
;       FIT,X, Y, PARAMETERS=par, NAMES=string, $
;             FUNCTION_NAME=string, ITMAX=ITMAX, ITER=ITER, TOL=TOL, $
;             /NODERIVATIVE
;
; INPUTS:
;       X:  A row vector of independent variables.  This routine does
;     not manipulate or use values in X, it simply passes X
;     to the user-written function.
;
;       Y:  A row vector containing the dependent variable.
;
; KEYWORD INPUTS:
;
;       FUNCTION_NAME:  The name of the function to fit.
;          If omitted, "FUNC" is used. The procedure must be written as
;          described under RESTRICTIONS, below.
;
;       PARAMETERS:  A structure containing the starting parameter values
;          for the function.  Final values are also passed back through
;          this variable.  The fitting function must accept this keyword.
;          If omitted, this structure is obtained from the user defined
;          function.
;
;       NAMES: The parameters to be fit.  Several options exist:
;          A string with parameter names delimited by spaces.
;          A string array specifying which parameters to fit.
;          An integer array corresponding to elements within the PARAMETERS structure.
;          If undefined, then FIT will attemp to fit to all double precision
;          elements of the PARAMETERS structure.
;
;       WEIGHT:   A row vector of weights, the same length as Y.
;          For no weighting,
;            w(i) = 1.0.
;          For instrumental weighting,
;            w(i) = 1.0/y(i), etc.
;          if not set then w is set to all one's  (equal weighting)
;
;       DY:  A row vector of errors in Y.  If set, then WEIGHTS are set to:
;               W = 1/DY^2 and previous values of the WEIGHTS are replaced.
;
;       ERROR_FACTOR: set this keyword to have DY set to ERROR_FACTOR * Y.
;
;       ITMAX:  Maximum number of iterations. Default = 20.
;
;       TOL:    The convergence tolerance. The routine returns when the
;               relative decrease in chi-squared is less than TOL in an
;               interation. Default = 1.e-5.
;
;       NODERIVATIVE:  (optional)
;            If set to 1 then the partial derivatives will be estimated in CURVEFIT using
;               forward differences.
;            If set to 0 then the user function is forced to provide
;               partial derivatives.
;            If not provided then partial derivatives will be determined
;               from the user function only if it has the proper keyword
;               arguments.
;
;       SILENT:  If this keyword is set then no fit information is printed.
;       MAXPRINT: Maximum number of parameters to display while iterating
;               (Default is 8)
;
; KEYWORD OUTPUTS:
;       ITER:   The actual number of iterations which were performed.
;
;       CHI2:   The value of chi-squared on exit.
;
;       FULLNAMES:  A string array containing the parameter names.
;
;       P_VALUES:  A vector with same dimensions as FULLNAMES, that
;           contains the final values for each parameter.  These values
;           will be the same as the values returned in PARAMETERS.
;
;       P_SIGMA:  A vector containing the estimated uncertainties in P_VALUES.
;
;       FITVALUES:  The fitted function values:
;
; OUTPUT
;       Returns a vector of calculated values.
;
; COMMON BLOCKS:
;       NONE.
;
; RESTRICTIONS:
;       The function to be fit must be defined and called FUNC,
;       unless the FUNCTION_NAME keyword is supplied.  This function,
;       must accept values of X (the independent variable), the keyword
;       PARAMETERS, and return F (the function's value at X).
;       if the NODERIV keyword is not set. then the function must also accept
;       the keywords: P_NAMES and PDER (a 2d array of partial derivatives).
;       For an example, see "GAUSSIAN".
;
;   The calling sequence is:
;
;       CASE 1:    (NODERIV is set)
;          F = FUNC(X,PAR=par)               ; if NODERIV is set  or:
;             where:
;          X = Variable passed into function.  It is the job of the user-written
;             function to interpret this variable. FIT does NOT use X.
;          PAR = structure containing function parameters, input.
;          F = Vector of NPOINT values of function, y(i) = funct(x), output.
;
;       CASE 2:     (NODERIV is not set)
;          F = FUNC(X,PAR=par,NAMES=names,PDER=pder)
;             where:
;          NAMES = string array of parameters to be fit.
;          PDER = Array, (NPOINT, NTERMS), of partial derivatives of FUNC.
;             PDER(I,J) = Derivative of function at ith point with
;             respect to jth parameter.  Optional output parameter.
;             PDER should not be calculated if P_NAMES is not
;             supplied in call. If the /NODERIVATIVE keyword is set in the
;             call to FIT then the user routine will never need to
;             calculate PDER.
;
; PROCEDURE:
;       Copied from "CURFIT", least squares fit to a non-linear
;       function, pages 237-239, Bevington, Data Reduction and Error
;       Analysis for the Physical Sciences.
;
;       "This method is the Gradient-expansion algorithm which
;       combines the best features of the gradient search with
;       the method of linearizing the fitting function."
;
;       Iterations are performed until the chi square changes by
;       only TOL or until ITMAX iterations have been performed.
;
;       The initial guess of the parameter values should be
;       as close to the actual values as possible or the solution
;       may not converge.
;
;EXAMPLE:  Fit to a gaussian plus a quadratic background:
;  Here is the user-written procedure to return F(x) and the partials, given x:
;
;See the function "GAUSSIAN" for an example function to fit to.
;
;x=findgen(10)-4.5                          ; Initialize independent variables.
;y=[1.7,1.9,2.1,2.7,4.6,5.5,4.4,1.7,0.5,0.3]; Initialize dependent variables.
;plot,x,y,psym=4                            ; Plot data.
;xv = findgen(100)/10.-5.                   ; get better resolution abscissa.
;oplot,xv,gaussian(xv,par=p)                ; Plot initial guess.
;help,p,/structure                          ; Display initial guess.
;fit,x,y,func='gaussian',par=p,fit=f        ; Fit to all parameters.
;oplot,x,f,psym=1                           ; Use '+' to plot fitted values.
;oplot,xv,gaussian(xv,par=p)                ; Plot fitted function.
;help,p,/structure                          ; Display new parameter values.
;
;names =tag_names(p)                        ; Obtain parameter names.
;p.a2 = 0                                   ; set quadratic term to 0.
;names = names([0,1,2,3,4])                 ; Choose a subset of parameters.
;print,names                                ; Display subset of names
;fit,x,y,func='gaussian',par=p,names=names  ; Fit to subset.
;
;   Please Note:  Typically the initial guess for parameters must be reasonably
;   good, otherwise the routine will not converge.  In this example the data
;   was selected so that the default parameters would converge.
;
;The following functions can be used with FIT:
;   "gaussian", "polycurve", "power_law", "exponential"
;
;KNOWN BUGS:
;   Do NOT trust the P_SIGMA Values (uncertainty in the parameters) if the
;   the value of flambda gets large. I believe
;   That some error (relating to flambda) was carried over from CURVEFIT. -Davin
;
;MODIFICATION HISTORY:
;       Function copied from CURVEFIT Written, DMS, RSI, September, 1982
;       and last modified by Mark Rivers, U. of Chicago, Febuary 12, 1995.
;       Davin Larson, U of California, November 1995, MAJOR MODIFICATIONS:
;           - Changed FUNCTION_NAME to a function (instead of procedure) that
;             accepts a structure to hold the parameters.  This makes the usage
;             much more user friendly, and allows a subset of parameters to
;             be fit.
;           - Allowed vectors and recursively searched structures to be fit as well.
;-


Last Modification =>  2008-06-23/22:23:13 UTC
;+
;FUNCTION:  GAUSS
;PURPOSE:
;  Evaluates a gaussian function with background.
;  This function may be used with the "fit" curve fitting procedure.
;
;KEYWORDS:
;  PARAMETERS: structure with the format:
;** Structure <275ac0>, 6 tags, length=48, refs=1:
;   H               DOUBLE           1.0000000      ; hieght
;   W               DOUBLE           1.0000000      ; width
;   X0              DOUBLE           0.0000000      ; center
;   A0              DOUBLE           0.0000000
;   A1              DOUBLE           0.0000000
;   A2              DOUBLE           0.0000000
;     If this parameter is not a structure then it will be created.
;
;USAGE:
;  p={h:2.,w:1.5,x0:5.0,a0:0.,a1:0.,a2:0.}
;  x = findgen(100)/10.
;  y = gaussian(x,par=p)
;  plot,x,y
;RETURNS:
;  p.a2*x^2 + p.a1*x + p.a0 + p.h * exp( - ((x-p.x0)/2/p.w)^2 )
;-


Last Modification =>  2008-06-23/22:23:13 UTC
;+
;FUNCTION:  GAUSSIAN
;PURPOSE:
;  Evaluates a gaussian function with background.
;  This function may be used with the "fitfunc" curve fitting function.
;
;KEYWORDS:
;  PARAMETERS: structure with the format:
;** Structure <275ac0>, 6 tags, length=48, refs=1:
;   H               DOUBLE           1.0000000      ; hieght
;   W               DOUBLE           1.0000000      ; width
;   X0              DOUBLE           0.0000000      ; center
;   A0              DOUBLE           0.0000000
;   A1              DOUBLE           0.0000000
;   A2              DOUBLE           0.0000000
;     If this parameter is not a structure then it will be created.
;  P_NAMES:      string array  (see "fitfunc" for details)
;  PDER_VALUES:  named variable in which partial derivatives are returned.
;
;USAGE:
;  p={h:2.,w:1.5,x0:5.0,a0:0.,a1:0.,a2:0.}
;  x = findgen(100)/10.
;  y = gaussian(x,par=p)
;  plot,x,y
;RETURNS:
;  p.a2*x^2 + p.a1*x + p.a0 + p.h * exp( - ((x-p.x0)/p.w)^2 )
;-


Last Modification =>  2008-06-23/22:23:13 UTC
;+
;FUNCTION:
;   H=histbins(R,XBINS)
;Purpose:
;   Returns the histogram (H) and bin locations (XBINS) for an array of numbers.
;Examples:
;   r = randomn(seed,10000)
;   plot,psym=10, xbins, histbins(r,xbins)             ;Use all defaults.
;   plot,psym=10, xbins, histbins(r,xbins ,/shift)     ;shift bin edges.
;   plot,psym=10, xbins, histbins(r,xbins, binsize=.2)
;   plot,psym=10, xbins, histbins(r,xbins, binsize=.2 ,/shift)
;   plot,psym=10, xbins, histbins(r,xbins, range=[-10,10])
;NOTE:
;   XBINS is an output, not an input!
;Keywords:  (All optional)  Defaults are based on the size and range of input.
;   BINSIZE:  Size of bins.
;   NBINS: force the output array to have this number of elements. (Use with RANGE)
;   RANGE: Limits of histogram
;   SHIFT :  Keyword that controls the location of bin edges. 
;      This has no effect if RANGE is defined.
;   NORMALIZE: Set keyword to return a normalized histogram (probability distribution).
;   REVERSE:  See REVERSE keyword for histogram
;   RETBINS:  If set then an array of bins (same size as r) is returned instead.
;See also: "average_hist", "histbins2d"
;   
;-


Last Modification =>  2008-06-23/22:23:13 UTC
;+
;Function:
; h = histbins2d(x,y,xval,yval)
;Input:
;   x, y, random variables to bin.
;Output:
;   h  number of events within bin
;   xval, yval,  center locations of the bins.
;
;-


Last Modification =>  2008-06-23/22:23:13 UTC
;+
;Function interp2d
;Purpose:
;  Interpolate a 2-dimensional function
;Usage:
;  new_z = interp2d(old_z,old_x,old_y,new_x,new_y,grid=grid)
;Input:
;  old_z  : fltarr(nx,ny)
;  old_x  : fltarr(nx)
;  old_y  : fltarr(ny)
;if GRID is set then:
;  new_z will be a 2-d array;  new_x and new_y should be 1-d vectors.
;if GRID is not set then:
;  new_x should have same dimensions as new_y.  new_z will have the same dimen.
;Notes:
;  This is a 2-dimensional version of the "INTERP" function
;  See IDL documentation of interpolate for a further explanation of the 
;     GRID keyword.
;-


Last Modification =>  2008-09-13/21:12:45 UTC
;+
;Procedure interp_gap,x,y,index=wb,count=c
;replaces NANs with interpolated values.
;-


Last Modification =>  2009-01-08/15:30:01 UTC
;+
;Name: libs
;Purpose:
;  Displays location of source files.
;
;Usage:
;  libs,string  ; string is the name of an IDL source file.
;                 It may contain wildcard characters
;Restrictions:
;
;-


Last Modification =>  2008-06-23/22:23:13 UTC
;+
;PROCEDURE loadct2, colortable
;
;KEYWORDS:
;   FILE:  Color table file
;          Uses the environment variable IDL_CT_FILE to determine 
;          the color table file if FILE is not set.
;common blocks:
;   colors:      IDL color common block.  Many IDL routines rely on this.
;   colors_com:  
;See also:
;   "get_colors","colors_com","bytescale"
;
;Created by Davin Larson;  August 1996
;Version:           1.4
;File:              00/07/05
;Last Modification: loadct2.pro
;-


Last Modification =>  2008-06-23/22:23:13 UTC
;+
;NAME:
;  make_cdf_index
;PROCEDURE:
;  make_cdf_index,  [pattern]
;PURPOSE:
;  Creates an index file for CDF files.
;  The index file will have one line for each CDF file found.
;  Each line contains the start time, end time and filename
;  with the following format:
;YYYY-MM-DD/hh:mm:ss  YYYY-MM-DD/hh:mm:ss   fullpathname.cdf
;  CDF files may be distributed over many directories or disks.
;
;INPUT:
;  pattern:  (string) file pattern, default is:  '*.cdf'
;KEYWORDS:
;  DATA_DIREC  (string) data directory(s) 
;  INDEX_FILENAME:  (string) Name of index file to be created.
;  NO_DUPLICATES:   Set to 1 if duplicate days are to be ignored.
;SEE ALSO:
;  "makecdf","loadcdf","loadcdfstr","loadallcdf",
;CREATED BY:
;  Davin Larson,  August 1996
;VERSION:
;  02/04/17  make_cdf_index.pro  1.5
;-


Last Modification =>  2008-06-23/22:23:13 UTC
;+
;*****************************************************************************
;
;  PURPOSE:
;
;
;
;  CALLS:  add_ddata.pro
;
;
;
;  INPUT:  sf = 3d data structure from get_sf.pro
;
;
;  KEYWORDS:  GRATIO = constant of proportionality in Power-Law
;
;   CREATED BY:  Davin Larson
;    LAST MODIFIED:  04/05/2008
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************
;-


Last Modification =>  2008-06-23/22:23:13 UTC
;+
;FUNCTION:   minmax_range,array 
;PURPOSE:  returns a two element array of min, max values
;INPUT:  array
;KEYWORDS:
;  MAX_VALUE:  ignore all numbers greater than this value
;  MIN_VALUE:  ignore all numbers less than this value
;  POSITIVE:   forces MINVALUE to 0
;
;CREATED BY:	Davin Larson
;LAST MODIFICATION:	@(#)minmax_range.pro	1.5 03/13/2008
;  MODIFIED BY:  Lynn B. Wilson III
;-


Last Modification =>  2008-06-23/22:23:13 UTC
;+
;FUNCTION mirror_ang
;USAGE:
;  ang = mirror_ang(v,par=p)
;-


Last Modification =>  2009-07-20/15:49:51 UTC
;+
;*****************************************************************************************
;
;  FUNCTION :   mom3d.pro
;  PURPOSE  :   Calculates the 3-Dimensional particle distribution functions from the 
;                 first 4 moments of the distribution function.
;
;              If magnetic field vector provided, then:
;               => mom.PTENS = [perp1,perp2,para,xy,xz,yz],    [eV cm^(-3)]
;               => mom.MAGT3 = [perp1,perp2,para],             [eV]
;               => mom.QVEC  = [perp1,perp2,para],             [eV cm^-3 km/s]
;               => mom.RTENS =     [eV^(3/2) cm^(-3)]
;              If magnetic field vector is NOT provided, then:
;               => mom.PTENS = [xx,yy,zz,xy,xz,yz] [GSE],    [eV cm^(-3)]
;               => etc.
;
;  CALLED BY:   NA
;
;  CALLS:  
;               mom_sum.pro
;               mom_translate.pro
;               rot_mat.pro
;               mom_rotate.pro
;
;  REQUIRES:  NA
;
;  INPUT:  
;               DATA    : [Structure] A 3D data structure returned by the programs
;                           get_?? [?? = el, eh, pl, ph, elb, etc.]
;
;  EXAMPLES:
;
;  KEYWORDS:  
;               SC_POT  :  A scalar defining an estimate of the spacecraft potential 
;                           [eV]
;               MAGDIR  :  A named variable which can either define the B-field
;                           direction or be returned
;               PARDENS :  A named variable to be returned to a higher level program 
;                           which is calculated in mom_sum.pro
;               SUMTENS :  A structure returned by mom_sum.pro
;               ERANGE  :  Set to a 2-Element array specifying the first and last
;                           elements of the energy bins desired to be used for
;                           calculating the moments
;               FORMAT  :  A dummy structure format used for preventing conflicting
;                           data structures
;               VALID   :  A returned varialbe which determines whether data 
;                           structures are useful or not
;
;   CHANGED:  1)  Davin Larson created                     [??/??/????   v1.0.0]
;             2)  Did some minor "clean up"                [04/06/2008   v1.0.1]
;             3)  Added comments regarding pressure tensor [09/22/2008   v1.0.1]
;             4)  Fixed comments regarding tensors         [01/28/2009   v1.0.2]
;             5)  Re-wrote and cleaned up                  [04/13/2009   v1.1.0]
;             6)  Updated man page                         [06/17/2009   v1.1.1]
;             7)  Fixed note on charge conversion constant [06/19/2009   v1.1.2]
;             8)  Fixed keyword description of ERANGE      [07/20/2009   v1.1.3]
;
;   CREATED:  ??/??/????
;   CREATED BY:  Davin Larson
;    LAST MODIFIED:  07/20/2009   v1.1.3
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-


Last Modification =>  2008-09-13/20:08:18 UTC
;+
;**************************************************************************
;CREATED BY:    Davin Larson    
;    LAST MODIFIED:  04/06/2008
;    MODIFIED BY: Lynn B. Wilson III
;**************************************************************************
;-


Last Modification =>  2009-06-17/21:54:27 UTC
;+
;*****************************************************************************************
;
;  FUNCTION :   mom_rotate.pro
;  PURPOSE  :   This program rotates a set of moment tensors due to the input rotation
;                 tensor, mrot.
;
;  CALLED BY: 
;               mom3d.pro
;
;  CALLS:
;               rotate_tensor.pro
;
;  REQUIRES:    NA
;
;  INPUT:
;               MOM   :  A 3D moment structure created by my_mom3d.pro
;               MROT  :  A 3x3 rotation matrix
;
;  EXAMPLES:    NA
;
;  KEYWORDS:    NA
;
;   CHANGED:  1)  Davin Larson created                    [??/??/????   v1.0.0]
;             2)  Re-wrote and cleaned up                 [04/13/2009   v1.1.0]
;             3)  Updated man page                        [06/17/2009   v1.1.1]
;
;   CREATED:  ??/??/????
;   CREATED BY:  Davin Larson
;    LAST MODIFIED:  06/17/2009   v1.1.1
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-


Last Modification =>  2009-06-20/00:42:16 UTC
;+
;*****************************************************************************************
;
;  FUNCTION :   mom_sum.pro
;  PURPOSE  :   This program calculates up to the 4th moment for a 3D particle structure.
;
;  CALLED BY: 
;               mom3d.pro
;
;  CALLS:
;               data_type.pro
;               conv_units.pro
;               str_element.pro
;
;  REQUIRES:    NA
;
;  INPUT:
;               DATA       :  A 3D moment structure from get_??.pro 
;                               (?? = el, eh, phb, etc.)
;
;  EXAMPLES:    NA
;
;  KEYWORDS:  
;               FORMAT     :  A structure with the desired format (see program)
;               SC_POT     :  A scalar defining the SC Potential (eV)
;               MAXMOMENT  :  A scalar defining the max moment desired for return
;               OLDWAY     :  If set, an "old" method is used to calculate differential
;                               energy
;               PARDENS    :  Set to a named variable to return the particle density
;                               [cm^(-3)]
;               DVOLUME    :  Set to an array with the same dimensions as data.DATA
;                               specifying the sterradians of the sampled data
;               ERANGE     :  Set to a 2-element array defining the first and last energy
;                               bins to use in the moment calculations
;               MASS       :  Set to a scalar defining the particle mass [eV/(km/sec)^2]
;
;   CHANGED:  1)  Davin Larson created                     [??/??/????   v1.0.0]
;             2)  Did some minor "clean up"                [06/16/2008   v1.0.1]
;             3)  Re-wrote and cleaned up                  [04/13/2009   v1.1.0]
;             4)  Updated man page                         [06/17/2009   v1.1.1]
;             6)  Fixed note on charge conversion constant [06/19/2009   v1.1.2]
;
;   CREATED:  ??/??/????
;   CREATED BY:  Davin Larson
;    LAST MODIFIED:  06/19/2009   v1.1.2
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-


Last Modification =>  2009-06-17/22:50:13 UTC
;+
;*****************************************************************************************
;
;  FUNCTION :   mom_translate.pro
;  PURPOSE  :   This program translates structure data into center of momentum frame
;                 unless a specific velocity is set, then it translates into that
;                 center of velocity frame.
;
;  CALLED BY: 
;               mom3d.pro
;
;  CALLS:       NA
;
;  REQUIRES:    NA
;
;  INPUT:
;               M     :  A 3D moment structure created by my_mom_sum.pro
;
;  EXAMPLES:    NA
;
;  KEYWORDS:  
;               MVEL  :  3-Element velocity vector used to translate from the center
;                          of momentum frame to another frame of reference [eV^(1/2)]
;
;   CHANGED:  1)  Davin Larson created                    [??/??/????   v1.0.0]
;             2)  Did some minor "clean up"               [04/06/2008   v1.0.1]
;             3)  Re-wrote and cleaned up                 [04/13/2009   v1.1.0]
;             4)  Updated man page                        [06/17/2009   v1.1.1]
;
;   CREATED:  ??/??/????
;   CREATED BY:  Davin Larson
;    LAST MODIFIED:  06/17/2009   v1.1.1
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-


Last Modification =>  2010-04-09/21:40:53 UTC
;+
;*****************************************************************************************
;
;  FUNCTION :   moments_3d.pro
;  PURPOSE  :   Returns all useful moments as a structure
;
;  CALLED BY:   NA
;
;  CALLS:
;               data_type.pro
;               conv_units.pro
;               str_element.pro
;               moments_3d.pro
;               sc_pot.pro
;               rot_mat.pro
;               xyz_to_polar.pro
;
;  REQUIRES:    NA
;
;  INPUT:
;               DATA    : 3d data structure.  (i.e. see "GET_EL")
;
;  EXAMPLES:
;               test = moments_3d()
;
;  KEYWORDS:  
;               SC_POT     :  Scalar defining the spacecraft potential (eV)
;               MAGDIR     :  3-Element vector defining the magnetic field (nT)
;                               associated with the data structure
;               TRUE_DENS  :  Scalar defining the true density (cc)
;               PARDENS    :  Scalar defining the density (cc) ??
;               DENS_ONLY  :  If set, program only returns the density estimate (cc)
;               MOM_ONLY   :  If set, program only returns through flux (1/cm/s^2)
;               ADD_MOMENT :  Set to a structure of identical format to the return
;                               format of this program to be added to the structure
;                               being manipulated
;               ERANGE     :  Set to a 2-Element array specifying the first and last
;                               elements of the energy bins desired to be used for
;                               calculating the moments
;               FORMAT     :  Set to a dummy variable which will be returned the
;                               as the structure format associated with the output
;                               structure of this program
;               BINS       :  Old keyword apparently
;               VALID      :  Set to a dummy variable which will return a 1 for a
;                               structure with useful data or 0 for a bad structure
;
;   CHANGED:  1)  Davin Larson created                     [??/??/????   v1.0.0]
;             2)  Updated man page                         [01/05/2009   v1.0.1]
;             3)  Fixed comments regarding tensors         [01/28/2009   v1.0.2]
;             4)  Changed an assignment variable           [03/01/2009   v1.0.3]
;             5)  Changed SC Potential calc to avoid redefining the original variable
;                                                          [03/04/2009   v1.0.4]
;             6)  Updated man page                         [03/20/2009   v1.0.5]
;             7)  Changed SC Potential keyword to avoid conflicts with
;                   sc_pot.pro calling                     [04/17/2009   v1.0.6]
;             8)  Updated man page                         [06/17/2009   v1.1.0]
;             9)  Added comments and units to calcs        [08/20/2009   v1.1.1]
;            10)  Added error handling and the programs:  
;                   convert_ph_units.pro and dat_3dp_str_names.pro
;                                                          [08/25/2009   v1.2.0]
;            11)  Fixed a typo that ONLY affected Pesa High data structures
;                                                          [04/09/2010   v1.2.1]
;
;   CREATED:  ??/??/????
;   CREATED BY:  Davin Larson
;    LAST MODIFIED:  04/09/2010   v1.2.1
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-


Last Modification =>  2008-06-23/22:23:14 UTC
;+
;PROCEDURE: nul_data
;PURPOSE:
;   Null out a range of tplot data.
;INPUT: none yet
;-


Last Modification =>  2008-06-23/22:23:14 UTC
;+
;FUNCTION:	pad
;PURPOSE:	makes a data pad from a 3d structure
;INPUT:	
;	dat:	A 3d data structure such as those gotten from get_el,get_pl,etc.
;		e.g. "get_el"
;KEYWORDS:
;	bdir:	Add B direction
;	esteps:	Energy steps to use
;	bins:	bins to sum over
;	num_pa:	number of the pad
;
;CREATED BY:	Davin Larson
;LAST MODIFICATION:	@(#)pad.pro	1.21 02/04/17
;-


Last Modification =>  2008-06-23/22:23:14 UTC
;+
;FUNCTION:	pad4
;PURPOSE:	makes a data pad from a 3d structure
;INPUT:	
;	dat:	A 3d data structure such as those gotten from get_el,get_pl,etc.
;		e.g. "get_el"
;KEYWORDS:
;	bdir:	Add B direction
;	esteps:	Energy steps to use
;	bins:	bins to sum over
;	num_pa:	number of the pad
;
;CREATED BY:	Davin Larson
;LAST MODIFICATION:	@(#)pad.pro	1.20 98/07/10
;-


Last Modification =>  2008-06-23/22:23:14 UTC
;+
;FUNCTION  polycurve(x,par=p)
;PURPOSE:
;   Evaluates a (4th degree) polynomial (can be used with "FIT")
;-


Last Modification =>  2008-06-23/22:23:14 UTC
;+
;FUNCTION  power_law(x,par=p)
;PURPOSE:
;   Evaluates a power law function (with background) (can be used with "FIT")
;-


Last Modification =>  2008-06-23/22:23:14 UTC
;+
; NAME:
;	RDPIX2
;
; PURPOSE:
;	Interactively display the X position, Y position, and pixel value 
;	of the cursor.
;
; CATEGORY:
;	Image display.
;
; CALLING SEQUENCE:
;	RDPIX, Image [, X0, Y0]
;
; INPUTS:
;	Image:	The array that represents the image being displayed.  This 
;		array may be of any type.  Rather reading pixel values from 
;		the display, they are taken from this parameter, avoiding 
;		scaling difficulties.
;
; OPTIONAL INPUT PARAMETERS:
;	X0, Y0:	The location of the lower-left corner of the image area on
;		screen.  If these parameters are not supplied, they are
;		assumed to be zero.
;
; OUTPUTS:
;	None.
;
; COMMON BLOCKS:
;	None.
;
; SIDE EFFECTS:
;	The X, Y, and value of the pixel under the cursor are continuously 
;	displayed.
;
; RESTRICTIONS:
;	None.
;
; PROCEDURE:
;	Instructions are printed and the pixel values are printed as the 
;	cursor is moved over the image.
;
;	Press the left or center mouse button to create a new line of output,
;	saving the previous line.
;
;	Press the right mouse button to exit the procedure.
;
; MODIFICATION HISTORY:
;	DMS, Dec, 1987.
;	Rob Montgomery (rob@hao.ucar.edu), 9/21/92;
;		Correct indices for case of !order = 1
;
;-


Last Modification =>  2008-06-23/22:23:14 UTC
;+
;FUNCTION:  data=read_asc(filename)
;PURPOSE:
;   Reads data from an ascii file and puts data in an array of structures.
;   Columns of data should be delimited by spaces.
;   Data is returned as an array of structures. The elements of the structure
;   correspond to the columns of the file.
;CALLING PROCEDURE:
;   read_ascii,data,'file.dat'
;KEYWORDS:
;   TAGS:  If set then the labels in the text line
;      preceeding the data will be used for the default struct tag names.
;      (There should be one label per column of data)
;   FORMAT:  a structure that specifies the output format
;      of the data.  For example if the input file has the
;      following data:
;      Year Day  secs    Vx     Vy     Vz      N
;      1996 123  13.45  512.3  -10.3   10.5   5.3
;      the format could be specified as:
;   FORMAT={year:0,day:0,sec:0.d,v:fltarr(3),n:0.}
;   if this keyword is not specified then a default structure will be created.
;CREATED BY: Davin Larson
;-


Last Modification =>  2009-08-05/13:32:13 UTC
;+
;*****************************************************************************************
;
;  FUNCTION :   rot_mat.pro
;  PURPOSE  :   Creates a rotation matrix that takes two input vectors, V1 and V2, and
;                 rotates them into a new X'-Z' plane, where the V1 vector is along
;                 the new Z'-Axis and V2 is in the X'-Z' plane.
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
;               V1  :  3-Element vector about which you wish to rotate other vectors
;               V2  :  3-Element vector (semi-optional)
;                       [  Default = [1.0,0.0,0.0]  ]
;
;  EXAMPLES:    
;               mrot = rot_mat(v1,v2)
;
;  KEYWORDS:    
;               NA
;
;   CHANGED:  1)  I renormalized the unit vectors to avoid floating point errors
;                   which become important when rotating high energy data
;                                                            [05/23/2008   v1.0.1]
;             2)  Updated man page                           [08/05/2009   v1.1.0]
;
;   CREATED:  ??/??/????
;   CREATED BY:  Davin Larson
;    LAST MODIFIED:  08/05/2009   v1.1.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-


Last Modification =>  2008-06-23/22:23:14 UTC
;+
;FUNCTION:  rotate_data,x,rotmatrix
;INPUT:   several options exist for x:
;    string:    data associated with the string is used.
;    structure: data.y is used
;    1 dimensional array
;    2 dimensional array
;   rotmatrix:   typically a 3 by 3 rotation matrix.
;RETURN VALUE:  Same dimensions and type as the input value of x.
;KEYWORDS:
;   name:  a string that is appended to the input string.
;EXAMPLES:
;   name 
;
;-


Last Modification =>  2009-06-17/21:53:38 UTC
;+
;*****************************************************************************************
;
;  FUNCTION :   rotate_tensor.pro
;  PURPOSE  :   This program attempts to rotate an N-th rank tensor in 3-Dimensions.
;
;  CALLED BY: 
;               mom_rotate.pro
;
;  CALLS:       NA
;
;  REQUIRES:    NA
;
;  INPUT:
;               TENS  :  An N-th Rank Tensor
;               MROT  :  A 3x3 rotation matrix
;
;  EXAMPLES:    NA
;
;  KEYWORDS:    NA
;
;   CHANGED:  1)  Davin Larson created                    [??/??/????   v1.0.0]
;             2)  Re-wrote and cleaned up                 [04/13/2009   v1.1.0]
;             3)  Updated man page                        [06/17/2009   v1.1.1]
;
;   CREATED:  ??/??/????
;   CREATED BY:  Davin Larson
;    LAST MODIFIED:  06/17/2009   v1.1.1
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-


Last Modification =>  2008-06-23/22:23:14 UTC
;+
;FUNCTION splfunc
;USAGE:
;  param = splfunc(x_old,y_old)
;  y = splfunc(x_new,param=p)
;-


Last Modification =>  2008-06-23/22:23:14 UTC
;+
;NAME:
;   time_to_str
;PURPOSE:
;   Obsolete. Use "time_string" instead.
;-


Last Modification =>  2008-06-23/22:23:14 UTC
;+
;PROCEDURE: tsmooth2, name, width, newname=newname
;PURPOSE:
;  Smooths the tplot data. 
;INPUTS: name:	The tplot handle.
;	 width:	Integer array, same dimension as the data.
;
;Documentation not complete.... 	
;
;CREATED BY:     REE 10/11/95
;Modified by:  D Larson.
;LAST MODIFICATION:	%M%
;
;-


Last Modification =>  2009-06-17/22:39:47 UTC
;+
;*****************************************************************************************
;
;  FUNCTION :   velocity.pro
;  PURPOSE  :   Returns the relativistic momentum (over mass = velocity) or
;                 nonrelativistic velocity given the energy and mass.  It can also return
;                 the energy if given a velocity. (~115.86 eV = ~1 Earth Radius/s)
;
;  CALLED BY:   NA
;
;  CALLS:       NA
;
;  REQUIRES:    NA
;
;  INPUT:
;               NRG       :  N-Element array of energies in (eV)
;               MASS      :  Scalar mass [eV/(km/sec)^2] of particles
;
;  EXAMPLES:
;               **[Note:  electron mass = 5.6967578e-06 eV/(km/sec)^2]
;               IDL> masse  = 5.6967578e-06
;               IDL> print, velocity([100.,200.,3000.],masse)
;                      6242.8967       8380.2799       32501.020
;               IDL> print, velocity([100.,200.,3000.],masse,/TRUE)     ; -returns km/s
;                      6241.5435       8377.0076       32311.693
;               IDL> print, velocity([100.,200.,3000.],masse,/INVERSE)  ; -returns eV
;                    0.035094875      0.11393514       25.634768
;
;  KEYWORDS:  
;               TRUE_VELOCITY  :  If set, includes relativistic corrections to velocity 
;                                    calculations
;               MOMEN_ON_MASS  :  [Seems to be obselete]
;               ELECTRON       :  Set if you don't know the electron mass (program 
;                                    figures it out for you)
;               PROTON         :  Set if you don't know the proton mass (program 
;                                    figures it out for you)
;               INVERSE        :  Set if you are giving the program velocities (km/s)
;                                    and expecting energies (eV) in return
;
;   CHANGED:  1)  Davin Larson created                     [??/??/????   v1.0.0]
;             2)  Did some minor "clean up"                [07/10/2008   v1.0.1]
;             2)  Updated man page                         [02/15/2009   v1.0.2]
;             6)  Updated man page                         [06/17/2009   v1.1.0]
;
;   CREATED:  ??/??/????
;   CREATED BY:  Davin Larson
;    LAST MODIFIED:  06/17/2009   v1.1.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-


Last Modification =>  2008-06-23/22:23:14 UTC
;+
;PROCEDURE: xy_edit,x,y,bins
;PURPOSE: 
;   Interactively select data points
;-


Last Modification =>  2008-06-23/22:23:14 UTC
;+
;FUNCTION:  yymmdd_to_time
;PURPOSE:
;    Returns time (seconds since 1970) given date in format:  YYMMDD  HHMM
;USAGE:
;  t = yymmdd_to_time(yymmdd [,hhmm])
;  (yymmdd can be either a long or a string)
;Examples:
;  t = yymmdd_to_time(990421,1422)
;  print,t,' ',time_string(t)
;Created by: Davin Larson, April 1999
;-



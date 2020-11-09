;+
;*****************************************************************************************
;
;  FUNCTION :   lbw_calc_reduced_vdf.pro
;  PURPOSE  :   This routine calculates the reduced velocity distribution function
;                 (VDF) from an input VDF.
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
;               is_a_3_vector.pro
;               is_a_number.pro
;               get_rotated_and_triangulated_vdf.pro
;               simpsons_13_3d_int1dor2d.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               VELS       :  [K,3]-Element [numeric] array of particle velocities [km/s]
;               DATA       :  [K]-Element [numeric] array of phase (velocity) space
;                               densities [e.g., s^(3) cm^(-3) km^(-3)]
;
;  EXAMPLES:    
;               [calling sequence]
;               
;
;  KEYWORDS:    
;               ***  INPUTS  ***
;               VLIM       :  Scalar [numeric] defining the speed limit for the velocity
;                               grids over which to triangulate the data [km/s]
;                               [Default = max vel. magnitude]
;               NGRID      :  Scalar [numeric] defining the number of grid points in each
;                               direction to use when triangulating the data.  The input
;                               will be limited to values between 30 and 300.
;                               [Default = 101]
;               SLICE2D    :  If set, routine will return a 2D slice instead of a 3D
;                               projection
;                               [Default = TRUE]
;               VFRAME     :  [3]-Element [float/double] array defining the 3-vector
;                               velocity of the K'-frame relative to the K-frame [km/s]
;                               to use to transform the velocity distribution into the
;                               bulk flow reference frame
;                               [ Default = [0,0,0] ]
;               VEC1       :  [3]-Element vector to be used for X-direction in
;                               a 3D rotation of the input data
;                               [e.g., see rotate_3dp_structure.pro]
;                               [ Default = [1.,0.,0.] ]
;               VEC2       :  [3]--Element vector to be used with VEC1 to define a 3D
;                               rotation matrix.  The new basis will have the following:
;                                 X'  :  parallel to VEC1
;                                 Z'  :  parallel to (VEC1 x VEC2)
;                                 Y'  :  completes the right-handed set
;                               [ Default = [0.,1.,0.] ]
;               INTD?      :  If set, routine will integrate over the associated dimension
;                               Default:
;                                 INTD1 = FALSE
;                                 INTD2 = TRUE
;                                 INTD3 = TRUE
;               ***  OUTPUT  ***
;               !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
;               ***  [all the following changed on output]  ***
;               !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
;               F3D_QH     :  Set to a named variable to return the 3D array of phase
;                               space densities triangulated onto a regular grid
;                                [e.g., s^(3) cm^(-3) km^(-3)]
;               V1DGRID    :  Set to a named variable to return the 1D array of regularly
;                               gridded velocities [km/s]
;
;   CHANGED:  1)  NA
;                                                                   [MM/DD/YYYY   v1.0.0]
;
;   NOTES:      
;               Velocity moments:
;                 Note:  d^3v --> v_perp dv_perp dv_para dphi --> π |v_perp| dv_perp dv_para
;                             --> dvx dvy dvz  {for cartesian coordinates}
;
;  REFERENCES:  
;               0)  Simpson's 1/3 Rule References:
;                 http://mathfaculty.fullerton.edu/mathews/n2003/SimpsonsRule2DMod.html
;                 http://www.physics.usyd.edu.au/teach_res/mp/doc/math_integration_2D.pdf
;                 https://en.wikipedia.org/wiki/Simpson%27s_rule
;               1)  See IDL's documentation for:
;                     QHULL.PRO:        https://harrisgeospatial.com/docs/qhull.html
;                     QGRID3.PRO:       https://harrisgeospatial.com/docs/QGRID3.html
;                     TRIANGULATE.PRO:  https://harrisgeospatial.com/docs/TRIANGULATE.html
;                     TRIGRID.PRO:      https://harrisgeospatial.com/docs/TRIGRID.html
;               2)  Carlson et al., (1983), "An instrument for rapidly measuring
;                      plasma distribution functions with high resolution,"
;                      Adv. Space Res. Vol. 2, pp. 67-70.
;               3)  Curtis et al., (1989), "On-board data analysis techniques for
;                      space plasma particle instruments," Rev. Sci. Inst. Vol. 60,
;                      pp. 372.
;               4)  Lin et al., (1995), "A Three-Dimensional Plasma and Energetic
;                      particle investigation for the Wind spacecraft," Space Sci. Rev.
;                      Vol. 71, pp. 125.
;               5)  Paschmann, G. and P.W. Daly (1998), "Analysis Methods for Multi-
;                      Spacecraft Data," ISSI Scientific Report, Noordwijk, 
;                      The Netherlands., Int. Space Sci. Inst.
;               6)  Wilson III, L.B., et al., "The Statistical Properties of Solar Wind
;                      Temperature Parameters Near 1 au," Astrophys. J. Suppl. 236(2),
;                      pp. 41, doi:10.3847/1538-4365/aab71c, 2018.
;               7)  Wilson III, L.B., et al., "Electron energy partition across
;                      interplanetary shocks: I. Methodology and Data Product,"
;                      Astrophys. J. Suppl. 243(8), doi:10.3847/1538-4365/ab22bd, 2019a.
;               8)  Wilson III, L.B., et al., "Electron energy partition across
;                      interplanetary shocks: II. Statistics,"
;                      Astrophys. J. Suppl. 245(24), doi:10.3847/1538-4365/ab5445, 2019b.
;               9)  Wilson III, L.B., et al., "Electron energy partition across
;                      interplanetary shocks: III. Analysis,"
;                      Astrophys. J. 893(22), doi:10.3847/1538-4357/ab7d39, 2020.
;
;   CREATED:  08/05/2020
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  08/05/2020   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION lbw_calc_reduced_vdf,vels,data,VLIM=vlim,NGRID=ngrid,SLICE2D=slice2d,VFRAME=vframe,$
                                        VEC1=vec1,VEC2=vec2,F3D_QH=fxyz_3d,V1DGRID=v1dgrid, $
                                        INTD1=intd1,INTD2=intd2,INTD3=intd3,NOMSSG=nomssg

ex_start       = SYSTIME(1)
;;----------------------------------------------------------------------------------------
;;  Define some constants and dummy variables
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
;;  Get fundamental and astronomical
@load_constants_fund_em_atomic_c2014_batch.pro
@load_constants_extra_part_co2014_ci2015_batch.pro
c2             = c[0]^2d0                 ;;  (m/s)^2
ckm            = c[0]*1d-3                ;;  m --> km
ckm2           = ckm[0]^2d0               ;;  (km/s)^2
;;----------------------------------------------------------------------------------------
;;  Defaults
;;----------------------------------------------------------------------------------------
def_vframe     = [0d0,0d0,0d0]          ;;  Assumes km/s units on input
def_vec1       = [1d0,0d0,0d0]
def_vec2       = [0d0,1d0,0d0]
;;----------------------------------------------------------------------------------------
;;  Check input structure format
;;----------------------------------------------------------------------------------------
IF (N_PARAMS() NE 2) THEN RETURN,0b
;;----------------------------------------------------------------------------------------
;;  Check inputs
;;----------------------------------------------------------------------------------------
test           = (is_a_3_vector(vels,V_OUT=swfv,/NOMSSG) EQ 0) OR (is_a_number(data,/NOMSSG) EQ 0)
IF (test[0]) THEN RETURN,0b
;;----------------------------------------------------------------------------------------
;;  Check keywords
;;----------------------------------------------------------------------------------------
;;  Check SLICE2D
IF ((N_ELEMENTS(slice2d) EQ 1) AND ~KEYWORD_SET(slice2d)) THEN slice_on = 0b ELSE slice_on = 1b
;;  Check INTD?
IF ((N_ELEMENTS(intd1) EQ 1) AND KEYWORD_SET(intd1)) THEN dim1_on = 1b ELSE dim1_on = 0b
IF ((N_ELEMENTS(intd2) EQ 1) AND KEYWORD_SET(intd2)) THEN dim2_on = 1b ELSE dim2_on = 0b
IF ((N_ELEMENTS(intd3) EQ 1) AND KEYWORD_SET(intd3)) THEN dim3_on = 1b ELSE dim3_on = 0b
;;  Check dimension integration factors
checks         = [dim1_on[0],dim2_on[0],dim3_on[0]]
IF (TOTAL(checks) EQ 0 OR TOTAL(checks) GT 2) THEN BEGIN
  ;;  Incorrect use of INTD? keywords --> use default
  dim1_on        = 0b
  dim2_on        = 1b
  dim3_on        = 1b
  checks         = [dim1_on[0],dim2_on[0],dim3_on[0]]
ENDIF
good           = WHERE(checks,gd)
CASE gd[0] OF
  1L    :  BEGIN
    ;;  Only integrate over one dimension
    int1d_on       = 1b
    int2d_on       = 0b
    int_dims       = good
  END
  2L    :  BEGIN
    ;;  Integrate over two dimensions
    int1d_on       = 0b
    int2d_on       = 1b
    int_dims       = good
  END
  ELSE  :  STOP     ;;  Shouldn't happen --> debug
ENDCASE
;;----------------------------------------------------------------------------------------
;;  Get rotated and triangulated structures
;;----------------------------------------------------------------------------------------
rt_struc       = get_rotated_and_triangulated_vdf(vels,data,VLIM=vlim,NGRID=ngrid,  $
                                                  SLICE2D=slice_on[0],VFRAME=vframe,$
                                                  VEC1=vec1,VEC2=vec2,F3D_QH=fxyz_3d)
;;  Check output
IF (SIZE(rt_struc,/TYPE) NE 8) THEN STOP
;;  Define relevant parameters
v1dgrid        = rt_struc[0].VX2D
nx             = N_ELEMENTS(v1dgrid)
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Integrate to find reduced VDF
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
x              = v1dgrid
y              = v1dgrid
z              = v1dgrid
ff             = fxyz_3d
;;  Integrate
output         = simpsons_13_3d_int1dor2d(x,y,z,ff,/LOG,/NOMSSG,INTD1=dim1_on[0],INTD2=dim2_on[0],INTD3=dim3_on[0])
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------
ex_time        = SYSTIME(1) - ex_start[0]
IF ~KEYWORD_SET(nomssg) THEN MESSAGE,STRING(ex_time[0])+' seconds execution time.',/CONTINUE,/INFORMATIONAL

RETURN,output
END











































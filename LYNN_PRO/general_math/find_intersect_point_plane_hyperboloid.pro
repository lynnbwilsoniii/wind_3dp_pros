;+
;*****************************************************************************************
;
;  FUNCTION :   find_intersect_point_plane_hyperboloid.pro
;  PURPOSE  :   Finds the 1st intersection point of an infinite, flat plane propagating
;                 along a uniform direction, N_IP, toward a hyperboloid of two-sheets
;                 symmetric about x-axis displaced by Xo -- displacement from focus along
;                 x-axis of origin.  The hyperboloid vertex is at, N_VRX = c + Xo - a,
;                 where c = center of hyperboloid and a is the semi-major axis.
;                 Therefore, the origin relative to the normal definition of a
;                 hyperboloid is at < -(Xo + c), 0, 0 > where c is the center paramter.
;
;                 The paramters are defined as:
;                   L     :  semi-latus rectum
;                         = b^2/a = a (e^2 - 1)
;                   e     :  eccentricity
;                         = sqrt(1 + b^2/a^2)
;                   a     :  semi-major axis
;                         = L/(e^2 - 1)
;                   b     :  semi-minor axis
;                         = L/sqrt(e^2 - 1)
;                   c     :  center
;                         = e L/(e^2 - 1)
;                   Xo    :  displacement of origin from center
;                   Rss   :  standoff distance from origin of nose
;                         = Xo + L/(1 + e) = Xo + (c - a)
;                         = N_VRX
;                   S2    :  surface of hyperboloid of two-sheets
;                         = (y^2 + z^2)/b^2 - [(x - c - Xo)/a]^2 + 1
;                   N_S   :  unit normal of hyperboloid surface
;                         = 2 < -(x - c - Xo)/a^2, y/b^2, z/b^2 >
;                   N_IP  :  unit normal of infinite plane
;
;  CALLED BY:   
;               NA
;
;  INCLUDES:
;               NA
;
;  CALLS:
;               is_a_3_vector.pro
;               unit_vec.pro
;               mag__vec.pro
;               test_plot_axis_range.pro
;               calc_grad_hyperboloid_of_2sheets.pro
;               fill_range.pro
;               my_crossp_2.pro
;               lbw_diff.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               POSI     :  [3]-Element [numeric] array defining the 3-vector position
;                             at the time of crossing the infinite plane [length units]
;                             {hyperboloid default length units are in Earth radii}
;               NIP      :  [3]-Element [numeric] array defining the 3-vector unit
;                             normal vector of the infinite plane
;
;  EXAMPLES:    
;               [calling sequence]
;               intloc = find_intersect_point_plane_hyperboloid(posi, nip [,SEMILR=semilr] $
;                                       [,ECCEN=eccen] [,XXO=xxo] [,NNX=nnx] [,NNY=nny]    $
;                                       [,XRANGE=xrange] [,YRANGE=yrange] [,ZRANGE=zrange] $
;                                       [,NSHOUT=nshout] [,XYZ_INT=xyz_int] [,DELXN=delxn] $
;                                       [,STR_OUT=str_out])
;
;               ;;  ********************************
;               ;;  Example
;               ;;  ********************************
;               posi            = [250d0,25d0,0d0]
;               nip             = REFORM(unit_vec([-0.9d0,-0.1d0,0.1d0]))
;               .compile calc_grad_hyperboloid_of_2sheets.pro
;               .compile find_intersect_point_plane_hyperboloid.pro
;               test            = find_intersect_point_plane_hyperboloid(posi,nip,NSHOUT=nshout,XYZ_INT=xyz_int,DELXN=delxn)
;               ;;  Check inner-product, XYZ-intersection point, and distance along normal
;               nip_dot_nsh     = TOTAL(nip*nshout,/NAN)
;               theta           = ACOS(nip_dot_nsh)*18d1/!DPI
;               PRINT,';;  ',theta[0], xyz_int[0], xyz_int[1], xyz_int[2], delxn[0]
;               ;;         179.99973       13.244093       2.6098170      -2.6098170       236.05710
;
;               ;;  ********************************
;               ;;  Example
;               ;;  ********************************
;               posi            = [250d0,25d0,0d0]
;               nip             = REFORM(unit_vec([-0.99d0, 0.0d0,0.1d0]))
;               .compile calc_grad_hyperboloid_of_2sheets.pro
;               .compile find_intersect_point_plane_hyperboloid.pro
;               test            = find_intersect_point_plane_hyperboloid(posi,nip,NSHOUT=nshout,XYZ_INT=xyz_int,DELXN=delxn)
;               ;;  Check inner-product, XYZ-intersection point, and distance along normal
;               nip_dot_nsh     = TOTAL(nip*nshout,/NAN)
;               theta           = ACOS(nip_dot_nsh)*18d1/!DPI
;               PRINT,';;  ',theta[0], xyz_int[0], xyz_int[1], xyz_int[2], delxn[0]
;               ;;         179.81889       13.336749    -0.074512710      -2.3701781       235.14542
;
;               ;;  ********************************
;               ;;  Example
;               ;;  ********************************
;               posi            = [250d0,25d0,0d0]
;               nip             = REFORM(unit_vec([-0.999d0,-0.1d0,0.0d0]))
;               .compile calc_grad_hyperboloid_of_2sheets.pro
;               .compile find_intersect_point_plane_hyperboloid.pro
;               test            = find_intersect_point_plane_hyperboloid(posi,nip,NSHOUT=nshout,XYZ_INT=xyz_int,DELXN=delxn)
;               ;;  Check inner-product, XYZ-intersection point, and distance along normal
;               nip_dot_nsh     = TOTAL(nip*nshout,/NAN)
;               theta           = ACOS(nip_dot_nsh)*18d1/!DPI
;               PRINT,';;  ',theta[0], xyz_int[0], xyz_int[1], xyz_int[2], delxn[0]
;               ;;         179.81889       13.336749       2.3477120    -0.074512710       237.74121
;
;               ;;  ********************************
;               ;;  Example
;               ;;  ********************************
;               posi            = [250d0,25d0,0d0]
;               nip             = REFORM(unit_vec([-0.999d0, 0.1d0,0.0d0]))
;               .compile calc_grad_hyperboloid_of_2sheets.pro
;               .compile find_intersect_point_plane_hyperboloid.pro
;               test            = find_intersect_point_plane_hyperboloid(posi,nip,NSHOUT=nshout,XYZ_INT=xyz_int,DELXN=delxn)
;               ;;  Check inner-product, XYZ-intersection point, and distance along normal
;               nip_dot_nsh     = TOTAL(nip*nshout,/NAN)
;               theta           = ACOS(nip_dot_nsh)*18d1/!DPI
;               PRINT,';;  ',theta[0], xyz_int[0], xyz_int[1], xyz_int[2], delxn[0]
;               ;;         179.81889       13.336749      -2.3477120    -0.074512710       232.76153
;
;  KEYWORDS:    
;               SEMILR   :  Scalar [numeric] defining the semi-latus rectum of the
;                             hyperboloid of two-sheets
;                             [Default = 23.3 Re]
;               ECCEN    :  Scalar [numeric] defining the eccentricity of the
;                             hyperboloid of two-sheets
;                             [Default = 1.16]
;               XXO      :  Scalar [numeric] defining the offset from the focus of the
;                             hyperboloid of two-sheets
;                             [Default = 3.0 Re]
;               NNX      :  Scalar [numeric] defining the number of grid points along X
;                             [Default = 100]
;               NNY      :  Scalar [numeric] defining the number of grid points along Y
;                             [Default = 200]
;               ?RANGE   :  [2]-Element [numeric] array defining the ? = {X,Y,Z} range
;                             of cartesian coordinates to use when constructing the
;                             dummy grid/mesh of the HoTS
;                             [Default = range by quadrants depending on location of interest]
;               ***  OUTPUT  ***
;               !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
;               ***  [all the following changed on output]  ***
;               !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
;               NSHOUT   :  Set to a named variable to return the outward normal of the
;                             model hyperboloid used to define the intersection point
;               XYZ_INT  :  Set to a named variable to return the {X,Y,Z} coordinates of
;                             the first point of intersection on the HoTS
;               DELXN    :  Set to a named variable to return the magnitude of the
;                             distance along the normal between POSI and XYZ_INT
;               STR_OUT  :  Set to a named variable to return the relevant HoTS parameters
;                             used to construct the HoTS, the range allowed, and both
;                             the outward unit normal and manifold surface scalar metric
;
;   CHANGED:  1)  Now tries to focus the range of Y and Z values generated to increase
;                   resolution based upon NIP and
;                   added keywords:  NNX and NNY
;                                                                   [10/22/2019   v1.0.1]
;             2)  Now calls calc_grad_hyperboloid_of_2sheets.pro and
;                   added keywords:  [X,Y,Z]RANGE and XYZ_INT and DELXN and STR_OUT
;                                                                   [02/18/2020   v2.0.0]
;
;   NOTES:      
;               1)  Make sure to keep units uniform between POSI, SEMILR, and XXO
;               2)  The routine assumes any aberrations etc. have been handled outside/
;                     before calling, thus all outputs are in a coordinate basis aligned
;                     with the symmetry axis of the hyperboloid.
;               3)  By reducing the hyperboloid surface to the quadrant of the expected
;                     intersection, the solution is significantly more accurate.
;
;  REFERENCES:  
;               1)  https://en.wikipedia.org/wiki/Hyperboloid
;               2)  http://mathworld.wolfram.com/Two-SheetedHyperboloid.html
;               3)  J.A. Slavin and R.E. Holzer "Solar wind flow about the terrestrial
;                      planets 1. Modeling bow shock position and shape," J. Geophys. Res.
;                      Vol. 86(A13), pp. 11,401--11,418, doi:10.1029/JA086iA13p11401, 1981.
;
;   CREATED:  04/02/2019
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  02/18/2020   v2.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION find_intersect_point_plane_hyperboloid,posi,nip,SEMILR=semilr,ECCEN=eccen,   $
                                                XXO=xxo,NNX=nnx,NNY=nny,XRANGE=xrange,$
                                                YRANGE=yrange,ZRANGE=zrange,          $
                                                NSHOUT=nshout,XYZ_INT=xyz_int,        $
                                                DELXN=delxn,STR_OUT=str_out

;;----------------------------------------------------------------------------------------
;;  Constants
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
;;  Define defaults
def__L         = 23.3d0                                     ;;  Default semi-latus rectum [Re]
def__e         = 1.16d0                                     ;;  Default eccentricity
def_xo         = 3d0                                        ;;  Default focus offset [Re]
def__a         = def__L[0]/(def__e[0]^2 - 1d0)              ;;  Default semi-major axis
def__b         = def__L[0]/SQRT(def__e[0]^2 - 1d0)          ;;  Default semi-minor axis
def__c         = def__L[0]*def__e[0]/(def__e[0]^2 - 1d0)    ;;  Default center/focus
def_so         = def_xo[0] + (def__c[0] - def__a[0])        ;;  Default standoff distance from origin of nose of hyperboloid
IF (def_so[0] GT 0) THEN BEGIN
  ;;  standoff is positive --> origin is shifted from normal location
  def_xran  = def_so[0]*(1d0 + [-1.75d0,2d-2])
ENDIF ELSE BEGIN
  ;;  standoff is negative --> origin may be at normal location
  def_xran  = def_so[0]*(1d0 + [5d-1,-2d-2])
ENDELSE
def_yran       = def__L[0]*SQRT(2d0)*[-1,1]
def_zran       = def_yran
def_nx         = 100L                                       ;;  Default Nx
def_ny         = 200L                                       ;;  Default Ny
yzero          = 0b                                         ;;  Logic:  TRUE --> NIP[1] = 0
zzero          = 0b                                         ;;  Logic:  TRUE --> NIP[2] = 0
quad           = 0                                          ;;  Numeric value for quadrant
;;  Dummy error messages
noinpt_msg     = 'No input supplied...'
notvec_msg     = 'Both POSI and NIP must be numeric 3-vectors...'
;;----------------------------------------------------------------------------------------
;;  Check input
;;----------------------------------------------------------------------------------------
IF (N_PARAMS() NE 2) THEN BEGIN
  ;;  no input???
  MESSAGE,noinpt_msg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
test           = (is_a_3_vector(posi,V_OUT=pout,/NOMSSG) EQ 0) OR (is_a_3_vector(nip,V_OUT=nout,/NOMSSG) EQ 0)
IF (test[0]) THEN BEGIN
  MESSAGE,notvec_msg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
;;  Define parameters
n_ip           = REFORM(unit_vec(nout,/NAN))
pmag           = (mag__vec(pout,/NAN))[0]
;;----------------------------------------------------------------------------------------
;;  Define quadrant in YZ-plane to search based upon NIP
;;----------------------------------------------------------------------------------------
all_quads      = REPLICATE(1b,5L)       ;;  Logic test for quadrants
;;    Y < 0    :  II or III
;;    Y > 0    :  I or IV
IF (n_ip[1] NE 0) THEN BEGIN
  IF (n_ip[1] LT 0) THEN BEGIN
    ;;  Quadrant I or IV
    all_quads[[2,3]] = 0b
  ENDIF ELSE BEGIN
    ;;  Quadrant II or III
    all_quads[[1,4]] = 0b
  ENDELSE
ENDIF ELSE BEGIN
  ;;  Y = 0    :  (I & II) or (III & IV)
  yzero  = 1b
ENDELSE
;;    Z < 0    :  I or II
;;    Z > 0    :  III or IV
IF (n_ip[2] NE 0) THEN BEGIN
  IF (n_ip[2] LT 0) THEN BEGIN
    ;;  Quadrant III or IV
    all_quads[[1,2]] = 0b
  ENDIF ELSE BEGIN
    ;;  Quadrant I or II
    all_quads[[3,4]] = 0b
  ENDELSE
ENDIF ELSE BEGIN
  ;;  Z = 0    :  (I & IV) or (II & III)
  zzero  = 1b
ENDELSE
;;--------------------------------------
;;  Define good quadrant
;;--------------------------------------
good_quad      = WHERE(all_quads,gd_quad)
IF (gd_quad[0] LE 1) THEN BEGIN
  ;;--------------------------------------------------------------------------------------
  ;;  Use nose
  ;;--------------------------------------------------------------------------------------
  quad = 0
ENDIF ELSE BEGIN
  ;;--------------------------------------------------------------------------------------
  ;;  Check if NIP is either on Y = 0 or Z = 0 line
  ;;--------------------------------------------------------------------------------------
  IF (yzero[0] OR zzero[0]) THEN BEGIN
    ;;------------------------------------------------------------------------------------
    ;;  Two quadrants are required
    ;;------------------------------------------------------------------------------------
    IF (yzero[0] AND zzero[0]) THEN BEGIN
      ;;----------------------------------------------------------------------------------
      ;;  Use nose
      ;;----------------------------------------------------------------------------------
      quad = 0
    ENDIF ELSE BEGIN
      ;;----------------------------------------------------------------------------------
      ;;  Cut the default Y and Z ranges in half
      ;;----------------------------------------------------------------------------------
      CASE 1 OF
        yzero[0]  :  BEGIN
          def_yran *= 5d-1
          IF (n_ip[2] LT 0) THEN quad = 5 ELSE quad = 6
        END
        zzero[0]  :  BEGIN
          def_zran *= 5d-1
          IF (n_ip[1] LT 0) THEN quad = 7 ELSE quad = 8
        END
        ELSE      :  STOP   ;; should not be possible
      ENDCASE
    ENDELSE
  ENDIF ELSE BEGIN
    ;;------------------------------------------------------------------------------------
    ;;  Single quadrant will suffice
    ;;------------------------------------------------------------------------------------
    quad = FIX(good_quad[1] - 1L)
  ENDELSE
ENDELSE
;;----------------------------------------------------------------------------------------
;;  Check keywords
;;----------------------------------------------------------------------------------------
;;  Check [X,Y,Z]RANGE
IF (test_plot_axis_range(xrange,/NOMSSG) EQ 0) THEN xran = def_xran ELSE xran = DOUBLE(xrange.SORT())
IF (test_plot_axis_range(yrange,/NOMSSG) EQ 0) THEN yran = def_yran ELSE yran = DOUBLE(yrange.SORT())
IF (test_plot_axis_range(zrange,/NOMSSG) EQ 0) THEN zran = def_zran ELSE zran = DOUBLE(zrange.SORT())
;;----------------------------------------------------------------------------------------
;;  Use gradient of the surface equation for a hyperboloid of two sheets with axis of
;;    symmetry along X-axis to define shock normal:
;;               (x - Ao)^2     (y - yo)^2     (z - zo)^2
;;  S(x,y,z) = - ----------  +  ----------  +  ----------  +  1  =  0
;;                  a^2            b^2            b^2
;;
;;   where:  a = semi-major axis, b = semi-minor axis, and
;;             [A,y,z]o = location of center, Ao = (c + Xo)
;;----------------------------------------------------------------------------------------
test           = calc_grad_hyperboloid_of_2sheets(NNX=nnx,NNY=nny,SEMILR=semilr,ECCEN=eccen, $
                                       XXO=xxo,QUAD=quad,XRANGE=xran,YRANGE=yran,ZRANGE=zran,$
                                       STR_OUT=hots_out)
IF (~test[0]) THEN RETURN,0b
;;----------------------------------------------------------------------------------------
;;  Define hyperboloid parameters
;;----------------------------------------------------------------------------------------
LL             = hots_out[0].SEMILR[0]                 ;;  semi-latus rectum
ee             = hots_out[0].ECCEN[0]                  ;;  eccentricity
xo             = hots_out[0].XXO[0]                    ;;  offset from the focus
nx             = hots_out[0].NX[0]                     ;;  # of X grid/mesh points
ny             = hots_out[0].NY[0]                     ;;  # of Y grid/mesh points
nz             = hots_out[0].NZ[0]                     ;;  # of Z grid/mesh points
a              = hots_out[0].SEMIMAJ[0]                ;;  semi-major axis
b              = hots_out[0].SEMIMIN[0]                ;;  semi-minor axis
c              = hots_out[0].CENTER[0]                 ;;  center/focus
n_vrx          = hots_out[0].STXOFF[0]                 ;;  standoff distance from origin of nose
xran           = hots_out[0].XRANGE                    ;;  Range of X grid/mesh values
yran           = hots_out[0].YRANGE                    ;;  Range of Y grid/mesh values
zran           = hots_out[0].ZRANGE                    ;;  Range of Z grid/mesh values
n_s            = hots_out[0].N_OUT                     ;;  Valid outward unit normal vectors
sur            = hots_out[0].SURF_SOLN                 ;;  Valid manifold surface scalar metric values
;;  Clean up
hots_out       = 0
;;  Define dummy arrays of abscissa for surface
xx             = fill_range(xran[0],xran[1],UNIFORM=nx[0])
yy             = fill_range(yran[0],yran[1],UNIFORM=ny[0])
zz             = fill_range(zran[0],zran[1],UNIFORM=nz[0])
;;----------------------------------------------------------------------------------------
;;  Minimize the magnitude of the outer-product
;;    |N_S x N_IP|
;;  Maximize the magnitude of the inner-product
;;    |N_S . N_IP|
;;----------------------------------------------------------------------------------------
ns_2d          = REFORM(n_s,nx[0]*ny[0]*ny[0],3L)
ns_x_nip       = my_crossp_2(ns_2d,n_ip,/NOM)
nsxnip_mag     = mag__vec(ns_x_nip,/NAN)
nip2d          = REPLICATE(-1d0,nx[0]*ny[0]*ny[0]) # n_ip
ns_d_nip       = TOTAL(ns_2d*nip2d,2,/NAN)
;;  Find max/min indices and compare
mn_op          = MIN(nsxnip_mag,inop,/NAN)
mx_ip          = MAX(ns_d_nip,ixip,/NAN)
inop3d         = ARRAY_INDICES(sur,inop)
ixip3d         = ARRAY_INDICES(sur,ixip)
xyz_int_in     = [xx[inop3d[0]],yy[inop3d[1]],zz[inop3d[2]]]
xyz_int_ix     = [xx[ixip3d[0]],yy[ixip3d[1]],zz[ixip3d[2]]]
nsh_int_in     = REFORM(ns_2d[inop[0],*])
nsh_int_ix     = REFORM(ns_2d[ixip[0],*])
;;----------------------------------------------------------------------------------------
;;  Minimize the magnitude of the difference
;;    |N_S - N_IP|
;;----------------------------------------------------------------------------------------
ns___nip       = lbw_diff(ns_2d,nip2d,/NAN)
diff_mag       = mag__vec(ns___nip,/NAN)
mn_diff        = MIN(diff_mag,idff,/NAN)
idff3d         = ARRAY_INDICES(sur,idff)
xyz_int_df     = [xx[idff3d[0]],yy[idff3d[1]],zz[idff3d[2]]]
nsh_int_df     = REFORM(ns_2d[idff[0],*])
;;  Find median of results
all_xyz_int    = [[xyz_int_in],[xyz_int_ix],[xyz_int_df]]
med_xyz_int    = MEDIAN(all_xyz_int,DIMENSION=2)
;avg_xyz_int    = MEAN(all_xyz_int,DIMENSION=2,/NAN)
all_nsh_int    = [[nsh_int_in],[nsh_int_ix],[nsh_int_df]]
med_nsh_int    = MEDIAN(all_nsh_int,DIMENSION=2)
;avg_nsh_int    = MEAN(all_nsh_int,DIMENSION=2,/NAN)
;;  Clean up
n_s      = 0 & ns_2d    = 0 & ns_x_nip = 0 & nsxnip_mag = 0 & nip2d = 0 & ns_d_nip = 0
ns___nip = 0 & diff_mag = 0 & sur      = 0 & xx         = 0 & yy    = 0 & zz       = 0
;;----------------------------------------------------------------------------------------
;;  Refine grid/mesh and re-calculate
;;----------------------------------------------------------------------------------------
pert           = [-1,1]
xyz_int_start  = med_xyz_int
xran_new       = xyz_int_start[0]*(1d0 + pert*1d-1)
yran_new       = xyz_int_start[1]*(1d0 + pert*1d-1)
zran_new       = xyz_int_start[2]*(1d0 + pert*1d-1)
IF (xyz_int_start[1] EQ 0 OR xyz_int_start[2] EQ 0) THEN BEGIN
  IF (xyz_int_start[1] EQ 0 AND xyz_int_start[2] EQ 0) THEN BEGIN
    quad = 0
  ENDIF ELSE BEGIN
    IF (xyz_int_start[1] EQ 0) THEN BEGIN
      ;;  qaud = 5 or 6
      quad = ([5,6])[(xyz_int_start[2] LT 0)]
    ENDIF ELSE BEGIN
      ;;  qaud = 7 or 8
      quad = ([7,8])[(xyz_int_start[1] LT 0)]
    ENDELSE
  ENDELSE
ENDIF ELSE BEGIN
  IF (xyz_int_start[1] GT 0) THEN BEGIN
    ;;  qaud = 1 or 4
    quad = ([1,4])[(xyz_int_start[2] LT 0)]
  ENDIF ELSE BEGIN
    ;;  qaud = 2 or 3
    quad = ([2,3])[(xyz_int_start[2] LT 0)]
  ENDELSE
ENDELSE
test           = calc_grad_hyperboloid_of_2sheets(NNX=nx,NNY=ny,SEMILR=LL,ECCEN=ee, $
                                                  XXO=xo,QUAD=quad,XRANGE=xran_new, $
                                                  YRANGE=yran_new,ZRANGE=zran_new,  $
                                                  STR_OUT=hots_out)
;IF (~test[0]) THEN RETURN,0b
IF (~test[0]) THEN STOP
;;----------------------------------------------------------------------------------------
;;  Define relevant hyperboloid parameters
;;----------------------------------------------------------------------------------------
nx             = hots_out[0].NX[0]                     ;;  # of X grid/mesh points
ny             = hots_out[0].NY[0]                     ;;  # of Y grid/mesh points
nz             = hots_out[0].NZ[0]                     ;;  # of Z grid/mesh points
n_s            = hots_out[0].N_OUT                     ;;  Valid outward unit normal vectors
sur            = hots_out[0].SURF_SOLN                 ;;  Valid manifold surface scalar metric values
;;  Define dummy arrays of abscissa for surface
xx             = fill_range(xran_new[0],xran_new[1],UNIFORM=nx[0])
yy             = fill_range(yran_new[0],yran_new[1],UNIFORM=ny[0])
zz             = fill_range(zran_new[0],zran_new[1],UNIFORM=nz[0])
;;  Minimize the magnitude of the outer-product
;;    |N_S x N_IP|
ns_2d          = REFORM(n_s,nx[0]*ny[0]*ny[0],3L)
ns_x_nip       = my_crossp_2(ns_2d,n_ip,/NOM)
nsxnip_mag     = mag__vec(ns_x_nip,/NAN)
mn_op          = MIN(nsxnip_mag,inop,/NAN)
inop3d         = ARRAY_INDICES(sur,inop)
xyz_int_in     = [xx[inop3d[0]],yy[inop3d[1]],zz[inop3d[2]]]
nsh_int_in     = REFORM(ns_2d[inop[0],*])
;;  Maximize the magnitude of the inner-product
;;    |N_S . N_IP|
nip2d          = REPLICATE(-1d0,nx[0]*ny[0]*ny[0]) # n_ip
ns_d_nip       = TOTAL(ns_2d*nip2d,2,/NAN)
mx_ip          = MAX(ns_d_nip,ixip,/NAN)
ixip3d         = ARRAY_INDICES(sur,ixip)
xyz_int_ix     = [xx[ixip3d[0]],yy[ixip3d[1]],zz[ixip3d[2]]]
nsh_int_ix     = REFORM(ns_2d[ixip[0],*])
;;  Minimize the magnitude of the difference
;;    |N_S - N_IP|
ns___nip       = lbw_diff(ns_2d,nip2d,/NAN)
diff_mag       = mag__vec(ns___nip,/NAN)
mn_diff        = MIN(diff_mag,idff,/NAN)
idff3d         = ARRAY_INDICES(sur,idff)
xyz_int_df     = [xx[idff3d[0]],yy[idff3d[1]],zz[idff3d[2]]]
nsh_int_df     = REFORM(ns_2d[idff[0],*])
;;----------------------------------------------------------------------------------------
;;  Define intersection as median of all three methods
;;----------------------------------------------------------------------------------------
all_xyz_int    = [[xyz_int_in],[xyz_int_ix],[xyz_int_df]]
all_nsh_int    = [[nsh_int_in],[nsh_int_ix],[nsh_int_df]]
;;  Find median of results
med_xyz_int    = MEDIAN(all_xyz_int,DIMENSION=2)
med_nsh_int    = MEDIAN(all_nsh_int,DIMENSION=2)
;;  Check validity of results
valid          = (TOTAL(FINITE(sur)) GT 5)
;;  Clean up
n_s      = 0 & ns_2d    = 0 & ns_x_nip = 0 & nsxnip_mag = 0 & nip2d = 0 & ns_d_nip = 0
ns___nip = 0 & diff_mag = 0 & sur      = 0
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Define outputs
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Define output structure
str_out        = hots_out[0]
;;  Define output keywords
nshout         = REFORM(med_nsh_int)
xyz_int        = REFORM(med_xyz_int)
;;  Calculate (P - {X,Y,Z}) . N_sh
del_pxyz       = lbw_diff(REFORM(pout,1,3),REFORM(med_xyz_int,1,3),/NAN)
del_d_nsh      = TOTAL(del_pxyz*REFORM(med_nsh_int,1,3),2,/NAN)
delxn          = ABS(del_d_nsh[0])
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN,valid
END


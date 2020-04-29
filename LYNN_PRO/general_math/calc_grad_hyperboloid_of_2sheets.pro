;+
;*****************************************************************************************
;
;  FUNCTION :   calc_grad_hyperboloid_of_2sheets.pro
;  PURPOSE  :   Creates a 3D mesh of the gradient of a hyperboloid of two-sheets (HoTS)
;                 given the hyperboloid parameters, quadrant of interest, and cartesian
;                 coordinate range of values allowed.
;
;  CALLED BY:   
;               NA
;
;  INCLUDES:
;               NA
;
;  CALLS:
;               is_a_number.pro
;               test_plot_axis_range.pro
;               fill_range.pro
;               unit_vec.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;               2)  IDL Version ≥8.4
;
;  INPUT:
;               NA
;
;  EXAMPLES:    
;               [calling sequence]
;               test = calc_grad_hyperboloid_of_2sheets( [,NNX=nnx] [,NNY=nny] [,SEMILR=semilr] $
;                                            [,ECCEN=eccen] [,XXO=xxo] [,QUAD=quad]             $
;                                            [,XRANGE=xrange] [,YRANGE=yrange] [,ZRANGE=zrange] $
;                                            [,STR_OUT=hots_out]                                )
;
;  KEYWORDS:    
;               NNX      :  Scalar [numeric] defining the number of grid points along X
;                             [Default = 100]
;               NNY      :  Scalar [numeric] defining the number of grid points along Y
;                             [Default = 200]
;               SEMILR   :  Scalar [numeric] defining the semi-latus rectum of the
;                             hyperboloid of two-sheets
;                             [Default = 23.3 Re]
;               ECCEN    :  Scalar [numeric] defining the eccentricity of the HoTS
;                             [Default = 1.16]
;               XXO      :  Scalar [numeric] defining the offset from the focus of the HoTS
;                             [Default = 3.0 Re]
;               QUAD     :  Scalar [numeric] defining the nearest quadrant of interest
;                             where the following are defined:
;                               0  :  Nose               --> (Y = 0 & Z = 0)
;                               1  :  Quadrant I         --> (Y > 0 & Z > 0)
;                               2  :  Quadrant II        --> (Y < 0 & Z > 0)
;                               3  :  Quadrant III       --> (Y < 0 & Z < 0)
;                               4  :  Quadrant IV        --> (Y > 0 & Z < 0)
;                               5  :  Quadrants I & II   --> (Y = 0 & Z > 0)
;                               6  :  Quadrants III & IV --> (Y = 0 & Z < 0)
;                               7  :  Quadrants I & IV   --> (Y > 0 & Z = 0)
;                               8  :  Quadrants II & III --> (Y < 0 & Z = 0)
;                             [Default = 0]
;               ?RANGE   :  [2]-Element [numeric] array defining the ? = {X,Y,Z} range
;                             of cartesian coordinates to use when constructing the
;                             dummy grid/mesh of the HoTS
;                             [Default = range by quadrants depending on location of interest]
;               ***  OUTPUT  ***
;               !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
;               ***  [all the following changed on output]  ***
;               !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
;               STR_OUT  :  Set to a named variable to return the relevant HoTS parameters
;                             used to construct the HoTS, the range allowed, and both
;                             the outward unit normal and manifold surface scalar metric
;
;   CHANGED:  1)  NA
;                                                                   [MM/DD/YYYY   v1.0.0]
;
;   NOTES:      
;               0)  See also:  find_intersect_point_plane_hyperboloid.pro
;               1)  Make sure to keep units uniform between ?RANGE, SEMILR, and XXO
;               2)  The routine assumes any aberrations etc. have been handled outside/
;                     before calling, thus all outputs are in a coordinate basis aligned
;                     with the symmetry axis of the hyperboloid.
;               3)  By reducing the hyperboloid surface to the quadrant of interest,
;                     the solution grid/mesh is significantly more refined/resolved.
;
;  REFERENCES:  
;               1)  https://en.wikipedia.org/wiki/Hyperboloid
;               2)  http://mathworld.wolfram.com/Two-SheetedHyperboloid.html
;               3)  J.A. Slavin and R.E. Holzer "Solar wind flow about the terrestrial
;                      planets 1. Modeling bow shock position and shape," J. Geophys. Res.
;                      Vol. 86(A13), pp. 11,401--11,418, doi:10.1029/JA086iA13p11401, 1981.
;
;   CREATED:  02/18/2020
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  02/18/2020   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION calc_grad_hyperboloid_of_2sheets,NNX=nnx,NNY=nny,SEMILR=semilr,ECCEN=eccen,    $
                                          XXO=xxo,QUAD=quad,XRANGE=xrange,YRANGE=yrange,$
                                          ZRANGE=zrange,STR_OUT=hots_out

;;----------------------------------------------------------------------------------------
;;  Constants
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
;;  Define defaults
def__L         = 23.3d0                    ;;  Default semi-latus rectum [Re]
def__e         = 1.16d0                    ;;  Default eccentricity
def_xo         = 3d0                       ;;  Default focus offset [Re]
def_nx         = 100L                      ;;  Default Nx
def_ny         = 200L                      ;;  Default Ny
def_qd         = 0                         ;;  Default quadrant center is nose of HoTS
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Check keywords
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Check SEMILR
IF (is_a_number(semilr,/NOMSSG) EQ 0) THEN LL = def__L[0] ELSE LL = ABS(semilr[0]) > 1d0
;;  Check ECCEN
IF (is_a_number(eccen,/NOMSSG) EQ 0) THEN ee = def__e[0] ELSE ee = ABS(eccen[0]) > 1.0001d0
;;  Check XXO
IF (is_a_number(xxo,/NOMSSG) EQ 0) THEN xo = def_xo[0] ELSE xo = 1d0*xxo[0]
;;  Check NNX[Y]
IF (is_a_number(nnx,/NOMSSG) EQ 0) THEN nx = def_nx[0] ELSE nx = LONG(ABS(nnx[0]))
IF (is_a_number(nny,/NOMSSG) EQ 0) THEN ny = def_ny[0] ELSE ny = LONG(ABS(nny[0]))
;;  Check QUAD
IF (is_a_number(quad,/NOMSSG) EQ 0) THEN qd = def_qd[0] ELSE qd = (FIX(ABS(quad[0])) > 0) < 4
;;-----------------------------------------------
;;  Define HoTS parameters
;;    a = L/[e^2 - 1]
;;    b = L/[e^2 - 1]^(1/2)   = a*[e^2 - 1]^(1/2)
;;    c = e*L/[e^2 - 1]       = e*a
;;    o = Xo + (c - a)        = Xo + a (e - 1)
;;-----------------------------------------------
a              = LL[0]/(ee[0]^2 - 1d0)             ;;  semi-major axis
b              = LL[0]/SQRT(ee[0]^2 - 1d0)         ;;  semi-minor axis
c              = LL[0]*ee[0]/(ee[0]^2 - 1d0)       ;;  center/focus
n_vrx          = xo[0] + (c[0] - a[0])             ;;  standoff distance from origin of nose of hyperboloid
IF (n_vrx[0] GT 0) THEN BEGIN
  ;;  standoff is positive --> origin is shifted from normal location
  def_xran  = n_vrx[0]*(1d0 + [-1.75d0,2d-2])
ENDIF ELSE BEGIN
  ;;  standoff is negative --> origin may be at normal location
  def_xran  = n_vrx[0]*(1d0 + [5d-1,-2d-2])
ENDELSE
;;-----------------------------------------------
;;  Define default ranges from quadrant setting
;;-----------------------------------------------
CASE qd[0] OF
  0     :  BEGIN               ;;  Nose
    def_ymin  =  -1d15
    def_ymax  =   1d15
    def_zmin  =  -1d15
    def_zmax  =   1d15
  END
  1     :  BEGIN               ;;  Quadrant I         --> (Y > 0 & Z > 0)
    def_ymin  =    0d0
    def_ymax  =   1d30
    def_zmin  =    0d0
    def_zmax  =   1d30
  END
  2     :  BEGIN               ;;  Quadrant II        --> (Y < 0 & Z > 0)
    def_ymax  =    0d0
    def_ymin  =  -1d30
    def_zmin  =    0d0
    def_zmax  =   1d30
  END
  3     :  BEGIN               ;;  Quadrant III       --> (Y < 0 & Z < 0)
    def_ymax  =    0d0
    def_ymin  =  -1d30
    def_zmax  =    0d0
    def_zmin  =  -1d30
  END
  4     :  BEGIN               ;;  Quadrant IV        --> (Y > 0 & Z < 0)
    def_ymin  =    0d0
    def_ymax  =   1d30
    def_zmax  =    0d0
    def_zmin  =  -1d30
  END
  5     :  BEGIN               ;;  Quadrants I & II   --> (Y = 0 & Z > 0)
    def_ymin  =  -1d15
    def_ymax  =   1d15
    def_zmin  =    0d0
    def_zmax  =   1d30
  END
  6     :  BEGIN               ;;  Quadrants III & IV --> (Y = 0 & Z < 0)
    def_ymin  =  -1d15
    def_ymax  =   1d15
    def_zmax  =    0d0
    def_zmin  =  -1d30
  END
  7     :  BEGIN               ;;  Quadrants I & IV   --> (Y > 0 & Z = 0)
    def_ymin  =    0d0
    def_ymax  =   1d30
    def_zmin  =  -1d15
    def_zmax  =   1d15
  END
  8     :  BEGIN               ;;  Quadrants II & III --> (Y < 0 & Z = 0)
    def_ymax  =    0d0
    def_ymin  =  -1d30
    def_zmin  =  -1d15
    def_zmax  =   1d15
  END
  ELSE  :  STOP ;;  should not happen...???
ENDCASE
def_yran       = LL[0]*SQRT(2d0)*[-1,1]
def_zran       = def_yran
def_yran[0]    = def_yran[0] > def_ymin[0]
def_yran[1]    = def_yran[1] < def_ymax[0]
def_zran[0]    = def_zran[0] > def_zmin[0]
def_zran[1]    = def_zran[1] < def_zmax[0]
;;  Check [X,Y,Z]RANGE
IF (test_plot_axis_range(xrange,/NOMSSG) EQ 0) THEN xran = def_xran ELSE xran = DOUBLE(xrange.SORT())
IF (test_plot_axis_range(yrange,/NOMSSG) EQ 0) THEN yran = def_yran ELSE yran = DOUBLE(yrange.SORT())
IF (test_plot_axis_range(zrange,/NOMSSG) EQ 0) THEN zran = def_zran ELSE zran = DOUBLE(zrange.SORT())
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Construct gradient of HoTS
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Define arrays of abscissa for surface
xx             = fill_range(xran[0],xran[1],UNIFORM=nx[0])
yy             = fill_range(yran[0],yran[1],UNIFORM=ny[0])
zz             = fill_range(zran[0],zran[1],UNIFORM=ny[0])
;;----------------------------------------------------------------------------------------
;;  Use gradient of the surface equation for a HoTS with axis of symmetry along
;;    X-axis to define shock normal:
;;               (x - Ao)^2     (y - yo)^2     (z - zo)^2
;;  S(x,y,z) = - ----------  +  ----------  +  ----------  +  1  =  0
;;                  a^2            b^2            b^2
;;
;;               (x - Ao)^2     (y - yo)^2 + (z - zo)^2
;;           = - ----------  +  -----------------------  +  1  =  0
;;                  a^2                   b^2
;;
;;               (x - Ao)^2     (y^2 + z^2)
;;           = - ----------  +  -----------  +  1  =  0  { for  yo  =  zo  =  0 }
;;                  a^2             b^2
;;
;;   where:  a = semi-major axis, b = semi-minor axis, and
;;             [A,y,z]o = location of center, Ao = (c + Xo)
;;----------------------------------------------------------------------------------------
;;  ∂S/∂x = N_SX = -2 (x - c - Xo)/a^2
n_sx           = -2d0*(xx - c[0] - xo[0])/a[0]^2d0
;;  ∂S/∂y = N_SY = +2 y/b^2
n_sy           = 2d0*yy/b[0]^2d0
;;  ∂S/∂z = N_SZ = +2 z/b^2
n_sz           = 2d0*zz/b[0]^2d0
;;  Construct dummy variables
n_s            = REPLICATE(d,nx[0],ny[0],ny[0],3L)             ;;  [Nx,Ny,Nz,3]-Element array
sur            = n_s[*,*,*,0]                                  ;;  [Nx,Ny,Nz]-Element array
oney           = REPLICATE(1d0,ny[0])                          ;;  [Ny]-Element array
;;  Loop through indices
FOR i=0L, nx[0] - 1L DO BEGIN
  tempx       = oney # n_sx[i]
  FOR j=0L, ny[0] - 1L DO BEGIN
    tempy         = oney # n_sy[j]
    temp          = [[tempx],[tempy],[n_sz]]
    ut            = unit_vec(temp,/NAN)
    n_s[i,j,*,0]  = REFORM(ut[*,0])
    n_s[i,j,*,1]  = REFORM(ut[*,1])
    n_s[i,j,*,2]  = REFORM(ut[*,2])
    ;;  Keep only the elements that lie on the surface
    check         = 1d0 + ((yy[j]^2d0 + zz^2d0)/b[0]^2d0) - ((xx[i] - c[0] - xo[0])/a[0])^2d0
;    check         = 1d0 + ((yy[j] + zz)/b[0])^2d0 - ((xx[i] - c[0] - xo[0])/a[0])^2d0
    sur[i,j,*]    = check
    bad_chck      = WHERE(ABS(check) GT 1d-2,bd_chck)
    IF (bd_chck[0] GT 0) THEN BEGIN
      ;;  Remove unphysical normals
      n_s[i,j,bad_chck,0]  = d
      n_s[i,j,bad_chck,1]  = d
      n_s[i,j,bad_chck,2]  = d
      sur[i,j,bad_chck]    = d
    ENDIF
  ENDFOR
ENDFOR
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Define output structure
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
tags           = ['SEMILR','ECCEN','XXO','SEMIMAJ','SEMIMIN','CENTER','STXOFF',$
                  'XRANGE','YRANGE','ZRANGE','NX','NY','NZ','N_OUT','SURF_SOLN']
hots_out       = CREATE_STRUCT(tags,LL[0],ee[0],xo[0],a[0],b[0],c[0],n_vrx[0],xran,yran,$
                                    zran,nx[0],ny[0],ny[0],n_s,sur)
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

IF (TOTAL(FINITE(sur)) LT 5) THEN RETURN,0b ELSE RETURN,1b
END





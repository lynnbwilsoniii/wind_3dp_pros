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
;               is_a_number.pro
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
;                                                              [,ECCEN=eccen] [,XXO=xxo]   )
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
;
;   CHANGED:  1)  NA
;                                                                   [MM/DD/YYYY   v1.0.0]
;
;   NOTES:      
;               ***********************
;               ***  Still Testing  ***
;               ***********************
;               1)  Make sure to keep units uniform between POSI, SEMILR, and XXO
;               2)  The routine assumes any aberrations etc. have been handled outside/
;                     before calling, thus all outputs are in a coordinate basis aligned
;                     with the symmetry axis of the hyperboloid.
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
;    LAST MODIFIED:  04/02/2019   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION find_intersect_point_plane_hyperboloid,posi,nip,SEMILR=semilr,ECCEN=eccen,XXO=xxo


;;----------------------------------------------------------------------------------------
;;  Constants
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
;;  Define defaults
def__L         = 23.3d0                    ;;  Default semi-latus rectum [Re]
def__e         = 1.16d0                    ;;  Default eccentricity
def_xo         = 3d0                       ;;  Default focus offset [Re]
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
;;  Check keywords
;;----------------------------------------------------------------------------------------
;;  Check SEMILR
IF (is_a_number(semilr,/NOMSSG) EQ 0) THEN LL = def__L[0] ELSE LL = ABS(semilr[0]) > 1d0
;;  Check ECCEN
IF (is_a_number(eccen,/NOMSSG) EQ 0) THEN ee = def__e[0] ELSE ee = ABS(eccen[0]) > 1.0001d0
;;  Check XXO
IF (is_a_number(xxo,/NOMSSG) EQ 0) THEN xo = def_xo[0] ELSE xo = 1d0*xxo[0]
;;----------------------------------------------------------------------------------------
;;  Define hyperboloid parameters
;;----------------------------------------------------------------------------------------
a              = LL[0]/(ee[0]^2 - 1d0)             ;;  semi-major axis
b              = LL[0]/SQRT(ee[0]^2 - 1d0)         ;;  semi-minor axis
c              = LL[0]*ee[0]/(ee[0]^2 - 1d0)       ;;  center/focus
n_vrx          = xo[0] + (c[0] - a[0])             ;;  standoff distance from origin of nose of hyperboloid
nx             = 100L                              ;;  # of points to use in dummy arrays
ny             = 200L                              ;;  # of points to use in dummy arrays
IF (n_vrx[0] GT 0) THEN BEGIN
  ;;  standoff is positive --> origin is shifted from normal location
  xran  = n_vrx[0]*(1d0 + [-1.75d0,2d-2])
ENDIF ELSE BEGIN
  ;;  standoff is negative --> origin may be at normal location
  xran  = n_vrx[0]*(1d0 + [5d-1,-2d-2])
ENDELSE
yran           = LL[0]*SQRT(2d0)*[-1,1]
zran           = yran
;;  Define arrays of abscissa for surface
xx             = fill_range(xran[0],xran[1],UNIFORM=nx[0])
yy             = fill_range(yran[0],yran[1],UNIFORM=ny[0])
zz             = yy
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
;;  N_SX = -2 (x - c - Xo)/a^2
n_sx           = -2d0*(xx - c[0] - xo[0])/a[0]^2d0
;;  N_SY = +2 y/b^2
n_sy           = 2d0*yy/b[0]^2d0
;;  N_SZ = +2 z/b^2
n_sz           = 2d0*zz/b[0]^2d0
n_s            = DBLARR(nx[0],ny[0],ny[0],3L)
sur            = DBLARR(nx[0],ny[0],ny[0])
oney           = REPLICATE(1d0,ny[0])
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
    check         = 1d0 + ((yy[j] + zz)/b[0])^2d0 - ((xx[i] - c[0] - xo[0])/a[0])^2d0
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
;n_s            = unit_vec(n_s0,/NAN)
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
;mx_ip          = MAX(ABS(ns_d_nip),ixip,/NAN)
inop3d         = ARRAY_INDICES(sur,inop)
ixip3d         = ARRAY_INDICES(sur,ixip)
xyz_int_in     = [xx[inop3d[0]],yy[inop3d[1]],zz[inop3d[2]]]; + [c[0] + xo[0],0d0,0d0]
xyz_int_ix     = [xx[ixip3d[0]],yy[ixip3d[1]],zz[ixip3d[2]]]; + [c[0] + xo[0],0d0,0d0]
;;  Clean up
delete_variable,n_s,ns_x_nip,nsxnip_mag,ns_d_nip
;;----------------------------------------------------------------------------------------
;;  Minimize the magnitude of the difference
;;    |N_S - N_IP|
;;----------------------------------------------------------------------------------------
ns___nip       = lbw_diff(ns_2d,nip2d,/NAN)
diff_mag       = mag__vec(ns___nip,/NAN)
mn_diff        = MIN(diff_mag,idff,/NAN)
idff3d         = ARRAY_INDICES(sur,idff)
xyz_int_df     = [xx[idff3d[0]],yy[idff3d[1]],zz[idff3d[2]]]
;;  Find mean and median of results
all_xyz_int    = [[xyz_int_in],[xyz_int_ix],[xyz_int_df]]
med_xyz_int    = MEDIAN(all_xyz_int,DIMENSION=2)
avg_xyz_int    = MEAN(all_xyz_int,DIMENSION=2,/NAN)
;;  Clean up
delete_variable,ns___nip,diff_mag

STOP
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN,med_xyz_int
END


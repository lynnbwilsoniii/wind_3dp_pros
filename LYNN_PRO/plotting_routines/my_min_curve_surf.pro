; $Id: //depot/idl/IDL_71/idldir/lib/min_curve_surf.pro#1 $
;
; Copyright (c) 1993-2009, ITT Visual Information Solutions. All
;       rights reserved. Unauthorized reproduction is prohibited.

Function my_min_curve_sphere_basis_function, d, TPS=tps
;
; The radial basis function, F(d), for either a Thin plate spline, or
; a minimum curvature surface.
;
COMPILE_OPT idl2, hidden
d2 = d^2
good = where(d2, count)
if count ne 0 then d2[good] = d2[good] * $
  alog(keyword_set(tps) ? d2[good] : d[good])
return, d2
end


;
;+
; NAME:
;   MY_MIN_CURVE_SURF
;
; PURPOSE:
;   This function Interpolates a regularly or irregularly-gridded
;   set of points, over either a plane or a sphere, with either a
;   minimum curvature surface or a thin-plate-spline surface.
;
; CATEGORY:
;   Mathematical functions, Interpolation, Surface Fitting
;
; CALLING SEQUENCE:
;   Result = MIN_CURVE_SURF(Z [, X, Y])
;
; INPUTS:
;   X, Y, Z:  arrays containing the X, Y, and Z coordinates of the
;         data points on the surface. Points need not be
;         regularly gridded. For regularly gridded input data,
;         X and Y are not used: the grid spacing is specified
;         via the XGRID and YGRID (or XVALUES and YVALUES)
;         keywords, and Z must be a two dimensional array.
;         For irregular grids, all three parameters must be
;         present and have the same number of elements.  If
;         the keyword SPHERE is set, X and Y are given in
;         degrees of longitude and latitude, respectively.
;
; KEYWORD PARAMETERS:
;   TPS:    If set, use the thin-plate-spline method, otherwise
;       use the minimum curvature surface method.
;    DOUBLE:    If set, perform computations in double precision,
;           enhancing accuracy. Also, if Z is double precision the
;           computations will also be done in double precision.
;    SPHERE:    If set, perform interpolation on the surface of a
;           sphere.  The inputs X and Y should be given in degrees of
;       longitude and latitude, respectively.
;     CONST:    If set, data on the sphere is fit with a constant
;           baseline, otherwise, data on the sphere is fit with a basline
;           that contains a constant term plus linear X, Y, and Z terms.
;           Has effect only if SPHERE is specified.  See the Procedure
;           section below for the formulae.
;
;  Input grid description:
;   REGULAR:  if set, the Z parameter is a two dimensional array
;         of dimensions (N,M), containing measurements over a
;         regular grid. If any of XGRID, YGRID, XVALUES, YVALUES
;         are specified, REGULAR is implied. REGULAR is also
;         implied if there is only one parameter, Z. If REGULAR is
;         set, and no grid (_VALUE or _GRID) specifications are
;         present, the respective grid is set to (0, 1, 2, ...).
;   XGRID:    contains a two element array, [xstart, xspacing],
;         defining the input grid in the X direction. Do not
;         specify both XGRID and XVALUES.
;   XVALUES:  if present, XVALUES(i) contains the X location
;         of Z(i,j). XVALUES must be dimensioned with N elements.
;   YGRID:    contains a two element array, [ystart, yspacing],
;         defining the input grid in the Y direction. Do not
;         specify both YGRID and YVALUES.
;   YVALUES:  if present, YVALUES(i) contains the Y location
;         of Z(i,j). YVALUES must be dimensioned with N elements.
;
;  Output grid description:
;   GS:   If present, GS must be a two-element vector [XS, YS],
;         where XS is the horizontal spacing between grid points
;         and YS is the vertical spacing. The default is based on
;         the extents of X and Y. If the grid starts at X value
;         Xmin and ends at Xmax, then the default horizontal
;         spacing is (Xmax - Xmin)/(NX-1). YS is computed in the
;         same way. The default grid size, if neither NX or NY
;         are specified, is 26 by 26.
;   BOUNDS:   If present, BOUNDS must be a four element array containing
;         the grid limits in X and Y of the output grid:
;         [Xmin, Ymin, Xmax, Ymax]. If not specified, the grid
;         limits are set to the extent of X and Y.
;   NX:       The output grid size in the X direction. NX need not
;         be specified if the size can be inferred from GS and
;         BOUNDS. The default value is 26.
;   NY:       The output grid size in the Y direction. See NX.
;   XOUT:     If present, XOUT must be a vector containing the output
;         grid X values. If this parameter is supplied, GS, BOUNDS,
;         and NX are ignored for the X output grid. Use this
;         parameter to specify irregularly spaced output grids.
;   YOUT:     If present, YOUT must be a vector containing the output
;         grid Y values. If this parameter is supplied, GS, BOUNDS,
;         and NY are ignored for the Y output grid. Use this
;         parameter to specify irregularly spaced output grids.
;   XPOUT:    If present, the arrays XPOUT and YPOUT contain the X and Y
;   YPOUT:    values for the output points. With these keywords, the
;         output grid need not be regular, and all other output
;         grid parameters are ignored. XPOUT and YPOUT must have
;         the same number of points, which is also the number of
;         points returned in the result.
;
; OUTPUTS:
;   This function returns a two-dimensional floating point array
;   containing the interpolated surface, sampled at the grid points.
;
; RESTRICTIONS:
;   The accuracy of this function is limited by the single precision
;   floating point accuracy of the machine.
;
;       SAMPLE EXECUTION TIMES  (measured on a Sun IPX)
;   # of input points   # of output points  Seconds
;   16          676         0.19
;   32          676         0.42
;   64          676         1.27
;   128         676         4.84
;   256         676         24.6
;   64          256         1.12
;   64          1024            1.50
;   64          4096            1.97
;   64          16384           3.32
;
; PROCEDURE:
;   A minimum curvature spline surface is fitted to the data points
;   described by X, Y, and Z.  The basis function:
;       C(x0,x1, y0,y1) = d^2 log(d^k),
;   where d is the distance between (x0,y0), (x1,y1), is used,
;   as described by Franke, R., "Smooth interpolation of scattered
;   data by local thin plate splines," Computers Math With Applic.,
;   v.8, no. 4, p. 273-281, 1982.  k = 1 for minimum curvature surface,
;   and 2 for Thin Plate Splines.  For N data points, a system of N+3
;   simultaneous equations are solved for the coefficients of the
;   surface.  For any interpolation point, the interpolated value
;   is:
;     F(x,y) = b(0) + b(1)*x + b(2)*y + Sum(a(i)*C(X(i),x,Y(i),y))
;
;   For a sphere the value is:
;     F(l,t) = b(0) + b(1)*x + b(2)*y +b(3)*z + Sum(a(i)*C(L(i),l,T(i),t))
;   On the sphere, l and t are longitude and latitude. C(L(i),l,
;   T(i),t) is the basis function above, with distance between the
;   two points, (L(i),T(i)), and (l,t)  measured in radians of arc length.
;   x, y, and z are the 3D cartesian coordinates of the point (l,t) on
;   the unit sphere.
;
;   For a sphere with the keyword CONST set the value is:
;     F(l,t) = b(0) + Sum(a(i)*C(L(i),l,T(i),t))
;
;   The results obtained the thin plate spline (TPS) or the minimum
;   curvature surface (MCS) methods are very similar.  The only
;   difference is in the basis functions: TPS uses d^2*alog(d^2),
;   and MCS uses d^2*alog(d), where d is the distance from
;   point (x(i),y(i)).
;
; EXAMPLES:
; Example 1: Irregularly gridded cases
;   Make a random set of points that lie on a gaussian:
;     n = 15                ;# random points
;     x = RANDOMU(seed, n)
;     y = RANDOMU(seed, n)
;     z = exp(-2 * ((x-.5)^2 + (y-.5)^2))    ;The gaussian
;
;   get a 26 by 26 grid over the rectangle bounding x and y:
;     r = min_curve_surf(z, x, y)   ;Get the surface.
;
;   Or: get a surface over the unit square, with spacing of 0.05:
;     r = min_curve_surf(z, x, y, GS=[0.05, 0.05], BOUNDS=[0,0,1,1])
;
;   Or: get a 10 by 10 surface over the rectangle bounding x and y:
;     r = min_curve_surf(z, x, y, NX=10, NY=10)
;
; Example 2: Regularly gridded cases
;   Make some random data
;     z = randomu(seed, 5, 6)
;
;   interpolate to a 26 x 26 grid:
;     CONTOUR, min_curve_surf(z, /REGULAR)
;
; MODIFICATION HISTORY:
;   DMS, RSI, March, 1993.  Written.
;   DMS, RSI, July, 1993.   Added XOUT and YOUT, XPOUT and YPOUT.
;   DMS, RSI, May, 1999.    Added DOUBLE keyword.
;   DMS, RSI, Feb 2000.     Switch from INVERT to LUDC.
;   DMS, RSI, May 2000.     Added SPHERE and CONST keywords.
;   CT, RSI, Aug 2001.      Per Scott Bennett's suggestion, vectorize loop
;                           when calculating planar distance.
;   LBW III, 08/29/2013.    Now uses LA_SVD and SVSOL instead of LUDC and LUSOL
;-

FUNCTION my_min_curve_surf, z, x, y, REGULAR = regular, XGRID=xgrid, $
            XVALUES = xvalues, YGRID = ygrid, YVALUES = yvalues, $
            GS = gs, BOUNDS = bounds, NX = nx0, NY = ny0, XOUT=xout, $
            YOUT=yout, XPOUT=xpout, YPOUT=ypout, TPS=tps, DOUBLE=double, $
            SPHERE=sphere, CONST=const

compile_opt idl2

ON_ERROR, 2  ; return to caller
s = size(z)                     ;Assume 2D
nx = s[1]
ny = s[2]
if n_elements(double) eq 0 then $ ;IF Z is double, use double
  double = s[s[0]+1] eq 5

is_sphere = keyword_set(sphere)        ;TRUE if spherical
reg = keyword_set(regular) or (n_params() eq 1)
tol = double ? 1.0d-20 : 1.0e-10 ;Zero tolerance.
one = double ? 1.0d0 : 1.0

if n_elements(xgrid) eq 2 then begin ;XGRID=[start, spacing]?
    x = (double ? dindgen(nx) : findgen(nx)) * xgrid[1] + xgrid[0]
    reg = 1
endif else if n_elements(xvalues) gt 0 then begin
    if n_elements(xvalues) ne nx then $
      message,'Xvalues must have '+string(nx)+' elements.'
    x = xvalues
    reg = 1
endif

if n_elements(ygrid) eq 2 then begin ;YGRID=[start, spacing]?
    y = (double ? dindgen(ny) : findgen(ny)) * ygrid[1] + ygrid[0]
    reg = 1
endif else if n_elements(yvalues) gt 0 then begin
    if n_elements(yvalues) ne ny then $
      message,'Yvalues must have '+string(ny)+' elements.'
    y = yvalues
    reg = 1
endif

if reg then begin
    if s[0] ne 2 then message,'Z array must be 2D for regular grids'
    if n_elements(x) ne nx then x = findgen(nx) * one
    if n_elements(y) ne ny then y = findgen(ny) * one
    x = x # replicate(one, ny)  ;Expand to full arrays.
    y = replicate(one,nx) # y
endif

n = n_elements(x)
if n ne n_elements(y) or n ne n_elements(z) then $
  message,'x, y, and z must have same number of elements.'

; For thin-plate-splines, terms are r^2 log(r^2).  For min curve surf,
; terms are r^2 log(r).
k = keyword_set(tps) ? 1.0 : 0.5

if n_elements(XPOUT) gt 0 then begin ;Explicit output locations?
    if n_elements(YPOUT) ne n_elements(XPOUT) then $
      message, 'XPOUT and YPOUT must have same number of points'
endif else begin                ;Regular grid
    if n_elements(bounds) lt 4 then begin ;Bounds specified?
        xmin = min(x, max = xmax)
        ymin = min(y, max = ymax)
        bounds = [xmin, ymin, xmax, ymax]
    endif

    if n_elements(gs) lt 2 then begin ;GS specified?  No.
        if n_elements(nx0) le 0 then nx = 26 else nx = nx0 ;Defaults for nx and ny
        if n_elements(ny0) le 0 then ny = 26 else ny = ny0
        gs = [(bounds[2]-bounds[0])/(nx-1.), $
              (bounds[3]-bounds[1])/(ny-1.)]
    endif else begin            ;GS is specified?
        if n_elements(nx0) le 0 then $
          nx = ceil((bounds[2]-bounds[0])/gs[0]) + 1 $
        else nx = nx0
        if n_elements(ny0) le 0 then $
          ny = ceil((bounds[3]-bounds[1])/gs[1]) + 1 $
        else ny = ny0
    endelse

    if n_elements(xout) gt 0 then begin ;Output grid specified?
        nx = n_elements(xout)
        xpout = xout
    endif else xpout = gs[0] * findgen(nx) + bounds[0]

    if n_elements(yout) gt 0 then begin
        ny = n_elements(yout)
        ypout = yout
    endif else ypout = gs[1] * findgen(ny) + bounds[1]
    xpout = xpout # replicate(1.,ny)
    ypout = replicate(1., nx) # ypout
endelse                         ;Regular grid


zmin = min(z, MAX=zmax, /NAN)
zscale = 1.0 / (zmax - zmin)     ;Normalize Z, other coords are already
                                ;on unit sphere.

if is_sphere then begin         ;Spherical?
    const = keyword_set(const)  ;If set, use a constant baseline
    cbase = const ? 1 : 4
    m = n + cbase               ;# of eqns to solve
    a = double ? dblarr(m,m) : fltarr(m, m) ;LHS
; For thin-plate-splines, terms are r^2 log(r^2).  For min curve surf,
; terms are r^2 log(r).
    cosz = cos(y * !dtor)
    p3 = [[cos(x * !dtor) * cosz], $ ;Dims = [n,3]
          [sin(x * !dtor) * temporary(cosz)], $
          [sin(y * !dtor)]]

    for i=0, n-2 do for j=i+1,n-1 do begin ;Compute matrix
        d = acos(total(p3[i,*] * p3[j,*])) ; = angular distance, 0 to !PI
        a[i+cbase,j+cbase] = d
        a[j+cbase,i+cbase] = d
    endfor

;  Apply basis function
    a[cbase, cbase] = $
      my_min_curve_sphere_basis_function(a[cbase:*, cbase:*], TPS=tps)
    for i=cbase, m-1 do a[i,i]=0.0 ;Zero the diagonals

    a[0,cbase:m-1] = 1          ; fill rest of array
    a[cbase:m-1, 0] = 1.
    if const eq 0 then for i=0,2 do begin ;Add x, y, and Z terms
        r = p3[*,i]
        a[cbase, i+1] = r
        a[i+1, cbase] = transpose(r)
    endfor

    b = double ? dblarr(m) : fltarr(m) ;Right hand side
    b[cbase] = (reform(z,n,1) - zmin) * zscale

    atemp = a
;    message,'Line 332',/info,/cont
;    LA_LUDC, atemp, Index          ;Solve the system of equations
;    ludc, atemp, Index          ;Solve the system of equations
;    message,'Line 334',/info,/cont
;    c = LA_LUSOL(temporary(atemp), index, b)
;    c = LUSOL(temporary(atemp), index, b)
;    message,'Line 336',/info,/cont
    LA_SVD,a,ww,uu,vv              ;;  Solution using SVDC
    c = SVSOL(uu,ww,vv,b)
    cc = c[cbase:*]

; For min_curve_surf, divide c[4:*] by 2 cause we use d^2 rather than d.
                                ;common scale factor
; if keyword_set(tps) eq 0 then c[4] = c[4:*]/2.0

    dims = size(xpout)
    nxny = n_elements(ypout)
    cosz = reform(cos(ypout * !dtor), nxny)
                                ;Cartesian coords of output grid [nxny,3]
    p3o = [[cosz * cos(xpout * !dtor)], $
           [temporary(cosz) * sin(xpout * !dtor)], $
           [reform(sin(ypout * !dtor), nxny)]]

    if const eq 0 then begin
        s = c[0] + c[1] * p3o[*,0] + c[2] * p3o[*,1] + c[3] * p3o[*,2]
        s = reform(s, dims[1], dims[2], /OVERWRITE)
    endif else s = replicate(c[0], dims[1], dims[2])

    for i=0L, n-1 do begin      ;Angular Distance
        d = acos(p3o # transpose(p3[i,*]))
        s = s + c[i+cbase] * my_min_curve_sphere_basis_function(d, TPS=tps)
    endfor

endif else begin                ;Planar case

    m = n + 3           ;# of eqns to solve
    a = double ? dblarr(m,m) : fltarr(m, m) ;LHS
    x0 = min(x, MAX=xmax)
    y0 = min(y, MAX=ymax)
    scale = 1./ ((xmax - x0) > (ymax-y0)) ;Scale factor for unit square
    xs = (x - x0) / scale       ;Scale into 0-1 rectangle to enhance accuracy
    ys = (y - y0) / scale

    for i=0L, n-2 do begin
        ; For each point, find the distance to all other points.
        d = (xs[i]-xs[i+1:n-1])^2 + (ys[i]-ys[i+1:n-1])^2 > tol ;Distance^2
        d = d * alog(d)* k      ;TPS: d^2 * alog(d^2)), MCS: d^2 * alog(d))
        a[i+3,i+1:n-1] = d
        a[i+4:n+2,i] = d
    endfor

    a[0,0:n-1] = 1              ; fill rest of array
    a[1,0:n-1] = reform(xs,1,n)
    a[2,0:n-1] = reform(ys,1,n)

    a[3:m-1,n] = 1.
    a[3,n+1] = reform(xs, n, 1)
    a[3,n+2] = reform(ys, n, 1)

    b = double ? dblarr(m) : fltarr(m) ;Right hand side
    b[0] = (reform(z,n,1) - zmin) * zscale
;stop
;    message,'Line 390',/info,/cont
;    LUDC, a, Index              ;Solution using LU decomposition
    LA_SVD,a,ww,uu,vv              ;;  Solution using SVDC
    c = SVSOL(uu,ww,vv,b)
;    LA_LUDC, a, Index              ;Solution using LU decomposition
;    message,'Line 397',/info,/cont
;    c = LUSOL(temporary(a), index, b)
;    c = LA_LUSOL(temporary(a), index, b)
;    message,'Line 400',/info,/cont

; For min_curve_surf, divide c[3:*] by 2 cause we use d rather than
; the d^2 we use for TPS.
    if keyword_set(tps) eq 0 then c[3] = c[3:*]/2.0

    xpouts = (xpout - x0) / scale ;reapply scale factor to output grid
    ypouts = (ypout - y0) / scale
    s = c[0] + c[1] * xpouts + c[2] * ypouts ;First terms
    for i=0L, n-1 do begin      ;This loop takes all the time.
        d = (xpouts-xs[i])^2 + (ypouts-ys[i])^2 > tol ;Distance ^2
        s = s + d * alog(d)* c[i+3]
    endfor
endelse                         ;Planar

return, (s / zscale) + zmin     ;Rescale data

end

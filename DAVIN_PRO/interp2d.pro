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
function interp2d,z,x,y,u,v,grid=grid,no_interp=no_interp

nx = n_elements(x)
ix = interp(findgen(nx),x,u)
if keyword_set(no_interp) then ix=round(ix)

ny = n_elements(y)
iy = interp(findgen(ny),y,v)
if keyword_set(no_interp) then iy=round(iy)

w = interpolate(z,ix,iy,missing=!values.f_nan,grid=grid)

return,w

end



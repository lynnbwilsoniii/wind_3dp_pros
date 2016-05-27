;+
;NAME:
;	enlarge_periodic
;FUNCTION:   enlarge_periodic
;INPUT:   image   (On the surface of a sphere)
;PURPOSE: enlarges a 2 dimensional matrix by n elements on each side
;   It assumes the array has spherical boundary conditions.
;OUTPUT:  enlarged image array
;NOTES:   Called from function: 'SMOOTH_PERIODIC'
;
;CREATED BY:	Davin Larson
;LAST MODIFICATION:	@(#)smooth_periodic.pro	1.5 95/10/04
;-
function enlarge_periodic, orig_image, n
if n le 0 then return,orig_image
image = orig_image
dim = dimen(image)
nx = dim(0)     ; must be even
ny = dim(1)
new_image = make_array(dimension =dim+2*n,type = data_type(image))
for i=0,nx+2*n-1 do begin
   for j=n,ny+n-1 do begin
      new_image(i,j) = image((i+nx-n) mod nx,(j+ny-n) mod ny)
   endfor
endfor
for i=0,n-1 do begin
   new_image(*,i)          = shift( new_image(*,2*n-i-1) , nx/2 )
   new_image(*,ny+2*n-i-1) = shift( new_image(*,ny+i),     nx/2 )
endfor
return,new_image
end



;+
;NAME:
;	smooth_periodic
;
;FUNCTION: smooth_periodic, old_image, n
;PURPOSE:  Uses box car smoothing of a surface with sperical periodic boundary
;    conditions.
;INPUT:
;   old_image:  2d matrix
;   n:          size of boxcar averaging window
;Output:  smoothed image.
;
;CREATED BY:	Davin Larson
;LAST MODIFICATION:	@(#)smooth_periodic.pro	1.5 95/10/04
;-
function smooth_periodic, old_image, n
if n le 0 then return,old_image
dim = dimen(old_image)
nx = dim(0)
ny = dim(1)
image = old_image
image = enlarge_periodic(image,n)
image = smooth(image,2*n+1)
image = image(n:nx+n-1,n:ny+n-1)
return,image
end


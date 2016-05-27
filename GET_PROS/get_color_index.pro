function get_color_index, arg1, arg2, arg3, closeness=closeness, $
                          hsv=hsv

;  finds closest color to RGB.  If only arg1 is specified, then 
;    translate color name to RGB first.

   rgb= not keyword_set( hsv )

   if n_params() gt 1 then begin
       red= arg1
       green= arg2
       blue= arg3
   endif else begin
       names= [ 'black', 'red', 'green', 'yellow', 'blue', $
                'magenta', 'cyan', 'white','grey','gray' ]
       rs= [ 0,1,0,1,0,1,0,1,.8,.8 ] * 255
       gs= [ 0,0,1,1,0,0,1,1,.8,.8 ] * 255
       bs= [ 0,0,0,0,1,1,1,1,.8,.8 ] * 255
       
       name= arg1
       r= (where( name eq names ))(0)
       if r(0) eq -1 then begin
           message, 'Named color not recognized.', /cont
           return, -1
       endif else begin
           red= rs(r)
           green= gs(r)
           blue= bs(r)
       endelse
       rgb=1
   endelse

   if rgb then begin       
       color_convert, red, green, blue, h,s,v, /rgb_hsv
   endif       
      
   tvlct, r, g, b, /get
   
   color_convert, r, g, b, HH, SS, VV, /rgb_hsv

;   h= (float(r-red))^2 + (float(g-green))^2 + (float(b-blue))^2

   angle= abs( float(HH-h) )
   r= where( angle gt 180 )
   if r(0) ne -1 then angle(r)= 360.-angle(r)

   dist2= (angle/180.)^2 + float(SS-s)^2 + float(VV-v)^2 
   
   min= sqrt( min( dist2, imin ) )
   
   if min gt 0.5 then begin
       message, 'Warning: No close colors found.', /cont
   endif
   
   closeness= min
   return, imin
end
   
   

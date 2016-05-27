function arctangent, upper, lower

If (upper GE 0.0) then begin
                     theta=Atan(Upper,lower)
                   
endif else begin
         theta=!DPI+(!DPI+Atan(upper,lower))
endelse
return, theta
end
                 
                 

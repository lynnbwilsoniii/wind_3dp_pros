;+
;FUNCTION EXPONENTIAL
;USAGE:
;  y = exponential(x,par=p)
;-

function exponential, x, parameters=p  $
   , p_names = p_names, pder_values= pder_values

if not keyword_set(p) then $
   p = {func:'exponential',h:1.d, l:1.0d,  a0:0.d }

if n_params() eq 0 then return,p

z = x/p.l
e = exp(- z)
f = p.a0 + p.h * e

if keyword_set(p_names) then begin
   np = n_elements(p_names)
   nd = n_elements(f)
   for i=0,np-1 do begin
      case strlowcase(p_names(i)) of
          'h': pder_values(*,i) = e
          'l': pder_values(*,i) = p.h * e * x / p.l^2
          'a0': pder_values(*,i) = 1
          else: print,'Unknown Variable ', p_names(i)
      endcase
   endfor
endif

return,f
end



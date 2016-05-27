;+
;FUNCTION  power_law(x,par=p)
;PURPOSE:
;   Evaluates a power law function (with background) (can be used with "FIT")
;-
function power_law, x,  $
    parameters=p,  p_names = p_names, pder_values= pder_values

if not keyword_set(p) then $
   p = {func:'power_law',h:1.0d, p:-2.d, bkg:.0d}

if n_params() eq 0 then return,0

f = p.h * x^p.p + p.bkg

if keyword_set(p_names) then begin
   np = n_elements(p_names)
   nd = n_elements(f)
   pder_values = dblarr(nd,np)
   for i=0,np-1 do begin
      case strupcase(p_names(i)) of
          'H': pder_values(*,i) = x^p.p
          'P': pder_values(*,i) = p.h * alog(x) * x^p.p
          'BKG': pder_values(*,i) = 1
      endcase
   endfor
endif

return,f
end

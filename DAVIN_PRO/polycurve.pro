;+
;FUNCTION  polycurve(x,par=p)
;PURPOSE:
;   Evaluates a (4th degree) polynomial (can be used with "FIT")
;-

function polycurve, x,  $
    parameters=p,  p_names = p_names, pder_values= pder_values

if not keyword_set(p) then $
   p = {func:'polycurve',a0:.0d, a1:.0d, a2:.0d, a3:.0d, a4:.0d}

if n_params() eq 0 then return,p

f = p.a4 * x^4 + p.a3 * x^3 + p.a2*x^2 + p.a1*x + p.a0

if keyword_set(p_names) then begin
   np = n_elements(p_names)
   nd = n_elements(f)
   pder_values = dblarr(nd,np)
   for i=0,np-1 do begin
      case strupcase(p_names(i)) of
          'A4': pder_values(*,i) = x^4
          'A3': pder_values(*,i) = x^3
          'A2': pder_values(*,i) = x^2
          'A1': pder_values(*,i) = x
          'A0': pder_values(*,i) = 1
      endcase
   endfor
endif

return,f
end




;2.1 16.98 107
;2.2 16.57 116
;2.3 16.22 127
;2.4 15.89 137
;2.5 15.75 147
;2.6 15.62 159
;2.7 15.22 169
;2.8 14.85 179
;2.9 14.52 189
;3.0 14.16 196
;3.1 14.05 200
;3.2 13.63 204
;3.3 13.24 204
;3.4 12.99 200
;3.5 12.64 192
;3.6 12.42 185
;3.7 12.06 179
;3.8 11.72 167
;3.9 11.47 156
;4.0 11.20 145
;4.1 10.70 135
;4.2 10.30 123
;4.3  9.88 114
;4.4  9.51 105
;4.5  9.09  96
;4.6  8.83  89
;4.7  8.50  82
;4.8  8.17  76
;4.9  7.79  70
;5.0  7.42  65

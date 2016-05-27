;+
;FUNCTION:  GAUSSIAN
;PURPOSE:
;  Evaluates a gaussian function with background.
;  This function may be used with the "fitfunc" curve fitting function.
;
;KEYWORDS:
;  PARAMETERS: structure with the format:
;** Structure <275ac0>, 6 tags, length=48, refs=1:
;   H               DOUBLE           1.0000000      ; hieght
;   W               DOUBLE           1.0000000      ; width
;   X0              DOUBLE           0.0000000      ; center
;   A0              DOUBLE           0.0000000
;   A1              DOUBLE           0.0000000
;   A2              DOUBLE           0.0000000
;     If this parameter is not a structure then it will be created.
;  P_NAMES:      string array  (see "fitfunc" for details)
;  PDER_VALUES:  named variable in which partial derivatives are returned.
;
;USAGE:
;  p={h:2.,w:1.5,x0:5.0,a0:0.,a1:0.,a2:0.}
;  x = findgen(100)/10.
;  y = gaussian(x,par=p)
;  plot,x,y
;RETURNS:
;  p.a2*x^2 + p.a1*x + p.a0 + p.h * exp( - ((x-p.x0)/p.w)^2 )
;-

function gaussian, x, parameters=p  $
   , p_names = p_names, pder_values= pder_values                     ;OPT?

;common gaussian_com, p0
if not keyword_set(p) then $
   p = {func:"gaussian",h:1.d, w:1.0d, x0:0.d, a0:0.d, a1:0.d, a2:0.d }

;if n_elements(p) eq 0 then p = p0 else p0=p

if n_params() eq 0 then return,p

z = (x - p.x0)/p.w
e = exp(- z^2 )
f =  p.a2*x^2 + p.a1*x + p.a0 + p.h * e

if keyword_set(p_names) then begin                                   ;OPT?
   np = n_elements(p_names)                                          ;OPT?
   nd = n_elements(f)                                                ;OPT?
   for i=0,np-1 do begin                                             ;OPT?
      case strupcase(p_names(i)) of                                 ;OPT?
          'H': pder_values(*,i) = e                                  ;OPT?
          'W': pder_values(*,i) = p.h * e * z^2 * 2 / p.w            ;OPT?
          'X0': pder_values(*,i) = p.h * e * z * 2 / p.w             ;OPT?
          'A0': pder_values(*,i) = 1                                 ;OPT?
          'A1': pder_values(*,i) = x                                 ;OPT?
          'A2': pder_values(*,i) = x^2                               ;OPT?
          else: print,'Unknown Variable ', p_names(i)                ;OPT?
      endcase                                                        ;OPT?
   endfor                                                            ;OPT?
endif                                                                ;OPT?

;SPECIAL NOTE: if the /NODERIV keyword is set in "fitfunc", then all
;lines ending in ";OPT?" above could be deleted.

return,f
end



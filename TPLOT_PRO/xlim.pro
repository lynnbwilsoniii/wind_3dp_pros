;+
;PROCEDURE:  xlim,lim, [min,max, [log]]
;PURPOSE:    
;   To set plotting limits for plotting routines.
;   This procedure will add the tags 'xrange', 'xstyle' and 'xlog' to the 
;   structure lim.  This structure can be used in other plotting routines such
;   as "SPEC3D".
;INPUTS: 
;   lim:     structure to be added to.  (Created if non-existent)
;   min:     min value of range
;   max:     max value of range
;KEYWORDS:
;   LOG:  (optional)  0: linear,   1: log
;See also:  "OPTIONS", "YLIM", "ZLIM"
;Typical usage:
;   xlim,lim,-20,100      ; create a variable called lim that can be passed to
;                         ; a plotting routine such as "SPEC3D".
;
;CREATED BY:	Davin Larson
;LAST MODIFICATION:	@(#)xlim.pro	1.9 02/04/17
;-
pro xlim,lim,min,max,log,log=lg
if n_elements(lg) ne 0 then log=lg
if n_elements(min) eq 2 then max=0 
if n_elements(max) eq 0 then range = [0.,0.] else range = float([min,max])
str_element,/add,lim,'xrange',range(0:1)
style = 0
str_element,lim,'style',value=style
if range(0) ne range(1) then style=(style or 1) else style=(style and not 1)
str_element,/add,lim,'xstyle',style
if n_elements(log) ne 0 then str_element,/add,lim,'xlog',log
return
end



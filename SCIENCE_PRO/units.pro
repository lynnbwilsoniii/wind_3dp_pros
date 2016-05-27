;+
;PROCEDURE:  units
;PURPOSE:    adds the tag 'units' to the structure "struct"
;INPUTS: 
;   struct:  structure to be added to.  (Created if non-existent)
;   units:     string containing units name.
;Typical usage:
;   units,lim,'Counts'
;
;CREATED BY:	Davin Larson
;LAST MODIFICATION: 	@(#)units.pro	1.4 02/04/17
;-
pro units,limit, u
if n_elements(u) eq 0     then u = 'Counts'
str_element,/add,limit,'units',u
end


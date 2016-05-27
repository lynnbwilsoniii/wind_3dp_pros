;+
;FUNCTION:	normal_to_data
;PURPOSE:	convert normal coordinates to data coordinates
;INPUT:
;	normv:	normal coordinates
;	s:	!AXIS structure
;KEYWORDS:
;	none
;
;CREATED BY: 	Davin Larson
;LAST MODIFICATION: 	@(#)normal_to_data.pro	1.5 98/08/02
;
;NOTE:	I think this procedure is superceded by convert_coord.
;-


function normal_to_data,  normv, s
if s.type eq 0 then return, (normv-s.s(0))/s.s(1)  $
else return, exp((normv - s.s(0) )/ s.s(1) * alog(10))
end


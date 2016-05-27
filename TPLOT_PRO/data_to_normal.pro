;+
;FUNCTION:	data_to_normal
;PURPOSE:	convert data coordinates to normal coordinates
;INPUT:
;	datav:	data coordinates
;	s:	!AXIS structure
;KEYWORDS:
;	none
;
;CREATED BY: 	Frank Marcoline.  Hiested from Davin's normal_to_data.
;LAST MODIFICATION: 	@(#)data_to_normal.pro	1.2 97/01/09
;
;NOTE:	I think this procedure is superceded by convert_coord.
;-


function data_to_normal,  datav, s
  if s.type eq 0 then return, s.s[1]*datav+s.s[0]  $
  else return, s.s[1]*alog10(datav)+s.s[0]
end


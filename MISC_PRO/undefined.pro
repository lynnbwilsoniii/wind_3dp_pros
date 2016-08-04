;+
;NAME:
; undefined
;PURPOSE:
; Tests whether a variable is undefined
;CALLING SEQUENCE:
; if ~undefined(var) then print,'Hooray!'
;
; INPUT:
;  var:  A variable to be tested
;
;OUTPUT:
; 1 on success, 0 on fail
; 
; $LastChangedBy: pcruce $
; $LastChangedDate: 2008-07-28 14:53:49 -0400 (Mon, 28 Jul 2008) $
; $LastChangedRevision: 3311 $
; $URL: svn+ssh://thmsvn@ambrosia.ssl.berkeley.edu/repos/spdsoft/trunk/general/misc/undefined.pro $
;-
function undefined,v

if size(v,/type) eq 0 then return,1 else return,0

end
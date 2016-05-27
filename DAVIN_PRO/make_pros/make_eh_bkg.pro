

function make_eh_bkg,dat,bins=bins

bkg = dat
if dat.units_name ne 'Counts' then print,'Units must be counts!'
add_ddata,bkg

th = reform(dat.theta(0,*))
anode = fix(th * 8. /180. +4)

for i=0,7 do begin
  ind  = where(anode eq i)
endfor  

; Eesa High has 24 discrete anodes

anode_7 = [21,43,65,87]
anode_6 = [19,20,41,42,63,64,85,86]
anode_5 = [13,14,17,18,35,36,39,40,57,58,61,62,79,80,83,84]
anode_4 = [11,12,15,16,33,34,37,38,55,56,59,60,77,78,81,82]
anode_3 = [ 0, 1, 4, 5,22,23,26,27,44,45,48,49,66,67,70,71]  ; often noisy
anode_2 = [ 2, 3, 6, 7,24,25,28,29,46,47,50,51,68,69,72,73]
anode_1 = [ 8, 9,30,31,52,53,74,75]
anode_0 = [10,32,54,76]
side_quads = indgen(44) +22

ehbins = bytarr(88)
ehbins(side_quads) = 1    ; side quadrants
noisy_quads = where(ehbins eq 0)
;ind = [0,1,4,5,22,23,26,27,44,45,48,49,66,67,70,71]  ; also noisy
;ehbins(ind) = 0;

stop
return ,bkg
end
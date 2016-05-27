;Sets all data below nlevel to bottom.


function noise_remove,innoise,nlevel = nlevel,bottom = bottom,quiet = quiet

if innoise.valid eq 0 then return, innoise

if not keyword_set(nlevel) then nlevel = 5e4
if not keyword_set(bottom) then bottom = 0.

if not keyword_set(quiet) then print, 'bottom = ',bottom, ' noiselevel = ',nlevel
n = innoise



n = conv_units(n,'eflux')

for i = 0, n.nenergy -1 do begin
	index = where(n.data(i,*) le nlevel and n.data(i,*) gt 0. , count)
	

	if count ne 0 then n.data(i,index)=bottom

endfor

return, n

end

function dat_avg, whichdata, begintime, endtime


get_data,whichdata,data =d, index = i

if i eq 0 then begin
	print, whichdata + ' DOES NOT EXIST'
	return, 0.
endif

print,'Averaging '+whichdata


index = where(d.x le endtime and d.x ge begintime, count)


if count ne 0 then begin
	if ndimen(d.y) eq 2 then $
		avg = total(d.y(index,*),1)/n_elements(index) $
	else $
		avg = total(d.y(index))/n_elements(index)
endif else begin
	print, 'No data points in trange for '+whichdata +', interpolating'

	store_data,'dat_avg',data = {x:(endtime-begintime)/2. + begintime}

	cutindex = where(d.x le endtime + 600 and d.x ge begintime - 600)
	store_data,whichdata+'cut', data = {x:d.x(cutindex), y:d.y(cutindex,*)}
	
	interpolate,'dat_avg',whichdata + 'cut','dat_avgout'

	get_data,'dat_avgout',data = dout

	if ndimen(dout.y) eq 0 then avg = dout.y else avg = reform(dout.y)

endelse

return, avg


end

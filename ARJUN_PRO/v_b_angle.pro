pro v_b_angle, timespan, normalize=normalize, offset=offset,picktimes = picktimes,_EXTRA=e


;HERE IS WHERE I WOULD PUT IN ALL THE TIMESHIFT STUFF FOR THE NORMALIZATION

if keyword_set(picktimes) then begin
	ctime,trange,npoints = 2
	timespan = time_string(trange)
endif




get_data,'Binterp',data = bfield,index = theindex

if theindex eq 0 then begin
	interpolate,'v_3d_ph1','B3_gse','Binterp'
	get_data,'Binterp',data = bfield
endif


get_data,'v_3d_ph1',data = velocity


angle = angl(bfield.y, velocity.y)

store_data,'angle',data = {y:angle, x:velocity.x}


vmag = sqrt(velocity.y(*,0)^2+ velocity.y(*,1)^2+ velocity.y(*,2)^2)

store_data,'vmag',data = {x:velocity.x, y:vmag}


cut_time,timespan,'angle','cutangle'

cut_time,timespan,'vmag','cutvel'

get_data,'cutangle',data = cutangle
get_data,'cutvel',data = cutvel

wi,2



plot,cutangle.y, cutvel.y, title = 'V mag versus V-B angle' $
		,xstyle=1, xrange=[0,180],psym=1,$
		xtitle = 'V-B angle',ytitle = 'V mag',$
		subtitle = timespan(0) + ' -> ' + timespan(1),xmargin= [10,10],$
		ymargin=[5,3],_EXTRA=e

end

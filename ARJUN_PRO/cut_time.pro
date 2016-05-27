pro cut_time, timespan,indata,outdata

get_data,indata,data = theindata

thetimespan = str_to_time(timespan)

index = where(theindata.x ge thetimespan(0) and theindata.x le thetimespan(1), count)

if count eq 0 then print,'no data availible between '+timespan else $
	store_data,outdata, data = {x:theindata.x(index), y:theindata.y(index)}

end

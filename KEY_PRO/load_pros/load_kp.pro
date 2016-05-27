;+
;PROCEDURE:	load_kp
;PURPOSE:
;   Loads Kp and ap data from a text file
;   Variables stored include:
;	Kp: Kp index (multiplied by 10)
;	ap: ap index
;	Sol_Rot_Num: Bartels Solar Rotation Number
;	Sol_Rot_Day: Number of day within Bartels 27-day cycle
;	Kp_Sum: Sum of the eight Kp indices for the day
;	ap_Mean: Mean of the eight ap indices for the day
;	Cp: Cp or Planetary Daily Character Figure
;	C9: Conversion of Cp to the 0-9 range
;	Sunspot_Number: International Sunspot Number
;	Solar_Radio_Flux: Ottawa 10.7-cm Solar Radio Flux Adjusted to 1 AU
;	Flux_Qualifier: "0" indicates flux required no adjustment.
;		"1" indicates flux required adjustment for burst
;		in progress at time of measurement.  "2" indicates a flux
;		approximated by either interpolation or extrapolation.
;		"3" indicates no observation.
;
;INPUTS:
;  none, but will call "timespan" if time_range is not already set.
;
;KEYWORDS:
;  time_range:	2 element vector specifying the time range.
;
;CREATED BY:	Peter Schroeder
;LAST MODIFIED: @(#)load_kp.pro	1.1 99/01/14
;-

pro load_kp,time_range=trange

file_prefix = '/disks/aeolus/disk1/wind/data/kp/'
if not keyword_set(trange) then get_timespan,tr else tr=time_double(trange)
if n_elements(tr) eq 1 then tr = [tr, tr+86399d0]

begintime = time_struct(tr(0))
endtime = time_struct(tr(1))

years = begintime.year+indgen(endtime.year-begintime.year+1)
nyears = n_elements(years)

kpdata = intarr(8.*366.*nyears)
apdata = kpdata
kptimes = dblarr(8.*366.*nyears)
daytimes = dblarr(366.*nyears)
srndata = intarr(366.*nyears)
srddata = srndata
kpsdata = srndata
apmdata = srndata
cpdata = fltarr(366.*nyears)
c9data = srndata
ssndata = srndata
srfdata = cpdata
fqdata = srndata

i = 0.

for j=0,nyears-1 do begin
	file = file_prefix+strcompress(years(j),/rem)
	print,'Loading '+file+'...'
	get_lun,lun
	openr,lun,file
	on_ioerror,bad
	while not eof(lun) do begin
		full_line = ''
		readf,lun,full_line
		year = strmid(full_line,0,2)
		month = strmid(full_line,2,2)
		day = strmid(full_line,4,2)
		srndata[i] = fix(strmid(full_line,6,4))
		srddata[i] = fix(strmid(full_line,10,2))
		for k = 0,7 do kpdata[k+i*8] = fix(strmid(full_line,12+2*k,2))
		kpsdata[i] = fix(strmid(full_line,28,3))
		for k = 0,7 do apdata[k+i*8] = fix(strmid(full_line,31+3*k,3))
		apmdata[i] = fix(strmid(full_line,55,3))
		cpdata[i] = float(strmid(full_line,58,3))
		c9data[i] = fix(strmid(full_line,61,1))
		ssndata[i] = fix(strmid(full_line,62,3))
		srfdata[i] = float(strmid(full_line,65,5))
		fqdata[i] = fix(strmid(full_line,70,1))
		kptimes[i*8.:(i+1)*8.-1.] = time_double('19'+year+'-'+month+'-'+$
			day+'/'+string(indgen(8)*3)+':00:00')
		daytimes[i] = time_double('19'+year+'-'+month+'-'+day)
		i = i+1.
	endwhile
	bad: close,lun
	free_lun,lun
endfor

store_data,'Kp',data={x: kptimes[0:i*8-1], y: kpdata[0:i*8-1]}
store_data,'ap',data={x: kptimes[0:i*8-1], y: apdata[0:i*8-1]}
store_data,'Sol_Rot_Num',data={x: daytimes[0:i-1], y: srndata[0:i-1]}
store_data,'Sol_Rot_Day',data={x: daytimes[0:i-1], y: srddata[0:i-1]}
store_data,'Kp_Sum',data={x: daytimes[0:i-1], y: kpsdata[0:i-1]}
store_data,'ap_Mean',data={x: daytimes[0:i-1], y: apmdata[0:i-1]}
store_data,'Cp',data={x: daytimes[0:i-1], y: cpdata[0:i-1]}
store_data,'C9',data={x: daytimes[0:i-1], y: c9data[0:i-1]}
store_data,'Sunspot_Number',data={x: daytimes[0:i-1], y: ssndata[0:i-1]}
store_data,'Solar_Radio_Flux',data={x: daytimes[0:i-1], y: srfdata[0:i-1]}
store_data,'Flux_Qualifier',data={x: daytimes[0:i-1], y: fqdata[0:i-1]}

end

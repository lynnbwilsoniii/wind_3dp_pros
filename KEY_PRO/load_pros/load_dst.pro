;+
;PROCEDURE:	load_dst
;PURPOSE:
;   loads DST data from a DST text file
;
;INPUTS:
;  none, but will call "timespan" if time_range is not already set.
;
;KEYWORDS:
;  time_range:	2 element vector specifying the time range.
;
;CREATED BY:	Peter Schroeder
;LAST MODIFIED: @(#)load_dst.pro	1.6 02/11/01
;-

pro load_dst,time_range=trange

file_prefix = '/home/wind/dat/misc/dst/dst'
if not keyword_set(trange) then get_timespan,tr else tr=time_double(trange)
if n_elements(tr) eq 1 then tr = [tr, tr+86399d0]

begintime = time_struct(tr(0))
endtime = time_struct(tr(1))

years = begintime.year+indgen(endtime.year-begintime.year+1)
nyears = n_elements(years)

dstdata = intarr(24.*366.*nyears)
times = dblarr(24.*366.*nyears)

i = 1l

for j=0,nyears-1 do begin
	file = file_prefix+strcompress(years(j),/rem)
	if file_test(file) eq 0 then continue
	if years(j) ge 2000 then year_pre = '20' else year_pre = '19'
	print,'Loading '+file+'...'
	get_lun,lun
	openr,lun,file
	on_ioerror,bad
	while not eof(lun) do begin
		full_line = ''
		readf,lun,full_line
		year = strmid(full_line,3,2)
		month = strmid(full_line,5,2)
		day = strmid(full_line,8,2)
		data = intarr(24)
		for k = 0,23 do data[k] = fix(strmid(full_line,20+4*k,4))
		mdata = fix(strmid(full_line,116,4))
		dstdata[(i-1)*24:i*24-1] = data
		times[(i-1)*24:i*24-1] = time_double(year_pre+year+'-'+month+'-'+$
			day+'/'+string(indgen(24)+1)+':00:00')
		i = i+1
	endwhile
	bad: close,lun
	free_lun,lun
endfor

i=i-1
if i gt 0 then $
  store_data,'dst',data={x: times[0:i*24-1], y: float(dstdata[0:i*24-1])} $
else message,/info,'No DST data during this time.'

end

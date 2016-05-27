;+
;NAME:		animate_en_pa_spec
;CALL:		animate_en_pa_spec,rate,[keywords]
;PARAMETERS:	rate: specifies the rate that the animation will
;		be displayed at, in percent of maximum.  For Sun Ultra
;		1 computers, a good value is 20.
;KEYWORDS:	units: the units ('df','eflux',etc.)
;		range: the z range (color scale) (should be set)
;		trange: the time range, as a 2-vector of strings
;		xrange: the xrange
;		sort: sorts the data points according to ndata
;		var_label: the variable labels
;		ascending: tells it to sort in ascending.  If not set,
;		sorts in descending order
;		ndata: the data to sort (default is 'n_3d_ph2')
;		picktimes: let's you interactively pick the time frame
;		from the tplot graph
;		wait: tells the program to wait for you to push return
;		before displaying the next graph
;		erange: the erange in a 2-vector
;		inst: which instrument to use (ex. 'el', 'eh', 'ph2')
;		numframes: total number of frames to create
;			Used when you only want, say, 20 frames over 3 hours
;CREATED:	Arjun Raj (3-17-98)
;-







pro animate_en_pa_spec,rate,units = units,range = range,trange = trange,xrange = xrange,sort = sort,var_label = var_label,b3=b3,ascending = ascending,wait = wait,ndata = ndata,picktimes = picktimes,erange = erange,plotenergy = plotenergy,smooth=smooth,inst = inst,numframes = numframes,_EXTRA = e

if not keyword_set(inst) then inst = 'el'
if not keyword_set(units) then units = 'eflux'
if not keyword_set(ndata) then ndata = 'n_3d_ph'
if not keyword_set(erange) then erange = [1,200000]
if not keyword_set(range) then range = [7.e5, 9.e7]
inst = 'get_' + inst

if keyword_set(picktimes) then begin
	ctime,trange;,npoints = 2
	trange = time_string(trange)
endif

alltimes = call_function(inst,/times)
data = call_function(inst,alltimes(0))
;alltimes(*) = alltimes(*) + data.integ_t*.5

;if k0                                                                                                                                  eyword_set(trange) then begin
;	thetrange = str_to_time(trange)
;	times = alltimes(where(alltimes ge thetrange(0) and alltimes le thetrange(1))) 
;endif else times = alltimes

times = alltimes


if keyword_set(sort) then begin
	if not keyword_set(ndata) then ndata = 'n_3d_ph'
	print, 'Sorting to '+ndata

	store_data,'intimes',data = {x:times+data.integ_t*.5,y:times}
	cut_time, trange,'intimes','thetimes'

	get_data,'thetimes',data = d
	times = d.y

	;print, 'trange = '	
	;print, trange


	;print, data.integ_t ,' sort integ_t'

	get_data,'thetimes',data = d
	;print, 'thetimes = '
	;print,time_string(d.x)

	interpolate,'thetimes',ndata,'finaltimes'
	get_data,'finaltimes',data = finaltimes
	sortindex = sort(finaltimes.y)
	if not keyword_set(ascending) then sortindex = reverse(sortindex)
	times = times(sortindex)
endif

;print, 'Time_string(times) = '
;print, time_string(times)
;print, finaltimes.y(sortindex)

;print, 'Number of total points = ', n_elements(times)

;stop

if not keyword_set(numframes) then begin
	nframes = n_elements(times)
	thestep = 1
endif else begin
	if n_elements(times) lt numframes then numframes = n_eements(times)
	nframes = numframes
	thestep = fix(n_elements(times)/numframes)
endelse

print, 'Total number of times: ',n_elements(times)
print, 'Times used: ', nframes
;print, 'Step: ',thestep
;print, 'Times/thestep: ', n_elements(times)/thestep

xanimate, set = [600,600,nframes]
currFrame = 0
i=0

while i le n_elements(times)-1 and currFrame le nframes -1 do begin
	print

	;print, 'i = ',i,' of ',n_elements(times)-1
	print, 'Frame ', currFrame+1,' of ',nframes
	get_en_pa_spec,call_function(inst,times(i)-3),units = units,range = range,erange= erange,var_label = var_label,_EXTRA=e

	print, 'Data time should be ' + time_string(times(i))
	print, 'Sort data should be ' , finaltimes.y(sortindex(i))
	print, 'Sort data interpolated to '+time_string(finaltimes.x(sortindex(i)))
	print
	if keyword_set(wait) then pause = get_kbrd(1)
	xanimate,frame=currFrame,window=!d.window

	i = i + thestep
	currFrame = currFrame +1
endwhile



xanimate,rate

end

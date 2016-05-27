;+
;NAME:		show_specs
;CALL:		show_specs,time,[keywords]
;KEYWORDS:	advance: advances to the next time
;		zlog: makes color axis log
;		subtract: subtracts 90 from 180 and 0
;		nlines: # of lines for the contour
;		nofill: doesn't fill in the contour
;		showdata: shows the data points
;		erange: the erange
;		xrange: the xrange
;		range: the zrange
;		b3: uses b3 data
;		units: specifies the units
;		var_label: specifies the variable labels
;		plotenergy: plots energy instead of velocity
;		vel: tells which velocity to use for bulk flow (def: v_3d_ph2)
;		smooth: smooths the data
;		onecnt: shows the one count line
;		eesah: does a plot for eesa high as well
;		pesah: does a plot for pesa high as well
;		elb: uses el burst data
;		sundir: plots the sun direction
;		print: prints the data
;NOTES:		Window 4 should be the tplot window (must be already tplotted)
;		Window 1 will have eesa low velocity graphs
;		Window 2 will have el_eh_spec
;		Window 3 will have eesa high velocity graphs (if EESAH is set)
;		Window 5 will have pesa high velocity graphs (if PESAH is set)
;CREATED:	Arjun Raj (8-19-97)
;-



pro show_specs,thetime,advance = advance,zlog=zlog,erange = erange,range = range,xrange = xrange,b3=b3,units = units,showdata = showdata,nlines = nlines,plotenergy = plotenergy,onecnt = onecnt,nofill = nofill,var_label = var_label,phb=phb,subtract = subtract,sundir = sundir,elb = elb,eesah = eesah,smooth = smooth,vel = vel,print = print,pesah = pesah,olines = olines,notctek = notctek


if not keyword_set(vel) then vel = 'v_3d_ph1'

if keyword_set(elb) then el = get_elb((thetime),advance = advance) else $
	el = get_el((thetime),advance = advance)

;if keyword_set(phb) then begin
;	elb = 1
;	el = get_phb((thetime),advance = advance)
;endif


eh = get_eh(el.time-4)
ph = get_ph2(el.time-4)
if keyword_set(elb) then ph = get_phb(el.time -1)
;if keyword_set(print) then ph = get_phb(el.time-1)
print,time_string(el.time)
print,time_string(eh.time)
print,time_string(ph.time)

print,'el.time = '+time_string(el.time)


if keyword_set(olines) then blah = olines else blah = 0
store_data,'blah',data = {ytitle:time_string(el.time-1), m:blah}



wi,4
get_data,'old_time',data = old_time,index = theindex
device, get_graphics = old,set_graphics = 6
color =!d.n_colors-1
@tplot_com
tplot_x = tplot_vars.settings.x
time_offset=tplot_vars.settings.time_offset
time_scale = tplot_vars.settings.time_scale


if theindex ne 0 then begin
	px = old_time.x
	;coords = convert_coord((px-time_offset)/time_scale,0,/data,/to_norm)
	coords = data_to_normal((px-time_offset)/time_scale,tplot_x)
	px = coords(0)
	plots,[px,px],[0,1],color = color,/norm,thick = 1,lines = 0
end
px = el.time
;coords = convert_coord((px-time_offset)/time_scale,0,/data,/to_norm)
coords = data_to_normal((px-time_offset)/time_scale,tplot_x)
plots,[coords(0),coords(0)],[0,1],color = color,/norm,thick = 1,lines = 0



device,set_graphics = old
store_data,'old_time',data = {x:px,y:px}

date = time_string(el.time)
newstring = strmid(date,0,10) + '_' + strmid(date,11,8)

;************COMPLETELY EXPERIMENTAL PRINTING THING******************

if keyword_set(print) then begin
	pp2,newstring,/land
	!p.multi = [0,1,32]
	device,font_size = 10
	;get_v_spec_t,el,sundir = sundir,erange = erange,range = range,b3 = b3,units = 'df',showdata = showdata,nlines = nlines,nofill = nofill,zlog = zlog,plotenergy = plotenergy,onecnt = onecnt,var_label = var_label,/cr,/gr,smooth = smooth,vel = vel,position=[.60,.50,.92,.95],olines = olines

	;if keyword_set(elb) then get_en_pa_spec,el,b3 = b3,zlog = zlog,xrange = xrange,onecnt = onecnt,sundir = sundir,range = range,units = units,subtract = subtract,position = [.08,.18,.40,.95] else $
;get_el_eh_spec,thetime,b3 = b3,sundir = sundir,zlog = zlog,xrange = xrange,onecnt = onecnt,range = range,units = units,subtract = subtract,position = [.08,.50,.40,.95]

	;MORE EXPERIMENTAL STUFF
	get_v_spec_t,el,sundir = sundir,erange = erange,range = range,b3 = b3,units = 'df',showdata = showdata,nlines = nlines,nofill = nofill,zlog = zlog,plotenergy = plotenergy,onecnt = onecnt,var_label = var_label,/cr,/gr,smooth = smooth,vel = vel,position=[.69,.62,.92,.95],pos2 = [.69,.18,.95,.5],olines = olines

	get_v_spec_t,ph,sundir = sundir,range = range,b3 = b3,units = 'df',showdata = showdata,nlines = nlines,nofill = nofill,zlog = zlog,plotenergy = plotenergy,onecnt = onecnt,/gr,smooth = smooth,vel = vel,position=[.05,.62,.3,.95],olines = olines

	get_v_spec_t,ph,sundir = sundir,range = range,b3 = b3,units = 'df',showdata = showdata,nlines = nlines,nofill = nofill,zlog = zlog,plotenergy = plotenergy,onecnt = onecnt,/nosub,/gr,smooth = smooth,vel = vel,position=[.38,.62,.61,.95],olines = olines

	if strpos(el.data_name, 'Burst') ne -1 then get_en_pa_spec,el,b3 = b3,zlog = zlog,xrange = xrange,onecnt = onecnt,sundir = sundir,range = range,units = units,subtract = subtract,position = [.05,.18,.3,.5],pos2 = [.38,.18,.59,.5] else $
			get_el_eh_spec,thetime,b3 = b3,zlog = zlog,xrange = xrange,onecnt = onecnt,sundir = sundir,range = range,units = units,subtract = subtract,thepos = [.05,.35,.59,.55],the2pos = [.05,.15,.59,.32]

	if keyword_set(notctek) then pplot2,newstring else pplot2,newstring,/col

endif else begin


	



;********************************


wi,1
get_v_spec_t,el,sundir = sundir,erange = erange,range = range,b3 = b3,units = 'df',showdata = showdata,nlines = nlines,nofill = nofill,zlog = zlog,plotenergy = plotenergy,onecnt = onecnt,var_label = var_label,/cr,/gr,smooth = smooth,vel = vel,olines = olines


wi,2


thetime = time_string(el.time)
if keyword_set(elb) then get_en_pa_spec,el,b3 = b3,zlog = zlog,xrange = xrange,onecnt = onecnt,sundir = sundir,range = range,units = units,subtract = subtract else $
get_el_eh_spec,thetime,b3 = b3,sundir = sundir,zlog = zlog,xrange = xrange,onecnt = onecnt,range = range,units = units,subtract = subtract

if keyword_set(eesah) then begin
	wi,3
	get_v_spec_t,eh,b3 = b3,sundir = sundir,units = 'df',showdata = showdata,onecnt = onecnt,nlines = nlines,nofill = nofill,zlog = zlog,plotenergy = plotenergy,/cr,/gr,smooth = smooth,vel = vel,olines = olines
endif

if keyword_set(pesah) then begin
	wi,5
	get_v_spec_t,ph,b3 = b3,sundir = sundir,units = 'df',showdata = showdata,onecnt = onecnt,nlines = nlines,nofill =nofill,zlog = zlog,plotenergy = plotenergy,/cr,/gr,smooth = smooth,vel = vel,olines = olines
	wi,6
	get_v_spec_t,ph,b3 = b3,sundir = sundir,units = 'df',showdata = showdata,onecnt = onecnt,nlines = nlines,nofill =nofill,zlog = zlog,plotenergy = plotenergy,/cr,/gr,smooth = smooth,vel = vel,/nosubtract,olines = olines

endif

if keyword_set(phb) then begin
	wi,5
	ph = get_phb(el.time - 1,advance=advance)
	get_v_spec_t,ph,sundir = sundir,erange = erange,range = range,b3 = b3,units = 'df',showdata = showdata,nlines = nlines,nofill = nofill,zlog = zlog,plotenergy = plotenergy,onecnt = onecnt,/cr,/gr,smooth = smooth,vel = vel,olines=olines
	wi,6
	get_v_spec_t,ph,sundir = sundir,erange = erange,range = range,b3 = b3,units = 'df',showdata = showdata,nlines = nlines,nofill = nofill,zlog = zlog,plotenergy = plotenergy,onecnt = onecnt,/cr,/gr,smooth = smooth,vel = vel,/nosub,olines = olines



endif


endelse

end

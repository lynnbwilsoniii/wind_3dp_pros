;+
;NOTE!:   This program is no longer maintained!  Use slice2d with ang=90.
;NAME:			cut2d
;PURPOSE:		creates a velocity or energy spectrogram
;			with v perp and v para as x and y, and the
;			specified units as z (color axis).
;			Also tranforms into bulk flow frame (unlike get_v_spec)
;CALL:			ex: get_v_spec_t,get_el('20:31'),[keywords]
;KEYWORDS:		XRANGE: vector specifying the xrange
;			RANGE: vector specifying the color range
;			UNITS: specifies the units ('eflux','df',etc.) (Def. is 'df')
;			NOZLOG: specifies a linear Z axis
;			THEBDATA: specifies b data to use (def is B3_gse)
;			VAR_LA: vector of tplot variables to show on plot
;			POSITION: positions the plot using a 4-vector
;			ERANGE: specifies the energy range to be used
;			NOFILL: doesn't fill the contour plot
;			NLINES: says how many lines to use if using NOFILL
;			SHOWDATA: plots all the data points over the contour
;			PLOTENERGY: plots using energy instead of velocity
;			VEL: tplot variable containing the velocity data
;			     (default is calculated with v_3d)
;			NOGRID: forces no triangulation
;			NOCROSS: suppresses cross section line plots
;			RESOLUTION: resolution of the mesh (default is 51)
;			NOSMOOTH: suppresses smoothing
;			NOSUN: suppresses the sun direction line
;			rmbins: tells the program to remove sun noise
;			theta:	how much theta range to cut out def. 40
;			phi:	how much phi range to cut out def. 20
;				both theta and phi only make sense for rmbins
;			NR: removes background noise from ph using noise_remove
;			noiselevel: background level in eflux
;			bottom: level to set as min eflux for background. def. is 0.
;			rm2: removes the sun noise using subtraction
;				REQUIRES write_ph.doc to run
;				Note: automatically sets /nosmooth
;				for smoothing, set /smooth
;			nlow: used with rm2.  Sets bottom of eflux noise level
;				def. 1e5
;			m: marks the tplot at the current time
;			filename: filename of stored data for rm2.
;			novelline: suppresses the velocity line
;LAST MODIFIED:		4-30-98
;CREATED BY:		Arjun Raj
;EXAMPLES:
;			cut2d,get_el('21:00')
;			displays 2d cut using el
;			cut2d,get_ph('21:00'),thebdata = 'Bexp'
;			displays 2d cut with Bexp used as b data
;			cut2d,get_ph(/adv), units = 'eflux'
;			advances time one step, uses eflux units
;			cut2d,get_el(/adv),erange = [25,900]
;			restricts energies to cut out photoelectrons
;			cut2d,get_el(/adv),vel = 'Vconv'
;			transforms into velocity frame, using specified velocity
;REMARKS:		when calling with phb and rm2, use file='write_phb.doc'
;			also, set the noiselevel to 1e5.  This gives the best
;			results
;
;
;  Modified by:  Lynn B. Wilson III
;
;  Last Modified:  08-15-2007
;-


;Yes, I know the program is a mess...
;Sorry.

pro cut2d, thedata2,nofix = nofix,nsteps = nsteps,xrange = xrange,$
           range = range, units = units,nozlog = nozlog,zlog = zlog,$
           thebdata = thebdata,b3 = b3,position = position,erange = erange,$
           nofill = nofill,var_label = var_label,nlines = nlines,$
           showdata = showdata,plotenergy = plotenergy,vel=vel,$
           nosubtract = nosubtract,nosmooth=nosmooth, smooth=smooth,$
           nocross = nocross,cross = cross,nogrid = nogrid,grid = grid,$
           resolution = resolution,pos2 = pos2,onecnt = onecnt,nosun = nosun,$
           sundir = sundir,olines = olines,noolines = noolines,$
           numolines = numolines,setpos = setpos,leavezero = leavezero,$
           rmbins = rmbins,nr = nr,noiselevel = noiselevel,bottom = bottom,$
           theta = theta,phi = phi,m=m,rm2=rm2,nlow = nlow,phb = phb,$
           filename = filename,novelline = novelline,subtract = subtract,$
           _EXTRA = e

thedata = thedata2   ;to protect the original data


if keyword_set(phb) then filename = 'write_phb.doc'


if keyword_set(rmbins) then begin
	print, 'Removing bins (bin_remove)'
	thedata = bin_remove(thedata,theta = theta,phi = phi)
endif ;else thedata = thedata2

;**************************************************************************
stop
;**************************************************************************


if keyword_set(rm2) then begin
	print, 'Removing bins (bin_remove2)'
	leavezero = 1
	if not keyword_set(smooth) then nosmooth = 1
	;nr = 1
	load_ph,new,filename = filename
	thedata = bin_remove2(thedata,theta = theta,phi = phi,new= new,nlow = nlow)
endif ;else thedata = thedata2


if keyword_set(nr) then begin
	print,'Removing Noise'
;print, noiselevel
	thedata = noise_remove(thedata,nlevel = noiselevel,bottom = bottom)
	leavezero = 1
endif

if keyword_set(m) then $
	new_time,'cut2d',thedata.time

numperrow=4

;MODIFICATIONS TO MAKE COMMAND LINE SMALLER
if not keyword_set(nozlog) then zlog = 1
if not keyword_set(nogrid) then grid = 1
if not keyword_set(nocross) then cross = 1
if not keyword_set(nosmooth) then smooth = 1
if not keyword_set(noolines) then begin
	if keyword_set(numolines) then olines = numolines else olines = 20
	endif
if not keyword_set(thebdata) then thebdata = 'wi_B3(GSE)'
if keyword_set(b3) then thebdata = 'wi_B3(GSE)'
print, 'B field used is '+thebdata
if not keyword_set(subtract) then nosubtract = 1
if not keyword_set(nosun) then sundir = 1

if keyword_set(zlog) then print,'zl'
if keyword_set(grid) then print,'grid'
if keyword_set(cross) then print,'cross'
if keyword_set(smooth) then print,'smooth'
if keyword_set(olines) then print,'olines'


;END MODIFICATiONS


if !d.name eq 'PS' then loadct,39

if not keyword_set(resolution) then resolution = 51
if resolution mod 2 eq 0 then resolution = resolution + 1

oldplot = !p.multi

if keyword_set(cross) then begin ;and  !d.name ne 'PS' then begin
	!p.multi = [0,2,1]
	grid = 1
endif

;if not keyword_set(vel) then vel = 'v_3d_ph'

if not keyword_set(position) then begin
	x_size = !d.x_size & y_size = !d.y_size
	xsize = .77
	yoffset = 0.
	d=1.
	if keyword_set(cross) then begin
		yoffset = yoffset + .5
		xsize = xsize/2.+.13/1.5
		y_size = y_size/2.
		x_size = x_size/2.
		d = .5
		if y_size le x_size then $
			pos2 = [.13*d+.05,.03+.13*d,.05+.13*d + xsize * y_size/x_size,.13*d + xsize+.03] else $
			pos2 = [.13*d+.05,.03+.13*d,.05+.13*d + xsize,.13*d + xsize *x_size/y_size+.03]

	endif
	if y_size le x_size then $
		position = [.13*d+.05,.13*d+yoffset,.05+.13*d + xsize * y_size/x_size,.13*d + xsize + yoffset] else $
		position = [.13*d+.05,.13*d+yoffset,.05+.13*d + xsize,.13*d + xsize *x_size/y_size + yoffset]
endif else begin
	if not keyword_set(pos2) then begin
		pos2 = position
		pos2(0) = position(0)
		pos2(2) = position(2)
		pos2(3) = position(1)-.08
		pos2(1) = .1
	endif
endelse


if keyword_set(var_label) and not keyword_set(setpos) then begin; and !d.name ne 'PS' then begin
	if keyword_set(cross) then begin
		pos2(1) = pos2(1) + .04
		pos2(3) = pos2(3) + .04
	endif
	position(1) = position(1) + .02
	position(3) = position(3) + .02
endif

if not keyword_set(nsteps) then nsteps = 18
if not keyword_set(units) then units = 'df'
if not keyword_set(nlines) then nlines = 60


theonecnt = thedata
thedata = conv_units(thedata,units)

;thedata.data(*,120)=0


;theonecnt = conv_units(theonecnt,'counts')
for i = 0,theonecnt.nenergy-1 do theonecnt.data(i,*) = 1
;theonecnt = conv_units(theonecnt,units)
;if theonecnt.units_name eq 'Counts' then theonecnt.data(*,*) = 1.

;**********************************************
bad_bins=where((thedata.dphi eq 0) or (thedata.dtheta eq 0) or $
	((thedata.data(0,*) eq 0.) and (thedata.theta(0,*) eq 0.) and $
	(thedata.phi(0,*) eq 180.)),n_bad)
good_bins=where(((thedata.dphi ne 0) and (thedata.dtheta ne 0)) and not $
	((thedata.data(0,*) eq 0.) and (thedata.theta(0,*) eq 0.) and $
	(thedata.phi(0,*) eq 180.)),n_good)

if n_bad ne 0 then print,'There are bad bins'


if thedata.valid ne 1 then begin
	print,'Not valid data'
	return
endif

bad120 = where(good_bins eq 120,count)
if count eq 1 and thedata.data_name eq 'Pesa High' then begin
	print, 'Fixing bad 120 bin'
	if n_bad eq 0 then bad_bins = [120] else bad_bins = [bad_bins,120]
	good_bins = good_bins(where(good_bins ne 120))
	n_bad = n_bad + 1
	n_good = n_good -1
endif



;**********************************************

;get the magnetic field into a variable

get_data,thebdata,data = mgf



;************EXPERIMENTAL INTERPOLATION FIX************
get_data,thebdata,data = bdata
index = where(bdata.x le thedata.time + 600 and bdata.x ge thedata.time - 600)
store_data,thebdata+'cut',data={x:bdata.x(index),y:bdata.y(index,*)}
;********

store_data,'time',data = {x:thedata.time+thedata.integ_t*.5}
;print, thedata.integ_t, ' Thedata.integ_t'
interpolate,'time',thebdata+'cut','Bfield'
get_data,'Bfield',data = mgf
bfield = fltarr(3)
bfield[0] = mgf.y(0,0)
bfield[1] = mgf.y(0,1)
bfield[2] = mgf.y(0,2)
print, 'All data interpolated to ' + time_string(mgf.x)

;In order to find out how many particles there are at all the different locations,
;we must transform the data into cartesian coordinates.

data = {dir:fltarr(n_good,3),energy:reverse(thedata.energy(*,0)),n:fltarr(thedata.nenergy,n_good)}

x = fltarr(n_good) & y = fltarr(n_good) & z = fltarr(n_good)

sphere_to_cart,1,thedata.theta(0,good_bins),thedata.phi(0,good_bins),x,y,z
data.dir(*,0) = x & data.dir(*,1) = y & data.dir(*,2) = z

if units eq 'counts' then $
	for i = 0,thedata.nenergy - 1 do $
		data.n(i,*) = thedata.data(thedata.nenergy-1-i,good_bins)/thedata.geom $
 else $
	for i = 0,thedata.nenergy - 1 do $
		data.n(i,*) = thedata.data(thedata.nenergy-1-i,good_bins)

;now the variable data contains both a tag with the directions associated with all the bins
;as well as all the counts.

if not keyword_set(erange) then begin
	erange = [data.energy(0,0),data.energy(thedata.nenergy-1,0)]
	eindex = indgen(thedata.nenergy)
endif else begin
	eindex = where(data.energy ge erange(0) and data.energy le erange(1))
	erange = [data.energy(eindex(0)),data.energy(eindex(n_elements(eindex)-1))]
endelse

;angles = angl(data.dir,bfield)

energy = data.energy(eindex)
n = data.n(eindex,*)

newdata = {dir:fltarr(n_elements(n),3),n:fltarr(n_elements(n))}

if strpos(thedata.data_name, 'Eesa') ne -1 then mass = 9.1e-31 $
	else mass = 1.67e-27

for i = 0,n_elements(energy)-1 do begin
	if not keyword_set(plotenergy) then $
		newdata.dir(i*n_elements(data.dir)/3:(i*n_elements(data.dir)/3+n_elements(data.dir)/3-1),*) = data.dir*sqrt(2*1.6e-19*energy(i)/mass) $
	else $
		newdata.dir(i*n_elements(data.dir)/3:(i*n_elements(data.dir)/3+n_elements(data.dir)/3-1),*) = data.dir*energy(i)

	newdata.n(i*n_elements(data.dir)/3:(i*n_elements(data.dir)/3+n_elements(data.dir)/3-1)) = reform(n(i,*))
endfor

;MAKE THE DIRECTIONS POINT THE RIGHT WAY************
;
;newdata.dir = -newdata.dir
if keyword_set(nosubtract) then print,'No velocity transform' else print,'Velocity used for subtraction is '+vel


if keyword_set(vel) then begin
	print,'Using '+vel+' for velocity vector'
	get_data,vel,data = dummy, index = theindex
	if theindex eq 0 then begin
		Print, 'Loading velocity data....'
		get_3dt,'v_3d','ph'
	endif

	interpolate,'time',vel,'value'
	get_data,'value',data = thevalue
	thevel = 1000.* reform(thevalue.y)
	if keyword_set(plotenergy) then factor = sqrt(total(thevel(*)^2))*mass/2./1.6e-19 else factor = 1.
endif else begin
	print, 'Calculating V with v_3d...'
	thevel = 1000. * v_3d(thedata)
	if keyword_set(plotenergy) then factor = sqrt(total(thevel(*)^2))*mass/2./1.6e-19 else factor = 1.
endelse


if not keyword_set(nosubtract) then begin
	newdata.dir(*,0) = newdata.dir(*,0) - thevel(0)*factor
	newdata.dir(*,1) = newdata.dir(*,1) - thevel(1)*factor
	newdata.dir(*,2) = newdata.dir(*,2) - thevel(2)*factor
endif else begin
	newdata.dir(*,0) = newdata.dir(*,0)
	newdata.dir(*,1) = newdata.dir(*,1)
	newdata.dir(*,2) = newdata.dir(*,2)
endelse




;**************NOW CONVERT TO THE DATA SET REQUIRED*****************
rot = cal_rot(bfield,thevel)

newdata.dir = newdata.dir#rot
if keyword_set(plotenergy) then factor=1. else factor = 1000.
vperp = (newdata.dir(*,1)^2 + newdata.dir(*,2)^2)^.5*newdata.dir(*,1)/abs(newdata.dir(*,1))/factor
vpara = newdata.dir(*,0)/factor
zdata = newdata.n

if keyword_set(sundir) then begin
	sund = [1,0,0]
	sund = sund#rot
	vperpsun = (sund(1)^2 + sund(2)^2)^.5*sund(1)/abs(sund(1))
	vparasun = sund(0)
endif


veldir = v_3d(thedata)

veldir = veldir#rot

;EXPERIMENTAL GET RID OF 0 THING*************
if not keyword_set(leavezero) then begin
	index = where(zdata ne 0)
	vperp = vperp(index)
	vpara = vpara(index)
	zdata = zdata(index)
endif else print, 'Zeros left in plot'

;EXPERIMENTAL GET RID OF SUN THING***********

index = where(zdata ge 0,count)
if count ne 0 then begin
	vperp = vperp(index)
	vpara = vpara(index)
	zdata = zdata(index)
endif



;******************NOW TO PLOT THE DATA********************

if not keyword_set(xrange) then begin
	themax = max(abs([vperp,vpara]))
	xrange = [-1*themax,themax]
endif else themax = max(abs(xrange))


if not keyword_set(range) then begin
	if not keyword_set(xrange) then begin	
		maximum = max(zdata)
		minimum = min(zdata(where(zdata ne 0)))
	endif else begin
		maximum = max(zdata(where(abs(vperp) le themax and abs(vpara) le themax)))
		minimum = min(zdata(where(zdata ne 0 and abs(vperp) le themax and abs(vpara) le themax)))
	endelse
endif else begin
	maximum = range(1)
	minimum = range(0)
endelse



if keyword_set(zlog) then $
	thelevels = 10.^(indgen(nlines)/float(nlines)*(alog10(maximum) - alog10(minimum)) + alog10(minimum)) $
else $
	thelevels = (indgen(nlines)/float(nlines)*(maximum-minimum)+minimum)
;**********EXTRA STUFF FOR THE CONTOUR LINE OVERPLOTS************
if keyword_set(olines) then begin
	if keyword_set(zlog) then $
		thelevels2 = 10.^(indgen(olines)/float(olines)*(alog10(maximum) - alog10(minimum)) + alog10(minimum)) $
else $
	thelevels2 = (indgen(olines)/float(olines)*(maximum-minimum)+minimum)

endif
;**********END EXTRA STUFF FOR LINE OVERPLOTS (MORE LATER)*************************************


thecolors = round((indgen(nlines)+1)*(!d.table_size-9)/nlines)+7

if not keyword_set(nofill) then fill = 1 else fill = 0

if not keyword_set(plotenergy) then begin
	xtitle = 'V Para (km/sec)'
	ytitle = 'V Perp (km/sec)'
endif else begin
	xtitle = 'E Para (eV)'
	ytitle = 'E Perp (eV)'
endelse

;**************************************************************************
stop
;**************************************************************************

if keyword_set(grid) then begin
	x= findgen(resolution)/(resolution-1)*(xrange(1)-xrange(0)) + xrange(0)
	spacing = (xrange(1)-xrange(0))/(resolution-1)
	triangulate,vpara,vperp,tr,b
	thesurf = trigrid(vpara,vperp,zdata,tr,[spacing,spacing], [xrange(0),xrange(0),xrange(1),xrange(1)],xgrid = xg,ygrid = yg )
	if keyword_set(smooth) then thesurf = smooth(thesurf,3)
	if n_elements(xg) mod 2 ne 1 then print,'The line plots are invalid',n_elements(xg)
	;print,n_elements(xg)
	contour,thesurf,xg,yg,$
		/closed,levels=thelevels,c_color = thecolors,fill=fill,$
		title = thedata.data_name+' '+time_string(thedata.time),$
		ystyle = 1,$
		ticklen = -0.01,$
		xstyle = 1,$
		xrange = xrange,$
		yrange = xrange,$
		xtitle = xtitle,$
		ytitle = ytitle,position = position
	if keyword_set(olines) then begin
		if !d.name eq 'PS' then somecol = !p.color else somecol = 0
		contour, thesurf,xg,yg,/closed,levels = thelevels2,ystyle = 1+4, $
			xstyle = 1+4,xrange = xrange, yrange = xrange, ticklen = 0,/noerase,position = position,col = somecol
	endif
endif else begin
	contour,zdata,vpara,vperp,/irregular,$
		/closed,levels=thelevels,c_color = thecolors,fill=fill,$
		title = thedata.data_name+' '+time_string(thedata.time) ,$
		ystyle = 1,$
		ticklen = -0.01,$
		xstyle = 1,$
		xrange = xrange,$
		yrange = xrange,$
		xtitle = xtitle,$
		ytitle = ytitle,position = position
	if keyword_set(olines) then begin
		if !d.name eq 'PS' then somecol = !p.color else somecol = 0
		contour, zdata,vpara,vperp,/irregular,/closed, levels = thelevels2, $
			ystyle = 1+4, xstyle = 1+4, ticklen = 0, xrange = xrange, yrange = xrange, position=position,/noerase, col = somecol
	endif
endelse

;**************************************************************************
stop
;**************************************************************************

oplot,[0,0],xrange,linestyle = 1
oplot,xrange,[0,0],linestyle = 1
if keyword_set(sundir) then oplot,[0,vparasun*max(xrange)],[0,vperpsun*max(xrange)]

if not keyword_set(novelline) then oplot,[0,veldir(0)],[0,veldir(1)],col= !d.table_size-9

;print, 'xvel, yvel = ',veldir(0), veldir(1)

;print, 'zvel = ',veldir(2)

if not keyword_set(plotenergy) then begin
	circy=sin(findgen(360)*!dtor)*sqrt(2.*1.6e-19*erange(0)/mass)/1000.
	circx=cos(findgen(360)*!dtor)*sqrt(2.*1.6e-19*erange(0)/mass)/1000.  ;sqrt(2*1.6e-19*energy(i)/mass)
	oplot,circx,circy,thick = 2

	circy=sin(findgen(360)*!dtor)*sqrt(2.*1.6e-19*erange(1)/mass)/1000.
	circx=cos(findgen(360)*!dtor)*sqrt(2.*1.6e-19*erange(1)/mass)/1000.  ;sqrt(2*1.6e-19*energy(i)/mass)
	oplot,circx,circy,thick = 2
endif else begin
	circy=sin(findgen(360)*!dtor)*erange(0)
	circx=cos(findgen(360)*!dtor)*erange(0)  ;sqrt(2*1.6e-19*energy(i)/mass)
	oplot,circx,circy,thick = 2

	circy=sin(findgen(360)*!dtor)*erange(1)
	circx=cos(findgen(360)*!dtor)*erange(1)  ;sqrt(2*1.6e-19*energy(i)/mass)
	oplot,circx,circy,thick = 2
endelse

;**************************************************************************
stop
;**************************************************************************

thetitle = thedata.units_name
if keyword_set(zlog) then thetitle = thetitle + ' (log)'
draw_color_scale,range=[minimum,maximum],log = zlog,yticks=10,title =thetitle


if keyword_set(showdata) then oplot,vpara,vperp,psym=1

;**************************************************************************
stop
;**************************************************************************

if keyword_set(var_label) then begin
	get_data,'time',data = theparticulartime
	;print, 'Vars interp. to '+time_string(theparticulartime.x)

	if keyword_set(vel) then velname = vel else velname = 'V_3D'

	if keyword_set(nosubtract) then outstring = velname + ' used (no trans)' else outstring = vel + 'used (trans)'
	for i = 0, n_elements(var_label)-1 do begin
		print,var_label(i)

		get_data,var_label(i),data = bdata
		index = where(bdata.x le thedata.time + 600 and bdata.x ge thedata.time - 600,count)
		if count ne 0 then begin
			store_data,var_label(i)+'cut',data={x:bdata.x(index),y:bdata.y(index,*)}


			interpolate,'time',var_label(i)+'cut','value'
			;get_data,var_label(i)+'cut',data = thename
			get_data,'value',data = thevalue
			outstring = outstring + '  ' + var_label(i) +'= '+ strtrim(string(format = '(G11.4)',thevalue.y(0)),2)
		endif
		if i mod numperrow eq 1 then outstring = outstring + '!c' 
	endfor
	xyouts,.13,.06,outstring,/normal
endif

;**************************************************************************
stop
;**************************************************************************

if keyword_set(cross) then begin
	n_elem = n_elements(thesurf(*,0))
	thetitle = thedata.units_name
	if keyword_set(zlog) then thetitle = thetitle + ' (log)'
	if keyword_set(plotenergy) then begin
		xtitle = 'Energy (eV)'
		vore = 'E'
	endif else begin
		xtitle = 'Velocity (km/sec)'
		vore = 'V'
	endelse


;HERE COMES SOME NEW COLOR STUFF
if !d.name eq 'PS' then thecolors = round((indgen(4)+1)*(!d.table_size-9)/4)+7 else begin
	thecolors=indgen(4)
	thecolors = thecolors + 3
endelse

	;first plot vpara on the + side
	plot,xg,[reverse(thesurf(n_elem/2:*,n_elem/2)),thesurf(n_elem/2+1:*,n_elem/2)],$
		xstyle = 1, ystyle =1,$
		xrange = xrange,yrange = [minimum,maximum],ylog = zlog, $
		title = 'Cross Sections',xtitle = xtitle,ytitle = thetitle,$
		position = pos2
	;overplot vpara on the minus side
	oplot,xg,[thesurf(0:n_elem/2,n_elem/2),reverse(thesurf(0:n_elem/2-1,n_elem/2))],color = thecolors(0)
	;now vperp on the + side
	oplot,xg,[reverse(reform(thesurf(n_elem/2,n_elem/2+1:*))),reform(thesurf(n_elem/2,n_elem/2:*))],color = thecolors(1)
	;and now vper on the - side
	oplot,xg,[reform(thesurf(n_elem/2,0:n_elem/2)),reverse(reform(thesurf(n_elem/2,0:n_elem/2-1)))],color = thecolors(2)


	;put a dotted line
	oplot,[0,0],[minimum,maximum],linestyle = 1
	if not keyword_set(plotenergy) then begin
		oplot,[sqrt(2.*1.6e-19*erange(0)/mass)/1000.,sqrt(2.*1.6e-19*erange(0)/mass)/1000.],[minimum,maximum],linestyle = 5
		oplot,-[sqrt(2.*1.6e-19*erange(0)/mass)/1000.,sqrt(2.*1.6e-19*erange(0)/mass)/1000.],[minimum,maximum],linestyle = 5
		oplot,[sqrt(2.*1.6e-19*erange(1)/mass)/1000.,sqrt(2.*1.6e-19*erange(1)/mass)/1000.],[minimum,maximum],linestyle = 5
		oplot,-[sqrt(2.*1.6e-19*erange(1)/mass)/1000.,sqrt(2.*1.6e-19*erange(1)/mass)/1000.],[minimum,maximum],linestyle = 5
		if keyword_set(onecnt) then begin
			oplot,sqrt(2.*1.6e-19*theonecnt.energy(*,0)/mass)/1000.,theonecnt.data(*,0),color = thecolors(3),linestyle = 3
			oplot,-sqrt(2.*1.6e-19*theonecnt.energy(*,0)/mass)/1000.,theonecnt.data(*,0),color = thecolors(3),linestyle = 3
		endif
	endif else begin
		oplot,[erange(0),erange(0)],[minimum,maximum],linestyle = 5
		oplot,-[erange(0),erange(0)],[minimum,maximum],linestyle = 5
		oplot,[erange(1),erange(1)],[minimum,maximum],linestyle = 5
		oplot,-[erange(1),erange(1)],[minimum,maximum],linestyle = 5
		if keyword_set(onecnt) then begin
			oplot,theonecnt.energy(*,0),theonecnt.data(*,0),color = thecolors(6),linestyle = 3
			oplot,-theonecnt.energy(*,0),theonecnt.data(*,0),color = thecolors(6),linestyle = 3
		endif
	endelse
	
	;now put the titles on the side of the graph
	positions = -findgen(5)*(pos2(3)-pos2(1))/5 + pos2(3)-.03
	xyouts,pos2(2) + .03,positions(0),vore+' para (+ side)',/norm,charsize = 1.01;.5
	xyouts,pos2(2) + .03,positions(1),vore+' para (- side)',/norm,color = thecolors(0),charsize = 1.01;.5
	xyouts,pos2(2) + .03,positions(2),vore+' perp (+ side)',/norm,color = thecolors(1),charsize = 1.01;.5
	xyouts,pos2(2) + .03,positions(3),vore+' perp (- side)',/norm,color = thecolors(2),charsize = 1.01;.5
	if keyword_set(onecnt) then xyouts,pos2(2) + .03,positions(4),'One count',/norm,color = thecolors(3),charsize = .5
endif
;**************************************************************************

stop

if !d.name ne 'PS' then !p.multi = oldplot
end

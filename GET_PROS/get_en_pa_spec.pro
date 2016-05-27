;+
;Name:		get_en_pa_spec
;Call:		get_en_pa_spec,get_el('19:49'),[keywords]
;Purpose:	To plot energy vs. pitch angle vs. counts at a specific time
;		Also can plot line plots at certain energies or 0, 90, and 180 deg.
;Keywords:	nofix:  tells the program not "clump" the data
;		nsteps: specifies the number of chunks used to fix the data
;			if not specified, uses 18
;		THEBDATA: specifies b data to use (def is B3_gse)
;		xrange: specifies the energy spectrum range
;			if not specified, uses all energies from instrument
;		range:  specifies the color axis range
;			default is the range of counts
;		nozl:	makes the color axis linear (log is def.)
;		units:  specifies the units
;			default is eflux
;		subtr:	for the line plots, subtracts the 90 deg data
;			from the 0 and 180.
;		angran:	sets the range of angles to include for the line plots
;			default is 30.
;		specsu:	subtracts the value at 90 deg (using angran) from the	
;			entire spectrogram
;		noline:	suppresses the line plots of energy
;		energi:	a vector of energies which will generate line plots of
;			pitch angle vs. counts.
;		var_la:	vector of tplot variables to put on plot
;		noB3:	doesn't use high resolution magnetic field data
;		nosun:  suppresses the anti-sun direction line
;Output:	The plot
;Last Modified by:	Arjun Raj (2-2-99)
;-

;Programming style is terrible, but it works.

pro get_en_pa_spec,thedata2,nofix=nofix,nsteps=nsteps,xrange=xrange,$
			range = range,units = units,zlog = zlog,b3 = b3, $
			position = position, nocscale = nocscale, forcerange = forcerange,$
			isel=isel,iseh=iseh,getrange = getrange,noy = noy,$
			var_label = var_label,angrange = angrange,noline=noline,pos2 = pos2,energies = energies,$
			noplot = noplot,get_data = get_data,noerase = noerase,specsubtract = specsubtract,$
			subtract = subtract,setrange = setrange,getotherrange = getotherrange,onecnt = onecnt,sundir = sundir,nosun = nosun, nob3 = nob3, nozl = nozl,thebdata = thebdata, rmbins= rmbins, theta = theta, phi = phi, nlow = nlow, filename = filename,noiselevel, bottom,nr=nr,rm2 = rm2,_EXTRA=e

thedata = thedata2

if !d.name eq 'PS' then loadct,39
numperrow = 4

if keyword_set(rmbins) then begin
	print, 'Removing bins (bin_remove)'
	thedata = bin_remove(thedata,theta = theta,phi = phi)
endif 


if keyword_set(rm2) then begin
	print, 'Removing bins (bin_remove2)'
	load_ph,new,filename = filename
	thedata = bin_remove2(thedata,theta = theta,phi = phi,new= new,nlow = nlow)
endif ;else thedata = thedata2


if keyword_set(nr) then begin
	print,'Removing Noise'
	thedata = noise_remove(thedata,nlevel = noiselevel,bottom = bottom)
endif



;(*******MODIFICATIONS TO MAKE EASIER TO USE************
if not keyword_set(nozl) then zlog = 1
;if not keyword_set(nob3) then b3 = 1
if keyword_set(b3) and not keyword_set(thebdata) then thebdata = 'B3_gsm'
if not keyword_set(thebdata) then begin
	thebdata = 'B3_gsm'
	b3=1
endif
if not keyword_set(nosun) then sundir=1

print, 'B field used is '+thebdata
;********END MODIFICATIONS************


if not keyword_set(nsteps) then nsteps = 18
if not keyword_set(angrange) then angrange = 30

;if not keyword_set(pos2) then begin
;	if keyword_set(var_label) then position(1) = position(1) + .08
;	if not keyword_set(noline) then position(1) = position(1) + .25
;	if keyword_set(energies) then position(1) = position(1) + .22
;endif


;*********POSITIONING STUFF**********
if not keyword_set(position) then begin
	if keyword_set(var_label) then begin
		if not keyword_set(noline) then begin
			position = [.1, .52,.85,.95]
			if not keyword_set(pos2) then pos2 = [position(0), .14,position(2), .45]
		endif else position = [.1, .1, .85, .95]
		labelpos = [.1, .08]
	endif else begin
		if not keyword_set(noline) then begin
			position = [.1, .52,.85,.95]
			if not keyword_set(pos2) then pos2 = [position(0),.08,position(2), .45]
		endif else position =[.1, .1, .85,.95]
	endelse
endif
;******END POSITIONING STUFF***********


if !d.name ne 'PS' then begin
	numPlots=0
	if not keyword_set(noline) then numPlots = numplots + 1
	if keyword_set(energies) then numPlots = numPlots + 1
	if numPlots eq 0 then !p.multi = 0 else !p.multi = [0,numPlots+1,1]
endif


theonecnt = thedata
;theonecnt = conv_units(theonecnt,'counts')
;for i = 0,theonecnt.nenergy-1 do theonecnt.data(i,*) = 1;theonecnt.geom

if not keyword_set(units) then units = 'eflux'

thedata = conv_units(thedata,units)
;theonecnt = conv_units(theonecnt,units)
;if theonecnt.units_name eq 'Counts' then theonecnt.data(*,*) = 1.

;**********************************************
;bad_bins=where((thedata.dphi eq 0) or (thedata.dtheta eq 0) or $
;	((thedata.data(0,*) eq 0.) and (thedata.theta(0,*) eq 0.) and $
;	(thedata.phi(0,*) eq 180.)),n_bad)
;good_bins=where(((thedata.dphi ne 0) and (thedata.dtheta ne 0)) and not $
;	((thedata.data(0,*) eq 0.) and (thedata.theta(0,*) eq 0.) and $
;	(thedata.phi(0,*) eq 180.)),n_good)

;if n_bad ne 0 then print,'There are bad bins'



;bad120 = where(good_bins eq 120,count)
;if count eq 1 and thedata.data_name eq 'Pesa High' then begin
;	print, 'Fixing bad 120 bin'
;	if n_bad eq 0 then bad_bins = [120] else bad_bins = [bad_bins,120]
;	good_bins = good_bins(where(good_bins ne 120))
;	n_bad = n_bad + 1
;	n_good = n_good -1
;endif


if thedata.valid ne 1 then begin
	print,'Not valid data'
	return
endif


usebins = thedata.bins(0,*)

for i = 1, thedata.nenergy-1 do usebins = usebins and thedata.bins(i,*)


good_bins = where(usebins ne 0, n_good)
bad_bins = where(usebins eq 0, n_bad)




;**********************************************

;get the magnetic field into a variable
;if keyword_set(B3) then begin
;	get_data,'B3_gsm',data = mgf,index = theindex
;	if theindex eq 0 then begin
;		get_mfi_3s
;		get_data,'B3_gsm',data = mgf
;	endif
;	Bname = 'B3_gsm'
;endif  ; else begin
	;get_data,'Bexp',data = mgf,index = theindex
	;if theindex eq 0 then begin
	;	get_mfi
	;	get_data,'Bexp',data = mgf
	;endif
	;Bname = 'Bexp'
;endelse
;get_data,thebdata,data = mgf

;************EXPERIMENTAL INTERPOLATION FIX************
;get_data,Bname,data = bdata
;index = where(bdata.x le thedata.time + 600 and bdata.x ge thedata.time - 600)
;store_data,Bname+'cut',data={x:bdata.x(index),y:bdata.y(index,*)}
;********

;print, 'All data interpolated to '+time_string(thedata.time+thedata.integ_t*.5)

store_data,'time',data = {x:thedata.time+thedata.integ_t*.5}
;interpolate,'time',Bname+'cut','Bfield'
;get_data,'Bfield',data = mgf

;now we have to find the magnetic field data which is interpolated to the data point we have

;bfield = fltarr(3)
;bfield[0] = mgf.y(0,0)
;bfield[1] = mgf.y(0,1)
;bfield[2] = mgf.y(0,2)

bfield = dat_avg(thebdata,thedata.time, thedata.end_time)
;print, bfield

;In order to find out how many particles there are at all the different locations,
;we must transform the data into cartesian coordinates.

data = {dir:fltarr(n_good,3),energy:reverse(thedata.energy(*,0)),n:fltarr(thedata.nenergy,n_good)}

x = fltarr(n_good) & y = fltarr(n_good) & z = fltarr(n_good)

sphere_to_cart,1,thedata.theta(0,good_bins),thedata.phi(0,good_bins),x,y,z
data.dir(*,0) = x & data.dir(*,1) = y & data.dir(*,2) = z


for i = 0,thedata.nenergy - 1 do $
		data.n(i,*) = thedata.data(thedata.nenergy-1-i,good_bins)

;now the variable data contains both a tag with the directions associated with all the bins
;as well as all the counts.

if not keyword_set(xrange) then begin
	xrange = [data.energy(0,0),data.energy(thedata.nenergy-1,0)]
	eindex = indgen(thedata.nenergy)
endif else begin
	if keyword_set(forcerange) then begin
		themin = max(data.energy(where(data.energy le xrange(0))))
		themax = min(data.energy(where(data.energy ge xrange(1))))
		eindex = where(data.energy ge themin and data.energy le themax)
	endif else begin
		eindex = where(data.energy ge xrange(0) and data.energy le xrange(1))
		xrange = [data.energy(eindex(0)),data.energy(eindex(n_elements(eindex)-1))]
	endelse
endelse

toplot = {ang:fltarr(n_good),energy:data.energy(eindex),n:fltarr(n_elements(eindex),n_good)}

angles = angl(data.dir,bfield)
angindex = sort(angles)
toplot.ang = angles(angindex)

;sunangle = angl([1,0,0],bfield)
;what we want is actually to plot the antisun direction
sunangle = 180. - angl([1,0,0],bfield)

toplot.n(*,*)=data.n(eindex,*)
toplot.n(*,*)=toplot.n(*,angindex)

if not keyword_set(nofix) then newdata = fixangdata(toplot,nsteps) else newdata = toplot

if keyword_set(specsubtract) then begin	
	thecounts = get_counts(newdata,angrange)
	for i = 0, n_elements(newdata.ang)-1 do newdata.n(*,i)= newdata.n(*,i)-thecounts.ninety
endif


if not keyword_set(range) then begin
	maximum = max(newdata.n)
	index = where(newdata.n ne 0.)
	minimum = min(newdata.n(index mod n_elements(newdata.n(*,0)),index/n_elements(newdata.n(*,0)) ))
endif else begin
	maximum = range(1)
	minimum = range(0)
endelse


if keyword_set(zlog) then $
	thelevels = 10.^(indgen(60)/60.*(alog10(maximum) - alog10(minimum)) + alog10(minimum)) $
else $
	thelevels = (indgen(60)/60.*(maximum-minimum)+minimum)

thecolors = round((indgen(60)+1)*(!d.table_size-9)/60)+7

thetimespan = time_string(thedata.time) +' -> '+ strmid(time_string(thedata.end_time),11,8)
thetitle = thedata.data_name + ' ' + thetimespan
if keyword_set(isel) and !d.name ne 'PS' then thetitle = 'Eesa Low'
if keyword_set(iseh) and !d.name ne 'PS' then thetitle = 'Eesa High'


if not keyword_set(noplot) then begin
if not keyword_set(noy) then begin
contour,newdata.n,newdata.energy,newdata.ang,$
		/normal,/xtype,/closed,levels=thelevels,c_color = thecolors,/fill,$
		title = thetitle ,$
		ystyle = 1,$
		ticklen = -0.01,$
		xstyle = 1,$
		xrange = xrange,$
		yrange = [0,180],$
		position = position,$
		xtitle = 'Energy (eV)',$
		noerase = noerase,$
		ytitle = 'Pitch Angle (degrees)',$
		_EXTRA = e
endif else $
contour,newdata.n,newdata.energy,newdata.ang,$
		/normal,/xtype,/closed,levels=thelevels,c_color = thecolors,/fill,$
		title = thetitle ,$
		ystyle = 1,$
		ticklen = -0.01,$
		xstyle = 1,$
		xrange = xrange,$
		yrange = [0,180],$
		position = position,$
		xtitle = 'Energy (eV)',$
		noerase = noerase,$
		yticks=1,$
		_EXTRA=e
endif

if keyword_set(sundir) then oplot,xrange,[sunangle,sunangle]

if not keyword_set(noplot) then begin
	axis,1,0,xaxis = 0,ticklen = .025,xticks = n_elements(newdata.energy)-1,xtickv = newdata.energy,/noerase,/data,charsize= .0001

	if not keyword_set(iseh) then $
		axis,xrange(0),1,yaxis = 0,ticklen = .025,yticks = n_elements(newdata.ang)-1,ytickv = newdata.ang,/noerase,/data,charsize = .0001 else $
		axis,xrange(1),1,yaxis = 1,ticklen = .025,yticks = n_elements(newdata.ang)-1,ytickv = newdata.ang,/noerase,/data,charsize = .0001
endif


thetitle = thedata.units_name
if keyword_set(zlog) then thetitle = thetitle + ' (log)'

if not keyword_set(nocscale) and not keyword_set(noplot) then $
	draw_color_scale,range=[minimum,maximum],log = zlog,yticks=10,title =thetitle

getrange = [minimum,maximum]

if not keyword_set(noline) then begin

;HERE COMES SOME NEW COLOR STUFF
if !d.name eq 'PS' then thecolors = round((indgen(3)+1)*(!d.table_size-9)/3)+7 else begin
	thecolors=indgen(3)
	thecolors = thecolors + 3
endelse



	thecounts = get_counts(newdata,angrange)
	if keyword_set(subtract) then begin
		islog = 0
		thecounts.oneeighty = thecounts.oneeighty-thecounts.ninety
		thecounts.zero = thecounts.zero - thecounts.ninety
		if keyword_set(setrange) then therange = setrange else $
			therange = [min([thecounts.zero,thecounts.oneeighty]),max([thecounts.zero,thecounts.oneeighty])]
	endif else begin
		if keyword_set(zlog) then islog = zlog else islog =0
		therange = [minimum,maximum]
	endelse
	getotherrange = therange
	position = [position(0),position(1)-.27,position(2),position(1)-.06]
	if not keyword_set(noplot) then begin
		if keyword_set(pos2) then position= pos2
		if not keyword_set(noy) then $
			plot,newdata.energy,thecounts.zero,/xlog,ylog = islog,/normal,$
				ystyle = 1,$
				ticklen = 0.01,$
				xstyle = 1,$
				xrange = xrange,$
				yrange = therange,$
				position = position,$
				;xtitle = 'Energy (eV)',$
				noerase = noerase,$
				ytitle = thedata.units_name $
		else $
			plot,newdata.energy,thecounts.zero,/xlog,ylog=islog,/normal,$
				ystyle = 1,$
				ticklen = 0.01,$
				yticks = 1,$
				ycharsize = 0.0001,$
				xstyle = 1,$
				xrange = xrange,$
				yrange = therange,$
				position = position,$
				;xtitle = 'Energy (eV)',$
				noerase = noerase

		if not keyword_set(subtract) then oplot,newdata.energy,thecounts.ninety,color = thecolors(1)
		oplot,newdata.energy,thecounts.oneeighty,color = thecolors(0)
		if keyword_set(onecnt) then begin
			oplot,reverse(theonecnt.energy(*,0)),reverse(theonecnt.data(*,0)),color = thecolors(2),linestyle=2
			if not keyword_set(isel) then xyouts,position(2) + .02,position(3) - .17,'One count',color = thecolors(2),/normal,charsize = .5
		endif
		if not keyword_set(isel) then begin
			if not keyword_set(subtract) then begin
				xyouts,position(2) + .02, position(3) - .02,'0 Deg.',/normal,charsize = .5
				xyouts,position(2) + .02, position(3) - .07,'90 Deg.',color = thecolors(1),/normal,charsize = .5
				xyouts,position(2) + .02, position(3) - .12,'180 Deg.',color = thecolors(0),/normal,charsize = .5
			endif else begin
				xyouts,position(2) + .02, position(3) - .02,'0-90 Deg.',/normal,charsize = .5
				xyouts,position(2) + .02, position(3) - .12,'180-90 Deg.',color = thecolors(0),/normal,charsize = .5
			endelse
		endif
	endif
endif


print,xrange


if keyword_set(energies) then begin
	index = find_closest(newdata.energy, energies)
	position = [position(0),position(1)-.23,position(2),position(1)-.06]
	thecolors = round((indgen(n_elements(index))+1)*(!d.table_size-9)/n_elements(index))+7

	if not keyword_set(noplot) then begin
		plot,newdata.ang,newdata.n(index(0),*),ylog = zlog,/normal,$
			ystyle = 1,$
			ticklen = 0.01,$
			xstyle = 1,$
			xrange = [0,180],$
			yrange = [minimum,maximum],$
			position = position,$
			xtitle = 'Pitch Angle (Degrees)',$
			noerase = noerase,$
			ytitle = thedata.units_name,color = 255
		xyouts,position(2) + .02, position(3) - .018,strtrim(string(format = '(G11.4)',$
			newdata.energy(index(0))),2) + ' eV',color = 255,/normal
		for i = 1,n_elements(index)-1 do begin
			oplot,newdata.ang,newdata.n(index(i),*),color = thecolors(i)
			xyouts,position(2)+.02,position(3)-.018-i*(position(3)-position(1))/n_elements(index),$
				strtrim(string(format = '(G11.4)',newdata.energy(index(i))),2) + ' eV',color = thecolors(i),/normal
		endfor
	endif
endif



if keyword_set(var_label) then begin
	currpos = [position(0),position(1)-.06]
	outstring = ''
	for i = 0, n_elements(var_label)-1 do begin

;		get_data,var_label(i),data = bdata
;		index = where(bdata.x le thedata.time + 600 and bdata.x ge thedata.time - 600,count)
;		if count ne 0 then begin
;			store_data,var_label(i)+'cut',data={x:bdata.x(index),y:bdata.y(index,*)}
;			interpolate,'time',var_label(i)+'cut','value'
;			get_data,var_label(i)+'cut',data = thename
;			get_data,'value',data = thevalue
;			outstring = outstring + '  ' + var_label(i) +'= '+ strtrim(string(format = '(G11.4)',thevalue.y(0)),2)
;		endif

		thevalue = dat_avg(var_label(i), thedata.time, thedata.end_time)

		outstring = outstring + '  ' + var_label(i) +'= '+ strtrim(string(format = '(G11.4)',thevalue),2)

		if i mod numperrow eq 1 then outstring = outstring + '!c' 
	endfor
	xyouts,labelpos(0),labelpos(1),outstring,/normal
endif



get_data=newdata

end

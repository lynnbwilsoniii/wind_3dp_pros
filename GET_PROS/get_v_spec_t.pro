;+
;NAME:			get_v_spec_t
;PURPOSE:		creates a velocity or energy spectrogram
;			with v perp and v para as x and y, and the
;			specified units as z (color axis).
;			Also tranforms into bulk flow frame (unlike get_v_spec)
;CALL:			ex: get_v_spec_t,get_el('20:31'),[keywords]
;KEYWORDS:		XRANGE: vector specifying the xrange
;			RANGE: vector specifying the color range
;			UNITS: specifies the units ('eflux','df',etc.)
;			ZLOG: specifies a logarithmic Z axis
;			B3: uses B3 data
;			VAR_LA: vector of tplot variables to show on plot
;			POSITION: positions the plot using a 4-vector
;			ERANGE: specifies the energy range to be used
;			NOFILL: doesn't fill the contour plot
;			NLINES: says how many lines to use if using NOFILL
;			SHOWDATA: plots all the data points over the contour
;			PLOTENERGY: plots using energy instead of velocity
;			VEL: tplot variable containing the velocity data
;			     (default is 'n_3d_ph2')
;			GRID: grids the data using triangulate and trigrid
;			NOSUBTRACT: doesn't transform into bulk flow frame
;			CROSS: puts up cross section line plots
;			RESOLUTION: resolution of the mesh (default is 51)
;			SMOOTH: smoothes the data using smooth
;			ONECNT: plots the one count data
;			SUNDIR: plots the sun direction line
;LAST MODIFIED:		8-18-97
;CREATED BY:		Arjun Raj
;-
; MODIFIED BY: Lynn B. Wilson III
;              06/18/2007

;Yes, I know the program is a mess...
;Sorry.

pro get_v_spec_t, thedata, $
  nofix = nofix, $
  nsteps = nsteps, $
  xrange = xrange, $
  range = range, $
  units = units, $
  zlog = zlog, $
  b3 = b3, $
  position = position, $
  erange = erange, $
  nofill = nofill, $
  var_label = var_label, $
  nlines = nlines, $
  showdata = showdata, $
  plotenergy = plotenergy, $
  vel=vel, $
  nosubtract = nosubtract, $
  smooth=smooth, $
  cross = cross, $
  grid = grid, $
  resolution = resolution, $
  pos2 = pos2, $
  onecnt = onecnt, $
  sundir = sundir, $
  olines = olines, $
  _EXTRA = e


if !d.name eq 'PS' then loadct,39

if not keyword_set(resolution) then resolution = 51
if resolution mod 2 eq 0 then resolution = resolution + 1

oldplot = !p.multi

if keyword_set(cross) and !d.name ne 'PS' then begin

	!p.multi = [0,2,1]
	grid = 1
	
endif

if not keyword_set(vel) then vel = 'v_3d_ph'

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
		
			pos2 = [.13*d+.05,.03+.13*d, $
			        .05+.13*d + xsize * y_size/x_size, $
			        .13*d + xsize+.03] else $
			        
			pos2 = [.13*d+.05,.03+.13*d,.05+.13*d + xsize, $
			       .13*d + xsize *x_size/y_size+.03]
			       

	endif
	
	if y_size le x_size then $
	
		position = [.13*d+.05,.13*d+yoffset, $
		            .05+.13*d + xsize * y_size/x_size, $
		            .13*d + xsize + yoffset] else $
		            
		position = [.13*d+.05,.13*d+yoffset, $
		            .05+.13*d + xsize, $
		            .13*d + xsize *x_size/y_size + yoffset]
		            
endif else begin

	if not keyword_set(pos2) then begin
	
		pos2 = position
		pos2(0) = position(0)
		pos2(2) = position(2)
		pos2(3) = position(1)-.08
		pos2(1) = .1
		
	endif
	
endelse


if keyword_set(var_label) and !d.name ne 'PS' then begin

	if keyword_set(cross) then begin
	
		pos2(1) = pos2(1) + .08
		pos2(3) = pos2(3) + .08
		
	endif
	
	position(1) = position(1) + .06
	position(3) = position(3) + .06
	
endif

if not keyword_set(nsteps) then nsteps = 18
if not keyword_set(units) then units = 'eflux'
if not keyword_set(nlines) then nlines = 60

theonecnt = thedata
thedata = conv_units(thedata,units)


theonecnt = conv_units(theonecnt,'counts')

for i = 0,theonecnt.nenergy-1 do theonecnt.data(i,*) = theonecnt.geomfactor

theonecnt = conv_units(theonecnt,units)

if theonecnt.units_name eq 'Counts' then theonecnt.data(*,*) = 1.

;**********************************************

bad_bins=where((thedata.dphi eq 0) or (thedata.dtheta eq 0) or $
	((thedata.data(0,*) eq 0.) and (thedata.theta(0,*) eq 0.) and $
	(thedata.phi(0,*) eq 180.)),n_bad)
	
good_bins=where(((thedata.dphi ne 0) and (thedata.dtheta ne 0)) and not $
	((thedata.data(0,*) eq 0.) and (thedata.theta(0,*) eq 0.) and $
	(thedata.phi(0,*) eq 180.)),n_good)

if n_bad ne 0 then print,'There are bad bins'
if thedata.valid ne 1 then print,'Not valid data'

;**********************************************
;get the magnetic field into a variable

if keyword_set(B3) then begin

	get_data,'wi_B3(GSE)',data = mgf,index = theindex
	
        if theindex eq 0 then begin
        
               get_mfi
               get_data,'B3GSE',data = mgf
               
        endif
        
	Bname = 'wi_B3(GSE)'
	
endif else begin

	get_data,'Bexp',data = mgf,index = theindex
	
	if theindex eq 0 then begin
	
		get_mfi
		get_data,'Bexp',data = mgf
		
	endif
	
	Bname = 'Bexp'
	
endelse

;************EXPERIMENTAL INTERPOLATION FIX************

get_data,Bname,data = bdata
index = where(bdata.x le thedata.time + 600 and bdata.x ge thedata.time - 600)
store_data,Bname+'cut',data={x:bdata.x(index),y:bdata.y(index,*)}

;********

store_data,'time',data = {x:thedata.time+thedata.integ_t*.5}
interpolate,'time',Bname+'cut','Bfield'
get_data,'Bfield',data = mgf
bfield = fltarr(3)
bfield[0] = mgf.y(0,0)
bfield[1] = mgf.y(0,1)
bfield[2] = mgf.y(0,2)
print,time_string(mgf.x)

;**********************************************
;In order to find out how many particles there are at all the different locations,
;we must transform the data into cartesian coordinates.

data = {dir:fltarr(n_good,3),energy:reverse(thedata.energy(*,0)), $
        n:fltarr(thedata.nenergy,n_good)}

x = fltarr(n_good) & y = fltarr(n_good) & z = fltarr(n_good)

sphere_to_cart,1,thedata.theta(0,good_bins),thedata.phi(0,good_bins),x,y,z
data.dir(*,0) = x & data.dir(*,1) = y & data.dir(*,2) = z

if units eq 'counts' then $

	for i = 0,thedata.nenergy - 1 do $
	
		data.n(i,*) = thedata.data(thedata.nenergy-1-i, $
		good_bins)/thedata.geom $
		
 else $
 
	for i = 0,thedata.nenergy - 1 do $
		data.n(i,*) = thedata.data(thedata.nenergy-1-i,good_bins)
		
;**********************************************
;now the variable data contains both a tag with the directions 
; associated with all the bins as well as all the counts.

if not keyword_set(erange) then begin

	erange = [data.energy(0,0),data.energy(thedata.nenergy-1,0)]
	eindex = indgen(thedata.nenergy)
	
endif else begin

	eindex = where(data.energy ge erange(0) and data.energy le erange(1))
	erange = [data.energy(eindex(0)), $
	          data.energy(eindex(n_elements(eindex)-1))]
endelse

;angles = angl(data.dir,bfield)
;**********************************************

energy = data.energy(eindex)
n = data.n(eindex,*)

newdata = {dir:fltarr(n_elements(n),3),n:fltarr(n_elements(n))}

if strpos(thedata.data_name, 'Eesa') ne -1 then mass = 9.1e-31 $
	else mass = 1.67e-27

for i = 0,n_elements(energy)-1 do begin
	if not keyword_set(plotenergy) then $
		newdata.dir(i*n_elements(data.dir)/3: $
		   (i*n_elements(data.dir)/3+n_elements(data.dir)/3-1),*) $
		   = data.dir*sqrt(2*1.6e-19*energy(i)/mass) $
		   
	else $
	
		newdata.dir(i*n_elements(data.dir)/3: $
		   (i*n_elements(data.dir)/3+n_elements(data.dir)/3-1),*) $
		   = data.dir*energy(i)

	newdata.n(i*n_elements(data.dir)/3: $
	   (i*n_elements(data.dir)/3+n_elements(data.dir)/3-1)) $
	   = reform(n(i,*))
	   
endfor
;**********************************************

;MAKE THE DIRECTIONS POINT THE RIGHT WAY************
;
;newdata.dir = -newdata.dir

print,'Velocity used is '+vel


if keyword_set(vel) then begin

	interpolate,'time',vel,'value'
	get_data,'value',data = thevalue
	thevel = 1000.* reform(thevalue.y)
	
	if keyword_set(plotenergy) then factor = sqrt(total(thevel(*)^2)) $
	                                        *mass/2./1.6e-19 else factor = 1.
	                                        
	if not keyword_set(nosubtract) then begin
	
		newdata.dir(*,0) = newdata.dir(*,0) - thevel(0)*factor
		newdata.dir(*,1) = newdata.dir(*,1) - thevel(1)*factor
		newdata.dir(*,2) = newdata.dir(*,2) - thevel(2)*factor
		
	endif else begin
	
		newdata.dir(*,0) = newdata.dir(*,0)
		newdata.dir(*,1) = newdata.dir(*,1)
		newdata.dir(*,2) = newdata.dir(*,2)
		
	endelse
	
endif




;**************NOW CONVERT TO THE DATA SET REQUIRED*****************

rot = cal_rot(bfield,thevel)

newdata.dir = newdata.dir#rot

;*******************************************************************************
;3dp> help, newdata.dir
;
;<Expression>    FLOAT     = Array[1815, 3]
;
;3dp> help, newdata.n
;
;<Expression>    FLOAT     = Array[1815]



if keyword_set(plotenergy) then factor=1. else factor = 1000.

;*******************************************************************************
; The following conditional statements were introduced to avoid errors due to
;  contour plots being unable to handle /nan values
;
;
;

vvpe1 = WHERE(FINITE(newdata.dir(*,1)),count)
vvpe2 = WHERE(FINITE(newdata.dir(*,2)),count)

vperp0 = (newdata.dir(vvpe1,1)^2 + newdata.dir(vvpe2,2)^2)^.5 $
         *newdata.dir(vvpe1,1)/abs(newdata.dir(vvpe1,1))/factor

vvpa = WHERE(FINITE(newdata.dir(*,0)),count)
vpara0 = newdata.dir(vvpa,0)/factor

zzz = where(finite(newdata.n),count)
zdata0 = newdata.n[zzz]

nvpe1 = n_elements(vvpe1)
nvpe2 = n_elements(vvpe2)
nvpa0 = n_elements(vvpa)
nzzz0 = n_elements(zzz)

hyperion = MIN([nvpe1,nvpe2,nvpa0,nzzz0],/nan)

;stop

CASE hyperion OF

  ;FOR (nvpe1 NE nvpe2 AND nvpe1 NE nvpa0 AND nvpe1 NE nzzz0) DO BEGIN

  nvpe1 : BEGIN
    npts0 = vvpe1
  END
  
  nvpe2 : BEGIN
    npts0 = vvpe2
  END
  
  nvpa0 : BEGIN
    npts0 = vvpa
  END
  
  nzzz0 : BEGIN
    npts0 = zzz
  END
  
ENDCASE


zdata = zdata0[npts0]
vperp = vperp0[npts0]
vpara = vpara0[npts0]


;stop
if keyword_set(sundir) then begin

	sund = [1,0,0]
	sund = sund#rot
	vperpsun = (sund(1)^2 + sund(2)^2)^.5*sund(1)/abs(sund(1))
	vparasun = sund(0)
	
endif


;******************NOW TO PLOT THE DATA********************

if not keyword_set(xrange) then begin

	themax = max(abs([vperp,vpara]),/nan)
	xrange = [-1*themax,themax]
	
endif else themax = max(abs(xrange),/nan)


if not keyword_set(range) then begin

	if not keyword_set(xrange) then begin	
		maximum = max(zdata,/nan)
		minimum = min(zdata(where(zdata ne 0.)),/nan)
	endif else begin
		maximum = max(zdata(where(abs(vperp) le themax $
		              and abs(vpara) le themax)),/nan)
		minimum = min(zdata(where(zdata ne 0. and $
		              abs(vperp) le themax and $
		              abs(vpara) le themax)),/nan)
		              
	endelse
	
endif else begin

	maximum = range(1)
	minimum = range(0)
	
endelse


;add_z = fltarr(n_elements(newdata.ang)*2)
;add_z(*) = 0
;if not keyword_set(energy) then begin
;	add_para = sqrt(2*1.6e-19 * (newdata.energy(0)-5) / mass) $
;                   *cos(!dtor * newdata.ang)/1000.
;	add_perp = sqrt(2*1.6e-19 * (newdata.energy(0)-5) / mass) $
;                   *sin(!dtor * newdata.ang)/1000.
;endif else begin
;	add_para = (newdata.energy(0)-2)*cos(!dtor*newdata.ang)
;	add_perp = (newdata.energy(0)-2)*cos(!dtor*newdata.ang)
;endelse
;add_para = [add_para,add_para]
;add_perp = [add_perp,-add_perp]


if keyword_set(zlog) then $

	thelevels = 10.^(indgen(nlines)/float(nlines)*(alog10(maximum) $
	            - alog10(minimum)) + alog10(minimum)) $
else $
	thelevels = (indgen(nlines)/float(nlines)*(maximum-minimum)+minimum)
	
;**********EXTRA STUFF FOR THE CONTOUR LINE OVERPLOTS************

if keyword_set(olines) then begin

	if keyword_set(zlog) then $
		thelevels2 = 10.^(indgen(olines)/float(olines)*(alog10(maximum) $
		            - alog10(minimum)) + alog10(minimum)) $
else $
	thelevels2 = (indgen(olines)/float(olines)*(maximum-minimum)+minimum)

endif

;**********END EXTRA STUFF FOR LINE OVERPLOTS (MORE LATER)***********************


thecolors = round((indgen(nlines)+1)*(!d.table_size-9)/nlines)+7

if not keyword_set(nofill) then fill = 1 else fill = 0

if not keyword_set(plotenergy) then begin
	xtitle = 'V Para (km/sec)'
	ytitle = 'V Perp (km/sec)'
endif else begin
	xtitle = 'E Para (eV)'
	ytitle = 'E Perp (eV)'
endelse


;*****************************************************************************

if keyword_set(grid) then begin

	x= findgen(resolution)/(resolution-1)*(xrange(1)-xrange(0)) + xrange(0)
	spacing = (xrange(1)-xrange(0))/(resolution-1)
	triangulate,vpara,vperp,tr,b
	thesurf = trigrid(vpara,vperp,zdata,tr,[spacing,spacing], $
	          [xrange(0),xrange(0),xrange(1),xrange(1)], $
	            xgrid = xg,ygrid = yg )

	            
	if keyword_set(smooth) then thesurf = smooth(thesurf,3)
	
	print,'If the following value is not odd, then the line plots' $
	      +' are invalid:',n_elements(xg)
	      
	;print,n_elements(xg)
	
	contour,thesurf,xg,yg,$
		/closed,levels=thelevels,c_color = thecolors,fill=fill,$
		title = thedata.data_name+' '+time_string(thedata.time)+$
		' - '+time_string(thedata.end_time),$
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
			xstyle = 1+4,xrange = xrange, yrange = xrange, $
			         ticklen = 0,/noerase,position = position, $
			         col = somecol
			         
	endif
	
endif else begin

	contour,zdata,vpara,vperp,/irregular,$
		/closed,levels=thelevels,c_color = thecolors,fill=fill,$
		title = thedata.data_name+' '+time_string(thedata.time)+$
		' - '+time_string(thedata.end_time),$
		ystyle = 1,$
		ticklen = -0.01,$
		xstyle = 1,$
		xrange = xrange,$
		yrange = xrange,$
		xtitle = xtitle,$
		ytitle = ytitle,position = position
		
	if keyword_set(olines) then begin
	
		if !d.name eq 'PS' then somecol = !p.color else somecol = 0
		contour, zdata,vpara,vperp,/irregular,/closed, $
		         levels = thelevels2, $
			ystyle = 1+4, xstyle = 1+4, ticklen = 0, $
			xrange = xrange, yrange = xrange, $
			position=position,/noerase, col = somecol
			
	endif
	
endelse


;*****************************************************************************
;adds dotted lines through middle of graph
;
oplot,[0,0],xrange,linestyle = 1
oplot,xrange,[0,0],linestyle = 1

if keyword_set(sundir) then oplot,[0,vparasun*max(xrange)], $
                                  [0,vperpsun*max(xrange)]

;*****************************************************************************
; The black circle in the center of the contour plot corresponds to the 
;   area inside which the data is invalid because it's below the lowest
;   energy range.
;
;

if not keyword_set(plotenergy) then begin

	circy=sin(findgen(360)*!dtor)*sqrt(2.*1.6e-19*erange(0)/mass)/1000.
	circx=cos(findgen(360)*!dtor)*sqrt(2.*1.6e-19*erange(0)/mass)/1000.  
	
;          sqrt(2*1.6e-19*energy(i)/mass)
;        !dtor = system variable defined as == !PI/180
;                (converts degrees to radians)

	oplot,circx,circy,thick = 2

	circy1=sin(findgen(360)*!dtor)*sqrt(2.*1.6e-19*erange(1)/mass)/1000.
	circx1=cos(findgen(360)*!dtor)*sqrt(2.*1.6e-19*erange(1)/mass)/1000.  
	
;          sqrt(2*1.6e-19*energy(i)/mass)
	
	oplot,circx1,circy1,thick = 2,linestyle = 2

endif else begin
	
	circy2=sin(findgen(360)*!dtor)*erange(0)
	circx2=cos(findgen(360)*!dtor)*erange(0)  ;sqrt(2*1.6e-19*energy(i)/mass)
	
	oplot,circx2,circy2,thick = 2

	circy3=sin(findgen(360)*!dtor)*erange(1)
	circx3=cos(findgen(360)*!dtor)*erange(1)  ;sqrt(2*1.6e-19*energy(i)/mass)
	
	oplot,circx3,circy3,thick = 2

endelse



thetitle = thedata.units_name

if keyword_set(zlog) then thetitle = thetitle + ' (log)'

draw_color_scale,range=[minimum,maximum],log = zlog,yticks=10,title = thetitle

;*****************************************************************************

if keyword_set(showdata) then oplot,vpara,vperp,psym=1


if keyword_set(var_label) then begin

	outstring = ''
	
	for i = 0, n_elements(var_label)-1 do begin
		print,var_label(i)

get_data,var_label(i),data = bdata

index = where(bdata.x le thedata.time + 600 and $
               bdata.x ge thedata.time - 600,count)
               
if count ne 0 then begin

store_data,var_label(i)+'cut',data={x:bdata.x(index),y:bdata.y(index,*)}


		interpolate,'time',var_label(i)+'cut','value'
		get_data,var_label(i)+'cut',data = thename
		get_data,'value',data = thevalue
		outstring = outstring + '  ' + var_label(i) +'= ' $
		        + strtrim(string(format = '(G11.4)',thevalue.y(0)),2)
		        
endif

		if i mod 2 eq 1 then outstring = outstring + '!c' 
		
	endfor
	
	xyouts,.13,.10,outstring,/normal
	
endif

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

;*****************************************************************************
;HERE COMES SOME NEW COLOR STUFF

if !d.name eq 'PS' then thecolors = round((indgen(4)+1)* $
                                    (!d.table_size-9)/4)+7 else begin
                                    
	thecolors=indgen(4)
	thecolors = thecolors + 3
	
endelse

;*****************************************************************************
;first plot vpara on the + side
	
	plot,xg,[reverse(thesurf(n_elem/2:*,n_elem/2)), $
	        thesurf(n_elem/2+1:*,n_elem/2)],$
		xstyle = 1, ystyle =1,$
		xrange = xrange,yrange = [minimum,maximum],ylog = zlog, $
		title = 'Cross Sections',xtitle = xtitle,ytitle = thetitle,$
		position = pos2
		
	;overplot vpara on the minus side
	
	oplot,xg,[thesurf(0:n_elem/2,n_elem/2), $
	         reverse(thesurf(0:n_elem/2-1,n_elem/2))], $
	         color = thecolors(0)
	         
;*****************************************************************************
;now vperp on the + side
	
	oplot,xg,[reverse(reform(thesurf(n_elem/2,n_elem/2+1:*))), $
	         reform(thesurf(n_elem/2,n_elem/2:*))], $
	         color = thecolors(1)
	         
	;and now vper on the - side
	
	oplot,xg,[reform(thesurf(n_elem/2,0:n_elem/2)), $
	     reverse(reform(thesurf(n_elem/2,0:n_elem/2-1)))], $
	     color = thecolors(2)

;*****************************************************************************
;put a dotted line
	
	oplot,[0,0],[minimum,maximum],linestyle = 1
	
	if not keyword_set(plotenergy) then begin
	
		oplot,[sqrt(2.*1.6e-19*erange(0)/mass)/1000., $
		      sqrt(2.*1.6e-19*erange(0)/mass)/1000.], $
		      [minimum,maximum],linestyle = 5
		      
		oplot,-[sqrt(2.*1.6e-19*erange(0)/mass)/1000., $
		      sqrt(2.*1.6e-19*erange(0)/mass)/1000.], $
		      [minimum,maximum],linestyle = 5
		      
		oplot,[sqrt(2.*1.6e-19*erange(1)/mass)/1000., $
		      sqrt(2.*1.6e-19*erange(1)/mass)/1000.], $
		      [minimum,maximum],linestyle = 5
		      
		oplot,-[sqrt(2.*1.6e-19*erange(1)/mass)/1000., $
		      sqrt(2.*1.6e-19*erange(1)/mass)/1000.], $
		      [minimum,maximum],linestyle = 5
		      
		if keyword_set(onecnt) then begin
		
	             oplot,sqrt(2.*1.6e-19*theonecnt.energy(*,0)/mass)/1000.,$
			   theonecnt.data(*,0),color = thecolors(3), $
			   linestyle = 3
		     oplot,-sqrt(2.*1.6e-19*theonecnt.energy(*,0)/mass)/1000.,$
			   theonecnt.data(*,0),color = thecolors(3), $
			   linestyle = 3
		endif
		
	endif else begin
	
		oplot,[erange(0),erange(0)],[minimum,maximum],linestyle = 5
		oplot,-[erange(0),erange(0)],[minimum,maximum],linestyle = 5
		oplot,[erange(1),erange(1)],[minimum,maximum],linestyle = 5
		oplot,-[erange(1),erange(1)],[minimum,maximum],linestyle = 5
		
		if keyword_set(onecnt) then begin
		
		   oplot,theonecnt.energy(*,0),theonecnt.data(*,0), $
		         color = thecolors(6),linestyle = 3
		   
		   oplot,-theonecnt.energy(*,0),theonecnt.data(*,0), $
		         color = thecolors(6),linestyle = 3
		endif
		
	endelse
	
;*****************************************************************************
;now put the titles on the side of the graph
	
	positions = -findgen(5)*(pos2(3)-pos2(1))/5 + pos2(3)-.03
	xyouts,pos2(2) + .03,positions(0),vore+' para (+ side)', $
	      /norm,charsize = .5
	xyouts,pos2(2) + .03,positions(1),vore+' para (- side)', $
	      /norm,color = thecolors(0),charsize = .5
	xyouts,pos2(2) + .03,positions(2),vore+' perp (+ side)', $
	      /norm,color = thecolors(1),charsize = .5
	xyouts,pos2(2) + .03,positions(3),vore+' perp (- side)', $
	      /norm,color = thecolors(2),charsize = .5
	      
	if keyword_set(onecnt) then xyouts,pos2(2) + .03, $
	             positions(4),'One count',/norm, $
	             color = thecolors(3),charsize = .5
endif

if !d.name ne 'PS' then !p.multi = oldplot

end

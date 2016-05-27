;+
;Name:		get_el_eh_spec
;Call:		get_el_eh_spec,'19:49',[keywords]
;Purpose:	To plot energy vs. pitch angle vs. counts at a specific time
;		Also can plot line plots at certain energies or 0, 90, and 180 deg.
;		Like get_en_pa_spec, but can show eesa Low and eesa High at the same time
;Keywords:	nofix:  tells the program not "clump" the data
;		nsteps: specifies the number of chunks used to fix the data
;			if not specified, uses 18
;		xrange: specifies the energy spectrum range
;			if not specified, uses all energies from instrument
;		range:  specifies the color axis range
;			default is the range of counts
;		THEBDATA: specifies b data to use (def is B3_gse)
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
;			pitch angle vs. counts. (This is not really supported anymore)
;		var_la:	vector of tplot variables to put on plot
;		noB3:	doesn't use high resolution magnetic field data
;		nosun:  suppresses the sun direction line
;		cutoff:	the cutoff energy between el and eh.
;			goes to the next lowest el energy bin and makes that the cutoff
;		advanc:	advances the time.
;		pick:	allows user to pick time of a tplot window
;Output:	The plot
;Last Modified by:	Arjun Raj (3-3-98)
;-




pro get_el_eh_spec,time,nofix=nofix,nsteps=nsteps,xrange=xrange1,$
			range = range,units = units,zlog = zlog,b3 = b3,$
			advance = advance,sundir = sundir,cutoff = cutoff,$
			var_label = var_label,energies = energies,noline = noline,$
			subtract = subtract,specsubtract = specsubtract,$
			setrange = setrange,onecnt = onecnt,thepos = thepos,$
			the2pos = the2pos,nosun = nosun, nob3 = nob3,$
			nozl = nozl,picktimes = picktimes, thebdata = thebdata

numperrow = 4


;(*******MODIFICATIONS TO MAKE EASIER TO USE************
if not keyword_set(nozl) then zlog = 1
if not keyword_set(nob3) then b3 = 1
if not keyword_set(nosun) then sundir=1
;********END MODIFICATIONS************


;******PICKTIMES STUFF***********

if keyword_set(picktimes) then begin
	ctime,trange,npoints = 1
	time = time_string(trange)
endif
;print, time


;********END PICKTIMES *********


;*********POSITIONING STUFF**********

if not keyword_set(thepos) then begin
	if keyword_set(var_label) then begin
		if not keyword_set(noline) then begin
			thepos = [.1, .52,.85,.95]
			if not keyword_set(the2pos) then the2pos = $
			     [thepos(0), .14,thepos(2), .45]
		endif else thepos = [.1, .1, .85, .95]
		labelpos = [.48, .08]
	endif else begin
		if not keyword_set(noline) then begin
			thepos = [.1, .52,.85,.95]
			if not keyword_set(the2pos) then the2pos = $
			     [thepos(0),.08,thepos(2), .45]
		endif else thepos =[.1, .1, .85,.95]
	endelse
endif
;******END POSITIONING STUFF***********



el = get_el(time,advance = advance)
eh = get_eh(el.time-4)

if el.valid ne 1 then begin
	print, 'Not valid el data!'
	return
endif

if eh.valid ne 1 then begin
	print, 'Not valid eh data!'
	return
endif

oldplot = !p.multi
if !d.name ne 'PS' then !p.multi = [0,2,1]

bottom = .2

if keyword_set(energies) then begin
	!p.multi = [0,9,1]
	bottom= bottom + .25
endif

if not keyword_set(cutoff) then cutoff = 1150.
if cutoff le 172. then cutoff = 180.
if cutoff ge 1136 then cutoff = 1150

energies_el = (el.energy(*,0))
energies_eh = (eh.energy(*,0))

if not keyword_set(xrange1) then xrange = [min(energies_el),max(energies_eh)] $
     else xrange = xrange1

index_el = where(energies_el ge xrange(0) and energies_el le cutoff)

xrange(0) = min(energies_el(index_el))
cutoff = max(energies_el(index_el))

index_eh = where(energies_eh le xrange(1) and energies_eh ge cutoff)
xrange(1) = max(energies_eh(index_eh))
cutoff_eh = max(energies_eh(where(energies_eh le cutoff)))


if not keyword_set(range) then begin
	get_en_pa_spec,el,/noplot,b3=b3,xrange = [xrange(0)-1,cutoff+1],$
	     getrange = range1,units = units,specsubtract = specsubtract,$
	     thebdata = thebdata
	get_en_pa_spec,eh,/noplot,b3=b3,xrange = [cutoff_eh-1,xrange(1)+1],$
	     getrange = range2,units = units,specsubtract = specsubtract,$
	     thebdata = thebdata
	range = [min([range1,range2]),max([range1,range2])]
endif

;**************HERE"S THE STUFF FOR THE SET POSITION PLOTS*********

if keyword_set(thepos) then begin

cutoffpos = (alog10(cutoff)-alog10(xrange(0)))/(alog10(xrange(1))-$
           alog10(xrange(0)))*(thepos(2)-thepos(0)) + thepos(0)

cutoffpos2 = (alog10(cutoff)-alog10(xrange(0)))/(alog10(xrange(1))-$
           alog10(xrange(0)))*(the2pos(2)-the2pos(0)) + the2pos(0)


if not keyword_set(setrange) then begin

get_en_pa_spec,el,zlog = zlog,/isel,/nocscale,units = units,b3 = b3,$
       sundir = sundir,nofix = nofix,nsteps = nsteps,$
       position = [thepos(0),thepos(1),cutoffpos,thepos(3)],$
       pos2 = [the2pos(0),the2pos(1),cutoffpos2 ,the2pos(3)],$
       range = range,xrange = [xrange(0)-1,cutoff+1],noline = noline,$
       get_data = newdata_el,subtract = subtract,getotherrange = otherrange,$
       specsubtract = specsubtract,onecnt = onecnt,thebdata = thebdata

endif else begin

get_en_pa_spec,el,zlog = zlog,/isel,/nocscale,units = units,b3 = b3,$
       nofix = nofix,nsteps = nsteps,position = [thepos(0),thepos(1),cutoffpos,$
       thepos(3)],pos2 = [the2pos(0),the2pos(1),cutoffpos2 ,the2pos(3)],$
       range = range,xrange = [xrange(0)-1,cutoff+1],noline = noline,$
       get_data = newdata_el,subtract = subtract,sundir = sundir,$
       setrange = setrange,specsubtract = specsubtract,onecnt = onecnt,$
       thebdata = thebdata

endelse

if keyword_set(setrange) then otherrange = setrange

get_en_pa_spec,eh,zlog = zlog,units = units,/noerase,sundir = sundir,$
       /noy,/iseh,b3 = b3,nofix = nofix,nsteps = nsteps,$
       position = [cutoffpos,thepos(1),thepos(2),thepos(3)],$
       pos2 = [cutoffpos2,the2pos(1),the2pos(2),the2pos(3)] ,$
       range = range,/forcerange,xrange = [cutoff,xrange(1)],$
       yticklen=0.,ycharsize=.0001,noline = noline,get_data = newdata_eh,$
       subtract = subtract,setrange = otherrange,specsubtract = specsubtract,$
       onecnt = onecnt,thebdata = thebdata


store_data,'time',data = {x:el.time+el.integ_t*.5}


if keyword_set(var_label) then begin
	outstring = ''
	for i = 0, n_elements(var_label)-1 do begin
		print, var_label(i)

;		get_data,var_label(i),data = bdata
;		index = where(bdata.x le el.time + 600 and bdata.x ge el.time - 600,count)
;		if count ne 0 then begin
;			store_data,var_label(i)+'cut',data={x:bdata.x(index),y:bdata.y(index,*)}
;			interpolate,'time',var_label(i)+'cut','value'
;			get_data,var_label(i)+'cut',data = thename
;			get_data,'value',data = thevalue
;			outstring = outstring + '  ' + var_label(i) +'= '+ strtrim(string(format = '(G11.4)',thevalue.y(0)),2)
;		endif

		thevalue = dat_avg(var_label(i), el.time, el.end_time)

		outstring = outstring + '  ' + var_label(i) +'= '$
		    +strtrim(string(format = '(G11.4)',thevalue),2)

		if i mod numperrow eq 1 then outstring = outstring + '!c' 
	endfor
	xyouts,labelpos(0),labelpos(1),outstring,/normal
endif


position = [.1,bottom - .25,.85,bottom-.06]

if keyword_set(energies) then begin
	newdata_el_eh = {energy:[newdata_el.energy,newdata_eh.energy(1:*)]}
	index = find_closest(newdata_el_eh.energy,energies)

	thecolors = round((indgen(n_elements(index))+1)$
	          *(!d.table_size-9)/n_elements(index))+7

	if newdata_el_eh.energy(index(0)) gt cutoff then $
	       theangles = newdata_eh.ang else theangles = newdata_el.ang
	       
	if newdata_el_eh.energy(index(0)) gt cutoff then $
	
		data = newdata_eh.n(where(newdata_eh.energy eq $
		      newdata_el_eh.energy(index(0))),*) else $
		data = newdata_el.n(where(newdata_el.energy eq $
		      newdata_el_eh.energy(index(0))),*)
	
	plot,theangles,data,ylog = zlog,/normal,$
		ystyle = 1,$
		ticklen = 0.01,$
		xstyle = 1,$
		xrange = [0,180],$
		yrange = range,$
		position = position,$
		xtitle = 'Pitch Angle (Degrees)',$
		/noerase,$
		ytitle = el.units_name,color = 255
		
	xyouts,position(2) + .02, position(3) - .018,$
	     strtrim(string(format = '(G11.4)',$
		newdata_el_eh.energy(index(0))),2) + ' eV',color = 255,/normal
		
	for i = 1,n_elements(index)-1 do begin
		if newdata_el_eh.energy(index(i)) gt cutoff then $
		     theangles = newdata_eh.ang else theangles = newdata_el.ang
		if newdata_el_eh.energy(index(i)) gt cutoff then $
			data = newdata_eh.n(where(newdata_eh.energy eq $
			    newdata_el_eh.energy(index(i))),*) else $
			data = newdata_el.n(where(newdata_el.energy eq $
			   newdata_el_eh.energy(index(i))),*)

		oplot,theangles,data,color = thecolors(i)
		xyouts,position(2)+.02,$
		   position(3)-.018-i*(position(3)-position(1))/n_elements(index),$
                   strtrim(string(format = '(G11.4)',$
                   newdata_el_eh.energy(index(i))),2) + ' eV',$
                   color =thecolors(i),/normal
	endfor

endif

thetimespan = time_string(el.time) +'-'+ strmid(time_string(el.end_time),11,8)
thetitle = el.data_name + '  ' + thetimespan

thetimespan = time_string(eh.time) +'-'+ strmid(time_string(eh.end_time),11,8)
thetitle = thetitle + '!c' + eh.data_name + ' ' + thetimespan


xyouts,.05,.04,thetitle,/normal




endif else begin



;*************************************************************



cutoffpos = (alog10(cutoff)-alog10(xrange(0)))/(alog10(xrange(1))-$
          alog10(xrange(0)))*.75 + .1

if not keyword_set(setrange) then begin

get_en_pa_spec,el,zlog = zlog,/isel,/nocscale,units = units,b3 = b3,$
       sundir = sundir,nofix = nofix,nsteps = nsteps,$
       position = [.1,bottom,cutoffpos,.95],range = range,$
       xrange = [xrange(0)-1,cutoff+1],noline = noline,$
       get_data = newdata_el,subtract = subtract,getotherrange = otherrange,$
       specsubtract = specsubtract,onecnt = onecnt,thebdata = thebdata

endif else begin

get_en_pa_spec,el,zlog = zlog,/isel,/nocscale,units = units,b3 = b3,$
       nofix = nofix,nsteps = nsteps,position = [.1,bottom,cutoffpos,.95],$
       range = range,xrange = [xrange(0)-1,cutoff+1],noline = noline,$
       get_data = newdata_el,subtract = subtract,sundir = sundir,$
       setrange = setrange,specsubtract = specsubtract,onecnt = onecnt

endelse

if keyword_set(setrange) then otherrange = setrange

get_en_pa_spec,eh,zlog = zlog,units = units,/noerase,sundir = sundir,/noy,$
       /iseh,b3 = b3,nofix = nofix,nsteps = nsteps,$
       position = [cutoffpos,bottom,.85,.95],range = range,/forcerange,$
       xrange = [cutoff,xrange(1)],yticklen=0.,ycharsize=.0001,$
       noline = noline,get_data = newdata_eh,subtract = subtract,$
       setrange = otherrange,specsubtract = specsubtract,onecnt = onecnt,$
       thebdata = thebdata

;print,max(newdata_el.n)
;;print,max(newdata_eh.n)


position = [.1,bottom - .25,.85,bottom-.06]

if keyword_set(energies) then begin
	newdata_el_eh = {energy:[newdata_el.energy,newdata_eh.energy(1:*)]}
	index = find_closest(newdata_el_eh.energy,energies)

	thecolors = round((indgen(n_elements(index))+1)*$
	          (!d.table_size-9)/n_elements(index))+7

	if newdata_el_eh.energy(index(0)) gt cutoff then $
	       theangles = newdata_eh.ang else theangles = newdata_el.ang
	       
	if newdata_el_eh.energy(index(0)) gt cutoff then $
	
		data = newdata_eh.n(where(newdata_eh.energy eq $
		     newdata_el_eh.energy(index(0))),*) else $
		     
		data = newdata_el.n(where(newdata_el.energy eq $
		     newdata_el_eh.energy(index(0))),*)
	
	plot,theangles,data,ylog = zlog,/normal,$
		ystyle = 1,$
		ticklen = 0.01,$
		xstyle = 1,$
		xrange = [0,180],$
		yrange = range,$
		position = position,$
		xtitle = 'Pitch Angle (Degrees)',$
		/noerase,$
		ytitle = el.units_name,color = 255
		
	xyouts,position(2) + .02, $
	   position(3) - .018,strtrim(string(format = '(G11.4)',$
           newdata_el_eh.energy(index(0))),2) + ' eV',color = 255,/normal
           
	for i = 1,n_elements(index)-1 do begin
	
		if newdata_el_eh.energy(index(i)) gt cutoff then $
		  theangles = newdata_eh.ang else theangles = newdata_el.ang
		  
		if newdata_el_eh.energy(index(i)) gt cutoff then $
		
			data = newdata_eh.n(where(newdata_eh.energy eq $
			     newdata_el_eh.energy(index(i))),*) else $
			     
			data = newdata_el.n(where(newdata_el.energy eq $
			     newdata_el_eh.energy(index(i))),*)

		oplot,theangles,data,color = thecolors(i)
		
		xyouts,position(2)+.02,position(3)-.018-i*$
		   (position(3)-position(1))/n_elements(index),$
                    strtrim(string(format = '(G11.4)',$
                    newdata_el_eh.energy(index(i))),2) + ' eV',$
                    color =thecolors(i),/normal
	endfor

endif





;if !d.name ne 'PS' then begin

thetimespan = time_string(el.time) +'-'+ strmid(time_string(el.end_time),11,8)
thetitle = el.data_name + '  ' + thetimespan

thetimespan = time_string(eh.time) +'-'+ strmid(time_string(eh.end_time),11,8)
thetitle = thetitle + '!c' + eh.data_name + ' ' + thetimespan
xyouts,.05,.04,thetitle,/normal

;endif



store_data,'time',data = {x:el.time}
if keyword_set(energies) then bottom = bottom - .25
position = [.5,bottom]

;if keyword_set(var_label) then begin
;	currpos = [position(0),position(1)-.10]
;	outstring = ''
;	for i = 0, n_elements(var_label)-1 do begin
;		interpolate,'time',var_label(i),'value'
;		get_data,var_label(i),data = thename
;		get_data,'value',data = thevalue
;		outstring = outstring + '  ' + var_label(i) +'= '$
;                   +strtrim(string(format = '(G11.4)',thevalue.y(0)),2)
;		if i mod 2 eq 1 then outstring = outstring + '!c' 
;		endfor
;	xyouts,currpos(0),currpos(1),outstring,/normal
;endif

if keyword_set(var_label) then begin
	currpos = [position(0),position(1)-.1]
	outstring = ''
	for i = 0, n_elements(var_label)-1 do begin
		print, var_label(i)

;		get_data,var_label(i),data = bdata
;		index = where(bdata.x le thedata.time + 600 and bdata.x ge $
;                              thedata.time - 600,count)
;		if count ne 0 then begin
;			store_data,var_label(i)+'cut',$
;                            data={x:bdata.x(index),y:bdata.y(index,*)}
;			interpolate,'time',var_label(i)+'cut','value'
;			get_data,var_label(i)+'cut',data = thename
;			get_data,'value',data = thevalue
;			outstring = outstring + '  ' + var_label(i)$
;                         +'= '+ strtrim(string(format = '(G11.4)',thevalue.y(0)),2)
;		endif

		thevalue = dat_avg(var_label(i), el.time, el.end_time)

		outstring = outstring + '  ' + var_label(i) +'= '$
		           +strtrim(string(format = '(G11.4)',thevalue),2)

		if i mod numperrow eq 1 then outstring = outstring + '!c' 
	endfor
	xyouts,labelpos(0),labelpos(1),outstring,/normal
endif





endelse

if !d.name ne 'PS' then !p.multi = oldplot

end



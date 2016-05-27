;+
;PROCEDURE:   FA_FIELDS_ROTATE,quanx,quany,quanz,start,totpoints,offsets=offsets,
;	filtfreq=filtfreq,filttime=filttime,changesf=changesf,twoD=twoD 
;		       
;PURPOSE:   Rotates 3D fields quantities into a field-aligned system-
;for the concise definition of the coordinate system see function fieldrot.pro
;the actual directions are dependent upon the spacecraft trajectory relative to Bo,
;However Z is always field-aligned. For the earths field at high latitude to an approximation 
;(being that the backgound B field projected into the orbital plane is perpendicular to the 
;spacecraft trajectory in that plane-of course the opposite is true at low latitudes),Y points in the same direction to the 
;spacecraft trajectory (opposite to E_along_V from fa_fields_despin),
;and X completes the right-handed orthogonal set-so need to look at plot_fa_crossing to
;get N,S,E, or W.   



;WARNING: Should not be used to get 3D DC fields!. If there appears to be a large parallel
;DC E field don't believe it.  
;
;INPUT:   
;	quanx,quany,quanz-DQDS of data to be rotated
;	for dc mag data order is 'MagDC','MagDC','MagDC'
;	for ac mag data order is 'Mag1AC*','Mag2AC*','Mag3AC*'
;	for E field dat order is 'V1-V2*' or 'V1-V4*' or 'V2-V4*' then 'V5-V8*', 'V9-V10*'
;
;       start-the start time for the data as a string '199*-**-**/**:**:**.**'
;	totpoints-the total number of data points to be rotated
; 
; KEYWORDS: 
;       offsets-set this keyword to remove DC offsets in the data
;		using this keyword will automatically load a full spin of data
;		so may take some time to run
;	filttime-set this keyword will do a time domain high pass filter on the data with
;		 a default base frequency of 0.1Hz. This filter works well for smaller numbers
;		 of data points but really starts to slow down after about 14000 on my sparc 20
;		 so probably best to not use with keyword offsets set with burst data
;	filtfreq-set this keyword to do a frequency domain high pass filter on the data with a
;		 default base frequency of 0.1 Hz. THis filter uses a box car applied to the whole
;		 dataset in one step. MUch faster than time domain but may have problems with
;		 ringing near the edges. Comparing results with filttime yields almost identical
;		 results so probably OK well inside the window.
;	changesf-set this keyword to reduce the sampling freq. of the data by the factor changesf 
;		 
;	twoD-	-when v9-10 not available can use to get the field-aligned and
;		along V components
; USE
;fa_fields_rotate,'V1-V4_4k','V5-V8_4k','V9-V10_4k','1997-04-23/19:47:37',5000,filtfreq=10.0,/offsets
;    Rotates the E fields 4k burst (with offsets removed and high pass filtered above 10Hz) into field-aligned system.  
;RETURN
;	stores the rotated field as tplot quantities-Bdcx,Bdcy,Bdcz or Bacx,Bacy,Bacz or Ex,Ey,Ez
;written by C. Chaston UCB 1996-10-30,modified on 1997-03-01,1998-07-01 

pro fa_fields_rotate,quanx,quany,quanz,start,totpoints,$
		     offsets=offsets,$
		     filtfreq=filtfreq,$
		     filttime=filttime,$
		     changesf=changesf


common magnetic,totmag




AngleB=21.0                                        ; angles relative to the right handed
AngleE=38.0                                        ; system defined by the spacecraft
                                                   ; spin axis, Z, an axis pointing along
                                                   ; the fluxgate boom and away from the
                                                   ; spacecraft in the spin plane and a third axis to
                                                   ; complete the set which also lies in the
						   ; spin plane
                                                   
                                                   
                                                   
maxpoints=totpoints-1                                                  
datatype=strmid(quanx,3,1)
case datatype of 
'D': quanstring='Bdc'
'1': quanstring='Bac'
'V': quanstring='E'
endcase                                                   
                                                  
        
        test=get_fa_fields(quanx, start, NPTS=2)
	sampfreq=1/(test.time(1)-test.time(0))
	
	
	pointsperspin=5.07*sampfreq
	if quanx NE 'MagDC' then begin
	    x=get_fa_fields(quanx, start, npts=totpoints)
	    y=get_fa_fields(quany, start, npts=totpoints)
	    if not keyword_set(twoD) then begin
	    	z=get_fa_fields(quanz, start, npts=totpoints)
	    endif else  begin
	    	z=findgen(totpoints*0.0)
            endelse
	endif else begin
	    x=get_fa_fields(quanx, start, npts=totpoints)
	    y=x
	    z=x
	    y.comp1=x.comp2
	    z.comp1=x.comp3
	endelse
	
	
	
	if keyword_set(offsets) then begin
		nospins=Floor(totpoints/pointsperspin)
		if nospins LT 1.0 then begin
			if quanx NE 'MagDC' then begin
	    			x=get_fa_fields(quanx, start, npts=pointsperspin)
	    			y=get_fa_fields(quany, start, npts=pointsperspin)
	    			z=get_fa_fields(quanz, start, npts=pointsperspin)
			endif else begin
	    			x=get_fa_fields(quanx, start, npts=pointsperspin)
	    			y=x
	    			y.comp1=x.comp2
	    			z.comp1=x.comp3
			endelse

			
			
			plot,x.comp1

			;Calculate offsets in AC data

			offx=Total(x.comp1)/pointsperspin
			offy=Total(y.comp1)/pointsperspin
			offz=Total(z.comp1)/pointsperspin

			


		endif else begin

			offx=Total(x.comp1(0:pointsperspin*nospins-1))/(pointsperspin*nospins)
			offy=Total(y.comp1(0:pointsperspin*nospins-1))/(pointsperspin*nospins)
			offz=Total(z.comp1(0:pointsperspin*nospins-1))/(pointsperspin*nospins)
			
			

		endelse
			x.comp1=x.comp1-offx
			y.comp1=y.comp1-offy
			z.comp1=z.comp1-offz
			
			
	endif
	endsampfreq=1/(x.time(totpoints-1)-x.time(totpoints-2))
   	print,' '
   	if sampfreq NE endsampfreq then print,'Warning ac file sampling ' + $
  	'frequency changes',sampfreq,'Hz to',endsampfreq,'Hz' else print,'ac ' + $
     	'file sampling frequency',sampfreq,'Hz' 
	window,0
	!p.multi=[0,1,3]
	plot,x.comp1
	plot,y.comp1
	plot,z.comp1

	if keyword_set(filttime) then begin
		if filttime EQ 1 then freq=0.1 else freq=filttime 

		fa_fields_filter,x,[freq,0]
		fa_fields_filter,y,[freq,0]
		fa_fields_filter,z,[freq,0]

		
	endif

	if keyword_set(filtfreq) then begin
		if filtfreq EQ 1 then freq=0.1 else freq=filtfreq 
		
		cutoff=floor(freq*(totpoints/sampfreq))
		
		zspec=fft(z.comp1)
		zspec(0:cutoff)=0
		zspec(totpoints-1-cutoff:totpoints-1)=0
		z.comp1=fft(zspec,1)

		xspec=fft(x.comp1)
		xspec(0:cutoff)=0
		xspec(totpoints-1-cutoff:totpoints-1)=0
		x.comp1=fft(xspec,1)

		yspec=fft(y.comp1)
		yspec(0:cutoff)=0
		yspec(totpoints-1-cutoff:totpoints-1)=0
		y.comp1=fft(yspec,1)
		
	endif

   	 
	if keyword_set(changesf) then begin


		factor=double(changesf)
		redpoints=Floor(totpoints/factor)
		print,'New number of datapoints ',redpoints
		maxpoints=redpoints-1
		tmpx=Make_Array(redpoints,/double)
		tmpy=Make_Array(redpoints,/double)
		tmpz=Make_Array(redpoints,/double)
		tmptime=Make_Array(redpoints,/double)

		for j=0L, redpoints-1 do begin

			tmpx(j)=Total(x.comp1(j*factor:j*factor+factor-1))/factor
			tmpy(j)=Total(y.comp1(j*factor:j*factor+factor-1))/factor
			tmpz(j)=Total(z.comp1(j*factor:j*factor+factor-1))/factor
			tmptime(j)=Total(z.time(j*factor:j*factor+factor-1))/factor

		endfor
		x=create_struct('time', tmptime ,'comp1',tmpx, 'NCOMP',3,'Data_Name',x.Data_Name,'Units_Name',x.units_name,'calibrated',x.calibrated) 
		y=create_struct('time', tmptime ,'comp1',tmpy, 'NCOMP',3,'Data_Name',y.Data_Name,'Units_Name',y.units_name,'calibrated',y.calibrated) 
		z=create_struct('time', tmptime ,'comp1',tmpz, 'NCOMP',3,'Data_Name',z.Data_name,'Units_Name',z.units_name,'calibrated',z.calibrated) 
	endif 



 print,'rotating to field aligned coords'
   xdmag=get_fa_fields('MagDC', start, NPTS=2,/calibrate)

   sampfreqdc=1/(xdmag.time(1)-xdmag.time(0))
   points=totpoints
   dcpoints=round(points*(sampfreqdc/sampfreq))+1
   if dcpoints LT 2.0 then print,'Warning:you have very few Mag DC points for rotation' 
   print,'Number of dcpoint ', dcpoints
    totmag=get_fa_fields('MagDC',start,NPTS=dcpoints,/calibrate)
    countdc=0
    endfreqdc=1/(totmag.time(dcpoints-1)-totmag.time(dcpoints-2))
    print,' '
    if sampfreqdc NE endfreqdc then print,'Warning dc file sampling ' + $
    'frequency changes',sampfreqdc,'Hz to',endfreqdc,'Hz' else print,'dc ' + $
    'file sampling frequency', sampfreqdc,'Hz'




fields=Make_array(3,maxpoints+1,/double)
rotated=Make_Array(3,maxpoints+1)




print,'interpolating and shifting to line up points' 

thelot=x
fa_fields_combine,thelot, y,tag_1='comp2',tag_2='comp1',/svy,/add
fa_fields_combine,thelot, z,tag_1='comp3',tag_2='comp1',/svy,/add
fa_fields_combine,thelot,totmag,tag_1='comp4',tag_2='comp1',/interp,delt_t=100.,/add
fa_fields_combine,thelot,totmag,tag_1='comp5',tag_2='comp2',/interp,delt_t=100.,/add
fa_fields_combine,thelot,totmag,tag_1='comp6',tag_2='comp3',/interp,delt_t=100.,/add


;Rotate AC data to the same coords as MagDC




 for j=0L,maxpoints DO BEGIN
        	
	dcx=thelot.comp4(j)
	dcy=thelot.comp5(j)
	dcz=thelot.comp6(j)
	                      
      case quanstring of
       'Bdc' : begin			;MagDC
           acx=x.comp1(j)
           acy=y.comp1(j)
           acz=z.comp1(j)
         end  
       'Bac' : begin			;Mag1AC
             acx=-thelot.comp2(j)*sin(angleB/180.0*!DPI)-thelot.comp3(j)*cos(angleB/180.0*!DPI)
             acy=thelot.comp1(j)
             acz=thelot.comp3(j)*sin(angleB/180.0*!DPI)-thelot.comp2(j)*cos(angleB/180.0*!DPI)

	end  
       'E' : begin			;V#-V#
             acx=thelot.comp1(j)*cos(angleE/180.0*!DPI)-thelot.comp2(j)*sin(angleE/180.0*!DPI)
  	     acy=thelot.comp2(j)*cos(angleE/180.0*!DPI)+thelot.comp1(j)*sin(angleE/180.0*!DPI)
             acz=-thelot.comp3(j)
         end    
         endcase
     
     ;now rotate to field-aligned system     
     
     fields(*,j)=fieldrot(dcx,dcy,dcz,acx,acy,acz)
     rotated(*,j)=[acx,acy,acz]
 
   
 endfor

store_data,quanstring+'x',data={x:thelot.time(0:maxpoints), y:transpose(fields(0,*))}
store_data,quanstring+'y',data={x:thelot.time(0:maxpoints), y:transpose(fields(1,*))}
store_data,quanstring+'z',data={x:thelot.time(0:maxpoints), y:transpose(fields(2,*))}
	
tplot_names
window,0
tplot,[quanstring+'x',quanstring+'y',quanstring+'z']
window,1




jj=[fft(fields(0,*)),fft(fields(1,*)),fft(fields(2,*))]
t1=jj(0,*)*conj(jj(0,*))
t2=jj(1,*)*conj(jj(1,*))
t3=jj(2,*)*conj(jj(2,*))
!p.multi=[0,1,3]
plot,t1(0:maxpoints/5),/ylog
plot,t2(0:maxpoints/5),/ylog
plot,t3(0:maxpoints/5),/ylog

return
end

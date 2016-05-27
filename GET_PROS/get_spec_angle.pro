;+
;NAME:		get_spec_angle
;PURPOSE:	to get tplot variables which will make spectrograms of average
;			counts per geometric factor vs. angle bins vs.
;			time for each energy level.
;
;
;INPUT:		DATA: A string of the data type the procedure should get (eg
;			'ph2','pl','el','eh','so','sf')
;
;KEYWORDS:	THETA:  two-element vector specifing the min and max theta 
;			angle of the selected bins (angle from solar-ecliptical
;			plane).  Default is [-30,30]
;		ZLOG:  This keyword will cause the tplot structures to
;			plot the spectrogram by log counts, not counts.
;		UNITS:  Set this keyword to a string containing the output
;			units, such as eflux, flux,
;			df, ncounts, rate, or nrate (default is counts).
;
;OUTPUTS:	Tplot variables named 'data_spec_n', where n is the 
;			energy level the variable corresponds
;			to and data is the data type (eg. ph2).
;
;EXAMPLE:	load_3dp_data,'96-03-27/10:',1
;		get_spec_angle,'so',theta=[-45,45]
;		tplot,['so_spec_0','so_spec_8']
;
;NOTES:		The data retured for each phi angle data.v(i) is the 
;			total counts divided by the total geometric
;			factor for all theta between min_theta <= 
;			theta <= max_theta, and all phi between
;			data.v(i) <= phi < data.v(i+1). 
;		At phi=180, Y,Zgse=0
;		At theta=0, Xgse=0
;
;CREATED BY:	Mike Moyer 96-11-12
;MODIFIED BY:	Arjun Raj 98-02-26		



pro get_spec_angle,get_dat,theta=theta,units=units,zlog=zlog,bins = bins

starting_t=systime(1)

if not keyword_set(units) then units = 'df'

;setting default values
if not keyword_set(get_dat) then begin
	dat_name='ph2'
	get_dat='get_ph2' 
endif else begin
	dat_name=get_dat
	get_dat='get_'+get_dat
endelse
	
if not keyword_set(zlog) then zlog=0
if not keyword_set(theta) then theta=[30,-30]
if theta(0) lt theta(1) then theta=reverse(theta)

s=call_function(get_dat,/times)
n_points=n_elements(s)
if n_points le 1 then begin
	print,'Sorry, No Data.'
	return
endif

t=dblarr(2)
 t(0)=s(0)
 t(1)=s(n_points-1)

;*****
;this gets the data for the time interval into the array named data,
;each element of which is the 3d structure for that time interval
;*****
d=call_function(get_dat,t(0))
while d.valid eq 0 do begin
	d=call_function(get_dat,t(0),/advance)
endwhile
data=replicate(d,n_points)
tags=n_tags(d)
n_energies=d.nenergy
n_bins=d.nbins

for i=0,n_points-1 do begin
	q=call_function(get_dat,(s(i)))

	if q.valid eq 0 then begin
		q=d
		q.data=!values.f_nan
		q.time=s(i)
		q.end_time=s(i)+(s(i)-s(i-1))
	endif

	if keyword_set(units) then q=conv_units(q,units)
	for j=0,tags-1 do begin 
		data(i).(j)=q.(j)
	endfor
endfor

;*****

thesebins = intarr(data(0).nbins)
thesebins(*)= 1
if keyword_set(bins) then begin
	;data2= bin_remove(data(0), outbins = mybins)
	thesebins= bins ;(bins)=1
endif   ;else thesebins(*) = 1

;stop


bad_bins=where((data(0).dphi(0,*) eq 0) or (data(0).dtheta(0,*) eq 0) or $
	((data(0).data(0,*) eq 0.) and (data(0).theta(0,*) eq 0.) and $
	(data(0).phi(0,*) eq 180.) or (thesebins eq 0)),n_bad)
good_bins=where(((data(0).dphi ne 0) and (data(0).dtheta ne 0)) and not $
	((data(0).data(0,*) eq 0.) and (data(0).theta(0,*) eq 0.) and $
	(data(0).phi(0,*) eq 180.) and (thesebins eq 1)),n_good)
if n_bad ne 0 then begin
	;data(*).geom(bad_bins) = !values.f_nan
	data(*).phi(*,bad_bins) = 1000.
	data(*).theta(*,bad_bins)=100.
endif


th_angle=fltarr(n_energies,n_good,n_points)
ph_angle=fltarr(n_energies,n_good,n_points)
dvalues=fltarr(n_energies,n_good,n_points)
dphi=fltarr(n_energies,n_good,n_points)

for i=0,n_energies-1 do begin
	for j=0,n_good-1 do begin
		th_angle(i,j,*)=data(*).theta(i,j)
		ph_angle(i,j,*)=data(*).phi(i,j)
		;if units eq 'counts' then $
		;	dvalues(i,j,*)=data(*).data(i,j) / data(*).geom(j) $
		;else $
			dvalues(i,j,*)=data(*).data(i,j)
		dphi(i,j,*)=data(0).dphi(j)
	endfor
end

if keyword_set(bins) then dat_name = dat_name + 'br'

for i=0,n_energies-1 do begin
	istr=strcompress(string(i),/remove_all)
	
	valid_bins=where((th_angle(i,*,0) le theta(0)) and $
		(th_angle(i,*,0) ge theta(1)),n_valid_bins)
	sort_idx=sort(ph_angle(i,valid_bins,0))
	uniq_phis=uniq(ph_angle(i,valid_bins(sort_idx),0))
	n_uniq=n_elements(uniq_phis)
	
	q={x:data(*).time,v:fltarr(n_points,n_uniq+2),$
		y:fltarr(n_points,n_uniq+2),energy:data(0).energy(i),$
		ytitle:'',ztitle:'',$
		yrange:[0,360],ystyle:1,zlog:zlog,spec:1}

	for k=0,n_points-1 do begin
	
		for l=0,n_uniq-1 do begin
			in_range=where((ph_angle(i,valid_bins(sort_idx),k) gt $
				(ph_angle(i,valid_bins(sort_idx(uniq_phis(l))),k) $
				- (dphi(i,valid_bins(sort_idx(uniq_phis(l))),k) / 2.))) $
				and $
				(ph_angle(i,valid_bins(sort_idx),k) le $
				(ph_angle(i,valid_bins(sort_idx(uniq_phis(l))),k) + $
				(dphi(i,valid_bins(sort_idx(uniq_phis(l))),k) / 2.))),$
				n_in_range)
			
			q.v(k,l+1)=ph_angle(i,valid_bins(sort_idx(uniq_phis(l))),k)
			
			if n_in_range ne 0 then begin
				q.y(k,l+1)=total(dvalues(i,valid_bins(sort_idx(in_range)),k)) / $
					n_in_range
			endif else begin
				q.y(k,l+1)=!values.f_nan
			endelse
		endfor
		
		q.v(k,0)=0.
		q.v(k,n_uniq+1)=360.
		q.y(k,0)=(q.y(k,1) + q.y(k,n_uniq))/2.
		q.y(k,n_uniq+1)=q.y(k,0)
		
	endfor

	
	q.ytitle=dat_name+'!c'+strcompress(string((data(0).energy(i,0)/1000.),$
		format='(g8.2)'),/remove_all)+'keV'
	if zlog ne 0 then q.ztitle=data(0).units_name+'!c(log)' else $
		q.ztitle=data(0).units_name

	store_data,dat_name+'_spec_'+istr,data=q 
	
endfor
print,strcompress(string(systime(1)-starting_t),/remove_all)+' seconds'

end

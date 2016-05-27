;+
;PROCEDURE:	get_mfi
;PURPOSE:	Gets key parameter data from the MFI experiment, such as Bexp,
;		Bmag,Bph, and Bth.
;INPUT:	
;	none but will call "timespan" and ask for input if
;	time range not already set
;KEYWORDS:
;	none
;
;CREATED BY:	Davin Larson
;LAST MODIFICATION:	@(#)get_mfi.pro	1.14 96/08/05
;-
; MODIFIED FOR FORMATTING PURPOSES:  Lynn B. Wilson III
;                                    06/20/2007

pro get_mfi,TIME_RANGE=range 

common times_dats, t

;stop

fname = 'wi_h0_mfi_files'       ; an index file similar to the one for 3DP
environvar = 'WI_H0_MFI_INDEX=' ; location of index file
dir = getenv(environvar)


if not keyword_set(dir) then $
   message,'Environment variable '+environvar+' is not defined!' 


get_file_names,filenames,TIME_RANGE=range,MASTERFILE=fname,ROOT=dir
ndays = n_elements(filenames)


if ndays eq 0 then begin
   print,"No WIND MFI data available from ",time_to_str(range(0)), ' to ', $
   time_to_str(range(1))
   return
endif
      

for d=0,ndays-1 do begin
   print,'Loading file: ',filenames(d)
   loadcdf,filenames(d),'Time_PB5',pb5  ,/append
   loadcdf,filenames(d),'BGSE' ,bexp_tot ,/append
   loadcdf,filenames(d),'BRMSGSE'  ,rms_tot ,/append
endfor

t_tot = pb5_to_time(pb5)

cart_to_sphere,bexp_tot(*,0),bexp_tot(*,1),bexp_tot(*,2),btot,th,ph

ind = where(btot ge 1000,cnt)


nan = !values.f_nan
if cnt gt 0 then begin
  bexp_tot(ind,*) = nan
  rms_tot(ind)= nan
  btot(ind) = nan
  th(ind)   = nan
  ph(ind)   = nan
endif

store_data,'Bexp',data={ytitle:'Bexp',x:t_tot,y:bexp_tot , max_value:1e30}
store_data,'Brms',data={ytitle:'Brms',x:t_tot,y:rms_tot , max_value:1e30}
store_data,'wi_B3_mag',data={ytitle:'Bmag',x:t_tot,y:btot, max_value:1e30}
store_data,'wi_B3_th' ,data={ytitle:'Bth',x:t_tot,y:th,yrange:[-90.,90.], max_value:1e30}
store_data,'wi_B3_phi' ,data={ytitle:'Bph',x:t_tot,y:ph,yrange:[-180.,180.], max_value:1e30}

end



function get_ph,t,add, advance=adv, times=tms, index=idx
;+
;FUNCTION:   get_ph(t)
;PURPOSE:
;  Returns a 3d structure containing all data pertinent to a single pesa high 3d sample.  
;  See "3D_STRUCTURE" for a more complete 
;  description of the structure.
;
;INPUT:
;    t: double,  seconds since 1970. If this time is a vector then the
;	routine will get all samples in between the two times in the 
;	vector
;KEYWORDS:
;	advance:	advance to the next data point
;	index:		select data by sample index instead of by time.
;	times:		if non-zero, return and array of data times 
;			corresponding to data samples.
;CREATED BY:	Frank Marcoline from Davin Larson's get_##.pro routines.
;LAST MODIFICATION:       @(#)get_ph.pro	1.32 99/05/03
;
;NOTES: The procedure "load_3dp_data" must be 
;	called first.
;-
@wind_com.pro

if n_elements(refdate) eq 0 then begin
  print, 'You must first load the data'
  return, {data_name:'null',valid:0}
endif

;set options to pick packet
options = [2,0,0L]              ;options(0)=2->ph, options(0)=index(0)
if (n_elements(idx) eq 0) and (n_elements(t) eq 0) and (not keyword_set(adv)) $
	and (not keyword_set(tms)) then ctime,t
if n_elements(t) eq 0 then t = time_double(refdate) else t = gettime(t)
time = dblarr(4)
time(0) = t(0)
if not keyword_set(adv) then adv=0 
if adv ne 0 and n_elements(t) eq 1 then reset_time=1 else reset_time=0
if n_elements(idx) gt 0 then options(1)=long(idx) else options(1)=-1L
if (n_elements(t) gt 1) then time2 = t(1)-t(0)+time(0) else time2=t

; get times if requested
if keyword_set(tms) then begin
        num = 10000
	options(0) = num
	times = dblarr(num)
	ok = call_external(wind_lib,'ph15times_to_idl',options,times)
        print,ok+1,'  Pesa high time samples'
        if ok lt 0 then return,0d else return,times(0:ok)
endif

mapcode = get_ph_mapcode(time,advance=adv,index=idx,options=options,/preset)

case mapcode of
  'D4A4'xl: nbins = 121         ;'D4A4'xl  =  0xD4A4
  'D4FE'xl: nbins = 97
  'D5EC'xl: nbins = 56
  'D6BB'xl: nbins = 65
  'D65D'xl: nbins = 88
  else: begin 
    mapstr = strupcase(string(mapcode,format='(z4.4)'))
    print,'Unknown ph data map ('+mapstr+') requested or bad packet'
    return,{data_name:'null',valid:0}
  end
endcase 

;do not alter this structure without changing ph_dcm.h
dat = { PROJECT_NAME   : 'Wind 3D Plasma',          $
        DATA_NAME      : 'Pesa High',               $
        UNITS_NAME     : 'Counts',                  $
        UNITS_PROCEDURE: 'convert_esa_units',       $
        TIME           : 0.d,                       $
        END_TIME       : 0.d,                       $
        TRANGE         : [0.d,0.d],                 $
        INTEG_T        : 0.d,                       $
        DELTA_T        : 0.d,                       $
        DEADTIME       : fltarr(15,nbins),          $
        DT             : fltarr(15,nbins),          $
        VALID          : 0,                         $
        SPIN           : 0l,                        $
        SHIFT	       : 0b,			    $
        INDEX          : 0l,                        $
        MAPCODE        : long(mapcode),             $
        DOUBLE_SWEEP   : 0b,			    $
        NENERGY        : 15,                        $
        NBINS          : nbins,                     $
        BINS           : replicate(1b,15,nbins),    $
        PT_MAP	       : intarr(32,24),	            $
        DATA           : fltarr(15,nbins),          $
        ENERGY         : fltarr(15,nbins),          $ 
        DENERGY        : fltarr(15,nbins),          $
        PHI            : fltarr(15,nbins),          $
        DPHI           : fltarr(15,nbins),          $
        THETA          : fltarr(15,nbins),          $
        DTHETA         : fltarr(15,nbins),          $
        BKGRATE        : fltarr(15,nbins),          $
        DVOLUME        : fltarr(15,nbins),          $
        DDATA          : replicate(!values.f_nan,15,nbins),          $
        DOMEGA         : fltarr(nbins),             $
        DACCODES       : intarr(30*4),              $
        VOLTS          : fltarr(30*4),              $
        MASS           : 0.d,                       $
        GEOMFACTOR     : 0.d,                       $
        GF             : fltarr(15,nbins),          $
        MAGF            : replicate(!values.f_nan,3), $
        SC_POT         : 0. $
}

size = n_tags(dat,/length)
if keyword_set(adv) then a=adv else a=0
if n_elements(idx) eq 0 then i=-1 else i=idx
options = long([size,a,i])
retdat = dat
oldtime = time(0)
q=0

repeat begin
	ok = call_external(wind_lib,'ph15_to_idl',options,time,mapcode,dat)
	dat.end_time = dat.time + dat.integ_t
	if retdat.valid eq 0 then retdat = dat   $
	else if dat.time ge oldtime and dat.valid eq 1 then begin
		retdat.data = dat.data +  retdat.data
		retdat.dt   = dat.dt   +  retdat.dt
		retdat.delta_t = dat.delta_t + retdat.delta_t
		retdat.integ_t = dat.integ_t + retdat.integ_t
		retdat.end_time = dat.end_time
		oldtime = dat.time
		q = dat.end_time gt time2
	endif else if dat.valid eq 1 then q = 1
	options[2] = dat.index+1
	if (time2 eq time(0)) then q=1
endrep until q
dat = retdat
;if (ok eq 0) or (dat.valid eq 0) then return,dat

dat.trange = [dat.time,dat.end_time]
dat.mass = 1836*5.6856591e-6             ; mass eV/(km/sec)^2
dat.geomfactor = 1.49e-2/360.*5.625        
dat.deadtime = 0.0
dat.bins(*,nbins-1) = 0
if n_params() gt 1 then add_all,dat,add
if reset_time then t = time(0)
return,dat
end


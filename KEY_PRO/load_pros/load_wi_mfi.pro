pro fill_bad_wi_mfi,d
  bad = where(d.dqf,nbad)
  if nbad ne 0 then begin
    tags = tag_names(d)
    for i=0,n_tags(d)-1 do begin
;      help,  tags(i), d(bad).(i)
       dt = data_type(d.(i))
       if tags(i) eq 'TIME' then dt=0
       if (dt eq 4) or (dt eq 5) then d(bad).(i)=!values.f_nan
    endfor
  endif

end


;+
;PROCEDURE:	load_wi_mfi
;PURPOSE:	
;   loads WIND MAGNETOMETER Experiment key parameter data for "tplot".
;
;INPUTS:	none, but will call "timespan" if time
;		range is not already set.
;KEYWORDS:
;  DATA:        Raw data can be returned through this named variable.
;  NVDATA:	Raw non-varying data can be returned through this variable.
;  TIME_RANGE:  2 element vector specifying the time range.
;  MASTERFILE:  (string) full file name to the master file.
;  RESOLUTION:  number of seconds resolution to return.
;  PREFIX:	Prefix for TPLOT variables created.  Default is 'wi_'
;  POLAR:       Also computes the B field in polar coordinates.
;SEE ALSO: 
;  "make_cdf_index","loadcdf","loadcdfstr","loadallcdf"
;
;CREATED BY:	Davin Larson
;FILE:  load_wi_mfi.pro
;LAST MODIFICATION: 02/11/01
;-
pro load_wi_mfi,time_range=trange,data=d,nvdata=nd,polar=polar, $
   prefix= prefix, $
   resolution = res, $
   cdfnames = cdfnames, $
   bartel=bartel, $
   masterfile=masterfile

if not keyword_set(masterfile) then masterfile = 'wi_k0_mfi_files'
if keyword_set(bartel) then masterfile = 'wi_k0_mfi_B_files'
cdfnames = ['BGSEc','RMS','DQF']

loadallcdf,masterfile=masterfile,cdfnames=cdfnames,data=d, $
   novarnames=novarnames,novard=nd,time_range=trange, $
   res=res,filter_proc='fill_bad_wi_mfi'


fill_bad_wi_mfi,d



if data_type(prefix) eq 7 then px=prefix else px = 'wi_'

;name = px+'B'

store_data,px+'B',data={x:d.time,y:dimen_shift(d.BGSEc,1)},max=900. $
  , dlim={labels:['Bx','By','Bz']}
store_data,px+'B_rms',data={x:d.time,y:dimen_shift(d.RMS,1)},max=900. 

if keyword_set(polar) then begin
   xyz_to_polar,px+'B',/ph_0_360
   options,px+'B_mag','ytitle','|B|'
   options,px+'B_th','ytitle','!4h!X!DB!U'
   ylim,px+'B_th',-90.,90.,0
   
   options,px+'B_phi','ytitle','!4u!X!DB!U'
   ylim,px+'B_phi',0.,360.
   options,px+'B_phi','psym',3
endif

end

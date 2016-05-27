;+
;PROCEDURE:	load_wi_or 
;PURPOSE:	
;   loads WIND 3D Plasma Experiment orbit data for "tplot".
;INPUTS:
;  none, but will call "timespan" if time_range is not already set.
;KEYWORDS:
;  DATA:        Raw data can be returned through this named variable.
;  TIME_RANGE:  2 element vector specifying the time range.
;  RESOLUTION:  number of seconds resolution to return.
;  POLAR:       Computes polar coordinates if set.
;  PRE:		If set, use predicted (pre) data.
;  NODATA:	Returns 1 if no data available.
;  HEC:		If set, retrieve HEC data.
;  VAR_LAB:	Return polar data and use as var_labels in tplot.
;  GSM:		If set, retrieve GSM data.
;  LAT:		If set, retrieve LAT data.
;SEE ALSO: 
;  "make_cdf_index","loadcdf","loadcdfstr","loadallcdf"
;
;CREATED BY:	Davin Larson
;FILE:  load_wi_or.pro
;LAST MODIFICATION: 99/12/28
;-
function find_or_files,trange

if keyword_set(trange) then tr = time_double(trange) else $
	get_timespan,tr

if n_elements(tr) ne 2 then tr = [tr(0),tr(0)+24.*3600.]

defprebreak = time_double('1997-7-2')
defmast = 'wi_or_def_files'
premast = 'wi_or_pre_files'

if (tr[0] lt defprebreak) then begin
  if (tr[1] gt defprebreak) then begin
    deftrange = [tr[0],defprebreak]
    pretrange = [defprebreak,tr[1]]
    get_file_names,deffiles,time_range=deftrange,masterfile=defmast
    get_file_names,prefiles,time_range=pretrange,masterfile=premast
    return,[deffiles,prefiles]
  endif else begin
    get_file_names,deffiles,time_range=tr,masterfile=defmast
    return,deffiles
  endelse
endif else begin
  get_file_names,prefiles,time_range=tr,masterfile=premast
  return,prefiles
endelse
end

pro load_wi_or,time_range=trange,data=d,polar=polar,pre=pre,nodata=nodat,resolution=res,hec=hec,var_lab=var_lab,gsm=gsm,lat=lat

if keyword_set(var_lab) then begin
  tplot_options,var_lab=['wi_pos_mag','wi_pos_phi']
  polar = 1
endif

if keyword_set(pre) then begin
	masterfile='wi_or_pre_files'
	get_file_names,cdffilenames,masterfile=masterfile,time_range=trange
endif else cdffilenames=find_or_files(trange)
	
if (keyword_set(cdffilenames) eq 0) then begin
	print,'No WI_OR files for given time range.'
	return
endif

cdfnames = ['GSE_POS']

if keyword_set(hec) then cdfnames = ['GSE_POS','HEC_POS']
if keyword_set(gsm) then cdfnames = [cdfnames, 'GSM_POS']
if keyword_set(lat) then cdfnames = [cdfnames,'LAT_SPACE']

d=0
nodat=0
loadallcdf,filenames=cdffilenames,cdfnames=cdfnames,data=d,time_range=trange,res=res

if keyword_set(d) eq 0 then begin
   if keyword_set(pre) then begin
      message,'No WIND orbit data during this time. Aborting.',/info
      nodat=1
      return
   endif else begin
      load_wi_or,time_range=trange,data=d,polar=polar,/pre,nodata=nodat,resolution=res,hec=hec,lat=lat
      return
   endelse
endif

pos = dimen_shift(d.gse_pos/6370.,1)
lab = ['X','Y','Z']


store_data,'wi_pos',data={x:d.time,y:pos}, dlim={labels:lab},min=-1e30

if keyword_set(hec) then begin
  hpos = dimen_shift(d.hec_pos,1)
  store_data,'wi_pos_hec',data={x:d.time,y:hpos}, dlim={labels:lab},min=-1e30
endif

if keyword_set(gsm) then begin
  gsmpos = dimen_shift(d.gsm_pos,1)
  store_data,'wi_pos_gsm',data={x:d.time,y:gsmpos}, dlim={labels:lab},min=-1e30
endif

if keyword_set(lat) then begin
  gsmpos = d.lat_space
  store_data,'wi_hg_lat',data={x:d.time,y:lat_space}, dlim={labels:lab},min=-1e30
endif

if keyword_set(polar) then begin
   xyz_to_polar,'wi_pos',/ph_0_360
   options,'wi_pos_mag','ytitle','D (R!dE!n)',/default
   options,'wi_pos_th','ytitle','!4h!X!DSC!U',/default
   options,'wi_pos_phi','ytitle','!4u!X!DSC!U',/default
   options,'wi_pos_phi','format','(f4.0)',/default
endif

end

FUNCTION get_ph_mapcode,t,advance=adv,index=idx,options=options,preset=preset
;+
;NAME:                  get_ph_mapcode
;PURPOSE:               
;                       get the current mapcode for ph
;                       see map3d.c for definitions of mapcodes
;                       typically get_ph_mapcode will only be called from other get_ph* routines
;CALLING SEQUENCE:      type=get_ph_ph_type(t,advance=advance,index=index,preset=preset)
;INPUTS:                t: double or dblarr(2) time
;KEYWORD PARAMETERS:    ADVANCE: get the mapcode for the next ph packet
;			INDEX:   get the mapcode for the ph packet with index INDEX
;			OPTIONS: options array decides how the packet is chosen:
;				IF OPTIONS(1) GE  0, get packet by index
;				IF OPTIONS(1) EQ -1, get packet by time
;			PRESET:  If set: t, advance, and index are preset
;				and no changes to these variables will be made
;OUTPUTS:               At the moment there are only two possible valid outputs
;                       1: MAP11b, or 2: MAP11d  (constants defined in map3d.h)
;COMMON BLOCKS:         wind_com
;EXAMPLE:               load_3dp_data,'1995-09-28',24
;			map0 = get_ph_mapcode(index=0)
;			map1 = get_ph_mapcode(str_to_time('1995-09-28/20'))
;			print,'Map0: ',map0,',    Map1: ',map1,format='(a,z,a,z)'
;		   -->  Map0:     D4A4,    Map1:     D4FE
;			;on 9/28/95 the telemetry rate changed from S2x to S1x
;			;See: http://sprg.ssl.berkeley.edu/wind3dp/wi_3dp_log
;CREATED BY:            Frank Marcoline
;-
@wind_com.pro
  if n_elements(refdate) eq 0 then begin
    print, 'You must first load the data'
    return,0
  endif
  if not keyword_set(preset) then begin 
    if not keyword_set(options) then options = [2,0,0]
    if n_elements(t) eq 0 then t = str_to_time(refdate)
    time = dblarr(4)
    time(0) = t(0)
    if not keyword_set(adv) then adv=0 
    if adv ne 0 and n_elements(t) eq 1 then reset_time=1 else reset_time=0
    if n_elements(idx) gt 0 then options(1)=long(idx) else options(1)=-1L
    if (n_elements(t) gt 1) then time2 = t(1)-t(0)+time(0) else time2=t
  endif else time = t                ;assume options,t,idx,and adv are set properly
  options = long(options)
  mapcode = 0l
  idtype  = 0
  instseq = 0
  ok = call_external(wind_lib,'get_ph_mapcode_idl',options,time,adv,mapcode,$
                     idtype,instseq)
  if not keyword_set(preset) then if reset_time then t = time(0)
  if ok eq 0 then begin 
    print,'get_ph_mapcode:  failed to get packet type'
    return,0
  endif else return,mapcode
END 

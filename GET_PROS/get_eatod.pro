;+
;PROCEDURE: 	get_eatod
;PURPOSE:
;  Gets analog to digital data for EESA
;INPUT:	
;  none, but "load_3dp_data" must be called 1st.
;KEYWORDS:
;  DATA:  named variable in which all data is returned.
;
;CREATED BY:	Davin Larson
;FILE:  get_eatod.pro
;VERSION:  1.6
;LAST MODIFICATION:  01/06/06
;-

pro get_eatod,data=d,long_term=long_term

@wind_com.pro

dat= {eatod_str,time:0.d,  $
   spin:0,mcp_low:0.,waves:0.,mcp_high:0.,pmt:0.,sweep_low:0.,sweep_high:0., $
   def_up:0.,def_down:0.,tp_0:0.,tp_1:0.,ref_plus:0.,gnd_adc:0.,ref_minus:0., $
   eesa_p5:0.,boom_p5:0., eesa_m5:0., cover:0., eesa_p12:0., boom_p12:0.,  $
   eesa_m12:0., boom_m12:0., eesa_ref:0., gnd_eesa:0., valid: 0 }

rec_len = long( n_tags(dat,/length) )

if keyword_set(long_term) then begin
   dir = '/home/wind/scratch/long_term/'
   openr,fp,dir+'eAtoD_accums',/get_lun
   filedata = assoc(fp,dat)
   file_status = fstat(fp)
   num_records = file_status.size / rec_len
   index = [0l,num_records -1]
   print,index,' Records'
   num =index(1)-index(0)+1
endif else begin
   if n_elements(wind_lib) eq 0 then begin
     print,'You must first load some data'
     return
   endif
   num = call_external(wind_lib,'eAtoD_to_idl')
endelse


if num eq 0 then begin
   print,'There is no EESA analog to digital data available for this time'
   return
end

d = replicate(dat,num)

if keyword_set(long_term) then begin
   if data_type(name) ne 7 then name = 'eatod_lt_'
   for i=0l,num-1 do  d(i) = filedata(i+index(0))
   free_lun,fp
endif else begin
   if data_type(name) ne 7 then name = 'eatod_'
   num = call_external(wind_lib,'eAtoD_to_idl',num,rec_len,d)
endelse


;Store all variables for TPLOT:
tags = tag_names(d)
ntags = n_elements(tags)
for i = 1,ntags-1 do begin
   store_data,name+tags(i),data={x:d.time,y:d.(i)}
endfor

return
end



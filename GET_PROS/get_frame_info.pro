;+
;PROCEDURE: 	get_frame_info
;PURPOSE:
;  Gets frame info data for WIND data files.
;INPUT:	
;  none, but "load_3dp_data" must be called 1st.
;KEYWORDS:
;  DATA:  named variable in which all data is returned.
;
;CREATED BY:	Davin Larson
;FILE:  get_eatod.pro
;VERSION:  1.4
;LAST MODIFICATION:  96/05/03
;-

pro get_frame_info,data=d,long_term=long_term,no_tplot=no_tplot

@wind_com.pro

dat = {frame_info_str,time:0.d,spn_per:0.d,spn0_time:0.d,fspin:0.d,dspin:0.d, $
    creep:0.d,counter:0l,errors:0l,npkts:0,m_pk_type:0,e_pk_type:0,p_pk_type:0,$
    n_fill:0,n_sync_err:0,min_frm_qual:bytarr(250),telem:fltarr(54),$
    nbytes:intarr(4),offset:0,spin:0l, $
    inst_mode:0b,phase:0b,seq:0b,misc:intarr(4),spc_mode:0l,nbytes_t:0,burst_num:0 }

rec_len = long( n_tags(dat,/length) )

if keyword_set(long_term) then begin
   dir = '/home/wind/scratch/long_term/'
   openr,fp,dir+'frame_accums',/get_lun
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
   num = call_external(wind_lib,'frame_info_to_idl')
endelse


if num eq 0 then begin
   print,'There is no frame info data available for this time'
   return
end

d = replicate(dat,num)

if keyword_set(long_term) then begin
   if data_type(name) ne 7 then name = 'info_lt_'
   for i=0l,num-1 do  d(i) = filedata(i+index(0))
   free_lun,fp
endif else begin
   if data_type(name) ne 7 then name = 'info_'
   num = call_external(wind_lib,'frame_info_to_idl',num,rec_len,d)
endelse

if keyword_set(no_tplot) then return

;Store all variables for TPLOT:
errlabs=['Gap','Offset Mismatch','Non-Consec Frames','Zero Bytes', $
 'Invalid Pk length','Invalid Pk','Shift error','Invalid Mode', $
  'Bad Frame Spin','Rollover','Reset','New 0 Time', $
  'Fill','Sync Error','Mode Change','GSE Correction']
tags = tag_names(d)
ntags = n_elements(tags)

for i = 1,ntags-1 do begin
   y = d.(i)
   if ndimen(y) eq 2 then y = transpose(y)
   data = {x:d.time,y:y}
   case tags(i) of
      'ERRORS':data=create_struct(data,{labels:errlabs,tplot_routine:'bitplot'})
      else:
   endcase
   store_data,name+tags(i),data=data
endfor

return
end



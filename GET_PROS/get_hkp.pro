;+
;PROCEDURE: 	get_hkp
;PURPOSE:
;    Gets housekeeping data for eesa and pesa;
;INPUT:	
;	none, but "load_3dp_data" must be called 1st.
;
;CREATED BY:	Davin Larson
;LAST MODIFICATION:	@(#)get_hkp.pro	1.16 01/06/06
;-

pro get_hkp,data=d,long_term=long_term,l_comm=l_comm,no_tplot=no_tplot
@wind_com.pro

dat= {hkp_str,time:0.d,  $
   errors:0l,inst_mode:0b,mode:0b,burst_stat:0b,rate:0b,f_seq:0b,$
   offset:0, spin:0, phase:0b, magel:0b, magaz:0, ncomm:0b, lcomm:bytarr(12),$
   m_vers:0b, m_stat:0b, m_lerr:0b, m_nerr:0b, m_nres:0b, m_bstat:0b, $
   fspin:0., $
   m_volt:fltarr(9), $
   e_vers:0b, e_stat:0b, e_lerr:0b, e_nerr:0b, e_nres:0b, e_bstat:0b, e_swp:0b,$
   e_volt:fltarr(8), $
   p_vers:0b, p_stat:0b, p_lerr:0b, p_nerr:0b, p_nres:0b, p_bstat:0b, p_swp:0b,$
   p_volt:fltarr(8), $
   temp:fltarr(4) , valid:0l }

rec_len = long( n_tags(dat,/length) )

if keyword_set(long_term) then begin
   dir = '/home/wind/scratch/long_term/'
   openr,fp,dir+'hkp_accums',/get_lun
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
   num = call_external(wind_lib,'hkp_to_idl')
endelse


if num eq 0 then begin
   print,'There is no housekeeping data available from this time'
   return
end

d = replicate(dat,num)

if keyword_set(long_term) then begin
   if data_type(name) ne 7 then name = 'hkp_lt_'
   for i=0l,num-1 do  d(i) = filedata(i+index(0))
   free_lun,fp
endif else begin
   if data_type(name) ne 7 then name = 'hkp_'
   num = call_external(wind_lib,'hkp_to_idl',num,rec_len,d)
endelse

if keyword_set(no_tplot) then return


m_volt_names=['main_p5','main_m5','main_p12','main_m12','sst_p9', $
    'sst_p5','sst_m4','sst_m9','sst_hv']
e_volt_names=['eesa_p5','eesa_p12','eesa_m12','eesa_mcpl','eesa_mcph', $
    'eesa_pmt','eesa_swpl','eesa_swph']
p_volt_names=['pesa_p5','pesa_p12','pesa_m12','pesa_mcpl','pesa_mcph', $
    'pesa_pmt','pesa_swpl','pesa_swph']
temp_names=['eesa_temp','pesa_temp','sst1_temp','sst3_temp']


store_data,name+'main',data={x:d.time,y:transpose(d.m_volt)},  $
   dlim={labels:m_volt_names}
store_data,name+'eesa',data={x:d.time,y:transpose(d.e_volt)},  $
   dlim={labels:e_volt_names}
store_data,name+'pesa',data={x:d.time,y:transpose(d.p_volt),labels:p_volt_names}
store_data,name+'temp',data={x:d.time,y:transpose(d.temp),labels:temp_names}
store_data,name+'resets',data={x:d.time,y:[[d.m_nres],[d.e_nres],[d.p_nres]], $
      labels:['main','eesa','pesa']}

store_data,name+'magel',dat={x:d.time,y:d.magel}
store_data,name+'magaz',dat={x:d.time,y:d.magaz}


store_data,name+'mode',dat={x:d.time,y:[[d.mode],[d.burst_stat+4],[d.rate+8]],$
      labels:['S/M','Burst','Rate']}
store_data,name+'burst',data={x:d.time,y:d.m_bstat,tplot_routine:'bitplot', $
      labels:['id0','id1','id2','id3','B0','B1','FPC','Prog']}
store_data,name+'I_mode',data={x:d.time,y:d.inst_mode,tplot_routine:'bitplot',$
      labels:['Sci','Man','Burst','2x']}
store_data,name+'n_comm',data={x:d.time,y:d.ncomm}

; Last command:
dncomm = d.ncomm - shift(d.ncomm,1)
dncomm(0) = 1         ; force first command
w = where(dncomm)
lcomm = string(d(w).lcomm(0:4),format='(5(Z3.2))')
lcomm = lcomm+string(dncomm(w),format= '(" (",I0.0,")")')
store_data,name+'l_comm',data={x:[d(w).time],y:[lcomm]}, dlim={tplot_routine:'strplot'}

return
end



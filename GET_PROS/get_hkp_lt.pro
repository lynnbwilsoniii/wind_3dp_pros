pro get_hkp_lt,trange,index = index

dir = '/home/wind/scratch/long_term/'
openr,fp,dir+'hkp_accums',/get_lun

dat= {time:0.d,errors:0l,inst_mode:0b,mode:0b,burst_stat:0b,rate:0b,f_seq:0b,$
   offset:0, spin:0, phase:0b, magel:0b, magaz:0, ncomm:0b, lcomm:bytarr(12),$
   m_vers:0b, m_stat:0b, m_lerr:0b, m_nerr:0b, m_nres:0b, m_bstat:0b, $
   fspin:0., $
   m_volt:fltarr(9), $
   e_vers:0b, e_stat:0b, e_lerr:0b, e_nerr:0b, e_nres:0b, e_bstat:0b, e_swp:0b,$
   e_volt:fltarr(8), $
   p_vers:0b, p_stat:0b, p_lerr:0b, p_nerr:0b, p_nres:0b, p_bstat:0b, p_swp:0b,$
   p_volt:fltarr(8), $
   temp:fltarr(4) , valid:0l }


m_volt_names=['main_p5','main_m5','main_p12','main_m12','sst_p9', $
    'sst_p5','sst_m4','sst_m9','sst_hv']
e_volt_names=['eesa_p5','eesa_p12','eesa_m12','eesa_mcpl','eesa_mcph', $
    'eesa_pmt','eesa_swpl','eesa_swph']
p_volt_names=['pesa_p5','pesa_p12','pesa_m12','pesa_mcpl','pesa_mcph', $
    'pesa_pmt','pesa_swpl','pesa_swph']
temp_names=['eesa_temp','pesa_temp','sst1_temp','sst3_temp']

filedata = assoc(fp,dat)

if not keyword_set(index) then begin
   file_status = fstat(fp)
   rec_len=n_tags(dat,/length)
;help,dat,file_status,/st
;stop
   num_records = file_status.size / rec_len
   index = [0l,num_records -1]
   print,index,' Records'
endif

np =index(1)-index(0)+1

time = fltarr(np)

m_volt = fltarr(np,9)
e_volt = fltarr(np,8)
p_volt = fltarr(np,8)
temp  = fltarr(np,4)
resets = intarr(np,3)
mode  = bytarr(np,3)
mbstat = bytarr(np)
n = 0l
for i=0l,np-1 do begin
    foo = filedata(i+index(0))
    time(i) = foo.time
    m_volt(i,*) = foo.m_volt
    e_volt(i,*) = foo.e_volt
    p_volt(i,*) = foo.p_volt
    temp(i,*) = foo.temp
    resets(i,*) = [foo.m_nres,foo.e_nres,foo.p_nres]
    mode(i,*)  = [foo.mode,foo.burst_stat,foo.rate]+[0,4,8]
    mbstat(i)  = foo.m_bstat
endfor



if data_type(name) ne 7 then name = 'hkp_lt_'


store_data,name+'main',data={x:time,y:m_volt,labels:m_volt_names}
store_data,name+'eesa',data={x:time,y:e_volt,labels:e_volt_names}
store_data,name+'pesa',data={x:time,y:p_volt,labels:p_volt_names}
store_data,name+'temp',data={x:time,y:temp,labels:temp_names}
store_data,name+'resets',data={x:time,y:resets,labels:['main','eesa','pesa']}
store_data,name+'mode',data={x:time,y:mode,labels:['S/M','Burst','Rate']}
store_data,name+'burst',data={x:time,y:mbstat,tplot_routine:'bitplot'}
free_lun,fp

end

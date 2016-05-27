pro get_so_lt,trange,index = index, $
    bins = bins,name=name,scale=scale

dir = '/home/wind/scratch/long_term/'
openr,fp,dir+'sst_3d_O_accums',/get_lun
dat = {time:0.d, dtime:0.d, n_packets:0l, quality:0l, dummy:fltarr(3), data:fltarr(9,48) }
filedata = assoc(fp,dat)

if not keyword_set(index) then begin
   file_status = fstat(fp)
   rec_len=n_tags(dat,/length)
;help,dat,file_status,/st
;stop
   num_records = file_status.size / rec_len
   index = [0l,num_records -1]
   print,'Records: ',index
endif

np =index(1)-index(0)+1

time = fltarr(np)
data = fltarr(np,9)

count = 0
if n_elements(bins) eq 48 then ind = where(bins,count)
if count eq 0 then ind = indgen(48)

if n_elements(scale) ne 9*48 then scale = replicate(1.,9,48)

;on_ioerror,error

n = 0l
for i=0l,np-1 do begin
    foo = filedata(i+index(0))
    if(foo.time) > 7.5738240e+08 then begin
       foo.data = foo.data/scale/foo.dtime
       data(n,*) = total(foo.data(*,ind),2)
       time(n)   = foo.time
       n=n+1
    endif
endfor
error:

time = time(0:n-1)
data = data(0:n-1,*)

if data_type(name) ne 7 then name = 'sstopen'

;print,index,np
dat = { ytitle:name,  x:time, y:data, ylog:1, panel_size:2.}

store_data,name,data=dat
free_lun,fp

end

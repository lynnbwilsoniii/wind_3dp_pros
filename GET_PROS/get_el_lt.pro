pro get_el_lt,trange,index = index, $
    bins = bins,name=name,scale=scale

dir = '/home/wind/scratch/long_term/'
openr,fp,dir+'el3d_accums',/get_lun
dat = {time:0.d, dtime:0.d, n_packets:0l, quality:0l, dummy:fltarr(3), $
        data:fltarr(15,88) }
filedata = assoc(fp,dat)

if not keyword_set(index) then begin
   file_status = fstat(fp)
   rec_len=n_tags(dat,/length)
;help,dat,file_status,/st
;stop
   num_records = file_status.size / rec_len
   index = [0l,num_records -1]
   print,' Records:',index
endif

;foo = filedata(0)
;startsstftime = foo.time
;if n_elements(trange) ne 2 then trange = [str_to_time('94-11-20'),systime(1)]
;tr = gettime(trange)
;if not keyword_set(index) then index = long((tr-startsstftime)/(256*6.))
;index(0) = index(0) > 0
;index(1) = index(1) < 50000l+index(0)


np =index(1)-index(0)+1

time = fltarr(np)
data = fltarr(np,15)

count = 0
if n_elements(bins) eq 88 then ind = where(bins,count)
if count eq 0 then ind = indgen(88)

if n_elements(scale) ne 15*88 then scale = replicate(1.,15,88)

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

if data_type(name) ne 7 then name = 'el_lt'

;print,index,np
dat = { ytitle:name,  x:time, y:data, ylog:1, panel_size:2.}

store_data,name,data=dat
free_lun,fp

end

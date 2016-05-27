pro get_sf_lt,trange,index = index, $
    bins = bins,name=name,scale=scale


dir = getenv('WIND3DP_LT_DIR')
if not keyword_set(dir) then $
    dir = '.'
filename = dir+'/sst_3d_F_accums'
openr,fp,filename,/get_lun
dat = {time:0.d, dtime:0.d, n_packets:0l, quality:0l, dummy:fltarr(3), data:fltarr(7,48) }
filedata = assoc(fp,dat)
print,'Using long term file: ',filename

   file_status = fstat(fp)
   rec_len=n_tags(dat,/length)
   num_records = file_status.size / rec_len
   index = [0l,num_records -1]

if keyword_set(trange) then begin
  mn = index([0,0])
  mx = index([1,1])
  repeat begin
     i = (mx+mn)/2
     x = [(filedata(i[0])).time ,(filedata(i[1])).time]
     tst = x(i) lt trange
     ntst = tst eq 0
     mn =  tst*i + ntst*mn
     mx = ntst*i +  tst*mx
  endrep  until max(mx-mn) le 1
  index = (mx+mn)/2
endif

print,'Records: ',index

np =index(1)-index(0)+1

time = fltarr(np)
data = fltarr(np,7)
nbins = 48

count = 0
if n_elements(bins) eq 48 then ind = where(bins,count)
if count eq 0 then ind = indgen(48)

;if n_elements(scale) ne 7*48 then scale = replicate(1.,7,48)

;on_ioerror,error

n = 0l
for i=0l,np-1 do begin
    foo = filedata(i+index(0))
    if(foo.time) > 7.5738240e+08 then begin
       foo.data = foo.data/scale/foo.dtime
       data(n,*) = average(foo.data(*,ind),2)
       time(n)   = foo.time+foo.dtime/2
       n=n+1
    endif
endfor
error:


if data_type(name) ne 7 then name = 'sstfoil'

;print,index,np
energies=[27188.1,40100.6,66132.4,108398.,181672.,309325.,516619.]



dat = {  x:time, y:data, v:energies  }
lim = {  ylog:1, panel_size:2.}

store_data,name,data=dat,dlim=lim
free_lun,fp

end

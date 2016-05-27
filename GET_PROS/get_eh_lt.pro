


pro get_eh_lt,trange,index = index, $
    bins = bins,name=name,scale=scale,bkgrate=bkgrate,erange=erange

dir = getenv('WIND3DP_LT_DIR')
if not keyword_set(dir) then $
    dir = '.'
filename = dir+'/eh3d_accums'
openr,fp,dir+'eh3d_accums',/get_lun
dat = {eh_lt,time:0.d, dtime:0.d, n_packets:0l, quality:0l, dummy:fltarr(3), data:fltarr(15,88) }
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
nbins = 88

count = 0
if n_elements(bins) eq nbins then ind = where(bins,count)
if count eq 0 then ind = indgen(88)

if n_elements(scale) ne 15*88 then scale = replicate(1.,15,88)
if n_elements(bkgrate) eq 0 then bkgrate = 0.


if keyword_set(erange) then begin

data = fltarr(np,nbins)
n = 0l
for i=0l,np-1 do begin
    foo = filedata(i+index(0))
    if(foo.time) > 7.5738240e+08 then begin
       foo.data = foo.data/foo.dtime
       foo.data = foo.data - bkgrate
       foo.data = foo.data/scale
       data(n,*) = total(foo.data(erange(0):erange(1),*),1)
       time(n)   = foo.time+foo.dtime/2
       n=n+1
    endif
endfor

endif else begin

data = fltarr(np,15)
n = 0l
for i=0l,np-1 do begin
    foo = filedata(i+index(0))
    if(foo.time) > 7.5738240e+08 then begin
       foo.data = foo.data/foo.dtime
       foo.data = foo.data - bkgrate
       foo.data = foo.data/scale
       data(n,*) = average(foo.data(*,ind),2)
       time(n)   = foo.time+foo.dtime/2
       n=n+1
    endif
endfor

endelse


if data_type(name) ne 7 then name = 'eh_lt'

;print,index,np
dat = {x:time, y:data,v:dgen(15,range=[27e3,135.],/log)}
lim = {ylog:1, panel_size:2.}

store_data,name,data=dat,dlim=lim
free_lun,fp

end

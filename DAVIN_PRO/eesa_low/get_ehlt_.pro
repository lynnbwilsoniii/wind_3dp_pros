function get_ehlt,time,ehtemp=ehtemp
common  ehlt_file,fp,filedata,index,num_records,ehstr,b,c

if not keyword_set(fp) then begin
  dir = '/disks/aeolus/home/wind/scratch/long_term/'
  openr,fp,dir+'eh3d_accums',/get_lun
  dat = {eh_lt,time:0.d, dtime:0.d, n_packets:0l, quality:0l, dummy:fltarr(3), data:fltarr(15,88) }
  filedata = assoc(fp,dat)

  file_status = fstat(fp)
  rec_len=n_tags(dat,/length)
  num_records = file_status.size / rec_len
  print,num_records,' Records'
endif

if keyword_set(ehtemp) then  ehstr = ehtemp

trange = time_double(time)
trange = trange[[0,n_elements(trange)-1]]
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
  print,'records: ',index
;  print,time_string()
endif

eh = ehstr
eh.data=0
eh.time=0
eh.integ_t = 0
n = 0l
for i=index[0],index[1] do begin
    foo = filedata(i)
    if(foo.time) > 7.5738240e+08 then begin
       eh.data = eh.data + foo.data
       eh.time = eh.time + foo.time
       eh.integ_t = eh.integ_t + foo.dtime
       n=n+1
    endif
endfor
eh.time = eh.time/n
eh.end_time = eh.time+eh.integ_t

return,eh


end


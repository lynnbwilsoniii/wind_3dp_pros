function findtime,filedata,records,t
  foo = filedata(0)
  t0 = foo.time
  foo = filedata(records-1)
  t1 = foo.time
  index = lonarr(2)
  for i=0,1 do begin 
    index(i) = long(records*(t(i)-t0)/(t1-t0))
    ;print,index(i)
    done = 0
    diff = foo.time-t(i)
    while not done do begin     ;newton's method?
      foo = filedata(index(i))
      index(i) = long(index(i)*(t(i)-t0)/(foo.time-t0))
      ;print,index(i)
      if abs(foo.time-t(i)) ge abs(diff) then done = 1
      diff = foo.time-t(i)
    endwhile
    done = 0
    if diff gt 0 then step = -1 else step = 1
    while not done do begin     ;find the record one before or one past t(i)
      index(i) = index(i)+step
      foo = filedata(index(i))
      ;print,index(i)
      if step*(foo.time-t(i)) gt 0 then done = 1 ;if we just passed over t(i)
    endwhile
    if i eq 0 then begin 
      if step eq 1 then index(i) = index(i)-1 ;select the record before t(0)
      index = index - 1 > 0
    endif                   ;if i eq 1 then we selected the record post t(1)
  endfor 
  return,index
end

pro get_pmom_lt,trange,filename=filename;,index = index, $
;on_ioerror,error

dir = getenv('WIND3DP_LT_DIR')
if not keyword_set(dir) then $
    dir = '/wind/scratch/long_term'
if not keyword_set(filename) then filename = dir+'/pmom_binary'
openr,fp,filename,/get_lun
dat = {time:0.d, dtime:0.d, quality:0, nsamp:0, counter:0l, dummy:0l,$
   dens:0., vel:fltarr(3), temp:0. }
filedata = assoc(fp,dat)

;foo = filedata(0)
;startsstftime = foo.time
;if n_elements(trange) ne 2 then trange = [str_to_time('94-11-20'),systime(1)]
;tr = gettime(trange)
;if not keyword_set(index) then index = long((tr-startsstftime)/(128*3.))
;index(0) = index(0) > 0
;index(1) = index(1) < 50000l+index(0)

file_status = fstat(fp)
rec_len=n_tags(dat,/length)
num_records = file_status.size / rec_len
if not keyword_set(index) then index = [0l,num_records -1] $
else index = index < (num_records-1)

if n_params() eq 1 then index = findtime(filedata,num_records,trange)

np =index(1)-index(0)+1

foo = filedata(index(0))
t0  = foo.time
foo = filedata(index(1))
t1  = foo.time

time = fltarr(np)
dens = fltarr(np)
vel = fltarr(np,3)
temp = fltarr(np)

n = 0l
for i=0l,np-1 do begin
    foo = filedata(i+index(0))
    if (foo.time ge t0) and (foo.time le t1) then begin
       time(n)   = foo.time
       dens(n)  = foo.dens
       vel(n,*) = foo.vel
       temp(n)  = foo.temp
       n=n+1
    endif
endfor
error:
print,n

time = time(0:n-1)
dens = dens(0:n-1)
vel =  vel(0:n-1,*)
temp = temp(0:n-1)

store_data,"Np_lt",data={ytitle:'Np_lt', x:time, y:dens}
store_data,"Vp_lt",data={ytitle:'Vp_lt', x:time, y:vel}
store_data,"Tp_lt",data={ytitle:'Tp_lt', x:time, y:temp}
free_lun,fp

end

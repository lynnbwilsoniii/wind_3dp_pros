pro load_sunspots

file = '/home/davin/dat/solar/sunspots/RIDAILY.PLT'
f = {year:0,month:0,date:0,ssn:0.}
file = '/home/davin/dat/solar/sunspots/MONTHLY.PLT'
f = {year:0,month:0,ssn:0.}
dat = read_asc(file,format=f)
if not keyword_set(dat) then begin
  print,'Unable to read file: ',file
  return
endif
n = n_elements(dat)
t = time_struct(replicate(0.,n))

t.year = dat.year
t.month = dat.month

t.date = 15
t = time_double(t)
store_data,'sunspots',data={x:t,y:dat.ssn}


end
pro  load_noaa_10cm,data=dat,all=all

basedir = getenv('BASE_DATA_DIR')

file = basedir+'/solar/noaa/RecentIndices.txt'
format = {year:0,mo:0,swo:0.,ri:0., ri_swo:0., $
  swo_sm:0., ri_sm:0., rf10cm:0., rf10cm_sm:0., $
  Ap:0., ap_sm:0. }

dat = read_asc(file,format=format)
if not keyword_set(dat) then begin
  print,'Unable to read file: ',file
  return
endif

t = replicate(time_struct(0d),n_elements(dat))
t.year = dat.year
t.month = dat.mo
t.date = 15
t = time_double(t)

store_data,'noaa

str_element,/add,dat,'time',t
if keyword_set(all) then begin
  store_data,'noaa',data=dat
  del_data,'noaa.YEAR'
  del_data,'noaa.MO'
endif else begin
  store_data,'rad10cm',data={x:t,y:dat.rf10cm},dlim={ytitle:'10 cm radio power'}
endelse


end

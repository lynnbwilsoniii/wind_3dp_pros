pro load_wi_wav_tnr_dens,data=alldat


;path = getenv('BASE_DATA_DIR')
path = '/home/lbwilson/overflow/wind_3dp/3DP_IDL_PROS/TNR_DATA/'
 files = findfile(path+'wi_lz*.dat',count=n)
 f = {time:0d,ne_nn:0.,ne_fit:0.,tc:0.,te:0.,sig_ne:0.,sig_tc:0.,sig_fit:0.}
 for i=0,n-1 do begin
   dat = read_asc(files[i],format=f,nheader=4,headers=headers)
   starttime = time_double(headers[0])
   dat.time = dat.time*3600+ starttime
   if i eq 0 then alldat = dat else alldat=[alldat,dat]
 endfor
 
 store_data,'tnr',data=alldat

end
 
 
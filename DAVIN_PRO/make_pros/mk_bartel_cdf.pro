;function full_pathname,fname,bartel=bartel,basedir=basedir,mkdir=mkdir
;
;if not keyword_set(basedir) then  basedir= getenv('BASE_DATA_DIR')
;parts = strsplit(fname,'_',/extract)
;
;if keyword_set(bartel) or parts[3] eq 'B' then  parts[3] = 'bartel'  $
;else parts[3] = strmid(parts[3],0,4)
;
;dir = basedir+'/'+strjoin(parts[0:3],'/')
;if file_test(dir,/dir) eq 0 and keyword_set(mkdir) then begin
;   message,/info,string(/print,'Making directory: ',dir)
;   file_mkdir,dir
;endif
;
;pathname = dir+'/'+fname
;return,pathname
;end



trange = time_double(['98-6-2','98-6-4'])
format = 'wi_sfsp2_3dp_files'
fnameformat = '(%"wi_3dp_sfsp2_B_%4d_")'
format = 'wi_sfsp_3dp_files'
fnameformat = '(%"wi_3dp_sfsp_B_%4d_")'
format = 'wi_h0_mfi_files'
fnameformat = '(%"wi_mfi_h0_B_%4d_")'
format = 'wi_k0_mfi_files'
fnameformat = '(%"wi_mfi_k0_B_%4d_")'

format = '/home/davin/dat/wi/3dp/ehsp1/????/*.cdf'
fnameformat = '(%"wi_3dp_ehsp1_B_%4d_")'

format = 'wi_3dp_ehsp_files'
fnameformat = '(%"wi_3dp_ehsp_B_%4d_")'

format = 'wi_3dp_sosp_files'
fnameformat = '(%"wi_3dp_sosp_B_%4d_")'

format = 'wi_3dp_sfsp_files'
fnameformat = '(%"wi_3dp_sfsp_B_%4d_")'

format = 'wi_plsp_3dp_files'
fnameformat = '(%"wi_3dp_plsp_B_%4d_")'

format = 'wi_3dp_elpd_files'
fnameformat = '(%"wi_3dp_elpd_B_%4d_")'

format = 'wi_k0_swe_files'
fnameformat = '(%"wi_swe_k0_B_%4d_")'

b = fix(bartel_time(/inv,time_double('94-12-1')))
b1 = fix(bartel_time(/inv,systime(1))-1)
stop
while b le b1 do begin
  trange = bartel_time(b+[0,1])
  files = cdf_file_names(format,trange=trange,/verb)
  if  keyword_set(files) then begin
  ptrs = cdf_ptrs(file=files,/verb,res=600d)
  version = n_elements(files) eq 27 ? 'v01' : 'v00'
  fname = string(/print,b,form=fnameformat)+version
  pname = full_pathname(fname,/mkdir)
  cdf_write_ptrs,ptrs,pname,/overwrite
  
  ptr_free,ptrs.attrptr,ptrs.dataptr
  endif
  b=b+1
  
endwhile

end



format = 'wi_k0_swe_files'
fnameformat = '(%"wi_swe_k0_B_%4d_")'

b = fix(bartel_time(/inv,time_double('94-12-1')))
b1 = fix(bartel_time(/inv,systime(1))-1)

while b le b1 do begin
  trange = bartel_time(b+[0,1])
  files = cdf_file_names(format,trange=trange,/verb)
  if  keyword_set(files) then begin
  ptrs = cdf_ptrs(file=files,/verb)  

np = n_elements(ptrs)
;depend = array_union(ptrs.depend_0,ptrs.name)
;d = depend[uniq(depend,sort(depend))]
tp = ptrarr(np)
for i=0,np-1 do begin
  p = ptrs[i]
  depend_0 =p.depend_0 ? p.depend_0 : p.name
  j = (array_union(depend_0,ptrs.name))[0]
  time = *ptrs[j].dataptr
  dtime = time-shift(time,1)
  dtime[0]=dtime[1]
  bad = where(dtime le -30.,nbad)
  if nbad gt 0 then time[bad] = !values.f_nan
  print,p.name,' ',ptrs[j].name
  tp[i] = ptr_new( time )
endfor
for i=0,np-1 do begin
  p = ptrs[i]
  depend_0 =p.depend_0 ? p.depend_0 : p.name
  *p.dataptr =  time_average(*tp[i], *p.dataptr,res=600d,trange=trange) 
endfor
  
  version = n_elements(files) eq 27 ? 'v01' : 'v00'
  fname = string(/print,b,form=fnameformat)+version
  pname = full_pathname(fname,/mkdir)
  cdf_write_ptrs,ptrs,pname,/overwrite
  
  ptr_free,ptrs.attrptr,ptrs.dataptr
  endif
  b=b+1
  
endwhile

end







pro mk_bartel_cdf          ; .run
res = 600d
b0 = fix(bartel_time(/inv,'1994-12-1')) 
b1 = fix(bartel_time(/inv,systime(1)))
plotdir = '/home/davin/splots'
b = b0
wi,0
while b le b1 do begin
  timespan,bartel_time(b+[0,1])
  tplot_options,title=string(/print,b,format='(%"Bartel Rotation %d")')

  plotname = string(/print,b,form='(%"wi_3dp_spec_B_%4d_v01")')

  sfspname = string(/print,b,form='(%"wi_3dp_sfsp_B_%4d_v01")')
  if file_test(full_pathname(sfspname)+'.cdf') then begin
     load_wi_sfsp_3dp,master='wi_3dp_sfsp_B_files'
  endif else begin
     load_wi_sfsp_3dp,res=res,data=sfsp
     makecdf,sfsp,file=full_pathname(sfspname),/overwrite
  endelse
  
  sospname = string(/print,b,form='(%"wi_3dp_sosp_B_%4d_v01")')
  if file_test(full_pathname(sospname)+'.cdf') then begin
     load_wi_sosp_3dp,master='wi_3dp_sosp_B_files'
  endif else begin
     load_wi_sosp_3dp,res=res,data=sosp
     makecdf,sosp,file=full_pathname(sospname),/overwrite
  endelse
  
  posname = string(/print,b,form='(%"wi_or_cmb_B_%4d_v01")')
  if file_test(full_pathname(posname)+'.cdf') then begin
     load_wi_or,master='wi_or_cmb_B_files'
  endif else begin
     load_wi_or,res=res,data=pos
     makecdf,pos,file=full_pathname(posname),/overwrite
  endelse
  
  ylim,'sfsp',1e-8,10,1
  ylim,'sosp',1e-8,10,1
  ylim,'wi_pos',-300,300,0
  options,'sfsp sosp',panel_size=2.
  options,'wi_pos',constant=0.,panel_size=.75
  tplot,'sfsp sosp wi_pos'
  makegif,full_pathname(/mkdir,basedir=plotdir,plotname),/no_expose
  if keyword_set(debug) then stop
  b = b+1
endwhile
end




;  change_file_names
;  dir = '/home/davin/dat/wi/3dp/elpd/????/'
;  f = findfile(dir+'*.cdf')
;  f2= f
;  strput,f2,'3dp_elpd',36
;  for i=0,n_elements(f)-1 do spawn,'mv '+f[i]+' '+f2[i]






function screen_locked
common screen_locked_com, timelast,lcked
if not keyword_set(timelast) then timelast=0
t = systime(1)
if t-timelast le 60 then return,lcked
timelast = t
command1 = 'ps -ef | grep xlock | grep -v grep'
spawn,command1,result1
command2 = 'ps -ef | grep dtscreen | grep -v grep'
spawn,command2,result2
command3 = 'ps -ef | grep dtgreet | grep -v grep'
spawn,command3,result3
lcked = keyword_set(result1) or keyword_set(result2) or keyword_set(result3)
return,lcked
end


pro wait_for_others

  defsysv,'!tcontrol',exists=i
  if i eq 0 then defsysv,'!tcontrol',getenv('HOST') ne 'boreas'
  
  if !tcontrol eq 0 then return
  
;  stoptime = '2003-1-1'
;  if time_double(stoptime) ge systime(1)-7*3600. then break
  
  ok=0 
  wtime = 300
  repeat begin
     ts= systime()
     hr = fix(strmid(ts,11,2))
;     if hr ge 22 or hr lt 7 then break
     if screen_locked() then break
     print,getenv('HOST'),'>  ',ts,'       Waiting...'
     wait,wtime
  endrep until ok
  print,getenv('HOST'),'>  ',ts
end





pro mk_all2_cdf,trange,n,plotdevice=plotdevice, $
  overwrite=overwrite,no_catch=no_catch,skip=skip,test=test,modn=modn,runtime=runtime

defsysv,'!debug',exists=i
if i eq 0 then defsysv,'!debug',0
starttime=systime(1)

;cd,'/home/davin/disk2/winddata/elpd_v05'
;set_plot,'z'

if not keyword_set(trange) then begin
  start=''
  read,start,prompt='Start time? '
  stop=''
  read,stop,prompt='End time? '
  trange=[start,stop]
endif

trfull = floor(minmax(time_double(trange))/86400d) * 86400d

if not keyword_set(n) then n = round((trfull[1]-trfull[0])/86400.d) 
if n le 0 then n=1

;sda = 0
verbose = 1
wsize = [800,900]

if keyword_set(plotdevice) then begin
   oldname= !d.name
endif

if !d.name eq 'Z' then  begin
  device,set_resol=wsize
  !p.charsize = .8
endif

if !d.name eq 'X' then begin
  window,0,xsize=wsize[0],ysize=wsize[1],retain=2
  tplot_options,window=0
  !p.charsize=1
  wi,0
endif


elpd = 1d
spec = 0
alf = 0
;test = 1
tbar = 0

for i=0,n-1 do begin
  
;  if not keyword_set(no_catch) then begin
;    catch,error_status
;    if error_status ne 0 then begin
;      page,time_string(tr[0],/date)+' '+!error_state.msg,subject='Error'
;      continue
;    endif  
;  endif

  tf = trfull[0] + i * 86400d
  
  if n_elements(modn) ne 0 then begin
     daynum = round(tf /86400d)
     if daynum mod 8 ne modn then continue
  endif
  
if 0 then begin
  if file_test('/tmp/wind3dp.exit') then exit
  if not file_test('/tmp/readme.batch') then exit
  if file_test(getenv('HOST')+'.stop') then stop
  if file_test(getenv('HOST')+'.quit') then break
  if file_test(getenv('HOST')+'.exit') then exit
  if !debug then stop
  wait_for_others
endif

  if keyword_set(test1) then stop
  if keyword_set(quit) then break
  
  tlabel = time_string(tf,/date,form=2)+'_v2'
  if keyword_set(skip) then begin
     tlabel = time_string(tf,/date,form=2)+'_v4'
  endif
  fname = getenv('BASE_DATA_DIR')+'/tmp/'+tlabel+'.tmp'
  if not keyword_set(overwrite) then begin
     if file_test(fname) then begin
       print,'FILE: '+fname+' found. skipping...'
       continue
     endif
     spawn,'touch '+fname
  endif
  
  if keyword_set(runtime) then begin
     if systime(1) gt starttime + 3600.*runtime then break
  endif

  tr = [tf,tf+86400d]
  tr1 = tr + round((3600*[-1.5,1.5])/60)*60d
  if keyword_set(skip) then timespan,tr $
  else  timespan,tr1
  del_data,'*' ; Delete all tplot data!

    
;if elpd then    get_elpd,data=elpdm,cdf_time=tr
if elpd then    get_elpd,data=elpdm,cdf_time=tr,test=test,/do_fit,/verbos,timebar=tbar,skip=skip
 
if spec then    get_all_spectra,cdf_time=tr


;if elpd or spec or alf then   load_3dp_data,mem=30
;if elpd or alf    then       load_wi_h0_mfi,/pol
;if elpd           then       load_wi_or,/var
;if elpd           then       load_wi_swe,/pol
;if elpd or alf    then       get_pmom2 ;,magname='wi_B3'
;  load_wi_swe,/pol
;  div_data,'wi_swe_VTHp','wi_swe_Vp_mag',newn='wi_swe_Vth/V'
   
;  plot_pmom,1
;  wi,0
;  makegif,'D'+tlabel+'_NVT'
  
;  alfven_data,trange=tr1
;  parker_spiral_angle,'wi_B3'
;  alfven_plot
;  makegif,'D'+tlabel+'_Alf'
;  tplot_to_cdf,'wi_B3 Np Vp Tp *_wv_* wi_B3_Vp_xwv_d_p-a',trange=tr,res=60d,file='wi_wvlt_'+tvlabel
  
;  mk_pmom2_cdf,/no_load,trange=tr,verbose=verbose  ; loads pmom data
;  shock_detect,sda,/append,trange=tr,verbose=verbose,/do_plot
;  if i mod 10 eq 0 then save,sda,file='IP_sd_'+tlabel[0]+'_'+tlabel[1]+'.sav'

;  if i lt 3 then page,time_string(tr[0],/date)+' was successful',subject='Comps' 

endfor


if keyword_set(plotdevice) then set_plot,oldname

;page,'All Successful!'

end








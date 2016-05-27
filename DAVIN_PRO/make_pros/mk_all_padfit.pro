





pro mk_all_padfit,trange,n

cd,'/home/davin/disk2/winddata/pdfit_v01'
set_plot,'z'

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

verbose = 1
wsize = [800,900]

if !d.name eq 'Z' then  begin
  device,set_resol=wsize
  !p.charsize = .8
endif
if !d.name eq 'X' then begin
  window,0,xsize=wsize[0],ysize=wsize[1]
  tplot_options,window=0
  !p.charsize=1
  wi,0
endif

for i=0,n-1 do begin
  if file_test(getenv('HOST')+'.stop') then stop
  if file_test(getenv('HOST')+'.quit') then break
  if file_test(getenv('HOST')+'.exit') then exit
;  catch,error_status
;  if error_status ne 0 then begin
;    page,time_string(tr[0],/date)+' '+!error_state.msg,subject='Error'
;    continue
;  endif

  tf = trfull[0] + i * 86400d
  
  tlabel = time_string(tf,/date,form=2)
  cdfname = 'pdfit_'+tlabel+'_v01'
  fname = 'pdfit_'+tlabel+'.png'
;  fname = cdfname+'.cdf'
  if not keyword_set(overwrite) then begin
     if file_test(fname) then begin
       print,'FILE: '+fname+' found. skipping...'
       continue
     endif
     spawn,'touch '+fname
  endif

  tr = [tf,tf+86400d]
;  tr1 = tr + round((3600*[-1.5,1.5])/60)*60d
  timespan,tr
   del_data,'*' ; Delete all tplot data!

  load_wi_elpd5,/no_reduce
  
  reduce_pads,'elpd',[125.,250.,500]
  get_bsn2,vname='VSW',bname='MAGF',pname='wi_pos'
  
    
  get_padfit,'elpd_125eV'
  get_padfit,'elpd_250eV'
  get_padfit,'elpd_500eV'
  
  vars = 'elm.* bsn.* elpd_???eV elpd_???eV_f.* wi_pos NSW VSW TSW'
  
  if keyword_set(test) then stop
  
  tplot_to_cdf,vars,file=cdfname,res=600d
  
  
  if keyword_set(test) then stop
  if keyword_set(quit) then break
endfor



end



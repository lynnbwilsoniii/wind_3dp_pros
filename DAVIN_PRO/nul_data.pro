;+
;PROCEDURE: nul_data
;PURPOSE:
;   Null out a range of tplot data.
;INPUT: none yet
;-
PRO nul_data,times=times,varname=vnames ,appname=appname, no_verify=no_verify 


if not keyword_set(times) then begin
  print, 'pick start and end times of data to nulify'
  ctime,times,y,vname=vnames,npoints=2
  if n_elements(vnames) ne 2 then return
  if vnames(0) ne vnames(1) then return
  vnames=vnames[0]
endif


tnams = tnames(vnames,dtype=dtype)


if not keyword_set(no_verify) then begin
print, 'Do you really want to NULL the following data quantities:'
print,tnams
print, 'in the following time periods:'
print,time_string(times)
ans='n'
read,ans,prompt='? '
if strlowcase(ans) ne 'y' then return
print,'ok'
endif


if dimen1(times) ne 2 then message,'Time must have at least 2 elements'

for i=0,n_elements(tnams)-1 do begin

vname = tnams[i]
if dtype[i] ne 1 then continue;
get_data,vname,data=d
if size(/type,d) ne 8 then continue

nd2 = dimen2(times)
for ns=0,nd2-1 do begin
   t = time_double(times(*,ns))

   w = where(d.x gt t(0) and d.x lt t(1),c)
  if c ne 0 then begin
    if ndimen(d.y) eq 1 then d.y(w) = !values.f_nan
    if ndimen(d.y) eq 2 then d.y(w,*) = !values.f_nan
  endif
  
endfor

if keyword_set(appname) then vname=vname+appname

store_data,vname,data=d

endfor

return
end

function reduce_timeres,time,data,res,newtime=newtime


ndim = size(data,/n_dimen)

if ndim eq 1 then begin
   return, average_hist(data,time,binsize=res,/shift,xbins=newtime,/nan)
endif
dim = size(data,/dimen)
nd = dim[1]

if ndim eq 2 then begin
  
  for i=0,nd-1 do begin
     d = average_hist(data[*,i],time,binsize=res,/shift,xbins=newtime,/nan)
     if i eq 0 then rd = d # replicate(1,nd) else rd[*,i] = d
  endfor
  return,rd
endif

message,'error'


end

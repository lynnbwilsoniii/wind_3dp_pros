pro get_beta,bmag=bmagn,pressure=presn,newname=newname,dens=densn,temp=tempn

if not keyword_set(bmagn) then bmagn= 'wi_B'
get_data,bmagn,ptr=bs

if keyword_set(densn) and keyword_set(tempn) then begin
  pressn = densn+'_'+tempn
  get_data,densn,ptr=ps
  if not keyword_set(ps) then print,densn,' not found'
  get_data,tempn,ptr=ts
  if not keyword_set(ts) then print,tempn,' not found'
  press = interp(*ts.y,*ts.x,*ps.x); * *ps.y
endif else begin
  if not keyword_set(presn) then presn = 'Pp'
  get_data,presn,ptr=ps
  press = *ps.y
endelse

bmag = *bs.y
if ndimen(bmag) eq 2 then bmag=sqrt(total(bmag^2,2))

bmag = interp(bmag,*bs.x,*ps.x)
bpress = bmag^2/4.03e-1

beta = press / bpress

if not keyword_set(newname) then newname=presn+'_beta'

store_data,newname,data={x:ps.x,y:beta},dlim={yrange:[.02,5],ylog:1,ystyle:1}
end

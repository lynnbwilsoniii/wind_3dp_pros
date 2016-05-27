
function ehbkgfit,x,set=set,parameters=p
if not keyword_set(p) then begin
  bkgrate=dblarr(8)+10.
  rgeom = dblarr(8)+1.
  bins= bytarr(15,88)+1
  bins(0,*) = 0
  bins(9:*,*) = 0
  bins(*,0:21) = 0
  bins(*,66:*) = 0
  p={bins:bins,slope:-4.5d,flux1k:1000.d,bkgrate:bkgrate,rgeom:rgeom}
endif
if not keyword_set(x) then return,0

detector=[ $
3,3,2,2,3,3,2,2,1,1,0, 4,4,5,5,4,4,5,5,6,6,7, $
3,3,2,2,3,3,2,2,1,1,0, 4,4,5,5,4,4,5,5,6,6,7, $
3,3,2,2,3,3,2,2,1,1,0, 4,4,5,5,4,4,5,5,6,6,7, $
3,3,2,2,3,3,2,2,1,1,0, 4,4,5,5,4,4,5,5,6,6,7] 


d = replicate(1,15) # detector
g = p.rgeom[d] * x.gf
dtime = x.integ_t / 32 /32
b = p.bkgrate[d] * dtime

counts = p.flux1k * (x.energy/1000.d)^p.slope * g + b

ind = where(p.bins)

if keyword_set(set) then begin
   x.data = !values.f_nan
   x.data(ind) = counts(ind)
endif


return,counts(ind)
end

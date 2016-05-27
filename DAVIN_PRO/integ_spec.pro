pro integ_spec,name,range,kolom=kolom,average=average,newname=newname
if n_params() eq 0 then ctime,t,y,vname=vname,np=2
if not keyword_set(name) then name = vname(0)
get_data,name,ptr=p
if not keyword_set(y) then y = minmax(*p.v)
if not keyword_set(range) then range = minmax(y)
help,d,/str
n  = dimen1(*p.y)
ny = dimen2(*p.y)
print,ny
v = *p.v
nv = ndimen(v)
if nv ne 1 then message,'dimension of v must be 1'
irange = minmax(round(interp(indgen(ny),v,range)))
printdat,irange,'Irange'
irange = 0 > irange < (ny-1)
if keyword_set(average) then iy=average((*p.y)[*,irange[0]:irange[1]],2) else begin
;y = total(d.y(*,irange(0):irange(1)),2)
dv = abs(deriv(v)) * (v ge range[0]) * (v le range[1])
if keyword_set(kolom) then dv = dv * kolom * v^(-3./5.)
iy = total(*p.y * (replicate(1,n) # dv),2)
;y = average(*p.y(*,irange(0):irange(1)),2)
endelse
help,iy
if not keyword_set(newname) then newname=name+'_i'
store_data,newname,data={x:*p.x,y:iy}
end

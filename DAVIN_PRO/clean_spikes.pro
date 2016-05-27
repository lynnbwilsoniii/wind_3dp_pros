

pro clean_spikes,name,new_name=new_name,nsmooth=ns,thresh=ft


get_data,name,data=d,dlim=dlim,lim=lim

ds = d
nd2 = dimen2(d.y)
if not keyword_set(ns) then  ns = 3
ns = (fix(ns)/2)*2 + 1
if not keyword_set(ft) then  ft = 10.
ft = float(ft)

for i=0,nd2-1 do ds.y[*,i] = smooth(d.y[*,i],ns,/nan)

bad = d.y gt (ft*ns*ds.y/(ns-1+ft) )
if nd2 gt 1 then bad = total(bad,2)
wbad = where(bad gt .5)
d.y[wbad,*] = !values.f_nan

if not keyword_set(new_name) then new_name = name+'_cln'
store_data,new_name,data=d,dlim=dlim,lim=lim

end

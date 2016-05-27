pro dalfven,nsmooth=ns
if not keyword_set(ns) then ns=64
mu0 = 4*!pi*1.609/100
mass = .0104
get_data,'wi_B3',t,b
v = data_cut('Vp',t)
n = data_cut('Np',t)
bs = b
vs = v
for i=0,2 do bs[*,i]=smooth(/nan,/edge,b[*,i],ns)
for i=0,2 do vs[*,i]=smooth(/nan,/edge,v[*,i],ns)
ns = smooth(/nan,/edge,n,ns)
bsmag = sqrt(total(bs^2,2))
b=(b-bs)/(bsmag # [1,1,1])
v=(v-vs)/(bsmag/sqrt(ns*mu0*mass) # [1,1,1])
for i = 0l,n_elements(t)-1 do begin
 rmat = rot_mat(reform(bs[i,*]))
 b[i,*] = b[i,*] # rmat
 v[i,*] = v[i,*] # rmat
endfor

store_data,'dx',data={x:t,y:[[b[*,0]],[v[*,0]]]},dlim={ytitle:'dB!dx!n/<B>!cdV!dx!n/V!dA!n'}
store_data,'dy',data={x:t,y:[[b[*,1]],[v[*,1]]]},dlim={ytitle:'dB!dy!n/<B>!cdV!dy!n/V!dA!n'}
store_data,'dz',data={x:t,y:[[b[*,2]],[v[*,2]]]},dlim={ytitle:'dB!dz!n/<B>!cdV!dz!n/V!dA!n'}
end

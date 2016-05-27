pro fdistfunc ,x,c,f,pder,param=v,nrg=nrg,num_angle=na

common fdistfunc_com, vx0,vy0,a_,b_,c_,d_,e_,f_
if not keyword_set(na) then na = 15

ang = (dindgen(na)+.5)/na*!dpi
;ang = (dindgen(na))/(na-1)*!dpi

if not keyword_set(nrg) then $
  nrg = [1135.05,  776.801,  531.663,  363.842,  249.195,  170.635,  116.921,  $
  80.0878,  54.9104,  37.7383,  25.9584,  17.9116,  12.3535];,  8.66193,  6.04879]


n_e = n_elements(nrg)

angs = replicate(1.d,n_e) # ang
mass = 5.6856593e-06
vel = velocity(nrg,mass) # replicate(1.d,na)

vx0 = vel * cos(angs)
vy0 = vel * sin(angs)

vx0 = vx0(*)
vy0 = vy0(*)

vx = x(*,0)
vy = x(*,1)

n = n_elements(vx0)
if n_elements(c) ne (n+2) then c = dblarr(n+2)

pder = dblarr(n_elements(vx),n+2)
for i=0, n-1 do begin
   d1 = ((vx0(i)-vx)^2 + (vy0(i)-vy)^2) > 1.0d-100  
   d2 = ((vx0(i)-vx)^2 + (vy0(i)+vy)^2) > 1.0d-100  
   pder(*,i) = (d1*alog(d1)+d2*alog(d2))/2.
endfor
pder(*,n) = 1.d
pder(*,n+1) = vx

f = pder # c

v={vx0:vx0,vy0:vy0,dfc:c}

end



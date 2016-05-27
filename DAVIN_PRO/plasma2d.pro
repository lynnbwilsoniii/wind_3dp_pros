

function deriv2,f,dx
;help,x,f
return,  (shift(f,-1)-shift(f,1))/(2*dx)
end


function partial,f,r,dim
if dim lt !cc.ndim then  par = deriv2(reform(f),!cc.dr[dim]) else par=0d
return,par
end



function cross_prod_2d,A,B
C = A
C[0,*,*] = ( A[1,*,*] * B[2,*,*] - A[2,*,*] * B[1,*,*])
C[1,*,*] = ( A[2,*,*] * B[0,*,*] - A[0,*,*] * B[2,*,*])
C[2,*,*] = ( A[0,*,*] * B[1,*,*] - A[1,*,*] * B[0,*,*])
return,C
end



function stens_cross_prod_2d,M,B
C = M
C[0,0,*,*] = 2*( M[0,1,*,*]*B[2,*,*] - M[2,0,*,*]*B[1,*,*] )
C[1,1,*,*] = 2*( M[1,2,*,*]*B[0,*,*] - M[0,1,*,*]*B[2,*,*] )
C[2,2,*,*] = 2*( M[2,0,*,*]*B[1,*,*] - M[1,2,*,*]*B[0,*,*] )
C[0,1,*,*] = ( M[2,0,*,*]*B[0,*,*] - M[1,2,*,*]*B[1,*,*] + (M[1,1,*,*]-M[0,0,*,*]) * B[2,*,*])
C[1,2,*,*] = ( M[0,1,*,*]*B[1,*,*] - M[2,0,*,*]*B[2,*,*] + (M[2,2,*,*]-M[1,1,*,*]) * B[0,*,*])  ; check this!
C[2,0,*,*] = ( M[1,2,*,*]*B[2,*,*] - M[0,1,*,*]*B[0,*,*] + (M[0,0,*,*]-M[2,2,*,*]) * B[1,*,*])  ; check this!
C[1,0,*,*] = C[0,1,*,*]
C[2,1,*,*] = C[1,2,*,*]
C[0,2,*,*] = C[2,0,*,*]
return,C
end


function dot_prod_2d,A,B
dot = (A[0,*,*]*B[0,*,*]+A[1,*,*]*B[1,*,*]+A[2,*,*]*B[2,*,*])
return,reform(dot,/over)
end


function trace_2d,T
dot = T[0,0,*,*] + T[1,1,*,*] + T[2,2,*,*]
return,reform(dot)
end


function div_2d, V,r
dVx = partial(V[0,*,*],r,0)
dVy = partial(V[1,*,*],r,1)
dVz = partial(V[2,*,*],r,2)
return,  reform(dVx+dVy+dVz)
end


function divt_2d, T,r
DT = dblarr([3,!cc.dim])
DT[0,*,*] = partial(T[0,0,*,*],r,0)  + partial(T[0,1,*,*],r,1) + partial(T[0,2,*,*],r,2)
DT[1,*,*] = partial(T[1,0,*,*],r,0)  + partial(T[1,1,*,*],r,1) + partial(T[1,2,*,*],r,2)
DT[2,*,*] = partial(T[2,0,*,*],r,0)  + partial(T[2,1,*,*],r,1) + partial(T[2,2,*,*],r,2)
return,dt
end


function oprod_2d,A,B
p = dblarr([3,3,!cc.dim])
for i=0,2 do for j=0,2 do  p[i,j,*,*] = A[i,*,*] * B[j,*,*]
return,P
end


function curl_2d, A,r
B=A
B[0,*,*] = (partial(A[2,*,*],r,1) - partial(A[1,*,*],r,2) )
B[1,*,*] = (partial(A[0,*,*],r,2) - partial(A[2,*,*],r,0) )
B[2,*,*] = (partial(A[1,*,*],r,0) - partial(A[0,*,*],r,1) )
return,B
end

function grad_2d, f,r
g = dblarr([3,!cc.dim])
g[0,*,*] =  partial(f,r,0)
g[1,*,*] =  partial(f,r,1)
g[2,*,*] =  partial(f,r,2)
return,g
end




function dS_dt,S,t,dsdt=ds,debug=debug
if not keyword_set(ds) then dS = S  ;fill_nan(S)

;for i=0,n_tags(ds)-1 do ds.(i) = !values.f_nan
;return,ds

ds.r=0

ds.B = -curl_2d(S.E,S.r)

ds.E =  !cc.c^2 * curl_2d(s.B,s.r)  - S.J /!cc.eps0

ds.rho = - div_2d(s.J,s.r)

mn3 =[1,1,1] # s.mn
ds.mn = - div_2d(mn3 * s.V,s.r)

jxb = cross_prod_2d(s.J,s.B)
rho3 = [1,1,1] # s.rho
rhoE =  rho3 * s.E
FF =  JxB + rhoE

memp_e2 = !cc.me*!cc.mp/!cc.q_e^2
memp_me = !cc.me*!cc.mp/!cc.q_e/!cc.mt
edm_memp = !cc.q_e*(!cc.mp-!cc.me)/!cc.mp/!cc.me
mp3me3_m2e= (!cc.mp^3+!cc.me^3)/!cc.mt^2/!cc.q_e

JJ_mn   = oprod_2d(s.J, s.J/mn3)
JVVJ =   oprod_2d(s.J, s.V) + oprod_2d(s.V, s.J)
delta_k = JVVJ + ((!cc.mp-!cc.me)/!cc.q_e) * JJ_mn
PI_k = (!cc.q_e/!cc.mt)* oprod_2d(mn3 * s.V,S.V) - ((!cc.mp-!cc.me)/!cc.mt)*JVVJ + mp3me3_m2e*JJ_mn

;epsilon = 0
epsilon   = (!cc.mt/!cc.q_e)*s.rho/s.mn
epsilon3  = [1,1,1] # epsilon
epsilon3x3 = reform([1,1,1] # reform(epsilon3,n_elements(epsilon3)) , [3,3,!cc.dim] )

PP = s.pi + s.pe
PP += (memp_e2) * JJ_mn  ; add in JJ/mn term   ; note this should really be done after the divergence is calculated!
PP -= memp_me * epsilon3x3 * delta_k               ; add in epsilon term
divP = divt_2d(PP , s.r)
ds.V =  (FF-divP) / mn3
for i=0,2 do for j=0,2 do  ds.V[i] -= s.V[j]*partial(s.V[i],s.r,j)


; Probably a great deal of accuracy is lost by calculating delta_k before taking its divergence
; this is not significant if the CM velocity is small

; Ohms law:
ds.J  = (s.E+ cross_prod_2d(s.V,s.B))*mn3 / memp_e2
ds.J -= edm_memp * FF
dP = 0
dP += (!cc.q_e/!cc.mp)*s.Pi
dP -= (!cc.q_e/!cc.me)*s.Pe
dP += delta_k
dP -= epsilon3x3 * PI_k
ds.J -= divt_2d(dP,s.r)

; resistance:  note: not included within the energy terms as it should be!
;ds.J -= !cc.sigma * s.J

; other terms must be added in

ds.Pi = (!cc.q_e/!cc.mp) * stens_cross_prod_2d(s.Pi,s.B)
Vi = s.V
Vi += !cc.me/!cc.q_e* (s.J/mn3)
Vi /=  (1+!cc.me/!cc.mt* epsilon3)   ; epsilon correction

for i=0,2 do  $
  for j=0,2 do  begin
     tmp = 0
     for k=0,2 do  begin          ; J terms added above
        tmp += partial(s.Pi[i,j] * Vi[k,*,*],s.r,k)
        tmp += (s.Pi[k,j]*partial(Vi[i,*,*],s.r,k) +s.Pi[i,k]*partial(Vi[j,*,*],s.r,k) )
     endfor
     ds.Pi[i,j] -=  tmp
  endfor


ds.Pe = (-!cc.q_e/!cc.me) * stens_cross_prod_2d(s.Pe,s.B)
Ve = s.V
Ve -=  !cc.mp/!cc.q_e* (s.J/mn3)
Ve /=  (1-!cc.mp/!cc.mt* epsilon3)   ; epsilon correction

for i=0,2 do  $
  for j=0,2 do  begin
     tmp = 0
     for k=0,2 do  begin          ; J terms added above
        tmp += partial(s.Pe[i,j] * Ve[k,*,*],s.r,k)
        tmp += (s.Pe[k,j]*partial(Ve[i,*,*],s.r,k) +s.Pe[i,k]*partial(Ve[j,*,*],s.r,k) )
     endfor
     ds.Pe[i,j] -=  tmp
  endfor

if keyword_set(debug) then stop
return,ds
end



pro def_constants,dim

defsysv,'!cc',exists=exists
if keyword_set(exists) then begin
  message,/info,'!cc already exists'
  return
endif

mu0 = 4*!dpi*1e-7
C = 2.99792d8        ; m/s
eps0 = 1/C^2/mu0
Mp    = 1.6726d-27   ; kg
Me  = Mp /1836  ; kg
Mt = Mp+Me  ; kg
q_e = 1.6022d-19    ; C
J_ev =  q_e
const={ $
    ndim:n_elements(dim)  $
   ,dim:dim  $
   ,dr:dim*0d $
   ,c:c  $
   ,mu0: mu0  $
   ,eps0 : eps0  $
   ,Mp    : Mp   $
   ,Me  : Me     $
   ,Mt : Mp+Me     $
   ,q_e : q_e  $
   ,sigma:0d   $
   ,diffusion:1d-10   $
   ,nmod: 1  $
   }
defsysv,'!cc',const
end




function define_state,desc

def = {desc2,tag:'',name:'',units0:'',scale:1d,units:'',ndim:-1,dim:[0,0,0]}

scaler = !values.d_nan
for i=0,n_elements(desc)-1 do begin
     desc[i].ndim = total(/pres,desc[i].dim gt 1)    ; make correction if needed
     d = desc[i]
     v = keyword_set(d.ndim) ? replicate(scaler,d.dim > 1) : scaler
     s = keyword_set(s) ?  create_struct(s,d.tag,v) : create_struct(d.tag,v)
endfor

return,s
end




pro diagnostics,S,dgn,d_desc=diag,debug=debug

diag  = [ {desc2,'EPS'     , 'Epsilon'  ,''        ,1d           ,''          , 0, [0,0,0] }  $
         ,{desc2,'eDIV_E'  , 'DEL.E-rho','C/cc'    ,1d-6/!cc.q_e ,'e/cc'      , 0, [0,0,0] }  $
         ,{desc2,'VE'      , 'Ve'       ,'m/s'     ,1d-3         ,'km/s'      , 1, [3,0,0] }  $
         ,{desc2,'VI'      , 'Vi'       ,'m/s'     ,1d-3         ,'km/s'      , 1, [3,0,0] }  $
         ,{desc2,'J_dot_E' , 'J.E'      ,'J/m^3/s' ,1d-6/!cc.q_e ,'eV/cc/s'   , 0, [0,0,0] }  $
         ,{desc2,'JXB'     , 'JxB'      ,'MKS' ,1e-6/!cc.q_e ,'?', 1, [3,0,0] }  $
         ,{desc2,'Se'      , 'Se'       ,'J/m^2/s' ,1d-6/!cc.q_e ,'eV/cc-m/s?', 1, [3,0,0] }  $
         ,{desc2,'Si'      , 'Si'       ,'J/m^2/s' ,1d-6/!cc.q_e ,'eV/cc-m/s?', 1, [3,0,0] }  $
         ,{desc2,'Sf'      , 'Sf'       ,'J/m^2/s' ,1d-6/!cc.q_e ,'eV/cc-m/s?', 1, [3,0,0] }  $
         ,{desc2,'DIV_SF'  , 'DEL.Sf'   ,'J/m^3/s' ,1d-6/!cc.q_e ,'eV/cc/s'   , 0, [0,0,0] }  $
         ,{desc2,'Ee'      , 'E_e'      ,'J/m^3'   ,1d-6/!cc.q_e ,'eV/cc'     , 0, [0,0,0] }  $
         ,{desc2,'Ei'      , 'E_i'      ,'J/m^3'   ,1d-6/!cc.q_e ,'eV/cc'     , 0, [0,0,0] }  $
         ,{desc2,'Ef'      , 'E_f'      ,'J/m^3'   ,1d-6/!cc.q_e ,'eV/cc'     , 0, [0,0,0] }  $
         ,{desc2,'Et'      , 'E_t'      ,'J/m^3'   ,1d-6/!cc.q_e ,'eV/cc'     , 0, [0,0,0] }  $
         ,{desc2,'E_VXB'   , 'E-VxB'    ,'V/m'     ,1d3          ,'mV/m'      , 1, [3,0,0] }  $
         ,{desc2,'J_EN'    , 'J/en'     ,'m/s'     ,1d-3         ,'km/s'      , 1, [3,0,0] }  $
         ,{desc2,'FREQ'    , 'omega'    ,'1/s'     ,1d           ,'1/s'       , 1, [4,0,0] }  $
         ,{desc2,'VTH'     , 'Vth'      ,'m/s'     ,1d-3         ,'km/s'      , 1, [2,0,0] }  $
         ]


if size(dgn,/type) ne 8 then  dgn= replicate(define_state(diag),size(S,/dimen))


mn3 = [1,1,1] # s.mn
J_mn = s.J / mn3
dgn.eps= (!cc.mt/!cc.q_e) * s.rho/s.mn
epsilon3 = [1,1,1] # dgn.eps

N_e = s.mn/!cc.mt * (1- !cc.mp/!cc.mt * dgn.eps)
N_i = s.mn/!cc.mt * (1+ !cc.me/!cc.mt * dgn.eps)
dgn.Ve = (s.V - !cc.mp/!cc.q_e * J_mn)  /   (1-(!cc.mp/!cc.mt)*epsilon3)
dgn.Vi = (s.V + !cc.me/!cc.q_e * J_mn)  /   (1+(!cc.me/!cc.mt)*epsilon3)
dgn.Ee    = (!cc.me * N_e * dot_prod_2d(dgn.Ve,dgn.Ve) + trace_2d(s.Pe))/2
dgn.Ei    = (!cc.mp * N_i * dot_prod_2d(dgn.Vi,dgn.Vi) + trace_2d(s.Pi))/2
Pe_dot_Ve =0
for i=0,2 do Pe_dot_Ve += reform(s.Pe[i,*]) * dgn.Ve
dgn.Se = ([1,1,1] # dgn.Ee)*dgn.Ve + Pe_dot_Ve
Pi_dot_Vi =0
for i=0,2 do Pi_dot_Vi += reform(s.Pi[i,*]) * dgn.Vi
dgn.Si = ([1,1,1] # dgn.Ei)*dgn.Vi + Pi_dot_Vi
dgn.J_dot_E = dot_prod_2d(S.J,S.E)
dgn.JxB   = cross_prod_2d(S.J,S.B)
dgn.Sf     = cross_prod_2d(S.E,S.B)/!cc.mu0
dgn.Div_Sf  = div_2d(dgn.Sf)
dgn.eDiv_E = !cc.eps0 * div_2d(S.E)  - S.rho
dgn.Ef    = dot_prod_2d(S.B,S.B)/(2*!cc.mu0) + dot_prod_2d(S.E,S.E)*(!cc.eps0/2)
;dgn.Div_Ep= div_2d(dgn.Ep)

dgn.E_VxB = s.E + cross_prod_2d(s.V,S.B)
dgn.J_en    = !cc.mt/!cc.q_e * J_mn

Bmag = sqrt(total(s.B*s.B,1))
dgn.freq[0] = !cc.q_e/!cc.me * Bmag
dgn.freq[1] = !cc.q_e/!cc.mp * Bmag
dgn.freq[2] = sqrt(!cc.q_e^2/!cc.me/!cc.eps0 * n_e)
dgn.freq[3] = sqrt(!cc.q_e^2/!cc.mp/!cc.eps0 * n_i)

Te = trace_2d(s.Pe)/n_e / 3
dgn.vth[0] = sqrt(2*Te/!cc.me)
Ti = trace_2d(s.Pi)/n_i / 3
dgn.vth[1] = sqrt(2*Ti/!cc.mp)

dgn.et = dgn.ef + dgn.ee + dgn.ei

if keyword_set(debug) then stop

for i=0,n_tags(dgn)-1 do dgn.(i) *= diag[i].scale

end








function init_state,s_desc=s_desc

help,define_state()

s_desc=[  {desc2,'R'   ,'R'    ,'m'     ,1e-3             ,'km'     , 1   ,[3,0,0] } $
         ,{desc2,'B'   ,'B'    ,'T'     ,1e9              ,'nT'     , 1   ,[3,0,0] } $
         ,{desc2,'E'   ,'E'    ,'V/m'   ,1e3              ,'mV/m'   , 1   ,[3,0,0] } $
         ,{desc2,'RHO' ,'rho'  ,'C/m^3' ,1e-6/!cc.q_e     ,'e/cc'   , 0   ,[0,0,0] } $
         ,{desc2,'J'   ,'J'    ,'A/m^3' ,1e6              ,'uA/m^2' , 1   ,[3,0,0] } $
         ,{desc2,'MN'  ,'n'    ,'Kg/m^3',1e-6/!cc.mt      ,'1/cc'   , 0   ,[0,0,0] } $
         ,{desc2,'V'   ,'V'    ,'m/s'   ,1e-3             ,'km/s'   , 1   ,[3,0,0] } $
         ,{desc2,'PE'  ,'Pe'   ,'J/m^3' ,1e-6/!cc.q_e     ,'eV/cc'  , 2   ,[3,3,0] } $
         ,{desc2,'PI'  ,'Pi'   ,'J/m^3' ,1e-6/!cc.q_e     ,'eV/cc'  , 2   ,[3,3,0] } $
 ]

state = define_state(s_desc)
s=replicate(state,!cc.dim)

L = [500000d]  ; length of box in m

;Initial conditions
!cc.dr = L / !cc.dim
x = dindgen(!cc.dim[0]) * !cc.dr[0]
s.r[0] = x
s.v=0
dens = .049d *1e6
s.mn = !cc.Mt * dens

s.B[0] = 0
s.B[1] = 10e-9 * ( erfc(2*sin(s.r[0]/L[0]*2*!dpi))/2-.1 )
s.B[2] = 0

s.J = curl_2d(s.B,s.r)/ !cc.mu0
s.E = cross_prod_2d(s.B,s.V)  ; + other ohms law terms

s.rho = !cc.eps0* div_2d(s.e,s.r)

jxb = cross_prod_2d(s.J,s.B)
rhoE =  ([1,1,1] # s.rho) * s.E
FF =  JxB  + rhoE

pmag = 0
for i=0,2 do pmag += s.b[i]^2/2/!cc.mu0
pmax = max(pmag)*1.1

pt = pmax - (-s.b[0]^2 + s.b[1]^2 + s.b[2]^2)/2/!cc.mu0 - s.mn * s.v[0]^2

s.pi=0
s.pi[0,0] = pt/2
s.pi[1,1] = pt/2
s.pi[2,2] = pt/2
s.pe = s.pi

;ds = ds_dt(s)
;printdat,ds
; try to force dj/dt to be zero
;s.E -= !cc.mp*!cc.me/!cc.q_e^2 * ds.J/([1,1,1] # s.mn)
;s.rho = !cc.eps0* div_2d(s.e,s.r)
return,s
end





pro plotbox,x,y,_extra=ex
str_element,ex,'ylog',ylog
plot,/nodata,minmax(x),minmax(y,pos=ylog),_extra=ex,ymargin=[1,1];,ystyle=1+2+16
end





pro plot_fft,s,name=name,units=units,scale=scale,plts=plts

nt = n_tags(s)
if not keyword_set(name) then name = tag_names(s)
if not keyword_set(units) then units=replicate('',nt)
if not keyword_set(scale) then scale=replicate(1,nt)
cols0 = 1
cols1 = [2,4,6]
cols2 = [[2,1,3],[1,4,5],[5,3,6]]

if not keyword_set(plts) then plts = indgen(nt-1)+1
nplts = n_elements(plts)
!p.multi = [0,0,nplts,0,1]

x = indgen(n_elements(s)/2)

for p=0,nplts-1 do begin
  v = plts[p]
  ytitle = name[v] + ' [' + units[v] + ']'
  y = s.(v) * scale[v]
  nd = size(/n_dimen,y)-1
  case nd of
    0: y = abs(fft(y))
    1: for j=0,2 do y[j,*] = abs(fft(y[j,*]))
    2: for i=0,2 do for j=0,2 do y[i,j,*]=abs(fft(y[i,j,*]))
  endcase
  plotbox,x,y,ytitle=ytitle,xtitle= p eq (nplts-1) ? xtitle : '',/ylog
  case nd of
    0: oplot,x,y, col=cols0
    1: for j=0,2 do oplot,x,y[j,*],col=cols1[j]
    2: for i=0,2 do for j=0,2 do oplot,x,y[i,j,*],col=cols2[i,j]
  endcase
endfor
end





pro plotvals,s,dsdt,dgn,s_desc=s_desc,dgn_desc=dgn_desc

;printdat,/val,width=300,s[n_elements(s)/2+20],'S'
;printdat,/val,width=300,dsdt[n_elements(s)/2+20],'dS/dt'

device,window_state=windows
cols0 = 1
cols1 = [2,4,6,1,3,5]
cols2 = [[2,1,3],[1,4,5],[5,3,6]]

if windows[0] then begin

name = s_desc.name
units= s_desc.units
scale= s_desc.scale

;if 1 then begin
; name  = ['X' , 'B','E'     ,'rho'        , 'J'    , 'n'        , 'V'  ,  'Pe'      ,  'Pi'  ]
; units = ['km','nT','mV/m'  ,'e/cc'       ,'uA/m^2','1/cc'      , 'm/s',  'eV/cc'   , 'eV/cc']
; scale = [1d-3,1e9 , 1e3    ,1e-6/!cc.q_e , 1e6    ,1e-6/!cc.mt , 1    ,1e-6/!cc.q_e,1e-6/!cc.q_e]
;endif else begin
; name  = ['X' , 'B','E'     ,'rho'        , 'J'   , 'mn'       , 'V'  ,  'Pe'      ,  'Pi'  ]
; units = ['m' , 'T','V/m'   ,'C/m^3'      ,'A/m^2','kg/m^3'    , 'm/s',  'J/m^3'   , 'J/m^3']
; scale = [1d  ,1   , 1      ,1            , 1     ,1           , 1    ,1           ,1           ]
;endelse

tags=tag_names(s)
xtitle = name[0] + ' [' + units[0] + ']'
x = s.r[0] * scale[0]

plts = [ 1,2,4,6,5,3,7,8 ]
;plts = [ 1,2 ]
;print,tags[plts]
nplts = n_elements(plts)

!p.multi = [0,keyword_set(dsdt)+1,nplts,0,1]
wi,0

for p=0,nplts-1 do begin
  v = plts[p]
  ytitle = name[v] + ' [' + units[v] + ']'
  y = s.(v) * scale[v]
  nd = size(/n_dimen,y)-1
  plotbox,x,y,ytitle=ytitle,xtitle= p eq (nplts-1) ? xtitle : ''
  case nd of
  0: oplot,x,y, col=cols0
  1: for j=0,2 do oplot,x,y[j,*],col=cols1[j]
  2: for i=0,2 do for j=0,2 do oplot,x,y[i,j,*],col=cols2[i,j]
  endcase
endfor

for p=0,nplts-1 do begin
  v = plts[p]
  ytitle = 'd'+name[v] + '/dt [' + units[v] + '/s]'
  y = dsdt.(v) * scale[v]
  nd = size(/n_dimen,y)-1
  plotbox,x,y,ytitle=ytitle,xtitle= p eq (nplts-1) ? xtitle : ''
  case nd of
  0: oplot,x,y, col=cols0
  1: for j=0,2 do oplot,x,y[j,*],col=cols1[j]
  2: for i=0,2 do for j=0,2 do oplot,x,y[i,j,*],col=cols2[i,j]
  endcase
endfor
endif


if windows[1] then begin
wi,1
!p.multi = [0,3,nplts,0,0]

for p=0,nplts-1 do begin
  v = plts[p]
  ytitle = 'd'+name[v] + '/dt [' + units[v] + '/s]'
  y = dsdt.(v) * scale[v]
  nd = size(/n_dimen,y)-1
  for i=0,2 do begin
    case nd of
    0: begin
         plotbox,x,y,ytitle=ytitle,xtitle= p eq (nplts-1) ? xtitle : ''
         oplot,x,y, col=cols0
       end
    1: begin
         plotbox,x,y[i,*],ytitle=ytitle,xtitle= p eq (nplts-1) ? xtitle : ''
         oplot,x,y[i,*],col=cols1[i]
       end
    2: begin
         plotbox,x,y[i,*,*],ytitle=ytitle,xtitle= p eq (nplts-1) ? xtitle : ''
         for j=0,2 do oplot,x,y[i,j,*],col=cols2[i,j]
       end
    endcase
  endfor
endfor
endif

if windows[3] then begin
   wi,3
   plot_fft,s,plts=plts
endif


if windows[2] then begin
  wi,2
;  diagnostics,s,dgn

name = tag_names(dgn)
plts = indgen(n_elements(name))
nplts = n_elements(plts)

!p.multi = [0,2,(nplts+1)/2,0,1]
units=replicate('',nplts)
scale= replicate(1,nplts)
for p=0,nplts-1 do begin
  v = plts[p]
  ytitle = name[v] + ' [' + units[v] + ']'
  y = dgn.(v) * scale[v]
  nd = size(/n_dimen,y)-1
  dim = size(/dim,y)
  plotbox,x,y,ytitle=ytitle,xtitle= p eq (nplts-1) ? xtitle : ''
  case nd of
  0: oplot,x,y, col=cols0
  1: for j=0,dim[0]-1 do oplot,x,y[j,*],col=cols1[j]
  2: for i=0,2 do for j=0,2 do oplot,x,y[i,j,*],col=cols2[i,j]
  endcase
endfor
endif

;plotbox,x,s.b *1e9,ytitle='B (nT)'
;for j=0,2 do oplot,x,s.b[j]*1e9,col=cols1[j]
;
;plotbox,x,s.E*1000 ,ytitle='E (mV/m)'
;for i=0,2 do oplot,x,s.E[i]*1000,col=cols1[i]
;
;plotbox,x,(s.mn)/1e6/!cc.mt ,ytitle='n (1/cc)'
;oplot,x,s.mn/1e6/!cc.mt
;
;plotbox,x,(s.rho)/1e6/!cc.q_e ,ytitle='rho (e/cc)'
;oplot,x,s.rho/1e6/!cc.q_e
;
;plotbox,x,(s.V)/1000 ,ytitle='V (km/s)'
;for i=0,2 do oplot,x,s.v[i]/1000,col=cols1[i]
;
;plotbox,x,s.j *1e6,ytitle='J (MKS*1e6)'
;for i=0,2 do oplot,x,s.j[i]*1e6,col=cols1[i]
;
;plotbox,s.r[0],s.Pi*1e11 ,ytitle='Pi (MKS *1e11)'
;for i=0,2 do for j=0,2 do oplot,s.r[0],s.pi[i,j]*1e11,col=cols2[i,j]
;
;plotbox,x,s.FF *1e14,ytitle='JxB+pE (MKS*1e14)'
;for i=0,2 do oplot,x,s.FF[i]*1e14,col=cols[i]
!p.multi = 0

end


pro plot_dgns_data,tt,dgns
   wi,4
   !p.multi =[0,1,4]
   n=n_elements(dgns)
   if n lt 2 then return
   psym = n lt 200 ? -1 : 0
   plot,tt,dgns.et,psym=psym,/ynozero
   plot,tt,dgns.ef,psym=psym,/ynozero
   plot,tt,dgns.ee,psym=psym,/ynozero
   plot,tt,dgns.ei,psym=psym,/ynozero
   !p.multi=0
   wi,5
   !p.multi =[0,1,4]
   n=n_elements(dgns)
   if n lt 2 then return
   psym = n lt 200 ? -1 : 0
   plot,tt[0 > (n-200):*],dgns[0 > (n-200):*].et,psym=psym,/ynozero
   plot,tt[0 > (n-200):*],dgns[0 > (n-200):*].ef,psym=psym,/ynozero
   plot,tt[0 > (n-200):*],dgns[0 > (n-200):*].ee,psym=psym,/ynozero
   plot,tt[0 > (n-200):*],dgns[0 > (n-200):*].ei,psym=psym,/ynozero
   !p.multi=0

end



function del2,s
sm = shift(s,-1)
sp = shift(s,1)
s2 = s
for i=1,n_tags(s)-1 do s2.(i) = (sm.(i) - 2*s.(i) + sp.(i))
s2.r = 0
return,s2
end



pro time_advance_s0,s0,s1,t,dt,n   ,dsdt=dsdt ,del2s=del2s
common time_advance_com,dt_last,b,c
dsdt = ds_dt(s1)
if not keyword_set(s0) then begin
   s0 = s1
   for i=1,n_tags(s1)-1 do s0.(i) = s1.(i) + dt*dsdt.(i)
endif else begin
   del2s = del2(s1)
   for i=1,n_tags(s1)-1 do s0.(i) += 2*dt*dsdt.(i) + !cc.diffusion * del2s.(i)
end
t += dt
n += 1l
dt_last = dt
return
end



; Begin Main
;s=0
if not keyword_set(init) then begin
  def_constants,[500]
  s=init_state(s_desc=s_desc)
  s_a=s
  s_b=0
  dt = min(!cc.dr)/!cc.c  /10
  !y.omargin = [4,2]
  !x.omargin = [1,1]
  ;!y.style = 2+16
  if n_elements(wt) eq 0 then wt=0
  n=0
  t=0d
  dgn = 0
  dgns=0
  tt = 0
  t_ind=0l
  d_ind=0l
  init=1
endif


while wt ge 0 do begin
  time_advance_s0 ,s_b, s_a, t, dt,n, dsdt=dsdt,  del2s=del2s
     diagnostics,s_a,dgn
     dgn_avg = average(dgn)
     append_array,tt,t,ind=t_ind
     append_array,dgns,dgn_avg,index=d_ind
     print,n,t
     if n mod !cc.nmod eq 0 then begin
       plotvals,s_a,dsdt,dgn ,s_desc=s_desc
       plot_dgns_data,tt[0:t_ind-1],dgns[0:d_ind-1]
       if wt eq 0 then stop else wait,wt
     endif
  time_advance_s0 ,s_a, s_b, t, dt,n, dsdt=dsdt,  del2s=del2s
     diagnostics,s_b,dgn
     dgn_avg = average(dgn)
     append_array,tt,t,ind=t_ind
     append_array,dgns,dgn_avg,index=d_ind
     print,n,t
     if n mod !cc.nmod eq 0 then begin
       plotvals,s_b,dsdt,dgn ,s_desc=s_desc
       plot_dgns_data,tt[0:t_ind-1],dgns[0:d_ind-1]
       if wt eq 0 then stop else wait,wt
     endif
endwhile

append_array,tt,ind=t_ind,/done
append_array,dgns,index=d_ind,/done

; save,s,s_a,s_b,tt,dgns,file='plasma2d-.5cc.sav'


end






;dsdt1 = ds_dt(s,t)
;s2 = s
;for i=0,nt-1 do s2.(i) += dt/2*dsdt1.(i)
;dsdt2 = ds_dt(s2,t+dt/2)
;s3 = s
;for i=0,nt-1 do s3.(i) += dt/2*dsdt2.(i)
;dsdt3 = ds_dt(s3,t+dt/2)
;s4 = s
;for i=0,nt-1 do s4.(i) += dt*dsdt3.(i)
;dsdt4 = ds_dt(s4,t+dt)
;for i=0,nt-1 do s.(i) += dt/6*(dsdt1.(i) + 2*dsdt2.(i) + 2*dsdt3.(i) + dsdt4.(i))

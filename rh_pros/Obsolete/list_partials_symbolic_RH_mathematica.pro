; => List of symbolic partial derivatives from mathematica

; => Eq 1.

;=========================================================================================
; => d/dphi 
;=========================================================================================
-(-sth[0]*sph[0]*vel1[1] + cph[0]*sth[0]*vel1[2])*rho1[0] + (-sth[0]*sph[0]*vel2[1] + cph[0]*sth[0]*vel2[2])*rho2[0]


;=========================================================================================
; => d/dthe 
;=========================================================================================
-(-sth[0]*vel1[0] + cth[0]*cph[0]*vel1[1] + cth[0]*sph[0]*vel1[2])*rho1[0] + (-sth[0]*vel2[0] + cth[0]*cph[0]*vel2[1] + cth[0]*sph[0]*vel2[2])*rho2[0]


;=========================================================================================
; => d/dVs 
;=========================================================================================
rho1[0] - rho2[0]




; => Eq 2.

;=========================================================================================
; => d/dphi 
;=========================================================================================
sth[0]*sph[0]*bf1[1] - sth[0]*sph[0]*bf2[1] - cph[0]*sth[0]*bf1[2] + cph[0]*sth[0]*bf2[2]


;=========================================================================================
; => d/dthe 
;=========================================================================================
sth[0]*bf1[0] - sth[0]*bf2[0] - cth[0]*cph[0]*bf1[1] + cth[0]*cph[0]*bf2[1] - cth[0]*sph[0]*bf1[2] + cth[0]*sph[0]*bf2[2]


;=========================================================================================
; => d/dVs 
;=========================================================================================
0




; => Eq 3.

;=========================================================================================
; => d/dphi 
;=========================================================================================
; => X 
sth[0]*(-((*sth[0]*(sph[0]*bf1[1] - cph[0]*bf1[2])*(sth[0]*bf1[0] - cth[0]*(cph[0]*bf1[1] + sph[0]*bf1[2])))/muo) + (*cth[0]*(sph[0]*bf1[1] - cph[0]*bf1[2])*(cth[0]*bf1[0] + sth[0]*(cph[0]*bf1[1] + sph[0]*bf1[2])))/muo + (*sth[0]*(sph[0]*bf2[1] - cph[0]*bf2[2])*(sth[0]*bf2[0] - cth[0]*(cph[0]*bf2[1] + sph[0]*bf2[2])))/muo - (*cth[0]*(sph[0]*bf2[1] - cph[0]*bf2[2])*(cth[0]*bf2[0] + sth[0]*(cph[0]*bf2[1] + sph[0]*bf2[2])))/muo - cth[0]*(sph[0]*vel1[1] - cph[0]*vel1[2])*(-vs[0] + cth[0]*vel1[0] + cph[0]*sth[0]*vel1[1] + sth[0]*sph[0]*vel1[2])*rho1[0] + sth[0]*(sph[0]*vel1[1] - cph[0]*vel1[2])*(sth[0]*vel1[0] - cth[0]*(cph[0]*vel1[1] + sph[0]*vel1[2]))*rho1[0] + cth[0]*(sph[0]*vel2[1] - cph[0]*vel2[2])*(-vs[0] + cth[0]*vel2[0] + cph[0]*sth[0]*vel2[1] + sth[0]*sph[0]*vel2[2])*rho2[0] + sth[0]*(-sph[0]*vel2[1] + cph[0]*vel2[2])*(sth[0]*vel2[0] - cth[0]*(cph[0]*vel2[1] + sph[0]*vel2[2]))*rho2[0])

; => Y 
sth[0]*(-(((sph[0]*bf1[1] - cph[0]*bf1[2])*(-cth[0]*cph[0]*sth[0]*bf1[0] + (cth[0]^2 + sth[0]^2*sph[0]^2)*bf1[1] - cph[0]*sth[0]^2*sph[0]*bf1[2]))/muo) + ((cth[0]*sph[0]*bf1[0] + sth[0]*(s2ph[0]*bf1[1] - c2ph[0]*bf1[2]))*(cth[0]*bf1[0] + sth[0]*(cph[0]*bf1[1] + sph[0]*bf1[2])))/muo + ((sph[0]*bf2[1] - cph[0]*bf2[2])*(-cth[0]*cph[0]*sth[0]*bf2[0] + (cth[0]^2 + sth[0]^2*sph[0]^2)*bf2[1] - cph[0]*sth[0]^2*sph[0]*bf2[2]))/muo - ((cth[0]*sph[0]*bf2[0] + sth[0]*(s2ph[0]*bf2[1] - c2ph[0]*bf2[2]))*(cth[0]*bf2[0] + sth[0]*(cph[0]*bf2[1] + sph[0]*bf2[2])))/muo + (sph[0]*vel1[1] - cph[0]*vel1[2])*(-cth[0]*cph[0]*sth[0]*vel1[0] + (cth[0]^2 + sth[0]^2*sph[0]^2)*vel1[1] - cph[0]*sth[0]^2*sph[0]*vel1[2])*rho1[0] - (-vs[0] + cth[0]*vel1[0] + cph[0]*sth[0]*vel1[1] + sth[0]*sph[0]*vel1[2])*(cth[0]*sph[0]*vel1[0] + sth[0]*(s2ph[0]*vel1[1] - c2ph[0]*vel1[2]))*rho1[0] + (-sph[0]*vel2[1] + cph[0]*vel2[2])*(-cth[0]*cph[0]*sth[0]*vel2[0] + (cth[0]^2 + sth[0]^2*sph[0]^2)*vel2[1] - cph[0]*sth[0]^2*sph[0]*vel2[2])*rho2[0] + (-vs[0] + cth[0]*vel2[0] + cph[0]*sth[0]*vel2[1] + sth[0]*sph[0]*vel2[2])*(cth[0]*sph[0]*vel2[0] + sth[0]*(s2ph[0]*vel2[1] - c2ph[0]*vel2[2]))*rho2[0])

; => Z 
sth[0]*(((sph[0]*bf1[1] - cph[0]*bf1[2])*(cth[0]*sth[0]*sph[0]*bf1[0] + cph[0]*sth[0]^2*sph[0]*bf1[1] - (cth[0]^2 + cph[0]^2*sth[0]^2)*bf1[2]))/muo - ((cth[0]*bf1[0] + sth[0]*(cph[0]*bf1[1] + sph[0]*bf1[2]))*(cth[0]*cph[0]*bf1[0] + sth[0]*(c2ph[0]*bf1[1] + s2ph[0]*bf1[2])))/muo - ((sph[0]*bf2[1] - cph[0]*bf2[2])*(cth[0]*sth[0]*sph[0]*bf2[0] + cph[0]*sth[0]^2*sph[0]*bf2[1] - (cth[0]^2 + cph[0]^2*sth[0]^2)*bf2[2]))/muo + ((cth[0]*bf2[0] + sth[0]*(cph[0]*bf2[1] + sph[0]*bf2[2]))*(cth[0]*cph[0]*bf2[0] + sth[0]*(c2ph[0]*bf2[1] + s2ph[0]*bf2[2])))/muo - (sph[0]*vel1[1] - cph[0]*vel1[2])*(cth[0]*sth[0]*sph[0]*vel1[0] + cph[0]*sth[0]^2*sph[0]*vel1[1] - (cth[0]^2 + cph[0]^2*sth[0]^2)*vel1[2])*rho1[0] + (-vs[0] + cth[0]*vel1[0] + cph[0]*sth[0]*vel1[1] + sth[0]*sph[0]*vel1[2])*(cth[0]*cph[0]*vel1[0] + sth[0]*(c2ph[0]*vel1[1] + s2ph[0]*vel1[2]))*rho1[0] + (sph[0]*vel2[1] - cph[0]*vel2[2])*(cth[0]*sth[0]*sph[0]*vel2[0] + cph[0]*sth[0]^2*sph[0]*vel2[1] - (cth[0]^2 + cph[0]^2*sth[0]^2)*vel2[2])*rho2[0] - (-vs[0] + cth[0]*vel2[0] + cph[0]*sth[0]*vel2[1] + sth[0]*sph[0]*vel2[2])*(cth[0]*cph[0]*vel2[0] + sth[0]*(c2ph[0]*vel2[1] + s2ph[0]*vel2[2]))*rho2[0])

;=========================================================================================
; => d/dthe 
;=========================================================================================
; => X 
((s2th[0]*bf1[0] - c2th[0]*(cph[0]*bf1[1] + sph[0]*bf1[2]))*(cth[0]*bf1[0] + sth[0]*(cph[0]*bf1[1] + sph[0]*bf1[2])))/muo + (*sth[0]*(sth[0]*bf2[0] - cth[0]*(cph[0]*bf2[1] + sph[0]*bf2[2]))^2)/muo + ((-2*cth[0]*sth[0]*bf2[0] + c2th[0]*(cph[0]*bf2[1] + sph[0]*bf2[2]))*(cth[0]*bf2[0] + sth[0]*(cph[0]*bf2[1] + sph[0]*bf2[2])))/muo + sth[0]*(sth[0]*vel1[0] - cth[0]*(cph[0]*vel1[1] + sph[0]*vel1[2]))^2*rho1[0] + (-vs[0] + cth[0]*vel2[0] + cph[0]*sth[0]*vel2[1] + sth[0]*sph[0]*vel2[2])*(s2th[0]*vel2[0] - c2th[0]*(cph[0]*vel2[1] + sph[0]*vel2[2]))*rho2[0] - (*(*sth[0]*(sth[0]*bf1[0] - cth[0]*(cph[0]*bf1[1] + sph[0]*bf1[2]))^2)/muo + (-vs[0] + cth[0]*vel1[0] + cph[0]*sth[0]*vel1[1] + sth[0]*sph[0]*vel1[2])*(s2th[0]*vel1[0] - c2th[0]*(cph[0]*vel1[1] + sph[0]*vel1[2]))*rho1[0] + sth[0]*(sth[0]*vel2[0] - cth[0]*(cph[0]*vel2[1] + sph[0]*vel2[2]))^2*rho2[0]*)


; => Y 
((cth[0]*cph[0]*sth[0]*bf1[0] - (cth[0]^2 + sth[0]^2*sph[0]^2)*bf1[1] + cph[0]*sth[0]^2*sph[0]*bf1[2])*(sth[0]*bf1[0] - cth[0]*(cph[0]*bf1[1] + sph[0]*bf1[2])))/muo + ((cth[0]*cph[0]*sth[0]*bf2[0] - (cth[0]^2 + sth[0]^2*sph[0]^2)*bf2[1] + cph[0]*sth[0]^2*sph[0]*bf2[2])*(-sth[0]*bf2[0] + cth[0]*(cph[0]*bf2[1] + sph[0]*bf2[2])))/muo + (*cph[0]*(cth[0]*bf2[0] + sth[0]*(cph[0]*bf2[1] + sph[0]*bf2[2]))*(c2th[0]*bf2[0] + s2th[0]*(cph[0]*bf2[1] + sph[0]*bf2[2])))/muo + (cth[0]*cph[0]*sth[0]*vel1[0] - (cth[0]^2 + sth[0]^2*sph[0]^2)*vel1[1] + cph[0]*sth[0]^2*sph[0]*vel1[2])*(-sth[0]*vel1[0] + cth[0]*(cph[0]*vel1[1] + sph[0]*vel1[2]))*rho1[0] + cph[0]*(-vs[0] + cth[0]*vel1[0] + cph[0]*sth[0]*vel1[1] + sth[0]*sph[0]*vel1[2])*(c2th[0]*vel1[0] + s2th[0]*(cph[0]*vel1[1] + sph[0]*vel1[2]))*rho1[0] + (-cth[0]*cph[0]*sth[0]*vel2[0] + (cth[0]^2 + sth[0]^2*sph[0]^2)*vel2[1] - cph[0]*sth[0]^2*sph[0]*vel2[2])*(-sth[0]*vel2[0] + cth[0]*(cph[0]*vel2[1] + sph[0]*vel2[2]))*rho2[0] - (*cph[0]*(((cth[0]*bf1[0] + sth[0]*(cph[0]*bf1[1] + sph[0]*bf1[2]))*(c2th[0]*bf1[0] + s2th[0]*(cph[0]*bf1[1] + sph[0]*bf1[2])))/muo + (-vs[0] + cth[0]*vel2[0] + cph[0]*sth[0]*vel2[1] + sth[0]*sph[0]*vel2[2])*(c2th[0]*vel2[0] + s2th[0]*(cph[0]*vel2[1] + sph[0]*vel2[2]))*rho2[0])*)

; => Z 
((cth[0]*sth[0]*sph[0]*bf1[0] + cph[0]*sth[0]^2*sph[0]*bf1[1] - (cth[0]^2 + cph[0]^2*sth[0]^2)*bf1[2])*(sth[0]*bf1[0] - cth[0]*(cph[0]*bf1[1] + sph[0]*bf1[2])))/muo + (*sph[0]*(cth[0]*bf2[0] + sth[0]*(cph[0]*bf2[1] + sph[0]*bf2[2]))*(c2th[0]*bf2[0] + s2th[0]*(cph[0]*bf2[1] + sph[0]*bf2[2])))/muo + sph[0]*(-vs[0] + cth[0]*vel1[0] + cph[0]*sth[0]*vel1[1] + sth[0]*sph[0]*vel1[2])*(c2th[0]*vel1[0] + s2th[0]*(cph[0]*vel1[1] + sph[0]*vel1[2]))*rho1[0] + (-cth[0]*sth[0]*sph[0]*vel2[0] - cph[0]*sth[0]^2*sph[0]*vel2[1] + (cth[0]^2 + cph[0]^2*sth[0]^2)*vel2[2])*(-sth[0]*vel2[0] + cth[0]*(cph[0]*vel2[1] + sph[0]*vel2[2]))*rho2[0] - (*(*sph[0]*(cth[0]*bf1[0] + sth[0]*(cph[0]*bf1[1] + sph[0]*bf1[2]))*(c2th[0]*bf1[0] + s2th[0]*(cph[0]*bf1[1] + sph[0]*bf1[2])))/muo + ((cth[0]*sth[0]*sph[0]*bf2[0] + cph[0]*sth[0]^2*sph[0]*bf2[1] - (cth[0]^2 + cph[0]^2*sth[0]^2)*bf2[2])*(sth[0]*bf2[0] - cth[0]*(cph[0]*bf2[1] + sph[0]*bf2[2])))/muo + (-cth[0]*sth[0]*sph[0]*vel1[0] - cph[0]*sth[0]^2*sph[0]*vel1[1] + (cth[0]^2 + cph[0]^2*sth[0]^2)*vel1[2])*(-sth[0]*vel1[0] + cth[0]*(cph[0]*vel1[1] + sph[0]*vel1[2]))*rho1[0] + sph[0]*(-vs[0] + cth[0]*vel2[0] + cph[0]*sth[0]*vel2[1] + sth[0]*sph[0]*vel2[2])*(c2th[0]*vel2[0] + s2th[0]*(cph[0]*vel2[1] + sph[0]*vel2[2]))*rho2[0]*)

;=========================================================================================
; => d/dVs 
;=========================================================================================
; => X 
sth[0]*(sth[0]*vel1[0]*rho1[0] - cth[0]*cph[0]*vel1[1]*rho1[0] - cth[0]*sph[0]*vel1[2]*rho1[0] - sth[0]*vel2[0]*rho2[0] + cth[0]*cph[0]*vel2[1]*rho2[0] + cth[0]*sph[0]*vel2[2]*rho2[0])

; => Y 
(-cth[0]*cph[0]*sth[0]*vel1[0] + (cth[0]^2 + sth[0]^2*sph[0]^2)*vel1[1] - cph[0]*sth[0]^2*sph[0]*vel1[2])*rho1[0] + (cth[0]*cph[0]*sth[0]*vel2[0] - (cth[0]^2 + sth[0]^2*sph[0]^2)*vel2[1] + cph[0]*sth[0]^2*sph[0]*vel2[2])*rho2[0]

; => Z 
(-cth[0]*sth[0]*sph[0]*vel1[0] - cph[0]*sth[0]^2*sph[0]*vel1[1] + (cth[0]^2 + cph[0]^2*sth[0]^2)*vel1[2])*rho1[0] - (*(-cth[0]*sth[0]*sph[0]*vel2[0] - cph[0]*sth[0]^2*sph[0]*vel2[1] + (cth[0]^2 + cph[0]^2*sth[0]^2)*vel2[2])*rho2[0]*)




; => Eq 4.

;=========================================================================================
; => d/dphi 
;=========================================================================================
; => X 
sth[0]*(sph[0]*bf1[2]*vs[0] - sph[0]*bf2[2]*vs[0] - cth[0]*sph[0]*bf1[2]*vel1[0] + cph[0]*bf1[1]*(vs[0] - cth[0]*vel1[0]) + cth[0]*sph[0]*bf2[2]*vel2[0] - cph[0]*bf2[1]*(vs[0] - cth[0]*vel2[0]) + cth[0]*cph[0]*bf1[0]*vel1[1] - cth[0]*cph[0]*bf2[0]*vel2[1] + cth[0]*sph[0]*bf1[0]*vel1[2] - cth[0]*sph[0]*bf2[0]*vel2[2])

; => Y 
sth[0]*(cph[0]^2*sth[0]*bf1[1]*vel1[0] - sth[0]*sph[0]^2*bf1[1]*vel1[0] + sth[0]*s2ph[0]*bf1[2]*vel1[0] - cph[0]^2*sth[0]*bf2[1]*vel2[0] + sth[0]*sph[0]^2*bf2[1]*vel2[0] - sth[0]*s2ph[0]*bf2[2]*vel2[0] - cth[0]*sph[0]*bf1[2]*vel1[1] + cth[0]*sph[0]*bf2[2]*vel2[1] + cth[0]*sph[0]*bf1[1]*vel1[2] + bf1[0]*(-c2ph[0]*sth[0]*vel1[1] + cph[0]*(vs[0] - 2*sth[0]*sph[0]*vel1[2])) - cth[0]*sph[0]*bf2[1]*vel2[2] + bf2[0]*(-cph[0]*vs[0] + c2ph[0]*sth[0]*vel2[1] + sth[0]*s2ph[0]*vel2[2]))

; => Z 
sth[0]*(-2*cph[0]*sth[0]*sph[0]*bf1[1]*vel1[0] + cph[0]^2*sth[0]*bf1[2]*vel1[0] - sth[0]*sph[0]^2*bf1[2]*vel1[0] + sth[0]*s2ph[0]*bf2[1]*vel2[0] - cph[0]^2*sth[0]*bf2[2]*vel2[0] + sth[0]*sph[0]^2*bf2[2]*vel2[0] - cth[0]*cph[0]*bf1[2]*vel1[1] + cth[0]*cph[0]*bf2[2]*vel2[1] + cth[0]*cph[0]*bf1[1]*vel1[2] - bf1[0]*(sph[0]*vs[0] - 2*cph[0]*sth[0]*sph[0]*vel1[1] + c2ph[0]*sth[0]*vel1[2]) - cth[0]*cph[0]*bf2[1]*vel2[2] + bf2[0]*(sph[0]*vs[0] - 2*cph[0]*sth[0]*sph[0]*vel2[1] + c2ph[0]*sth[0]*vel2[2]))

;=========================================================================================
; => d/dthe 
;=========================================================================================
; => X
cth[0]*cph[0]*bf2[2]*vs[0] + cth[0]^2*cph[0]*bf1[2]*vel1[0] + cph[0]*sth[0]^2*bf2[2]*vel2[0] + cth[0]^2*sph[0]*bf1[0]*vel1[1] + s2th[0]*bf1[2]*vel1[1] + sth[0]^2*sph[0]*bf2[0]*vel2[1] + cph[0]*sth[0]^2*bf1[0]*vel1[2] + bf1[1]*(-c2th[0]*sph[0]*vel1[0] + cth[0]*(sph[0]*vs[0] - 2*sth[0]*vel1[2])) + cth[0]^2*cph[0]*bf2[0]*vel2[2] + bf2[1]*(-cth[0]*sph[0]*vs[0] + c2th[0]*sph[0]*vel2[0] + s2th[0]*vel2[2]) - (*cph[0]*bf1[2]*(cth[0]*vs[0] + sth[0]^2*vel1[0]) + sth[0]^2*sph[0]*bf1[0]*vel1[1] + cth[0]^2*sph[0]*bf2[0]*vel2[1] + bf2[2]*(cth[0]^2*cph[0]*vel2[0] + s2th[0]*vel2[1]) + cth[0]^2*cph[0]*bf1[0]*vel1[2] + cph[0]*sth[0]^2*bf2[0]*vel2[2] )

; => Y 
cth[0]*sth[0]*bf1[2]*vel1[0] + cth[0]*cph[0]^2*sth[0]*bf1[2]*vel1[0] + 2*cth[0]*cph[0]*sth[0]*sph[0]*bf2[1]*vel2[0] + cph[0]*sth[0]^2*bf1[2]*vel1[1] + bf2[2]*(sth[0]*vs[0] + cth[0]*sth[0]*sph[0]^2*vel2[0] + cth[0]^2*cph[0]*vel2[1]) + cth[0]^2*cph[0]*bf1[1]*vel1[2] + cph[0]*sth[0]^2*bf2[1]*vel2[2] + cth[0]*bf2[0]*(sph[0]*vs[0] - 2*cph[0]*sth[0]*sph[0]*vel2[1] + 2*cph[0]^2*sth[0]*vel2[2]) - (*2*cth[0]*cph[0]*sth[0]*sph[0]*bf1[1]*vel1[0] + cth[0]*sth[0]*bf2[2]*vel2[0] + cth[0]*cph[0]^2*sth[0]*bf2[2]*vel2[0] + bf1[2]*(sth[0]*vs[0] + cth[0]*sth[0]*sph[0]^2*vel1[0] + cth[0]^2*cph[0]*vel1[1]) + cph[0]*sth[0]^2*bf2[2]*vel2[1] + cph[0]*sth[0]^2*bf1[1]*vel1[2] + cth[0]*bf1[0]*(sph[0]*vs[0] - 2*cph[0]*sth[0]*sph[0]*vel1[1] + 2*cph[0]^2*sth[0]*vel1[2]) + cth[0]^2*cph[0]*bf2[1]*vel2[2] )

; => Z 
2*cth[0]*cph[0]*sth[0]*sph[0]*bf1[2]*vel1[0] + cth[0]*sth[0]*bf2[1]*vel2[0] + cth[0]*sth[0]*sph[0]^2*bf2[1]*vel2[0] + sth[0]^2*sph[0]*bf1[2]*vel1[1] + cth[0]^2*sph[0]*bf2[2]*vel2[1] + bf1[1]*(sth[0]*vs[0] + cth[0]*cph[0]^2*sth[0]*vel1[0] + cth[0]^2*sph[0]*vel1[2]) + cth[0]*bf1[0]*(2*sth[0]*sph[0]^2*vel1[1] + cph[0]*(vs[0] - 2*sth[0]*sph[0]*vel1[2])) + sth[0]^2*sph[0]*bf2[1]*vel2[2] - (*cth[0]*sth[0]*bf1[1]*vel1[0] + cth[0]*sth[0]*sph[0]^2*bf1[1]*vel1[0] + 2*cth[0]*cph[0]*sth[0]*sph[0]*bf2[2]*vel2[0] + cth[0]^2*sph[0]*bf1[2]*vel1[1] + sth[0]^2*sph[0]*bf2[2]*vel2[1] + sth[0]^2*sph[0]*bf1[1]*vel1[2] + bf2[1]*(sth[0]*vs[0] + cth[0]*cph[0]^2*sth[0]*vel2[0] + cth[0]^2*sph[0]*vel2[2]) + cth[0]*bf2[0]*(2*sth[0]*sph[0]^2*vel2[1] + cph[0]*(vs[0] - 2*sth[0]*sph[0]*vel2[2])) )

;=========================================================================================
; => d/dVs
;=========================================================================================
; => X 
sth[0]*(sph[0]*bf1[1] - sph[0]*bf2[1] + cph[0]*(-bf1[2] + bf2[2]))

; => Y 
sth[0]*sph[0]*bf1[0] + cth[0]*(-bf1[2] + bf2[2]) - (sth[0]*sph[0]*bf2[0])

; => Z 
cph[0]*sth[0]*bf1[0] + cth[0]*(-bf1[1] + bf2[1]) - (cph[0]*sth[0]*bf2[0])




; => Eq 5.

;=========================================================================================
; => d/dphi
;=========================================================================================

(1/muo)*sth[0]*(-cph[0]*sth[0]*sph[0]*bf1[1]^2 + cth[0]*sph[0]*bf2[0]*bf2[1] + cph[0]*sth[0]*sph[0]*bf2[1]^2 + c2ph[0]*sth[0]*bf1[1]*bf1[2] + cph[0]*sth[0]*sph[0]*bf1[2]^2 - cth[0]*bf1[0]*(sph[0]*bf1[1] - cph[0]*bf1[2]) - cth[0]*cph[0]*bf2[0]*bf2[2] - cph[0]^2*sth[0]*bf2[1]*bf2[2] + sth[0]*sph[0]^2*bf2[1]*bf2[2] - cph[0]*sth[0]*sph[0]*bf2[2]^2 - 2*sph[0]*vs[0]*vel1[1]*muo*rho1[0] + 2*cth[0]*sph[0]*vel1[0]*vel1[1]*muo*rho1[0] + sth[0]*s2ph[0]*vel1[1]^2*muo*rho1[0] + 2*cph[0]*vs[0]*vel1[2]*muo*rho1[0] - 2*cth[0]*cph[0]*vel1[0]*vel1[2]*muo*rho1[0] - 2*cph[0]^2*sth[0]*vel1[1]*vel1[2]*muo*rho1[0] + 2*sth[0]*sph[0]^2*vel1[1]*vel1[2]*muo*rho1[0] - 2*cph[0]*sth[0]*sph[0]*vel1[2]^2*muo*rho1[0] + 2*sph[0]*vs[0]*vel2[1]*muo*rho2[0] - 2*cth[0]*sph[0]*vel2[0]*vel2[1]*muo*rho2[0] - 2*cph[0]*sth[0]*sph[0]*vel2[1]^2*muo*rho2[0] - 2*cph[0]*vs[0]*vel2[2]*muo*rho2[0] + 2*cth[0]*cph[0]*vel2[0]*vel2[2]*muo*rho2[0] + 2*cph[0]^2*sth[0]*vel2[1]*vel2[2]*muo*rho2[0] - 2*sth[0]*sph[0]^2*vel2[1]*vel2[2]*muo*rho2[0] + sth[0]*s2ph[0]*vel2[2]^2*muo*rho2[0])*


;=========================================================================================
; => d/dthe
;=========================================================================================

1/2*((-2*cth[0]*sth[0]*bf1[0]^2 + 2*c2th[0]*bf1[0]*(cph[0]*bf1[1] + sph[0]*bf1[2]) + s2th[0]*(cph[0]*bf1[1] + sph[0]*bf1[2])^2)/muo + ( s2th[0]*bf2[0]^2 - 2*c2th[0]*bf2[0]*(cph[0]*bf2[1] + sph[0]*bf2[2]) - s2th[0]*(cph[0]*bf2[1] + sph[0]*bf2[2])^2)/muo - 4*(-vs[0] + cth[0]*vel1[0] + cph[0]*sth[0]*vel1[1] + sth[0]*sph[0]*vel1[2])*(-sth[0]*vel1[0] + cth[0]*(cph[0]*vel1[1] + sph[0]*vel1[2]))*rho1[0] + 4*(-vs[0] + cth[0]*vel2[0] + cph[0]*sth[0]*vel2[1] + sth[0]*sph[0]*vel2[2])*(-sth[0]*vel2[0] + cth[0]*(cph[0]*vel2[1] + sph[0]*vel2[2]))*rho2[0])*


;=========================================================================================
; => d/dVs
;=========================================================================================

2*(-vs[0] + cth[0]*vel1[0] + cph[0]*sth[0]*vel1[1] + sth[0]*sph[0]*vel1[2])*rho1[0] - ( 2*(-vs[0] + cth[0]*vel2[0] + cph[0]*sth[0]*vel2[1] + sth[0]*sph[0]*vel2[2])*rho2[0] )




; => Eq 6.

;=========================================================================================
; => d/dphi
;=========================================================================================

sth[0]*(((sph[0]*bf1[1] - cph[0]*bf1[2])*(cth[0]*bf1[0] + sth[0]*(cph[0]*bf1[1] + sph[0]*bf1[2]))*vs[0])/*muo - ((sph[0]*bf2[1] - cph[0]*bf2[2])*(cth[0]*bf2[0] + sth[0]*(cph[0]*bf2[1] + sph[0]*bf2[2]))*vs[0])/*muo + ((-sph[0]*bf1[1] + cph[0]*bf1[2])*(bf1[0]*(-cth[0]*vs[0] + vel1[0]) + bf1[1]*(-cph[0]*sth[0]*vs[0] + vel1[1]) + bf1[2]*(-sth[0]*sph[0]*vs[0] + vel1[2])))/muo - ((-sph[0]*bf2[1] + cph[0]*bf2[2])*(bf2[0]*(-cth[0]*vs[0] + vel2[0]) + bf2[1]*(-cph[0]*sth[0]*vs[0] + vel2[1]) + bf2[2]*(-sth[0]*sph[0]*vs[0] + vel2[2])))/muo + vs[0]*(sph[0]*vel1[1] - cph[0]*vel1[2])*(vs[0] - cth[0]*vel1[0] - cph[0]*sth[0]*vel1[1] - sth[0]*sph[0]*vel1[2])*rho1[0] - (-sph[0]*vel1[1] + cph[0]*vel1[2])*(1/*2*((-cth[0]*vs[0] + vel1[0])^2 + (-cph[0]*sth[0]*vs[0] + vel1[1])^2 + (-sth[0]*sph[0]*vs[0] + vel1[2])^2) + gfactor[0]*press1[0]*rho1[0]) + bf1[0]^2 + bf1[1]^2 + bf1[2]^2\))/( muo*rho1[0]))*rho1[0] + vs[0]*(-sph[0]*vel2[1] + cph[0]*vel2[2])*(vs[0] - cth[0]*vel2[0] - cph[0]*sth[0]*vel2[1] - sth[0]*sph[0]*vel2[2])*rho2[0] + (-sph[0]*vel2[1] + cph[0]*vel2[2])*(1/*2*((-cth[0]*vs[0] + vel2[0])^2 + (-cph[0]*sth[0]*vs[0] + vel2[1])^2 + (-sth[0]*sph[0]*vs[0] + vel2[2])^2) + gfactor[0]*press2[0]*rho2[0]) + bf2[0]^2 + bf2[1]^2 + bf2[2]^2\))/( muo*rho2[0]))*rho2[0])


;=========================================================================================
; => d/dthe
;=========================================================================================

((sth[0]*bf1[0] - cth[0]*(cph[0]*bf1[1] + sph[0]*bf1[2]))*(cth[0]*bf1[0] + sth[0]*(cph[0]*bf1[1] + sph[0]*bf1[2]))*vs[0])/*muo + ((-sth[0]*bf1[0] + cth[0]*(cph[0]*bf1[1] + sph[0]*bf1[2]))*(bf1[0]*(-cth[0]*vs[0] + vel1[0]) + bf1[1]*(-cph[0]*sth[0]*vs[0] + vel1[1]) + bf1[2]*(-sth[0]*sph[0]*vs[0] + vel1[2])))/muo + vs[0]*(-vs[0] + cth[0]*vel2[0] + cph[0]*sth[0]*vel2[1] + sth[0]*sph[0]*vel2[2])*(sth[0]*vel2[0] - cth[0]*(cph[0]*vel2[1] + sph[0]*vel2[2]))*rho2[0] + (-sth[0]*vel2[0] + cth[0]*(cph[0]*vel2[1] + sph[0]*vel2[2]))*(1/*2*((-cth[0]*vs[0] + vel2[0])^2 + (-cph[0]*sth[0]*vs[0] + vel2[1])^2 + (-sth[0]*sph[0]*vs[0] + vel2[2])^2) + gfactor[0]*press2[0]*rho2[0]) + bf2[0]^2 + bf2[1]^2 + bf2[2]^2\))/( muo*rho2[0]))*rho2[0] - ( ((sth[0]*bf2[0] - cth[0]*(cph[0]*bf2[1] + sph[0]*bf2[2]))*(cth[0]*bf2[0] + sth[0]*(cph[0]*bf2[1] + sph[0]*bf2[2]))*vs[0])/*muo + ((-sth[0]*bf2[0] + cth[0]*(cph[0]*bf2[1] + sph[0]*bf2[2]))*(bf2[0]*(-cth[0]*vs[0] + vel2[0]) + bf2[1]*(-cph[0]*sth[0]*vs[0] + vel2[1]) + bf2[2]*(-sth[0]*sph[0]*vs[0] + vel2[2])))/muo + vs[0]*(-vs[0] + cth[0]*vel1[0] + cph[0]*sth[0]*vel1[1] + sth[0]*sph[0]*vel1[2])*(sth[0]*vel1[0] - cth[0]*(cph[0]*vel1[1] + sph[0]*vel1[2]))*rho1[0] + (-sth[0]*vel1[0] + cth[0]*(cph[0]*vel1[1] + sph[0]*vel1[2]))*(1/*2*((-cth[0]*vs[0] + vel1[0])^2 + (-cph[0]*sth[0]*vs[0] + vel1[1])^2 + (-sth[0]*sph[0]*vs[0] + vel1[2])^2) + gfactor[0]*press1[0]*rho1[0]) + bf1[0]^2 + bf1[1]^2 + bf1[2]^2\))/( muo*rho1[0]))*rho1[0] )


;=========================================================================================
; => d/dVs
;=========================================================================================

(cth[0]*bf2[0] + sth[0]*(cph[0]*bf2[1] + sph[0]*bf2[2]))^2/muo + (-vs[0] + cth[0]*vel1[0] + cph[0]*sth[0]*vel1[1] + sth[0]*sph[0]*vel1[2])^2*rho1[0] + (1/2*((-cth[0]*vs[0] + vel1[0])^2 + (-cph[0]*sth[0]*vs[0] + vel1[1])^2 + (-sth[0]*sph[0]*vs[0] + vel1[2])^2) + gfactor[0]*press1[0]*rho1[0]) + bf1[0]^2 + bf1[1]^2 + bf1[2]^2\))/( muo*rho1[0]))*rho1[0] - ( (cth[0]*bf1[0] + sth[0]*(cph[0]*bf1[1] + sph[0]*bf1[2]))^2/muo + (-vs[0] + cth[0]*vel2[0] + cph[0]*sth[0]*vel2[1] + sth[0]*sph[0]*vel2[2])^2*rho2[0] + (1/2*((-cth[0]*vs[0] + vel2[0])^2 + (-cph[0]*sth[0]*vs[0] + vel2[1])^2 + (-sth[0]*sph[0]*vs[0] + vel2[2])^2) + gfactor[0]*press2[0]*rho2[0]) + bf2[0]^2 + bf2[1]^2 + bf2[2]^2\))/( muo*rho2[0]))*rho2[0] )












;=========================================================================================
; => d/dphi
;=========================================================================================
; => X
csph    = [cph[0],sph[0]]
scph    = [sph[0],cph[0]]
scth    = [sth[0],cth[0]]
csth    = REVERSE(scth)
c2cth   = [c2th[0],cth[0]]
s2c2ph  = [s2ph[0],c2ph[0]]
c2s2ph  = REVERSE(s2c2ph)
term01v = dot_2d_2n_add(csph,vel1[1:2])          ; =(cph[0]*vel1[1] + sph[0]*vel1[2])
term02v = dot_2d_2n_add(csph,vel2[1:2])          ; =(cph[0]*vel2[1] + sph[0]*vel2[2])
term01b = dot_2d_2n_add(csph,bf1[1:2])           ; =(cph[0]*bf1[1] + sph[0]*bf1[2])
term02b = dot_2d_2n_add(csph,bf2[1:2])           ; =(cph[0]*bf2[1] + sph[0]*bf2[2])
term11v = dot_2d_2n_sub(scph,vel1[1:2])          ; =(sph[0]*vel1[1] - cph[0]*vel1[2])
term12v = dot_2d_2n_sub(scph,vel2[1:2])          ; =(sph[0]*vel2[1] - cph[0]*vel2[2])
term11b = dot_2d_2n_sub(scph,bf1[1:2])           ; =(sph[0]*bf1[1] - cph[0]*bf1[2])
term12b = dot_2d_2n_sub(scph,bf2[1:2])           ; =(sph[0]*bf2[1] - cph[0]*bf2[2])
term21v = dot_2d_2n_sub(s2c2ph,vel1[1:2])        ; =(s2ph[0]*vel1[1] - c2ph[0]*vel1[2])
term22v = dot_2d_2n_sub(s2c2ph,vel2[1:2])        ; =(s2ph[0]*vel2[1] - c2ph[0]*vel2[2])
term21b = dot_2d_2n_sub(s2c2ph,bf1[1:2])         ; =(s2ph[0]*bf1[1] - c2ph[0]*bf1[2])
term22b = dot_2d_2n_sub(s2c2ph,bf2[1:2])         ; =(s2ph[0]*bf2[1] - c2ph[0]*bf2[2])
term31v = dot_2d_2n_sub(c2s2ph,vel1[1:2])        ; =(c2ph[0]*vel1[1] + s2ph[0]*vel1[2])
term32v = dot_2d_2n_sub(c2s2ph,vel2[1:2])        ; =(c2ph[0]*vel2[1] + s2ph[0]*vel2[2])
term31b = dot_2d_2n_sub(c2s2ph,bf1[1:2])         ; =(c2ph[0]*bf1[1] + s2ph[0]*bf1[2])
term32b = dot_2d_2n_sub(c2s2ph,bf2[1:2])         ; =(c2ph[0]*bf2[1] + s2ph[0]*bf2[2])
term41b = dot_2d_2n_sub(scth,[bf1[0],term01b])   ; =(sth[0]*bf1[0] - cth[0]*term01b)
term42b = dot_2d_2n_sub(scth,[bf2[0],term02b])   ; =(sth[0]*bf2[0] - cth[0]*term02b)
term41v = dot_2d_2n_sub(scth,[vel1[0],term01v])  ; =(sth[0]*vel1[0] - cth[0]*term01v)
term42v = dot_2d_2n_sub(scth,[vel2[0],term02v])  ; =(sth[0]*vel1[0] - cth[0]*term02v)
term51b = dot_2d_2n_add(csth,[bf1[0],term01b])   ; =(cth[0]*bf1[0] + sth[0]*term01b)
term52b = dot_2d_2n_add(csth,[bf2[0],term02b])   ; =(cth[0]*bf2[0] + sth[0]*term02b)

term01s = (cth[0]*vel1[0] - vs[0])
term02s = (cth[0]*vel2[0] - vs[0])

term11s = (term01s + term01v*sth[0])



ctsp       = cth[0]*sph[0]
ctcp       = cth[0]*cph[0]
cpst       = cph[0]*sth[0]
stsp       = sth[0]*sph[0]
ctstsp     = cth[0]*stsp[0]
ctcpst     = cth[0]*cpst[0]
cpst2sp    = cph[0]*sth2[0]*sph[0]
ct2st2sp2  = (cth2[0] + sth2[0]*sph2[0])
ct2cp2st2  = (cth2[0] + cph2[0]*sth2[0])



term0    = term31*(c2th[0]*bf1[0] + s2th[0]*term41)
term1    = term32*(c2th[0]*bf2[0] + s2th[0]*term42)
term2    = -1d0*(term11)*(term21 + term01)*rho1[0]
term3    =  1d0*(term12)*(term22 + term02)*rho2[0]
df_dphix = sth[0]*((term0 - term1)/muo + term2 + term3)


; => X 
sth[0]*((cth[0]*term11b*term51b + sth[0]*term12b*term42b - cth[0]*term12b*term52b - sth[0]*term11b*term41b)/muo + (sth[0]*term11v*term41v - cth[0]*term11v*term11s)*rho1[0] + (cth[0]*term12v*(term02s + cpst[0]*vel2[1] + stsp[0]*vel2[2]) - sth[0]*term12v*term42v)*rho2[0])

; => Y 
sth[0]*(((ctsp[0]*bf1[0] + sth[0]*term21b)*term51b - term11b*(ct2st2sp2[0]*bf1[1] - ctcpst[0]*bf1[0] - cpst2sp[0]*bf1[2]) + term12b*(ct2st2sp2[0]*bf2[1] - ctcpst[0]*bf2[0] - cpst2sp[0]*bf2[2]) - (ctsp[0]*bf2[0] + sth[0]*term22b)*term52b)/muo + (term11v*(ct2st2sp2[0]*vel1[1] - ctcpst[0]*vel1[0] - cpst2sp[0]*vel1[2]) - term11s*(ctsp[0]*vel1[0] + sth[0]*term21v))*rho1[0] + ((term02s + cpst[0]*vel2[1] + stsp[0]*vel2[2])*(ctsp[0]*vel2[0] + sth[0]*term22v)  - term12v*(ct2st2sp2[0]*vel2[1] - ctcpst[0]*vel2[0] - cpst2sp[0]*vel2[2]))*rho2[0])

; => Z 
sth[0]*( ( term11b*(ctstsp[0]*bf1[0] + cpst2sp[0]*bf1[1] - ct2cp2st2[0]*bf1[2]) - term51b*(ctcp[0]*bf1[0] + sth[0]*term31b) - term12b*(ctstsp[0]*bf2[0] + cpst2sp[0]*bf2[1] - ct2cp2st2[0]*bf2[2]) + term52b*(ctcp[0]*bf2[0] + sth[0]*term32b) )/muo + (term11s*(ctcp[0]*vel1[0] + sth[0]*term31v) - term11v*(ctstsp[0]*vel1[0] + cpst2sp[0]*vel1[1] - ct2cp2st2[0]*vel1[2]))*rho1[0] + (term12v*(ctstsp[0]*vel2[0] + cpst2sp[0]*vel2[1] - ct2cp2st2[0]*vel2[2]) - (term02s + cpst[0]*vel2[1] + stsp[0]*vel2[2])*(ctcp[0]*vel2[0] + sth[0]*term32v))*rho2[0])


;=========================================================================================
; => d/dthe
;=========================================================================================
; => X 
((s2th[0]*bf1[0] - c2th[0]*term01b)*(cth[0]*bf1[0] + sth[0]*term01b))/muo + ( sth[0]*(sth[0]*bf2[0] - cth[0]*term02b)^2)/muo + ( (c2th[0]*term02b - 2*cth[0]*sth[0]*bf2[0] )*(cth[0]*bf2[0] + sth[0]*term02b))/muo + sth[0]*(sth[0]*vel1[0] - cth[0]*term01v)^2*rho1[0] + (term02s + cph[0]*sth[0]*vel2[1] + sth[0]*sph[0]*vel2[2])*(s2th[0]*vel2[0] - c2th[0]*term02v)*rho2[0] - ( ( sth[0]*(sth[0]*bf1[0] - cth[0]*term01b)^2)/muo + (term01s + cph[0]*sth[0]*vel1[1] + sth[0]*sph[0]*vel1[2])*(s2th[0]*vel1[0] - c2th[0]*term01v)*rho1[0] + sth[0]*(sth[0]*vel2[0] - cth[0]*term02v)^2*rho2[0])


; => Y 
((cth[0]*cph[0]*sth[0]*bf1[0] - (cth2[0] + sth2[0]*sph2[0])*bf1[1] + cpst2sp[0]*bf1[2])*(sth[0]*bf1[0] - cth[0]*term01b))/muo + ((cth[0]*cph[0]*sth[0]*bf2[0] - (cth2[0] + sth2[0]*sph2[0])*bf2[1] + cpst2sp[0]*bf2[2])*(cth[0]*term02b - sth[0]*bf2[0] ))/muo + ( cph[0]*(cth[0]*bf2[0] + sth[0]*term02b)*(c2th[0]*bf2[0] + s2th[0]*term02b))/muo + (cth[0]*cph[0]*sth[0]*vel1[0] - (cth2[0] + sth2[0]*sph2[0])*vel1[1] + cpst2sp[0]*vel1[2])*( cth[0]*term01v - sth[0]*vel1[0] )*rho1[0] + cph[0]*(term01s + cph[0]*sth[0]*vel1[1] + sth[0]*sph[0]*vel1[2])*(c2th[0]*vel1[0] + s2th[0]*term01v)*rho1[0] + ( (cth2[0] + sth2[0]*sph2[0])*vel2[1] - cth[0]*cph[0]*sth[0]*vel2[0] - cpst2sp[0]*vel2[2] )*( cth[0]*term02v - sth[0]*vel2[0] )*rho2[0] - ( cph[0]*(((cth[0]*bf1[0] + sth[0]*term01b)*(c2th[0]*bf1[0] + s2th[0]*term01b))/muo + (term02s + cph[0]*sth[0]*vel2[1] + sth[0]*sph[0]*vel2[2])*(c2th[0]*vel2[0] + s2th[0]*term02v)*rho2[0]))

; => Z 
((cth[0]*sth[0]*sph[0]*bf1[0] + cpst2sp[0]*bf1[1] - (cth2[0] + cph2[0]*sth2[0])*bf1[2])*(sth[0]*bf1[0] - cth[0]*term01b))/muo + ( sph[0]*(cth[0]*bf2[0] + sth[0]*term02b)*(c2th[0]*bf2[0] + s2th[0]*term02b))/muo + sph[0]*(term01s + cph[0]*sth[0]*vel1[1] + sth[0]*sph[0]*vel1[2])*(c2th[0]*vel1[0] + s2th[0]*term01v)*rho1[0] + ( (cth2[0] + cph2[0]*sth2[0])*vel2[2] - cth[0]*sth[0]*sph[0]*vel2[0] - cpst2sp[0]*vel2[1] )*( cth[0]*term02v - sth[0]*vel2[0] )*rho2[0] - ( ( sph[0]*(cth[0]*bf1[0] + sth[0]*term01b)*(c2th[0]*bf1[0] + s2th[0]*term01b))/muo + ((cth[0]*sth[0]*sph[0]*bf2[0] + cpst2sp[0]*bf2[1] - (cth2[0] + cph2[0]*sth2[0])*bf2[2])*(sth[0]*bf2[0] - cth[0]*term02b))/muo + ( (cth2[0] + cph2[0]*sth2[0])*vel1[2] - cth[0]*sth[0]*sph[0]*vel1[0] - cpst2sp[0]*vel1[1] )*( cth[0]*term01v - sth[0]*vel1[0] )*rho1[0] + sph[0]*(term02s + cph[0]*sth[0]*vel2[1] + sth[0]*sph[0]*vel2[2])*(c2th[0]*vel2[0] + s2th[0]*term02v)*rho2[0])

;=========================================================================================
; => d/dVs
;=========================================================================================
; => X
sth[0]*((sth[0]*vel1[0] - ctcp[0]*vel1[1] - ctsp[0]*vel1[2])*rho1[0] - (sth[0]*vel2[0] - ctcp[0]*vel2[1] - ctsp[0]*vel2[2])*rho2[0])

; => Y
(ct2st2sp2[0]*vel1[1] - ctcpst[0]*vel1[0] - cpst2sp[0]*vel1[2])*rho1[0] + (ctcpst[0]*vel2[0] - ct2st2sp2[0]*vel2[1] + cpst2sp[0]*vel2[2])*rho2[0]

; => Z
(ct2cp2st2[0]*vel1[2] - ctstsp[0]*vel1[0] - cpst2sp[0]*vel1[1])*rho1[0] - ((ct2cp2st2[0]*vel2[2] - ctstsp[0]*vel2[0] - cpst2sp[0]*vel2[1])*rho2[0])












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


    term0           = 
    term1           = 
    df_dphix        = 
    term0           = 
    term1           = 
    df_dphiy        = 
    term0           = 
    term1           = 
    df_dphiz        = 

;=========================================================================================
; => d/dthe 
;=========================================================================================
; => X
cth[0]*cph[0]*bf2[2]*vs[0] + cth[0]^2*cph[0]*bf1[2]*vel1[0] + cph[0]*sth[0]^2*bf2[2]*vel2[0] + cth[0]^2*sph[0]*bf1[0]*vel1[1] + s2th[0]*bf1[2]*vel1[1] + sth[0]^2*sph[0]*bf2[0]*vel2[1] + cph[0]*sth[0]^2*bf1[0]*vel1[2] + bf1[1]*(-c2th[0]*sph[0]*vel1[0] + cth[0]*(sph[0]*vs[0] - 2*sth[0]*vel1[2])) + cth[0]^2*cph[0]*bf2[0]*vel2[2] + bf2[1]*(-cth[0]*sph[0]*vs[0] + c2th[0]*sph[0]*vel2[0] + s2th[0]*vel2[2]) - (*cph[0]*bf1[2]*(cth[0]*vs[0] + sth[0]^2*vel1[0]) + sth[0]^2*sph[0]*bf1[0]*vel1[1] + cth[0]^2*sph[0]*bf2[0]*vel2[1] + bf2[2]*(cth[0]^2*cph[0]*vel2[0] + s2th[0]*vel2[1]) + cth[0]^2*cph[0]*bf1[0]*vel1[2] + cph[0]*sth[0]^2*bf2[0]*vel2[2] )

; => Y 
cth[0]*sth[0]*bf1[2]*vel1[0] + cth[0]*cph[0]^2*sth[0]*bf1[2]*vel1[0] + 2*cth[0]*cph[0]*sth[0]*sph[0]*bf2[1]*vel2[0] + cph[0]*sth[0]^2*bf1[2]*vel1[1] + bf2[2]*(sth[0]*vs[0] + cth[0]*sth[0]*sph[0]^2*vel2[0] + cth[0]^2*cph[0]*vel2[1]) + cth[0]^2*cph[0]*bf1[1]*vel1[2] + cph[0]*sth[0]^2*bf2[1]*vel2[2] + cth[0]*bf2[0]*(sph[0]*vs[0] - 2*cph[0]*sth[0]*sph[0]*vel2[1] + 2*cph[0]^2*sth[0]*vel2[2]) - (*2*cth[0]*cph[0]*sth[0]*sph[0]*bf1[1]*vel1[0] + cth[0]*sth[0]*bf2[2]*vel2[0] + cth[0]*cph[0]^2*sth[0]*bf2[2]*vel2[0] + bf1[2]*(sth[0]*vs[0] + cth[0]*sth[0]*sph[0]^2*vel1[0] + cth[0]^2*cph[0]*vel1[1]) + cph[0]*sth[0]^2*bf2[2]*vel2[1] + cph[0]*sth[0]^2*bf1[1]*vel1[2] + cth[0]*bf1[0]*(sph[0]*vs[0] - 2*cph[0]*sth[0]*sph[0]*vel1[1] + 2*cph[0]^2*sth[0]*vel1[2]) + cth[0]^2*cph[0]*bf2[1]*vel2[2] )

; => Z 
2*cth[0]*cph[0]*sth[0]*sph[0]*bf1[2]*vel1[0] + cth[0]*sth[0]*bf2[1]*vel2[0] + cth[0]*sth[0]*sph[0]^2*bf2[1]*vel2[0] + sth[0]^2*sph[0]*bf1[2]*vel1[1] + cth[0]^2*sph[0]*bf2[2]*vel2[1] + bf1[1]*(sth[0]*vs[0] + cth[0]*cph[0]^2*sth[0]*vel1[0] + cth[0]^2*sph[0]*vel1[2]) + cth[0]*bf1[0]*(2*sth[0]*sph[0]^2*vel1[1] + cph[0]*(vs[0] - 2*sth[0]*sph[0]*vel1[2])) + sth[0]^2*sph[0]*bf2[1]*vel2[2] - (*cth[0]*sth[0]*bf1[1]*vel1[0] + cth[0]*sth[0]*sph[0]^2*bf1[1]*vel1[0] + 2*cth[0]*cph[0]*sth[0]*sph[0]*bf2[2]*vel2[0] + cth[0]^2*sph[0]*bf1[2]*vel1[1] + sth[0]^2*sph[0]*bf2[2]*vel2[1] + sth[0]^2*sph[0]*bf1[1]*vel1[2] + bf2[1]*(sth[0]*vs[0] + cth[0]*cph[0]^2*sth[0]*vel2[0] + cth[0]^2*sph[0]*vel2[2]) + cth[0]*bf2[0]*(2*sth[0]*sph[0]^2*vel2[1] + cph[0]*(vs[0] - 2*sth[0]*sph[0]*vel2[2])) )

    term0           = 
    term1           = 
    df_dthex        = 
    term0           = 
    term1           = 
    df_dthey        = 
    term0           = 
    term1           = 
    df_dthez        = 

;=========================================================================================
; => d/dVs
;=========================================================================================
; => X 
sth[0]*(sph[0]*bf1[1] - sph[0]*bf2[1] + cph[0]*(-bf1[2] + bf2[2]))

; => Y 
sth[0]*sph[0]*bf1[0] + cth[0]*(-bf1[2] + bf2[2]) - (sth[0]*sph[0]*bf2[0])

; => Z 
cph[0]*sth[0]*bf1[0] + cth[0]*(-bf1[1] + bf2[1]) - (cph[0]*sth[0]*bf2[0])


    term0           = 
    term1           = 
    df_dvshx        = 
    term0           = 
    term1           = 
    df_dvshy        = 
    term0           = 
    term1           = 
    df_dvshz        = 







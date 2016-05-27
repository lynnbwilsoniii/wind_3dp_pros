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


    term0           = 
    term1           = 
    df_dphi         = 
    df_dthe         = 
    df_dvsh         = 









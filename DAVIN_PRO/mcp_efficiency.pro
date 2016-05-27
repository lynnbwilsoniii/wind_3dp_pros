function mcp_efficiency,energy

;eff = 1-(2/(3+6.5/(energy/1000.-.5)+30/(energy/1000.-.5)^3))


tmax = 2.283
a = 1.35
delta_max = 1.0
emax = 325.  ;eV
delta = delta_max * (energy/emax)^(1-a)*(1-exp(-tmax*(energy/emax)^a))/(1-exp(-tmax))
k = 2.2
eff = (1-exp(-k*delta/delta_max))/ (1-exp(-k))
; REF: Relative electron detection efficiency of microchannel plates from 0-3 keV
;  R.R. Goruganthu and W. G. Wilson, Rev. Sci. Instrum. Vol. 55, No. 12 Dec 1984

return,eff
end
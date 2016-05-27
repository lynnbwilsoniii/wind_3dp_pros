retdat.geomfactor = 1.26e-2/180.*5.625

anode_el = byte((90-retdat.theta)/22.5)
relgeom_el = 4 * [0.977,1.019,0.990,1.125,1.154,0.998,0.977,1.005]
retdat.gf = relgeom_el[anode_el]

retdat.energy = retdat.energy + 2.
retdat.phi = retdat.phi - 5.625

ncount = [1,1,2,4,4,2,1,1]
retdat.deadtime = 6e-7 / ncount[anode_el]


;if n_elements(init_el) eq 0 then begin
;   theta_el = reform(retdat.theta(0,*))
;   energy_el = reform(retdat.energy(*,0))
;    anode_el = byte((90-theta_el)/22.5)
;   relgeom_el=[0.977,1.019,0.990,1.125,1.154,0.998,0.977,1.005]
;   e_shift_el= 7.
;endif

;retdat.energy = retdat.energy + e_shift_el
;retdat.geom=retdat.geom * relgeom_el(anode_el)
;retdat.geomfactor = 1.26e-2/180.*5.625
;retdat.mass = 5.6856591e-6             ; mass eV/(km/sec)^2       
;if n_params() gt 1 then add_all,retdat,add
;retdat.e_shift = e_shift_el
;retdat.valid=2


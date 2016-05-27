

function pl_response,nrg,phi,e,p,par=par
p_s = par.p_s
t_s = par.t_s
e_s = par.e_s
volts = par.volts
ea_resp = par.ea_resp
phi_pt = 225. - (p_s + p + e/16.)*5.625
f =    plea_resp(nrg/volts(e,0), phi - phi_pt,par=ea_resp)
f = f+ plea_resp(nrg/volts(e,1), phi - phi_pt,par=ea_resp)
f = f+ plea_resp(nrg/volts(e,2), phi - phi_pt,par=ea_resp)
f = f+ plea_resp(nrg/volts(e,3), phi - phi_pt,par=ea_resp)
return,f/4.
end







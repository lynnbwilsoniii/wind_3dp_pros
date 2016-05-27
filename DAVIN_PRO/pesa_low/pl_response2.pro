function pl_response2,nrg,phi,theta,e,p,t,par=par
p_s = par.p_s
t_s = par.t_s
e_s = par.e_s
volts = par.volts
ea_resp = par.ea_resp
t_resp = par.t_resp
phi_pt = 225. - (p_s + p + e/16.)*5.625
theta_t = -45. + (t_s + t + .5) * 5.625
f =    plea_resp(nrg/volts(0,e), phi - phi_pt,par=ea_resp)/volts(0,e)
f = f+ plea_resp(nrg/volts(1,e), phi - phi_pt,par=ea_resp)/volts(1,e)
f = f+ plea_resp(nrg/volts(2,e), phi - phi_pt,par=ea_resp)/volts(2,e)
f = f+ plea_resp(nrg/volts(3,e), phi - phi_pt,par=ea_resp)/volts(3,e)
resp = f/4. * gaussian2(theta - theta_t,par=t_resp)
return,resp
end


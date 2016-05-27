forward_function plea_resp

function plea_resp,ev,alpha,param=par
common pl_response_com, par0
if n_params() eq 1 then return,plea_resp(ev.ev,ev.alpha,param=par)
if data_type(par0) ne 8 then $
   par0 = {h:1.d, ka:6.d, kw:0.04d, $
       alpha0:-0.7d,alphaw:1.d,c:1.7d}
if data_type(par) ne 8 then par=par0 else par0=par
if n_params() eq 0 then return,0

x = (ev/par.ka-1)/par.kw
y = (alpha - par.alpha0)/par.alphaw
z2 = -x^2 + par.c*x*y - y^2
norm = par.kw * par.ka * par.alphaw * !dpi /  sqrt(1-par.c^2/4)
f = par.h / norm * exp(z2)
return,f
end

;   par = {h:1.d, ka:6.2577846d, kw:0.044184023d, $
;       alpha0:-0.73350625d,alphaw:1.6509076d,c:1.7655671d}


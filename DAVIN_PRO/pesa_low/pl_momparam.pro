function pl_momparam,dat,par=par
if data_type(par) ne 8 then begin
   mom = moments_3d()
   
;   spec = {n:10.d,v:dblarr(3),vth:50.d,q:1,m:1}
   par =    {p:mom, a:mom }                ;, deadtime:1e-6 }
;   help,par,/st
endif
       
if data_type(dat) eq 8 then begin
   tdat = total(dat.data,2)
   mx = max(tdat,mxb)
   erp = [mxb-3,13]
   era = [0,mxb-4]
   par.p = moments_3d(dat,erange=erp,format=par.p)
   alpha = dat
   alpha.mass = alpha.mass*4
   alpha.energy = alpha.energy *2
   par.a = moments_3d(dat,erange=era,format=par.a)
endif

return,par

end



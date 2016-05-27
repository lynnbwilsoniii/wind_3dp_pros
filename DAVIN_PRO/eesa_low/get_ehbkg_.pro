function get_ehbkg,eh,limit=lim,parameters=p

dummy=ehbkgfit(param=p)

ind = where(p.bins)

data = eh.data(ind)
ddata = sqrt(data + 1. + (.03 * data)^2 )

nam = 'flux1k slope bkgrate'
fit = fitfunc(eh,data,dy=ddata,param=p,p_names=nam,func='ehbkgfit')
help,nam

pbkg = p

eht = eh
dummy = ehbkgfit(eht,/set,param=pbkg)
pbkg.flux1k = 0
pbkg.bins=1

ehb = eh
dummy = ehbkgfit(ehb,/set,param=pbkg)

if keyword_set(lim) then begin
   spec3d,lim=lim,eh
;   spec3d,lim=lim,ehb,/over
   spec3d,lim=lim,eht,/over
endif


return,ehb
end
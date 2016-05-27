;FUNCTION:	mom_el,dat
;INPUT:	
;	data:	structure,	3d data structure.  (i.e. see "GET_EL")
;PURPOSE:
;       Returns all useful moments as a structure
;KEYWORDS:
;	erange:	
;	bins:	
;
;CREATED BY:    Davin Larson    
;LAST MODIFICATION: %E%
;-
function mom_el, dat,  $
   format=mf,  $
   sc_pot=sc_pot,  $
   pardens = pardens,  $
   true_dens=true_dens, $
   chi = chi, $
;   nhot = nhot, $
   names0 = names0, $
   nfit = nfit, $
   fit_core = fc, $
   hmom = mh, $
   all_mom = all_mom, $
   lim=lim,er=er

if n_elements(sc_pot) eq 0 then str_element,fc,'sc_pot',sc_pot
if n_elements(sc_pot) eq 0 then str_element,dat,'sc_pot',sc_pot
if n_elements(sc_pot) eq 0 then sc_pot = 4.

if not keyword_set(fc) then begin
  sumc = mom_sum(dat,sc_pot=sc_pot,pardens=pardens)
  fc = sum2elfit(sumc)     ; initial guess
  fit_core=1
endif
if keyword_set(nfit) then fit_core=1

if not keyword_set(names0) then names0='sc_pot core.t core.tdif vsw'
if keyword_set(true_dens) then begin
  names=names0 
endif  else names='core.n '+names0
op = {emin:0.,emax:30.,names:names,do_fit:1,display:1}

fdat = dat
hdat = dat
;if keyword_set(mh) then nhot = mh.density
nhalo = fc.halo.n
if not keyword_set(nhot) then nhot = .2
nhot = 0. > nhot < 2.


if keyword_set(true_dens) then nfit=3 else nfit=1
fit_core=1
fit_halo = 0


if keyword_set(fit_halo) then begin
   oph = op
   oph.emin = 70.
   oph.emax = 2000.
   oph.names = 'halo'
   fc = fitel3d(dat,guess=fc,opt=oph,xchi=chi)
   chih = average(chi^2,2)
endif

for i=0,nfit-1 do begin
if keyword_set(true_dens) then help,true_dens,nhot

nhalo = .05 > fc.halo.n < 2.
if keyword_set(fit_core) then begin
   fc.halo.n = 0
   if keyword_set(true_dens) then   fc.core.n = true_dens - nhot
   op.emin = fc.sc_pot*.8
   op.emax = fc.sc_pot + 3.0 * fc.core.t > 13.
   fc = fitel3d(dat,guess=fc,opt=op,xchi=chi)
   chi = average(chi^2,2)
   sc_pot = fc.sc_pot
endif

if keyword_set(fit_halo) then begin
   fc.halo.n = nhalo
   dummy=elfit7(par=fc)
   fc = fitel3d(dat,guess=fc,opt=oph,xchi=chih)
;   chih = average(chih^2,2)
endif


fc0 = fc
fc0.halo.n = 0
dum = elfit7(fdat,/set,par=fc0)
hdat.data = dat.data-fdat.data
  
  sumc = elfit2sum(fc,/core_only)
  sumh = mom_sum(hdat,sc_pot=sc_pot,pardens=hpardens)
  sumt = sumc
  sumt.n   = sumc.n   + sumh.n
  sumt.nv   = sumc.nv   + sumh.nv
  sumt.nvv   = sumc.nvv   + sumh.nvv
  sumt.nvvv   = sumc.nvvv  + sumh.nvvv
  sumt.nvvvv   = sumc.nvvvv  + sumh.nvvvv

if keyword_set(lim)  then begin
  wi,2
  spec3d,dat,lim=lim,color=4
  spec3d,fdat,lim=lim,color=3,/over
  spec3d,hdat,lim=lim,/over,/pitch;,color=6
  oplot,fc.sc_pot*[1,1],[1e-10,1e10]
  oplot,[op.emin,op.emax],7e8*[1,1]
  wi,9
  dummy = mom_sum(dat,sc_pot=sc_pot,pardens=pardens)
  plot,hpardens,yrange=[-.05,1.5],/ystyle
  if keyword_set(pardens) then oplot,pardens
endif


n= fc.core.n
  
mt = mom3d(sum=sumt,format=mf)  & mt.time = dat.time
mh = mom3d(sum=sumh,format=mf)
;mc = mom3d(sum=sumc,format=mf)
nhot = mh.density
 

if keyword_set(true_dens) then begin
   n_error = (mt.density-true_dens)/true_dens
   help,nhot,n_error
   if abs(n_error) lt .01  then goto,break
endif
  
endfor

break:

if arg_present(all_mom) then all_mom = {fc:fc,mh:mh,mt:mt}

return,mt

end



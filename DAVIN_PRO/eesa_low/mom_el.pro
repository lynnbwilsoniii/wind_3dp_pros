;FUNCTION:	mom_el,dat
;INPUT:	
;	data:	structure,	3d data structure.  (i.e. see "GET_EL")
;PURPOSE:
;       Returns all useful moments as a structure
;KEYWORDS:
;
;CREATED BY:    Davin Larson    
;LAST MODIFICATION: %E%
;-
function mom_el, dat,  $
   test=test, $
   verbose=verbose, $
   display = display, $
   format=mf,  $
   sc_pot=scpot,  $
   pardens = pardens,  $
   true_dens=true_dens, $
   chi = chi, $
   fitresult = fitresult, $
;   nhot = nhot, $
   names0 = names0, $
   nfit = nfit, $
   fit_core = fc, $
   hmom = mh, $
   all_mom = all_mom, $
   lim=lim
   
if finite(total(dat.magf^2)) eq 0 then begin
    fc = 0
    fitresult = 0
    return,mom3d()
endif

if keyword_set(true_dens) then nsw_sc_pot = sc_pot(true_dens)
if n_elements(sc_pot) eq 0 then str_element,fc,'sc_pot',scpot
if n_elements(sc_pot) eq 0 then str_element,dat,'sc_pot',scpot
if n_elements(sc_pot) eq 0 then scpot = 4.

fit_core=1

;if not keyword_set(fc) then begin
;  sumc = mom_sum(dat,sc_pot=scpot,pardens=pardens)
;  fc = sum2elfit(sumc)     ; initial guess
;endif

if not keyword_set(dat) then return, mom3d()

;if keyword_set(nfit) then fit_core=1

if not keyword_set(names0) then names0='sc_pot core.t core.tdif vsw'

if keyword_set(true_dens) then begin
  names=names0 
endif  else names='core.n '+names0

if keyword_set(test) then begin
   if !d.name ne 'X' then message,'Must use X device!'
   device,window_state=wstate
   if wstate[2] eq 0 then window,2
   if wstate[3] eq 0 then window,3
   if wstate[4] eq 0 then window,4
   if wstate[5] eq 0 then window,5
   if wstate[9] eq 0 then window,9
   xlim,lim,4,2000,1
   units,lim,'eflux' & ylim,lim,3e4,3e9,1
   units,alim,'df' & ylim,alim,1e-18,1e-7,1
   options,alim,'psym',1
   options,lim,'a_color' ,'sundir'
   options,alim,'a_color' ,'phi'
   options,alim,'colors','gyrmbc'
   bins2 = bytarr(15,88)
   bins2[*,[0,1,4,5,22,23,26,27,44,45,48,49,66,67,70,71]] = 1
   options,lim,'bins',bins2
   options,alim,'bins',bins2
   op={emin:0., emax:30., dfmin:0., names:names, bins:replicate(1b,15,88), $
    display:1, do_fit:1,limits:lim, alimits:alim }

endif else  op = {emin:0.,emax:30.,names:names,do_fit:1,display:0}

fdat = dat
hdat = dat
;if keyword_set(mh) then nhot = mh.density
;nhalo = fc.halo.n
;if not keyword_set(nhot) then nhot = .2
;nhot = 0. > nhot < 2.


;if keyword_set(true_dens) then nfit=3 else nfit=1
fit_core=1
fit_halo = 0

erange = minmax(dat.energy)

if keyword_set(fit_halo) then begin
   oph = op
   oph.emin = 50.
   oph.emax = 2000.
   oph.names = 'halo.v halo.n halo.vth'
   fc = fitel3d(dat,guess=fc,opt=oph,fitresult=fitresult,verbose=verbose)
   chih = fitresult.x2
endif

maxits = 20
nfit = 2

for i=0,nfit-1 do begin

;if keyword_set(true_dens) then help,true_dens,nhot
help,true_dens

help,scpot
if not keyword_set(fc) then begin
  sumc = mom_sum(dat,sc_pot=nsw_sc_pot,pardens=pardens)
  fc = sum2elfit(sumc)     ; initial guess
endif

;nhalo = .01 > fc.halo.n < 2.
fc.sc_pot = 1. > fc.sc_pot < 40.

if keyword_set(fit_core) then begin
   if fc.sc_pot lt erange[0]*.85 then begin
     op.names = names0 
     if keyword_set(true_dens) then fc.core.n = true_dens ; - nhot
   endif else begin
     op.names = 'core.n ' + names0 
   endelse
   op.emax = fc.sc_pot + 3.0 * fc.core.t > 13.
   op.emin = fc.sc_pot *.8 < op.emax*.7
   fc = fitel3d(dat,guess=fc,opt=op,fdat=fdat,fitresult=fitresult,verbose=verbose)
   chi = fitresult.x2
   scpot = fc.sc_pot
endif

if keyword_set(fit_halo) then begin
;   fc.halo.n = nhalo
   fc = fitel3d(dat,guess=fc,opt=oph,fdat=fdat,fitresult=fitresult,verbose=verbose)
   chih = fitresult.x2
endif

mt = mom_elfit(dat,fc,fdat,mh=mh,format=mf,hpardens=hpardens)

if keyword_set(lim)  then begin
  wset,5
  spec3d,dat,lim=lim,color=4
  spec3d,fdat,lim=lim,color=3,/over
  spec3d,hdat,lim=lim,/over,/pitch;,color=6
  oplot,fc.sc_pot*[1,1],[1e-10,1e10]
  oplot,[op.emin,op.emax],7e8*[1,1]
  wset,9
  dat.bins=1
  dummy = mom_sum(dat,sc_pot=fc.sc_pot,pardens=pardens)
  plot,hpardens,yrange=[.001,20.],/ystyle,/ylog,psym=-1
  oplot,-hpardens,/col,psym=-1
  if keyword_set(pardens) then oplot,pardens,psym=-4
  if keyword_set(pardens) then oplot,-pardens,/col,psym=-4
  wset,0
endif
dat.bins=1

;n= fc.core.n
  
;nhot = mh.density
 
if fitresult.nits lt maxits and finite(fitresult.chi2) then break

if finite(fitresult.chi2) eq 0 then fc = 0
fc = 0
;fc.sc_pot = nsw_sc_pot
;fc.core.n = true_dens
;fc.core.t = 10.
;fc.vsw = dat.vsw
;fc.core.tdif = 0.

;if keyword_set(true_dens) then begin
;   n_error = (mt.density-true_dens)/true_dens
;   help,nhot,n_error
;   if abs(n_error) lt .01  then goto,break
;endif
  
endfor

break:

if arg_present(all_mom) then all_mom = {fc:fc,mh:mh,mt:mt}

return,mt

end



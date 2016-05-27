function fitel3d,dat,options=opts,guess=guess,fdat=fdat $
  ,no_fit=no_fit,xchi=chi,fitresult=fitresult,verbose=verbose

fname = 'elfit7'
pnames = 'core.t core.tdif sc_pot halo vsw' ;halo.n halo.vth halo.v'
str_element,opts,'names',pnames


dummy = call_function(fname,par=guess)  ; set limits

nan = !values.f_nan
chi2 = nan 
fitresult = { nits:0, x2:replicate(nan,15), erange:[nan,nan],vflags:0l,chi2:nan }



;if keyword_set(no_fit) then return,guess


if data_type(opts) ne 8 then begin
   xlim,lim,4,2000,1
   units,lim,'eflux' & ylim,lim,1e4,3e9,1
   units,alim,'df' & ylim,alim,1e-18,1e-7,1
   options,alim,'psym',1
   options,lim,'a_color' ,'sundir'
   options,alim,'a_color' ,'phi'
   options,alim,'colors','mbcgyr'
   bins2 = bytarr(15,88)
   bins2[*,[0,1,4,5,22,23,26,27,44,45,48,49,66,67,70,71]] = 1
   options,lim,'bins',bins2
   options,alim,'bins',bins2

 opts={emin:0., emax:3000., dfmin:0., names:pnames, bins:replicate(1b,15,88), $
    display:1, do_fit:1,limits:lim, alimits:alim }
endif
    
if not keyword_set(dat) then return,guess
if dat.valid eq 0 then return,fill_nan(guess)


emin=0.
emax = 3e3
str_element,opts,'emin',emin
str_element,opts,'emax',emax
str_element,opts,'bins',bins
dat.bins = 1

if keyword_set(bins) then dat.bins = bins

w = where(dat.energy lt emin,c)
if c ne 0 then dat.bins[w] = 0
w = where(dat.energy gt emax,c)
if c ne 0 then dat.bins[w] = 0

str_element,opts,'dfmin',dfmin
if keyword_set(dfmin) then begin
  df = conv_units(dat,'df')
  w=where(df.data lt dfmin,c)
  if c ne 0 then dat.bins[w] = 0
endif

dat.ddata = sqrt((.05*dat.data)^2 + (dat.data+2.))

cnts =  dat.data(where(dat.bins)) 
dcnts = dat.ddata(where(dat.bins)) 

fit = guess


fit.magf = dat.magf

str_element,opts,'display',display
str_element,opts,'limits',lim
str_element,opts,'alimits',alim


dummy = call_function(fname,par=fit)
if opts.do_fit and not keyword_set(no_fit) then $
  fit,dat,cnts,dy=dcnts,func=fname,name=pnames,par=fit,chi2=chi2,maxprint=12,fullnames=fullnames,iter=iter,silent= keyword_set(verbose) eq 0

fitresult.chi2 = chi2
fitresult.nits = iter
fitresult.erange = [emin,emax]

;allnames = 'CORE.N CORE.T CORE.TDIF CORE.V HALO.N HALO.VTH HALO.K HALO.V SC_POT VSW[0] VSW[1] VSW[2]'
allnames = ['CORE.N', 'CORE.T', 'CORE.TDIF', 'CORE.V', 'HALO.N', 'HALO.VTH', 'HALO.K', 'HALO.V', 'SC_POT', 'VSW[0]', 'VSW[1]', 'VSW[2]']
flags = array_union(allnames,fullnames) ge 0
fitresult.vflags = total( ishft( long(flags) , indgen( n_elements(flags) ) ) )


dat.sc_pot = fit.sc_pot
fdat = dat
 
; str_element,/add,fdat,'sc_pot',fit.sc_pot
dummy = call_function(fname,fdat,par=fit,/set) 
 
chi = (dat.data-fdat.data)/dat.ddata
 
fitresult.x2 = average(chi^2,2)


if keyword_set(display) then begin
 z2 = alog10(dat.data/fdat.data)
 
  plt = get_plot_state()
  pang=1
  sundir=1
  str_element,lim2,'pitchangle',pang
  str_element,lim2,'sundir',sundir
  if keyword_set(pang) then str_element,dat,'magf',vec
  if keyword_set(sundir) then vec = [-1.,0.,0.]
  if keyword_set(vec)  then begin
     phi = average(dat.phi,1,/nan)   ; average phi
     theta = average(dat.theta,1,/nan)  ; average theta
     xyz_to_polar,vec,theta=bth,phi=bph
     p = pangle(theta,phi,bth,bph)
;    col = bytescale(p,range=[0.,180.])   
  endif

   wset,4
   ylim,lim2,4,2000,1
   xlim,lim2,-1,dat.nbins
   zlim,lim2,-.5,.5
   options,lim2,'no_interp',1
   options,lim2,'xmargin',[10,10]
   y2 = dat.energy
   x2 = replicate(1.,dat.nenergy) # indgen(dat.nbins)
;   z2 = (dat.data-fdat.data)/dat.ddata
;   w = where(dat.bins eq 0,c)
;   if c ne 0 then z2[w]=!values.f_nan

   b2 = dat.bins
;   z2 = alog10(dat.data/5000)
   if keyword_set(p) then begin
      s = sort(p)
      y2 = y2[*,s]
;      x2 = x2[*,s]
      z2 = z2[*,s]
      b2 = b2[*,s]
   endif   
   x = average(x2,1)
   y = average(y2,2)
   c = bytescale(z2,range=[-2,2])
   specplot,findgen(dat.nbins),y,transpose(z2),lim=lim2
   w = where(b2 eq 0,c)
   if c ne 0 then oplot,x2[w],y2[w],ps=7
   fdat.ddata=0


if keyword_set(lim) then begin
 wset,2
 fdat1 = fdat
 w = where(dat.bins eq 0,c)
; if c ne 0 then fdat1.data[w]=!values.f_nan
 over=0
 spec3d,dat,lim=lim,over=over
 foo = lim
 options,foo,'psym',-4
 spec3d,fdat1 ,lim=foo,over=over ;,psym=-4
 hdat=dat
 hdat.data = dat.data - fdat.data
 options,foo,'psym',-5
; spec3d,hdat,over=over,lim=foo

 oplot,fit.sc_pot*[1,1],10.^!y.crange
 oplot,(fit.sc_pot-fit.e_shift)*[1,1],[1e-25,1e25],col=1
  oplot,emin*[1,1],10.^!y.crange,col=6
  oplot,emax*[1,1],10.^!y.crange,col=6
;  printdat,fit
endif

if keyword_set(alim) then begin
   wset,3
   aplot,dat,lim=alim
   alim2 = alim
   options,alim2,'psym',-4
   aplot,fdat ,lim=alim2, /over
endif

restore_plot_state,plt
endif


return,fit

end


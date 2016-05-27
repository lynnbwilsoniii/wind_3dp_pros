pro el_sample,dat,options=ops,help=help,fit=fc
common el_sample_com2,elopts,last

if n_elements(ops) ne 0 then elopts=ops
if not keyword_set(elopts) then begin


units,slim1,'df' & ylim,slim1,1e-17,1e-9,1
units,slim1,'flux' & ylim,slim1,10,1e7,1
units,slim1,'eflux' & ylim,slim1,1e4,1e9,1
options,slim1,'pitchangle',1
xlim,slim1,2,2000,1
;options,slim1,'xmargin',[4,3]
;options,slim1,'ymargin',[4,4]
;options,slim1,'noerase',1
options,slim1,'w',1

slim2 = slim1
;options,slim1,'region' ,[.4,0,.7,.5]
;options,slim2,'region' ,[.4,.5,.7,1]

units,plim,'flux' & ylim,plim,10,1e7,1
units,plim,'df' & ylim,plim,1e-17,1e-9,1
options,plim,'psym',-1
;options,plim,'region' ,[.7,0.,1.,1]
;options,plim,'noerase',1

ylim,clim,1e-17,1e-9,1
xlim,clim,-20000.,20000.,0
options,clim,'cpd',2

options,misc,'vsw', 'pm.VELOCITY'
options,misc,'dens', 'pm.DENSITY'
options,misc,'mag' , 'wi_B3'

options,misc,'npa' , 11
options,misc,'nrat' , 1.
options,misc,'bnc' , 1
plot3d_options,tri=1

;window,1,xsize=400,ysize=300,xpos=0,ypos=750
;window,2,xsize=400,ysize=300,xpos=0,ypos=750
;window,3,xsize=400,ysize=700,xpos=800,ypos=700
window,4,xsize=400,ysize=700,xpos=580,ypos=700
window,5,xsize=400,ysize=300,xpos=0,ypos=750
window,6,xsize=400,ysize=300,xpos=0,ypos=750
window,7,xsize=250,ysize=700,xpos=1000,ypos=700
window,9,xsize=200,ysize=200,xpos=0,ypos=700

options,elopts,'clim',clim
options,elopts,'slim1',slim1
options,elopts,'slim2',slim2
options,elopts,'plim',plim
options,elopts,'misc',misc
options,elopts,'tlast',0.d

printdat,elopts

endif

if keyword_set(help) then begin
  printdat,elopts
  stop
  return
endif

ops = elopts


hard=keyword_set(hard)



plt = get_plot_state()
ctime,t  ,np=npnts
;wi,0 & if !d.name eq 'X' then tv,tplot_im else tplot
if not keyword_set(t) then t=elopts.tlast
dat = get_el2(t)
if dat.valid eq 0 then return
fname = time_string(format=2,dat.time)
timebar,dat.trange
elopts.tlast = dat.time
add_magf,dat,elopts.misc.mag
np=elopts.misc.nrat * data_cut(elopts.misc.dens,dat.time) & print,np
nswe=data_cut('wi_swe_Np',dat.time)
nwav=data_cut('wi_wav_Ne',dat.time)
;npl = data_cut('pm.DENSITY',dat.time)
em=moments_3d(dat,true=np,pardens=pardens);,form=em);,all=ma)
;mc = ma.c
wi,5
;em = mom_el(dat,true=np,all=ma,fit=fc,pardens=pardens,lim=slim1)
;wi,9 & plot,pardens/total(pardens),yrange=[0,.5],psym=10


;printdat,em

sc_pot=em.sc_pot
wi,5 & spec3d,dat,lim=elopts.slim1
oplot,sc_pot*[1,1],[1e-15,1e9]
Print,'Click on sc potential'
getxy,sc_pot
oplot,sc_pot*[1,1],[1e-15,1e9]

;em2=mom_el(dat,sc_pot=sc_pot)
if sc_pot ne em.sc_pot then $
;  em = moments_el(dat,sc_pot=sc_pot,all=ma,fit=fc,pardens=pardens,lim=slim1)
  em = mom_el(dat,sc_pot=sc_pot,all=ma,fit=fc,pardens=pardens,lim=slim1)
wi,9 & plot,pardens/total(pardens),yrange=[0,.5]



add_vsw,dat,elopts.misc.vsw
add_str_element,dat,'sc_pot',sc_pot
add_str_element,dat,'Ntrue',nswe
esteps = average(dat.energy,2)
dfi = convert_vframe(dat,/interp,ethres=500.,evalues=esteps)
df  = convert_vframe(dat)
dfe = convert_vframe(dat,fc.vsw)
wi,6
spec3d,df,lim=elopts.slim2
;wi,1 & spec3d,dfi,lim=elopts.slim

pd = pad(dfi,bins=bins,num_pa=npa)
str_element,/add,pd,'deadtime',0.
dfpar = distfunc(pd.energy,pd.angles,mass=pd.mass,df=pd.data)
extract_tags,dfi,dfpar

; wi,7 & spec3d,pd,lim=elopts.slim
wi,7 & padplot,pd,lim=elopts.plim
wi,4 & cont2d,dfi,vlim,cpd=cpd,lim=elopts.clim,redf=redf,vout=vout,ngr=50
 
wi,6
spec3d,pd,lim=elopts.slim2

;str_element,/add,dfi,'redf',redf
;str_element,/add,dfi,'vout',vout
; wi,5  & plot3d,dfi,bnc=elopts.misc.bnc
; wi,6  & plot3d,dfi,bnc=-elopts.misc.bnc
wi,8  & plot3d,dfi,bnc=-elopts.misc.bnc


;fit = mom2fit(mc,fit=fit)
;fit = fitel3d(dat,guess=fit,options=opts)


if keyword_set(hard) then begin
popen,'spec1'+fname,/port
spec3d,pd,lim=elopts.slim2

popen,'spec2'+fname,/port
spec3d,pd,lim=elopts.slim2

popen,'cont'+fname,/port
cont2d,dfi,vlim,cpd=cpd,lim=elopts.clim,redf=redf,vout=vout,ngr=50



endif


restore_plot_state,plt


end

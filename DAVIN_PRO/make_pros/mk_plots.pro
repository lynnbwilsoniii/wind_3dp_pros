;idl
!p.charsize=.6


start=''
read,start,prompt='Start date? '

ndays = 1
read,ndays,prompt='Number of days? '


nplots = 7
read,nplots,prompt='Number of plots? '

printer=''
read,printer,prompt='Printer Name? '

daysec = 24.d*3600.d
cd ,'~davin/plots'

ts = dindgen(nplots)*ndays*daysec+time_double(start)
print,transpose(time_string(ts))
i=0

;  .run

window,xsize=700,ysize=900
tr = time_double(['95-2-1','2002-1-1'])
cr = fix(carr_rot(tr))
nplots = cr[1]-cr[0]+1
vars='MAGF_mag MAGF_th MAGF_phi em.SC_POT Nsw Vsw em.VELOCITY em.MAGT3 em.SKEWNESS em.QVEC em.EXCESS elpd-1-4:4 elpd-1-4:4_norm
ylim,'em.QVEC',-2e5,2e5
ylim,'em.SKEWNESS',-1,1
store_data,'Vsw',data='em.VELOCITY_mag VSW_mag'
store_data,'Nsw',data='em.DENSITY NSW'
options,'VSW_* NSW',colors='b'
ylim,'Vsw',300,700
ylim,'Nsw',.5,50,1
ylim,'MAGF_mag',0,30
ylim,'em.VELOCITY',-800,200
ylim,'em.MAGT3',1,50,1
ylim,'em.EXCESS',0,5,0
ylim,'em.SC_POT',-5,30
elpd_lim
for c=cr[0],cr[1] do begin
  t = carr_rot(/inv,[c,c+1])
 ; t[1]=t[0]+3600.*24*2
  timespan,t
  load_wi_elpd4,res=600.
  load_wi_or,/var
  xyz_to_polar,'VSW'
  xyz_to_polar,'MAGF'
  xyz_to_polar,'em.VELOCITY'
  normpad
  tplot,vars
  makegif,strcompress('sum_CR_'+string(c),/remove)
endfor

end

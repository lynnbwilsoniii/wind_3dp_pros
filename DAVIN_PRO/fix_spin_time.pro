pro fix_spin_time,fspin,ftime

get_frame_info,data=frame,/no_tplot

w = where(frame.time gt time_double('90-1-1') and frame.spin gt 0)
frame = frame[w]
;ftime = frame[w].time
;fspin = frame[w].fspin
ftime = frame.time
fspin = frame.fspin

; fspin[2500:*]=fspin[2500:*]-floor(fspin[2500])

dspin = (fspin-shift(fspin,1))
dspin[0] = dspin[1]
dtime = (ftime-shift(ftime,1))
dtime[0] = dtime[1]
spin_period =  dtime/dspin 
good = spin_period gt 2.3 and spin_period lt 3.5
bad = good eq 0
; w = where(spin_period le 2.3 or spin_period ge 3.5)
w = where((bad and shift(bad,-1)) eq 0)

ftime = frame[w].time
fspin = frame[w].fspin

dspin = (fspin-shift(fspin,1))
dspin[0] = dspin[1]
dtime = (ftime-shift(ftime,1))
dtime[0] = dtime[1]
spin_period =  dtime/dspin 
good = spin_period gt 2.3 and spin_period lt 3.5
w = where(good)

period = average(spin_period[w])
w = where(dspin lt 0,c)
ns = n_elements(fspin)
msbyte = replicate(0l,ns)
for i=0,c-1  do $
    msbyte[w[i]:*] = msbyte[w[i]:*] + round(-dspin[w[i]] + (dtime/period)[w[i]])

;  plot,fspin+msbyte
fspin = fspin+msbyte

t0 = average(minmax(ftime))
y= fspin 
x= ftime-t0

nsm=31
correlate_vect,x,y,a=a,b=b,r=r , nsm
a[0:nsm/2] = a[nsm/2+1]  &   a[ns-nsm/2:*] = a[ns-nsm/2-1]
b[0:nsm/2] = b[nsm/2+1]  &   b[ns-nsm/2:*] = b[ns-nsm/2-1]

s = a+b*(ftime-t0)
ds = s-fspin

if 0 then begin
!p.multi=[0,1,3]
plot,a,/ynoz
plot,1/b,/ynoz
plot,ds,ps=3 ; ,xr=[0,300],yrange=[-.05,.15]
!p.multi=0
endif

fspin = fspin + (-1/32. > ds < 1/32.) + 1/32.


if 0 then begin
y = fspin 
x= ftime-t0
correlate_vect,x,y,a=a,b=b,r=r , nsm
a[0:nsm/2] = a[nsm/2+1]  &   a[ns-nsm/2:*] = a[ns-nsm/2-1]
b[0:nsm/2] = b[nsm/2+1]  &   b[ns-nsm/2:*] = b[ns-nsm/2-1]
s = a+b*(ftime-t0)
ds = s-fspin
!p.multi=[0,1,3]
plot,a,/ynoz
plot,1/b,/ynoz
plot,ds,ps=3 ; ,xr=[0,300],yrange=[-.05,.15]
!p.multi=0
endif

end


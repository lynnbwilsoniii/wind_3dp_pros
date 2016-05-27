function fix_pmom_spin_time,dat

w = where(dat.valid)
time = dat[w].time

fix_spin_time,fspin,ftime

s = round(interpol(fspin,ftime,time))

nan = fill_nan(dat[0])
srange = minmax(s)
ns = srange[1]-srange[0]+1

dat2=replicate(nan,ns)
spin = lindgen(ns)+srange[0]

dat2[s-srange[0]] = dat[w]
t0 = dat2.time
t = interpol(ftime,fspin+1/8.,spin)
dat2.time = t
;plot,t-t0
return,dat2

end


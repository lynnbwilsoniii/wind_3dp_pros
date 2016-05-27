pro tzoom,names,trange=trange

tplot,new=ts1,/help
if n_elements(trange) ne 2 then ctime,trange
tplot,names,trange=trange,old=ts1,wi=ts1.options.window+1,new=ts2
;tlimit,old=ts1,wi=ts1.options.window+1,new=ts2
tplot,old=ts1,/help

end


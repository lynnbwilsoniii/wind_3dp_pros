function get_3d,type,time,addstuff=addstuff,index=index,times=times


dat = call_function('get_'+type,time,index=index,times=times)

if keyword_set(times) then return,dat

magf = average(tsample('wi_B3',dat.trange),1)
dat.magf = magf

return,dat
end

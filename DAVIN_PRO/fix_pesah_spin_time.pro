function fix_pesah_spin_time,time


fix_spin_time,fspin,ftime

s = round(interpol(fspin,ftime,time))

t = interpol(ftime,fspin+3./8.,s)

return,t

end


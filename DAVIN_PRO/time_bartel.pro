function time_bartel,x,to_bartel=to_bartel,inverse=inverse

if keyword_set(to_bartel) or keyword_set(inverse) then begin
  bart = (time_double(x) - time_double('2000-09-21')) /27d/24d/3600d + 2282
  return,bart

endif
t0 = (x-2282)*27d*24d*3600d + time_double('2000-09-21')

return,t0

end


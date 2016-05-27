function get_data_time, data_sel


t = 0
n = 0
max = 30000

times = dblarr(max)
routine = 'get_'+data_sel

dat = call_function(routine,t)

while (dat.valid ne 0) and (n lt max) do begin
   times(n) = (dat.time + dat.end_time)/2.
   n = n+1
   dat = call_function(routine,t,/adv)
endwhile

times = times(0:n-1)
return,times
end

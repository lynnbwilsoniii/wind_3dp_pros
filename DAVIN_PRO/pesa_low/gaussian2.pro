
function gaussian2,x,param=par
if data_type(par) ne 8 then par = {area:1.d,mean:0.d,width:1.d}

g = par.area / par.width / sqrt(!pi) * exp(-((x-par.mean)/par.width)^2)

return,g
end


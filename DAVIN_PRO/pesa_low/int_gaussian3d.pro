

function int_gaussian3d(gtg,ttt,delv)
mtm = gtg+ttt
r =  gtg ## inverse(mtm) ## ttt 
x0 = delv ## r ## delv
help,r,x0
intgral = sqrt(!dpi * determ(mtm))  * exp(-x0(0))
return,intgral
end

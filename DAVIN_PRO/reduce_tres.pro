function reduce_tres,dat,n
if n le 1 then return,dat
dim = size(/dimen,dat)
m = (dim[0] mod n)
l = dim[0]-m-1

case n_elements(dim) of
1:  return,rebin(dat[0:l],dim[0]/n)
2:  return,rebin(dat[0:l,*],dim[0]/n,dim[1])
3:  return,rebin(dat[0:l,*,*],dim[0]/n,dim[1],dim[2])
endcase
return,0
end



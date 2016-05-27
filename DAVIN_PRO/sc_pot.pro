function sc_pot,n,parameters=p
if keyword_set(p) then message,/info, "new pot function"
;if data_type(p) ne 8 then p={v0:-1.9036d,n0:533.7d}
;return,p.v0*alog(n/p.n0)
lx=alog([0.287739,0.892897, 2.87739, 22.0925])
y=[22.0322, 14.7480, 9.80201, 5.30560]
y2=[0.00000, 2.50982, 1.43188 ,0.00000]
logn = alog(.8*n)
return, spl_interp(lx,y,y2,logn)

end


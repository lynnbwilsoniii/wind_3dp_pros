pro make_wi_xx_3dp,tplotname,filename=filename,data=data

get_data,tplotname,data=tdat
nrec = n_elements(tdat.x)
y = reform(tdat.y(0,*,*))
v1 = reform(tdat.v1(0,*))
v2 = reform(tdat.v2(0,*))

data0 = {time:0.d,eflux:y,  eflux_en:v1,  eflux_pa:v2  $
   ,vsw:fltarr(3),sc_pot:0. }

data = replicate(data0,nrec)

print,tplotname
help,tdat,/st
print,nrec,' records'
help,data,/st

data.time = tdat.x
data.eflux = dimen_shift(tdat.y,-1)
data.eflux_en = dimen_shift(tdat.v1,-1)
data.eflux_pa = dimen_shift(tdat.v2,-1)

makecdf,data,/over,file=filename

end


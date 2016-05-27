function get_pad,t,dats ,bins=bins, bkg=bkg, sum=sum, $
   vsource=vsource, bsource=bsource, src=src, lim = lim,dfdv=dfdv
   


if not keyword_set(bsource) then bsource = 'wi_B3'
if not keyword_set(vsource) then vsource = 'Vp'
if not keyword_set(dats) then dats = 'el'

func = 'get_'+dats


pd = 0
if keyword_set(lim) then box,lim

dat = call_function(func,t(0),src)
repeat begin
;  add_magf,dat,bsource
;  add_vsw,dat,vsource
  sum = sum3d(sum,dat)
  if keyword_set(bkg) then dat = sub3d(dat,bkg)
print,time_to_str(dat.time)
  dat = convert_vframe(dat,/int,ethr=300.,bins=bins,dfdv=dfdv)
  dat.vsw = [1.,0.,0.]
  accum_pad,pd,dat=dat,bin=bins,lim=lim
  dat = call_function(func,0.,src,/adv)
endrep until dat.time gt t(1)


return,pd
end



pro reduce_yres,dat,val,n
dim = size(/dimen,dat)
mm = minmax(val)
nv = n_elements(val)
if nv ne dim[1] then message,'error'
ind = fix( findgen(nv) / nv *n) < (n-1)
;print,ind

newval = make_array(dimen=[n],value=val[0])
newdat = make_array(dimen=[dim[0],n],value=dat[0])
for i=0,n-1 do begin
  w = where(ind eq i,c)
  if c ne 0 then begin
    newval[i] = average(val[w])
    newdat[*,i] = average(dat[*,w],2)
  endif
endfor
dat = newdat
val = newval
return
end


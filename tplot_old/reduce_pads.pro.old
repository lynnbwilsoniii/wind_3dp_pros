pro reduce_pads,name,d,n1,n2,deflim=options,newname=newname,nan=nan,e_units=e_units


if n_params() eq 2 then begin
   get_data,name,ptr=p
   n = n_elements(*p.x)
   dim = size(/dimen,*p.y)
   npa = dim[2]
   nd = n_elements(d)
   y = replicate(!values.f_nan,n,npa,nd)
   y0 = alog(*p.y)
   for i=0l,n-1 do begin
      for j=0,npa-1 do begin
         y[i,j,*] = interpol(reform(y0[i,*,j]),reform((*p.v1)[i,*]),d)
      endfor
   endfor
   y =exp(y)
   newname = strcompress(/remove,name+'_'+string(round(d))+'eV')
   dlim={spec:1,yrange:[0,180],ystyle:1,zlog:1,panel_size:.5}
   for i=0,nd-1 do $
     store_data,newname[i],data={x:p.x,y:y[*,*,i],v:*p.v2},dlim=dlim
return
endif

if n_elements(nan) eq 0 then nan=1
nan = 1
reduce_dimen,name,d,n1,n2,deflim=options,newname=newname,data=data,vrange=vrange,nan=nan
if not keyword_set(data) then return

if not keyword_set(e_units) then e_units=0

case d of
1: begin
   fmt = '(g0.0)' 
   unt = ([' eV',' keV',' Mev'])(e_units)
   scale = ([1.,1000.,1e6])(e_units)
   options,newname,'spec',1,/def
   ylim,newname,0,180,/def
   options,newname,'yticks',2,/def
   options,newname,'ytickv',[0.,90.,180.],/def
   options,newname,'panel_size',.75,/def

   end
2: begin
   fmt = '(g0.0)' 
   unt = ' deg'
   scale = 1.
   ylim,newname,1,1,1,/def
   options,newname,'panel_size',2.,/def
   options,newname,/labflag,colors='mbcgyr'
   end
endcase


vrange = roundsig(vrange/scale,sigfig=1.3)
vst = strcompress(string(vrange,format=fmt),/remove_all)
if vrange(0) eq vrange(1) then ytitle = vst(0)+ unt $
else ytitle = vst(0)+'-'+vst(1)+unt
options,newname,'ytitle',ytitle,/def
options,newname,'s_value',vrange

vals = data.v
if ndimen(vals) eq 2 then vals=total(vals,1,/nan)/total(finite(vals),1)
vals = roundsig(vals,sigfig=1.3)
options,newname,'labels',strcompress(string(vals,format=fmt),/remov),/def

options,newname,'max_value',1e10,/def

end

pro cont2d,dfpar,vlim,ngrid=n,redf=redf,cpd=cpd,lim=lim,nocolor=nocolor,vout=vout,fill=fill,ccolors=ccolors,plot1=plot1

if keyword_set(n) eq 0 then n =30
if keyword_set(vlim) eq 0 then vlim = 20000.
str_element,lim,'xrange',xrange
str_element,lim,'cpd',cpd
if keyword_set(xrange) then vlim = max(xrange)

;color = get_colors(nocolor=nocolor)
color = get_colors()

vout = (dindgen(2*n+1)/n-1) * vlim
vx = vout # replicate(1.,2*n+1)
vy = replicate(1.,2*n+1) # vout

df = distfunc(vx,vy,par=dfpar)
;print,minmax_range(df)
df_range= alog(minmax_range(df))/alog(10.)
if keyword_set(cpd) then cpd0=cpd $
else cpd0 = floor(15/(df_range(1)-df_range(0))) > 1.
;print,cpd0

df10 = alog(df)/alog(10.)
levels = (findgen(30)-29)/cpd0 + ceil(max(df10))
;print,ceil(max(df10))
c_labels = levels eq floor(levels)

v2 = sqrt(vx^2+vy^2)
v02 = sqrt(dfpar.vx0^2 + dfpar.vy0^2)

mn = min(v02)/1.1
mn =0.
mx = max(v02)*1.1
bad = where((v2 lt mn) or (v2 gt mx),count)
if count ne 0 then df10(bad) = !values.f_nan

str_element,dfpar,'time',value=t
str_element,dfpar,'end_time',value=t2
if keyword_set(t) then title = trange_str(t,t2) else title=''

pos = plot_pos(1.,/top)
;positions = plot_positions(ysize=[1,1])
;pos = positions[*,0]
;print,pos
;print,levels

ndec = 4
;cl = (levels/ndec-floor(levels/ndec-.01))
;print,cl
;col = bytescale(cl,range=[0,1.])
;col = -(levels/5-floor(levels/5) )* 5
;col = floor(levels) mod 6 + 1
col = floor(levels)+3
col = col-6*floor(col/6.) +1

overplot= keyword_set(fill)

lim1 = {xrange:[-vlim,vlim],xstyle:1,xlog:0,xtitle:'V parallel (km/s)', $
        yrange:[-vlim,vlim],ystyle:1,ylog:0,ytitle:'V perpendicular (km/s)', $
        title:title,aspect:1,top:1}


extract_tags,lim1,lim
lim1.yrange = lim1.xrange
lim1.xlog=0
lim1.ylog=0


box,lim1


if overplot then $
 contour,df10,vout,vout,lev=levels,tit=title,c_labels=c_labels,/xstyle,/ystyle,xtitle='V parallel (km/s)',ytitle='V perpendicular (km/s)',overplot=1,/fill,/isotr
contour,df10,vout,vout,lev=levels,c_col=col,tit=title,c_labels=c_labels,/xstyle,/ystyle,xtitle='V parallel (km/s)',ytitle='V perpendicular (km/s)',overplot=1,color=ccolor,/isotr

oplot,dfpar.vx0,dfpar.vy0,psym=3,color=color.cyan

;oplot,[0,0],[-vlim,vlim],color=color.yellow

time_stamp

;oplot,v(*,0),v(*,1),psym=3,color=color.red

str_element,dfpar,'vs',val=vref
if keyword_set(vref) then begin
   df10(where(vx lt 0)) = !values.f_nan
   vtemp = vout(n:2*n)
   df10 =df10(n:2*n,*)
help,vtemp,df10,vout
;   contour,df10,-vtemp+vref*2,vout,lev=levels,color=color.red,/overplot $
;   ,/follow,c_label=0;, c_linestyle=2
;   oplot,[vref,vref],[-vlim,vlim],color=color.magenta;,linestyle=1
   oplot,2*[vref,vref],[-vlim,vlim],color=color.green;,linestyle=1
   print,vref
endif

str_element,dfpar,'br',val=brat
if keyword_set(brat) then begin
   v = sqrt(2.)*(findgen(100)+1)/100*vlim
   a = mirror_ang(v,par=dfpar)*!dtor
   oplot,v*cos(a),v*sin(a),color = color.green;,linestyle=1
   oplot,v*cos(a),-v*sin(a),color = color.green;,linestyle=1

   xyouts,vlim,vlim*.9,'Solar Wind  ',align=1.,col=color.green
   xyouts,-vlim,vlim*.9,'  Reflected',align=0.,col=color.green
   xyouts,-vlim,-vlim*.9,'  Reflected',align=0.,col=color.green
   xyouts,-vlim,-vlim*.2,'  Escaped',align=0.,col=color.green
endif


if keyword_set(redf) then redf=!pi*total(df * abs(vy),2) * vlim/n /redf

pos2 = pos
pos2(1)=.06
pos2(3)=pos(1)-.06

plot1 = get_plot_state()

if pos2(3) gt (pos2(1)+.10) then begin
   df = distfunc(vout,0.,par=dfpar)    ;  vparallel cut

   dflim={noerase:1,ylog:1,xstyle:1,title:'',ytitle:'f (sec!u3!n/km!u3!n/cm!u3!n)', $
xtitle:'Velocity (km/s)'}
      

   extract_tags,dflim,lim
   extract_tags,plotstuff,dflim,/plot
   plotstuff.title=''

   plot,vout,df,pos=pos2,_extra=plotstuff

   df = distfunc(0.,vout,par=dfpar)    ;  vperp cut
   oplot,vout,df,col=color.green,lines=2
;   oplot,vout,df,lines=2

   ; reduced f
   if keyword_set(redf) then oplot,vout,redf/1e7,col=color.red;,lines=2

endif

;plots,[0.,1.,1.,0.,0.],[0.,0.,1.,1.,0.],/norm

end

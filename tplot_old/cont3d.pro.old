; +
;PROCEDURE: cont3d,dat
;PURPOSE:
;  Makes a contour plot of distribution function for 3d data.
; -

pro cont3d,dat,newdat = dat3d,options=opt, $
   dpoints=dpoints, circles=circles,vlim=vlim,ncircles=ncircles, $
   ngrid = ngrid,cpd=cpd

dat3d = dat

add_df2dp,dat3d,ngrid=ngrid,vlim=vlim
;help,dat3d,/st

red = 200


;set default options:

title = dat3d.project_name+'  '+dat3d.data_name
title = title+'!C'+trange_str(dat3d.time,dat3d.end_time)
ytitle = 'V perpendicular  (km/sec)'
xtitle = 'V parallel  (km/sec)'
add_str_element,contstuff,'title',title
add_str_element,contstuff,'xtitle',xtitle
add_str_element,contstuff,'ytitle',ytitle

dfdata = dat3d.df2d

range = minmax_range(dfdata,/pos)   ; get min positive values
print,range

dfdata = alog(dfdata)/alog(10.) 
range =  alog(range)/alog(10.)

if n_elements(cpd) eq 0 then begin
   cpd = fix(30/(range(1)-range(0))) > 1
   print,cpd,' contours per decade'
endif
nlevels = fix((range(1)-range(0)+1)*cpd)
nlevels = (nlevels > 2) < 30
levels = reverse((fix(floor(range(1)*cpd))-findgen(nlevels))/cpd)
print,nlevels,cpd
c_colors = bytescale(findgen(nlevels))

add_str_element,contstuff,'levels',levels
add_str_element,contstuff,'c_colors',c_colors

if keyword_set(vlim) then xlim,contstuff,-vlim,vlim
if keyword_set(vlim) then ylim,contstuff,-vlim,vlim

; over write with user choices passed in by the option structure:
extract_tags,contstuff,opt,/contour

print,range
;help,contstuff,/st
print,contstuff.levels
;stop

contour, dfdata, dat3d.vpar2d, dat3d.vperp2d,_extra=contstuff

if keyword_set(dpoints) then  $
    oplot,dat3d.vpar_dat,dat3d.vperp_dat,psym=3

;oplot,[-2.*plim,2.*plim],[0,0],linestyle=1
;oplot,[0,0],[-2.*plim,2.*plim],linestyle=1
;		oplot,[1000,1000],[-2.*plim,2.*plim],linestyle=1
;		oplot,[-1000,-1000],[-2.*plim,2.*plim],linestyle=1
;		oplot,[-2.*plim,2.*plim],[1000,1000],linestyle=1
;		oplot,[-2.*plim,2.*plim],[-1000,-1000],linestyle=1
vdpar= -dat3d.vsw2d(2)
vdperp= -dat3d.vsw2d(0)
oplot,[vdpar,-100*vdpar],[vdperp,-100*vdperp],linestyle=0
oplot,[vdpar],[vdperp],psym=1


if keyword_set(ncircles) then begin
   if not keyword_set(vlim) then vlim = max(!x.crange)
   circles = (findgen(ncircles)+1)*vlim/ncircles
endif

if keyword_set(circles) then begin
   angles=findgen(181)*2./!radeg
   for c=0,n_elements(circles)-1 do begin
      r = circles(c)
      oplot,r*cos(angles),r*sin(angles),linestyle=1,color=red
   endfor
endif   


return
end

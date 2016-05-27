pro colorbar2, zmat=zmat, zlog=zlog, zrange=zrange, $
                    colors=colors, _extra=e, help, ztitle=ztitle, $
                    zword=zword

if n_params() gt 0 then begin
    print, 'USAGE: '
    print, 'pro colorbar, zmat=zmat, zlog=zlog, zrange=zrange, '+$
      'colors=colors, _extra=e'
    print, '   zmat can be passed for autorange'
    stop, ' '
endif
    

zlog=keyword_set(zlog)

if not keyword_set(zrange) then begin
    if keyword_set(zmat) then begin
        zrange=dblarr(2)
        zrange(0)=min(zmat)
        zrange(1)=max(zmat)  
    endif else begin
        print, 'COLORBAR: no z range specified.'
        return
    endelse
end

if not keyword_set(colors) then begin
    colors=[8,!d.table_size-2]
endif
ncolors= colors(1)-colors(0)+1

ylog=!y.type
xlog=!x.type

if (ylog) then begin
    ycrange=10^!y.crange
endif else begin
    ycrange=!y.crange
endelse

if (xlog) then begin
    xcrange=10^!x.crange
endif else begin
    xcrange=!x.crange
endelse

ll= convert_coord( xcrange(0), ycrange(0), /data, /to_device )
ur= convert_coord( xcrange(1), ycrange(1), /data, /to_device )

llb= ll
urb= ur

llb(0)= ur(0)+ (ur(0)-ll(0)) * 0.05
urb(0)= llb(0)+ (ur(0)-ll(0)) * 0.05

cmap= transpose(indgen(ncolors))+colors(0)

    lln= convert_coord( ll, /device, /to_normal )
    urn= convert_coord( ur, /device, /to_normal )
    llnb=lln
    urnb=urn
    llnb(0)= urn(0)+ (urn(0)-lln(0)) * 0.05
    urnb(0)= llnb(0)+ (urn(0)-lln(0)) * 0.05
    xsizen= urnb(0)-llnb(0) ;width of color bar
    ysizen= urnb(1)-llnb(1) ;height of color bar

;tv is a device sensitive animal
if !d.name eq 'PS' then begin
    tv, cmap, llnb(0), llnb(1), xsize=xsizen, ysize=ysizen, /normal
endif else begin
    cmaptemp = congrid( cmap, urb(0)-llb(0), urb(1)-llb(1) ) ;expand
;    color map over the entire color bar plotting region.

    tv, cmaptemp, llnb(0), llnb(1), /normal
endelse

plot, findgen(100), /nodata, /noerase, $
  position=[ llnb(0), llnb(1), urnb(0), urnb(1) ], $
  xstyle=4, yrange=zrange, ystyle=5, xrange=[0,1]
axis, yaxis=1, ylog=zlog, yrange=zrange, ystyle=1, _extra=e
plot, findgen(100), /nodata, /noerase, $
  position=[ lln(0), lln(1), urn(0), urn(1) ], $
  xstyle=4, yrange=zrange, ystyle=5, xrange=[0,1]


if keyword_set(zword) then $
  xyouts, (urb(0)+llb(0))/2, urb(1)+(urb(1)-llb(1))*0.03, align=0.5, $
  zword, /device

return
end


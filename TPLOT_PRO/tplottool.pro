; This program is used as an example in the "Widgets"
; chapter of the _Using IDL_ manual.
;
PRO tplottool_event, ev
@tplot_com
WIDGET_CONTROL, ev.top, GET_UVALUE=wid
;WIDGET_CONTROL, ev.id, GET_UVALUE=uval
CASE ev.id OF
    wid.tplot : begin
       WIDGET_CONTROL, wid.tnames, get_value = names
       WIDGET_CONTROL, wid.trange, get_value = times
       WIDGET_CONTROL, wid.trange, set_value = time_string(times)
       tplot,names,trange=times
       end
    wid.tlimit : begin
       ctime,times,npoints=2
       WIDGET_CONTROL, wid.tnames, get_value = names
       WIDGET_CONTROL, wid.trange, set_value = time_string(times)
       tplot,names,trange=times
       end
    wid.tzoom  : tzoom
    wid.ctime  : begin
        ctime,t
        WIDGET_CONTROL, wid.ctime, set_uvalue=t
        end
    wid.tnames : begin
        WIDGET_CONTROL, wid.tnames, get_value=tnames
;        widget_control, wid.dlist, get_uvalue=dlist
;        widget_control, wid.dlist, set_list_select=where(array_union(dlist,tnames) ge 0)
        dnames=wid.dnames_a
        WIDGET_CONTROL, wid.dnames, set_value=array_union(dnames,tnames) ge 0
        end
    wid.names  : begin
        tplot_names
        end
    wid.exec   : begin
        WIDGET_CONTROL, wid.ctime, GET_UVALUE=t
        WIDGET_CONTROL, wid.exectext, GET_VALUE=Command
        d = execute(command[0])
        end
    wid.dnames : begin
        WIDGET_CONTROL, wid.tnames, get_value = tnames
        WIDGET_CONTROL, wid.dnames, get_value=new_names
        if ev.select then tnames = [tnames,ev.value] $
        else begin
           w = where(tnames ne ev.value,c)
           if c ne 0 then tnames = tnames[w]
        endelse
        widget_control, wid.tnames, set_value = tnames
        end
;    wid.dlist : begin
;        printdat,ev
;        WIDGET_CONTROL, wid.tnames, get_value = tnames
;        WIDGET_CONTROL, wid.dlist, get_uvalue=dlist
;        ind = widget_info(wid.dlist,/list_select)       
;        if ind[0] ge 0  then tnames = [tnames,dlist[ev.index]] $
;        else begin
;           w = where(tnames ne dlist[ev.index],c)
;           if c ne 0 then tnames = tnames[w]
;        endelse
;        widget_control, wid.tnames, set_value = tnames
;        end
    wid.done   : WIDGET_CONTROL, ev.top, /DESTROY
    else: message,'Do Nothing',/info
ENDCASE
END



PRO tplottool,execcom=execcom,width=width
@tplot_com.pro

if not keyword_set(width) then width = 16
base = WIDGET_BASE(/COLUMN,title='Tplot Tool')
str_element,/add,wid,'tplot' , WIDGET_BUTTON(base, VALUE='Tplot')
tnames=''
str_element,tplot_vars,'options.varnames',tnames
str_element,/add,wid,'tnames', WIDGET_TEXT(base,VALUE=tnames,/editable, $
   /all,xsize=width,ysize=12,/scroll)
str_element,/add,wid,'tlimit', WIDGET_BUTTON(base, VALUE='Tlimit')
str_element,/add,wid,'trange', WIDGET_TEXT(base, /edit,ysize=2,xsize=width $
     ,VALUE=time_string(tplot_vars.options.trange))
str_element,/add,wid,'tzoom', WIDGET_BUTTON(base, VALUE='Zoom')
str_element,/add,wid,'ctime', WIDGET_BUTTON(base, VALUE='Ctime')
str_element,/add,wid,'names', WIDGET_BUTTON(base, VALUE='Names')
dnames = data_quants[1:*].name
str_element,/add,wid,'dnames_a',dnames
str_element,/add,wid,'dnames', CW_bgroup(base,dnames $
     ,x_scroll=width*10,y_scroll_size=8*30  $
     ,set_value=array_union(dnames,tnames) ge 0 $
     ,/scroll,/nonexcl,/return_name)
;str_element,/add,wid,'dlist', WIDGET_LIST(base,uvalue=dnames,value=dnames $
;      ,ysize=8,/multiple   )
;str_element,/add,wid,'fslider', CW_fslider(base,value=50.,/edit)
;str_element,/add,wid,'test', CW_test(base)
str_element,/add,wid,'exec', WIDGET_BUTTON(base,VALUE='Exec')
if n_elements(execcom) eq 0 then execcom=''
str_element,/add,wid,'exectext', WIDGET_TEXT(base,value=execcom,/editable, XSIZE=width)
str_element,/add,wid,'done',   WIDGET_BUTTON(base, VALUE='Done')
WIDGET_CONTROL, base, SET_UVALUE=wid
WIDGET_CONTROL, base, /REALIZE
printdat,wid
XMANAGER, 'tplottool', base,/no_block
END

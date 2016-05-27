PRO spec3d_widg_kill, id
;+
; NAME:
;       spec3d_widg_kill
;
; PURPOSE: 
;
;       This procedure cleans up after the spec3d_widg widget when it is
;       killed.  This is accomplished by removing the element of the
;       regarr list correspoinding to the killed widget.
;
;       *This procedure should only be called by xmanager.pro!
;
; CATEGORY:
;       
;       spec3d_tool
;
; CALLING SEQUENCE:
;       
;       spec3d_widg_kill, id
;
; INPUTS:
;       
;       id:  The widget id of the widget being killed.
;
; COMMON BLOCKS:
;
;       myregister: This common block exists to make the the variable
;                   myreg global.  The purpose of this variable is to
;                   register hydra_fitf widgets.  Specifically, myreg
;                   is an array of structures which contain the widget
;                   id of a hydra_fitf base widget and the widget id
;                   of the draw window which owns that slice window.
;                   This array facilitate multiple slice widgets being
;                   open at the same time.  With out this registry one
;                   would not be able to know which slice widget a
;                   given draw window click event should be sent to.  
;
; SIDE EFFECTS:
;       
;       The element of the regarr associated with the killed window is
;       erased.
;
; Written by:   Eric E. Dors, 1 March 1998.
;
; MODIFICATION HISTORY:
;
;-
COMMON  myregister, regarr
nelem = n_elements(regarr)
index = (where(regarr(*).winbase EQ id))(0)
IF (nelem EQ 1) THEN BEGIN
    regarr = -1
ENDIF ELSE IF (index EQ 0) THEN BEGIN
    regarr = regarr(1:*) 
ENDIF ELSE IF (index EQ nelem-1) THEN BEGIN
    regarr = regarr(0:nelem-2) 
ENDIF ELSE BEGIN
    regarr = [regarr(0:index-1), regarr(index+1:*)]
ENDELSE

END
;----------------------------------------------------------------------
FUNCTION add_to_regarr, regarr
;+
; NAME:
;       add_to_regarr
;
; PURPOSE:
;       
;       This function adds a new element to the regarr list when a new
;       slice widget is opened.
;
; CATEGORY:
;       
;       window_widg
;
; CALLING SEQUENCE:
;
;       result=add_to_regarr(regarr)
;
; INPUTS:
;
;       regarr: regarr is an array of structures which contain the
;               widget id of a hydra_fitf base widget and the widget
;               id of the draw window which owns that slice window.
;               This array facilitate multiple slice widgets being
;               open at the same time.  With out this registry one
;               would not be able to know which slice widget a given
;               draw window click event should be sent to.
;
; OUTPUTS:
;
;       regarr: The updated widget rigistration list is returned.
;
;       result: The index to the new entry in regarr.
;
; EXAMPLE:
;
;               index = add_to_regarr(regarr)
;
;
; Written by:   Eric E. Dors, 1 March 1998.
;
; MODIFICATION HISTORY:
;
;-

regvec = {regvect, window:-1L, winbase:-1L}

nelem = n_elements(regarr)
sz = size(regarr)
IF (nelem EQ 0) THEN BEGIN
    regarr = [regvec]
    index = 0
ENDIF ELSE IF ((nelem EQ 1) AND (sz(0) EQ 0)) THEN BEGIN
    regarr = [regvec]
    index = 0
ENDIF ELSE BEGIN
    regarr = [regarr, regvec]
    index = nelem
ENDELSE

return, index

END
;-----------------------------------------------------------------------------
PRO plot_spec, state, step = step, hard = hard, replot = replot


units = state.cnfg.units(state.cnfg.unit_sel)
lim =  state.cnfg.unit_specs(state.cnfg.unit_sel).lim

IF keyword_set(hard) THEN BEGIN
    plmode = state.pr.orient
    xsize = state.pr.pl_specs(plmode).xsize
    ysize = state.pr.pl_specs(plmode).ysize
    help, xsize, ysize
;    set_plot, 'ps'
    IF plmode THEN land =  1 ELSE port =  1
;    DEVICE,PORT = port, land = land,/INCHES,XSIZE= xsize, YSIZE= ysize $
;      ,XOFFSET=0.,YOFFSET = 0. ,FILENAME = state.pr.filename+'.ps' $
;      , /color, bits = 8

    popen, state.pr.filename, font = -1, port =  port, land = land, $
      xsize = xsize, ysize = ysize

    loadct2, 34
    print, 'color loaded'
    BOXPOS,NROWS=1,NCOLS=1,POS=P,MARG=[8,8],space=[0,0] $
      , plsize = [xsize, ysize]

ENDIF ELSE BOXPOS,NROWS=1,NCOLS=1,POS=P,MARG=[4,4],space=[0,0], plsize = [5, 5]


!p.position = p(0).pos


tidmax =  state.tidmax
tidsel =  state.tidsel

CASE state.cnfg.mode OF 
    1: BEGIN
        times=get_el2(/time)
        IF NOT keyword_set(step) THEN BEGIN
            ctime, t, np = 1
            tidmax = n_elements(times)
            tidsel = where(abs(t-times) EQ min(abs(t-times)), n)
        ENDIF ELSE t =  times(tidsel(0))
        IF NOT keyword_set(hard) AND NOT keyword_set(replot) THEN BEGIN
            timebar,state.tlast,/transient, color=state.tbar_col
            timebar,t,/transient, color=state.tbar_col
        ENDIF

        el=get_el2(index=tidsel(0))

        add_magf, el, 'wi_B3'
        add_vsw, el, 'mom_comp.VELOCITY'

;quick fix to load sc_pot
        sc_pot = data_cut('emom.SC_POT',t,count=count)
        add_str_element, el, 'sc_pot', sc_pot
        print, ''
        print, 'sc_pot = ', sc_pot
        print, ''

        spec3d,el, lim = lim, units = units, /pitch
    END
    4: BEGIN
        times=get_pl2(/time)
        IF NOT keyword_set(step) THEN BEGIN
            ctime, t, np = 1
            tidmax = n_elements(times)
            tidsel = where(abs(t-times) EQ min(abs(t-times)), n)
        ENDIF ELSE t =  times(tidsel(0))
        IF NOT keyword_set(hard) AND NOT keyword_set(replot) THEN BEGIN
            timebar,state.tlast,/transient, color=state.tbar_col
            timebar,t,/transient, color=state.tbar_col
        ENDIF

        pl=get_pl2(index=tidsel(0))
        spec3d,pl, lim = lim, units = units
    END
    8: BEGIN
        times=get_ph2(/time)
        IF NOT keyword_set(step) THEN BEGIN
            ctime, t, np = 1
            tidmax = n_elements(times)
            tidsel = where(abs(t-times) EQ min(abs(t-times)), n)
        ENDIF ELSE t =  times(tidsel(0))
        IF NOT keyword_set(hard) AND NOT keyword_set(replot) THEN BEGIN
            timebar,state.tlast,/transient, color=state.tbar_col
            timebar,t,/transient, color=state.tbar_col
        ENDIF

        pl=get_pl2(index=tidsel(0))
        ph = get_ph2(index=tidsel(0))
        spec3d,ph, lim = lim, units = units
    END
    12: BEGIN
        times=get_pl2(/time)
        IF NOT keyword_set(step) THEN BEGIN
            ctime, t, np = 1
            tidmax = n_elements(times)
            tidsel = where(abs(t-times) EQ min(abs(t-times)), n)
        ENDIF ELSE t =  times(tidsel(0))
        IF NOT keyword_set(hard) AND NOT keyword_set(replot) THEN BEGIN
            timebar,state.tlast,/transient, color=state.tbar_col
            timebar,t,/transient, color=state.tbar_col
        ENDIF

        pl=get_pl2(index=tidsel(0))
        ph = get_ph2(pl.time)
        spec3d,pl, lim = lim, units = units
        spec3d,ph,/over, units = units
   END
    ELSE: BEGIN
        ret=dialog_message(/error, dialog_parent = state.main_base, $
                           'ERROR: Mode selection not valid')
    END
ENDCASE

color=[8,!d.table_size-2]
colorbar2,zrange=[0.,180.],color=color
!p.position = 0

IF keyword_set(hard) THEN BEGIN
;    device, /close
    pclose
    set_plot, 'x'

    !P.BACKGROUND=255           ;INITIALIZE BACKGROUND TO WHITE
    !P.COLOR = 0                ;INITIALIZE DISPLAY

    IF state.pr.lp THEN spawn, 'lp -d'+state.pr.printer+' '$
      +state.pr.filename+'.ps'
ENDIF




state.tidmax = tidmax
state.tidsel = tidsel
state.tlast =  t

state.plflag = 1 ;flag activates prev and next buttons

RETURN
END

;-----------------------------------------------------------------------------
PRO init_spec_statestr, state, group = group, window = window

IF NOT keyword_set(group) THEN parent_id=0 ELSE parent_id=group

IF NOT keyword_set(window) THEN window =  0

;initialize limit structure
xlim, lim
ylim, lim

lim = {lim_str, xrange:fltarr(2), xstyle:1, yrange:fltarr(2), ystyle:1}
;units structure specifications
eflux_specs = {unitspecs, lim:lim, xcrange:fltarr(2), ycrange:fltarr(2)}
df_specs = eflux_specs
r_specs = eflux_specs
flux_specs = eflux_specs


cnfgdef =  {species:0, $      ;0/1 for electrons/ions
            mode_sel:[1, 0, 0, 0], $ ;data type mode selection (el,eh,pl,ph)
            mode:1, $           ;plot mode = total(2^mod_sel)
            unit_sel:0, $
            units:['eflux', 'df', 'rate', 'flux'], $
            unit_specs:[eflux_specs, df_specs, r_specs, flux_specs]}

cnfg =  cnfgdef
           

pl_specs_land =  {plspec, xsize:0., $
         ysize:0., $
         xoff:0., $
         yoff:0.}

pl_specs_port =  {plspec, xsize:8.5, $
         ysize:11., $
         xoff:0., $
         yoff:0.}



prdef = {filename:'spec3d', $
         orient:0, $            ;0/1 for portrait/landscape
         pl_specs:[pl_specs_port, pl_specs_land], $
         lp:0, $                ;set = 1 to print out hardcopy
         printer:'ctek0'}       ;printer to print out hardcopy


pr = prdef


cnfg_ids = {xmin:-1l, $
              xmax:-1l, $
              ymin:-1l, $
              ymax:-1l, $
            mode_buttons:-1l, $
            unit_buttons:-1l}

prcnfg_ids = {file:-1l, $
              xsize:-1l, $
              ysize:-1l, $
              xoff:-1l, $
              yoff:-1l, $
              plmode:-1l, $
              lp:-1l, $
              printer:-1l, $
              done:-1l}

col =  get_colors()

;main spec3d state structure
state = {regname:'', $          ;registered name of window widget
         cnfgdef:cnfgdef, $     ;default plot configuration definitions
         cnfg:cnfg, $           ;variable plot configuration definitions
         cnfg_base: -1L, $      ;config widget id
         cnfg_ids:cnfg_ids, $   ;config child widget ids
         plflag:0, $            ;plot mode = total(2^mod_sel)
         tidsel:-1l, $
         tidmin:0l, $
         tidmax:-1l, $
         tcurr:0d, $
         tlast:0d, $
         tbar_col:col.red, $
         prdef:prdef, $         ;default print settings
         pr:pr, $               ;variable print settings
         prcnfg_base: -1L, $      ;config widget id
         prcnfg_ids:prcnfg_ids, $ ;config child widget ids
         window: window, $      ;window label
         winidx: -1, $          ;plot window id
         parent_id: parent_id, $ ;parent window widget id
         main_base: -1L, $        ;window_widg base
         draw_x: 600, $         ;default draw widget size
         draw_y: 600, $         ;default draw widget size
         min_xsz: -1L, $        ;minimum allowed xsize of the window widget
         min_ysz: -1L, $        ;minimum allowed ysize of the window widget
         draw_id: -1L, $      ;draw widget base id
         button_base: -1L}      ;button bar widget id


RETURN
END
;-----------------------------------------------------------------------------
PRO spec_config_widg_event, event

child = widget_info(event.handler, /child)
widget_control, child, get_uvalue = handler
spec_child = widget_info(handler, /child)
widget_control, spec_child, get_uvalue = state


widget_control, event.id,get_uvalue = config_string

CASE config_string OF 
    'mode': BEGIN
        state.cnfg.mode_sel(event.value) = event.select  
        ind =  where(state.cnfg.mode_sel EQ 1)
        mode =  total(2^ind)
        IF mode NE state.cnfg.mode THEN BEGIN
            state.cnfg.mode = mode
            state.plflag = 0
            widget_control, spec_child, set_uvalue = state
        ENDIF
    END
    'units': BEGIN
        state.cnfg.unit_sel = event.value  
        set_spec_config, state;, update = 1
        widget_control, spec_child, set_uvalue = state
    END
    'xmin': BEGIN
        state.cnfg.unit_specs(state.cnfg.unit_sel).lim.xrange(0) = event.value
;        state.cnfgdef.unit_specs(state.cnfg.unit_sel).lim.xstyle = 1
        widget_control, spec_child, set_uvalue = state
    END
    'xmax': BEGIN
        state.cnfg.unit_specs(state.cnfg.unit_sel).lim.xrange(1) = event.value
;        state.cnfgdef.unit_specs(state.cnfg.unit_sel).lim.xstyle = 1
        widget_control, spec_child, set_uvalue = state
    END
    'ymin': BEGIN
        state.cnfg.unit_specs(state.cnfg.unit_sel).lim.yrange(0) = event.value
;        state.cnfgdef.unit_specs(state.cnfg.unit_sel).lim.ystyle = 1
        widget_control, spec_child, set_uvalue = state
    END
    'ymax': BEGIN
        state.cnfg.unit_specs(state.cnfg.unit_sel).lim.yrange(1) = event.value
;        state.cnfgdef.unit_specs(state.cnfg.unit_sel).lim.ystyle = 1
        widget_control, spec_child, set_uvalue = state
    END
    'done': BEGIN
        IF event.value THEN BEGIN
            widget_control, spec_child, set_uvalue = state
            widget_control, event.top, /destroy
        ENDIF ELSE BEGIN
            state.cnfg =  state.cnfgdef
            set_spec_config, state
            widget_control, spec_child, set_uvalue = state
        ENDELSE
    END
    ELSE: BEGIN
        ret=dialog_message(/error, dialog_parent = state.main_base, $
                         'ERROR: undefined event in spec3d_config_widg_event')
        print, 'ERROR: undefined event in window_widg_event'
    END

ENDCASE


;help, state

HELP, /STRUCTURE, event

RETURN
END
;-----------------------------------------------------------------------------
PRO set_spec_config, state, update = update

widget_control, state.cnfg_base, update=0
;stop
widget_control, state.cnfg_ids.xmin, set_value = state.cnfg.unit_specs(state.cnfg.unit_sel).lim.xrange(0)
widget_control, state.cnfg_ids.xmax, set_value = state.cnfg.unit_specs(state.cnfg.unit_sel).lim.xrange(1)

widget_control, state.cnfg_ids.ymin, set_value = state.cnfg.unit_specs(state.cnfg.unit_sel).lim.yrange(0)
widget_control, state.cnfg_ids.ymax, set_value = state.cnfg.unit_specs(state.cnfg.unit_sel).lim.yrange(1)

widget_control, state.cnfg_ids.mode_buttons, set_value = state.cnfg.mode_sel
widget_control, state.cnfg_ids.unit_buttons, set_value = state.cnfg.unit_sel


IF keyword_set(update) THEN BEGIN
    widget_control, state.cnfg_base, /update
ENDIF

RETURN
END
;-----------------------------------------------------------------------------
PRO spec_config_widg, handler, state

IF xregistered('spec_config_widg') THEN return

cnfg_base =  widget_base(title = 'Spec3d Configuration '+string(state.window, format = '(i2.2)'), /row)

state.cnfg_base =  cnfg_base

cbase1 = widget_base(cnfg_base, /column)
cbase2 = widget_base(cnfg_base, /column)

state.cnfg_ids.mode_buttons = cw_bgroup(cbase1,label_top = 'Select data type' $
                         , /nonexclusive, $
                            ['ELow', 'EHigh', 'PLow', 'PHigh'] $
                         , uvalue = 'mode', $
                            /frame,/row)

state.cnfg_ids.unit_buttons = cw_bgroup(cbase1,label_top = 'Select units' $
                         , /exclusive, state.cnfg.units, uvalue = 'units', $
                             /row)

xbase = widget_base(cbase1, /column, /base_align_center)
xrange_label = widget_label(xbase, value = 'Xrange' )
state.cnfg_ids.xmin = cw_field(xbase, uvalue = 'xmin', title = 'Min', /float, $
                /all_events)
state.cnfg_ids.xmax = cw_field(xbase, uvalue = 'xmax', title = 'Max', /float, $
                value = '', /all_events)

ybase = widget_base(cbase1, /column, /base_align_center)
yrange_label = widget_label(ybase, value = 'Yrange' )
state.cnfg_ids.ymin = cw_field(ybase, uvalue = 'ymin', title = 'Min', /float, $
                /all_events)
state.cnfg_ids.ymax = cw_field(ybase, uvalue = 'ymax', title = 'Max', /float, $
                /all_events)


;xran_field=cw_field(rbase,title='xrange: ', value = widg_info.pr.xsize $
;                       , /return_events,/float,xsize=5, ysize=1,/row)

;yran_field=cw_field(rbase,title='yrange: ', value = widg_info.pr.ysize $
;                       , /return_events,/float,xsize=5, ysize=1,/row)

cancel_buttons=cw_bgroup(cbase1, ['Default', 'Done'],row=1 $
                         , uvalue = 'done')

;save spec3d_tool event handler; to be used to retrieve state
;structure in spec_config_widg_event.
widget_control, cbase1, set_uvalue = handler

;IF NOT keyword_set(refresh) THEN BEGIN
widget_control, /realize, cnfg_base
xmanager, 'spec_config_widg', cnfg_base, /no_block $
  , group_leader = state.main_base
;ENDIF

RETURN
END
;------------------------------------------------------------------------------
PRO spec_prconfig_widg_event, event

child = widget_info(event.handler, /child)
widget_control, child, get_uvalue = handler
spec_child = widget_info(handler, /child)
widget_control, spec_child, get_uvalue = state

printdat, state.prcnfg_ids
CASE event.id OF
    state.prcnfg_ids.done: BEGIN
        CASE event.value OF
            'Default' : BEGIN
                state.pr = state.prdef
print, 'need to set up refresh mode'
                widget_control, spec_child, set_uvalue = state
            ENDCASE 
            'Done' : WIDGET_CONTROL, event.top, /DESTROY
            'Print' : plot_spec, state, /step, /hard

        ENDCASE
    ENDCASE
    state.prcnfg_ids.file: BEGIN
        state.pr.filename =  event.value(0)
        widget_control, spec_child, set_uvalue = state
    END
    state.prcnfg_ids.plmode: BEGIN
        state.pr.orient = event.select
        widget_control, spec_child, set_uvalue = state
    END
    state.prcnfg_ids.xsize: BEGIN
        state.pr.pl_specs(state.prcnfg_ids.plmode).xsize = event.value(0)
        widget_control, spec_child, set_uvalue = state
    END
    state.prcnfg_ids.ysize: BEGIN
        state.pr.pl_specs(state.prcnfg_ids.plmode).ysize = event.value(0)
        widget_control, spec_child, set_uvalue = state
    END
    state.prcnfg_ids.xoff: BEGIN
        state.pr.pl_specs(state.prcnfg_ids.plmode).xoff = event.value(0)
        widget_control, spec_child, set_uvalue = state
    END
    state.prcnfg_ids.yoff: BEGIN
        state.pr.pl_specs(state.prcnfg_ids.plmode).yoff = event.value(0)
        widget_control, spec_child, set_uvalue = state
    END
    state.prcnfg_ids.lp: BEGIN
        state.pr.lp =  event.select
        widget_control, spec_child, set_uvalue = state
    END
    state.prcnfg_ids.printer: BEGIN
        state.pr.printer =  event.value(0)
        widget_control, spec_child, set_uvalue = state
    END
    ELSE:
ENDCASE

help, event.value(0)

HELP, /STRUCTURE, event
RETURN
END
;------------------------------------------------------------------------------
PRO spec_prconfig_widg, handler, state

IF xregistered('spec_prconfig_widg') THEN return

prcnfg_base = WIDGET_BASE(TITLE = "Spec3d Print Configuration",/column)

state.prcnfg_base = prcnfg_base
cbase1=widget_base(prcnfg_base,/column)

rbase1=widget_base(prcnfg_base,/row)
rbase2=widget_base(prcnfg_base,/row)
cbase2=widget_base(rbase2,/column)



plmode = state.pr.orient
xsize = state.pr.pl_specs(plmode).xsize
ysize = state.pr.pl_specs(plmode).ysize
xoff = state.pr.pl_specs(plmode).xoff
yoff = state.pr.pl_specs(plmode).yoff


;stop
state.prcnfg_ids.file =cw_field(cbase1,title='Filename:   ' $
             , value = state.pr.filename, /all_events $
             , /string,xsize=20, ysize=1,/row)

state.prcnfg_ids.plmode=cw_bgroup(cbase1,['Portrait', 'Landscape'], label_left='Orientation: ', /exclusive, set_value = plmode, /return_name, row = 1)

state.prcnfg_ids.xsize=cw_field(cbase1,title='xsize: ' $
                        , value = xsize $
                       , /all_events,/float,xsize=5, ysize=1,/row)

state.prcnfg_ids.ysize=cw_field(cbase1,title='ysize: ', value = ysize $
                       , /all_events,/float,xsize=5, ysize=1,/row)

state.prcnfg_ids.xoff=cw_field(cbase1,title='xoffset: ', value = xoff $
                       , /all_events,/float,xsize=5, ysize=1,/row)

state.prcnfg_ids.yoff=cw_field(cbase1,title='yoffset: ', value = yoff $
                       , /all_events,/float,xsize=5, ysize=1,/row)

state.prcnfg_ids.lp=cw_bgroup(rbase1,/nonexclusive, $
  ['lp'], column = 1,/return_index, set_value = [state.pr.lp])

state.prcnfg_ids.printer=cw_field(rbase1,title='Printer: ', value = state.pr.printer $
                       , /all_events,/string,xsize=8, ysize=1,/row)

state.prcnfg_ids.done=cw_bgroup(cbase2, ['Done', 'Default', 'Print'],row=1 $
                                , /return_name)

;save spec3d_tool event handler; to be used to retrieve state
;structure in spec_config_widg_event.
widget_control, cbase1, set_uvalue = handler

widget_control, /realize, prcnfg_base
xmanager, 'spec_prconfig_widg', prcnfg_base, /no_block $
  , group_leader = state.main_base


RETURN
END
;-----------------------------------------------------------------------------
PRO spec3d_tool_event, event
;COMMON fpitch_draw_info, slice_base, slice_bases, lock_buttons

child = widget_info(event.handler, /child)
widget_control, child, get_uvalue = state

widget_control, event.id, get_uvalue = button_string

;printdat, state

;widget_control, /hourglass

CASE button_string OF
    'button_plot': BEGIN
        wset, state.winidx
        plot_spec, state
        widget_control, child, set_uvalue= state
   END
    'button_replot': BEGIN
        IF state.plflag THEN BEGIN
            wset, state.winidx
            plot_spec, state, /step, /replot
        ENDIF ELSE ret=dialog_message(dialog_parent = state.main_base, $
                      'Plot 3D distribution first to activate this button')
    END
    'button_config': begin
        spec_config_widg, event.handler, state
        set_spec_config, state
        widget_control, child, set_uvalue= state
    END
    'button_next': BEGIN 
        IF state.plflag THEN BEGIN
            state.tidsel = state.tidsel + 1 < state.tidmax
            wset, state.winidx
            plot_spec, state, /step
            widget_control, child, set_uvalue= state
        ENDIF ELSE ret=dialog_message(dialog_parent = state.main_base, $
                           'Plot spectra first to activate this button')
   END
    'button_prev': BEGIN
        IF state.plflag THEN BEGIN
            state.tidsel = state.tidsel - 1 > state.tidmin
            wset, state.winidx
            plot_spec, state, /step
            widget_control, child, set_uvalue= state
        ENDIF ELSE ret=dialog_message(dialog_parent = state.main_base, $
                           'Plot spectra first to activate this button')
    END
    'button_unlocked': begin
        lock_buttons=1
    end
    'button_locked': begin
        lock_buttons=0
    end
    'button_done': BEGIN
        timebar,state.tlast,/transient, color=state.tbar_col
        widget_control, event.top, /destroy
    END
    'button_help': BEGIN
        which_gen, 'hydra_fpitch.help', file = file
        helpfile = file
        xdisplayfile, helpfile(0)
    END
    'button_print': BEGIN
        plot_spec, state, /step, /hard
    END
    'button_pr config': BEGIN
       spec_prconfig_widg, event.handler, state
       widget_control, child, set_uvalue= state
    END
    'button_xloadct': begin
        xloadct
    end
    'button_stop': begin
        message, 'Stopping, type .con to continue', /cont
        stop, ' '
    end
    'main_base': BEGIN 
        bbase = widget_info(state.button_base, /geometry)
        sbase = widget_info(state.base_id, /geometry)

        newdraw_x = event.x
        newdraw_y = event.y

        state.draw_x = newdraw_x 
        state.draw_y = newdraw_y 

        widget_control, state.base_id, $
          xsize = state.draw_x+2*bbase.margin, $
          ysize = state.draw_y+bbase.scr_ysize+4*bbase.margin+bbase.ypad

        widget_control, state.slice_draw, xsize = state.draw_x, $
          ysize = state.draw_y

;*******need to replot data here*********

        widget_control, child, set_uvalue = state
    END
    ELSE: BEGIN
                ret=dialog_message(/error, dialog_parent = state.base_id, $
                           'ERROR: undefined event in window_widg_event')
                print, 'ERROR: undefined event in window_widg_event'
    END
ENDCASE



END

;-------------------------------------------------------------------------
PRO spec3d_widg, state

sbxsize = 600
sbysize = 600

button_height= ( sbysize*0.85 ) / 10.
button_width= sbxsize / 6.

main_base = widget_base(title = state.regname, row = 1, $
                          /tlb_size_events, $
                         uvalue = 'main_base')
 
button_names= ['Plot', 'Replot', 'Config', 'Prev', 'Next', 'Print' $
               , 'Pr config', 'Unlocked','Help', 'Done']
;button_names= [  button_names,strarr( 10 - n_elements( button_names ) ) ]

;create button widget base child process used to store state structure
button_base = widget_base(main_base,xsize= button_width, ysize= button_height, column = 1, /frame)

;create draw widget base child process
draw_base = widget_base(main_base, column = 1)

;create control panel buttons
for i=0,n_elements(button_names)-1 do begin 
    button = widget_button( button_base, value=button_names(i), $
                      xsize= button_width, ysize= button_height, $
                      uvalue='button_'+strlowcase(button_names(i)), $
                      font=font )
    if button_names(i) eq 'Unlocked' then lock_id= button
endfor

;create draw widget
draw_id = widget_draw(draw_base, xsize = sbxsize, $
                         ysize = sbysize*0.9, xoffset=button_width, yoffset=0 )

widget_control, main_base, /realize
widget_control, draw_id, get_value = win_id
state.winidx = win_id

erase, get_color_index( 'white' )

state.main_base = main_base       ;save main base
state.button_base = button_base ;save id of first child process
state.draw_id = draw_id      ;save slice_draw button: used in window resize

widget_control, button_base, set_uvalue = state
xmanager, 'spec3d_tool', main_base, cleanup='spec3d_widg_kill', /no_block

IF keyword_set(intrpt) THEN stop
RETURN
END
;-----------------------------------------------------------------------------
;-
; NAME:
;	SPEC3D_TOOL
;
; PURPOSE:
;	This procedure provide a widget interface to the spec3d
;	plotting routine.
;
; CATEGORY:
;	Widgets.
;
; CALLING SEQUENCE:
;
;	SPEC3D_TOOL,window=window,wi_name = wi_name, group = group
;
; KEYWORD PARAMETERS:
;	window:	Window number for spec3d_tool.
;
;	wi_name: optional tool title.
;
;	group:  group hierarchy to which widget belong.
;
; OUTPUTS:
;	None.
;
; RESTRICTIONS:
;	Must be used with tplot window already activated
;
; MODIFICATION HISTORY:
; 	Written by:	Arthur J. Hull, 8/2/99.
;-
;$Header$
;$Log$

PRO spec3d_tool, wi_name = wi_name, group = group, window = window $
                  , intrpt = intrpt
COMMON  myregister, regarr

toolname =  'SPEC3D'

;widget header
IF (n_elements(window) NE 0) THEN BEGIN
    IF keyword_set(wi_name) THEN regname = wi_name+string(window, format = '(i2.2)') ELSE regname = toolname+' '+string(window, format = '(i2.2)')
ENDIF ELSE BEGIN
    IF keyword_set(wi_name) THEN regname = wi_name $
    ELSE regname = toolname
ENDELSE

;check to see if window already registered i.e. does it exist
IF NOT xregistered(regname) THEN BEGIN
    index = add_to_regarr(regarr)
    init_spec_statestr, state, group = group, window = window
ENDIF ELSE BEGIN 
    index = where(regarr(*).window EQ window)
    child = widget_info(regarr(index).winbase, /child)
    widget_control, child, get_uvalue = state
    widget_control, state.draw_id, get_value = win_id ;gets window number
    state.winidx = win_id
    wset, state.winidx
    widget_control, child, set_uvalue = state
    return
ENDELSE 

state.regname = regname

spec3d_widg, state

regarr(index).window = window
regarr(index).winbase = state.main_base


IF keyword_set(intrpt) THEN stop
RETURN
END



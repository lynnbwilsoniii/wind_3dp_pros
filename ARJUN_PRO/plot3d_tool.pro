PRO plot3d_widg_kill, id
;+
; NAME:
;       plot3d_widg_kill
;
; PURPOSE: 
;
;       This procedure cleans up after the plot3d_widg widget when it is
;       killed.  This is accomplished by removing the element of the
;       regarr list correspoinding to the killed widget.
;
;       *This procedure should only be called by xmanager.pro!
;
; CATEGORY:
;       
;       plot3d_tool
;
; CALLING SEQUENCE:
;       
;       plot3d_widg_kill, id
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
PRO plot_dist3d, state, step = step, hard = hard

IF keyword_set(hard) THEN BEGIN

    plmode = state.pr.orient
    pl_specs = state.pr.pl_specs(plmode)
    xsize = state.pr.pl_specs(plmode).xsize
    ysize = state.pr.pl_specs(plmode).ysize
    
    IF plmode THEN land =  1 ELSE port =  1
        
    popen, state.pr.filename, font = -1, port =  port, land = land, $
      xsize = xsize, ysize = ysize
         ; xoff = state.pr.pl_specs(state.pr.orient).xoff, $
          ;yoff = state.pr.pl_specs(state.pr.orient).yoff
 
    loadct2, 34
ENDIF ELSE wset, state.winidx

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
        IF NOT keyword_set(hard) THEN BEGIN
            timebar,state.tlast,/transient, color=state.tbar_col
            timebar,t,/transient, color=state.tbar_col
        ENDIF
        el=get_el2(index=tidsel(0))
        add_magf, el, 'wi_B3'
;        add_vsw, el, 'emom.VELOCITY'
;        add_vsw, el, 'PL.MOM.P.VELOCITY'
        add_vsw, el, 'mom_comp.VELOCITY'
        add_ddata, el
;quick fix to load sc_pot
        sc_pot = data_cut('emom.SC_POT',t,count=count)
        add_str_element, el, 'sc_pot', sc_pot
        print, ''
        print, 'sc_pot = ', sc_pot
        print, ''

        eli=convert_vframe(el,/int) ;converts to distribution function
        eli.phi=eli.phi+.01
        plot3d_options,tri=1
        plot3d,eli, bnc = state.cnfg.bnc
    END
    4: BEGIN
        times=get_pl2(/time)
        IF NOT keyword_set(step) THEN BEGIN
            ctime, t, np = 1
            tidmax = n_elements(times)
            tidsel = where(abs(t-times) EQ min(abs(t-times)), n)
        ENDIF ELSE t =  times(tidsel(0))
        IF NOT keyword_set(hard) THEN BEGIN
            timebar,state.tlast,/transient, color=state.tbar_col
            timebar,t,/transient, color=state.tbar_col
        ENDIF

        pl=get_pl2(index=tidsel(0))
        plot3d,pl
    END
    8: BEGIN
        times=get_ph2(/time)
        IF NOT keyword_set(step) THEN BEGIN
            ctime, t, np = 1
            tidmax = n_elements(times)
            tidsel = where(abs(t-times) EQ min(abs(t-times)), n)
        ENDIF ELSE t =  times(tidsel(0))
        IF NOT keyword_set(hard) THEN BEGIN
            timebar,state.tlast,/transient, color=state.tbar_col
            timebar,t,/transient, color=state.tbar_col
        ENDIF

        ph = get_ph2(index=tidsel(0))
        plot3d,ph
    END
    ELSE: BEGIN
        ret=dialog_message(/error, dialog_parent = state.main_base, $
                           'ERROR: Mode selection not valid')
    END
ENDCASE


IF keyword_set(hard) THEN BEGIN
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
PRO init_plot3d_statestr, state, group = group, window = window

IF NOT keyword_set(group) THEN parent_id=0 ELSE parent_id=group

IF NOT keyword_set(window) THEN window =  0

;configuration defaults
cnfgdef =  {species:0, $      ;0/1 for electrons/ions
            mode_sel: 0, $ ;data type mode selection (el=0,eh=1,pl=2,ph=3)
            mode:1, $           ;plot mode = total(2^mod_sel)
            bnc:1, $            ;
            units:'eflux', $
            bins:0}

cnfg =  cnfgdef
          

;landscape plot specifications
pl_specs_land =  {plspec, xsize:0., $
         ysize:0., $
         xoff:0., $
         yoff:0.}

;portrait plot specifications
pl_specs_port =  {plspec, xsize:6., $
         ysize:6., $
         xoff:0., $
         yoff:4.}


;printer defaults
prdef = {filename:'plot3d', $
         orient:0, $            ;0/1 for portrait/landscape
         pl_specs:[pl_specs_port, pl_specs_land], $
         lp:0, $                ;set = 1 to print out hardcopy
         printer:'ctek0'}       ;printer to print out hardcopy
pr = prdef

;print configuration widget ids
prcnfg_ids = {file:-1l, $
              xsize:-1l, $
              ysize:-1l, $
              xoff:-1l, $
              yoff:-1l, $
              plmode:-1l, $
              lp:-1l, $
              printer:-1l, $
              done:-1l}

;col =  get_colors()

;main plot3d state structure
state = {regname:'', $          ;registered name of window widget
         cnfgdef:cnfgdef, $     ;default plot configuration definitions
         cnfg:cnfg, $           ;variable plot configuration definitions
         cnfg_base: -1L, $      ;config widget id
;         cnfg_ids:cnfg_ids, $   ;config child widget ids
         plflag:0, $            ;plot mode = total(2^mod_sel)
         tidsel:-1l, $
         tidmin:0l, $
         tidmax:-1l, $
         tcurr:0d, $
         tlast:0d, $
         tbar_col:75, $
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
PRO plot3d_config_widg_event, event

child = widget_info(event.handler, /child)
widget_control, child, get_uvalue = handler;, /no_copy
plot3d_child = widget_info(handler, /child)
widget_control, plot3d_child, get_uvalue = state;, /no_copy


widget_control, event.id,get_uvalue = config_string

CASE config_string OF 
    'mode': BEGIN
        state.cnfg.mode_sel = event.value
;        ind =  where(state.cnfg.mode_sel EQ 1)
        mode =  total(2^event.value)
        IF mode NE state.cnfg.mode THEN BEGIN
            state.cnfg.mode = mode
            state.plflag = 0
            widget_control, plot3d_child, set_uvalue = state
        ENDIF
    END
    'bdir': BEGIN
        state.cnfg.bnc = -1 + event.value*2
        widget_control, plot3d_child, set_uvalue = state
    END
    'done': BEGIN
        IF event.value THEN BEGIN
            widget_control, plot3d_child, set_uvalue = state
            widget_control, event.top, /destroy
        ENDIF ELSE print, 'default button not set up yet'
    END
    ELSE: BEGIN
        ret=dialog_message(/error, dialog_parent = state.main_base, $
                         'ERROR: undefined event in plot3d_config_widg_event')
        print, 'ERROR: undefined event in window_widg_event'
    END

ENDCASE


;help, state

HELP, /STRUCTURE, event

RETURN
END
;-----------------------------------------------------------------------------
PRO plot3d_config_widg, handler, state, refresh = refresh

IF xregistered('plot_config_widg') THEN return

cnfg_base =  widget_base(title = 'Plot3d Configuration '+string(state.window, format = '(i2.2)'), /row)

state.cnfg_base =  cnfg_base

cbase1 = widget_base(cnfg_base, /column)
cbase2 = widget_base(cnfg_base, /column)

mode_buttons = cw_bgroup(cbase1, ['ELow', 'EHigh', 'PLow', 'PHigh'] $
                         , label_top = 'Select data type', /exclusive $
                         , uvalue = 'mode' $
                         , set_value = state.cnfg.mode_sel, /frame,row=1)

bdirvalue =  (state.cnfg.bnc + 1)/2 ;= -1 + event.value*2

bdir_buttons=cw_bgroup(cbase1, ['-1', '+1'], label_left = 'bnc: ',row=1 $
                         , uvalue = 'bdir', /exclusive $
                       , set_value = bdirvalue)

cancel_buttons=cw_bgroup(cbase1, ['Default', 'Done'],row=1 $
                         , uvalue = 'done')

;save plot3d_tool event handler; to be used to retrieve state
;structure in plot3d_config_widg_event.
widget_control, cbase1, set_uvalue = handler

IF NOT keyword_set(refresh) THEN BEGIN
    widget_control, /realize, cnfg_base
    xmanager, 'plot3d_config_widg', cnfg_base, /no_block $
      , group_leader = state.main_base
ENDIF

RETURN
END
;------------------------------------------------------------------------------
PRO plot3d_prconfig_widg_event, event

child = widget_info(event.handler, /child)
widget_control, child, get_uvalue = handler
plot3d_child = widget_info(handler, /child)
widget_control, plot3d_child, get_uvalue = state

;printdat, state.prcnfg_ids
CASE event.id OF
    state.prcnfg_ids.done: BEGIN
        CASE event.value OF
            'Default' : BEGIN
                state.pr = state.prdef
print, 'need to set up refresh mode'
                widget_control, plot3d_child, set_uvalue = state
            ENDCASE 
            'Done' : WIDGET_CONTROL, event.top, /DESTROY
            'Print' : plot_dist3d, state, /step, /hard

        ENDCASE
    ENDCASE
    state.prcnfg_ids.file: BEGIN
        state.pr.filename =  event.value(0)
        widget_control, plot3d_child, set_uvalue = state
    END
    state.prcnfg_ids.plmode: BEGIN
        state.pr.orient = event.select
        widget_control, plot3d_child, set_uvalue = state
    END
    state.prcnfg_ids.xsize: BEGIN
        state.pr.pl_specs(state.prcnfg_ids.plmode).xsize = event.value(0)
        widget_control, plot3d_child, set_uvalue = state
    END
    state.prcnfg_ids.ysize: BEGIN
        state.pr.pl_specs(state.prcnfg_ids.plmode).ysize = event.value(0)
        widget_control, plot3d_child, set_uvalue = state
    END
    state.prcnfg_ids.xoff: BEGIN
        state.pr.pl_specs(state.prcnfg_ids.plmode).xoff = event.value(0)
        widget_control, plot3d_child, set_uvalue = state
    END
    state.prcnfg_ids.yoff: BEGIN
        state.pr.pl_specs(state.prcnfg_ids.plmode).yoff = event.value(0)
        widget_control, plot3d_child, set_uvalue = state
    END
    state.prcnfg_ids.lp: BEGIN
        state.pr.lp =  event.select
        widget_control, plot3d_child, set_uvalue = state
    END
    state.prcnfg_ids.printer: BEGIN
        state.pr.printer =  event.value(0)
        widget_control, plot3d_child, set_uvalue = state
    END
    ELSE:
ENDCASE

help, event.value(0)

HELP, /STRUCTURE, event
RETURN
END
;------------------------------------------------------------------------------
PRO plot3d_prconfig_widg, handler, state

IF xregistered('plot3d_prconfig_widg') THEN return

prcnfg_base = WIDGET_BASE(TITLE = "Plot3d Print Configuration",/column)

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

;save plot3d_tool event handler; to be used to retrieve state
;structure in plot3d_config_widg_event.
widget_control, cbase1, set_uvalue = handler

widget_control, /realize, prcnfg_base
xmanager, 'plot3d_prconfig_widg', prcnfg_base, /no_block $
  , group_leader = state.main_base


RETURN
END
;-----------------------------------------------------------------------------
PRO plot3d_tool_event, event
;COMMON fpitch_draw_info, slice_base, slice_bases, lock_buttons

child = widget_info(event.handler, /child)
widget_control, child, get_uvalue = state

widget_control, event.id, get_uvalue = button_string

;widget_control, /hourglass

CASE button_string OF
    'button_plot': BEGIN
        plot_dist3d, state
        widget_control, child, set_uvalue= state
    END
    'button_replot': BEGIN
        IF state.plflag THEN BEGIN
            plot_dist3d, state, /step
;            widget_control, child, set_uvalue= state
        ENDIF ELSE ret=dialog_message(dialog_parent = state.main_base, $
                      'Plot 3D distribution first to activate this button')
    END
    'button_config': begin
        plot3d_config_widg, event.handler, state
        widget_control, child, set_uvalue= state
    END
    'button_next': BEGIN 
        IF state.plflag THEN BEGIN
            state.tidsel = state.tidsel + 1 < state.tidmax
            plot_dist3d, state, /step
            widget_control, child, set_uvalue= state
        ENDIF ELSE ret=dialog_message(dialog_parent = state.main_base, $
                      'Plot 3D distribution first to activate this button')
   END
    'button_prev': BEGIN
        IF state.plflag THEN BEGIN
            state.tidsel = state.tidsel - 1 > state.tidmin
            plot_dist3d, state, /step
            widget_control, child, set_uvalue= state
        ENDIF ELSE ret=dialog_message(dialog_parent = state.main_base, $
                      'Plot 3D distribution first to activate this button')
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
    END
    'button_print': plot_dist3d, state, /step, /hard
    'button_pr config': BEGIN
        plot3d_prconfig_widg, event.handler, state
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
PRO plot3d_widg, state

sbxsize = 600
sbysize = 600

button_height= ( sbysize*0.85 ) / 10.
button_width= sbxsize / 6.

main_base = widget_base(title = state.regname, row = 1, $
                          /tlb_size_events, $
                         uvalue = 'main_base')
 
button_names= ['Plot','Replot', 'Config', 'Prev', 'Next', 'Print' $
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
xmanager, 'plot3d_tool', main_base, cleanup='plot3d_widg_kill', /no_block

IF keyword_set(intrpt) THEN stop
RETURN
END
;-----------------------------------------------------------------------------
;+
; NAME:
;	PLOT3D_TOOL
;
; PURPOSE:
;	This procedure provides a widget interface to the plot3d
;	plotting routine.
;
; CATEGORY:
;	Widgets.
;
; CALLING SEQUENCE:
;
;	PLOT3D_TOOL,window=window,wi_name = wi_name, group = group
;
; KEYWORD PARAMETERS:
;	window:	Window number for plot3d_tool.
;
;	wi_name: optional tool title.
;
;	group:  group hierarchy to which widget belong.
;
; OUTPUTS:
;	None.
;
;
; SIDE EFFECTS:
;	Describe "side effects" here.  There aren't any?  Well, just delete
;	this entry.
;
; RESTRICTIONS:
;	Must be used with tplot window already activated
;
; MODIFICATION HISTORY:
; 	Written by:	Arthur J. Hull, 8/2/99.
;-
;$Header$
;$Log$

PRO plot3d_tool, wi_name = wi_name, group = group, window = window $
                  , intrpt = intrpt
COMMON  myregister, regarr

toolname =  'PLOT3D'

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
    init_plot3d_statestr, state, group = group, window = window
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

plot3d_widg, state

regarr(index).window = window
regarr(index).winbase = state.main_base


IF keyword_set(intrpt) THEN stop
RETURN
END



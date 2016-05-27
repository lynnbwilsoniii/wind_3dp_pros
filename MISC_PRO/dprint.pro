;+
; PROJECT:
;       General Purpose
;       SOHO - CDS/SUMER
;       THEMIS
;
; NAME:
;       DPRINT
;
; PURPOSE:
;       Diagnostic PRINT (activated only when DEBUG reaches DLEVEL)
;
; EXPLANATION:
;       This routine acts similarly to the PRINT command, except that
;       it is activated only when the common block variable DEBUG is
;       set to be equal to or greater than the debugging level set by
;       DLEVEL (default to 0).  It is useful for debugging.
;       If DLEVEL is not provided it uses a persistent (common block) value set with the
;       keyword SETDEBUG.
;
; CALLING SEQUENCE (typically written into code):
;       DPRINT, v1 [,v2 [,v3...]]] [,format=format] [,dlevel=dlevel] [,verbose=verbose]
;             The values of v1,v2,v3 will only be printed if verbose >= dlevel
;
; CALLING SEQUENCE to change options (typically typed from IDL command line - Don't put these lines in code!!!)
;       DPRINT, setdebug=2   ; define persistent debug level (2 is typical level)
;       DPRINT, SETVERBOSE=2 ; Same as above
;       DPRINT, print_trace=[0,1,2, or 3]  ; Display program trace info in subsequent calls to DPRINT
;       DPRINT, /print_dlevel      ; Display current dlevel and verbose settings.
;       DPRINT, /print_dtime       ; Display delta time between DPRINT statements.
;
; INPUTS:
;       V1, V2, ... - List of variables to be printed out (20 max).
;
; OPTIONAL INPUTS:
;       None.
;
; OUTPUTS:
;       All input variables are printed out on the screen (or the
;       given unit)
;
; OPTIONAL Keywords:
;       FORMAT - Output format to be used
;       UNIT   - Output unit through which the variables are printed. If
;                missing, the standard output (i.e., your terminal) is used.
;
; KEYWORD PARAMETERS:
;       DLEVEL = DLEVEL - An integer indicating the debugging level; defaults to 0
;       VERBOSE = VERBOSE - An integer indicating current verbosity level, If verbose is set
;       it will override the current value of SETVERBOSE, for the specific call of dprint in which
;       it is set.
;       SETVERBOSE=value            - Set debug level to value
;       SETDEBUG=value            - Same as SETVERBOSE
;       GETDEBUG=named variable   - Get current debug level
;       DWAIT = NSECONDS  ; provides an additional constraint on printing.
;              It will only print if more than NSECONDS has elapsed since last dprint.
;       CHECK_EVENTS= [0,1]    -    If set then WIDGET events are captured and processed within DPRINT
;       BREAK_DETECTED= named variable   - Used to break out of user routines (see DPRINTTOOL)
;
;
; COMMON BLOCKS:
;       DPRINT_COM.
;
; RESTRICTIONS:
;     - Changed see SETDEBUG above
;       Can print out a maximum of 20 variables (depending on how many
;          is listed in the code)
;
; SIDE EFFECTS:
;       Generally None.
;
; CATEGORY:
;       Utility, miscellaneous
;
; PREVIOUS HISTORY:
;       Written March 18, 1995, Liyun Wang, GSFC/ARC
;
; MODIFICATION HISTORY:
;       Version 1, Liyun Wang, GSFC/ARC, March 18, 1995
;       Version 2, Zarro, SM&A, 30 November 1998 - added error checking
;       Version 3, Zarro, (EIT/GSFC), 23 Aug 2000 - removed DATATYPE calls
;       Version 4, Larson  (2007) stripped out calls to "execute" so that it can be called from IDL VM
;                          Fixed bug that allows format keyword to be used.
;                          Added SETDEBUG keyword and GETDEBUG keyword
;                          Added DWAIT keyword
;                          Added PRINT_TRACE,PRINT_DTIME,PRINT_DLEVEL
;                          Added Widget options
; $LastChangedBy: davin-win $
; $LastChangedDate: 2012-02-22 17:20:18 -0800 (Wed, 22 Feb 2012) $
; $LastChangedRevision: 9830 $
; $URL: svn+ssh://thmsvn@ambrosia.ssl.berkeley.edu/repos/ssl_general/tags/tdas_7_00/misc/SSW/dprint.pro $
;
;-



;function dprint_header,sublevel=sublevel  ,delta_time=delta_time
;  common dprint_com, dprint_struct
;
;  delta_time=2.1345
;  dlevel = 3   &dbg=2
;  prefix = ''
;  if dprint_struct.print_dlevel then  prefix=[prefix, string(dlevel,dbg,format='(i0.0,"/",i0.0)') ]
;  if dprint_struct.print_time   then  prefix=[prefix, time_string(tformat=dprint_struct.tformat,newtime,/local)]
;  if dprint_struct.print_dtime  then  prefix=[prefix, string(format='(f6.3)',delta_time) ]
;  if dprint_struct.print_trace  then  begin
;    stack = scope_traceback(/structure,system=1)
;    level = n_elements(stack) ; -1
;;    if level gt 200 then begin
;;       Message,"Stack is too large! Runaway recursion?"
;;    endif
;    if keyword_set(sublevel) then level -= sublevel
;    level = level > 1
;    stack = stack[0:level-1]
;    stacknames=stack.routine + string(stack.line,format='("(",i0,")")')
;    prefix = [prefix,stacknames]
;  endif
;  return,prefix
;end


PRO DPRINT,v1,v2,v3,v4,v5,v6,v7,v8,v9,v10,  $
           v11,v12,v13,v14,v15,v16,v17,v18,v19,v20, $
           format=format, $            ;  Like the format string in print
           dlevel=dlevel,  $           ;  Overides the debug level
           verbose=verbose,$
           setdebug=setdebug, $
           setverbose=setverbose, $
           getdebug=getdebug,$
           filename=filename, $
           print_dlevel=print_dlevel,  $
           check_events=check_events,  $
           no_check_events=no_check_events,  $
           get_check_events=get_check_events,  $
           print_time = print_time   , $
           print_dtime =print_dtime,   $
           print_trace= print_trace,  $
;           display_routine= display_routine,  $           ; user specified routine to display messages
;           set_display_routine = set_display_routine, $
           display_object = display_object,  $
           set_display_object = set_display_object,  $
           status=status, $
           break_requested = break_requested,  $
           dwait=dwait,  $
           reset=reset,  $
           sublevel=sublevel, $
           get_dprint_struct = get_dprint_struct, $
           help = help, $
           phelp=phelp,  $
           unit=unit

   on_error,2

   common dprint_com, dprint_struct
   newtime = systime(1)

   if not keyword_set(dprint_struct) or keyword_set(reset) then dprint_struct={  $
       debug:getenv('IDL_DEBUG') ? FIX(getenv('IDL_DEBUG')) : 2, $
       lasttime:newtime, $
       lastflushtime:0d, $
       print_dlevel:0, $
       print_time:0,  $
;       display_routine:'', $
       display_object: obj_new(),  $
       tformat:'',   $
       print_dtime:0,  $
       print_trace:0,  $
       file_unit:-1,    $
       file_name:'',   $
       max_lines: uint(-1),   $       ; maximum # of lines to be displayed
       check_events:0, $
       widget_id:0l,   $
       widget_lasttime:0d, $
       widget_dwait:0.1d,  $
       break_flag:0,   $
       ireturn:0  }

  ; if dprint_struct.ireturn then return        ; do nothing (used to avoid unlimited recursion)

;   if not keyword_set(dprint_struct.lasttime) then dprint_struct.lasttime = newtime
;   if not keyword_set(dprint_struct.lastflushtime) then dprint_struct.lastflushtime = newtime
   getdebug = dprint_struct.debug
;   if n_elements(file_unit_c) eq 0 then file_unit_c = -1  ; standard output
   np = N_PARAMS()
;   if np eq 0 then begin
      if n_elements(print_dlevel) ne 0 then dprint_struct.print_dlevel=print_dlevel
      if n_elements(print_dtime)  ne 0 then begin
          dprint_struct.print_dtime =print_dtime
          dprint_struct.lasttime = newtime
      endif
      if n_elements(print_time)   ne 0 then begin
         if size(/type,print_time) eq 7 then  dprint_struct.tformat = print_time
         dprint_struct.print_time = keyword_set(print_time)
      endif
      if n_elements(print_trace)  ne 0 then dprint_struct.print_trace = print_trace
      if ((n_elements(set_display_object) ne 0) && (scope_level() eq 2 )) then dprint_struct.display_object = set_display_object
;      if n_elements(set_display_routine) ne 0 then dprint_struct.display_routine = set_display_routine
      if n_elements(filename) ne 0 then begin
          if dprint_struct.file_unit gt 0  then free_lun,dprint_struct.file_unit
          dprint_struct.file_unit = -1
          if keyword_set(filename)  then begin
              openw,unit,filename,/get_lun
              dprint_struct.file_unit = unit
              fs = fstat(unit)
              dprint_struct.file_name_c = fs.name
          endif
      endif
      get_dprint_struct = dprint_struct
      get_check_events = dprint_struct.check_events
      if n_elements(check_events) ne 0 then dprint_struct.check_events = check_events
      if n_elements(setdebug) ne 0 then dprint_struct.debug = setdebug
      if n_elements(setverbose) ne 0 then dprint_struct.debug = setverbose
      if keyword_set(status) then printdat,dprint_struct
;      return
;   endif

   if keyword_set(help) then printdat,dprint_struct

   IF N_ELEMENTS(dlevel) EQ 0 THEN dlevel = 0
   delta_time = newtime-dprint_struct.lasttime

   if keyword_set(dprint_struct.check_events && ~keyword_set(no_check_events)) then begin
      event= widget_event(/nowait)
   endif

   if keyword_set(dwait) and not keyword_set(dprint_struct.break_flag) then begin
      if dwait ge delta_time  then return
   endif

   if newtime-dprint_struct.lastflushtime gt 10. then begin
      dprint_struct.lastflushtime = newtime
      wait,.01    ; This wait statement is the only way I know to flush the print buffer. This is a low overhead.
   endif

   dbg = (n_elements(verbose) ne 0 && verbose lt 99) ? verbose : dprint_struct.debug
   IF dlevel GT dbg and not keyword_set(dprint_struct.break_flag) THEN RETURN

   dprint_struct.ireturn = 1

   prefix = ''

   if dprint_struct.print_dlevel then  prefix=[prefix, string(dlevel,dbg,format='(i0.0,"/",i0.0)') ]
   if dprint_struct.print_time   then  prefix=[prefix, time_string(tformat=dprint_struct.tformat,newtime,/local)]
   if dprint_struct.print_dtime  then  prefix=[prefix, string(format='(f6.3)',delta_time) ]
   if dprint_struct.print_trace ne 0  then  begin
     stack = scope_traceback(/structure,system=0)
     level = n_elements(stack) -1
;     if level gt 200 then begin
;        Message,"Stack is too large! Runaway recursion?"
;     endif
     if keyword_set(sublevel) then level -= sublevel
     level = level > 1
     stack = stack[0:level-1]
;     levels = indgen(level)
;     stacknames=strtrim(levels,2)+'  '+stack.routine + string(stack.line,format='(" (",i0,")")')
     stacknames=stack.routine + string(stack.line,format='("(",i0,")")')
     case dprint_struct.print_trace of
        1: if level ge 2 then stacknames = stacknames[level-1]
        2: if level ge 2 then stacknames[0:level-2] = '  '
        4: stacknames = string(/print,format='(i2," ",a-32)',level,stacknames[level-1])
        else:   ; do nothing
     endcase
     prefix = [prefix,stacknames]
;     if level eq 1 and stack[0].line le 1 then prefix=''     ; Calls from command line  (Kludge)
  endif
  if keyword_set(prefix) then prefix = prefix[1:*]

    if 1 then begin

    endif

   dprint_struct.lasttime = newtime

   if dprint_struct.file_unit gt 0 then begin   ; perform safety check
       fs = fstat(dprint_struct.file_unit)
       if fs.open eq 0 or fs.name ne dprint_struct.file_name then begin
           dprint_struct.file_unit = -1
           dprint_struct.file_name = ''
       endif
   endif
   u = n_elements(unit) ? unit : dprint_struct.file_unit

   prefix_str = keyword_set(prefix) ? strjoin(prefix+': ') : ''
;   if keyword_set(prefix) then print,prefix_str,format='(a,$)'

   if keyword_set(phelp) then begin    ; experimental option - this may change
        vnames0=scope_varname(v1,v2,v3,v4,v5,v6,v7,v8,v9,v10,v11,v12)
        vnames1=scope_varname(v1,v2,v3,v4,v5,v6,v7,v8,v9,v10,v11,v12,level=-1)
        for i=0,np-1 do begin
           printdat,unit=u,scope_varfetch(vnames0[i]),varname=vnames1[i],output=txt,recursemax=phelp
           text = (i eq 0) ? txt : [text,txt]
        endfor
   endif else begin

   case np of
   0:  text = ''  ;string(/print,format=format)
   1:  text = string(/print,format=format,v1)
   2:  text = string(/print,format=format,v1,v2)
   3:  text = string(/print,format=format,v1,v2,v3)
   4:  text = string(/print,format=format,v1,v2,v3,v4)
   5:  text = string(/print,format=format,v1,v2,v3,v4,v5)
   6:  text = string(/print,format=format,v1,v2,v3,v4,v5,v6)
   7:  text = string(/print,format=format,v1,v2,v3,v4,v5,v6,v7)
   8:  text = string(/print,format=format,v1,v2,v3,v4,v5,v6,v7,v8)
   9:  text = string(/print,format=format,v1,v2,v3,v4,v5,v6,v7,v8,v9)
   10: text = string(/print,format=format,v1,v2,v3,v4,v5,v6,v7,v8,v9,v10)
   11: text = string(/print,format=format,v1,v2,v3,v4,v5,v6,v7,v8,v9,v10,v11)
   12: text = string(/print,format=format,v1,v2,v3,v4,v5,v6,v7,v8,v9,v10,v11,v12)
   13: text = string(/print,format=format,v1,v2,v3,v4,v5,v6,v7,v8,v9,v10,v11,v12,v13)
   14: text = string(/print,format=format,v1,v2,v3,v4,v5,v6,v7,v8,v9,v10,v11,v12,v13,v14)
   15: text = string(/print,format=format,v1,v2,v3,v4,v5,v6,v7,v8,v9,v10,v11,v12,v13,v14,v15)
   16: text = string(/print,format=format,v1,v2,v3,v4,v5,v6,v7,v8,v9,v10,v11,v12,v13,v14,v15,v16)
   17: text = string(/print,format=format,v1,v2,v3,v4,v5,v6,v7,v8,v9,v10,v11,v12,v13,v14,v15,v16,v17)
   18: text = string(/print,format=format,v1,v2,v3,v4,v5,v6,v7,v8,v9,v10,v11,v12,v13,v14,v15,v16,v17,v18)
   19: text = string(/print,format=format,v1,v2,v3,v4,v5,v6,v7,v8,v9,v10,v11,v12,v13,v14,v15,v16,v17,v18,v19)
   20: text = string(/print,format=format,v1,v2,v3,v4,v5,v6,v7,v8,v9,v10,v11,v12,v13,v14,v15,v16,v17,v18,v19,v20)
   else: text = 'Get real! 20 variables is enough!'
   endcase

   endelse

   ;msg = prefix_str+text
   prefix_len = strlen(prefix_str)
   spaces = prefix_len gt 0 ? string(replicate(32b,prefix_len)) : ''
;   for i=0,n_elements(msg)-1 do  printf,u,msg[i]

;   str_element,dprint_struct,'display_routine',disprout
;   if size(/type,display_routine) eq 7 then disprout = display_routine
;   for i=0,n_elements(disprout)-1 do if keyword_set(disprout[i]) then begin
;       call_procedure,disprout[i],text,prefix=prefix_str
;   endif

   if n_elements(text) gt dprint_struct.max_lines then begin
        text = text[0:dprint_struct.max_lines-1]
        text[dprint_struct.max_lines-1] = 'Output Terminated.'
   endif

   dispobj = dprint_struct.display_object                             ; grab default object from structure
   if keyword_set(display_object) then dispobj = display_object  ; grab alternative object(s) from keyword
   for i=0,n_elements(dispobj)-1 do begin
        if (obj_valid(dispobj[i]) && obj_hasmethod(dispobj[i],'print')) then begin
            (dispobj[i])->print,prefix=prefix_str,text
        endif else begin                                             ; Default output (typical usage)
            for j=0,n_elements(text)-1 do  printf,u,(j eq 0 ? prefix_str : spaces) + text[j]
        endelse
   endfor


   if keyword_set(dwait) then wait, .01      ; This  line is used to flush the print buffer (update the display)


   if keyword_set(dprint_struct.widget_id) and newtime-dprint_struct.widget_lasttime ge dprint_struct.widget_dwait then begin
        dprint_struct.widget_lasttime = newtime
        dprinttool,/update,text,prefix=prefix ,/sublevel
   endif

   dprint_struct.ireturn=0

   if keyword_set(dprint_struct.break_flag) and arg_present(break_requested) then begin
       dprint_struct.break_flag = 0
       break_requested=1
       print,strjoin(prefix,': ')+' Break Detected'

   endif
   return

END

;---------------------------------------------------------------------------
; End of 'dprint.pro'.
;---------------------------------------------------------------------------



; .run
;pro testrout,str,prefix=pre
;print,(keyword_set(pre) ? '('+pre+') ' : '') + '"'+str+'"'
;end

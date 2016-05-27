PRO see,module,debug=debug,editor=editor
 
  IF NOT keyword_set(debug) THEN debug = 0
  n_errors = 0

  IF NOT keyword_set(module) THEN BEGIN 
    read,'Input module name, or hit return to quit:  ',module
    IF string(module) EQ '' THEN return 
  ENDIF 

  module = strtrim(module,2)

  procs = routine_info()          ;get a list of compiled procedures
  funcs = routine_info(/func)     ; "  "  "   "     "     functions
  wp = where(procs EQ strupcase(module)) ;see if module is a compiled procedure
  wf = where(funcs EQ strupcase(module)) ; "  "    "    "  "    "     function 
  func = -1
  IF wp[0] NE -1 THEN func = 0    ;module is a compiled procedure
  IF wf[0] NE -1 THEN func = 1    ;  "    "  "    "     function

  catch,resolve_error
  IF resolve_error NE 0 THEN BEGIN 
    n_errors = n_errors + 1
    IF n_errors GT 2 THEN BEGIN 
      print,'See:  too many errors.  Exiting.  Try setting DEBUG=1'
      return
    ENDIF 
    IF debug NE 0 THEN print,'Error '+strtrim(n_errors,2)+':  '+!ERROR_STATE.MSG
    IF n_errors EQ 1 AND func EQ -1 THEN resolve_routine,module,/is_function
  ENDIF 
    
  IF func EQ -1 THEN BEGIN 
;    q = !quiet
;    !quiet = 1
    IF n_errors EQ 0 THEN resolve_routine,module
    func = n_errors
    IF func GT 1 THEN BEGIN 
;      print,string2('See:  '+module+' not found.  Please compile.',/bold)
      print,'See:  '+module+' not found.  Please compile.'
    
      return
    ENDIF 
;    !quiet = q
  ENDIF

  file = routine_info(module,/source,func=func)
  IF file.path EQ '' THEN BEGIN 
;      print,string2('See:  '+module+' not found.  Please compile.',/bold)
      print,string('See:  '+module+' not found.  Please compile.')
      return
  ENDIF 
  print,'Opening: ',file
  ;spawn,'/disks/zephyr/home/fvm/bin/less '+file.path
  if not keyword_set(editor) then editor=getenv('EDITOR')
  if not keyword_set(editor) then editor='gedit'

  spawn,editor+' '+file.path+' &'

END

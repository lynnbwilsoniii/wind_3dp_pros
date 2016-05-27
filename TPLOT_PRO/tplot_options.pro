;+
;PROCEDURE:  tplot_options [,string,value]
;NAME:
;  tplot_options
;PURPOSE:
;  Sets global options for the "tplot" routine.
;INPUTS:
;   string: 	option to be set.
;   value:	value to be given the option.
;KEYWORDS:
;   HELP:      Display current options structure.
;   VAR_LABEL:   String [array], variable[s] to be used for plot labels.
;   FULL_TRANGE: 2 element double array specifying the full time range.
;   TRANGE:      2 element double array specifying the current time range.
;   DATANAMES:  String containing names of variable to plot
;   REFDATE:    Reference date.  String with format: 'YYYY-MM-DD'.
;         This reference date is used with the gettime subroutine.
;   WINDOW:     Window to be used for all time plots. (-1 specifies current 
;       window.
;   VERSION:    plot label version. (1 or 2 or 3)
;   TITLE:	string used for the tplot title
;   OPTIONS:	tplot options structure to be passed to replace the current
;		structure.
;   GET_OPTIONS:returns the new tplot options structure.
;EXAMPLES:
;   tplot_options,'ynozero',1          ; set all panels to YNOZERO=1
;   tplot_options,'title','My Data'    ; Set title
;   tplot_options,'xmargin',[10,10]    ; Set left/right margins to 10 characters
;   tplot_options,'ymargin',[4,2]      ; Set top/bottom margins to 4/2 lines
;   tplot_options,'position',[.25,.25,.75,.75]  ; Set plot position (normal coord)
;   tplot_options,'wshow',1             ; de-iconify window with each tplot
;   tplot_options,'version',3          ; Sets the best time ticks possible
;   tplot_options,'window',0           ; Makes tplot always use window 0
;   tplot_options,/help                ; Display current options
;   tplot_options,get_options=opt      ; get option structure in the variable opt.
;
;SEE ALSO:  "TPLOT", "OPTIONS", "TPLOT_COM"
;CREATED BY:  Davin Larson   95/08/29
;LAST MODIFICATION: 01/10/08
;VERSION: @(#)tplot_options.pro	1.16
;-
pro tplot_options,string,value  $
  ,datanames=datanames  $
  ,var_label=var_label $
  ,version=version  $
  ,title = title  $
  ,refdate = refdate  $
  ,full_trange = tr_full   $
  ,trange = tr    $ 
  ,options = opts  $ 
  ,get_options = get_opts $
  ,help=help  $
  ,window = wind
@tplot_com

if n_elements(opts)      ne 0 then str_element,tplot_vars,'options',opts,$
	/add_replace
str_element,tplot_vars,'options',tplot_opts
if data_type(tplot_opts) ne 8 then str_element,tplot_vars,'options',0,$
	/add_replace
if data_type(string) eq 7 then str_element,tplot_vars,'options.'+string,value,$
	/add_replace

if data_type(datanames) eq 7 then $
      str_element,tplot_vars,'options.datanames',datanames,/add_replace

if not keyword_set(tplot_vars) then begin
   options ={datanames:'',varnames:'',trange_full:dblarr(2),trange:dblarr(2)}
   settings={varnames:'',trange_old:dblarr(2),trange_cur:dblarr(2)}
   tplot_vars= {options:options,settings:settings}
endif

if n_elements(title)     ne 0 then str_element,tplot_vars,'options.title',$
	title,/add_replace

if n_elements(var_label) ne 0 then str_element,tplot_vars,'options.var_label',$
	var_label,/add_replace
if n_elements(version)   ne 0 then str_element,tplot_vars,'options.version',$
	version,/add_replace
if n_elements(refdate)   ne 0 then str_element,tplot_vars,'options.refdate',$
	strmid(time_string(refdate),0,10),/add_replace

if n_elements(tr)        ne 0 then str_element,tplot_vars,'options.trange',$
	tr,/add_replace
if n_elements(tr_full)   ne 0 then str_element,tplot_vars,$
	'options.trange_full',tr_full,/add_replace
if n_elements(wind)      ne 0 then str_element,tplot_vars,'options.window',$
	wind,/add_replace

str_element,tplot_vars,'options.trange_full',t_f
if n_elements(t_f)   eq 0 then str_element,$
	tplot_vars,'options.trange_full',double([0.,0.]),/add_replace

str_element,tplot_vars,'settings.trange_old',t_o
if n_elements(t_o)    eq 0 then str_element,$
	tplot_vars,'settings.trange_old',tplot_vars.options.trange_full,$
	/add_replace

str_element,tplot_vars,'options.trange',t_r
if n_elements(t_r)        eq 0 then str_element,$
	tplot_vars,'options.trange',tplot_vars.settings.trange_old,/add_replace

if keyword_set(help) then begin
   help,/st,tplot_vars.options 
endif

get_opts = tplot_vars.options
end

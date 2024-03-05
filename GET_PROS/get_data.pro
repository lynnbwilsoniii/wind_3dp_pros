;+
;PROCEDURE:  get_data , name, time, data, values
;PURPOSE:
;   Retrieves the data and or limit structure associated with a name handle.
;   This procedure is used by the "TPLOT" routines.
;INPUT:  name    scalar string or index of TPLOT variable
;        time	 named variable to return time values.
;        data    named variable to return data (y) values.
;        values  named variable to return additional (v) values.
;KEYWORDS:
;   DATA:   named variable to hold the data structure.
;   LIMITS: named variable to hold the limits structure.
;   DLIMITS: named variable to hold the default limits structure.
;   ALIMITS: named variable to hold the combined limits and default limits
;            structures.
;   DTYPE: named variable to hold the data type value.  These values are:
;		0: undefined data type
;		1: normal data in x,y format
;		2: structure-type data in time,y1,y2,etc. format
;		3: an array of tplot variable names
;   PTR:   named variable to hold pointers to data structure.
;   INDEX:  named variable to hold the name index.  This value will be 0
;     if the request was unsuccessful.
;   TRANGE: named variable to hold the time range (output variable only,
;           does not affect data returned).
;
;SEE ALSO:	"STORE_DATA", "TPLOT_NAMES", "TPLOT"
;
;CREATED BY:	Davin Larson
;MODIFICATION BY: 	Peter Schroeder
;LAST MODIFICATION:	@(#)get_data.pro	1.28 02/04/17
; $LastChangedBy: jimm $
; $LastChangedDate: 2016-11-01 13:30:00 -0400 (Tue, 01 Nov 2016) $
; $LastChangedRevision: 22247 $
; $URL: svn+ssh://thmsvn@ambrosia.ssl.berkeley.edu/repos/spdsoft/trunk/general/tplot/get_data.pro $
;
;-
pro get_data,name, time, data, values, $
    data_str = data_str, $
    limits_str = lim_str, $
    alimits_str = alim_str, $
    dlimits_str = dlim_str, $
    ptr_str = ptr_str, $
    index = index, $
    dtype = dtype, $
    trange = trange

@tplot_com.pro
time = 0
data = 0
values = 0
data_str = 0
lim_str = 0
alim_str = 0
dlim_str = 0
dtype = 0
ptr_str = 0
trange = 0

index = find_handle(name)

;if index eq 0 then begin
;   auto_load,name,success=s
;   if s ne 0 then index = find_handle(name,tagname)
;endif

if index ne 0 then begin
   dq = data_quants[index]
   if arg_present(data) or arg_present(time) or arg_present(values) or $
   	arg_present(data_str) then begin
   		if size(/type,*dq.dh) eq 8 then begin
; 	  		mytags = tag_names_r(*dq.dh)             Too goofy to be useful!!!   see similar line in store_data
 	  		mytags = tag_names(*dq.dh)
	   		for i=0,n_elements(mytags)-1 do begin
	   			str_element,*dq.dh,mytags[i],foo
   				if ptr_valid(foo) then $
   				    str_element,data_str,mytags[i],*foo,/add
	   		endfor
	   	endif else data_str = *dq.dh
                if size(/type,data_str) ne 8 then $
                   dprint, dlevel = 6, 'No Data Structure for: '+name
   endif

   if arg_present(lim_str) or arg_present(alim_str) then begin
      lim_str = *dq.lh
      if size(/type, lim_str) ne 8 then $
         dprint, dlevel = 6, 'No Limits Structure for: '+name
   endif
   if arg_present(dlim_str) or arg_present(alim_str) then begin
      dlim_str = *dq.dl
      if size(/type, dlim_str) ne 8 then $
         dprint, dlevel = 6, 'No Dlimits Structure for: '+name
   endif

   extract_tags,alim_str,dlim_str,/replace
   extract_tags,alim_str,lim_str,/replace

   if arg_present(trange) then trange = dq.trange

;   if data_type(data_str) eq 7 and ndimen(data_str) eq 0 then $
;      	get_data,data_str+'',data=data_str ; get links

;   if data_type(data_str) eq 10 then data_str = *data_str

; Old style: get x,y and v tag names:
	str_element,data_str,'x',value= time
	str_element,data_str,'y',value= data
	str_element,data_str,'v',value= values

; New style: get time, data tag names:
	str_element,data_str,'time',value= time
	str_element,data_str,'data',value= data
	if size(/type,*dq.dh) eq 8 then ptr_str = *dq.dh

str_element,dq,'dtype',dtype
endif else dprint, dlevel = 6, 'Variable '+string(name)+ ' Not Found'
return
end


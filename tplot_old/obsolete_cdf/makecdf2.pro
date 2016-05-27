;+
; PROCEDURE:
;     makecdf2, data, sktfile=sktfile, cdffile=cdffile, $
;         gattributes=gattr, vattributes=vattr, overwrite=overwrite, $
;	  status=status, verbose=verbose
;
; PURPOSE:
;     Creates a CDF file from a structure of arrays
;
; INPUT:
;     data:
;     (this sounds complicated to describe, but see the EXAMPLE below)
;         The structure containing the data to write out to CDF.
;         The 'data' structure will contain exactly one field for each variable that
;         is to be written to the output CDF (with the exception that additional
;         variables 'Epoch' and 'Time_PB5' will be written to the CDF file, if they
;         have been specified in the skeleton file input via the 'sktfile' keyword
;         parameter).
;         Each field of the 'data' structure is itself a structure containing exactly
;         4 fields, named 'name', 'value', 'recvary', and 'fill'.
;         The 'name' field of the n-th field of 'data' should be the name of the n-th
;         CDF variable in the output CDF file.  The 'value' field of the n-th field of
;         'data' should be an array containing the values of the n-th variable (the
;         i-th element of the array is the value at the i-th time).  The 'recvary'
;         field of the n-th field of 'data' should be 1 if the n-th variable is time
;         varying and 'recvary' should be 0 if the n-th variable is time invariant.
;         Time invariant variables are generally things like various kinds of array
;         descriptors that don't depend on the time.  The 'fill' field of the n-th field
;         of 'data' should be 1 if the variable should have its values overwritten with
;         ISTP standard FILLVAL's for all times for which data are missing or invalid,
;         as specified by the values of the 'quality_flag' variable, otherwise, 'fill'
;         should be zero.
;
;         NOTE: the first field of the 'data' structure must contain the time values
;         in seconds since 01-01-1970/00:00:00 UT.
;
;         NOTE: all of the time variant variable arrays in the 'data' structure must
;         be based on the exact same time array (that set of times given in the first
;         field of the 'data' structure).  If you have a set of arrays to write out
;         to CDF which are not all based on the same time array, you must first do
;         the appropriate interpolations to generate a set of arrays that are all
;         based on the same time array.  See the routine 'time_align.pro' for one
;         simple way to do this with tplot variables.
;
; KEYWORDS:
;     sktfile:
;         name of the skeleton file that is to be used to specify the global attributes
;         and their values, variable attributes and their values, and variable types and
;         sizes.  The value used for this parameter should not include any '.skt' suffix.
;     cdffile:
;         Name of CDF file to be created.  Do not include any '.cdf' suffix.
;     gattributes:
;         FIX
;     vattributes:
;         FIX
;     overwrite:
;         if set, overwrite any existing CDF file with the specified name (default
;         is to not overwrite any such existing file).
;     status:
;         status is 0 on successful return, nonzero on unsuccessful return.
;         A routine that calls makecdf2 should in general use the status keyword parameter
;         and verify that the CDF write has completed successfully.
;     verbose:
;	  if set, display diagnostic messages.  Useful for debugging.
;  
; EXAMPLE:
;     Consider making a CDF file of the FAST EESA summary data, as is done by the IDL
;     routine 'fast_e_summary.pro'.  Assume that an appropriate skeleton file named
;     'fa_k0_ees_template.skt' has been created, containing the appropriate variable
;     definitions and the appropriate global and variable scope attributes and their
;     values.  Assume that all the standard data necessary has been stored with
;     'store_data' in IDL.
;
;     Then to make the CDF file named 'fa_k0_ees.cdf'containing the variables 'unix_time',
;     'el_0', 'el_90', 'el_180', 'el_en', 'el_low', 'el_low_pa', 'el_high',
;     'el_high_pa', 'JEe', and 'Je', you could give the following IDL commands:
;
;         > get_data, 'el_0',     data=el_0
;         > get_data, 'el_90',    data=el_90
;         > get_data, 'el_180',   data=el_180
;         > get_data, 'el_low',   data=el_low
;         > get_data, 'el_high',  data=el_high
;         > get_data, 'JEe',      data=JEe
;         > get_data, 'Je',       data=Je
;         >
;         > data = {unix_time:  {name:'unix_time',  value:el_0.x,    recvary:1, fill:0}, $
;         >         el_0:       {name:'el_0',       value:el_0.y,    recvary:1, fill:1}, $
;         >         el_90:      {name:'el_90',      value:el_90.y,   recvary:1, fill:1}, $
;         >         el_180:     {name:'el_180',     value:el_180.y,  recvary:1, fill:1}, $
;         >         el_en:      {name:'el_en',      value:el_0.v,    recvary:1, fill:1}, $
;         >         el_low:     {name:'el_low',     value:el_low.y,  recvary:1, fill:1}, $
;         >         el_low_pa:  {name:'el_low_pa',  value:el_low.v,  recvary:1, fill:1}, $
;         >         el_high:    {name:'el_high',    value:el_high.y, recvary:1, fill:1}, $
;         >         el_high_pa: {name:'el_high_pa', value:el_high.v, recvary:1, fill:1}, $
;         >         JEe:        {name:'JEe',        value:JEe.y,     recvary:1, fill:1}, $
;         >         Je:         {name:'Je',         value:Je.y,      recvary:1, fill:1}}
;         >
;         > makecdf2, data, sktfile='fa_k0_ees_template', $
;               cdffile='fa_k0_ees', status=status, /overwrite
;         > if status ne 0 then begin
;         >     message, /info, 'makecdf2 failed.'
;         >     return
;         > endif
;
;     Note that in the above, the name of the field containing time was named 'unix_time',
;     and not 'time'.  In general, CDF variables can be named anything you want, but there
;     are a few special exceptions.  
;     IF A CDF CONTAINS AN 'EPOCH' VARIABLE, THE FOLLOWING VARIABLE NAMES SHOULD NOT BE
;     USED:  TIME, YEAR, MONTH, DAY, HOUR, MINUTE, SECOND, MSEC, IYEAR, IMONTH, IDAY,
;     IHOUR, IMINUTE, ISECOND, IMSEC.  THIS IS BECAUSE MANY STANDARD CDF ANALYSIS TOOLS
;     USE THESE NAMES FOR SPECIFIC PURPOSES.  This is because of certain assumptions
;     made by various software tools developed by CDHF.
;
; SEE ALSO:
;     "time_align"
;
; VERSION: @(#)makecdf2.pro	1.2 98/08/13
;-


pro makecdf2, data, $
    sktfile=sktfile, $
    cdffile=cdffile, $
    gattributes=gattr, $
    vattributes=vattr, $
    verbose=verbose, $
    overwrite=overwrite, $
    status=status

status = -1
if not keyword_set(cdffile) then begin
    message, /info, "The keyword parameter 'cdffile' must be set"
    return
endif

if keyword_set(verbose) then verbose = fix(verbose) else verbose = fix(0)

if keyword_set(overwrite) then begin
  on_ioerror, create
  id = cdf_open(cdffile)
  cdf_delete,id
  create:
  on_ioerror,null
  cmd_overwrite = '-delete '
endif else begin
  cmd_overwrite = '-nodelete '
endelse

if keyword_set(sktfile) then begin
    ; attempt to create the cdf file from the skt file silently, returning the command status
    cmd = '$CDF_BIN/skeletoncdf -cdf ' + cdffile + ' ' + cmd_overwrite + ' ' + sktfile
    cmd = '(' + cmd + ' ); echo $status'
    if verbose then begin
	print, 'makecdf2: creating CDF from sktfile with cmd = ', cmd
    endif
    spawn, cmd, stat, count=stat_size
    if stat(stat_size - 1) eq 0 then begin
        id = cdf_open(cdffile)
    endif else begin
	for k = 0, stat_size - 2 do print, stat(k)
	print, 'skeletoncdf failed to initialize CDF file using SKT file = ', sktfile
	return
    endelse
endif else begin
    id = cdf_create(cdffile, /SINGLE)
endelse

;
; If the 'Epoch' variable has been defined in the skeleton table, write its values
;
if cdf_var_exists(id, 'Epoch') then begin
    epoch0 = 719528.d * 24.* 3600. * 1000.  ;Jan 1, 1970
    epoch = data.(0).value * 1000. + epoch0
    cdf_varput, id, 'Epoch', epoch
endif

;
; If 'Time_PB5' variable was defined via the skeleton table, write its values
;
if cdf_var_exists(id, 'Time_PB5') then begin
    pb5 = time_pb5(data.(0).value)
    pb5_shifted = dimen_shift(pb5, -1)
    cdf_varput, id, 'Time_PB5', pb5_shifted
    ; leave out the writing of the min and max to SCALEMIN and SCALEMAX for now
endif

;
; If 'unix_time' variable was defined via the skeleton table, write its min/max
;
; leave out for now

;
; If 'quality_flag' variable was defined via the skeleton table, write its values
;
if verbose then print, 'makecdf2: starting processing of quality_flag'
if cdf_var_exists(id, 'quality_flag') then begin
    quality_flag = make_quality(data)
    cdf_varput, id, 'quality_flag', quality_flag
endif


;
; If the 'post_gap_flag' variable has been defined in the skeleton table, write its values
; post_gap_flag will be 1 for the first data point for which both (quality ne 255) and
; (quality of previous data point eq 255), else post_gap_flag = 0.
;
if verbose then print, 'makecdf2: starting processing of post_gap_flag'
if cdf_var_exists(id, 'post_gap_flag') then begin
    quality_shift = shift(quality_flag, 1)
    quality_shift(0) = 0
    post_gap_flag = (quality_flag ne 255) and (quality_shift eq 255)
    cdf_varput, id, 'post_gap_flag', post_gap_flag
endif


;
; Write out all the data, as Z Variables
;
iszvar = 1
for i = 0, n_tags(data) - 1 do begin
    name  = data.(i).name
    value = data.(i).value
    fill  = data.(i).fill
    value_element = reform(value(0,*,*,*,*))
    sz = size(value_element)
    if sz(0) eq 1 then begin
	if sz(1) eq 1 then value_element = value_element(0)
    endif
    type  = data_type(value_element)
    dims  = dimen(value_element)
    ndims = ndimen(value_element)
    recnovary = data.(i).recvary eq 0
    if cdf_var_exists(id, name) then begin

    ; set all elements of the value to be stored to the type-correct FILLVAL
    ; wherever quality_flag = 255.
    	if fill eq 1 then begin
	        case type of
		    1: fillval = byte(-128)
		    2: fillval = fix(-32768)
		    3: fillval = long(-2147483648)
		    4: fillval = float(-1.0e31)
		    5: fillval = double(-1.0d31)
 	       endcase
 	       times = where(quality_flag eq 255, count)
	        if count gt 0 then value(times,*,*,*,*,*,*) = fillval
	endif


    ; shift the value array so that the time index is the last index, instead of the first.
;    value_shifted = dimen_shift(value, -1)
	cdf_varput, id, name, value, /zvariable
    endif
endfor


;
; if the gattr keyword parameter is set, set the gattrs appropriately
;
if keyword_set(gattr) then begin
    n_gattrs = n_tags(gattr)
    for i = 0, n_gattrs - 1 do begin
	attr_name = gattr.(i).name
	attr_value = gattr.(i).value
	attr_replace = gattr.(i).replace
	if not cdf_attr_exists(id, attr_name) then begin
	    attr_id = cdf_attcreate(id, attr_name, /GLOBAL_SCOPE)
        endif
	if cdf_attr_exists(id, attr_name, scope=scope) then begin
	    if scope ne 'GLOBAL_SCOPE' then begin
		message, /info, 'attribute ' + attr_name + $
		    ' in gattr keyword param is not GLOBAL_SCOPE'
		return
	    endif
	endif
        cdf_attinq, id, attr_name, name, scope, max_entry, max_zentry
	if attr_replace then begin
	    if max_entry eq -1 then begin
		attr_entry = 0
	    endif else begin
		attr_entry = max_entry
	    endelse
	endif else begin
	    attr_entry = max_entry + 1
        endelse
        cdf_attput, id, attr_name, attr_entry, attr_value
    endfor
endif


;
; if the vattr keyword parameter is set, set the vattrs appropriately
;
if keyword_set(vattr) then begin
    n_vattrs = n_tags(vattr)
    for i = 0, n_vattrs - 1 do begin
	attr_name  = vattr.(i).name
	var_name   = vattr.(i).entry
	attr_value = vattr.(i).value
	if not cdf_attr_exists(id, attr_name) then begin
	    attr_id = cdf_attcreate(id, attr_name, /VARIABLE_SCOPE)
        endif
	if cdf_attr_exists(id, attr_name, scope=scope) then begin
	    if scope ne 'VARIABLE_SCOPE' then begin
		message, /info, 'attribute ' + attr_name + $
		    ' in vattr keyword param is not VARIABLE_SCOPE'
		return
	    endif
	endif
        cdf_attinq, id, attr_name, name, scope, max_entry, max_zentry
        cdf_attput, id, attr_name, var_name, attr_value
    endfor
endif

cdf_close, id
status = 0
return

end


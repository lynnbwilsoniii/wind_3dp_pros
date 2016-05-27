;+
; FUNCTION: dummy = cdf_save_vars(cdf_structure,new_cdf_name)
; PURPOSE:  To dump data and metadata from an IDL structure into a CDF file.
;		The structure format is the structure produced by cdf_load_vars.pro
; INPUTS:   cdf_structure : IDL structure defined by cdf_load_vars.pro
;	    new_cdf_name  : a string to name the new CDF file with
; OUTPUTS:  CDF file named by the new_cdf_name input
; EXAMPLE:  dummy = cdf_save_vars(cdfi,'newcdf.cdf')
;
; Written by: Matt Davis  
;
;Note: To use this routine you must have the CDF_EPOCH/CDF_EPOCH16 bug patch on your IDL6.3
;and if you are using Solaris you need to be in 32-bit mode NOT 64-bit (ie, idl -32)
;-

;------------------------------------------------------------------------------------------

function cdf_save_vars, cdf_structure, new_cdf_name

;check input
;-----------
if not keyword_set(cdf_structure) then begin
  print, "No valid input."
  print, "Example: dummy=cdf_save_vars(idl_structure,'newcdf.cdf')"
  return,1
endif

if not keyword_set(new_cdf_name) then begin
  print, "Need name for output CDF."
  print, "Example: dummy=cdf_save_vars(idl_structure,'newcdf.cdf')"
  return,1
endif

;create CDF file
;---------------

file=new_cdf_name
cdf_parameters=create_struct(cdf_structure.inq.encoding,1,cdf_structure.inq.decoding,1,cdf_structure.inq.majority,1)
id=cdf_create(file,/clobber,/single_file,_extra=cdf_parameters)


;add global attributes
;---------------------

ga_names=tag_names(cdf_structure.g_attributes)

;make names ISTP compliant
ga=strupcase(strmid(ga_names,0,1))+strlowcase(strmid(ga_names,1))
index=where(ga eq 'Text' or ga eq 'Title' or ga eq 'Mods' or ga eq 'Link_text' or ga eq 'Link_title' or ga eq 'Http_link')
if index(0) ne -1 then ga(index)=strupcase(ga(index))
index=where(ga eq 'Pi_name' or ga eq 'Pi_affiliation')
if index(0) ne -1 then ga(index)=strupcase(strmid(ga_names(index),0,2))+strlowcase(strmid(ga_names(index),2))
index=where(ga eq 'Adid_ref')
if index(0) ne -1 then ga(index)=strupcase(strmid(ga_names(index),0,4))+strlowcase(strmid(ga_names(index),4))
ga_names_istp_compliant=ga

;update logical_file_id (these checks are copied from write_data_to_cdf in IDLmakecdf)
  logical_file_id = file
  period = rstrpos(logical_file_id, '.') ;find position of last '.'
  if (period gt -1) then logical_file_id = strmid(file,0,period)
  slash = rstrpos(logical_file_id, '/') ;find position of last '/'
  if (slash gt -1) then logical_file_id = strmid(logical_file_id,slash+1)
  cdf_structure.g_attributes.logical_file_id=logical_file_id

for i=0,n_elements(ga_names_istp_compliant)-1 do begin

  global_dummy = cdf_attcreate(id, ga_names_istp_compliant[i], /global_scope)
  n_atts = n_elements(cdf_structure.g_attributes.(i))
  for j = 0, n_atts-1 do $
    cdf_attput, id, ga_names_istp_compliant[i], j, $
    cdf_structure.g_attributes.(i)[j]
endfor  ; i


;add variables and their data and attributes
;-------------------------------------------

for i=0,cdf_structure.nv-1 do begin


	;create variable
	;---------------
	
	
	if (cdf_structure.vars[i].recvary eq 0) then recvary='rec_novary' else recvary='rec_vary'
	
	if (ptr_valid(cdf_structure.vars[i].dataptr)) then begin
	   data_dimen=size(*cdf_structure.vars[i].dataptr,/dimen)
	   dimen_data_dimen=size(data_dimen,/dimen)
	   if (cdf_structure.vars[i].recvary eq 1) then begin
	     if dimen_data_dimen(0) eq 1 then data_dimen=0 else data_dimen=data_dimen(1,*)
	   endif else data_dimen=data_dimen
	endif else begin
	   str_element,cdf_structure.vars[i],'d',success=success
	   if success eq 1 then begin
	      index=where(cdf_structure.vars[i].d gt 0)
	      if index(0) ne -1 then data_dimen=cdf_structure.vars[i].d(index) else data_dimen=0
	   endif else data_dimen=0
	endelse
	
	
	if (cdf_structure.vars[i].datatype eq 'CDF_CHAR' or cdf_structure.vars[i].datatype eq 'CDF_UCHAR') then begin
	   if (ptr_valid(cdf_structure.vars[i].dataptr)) then begin
	      numelem=max(strlen(*cdf_structure.vars[i].dataptr))
	      *cdf_structure.vars[i].dataptr=string(*cdf_structure.vars[i].dataptr,format='(a'+string(numelem)+')')
	   endif else numelem=1
	endif else numelem=1
	
	if (cdf_structure.vars[i].datatype eq 'CDF_EPOCH16') then datatype='CDF_LONG_EPOCH' else datatype=cdf_structure.vars[i].datatype
	
	var_parameters=create_struct(datatype,1,recvary,1,'numelem',numelem)
	
	if (data_dimen eq 0) then begin
	   dummy=cdf_varcreate(id,cdf_structure.vars[i].name,_extra=var_parameters,/zvariable)
	endif else begin
	   dummy=cdf_varcreate(id,cdf_structure.vars[i].name,data_dimen,dim=data_dimen,_extra=var_parameters,/zvariable)
	endelse
		
	
	;add variable attributes
	;-----------------------
	
	va=*cdf_structure.vars[i].attrptr
	va_names=tag_names(va)

	for j=0,n_elements(va_names)-1 do begin
	
		att_exists=cdf_attexists(id,va_names(j),/zvariable)
		if (att_exists eq 0) then dummy=cdf_attcreate(id,va_names(j),/variable_scope)
		if cdf_structure.vars[i].datatype eq 'CDF_EPOCH' && ((va_names(j) eq 'FILLVAL') || (va_names(j) eq 'VALIDMIN') || (va_names(j) eq 'VALIDMAX')) then begin
		  cdf_attput,id,va_names(j),cdf_structure.vars[i].name,va.(j),/zvariable,/cdf_epoch
		endif else cdf_attput,id,va_names(j),cdf_structure.vars[i].name,va.(j),/zvariable
			
	endfor  ; j
	
	
	;add variable data
	;-----------------
	print,i
		
	if (ptr_valid(cdf_structure.vars[i].dataptr)) then begin
		vd=*cdf_structure.vars[i].dataptr
		if (data_dimen ne 0 and recvary eq 'rec_vary') then begin
			
			num_dimen=dimen(data_dimen)
			transshift=shift((findgen(num_dimen+1)),-1)
			vd=transpose(vd,transshift)
		endif

		cdf_varput,id,cdf_structure.vars[i].name,vd,/zvariable
	endif
	
		
	
			
endfor  ; i




;close cdf file
;--------------
cdf_close,id

end

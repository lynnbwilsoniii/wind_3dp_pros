;+
;PROCEDURE: loadallhdf
;PURPOSE:
;  Loads selected HDF file variables into a data structure.
;KEYWORDS:
;  VDATANAME:   (Required) name of VData set to be retrieved from HDF file.
;  (following keywords are optional)
;  FILENAMES:   string (array); full pathname of file(s) to be loaded.
;     (INDEXFILE, ENVIRONVAR, MASTERFILE and TIME_RANGE are ignored 
;     if this is set.)
;
;  MASTERFILE:  Full Pathname of indexfile or name of environment variable
;     giving path and filename information as defined in "get_file_names".
;     (INDEXFILE and ENVIRONVAR are ignored if this is set)
;
;  INDEXFILE:   File name (without path) of indexfile. This file
;     should be located in the directory given by ENVIRONVAR.  If not given
;     then "PICKFILE" is used to select an index file. see "make_cdf_index" for
;     information on producing this file.
;
;  ENVIRONVAR:  Name of environment variable containing directory of indexfiles
;     (default is 'CDF_INDEX_DIR')
;
;  TIME_RANGE:  Two element vector specifying time range (default is to use
;     trange_full; see "TIMESPAN" or "GET_TIMESPAN" for more info)
;
;  HDFNAMES:    Names of HDF variables to be loaded. (string array)
;  TAGNAMES:    String array of structure tag names.
;  DATA:        Named variable that data is returned in.
;
;  TPLOT_NAME:  "TPLOT" string name. If set then a tplot variable is created.
;     Individual elements can be referred to as 'NAME.ELEMENT'
;
;VERSION:  @(#)loadallhdf.pro	1.1 00/01/20
;Created by Peter Schroeder, January 2000
;-
pro loadallhdf, filenames=filenames, vdataname=vdataname, data=data, $
	masterfile=masterfile, time_range=time_range, hdfnames=hdfnames, $
	tagnames=tagnames,indexfile=indexfile,environvar=environvar

if not keyword_set(filenames) then begin
	if not keyword_set(masterfile) then begin
		if not keyword_set(environvar) then $
			environvar = 'CDF_INDEX_DIR'
		dir = getenv(environvar)
		if not keyword_set(dir) then message,$
			'Environment variable '+environvar+$
			' is not defined!',/info
		if not keyword_set(indexfile) then masterfile = pickfile(path=dir) $
		else masterfile = filepath(indexfile,root_dir=dir)
	endif
	get_file_names,filenames,masterfile=masterfile,time_range=time_range,$
		nfiles=nfiles
	if nfiles eq 0 then begin
		data=0
		print,'LOADALLHDF: No data files valid for given time range'
		return
	endif
endif

data = 0

for fileindex=0,n_elements(filenames)-1 do begin
	
	hdf_fp = hdf_open(filenames[fileindex],/read)
	if (hdf_fp eq -1) then begin
		print, 'HDF_OPEN: could not open file ', filenames[fileindex]
		return
	endif else print,'Loading ',filenames[fileindex]

	vdata_ref = hdf_vd_find(hdf_fp,vdataname)
	if (vdata_ref eq 0) then begin
		print, 'HDF_VD_FIND: could not find Vdata ', vdataname
		return
	endif

	vdata_id = hdf_vd_attach(hdf_fp, vdata_ref, /read)
	if (vdata_id eq 0) then begin
		print, 'HDF_VD_ATTACH: could attach Vdata ', vdataname
		return
	endif

	hdf_vd_get,vdata_id,class=class,count=count,fields=fields,$
		interlace=interlace,name=name,nfields=nfields,ref=ref,$
		size=size,tag=tag

	if count eq 0 then begin
		print, 'No records found in file ',filename[fileindex]
		return
	endif

	counter = 0

	if n_elements(hdfnames) gt 0 then begin
		if n_elements(tagnames) gt 0 then $
			if n_elements(tagnames) ne n_elements(hdfnames) then begin
				print,'LOADALLHDF: Number of tagnames and hdfnames not equal'
				return
			endif
		filehdfnames = strsplit(fields,',',/extract)
		foo_index = where(strupcase(hdfnames[0]) eq strupcase(filehdfnames),$
			name_count)
		if name_count eq 0 then begin
			print,'LOADALLHDF: Variable '+hdfnames[0]+' not found'
			return
		endif
		foo = filehdfnames[foo_index]
		name_index = foo_index
		for i = 1,n_elements(hdfnames)-1 do begin
			foo_index = where(strupcase(hdfnames[i]) eq $
				strupcase(filehdfnames),name_count)
			if name_count eq 0 then begin
				print,'LOADALLHDF: Variable '+hdfnames[i]+' not found'
				return
			endif
			foo = foo+','+filehdfnames[foo_index]
			name_index = [name_index,foo_index[0]]
		endfor
		fieldnames = foo[0]
	endif

	if n_elements(hdfnames) eq 0 then begin
		fieldnames = fields
		name_index = lindgen(nfields)
		filehdfnames = strsplit(fields,',',/extract)
		hdfnames = filehdfnames
	endif

	read_result = hdf_vd_read(vdata_id,rawdata,fields=fieldnames,/no_interlace)
	if read_result eq 0 then begin
		printf,'LOADALLHDF: No data found in file '+filenames[fileindex]
	endif

	for i=0,n_elements(name_index)-1 do begin
		hdf_vd_getinfo,vdata_id,name_index[i],name=name,order=order,size=size,$
			type=type
		this_element = call_function(type,rawdata,counter,count)
		if n_elements(tagnames) gt 0 then name = tagnames(i)
		if fileindex eq 0 then $
			str_element,data,name,this_element,/add $
		else begin
			str_element,data,name,old_element
			append_array,old_element,this_element
			str_element,data,name,old_element,/add
		endelse
		counter = counter + count*size
	endfor

endfor

return
end

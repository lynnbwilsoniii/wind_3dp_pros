;+
;PROCEDURE:	loadcdf3
;PURPOSE:	
;   Loads one type of data from specified cdf file.
;INPUT:		
;	CDF_file:	the file to load data from  (or the id of an open file)
;	CDF_var:	the variable to load
;	x:		the variable to load data into
;
;KEYWORDS:
;	zvar:	 	must be set if variable to be loaded is a zvariable.
;       append:         appends data to the end of x instead of overwriting it.
;       nrecs:          number of records to be read.
;	no_shift:	if set, do not perform dimen_shift to data.
;	rec_start:	CDF record number to begin reading.
;
;CREATED BY:	Jim Byrnes, heavily modified by Davin Larson (was loadcdf)
;MODIFICATIONS:
;  96-6-26  added APPEND keyword
;LAST MODIFICATION:	@(#)loadcdf2.pro	1.5 98/08/13
;-

; The following program will load all of the data for a specific CDF file and
; variable into IDL. 
; 
;(Jim Byrnes)

pro loadcdf3,CDF_file,CDF_var,x0, zvar = zvar, $
   append=append,no_shift=no_shift,nrecs = nrecs, $
   rec_start=rec_start,numrecs=numrecs

;
; Open CDF file  (if neccesary)
;
if data_type(cdf_file) eq 7 then id = cdf_open(cdf_file) else id = cdf_file

;
; Get file CDF structure information
; 

inq = cdf_inquire(id)

;
; Get variable structure information
;

vinq = cdf_varinq(id,CDF_var, zvariable = zvar)
zvar = vinq.is_zvar
;help, vinq,/st
;help,zvar

!quiet = 1
cdf_control,id,variable=CDF_var,get_var_info=varinfo
!quiet = 0

if not keyword_set(nrecs) then nrecs = varinfo.maxrec+1
;if vinq.recvar eq 'NOVARY' then nrecs = 1

numrecs=nrecs

x=0
if numrecs gt 0 then begin


if keyword_set(zvar) then begin
  CDF_varget,id,CDF_var,x,REC_COUNT=nrecs,zvariable = zvar,rec_start=rec_start
endif else begin
  dims = total(vinq.dimvar)
  dimc = vinq.dimvar * inq.dim
  dimw = where(dimc eq 0,c)
  if c ne 0 then dimc(dimw) = 1
  CDF_varget,id,CDF_var,x,COUNT=dimc,REC_COUNT=nrecs,rec_start=rec_start
;  help,x,nrecs
;  if nrecs eq 1 then x=reform(/overw,x,[nrecs,dimc])
;  help,x,nrecs
endelse

;help,cdf_var,x

;if size(/n_dimen,x) gt 1 then  x = reform(x,/overwrite)
nd = size(/n_dimen,x)
if nd ge 2 and vinq.recvar eq 'VARY' and not keyword_set(no_shift) then $
    x = transpose(x,shift(indgen(nd),1))
if nd eq 0 and vinq.recvar eq 'VARY' then x=[x]

;if vinq.recvar eq 'VARY' and dims ne 0 and not keyword_set(no_shift) then $
;   x = dimen_shift(x,1) 

;if ndimen(x) gt 0 then x = reform(x,/overwrite)

;help,cdf_var,x

if keyword_set(append) and keyword_set(x0)  then x0=[x0,x] else x0=x

endif else if not keyword_set(append) then x0=0

if data_type(cdf_file) eq 7 then cdf_close,id
return
end



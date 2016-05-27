;+
;FUNCTION: mread_sdt.pro
;
;PURPOSE: to provide a way to read in single file or array of files
;        used with function read_sdt.pro and pro findstart.pro
;
;ARGUMENTS:
;       FILE_NAME    -> array of names of file to be input
;       DATA_ARRAY   <- name of variable for data to be stored in
;       NAME_ARRAY   <- name of variable for quatity names (and units) to be
;                       stored in
;
;KEYWORDS: 
;       VERBOSE      /  Prints filenames as read
;
;RETURNS: Status
;            0 - Failure
;            1 - Success
;
;CALLING SEQUENCE: status=mread_sdt(file_name_array,data,name)
;                  if status then status=fix_sdt_time(data,month,day,year)
;
;NOTES: Times are listed in UT from day data was taken. Use FIX_SDT_TIME
;       to set time points to standard UT time
;
;       IMPORTANT: Use SDT_FREE on returned pointer array (DATA_ARRAY) to
;                  free associated memory.
;
;CREATED BY: Lisa Rassel May 2001
;
;LAST MODIFICATION: 
;	06/11/2001-L.Rassel	now tracks file names 
;	07/25/2001-J. Dombeck   added VERBOSE keyword
;-
;INCLUDED MODULES:
;   mread_sdt
;
;LIBRARIES USED:
;   None
;
;DEPENDANCIES
;   data_type
;   read_sdt
;   sdt_free
;
;-



;*** MAIN *** : * MREAD_SDT *

function mread_sdt,file_array,data_array,name_array,verbose=verbose
  

; Check input

  if n_elements(file_array) eq 0 then begin
    message,"FILE_ARRAY required",/cont
    return,0
  endif

  if data_type(file_array) ne 7 then begin
    message,"FILE_ARRAY needs to contain string(s)",/cont
    return,0
  endif


; If single file make it an array

  sz=size(file_array)
  if sz[0] eq 0 then file_array=[file_array]


; Read data

  file_size=n_elements(file_array)
  file_data=make_array(file_size,/ptr)
  name_array=make_array(file_size,2,/string)    ;creates empty name array

  for i=0l,file_size-1 do begin

    if keyword_set(verbose) then $
      print,'Reading file - '+file_array[i]
    if not read_sdt(file_array[i],data,name) then begin
      sdt_free,file_data
      return,0
    endif
      
    name_array[i,*]=name[1,*]                 ;saves name into name array
    file_data[i]=ptr_new(data)
  endfor

  data_array=file_data

return,1
end        ;*** MAIN *** : * MREAD_SDT *

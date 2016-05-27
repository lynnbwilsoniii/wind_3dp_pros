;+
;FUNCTION: read_sdt.pro
;
;PURPOSE: To read sdt ascii data files and output data in matrix form.
;
;ARGUMENTS: 
;       FILE_NAME    -> name of file to be input
;       DATA_ARRAY   <- name of variable for data to be stored in
;       NAME_ARRAY   <- name of variable for the quantity name (and units) to
;                       be stored in
;
;KEYWORDS: n/a
;
;RETURNS: Status
;            0 - Failure
;            1 - Success
;
;CALLING SEQUENCE: status=read_sdt('file_name',data,name)
;                  if status then status=fix_sdt_time(data,month,day,year)
;
;NOTES: Use FIX_SDT_TIME to change sdt times to Unix times.
;       Works with mread_sdt if multiple files are to be read.
;
;CREATED BY:   Lisa Rassel May 2001
;
;MODIFICATION HISTORY: 
;	5/18/01- L.Rassel	creation
;	6/11/01- L.Rassel	now finds file name
;       8/14/01- L.Rassel       greatly increase speed (by reading twice)
;       9/6/01 - J.Dombeck      fixed crash if wrong file type
;                                (first line cannot be split)   
;      10/04/01- J.Dombeck      names array to include ['UT','sec']
;      10/22/01- J.Dombeck      fixed FINDSTRT to work with 3.4+ SDT files
;- 
;INCLUDED MODULES:
;   rdsdt_findstart
;   rdsdt_getlength
;   read_sdt
;
;LIBRARIES USED:
;   None
;
;DEPENDANCIES
;   None
;
;-


;* RDSDT_FINDSTART *  set file pointer to the start of data 

function rdsdt_findstart,unit

  ;  In SDT the data always starts after a line with "Component Depths" in it
  ;  However, sometimes SDT messes up and the data doesn't start after the
  ;  first such line.  Luckily on the bogus lines, the "Component Depths"
  ;  is always followed by an "S" in the 16th character spot.  This character
  ;  is a number in a good line.

  line=''
  while (((not stregex(line,'^%{0,1}Component Depths',/boolean)) or $
    (stregex(line,'^%{0,1}Component Depths%{0,1}Start',/boolean))) and $
    (not eof(unit))) do begin

    readf,unit,line
  endwhile
  if eof(unit) then return,0 else return,1

end     ;* RDSDT_FINDSTART *


;* RDSDT_GETLENGTH * find the length of file to make the input array

function rdsdt_getlength,file_name,elements,unit
  a=0l & b=0l & c=' ' & d=' '  & er=0 &  inp=' '


  ; Run findstart to find the begining of data

    if not rdsdt_findstart(unit) then begin
      message,'Incorrect file type',/cont
      free_lun,unit
      return,0
    endif


  ; Get number of first data point

    readf,unit,a


  ; Loop until end

    while((c ne "End" and c ne "%En") and not eof(unit)) do begin
      d=inp
      readf,unit,inp
      c=strmid(inp,0,3)
    endwhile


  ; Get number of last data point

    b=long(d)

    if eof(unit) then begin
      message,"File " +file_name+ " is missing End.",/cont
      return,0
    endif


  ; Compute number of data points

    elements=b-a+1

return,1
end      ;* RDSDT_GETLENGTH * 
  


;*** MAIN *** : * READ_SDT *

function read_sdt,file_name,data_array,name_array


; Open file

  openr,unit,file_name,error=err,/get_lun
    
  if (err ne 0)  then begin             
    message,'file not found - '+file_name,/cont
    return,0
  endif


; Find variable name

  first_line=' ' 

  readf,unit,first_line

  name=strsplit(first_line,/extract)
  if n_elements(name) lt 2 then begin
    message,"Incorrect file type",/cont
    free_lun,unit
    return,0
  endif

  name=strcompress(name[1],/remove_all)
  if (not eof(unit)) then name_array=[['UT',name],['sec','na']]    


  if eof(unit) then begin
    message,"Incorrect file type",/cont
    free_lun,unit
    return,0
  endif



; Find number of data points

  if not rdsdt_getlength(file_name,num_lines,unit) then begin
    free_lun,unit
    return,0
  endif


; Re-open file (reset to begining of file)

  free_lun,unit
  openr,unit,file_name,error=err,/get_lun
    
  if (err ne 0)  then begin             
    message,'file - '+file_name+' - DISAPPEARED',/cont
    free_lun,unit
    return,0
  endif


; Run findstart to find the begining of data

  if not rdsdt_findstart(unit) then begin
    message,"Incorrect file type",/cont
    free_lun,unit
    return,0
  endif

  times=make_array(num_lines,/double)
  values=make_array(num_lines,/double)


; Read Data


  bogus=0l & time=double(0) & value=double(0)

  for yy=0l,num_lines-1 do begin
    readf,unit,bogus,time,value
    times[yy]=time
    values[yy]=value
  endfor


; Set data_array

  data_array=[[times],[values]]
  free_lun,unit
  return,1

end        ;*** MAIN *** : * READ_SDT *

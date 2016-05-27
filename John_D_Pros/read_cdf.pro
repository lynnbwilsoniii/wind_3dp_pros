;+
; FUNCTION: read_cdf.pro
;
; PURPOSE: to read a single cdf file and return all the data contained
;
; ARGUMENTS:
;       FILENAME  -> the cdf file name
;       DATA      <- name of variable for the data to be stored in
;       VAR_NAMES <- the original name of the variables
;       ZVARS     <> list of whether or not variables are zvariables
;
; KEYWORDS:
;       NOTIME    /  don't automatically pre-pend times
;       VARNAME   -> Name(s) of CDF variable to return
;       NAMES     /  Only return CDF variable names - Not Data
;
; RETURNS: Status
;            0 - Failure
;            1 - Success
;
; CALLING SEQUENCE: status=read_cdf('filename',data,varnames)
;
; NOTES:
;         IMPORTANT: Use SDT_FREE on returned pointer array (DATA)
;                    to free associated memory.
;
; CREATED BY: Wira Yusoff Sept 2001.
;
; LAST MODIFICATION:
;       09/20/01-W. Yusoff        Created
;       11/20/01-J. Dombeck       Fixed bug in last z-quantity
;       11/24/01-W. Yusoff        Added keyword VARNAME for loading only 
;                                   given variable(s)
;       11/25/01-W. Yusoff        Added function inq_cdfvar,an improved
;                                 version of cdf_varinq
;       11/28/01-J. Dombeck       Added NAMES keyword, ZVARS argument
;       12/03/01-J. Crumley       Fixed sdt_free typos, fixed /NAMES
;       02/09/09-J. Dombeck       Fixed Names keyword
;       01/05/10-L.B. Wilson III  Attempted to make CDF_VARGET.PRO quiet
;-
; INCLUDED MODULES:
;     read_cdf
;     inq_cdfvar
;
; LIBRARIES USED:
;     none
;
; DEPENDENCIES:
;     epoch2unix
;-

;*** FUNCTION *** : * INQ_CDFVAR *

function inq_cdfvar,id,var,result,zvariable=zvariable

   CATCH, Error_status

   if Error_status NE 0 then return,0

   result=cdf_varinq(id,var,/zvariable)

   return,1

end ;*** FUNCTION *** : * INQ_CDFVAR *


;*** MAIN *** : * READ_CDF *

function read_cdf,       $
         filename,       $
         data,           $
         var_names,      $
         zvars,          $
         notime=notime,  $
         varname=varname,$
         names=names,    $
	 orbit=orbit,    $
	 ies=ies
	 

  CATCH, Error_status

  if Error_status NE 0 then begin
    message,'Error_status='+Error_status,/cont
    return,0
  endif


; Don't crash if error w/ file

  on_ioerror,ERROPEN

; if orbit keyword set

  if keyword_set(orbit) then begin
    if not keyword_set(ies) then begin
      name0='/data/fast/kp/ees/' 
      name1='fa_k0_ees_'
    endif else begin 
      name0='/data/fast/kp/ies/'
      name1='fa_k0_ies_'
    endelse

    name3='_v03.cdf'
    name4='_v02.cdf'
    name5='_v01.cdf'
    current='0'
    name2=strcompress(fix(orbit,/print,type=7),/remove_all)
    if strlen(name2) eq 4 then name2='0'+name2 else $
    if strlen(name2) eq 3 then name2='00'+name2 else $
    if strlen(name2) eq 2 then name2='000'+name2 else $
    if strlen(name2) eq 1 then name2='0000'+name2
    filename=name0+name1+name2+name3
    openr,1,filename,error=err ;try to open the file
    close,/file
    if err ne 0 then begin
     message,'File not found!: '+filename,/cont
     filename=name0+name1+name2+name4
     openr,1,filename,error=err
     close,/file
    endif
    if err ne 0 then begin
     message,'File not found!: '+filename,/cont
     filename=name0+name1+name2+name5
     openr,1,filename,error=err
     close,/file
    endif
    if err ne 0 then return, -1
   endif

; Get CDF file info

  id=cdf_open(filename)
  on_ioerror,ERRFILE
  info=cdf_inquire(id)
  info=cdf_inquire(id)
  nvars=info.nvars
  nzvars=info.nzvars
  tot_vars=nvars+nzvars


; Read only given variables

  nvar=n_elements(varname)
  if nvar ne 0 then begin

    if n_elements(zvars) ne nvar then begin
      message,"VARNAME / ZVARS Mismatch",/cont
      return,0
    endif

    var_names=strarr(nvar,2)
    var_names[*,1]='na'                     ; Units not listed in CDF files
    datain=ptrarr(nvar,/allocate_heap)

    for xx=0,nvar-1 do begin

      vname=varname[xx]

      if zvars[xx] eq 0 then begin
        status=inq_cdfvar(id,vname,varinq)
        if status eq 1 then begin
         nrecs=info.maxrec+1
         if varinq.recvar eq 'NOVARY' then nrecs = 1
         !QUIET = 1
         cdf_varget,id,vname,dat,REC_COUNT=nrecs
         !QUIET = 0
         var_names[xx,0]=vname
         if n_elements(dat) gt 1 then *datain[xx]=transpose(dat)
        endif else begin
          sdt_free,datain
          return,0
        endelse
      endif else begin
        status=inq_cdfvar(id,vname,varinq,/zvariable)
        if status eq 1 then begin
        !QUIET = 1
        cdf_control,id,variable=vname,get_var_info=zvar_inf,/zvariable
        !QUIET = 0
        nrecs=zvar_inf.maxrecs+1
        if varinq.recvar eq 'NOVARY' then nrecs = 1
        !QUIET = 1
        cdf_varget,id,vname,dat,REC_COUNT=nrecs,/zvariable
        !QUIET = 0
        var_names[xx,0]=vname
        if n_elements(dat) gt 1 then *datain[xx]=transpose(dat)
        endif else begin
          sdt_free,datain
          return,0
        endelse
     endelse

    endfor

    data=datain

  return,1
  endif


; Read in (and/or get names of) all variables

  var_names=strarr(tot_vars,2)
  var_names[*,1]='na'                     ; Units not listed in CDF files
  datain=ptrarr(tot_vars,/allocate_heap)
  zvars=make_array(tot_vars,/int)


; Get data (Regular variables)

  if nvars ne 0 then begin
    for var=0,nvars-1 do begin
      varinq=cdf_varinq(id,var)
      cdf_var=varinq.name
      if not keyword_set(names) then begin
        nrecs=info.maxrec+1
        if varinq.recvar eq 'NOVARY' then nrecs = 1
        !QUIET = 1
        cdf_varget,id,cdf_var,tmp_data,REC_COUNT=nrecs
        !QUIET = 0
        if n_elements(tmp_data) gt 1 then *datain[var]=transpose(tmp_data) $
                                     else *datain[var]=tmp_data
      endif
      var_names[var,0]=cdf_var
      zvars[var]=0
    endfor
  endif


; Get data ("Z" [multi-dimensional] variables)

  if nzvars ne 0 then begin
    for var=0,nzvars-1 do begin
      varinq=cdf_varinq(id,var,/zvariable)
      cdf_var=varinq.name
      if not keyword_set(names) then begin
        ; Ignore waning of CDF creation
        !QUIET = 1
        cdf_control,id,variable=var,get_var_info=zvar_inf,/zvariable
        !QUIET = 0
        nrecs=zvar_inf.maxrecs+1
        if varinq.recvar eq 'NOVARY' then nrecs = 1
        !QUIET = 1
        cdf_varget,id,cdf_var,tmp_data,REC_COUNT=nrecs,/zvariable
        !QUIET = 0
        if n_elements(tmp_data) gt 1 $
           then *datain[nvars+var]=transpose(tmp_data)$
           else *datain[nvars+var]=tmp_data
      endif
      var_names[nvars+var,0]=strcompress(cdf_var)
      zvars[nvars+var]=1
    endfor
  endif

  cdf_close,id


; If don't need to check for times - DONE

  if keyword_set(notime) then begin
    data=datain
    return,1
  endif

; if just need names, then done
  if keyword_set(names) then return,1

; Find Times (Epoch) and append to beginning of each series

  epidx=where(stregex(strupcase(var_names[*,0]),'EPOCH',/boolean),cnt)
  if cnt ne 1 then begin
    message,"WARNING: Unique EPOCH series not found - times not set",/cont
    data=datain
    return,1
  endif

  idx=where(stregex(strupcase(var_names[*,0]),'EPOCH',/boolean) eq 0)
  times=epoch2unix(*datain[epidx[0]])
  data=ptrarr(tot_vars-1,/allocate_heap)
  for xx=0,tot_vars-2 do begin
    sz=size(*datain[idx[xx]])
    if sz[1] ne n_elements(times) then begin
      str='WARNING: Index'+strcompress(string(xx))+' ('+ $
          var_names[idx[xx]]+ $
          ') does not have proper number of elements.  Times not pre-pended.'
      message,str,/cont
      *data[xx]=*datain[idx[xx]]
    endif else begin
      *data[xx]=transpose([transpose(times),transpose(*datain[idx[xx]])])
    endelse
  endfor
  var_names=var_names[idx]
  var_nam=strarr(n_elements(var_names),2)
  var_nam[*,0]=var_names
  var_nam[*,1]='na'
  var_names=var_nam 
  sdt_free,datain

return,1


; I/O Errors

ERROPEN:

  message,'Error opening CDF file - '+filename,/cont
  return,0


ERRFILE:

  message,'Error reading CDF file - '+filename,/cont
  cdf_close,id
  return,0


end        ;*** MAIN *** : * READ_CDF *


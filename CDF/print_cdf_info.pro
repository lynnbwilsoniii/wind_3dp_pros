;+
;PROCEDURE:     print_cdf_info
;PURPOSE:   prints information about a specified cdf file
;INPUT:
;   filename: The name of the file for which info is desired.
;KEYWORDS:
;   none
;
;CREATED BY:    D. Larson
;LAST MODIFICATION:     @(#)print_cdf_info.pro 1.13 02/11/01
;-

pro print_cdf_info,filename,printatt=printatt
if keyword_set(filename) eq 0 then filename = dialog_pickfile()
print,'File: ',filename
id=cdf_open(filename)
info=cdf_info(id)
printdat,info,nstr=1
;print,'dim=',info.dim
Print,'VARIABLES:'
print_struct,info.vars
q= !quiet
;print,'number or records=',info.num_recs
;help,info,/st

cdf_doc,id,v,r,c
;print,v,r,c

if keyword_set(printatt) then begin
print,"ATTRIBUTES:"
;  gatts = cdf_var_atts(id,attri=allatt)
 for a=0,info.inq.natts-1 do begin
  cdf_control,id,att=a,get_attr_info=ai
  cdf_attinq,id,a,name,scope,maxrent,maxzent
  scp = strmid(scope,0,1)
  if scp eq 'G' then begin
     for gentry = 0,ai.maxgentry do begin
       if cdf_attexists(id,a,gentry) then begin
         cdf_attget,id,a,gentry,value
         print,a,gentry,name,value,format='(i3," ",i2," ",a," --> ",a)'
 ;        printdat,value
       endif
     endfor
  endif
  if scp eq 'V' then begin
     print,a,name,ai.numrentries,ai.numzentries,format='(i3," ","  "," ",a,"  (",i0,",",i0,")")'
  endif
 endfor
endif

if 0 then begin
Print,'VARIABLES:'
print,format='(" mrec ","rec"," Z","          VAR NAME","        TYPE"," ELEM", "   VARY"," DIMVAR")'
;help,cdf_varinq(id,0),/str
for itest =0,info.nvars-1  do begin
!quiet =1
   cdf_control,id,var=itest,get_var_info=info
!quiet = q
   vinq = cdf_varinq(id,itest)
   print,info.maxrec,format='(i5," ",$)'
   print,itest,vinq,format='(i3,i2,a18,a12,i5,a7,5z)'
endfor

for itest =0,info.nzvars-1  do begin
!quiet =1
   cdf_control,id,var=itest,get_var_info=info,/zvar
!quiet = q
   vinq = cdf_varinq(id,itest, /zvariable)
   print,info.maxrec,format='(i5," ",$)'
   print,itest,vinq,format='(i3,i2,a18,a12,i5, a7, i7,i7,i7,i7)'
endfor
endif

cdf_close,id
end



;+
;PROCEDURE:	mk_cr_cdf
;PURPOSE:	Creates CDF files spanning a Carrington rotation.
;INPUT:		t	time in the Carrington rotation of interest
;			(optional if crnum set)
;KEYWORDS:	crnum	Carrington number (optional if t set)
;		fileprefix	prefix of CDF files to be read.  For
;			example, fileprefix='wi_elsp_3dp_' or
;			fileprefix='wi_em_3dp_' (required)
;		resolution	time resolution in seconds (optional)
;CREATED BY:	Peter Schroeder
;LAST MODIFIED:	@(#)mk_cr_cdf.pro	1.3 98/11/03
;-

pro mk_cr_cdf, t, crnum = crnum, fileprefix = fileprefix, resolution = res

par0 = time_double('1853-10-27/14:21:42')
par1 = 2355919.8d

if (keyword_set(crnum) eq 0) then begin
  if (keyword_set(t)) then $
    crnum = fix((time_double(t) - par0)/par1) $
  else begin
    print,'Error (MK_CR_CDF) - must enter time or Carrington number'
    return
  endelse
endif


trange = (dindgen(2) + double(crnum))*par1+par0
if keyword_set(res) then  trange = round(trange/res)*res
print,time_string(trange)

if (keyword_set(fileprefix) eq 0) then begin
  print,'Error (MK_CR_CDF) - must enter fileprefix'
  return
endif

indexfile = fileprefix+'files'

d = 0
loadallcdf,indexfile=indexfile,data=d,resolution=res,time_range=trange,$
  novardata = nv,cdfnames=cdfnames

printdat,cdfnames
printdat,d

if not keyword_set(d) then begin
  print,'Error (MK_CR_CDF) - no data for time range'
  return
endif

dates = strcompress(crnum,/rem)
filename = fileprefix+'cr'+dates+'_v01'
makecdf,d,datanovary=nv,filename=filename,tagsvary=cdfnames

return
end

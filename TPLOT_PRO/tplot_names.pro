pro tplot_names, datanames , time_range=times, names=names, verbose=verbose,  $
  sort=sortit, tsort=tsort, asort=asort, $
   reverse=rev, create_time=create_time,all=all,current=current
;+
;PROCEDURE:  tplot_names [, datanames ]
;PURPOSE:    
;   Lists current stored data names that can be plotted with the TPLOT routines.
;INPUT:   (Optional)  An string (or array of strings) to be displayed
;         The strings may contain wildcard characters.
;Optional array of strings.  Each string should be associated with a data
;       quantity.  (see the "store_data" and "get_data" routines)
;KEYWORDS:
;  TIME_RANGE:  Set this keyword to print out the time range for each quantity.
;  CREATE_TIME: Set to print creation time.
;  VERBOSE:     Set this keyword to print out more info on the data structures
;  NAMES:       Named variable in which the array of valid data names is returned.
;  ASORT:       Set to sort by name.
;  TSORT:       Set to sort by creation time.
;  CURRENT:     Set to display only names in last call to tplot.
;EXAMPLE
;   tplot_names,'*3dp*'   ; display all names with '3dp' in the name
;CREATED BY:	Davin Larson
;SEE ALSO:   "TNAMES"  "TPLOT"
;MODS:     Accepts wildcards
;LAST MODIFICATION:	@(#)tplot_names.pro	1.19 01/10/08
;-
@tplot_com.pro


if n_elements(data_quants) eq 0 then begin
   print,"No data has been saved yet"
   return
endif

;  The following section could eventually be replaced by tnames()
names = tnames(datanames,nd,ind=ind,all=all,tplot=current)

if keyword_set(sortit) or keyword_set(asort) then begin
  s = sort(names)
  names = names[s]
  ind   = ind[s]
endif

if keyword_set(tsort) then begin
  s = sort(data_quants[ind].create_time)
  names = names[s]
  ind   = ind[s]
endif

if keyword_set(rev) then begin
  names = reverse(names)
  ind = reverse(ind)
endif

  format1='($,i3," ",a,T??," ")'
  format2='($,"  ",a," ",a)'
  mx = max(strlen(names))
  ps = strtrim((mx+5 < 40) > 10,2)
  strput,format1,ps,strpos(format1,'??')
  for k=0,nd-1 do begin
     i=ind[k]
     dq = data_quants[i]
     tr = time_string(dq.trange)
     n  = dq.name
     dc = dq.dtype
     dp = dq.dh
     ndp = n_elements(*dp)
     print,i,n ,format=format1
     if keyword_set(times) then  print,tr(0),tr(1),format=format2
     if keyword_set(create_time) then print,systime(0,dq.create_time),format='($," ",a)'
     if dc eq 3 then for j=0,ndp-1 do print,(*dp)(j),format='($," ",a)'
     print
     if keyword_set(verbose) then begin
        printdat,dq,level='     ','DQ'
;       printdat,*dq.dl,level='      ','DLIMIT'
;       printdat,*dq.lh,level='      ','LIMIT'
;       printdat,*dq.dh,level='      ','DATA'
     endif
  endfor

end




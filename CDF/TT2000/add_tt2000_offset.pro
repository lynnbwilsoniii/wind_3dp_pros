;+
;
;Procedure: add_tt2000_offset
;
;Purpose:
;  Takes TDAS double timestamp and offsets date(s) using the data in the CDF 3.4(or later) leap second config file.
;  Like time_string and time_double, it is vectorized and accepts array inputs of arbitrary dimensions
; 
;Inputs: 
;  Dates: If /subtract is not set: double precision seconds since 1970 TAI (Unix timestamp)  Can be scalar or array values with any dimensions or ordering.
;         If /subtract is set: double precision seconds since 1970 TT(timestamp TT 1970 epoch) can be scalar or array values with any dimensions or ordering
;          
;Keywords:
;  subtract:  If this keyword is set, this function will subtract leap seconds from a TT date that already includes them.
;  
;  Offsets: Set this to a named variable in which to return the offsets used for the calculation.  Note that these can differ in both sign and magnitude for
;  a particular date, depending on whether you are adding or subtracting.
;
;Return Value:
;  The data with leap seconds added(or removed). 
;  
;Notes:
;  #1 This routine requires the CDF 3.4 leap second file.  One will be provided with the TDAS install, but it will be updated
;  automatically when a new leap second occurs.
;  
;  #2 The IDL system variable "!CDF_LEAP_SECONDS" must be defined for this routine to work.  This variable is defined by
;  calling cdf_leap_second_init.  Normally, the initialization routine for missions that use tt2000 should use this.
;
;  #3 The calculation adds both leap seconds and the 32.184 second historical offset between TAI and TT
;
;
;Examples:
;THEMIS>  print,time_double('2007-03-23')-add_tt2000_offset(time_double('2007-03-23'))
;      -65.183998
;THEMIS>  print,time_double('2007-03-23')-add_tt2000_offset(time_double('2007-03-23'),offsets=off_p)
;      -65.183998
;THEMIS> print,off_p
;      65.1840     
;THEMIS>  print,time_double('2007-03-23')-add_tt2000_offset(time_double('2007-03-23'),offsets=off_s,/subtract)
;       65.183998
;THEMIS> print,off_s
;     -65.1840  
;
;
; $LastChangedBy: kersten $
; $LastChangedDate: 2013-01-30 10:33:53 -0800 (Wed, 30 Jan 2013) $
; $LastChangedRevision: 11501 $
; $URL: svn+ssh://thmsvn@ambrosia.ssl.berkeley.edu/repos/spdsoft/trunk/general/misc/time/TT2000/add_tt2000_offset.pro $
;-

function add_tt2000_offset,dates,subtract=subtract,offsets=offsets

  defsysv,'!CDF_LEAP_SECONDS',exists=exists
  
  if ~keyword_set(exists) then begin
    ;fatal error
    message,'Error. !CDF_LEAP_SECONDS, must be defined.  Try calling cdf_leap_second_init'
  endif
;  stop
  leap_data = read_asc(!cdf_leap_seconds.local_data_dir+'/CDFLeapSeconds.txt')
  leap_dates= time_double(strtrim(leap_data.(0),2)+'-'+strtrim(leap_data.(1),2)+'-'+strtrim(leap_data.(2),2)+'/00:00:00')
  leap_offsets=leap_data.(3)
  
  ;leap seconds occur at the TT calendar date in the file.  This date will already include leap seconds.
  if keyword_set(subtract) then begin
    leap_dates+=32.184 ;offset between unix epoch(TAI) & J2000.0 epoch(TT)
    leap_dates+=[0,leap_offsets[1:n_elements(leap_offsets)-1]]
    ;leap_dates-=leap_offsets
  endif 
  
  ;finds which offset parameters apply to which input dates
  offset_indexes=value_locate(leap_dates,dates,/l64) ;this assumes that leap_dates is monotone
  offsets=([0,leap_offsets])[offset_indexes+1]+32.184 ;offset_indexes has range [-1,n-1], so prepending the zero offset element allows indexing without error 

  if keyword_set(subtract) then begin
    offsets*=-1
  endif
  
  return,dates+offsets
 
end
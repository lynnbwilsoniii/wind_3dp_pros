;+
;
;Procedure: Crib TT2000
;
;Purpose:  Demonstrate how to use TT2000 times with TDAS.  Describe what operations are performed on import.
;
;Notes: Requires CDF 3.4.0 or newer
;
; $LastChangedBy: pcruce $
; $LastChangedDate: 2012-04-18 15:14:40 -0700 (Wed, 18 Apr 2012) $
; $LastChangedRevision: 10350 $
; $URL: svn+ssh://thmsvn@ambrosia.ssl.berkeley.edu/repos/ssl_general/trunk/CDF/TT2000/crib_tt2000.pro $
;-


 ;cdf_leap_second_init must be called to initialize TT2000
 ;It can be added to mission init routines, or missions can write their own customized versions of this routine
 ;This routine initializes an IDL system variable called !CDF_LEAP_SECONDS, it stores the config information necessary to 
 ;download and find the leap second config file from SPDF
 cdf_leap_second_init

 ;Description of TT2000 & the conversion:
 ;TT2000 times are provided as signed 64 bit integers.(LONG64)  These integers represent the number of nanoseconds since
 ;J2000.0 with leap seconds added as they occur.
 ;Converting to TDAS Unix timestamps occurs as follows:
 ;#1 Convert signed integer nanoseconds into double precision seconds(there may be some loss of precision here, for high resolution data types)
 ; e.g. tt2000_double=double(tt2000_integer)/1d9
 ;#2 Convert double precision seconds from J2000.0(2000-01-01/12:00:00 TT) to Unix Epoch (1970-01-01/00:00:00 TAI)
 ; e.g. tt1970_double=tt2000_double+time_double('2000-01-01/12:00:00')
 ;#3 For historical reasons, there is a 32.184 second skew between TT & TAI.  This must be subtracted.
 ; e.g. tai1970_double=tt1970_double-32.184
 ;#4 The unix timestamp does not include leap seconds.  These must be subtracted.  
 ; Since leap seconds are irregular, this is done by table lookup. The table is automatically downloaded and updated by TDAS
 ; e.g. unix_timestamp=tai1970_double-leap_table_lookup[tai1970_double]
 ;
 ;

 ;Test file from Tami Kovalick
 ;You can download this file or any TT2000 file yourself and set the fname.
 ;Auto downloading this particular example file is just for convenience, but there
 ;is nothing special about it.
 ;
 fname=file_retrieve('c4_waveform_wbd_200207281850_v01.cdf',local_data_dir=!CDF_LEAP_SECONDS.local_data_dir,remote_data_dir='http://themis.ssl.berkeley.edu/data/themis/examples/')
 ;
 ;fname='/home/pcruce/IDLWorkspace/c4_waveform_wbd_200207281850_v01.cdf'
; 
;
;If this flag is disabled, timestamps are converted as nearly as possible to unix timestamps(ie performs steps 1-4 from above)
 !cdf_leap_seconds.preserve_tt2000=0
 cdfi=cdf_load_vars(fname,var_type='data',varnames=varnames,number_records=1000,/convert_int1_to_int2) ;limit number of records so as to not blow up memory
 cdf_info_to_tplot,cdfi,varnames
 get_data,'Bandwidth',data=d
 print,'Offset Removed: ', time_string(d.x[0],precision=3)
 stop

;If this flag is enabled, timestamps are still converted to double precision seconds since 1970
;But the leap second and TAI/TT offsets are not performed. (ie only performs steps 1 & 2 from above)
;Converting back to the J2000 epoch from this is as simple as subtracting time_double('2000-01-01/12:00:00') from the
;data timestamps.
 !cdf_leap_seconds.preserve_tt2000=1
 cdfi=cdf_load_vars(fname,var_type='data',varnames=varnames,number_records=1000,/convert_int1_to_int2) ;limit number of records so as to not blow up memory
 cdf_info_to_tplot,cdfi,varnames
 !cdf_leap_seconds.preserve_tt2000=0 ;don't want to leave this on by accident
 get_data,'Bandwidth',data=d
 print,'Offset Included: ', time_string(d.x[0],precision=3)
 
 stop
 
 ;Example transition across a leap second boundary
 ;And low level conversion.
 
 ;This routine is part of CDF 3.4.0, it computes timestamps(CDF epochs) from dates.
 cdf_tt2000,epoch,[2005,2005,2006,2006],[12,12,1,1],[31,31,1,1],[23,23,0,0],[59,59,0,0],[58,59,0,1],/compute
 
 print,'Offset Included',time_string(double(epoch)/1e9+time_double('2000-01-01/12:00:00')) ;Equivalent to !cdf_leap_seconds.preserve_tt2000=1
 print,'Offset Removed:',time_string(add_tt2000_offset(double(epoch)/1e9+time_double('2000-01-01/12:00:00'),/subtract,offset=off)) ;Equivalent to !cdf_leap_seconds.preserve_tt2000=0
 print,'Offsets Applied:', off
 print,'Inversion:',time_string(add_tt2000_offset(add_tt2000_offset(double(epoch)/1e9+time_double('2000-01-01/12:00:00'),/subtract))) ;Verify that the transformation correctly inverts
 stop

 ;CONFIGURATION:
 ;Settings for how the tt2000 leap second table is downloaded are set by cdf_leap_second_init.
 ;You can change these settings by setting keywords when cdf_leap_second_init is called, or 
 ;you can change these settings then call tt2000_write_config, to save the settings for a future session.
 !cdf_leap_seconds.no_download=1
 tt2000_write_config
 
 ;OR
 cdf_leap_second_init,/no_download

end
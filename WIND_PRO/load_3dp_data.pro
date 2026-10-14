;+
;*****************************************************************************************
;
;  PROCEDURE:   load_3dp_data.pro
;  PURPOSE  :   Opens and loads into memory the 3DP LZ data file(s) within the given time
;                 range specified by user.  This must be called prior to any data 
;                 retrieval program (e.g. get_el.pro)!
;
;  CALLED BY:   
;               NA
;
;  INCLUDES:
;               NA
;
;  CALLS:
;               init_wind_lib.pro
;               @wind_com.pro
;               @tplot_com.pro
;               get_timespan.pro
;               time_double.pro
;               timespan.pro
;               time_string.pro
;               str_element.pro
;               load_wi_h0_mfi.pro
;               store_data.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;               2)  WindLib Libraries and the following shared objects:
;                     wind3dp_lib_ls32.so          ;;  Sun Machines [32-bit, > v5.5]
;                     wind3dp_lib_ss32.so          ;;  Sun Machines [32-bit, < v5.5]
;                     wind3dp_lib_darwin_i386.so   ;;  for Macs with Intel CPUs   [32-bit]
;                     wind3dp_lib_darwin_ppc.so    ;;  for Macs with PowerPC CPUs [32-bit]
;                     wind3dp_lib_linux_x86.so     ;;  Linux machines [32-bit]
;                     wind3dp_lib_linux_x86_64.so  ;;  Linux machines [64-bit]
;                     wind3dp_lib_darwin_x86_64.so ;;  for Macs with Intel CPUs   [64-bit]
;
;  INPUT:
;               TIME       :  Scalar [string] defining the start time of the data to load
;                               with formats accepted by time_string.pro, for example the
;                               following work:
;                                 'YY-MM-DD/hh:mm:ss'
;                                 'YYYY-MM-DD/hh:mm:ss'
;               DELTAT     :  Scalar [double] defining the number of hours to load
;
;  EXAMPLES:    
;               [calling sequence]
;               load_3dp_data,time,deltat [,MEMSIZE=memsize] [,QUALITY=quality]        $
;                                         [,IF_NEEDED=if_needed] [,NOSET=noset]        $
;                                         [,NOMAG=nomag]
;
;               ;;  Examples
;               ;;  Load 24 hours of data starting on Feb. 21, 1996 and allow
;               ;;    invalid packets to come through
;               UMN> load_3dp_data,'1996-02-21/00:00:00',24,QUALITY=2,MEMSIZE=150
;               ;;  Check to see if load worked...
;               UMN> tplot_names
;               UMN> tplot,[1,2]
;               UMN> tra = ['1996-02-21/00:00:00','1996-02-22/00:00:00']
;               UMN> trd = time_double(tra)
;               ;;  Get an example level zero electron distribution to ensure shared
;               ;;    object libraries are working correctly
;               UMN> el0 = get_el(trd[0])
;               UMN> HELP, el0,/STRUCT
;               ;;  If that worked, then get ALL the EESA Low distributions in the
;               ;;    time range loaded
;               UMN> elstrs = get_3dp_structs('el',TRANGE=trd)
;               UMN> HELP, elstrs,/STRUCT
;
;  KEYWORDS:    
;               QUALITY    :  Scalar [integer] defining the quality type of the data to
;                               load.  The shared object libraries filter the data and
;                               allows these issues through:
;                                 0  :  Most conservative option {** Default **}
;                                 1  :  Frame contains some fill data
;                                 2  :  Packets can be invalid
;                                 4  :  Packets can contain fill data
;               MEMSIZE    :  Scalar [long] that defines the amount of memory to
;                               allocate in IDL (benefitted older machines)
;                               {Default = 30}
;               IF_NEEDED  :  If set, stops routine from re-loading data if already
;                               loaded
;               NOSET      :  If set, routine will not use timespan.pro to set the
;                               time ranges in the tplot_com.pro common block
;               NOMAG      :  If set, routine will not load the MFI magnetic field
;                               data using load_wi_h0_mfi.pro
;
;   CHANGED:  1)  Davin Larson changed something...
;                                                                   [11/05/2002   v1.0.20]
;             2)  Changed the source location of Level Zero data files to:
;                   '/data1/wind/3dp/lz/wi_lz_3dp_files'
;                   => Specific to the University of Minnesota
;                                                                   [06/19/2008   v1.0.22]
;             3)  Updated man page
;                                                                   [08/05/2009   v1.1.0]
;             4)  Fixed minor syntax error
;                                                                   [08/26/2009   v1.1.1]
;             5)  Updated man page, added shared object library and added error handling
;                                                                   [08/05/2010   v1.2.0]
;             6)  Master file path location no longer hard coded into init_wind_lib.pro
;                   call
;                                                                   [07/25/2011   v1.2.1]
;             7)  Cleaned up and updated Man. page
;                                                                   [08/08/2013   v1.2.2]
;             8)  Added keyword:  NOMAG
;                                                                   [02/05/2026   v1.2.3]
;
;   NOTES:      
;               0)  This routine MUST be run prior to grabbing any 3DP distributions
;                     from the level zero (lz) files
;
;  REFERENCES:  
;               0)  Harten, R. and K. Clark "The Design Features of the GGS Wind and
;                      Polar Spacecraft," Space Sci. Rev. Vol. 71, pp. 23--40, 1995.
;               1)  Carlson et al., "An instrument for rapidly measuring plasma
;                      distribution functions with high resolution," Adv. Space Res.
;                      2, pp. 67--70, 1983.
;               2)  Curtis et al., "On-board data analysis techniques for space plasma
;                      particle instruments," Rev. Sci. Inst. 60, pp. 372--380, 1989.
;               3)  Lin et al., "A Three-Dimensional Plasma and Energetic particle
;                      investigation for the Wind spacecraft," Space Sci. Rev.
;                      71, pp. 125--153, 1995.
;               4)  Wilson III, L.B., et al., "A Quarter Century of Wind Spacecraft
;                      Discoveries," Reviews of Geophysics 59(2), pp. e2020RG000714,
;                      doi:10.1029/2020RG000714, 2021.
;
;   CREATED:  ??/??/????
;   CREATED BY:  Davin Larson
;    LAST MODIFIED:  02/05/2026   v1.2.3
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

PRO load_3dp_data,time,deltat,MEMSIZE=memsize,QUALITY=quality, $
                  IF_NEEDED=if_needed,NOSET=noset,NOMAG=nomag

;;----------------------------------------------------------------------------------------
;;  Initialize file locations and save in common block
;;----------------------------------------------------------------------------------------
init_wind_lib
;;----------------------------------------------------------------------------------------
;;  Load common blocks and initialize LZ file locations
;;----------------------------------------------------------------------------------------
@wind_com.pro
@tplot_com.pro

COMMON times_dats, t
;;----------------------------------------------------------------------------------------
;;  Check input parameters
;;----------------------------------------------------------------------------------------
IF (N_ELEMENTS(quality) NE 1) THEN quality = 0
IF (N_ELEMENTS(deltat) EQ 0)  THEN deltat  = 24d0

CASE N_ELEMENTS(time) OF
  0    : BEGIN
    get_timespan,time
    noset = 1
  END
  1    : BEGIN
    to  = time_double(time)
    t1  = to[0] + 36d2*deltat[0]
    t   = [to,t1]
  END
  2    : BEGIN
    t   = time_double(time)
  END
  ELSE : BEGIN
    MESSAGE,'Improper input format:  TIME',/INFORMATIONAL,/CONTINUE
    RETURN
  END
ENDCASE
ttype = SIZE(t,/TYPE)
IF (N_ELEMENTS(t) NE 2) OR (ttype NE 5) THEN MESSAGE,'Improper time input!'
;;----------------------------------------------------------------------------------------
;;  Check optional parameters
;;----------------------------------------------------------------------------------------
IF KEYWORD_SET(memsize) THEN memsize = FIX(memsize) ELSE memsize = 30

IF (KEYWORD_SET(if_needed) AND KEYWORD_SET(loaded_trange)) THEN BEGIN
  IF (t[1] LE loaded_trange[1] AND t[0] GE loaded_trange[0]) THEN BEGIN
    MESSAGE,'WIND decommutator data already loaded.  Skipping...',/INFORMATIONAL,/CONTINUE
    RETURN
  ENDIF
ENDIF
;;----------------------------------------------------------------------------------------
;;  Call WindLib libraries
;;----------------------------------------------------------------------------------------
MESSAGE,'Using decomutator: "'+wind_lib+'"',/INFORMATIONAL,/CONTINUE
err = CALL_EXTERNAL(wind_lib,'load_data_files_idl',t,lz_3dp_files,memsize,quality)
;;----------------------------------------------------------------------------------------
;;  Define some common block variables
;;----------------------------------------------------------------------------------------
loaded_trange = t
IF NOT KEYWORD_SET(noset) THEN timespan,t

str     = time_string(t)
refdate = STRMID(str[0],0,STRPOS(str[0],'/'))
str_element,tplot_vars,'OPTIONS.REFDATE',refdate[0],/ADD_REPLACE
;;----------------------------------------------------------------------------------------
;;  Load magnetic field data
;;----------------------------------------------------------------------------------------
IF NOT KEYWORD_SET(nomag) THEN load_wi_h0_mfi,TIME_RANGE=t
;;  Save time range as TPLOT variable
store_data,'TIME',DATA={STTR:t[0],ETTR:t[1]}

MESSAGE,'Reference date is: '+refdate[0],/INFORMATIONAL,/CONTINUE
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN
END



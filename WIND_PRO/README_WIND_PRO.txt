Last Modification =>  2008-06-23/22:24:16 UTC
;+
;PROCEDURE change_pkquality, pkquality
;
;PURPOSE:
;  Change the level of packet quality used when filtering packets through
;  the WIND decommutation software.
;
;INPUTS:
;  pkquality: set bits to determine level of packet quality.
;	      the following bits will allow packets with these possible
;	      quality problems through the decommutator filter:
;		1: frame contains some fill data
;		2: the following packet is invalid
;		4: packet contains fill data
;	      the most conservative option is to set pkquality = 0
;
;CREATED BY:	Peter Schroeder
;LAST MODIFICATION: @(#)change_pkquality.pro	1.1 97/12/18
;-


Last Modification =>  2008-06-23/22:24:16 UTC
;+
;PROCEDURE:	help_3dp
;PURPOSE:	Calls netscape and brings up our on_line help.  One of the pages
;		accessed by this on_line help provides documentation on all of
;		our procedures and is produced by"makehelp"
;INPUT:		none
;KEYWORDS:	
;	MOSAIC:	if set uses mosaic instead of netscape
;
;CREATED BY:	Jasper Halekas
;FILE:   help_3dp.pro
;VERSION:  1.7
;LAST MODIFICATION: 02/04/17
;-


Last Modification =>  2010-08-05/13:51:51 UTC
;+
;*****************************************************************************************
;
;  FUNCTION :   init_wind_lib.pro
;  PURPOSE  :   Initializes common block variables for the WIND 3DP library.  There is
;                 no reason for the typical user to execute this routine as it is
;                 automatically called from "LOAD_3DP_DATA".  However it can be used to
;                 overide the default directories and/or libraries.
;
;  CALLED BY:   
;               load_3dp_data.pro
;
;  CALLS:
;               setfileenv.pro
;               wind_com.pro
;               umn_default_env.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;               2)  WindLib Libraries and the following shared objects:
;                     wind_lib.so
;
;  INPUT:
;               NA
;
;  EXAMPLES:    
;               NA
;
;  KEYWORDS:    
;               WLIB      :  Scalar string specifying the full pathname of the shared 
;                              object code for wind data extraction library.   
;                              [Default = $IDL_3DP_DIR/lib/wind_lib.so]
;               MASTFILE  :  Scalar string specifying the full pathname of the
;                              3DP master data file.
;                              [Default = $WIND_DATA_DIR/wi_lz_3dp_files]
;
;   CHANGED:  1)  Davin Larson changed something...          [04/18/2002   v1.0.12]
;             2)  Updated man page                           [08/05/2009   v1.1.0]
;             3)  Fixed minor syntax error                   [08/26/2009   v1.1.1]
;             4)  Updated man page, added shared object library and added error handling
;                                                            [08/05/2010   v1.2.0]
;
;
;   NOTES:
;               Please see help_3dp.html for information on creating the master file
;                 for 3DP level zero data allocation.
;
;RESTRICTIONS:
;               This procedure is operating system dependent!  (UNIX ONLY)
;               This procedure expects to find two environment variables:
;                 1)  WIND_DATA_DIR : The directory containing the master 
;                                       file: 'wi_lz_3dp_files'
;                 2)  IDL_3DP_DIR   : The directory containing the source code and 
;                                       the sub-directory/file:  lib/wind_lib.so
;
;   CREATED:  ??/??/????
;   CREATED BY:  Davin Larson
;    LAST MODIFIED:  08/05/2010   v1.2.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-


Last Modification =>  2010-08-05/13:50:30 UTC
;+
;*****************************************************************************************
;
;  FUNCTION :   load_3dp_data.pro
;  PURPOSE  :   Opens and loads into memory the 3DP LZ data file(s) within the given time
;                 range specified by user.  This must be called prior to any data 
;                 retrieval program (e.g. get_el.pro)!
;
;  CALLED BY:   
;               NA
;
;  CALLS:
;               wind_com.pro
;               tplot_com.pro
;               init_wind_lib.pro
;               get_timespan.pro
;               time_double.pro
;               time_string.pro
;               str_element.pro
;               timespan.pro
;               load_wi_h0_mfi.pro
;               store_data.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;               2)  WindLib Libraries and the following shared objects:
;                     wind3dp_lib_ls32.so
;                     wind3dp_lib_ss32.so
;                     wind3dp_lib_darwin_i386.so   ; => for Macs
;
;  INPUT:
;               TIME       :  Scalar String ['YY-MM-DD/hh:mm:ss']
;               DELTAT     :  Scalar defining the number of hours to load
;
;  EXAMPLES:    
;               
;
;  KEYWORDS:    
;               QUALITY    :  [integer] specifying the quality of data with the following
;                                consequences for each bit case where the decommutator
;                                filter allows these issues through:
;                                1  :  Frame contains some fill data
;                                2  :  Packets can be invalid
;                                4  :  Packets can contain fill data
;                                [Default = 0 (most conservative option)]
;               MEMSIZE    :  Option that allows one to allocate more memory for IDL
;               IF_NEEDED  :  
;               NOSET      :  
;
;   CHANGED:  1)  Davin Larson changed something...          [11/05/2002   v1.0.20]
;             2)  Changed the source location of Level Zero data files to:
;                   '/data1/wind/3dp/lz/wi_lz_3dp_files'
;                   => Specific to the University of Minnesotat
;                                                            [06/19/2008   v1.0.22]
;             3)  Updated man page                           [08/05/2009   v1.1.0]
;             4)  Fixed minor syntax error                   [08/26/2009   v1.1.1]
;             5)  Updated man page, added shared object library and added error handling
;                                                            [08/05/2010   v1.2.0]
;
;   CREATED:  ??/??/????
;   CREATED BY:  Davin Larson
;    LAST MODIFIED:  08/05/2010   v1.2.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-


Last Modification =>  2008-06-23/22:24:16 UTC
;+
;BATCH FILE:	makehelp
;NAME:
;       makehelp
;PURPOSE:
;	Uses "mk_html_help2" to create an html help file
;       called  3dp_ref_man.html.  "help_3dp" will call
;       up a browser and open our on_line help facility, which
;       provides a link to the page generated by this procedure.
;INPUT:		none
;KEYWORDS:	N/A
;
;CREATED BY:	Jasper Halekas
;LAST MODIFICATION:	@(#)makehelp.pro	1.25   99/04/22
;-


Last Modification =>  2010-08-05/16:31:57 UTC
;+
;*****************************************************************************************
;
;  FUNCTION :   pl_mcp_eff.pro
;  PURPOSE  :   Loads Pesa Low channel plate efficiencies
;
;  CALLED BY:   
;               get_pl_extra.pro
;
;  CALLS:
;               umn_default_env.pro
;               read_asc.pro
;               time_double.pro
;               interp.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;               2)  ASCII file:
;                     pl_mcp_eff.dat
;
;  INPUT:
;               TIME  :  
;
;  EXAMPLES:    
;               
;
;  KEYWORDS:    
;               DEADT   :  Set to a named variable to return the 
;               MCPEFF  :  Set to a named variable to return the Pesa Low channel 
;                            plate efficiency
;               RESET   :  If set, uses Modified Pesa Low channel plate efficiency
;
;   CHANGED:  1)  Updated man page and added error handling for multiple OS's
;                                                                [08/05/2010   v1.1.0]
;
;   NOTES:      
;               
;
;   CREATED:  ??/??/????
;   CREATED BY:  Davin Larson
;    LAST MODIFIED:  08/05/2010   v1.1.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-


Last Modification =>  2010-08-05/13:34:59 UTC
;+
;*****************************************************************************************
;
;  FUNCTION :   wind_com.pro
;  PURPOSE  :   Common block for wind procedures
;
;  CALLED BY:   
;               init_wind_lib.pro
;               load_3dp_data.pro
;
;  CALLS:
;               NA
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               NA
;
;  EXAMPLES:    
;               @wind_com.pro
;
;  KEYWORDS:    
;               NA
;
;   CHANGED:  1)  Davin Larson changed something...          [11/01/2002   v1.0.6]
;             2)  Updated man page                           [08/05/2010   v1.1.0]
;
;   NOTES:      
;               
;
;   CREATED:  ??/??/????
;   CREATED BY:  Davin Larson
;    LAST MODIFIED:  08/05/2010   v1.1.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-



Last Modification =>  2008-06-23/22:23:54 UTC
;+
; FUNCTION: cdf_attr_exists, cdf, attrname
;
; PURPOSE:
;     determines if a specified CDF file has an attribute with a specified name
;
; INPUTS:
;     cdf:
;         either the cdf_id of an open CDF file, or the name of a CDF file
;     attrname:
;         name of the attribute to be asked about
;
; KEYWORDS:
;     scope:
;         if set, return the scope of the attribute (if it is present). The scope
;         may be either of the strings 'GLOBAL_SCOPE' or 'VARIABLE_SCOPE'.
;         The value of this variable is only meaningful if the return value is 1.
;
; OUTPUTS:
;     return value is 1 if yes, 0 if no
;
; CREATED BY: Vince Saba
;
; LAST MODIFICATION: @(#)cdf_attr_exists.pro	1.1 98/04/14
;-


Last Modification =>  2009-08-27/18:25:33 UTC
;+
;NAME:  cdf_info
;FUNCTION:   cdf_info(id)
;PURPOSE:
;  Returns a structure with useful information about a CDF file.
;  In particular the number of file records is returned in this structure.
;INPUT:
;   id:   CDF file ID.
;CREATED BY:    Davin Larson
; LAST MODIFIED: @(#)cdf_info.pro    1.9 02/11/01
; $LastChangedBy: davin-win $
; $LastChangedDate: 2007-09-21 11:54:11 -0700 (Fri, 21 Sep 2007) $
; $LastChangedRevision: 1609 $
; $URL: svn+ssh://thmsvn@ambrosia.ssl.berkeley.edu/repos/ssl_general/trunk/CDF/cdf_info.pro $
;-


Last Modification =>  2009-08-27/18:26:50 UTC
;+
;NAME:  cdf_var_atts
;FUNCTION:   cdf_var_atts(id [,var[,attname]])
;PURPOSE:
;  Returns a structure that contains all the attributes of a variable within
;  a CDF file. If attname is provided then it returns the value of only that attribute.
;KEYWORDS:
;  DEFAULT: The default value of the attribute.
;  ATTRIBUTES=att  A named variable that returns an array of structures containing attribute info
;                  if this variable is passed in on subsequent calls to cdf_var_atts it can significantly
;                  improve performance.   OBSOLETE!!!
;USAGE:
;   atts = cdf_var_atts(file)  ; returns structure containing all global attributes
;   atts = cdf_var_atts(file
;INPUT:
;   id:         CDF file ID or filename.
;   var;        CDF variable name or number
;   attname:    CDF attribute name
;CREATED BY:    Davin Larson
; $LastChangedBy: jimm $
; $LastChangedDate: 2008-03-11 12:14:10 -0700 (Tue, 11 Mar 2008) $
; $LastChangedRevision: 2469 $
; $URL: svn+ssh://thmsvn@ambrosia.ssl.berkeley.edu/repos/ssl_general/trunk/CDF/cdf_var_atts.pro $
;-


Last Modification =>  2008-06-23/22:23:54 UTC
;+
; FUNCTION: cdf_var_exists, cdf, varname
;
; PURPOSE:
;     determines if a specified CDF file has a variable with a specified name
;
; INPUTS:
;     cdf:
;         either the cdf_id of an open CDF file, or the name of a CDF file
;     attrname:
;         name of the variable to be asked about
;
; KEYWORDS:
;
; OUTPUTS:
;     return value is 1 if yes, 0 if no
;
; CREATED BY: Vince Saba
;
; LAST MODIFICATION: @(#)cdf_var_exists.pro	1.1 98/04/14
;-


Last Modification =>  2011-02-18/23:56:25 UTC
;+
;*****************************************************************************************
;
;  FUNCTION :   load_wi_h0_mfi.pro
;  PURPOSE  :   Loads wind magnetometer high resolution data into "TPLOT".
;
;  CALLED BY:   
;               load_3dp_data.pro
;
;  CALLS:
;               loadallcdf.pro
;               data_type.pro
;               str_element.pro
;               store_data.pro
;               options.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               NA
;
;  EXAMPLES:    
;               
;
;  KEYWORDS:    
;               TIME_RANGE  :  2-Element vector specifying the time range
;               POLAR       :  Also computes the B field in polar coordinates.
;               DATA        :  Data returned in this named variable.
;               HOUR        :  Load hourly averages instead of 3 second data.
;               MINUTE      :  Load 60 second averages instead of 3 second data.
;               NODATA      :  Returns 0 if data exists for time range, otherwise 
;                                returns 1.
;               GSM         :  If set, GSM data is retrieved as well as GSE.
;               PREFIX      :  (string) prefix for tplot variables.  
;                                [Default is 'wi_']
;               NAME        :  (string) name for tplot variables.
;                                [Default is 'wi_Bh']
;               RESOLUTION  :  Resolution to return in seconds.
;               MASTERFILE  :  (string) full filename of master file.
;               
;
;   CHANGED:  1)  P. Schroeder changed something...              [09/25/2003   v1.0.?]
;             2)  Changed plot labels for theta and phi B-fields due to 
;                   font issues                                  [06/19/2008   v1.1.0]
;             3)  Updated man page and fixed some things         [08/05/2010   v1.2.0]
;             4)  Fixed an issue that occurs when calculating the magnitude of B
;                                                                [02/18/2011   v1.2.1]
;
;   NOTES:      
;               1)  If time range is not set, program will call timespan.pro
;
;   CREATED:  ??/??/????
;   CREATED BY:  Peter Schroeder
;    LAST MODIFIED:  02/18/2011   v1.2.1
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-


Last Modification =>  2008-06-23/22:23:54 UTC
;+
;PROCEDURE:	load_wi_wav
;PURPOSE:	
;   loads WIND WAVES Experiment key parameter data for "tplot".
;
;INPUTS:	none, but will call "timespan" if time
;		range is not already set.
;KEYWORDS:
;  DATA:        Raw data can be returned through this named variable.
;  NVDATA:	Raw non-varying data can be returned through this variable.
;  TIME_RANGE:  2 element vector specifying the time range.
;  MASTERFILE:  (string) full file name to the master file.
;  RESOLUTION:  number of seconds resolution to return.
;  NE_FILTER:	Name of electron density variable to be used as filter.
;  MOON:	Load moon position data.
;  SOLAR:	Load solar data.
;SEE ALSO: 
;  "make_cdf_index","loadcdf","loadcdfstr","loadallcdf"
;
;CREATED BY:	Davin Larson
;FILE:  load_wi_wav.pro
;LAST MODIFICATION: 99/05/27
;-


Last Modification =>  2008-06-23/22:23:54 UTC
;+
;PROCEDURE: loadallcdf
;USAGE:
;  loadallcdf,  FORMAT
;PURPOSE:
;  Loads selected CDF file variables into a data structure.
;  VARYing data is returned through the keyword: DATA.
;  NOVARY data is returned through the keyword:  NOVARDATA.
;INPUT:
;  FORMAT is a string (i.e. 'wi_k0_3dp_files') that specify the type of
;  files to be searched for.  see "cdf_file_names" for more info.
;KEYWORDS:  (all keywords are optional)
;  FILENAMES:   string (array); full pathname of file(s) to be loaded.
;     (INDEXFILE, ENVIRONVAR, MASTERFILE and TIME_RANGE are ignored 
;     if this is set.)
;  TIME_RANGE:  Two element vector specifying time range (default is to use
;     trange_full; see "TIMESPAN" or "TIMERANGE" for more info)
;
;  CDFNAMES:    Names of CDF variables to be loaded. (string array)
;  TAGNAMES:	String array of structure tag names.
;  DATA:        Named variable that data is returned in.
;  RESOLUTION:	Resolution in seconds to be returned.
;
;  NOVARNAMES:  Names of 'novary' variables to be loaded
;  NOVARDATA:   Named variable that 'novary' data is returned in.
;
;  TPLOT_NAME:  "TPLOT" string name. If set then a tplot variable is created.
;     Individual elements can be referred to as 'NAME.ELEMENT'
;  CARR_FILE:	Load Carrington rotation files.
;
;SEE ALSO:
;  "loadcdf","loadcdfstr","makecdf","make_cdf_index","get_file_names","
;VERSION:  02/04/19  loadallcdf.pro  1.27
;Created by Davin Larson,  August 1996
;-


Last Modification =>  2008-06-23/22:23:54 UTC
;+
;PROCEDURE: loadallhdf
;PURPOSE:
;  Loads selected HDF file variables into a data structure.
;KEYWORDS:
;  VDATANAME:   (Required) name of VData set to be retrieved from HDF file.
;  (following keywords are optional)
;  FILENAMES:   string (array); full pathname of file(s) to be loaded.
;     (INDEXFILE, ENVIRONVAR, MASTERFILE and TIME_RANGE are ignored 
;     if this is set.)
;
;  MASTERFILE:  Full Pathname of indexfile or name of environment variable
;     giving path and filename information as defined in "get_file_names".
;     (INDEXFILE and ENVIRONVAR are ignored if this is set)
;
;  INDEXFILE:   File name (without path) of indexfile. This file
;     should be located in the directory given by ENVIRONVAR.  If not given
;     then "PICKFILE" is used to select an index file. see "make_cdf_index" for
;     information on producing this file.
;
;  ENVIRONVAR:  Name of environment variable containing directory of indexfiles
;     (default is 'CDF_INDEX_DIR')
;
;  TIME_RANGE:  Two element vector specifying time range (default is to use
;     trange_full; see "TIMESPAN" or "GET_TIMESPAN" for more info)
;
;  HDFNAMES:    Names of HDF variables to be loaded. (string array)
;  TAGNAMES:    String array of structure tag names.
;  DATA:        Named variable that data is returned in.
;
;  TPLOT_NAME:  "TPLOT" string name. If set then a tplot variable is created.
;     Individual elements can be referred to as 'NAME.ELEMENT'
;
;VERSION:  @(#)loadallhdf.pro	1.1 00/01/20
;Created by Peter Schroeder, January 2000
;-


Last Modification =>  2008-06-23/22:23:54 UTC
;+
;PROCEDURE:	loadcdf2
;PURPOSE:	
;   Loads one type of data from specified cdf file.
;INPUT:		
;	CDF_file:	the file to load data from  (or the id of an open file)
;	CDF_var:	the variable to load
;	x:		the variable to load data into
;
;KEYWORDS:
;	zvar:	 	must be set if variable to be loaded is a zvariable.
;       append:         appends data to the end of x instead of overwriting it.
;       nrecs:          number of records to be read.
;	no_shift:	if set, do not perform dimen_shift to data.
;	rec_start:	CDF record number to begin reading.
;
;CREATED BY:	Jim Byrnes, heavily modified by Davin Larson (was loadcdf)
;MODIFICATIONS:
;  96-6-26  added APPEND keyword
;LAST MODIFICATION:	@(#)loadcdf2.pro	1.5 98/08/13
;-


Last Modification =>  2008-06-23/22:23:54 UTC
;+
;PROCEDURE:	loadcdfstr
;PURPOSE:	
;  loads data from specified cdf file into a structure.
;INPUT:		
;	x:		A named variable to return the structure in
;	novardata:	A named variable to return the non-varying
;			data.
;
;KEYWORDS:
;       FILENAMES:  [array of] CDF filename[s].  (or file id's)
;	PATH:	    CDF file path.
;       VARNAMES:   [array of] CDF variable name[s] to be loaded.
;	NOVARNAMES: [array of] CDF non-varying field names.
;       TAGNAMES:   optional array of structure tag names.
;	RESOLUTION: resolution to return in seconds.
;	APPEND:     if set, append data to the end of x.
;       TIME:     If set, will create tag TIME using the Epoch variable.
;SEE ALSO:
;  "loadcdf2", "loadallcdf", "print_cdf_info","make_cdf_index"
;
;CREATED BY:	Davin Larson 
;MODIFICATIONS:
;LAST MODIFICATION:	@(#)loadcdfstr.pro	1.22 02/04/17
;-


Last Modification =>  2008-06-23/22:23:54 UTC
;+
;WARNING!!! This Function is OBSOLETE try not to use it...
;FUNCTION: pb5_to_time
;INPUT: pb5 array from cdf files (especially kpd files)
;OUTPUT:  double array,  seconds since 1970
;
;SEE ALSO: 	"print_cdf_info",
;		"loadcdf"
;
;CREATED BY: 	Davin Larson
;LAST MODIFICATION:	@(#)pb5_to_time.pro	1.5 95/10/18
;-


Last Modification =>  2009-08-11/00:09:21 UTC
;+
;*****************************************************************************************
;
;  FUNCTION :   reduce_dimen.pro
;  PURPOSE  :   Reduces a 3-Dimensional TPLOT structure to a 2-Dimensional TPLOT 
;                 structure such that it depends on only energy or pitch-angle,
;                 depending on user input.
;
;  CALLED BY:   
;               reduce_pads.pro
;
;  CALLS:
;               get_data.pro
;               dimen.pro
;               ndimen.pro
;               extract_tags.pro
;               store_data.pro
;
;  REQUIRES:    
;               NA
;
;  INPUT:
;               NAME     :  Scalar string associated with a TPLOT variable
;               D        :  Set to 1 to split up by energy or 2 to split up pitch-angles
;               N1       :  Scalar integer defining the start element to sum over
;               N2       :  Scalar integer defining the end element to sum over
;
;  EXAMPLES:    
;               reduce_dimen,name,d,n1,n2,DEFLIM=deflim,NEWNAME=newname
;
;  KEYWORDS:    
;               DEFLIM   :  Structure of default TPLOT plotting options
;               NEWNAME  :  Scalar string defining new TPLOT name to use for reduced data
;               DATA     :  Set to a named variable to return the data to
;               VRANGE   :  Set to a named variable to return the data being s
;               NAN      :  If set, program ignores NaNs
;
;   CHANGED:  1)  I did something...?                       [06/20/2008   v1.0.3]
;             2)  Updated man page and cleaned up a little  [08/10/2009   v1.1.0]
;
;   CREATED:  Sept 1995
;   CREATED BY:  Davin Larson
;    LAST MODIFIED:  08/10/2009   v1.1.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-


Last Modification =>  2009-10-18/15:13:35 UTC
;+
;*****************************************************************************************
;
;  FUNCTION :   reduce_pads.pro
;  PURPOSE  :   This program is intended to separate spectra structures produced by
;                 get_padspec.pro or get_padspecs.pro by angle or energy then return
;                 the new separated structures to TPLOT.
;
;  CALLED BY:   
;               calc_padspecs.pro
;
;  CALLS:
;               get_data.pro
;               store_data.pro
;               reduce_dimen.pro
;               options.pro
;               ylim.pro
;               roundsig.pro
;               ndimen.pro
;
;  REQUIRES:    
;               NA
;
;  INPUT:
;               NAME     :  Scalar string associated with a TPLOT variable
;               D        :  Set to 1 to split up by energy or 2 to split up pitch-angles
;               N1       :  Scalar integer defining the start element to sum over
;               N2       :  Scalar integer defining the end element to sum over
;
;  EXAMPLES:    
;               reduce_pads,name,d,n1,n2,DEFLIM=options,NEWNAME=newname,/NAN,E_UNITS=0,$
;                                        ANGLES=angles
;
;  KEYWORDS:    
;               DEFLIM   :  Structure of default TPLOT plotting options
;               NEWNAME  :  Scalar string defining new TPLOT name to use for reduced data
;               NAN      :  If set, program ignores NaNs
;               E_UNITS  :  Set to one of the following values to change the output units:
;                            0 = eV  [Default]
;                            1 = keV
;                            2 = MeV
;               ANGLES   :  Set to a named variable to return the pitch-angles (IF d=2)
;
;   CHANGED:  1)  Added keyword:  ANGLES                    [06/20/2008   v1.1.0]
;             2)  Updated man page and cleaned up a little  [08/10/2009   v1.2.0]
;             3)  Updated man page                          [10/18/2009   v1.2.1]
;
;   CREATED:  ??/??/????
;   CREATED BY:  Davin Larson
;    LAST MODIFIED:  10/18/2009   v1.2.1
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-


Last Modification =>  2010-08-05/13:28:31 UTC
;+
;*****************************************************************************************
;
;  FUNCTION :   setfileenv.pro
;  PURPOSE  :   Sets up environment variables giving information on the location
;                 of master index files and file paths of WIND 3DP data.
;
;  CALLED BY:   
;               
;
;  CALLS:
;               umn_default_env.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               NA
;
;  EXAMPLES:    
;               NA
;
;  KEYWORDS:    
;               NA
;
;   CHANGED:  1)  P. Schroeder changed something...              [09/25/2003   v1.0.26]
;             2)  Changed path locations                         [01/08/2008   v1.1.0]
;             3)  Updated man page and added error handling for multiple OS's and
;                   computer systems                             [08/05/2010   v1.2.0]
;
;   NOTES:      
;               
;
;   CREATED:  ??/??/????
;   CREATED BY:  Peter Schroeder
;    LAST MODIFIED:  08/05/2010   v1.2.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-


Last Modification =>  2008-08-11/22:00:35 UTC
;+
;WIND 3D Plasma startup procedure.
;Calling procedure:
;@start3dp
;PURPOSE:  Initializes 3DP code.
;
;CREATED BY:	Davin Larson
;LAST MODIFICATION:	@(#)start3dp.pro	1.10 97/02/10
;-



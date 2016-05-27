Last Modification =>  2010-01-04/16:03:16 UTC
;+
;*****************************************************************************************
;
;  FUNCTION :   cotrans.pro
;  PURPOSE  :   This program performs geophysical coordinate transformations
;                 GEI<-->GSE;
;                 GSE<-->GSM;
;                 GSM<-->SM;
;                 GEI<-->GEO;
;                 interpolates the spinphase, right ascension, declination
;                 updates coord_sys atribute of output tplot variable.
;
;  CALLED BY:   
;               
;
;  CALLS:
;               cotrans_lib.pro
;               get_data.pro
;               cotrans_get_coord.pro
;               sub_GSE2GSM.pro
;               sub_GEI2GSE.pro
;               sub_GSM2SM.pro
;               sub_GEI2GEO.pro
;               sub_GSE2GSM.pro
;               cotrans_set_coord.pro
;               str_element.pro
;               store_data.pro
;
;  REQUIRES:    
;               1)  THEMIS IDL Libraries
;
;  INPUT:
;               NAME_IN         :  Data in the input coordinate system (t-plot variable 
;                                    name, or array)
;               NAME_OUT        :  variable name for output (t-plot variable name, 
;                                    or array)
;               TIME            :  [Optional Input]  Array of times for input values,
;                                    if provided then the first parameter is an array,
;                                    and the second parameter is a named variable to
;                                    contain the output array.
;
;  EXAMPLES:    
;               cotrans, name_in, name_out [, time]
;
;               cotrans,'tha_fgl_gse','tha_fgl_gsm',/GSE2GSM
;               cotrans,'tha_fgl_gsm','tha_fgl_gse',/GSM2GSE
;
;               cotrans,'tha_fgl_gse','tha_fgl_gei',/GSE2GEI
;               cotrans,'tha_fgl_gei','tha_fgl_gse',/GEI2GSE
;
;               cotrans,'tha_fgl_gsm','tha_fgl_sm',/GSM2SM
;               cotrans,'tha_fgl_sm','tha_fgl_gsm',/SM2GSM
;
;  KEYWORDS:    
;               IGNORE_DLIMITS  :  If set, the program won't require the coordinate
;                                    system of the input tplot variable to match the 
;                                    coordinate system from which the data is being 
;                                    converted
;
;   CHANGED:  1)  P. Cruce changed something                  [01/29/2008   v1.0.?]
;             2)  Updated man page                            [01/04/2010   v1.1.0]
;
;   NOTES:      
;               1)  under construction!!
;               2)  URL: svn+ssh://thmsvn@ambrosia.ssl.berkeley.edu/repos/ssl_general/tags/tdas_4_00/cotrans/cotrans.pro
;
;   CREATED:  ??/??/????
;   CREATED BY:  Hannes Schwarzl & Patrick Cruce (pcruce@igpp.ucla.edu)
;    LAST MODIFIED:  01/04/2010   v1.1.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-


Last Modification =>  2010-01-04/16:18:10 UTC
;+
;*****************************************************************************************
;
;  FUNCTION :   cotrans_get_coord.pro
;  PURPOSE  :   Determine the coordinate system of data by examining the contents of
;                 of its DLIMIT structure.
;
;  CALLED BY:   
;               cotrans.pro
;
;  CALLS:
;               get_data.pro
;               str_element.pro
;
;  REQUIRES:    
;               1)  THEMIS IDL Libraries
;
;  INPUT:
;               DL     :  Anonymous STRUCT. or TPLOT variable name
;
;  EXAMPLES:    
;               cotrans_get_coord, dl
;
;  KEYWORDS:    
;               NA
;
;   CHANGED:  1)  kenb-mac changed something                   [05/01/2007   v1.0.?]
;             2)  Updated man page                             [01/04/2010   v1.1.0]
;
;   NOTES:      
;               
;
;   CREATED:  ??/??/????
;   CREATED BY:  ?
;    LAST MODIFIED:  01/04/2010   v1.1.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-


Last Modification =>  2010-01-04/16:18:30 UTC
;+
;pro sub_GSE2GSM
;
;Purpose: transforms data from GSE to GSM
;
;
;keywords:
;   /GSM2GSE : inverse transformation
;Example:
;      sub_GSE2GSM,tha_fglc_gse,tha_fglc_gsm
;
;      sub_GSE2GSM,tha_fglc_gsm,tha_fglc_gse,/GSM2GSE
;
;
;Notes: under construction!!  will run faster in the near future!!
;
;Written by Hannes Schwarzl
; $LastChangedBy: pcruce $
; $LastChangedDate: 2007-11-19 13:25:56 -0800 (Mon, 19 Nov 2007) $
; $LastChangedRevision: 2056 $
; $URL: svn+ssh://thmsvn@ambrosia.ssl.berkeley.edu/repos/ssl_general/tags/tdas_4_00/cotrans/cotrans_lib.pro $
;-
;+
;pro: sub_GEI2GSE
;
;Purpose: transforms THEMIS fluxgate magnetometer data from GEI to GSE
;
;
;keywords:
;   /GSE2GEI : inverse transformation
;Example:
;      sub_GEI2GSE,tha_fglc_gei,tha_fglc_gse
;
;      sub_GEI2GSE,tha_fglc_gse,tha_fglc_gei,/GSE2GEI
;
;
;Notes: under construction!!  will run faster in the near future!!
;
; $LastChangedBy: pcruce $
; $LastChangedDate: 2007-11-19 13:25:56 -0800 (Mon, 19 Nov 2007) $
; $LastChangedRevision: 2056 $
; $URL $
;-
;+
;pro sub_GSM2SM
;
;Purpose: transforms data from GSM to SM
;
;
;keywords:
;   /SM2GSM : inverse transformation
;Example:
;      sub_GSM2SM,tha_fglc_gsm,tha_fglc_sm
;
;      sub_GSM2SM,tha_fglc_sm,tha_fglc_gsm,/SM2GSM
;
;
;Notes: under construction!!  will run faster in the near future!!
;
;Written by Hannes Schwarzl
; $LastChangedBy: pcruce $
; $LastChangedDate: 2007-11-19 13:25:56 -0800 (Mon, 19 Nov 2007) $
; $LastChangedRevision: 2056 $
; $URL: svn+ssh://thmsvn@ambrosia.ssl.berkeley.edu/repos/ssl_general/tags/tdas_4_00/cotrans/cotrans_lib.pro $
;-
;+
;pro sub_GEI2GEO
;
;Purpose: transforms data from GEI to GEO
;
;
;keywords:
;   /GEO2GEI : inverse transformation
;Example:
;      sub_GEI2GEO,tha_fglc_gei,tha_fglc_geo
;
;      sub_GEI2GEO,tha_fglc_geo,tha_fglc_gei,/GEO2GEI
;
;
;Notes:
;
;Written by Patrick Cruce(pcruce@igpp.ucla.edu)
; $LastChangedBy: pcruce $
; $LastChangedDate: 2007-11-19 13:25:56 -0800 (Mon, 19 Nov 2007) $
; $LastChangedRevision: 2056 $
; $URL: svn+ssh://thmsvn@ambrosia.ssl.berkeley.edu/repos/ssl_general/tags/tdas_4_00/cotrans/cotrans_lib.pro $
;-
;+
;proceddure: subGEI2GSE
;
;Purpose: transforms data from GEI to GSE
;
;INPUTS: TIMES as time_struct, DATA_in as nx3 array
;
;
;keywords:
;
;Example:
;
;
;Notes: under construction!!  will run faster in the near future!!
;
; $LastChangedBy: pcruce $
; $LastChangedDate: 2007-11-19 13:25:56 -0800 (Mon, 19 Nov 2007) $
; $LastChangedRevision: 2056 $
; $URL $
;-
;+
;procedure: subGSE2GEI
;
;Purpose: transforms data from GSE to GEI
;
;INPUTS: TIMES as time_struct, DATA_in as nx3 array
;
;
;keywords:
;
;Example:
;
;
;Notes: under construction!!  will run faster in the near future!!
;
; $LastChangedBy: pcruce $
; $LastChangedDate: 2007-11-19 13:25:56 -0800 (Mon, 19 Nov 2007) $
; $LastChangedRevision: 2056 $
; $URL $
;-
;+
;procedure: subGSE2GSM
;
;Purpose: transforms data from GSE to GSM
;
;INPUTS: TIMES as time_struct, DATA_in as nx3 array
;
;
;keywords:
;
;Example:
;
;
;Notes: under construction!!  will run faster in the near future!!
;
; $LastChangedBy: pcruce $
; $LastChangedDate: 2007-11-19 13:25:56 -0800 (Mon, 19 Nov 2007) $
; $LastChangedRevision: 2056 $
; $URL $
;-
;+
;procedure: subGSM2GSE
;
;Purpose: transforms data from GSM to GSE
;
;INPUTS: TIMES as time_struct, DATA_in as nx3 array
;
;
;keywords:
;
;Example:
;
;
;Notes: under construction!!  will run faster in the near future!!
;
; $LastChangedBy: pcruce $
; $LastChangedDate: 2007-11-19 13:25:56 -0800 (Mon, 19 Nov 2007) $
; $LastChangedRevision: 2056 $
; $URL $
;-
;+
;procedure: subGSM2SM
;
;Purpose: transforms data from GSM to SM
;
;INPUTS: TIMES as time_struct, DATA_in as nx3 array
;
;
;keywords:
;
;Example:
;
;
;Notes: under construction!!
;
; $LastChangedBy: pcruce $
; $LastChangedDate: 2007-11-19 13:25:56 -0800 (Mon, 19 Nov 2007) $
; $LastChangedRevision: 2056 $
; $URL $
;-
;+
;procedure: subSM2GSM
;
;Purpose: transforms data from SM to GSM
;
;INPUTS: TIMES as time_struct, DATA_in as nx3 array
;
;
;keywords:
;
;Example:
;
;
;Notes: under construction!!
;
; $LastChangedBy: pcruce $
; $LastChangedDate: 2007-11-19 13:25:56 -0800 (Mon, 19 Nov 2007) $
; $LastChangedRevision: 2056 $
; $URL $
;-
;+
;procedure: subGEI2GEO
;
;Purpose: transforms data from GEI to GEO
;
;INPUTS: TIMES as time_struct, DATA_in as nx3 array
;
;
;keywords:
;
;Example:
;
;
;Notes: under construction!!
;
; $LastChangedBy: pcruce $
; $LastChangedDate: 2007-11-19 13:25:56 -0800 (Mon, 19 Nov 2007) $
; $LastChangedRevision: 2056 $
; $URL $
;-
;+
;procedure: subGEO2GEI
;
;Purpose: transforms data from GEO to GEI
;
;INPUTS: TIMES as time_struct, DATA_in as nx3 array
;
;
;keywords:
;
;Example:
;
;
;Notes: under construction!!
;
; $LastChangedBy: pcruce $
; $LastChangedDate: 2007-11-19 13:25:56 -0800 (Mon, 19 Nov 2007) $
; $LastChangedRevision: 2056 $
; $URL $
;-
;+
;procedure: csundir_vect
;
;Purpose: calculates the direction of the sun
;         (vectorized version of csundir from ROCOTLIB by
;          Patrick Robert)
;
;INPUTS: integer time
;
;
;output :      gst      greenwich mean sideral time (radians)
;              slong    longitude along ecliptic (radians)
;              sra      right ascension (radians)
;              sdec     declination of the sun (radians)
;              obliq    inclination of Earth's axis (radians)
;
;
;
;Notes: under construction!!
;
; $LastChangedBy: pcruce $
; $LastChangedDate: 2007-11-19 13:25:56 -0800 (Mon, 19 Nov 2007) $
; $LastChangedRevision: 2056 $
; $URL $
;-
;+
;procedure: tgeigse_vect
;
;Purpose: GEI to GSE transformation
;         (vectorized version of tgeigse from ROCOTLIB by
;          Patrick Robert)
;
;
;
;Notes: under construction!!
;
; $LastChangedBy: pcruce $
; $LastChangedDate: 2007-11-19 13:25:56 -0800 (Mon, 19 Nov 2007) $
; $LastChangedRevision: 2056 $
; $URL $
;-
;+
;procedure: tgsegei_vect
;
;Purpose: GSE to GEI transformation
;         (vectorized version of tgsegei from ROCOTLIB by
;          Patrick Robert)
;
;
;
;Notes: under construction!!
;
; $LastChangedBy: pcruce $
; $LastChangedDate: 2007-11-19 13:25:56 -0800 (Mon, 19 Nov 2007) $
; $LastChangedRevision: 2056 $
; $URL $
;-
;+
;procedure: tgsegsm_vect
;
;Purpose: GSE to GSM transformation
;         (vectorized version of tgsegsm from ROCOTLIB by
;          Patrick Robert)
;
;
;
;Notes: under construction!!
;
; $LastChangedBy: pcruce $
; $LastChangedDate: 2007-11-19 13:25:56 -0800 (Mon, 19 Nov 2007) $
; $LastChangedRevision: 2056 $
; $URL $
;-
;+
;procedure: tgsmgse_vect
;
;Purpose: GSM to GSE transformation
;         (vectorized version of tgsmgse from ROCOTLIB by
;          Patrick Robert)
;
;
;
;Notes: under construction!!
;
; $LastChangedBy: pcruce $
; $LastChangedDate: 2007-11-19 13:25:56 -0800 (Mon, 19 Nov 2007) $
; $LastChangedRevision: 2056 $
; $URL $
;-
;+
;procedure: tgsmsm_vect
;
;Purpose: GSM to SM transformation
;         (vectorized version of tgsmsma from ROCOTLIB by
;          Patrick Robert)
;
;
;
;Notes: under construction!!
;
; $LastChangedBy: pcruce $
; $LastChangedDate: 2007-11-19 13:25:56 -0800 (Mon, 19 Nov 2007) $
; $LastChangedRevision: 2056 $
; $URL $
;-
;+
;procedure: tsmgsm_vect
;
;Purpose: SM to GSM transformation
;         (vectorized version of tsmagsm from ROCOTLIB by
;          Patrick Robert)
;
;
;
;Notes: under construction!!
;
; $LastChangedBy: pcruce $
; $LastChangedDate: 2007-11-19 13:25:56 -0800 (Mon, 19 Nov 2007) $
; $LastChangedRevision: 2056 $
; $URL $
;-
;+
;procedure: cdipdir_vect
;
;Purpose: calls cdipdir from ROCOTLIB in a vectorized environment
;
;
;
;Notes: under construction!!
;
; $LastChangedBy: pcruce $
; $LastChangedDate: 2007-11-19 13:25:56 -0800 (Mon, 19 Nov 2007) $
; $LastChangedRevision: 2056 $
;
; faster algorithm (for loop across all points avoided) Hannes 05/25/2007
;
; $URL $
;-
;+
;procedure: cdipdir
;
;Purpose: cdipdir from ROCOTLIB. direction of Earth's magnetic axis in GEO
;
;
;
;Notes: under construction!!
;
; $LastChangedBy: pcruce $
; $LastChangedDate: 2007-11-19 13:25:56 -0800 (Mon, 19 Nov 2007) $
; $LastChangedRevision: 2056 $
; $URL $
;-


Last Modification =>  2010-01-04/16:13:57 UTC
;+
;*****************************************************************************************
;
;  FUNCTION :   cotrans_set_coord.pro
;  PURPOSE  :   Sets the coordinate system of data by setting the data_att structure 
;                 of its DLIMIT structure.
;
;  CALLED BY:   
;               cotrans.pro
;
;  CALLS:
;               str_element.pro
;               store_data.pro
;
;  REQUIRES:    
;               1)  THEMIS IDL Libraries
;
;  INPUT:
;               DL     :  Anonymous STRUCT.
;               COORD  :  Scalar string defining the coordinate system
;
;  EXAMPLES:    
;               cotrans_set_coord, dl, 'gei'
;
;  KEYWORDS:    
;               NA
;
;   CHANGED:  1)  kenb-mac changed something                   [08/01/2007   v1.0.?]
;             2)  Updated man page                             [01/04/2010   v1.1.0]
;
;   NOTES:      
;               
;
;   CREATED:  ??/??/????
;   CREATED BY:  ?
;    LAST MODIFIED:  01/04/2010   v1.1.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-



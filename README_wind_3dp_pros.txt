Last Modification =>  2009-10-22/17:03:08 UTC
;+
;*****************************************************************************************
;
;  FUNCTION :   TMlib_wrapper.pro
;  PURPOSE  :   Compiles STEREO TM-Library software if available.
;
;  CALLED BY:   
;               start_umn_3dp.pro
;
;  CALLS:
;               TMlib.pro
;               TMlib_Time.pro
;               TM_Client_Info.pro
;
;  REQUIRES:    
;               TMlib software package for STEREO
;
;  INPUT:
;               NA
;
;  EXAMPLES:    
;               @TMlib_wrapper
;
;  KEYWORDS:    
;               NA
;
;   CHANGED:  1)  NA [MM/DD/YYYY   v1.0.0]
;
;   NOTES:      
;               
;
;   CREATED:  10/22/2009
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  10/22/2009   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-


Last Modification =>  2010-09-24/12:30:59 UTC
;+
;COMMON BLOCK  colors_com_inc
;WARNING!  Don't rely on this file to remain stable!
;USE "get_colors" to get color information.
;SEE ALSO:
;  "get_colors","bytescale","loadct2"
;-


Last Modification =>  2009-10-22/17:03:18 UTC
;+
;*****************************************************************************************
;
;  FUNCTION :   start_umn_3dp.pro
;  PURPOSE  :   Start up routine to initialize UMN versions of Berkeley SSL 
;                 Wind/3DP software upon starting IDL.
;
;  CALLED BY:   
;               NA
;
;  CALLS:
;               wind_3dp_umn_init.pro
;               plot3d_options.pro
;               TMlib_wrapper.pro
;
;  REQUIRES:    
;               UMN Edited 3DP Libraries
;
;  INPUT:
;               NA
;
;  EXAMPLES:    
;               @start_umn_3dp
;
;  KEYWORDS:    
;               NA
;
;   CHANGED:  1)  Changed compliation list                         [09/17/2009   v1.0.1]
;             2)  Changed compliation list                         [09/18/2009   v1.0.2]
;             3)  Added plot3d.pro options by calling plot3d_options.pro with default
;                   options already chosen                         [09/18/2009   v1.0.3]
;             4)  Changed compliation list                         [09/21/2009   v1.0.4]
;             5)  Added a device call for default formats          [09/21/2009   v1.0.5]
;             6)  Changed compliation list                         [09/24/2009   v1.0.6]
;             7)  Added extra option for plot3d_options.pro        [09/25/2009   v1.0.7]
;             8)  Added extra option for TMlib Client Software compilation which acts
;                   similar to calling "sidl" from command prompt instead of "uidl"
;                                                                  [10/22/2009   v1.1.0]
;
;   NOTES:      
;               1)  Still in production...
;
;   CREATED:  09/16/2009
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  10/22/2009   v1.1.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-


Last Modification =>  2009-11-12/15:09:18 UTC
;+
;*****************************************************************************************
;
;  FUNCTION :   umn_default_env.pro
;  PURPOSE  :   Sets up the default structure of the new system variable, !WIND3DP_UMN.
;
;  CALLED BY:   
;               wind_3dp_umn_init.pro
;
;  CALLS:
;               NA
;
;  REQUIRES:    
;               NA
;
;  INPUT:
;               NA
;
;  EXAMPLES:    
;               structure_format = umn_default_env()
;
;  KEYWORDS:    
;               NA
;
;   CHANGED:  1)  Changed output structure format                  [09/24/2009   v1.1.0]
;
;   NOTES:      
;               
;
;   CREATED:  09/16/2009
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  09/24/2009   v1.1.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-
;+
;*****************************************************************************************
;
;  FUNCTION :   wind_3dp_umn_init.pro
;  PURPOSE  :   Called by start_umn_3dp.pro and intializes a new system
;                 variable, !WIND3DP_UMN, for later use with directory calls.
;
;  CALLED BY:   
;               start_umn_3dp.pro
;
;  CALLS:
;               umn_default_env.pro        ; => Located above this routine
;
;  REQUIRES:    
;               UMN Edited 3DP Libraries
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
;   CHANGED:  1)  Changed start_umn_3dp.pro compile list         [09/17/2009   v1.0.1]
;             2)  Changed output system variable format          [09/24/2009   v1.1.0]
;             3)  Fixed a typo in WIND_ORBIT_DIR definition      [11/12/2009   v1.1.1]
;
;   NOTES:      
;               1)  This program should be called at startup by start_umn_3dp.pro
;
;   CREATED:  09/16/2009
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  11/12/2009   v1.1.1
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-



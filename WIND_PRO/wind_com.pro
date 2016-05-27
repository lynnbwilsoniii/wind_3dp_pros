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

COMMON wind_com,  data_directory, lz_3dp_files, wind_lib, loaded_trange, $
                  refdate, project_name
;    reftime, $
   



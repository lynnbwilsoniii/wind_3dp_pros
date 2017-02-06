;+
;*****************************************************************************************
;
;  FUNCTION :   read_wind_sr_data.pro
;  PURPOSE  :   This routine reads the ASCII file containing information about the
;                 Wind spacecraft solar array, regulated bus current, and batteries.
;
;  CALLED BY:   
;               NA
;
;  CALLS:
;               get_os_slash.pro
;               time_double.pro
;               str_element.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;               2)  ASCII File:  wind_senior_review_data.txt
;
;  INPUT:
;               NA
;
;  EXAMPLES:    
;               IDL> test = read_wind_sr_data()
;
;  KEYWORDS:    
;               NA
;
;   CHANGED:  1)  Added six more columns of data including:  max output bias charge
;                   current for each battery and avg battery temperature for each
;                   battery
;                                                                   [01/18/2013   v1.1.0]
;             2)  Updated to account for new location of routine and ASCII file and
;                   now calls get_os_slash.pro
;                                                                   [11/08/2013   v1.1.1]
;
;   NOTES:      
;               
;
;  REFERENCES:  
;               1)  Harten, R., K. Clark (1995) "The Design Features of the GGS Wind
;                      and Polar Spacecraft," Space Sci. Rev. Vol. 71, pp. 23-40.
;
;   CREATED:  01/08/2013
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  11/08/2013   v1.1.1
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION read_wind_sr_data

;;----------------------------------------------------------------------------------------
;;  Define some constants and dummy variables
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
pick_mssg      = 'Select the desired file and then click okay'
;;  Define format of file
mform          = '(a10,I8.3,15f25.4)'
slash          = get_os_slash()         ;;  '/' for Unix, '\' for Windows
;;----------------------------------------------------------------------------------------
;;  Load all relevant data
;;----------------------------------------------------------------------------------------
;;  Define directory location of file
dir_str        = '.'+slash[0]+'wind_3dp_pros'+slash[0]+'Wind_Engineering'+slash[0]
mdir           = FILE_EXPAND_PATH(dir_str[0])
;;  Define file name
fname          = 'wind_senior_review_data.txt'
file           = FILE_SEARCH(mdir,fname[0])
;;----------------------------------------------------------------------------------------
;;  Check for file
;;----------------------------------------------------------------------------------------
good           = WHERE(file[0] NE '',gd)
IF (gd EQ 0) THEN BEGIN
  gfile = DIALOG_PICKFILE(PATH=dir_str[0],TITLE=pick_mssg)
ENDIF ELSE BEGIN
  gfile = file[0]
ENDELSE
;;----------------------------------------------------------------------------------------
;;  Define relevant quantities
;;      Units:  A = ampere, V = volts
;;----------------------------------------------------------------------------------------
n              = FILE_LINES(gfile[0]) - 4L    ;;  number of lines of data in file
month          = STRARR(n)                    ;;  Month of year [e.g., '11']
day            = STRARR(n)                    ;;  Day of month [e.g., '03']
year           = STRARR(n)                    ;;  Year [e.g., '1994']
dates          = STRARR(n)                    ;;  Dates [e.g., '1994-11-03/00:00:00.000']
doy            = LONARR(n)                    ;;  Day of Year
;;  Solar array and regulated bus currents have been filtered to remove shadow intervals
sa__avg        = DBLARR(n)                    ;;  Solar array current output [Avg., A]
sa__min        = DBLARR(n)                    ;;  Solar array current output [Min., A]
sa__max        = DBLARR(n)                    ;;  Solar array current output [Max., A]
rb__avg        = DBLARR(n)                    ;;  Regulated bus current output [Avg., A]
rb__min        = DBLARR(n)                    ;;  Regulated bus current output [Min., A]
rb__max        = DBLARR(n)                    ;;  Regulated bus current output [Max., A]
bv1_avg        = DBLARR(n)                    ;;  Battery-1 bias voltage output [Avg., V]
bv2_avg        = DBLARR(n)                    ;;  Battery-2 bias voltage output [Avg., V]
bv3_avg        = DBLARR(n)                    ;;  Battery-3 bias voltage output [Avg., V]
cc1_max        = DBLARR(n)                    ;;  Charge current on Battery-1 [Max., A]
cc2_max        = DBLARR(n)                    ;;  Charge current on Battery-2 [Max., A]
cc3_max        = DBLARR(n)                    ;;  Charge current on Battery-3 [Max., A]
bt1_avg        = DBLARR(n)                    ;;  Battery-1 temperature [Avg., deg. C]
bt2_avg        = DBLARR(n)                    ;;  Battery-2 temperature [Avg., deg. C]
bt3_avg        = DBLARR(n)                    ;;  Battery-3 temperature [Avg., deg. C]
;;  Define dummy variables for reading in data
a              = ''                           ;; e.g., '11/03/1994'
b              = 0L                           ;; e.g., 307
c              = DBLARR(15)
;;----------------------------------------------------------------------------------------
;;  Open file and read header
;;----------------------------------------------------------------------------------------
mline          = ''
infile         = gfile[0]
OPENR,gunit,infile,/GET_LUN
FOR mvc=0L, 3L DO READF,gunit,mline
;;----------------------------------------------------------------------------------------
;;  Read file and define data
;;----------------------------------------------------------------------------------------
FOR j=0L, n - 1L DO BEGIN
  READF,gunit,a,b,c,FORMAT=mform
  ;;  Define date and day of year
  year[j]     = STRMID(a[0],6L)
  month[j]    = STRMID(a[0],0L,2L)
  day[j]      = STRMID(a[0],3L,2L)
  doy[j]      = LONG(b[0])
  ;;  Define solar array outputs
  sa__avg[j]  = DOUBLE(c[0])
  sa__min[j]  = DOUBLE(c[1])
  sa__max[j]  = DOUBLE(c[2])
  ;;  Define regulated bus outputs
  rb__avg[j]  = DOUBLE(c[3])
  rb__min[j]  = DOUBLE(c[4])
  rb__max[j]  = DOUBLE(c[5])
  ;;  Define avg battery bias voltage outputs
  bv1_avg[j]  = DOUBLE(c[6])
  bv2_avg[j]  = DOUBLE(c[7])
  bv3_avg[j]  = DOUBLE(c[8])
  ;;  Define max battery charge currents
  cc1_max[j]  = DOUBLE(c[9])
  cc2_max[j]  = DOUBLE(c[10])
  cc3_max[j]  = DOUBLE(c[11])
  ;;  Define avg battery temperatures
  bt1_avg[j]  = DOUBLE(c[12])
  bt2_avg[j]  = DOUBLE(c[13])
  bt3_avg[j]  = DOUBLE(c[14])
ENDFOR
;;  Close file
FREE_LUN,gunit
;;----------------------------------------------------------------------------------------
;;  Define timestamps
;;----------------------------------------------------------------------------------------
dates          = year+'-'+month+'-'+day+'/00:00:00.000'
unix           = time_double(dates)
;;----------------------------------------------------------------------------------------
;;  Define dummy structure to return to user
;;----------------------------------------------------------------------------------------
;;  Define dates and timestamps
str_element,dummy,'SCETS'        ,dates       ,/ADD_REPLACE
str_element,dummy,'DOY'          ,doy         ,/ADD_REPLACE
str_element,dummy,'UNIX'         ,unix        ,/ADD_REPLACE
;;  Define solar array outputs
str_element,dummy,'SOLARR_AVG'   ,sa__avg     ,/ADD_REPLACE
str_element,dummy,'SOLARR_MIN'   ,sa__min     ,/ADD_REPLACE
str_element,dummy,'SOLARR_MAX'   ,sa__max     ,/ADD_REPLACE
;;  Define regulated bus outputs
str_element,dummy,'REGBUS_AVG'   ,rb__avg     ,/ADD_REPLACE
str_element,dummy,'REGBUS_MIN'   ,rb__min     ,/ADD_REPLACE
str_element,dummy,'REGBUS_MAX'   ,rb__max     ,/ADD_REPLACE
;;  Define avg battery bias voltage outputs
str_element,dummy,'BV1_AVG'      ,bv1_avg     ,/ADD_REPLACE
str_element,dummy,'BV2_AVG'      ,bv2_avg     ,/ADD_REPLACE
str_element,dummy,'BV3_AVG'      ,bv3_avg     ,/ADD_REPLACE
;;  Define max battery charge currents
str_element,dummy,'CC1_MAX'      ,cc1_max     ,/ADD_REPLACE
str_element,dummy,'CC2_MAX'      ,cc2_max     ,/ADD_REPLACE
str_element,dummy,'CC3_MAX'      ,cc3_max     ,/ADD_REPLACE
;;  Define avg battery temperatures
str_element,dummy,'BT1_AVG'      ,bt1_avg     ,/ADD_REPLACE
str_element,dummy,'BT2_AVG'      ,bt2_avg     ,/ADD_REPLACE
str_element,dummy,'BT3_AVG'      ,bt3_avg     ,/ADD_REPLACE
;;----------------------------------------------------------------------------------------
;;  Return dummy structure to user
;;----------------------------------------------------------------------------------------

RETURN,dummy
END
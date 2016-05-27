;+
;*****************************************************************************************
;
;  FUNCTION :   get_pl_cal.pro
;  PURPOSE  :   This routine returns a 3D structure containing all data pertinent to a 
;                 single Pesa Low 3D data sample.  See "3D_STRUCTURE" for a more 
;                 complete description of the structure.
;
;  CALLED BY:   
;               cal_pl_mcp_eff.pro
;
;  CALLS:
;               wind_com.pro
;               ctime.pro
;               gettime.pro
;               add_all.pro
;
;  REQUIRES:    
;               1)  External Windlib libraries
;               2)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               T        :  Scalar or 2-Element Unix time telling the program what the
;                             start or start and stop times of interest are
;               ADD      :  Optional input telling program to add some data 
;                             structure tags to to the return structure
;
;  EXAMPLES:    
;               t  = '1995-01-01/00:00:00'
;               td = time_double(t)
;               pl = get_pl_cal(td)
;
;  KEYWORDS:    
;               TIMES    :  If set, program returns the start times of all the Pesa
;                             Low distributions within the time range loaded
;               INDEX    :  Scalar integer telling program to select data by sample
;                             index instead of times
;               ADVANCE  :  If set, program gets the next distribution
;
;   CHANGED:  1)  Changed the way the mass is calculated           [07/19/2011   v1.0.1]
;             2)  Fixed an error in the MASS calculated
;                                                                  [08/05/2013   v1.1.0]
;
;   NOTES:      
;               1)  Adaptation of get_pl.pro to avoid calling get_pl_extra.pro for
;                     calibration of MCP efficiency
;
;   CREATED:  06/07/2011
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  08/05/2013   v1.1.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION get_pl_cal,t,add,TIMES=tms,INDEX=idx,ADVANCE=adv

;;----------------------------------------------------------------------------------------
;;  Define some constants and dummy variables
;;----------------------------------------------------------------------------------------
c              = 2.99792458d8      ;;  Speed of light in vacuum [m/s]
c2             = c[0]^2
ckm            = 2.99792458d5      ;;  Speed of light in vacuum [km/s]
ckm2           = ckm[0]^2
me             = 9.10938291d-31    ;;  Electron mass [kg] [2010 value]
mp             = 1.672621777d-27   ;;  Proton mass [kg] [2010 value]
qq             = 1.602176565d-19   ;;  Fundamental charge (C) [2010 value]
;;  convert masses to [eV c^(-2)]
me_eV          = me[0]*c2[0]/qq[0]
mp_eV          = mp[0]*c2[0]/qq[0]
;;  convert masses to [eV km^(-2) s^(2)]
me_esa         = me_eV[0]/ckm2[0]
mp_esa         = mp_eV[0]/ckm2[0]
;;----------------------------------------------------------------------------------------
;;  Load common blocks
;;----------------------------------------------------------------------------------------
@wind_com.pro

;;----------------------------------------------------------------------------------------
;;  Define a dummy structure format
;;----------------------------------------------------------------------------------------
dat = { pl_struct,                                         $
   PROJECT_NAME     :  'Wind 3D Plasma',                   $
   DATA_NAME        :  'Pesa Low',                         $
   UNITS_NAME       :  'Counts',                           $
   UNITS_PROCEDURE  :  'convert_esa_units',                $
   TIME             :  0.d,                                $
   END_TIME         :  0.d,                                $
   TRANGE           :  [0.d,0.d],                          $
   INTEG_T          :  0.d,                                $
   DELTA_T          :  0.d,                                $
   MASS             :  0.d,                                $
   GEOMFACTOR       :  0.d,                                $
   INDEX            :  0L,                                 $
   VALID            :  0,                                  $
   SPIN             :  0L,                                 $
   NBINS            :  25,                                 $
   NENERGY          :  14,                                 $
   DACCODES         :  INTARR(4,14),                       $
   VOLTS            :  FLTARR(4,14),                       $
   DATA             :  FLTARR(14, 25),                     $
   ENERGY           :  FLTARR(14, 25),                     $
   DENERGY          :  FLTARR(14, 25),                     $
   PHI              :  FLTARR(14, 25),                     $
   DPHI             :  FLTARR(14, 25),                     $
   THETA            :  FLTARR(14, 25),                     $
   DTHETA           :  FLTARR(14, 25),                     $
   BINS             :  REPLICATE(1b,14,25),                $
   DT               :  FLTARR(14,25),                      $
   GF               :  FLTARR(14,25),                      $
   BKGRATE          :  FLTARR(14,25),                      $
   DEADTIME         :  FLTARR(14,25),                      $
   DVOLUME          :  FLTARR(14,25),                      $
   DDATA            :  REPLICATE(!VALUES.F_NAN,14,25),     $
   MAGF             :  REPLICATE(!VALUES.F_NAN,3),         $
   SC_POT           :  0.,                                 $
   P_SHIFT          :  0b,                                 $
   T_SHIFT          :  0b,                                 $
   E_SHIFT          :  0b,                                 $
   DOMEGA           :  FLTARR(25)                          $
}

;;----------------------------------------------------------------------------------------
;;  Check input and keywords
;;----------------------------------------------------------------------------------------
size = N_TAGS(dat,/LENGTH)
IF (N_ELEMENTS(idx) EQ 0) AND (N_ELEMENTS(t) EQ 0) AND (NOT KEYWORD_SET(adv)) $
  AND (NOT KEYWORD_SET(tms)) THEN ctime,t
IF KEYWORD_SET(adv) THEN a = adv ELSE a = 0
IF (N_ELEMENTS(idx) EQ 0) THEN i = -1 ELSE i = idx
IF (N_ELEMENTS(t)   EQ 0) THEN t = 0.d

options = LONG([size,a,i])
;;----------------------------------------------------------------------------------------
;;  Make sure 3DP data has been loaded into IDL
;;----------------------------------------------------------------------------------------
IF (N_ELEMENTS(wind_lib) EQ 0) THEN BEGIN
  MESSAGE,'You must first load the data',/INFORMATIONAL,/CONTINUE
  RETURN,0
ENDIF
;;----------------------------------------------------------------------------------------
;;  Get times if requested
;;----------------------------------------------------------------------------------------
IF KEYWORD_SET(tms) THEN BEGIN
  num        = CALL_EXTERNAL(wind_lib,'pl5x5_to_idl')
  options[0] = num
  PRINT, num,' Pesa low time samples'
  times      = DBLARR(num)
  ok         = CALL_EXTERNAL(wind_lib,'pl5x5_to_idl',options,times)
  RETURN,times
ENDIF

time = gettime(t)
IF (N_ELEMENTS(time) EQ 1) THEN time = [time,time]
;;----------------------------------------------------------------------------------------
;;  Keep dummy structure format
;;----------------------------------------------------------------------------------------
retdat  = dat
q       = 0
oldtime = dat.TIME
integ   = (N_ELEMENTS(t) GE 2)
;;----------------------------------------------------------------------------------------
;;  get data structures from Windlib libraries
;;----------------------------------------------------------------------------------------
REPEAT BEGIN
   ok           = CALL_EXTERNAL(wind_lib,'pl5x5_to_idl',options,time,dat)
   dat.END_TIME = dat.TIME + dat.INTEG_T
   IF (retdat.VALID EQ 0) THEN retdat = dat   $
   ELSE IF (dat.TIME GE oldtime AND dat.VALID EQ 1) THEN BEGIN
           retdat.DATA     = dat.DATA +  retdat.DATA
           retdat.DT       = dat.DT   +  retdat.DT
           retdat.DELTA_T  = dat.DELTA_T + retdat.DELTA_T
           retdat.INTEG_T  = dat.INTEG_T + retdat.INTEG_T
           retdat.END_TIME = dat.END_TIME
           oldtime         = dat.TIME
           q               = dat.END_TIME GT time[1]
   ENDIF ELSE IF dat.VALID EQ 1 THEN q = 1
   options[2] = dat.INDEX + 1
   IF (time[1] EQ time[0]) THEN q = 1
ENDREP UNTIL q

retdat.TRANGE = [retdat.TIME,retdat.END_TIME]
;;  [mass] = eV/(km/sec)^2
;qq                = 1.60217733d-19      ;;  Fundamental charge (C)
;me                = 9.1093897d-31       ;;  Electron mass (kg)
;mp                = 1.6726231d-27       ;;  Proton mass (kg)
;c                 = 2.99792458d8        ;;  Speed of light in vacuum (m/s)
;c2                = (c[0]*1d-3)^2       ;;  " " squared (km/s)^2
;me_fac            = me[0]*c2[0]/qq[0]   ;;  Electron mass [eV/(km/sec)^2]
;retdat.MASS       = mp[0]/me[0]*me_fac[0]
;;  LBW III  08/05/2013   v1.1.0
retdat.MASS       = mp_esa[0]
;;  Define geometry factor
;    1.62 x 10^(-4) = Geometry factor [cm^2 sr]
;              180. = Pesa Low Field of View (deg)
;             5.625 = Pesa Low angular resolution (deg)
retdat.GEOMFACTOR = 1.62d-4/180d0*5.625d0
;;  If user specifies, then add structure elements (e.g. 'MAGF') to the structure
;      Note:  I would NOT recommend relying upon add_all.pro
IF N_PARAMS() GT 1 THEN add_all,retdat,add
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN,retdat
END



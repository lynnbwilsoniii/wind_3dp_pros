;+
;*****************************************************************************************
;
;  FUNCTION :   get_plb.pro
;  PURPOSE  :   This routine returns a 3D structure containing all data pertinent to a 
;                 single Pesa Low Burst 3D data sample.  See "3D_STRUCTURE" for a more 
;                 complete description of the structure.
;
;  CALLED BY:   
;               NA
;
;  CALLS:
;               wind_com.pro
;               ctime.pro
;               gettime.pro
;               add_all.pro
;               get_plb_extra.pro
;
;  REQUIRES:    
;               1)  External Windlib libraries
;
;  INPUT:
;               T        :  Scalar or 2-Element Unix time telling the program what the
;                             start or start and stop times of interest are
;               ADD      :  Optional input telling program to add some data 
;                             structure tags to to the return structure
;
;  EXAMPLES:    
;               t   = '1995-01-01/00:00:00'
;               td  = time_double(t)
;               plb = get_plb(td)
;
;  KEYWORDS:    
;               TIMES    :  If set, program returns the start times of all the Pesa
;                             Low distributions within the time range loaded
;               INDEX    :  Scalar integer telling program to select data by sample
;                             index instead of times
;               ADVANCE  :  If set, program gets the next distribution
;
;   CHANGED:  1)  Peter changed something                          [04/27/1999   v1.0.17]
;             2)  Fixed up man page, program, and other minor changes 
;                                                                  [02/18/2011   v1.1.0]
;             3)  Now calls get_plb_extra.pro                      [07/25/2011   v1.2.0]
;
;   NOTES:      
;               1)  The procedure "load_3dp_data" must be called prior to use
;
;   CREATED:  ??/??/????
;   CREATED BY:  Peter Schroeder
;    LAST MODIFIED:  07/25/2011   v1.2.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION get_plb,t,add,TIMES=tms,INDEX=idx,ADVANCE=adv

;-----------------------------------------------------------------------------------------
; => Load common blocks
;-----------------------------------------------------------------------------------------
@wind_com.pro

;-----------------------------------------------------------------------------------------
; => Define a dummy structure format
;-----------------------------------------------------------------------------------------
dat = { plb_struct,                                        $
   PROJECT_NAME     :  'Wind 3D Plasma',                   $
   DATA_NAME        :  'Pesa Low Burst',                   $
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
   NBINS            :  64,                                 $
   NENERGY          :  14,                                 $
   DACCODES         :  INTARR(4,14),                       $
   VOLTS            :  FLTARR(4,14),                       $
   DATA             :  FLTARR(14, 64),                     $
   ENERGY           :  FLTARR(14, 64),                     $
   DENERGY          :  FLTARR(14, 64),                     $
   PHI              :  FLTARR(14, 64),                     $
   DPHI             :  FLTARR(14, 64),                     $
   THETA            :  FLTARR(14, 64),                     $
   DTHETA           :  FLTARR(14, 64),                     $
   BINS             :  REPLICATE(1b,14,64),                $
   DT               :  FLTARR(14,64),                      $
   GF               :  FLTARR(14,64),                      $
   BKGRATE          :  FLTARR(14,64),                      $
   DEADTIME         :  FLTARR(14,64),                      $
   DVOLUME          :  FLTARR(14,64),                      $
   DDATA            :  REPLICATE(!VALUES.F_NAN,14,64),     $
   MAGF             :  REPLICATE(!VALUES.F_NAN,3),         $
   SC_POT           :  0.,                                 $
   P_SHIFT          :  0b,                                 $
   T_SHIFT          :  0b,                                 $
   E_SHIFT          :  0b,                                 $
   DOMEGA           :  FLTARR(64)                          $
}
;   ENERGY    :     fltarr(14, 25), $
;   THETA     :     fltarr(14, 25), $
;   PHI       :     fltarr(14, 25), $
;   MAP       :     intarr(5, 5), $
;   GEOM      :     fltarr(25), $
;   DENERGY   :     fltarr(14, 25), $
;   DTHETA    :     fltarr(25), $
;   DPHI      :     fltarr(25), $
;   DOMEGA    :     fltarr(25), $
;   EFF       :     fltarr(14), $
;-----------------------------------------------------------------------------------------
; => Check input and keywords
;-----------------------------------------------------------------------------------------
size = N_TAGS(dat,/LENGTH)
IF (N_ELEMENTS(idx) EQ 0) AND (N_ELEMENTS(t) EQ 0) AND (NOT KEYWORD_SET(adv)) $
  AND (NOT KEYWORD_SET(tms)) THEN ctime,t
IF KEYWORD_SET(adv) THEN a = adv ELSE a = 0
IF (N_ELEMENTS(idx) EQ 0) THEN i = -1 ELSE i = idx
IF (N_ELEMENTS(t)   EQ 0) THEN t = 0.d

options = LONG([size,a,i])
;-----------------------------------------------------------------------------------------
; => Make sure 3DP data has been loaded into IDL
;-----------------------------------------------------------------------------------------
IF (N_ELEMENTS(wind_lib) EQ 0) THEN BEGIN
  MESSAGE,'You must first load the data',/INFORMATIONAL,/CONTINUE
  RETURN,0
ENDIF
;-----------------------------------------------------------------------------------------
; => Get times if requested
;-----------------------------------------------------------------------------------------
IF KEYWORD_SET(tms) THEN BEGIN
  num        = CALL_EXTERNAL(wind_lib,'pl8x8_to_idl')
  options[0] = num
  PRINT, num,' Pesa low burst time samples'
  IF (num GT 0) THEN BEGIN
    times = DBLARR(num)
    ok    = CALL_EXTERNAL(wind_lib,'pl8x8_to_idl',options,times)
    RETURN,times
  ENDIF ELSE RETURN,0d
ENDIF

time = gettime(t)
IF (N_ELEMENTS(time) EQ 1) THEN time = [time,time]
;-----------------------------------------------------------------------------------------
; => Keep dummy structure format
;-----------------------------------------------------------------------------------------
retdat  = dat
q       = 0
oldtime = dat.TIME
integ   = (N_ELEMENTS(t) GE 2)
;-----------------------------------------------------------------------------------------
; => get data structures from Windlib libraries
;-----------------------------------------------------------------------------------------
REPEAT BEGIN
   ok           = CALL_EXTERNAL(wind_lib,'pl8x8_to_idl',options,time,dat)
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
; => [mass] = eV/(km/sec)^2
retdat.MASS       = 1836*5.6856591e-6
; => Define geometry factor
;    1.62 x 10^(-4) = Geometry factor [cm^2 sr]
;              180. = Pesa Low Field of View (deg)
;             5.625 = Pesa Low angular resolution (deg)
retdat.GEOMFACTOR = 1.62e-4/180.*5.625        
; => If user specifies, then add structure elements (e.g. 'MAGF') to the structure
;      Note:  I would NOT recommend relying upon add_all.pro
IF N_PARAMS() GT 1 THEN add_all,retdat,add
; => Fix/Calibrate geometry factor and dead time
@get_plb_extra.pro

RETURN,retdat
END


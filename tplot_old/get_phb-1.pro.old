;+
;*****************************************************************************************
;
;  FUNCTION :   get_phb.pro
;  PURPOSE  :   This routine returns a 3D structure containing all data pertinent to a 
;                 single Pesa High Burst 3D data sample.  See "3D_STRUCTURE" for a more 
;                 complete description of the structure.
;
;  CALLED BY:   
;               NA
;
;  CALLS:
;               wind_com.pro
;               ctime.pro
;               str_to_time.pro
;               gettime.pro
;               get_ph_mapcode.pro
;               add_all.pro
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
;               phb = get_phb(td)
;
;  KEYWORDS:    
;               TIMES    :  If set, program returns the start times of all the Pesa
;                             Low distributions within the time range loaded
;               INDEX    :  Scalar integer telling program to select data by sample
;                             index instead of times
;               ADVANCE  :  If set, program gets the next distribution
;
;   CHANGED:  1)  Peter changed something                          [05/03/1999   v1.0.16]
;             2)  Fixed up man page, program, and other minor changes 
;                                                                  [02/18/2011   v1.1.0]
;
;   NOTES:      
;               1)  The procedure "load_3dp_data" must be called prior to use
;
;   CREATED:  ??/??/????
;   CREATED BY:  Peter Schroeder
;    LAST MODIFIED:  02/18/2011   v1.1.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION get_phb,t,add,ADVANCE=adv,TIMES=tms,INDEX=idx

;-----------------------------------------------------------------------------------------
; => Load common blocks
;-----------------------------------------------------------------------------------------
@wind_com.pro

;-----------------------------------------------------------------------------------------
; => Check if data is loaded
;-----------------------------------------------------------------------------------------
IF (N_ELEMENTS(refdate) EQ 0) THEN BEGIN
  MESSAGE,'You must first load the data',/INFORMATIONAL,/CONTINUE
  RETURN, {DATA_NAME:'null',VALID:0}
ENDIF

;-----------------------------------------------------------------------------------------
; => Set options to pick packet
;-----------------------------------------------------------------------------------------
options = [15,0,0L]              ;options(0)=15->phb, options(0)=index(0)
IF (N_ELEMENTS(idx) EQ 0) AND (N_ELEMENTS(t) EQ 0) AND (NOT KEYWORD_SET(adv)) $
	AND (NOT KEYWORD_SET(tms)) THEN ctime,t
IF (N_ELEMENTS(t) EQ 0) THEN t = str_to_time(refdate) ELSE t = gettime(t)

time    = DBLARR(4)
time[0] = t[0]
IF NOT KEYWORD_SET(adv) THEN adv = 0 
IF (adv NE 0 AND N_ELEMENTS(t) EQ 1) THEN reset_time = 1 ELSE reset_time = 0
IF (N_ELEMENTS(idx) GT 0) THEN options[1] = LONG(idx) ELSE options[1] = -1L
IF (N_ELEMENTS(t) GT 1)   THEN time2      = t[1] - t[0] + time[0] ELSE time2 = t
;-----------------------------------------------------------------------------------------
; => Get times if requested
;-----------------------------------------------------------------------------------------
IF KEYWORD_SET(tms) THEN BEGIN
  num        = 10000
  options[0] = num
  times      = DBLARR(num)
  ok         = CALL_EXTERNAL(wind_lib,'phb15times_to_idl',options,times)
  PRINT,ok + 1,'  Pesa high burst time samples'
  IF (ok LT 0) THEN RETURN,0d ELSE RETURN,times[0:ok]
ENDIF
;-----------------------------------------------------------------------------------------
; => Get mapcode
;-----------------------------------------------------------------------------------------
mapcode = get_phb_mapcode(time,ADVANCE=adv,INDEX=idx,OPTIONS=options,/PRESET)

CASE mapcode OF
  'D4A4'xl: nbins = 121         ;'D4A4'xl  =  0xD4A4
  'D4FE'xl: nbins = 97
  'D5EC'xl: nbins = 56
  'D6BB'xl: nbins = 65
  'D65D'xl: nbins = 88
  ELSE: BEGIN 
    mapstr = STRUPCASE(STRING(mapcode,FORMAT='(z4.4)'))
    MESSAGE,'Unknown phb data map ('+mapstr+') requested or bad packet',/INFORMATIONAL,/CONTINUE
    RETURN,{DATA_NAME:'null',VALID:0}
  END
ENDCASE 

;-----------------------------------------------------------------------------------------
; => Define a dummy structure format
;-----------------------------------------------------------------------------------------
;do not alter this structure without changing ph_dcm.h
dat = { PROJECT_NAME   : 'Wind 3D Plasma',          $
        DATA_NAME      : 'Pesa High Burst',         $
        UNITS_NAME     : 'Counts',                  $
        UNITS_PROCEDURE: 'convert_esa_units',       $
        TIME           : 0.d,                       $
        END_TIME       : 0.d,                       $
        TRANGE         : [0.d,0.d],                 $
        INTEG_T        : 0.d,                       $
        DELTA_T        : 0.d,                       $
        DEADTIME       : FLTARR(15,nbins),          $
        DT             : FLTARR(15,nbins),          $
        VALID          : 0,                         $
        SPIN           : 0L,                        $
        SHIFT          : 0b,                        $
        INDEX          : 0L,                        $
        MAPCODE        : LONG(mapcode),             $
        DOUBLE_SWEEP   : 0b,                        $
        NENERGY        : 15,                        $
        NBINS          : NBINS,                     $
        BINS           : REPLICATE(1b,15,nbins),    $
        PT_MAP         : INTARR(32,24),             $
        DATA           : FLTARR(15,nbins),          $
        ENERGY         : FLTARR(15,nbins),          $
        DENERGY        : FLTARR(15,nbins),          $
        PHI            : FLTARR(15,nbins),          $
        DPHI           : FLTARR(15,nbins),          $
        THETA          : FLTARR(15,nbins),          $
        DTHETA         : FLTARR(15,nbins),          $
        BKGRATE        : FLTARR(15,nbins),          $
        DVOLUME        : FLTARR(15,nbins),          $
        DDATA          : REPLICATE(!VALUES.F_NAN,15,nbins), $
        DOMEGA         : FLTARR(nbins),             $
        DACCODES       : INTARR(30*4),              $
        VOLTS          : FLTARR(30*4),              $
        MASS           : 0.d,                       $
        GEOMFACTOR     : 0.d,                       $
        GF             : FLTARR(15,nbins),          $
        MAGF           : REPLICATE(!VALUES.F_NAN,3),$
        SC_POT         : 0. $
}
;-----------------------------------------------------------------------------------------
; => Check input and keywords
;-----------------------------------------------------------------------------------------
size = N_TAGS(dat,/LENGTH)
IF KEYWORD_SET(adv) THEN a = adv ELSE a = 0
IF (N_ELEMENTS(idx) EQ 0) THEN i = -1 ELSE i = idx

options = LONG([size,a,i])
retdat  = dat
oldtime = time[0]
q       = 0

REPEAT BEGIN
	ok           = CALL_EXTERNAL(wind_lib,'phb15_to_idl',options,time,mapcode,dat)
	dat.END_TIME = dat.TIME + dat.INTEG_T
	IF (retdat.VALID EQ 0) THEN retdat = dat   $
	ELSE IF (dat.TIME GE oldtime AND dat.VALID EQ 1) THEN BEGIN
		retdat.DATA     = dat.DATA +  retdat.DATA
		retdat.DT       = dat.DT   +  retdat.DT
		retdat.DELTA_T  = dat.DELTA_T + retdat.DELTA_T
		retdat.INTEG_T  = dat.INTEG_T + retdat.INTEG_T
		retdat.END_TIME = dat.END_TIME
		oldtime         = dat.TIME
		q               = dat.END_TIME GT time2
	ENDIF ELSE IF (dat.VALID EQ 1) THEN q = 1
	options[2] = dat.INDEX + 1
	IF (time2 EQ time[0]) THEN q = 1
ENDREP UNTIL q
dat = retdat
;if (ok eq 0) or (dat.valid eq 0) then return,dat

dat.TRANGE     = [dat.TIME,dat.END_TIME]
; => [mass] = eV/(km/sec)^2
dat.MASS       = 1836*5.6856591e-6
; => Define geometry factor
;    1.49 x 10^(-2) = Geometry factor [cm^2 sr]
;              360. = Pesa Low Field of View (deg)
;             5.625 = Pesa Low angular resolution (deg)
dat.GEOMFACTOR = 1.49e-2/360.*5.625
dat.DEADTIME   = 0.0
dat.BINS[*,nbins - 1L] = 0
; => If user specifies, then add structure elements (e.g. 'MAGF') to the structure
;      Note:  I would NOT recommend relying upon add_all.pro
IF N_PARAMS() GT 1 THEN add_all,dat,add
IF reset_time THEN t = time[0]
RETURN,dat
END


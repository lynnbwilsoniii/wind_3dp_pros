;+
;*****************************************************************************************
;
;  FUNCTION :   get_el.pro
;  PURPOSE  :   This routine returns a 3D structure containing all velocity distribution
;                 function data pertinent to a single EESA Low 3D data sample.
;                 [See "3D_STRUCTURE" for a more complete description of the structure]
;
;  CALLED BY:   
;               NA
;
;  CALLS:
;               wind_com.pro
;               ctime.pro
;               gettime.pro
;
;  REQUIRES:    
;               1)  External Windlib shared object libraries
;                     [e.g., ~/WIND_PRO/wind3dp_lib_darwin_i386.so]
;
;  INPUT:
;               T        :  Scalar (or [2]-Element array of) [double] Unix time(s)
;                             defining start (and stop) time(s) of interest.  If input
;                             is a [2]-element array, then all the data structures
;                             between T[0] and T[1] will be averaged together into one
;                             IDL structure on output.
;               ADD      :  Scalar [structure, OPTIONAL] defining another distribution
;                             to add to the structure found for T
;                             ** [Obsolete] **
;
;  EXAMPLES:    
;               t  = '1995-01-01/00:00:00'  ;;  Define a timestamp of interest
;               td = time_double(t)         ;;  Convert to Unix
;               el = get_el(td[0])          ;;  Get IDL structure of distribution
;
;  KEYWORDS:    
;               TIMES    :  If set, program returns the start times of all the EESA
;                             Low distributions within the time range loaded during
;                             call to load_3dp_data.pro
;               INDEX    :  Scalar [integer] telling program to select data by sample
;                             index instead of Unix time
;               ADVANCE  :  If set, program gets the next distribution
;
;   CHANGED:  1)  Peter changed something
;                                                                  [05/06/1999   v1.0.29]
;             2)  Fixed up man page, changed ()'s to []'s for indexing, and removed
;                   dependence upon get_el_extra.pro
;                                                                  [08/05/2013   v1.1.0]
;
;   NOTES:      
;               1)  The procedure "load_3dp_data" must be called prior to use
;               2)  Would not recommend the use of ADVANCE and ADD is obsolete
;
;   CREATED:  ??/??/????
;   CREATED BY:  Peter Schroeder
;    LAST MODIFIED:  08/05/2013   v1.1.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION get_el,t,add,TIMES=tms,INDEX=idx,ADVANCE=adv

;;----------------------------------------------------------------------------------------
;;  Define dummy variables
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
;;----------------------------------------------------------------------------------------
;;  Load common blocks
;;----------------------------------------------------------------------------------------
@wind_com.pro
;;----------------------------------------------------------------------------------------
;;  Define a default structure format
;;----------------------------------------------------------------------------------------
dat = { el_struct,                                  $
        PROJECT_NAME     :   'Wind 3D Plasma',      $
        DATA_NAME        :     'Eesa Low',          $
        UNITS_NAME       :     'Counts',            $
        UNITS_PROCEDURE  :'convert_esa_units',      $
        TIME             :     0.d,                 $
        END_TIME         :     0.d,                 $
        TRANGE           :     [0.d,0.d],           $
        INTEG_T          :     0.d,                 $
        DELTA_T          :     0.d,                 $
        MASS             :     0.d,                 $
        GEOMFACTOR       :     0.d,                 $
        INDEX            :     0L,                  $
        N_SAMPLES        :     0L,                  $
        SHIFT            :     0b,                  $
        VALID            :     0,                   $
        SPIN             :     0L,                  $
        NBINS            :     88,                  $
        NENERGY          :     15,                  $
        DACCODES         :     INTARR(8,15),        $
        VOLTS            :     FLTARR(8,15),        $
        DATA             :     FLTARR(15, 88),      $
        ENERGY           :     FLTARR(15, 88),      $
        DENERGY          :     FLTARR(15, 88),      $
        PHI              :     FLTARR(15, 88),      $
        DPHI             :     FLTARR(15, 88),      $
        THETA            :     FLTARR(15, 88),      $
        DTHETA           :     FLTARR(15, 88),      $
        BINS             :     REPLICATE(1b,15,88), $
        DT               :     FLTARR(15,88),       $
        GF               :     FLTARR(15,88),       $
        BKGRATE          :     FLTARR(15,88),       $
        DEADTIME         :     FLTARR(15,88),       $
        DVOLUME          :     FLTARR(15,88),       $
        DDATA            :     REPLICATE(f,15,88),  $
        MAGF             :     REPLICATE(f,3),      $
        VSW              :     REPLICATE(f,3),      $
        DOMEGA           :     FLTARR(88),          $
        SC_POT           :     0.,                  $
        E_SHIFT          :     0.                   $
}
;;----------------------------------------------------------------------------------------
;;  Check input
;;----------------------------------------------------------------------------------------
size           = N_TAGS(dat,/LENGTH)
test           = (N_ELEMENTS(idx) EQ 0) AND (N_ELEMENTS(t) EQ 0) AND $
                 (NOT KEYWORD_SET(adv)) AND (NOT KEYWORD_SET(tms))
IF (test) THEN ctime,t  ;;  use ctime.pro to define time range for data
IF KEYWORD_SET(adv)       THEN a = adv ELSE a = 0
IF (N_ELEMENTS(idx) EQ 0) THEN i = -1  ELSE i = idx
IF (N_ELEMENTS(t)   EQ 0) THEN t = 0.d
options        = LONG([size,a,i])

IF (N_ELEMENTS(wind_lib) EQ 0) THEN BEGIN
  ;;  User did not call load_3dp_data.pro first
  MESSAGE,'You must first load the data',/INFORMATIONAL,/CONTINUE
  RETURN,0
ENDIF
;;----------------------------------------------------------------------------------------
;;  Get start times, if requested
;;----------------------------------------------------------------------------------------
IF KEYWORD_SET(tms) THEN BEGIN
;   num = call_external(wind_lib,'e3d88_to_idl')
  num        = 20000
  options[0] = num
  times      = DBLARR(num)
  ok         = CALL_EXTERNAL(wind_lib,'e3d88_to_idl',options,times)
  PRINT, ok + 1, '  Eesa low time samples'
  IF (ok LT 0) THEN RETURN,0d0 ELSE RETURN,times[0L:ok]
ENDIF
;;----------------------------------------------------------------------------------------
;;  Keep default structure format
;;----------------------------------------------------------------------------------------
time           = gettime(t)
IF (N_ELEMENTS(time) EQ 1) THEN time = [time[0],time[0]]
retdat         = dat
q              = 0
oldtime        = dat.TIME
;;----------------------------------------------------------------------------------------
;;  Get data structures from shared object libraries
;;----------------------------------------------------------------------------------------
REPEAT BEGIN
  ok           = CALL_EXTERNAL(wind_lib,'e3d88_to_idl',options,time,dat)
  dat.END_TIME = dat.TIME + dat.INTEG_T
  IF (retdat.VALID EQ 0) THEN retdat = dat   $
    ELSE IF (dat.TIME GE oldtime AND dat.VALID EQ 1) THEN BEGIN
      retdat.DATA      = dat.DATA     + retdat.DATA
      retdat.DT        = dat.DT       + retdat.DT
      retdat.DELTA_T   = dat.DELTA_T  + retdat.DELTA_T
      retdat.INTEG_T   = dat.INTEG_T  + retdat.INTEG_T
      retdat.END_TIME  = dat.END_TIME
      retdat.N_SAMPLES = dat.N_SAMPLES
      oldtime          = dat.TIME
      q                = (dat.END_TIME GT time[1])
    ENDIF ELSE IF (dat.VALID EQ 1) THEN q = 1
  options[2] = dat.INDEX + 1
  IF (time[1] EQ time[0]) THEN q = 1
ENDREP UNTIL q
;;  Define time range of structure
retdat.TRANGE = [retdat.TIME,retdat.END_TIME]
;@get_el_extra.pro
;;----------------------------------------------------------------------------------------
;;  Modify data structures
;;----------------------------------------------------------------------------------------
;;  Define geometry factor
;;    1.26 x 10^(-2) = Geometry factor [cm^(2) sr]
;;              180. = EESA Low Field of View (deg)
;;             5.625 = EESA Low angular resolution (deg)
retdat.GEOMFACTOR = 1.26e-2/180.*5.625
;;  Define modified geometry factor with consideration of anode efficiencies
anode_el          = BYTE((90-retdat.theta)/22.5)
relgeom_el        = 4 * [0.977,1.019,0.990,1.125,1.154,0.998,0.977,1.005]
retdat.GF         = relgeom_el[anode_el]
;;  Shift energies by 2 eV
retdat.ENERGY     = retdat.ENERGY + 2.
;;  Rotate azimuthal angles by 5.625 deg
retdat.PHI        = retdat.PHI    - 5.625
;;  Define detector deadtime
ncount            = [1,1,2,4,4,2,1,1]
retdat.deadtime   = 6e-7 / ncount[anode_el]
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN,retdat
END

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
;  INCLUDES:
;               NA
;
;  CALLS:
;               wind_com.pro
;               ctime.pro
;               str_to_time.pro
;               gettime.pro
;               get_phb_mapcode.pro
;               add_all.pro
;
;  REQUIRES:    
;               1)  External Windlib shared object libraries
;                     [e.g., ~/WIND_PRO/wind3dp_lib_darwin_i386.so]
;               2)  UMN Modified Wind/3DP IDL Libraries
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
;               [calling sequence]
;               phb = get_phb([t] [,add] [,/TIMES] [,INDEX=idx] [,/ADVANCE])
;
;               ;;  Example
;               t   = '1995-01-01/00:00:00'  ;;  Define a timestamp of interest
;               td  = time_double(t)         ;;  Convert to Unix
;               phb = get_phb(td[0])          ;;  Get IDL structure of distribution
;
;  KEYWORDS:    
;               TIMES    :  If set, program returns the start times of all the PESA
;                             High burst distributions within the time range loaded
;                             during call to load_3dp_data.pro
;               INDEX    :  Scalar [integer] telling program to select data by sample
;                             index instead of Unix time
;               ADVANCE  :  If set, program gets the next distribution relative to the
;                             previously retrieved distribution
;
;   CHANGED:  1)  Peter changed something
;                                                                   [05/03/1999   v1.0.16]
;             2)  Fixed up man page, program, and other minor changes
;                                                                   [02/18/2011   v1.1.0]
;             3)  Updated Man. page and rewrote routine
;                                                                   [05/14/2021   v1.1.1]
;
;   NOTES:      
;               1)  The procedure "load_3dp_data" must be called prior to use
;               2)  Would not recommend the use of ADVANCE and ADD is obsolete
;               3)  Safest to call get_3dp_structs.pro
;
;  REFERENCES:  
;               0)  Lin et al., "A Three-Dimensional Plasma and Energetic particle
;                      investigation for the Wind spacecraft," Space Sci. Rev.
;                      71, pp. 125--153, 1995.
;               1)  Meeks, C., and P.B. Siegel "Dead time correction via the time
;                      series," Amer. J. Phys. 76, pp. 589--590, doi:10.1119/1.2870432,
;                      2008.
;               2)  M. Wüest, D.S. Evans, and R. von Steiger "Calibration of Particle
;                      Instruments in Space Physics," ESA Publications Division,
;                      Keplerlaan 1, 2200 AG Noordwijk, The Netherlands, 2007.
;               3)  M. Wüest, et al., "Review of Instruments," ISSI Sci. Rep. Ser.
;                      Vol. 7, pp. 11--116, 2007.
;
;   CREATED:  ??/??/????
;   CREATED BY:  Peter Schroeder
;    LAST MODIFIED:  05/14/2021   v1.1.1
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION get_phb,t,add,ADVANCE=adv,TIMES=tms,INDEX=idx

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
;;  Check if data is loaded
;;----------------------------------------------------------------------------------------
IF (N_ELEMENTS(refdate) EQ 0) THEN BEGIN
  MESSAGE,'You must first load the data',/INFORMATIONAL,/CONTINUE
  RETURN, {DATA_NAME:'null',VALID:0}
ENDIF
;;----------------------------------------------------------------------------------------
;;  Set options to pick packet
;;----------------------------------------------------------------------------------------
options        = [15,0,0L]              ;;  options(0)=15->phb, options(0)=index(0)
IF (N_ELEMENTS(idx) EQ 0) AND (N_ELEMENTS(t) EQ 0) AND (NOT KEYWORD_SET(adv)) $
	AND (NOT KEYWORD_SET(tms)) THEN ctime,t
IF (N_ELEMENTS(t) EQ 0) THEN t = str_to_time(refdate) ELSE t = gettime(t)

time           = DBLARR(4)
time[0]        = t[0]
IF NOT KEYWORD_SET(adv)              THEN adv = 0 
IF (adv NE 0 AND N_ELEMENTS(t) EQ 1) THEN reset_time = 1 ELSE reset_time = 0
IF (N_ELEMENTS(idx) GT 0)            THEN options[1] = LONG(idx) ELSE options[1] = -1L
IF (N_ELEMENTS(t) GT 1)              THEN time2      = t[1] - t[0] + time[0] ELSE time2 = t
;;----------------------------------------------------------------------------------------
;;  Get start times, if requested
;;----------------------------------------------------------------------------------------
IF KEYWORD_SET(tms) THEN BEGIN
  num            = 10000
  options[0]     = num[0]
  times          = DBLARR(num)
  ok             = CALL_EXTERNAL(wind_lib,'phb15times_to_idl',options,times)
  IF (SIZE(ok,/TYPE) EQ 0) THEN RETURN,0d0
  PRINT, ok[0] + 1, '  Pesa high burst time samples'
  IF (ok[0] LT 0) THEN RETURN,0d0 ELSE RETURN,times[0L:ok[0]]
ENDIF
;;----------------------------------------------------------------------------------------
;;  Get PESA High Burst mapcode
;;----------------------------------------------------------------------------------------
mapcode        = get_phb_mapcode(time,ADVANCE=adv,INDEX=idx,OPTIONS=options,/PRESET)
;;  Define number of corresponding angle bins
CASE mapcode[0] OF
  'D4A4'xl : nbins = 121         ;'D4A4'xl  =  0xD4A4
  'D4FE'xl : nbins = 97
  'D5EC'xl : nbins = 56
  'D6BB'xl : nbins = 65
  'D65D'xl : nbins = 88
  ELSE: BEGIN 
    mapstr         = STRUPCASE(STRING(mapcode[0],FORMAT='(z4.4)'))
    MESSAGE,'Unknown phb data map ('+mapstr[0]+') requested or bad packet',/INFORMATIONAL,/CONTINUE
    RETURN,{DATA_NAME:'null',VALID:0}
  END
ENDCASE
;;----------------------------------------------------------------------------------------
;;  Define a default structure format
;;----------------------------------------------------------------------------------------
dat = { PROJECT_NAME     :   'Wind 3D Plasma',      $
        DATA_NAME        : 'Pesa High Burst',       $
        UNITS_NAME       :     'Counts',            $
        UNITS_PROCEDURE  : 'convert_esa_units',     $
        TIME             :     0d0,                 $           ;;  Start time [Unix* {well SC clocks are UTC so it's not really Unix}]
        END_TIME         :     0d0,                 $           ;;  End Time [Unix*]
        TRANGE           :     [0d0,0d0],           $           ;;  [TIME,END_TIME]
        INTEG_T          :     0d0,                 $           ;;  Scalar integration time [s] = END_TIME - TIME
        DELTA_T          :     0d0,                 $           ;;  Often the same as INTEG_T
        DEADTIME         : FLTARR(15,nbins),        $           ;;  Array of background values [UNITS_NAME] --> User is expected to determine these
        DT               : FLTARR(15,nbins),        $           ;;  " " anode accumulation times [s] for any given energy-angle bin
        VALID            :     0,                   $           ;;  Scalar defining whether the VDF is good [TRUE] or bad [FALSE]
        SPIN             :     0L,                  $           ;;  " " defining the spacecraft spin number
        SHIFT            :     0b,                  $           ;;  " " defining the byte shift of some parameter [not really known where/when this matters after data out of *.so software]
        INDEX            :     0L,                  $           ;;  " " long integer tag associated with a structure indexing number
        MAPCODE          : LONG(mapcode[0]),        $           ;;  " " defining the mapcode index used for this distribution
        DOUBLE_SWEEP     : 0b,                      $           ;;  " " defining whether the instrument is in a double-sweep mode (i.e., is it sweeping through energies twice per look direction)
        NENERGY          :     15,                  $           ;;  " " integer defining the number of energy bins
        NBINS            : nbins,                   $           ;;  " " integer defining the number of solid-angle bins
        BINS             : REPLICATE(1b,15,nbins),  $           ;;  Array of byte values indicating whether to use or ignore any given energy-angle bin (used by other routines)
        PT_MAP           : INTARR(32,24),           $           ;;  " " defining the mapping to solid-angle in different modes (I think this is correct???)
        DATA             : FLTARR(15,nbins),        $           ;;  " " data values [UNITS_NAME]
        ENERGY           : FLTARR(15,nbins),        $           ;;  " " energy bin mid-point values [eV] = (E_upp + E_low)/2
        DENERGY          : FLTARR(15,nbins),        $           ;;  " " energy bin widths/sizes [eV] = (E_upp - E_low)
        PHI              : FLTARR(15,nbins),        $           ;;  " " azimuthal mid-point GSE angles [deg] for each data point = (phi_upp + phi_low)/2
        DPHI             : FLTARR(15,nbins),        $           ;;  " " azimuthal bin widths/sizes [deg] = (phi_upp - phi_low)
        THETA            : FLTARR(15,nbins),        $           ;;  " " poloidal mid-point GSE angles [deg] from -90 to +90 degrees = (theta_upp + theta_low)/2
        DTHETA           : FLTARR(15,nbins),        $           ;;  " " poloidal bin widths/sizes [deg] = (theta_upp - theta_low)
        BKGRATE          : FLTARR(15,nbins),        $           ;;  " " background values [UNITS_NAME] --> User is expected to determine these
        DVOLUME          : FLTARR(15,nbins),        $           ;;  " " defining the differential volume for each energy-angle bin [sr]
        DDATA            : REPLICATE(f,15,nbins),   $           ;;  " " uncertainties for each data point [UNITS_NAME] --> User is expected to determine these
        DOMEGA           : FLTARR(nbins),           $           ;;  " " solid-angles [sr] spanned by each solid-angle bin
        DACCODES         : INTARR(30*4),            $           ;;  " " information regarding the digital-to-analog converter (DAC)
        VOLTS            : FLTARR(30*4),            $           ;;  " " voltages for DAC [volts]
        MASS             :     0d0,                 $           ;;  Scalar particle mass [eV/c^2 with c in units of km/s]
        GEOMFACTOR       :     0d0,                 $           ;;  " " total geometric factor determined from physical geometry of detector
        GF               : FLTARR(15,nbins),        $           ;;  Array of relative geometric factors per energy-angle bin used in unit conversion routines to correct GEOMFACTOR
        MAGF             :     REPLICATE(f,3),      $           ;;  [3]-Element array defining the magnetic field 3-vector [nT] in GSE for the time of this VDF
        SC_POT           :     0.                   $           ;;  Scalar defining the spacecraft electric potential [eV] for the time of this VDF
}
;;----------------------------------------------------------------------------------------
;;  Check input
;;----------------------------------------------------------------------------------------
nt             = N_TAGS(dat,/LENGTH)
IF KEYWORD_SET(adv)       THEN a = adv ELSE a = 0
IF (N_ELEMENTS(idx) EQ 0) THEN i = -1  ELSE i = idx
options        = LONG([nt[0],a[0],i[0]])
retdat         = dat[0]
q              = 0
oldtime        = time[0]
;;----------------------------------------------------------------------------------------
;;  Get data structures from shared object libraries
;;----------------------------------------------------------------------------------------
REPEAT BEGIN
  ok           = CALL_EXTERNAL(wind_lib,'phb15_to_idl',options,time,mapcode,dat)
  dat.END_TIME = dat[0].TIME + dat[0].INTEG_T
  IF (retdat.VALID EQ 0) THEN retdat = dat   $
  ELSE IF (dat[0].TIME GE oldtime[0] AND dat[0].VALID EQ 1) THEN BEGIN
    retdat.DATA     = dat[0].DATA    +  retdat[0].DATA
    retdat.DT       = dat[0].DT      +  retdat[0].DT
    retdat.DELTA_T  = dat[0].DELTA_T + retdat[0].DELTA_T
    retdat.INTEG_T  = dat[0].INTEG_T + retdat[0].INTEG_T
    retdat.END_TIME = dat[0].END_TIME
    oldtime         = dat[0].TIME
    q               = (dat[0].END_TIME GT time2[0])
  ENDIF ELSE IF (dat[0].VALID EQ 1) THEN q = 1
  options[2]   = dat[0].INDEX + 1
  IF (time2[0] EQ time[0]) THEN q = 1
ENDREP UNTIL q
dat            = retdat[0]
;;  Define time range of structure
dat.TRANGE     = [retdat[0].TIME,retdat[0].END_TIME]
;;----------------------------------------------------------------------------------------
;;  Modify data structures
;;----------------------------------------------------------------------------------------
;;  Define mass [eV/c^2 with c in units of km/s]
dat.MASS       = 0.010439684840519178e0
;;  Define geometry factor
;;    1.49 x 10^(-2) = Geometry factor [cm^2 sr]
;;              360. = Pesa Low Field of View (deg)
;;             5.625 = Pesa Low angular resolution (deg)
dat.GEOMFACTOR = 1.49e-2/360.*5.625
;;  Define detector deadtime  [+LBW 05/14/2021   v1.1.1]
dat.DEADTIME   = 0e0       ;;  the routine convert_ph_units.pro will handle this "properly"
dat.BINS[*,nbins - 1L] = 0
;;  If user specifies, then add structure elements (e.g. 'MAGF') to the structure
;;    Note:  I would NOT recommend relying upon add_all.pro
IF N_PARAMS() GT 1 THEN add_all,dat,add
IF reset_time THEN t = time[0]
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN,dat
END


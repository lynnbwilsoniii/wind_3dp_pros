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
;  INCLUDES:
;               NA
;
;  CALLS:
;               wind_com.pro
;               ctime.pro
;               gettime.pro
;               add_all.pro
;               pl_mcp_eff.pro
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
;               plb = get_plb([t] [,add] [,/TIMES] [,INDEX=idx] [,/ADVANCE])
;
;               ;;  Example
;               t   = '1995-01-01/00:00:00'  ;;  Define a timestamp of interest
;               td  = time_double(t)         ;;  Convert to Unix
;               plb = get_plb(td[0])         ;;  Get IDL structure of distribution
;
;  KEYWORDS:    
;               TIMES    :  If set, program returns the start times of all the PESA
;                             Low Burst distributions within the time range loaded
;                             during call to load_3dp_data.pro
;               INDEX    :  Scalar [integer] telling program to select data by sample
;                             index instead of Unix time
;               ADVANCE  :  If set, program gets the next distribution relative to the
;                             previously retrieved distribution
;
;   CHANGED:  1)  Peter changed something
;                                                                   [04/27/1999   v1.0.17]
;             2)  Fixed up man page, program, and other minor changes
;                                                                   [02/18/2011   v1.1.0]
;             3)  Now calls get_plb_extra.pro
;                                                                   [07/25/2011   v1.2.0]
;             3)  Updated Man. page and rewrote routine
;                                                                   [05/14/2021   v1.2.1]
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
;    LAST MODIFIED:  05/14/2021   v1.2.1
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION get_plb,t,add,TIMES=tms,INDEX=idx,ADVANCE=adv

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
dat = { plb_struct,                                 $
        PROJECT_NAME     :  'Wind 3D Plasma',       $
        DATA_NAME        :  'Pesa Low Burst',       $
        UNITS_NAME       :  'Counts',               $
        UNITS_PROCEDURE  :  'convert_esa_units',    $
        TIME             :     0d0,                 $           ;;  Start time [Unix* {well SC clocks are UTC so it's not really Unix}]
        END_TIME         :     0d0,                 $           ;;  End Time [Unix*]
        TRANGE           :     [0d0,0d0],           $           ;;  [TIME,END_TIME]
        INTEG_T          :     0d0,                 $           ;;  Scalar integration time [s] = END_TIME - TIME
        DELTA_T          :     0d0,                 $           ;;  Often the same as INTEG_T
        MASS             :     0d0,                 $           ;;  Scalar particle mass [eV/c^2 with c in units of km/s]
        GEOMFACTOR       :     0d0,                 $           ;;  " " total geometric factor determined from physical geometry of detector
        INDEX            :     0L,                  $           ;;  " " long integer tag associated with a structure indexing number
        VALID            :     0,                   $           ;;  " " defining whether the VDF is good [TRUE] or bad [FALSE]
        SPIN             :     0L,                  $           ;;  " " defining the spacecraft spin number
        NBINS            :     64,                  $           ;;  " " integer defining the number of solid-angle bins
        NENERGY          :     14,                  $           ;;  " " integer defining the number of energy bins
        DACCODES         :     INTARR(4,14),        $           ;;  Array of information regarding the digital-to-analog converter (DAC)
        VOLTS            :     FLTARR(4,14),        $           ;;  " " voltages for DAC [volts]
        DATA             :     FLTARR(14,64),       $           ;;  " " data values [UNITS_NAME]
        ENERGY           :     FLTARR(14,64),       $           ;;  " " energy bin mid-point values [eV] = (E_upp + E_low)/2
        DENERGY          :     FLTARR(14,64),       $           ;;  " " energy bin widths/sizes [eV] = (E_upp - E_low)
        PHI              :     FLTARR(14,64),       $           ;;  " " azimuthal mid-point GSE angles [deg] for each data point = (phi_upp + phi_low)/2
        DPHI             :     FLTARR(14,64),       $           ;;  " " azimuthal bin widths/sizes [deg] = (phi_upp - phi_low)
        THETA            :     FLTARR(14,64),       $           ;;  " " poloidal mid-point GSE angles [deg] from -90 to +90 degrees = (theta_upp + theta_low)/2
        DTHETA           :     FLTARR(14,64),       $           ;;  " " poloidal bin widths/sizes [deg] = (theta_upp - theta_low)
        BINS             :     REPLICATE(1b,14,64), $           ;;  " " byte values indicating whether to use or ignore any given energy-angle bin (used by other routines)
        DT               :     FLTARR(14,64),       $           ;;  " " anode accumulation times [s] for any given energy-angle bin
        GF               :     FLTARR(14,64),       $           ;;  " " relative geometric factors per energy-angle bin used in unit conversion routines to correct GEOMFACTOR
        BKGRATE          :     FLTARR(14,64),       $           ;;  " " background values [UNITS_NAME] --> User is expected to determine these
        DEADTIME         :     FLTARR(14,64),       $           ;;  " " deadtimes [s], i.e., times when instrument not taking or unable to take data [e.g., Meeks and Siegel, 2008]
        DVOLUME          :     FLTARR(14,64),       $           ;;  " " defining the differential volume for each energy-angle bin [sr]
        DDATA            :     REPLICATE(f,14,64),  $           ;;  " " uncertainties for each data point [UNITS_NAME] --> User is expected to determine these
        MAGF             :     REPLICATE(f,3),      $           ;;  [3]-Element array defining the magnetic field 3-vector [nT] in GSE for the time of this VDF
        SC_POT           :     0.,                  $           ;;  Scalar defining the spacecraft electric potential [eV] for the time of this VDF
        P_SHIFT          :     0b,                  $           ;;  Scalar defining a shift parameter for ???
        T_SHIFT          :     0b,                  $           ;;  Scalar defining a shift parameter for ???
        E_SHIFT          :     0b,                  $           ;;  Scalar defining an energy shift value [eV] for the energy bins
        DOMEGA           :     FLTARR(64)           $           ;;  Array of solid-angles [sr] spanned by each solid-angle bin
}
;;----------------------------------------------------------------------------------------
;;  Check input
;;----------------------------------------------------------------------------------------
nt             = N_TAGS(dat,/LENGTH)
test           = (N_ELEMENTS(idx) EQ 0) AND (N_ELEMENTS(t) EQ 0) AND $
                 (NOT KEYWORD_SET(adv)) AND (NOT KEYWORD_SET(tms))
IF (test[0]) THEN ctime,t  ;;  use ctime.pro to define time range for data
IF KEYWORD_SET(adv)       THEN a = adv ELSE a = 0
IF (N_ELEMENTS(idx) EQ 0) THEN i = -1  ELSE i = idx
IF (N_ELEMENTS(t)   EQ 0) THEN t = 0d0
options        = LONG([nt[0],a[0],i[0]])

IF (N_ELEMENTS(wind_lib) EQ 0) THEN BEGIN
  ;;  User did not call load_3dp_data.pro first
  MESSAGE,'You must first load the data',/INFORMATIONAL,/CONTINUE
  RETURN,0
ENDIF
;;----------------------------------------------------------------------------------------
;;  Get start times, if requested
;;----------------------------------------------------------------------------------------
IF KEYWORD_SET(tms) THEN BEGIN
  num            = CALL_EXTERNAL(wind_lib,'pl8x8_to_idl')
  PRINT, num[0], '  Pesa low burst time samples'
  options[0]     = num[0]
  IF (num[0] LE 0) THEN RETURN,0d0
  times          = DBLARR(num)
  ok             = CALL_EXTERNAL(wind_lib,'pl8x8_to_idl',options,times)
  RETURN,times
;  IF (SIZE(ok,/TYPE) EQ 0) THEN RETURN,0d0
;  IF (ok[0] LT 0) THEN RETURN,0d0 ELSE RETURN,times[0L:ok[0]]
ENDIF
;;----------------------------------------------------------------------------------------
;;  Keep default structure format
;;----------------------------------------------------------------------------------------
time           = gettime(t)
IF (N_ELEMENTS(time) EQ 1) THEN time = [time[0],time[0]]
retdat         = dat[0]
q              = 0
oldtime        = dat[0].TIME
integ          = (N_ELEMENTS(t) GE 2)
;;----------------------------------------------------------------------------------------
;;  Get data structures from shared object libraries
;;----------------------------------------------------------------------------------------
REPEAT BEGIN
   ok           = CALL_EXTERNAL(wind_lib,'pl8x8_to_idl',options,time,dat)
   dat.END_TIME = dat[0].TIME + dat[0].INTEG_T
   IF (retdat.VALID EQ 0) THEN retdat = dat   $
   ELSE IF (dat[0].TIME GE oldtime[0] AND dat[0].VALID EQ 1) THEN BEGIN
           retdat.DATA     =  dat[0].DATA    + retdat[0].DATA
           retdat.DT       =  dat[0].DT      + retdat[0].DT
           retdat.DELTA_T  =  dat[0].DELTA_T + retdat[0].DELTA_T
           retdat.INTEG_T  =  dat[0].INTEG_T + retdat[0].INTEG_T
           retdat.END_TIME =  dat[0].END_TIME
           oldtime         =  dat[0].TIME
           q               = (dat[0].END_TIME GT time[1])
   ENDIF ELSE IF (dat[0].VALID EQ 1) THEN q = 1
   options[2] = dat[0].INDEX + 1
   IF (time[1] EQ time[0]) THEN q = 1
ENDREP UNTIL q
;;  Define time range of structure
retdat.TRANGE  = [retdat[0].TIME,retdat[0].END_TIME]
;;----------------------------------------------------------------------------------------
;;  Modify data structures
;;----------------------------------------------------------------------------------------
;;  Define mass [eV/c^2 with c in units of km/s]
retdat.MASS       = 0.010439684840519178d0
;;  Define geometry factor
;;  1.62 x 10^(-4) = Geometry factor [cm^2 sr]
;;            180. = Pesa Low Field of View (deg)
;;           5.625 = Pesa Low angular resolution (deg)
retdat.GEOMFACTOR = 1.62e-4/180.*5.625
;;  If user specifies, then add structure elements (e.g. 'MAGF') to the structure
;;    Note:  I would NOT recommend relying upon add_all.pro
IF N_PARAMS() GT 1 THEN add_all,retdat,add
;;  Fix/Calibrate geometry factor and dead time
pl_mcp_eff,retdat[0].TIME,DEADT=dt,MCPEFF=mcpeff,/BURST
retdat.DEADTIME    = dt
retdat.GEOMFACTOR *= mcpeff
;@get_plb_extra.pro
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN,retdat
END


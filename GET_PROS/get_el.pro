;+
;*****************************************************************************************
;
;  FUNCTION :   get_el.pro
;  PURPOSE  :   This routine returns a 3D structure containing all velocity distribution
;                 function (VDF) data pertinent to a single EESA Low 3D data sample or
;                 the user can sum counts over multiple VDFs or return an array of
;                 VDF start times.
;                 [See "3D_STRUCTURE" for a more complete description of the structure]
;
;  CALLED BY:   
;               NA
;
;  INCLUDES:
;               NA
;
;  COMMON:
;               wind_com.pro
;
;  CALLS:
;               ctime.pro
;               gettime.pro
;
;  REQUIRES:    
;               1)  External Windlib shared object libraries
;                     [e.g., ~/WIND_PRO/wind3dp_lib_darwin_x86_64.so]
;               2)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               T        :  Scalar (or [2]-Element array of) [double] Unix time(s)
;                             defining start (and stop) time(s) of interest.  If input
;                             is a [2]-element array, then all the data structures
;                             between T[0] and T[1] will be summed together into one
;                             IDL structure on output.  The summing is performed in units
;                             of counts and the DT and INTEG_T values change accordingly.
;               ADD      :  Scalar [structure, OPTIONAL] defining another distribution
;                             to add to the structure found for T
;                             ** [Obsolete] **
;
;  EXAMPLES:    
;               [calling sequence]
;               el = get_el([t] [,add] [,/TIMES] [,INDEX=idx] [,/ADVANCE])
;
;               ;;  Example
;               t  = '1995-01-01/00:00:00'  ;;  Define a timestamp of interest
;               td = time_double(t)         ;;  Convert to Unix
;               el = get_el(td[0])          ;;  Get IDL structure of distribution
;
;  KEYWORDS:    
;               TIMES    :  If set, program returns the start times of all the EESA
;                             High distributions within the time range loaded during
;                             call to load_3dp_data.pro
;                             [Default = FALSE]
;               INDEX    :  Scalar [integer] telling program to select data by sample
;                             index instead of Unix time
;               ADVANCE  :  If set, program gets the next distribution relative to the
;                             previously retrieved distribution
;                             [Default = FALSE]
;
;   CHANGED:  1)  Peter changed something
;                                                                   [05/06/1999   v1.0.29]
;             2)  Fixed up man page, changed ()'s to []'s for indexing, and removed
;                   dependence upon get_el_extra.pro
;                                                                   [08/05/2013   v1.1.0]
;             3)  Updated Man. page and cleaned up routine a little
;                                                                   [05/14/2021   v1.1.1]
;             4)  Changed how routine handles large time ranges for determining the
;                   number of VDFs
;                                                                   [02/28/2024   v1.1.2]
;             5)  Fixed a bug if e3d88_to_idl.c returned an empty array
;                                                                   [03/01/2024   v1.1.3]
;
;   NOTES:      
;               1)  The procedure "load_3dp_data" must be called prior to use
;               2)  Would not recommend the use of ADVANCE and ADD is obsolete
;               3)  Safest to call wrapping routine, get_3dp_structs.pro
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
;               4)  Wilson III, L.B., et al., "A Quarter Century of Wind Spacecraft
;                      Discoveries," Rev. Geophys. 59(2), pp. e2020RG000714,
;                      doi:10.1029/2020RG000714, 2021.
;
;   CREATED:  ??/??/????
;   CREATED BY:  Peter Schroeder
;    LAST MODIFIED:  03/01/2024   v1.1.3
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
;;  IDL system and OS stuff
;;----------------------------------------------------------------------------------------
vers           = !VERSION.OS_FAMILY   ;;  e.g., 'unix'
vern           = !VERSION.RELEASE     ;;  e.g., '7.1.1'
verm           = !VERSION.MEMORY_BITS ;;  e.g., 64 for a 64-bit machine
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
        TIME             :     0d0,                 $           ;;  Start time [Unix* {well SC clocks are UTC so it's not really Unix}]
        END_TIME         :     0d0,                 $           ;;  End Time [Unix*]
        TRANGE           :     [0d0,0d0],           $           ;;  [TIME,END_TIME]
        INTEG_T          :     0d0,                 $           ;;  Scalar integration time [s] = END_TIME - TIME
        DELTA_T          :     0d0,                 $           ;;  Often the same as INTEG_T
        MASS             :     0d0,                 $           ;;  Scalar particle mass [eV/c^2 with c in units of km/s]
        GEOMFACTOR       :     0d0,                 $           ;;  " " total geometric factor determined from physical geometry of detector
        INDEX            :     0L,                  $           ;;  " " long integer tag associated with a structure indexing number
        N_SAMPLES        :     0L,                  $           ;;  " " defining the number of VDFs summed together
        SHIFT            :     0b,                  $           ;;  " " defining the byte shift of some parameter [not really known where/when this matters after data out of *.so software]
        VALID            :     0,                   $           ;;  " " defining whether the VDF is good [TRUE] or bad [FALSE]
        SPIN             :     0L,                  $           ;;  " " defining the spacecraft spin number
        NBINS            :     88,                  $           ;;  " " integer defining the number of solid-angle bins
        NENERGY          :     15,                  $           ;;  " " integer defining the number of energy bins
        DACCODES         :     INTARR(8,15),        $           ;;  Array of information regarding the digital-to-analog converter (DAC)
        VOLTS            :     FLTARR(8,15),        $           ;;  " " voltages for DAC [volts]
        DATA             :     FLTARR(15, 88),      $           ;;  " " data values [UNITS_NAME]
        ENERGY           :     FLTARR(15, 88),      $           ;;  " " energy bin mid-point values [eV] = (E_upp + E_low)/2
        DENERGY          :     FLTARR(15, 88),      $           ;;  " " energy bin widths/sizes [eV] = (E_upp - E_low)
        PHI              :     FLTARR(15, 88),      $           ;;  " " azimuthal mid-point GSE angles [deg] for each data point = (phi_upp + phi_low)/2
        DPHI             :     FLTARR(15, 88),      $           ;;  " " azimuthal bin widths/sizes [deg] = (phi_upp - phi_low)
        THETA            :     FLTARR(15, 88),      $           ;;  " " poloidal mid-point GSE angles [deg] from -90 to +90 degrees = (theta_upp + theta_low)/2
        DTHETA           :     FLTARR(15, 88),      $           ;;  " " poloidal bin widths/sizes [deg] = (theta_upp - theta_low)
        BINS             :     REPLICATE(1b,15,88), $           ;;  " " byte values indicating whether to use or ignore any given energy-angle bin (used by other routines)
        DT               :     FLTARR(15,88),       $           ;;  " " anode accumulation times [s] for any given energy-angle bin
        GF               :     FLTARR(15,88),       $           ;;  " " relative geometric factors per energy-angle bin used in unit conversion routines to correct GEOMFACTOR
        BKGRATE          :     FLTARR(15,88),       $           ;;  " " background values [UNITS_NAME] --> User is expected to determine these
        DEADTIME         :     FLTARR(15,88),       $           ;;  " " deadtimes [s], i.e., times when instrument not taking or unable to take data [e.g., Meeks and Siegel, 2008]
        DVOLUME          :     FLTARR(15,88),       $           ;;  " " defining the differential volume for each energy-angle bin [sr]
        DDATA            :     REPLICATE(f,15,88),  $           ;;  " " uncertainties for each data point [UNITS_NAME] --> User is expected to determine these
        MAGF             :     REPLICATE(f,3),      $           ;;  [3]-Element array defining the magnetic field 3-vector [nT] in GSE for the time of this VDF
        VSW              :     REPLICATE(f,3),      $           ;;  [3]-Element array defining the bulk flow velocity [km/s] in GSE (used for frame transformations) for the time of this VDF
        DOMEGA           :     FLTARR(88),          $           ;;  Array of solid-angles [sr] spanned by each solid-angle bin
        SC_POT           :     0.,                  $           ;;  Scalar defining the spacecraft electric potential [eV] for the time of this VDF
        E_SHIFT          :     0.                   $           ;;  Scalar defining an energy shift value [eV] for the energy bins
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
  MESSAGE,'You must first load 3DP data by calling load_3dp_data.pro',/INFORMATIONAL,/CONTINUE
  RETURN,0
ENDIF
;;----------------------------------------------------------------------------------------
;;  Get start times, if requested
;;----------------------------------------------------------------------------------------
IF KEYWORD_SET(tms) THEN BEGIN
  ;;  If system is 64-bit, then allow more EH VDFs
  IF (verm[0] GE 64) THEN num = CALL_EXTERNAL(wind_lib,'e3d88_to_idl') > 1L ELSE num = 20000L
  options[0]     = num[0]
  times          = DBLARR(num)
  ok             = CALL_EXTERNAL(wind_lib,'e3d88_to_idl',options,times)
  IF (SIZE(ok,/TYPE) EQ 0) THEN RETURN,0d0
  MESSAGE,STRTRIM(STRING(ok[0] + 1L,FORMAT='(I)'),2L)+'  Eesa low time samples',/CONTINUE,/INFORMATIONAL
  IF (ok[0] LT 0) THEN RETURN,0d0 ELSE RETURN,times[0L:ok[0]]
ENDIF
;;----------------------------------------------------------------------------------------
;;  Keep default structure format
;;----------------------------------------------------------------------------------------
time           = gettime(t)
IF (N_ELEMENTS(time) EQ 1) THEN time = [time[0],time[0]]
retdat         = dat[0]
q              = 0
oldtime        = dat[0].TIME
;;----------------------------------------------------------------------------------------
;;  Get data structures from shared object libraries
;;----------------------------------------------------------------------------------------
REPEAT BEGIN
  ok             = CALL_EXTERNAL(wind_lib,'e3d88_to_idl',options,time,dat)
  dat.END_TIME   = dat[0].TIME + dat[0].INTEG_T
  IF (retdat[0].VALID EQ 0) THEN BEGIN
    retdat         = dat[0]
  ENDIF ELSE BEGIN
    IF (dat[0].TIME GE oldtime[0] AND dat[0].VALID EQ 1) THEN BEGIN
      retdat.DATA      = dat[0].DATA     + retdat[0].DATA
      retdat.DT        = dat[0].DT       + retdat[0].DT
      retdat.DELTA_T   = dat[0].DELTA_T  + retdat[0].DELTA_T
      retdat.INTEG_T   = dat[0].INTEG_T  + retdat[0].INTEG_T
      retdat.END_TIME  = dat[0].END_TIME
      retdat.N_SAMPLES = dat[0].N_SAMPLES
      oldtime          = dat[0].TIME
      q                = (dat[0].END_TIME GT time[1])
    ENDIF ELSE IF (dat[0].VALID EQ 1) THEN q = 1
  ENDELSE
  options[2]     = dat[0].INDEX + 1
  IF (time[1] EQ time[0]) THEN q = 1
ENDREP UNTIL q
;;  Define time range of structure
retdat.TRANGE  = [retdat[0].TIME,retdat[0].END_TIME]
;;----------------------------------------------------------------------------------------
;;  Modify data structures
;;----------------------------------------------------------------------------------------
;;  Define geometry factor
;;    1.26 x 10^(-2) = Geometry factor [cm^(2) sr]
;;              180. = EESA Low Field of View (deg)
;;             5.625 = EESA Low angular resolution (deg)
retdat.GEOMFACTOR = 1.26e-2/180.*5.625
;;  Define modified geometry factor with consideration of anode efficiencies
anode_el          = BYTE((90 - retdat[0].THETA)/22.5)
relgeom_el        = 4 * [0.977,1.019,0.990,1.125,1.154,0.998,0.977,1.005]
retdat.GF         = relgeom_el[anode_el]
;;  Shift energies by 2 eV  [No explanation for this, just in original code]
retdat.ENERGY    += 2e0
;;  Rotate azimuthal angles by 5.625 deg  [No explanation for this, just in original code]
retdat.PHI       -= 5.625e0
;;  Define detector deadtime  [No explanation for this, just in original code]
ncount            = [1,1,2,4,4,2,1,1]
retdat.DEADTIME   = 6e-7 / ncount[anode_el]
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN,retdat
END






;+
;*****************************************************************************************
;
;  FUNCTION :   whistler_params_calc_1d.pro
;  PURPOSE  :   Calculates the cold plasma resonance energy estimate given a 
;                 magnetic field strength, plasma density, wave frequency, 
;                 and propagation angle.
;
;  CALLED BY:   
;               cold_plasma_whistler_params_1d.pro
;
;  CALLS:
;               NA
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               MAGF         :  N-Element array of magnetic field magnitudes (nT)
;               DENS         :  " " plasma density [cm^(-3)]
;               FREQF        :  N-Element array of wave frequencies (Hz)
;               ANGLE        :  " " wave propagation angle with respect to the magnetic
;                                 field (degrees)
;
;  EXAMPLES:    
;               test = whistler_params_calc(magf,dens,freqf,angle,WAVE_LENGTH=wave_l,$
;                                           V_PHASE=vphase,ERES_LAND=eres_lan,       $
;                                           ERES_NCYC=eres_nor,ERES_ACYC=eres_ano)
;
;  KEYWORDS:    
;               WAVE_LENGTH  :  Set to a named variable to return the wave lengths (km)
;               V_PHASE      :  " " phase speeds (km/s)
;               ERES_LAND    :  " " Landau resonant energies (eV)
;               ERES_NCYC    :  " " normal cyclotron resonant energies (eV)
;               ERES_ACYC    :  " " anomalous cyclotron resonant energies (eV)
;
;   CHANGED:  1)  NA [MM/DD/YYYY   v1.0.0]
;
;   NOTES:      
;               1)  All inputs must have the same dimensions and the indices must
;                     correspond to the simultaneous values to be used in the
;                     calculations
;
;   CREATED:  08/25/2011
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  08/25/2011   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION whistler_params_calc_1d,magf,dens,freqf,angle,WAVE_LENGTH=wave_l,V_PHASE=vphase,$
                                ERES_LAND=eres_lan,ERES_NCYC=eres_nor,ERES_ACYC=eres_ano

;-----------------------------------------------------------------------------------------
; => Make sure input is defined
;-----------------------------------------------------------------------------------------
IF (N_PARAMS() NE 4) THEN RETURN,0
;-----------------------------------------------------------------------------------------
; => Define dummy variables
;-----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
epo            = 8.854187817d-12        ; => Permittivity of free space (F/m)
muo            = 4d0*!DPI*1d-7          ; => Permeability of free space (N/A^2 or H/m)
me             = 9.1093897d-31          ; => Electron mass (kg)
mp             = 1.6726231d-27          ; => Proton mass (kg)
qq             = 1.60217733d-19         ; => Fundamental charge (C)
K_eV           = 1.160474d4             ; => Conversion = degree Kelvin/eV
kB             = 1.380658d-23           ; => Boltzmann Constant (J/K)
c              = 2.99792458d8           ; => Speed of light in vacuum (m/s)
wcefac         = qq/me
wpefac         = SQRT(qq^2/me/epo)
;-----------------------------------------------------------------------------------------
; => Check input
;-----------------------------------------------------------------------------------------
freqw          = REFORM(freqf)*(2d0*!DPI)     ; => Convert wave frequency to radians/s
pdens          = REFORM(dens)*1d6             ; => Convert density to # m^(-3)
bmag           = REFORM(magf)*1d-9            ; => Convert B-field to T
costhkb        = COS(angle*!DPI/18d1)         ; => Convert angles to cosines

nbm            = N_ELEMENTS(bmag)
nfs            = N_ELEMENTS(freqw)
;-----------------------------------------------------------------------------------------
; => Define relevant parameters
;-----------------------------------------------------------------------------------------
wce       = wcefac[0]*bmag                     ; => Cyclotron frequency (radians/s)
wpe       = wpefac[0]*SQRT(pdens)              ; => Plasma frequency (radians/s)
; => Energy factor (eV)
efactor   = (bmag^2/(2d0*muo[0]*pdens))/qq[0]
frat      = freqw/wce                          ; => Ratio of wave to electron cyclotron frequency
fmult     = freqw*wce
;-----------------------------------------------------------------------------------------
; => Calculate the relevant whistler parameters
;-----------------------------------------------------------------------------------------
cos_fac   = (costhkb - frat)                   ; => [N]-Element array
rat_fac   = 1d0/(frat*costhkb^2)               ; => [N]-Element array
wfac      = (2d0*!DPI)*SQRT(2d0/me*qq)*1d-3    ; => Factor for wavelength
vfac      = (c/wpe)*1d-3                       ; => Factor for phase speed [km]

eres_lan  = (rat_fac*cos_fac)*(0d0 + frat)^2   ; => Landau Resonance Energies (unitless)
eres_nor  = (rat_fac*cos_fac)*(-1d0 + frat)^2  ; => Normal Cyclotron Resonance [CR] Energies (unitless)
eres_ano  = (rat_fac*cos_fac)*(1d0 + frat)^2   ; => Anomalous CR Energies (unitless)
wave_l    = wfac[0]*SQRT(cos_fac/fmult)        ; => Wavelength [km eV^(-1/2)]
vphase    = vfac*SQRT(fmult*cos_fac)           ; => Phase speed [km/s]

eres_lan *= efactor                            ; => Landau Resonance Energies [eV]
eres_nor *= efactor                            ; => Normal CR Energies [eV]
eres_ano *= efactor                            ; => Anomalous CR Energies [eV]
wave_l   *= SQRT(efactor)                      ; => Wavelength [km]

RETURN,1
END

;+
;*****************************************************************************************
;
;  FUNCTION :   cold_plasma_whistler_params_1d.pro
;  PURPOSE  :   Given the ambient magnetic field strength, plasma density, wave
;                 frequency, and propagation angle the program will return a
;                 cold plasma estimate of a whistler wave phase velocity,
;                 Landau, normal, and anomalous cyclotron resonance energies,
;                 and an estimated wavelength.
;
;  CALLED BY:   
;               NA
;
;  CALLS:
;               whistler_params_calc_1d.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               MAGF   :  N-Element array of magnetic field magnitudes (nT)
;               DENS   :  " " plasma densities [cm^(-3)]
;               FREQF  :  " " wave frequencies (Hz)
;               ANGLE  :  " " wave propagation angles with respect to the magnetic
;                           field (degrees)
;
;  EXAMPLES:    
;               test = cold_plasma_whistler_params_1d(magf,dens,freqf,angle)
;
;  KEYWORDS:    
;               NA
;
;   CHANGED:  1)  NA [MM/DD/YYYY   v1.0.0]
;
;   NOTES:      
;               1)  These calculations are in the high density limit or:
;                     Ωce << Ωpe
;
;   CREATED:  08/25/2011
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  08/25/2011   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION  cold_plasma_whistler_params_1d,magf,dens,freqf,angle

;-----------------------------------------------------------------------------------------
; => Define dummy variables
;-----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
epo            = 8.854187817d-12        ; => Permittivity of free space (F/m)
muo            = 4d0*!DPI*1d-7          ; => Permeability of free space (N/A^2 or H/m)
me             = 9.1093897d-31          ; => Electron mass (kg)
mp             = 1.6726231d-27          ; => Proton mass (kg)
qq             = 1.60217733d-19         ; => Fundamental charge (C)
K_eV           = 1.160474d4             ; => Conversion = degree Kelvin/eV
kB             = 1.380658d-23           ; => Boltzmann Constant (J/K)
c              = 2.99792458d8           ; => Speed of light in vacuum (m/s)
wcefac         = qq/me
wpefac         = SQRT(qq^2/me/epo)
;-----------------------------------------------------------------------------------------
; => Check input
;-----------------------------------------------------------------------------------------
freqw   = REFORM(freqf)                 ; => Wave frequency [Hz]
pdens   = REFORM(dens)                  ; => Density [cm^(-3)]
bmag    = REFORM(magf)                  ; => B-field [nT]
angles  = REFORM(angle)
;-----------------------------------------------------------------------------------------
; => Define relevant parameters
;-----------------------------------------------------------------------------------------
nbm      = N_ELEMENTS(bmag)
ndn      = N_ELEMENTS(pdens)
nfs      = N_ELEMENTS(freqw)
nth      = N_ELEMENTS(angles)
test     = (nbm NE ndn) OR (nbm NE nfs) OR (nbm NE nth) OR $
           (ndn NE nfs) OR (ndn NE nth) OR (nfs NE nth)
IF (test) THEN RETURN,0
;-----------------------------------------------------------------------------------------
; => Define resonance parameters
;-----------------------------------------------------------------------------------------
; => Landau Resonance Energies (eV)
eres_lan = DBLARR(nbm)
; => Normal Cyclotron Resonance Energies (eV)
eres_nor = DBLARR(nbm)
; => Anomalous Cyclotron Resonance Energies (eV)
eres_ano = DBLARR(nbm)
; => Wavelengths (km)
wave_l   = DBLARR(nbm)
; => Phase speeds (km/s)
vphase   = DBLARR(nbm)

tests = whistler_params_calc_1d(bmag,pdens,freqw,angles,WAVE_LENGTH=ww0,$
                                V_PHASE=vv0,ERES_LAND=el0,ERES_NCYC=ecn,$
                                ERES_ACYC=eca)

eres_lan = REFORM(el0)
eres_nor = REFORM(ecn)
eres_ano = REFORM(eca)
wave_l   = REFORM(ww0)
vphase   = REFORM(vv0)
;-----------------------------------------------------------------------------------------
; => Return data structure
;-----------------------------------------------------------------------------------------
tags     = ['WAVE_LENGTH','V_PHASE','ERES_LAND','ERES_NCYC','ERES_ACYC']
struc    = CREATE_STRUCT(tags,wave_l,vphase,eres_lan,eres_nor,eres_ano)


RETURN,struc
END

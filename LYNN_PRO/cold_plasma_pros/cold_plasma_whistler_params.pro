;+
;*****************************************************************************************
;
;  FUNCTION :   whistler_params_calc.pro
;  PURPOSE  :   Calculates the cold plasma resonance energy estimate given a 
;                 magnetic field strength, plasma density, wave frequency, 
;                 and propagation angle.
;
;  CALLED BY:   
;               cold_plasma_whistler_params.pro
;
;  CALLS:
;               NA
;
;  REQUIRES:    
;               NA
;
;  INPUT:
;               MAGF         :  N-Element array of magnetic field magnitudes (nT)
;               DENS         :  " " plasma density [cm^(-3)]
;               FREQF        :  M-Element array of wave frequencies (Hz)
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
;               1)  User should not call this routine
;
;   CREATED:  03/22/2011
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  03/22/2011   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION whistler_params_calc,magf,dens,freqf,angle,WAVE_LENGTH=wave_l,V_PHASE=vphase,$
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
freqw          = REFORM(freqf[*])*(2d0*!DPI)  ; => Convert wave frequency to radians/s
pdens          = dens[0]*1d6                  ; => Convert density to # m^(-3)
bmag           =  REFORM(magf[*])*1d-9        ; => Convert B-field to T
;bmag           = magf[0]*1d-9                 ; => Convert B-field to T
costhkb        = COS(angle[0]*!DPI/18d1)      ; => Convert angles to cosines

nbm            = N_ELEMENTS(bmag)
nfs            = N_ELEMENTS(freqw)
;-----------------------------------------------------------------------------------------
; => Define relevant parameters
;-----------------------------------------------------------------------------------------
wce      = wcefac[0]*bmag[*]                ; => Cyclotron frequency (radians/s)
wpe      = wpefac[0]*SQRT(pdens[0])         ; => Plasma frequency (radians/s)
; => Energy factor (J)
IF (nbm GT 1) THEN BEGIN
;  efactor  = (REPLICATE(1d0,nfs) # (bmag[*]^2/(2d0*muo*pdens[0])))/qq   ; => [eV]
  efactor  = (bmag[*]^2/(2d0*muo*pdens[0]))/qq   ; => [eV]
  frat     = freqw[*] ## (1d0/wce[*])
  fmult    = freqw[*] ## wce[*]
ENDIF ELSE BEGIN
  efactor  = (bmag[0]^2/(2d0*muo*pdens[0]))/qq   ; => [eV]
  frat     = freqw[*]/wce[0]
  fmult    = freqw[*]*wce[0]
ENDELSE
;-----------------------------------------------------------------------------------------
; => Calculate the relevant whistler parameters
;-----------------------------------------------------------------------------------------
cos_fac  = (costhkb[0] - frat)               ; => [N,M]-Element array
rat_fac  = 1d0/(frat*costhkb[0]^2)           ; => [N,M]-Element array
wfac     = (2d0*!DPI)*SQRT(2d0/me*qq)*1d-3   ; => Factor for wavelength
vfac     = (c/wpe[0])*1d-3                   ; => Factor for phase speed

eres_lan = (rat_fac*cos_fac)*(0d0 + frat)^2   ; => Landau Resonance Energies (unitless)
eres_nor = (rat_fac*cos_fac)*(-1d0 + frat)^2  ; => Normal Cyclotron Resonance Energies (unitless)
eres_ano = (rat_fac*cos_fac)*(1d0 + frat)^2   ; => Anomalous Cyclotron Resonance Energies (unitless)
wave_l   = wfac[0]*SQRT(cos_fac/fmult)
vphase   = vfac[0]*SQRT(fmult*cos_fac)


FOR i=0L, nbm - 1L DO BEGIN
  eres_lan[i,*] *= efactor[i]
  eres_nor[i,*] *= efactor[i]
  eres_ano[i,*] *= efactor[i]
  wave_l[i,*]   *= SQRT(efactor[i])
ENDFOR

RETURN,1
END

;+
;*****************************************************************************************
;
;  FUNCTION :   cold_plasma_whistler_params.pro
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
;               whistler_params_calc.pro
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
;               test = cold_plasma_whistler_params(magf,dens,freqf,angle)
;
;  KEYWORDS:    
;               NA
;
;   CHANGED:  1)  Added calculation to allow for different number of elements for
;                   each type of input                          [03/22/2011   v1.1.0]
;
;   NOTES:      
;               1)  These calculations are in the high density limit or:
;                     Ωce << Ωpe
;
;   CREATED:  05/01/2010
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  03/22/2011   v1.1.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION  cold_plasma_whistler_params,magf,dens,freqf,angle

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
; => Landau Resonance Energies (eV)
;eres_lan = d
eres_lan = DBLARR(nbm,ndn,nfs,nth)
; => Normal Cyclotron Resonance Energies (eV)
;eres_nor = d
eres_nor = DBLARR(nbm,ndn,nfs,nth)
; => Anomalous Cyclotron Resonance Energies (eV)
;eres_ano = d
eres_ano = DBLARR(nbm,ndn,nfs,nth)
; => Wavelengths (km)
;wave_l   = d
wave_l   = DBLARR(nbm,ndn,nfs,nth)
; => Phase speeds (km/s)
;vphase   = d
vphase   = DBLARR(nbm,ndn,nfs,nth)


IF (nbm GT 1) THEN BEGIN
  FOR j=0L, ndn - 1L DO BEGIN
    FOR m=0L, nth - 1L DO BEGIN
      test = whistler_params_calc(bmag[*],pdens[j],freqw[*],angles[m],WAVE_LENGTH=ww0,$
                                  V_PHASE=vv0,ERES_LAND=el0,ERES_NCYC=ecn,ERES_ACYC=eca)
      eres_lan[*,j,*,m] = REFORM(el0,nbm,1L,nfs)
      eres_nor[*,j,*,m] = REFORM(ecn,nbm,1L,nfs)
      eres_ano[*,j,*,m] = REFORM(eca,nbm,1L,nfs)
      wave_l[*,j,*,m]   = REFORM(ww0,nbm,1L,nfs)
      vphase[*,j,*,m]   = REFORM(vv0,nbm,1L,nfs)
    ENDFOR
  ENDFOR
ENDIF ELSE BEGIN
  FOR j=0L, ndn - 1L DO BEGIN
    FOR m=0L, nth - 1L DO BEGIN
      test = whistler_params_calc(bmag[0],pdens[j],freqw[*],angles[m],WAVE_LENGTH=ww0,$
                                  V_PHASE=vv0,ERES_LAND=el0,ERES_NCYC=ecn,ERES_ACYC=eca)
      eres_lan[0,j,*,m] = el0
      eres_nor[0,j,*,m] = ecn
      eres_ano[0,j,*,m] = eca
      wave_l[0,j,*,m]   = ww0
      vphase[0,j,*,m]   = vv0
    ENDFOR
  ENDFOR
ENDELSE
;-----------------------------------------------------------------------------------------
; => Return data structure
;-----------------------------------------------------------------------------------------
tags     = ['WAVE_LENGTH','V_PHASE','ERES_LAND','ERES_NCYC','ERES_ACYC']
struc    = CREATE_STRUCT(tags,wave_l,vphase,eres_lan,eres_nor,eres_ano)


RETURN,struc
END
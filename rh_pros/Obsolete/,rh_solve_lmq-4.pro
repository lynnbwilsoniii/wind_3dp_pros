;+
;*****************************************************************************************
;
;  FUNCTION :   rh_solve_lmq.pro
;  PURPOSE  :   Creates a chi-squared map using technique analogous to the
;                 Levenberg-Marquardt method on the Rankine-Hugoniot equations
;                 from Koval and Szabo, [2008].  The routine uses the chi-squared map
;                 to find a local minimum and then returns a data structure with
;                 the associated shock normal vector, theta, phi, Vshn, and Un.
;
;  CALLED BY:   
;               NA
;
;  CALLS:
;               rh_resize.pro
;               vshn_calc.pro
;               rh_eq_chisq.pro
;
;  REQUIRES:    
;               NA
;
;  INPUT:
;               RHO     :  [N,2]-Element [up,down] array corresponding to the number
;                            density [cm^(-3)]
;               VSW     :  [N,3,2]-Element [up,down] array corresponding to the solar wind
;                            velocity vectors [SC-frame, km/s]
;               MAG     :  [N,3,2]-Element [up,down] array corresponding to the ambient
;                            magnetic field vectors [nT]
;               TOT     :  [N,2]-Element [up,down] array corresponding to the total plasma
;                            temperature [eV]
;
;  EXAMPLES:    
;               NA
;
;  KEYWORDS:    
;               NMAX    :  Scalar defining the maximum # of iterations to perform in
;                            Levenberg-Marquardt method
;                            [Default = 100]
;               NEQS    :  [5]-Element array defining which equations to use in the
;                            solution { Eq. 2, Eq. 3, Eq. 4, Eq. 5, Eq. 6 }
;                            [Default = [1,1,1,1,1] or use all]
;               NOMSSG  :  If set, the program will NOT print out a message about the
;                            running time of the program.  This is particularly useful
;                            when calling the program multiple times in a loop.
;               SOLN    :  Set to a named variable to return the best fit solutions
;                            for the shock normal vector, theta, phi, Vshn, and Un
;                            {Un both upstream and downstream}
;               BOWSH   :  If set, routine uses values more appropriate for bow shock
;                            calculations [i.e. shift phi by 180 degrees]
;
;   CHANGED:  1)  Changed input and output format so that N RH Eqs
;                   are calculated for each shock normal vector     [09/07/2011   v1.1.0]
;             2)  Added keyword:  NEQS and changed normalization    [09/09/2011   v1.2.0]
;             3)  Now calls rh_resize.pro and added functionality of keyword NMAX
;                                                                   [09/10/2011   v1.3.0]
;             4)  Added keyword:  SOLN                              [09/12/2011   v1.4.0]
;             5)  Removed unnecessary calculation                   [09/15/2011   v1.4.1]
;             6)  Added keyword:  BOWSH                             [09/15/2011   v1.5.0]
;             7)  Updated man page now that subroutines are standalone
;                                                                   [07/11/2012   v1.6.0]
;
;   NOTES:      
;               1)  NMAX must be at least 25
;               2)  Definitions:
;                     theta = poloidal angle from XY-plane
;                     phi   = azimuthal angle from +X-axis
;                     Vshn  = shock normal speed in spacecraft frame
;               3)  Elements of SOLN structure contain {Avg., Std. Dev.}
;                     shock normal vector -> Avg.      = soln.SH_NORM[*,0]
;                                         -> Std. Dev. = soln.SH_NORM[*,1]
;
;  REFERENCES:  
;               1)  Vinas, A.F. and J.D. Scudder (1986), "Fast and Optimal Solution to
;                      the 'Rankine-Hugoniot Problem'," J. Geophys. Res. 91, pp. 39-58.
;               2)  A. Szabo (1994), "An improved solution to the 'Rankine-Hugoniot'
;                      problem," J. Geophys. Res. 99, pp. 14,737-14,746.
;               3)  Koval, A. and A. Szabo (2008), "Modified 'Rankine-Hugoniot' shock
;                      fitting technique:  Simultaneous solution for shock normal and
;                      speed," J. Geophys. Res. 113, pp. A10110.
;
;   CREATED:  06/21/2011
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  07/11/2012   v1.6.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION rh_solve_lmq,rho,vsw,mag,tot,NMAX=nmax,POLYT=polyt,NEQS=neqs,$
                                      NOMSSG=nom,SOLN=soln,BOWSH=bowsh

;*****************************************************************************************
ex_start = SYSTIME(1)
;*****************************************************************************************
;-----------------------------------------------------------------------------------------
; => Define dummy variables
;-----------------------------------------------------------------------------------------
f          = !VALUES.F_NAN
d          = !VALUES.D_NAN
K_eV       = 1.160474d4        ; => Conversion = degree Kelvin/eV
kB         = 1.3806504d-23     ; => Boltzmann Constant (J/K)
qq         = 1.60217733d-19    ; => Fundamental charge (C) [or = J/eV]
me         = 9.1093897d-31     ; => Electron mass [kg]
mp         = 1.6726231d-27     ; => Proton mass [kg]
mi         = (me + mp)         ; => Total mass [kg]
muo        = 4d0*!DPI*1d-7     ; => Permeability of free space (N/A^2 or H/m)

IF KEYWORD_SET(nmax)  THEN m   = nmax[0] ELSE m   = 100L
IF KEYWORD_SET(bowsh) THEN bow = 1       ELSE bow = 0
m          = m > 25L
; => Create polar angles
phi        = DINDGEN(m)*2d0*!DPI/(m - 1L) - !DPI*bow[0]
the        = DINDGEN(m)*!DPI/(m - 1L) - !DPI/2d0
ph         = REFORM(phi)
th         = REFORM(the)
; => Generate shock normal vector
;            [theta, phi, 3]
nor        = DBLARR(m,m,3L)
nor[*,*,0] = COS(th) # COS(ph)
nor[*,*,1] = COS(th) # SIN(ph)
nor[*,*,2] = SIN(th) # REPLICATE(1,m)
;-----------------------------------------------------------------------------------------
; => Check input
;-----------------------------------------------------------------------------------------
IF (N_PARAMS() NE 4) THEN RETURN,d
IF (N_ELEMENTS(rho) EQ 4) THEN BEGIN
  ; => Only entered 2 data pairs
  errmsg = 'Enter more than 2 data pairs...'
  MESSAGE,errmsg[0],/INFORMATIONAL,/CONTINUE
  RETURN,d
ENDIF
ni         = rho
vo         = vsw
bo         = mag
te         = tot

rh_resize,RHO=ni,NPTS=npts_r
rh_resize,VSW=vo,NPTS=npts_v
rh_resize,MAG=bo,NPTS=npts_b
rh_resize,TOT=te,NPTS=npts_t
check      = TOTAL(FINITE([npts_r,npts_v,npts_b,npts_t])) NE 4
IF (check) THEN RETURN,d
nd         = npts_r[0]            ; => # of data points
;-----------------------------------------------------------------------------------------
; => Determine which equations to sum
;-----------------------------------------------------------------------------------------
IF KEYWORD_SET(neqs) THEN BEGIN
  IF (N_ELEMENTS(neqs) NE 5) THEN BEGIN
    ; => Default = use all
    nqq = [1,1,1,1,1]
  ENDIF ELSE BEGIN
    good = WHERE(neqs,gnq)
    IF (gnq GT 0) THEN BEGIN
      nqq       = [0,0,0,0,0]
      nqq[good] = 1
    ENDIF ELSE BEGIN
      ; => Default = use all
      nqq = [1,1,1,1,1]
    ENDELSE
  ENDELSE
ENDIF ELSE BEGIN
  ; => Default = use all
  nqq = [1,1,1,1,1]
ENDELSE
;-----------------------------------------------------------------------------------------
; => Calculate chi-squared
;-----------------------------------------------------------------------------------------
;             [theta, phi]
chisq      = DBLARR(m,m)
stddv      = DBLARR(nd,m)
j          = 0L
true       = 1
WHILE(true) DO BEGIN
  schi       = DBLARR(nd,m)
  tnor       = REFORM(nor[*,j,*])          ; => [M,3]-Element array
  ; => Calculate shock normal speed [SC-frame] from Eq. 7 of Koval and Szabo, [2008]
  vshns      = vshn_calc(ni,vo,tnor)       ; => [N,M]-Element array
  ; => Calculate chi-squared for M-data points
  tchi       = rh_eq_chisq(ni,vo,bo,te,tnor,vshns,POLYT=polyt,SIGX=sigx,NEQS=nqq)  ; => [N,M]-Element array
  good       = WHERE(nqq,gnq)
  ; => Normalize the chi-squared values by # of degrees of freedom
  ;      and sum over N-data points
  chisq[*,j] = TOTAL(tchi,1L,/NAN,/DOUBLE)/ABS(nd[0]*gnq[0] - 1d0)
  IF (j LT m - 1L) THEN true = 1 ELSE true = 0
  j         += true
ENDWHILE
;-----------------------------------------------------------------------------------------
; => Calculate the minimum of the chi-squared distribution
;-----------------------------------------------------------------------------------------
mnchsq    = MIN(chisq,/NAN,ln)
; => There are typically 2 regions, so find the one closer to the expected
good      = WHERE(chisq LE mnchsq[0]+0.1,gd)
gmin2     = ARRAY_INDICES(chisq,good)
IF (bow) THEN BEGIN
  ; => Bow shocks are expected to have normal along +X GSE
  diff      = ABS(REFORM(gmin2[0,*]))*ABS(REFORM(gmin2[1,*]))
ENDIF ELSE BEGIN
  ; => IP shocks are expected to have normal along -X GSE
  diff      = ABS(50 - REFORM(gmin2[0,*]))*ABS(50 - REFORM(gmin2[1,*]))
ENDELSE
sph       = SORT(diff)
gmin      = REFORM(gmin2[*,sph[0]])
; => Calculate the best fit shock normal vector
gnorm     = REFORM(nor[gmin[0],gmin[1],*])
;-----------------------------------------------------------------------------------------
; => Region of 68.3% confidence -> ∆X^2 = 2.30 (for 2 degrees of freedom)
;      Theorem D from numerical recipes [Section 15.6]
;-----------------------------------------------------------------------------------------
IF (bow) THEN BEGIN
  ; => Bow shocks are higher Mach number, thus typically more turbulent
  ;     => Use smaller chi-squared difference
  conf683 = mnchsq[0] + 1.00
ENDIF ELSE BEGIN
  ; => IP shocks are lower Mach number, thus typically more laminar
  conf683 = mnchsq[0] + 2.30
ENDELSE
region  = WHERE(chisq LE conf683[0],greg)
rind    = ARRAY_INDICES(chisq,region)
; => often more than one minima, so center points on known min.
good1   = WHERE(REFORM(rind[0,*]) LE gmin[0] + 10 AND REFORM(rind[0,*]) GE gmin[0] - 10,gd1)
good2   = WHERE(REFORM(rind[1,*]) LE gmin[1] + 10 AND REFORM(rind[1,*]) GE gmin[1] - 10,gd2)
;chi_reg = REPLICATE(d,100L,100L)
;chi_reg[rind[0,good1],rind[1,good2]] = chisq[rind[0,good1],rind[1,good2]]
th_reg  = REFORM(th[rind[0,good1]])
ph_reg  = REFORM(ph[rind[1,good2]])
; => Define Avg. +/- Std. Dev.
ph_avg  = MEAN(ph_reg,/NAN,/DOUBLE)
ph_std  = STDDEV(ph_reg,/NAN,/DOUBLE)
th_avg  = MEAN(th_reg,/NAN,/DOUBLE)
th_std  = STDDEV(th_reg,/NAN,/DOUBLE)
; => Calculate the range of possible shock normals
norx    = COS(th_reg) # COS(ph_reg)
nory    = COS(th_reg) # SIN(ph_reg)
norz    = SIN(th_reg) # REPLICATE(1,gd1)
; => Define Avg. +/- Std. Dev.
nx_avg  = MEAN(norx,/NAN,/DOUBLE)
nx_std  = STDDEV(norx,/NAN,/DOUBLE)
ny_avg  = MEAN(nory,/NAN,/DOUBLE)
ny_std  = STDDEV(nory,/NAN,/DOUBLE)
nz_avg  = MEAN(norz,/NAN,/DOUBLE)
nz_std  = STDDEV(norz,/NAN,/DOUBLE)
; => Define all combinations
xx      = [nx_avg[0],ny_avg[0],nz_avg[0]]
dx      = [nx_std[0],ny_std[0],nz_std[0]]
dx3     = dx # REPLICATE(1d0,3L)
yy      = [ [xx - dx],   [xx],  [xx + dx]]
zz      = [[[yy - dx3]],[[yy]],[[yy + dx3]]]       ; => [3L,3L,3L]-Element array
ww      = TRANSPOSE(REFORM(zz,3L,3L*3L))           ; => [9L,3L]-Element array
; => Calculate array of possible shock normal speeds in spacecraft frame [km/s]
vshn_a  = vshn_calc(ni,vo,ww)
; => Calculate the best fit shock normal speed in spacecraft frame [km/s]
vshnavg = MEAN(vshn_a,/NAN,/DOUBLE)
vshnstd = STDDEV(vshn_a,/NAN,/DOUBLE)
; => Calculate array of possible shock normal speeds in shock frame [km/s]
ushn_a  = del_vsn(vo,ww,vshn_a,VEC=0)
; => Calculate the best fit shock normal speed in shock frame [km/s] {upstream, downstream}
unavgup = MEAN(ushn_a[*,*,0],/NAN,/DOUBLE)
unstdup = STDDEV(ushn_a[*,*,0],/NAN,/DOUBLE)
unavgdn = MEAN(ushn_a[*,*,1],/NAN,/DOUBLE)
unstddn = STDDEV(ushn_a[*,*,1],/NAN,/DOUBLE)
;-----------------------------------------------------------------------------------------
; => Create data structure of results and return
;-----------------------------------------------------------------------------------------
tags       = ['SH_NORM','THETA','PHI','VSHN','USHN_UP','USHN_DN']
soln       = CREATE_STRUCT(tags,[[xx],[dx]],[th_avg[0],th_std[0]],[ph_avg[0],ph_std[0]],$
                                [vshnavg[0],vshnstd[0]],[unavgup[0],unstdup[0]],$
                                [unavgdn[0],unstddn[0]])

;*****************************************************************************************
ex_time = SYSTIME(1) - ex_start
IF NOT KEYWORD_SET(nom) THEN BEGIN
  MESSAGE,STRING(ex_time)+' seconds execution time.',/INFORMATIONAL,/CONTINUE
ENDIF
;*****************************************************************************************
;-----------------------------------------------------------------------------------------
; => Return chi-squared
;-----------------------------------------------------------------------------------------
RETURN,chisq
END


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
;  INCLUDES:
;               NA
;
;  CALLS:
;               rh_resize.pro
;               vshn_calc.pro
;               rh_eq_chisq.pro
;               del_vsn.pro
;
;  REQUIRES:    
;               1)  LBW's Rankine-Hugoniot Analysis Library
;
;  INPUT:
;               RHO     :  [N,2]-Element [numeric] array corresponding to the number
;                            density [cm^(-3)] for upstream and downstream
;               VSW     :  [N,3,2]-Element [numeric] array corresponding to the solar wind
;                            velocity vectors [SC-frame, km/s] for upstream and downstream
;               MAG     :  [N,3,2]-Element [numeric] array corresponding to the ambient
;                            magnetic field vectors [nT] for upstream and downstream
;               TOT     :  [N,2]-Element [numeric] array corresponding to the total plasma
;                            temperature [eV] for upstream and downstream
;
;  EXAMPLES:    
;               [calling sequence]
;               
;
;  KEYWORDS:    
;               NMAX    :  Scalar [numeric] defining the maximum # of iterations to
;                            perform in Levenberg-Marquardt method
;                            [Default = 100]
;               NEQS    :  [5]-Element [integer] array defining which equations to use
;                            in the solution { Eq. 2, Eq. 3, Eq. 4, Eq. 5, Eq. 6 }
;                            [Default = [1,1,1,1,1] or use all]
;               NOMSSG  :  If set, the program will NOT print out a message about the
;                            running time of the program.  This is particularly useful
;                            when calling the program multiple times in a loop.
;               SOLN    :  Set to a named variable to return the best fit solutions
;                            for the shock normal vector, theta, phi, Vshn, and Un
;                            {Un both upstream and downstream}
;               BOWSH   :  ***  Obsolete  ***
;                          If set, routine uses values more appropriate for bow shock
;                            calculations [i.e., shift phi by 180 degrees]
;               REVER   :  If set, routine calculates values appropriate for a reverse
;                            shock (i.e., sign changes in calculation of Ushn)
;                            [Default = FALSE]
;               PHRAN   :  [2]-Element [numeric] array defining the range of azimuthal
;                            angles [degrees] to limit to in the solution finding
;                            [Default = [0,360]]
;               THRAN   :  [2]-Element [numeric] array defining the range of latitudinal
;                            angles [degrees] to limit to in the solution finding
;                            [Default = [-90,90]]
;
;   CHANGED:  1)  Changed input and output format so that N RH Eqs
;                   are calculated for each shock normal vector
;                                                                   [09/07/2011   v1.1.0]
;             2)  Added keyword:  NEQS and changed normalization
;                                                                   [09/09/2011   v1.2.0]
;             3)  Now calls rh_resize.pro and added functionality of keyword NMAX
;                                                                   [09/10/2011   v1.3.0]
;             4)  Added keyword:  SOLN
;                                                                   [09/12/2011   v1.4.0]
;             5)  Removed unnecessary calculation
;                                                                   [09/15/2011   v1.4.1]
;             6)  Added keyword:  BOWSH
;                                                                   [09/15/2011   v1.5.0]
;             7)  Updated man page now that subroutines are standalone
;                                                                   [07/11/2012   v1.6.0]
;             8)  Changed manner in which routine forces an outward shock normal when
;                   the BOWSH keyword is set
;                                                                   [08/16/2012   v1.7.0]
;             9)  Cleaned up, updated Man. page, and optimized and
;                   added new keywords: REVER, PHRA, and THRA
;                                                                   [08/28/2020   v1.7.1]
;
;   NOTES:      
;               1)  NMAX must be at least 25
;               2)  Definitions:
;                     theta   = poloidal angle from XY-plane = latitude
;                     phi     = azimuthal angle from +X-axis
;                     Vshn    = shock normal speed in spacecraft frame
;                     Ushn,j  = shock normal speed in shock frame in j-th region
;               3)  Elements of SOLN structure contain {Avg., Std. Dev.}
;                     shock normal vector -> Avg.      = soln.SH_NORM[*,0]
;                                         -> Std. Dev. = soln.SH_NORM[*,1]
;               4)  ***  User should use REVER keyword instead of BOWSH now  ***
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
;    LAST MODIFIED:  08/28/2020   v1.7.1
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION rh_solve_lmq,rho,vsw,mag,tot,NMAX=nmax,POLYT=polyt,NEQS=neqs,NOMSSG=nom,   $
                                      SOLN=soln,BOWSH=bowsh,REVER=rever,PHRAN=phran,$
                                      THRAN=thran

;*****************************************************************************************
ex_start = SYSTIME(1)
;*****************************************************************************************
;;----------------------------------------------------------------------------------------
;;  Define dummy variables
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
kB             = 1.3806485200d-23         ;;  Boltzmann Constant [J K^(-1), 2014 CODATA/NIST]
qq             = 1.6021766208d-19         ;;  Fundamental charge [C, 2014 CODATA/NIST]
me             = 9.1093835600d-31         ;;  Electron mass [kg, 2014 CODATA/NIST]
mp             = 1.6726218980d-27         ;;  Proton mass [kg, 2014 CODATA/NIST]
K_eV           = qq[0]/kB[0]              ;;  Conversion = degree Kelvin/eV
mi             = (me + mp)                ;;  Total mass [kg]
muo            = 4d0*!DPI*1d-7            ;;  Permeability of free space (N/A^2 or H/m)
;;  Define allowed number types
all_num_type   = [1,2,3,4,5,6,9,12,13,14,15]
;;  Define default theta and phi ranges [degrees]
def_phran      = [0d0,36d1]
def_thran      = [-1d0,1d0]*9d1
phi_on         = 0b
the_on         = 0b
;;----------------------------------------------------------------------------------------
;;  Check input
;;----------------------------------------------------------------------------------------
IF (N_PARAMS() LT 4) THEN RETURN,d
test           = (N_ELEMENTS(rho) LE 4) OR (N_ELEMENTS(tot) LE 4)
IF (N_ELEMENTS(rho) EQ 4) THEN BEGIN
  ;;  Only entered 2 data pairs
  errmsg = 'Enter more than 2 data pairs...'
  MESSAGE,errmsg[0],/INFORMATIONAL,/CONTINUE
  RETURN,d
ENDIF
;;----------------------------------------------------------------------------------------
;;  Check keywords to define array of shock normals
;;----------------------------------------------------------------------------------------
;;  Check NMAX
IF (KEYWORD_SET(nmax) AND (TOTAL(SIZE(nmax,/TYPE) EQ all_num_type) EQ 1)) THEN m = nmax[0] ELSE m = 100L
;;  Check BOWSH
IF KEYWORD_SET(bowsh) THEN bow = 1b ELSE bow = 0b
;;  Check REVER
IF KEYWORD_SET(rever) THEN rev = 1b ELSE rev = 0b
;;  Check PHRAN
IF ((N_ELEMENTS(phran) EQ 2) AND (TOTAL(SIZE(phran,/TYPE) EQ all_num_type) EQ 1)) THEN BEGIN
  phmnmx         = DOUBLE(phran[SORT(phran)])
  IF (phmnmx[0] EQ phmnmx[1] OR (TOTAL(FINITE(phmnmx)) LT 2)) THEN BEGIN
    ;;  Use default
    phmnmx         = def_phran
    phmnmx[0]     *= rev[0]
  ENDIF ELSE BEGIN
    ;;  Make sure values fall within valid ranges
    phmnmx[0]      = phmnmx[0] > def_phran[0]
    phmnmx[1]      = phmnmx[1] < def_phran[1]
    phi_on         = 1b
  ENDELSE
ENDIF ELSE BEGIN
  ;;  Use default
  phmnmx         = def_phran
  phmnmx[0]     *= rev[0]
ENDELSE
;;  Check THRAN
IF ((N_ELEMENTS(thran) EQ 2) AND (TOTAL(SIZE(thran,/TYPE) EQ all_num_type) EQ 1)) THEN BEGIN
  thmnmx         = DOUBLE(thran[SORT(thran)])
  IF (thmnmx[0] EQ thmnmx[1] OR (TOTAL(FINITE(thmnmx)) LT 2)) THEN BEGIN
    ;;  Use default
    thmnmx         = def_thran
  ENDIF ELSE BEGIN
    thmnmx[0]      = thmnmx[0] > def_thran[0]
    thmnmx[1]      = thmnmx[1] < def_thran[1]
    the_on         = 1b
  ENDELSE
ENDIF ELSE BEGIN
  ;;  Use default
  thmnmx         = def_thran
ENDELSE
;;  Convert to radians
phmnmx        *= (!DPI/18d1)
thmnmx        *= (!DPI/18d1)
;;----------------------------------------------------------------------------------------
;;  Generate shock normal vectors
;;----------------------------------------------------------------------------------------
;;  Create polar angle arrays [radians]
m              = m[0] > 25L
phi            = DINDGEN(m[0])*(phmnmx[1] - phmnmx[0])/(m[0] - 1L) + phmnmx[0]
the            = DINDGEN(m[0])*(thmnmx[1] - thmnmx[0])/(m[0] - 1L) + thmnmx[0]
;phi            = DINDGEN(m)*2d0*!DPI/(m - 1L) - !DPI*bow[0]
;the            = DINDGEN(m)*!DPI/(m - 1L) - !DPI/2d0
ph             = REFORM(phi)
th             = REFORM(the)
;;  Generate shock normal vector
;;           [theta, phi, 3]
dumb3d         = DBLARR(m[0],m[0],3L)
nor            = dumb3d
nor[*,*,0]     = COS(th) # COS(ph)
nor[*,*,1]     = COS(th) # SIN(ph)
nor[*,*,2]     = SIN(th) # REPLICATE(1d0,m[0])
;;----------------------------------------------------------------------------------------
;;  Define params
;;----------------------------------------------------------------------------------------
ni             = rho
vo             = vsw
bo             = mag
te             = tot
;;  Format the input for routines [e.g. chi-squared routine]
rh_resize,RHO=ni,NPTS=npts_r
rh_resize,VSW=vo,NPTS=npts_v
rh_resize,MAG=bo,NPTS=npts_b
rh_resize,TOT=te,NPTS=npts_t
check          = TOTAL(FINITE([npts_r,npts_v,npts_b,npts_t])) NE 4
IF (check) THEN RETURN,d
nd             = npts_r[0]            ;;  # of data points
;;----------------------------------------------------------------------------------------
;;  Determine which equations to sum
;;----------------------------------------------------------------------------------------
IF KEYWORD_SET(neqs) THEN BEGIN
  IF (N_ELEMENTS(neqs) NE 5) THEN BEGIN
    ;;  Default = use all
    nqq = [1,1,1,1,1]
  ENDIF ELSE BEGIN
    good = WHERE(neqs,gnq)
    IF (gnq[0] GT 0) THEN BEGIN
      nqq       = [0,0,0,0,0]
      nqq[good] = 1
    ENDIF ELSE BEGIN
      ;;  Default = use all
      nqq = [1,1,1,1,1]
    ENDELSE
  ENDELSE
ENDIF ELSE BEGIN
  ;;  Default = use all
  nqq = [1,1,1,1,1]
ENDELSE
;;----------------------------------------------------------------------------------------
;;  Calculate chi-squared
;;----------------------------------------------------------------------------------------
;;            [theta, phi]
chisq          = dumb3d[*,*,0]
dumb2d         = DBLARR(nd[0],m[0])
stddv          = dumb2d
j              = 0L
true           = 1
WHILE(true) DO BEGIN
  schi       = dumb2d
  tnor       = REFORM(nor[*,j,*])          ;;  [M,3]-Element array
  ;;  Calculate shock normal speed [SC-frame] from Eq. 7 of Koval and Szabo, [2008]
  vshns      = vshn_calc(ni,vo,tnor)       ;;  [N,M]-Element array
  ;;  Calculate chi-squared for M-data points
  tchi       = rh_eq_chisq(ni,vo,bo,te,tnor,vshns,POLYT=polyt,SIGX=sigx,NEQS=nqq)  ;;  [N,M]-Element array
  good       = WHERE(nqq,gnq)
  ;;  Normalize the chi-squared values by # of degrees of freedom
  ;;      and sum over N-data points
  chisq[*,j] = TOTAL(tchi,1L,/NAN,/DOUBLE)/ABS(nd[0]*gnq[0] - 1d0)
  IF (j[0] LT (m[0] - 1L)) THEN true = 1 ELSE true = 0
  j         += true
ENDWHILE
;;----------------------------------------------------------------------------------------
;;  Calculate the minimum of the chi-squared distribution
;;----------------------------------------------------------------------------------------
mnchsq         = MIN(chisq,/NAN,ln)
;;  There are typically 2 regions, so find the one closer to the expected
good           = WHERE(chisq LE mnchsq[0]+0.1,gd)
gmin2          = ARRAY_INDICES(chisq,good)
IF (bow) THEN BEGIN
;IF (rev[0]) THEN BEGIN
  ;;  Reverse shocks are expected to have normal along +X GSE
  diff      = ABS(REFORM(gmin2[0,*]))*ABS(REFORM(gmin2[1,*]))
ENDIF ELSE BEGIN
  ;;  Forward shocks are expected to have normal along -X GSE
  diff      = ABS(50 - REFORM(gmin2[0,*]))*ABS(50 - REFORM(gmin2[1,*]))
ENDELSE
sph            = SORT(diff)
gmin           = REFORM(gmin2[*,sph[0]])
;;  Calculate the best fit shock normal vector
gnorm          = REFORM(nor[gmin[0],gmin[1],*])
;;----------------------------------------------------------------------------------------
;;  Region of 68.3% confidence -> ∆X^2 = 2.30 (for 2 degrees of freedom)
;;      Theorem D from numerical recipes [Section 15.6]
;;----------------------------------------------------------------------------------------
;IF (bow) THEN BEGIN
IF (rev[0]) THEN BEGIN
  ;;  Reverse shocks, like the bow shock, are often higher Mach number, thus typically more turbulent
  ;;    --> Use smaller chi-squared difference
  conf683 = mnchsq[0] + 1.00
ENDIF ELSE BEGIN
  ;;  IP shocks tend to be lower Mach number, thus typically more laminar
  conf683 = mnchsq[0] + 2.30
ENDELSE
region         = WHERE(chisq LE conf683[0],greg)
rind           = ARRAY_INDICES(chisq,region)
;;  often more than one minima, so center points on known min.
good1          = WHERE((REFORM(rind[0,*]) LE gmin[0] + 10) AND (REFORM(rind[0,*]) GE gmin[0] - 10),gd1)
good2          = WHERE((REFORM(rind[1,*]) LE gmin[1] + 10) AND (REFORM(rind[1,*]) GE gmin[1] - 10),gd2)
;;  Define Range of shock normal vectors [spherical coordinate angles, radians]
th_reg         = REFORM(th[rind[0,good1]])
ph_reg         = REFORM(ph[rind[1,good2]])
test           = ((ABS(MEAN(ph_reg,/NAN,/DOUBLE)) GT 12d1*(!DPI/18d1)) AND rev[0]) AND ~phi_on[0]
;test           = (ABS(MEAN(ph_reg,/NAN,/DOUBLE)) GT 12d1*(!DPI/18d1)) AND bow
IF (test[0]) THEN BEGIN
  ;; initial attempt at outward normal failed
  ;;  alter shock normal angles
  ph_reg  += 18d1*(!DPI/18d1)
  th_reg  *= -1d0
ENDIF
;;  Define Average [shock normal vector angles, radians]
ph_avg         = MEAN(ph_reg,/NAN,/DOUBLE)
th_avg         = MEAN(th_reg,/NAN,/DOUBLE)
;;  Define Standard Deviation [shock normal angles]
ph_std         = STDDEV(ph_reg,/NAN,/DOUBLE)
th_std         = STDDEV(th_reg,/NAN,/DOUBLE)
;;  Calculate the range of possible shock normals
norx           = COS(th_reg) # COS(ph_reg)
nory           = COS(th_reg) # SIN(ph_reg)
norz           = SIN(th_reg) # REPLICATE(1,gd1)
;;  Define Avg. +/- Std. Dev.
nx_avg         = MEAN(norx,/NAN,/DOUBLE)
nx_std         = STDDEV(norx,/NAN,/DOUBLE)
ny_avg         = MEAN(nory,/NAN,/DOUBLE)
ny_std         = STDDEV(nory,/NAN,/DOUBLE)
nz_avg         = MEAN(norz,/NAN,/DOUBLE)
nz_std         = STDDEV(norz,/NAN,/DOUBLE)
;;  Define all combinations
xx             = [nx_avg[0],ny_avg[0],nz_avg[0]]
dx             = [nx_std[0],ny_std[0],nz_std[0]]
dx3            = dx # REPLICATE(1d0,3L)
yy             = [ [xx - dx],   [xx],  [xx + dx]]
zz             = [[[yy - dx3]],[[yy]],[[yy + dx3]]]       ;;  [3L,3L,3L]-Element array
ww             = TRANSPOSE(REFORM(zz,3L,3L*3L))           ;;  [9L,3L]-Element array
;;  Calculate array of possible shock normal speeds in spacecraft frame [km/s]
vshn_a         = vshn_calc(ni,vo,ww)
;;  Calculate array of possible shock normal speeds in shock frame [km/s]
good           = WHERE(vshn_a GT 0,gd,COMPLEMENT=bad,NCOMPLEMENT=bd)
IF (rev[0]) THEN BEGIN
;  vshn_a        *= -1d0
;  good           = WHERE(vshn_a LT 0,gd,COMPLEMENT=bad,NCOMPLEMENT=bd)
  ;;  Calculate the best fit shock normal speed in spacecraft frame [km/s]
  IF (gd[0] GT 0) THEN vshnavg =   MEAN(vshn_a[bad],/NAN,/DOUBLE) ELSE vshnavg =   MEAN(ABS(vshn_a),/NAN,/DOUBLE)
  IF (gd[0] GT 0) THEN vshnstd = STDDEV(vshn_a[bad],/NAN,/DOUBLE) ELSE vshnstd = STDDEV(ABS(vshn_a),/NAN,/DOUBLE)
  ;;  Vshn reverses sign for a reverse shock
  temp           = -1d0*vshn_a
;  temp           = -1d0*ABS(vshn_a)
;  IF (bd[0] GT 0 AND gd[0] LT N_ELEMENTS(temp)) THEN temp[bad] = d
  ushn_a         = del_vsn(vo,ww,temp,VEC=0)
  ;;  Calculate the best fit shock normal speed in shock frame [km/s] {upstream, downstream}
  temp           = REFORM(ushn_a[*,*,0])
  unavgup        =   MEAN(temp[bad],/NAN,/DOUBLE)
  unstdup        = STDDEV(temp[bad],/NAN,/DOUBLE)
  temp           = REFORM(ushn_a[*,*,1])
  unavgdn        =   MEAN(temp[bad],/NAN,/DOUBLE)
  unstddn        = STDDEV(temp[bad],/NAN,/DOUBLE)
ENDIF ELSE BEGIN
;  good           = WHERE(vshn_a GT 0,gd,COMPLEMENT=bad,NCOMPLEMENT=bd)
  ;;  Calculate the best fit shock normal speed in spacecraft frame [km/s]
  IF (gd[0] GT 0) THEN vshnavg =   MEAN(vshn_a[good],/NAN,/DOUBLE) ELSE vshnavg =   MEAN(ABS(vshn_a),/NAN,/DOUBLE)
  IF (gd[0] GT 0) THEN vshnstd = STDDEV(vshn_a[good],/NAN,/DOUBLE) ELSE vshnstd = STDDEV(ABS(vshn_a),/NAN,/DOUBLE)
  ;;  Use the regular approach
;  temp           =  1d0*vshn_a
;  temp           =  1d0*ABS(vshn_a)
;  IF (bd[0] GT 0 AND gd[0] LT N_ELEMENTS(temp)) THEN temp[bad] = d
  ushn_a         = del_vsn(vo,ww,vshn_a,VEC=0)
  ;;  Calculate the best fit shock normal speed in shock frame [km/s] {upstream, downstream}
  temp           = REFORM(ushn_a[*,*,0])
  unavgup        =   MEAN(temp[good],/NAN,/DOUBLE)
  unstdup        = STDDEV(temp[good],/NAN,/DOUBLE)
  temp           = REFORM(ushn_a[*,*,1])
  unavgdn        =   MEAN(temp[good],/NAN,/DOUBLE)
  unstddn        = STDDEV(temp[good],/NAN,/DOUBLE)
;  unavgup        = MEAN(ushn_a[*,*,0],/NAN,/DOUBLE)
;  unstdup        = STDDEV(ushn_a[*,*,0],/NAN,/DOUBLE)
;  unavgdn        = MEAN(ushn_a[*,*,1],/NAN,/DOUBLE)
;  unstddn        = STDDEV(ushn_a[*,*,1],/NAN,/DOUBLE)
ENDELSE
;;----------------------------------------------------------------------------------------
;;  Create data structure of results and return
;;----------------------------------------------------------------------------------------
tags           = ['SH_NORM','THETA','PHI','VSHN','USHN_UP','USHN_DN']
soln           = CREATE_STRUCT(tags,[[xx],[dx]],[th_avg[0],th_std[0]],[ph_avg[0],ph_std[0]],$
                                    [vshnavg[0],vshnstd[0]],[unavgup[0],unstdup[0]],$
                                    [unavgdn[0],unstddn[0]])

;*****************************************************************************************
ex_time        = SYSTIME(1) - ex_start
IF ~KEYWORD_SET(nom) THEN MESSAGE,STRING(ex_time)+' seconds execution time.',/INFORMATIONAL,/CONTINUE
;*****************************************************************************************
;;----------------------------------------------------------------------------------------
;;  Return chi-squared result to user
;;----------------------------------------------------------------------------------------

RETURN,chisq
END

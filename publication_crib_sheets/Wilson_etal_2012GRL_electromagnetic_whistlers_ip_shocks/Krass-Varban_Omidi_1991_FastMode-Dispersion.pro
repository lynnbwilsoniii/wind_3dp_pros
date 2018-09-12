;-----------------------------------------------------------------------------------------
; => Constants
;-----------------------------------------------------------------------------------------
f      = !VALUES.F_NAN
d      = !VALUES.D_NAN
epo    = 8.854187817d-12   ; => Permittivity of free space (F/m)
muo    = 4d0*!DPI*1d-7     ; => Permeability of free space (N/A^2 or H/m)
me     = 9.10938291d-31    ; => Electron mass (kg) [2010 value]
mp     = 1.672621777d-27   ; => Proton mass (kg) [2010 value]
ma     = 6.64465675d-27    ; => Alpha-Particle mass (kg) [2010 value]
qq     = 1.602176565d-19   ; => Fundamental charge (C) [2010 value]
kB     = 1.3806488d-23     ; => Boltzmann Constant (J/K) [2010 value]
K_eV   = 1.1604519d4       ; => Factor [Kelvin/eV] [2010 value]
c      = 2.99792458d8      ; => Speed of light in vacuum (m/s)
; => Multiplication factors for plasma frequency calculations [to angular frequency]
wpefac = SQRT(1d6*qq^2/me/epo)
wppfac = SQRT(1d6*qq^2/mp/epo)
;-----------------------------------------------------------------------------------------
; => Shock Parameters
;-----------------------------------------------------------------------------------------
; => Shock normal speed [km/s, spacecraft frame] RHO8
vshn   = [ 391.2, 687.4, 772.4, 641.4]
; => Shock normal speed [km/s, shock frame] RHO8
ushn   = [ 132.3, 401.3, 386.3, 263.6]
; => Alfven speed [km/s]
vaup   = [ 48.44, 64.75,114.45, 66.20]
; => Sound speed [km/s]
csup   = [ 34.04, 54.98, 68.20, 46.87]
; => Shock normal angle [deg] RHO8
the    = [71d0,82d0,82d0,87d0]
; => Upstream solar wind speed [km/s]
vsw_up = [[-293.129,6.851,-1.439],[-484.565,6.580,10.997],[-449.733,41.122,34.701],[-446.427,-9.395,-3.779]]
vmagu  = SQRT(TOTAL(vsw_up^2,1L,/NAN))
; => Upstream average number density [cm^(-3)]
ni_up  = [ 11.18,  6.68,  8.40,  5.31]
; => Shock normal vectors RHO8
shnv   = [[-0.903, 0.168,-0.397],[-0.655,0.040,-0.754],[-0.914,-0.220,-0.341],[-0.865,-0.452,0.218]]
;-----------------------------------------------------------------------------------------
; => Shock Calcs
;-----------------------------------------------------------------------------------------
; => Dot product between shock normal vector and Vsw
n_dot_vsw = my_dot_prod(vsw_up,shnv,/nom)
; => Transformation velocity from SC to shock frame [km/s]
v_trans   = vsw_up - ((REPLICATE(1d0,3) # vshn)*shnv)
vtr_dot_n = my_dot_prod(v_trans,shnv,/nom)
v_trmg    = SQRT(TOTAL(v_trans^2,1L,/NAN))
; => Angle [deg] between shock normal vector and Vsw
thnv      = ACOS(n_dot_vsw/vmagu)*18d1/!DPI
; => Upstream Alfven Mach number
mach_a    = ushn/vaup
; => Upstream average ion plasma frequency [rad/s]
wpp_up    = wppfac[0]*SQRT(ni_up)
; => Upstream average ion inertial length [km]
Li_iner   = (c[0]*1d-3)/wpp_up
; => cosine squared of shock normal angle
cth       = COS(the*!DPI/18d1)^2


PRINT,'; ',vtr_dot_n/vaup
;       -2.5860478      -5.8293128      -3.3401782      -3.8044102

PRINT,'; ',v_trmg/vaup
;        3.6204293       8.1979959       3.8982953       5.0340775

; => 15 < theta_kn < 60
PRINT,'; ',COS([15d0,60d0]*!DPI/18d1)
;       0.96592583      0.50000000



;-----------------------------------------------------------------------------------------
; => Fast mode dispersion relation:
;      [Krass-Varban and Omidi, 1991]
;-----------------------------------------------------------------------------------------
n       = 1000
; => Normalized wave number [unitless]
kk      = DINDGEN(n)*(50d0 - 0d0)/(n - 1) + 0.01

ss      = DBLARR(n,4)
FOR j=0L, 3L DO ss[*,j] = 1d0 + cth[j]*(1d0 + kk^2)

; => Normalized fast mode frequency [rest frame] dispersion relation
wp      = DBLARR(n,4)
FOR j=0L, 3L DO wp[*,j] = kk*SQRT( (ss[*,j] + SQRT(ss[*,j]^2 - 4d0*cth[j]) )/2d0)

; => Normalized shock frame fast mode group speed
vgfast  = DBLARR(n,4)
FOR j=0L, 3L DO BEGIN                               $
  term0       = (1d0 + cth[j]*(1d0 + 2d0*kk^2))   & $
  term1       = SQRT(1d0 + cth[j]*(1d0 + kk^2))   & $
  vgfast[*,j] = term0/term1 - mach_a[j]


; => Normalized fast mode frequency [shock frame] dispersion relation
wp_sh   = DBLARR(n,4)
FOR j=0L, 3L DO wp_sh[*,j] = wp[*,j] + kk*(vtr_dot_n[j]/vaup[j])

; => Normalized fast mode frequency [shock frame]
wp_sh_2 = DBLARR(n,4,2)
FOR j=0L, 3L DO BEGIN                                                        $
  wp_sh_2[*,j,0] = wp[*,j] + kk*(vtr_dot_n[j]/vaup[j])*COS(15d0*!DPI/18d1) & $
  wp_sh_2[*,j,1] = wp[*,j] + kk*(vtr_dot_n[j]/vaup[j])*COS(60d0*!DPI/18d1)


;-----------------------------------------------------------------------------------------
; => Plot Results
;-----------------------------------------------------------------------------------------
WINDOW,0,RETAIN=2,XSIZE=1700,YSIZE=1100

shsuff = ' [shock frame]'
rssuff = ' [rest frame]'
yttl   = '!7x!3'+'/!7X!3'+'!Dci!N'
xttl   = '(k c)/!7x!3'+'!Dpi!N'
xdat   = kk
ydat   = wp
xran   = [  0d0,50d0]
yran0  = [  0d0,810d0]
yran1  = [-60d0, 60d0]
xposi  = xran[1]/7d0
yposi  = yran0[1] - 1d-1*ABS(yran0[1])

pstr   = {NODATA:1,XSTYLE:1,YSTYLE:1,XRANGE:xran,YRANGE:yran0,XMINOR:5,YMINOR:5,$
          XTICKLEN:0.04,YTICKLEN:0.04,YMARGIN:[4.,2.],XMARGIN:[12.,15.],  $
          XTITLE:xttl,YTITLE:yttl[0]+rssuff[0],YLOG:0}

PLOT,xdat,ydat[*,0],_EXTRA=pstr
  OPLOT,xdat,ydat[*,0],COLOR=250,LINESTYLE=0
  OPLOT,xdat,ydat[*,1],COLOR=200,LINESTYLE=1
  OPLOT,xdat,ydat[*,2],COLOR=150,LINESTYLE=2
  OPLOT,xdat,ydat[*,3],COLOR= 50,LINESTYLE=3
  XYOUTS,xposi[0],yposi[0],'1997-12-10',COLOR=250,/DATA
  XYOUTS,xposi[0],yposi[0]- 1d-1*ABS(yran0[1]),'1998-08-26',COLOR=200,/DATA
  XYOUTS,xposi[0],yposi[0]- 2d-1*ABS(yran0[1]),'1998-09-24',COLOR=150,/DATA
  XYOUTS,xposi[0],yposi[0]- 3d-1*ABS(yran0[1]),'2000-02-11',COLOR= 50,/DATA


xdat   = kk
ydat   = wp_sh
yposi  = yran1[1] - 5d0
pstr   = {NODATA:1,XSTYLE:1,YSTYLE:1,XRANGE:xran,YRANGE:yran1,XMINOR:5,YMINOR:5,$
          XTICKLEN:0.04,YTICKLEN:0.04,YMARGIN:[4.,2.],XMARGIN:[12.,15.],  $
          XTITLE:xttl,YTITLE:yttl[0]+shsuff[0],YLOG:0}

PLOT,xdat,ydat[*,0],_EXTRA=pstr
  OPLOT,xdat,ydat[*,0],COLOR=250,LINESTYLE=0
  OPLOT,xdat,ydat[*,1],COLOR=200,LINESTYLE=1
  OPLOT,xdat,ydat[*,2],COLOR=150,LINESTYLE=2
  OPLOT,xdat,ydat[*,3],COLOR= 50,LINESTYLE=3
  OPLOT,xran,[0.,0.],LINESTYLE=1
  XYOUTS,xposi[0],yposi[0]- 0d0,'1997-12-10',COLOR=250,/DATA
  XYOUTS,xposi[0],yposi[0]- 5d0,'1998-08-26',COLOR=200,/DATA
  XYOUTS,xposi[0],yposi[0]- 1d1,'1998-09-24',COLOR=150,/DATA
  XYOUTS,xposi[0],yposi[0]-15d0,'2000-02-11',COLOR= 50,/DATA

fname  = 'magnetosonic_dispersion_shock-frame_whistler-precursor-study'
suffx  = '_wWci-vs-Li'
popen,fname[0]+suffx[0],/LAND
  PLOT,xdat,ydat[*,0],_EXTRA=pstr
    OPLOT,xdat,ydat[*,0],COLOR=250,LINESTYLE=0
    OPLOT,xdat,ydat[*,1],COLOR=200,LINESTYLE=1
    OPLOT,xdat,ydat[*,2],COLOR=150,LINESTYLE=2
    OPLOT,xdat,ydat[*,3],COLOR= 50,LINESTYLE=3
    OPLOT,xran,[0.,0.],LINESTYLE=1
    XYOUTS,xposi[0],yposi[0]- 0d0,'1997-12-10',COLOR=250,/DATA
    XYOUTS,xposi[0],yposi[0]- 5d0,'1998-08-26',COLOR=200,/DATA
    XYOUTS,xposi[0],yposi[0]- 1d1,'1998-09-24',COLOR=150,/DATA
    XYOUTS,xposi[0],yposi[0]-15d0,'2000-02-11',COLOR= 50,/DATA
pclose


shsuff = ' [shock frame]'
rssuff = ' [rest frame]'
yttl   = '!7x!3'+'/!7X!3'+'!Dci!N'
xttl   = '(k c)/!7x!3'+'!Dpe!N'
xdat   = kk/SQRT(mp[0]/me[0])
ydat   = wp_sh
;ydat   = wp_sh_2
xran   = [  0d0,50d0]/SQRT(mp[0]/me[0])
xposi  = xran[1]/7d0
yran1  = [-60d0, 60d0]
yposi  = yran1[1] - 5d0

pstr   = {NODATA:1,XSTYLE:1,YSTYLE:1,XRANGE:xran,YRANGE:yran1,XMINOR:5,YMINOR:5,$
          XTICKLEN:0.04,YTICKLEN:0.04,YMARGIN:[4.,2.],XMARGIN:[12.,15.],  $
          XTITLE:xttl,YTITLE:yttl[0]+shsuff[0],YLOG:0}

PLOT,xdat,ydat[*,0],_EXTRA=pstr
  OPLOT,xdat,ydat[*,0],COLOR=250,LINESTYLE=0
  OPLOT,xdat,ydat[*,1],COLOR=200,LINESTYLE=1
  OPLOT,xdat,ydat[*,2],COLOR=150,LINESTYLE=2
  OPLOT,xdat,ydat[*,3],COLOR= 50,LINESTYLE=3
  OPLOT,xran,[0.,0.],LINESTYLE=1
  XYOUTS,xposi[0],yposi[0]- 0d0,'1997-12-10',COLOR=250,/DATA
  XYOUTS,xposi[0],yposi[0]- 5d0,'1998-08-26',COLOR=200,/DATA
  XYOUTS,xposi[0],yposi[0]- 1d1,'1998-09-24',COLOR=150,/DATA
  XYOUTS,xposi[0],yposi[0]-15d0,'2000-02-11',COLOR= 50,/DATA

fname  = 'magnetosonic_dispersion_shock-frame_whistler-precursor-study'
suffx  = '_wWci-vs-Le'
popen,fname[0]+suffx[0],/LAND
  PLOT,xdat,ydat[*,0],_EXTRA=pstr
    OPLOT,xdat,ydat[*,0],COLOR=250,LINESTYLE=0
    OPLOT,xdat,ydat[*,1],COLOR=200,LINESTYLE=1
    OPLOT,xdat,ydat[*,2],COLOR=150,LINESTYLE=2
    OPLOT,xdat,ydat[*,3],COLOR= 50,LINESTYLE=3
    OPLOT,xran,[0.,0.],LINESTYLE=1
    XYOUTS,xposi[0],yposi[0]- 0d0,'1997-12-10',COLOR=250,/DATA
    XYOUTS,xposi[0],yposi[0]- 5d0,'1998-08-26',COLOR=200,/DATA
    XYOUTS,xposi[0],yposi[0]- 1d1,'1998-09-24',COLOR=150,/DATA
    XYOUTS,xposi[0],yposi[0]-15d0,'2000-02-11',COLOR= 50,/DATA
pclose



shsuff = ' [shock frame]'
yttl   = 'V!Dgr!N'+'/V!DA!N'
xttl   = '(k c)/!7x!3'+'!Dpe!N'
xdat   = kk/SQRT(mp[0]/me[0])
ydat   = vgfast
xran   = [  0d0,50d0]/SQRT(mp[0]/me[0])
xposi  = xran[1]/7d0
yran1  = [-10d0, 20d0]
yposi  = yran1[1] - 1d-1*ABS(yran1[1])

pstr   = {NODATA:1,XSTYLE:1,YSTYLE:1,XRANGE:xran,YRANGE:yran1,XMINOR:5,YMINOR:5,$
          XTICKLEN:0.04,YTICKLEN:0.04,YMARGIN:[4.,2.],XMARGIN:[12.,15.],  $
          XTITLE:xttl,YTITLE:yttl[0]+shsuff[0],YLOG:0}

PLOT,xdat,ydat[*,0],_EXTRA=pstr
  OPLOT,xdat,ydat[*,0],COLOR=250,LINESTYLE=0
  OPLOT,xdat,ydat[*,1],COLOR=200,LINESTYLE=1
  OPLOT,xdat,ydat[*,2],COLOR=150,LINESTYLE=2
  OPLOT,xdat,ydat[*,3],COLOR= 50,LINESTYLE=3
  OPLOT,xran,[0.,0.],LINESTYLE=1
  XYOUTS,xposi[0],yposi[0]- 0d0,'1997-12-10',COLOR=250,/DATA
  XYOUTS,xposi[0],yposi[0]- 1d-1*ABS(yran1[1]),'1998-08-26',COLOR=200,/DATA
  XYOUTS,xposi[0],yposi[0]- 2d-1*ABS(yran1[1]),'1998-09-24',COLOR=150,/DATA
  XYOUTS,xposi[0],yposi[0]- 3d-1*ABS(yran1[1]),'2000-02-11',COLOR= 50,/DATA


;-----------------------------------------------------------------------------------------
; => Example Plot
;-----------------------------------------------------------------------------------------
shsuff = ' [shock frame]'
yttl   = '!7x!3'+'/!7X!3'+'!Dci!N'
xttl   = '(k c)/!7x!3'+'!Dpe!N'
xdat   = kk/SQRT(mp[0]/me[0])
ydat   = wp_sh
xran   = [  0d0,50d0]/SQRT(mp[0]/me[0])
yran1  = [-70d0, 70d0]
xposi  = xran[0] - xran[1]/25d0
yposi  = yran1[1]/5d0
; => Define phase standing value as closest to zero in curve
minph  = MIN(ABS(wp_sh[*,1]),/NAN,ln)
phstnd = xdat[ln]
PRINT,';',phstnd[0]
;      0.96268150
; => Define group standing value as minimum in curve
mingr  = MIN(wp_sh[*,1],/NAN,ln)
grstnd = xdat[ln]
PRINT,';',grstnd[0]
;      0.48846555

pstr   = {NODATA:1,XSTYLE:13,YSTYLE:13,XRANGE:xran,YRANGE:yran1,XMINOR:5,YMINOR:5,$
          XTICKLEN:0.0,YTICKLEN:0.0,YMARGIN:[4.,2.],XMARGIN:[15.,15.],  $
          XTITLE:xttl,YTITLE:yttl[0]+shsuff[0],YLOG:0}

PLOT,xdat,ydat[*,0],_EXTRA=pstr
  OPLOT,xdat,ydat[*,1],COLOR=200,LINESTYLE=3
  ARROW,xran[0],0.,xran[1],0.,/DATA,/SOLID
  ARROW,xran[0],yran1[0],xran[0],yran1[1],/DATA,/SOLID
  XYOUTS,xran[1]*6d0/7d0,-10.,xttl[0],/DATA
  XYOUTS,xposi[0],yposi[0],yttl[0]+shsuff[0],/DATA,ORIENTATION=90.
  OPLOT,[phstnd[0],phstnd[0]],yran1,LINESTYLE=1  ; => phase standing point
  OPLOT,[grstnd[0],grstnd[0]],yran1,LINESTYLE=1  ; => group standing point


fname  = 'example_magnetosonic_dispersion_shock-frame_phase-group-standing-lines'
suffx  = '_wWci-vs-Le'
popen,fname[0]+suffx[0],/LAND
  PLOT,xdat,ydat[*,0],_EXTRA=pstr
    OPLOT,xdat,ydat[*,1],COLOR=200,LINESTYLE=3
    ARROW,xran[0],0.,xran[1],0.,/DATA,/SOLID
    ARROW,xran[0],yran1[0],xran[0],yran1[1],/DATA,/SOLID
    XYOUTS,xran[1]*6d0/7d0,-10.,xttl[0],/DATA
    XYOUTS,xposi[0],yposi[0],yttl[0]+shsuff[0],/DATA,ORIENTATION=90.
    OPLOT,[phstnd[0],phstnd[0]],yran1,LINESTYLE=1  ; => phase standing point
    OPLOT,[grstnd[0],grstnd[0]],yran1,LINESTYLE=1  ; => group standing point
pclose

;-----------------------------------------------------------------------------------------
; => Define phase/group standing point for each event
;-----------------------------------------------------------------------------------------
n       = 5000
; => Normalized wave number [unitless]
kk      = DINDGEN(n)*(500d0 - 0d0)/(n - 1) + 0.1

ss      = DBLARR(n,4)
FOR j=0L, 3L DO ss[*,j] = 1d0 + cth[j]*(1d0 + kk^2)

; => Normalized fast mode frequency [rest frame] dispersion relation
wp      = DBLARR(n,4)
FOR j=0L, 3L DO wp[*,j] = kk*SQRT( (ss[*,j] + SQRT(ss[*,j]^2 - 4d0*cth[j]) )/2d0)

; => Normalized shock frame fast mode group speed
vgfast  = DBLARR(n,4)
FOR j=0L, 3L DO BEGIN                               $
  term0       = (1d0 + cth[j]*(1d0 + 2d0*kk^2))   & $
  term1       = SQRT(1d0 + cth[j]*(1d0 + kk^2))   & $
  vgfast[*,j] = term0/term1 - mach_a[j]


; => Normalized fast mode frequency [shock frame] dispersion relation
wp_sh   = DBLARR(n,4)
FOR j=0L, 3L DO wp_sh[*,j] = wp[*,j] + kk*(vtr_dot_n[j]/vaup[j])

; => Normalized fast mode frequency [shock frame]
wp_sh_2 = DBLARR(n,4,2)
FOR j=0L, 3L DO BEGIN                                                        $
  wp_sh_2[*,j,0] = wp[*,j] + kk*(vtr_dot_n[j]/vaup[j])*COS(15d0*!DPI/18d1) & $
  wp_sh_2[*,j,1] = wp[*,j] + kk*(vtr_dot_n[j]/vaup[j])*COS(60d0*!DPI/18d1)





xdat   = kk/SQRT(mp[0]/me[0])
tdates = ['1997-12-10','1998-08-26','1998-09-24','2000-02-11']
for j=0l, 3l do begin                      $
  minph  = MIN(ABS(wp_sh[*,j]),/NAN,ln)  & $
  phstnd = xdat[ln]                      & $
  PRINT,';',phstnd[0],'  For '+tdates[j]
; => Define phase standing value as closest to zero in curve
;      0.17039394  For 1997-12-10
;      0.96167755  For 1998-08-26
;      0.53452445  For 1998-09-24
;       1.6362527  For 2000-02-11


for j=0l, 3l do begin                      $
  mingr  = MIN(wp_sh[*,j],/NAN,ln)       & $
  grstnd = xdat[ln]                      & $
  PRINT,';',grstnd[0],'  For '+tdates[j]
; => Define group standing value as minimum in curve
;     0.088697991  For 1997-12-10
;      0.48784105  For 1998-08-26
;      0.27543159  For 1998-09-24
;      0.84263488  For 2000-02-11

;-----------------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------------



; => Find phase standing and group standing points for 1998-08-26 event
zero = REPLICATE(0d0,n)

xx0  = kk/SQRT(mp[0]/me[0])
xx1  = kk/SQRT(mp[0]/me[0])
yy0  = zero
yy1  = wp_sh[*,1]
test = curveint(xx0,yy0,xx1,yy1)
PRINT,';',test[0]
; => (k c)/w_pe value of phase standing whistler for 1998-08-26 event
;      0.96271484


xx0  = kk/SQRT(mp[0]/me[0])
xx1  = kk/SQRT(mp[0]/me[0])
yy0  = zero
yy1  = wp_sh_2[*,1]
test = curveint(xx0,yy0,xx1,yy1)
PRINT,';',test[0]
; => (k c)/w_pe value of phase standing whistler for 1998-08-26 event [used theta_kn]
;      0.92887939

xx0  = kk/SQRT(mp[0]/me[0])
xx1  = kk/SQRT(mp[0]/me[0])
yy0  = zero
yy1  = vgfast[*,1]
test = curveint(xx0,yy0,xx1,yy1)
PRINT,';',test[0]
; => (k c)/w_pe value of group standing whistler for 1998-08-26 event [used theta_kn]
;      0.51896095

































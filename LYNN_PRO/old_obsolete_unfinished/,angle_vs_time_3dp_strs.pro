;+
;*****************************************************************************************
;
;  FUNCTION :   angle_vs_time_3dp_strs.pro
;  PURPOSE  :   Plots the azimuthal and polar angles [GSE or FAC] coordinates of an
;                 input data structure [from get_??.pro] versus the time from 
;                 the beginning of the data sample.
;                 dat.PHI   = azimuthal angles
;                 dat.THETA = polar     angles
;
;  CALLED BY:   
;               NA
;
;  CALLS:
;               dat_3dp_str_names.pro
;               xyz_to_polar.pro
;               dat_3dp_energy_bins.pro
;               velocity.pro
;               sphere_to_cart.pro
;               cal_rot.pro
;               cart_to_sphere.pro
;               time_string.pro
;               file_name_times.pro
;               popen.pro
;               pclose.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               DAT      :  A 3d data structure such as those gotten from get_??.pro
;                             ?? = e[l,h], e[l,h]b, p[l,h], p[l,h]b, sf[ ,b,t], so[ ,b,t]
;
;  EXAMPLES:    
;               ; => know that spin rate = 116.06690 +/- 0.0050694072 deg/s
;               ;      for 1998-08-26  [Avg. +/- Std. Dev. from 911 points]
;               sprate = 116.06690
;               dat    = get_el(time_double('1998-08-26/00:00:00'))
;               angle_vs_time_3dp_strs,dat,SPRATE=sprate
;
;  KEYWORDS:    
;               SPRATE   :  Scalar defining the spacecraft spin rate at the time of the
;                             data structure in question [degrees per second]
;               FSAVE    :  If set, program will save plot as to post script
;               NOERR    :  If set, program will not plot error bars
;               KILLN    :  If set, program will set "bad" angle bins to NaNs, thus
;                             not plotting them
;                             ["bad" = dat.DATA EQ 0. or NaN]
;               VBPLANE  :  If set, program plots angles with respect to new coordinate
;                             system defined by:
;                             X'         = B-field direction
;                             X'Y'-Plane = plane containing Vsw AND B
;                             Z'         = X' x Y'
;                             [Transforms into solar wind frame 1st]
;               VTIME    :  Scalar (or array) unix time defining a time of interest
;                             during the duration of the data sample
;                             [SPRATE must be set for this to work]
;               VCOLS    :  Color table values associated with VTIME
;                             [MUST have same # of elements as VTIME for this to work]
;
;   CHANGED:  1)  NA [MM/DD/YYYY   v1.0.0]
;
;   NOTES:      
;               1)  Determine the spacecraft spin rate (deg/s) prior to running this
;                     routine if you want to know times associated with specific
;                     angle bins
;
;   CREATED:  06/17/2011
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  06/17/2011   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

PRO angle_vs_time_3dp_strs,dat,SPRATE=sprate,FSAVE=fsave,NOERR=noerr,KILLN=killn,$
                           VBPLANE=vbpln,VTIME=vtime,VCOLS=vcols

;-----------------------------------------------------------------------------------------
; => Define default parameters
;-----------------------------------------------------------------------------------------
f      = !VALUES.F_NAN
d      = !VALUES.D_NAN
; => Check input
IF (SIZE(dat,/TYPE) NE 8) THEN RETURN

IF KEYWORD_SET(sprate) THEN sp = 1 ELSE sp = 0
IF KEYWORD_SET(noerr)  THEN no = 0 ELSE no = 1
IF KEYWORD_SET(killn)  THEN kl = 1 ELSE kl = 0
IF KEYWORD_SET(vbpln)  THEN vb = 1 ELSE vb = 0
IF KEYWORD_SET(vtime)  THEN vt = 1 ELSE vt = 0
IF    (vt AND sp)      THEN vt = 1 ELSE vt = 0
IF KEYWORD_SET(vcols)  THEN vc = 1 ELSE vc = 0
;-----------------------------------------------------------------------------------------
; => Make sure name is in the correct format
;-----------------------------------------------------------------------------------------
strns    = dat_3dp_str_names(dat)
tname    = strns.LC                ; => e.g. 'Pesa High Burst'
pname    = STRUPCASE(strns.SN)
fpref    = pname[0]+'_Angular_vs_'
;-----------------------------------------------------------------------------------------
; => Define relevant parameters
;-----------------------------------------------------------------------------------------
phi      = dat.PHI         ; => Azimuthal angle (deg) in GSE coordinates
theta    = dat.THETA       ; => Polar     angle (deg) in GSE coordinates
; => Define lower/upper bounds on these angles from angular uncertainties
phi_low  = phi - dat.DPHI
phi_upp  = phi + dat.DPHI
the_low  = theta - dat.DTHETA
the_upp  = theta + dat.DTHETA
; => Define magnetic field and solar wind velocity at the time of this structure
magf     = dat.MAGF
vsw      = dat.VSW
; => Redefine these values as polar angles
xyz_to_polar,magf,THETA=bthe,PHI=bphi,/PH_0_360
xyz_to_polar,vsw, THETA=vthe,PHI=vphi,/PH_0_360
; => Define data dimensions
sz       = SIZE(phi,/DIMENSIONS)
neb      = sz[0]           ; => # of center energy bins used for energy sweep analyzer
ned      = sz[1]           ; => # of data points per energy bin
;-----------------------------------------------------------------------------------------
; => Remove bad bins
;-----------------------------------------------------------------------------------------
IF KEYWORD_SET(kl) THEN BEGIN
  ; => remove bad data bins if they exist
  data      = dat.DATA
  test      = (data LE 0.) OR (FINITE(data) EQ 0)
  bad       = WHERE(test,bd,COMPLEMENT=good,NCOMPLEMENT=gd)
  IF (bd GT 0) THEN BEGIN
    suffx     = '_no-bad-bins'
    bind      = ARRAY_INDICES(test,bad)
    ; => Kill bad data points
    phi[bind[0,*],bind[1,*]]     = f
    theta[bind[0,*],bind[1,*]]   = f
    phi_low[bind[0,*],bind[1,*]] = f
    phi_upp[bind[0,*],bind[1,*]] = f
    the_low[bind[0,*],bind[1,*]] = f
    the_upp[bind[0,*],bind[1,*]] = f
  ENDIF ELSE BEGIN
    suffx     = '_all-bins'
  ENDELSE
ENDIF ELSE BEGIN
  suffx     = '_all-bins'
ENDELSE
;-----------------------------------------------------------------------------------------
; => Determine Coordinates
;-----------------------------------------------------------------------------------------
IF KEYWORD_SET(vb) THEN BEGIN
  my_en     = dat_3dp_energy_bins(dat)
  vmag      = velocity(dat.ENERGY,dat.MASS,/TRUE)
  the0      = theta
  ph0       = phi
  dtheta    = dat.DTHETA
  dphi      = dat.DPHI
  ; => convert to cartesian
  sphere_to_cart,vmag,the0,ph0,vx,vy,vz
  mvel      = [[[vx]],[[vy]],[[vz]]]           ; => [neb,ned,3] element array of velocities
  IF (STRMID(pname[0],0L,2L) NE 'PL') THEN BEGIN
    ; => convert into solar wind frame
    FOR j=0L, 2L DO BEGIN
      mvel[*,*,j] = mvel[*,*,j] - vsw[j]
    ENDFOR
    ; => Define new vmag
    vmag  = SQRT(TOTAL(mvel^2,3,/NAN))
    suffx = suffx[0]+'_Vsw-Frame_FAC'
    ttext = '[FAC, Vsw-Frame]'
  ENDIF ELSE BEGIN
    suffx = suffx[0]+'_FAC'
    ttext = '[FAC, SC-Frame]'
  ENDELSE
  mrot      = cal_rot(magf,vsw)
  ; => Rotate Vsw and B-field
  magf      = REFORM(mrot ## magf)
  vsw       = REFORM(mrot ## vsw )
  ; => Calculate angles of new Vsw and B-field
  xyz_to_polar,magf,THETA=bthe,PHI=bphi,/PH_0_360
  xyz_to_polar,vsw, THETA=vthe,PHI=vphi,/PH_0_360
  ; => Rotate particle velocities
  nvel      = DBLARR(neb,ned,3L)
  FOR j=0L, neb - 1L DO BEGIN
    tempv        = REFORM(mvel[j,*,*])  # mrot
    nvel[j,*,*]  = tempv
  ENDFOR
  ; => Convert back into spherical coordinates to define new angles
  cart_to_sphere,nvel[*,*,0],nvel[*,*,1],nvel[*,*,2],vmag,the1,phi1,/PH_0_360
  ; => Redefine angles and limits
  phi       = phi1
  theta     = the1
  ; => Redefine limits
  phi_low   = phi - dphi
  phi_upp   = phi + dphi
  the_low   = theta - dtheta
  the_upp   = theta + dtheta
ENDIF ELSE BEGIN
  suffx     = suffx[0]+'_GSE'
  ttext     = '[GSE, SC-Frame]'
ENDELSE
; => Define strings for [phi,theta] associated with Vsw and B
vsw_str  = STRTRIM(STRING(FORMAT='(f10.1)',[vphi,vthe]),2L)
mag_str  = STRTRIM(STRING(FORMAT='(f10.1)',[bphi,bthe]),2L)

;-----------------------------------------------------------------------------------------
; => Define plot relevant parameters
;-----------------------------------------------------------------------------------------
unix     = dat.TIME                         ; => Unix time at start of sample
scet     = time_string(unix,PREC=0)         ; => SCET [e.g. 1998-08-26/06:40:21]
fnm      = file_name_times(scet,PREC=0)
sfname   = fnm.F_TIME[0]                    ; => e.g. 1998-08-26_0640x21
ttle0    = tname[0]+' for '+scet[0]         ; => e.g. 'Pesa High Burst for 1998-08-26/06:40:21'

IF KEYWORD_SET(sp) THEN BEGIN
  fname     = fpref[0]+'Time_'+sfname[0]
  xttl      = 'Time from Start of Dist. (s)'
  ttle      = 'Angle '+ttext[0]+' versus Sample Time from Start'
  IF (STRMID(pname[0],0L,2L) NE 'PL') THEN BEGIN
    ; => Use spin rate to determine time stamps for each [phi,theta] data point
    del_t_phi = dat.PHI/sprate[0]
    ; => Define Unix times associated with these values
    unx_t_phi = unix[0] + del_t_phi
    ; => Normalize to start time  [sometimes phi[0] < 0.0]
    delt_phin = unx_t_phi - MIN(unx_t_phi,/NAN)
  ENDIF ELSE BEGIN
    ; => Determine times for PESA Low
    diff_t    = dat.END_TIME[0] - dat.TIME[0]
    dtt       = TOTAL(dat.DT,/NAN)           ; => Total time detector takes data
    IF (dtt[0] LT diff_t[0]) THEN BEGIN
      dt        = TOTAL(dat.DT,2L,/NAN)/TOTAL(FINITE(dat.DT),2L)
      delt_phin = REPLICATE(0d0,neb,ned)
      dtmx      = 0d0
      FOR j=0L, ned - 1L DO BEGIN
        dt0             = dt + dtmx[0]
        delt_phin[*,j] += dt0
        dtmx           += TOTAL(dt,/NAN) + dt[0]
      ENDFOR
      diff    = diff_t[0] - MAX(delt_phin,/NAN)
      IF (diff[0] GT 0) THEN BEGIN
        ; => Shift each energy sweep uniformly to account for time gap
        fact = diff[0]/(ned - 1L)
        FOR j=0L, ned - 1L DO delt_phin[*,j] += fact[0]
      ENDIF
    ENDIF ELSE BEGIN
      delt_phin = REPLICATE(1d0,neb) # (DINDGEN(ned)*diff_t/(ned - 1L))
    ENDELSE
  ENDELSE
  IF KEYWORD_SET(vt) THEN BEGIN
    vert_t = REFORM(vtime) - MIN(unix[0],/NAN)
    good   = WHERE(vert_t GE 0.,gd)
    IF (gd GT 0) THEN vert_t = vert_t[good] ELSE vert_t = d
    IF (gd EQ 0) THEN vt = 0
  ENDIF ELSE BEGIN
    vert_t = d
  ENDELSE
  xra       = [dat.TIME[0],dat.END_TIME[0]] - dat.TIME[0]
  xra[1]   *= 1.05
ENDIF ELSE BEGIN
  fname     = fpref[0]+'Index_'+sfname[0]
  ttle      = 'Angle '+ttext[0]+' versus Angle-Index'
  xttl      = 'Index from Start at Zero'
  ; => Define Index associated with phi values
  delt_phin = DINDGEN(neb,ned)
  vert_t    = d
  xra       = [0,1d0 + MAX(delt_phin,/NAN)]
ENDELSE
IF KEYWORD_SET(vc)  THEN nvc = N_ELEMENTS(vcols)  ELSE nvc = 1
IF KEYWORD_SET(vt)  THEN nvt = N_ELEMENTS(vert_t) ELSE nvt = 1
IF (nvc NE nvt) THEN BEGIN
  vc   = 0
  vcol = LINDGEN(nvt)*(250L - 30L)/(nvt - 1L) + 30L
ENDIF ELSE BEGIN
  vcol = LINDGEN(nvc)*(250L - 30L)/(nvc - 1L) + 30L
ENDELSE
vcol = REVERSE(ROUND((vcol*1e3)^(2e0/3e0)/16e0))
;-----------------------------------------------------------------------------------------
; => Setup plot structures
;-----------------------------------------------------------------------------------------
pmulti   = !P.MULTI
!P.MULTI = [0,1,2]
yttlph   = 'Azimuthal Angle (deg)'+'!C'+ttext[0]
yttlth   = 'Polar Angle (deg)'+'!C'+ttext[0]
yra_ph   = [(-10. < MIN(phi,/NAN)),(370. > MAX(phi,/NAN))]
yra_th   = [-100.,100.]
; => Define a color array for different energy bins
cols     = LINDGEN(neb)*(250L - 30L)/(neb - 1L) + 30L
; => Define plot structures
; => PHI
pstrph   = {YRANGE:yra_ph,XTITLE:xttl,YTITLE:yttlph,NODATA:1,XSTYLE:1,YSTYLE:1,$
            XRANGE:xra,XMINOR:11L,YMINOR:11L,TITLE:ttle}
; => THETA
pstrth   = {YRANGE:yra_th,XTITLE:xttl,YTITLE:yttlth,NODATA:1,XSTYLE:1,YSTYLE:1,$
            XRANGE:xra,XMINOR:11L,YMINOR:11L,TITLE:ttle0}
;-----------------------------------------------------------------------------------------
; => Plot data
;-----------------------------------------------------------------------------------------
IF KEYWORD_SET(fsave) THEN BEGIN
  popen,fname[0]+suffx[0],/LAND
ENDIF

; => PHI
  PLOT,delt_phin,phi,_EXTRA=pstrph
    OPLOT,xra,[bphi,bphi],COLOR=30
    OPLOT,xra,[vphi,vphi],COLOR=70
    OPLOT,delt_phin,phi,PSYM=4
    ; => Plot error bars
    IF KEYWORD_SET(no) THEN BEGIN
      FOR j=0L, neb - 1L DO BEGIN
        ERRPLOT,delt_phin[j,*],phi_low[j,*],phi_upp[j,*],/DATA,COLOR=cols[j]
      ENDFOR
    ENDIF
    ; => Overplot the time of interest
    FOR j=0L, nvt - 1L DO BEGIN
      OPLOT,[vert_t[j],vert_t[j]],yra_ph,THICK=3.,COLOR=vcol[j]
    ENDFOR
    ; => Define the horizontal lines
    XYOUTS,0.25,330.,/DATA,'B-Phi = '+mag_str[0]+' deg',COLOR=30
    XYOUTS,0.25,300.,/DATA,'Vsw-Phi = '+vsw_str[0]+' deg',COLOR=70
; => THETA
  PLOT,delt_phin,theta,_EXTRA=pstrth
    OPLOT,xra,[bthe,bthe],COLOR=30
    OPLOT,xra,[vthe,vthe],COLOR=70
    OPLOT,delt_phin,theta,PSYM=4
    ; => Plot error bars
    IF KEYWORD_SET(no) THEN BEGIN
      FOR j=0L, neb - 1L DO BEGIN
        ERRPLOT,delt_phin[j,*],the_low[j,*],the_upp[j,*],/DATA,COLOR=cols[j]
      ENDFOR
    ENDIF
    ; => Overplot the time of interest
    FOR j=0L, nvt - 1L DO BEGIN
      OPLOT,[vert_t[j],vert_t[j]],yra_th,THICK=3.,COLOR=vcol[j]
    ENDFOR
    ; => Define the horizontal lines
    XYOUTS,0.25,90.,/DATA,'B-Theta = '+mag_str[1]+' deg',COLOR=30
    XYOUTS,0.25,60.,/DATA,'Vsw-Theta = '+vsw_str[1]+' deg',COLOR=70

IF KEYWORD_SET(fsave) THEN BEGIN
  pclose
ENDIF
;-----------------------------------------------------------------------------------------
; => Return plot state to original form
;-----------------------------------------------------------------------------------------
!P.MULTI = pmulti

RETURN
END
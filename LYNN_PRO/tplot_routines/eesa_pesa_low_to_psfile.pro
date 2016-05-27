;+
;*****************************************************************************************
;
;  FUNCTION :   eesa_pesa_low_to_psfile.pro
;  PURPOSE  :   This program plots the various quantities produced by the program
;                 eesa_pesa_low_to_tplot.pro and saves them as PS files.
;
;  CALLED BY:   
;               eesa_pesa_low_to_tplot.pro
;
;  CALLS:
;               tnames.pro
;               options.pro
;               get_data.pro
;               time_double.pro
;               my_time_string.pro
;               popen.pro
;               tplot.pro
;               pclose.pro
;
;  REQUIRES:    
;               TPLOT variables created by pesa_low_moment_calibrate.pro and/or
;                 moments_array_3dp.pro
;
;  INPUT:
;               NA
;
;  EXAMPLES:    
;               NA
;
;  KEYWORDS:    
;               DATE      :  [string] 'MMDDYY' [MM=month, DD=day, YY=year]
;               TRANGE    :  [Double] 2-Element array specifying the time range 
;                              of the data to plot for PS files [Unix time]
;               NOMSSG    :  If set, TPLOT will NOT print out the index and TPLOT handle
;                              of the variables being plotted
;
;   CHANGED:  1)  NA [MM/DD/YYYY   v1.0.0]
;
;   NOTES:      
;               1)  This program is meant to be specifically called by 
;                     eesa_pesa_low_to_tplot.pro
;
;   CREATED:  09/29/2009
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  09/29/2009   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

PRO eesa_pesa_low_to_psfile,DATE=date,TRANGE=trange,NOMSSG=nom

;*****************************************************************************************
ex_start = SYSTIME(1)
;*****************************************************************************************
;-----------------------------------------------------------------------------------------
; => Format TPLOT options
;-----------------------------------------------------------------------------------------
nnw = tnames()
options,nnw,"YSTYLE",1
options,nnw,"PANEL_SIZE",2.
options,nnw,'XMINOR',5
options,nnw,'XTICKLEN',0.04
;-----------------------------------------------------------------------------------------
; => Save plots to PS files if desired
;-----------------------------------------------------------------------------------------
magf_check = tnames('WIND_*(GSE,nT)') NE ''
IF (magf_check[0]) THEN BEGIN
  ; => HTR B-field data
  magf_names = tnames('WIND_*(GSE,nT)')
  magf_fname = 'HTR-MFI_'
ENDIF ELSE BEGIN 
  ; => 3s B-field data
  magf_names = tnames('wi_B3*')
  magf_fname = 'MFI3s_'
ENDELSE
IF (magf_names[0] EQ '') THEN magf_fname = 'Null-MagF_'
; => Check if near a shock
idens_check = tnames('N_i3*') NE ''
IF (idens_check) THEN idname = 'N_i3' ELSE idname = 'N_i2'
ion_names = [tnames(idname),tnames(['T_i2','Ti_para','Ti_perp','Ti_anisotropy'])]
gion      = WHERE(ion_names NE '',gi)
IF (gi GT 0) THEN ion_names = ion_names[gion] ELSE ion_names = ''
;-----------------------------------------------------------------------------------------
; => Define the base TPLOT names of each type of data
;-----------------------------------------------------------------------------------------
tavg_base = 'T_avg_'
vthm_base = 'V_Therm_'
dens_base = 'N_'
vels_base = 'Velocity_'
tpar_base = 'Tpara_'
tper_base = 'Tperp_'
tani_base = 'Tanisotropy_'
; => Define the base FILE names of each type of data
tavg_basf = 'Tavg'
vthm_basf = 'VTherm'
dens_basf = 'N'
vels_basf = 'Vels'
tpar_basf = 'Tpara'
tper_basf = 'Tperp'
tani_basf = 'Tanis'
; => Define the default FILE name suffixes of each type of data
fn_tavg_n = ''
fn_vthm_n = ''
fn_dens_n = ''
fn_vels_n = ''
fn_tpar_n = ''
fn_tper_n = ''
fn_tani_n = ''
;-----------------------------------------------------------------------------------------
; => Define the TPLOT names of each type of data
;-----------------------------------------------------------------------------------------
chratio_n = tnames(['Tpara_Core-Halo_sw','Tperp_Core-Halo_sw'])
el_tavg_n = tnames(tavg_base+'*')
el_vthm_n = tnames(vthm_base+'*')
el_dens_n = tnames(dens_base+'*')
el_vels_n = tnames(vels_base+'*')
el_tpar_n = tnames(tpar_base+'*')
el_tper_n = tnames(tper_base+'*')
el_tani_n = tnames(tani_base+'*')
; => Get rid of overlapping TPLOT handles
bad       = (STRPOS(el_tpar_n,'Tpara_Core') GE 0)
bposi     = WHERE(bad,bb,COMPLEMENT=gposi,NCOMPLEMENT=gg)
IF (gg GT 0) THEN BEGIN
  el_tpar_n = el_tpar_n[gposi]
ENDIF ELSE el_tpar_n = ''
bad       = (STRPOS(el_tper_n,'Tperp_Core') GE 0)
bposi     = WHERE(bad,bb,COMPLEMENT=gposi,NCOMPLEMENT=gg)
IF (gg GT 0) THEN BEGIN
  el_tper_n = el_tper_n[gposi]
ENDIF ELSE el_tper_n = ''
bad       = (STRPOS(el_dens_n,'N_i') GE 0)
bposi     = WHERE(bad,bb,COMPLEMENT=gposi,NCOMPLEMENT=gg)
IF (gg GT 0) THEN BEGIN
  el_dens_n = el_dens_n[gposi]
ENDIF ELSE el_dens_n = ''
;-----------------------------------------------------------------------------------------
; => Define the FILE name suffixes of each type of data
; => Definitions:
;      SHF  :  SHock Frame
;      SCF  :  SpaceCraft Frame
;      SWF  :  Solar Wind Frame
;-----------------------------------------------------------------------------------------
def_suff  = ['elSCF','elSWF','ceSWF','heSWF']
sc_suff   = '_sc'
sw_suff   = '_sw'
;-----------------------------------------------------------------------------------------
; => Make sure we have the TPLOT variables available
;-----------------------------------------------------------------------------------------
tavg_els  = [WHERE(STRPOS(el_tavg_n,sc_suff) GE 0),WHERE(STRPOS(el_tavg_n,sw_suff) GE 0)]
vthm_els  = [WHERE(STRPOS(el_vthm_n,sc_suff) GE 0),WHERE(STRPOS(el_vthm_n,sw_suff) GE 0)]
dens_els  = [WHERE(STRPOS(el_dens_n,sc_suff) GE 0),WHERE(STRPOS(el_dens_n,sw_suff) GE 0)]
vels_els  = [WHERE(STRPOS(el_vels_n,sc_suff) GE 0),WHERE(STRPOS(el_vels_n,sw_suff) GE 0)]
tpar_els  = [WHERE(STRPOS(el_tpar_n,sc_suff) GE 0),WHERE(STRPOS(el_tpar_n,sw_suff) GE 0)]
tper_els  = [WHERE(STRPOS(el_tper_n,sc_suff) GE 0),WHERE(STRPOS(el_tper_n,sw_suff) GE 0)]
tani_els  = [WHERE(STRPOS(el_tani_n,sc_suff) GE 0),WHERE(STRPOS(el_tani_n,sw_suff) GE 0)]

tavg_gels = WHERE(tavg_els GE 0,gtavg)
vthm_gels = WHERE(vthm_els GE 0,gvthm)
dens_gels = WHERE(dens_els GE 0,gdens)
vels_gels = WHERE(vels_els GE 0,gvels)
tpar_gels = WHERE(tpar_els GE 0,gtpar)
tper_gels = WHERE(tper_els GE 0,gtper)
tani_gels = WHERE(tani_els GE 0,gtani)
;-----------------------------------------------------------------------------------------
; => Define the FILE name suffixes of each type of data
;-----------------------------------------------------------------------------------------
; => Avg. Temp
IF (gtavg GT 0) THEN BEGIN
  tels0     = tavg_els[tavg_gels]
  el_tavg_n = el_tavg_n[tels0]
  fn_tavg_n = tavg_basf
  FOR j=0L, N_ELEMENTS(tels0) - 1L DO BEGIN
    fn_tavg_n += '-'+def_suff[tels0[j]]
  ENDFOR
ENDIF ELSE BEGIN
  el_tavg_n = ''
ENDELSE
; => Thermal Speed
IF (gvthm GT 0) THEN BEGIN
  tels0     = vthm_els[vthm_gels]
  el_vthm_n = el_vthm_n[tels0]
  fn_vthm_n = vthm_basf
  FOR j=0L, N_ELEMENTS(tels0) - 1L DO BEGIN
    fn_vthm_n += '-'+def_suff[tels0[j]]
  ENDFOR
ENDIF ELSE BEGIN
  el_vthm_n = ''
ENDELSE
; => Density
IF (gdens GT 0) THEN BEGIN
  tels0     = dens_els[dens_gels]
  el_dens_n = el_dens_n[tels0]
  fn_dens_n = dens_basf
  FOR j=0L, N_ELEMENTS(tels0) - 1L DO BEGIN
    fn_dens_n += '-'+def_suff[tels0[j]]
  ENDFOR
ENDIF ELSE BEGIN
  el_dens_n = ''
ENDELSE
; => 1st Moment of DF (i.e. velocity)
IF (gvels GT 0) THEN BEGIN
  tels0     = vels_els[vels_gels]
  el_vels_n = el_vels_n[tels0]
  fn_vels_n = vels_basf
  FOR j=0L, N_ELEMENTS(tels0) - 1L DO BEGIN
    fn_vels_n += '-'+def_suff[tels0[j]]
  ENDFOR
ENDIF ELSE BEGIN
  el_vels_n = ''
ENDELSE
; => Temperature (i.e. Avg. KE) parallel to B-field
IF (gtpar GT 0) THEN BEGIN
  tels0     = tpar_els[tpar_gels]
  el_tpar_n = el_tpar_n[tels0]
  fn_tpar_n = tpar_basf
  FOR j=0L, N_ELEMENTS(tels0) - 1L DO BEGIN
    fn_tpar_n += '-'+def_suff[tels0[j]]
  ENDFOR
ENDIF ELSE BEGIN
  el_tpar_n = ''
ENDELSE
; => Temperature (i.e. Avg. KE) perpendicular to B-field
IF (gtper GT 0) THEN BEGIN
  tels0     = tper_els[tper_gels]
  el_tper_n = el_tper_n[tels0]
  fn_tper_n = tper_basf
  FOR j=0L, N_ELEMENTS(tels0) - 1L DO BEGIN
    fn_tper_n += '-'+def_suff[tels0[j]]
  ENDFOR
ENDIF ELSE BEGIN
  el_tper_n = ''
ENDELSE
; => Temperature anisotropy
IF (gtani GT 0) THEN BEGIN
  tels0     = tani_els[tani_gels]
  el_tani_n = el_tani_n[tels0]
  fn_tani_n = tani_basf
  FOR j=0L, N_ELEMENTS(tels0) - 1L DO BEGIN
    fn_tani_n += '-'+def_suff[tels0[j]]
  ENDFOR
ENDIF ELSE BEGIN
  el_tani_n = ''
ENDELSE
;-----------------------------------------------------------------------------------------
; => Define the FILE name suffixes of each type of data
;-----------------------------------------------------------------------------------------
IF NOT KEYWORD_SET(trange) THEN BEGIN
  mxtrange = [1d30,0d0]
  all_tpnm = [magf_names,ion_names,el_tavg_n,el_vthm_n,el_vels_n,$
              el_tpar_n,el_tper_n,el_tani_n]
  good     = WHERE(all_tpnm NE '',gd)
  IF (gd GT 0) THEN BEGIN
    FOR j=0L, gd - 1L DO BEGIN
      get_data,all_tpnm[good[j]],DATA=gdat
      IF (SIZE(gdat,/TYPE) EQ 8) THEN mxtrange[0] = mxtrange[0] < MIN(gdat.X,/NAN)
      IF (SIZE(gdat,/TYPE) EQ 8) THEN mxtrange[1] = mxtrange[1] > MAX(gdat.X,/NAN)
    ENDFOR
  ENDIF ELSE BEGIN
    MESSAGE,'No TPLOT variables are available...',/INFORMATIONAL,/CONTINUE
    RETURN
  ENDELSE
ENDIF ELSE BEGIN
  ; => Check TRANGE keyword format
  mxtrange = time_double(trange)
ENDELSE
;-----------------------------------------------------------------------------------------
; => Define the FILE time range name
;-----------------------------------------------------------------------------------------
ymdb   = ''               ; => ['YYYY-MM-DD/HH:MM:SS.ssss']
UTtime = ''               ; => ['HHMM-SSxsss']
gdate  = ''               ; => ['YYYY-MM-DD']
frange = ''               ; => ['YYYY-MM-DD_HHMM-SSxsss_YYYY-MM-DD_HHMM-SSxsss']
tprang = 0d0              ; => The time range (Unix) to use for all PS file plots

mts    = my_time_string(mxtrange,UNIX=1)
tprang = mts.UNIX
ymdb   = mts.DATE_TIME
UTtime = STRMID(ymdb[*],11L,2L)+STRMID(ymdb[*],14L,2L)+'-'+$
         STRMID(ymdb[*],17L,2L)+'x'+STRMID(ymdb[*],20L,3L)
gdate  = STRMID(ymdb[*],0L,10L)
frange = '_'+gdate[0]+'_'+UTtime[0]+'_'+gdate[1]+'_'+UTtime[1]
;-----------------------------------------------------------------------------------------
; => Save files to PS
;-----------------------------------------------------------------------------------------
; => Plot ion data first
fn_ions_n  = ''
IF (ion_names[0] NE '') THEN BEGIN
  ion_fnames = ['Ni','Ti','Ti-para','Ti-perp','Ti-anis']
  ion_fnames = ion_fnames[gion]
  IF (gi GT 3) THEN BEGIN
    IF (gi EQ 5) THEN BEGIN
      fn_ions_n  = '_'+ion_fnames[0]+'-'+ion_fnames[1]
      nns        = [magf_names,ion_names[0:1]]
      fname      = magf_fname+fn_ions_n+frange
      popen,fname,/PORT
        tplot,nns,TRANGE=tprang,NOMSSG=nom
      pclose
      fn_ions_n  = '_'+ion_fnames[2]+'-'+ion_fnames[3]+'-'+ion_fnames[4]
      nns        = [magf_names,ion_names[2:4]]
      fname      = magf_fname+fn_ions_n+frange
      popen,fname,/PORT
        tplot,nns,TRANGE=tprang,NOMSSG=nom
      pclose
    ENDIF ELSE BEGIN
      check = (gion[0] EQ 0) AND (gion[1] EQ 1)
      IF (check) THEN BEGIN
        fn_ions_n  = '_'+ion_fnames[0]+'-'+ion_fnames[1]
        nns        = [magf_names,ion_names[0:1]]
        fname      = magf_fname+fn_ions_n+frange
        popen,fname,/PORT
          tplot,nns,TRANGE=tprang,NOMSSG=nom
        pclose
        fn_ions_n  = ''
        FOR j=2L, gi - 1L DO BEGIN
          IF (j EQ 2) THEN fn_ions_n = '_'+ion_fnames[j] ELSE fn_ions_n += '-'+ion_fnames[j]
        ENDFOR
        nns        = [magf_names,ion_names[2:4]]
        fname      = magf_fname+fn_ions_n+frange
        popen,fname,/PORT
          tplot,nns,TRANGE=tprang,NOMSSG=nom
        pclose
      ENDIF ELSE BEGIN
        FOR j=0L, gi - 1L DO BEGIN
          IF (j EQ 0) THEN fn_ions_n = '_'+ion_fnames[j] ELSE fn_ions_n += '-'+ion_fnames[j]
        ENDFOR
        nns        = [magf_names,ion_names]
        fname      = magf_fname+fn_ions_n+frange
        popen,fname,/PORT
          tplot,nns,TRANGE=tprang,NOMSSG=nom
        pclose
      ENDELSE
    ENDELSE
  ENDIF ELSE BEGIN
    FOR j=0L, gi - 1L DO BEGIN
      IF (j EQ 0) THEN fn_ions_n = '_'+ion_fnames[j] ELSE fn_ions_n += '-'+ion_fnames[j]
    ENDFOR
    nns        = [magf_names,ion_names]
    fname      = magf_fname+fn_ions_n+frange
    popen,fname,/PORT
      tplot,nns,TRANGE=tprang,NOMSSG=nom
    pclose
  ENDELSE
ENDIF
;-----------------------------------------------------------------------------------------
; => Plot electron data
;-----------------------------------------------------------------------------------------
; => Avg. Temp
IF (el_tavg_n[0] NE '') THEN BEGIN
  nns        = [magf_names,el_tavg_n]
  fname      = magf_fname+fn_tavg_n+frange
  popen,fname,/PORT
    tplot,nns,TRANGE=tprang,NOMSSG=nom
  pclose
ENDIF
; => Thermal Speed
IF (el_vthm_n[0] NE '') THEN BEGIN
  nns        = [magf_names,el_vthm_n]
  fname      = magf_fname+fn_vthm_n+frange
  popen,fname,/PORT
    tplot,nns,TRANGE=tprang,NOMSSG=nom
  pclose
ENDIF
; => Density
IF (el_dens_n[0] NE '') THEN BEGIN
  nns        = [magf_names,el_dens_n]
  fname      = magf_fname+fn_dens_n+frange
  popen,fname,/PORT
    tplot,nns,TRANGE=tprang,NOMSSG=nom
  pclose
ENDIF
; => 1st Moment of DF (i.e. velocity)
IF (el_vels_n[0] NE '') THEN BEGIN
  nns        = [magf_names,el_vels_n]
  fname      = magf_fname+fn_vels_n+frange
  popen,fname,/PORT
    tplot,nns,TRANGE=tprang,NOMSSG=nom
  pclose
ENDIF
; => Temperature (i.e. Avg. KE) parallel to B-field
IF (el_tpar_n[0] NE '') THEN BEGIN
  nns        = [magf_names,el_tpar_n]
  fname      = magf_fname+fn_tpar_n+frange
  popen,fname,/PORT
    tplot,nns,TRANGE=tprang,NOMSSG=nom
  pclose
ENDIF
; => Temperature (i.e. Avg. KE) perpendicular to B-field
IF (el_tper_n[0] NE '') THEN BEGIN
  nns        = [magf_names,el_tper_n]
  fname      = magf_fname+fn_tper_n+frange
  popen,fname,/PORT
    tplot,nns,TRANGE=tprang,NOMSSG=nom
  pclose
ENDIF
; => Temperature anisotropy
IF (el_tani_n[0] NE '') THEN BEGIN
  nns        = [magf_names,el_tani_n]
  fname      = magf_fname+fn_tani_n+frange
  popen,fname,/PORT
    tplot,nns,TRANGE=tprang,NOMSSG=nom
  pclose
ENDIF
; => Halo-to-Core Temperature ratios
IF (chratio_n[0] NE '') THEN BEGIN
  nns        = [magf_names,chratio_n]
  fn_chra_n  = '_Tparahc_Tperphc'
  fname      = magf_fname+fn_chra_n+frange
  popen,fname,/PORT
    tplot,nns,TRANGE=tprang,NOMSSG=nom
  pclose
ENDIF
;*****************************************************************************************
ex_time = SYSTIME(1) - ex_start
MESSAGE,STRING(ex_time)+' seconds execution time.',/INFORMATIONAL,/CONTINUE
;*****************************************************************************************
RETURN
END
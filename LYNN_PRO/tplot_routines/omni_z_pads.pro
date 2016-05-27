;+
;*****************************************************************************************
;
;  FUNCTION :   omni_z_pads.pro
;  PURPOSE  :   This program gets rid of bad PAD data so one doesn't waste time
;                 sorting through all the different energy bins trying to get rid
;                 of the ones with the most data gaps.  The program returns the 
;                 calibrated data as a TPLOT variable for later use.
;
;  CALLED BY: 
;               calc_padspecs.pro
;
;  CALLS:
;               tnames.pro
;               get_data.pro
;               store_data.pro
;               options.pro
;               clean_spec_spikes.pro
;               spec_vec_data_shift.pro
;               ylim.pro
;
;  REQUIRES:    NA
;
;  INPUT:
;               NN1   :  [String] A defined TPLOT variable name with associated spectra
;                          data separated by pitch-angle as TPLOT variables
;                          [e.g. 'nelb_pads']
;
;  EXAMPLES:
;               zdat = z_pads_2('nelb_pads',LABS=mylabs,PANGS=myangs)
;
;  KEYWORDS:  
;               LABS  :  [string] Specifying the energy bin labels for plotting
;               PANGS :  [string] Specifying the pitch-angles to look at
;
;   CHANGED:  1)  Changed omni spectra calc                         [08/18/2008   v1.1.37]
;             2)  Updated man page                                  [03/19/2009   v1.1.38]
;             3)  Changed program my_str_names.pro to dat_3dp_str_names.pro
;                   and my_clean_spikes_2.pro to clean_spec_spikes.pro
;                   and my_data_shift_2.pro to spec_vec_data_shift.pro
;                   and renamed from z_pads_2.pro                   [08/12/2009   v2.0.0]
;             4)  Fixed a typo in interpolation loop (line 150)     [11/30/2011   v2.0.1]
;
;   CREATED:  ??/??/????
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  11/30/2011   v2.0.1
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION omni_z_pads,nn1,LABS=labs,PANGS=pangs

;-----------------------------------------------------------------------------------------
; => Define some dummy variables
;-----------------------------------------------------------------------------------------
snn1 = STRMID(nn1,0,3)
ff1  = 0  ; label flag to identify where labels go in tplot
ang  = 0  ; number of pitch-angles for spec plots
;-----------------------------------------------------------------------------------------
; 'sf'&'so' order their data&labels backwards from EESA/PESA data
;   so we need to adjust this to fix the plot labels
;-----------------------------------------------------------------------------------------
IF KEYWORD_SET(pangs) THEN BEGIN
  ang = N_ELEMENTS(pangs)+1L
  IF (STRMID(snn1,0,2) EQ 'ns') THEN ff1 = -1 ELSE ff1 = 1
ENDIF ELSE BEGIN
  CASE snn1 OF
    'neh' : BEGIN
      ff1 = 1
      ang = 8L
    END
    'nsf' : BEGIN
      ff1 = -1
      ang = 8L
    END
    'nso' : BEGIN
      ff1 = -1
      ang = 8L
    END
    'nel' : BEGIN
      ff1 = 1
      ang = 16L
    END  
    ELSE : BEGIN
      ff1 = 1
      ang = 8L
    END
  ENDCASE
ENDELSE
;-----------------------------------------------------------------------------------------
; => Create dummy structures
;-----------------------------------------------------------------------------------------
IF KEYWORD_SET(labs) THEN BEGIN
  mylim = CREATE_STRUCT('YLOG',1,'PANEL_SIZE',2.0,'LABELS',LABS,$
                        'LABFLAG',ff1)
ENDIF ELSE BEGIN
  mylim = CREATE_STRUCT('YLOG',1,'PANEL_SIZE',2.0,'LABFLAG',ff1)
ENDELSE

n_0 = tnames(nn1+'-2-0:1*')
get_data,n_0[0],DATA=dat0
nns = STRMID(nn1,0,3)

nens   = N_ELEMENTS(dat0.y[0,*])  ; # of energy bins
nsam   = N_ELEMENTS(dat0.y[*,0])  ; # of data samples
mnames = STRARR(ang-1L)
avdat  = REPLICATE(!VALUES.F_NAN,ang-1L,nsam,nens)

FOR i=0, ang-2L DO BEGIN
  j = i + 1
  nn2 = nn1+'-2-'+STRTRIM(i,1)+':'+STRTRIM(j,1)
  get_data,nn2,data=dat
  lbyd  = WHERE(dat.y LE 0.0 OR FINITE(dat.y) EQ 0,lby)
  ;---------------------------------------------------------------------------------------
  ; -Get rid of negative data
  ;---------------------------------------------------------------------------------------
  IF (lby GT 0) THEN BEGIN
    lbind = ARRAY_INDICES(dat.y,lbyd)
    dat.y[lbind[0,*],lbind[1,*]] = !VALUES.F_NAN
  ENDIF
  gylim = WHERE(dat.y GT 0.0 AND FINITE(dat.y),gyli,COMPLEMENT=bylim)
  IF (gyli EQ nens*nsam) THEN BEGIN
    ymin = MIN(dat.y,/NAN)/1.1
    ymax = MAX(dat.y,/NAN)/1.1
    y2   = dat.y
    GOTO,JUMP_GOOD
  ENDIF
  ;---------------------------------------------------------------------------------------
  ; -Get rid of non-finite data
  ;---------------------------------------------------------------------------------------
  IF (gyli GT 0) THEN BEGIN
    y    = dat.y
    cind = ARRAY_INDICES(y,bylim)
    cgnd = ARRAY_INDICES(y,gylim)
    noda = gyli*1.0/(nsam*nens*1.0)
    IF (noda GE 0.8) THEN BEGIN
      y2     = y
      ;-----------------------------------------------------------------------------------
      ; -Interpolate data gaps
      ;-----------------------------------------------------------------------------------
      FOR k=0L, nens - 1L DO BEGIN       ; => LBW III 2011-11-30
        ggc = WHERE(cgnd[1,*] EQ k,g0)
        IF (g0 GT 0) THEN BEGIN
          y22     = REFORM(y[cgnd[0,ggc],k])
          t22     = REFORM(dat.x[cgnd[0,ggc]])
          temp    = INTERPOL(y22,t22,dat.X);,/SPLINE)
          y2[*,k] = temp
        ENDIF ELSE BEGIN
          y22     = REPLICATE(!VALUES.F_NAN,nsam)
          y2[*,k] = y22
        ENDELSE
      ENDFOR
      gylim = WHERE(y2 GT 0.0 AND FINITE(y2),gyli,COMPLEMENT=bylim)
      gyind = ARRAY_INDICES(y2,gylim)
      ;-----------------------------------------------------------------------------------
      ; -Redefine energy bin values
      ;-----------------------------------------------------------------------------------
      tempen  = TOTAL(FINITE(dat.V),1,/NAN)
      tempv   = TOTAL(dat.V,1,/NAN)/tempen  ; -FLTARR(nens)
      tempv2  = REPLICATE(1.,nsam) # tempv  ; -FLTARR(nsam,nens)
      dat.V[cind[0,*],cind[1,*]] = tempv2[cind[0,*],cind[1,*]]
      ;-----------------------------------------------------------------------------------
      ; -Determine ylimits if possible (avoiding 0.0 and /NAN's)
      ;-----------------------------------------------------------------------------------
      ymin  = MIN(y2[gyind[0,*],gyind[1,*]],/NAN)/1.1
      ymax  = MAX(y2[gyind[0,*],gyind[1,*]],/NAN)*1.1
    ENDIF ELSE BEGIN
      y2     = y
      gyind  = ARRAY_INDICES(y2,gylim)   ; -element indices of good data
      byind  = ARRAY_INDICES(y2,bylim)   ; -" " bad data
      y2[byind[0,*],byind[1,*]] = !VALUES.F_NAN
      ;-----------------------------------------------------------------------------------
      ; -Redefine energy bin values
      ;-----------------------------------------------------------------------------------
      tempen  = TOTAL(FINITE(dat.V),1,/NAN)
      tempv   = TOTAL(dat.V,1,/NAN)/tempen  ; -FLTARR(nens)
      tempv2  = REPLICATE(1.,nsam) # tempv  ; -FLTARR(nsam,nens)
      dat.v[byind[0,*],byind[1,*]] = tempv2[byind[0,*],byind[1,*]]
      ymin  = MIN(y2[gyind[0,*],gyind[1,*]],/NAN)/1.1
      ymax  = MAX(y2[gyind[0,*],gyind[1,*]],/NAN)*1.1
    ENDELSE
  ENDIF ELSE BEGIN
    y2    = dat.Y
    y2    = !VALUES.F_NAN
    dat.v = !VALUES.F_NAN
    ymin  = !VALUES.F_NAN
    ymax  = !VALUES.F_NAN
  ENDELSE
  ;=======================================================================================
  JUMP_GOOD:
  ;=======================================================================================
  avdat[i,*,*] = y2
  store_data,nn2,DATA=dat,NEWNAME=nn2+'_N',LIM=mylim
  mnames[i] = nn2+'_N'
  options,nn2+'_N','LABFLAG',ff1
  options,nn2+'_N','YMINOR',9
  options,nn2+'_N','XMINOR',4
  ylim,nn2+'_N',ymin,ymax,1
  IF KEYWORD_SET(pangs) THEN BEGIN
    options,nn2+'_N','YTITLE',nns+'!C'+pangs[i]
  ENDIF
ENDFOR
;-----------------------------------------------------------------------------------------
; -Need to convert pitch-angles back into floats
;-----------------------------------------------------------------------------------------
IF KEYWORD_SET(pangs) THEN BEGIN
  pang_len = STRLEN(pangs)             ; -string length of pangs
  pang_ran = STRARR(N_ELEMENTS(pangs)) ; -pangs w/o the added degree symbol
  FOR k=0L,N_ELEMENTS(pangs)-1L DO pang_ran[k] = STRMID(pangs[k],0,pang_len[k]-5L)
  dash_pos = STRPOS(pang_ran,'-')      ; -character position of '-' in pang_ran
  rang_len = STRLEN(pang_ran)
  my_pang0 = DBLARR(N_ELEMENTS(pangs)) ; -lower bound of pitch-angle ranges
  my_pang1 = DBLARR(N_ELEMENTS(pangs)) ; -upper bound of " "
  FOR k=0L,N_ELEMENTS(pangs)-1L DO BEGIN
    my_pang0[k] = DOUBLE(STRMID(pang_ran[k],0,dash_pos[k]))*!DPI/18d1
    my_pang1[k] = DOUBLE(STRMID(pang_ran[k],dash_pos[k]+1L,rang_len[k]))*!DPI/18d1
  ENDFOR
  avdat2   = FLTARR(nsam,nens)  ; -Omni directional estimate of data...
  ang2     = (ang-1L)*1d0       ; -# of Pitch-Angles [float]  
  dang     = ABS(my_pang1 - my_pang0)
  teavdat3 = DBLARR(ang-1L,nsam,nens)
  tavdat3  = DBLARR(ang-1L,nsam,nens)
  FOR j=0L,ang-2L DO BEGIN
    tdang           = avdat[j,*,*]*SIN(dang[j])*(2.0*!PI)*dang[j]
    teavdat3[j,*,*] = TOTAL(FINITE(tdang),1,/NAN)
    tavdat3[j,*,*]  = TOTAL(tdang,1,/NAN)/teavdat3[j,*,*]
  ENDFOR
  avdat2 = TOTAL(tavdat3,1,/NAN)/TOTAL(FINITE(tavdat3),1,/NAN)
ENDIF ELSE BEGIN
  teavdat3 = TOTAL(FINITE(avdat),1,/NAN,/DOUBLE)
  avdat2   = TOTAL(avdat,1,/NAN,/DOUBLE)/teavdat3
ENDELSE

omnistr  = CREATE_STRUCT('X',dat0.x,'Y',avdat2,'V',dat0.v)
store_data,nn1+'_omni',DATA=omnistr,LIM=mylim
options,nn1+'_omni','LABFLAG',ff1
options,nn1+'_omni','LABELS',labs
options,nn1+'_omni','YTITLE',nn1+' Omni Flux'
options,nn1+'_omni','YMINOR',9   ; -put 9 minor tick marks on plots
options,nn1+'_omni','XMINOR',4
;-----------------------------------------------------------------------------------------
; - Created a normalized spectrum to observe relative changes in flux
;-----------------------------------------------------------------------------------------
mysip = (SIZE(omnistr.Y,/DIMENSIONS))[0]/1500L
shon  = STRMID(nn1,0,3)
IF (mysip GT 3L AND mysip LE 12L) THEN BEGIN
  hsmooth = mysip + 1L
  lsmooth = LONG(3./5.*hsmooth)
ENDIF ELSE BEGIN
  IF (mysip GT 12L) THEN BEGIN
    CASE shon OF
      'nsf' : BEGIN
        hsmooth = 20L
        lsmooth = 12L
      END
      'nso' : BEGIN
        hsmooth = 20L
        lsmooth = 12L
      END
      'nel' : BEGIN
        hsmooth = 10L
        lsmooth = 5L
      END
      'neh' : BEGIN
        hsmooth = 12L
        lsmooth = 7L
      END
      'nph' : BEGIN
        hsmooth = 15L
        lsmooth = 10L
      END
      'npl' : BEGIN
        hsmooth = 15L
        lsmooth = 10L
      END
      ELSE  : BEGIN
        hsmooth = 12L
        lsmooth = 7L
      END
    ENDCASE
  ENDIF ELSE BEGIN
    hsmooth = 3L
    lsmooth = 3L
  ENDELSE
ENDELSE
tnn1 = nn1+'_omni'
;-----------------------------------------------------------------------------------------
; => Clean up, normalize, and shift
;-----------------------------------------------------------------------------------------
clean_spec_spikes,tnn1,NSMOOTH=lsmooth,ESMOOTH=[0,2,hsmooth],NEW_NAME=tnn1+'_cln'
spec_vec_data_shift,tnn1+'_cln',/DATN,NEW_NAME=tnn1+'_cln_sh_n'
RETURN,mnames
END

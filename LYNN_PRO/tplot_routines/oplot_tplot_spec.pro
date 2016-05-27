;+
;*****************************************************************************************
;
;  FUNCTION :   oplot_tplot_spec.pro
;  PURPOSE  :   This program provides the ability to plot lines over a spectrogram
;                 plot in TPLOT interactively.  
;
;  CALLED BY:   
;               NA
;
;  CALLS:
;               tnames.pro
;               tplot.pro
;               get_data.pro
;               extract_tags.pro
;               str_element.pro
;               no_label.pro
;
;  REQUIRES:    
;               TPLOT libraries
;
;  INPUT:
;               NAMES      :  N-Element string array of TPLOT handles/names
;               OP_NAMES   :  M-Element string array of TPLOT handles/names
;
;  EXAMPLES:    
;               .......................................
;               :         Get data into TPLOT         :
;               .......................................
;               ex     = rot_tds_ef.(0)[*,0]    ; => Parallel E-field [N-element array]
;               utx    = REFORM(tds_unx[0,*])   ; => Unix time        [N-element array]
;               time   = '20000406_1632-09x380'
;               store_data,'Epara_'+time[0],DATA={X:utx,Y:ex}
;               paname = 'Epara_'+time[0]+'_wavelet'
;               wavelet_to_tplot,utx,ex,NEW_NAME=paname,SIGNIF=signif,CONE=cone,        $
;                                       PERIOD=period,FFT_THEOR=fft_theor,SCALES=scales,$
;                                       CONF_95LEV=conf_95lev
;               options,paname,'ZRANGE',[1e-1,1e3]
;               options,'Epara_'+time[0],'YRANGE',[-21e0,21e0]
;               options,paname,'YRANGE',[15e1,6e4]
;               op_names = 'Conf_Level_95'
;               store_data,op_names,DATA={X:utx,Y:conf_95lev,V:1d0/period,SPEC:1}
;               options,op_names,'LEVEL',1.0
;               options,op_names,'C_ANNOT','95%'
;               options,op_names,'ZRANGE',[5e-1,1e0]
;               options,op_names,'YTITLE','95% Confidence Level'+'!C'+'(anything > 1.0)'
;               store_data,'Cone_of_Influence',DATA={X:utx,Y:1d0/cone}
;               op_names = ['Conf_Level_95','Cone_of_Influence']
;               options,op_names,'YLOG',1
;               options,op_names,'YRANGE',[15e1,6e4]
;               nnw = tnames()
;               options,nnw,"YSTYLE",1
;               options,nnw,"PANEL_SIZE",2.
;               options,nnw,'XMINOR',5
;               options,nnw,'XTICKLEN',0.04
;               ......................................
;               : Plot OP_NAMES over PANAME in TPLOT :
;               ......................................
;               ltag = ['LEVELS','C_ANNOTATION','YLOG','C_THICK']
;               lims = CREATE_STRUCT(ltag,1.0,'95%',1,1.5)
;               oplot_tplot_spec,panames,op_names,LIMITS=lims
;
;  KEYWORDS:    
;               OPLOT_IND  :  Not sure yet...
;               LIMITS     :  A plot limits structure with tags associated with the
;                               keywords for the built-in IDL plotting routines.
;               TRANGE     :  2-Element double-array of Unix times specifying the time
;                               range you wish to plot
;               NOMSSG     :  If set, TPLOT will NOT print out the index and TPLOT handle
;                               of the variables being plotted
;
;   CHANGED:  1)  Added keyword:  NOMSSG                     [10/16/2009   v1.1.0]
;             2)  Changed manner in which program determines plot structure info
;                                                            [05/25/2010   v1.2.0]
;             3)  Added capacity to deal with different colors for overplotted lines
;                                                            [07/14/2010   v1.3.0]
;
;   NOTES:      
;               1)  At the moment, the program assumes that NAMES can be an N-element
;                     array of spectrogram and non-spectrogram plots in column form to
;                     plot over.  It also assumes that OP_NAMES is an M-element
;                     TPLOT handle that can either be line plots or a 2D contour plots.
;               2)  If the number of spec plots does NOT equal the number of elements in
;                     OP_NAMES, then program assumes you wish to plot ALL of OP_NAMES
;                     over ONLY the LAST spectrogram plot.
;
;   CREATED:  09/13/2009
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  07/14/2010   v1.3.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

PRO oplot_tplot_spec,names,op_names,OPLOT_IND=oplot_ind,LIMITS=limits,TRANGE=trange,$
                     NOMSSG=nom

;-----------------------------------------------------------------------------------------
; => Define some defaults
;-----------------------------------------------------------------------------------------
dev_n = STRLOWCASE(!D.NAME)
; => If X-Windows, then use 255 [white] else 0 [black]
IF (dev_n EQ 'x') THEN def_color = 255 ELSE def_color = 0
;-----------------------------------------------------------------------------------------
; => Check input
;-----------------------------------------------------------------------------------------
nns  = REFORM(names)
nos  = REFORM(op_names)
ntyp = SIZE(nns,/TYPE)
otyp = SIZE(nos,/TYPE)
IF (ntyp NE otyp) THEN BEGIN
  nns = tnames(nns)
  nos = tnames(nos)
ENDIF
;-----------------------------------------------------------------------------------------
; => 
;-----------------------------------------------------------------------------------------
ns = N_ELEMENTS(nns)
no = N_ELEMENTS(nos)
sp = 0                ; => # of spec plots
si = REPLICATE(-1,ns)
IF (ns GE 1L AND nns[0] NE '') THEN BEGIN
  ;---------------------------------------------------------------------------------------
  ; => Plot input NAMES with TPLOT
  ;---------------------------------------------------------------------------------------
  tplot,nns,TRANGE=trange,NEW_TVARS=new_opt2,NOMSSG=nom
  lim_olds  = PTRARR(ns,/ALLOCATE_HEAP)
  dlim_olds = PTRARR(ns,/ALLOCATE_HEAP)
  FOR j=0L, ns - 1L DO BEGIN
    get_data,nns[j],DATA=spec0,DLIM=dlim_old,LIM=lim_old
    IF (SIZE(spec0,/TYPE) EQ 8) THEN BEGIN
      stags = TAG_NAMES(spec0)
      stest = WHERE(stags EQ 'SPEC',st)
      IF (st EQ 0L) THEN BEGIN
        *(lim_olds)[j] = 0
        GOTO,JUMP_IGNORE
      ENDIF ELSE BEGIN
        sp   += 1    ; => Count the # of spec plots
        si[j] = j    ; => Keep track of indecies that correspond to spec plots
      ENDELSE
      wave     = spec0.Y
      utx      = spec0.X
      uvy      = spec0.V
      test_str = [SIZE(lim_old,/TYPE) EQ 8,SIZE(dlim_old,/TYPE) EQ 8]
      IF (test_str[0] OR test_str[1]) THEN BEGIN
        IF (test_str[0] AND test_str[1]) THEN BEGIN
          ttes0 = TAG_NAMES(lim_old)
          ttes1 = TAG_NAMES(dlim_old)
          ttest = [ttes0,ttes1]
        ENDIF ELSE BEGIN
          IF (test_str[0]) THEN ttest = TAG_NAMES(lim_old) ELSE ttest = TAG_NAMES(dlim_old)
        ENDELSE
        gtags = ['YLOG','YRANGE','XRANGE']
        g_t   = 0
        FOR k=0L, N_ELEMENTS(gtags) - 1L DO BEGIN
          gtest = WHERE(ttest EQ gtags[k],ggt)
          IF (k EQ 1 AND ggt EQ 0) THEN BEGIN
            ; => No Y-Range set for data... fix this
            IF KEYWORD_SET(trange) THEN BEGIN
              tra_00 = trange
            ENDIF ELSE BEGIN
              tra_00 = [MIN(utx,/NAN),MAX(utx,/NAN)]
            ENDELSE
            gxra   = WHERE(utx LE tra_00[1] AND utx GE tra_00[0],gdxr)
            IF (gdxr GT 1) THEN BEGIN
              ; => If data falls within time range, then estimate Y-Range
              yra_00 = [MIN(uvy[gxra],/NAN),MAX(uvy[gxra],/NAN)]
              test_0 = (TOTAL(FINITE(yra_00),/NAN) EQ 2) AND (yra_00[0] NE yra_00[1])
              IF (test_0) THEN BEGIN
                str_element,lim_old,'YRANGE',yra_00,/ADD_REPLACE
                ggt = 1
              ENDIF
            ENDIF
          ENDIF
          IF (ggt GT 0L) THEN g_t += 1
        ENDFOR
        ; => Add old limit structures to pointer for later use
        IF (g_t GT 0L) THEN *(lim_olds)[j]  = lim_old  ELSE *(lim_olds)[j]  = 0
        IF (g_t GT 0L) THEN *(dlim_olds)[j] = dlim_old ELSE *(dlim_olds)[j] = 0
      ENDIF
    ENDIF ELSE BEGIN
      *(lim_olds)[j]  = 0
      *(dlim_olds)[j] = 0
    ENDELSE
    ;=====================================================================================
    JUMP_IGNORE:
    ;=====================================================================================
  ENDFOR
  gsi = WHERE(si GE 0L,gi)
  IF (gi GT 0L) THEN BEGIN
    si = si[gsi]
    IF (sp NE gi) THEN sp = gi
  ENDIF ELSE BEGIN
    MESSAGE,'No TPLOT names for NAMES input were spec plots...',/CONTINUE,/INFORMATIONAL
    RETURN
  ENDELSE
ENDIF ELSE BEGIN
  MESSAGE,'No TPLOT names were found associated with NAMES input...',/CONTINUE,/INFORMATIONAL
  RETURN
ENDELSE
;-----------------------------------------------------------------------------------------
; => Get plot information associated with spectrogram plot
;-----------------------------------------------------------------------------------------
setss = new_opt2.SETTINGS
xwind = setss.X.WINDOW
ywind = setss.Y.WINDOW
xran  = new_opt2.OPTIONS.TRANGE
; => List of tags that we do NOT want in plot structure
excptags = ['ZRANGE','ZSTYLE','ZTICKS','ZTICKV','ZTICKNAME','ZTITLE','ZLOG',$
                     'YSTYLE','YTICKS','YTICKV','YTICKNAME','YTITLE',       $
                     'XSTYLE','XTICKS','XTICKV','XTICKNAME','XTITLE']
IF (sp GT 0) THEN BEGIN
  nopts = PTRARR(sp,/ALLOCATE_HEAP)
  ; => Get IDL keywords associated with AXIS.PRO
  FOR j=0L, sp - 1L DO BEGIN
    ; => Define plot position in normal coordinates of last spec plot
    xypos = [xwind[0],ywind[0,si[j]],xwind[1],ywind[1,si[j]]]
    opts  = CREATE_STRUCT('NOERASE',1,'POSITION',xypos,'NORMAL',1,'XSTYLE',5,$
                          'YSTYLE',5,'XRANGE',xran)
    lim_old  = *(lim_olds)[si[j]]
    dlim_old = *(dlim_olds)[si[j]]
    oopts    = opts
    extract_tags,oopts,lim_old,/AXIS,EXCEPT_TAGS=excptags
    extract_tags,oopts,dlim_old,/AXIS,EXCEPT_TAGS=excptags
    jstr     = 'T'+STRTRIM(j,2L)
    ; => Create structure with plot limit structure options
    str_element,nopts,jstr,oopts,/ADD_REPLACE
  ENDFOR
ENDIF ELSE BEGIN
  MESSAGE,'No TPLOT names for NAMES input were spec plots...',/CONTINUE,/INFORMATIONAL
  RETURN
ENDELSE
;---------------------------------------------------------------------------------------
; => Release pointers
;---------------------------------------------------------------------------------------
FOR j=0L, ns - 1L DO BEGIN
  PTR_FREE,lim_olds[j]
  PTR_FREE,dlim_olds[j]
ENDFOR
PTR_FREE,lim_olds
PTR_FREE,dlim_olds
;-----------------------------------------------------------------------------------------
; => Plot the desired data over the spec plot
;-----------------------------------------------------------------------------------------
IF (no GE 1L AND nos[0] NE '' AND no GE sp) THEN BEGIN
  FOR j=0L, no - 1L DO BEGIN
    IF (no EQ sp) THEN BEGIN
      ; => Assumes you want to overplot one onto each spec plot
      n_opts = nopts.(j)
    ENDIF ELSE BEGIN
      ; => Assumes you want to overplot all onto last spec plot
      n_opts = nopts.(sp-1L)
    ENDELSE
    get_data,nos[j],DATA=op_dat,DLIM=dlim_nos,LIM=lim_nos
    otags = TAG_NAMES(op_dat)
    vgood = WHERE(otags EQ 'V',vgd)
    ;-------------------------------------------------------------------------------------
    ; => Look at tag names of structures
    ;-------------------------------------------------------------------------------------
    IF (SIZE(dlim_nos,/TYPE) EQ 8) THEN BEGIN
      dumb_tags0 = STRLOWCASE(TAG_NAMES(dlim_nos))
    ENDIF ELSE dumb_tags0 = ''
    IF (SIZE(lim_nos,/TYPE) EQ 8) THEN BEGIN
      dumb_tags1 = STRLOWCASE(TAG_NAMES(lim_nos))
    ENDIF ELSE dumb_tags1 = ''
    test_colors0 = TOTAL(dumb_tags0 EQ 'colors') EQ 0
    test_colors1 = TOTAL(dumb_tags1 EQ 'colors') EQ 0
    bad          = WHERE([test_colors0,test_colors1],bd,COMPLEMENT=good)
    test_colors  = test_colors0 AND test_colors1
    ;-------------------------------------------------------------------------------------
    ; => Define colors of overplots [not applied to contour unless c_colors used]
    ;-------------------------------------------------------------------------------------
    IF (test_colors) THEN BEGIN
      colors = def_color
    ENDIF ELSE BEGIN
      IF (bad[0] EQ 0) THEN dummy_structure = lim_nos ELSE dummy_structure = dlim_nos
      colors = dummy_structure.COLORS
    ENDELSE
    ;-------------------------------------------------------------------------------------
    ; => Make sure TPLOT variable is a structure with correct format
    ;-------------------------------------------------------------------------------------
    IF (SIZE(op_dat,/TYPE) EQ 8) THEN BEGIN
      odat  = REFORM(op_dat.Y)
      otime = op_dat.X
      oddim = SIZE(odat,/DIMENSIONS)
      ondim = SIZE(odat,/N_DIMENSIONS)
      ;-----------------------------------------------------------------------------------
      ; => Determine the type of plot
      ;-----------------------------------------------------------------------------------
      CASE ondim[0] OF
        1    : BEGIN
          ;-------------------------------------------------------------------------------
          ; => Single line plot
          ;-------------------------------------------------------------------------------
          str_element,n_opts,'NOCLIP',0,/ADD_REPLACE
          str_element,n_opts,'YTICKFORMAT','no_label',/ADD_REPLACE
          str_element,n_opts,'XTICKFORMAT','no_label',/ADD_REPLACE
          str_element,n_opts,'THICK',1.5,/ADD_REPLACE
          ; => Check color options
          IF (N_ELEMENTS(colors) NE 1) THEN colors = colors[0]
          ; => Plot data
          PLOT,otime,odat,_EXTRA=n_opts,/NODATA
            OPLOT,otime,odat,COLOR=colors
        END
        2    : BEGIN
          str_element,n_opts,'YTICKFORMAT','no_label',/ADD_REPLACE
          str_element,n_opts,'XTICKFORMAT','no_label',/ADD_REPLACE
          ; => Check if Contour-like plot
          IF (vgd GT 0L) THEN BEGIN
            ;-----------------------------------------------------------------------------
            ; => Use Contour plot if Tag V is present
            ;-----------------------------------------------------------------------------
            oyvals = op_dat.V
            ; => Get IDL keywords associated with CONTOUR.PRO from keyword LIMITS
            IF KEYWORD_SET(limits) THEN BEGIN
              extract_tags,n_opts,limits,/CONTOUR,EXCEPT_TAGS=excptags
            ENDIF
            ; => Get IDL keywords associated with CONTOUR.PRO from plot structure LIM_NOS
            IF (SIZE(lim_nos,/TYPE) EQ 8) THEN BEGIN
              extract_tags,n_opts,lim_nos,/CONTOUR,EXCEPT_TAGS=excptags
            ENDIF
            dumb_tagsc = STRLOWCASE(TAG_NAMES(n_opts))
            test_nlevs = (TOTAL(dumb_tagsc EQ 'levels') EQ 0) AND $
                         (TOTAL(dumb_tagsc EQ 'nlevels') EQ 0)
            IF (test_nlevs) THEN BEGIN
              IF (N_ELEMENTS(colors) NE 6) THEN ccols = def_color ELSE ccols = colors
            ENDIF ELSE BEGIN
              badc = WHERE([(TOTAL(dumb_tagsc EQ 'levels') EQ 0),$
                            (TOTAL(dumb_tagsc EQ 'nlevels') EQ 0)],bd,COMPLEMENT=goodc)
              IF (badc[0] EQ 0) THEN BEGIN
                nlevs = n_opts.NLEVELS
              ENDIF ELSE BEGIN
                nlevs = N_ELEMENTS(n_opts.LEVELS)
              ENDELSE
              IF (N_ELEMENTS(colors) NE nlevs) THEN ccols = def_color ELSE ccols = colors
            ENDELSE
            str_element,n_opts,'C_THICK',1.5,/ADD_REPLACE
            CONTOUR,odat,otime,oyvals,_EXTRA=n_opts,C_COLORS=ccols
          ENDIF ELSE BEGIN
            ;-----------------------------------------------------------------------------
            ; => Stacked line plot
            ;-----------------------------------------------------------------------------
            str_element,n_opts,'NOCLIP',0,/ADD_REPLACE
            oyvals = 0
            gdim   = WHERE(oddim EQ N_ELEMENTS(otime),gdi)
            CASE gdim[0] OF
              0L   : BEGIN
                no_plots = oddim[1]
              END
              1L   : BEGIN
                no_plots = oddim[0]
                odat     = TRANSPOSE(odat)
              END
              ELSE : GOTO,JUMP_NO_OPLOT
            ENDCASE
            ; => Check color options
            IF (N_ELEMENTS(colors) NE no_plots) THEN colors = REPLICATE(colors[0],no_plots)
            FOR k=0L, no_plots - 1L DO BEGIN
              PLOT,otime,odat[*,k],_EXTRA=n_opts,/NODATA
                OPLOT,otime,odat[*,k],COLOR=colors[k]
            ENDFOR
          ENDELSE
        END
        ELSE : BEGIN
          MESSAGE,'Cannot deal with 3D structures...',/CONTINUE,/INFORMATIONAL
          RETURN
        END
      ENDCASE
    ENDIF
    ;=====================================================================================
    JUMP_NO_OPLOT:
    ;=====================================================================================
  ENDFOR
ENDIF

END
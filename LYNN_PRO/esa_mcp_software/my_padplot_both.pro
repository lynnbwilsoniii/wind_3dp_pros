;+
;*****************************************************************************************
;
;  PROCEDURE:   my_padplot_both.pro
;  PURPOSE  :   Produces two plots from an input pitch-angle distribution (PAD)
;                 function produced by the program my_pad_dist.pro or pad.pro.
;                 The first plot has the units of particle flux while the second
;                 is in the units of energy flux.  If the structure is "good,"
;                 no array of labels or colors are necessary because the program
;                 should take care of that for you.  I also eliminated the use
;                 mplot.pro due to its inability to automate the plot labels and
;                 locations in an acceptable manner.  I also included/altered the
;                 keyword associated with specifying energy bins because it was
;                 not clear how the program wanted you to format the input.  So
;                 I eliminated the need to specify how the energy bins should be
;                 entered making that keyword more robust.
;
;  CALLED BY:   
;               NA
;
;  CALLS:
;               test_wind_vs_themis_esa_struct.pro
;               dat_3dp_str_names.pro
;               dat_themis_esa_str_names.pro
;               str_element.pro
;               wind_3dp_units.pro
;               conv_units.pro
;               pad.pro
;               themis_esa_pad.pro
;               dat_3dp_energy_bins.pro
;               trange_str.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               TEMPDAT  :   Scalar [structure] containing pitch angle distribution
;                              (PAD) data quantities and appropriate structure tags
;                              [see PAD.PRO]
;                              If TEMPDAT is not a structure associated with pad.pro,
;                              then the routine calls pad.pro and plots the results.
;
;  EXAMPLES:    
;               .....................................................................
;               : =>> Plot the PAD in Flux and Energy Flux vs pitch angle for the 9 :
;               :       highest energies                                            :
;               .....................................................................
;               my_padplot,pad,UNITS='flux',EBINS=[0,8]
;
;  KEYWORDS:    
;               LIMITS   :  Scalar [structure] defining the plot limits structure
;                             [see XLIM.PRO, YLIM.PRO, or OPTIONS.PRO]
;                             The limit structure can have the following elements:
;               UNITS    :  Scalar [string] defining the units to plot in 1st panel and
;                             2nd panel will contain the next higher order units
;                             [e.g. 'counts' in 1st and 'flux' in 2nd]
;                             [Default = 'flux']
;               COLOR    :  [N]-Element array of colors to be used for each bin
;                             [N = EBINS[1] - EBINS[0] + 1L]
;               LABEL    :  Set to print labels for each energy step.
;               EBINS    :  [2]-Element array specifying which energy bins to plot
;                             {e.g. [0,9] plots the 10 highest energy bins for the
;                              Eesa and Pesa instruments and SST instruments}
;                             [Default = [0,TEMPDAT.NENERGY - 1L]]
;               SCPOT    :  Scalar denoting the spacecraft (SC) potential (POT) 
;                             estimate for the PAD being plotted [eV]
;               VTHERM   :  Scalar denoting the Thermal Velocity for PAD (km/s)
;               WINDOW   :  ** Obsolete **
;
;   CHANGED:  1)  Fixed indexing issue when EBINS[0] Not = 0
;                                                                   [12/08/2008   v1.2.22]
;             2)  Made program capable of handling any unit input and altered method
;                   for determining plot labels
;                                                                   [01/29/2009   v1.2.23]
;             3)  Changed color output
;                                                                   [07/30/2009   v1.2.24]
;             4)  Changed program my_3dp_energy_bins.pro to dat_3dp_energy_bins.pro
;                   and my_str_names.pro to dat_3dp_str_names.pro
;                                                                   [08/05/2009   v1.3.0]
;             5)  Changed charsize constraints to keep within 0.9 < char < 1.1
;                   and output plot structure format and output
;                                                                   [09/18/2009   v1.3.1]
;             6)  Updated man page
;                   and now calls wind_3dp_units.pro
;                                                                   [10/14/2009   v1.4.0]
;             7)  Fixed an issue with plot ranges if ymin = 0.0 and changed
;                   energy bin label positions slightly
;                                                                   [03/02/2011   v1.4.1]
;             8)  Removed dependence on my_3dp_plot_labels.pro and cleaned up
;                                                                   [01/17/2012   v1.5.0]
;             9)  Corrected dummy structure tag name definitions for non-PAD input,
;                   now calls pad.pro, themis_esa_pad.pro, dat_themis_esa_str_names.pro,
;                   and test_wind_vs_themis_esa_struct.pro, and
;                   updated man page
;                                                                   [08/15/2012   v1.6.0]
;            10)  Fixed a bug in test_wind_vs_themis_esa_struct.pro that prevented
;                   the routine from working when TEMPDAT is a pitch-angle structure
;                   returned by pad.pro
;                                                                   [10/02/2014   v1.7.0]
;
;   NOTES:      
;               1)  The following keywords are obselete:  MULTI and OVERPLOT
;               2)  The routine will call pad.pro if the input is not in the correct
;                     format, but will not convert into the bulk flow frame for you
;
;  REFERENCES:  
;               
;
; ADAPTED FROM: padplot.pro    BY: Davin Larson
;   CREATED:  ??/??/????
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  10/02/2014   v1.7.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

PRO my_padplot_both,tempdat,NOCOLOR=nocolor,LIMITS=limits,UNITS=units,COLOR=shades, $
                            LABEL=labels,EBINS=ebins,WINDOW=wins,SCPOT=scpot,       $
                            VTHERM=vtherm

;;----------------------------------------------------------------------------------------
;;  Define some constants and dummy variables
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
notstr_mssg    = 'Must be an IDL structure...'
badstr_themis  = 'Not an appropriate THEMIS ESA structure...'
badstr_wind    = 'Not an appropriate 3DP structure...'
notvdf_msg     = 'Must be an ion velocity distribution IDL structure...'
;;----------------------------------------------------------------------------------------
;;  Check input
;;----------------------------------------------------------------------------------------
IF (N_PARAMS() EQ 0) THEN RETURN
dat            = tempdat[0]   ;;  in case it is an array of structures of the same format
IF (SIZE(dat,/TYPE) NE 8L) THEN BEGIN
  MESSAGE,notstr_mssg[0],/INFORMATIONAL,/CONTINUE
  RETURN
ENDIF
;test0      = test_wind_vs_themis_esa_struct(dat,/NOM)
test0          = test_wind_vs_themis_esa_struct(dat,/NOM)
test1          = test_wind_vs_themis_esa_struct(dat,/NOM,/PAD)
test           = ((test0.(0) + test0.(1)) NE 1) AND ((test1.(0) + test1.(1)) NE 1)
IF (test) THEN BEGIN
  MESSAGE,notvdf_msg,/INFORMATIONAL,/CONTINUE
  RETURN
ENDIF
;;  Check which spacecraft is being used
IF (test0.(0) OR test1.(0)) THEN BEGIN
  ;;-------------------------------------------
  ;; Wind
  ;;-------------------------------------------
  str_names = dat_3dp_str_names(dat)
  yname     = STRUPCASE(str_names.SN)          ;; e.g. 'ELB'
  tn1       = STRUPCASE(STRMID(yname,0L,1L))   ;; -1st letter of structure name
  IF (STRLOWCASE(tn1) EQ 's') THEN BEGIN
    lab_form = '(f10.2)'
    lab_suff = ' keV'
  ENDIF ELSE BEGIN
    lab_form = '(f10.1)'
    lab_suff = ' eV'
  ENDELSE
  pad_func  = 'pad'
ENDIF ELSE BEGIN
  ;;-------------------------------------------
  ;; THEMIS
  ;;-------------------------------------------
  str_names = dat_themis_esa_str_names(dat)
  yname     = STRUPCASE(str_names.SN)          ;; e.g. 'PEIB'
  tn1       = STRUPCASE(STRMID(yname,1L,2L))   ;; 2nd 2 letters of structure name
  IF (STRMID(STRLOWCASE(tn1),0,1) EQ 's') THEN BEGIN
    lab_form = '(f10.2)'
    lab_suff = ' keV'
  ENDIF ELSE BEGIN
    lab_form = '(f10.1)'
    lab_suff = ' eV'
  ENDELSE
  pad_func  = 'themis_esa_pad'
ENDELSE

ulen           = STRLEN(tempdat.DATA_NAME)              ;; length of string for tempdat.DATA_NAME
ungd           = STRMID(tempdat.DATA_NAME,ulen-3,3)     ;; last 3 characters of tempdat.DATA_NAME
IF KEYWORD_SET(limits) THEN BEGIN
  str_element,limits,'UNITS','FLUX',/ADD_REPLACE
  limits2 = limits
  str_element,limits2,'UNITS','EFLUX',/ADD_REPLACE
ENDIF
;;----------------------------------------------------------------------------------------
;;  Determine plot units and labels
;;----------------------------------------------------------------------------------------
IF KEYWORD_SET(units) THEN uname = STRLOWCASE(units) ELSE uname = 'flux'
new_units      = wind_3dp_units(uname)
gunits         = new_units.G_UNIT_NAME      ;;  e.g. 'flux'
punits         = new_units.G_UNIT_P_NAME    ;;  e.g. ' (# cm!U-2!Ns!U-1!Nsr!U-1!NeV!U-1!N)'
unit_name1     = STRUPCASE(gunits)
punits_1       = punits
CASE STRLOWCASE(gunits) OF
  'counts' : BEGIN
    unit_name2 = 'FLUX'
    punits_2   = '(# cm!U-2!Ns!U-1!Nsr!U-1!NeV!U-1!N)'
  END
  'flux'   : BEGIN
    unit_name2 = 'EFLUX'
    punits_2   = '(eV cm!U-2!Ns!U-1!Nsr!U-1!NeV!U-1!N)'
  END
  'eflux'  : BEGIN
    unit_name2 = 'E2FLUX'
    punits_2   = '(eV!U2!N cm!U-2!Ns!U-1!Nsr!U-1!NeV!U-1!N)'
  END
  'df'     : BEGIN
    unit_name2 = 'FLUX'
    punits_2   = '(# cm!U-2!Ns!U-1!Nsr!U-1!NeV!U-1!N)'
  END
  ELSE     : BEGIN
    ;; Use Default
    unit_name1 = 'FLUX'
    punits_1   = '(# cm!U-2!Ns!U-1!Nsr!U-1!NeV!U-1!N)'
    unit_name2 = 'EFLUX'
    punits_2   = '(eV cm!U-2!Ns!U-1!Nsr!U-1!NeV!U-1!N)'
  END
ENDCASE
;;----------------------------------------------------------------------------------------
;;  Check units and structure format
;;----------------------------------------------------------------------------------------
IF (ungd EQ 'PAD') THEN BEGIN
  dato    = conv_units(tempdat,STRLOWCASE(unit_name1))
  dat2o   = conv_units(tempdat,STRLOWCASE(unit_name2))
  dat     = dato
  dat2    = dat2o
ENDIF ELSE BEGIN
  ;;  Call pitch-angle calculation routine
  dato    = conv_units(tempdat,STRLOWCASE(unit_name1))
  dat2o   = conv_units(tempdat,STRLOWCASE(unit_name2))
  dat     = CALL_FUNCTION(pad_func[0],dato)
  dat2    = CALL_FUNCTION(pad_func[0],dat2o)
  str_element,limits, 'UNITS',STRLOWCASE(unit_name1),/ADD_REPLACE
  limits2 = limits
  str_element,limits2,'UNITS',STRLOWCASE(unit_name2),/ADD_REPLACE
ENDELSE
;;----------------------------------------------------------------------------------------
;;  Make sure energies haven't been labeled as zeros
;;----------------------------------------------------------------------------------------
IF KEYWORD_SET(ebins) THEN BEGIN
  ebins2 = ebins
ENDIF ELSE BEGIN
  ebins2 = [0,dat.NENERGY-1L]
ENDELSE

my_ens         = dat_3dp_energy_bins(dat,EBINS=ebins2)
estart         = my_ens.E_BINS[0]
eend           = my_ens.E_BINS[1]
myen           = my_ens.ALL_ENERGIES
newbins        = [estart,eend]
diffen         = eend[0] - estart[0] + 1L
mebins         = INTARR(diffen)
FOR i=0L, diffen[0] - 1L DO BEGIN
  j = i[0] + estart[0]
  mebins[i] = j[0]
ENDFOR
;;----------------------------------------------------------------------------------------
;  -Define energy bin values and plot labels
;;----------------------------------------------------------------------------------------
mlabs          = STRTRIM(STRING(FORMAT=lab_form[0],myen),2)+lab_suff[0]
;;----------------------------------------------------------------------------------------
;;  Create two data sets based upon the two different sets of units
;;----------------------------------------------------------------------------------------
ytitle         = yname+' '+unit_name1+' '+punits_1
ytitle2        = yname+' '+unit_name2+' '+punits_2
nb             = dat.NBINS
nb2            = dat2.NBINS
title          = dat.PROJECT_NAME+'!C'+dat.DATA_NAME
title          = title+'!C'+trange_str(dat.TIME,dat.END_TIME)
xtitle         = 'Pitch Angle  (degrees)'
xtitle2        = 'Pitch Angle  (degrees)'
ydat           = TRANSPOSE(dat.DATA)
xdat           = TRANSPOSE(dat.ANGLES)
ydat2          = TRANSPOSE(dat2.DATA)
xdat2          = TRANSPOSE(dat2.ANGLES)
;;----------------------------------------------------------------------------------------
;;  Make sure ydata does not have any "zeroed" data
;;----------------------------------------------------------------------------------------
by11           = WHERE(ydat  LE 0.0,b11)
by22           = WHERE(ydat2 LE 0.0,b22)
IF (b11 GT 0) THEN bind = ARRAY_INDICES(ydat,by11)
IF (b11 GT 0) THEN ydat[bind[0,*],bind[1,*]] = f
IF (b22 GT 0) THEN bind = ARRAY_INDICES(ydat2,by22)
IF (b22 GT 0) THEN ydat2[bind[0,*],bind[1,*]] = f
;;----------------------------------------------------------------------------------------
;;  Make sure y-limits are not determined by "zeroed" data or NAN's
;;----------------------------------------------------------------------------------------
gy11           = WHERE(ydat[*,mebins] NE 0.0 AND FINITE(ydat[*,mebins]),g11)
gy22           = WHERE(ydat2[*,mebins] NE 0.0 AND FINITE(ydat2[*,mebins]),g22)
IF (g11 EQ 0 OR g11*1.0 LT 0.1*dat.NBINS*dat.NENERGY) THEN BEGIN
;  PRINT,''
;  PRINT,'Not enough finite data for plotting!'
;  PRINT,''
  MESSAGE,'Not enough finite data for plotting!',/INFORMATIONAL,/CONTINUE
  RETURN
ENDIF
IF (g11 GT 0) THEN BEGIN
  gyind1 = ARRAY_INDICES(ydat,gy11)
  ymin   = MIN(ydat[gyind1[0,*],mebins[REFORM(gyind1[1,*])]],/NAN)/1.1
  ymax   = MAX(ydat[gyind1[0,*],mebins[REFORM(gyind1[1,*])]],/NAN)*1.1  
ENDIF ELSE BEGIN
  ymin   = MIN(ydat,/NAN)/1.1
  ymax   = MAX(ydat,/NAN)*1.1
ENDELSE
IF (g22 GT 0) THEN BEGIN
  gyind2 = ARRAY_INDICES(ydat2,gy22)
  ymin2  = MIN(ydat2[gyind2[0,*],mebins[REFORM(gyind2[1,*])]],/NAN)/1.1
  ymax2  = MAX(ydat2[gyind2[0,*],mebins[REFORM(gyind2[1,*])]],/NAN)*1.1
ENDIF ELSE BEGIN
  ymin2  = MIN(ydat2,/NAN)/1.1
  ymax2  = MAX(ydat2,/NAN)*1.1
ENDELSE
;;----------------------------------------------------------------------------------------
;;  If the following two keywords are set, then they are added as title2
;;----------------------------------------------------------------------------------------
IF KEYWORD_SET(SCPOT) THEN BEGIN
  mysc = 'SC Potential : '+STRTRIM(STRING(format='(f10.2)',scpot),1)+' eV'
ENDIF ELSE mysc = ''
IF KEYWORD_SET(VTHERM) THEN BEGIN
  myvt = '  Thermal Speed: '+STRTRIM(STRING(format='(f10.2)',vtherm),1)+' km/s'
ENDIF ELSE myvt = ''

title2         = mysc[0]+myvt[0]
;;  If plot range is bad, then change it
IF (ymin LE 0. OR ymax LE 0.) THEN BEGIN
  ymin   = 1e-30
  ymax   = 1e0
ENDIF

IF (ymin2 LE 0. OR ymax2 LE 0.) THEN BEGIN
  ymin2  = 1e-30
  ymax2  = 1e0
ENDIF

;;  Define plot margins based upon current device settings
IF (STRLOWCASE(!D.NAME) EQ 'x') THEN xmarg = [10,15] ELSE xmarg = [10,10]
;;  Define a plot limits structure for first plot (top panel)
IF (FINITE(ymin) AND FINITE(ymax) AND ymin GT 0. AND ymax GT 0.) THEN BEGIN
  plotlim = {TITLE:title,XMINOR:9,XTICKNAME:['0','45','90','135','180'], $
             XTITLE:xtitle,XMARGIN:xmarg,XSTYLE:1,XRANGE:[0.,180.],      $
             XTICKV:[0.,45.,90.,135.,180.], XTICKS:4,YMINOR:9,YSTYLE:1,  $
             YTITLE:ytitle,YMARGIN:[3,5],YLOG:1,YRANGE:[ymin,ymax]        }
ENDIF ELSE BEGIN  
  plotlim = {TITLE:title,XMINOR:9,XTICKNAME:['0','45','90','135','180'], $
             XTITLE:xtitle,XMARGIN:xmarg,XSTYLE:1,XRANGE:[0.,180.],      $
             XTICKV:[0.,45.,90.,135.,180.], XTICKS:4,YMINOR:9,YSTYLE:1,  $
             YTITLE:ytitle,YMARGIN:[3,5],YLOG:1                           }
ENDELSE

;;  Define a plot limits structure for second plot (bottom panel)
IF (FINITE(ymin2) AND FINITE(ymax2) AND ymin2 GT 0. AND ymax2 GT 0.) THEN BEGIN
  plot2lim = plotlim
  str_element,plot2lim,'XTITLE',xtitle2,/ADD_REPLACE
  str_element,plot2lim,'YTITLE',ytitle2,/ADD_REPLACE
  str_element,plot2lim,'TITLE',title2,/ADD_REPLACE
  str_element,plot2lim,'YRANGE',[ymin2,ymax2],/ADD_REPLACE
ENDIF ELSE BEGIN
  plot2lim = {TITLE:title2,XMINOR:9,XTICKNAME:['0','45','90','135','180'], $
              XTITLE:xtitle2,XMARGIN:xmarg,XSTYLE:1,XRANGE:[0.,180.],      $
              XTICKV:[0.,45.,90.,135.,180.], XTICKS:4,YMINOR:9,YSTYLE:1,   $
              YTITLE:ytitle2,YMARGIN:[4,3],YLOG:1                           }
ENDELSE
IF (title2 EQ '') THEN str_element,plot2lim,'TITLE',/DELETE
;;----------------------------------------------------------------------------------------
;;  Get plot labels and label positions
;;----------------------------------------------------------------------------------------
nb         = dat.NBINS     ;;  # of pitch-angle bins used
n_e        = diffen[0]     ;;  # of energy bins used
posi0      = FLTARR(n_e,2)
posi2      = FLTARR(n_e,2)

yran1      = ALOG10(plotlim.YRANGE)
yran2      = ALOG10(plot2lim.YRANGE)
yposi1     = FINDGEN(n_e)*(MAX(yran1,/NAN) - MIN(yran1,/NAN))/(n_e - 1L) + MIN(yran1,/NAN)
yposi2     = FINDGEN(n_e)*(MAX(yran2,/NAN) - MIN(yran2,/NAN))/(n_e - 1L) + MIN(yran2,/NAN)
xposi      = 185.

posi0[*,0] = xposi[0]
posi2[*,0] = xposi[0]
posi0[*,1] = 1e1^(yposi1)
posi2[*,1] = 1e1^(yposi2)
mylabs     = mlabs[mebins]

IF NOT KEYWORD_SET(wins) THEN wins = 1
;;----------------------------------------------------------------------------------------
;;  Plot data
;;----------------------------------------------------------------------------------------
!P.MULTI     = [0,1,2]
charsize     = !P.CHARSIZE
IF (charsize GT 1.1 OR charsize LT 0.9) THEN BEGIN
  charsize = 1.0
ENDIF ELSE BEGIN
  charsize = charsize
ENDELSE
str_element,plotlim, 'CHARSIZE',charsize,/ADD_REPLACE
str_element,plot2lim,'CHARSIZE',charsize,/ADD_REPLACE
;;  Define colors for each energy bin
my_colors = LINDGEN(diffen)*(250L - 30L)/(diffen - 1L) + 30L

;;  Plot 1st PAD with 1st units
PLOT,xdat[*,0],ydat[*,0],/NODATA,_EXTRA=plotlim
  FOR j=0L, diffen-1L DO BEGIN
    i = j + estart
    OPLOT,xdat[*,i],ydat[*,i],COLOR=my_colors[j]
    OPLOT,xdat[*,i],ydat[*,i],COLOR=my_colors[j],psym=2,symsize=0.8
    XYOUTS,posi0[j,0],posi0[j,1],mylabs[j],/DATA,COLOR=my_colors[j]
  ENDFOR

;;  Plot 2nd PAD with 2nd units
PLOT,xdat2[*,0],ydat2[*,0],/NODATA,_EXTRA=plot2lim
  FOR j=0L, diffen-1L DO BEGIN
    i = j + estart
    OPLOT,xdat2[*,i],ydat2[*,i],COLOR=my_colors[j]
    OPLOT,xdat2[*,i],ydat2[*,i],COLOR=my_colors[j],psym=2,symsize=0.8
    XYOUTS,posi2[j,0],posi2[j,1],mylabs[j],/DATA,COLOR=my_colors[j]
  ENDFOR
;;  Reset !P.MULTI
!P.MULTI = 0
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN
END

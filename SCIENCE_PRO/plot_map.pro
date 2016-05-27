;+
;*****************************************************************************************
;
;  FUNCTION :   plot_map.pro
;  PURPOSE  :   Plot the map from the standard 3-D data structure that is returned
;                 from the IDL from SDT interface.  The THETA, PHI, DTHETA, DPHI,
;                 DATA_NAME and PROJECT_NAME tags must exist for this routine to work.
;                 (The standard 3-D data structure should contain these.)
;
;  CALLED BY:   
;               NA
;
;  CALLS:
;               test_wind_vs_themis_esa_struct.pro
;               dat_3dp_str_names.pro
;               dat_themis_esa_str_names.pro
;               routine_version.pro
;               time_string.pro
;
;  REQUIRES:    
;               1)  THEMIS TDAS IDL libraries or UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               DAT       :  3DP data structure(s) either from get_??.pro
;                              [?? = el, elb, phb, sf, etc.]
;
;  EXAMPLES:    
;               NA
;
;  KEYWORDS:    
;               DEFTICKS  :  If set, program uses a default set of [X,Y]-Axis tick mark
;                              labels (makes for a nice looking plot) and axes ranges
;               COORD     :  Scalar that defines the coordinate system associated with
;                              the [theta,phi]-angle bins in DAT
;                              [Default = 'GSE']
;
;   CHANGED:  1)  Added error handling specific to data structure [08/22/1995   v1.0.1]
;             2)  Cleaned up, updated man page...                 [01/13/2012   v1.1.0]
;             3)  Changed angle bin corner calculations           [01/14/2012   v1.2.0]
;             4)  Updated to be in accordance with newest version of plot_map.pro
;                   in TDAS IDL libraries
;                   A)  Cleaned up and added some comments
;                   B)  Changed error handling to accomodate THEMIS ESA structures
;                   C)  No longer calls test_3dp_struc_format.pro, instead calls
;                         test_wind_vs_themis_esa_struct.pro and
;                         dat_themis_esa_str_names.pro
;                                                                  [08/07/2012   v1.3.0]
;             5)  Added keyword COORD and version number to output and
;                   now calls routine_version.pro
;                                                                  [08/11/2012   v1.4.0]
;
;   NOTES:      
;               1)  So long as the data structure has the same structure tags, this
;                     routine should plot the data bins in [theta vs. phi]-space
;               2)  The default axes tick marks for the THEMIS ESA structures assume the
;                     input is in DSL coordinates
;
;   CREATED:  ??/??/????
;   CREATED BY:  Jonathan M. Loran
;    LAST MODIFIED:  08/11/2012   v1.4.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

PRO plot_map,dat,DEFTICKS=defticks,COORD=coord

;;----------------------------------------------------------------------------------------
;; => Define some constants and dummy variables
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
;;-------------------------------------------
;; => Define some default plot parameters
;;-------------------------------------------
def_xtn0 = ['0','30','60','90','120','150','180','210','240','270','300','330','360']
def_xtn1 = ['390','420','450','480','510','540','570','600','630','660','690','720']
def_xtna = [def_xtn0,def_xtn1]
def_xtv0 = [0e0,3e1,6e1,9e1,12e1,15e1,18e1,21e1,24e1,27e1,30e1,33e1,36e1]
def_xtv1 = [39e1,42e1,45e1,48e1,51e1,54e1,57e1,60e1,63e1,66e1,69e1,72e1]
def_xtva = [def_xtv0,def_xtv1]
def_xtsa = N_ELEMENTS(def_xtva) - 1L

def_xtvW = [0e0,3e1,6e1,9e1,12e1,15e1,18e1,21e1,24e1,27e1,30e1,33e1,36e1]
def_xtnW = ['0','30','60','90','120','150','180','210','240','270','300','330','360']
def_xtvT = [9e1,12e1,15e1,18e1,21e1,24e1,27e1,30e1,33e1,36e1,39e1,42e1,45e1]
def_xtnT = ['90','120','150','180','210','240','270','300','330','360','390','420','450']

def_xts  = N_ELEMENTS(def_xtv) - 1L
def_ytv  = [-9e1,-6e1,-3e1, 0e0, 3e1, 6e1, 9e1]
def_ytn  = ['-90','-60','-30','0','30','60','90']
def_yts  = N_ELEMENTS(def_ytv) - 1L
def_yran = [-9e1,9e1]
;;-------------------------------------------
;; => Dummy error messages
;;-------------------------------------------
notstr_msg     = 'Must be an IDL structure from Wind/3DP or THEMIS/ESA...'
badesa_mssg    = 'Not an appropriate ESA structure...'
bad3dp_mssg    = 'Not an appropriate 3DP structure...'
;;----------------------------------------------------------------------------------------
;; => Check keywords
;;----------------------------------------------------------------------------------------
IF ~KEYWORD_SET(coord) THEN cord = 'GSE' ELSE cord = STRUPCASE(coord[0])
;;----------------------------------------------------------------------------------------
;; => Check input
;;----------------------------------------------------------------------------------------
IF (N_PARAMS() EQ 0) THEN RETURN
data  = dat[0]   ; => in case it is an array of structures of the same format
;;----------------------------------------------------------------------------------------
;; => Check DAT structure format
;;----------------------------------------------------------------------------------------
test0      = test_wind_vs_themis_esa_struct(data,/NOM)
test       = (test0.(0) + test0.(1)) NE 1
IF (test) THEN BEGIN
  MESSAGE,notstr_msg[0],/INFORMATIONAL,/CONTINUE
  ;; => Create empty plot
  !P.MULTI = 0
  PLOT,[0.0,1.0],[0.0,1.0],/NODATA
  RETURN
ENDIF
;; => Check which spacecraft is being used
IF (test0.(0)) THEN BEGIN
  ;;-------------------------------------------
  ;; Wind
  ;;-------------------------------------------
  ; => Check which instrument is being used
  strn   = dat_3dp_str_names(data[0])
  IF (SIZE(strn,/TYPE) NE 8) THEN BEGIN
    MESSAGE,bad3dp_mssg[0],/INFORMATIONAL,/CONTINUE
    ;; => Create empty plot
    !P.MULTI = 0
    PLOT,[0.0,1.0],[0.0,1.0],/NODATA
    RETURN
  ENDIF
  ;; => Know structure is valid now
  IF (STRMID(strn.SN[0],0,2) EQ 'ph') THEN BEGIN
    def_xran = [-4e1,37e1]
    def_xtv  = [-3e1,def_xtvW]
    def_xtn  = ['-30',def_xtnW]
  ENDIF ELSE BEGIN
    def_xran = [-2e0,36e1]
  ENDELSE
ENDIF ELSE BEGIN
  ;;-------------------------------------------
  ;; THEMIS ESA
  ;;-------------------------------------------
  ; => Check which instrument is being used
  strn   = dat_themis_esa_str_names(data[0])
  IF (SIZE(strn,/TYPE) NE 8) THEN BEGIN
    MESSAGE,badesa_mssg[0],/INFORMATIONAL,/CONTINUE
    ;; => Create empty plot
    !P.MULTI = 0
    PLOT,[0.0,1.0],[0.0,1.0],/NODATA
    RETURN
  ENDIF
  ;; => Know structure is valid now
  temp   = (STRMID(strn.SN[0],0,3) EQ 'pei') OR (STRMID(strn.SN[0],0,3) EQ 'pee')
  IF (temp) THEN BEGIN
    def_xran = [ 9e1,45e1]
    def_xtv  = def_xtvT
    def_xtn  = def_xtnT
  ENDIF ELSE BEGIN
    def_xran = [-2e0,36e1]
  ENDELSE
ENDELSE
;;########################################################################################
;; => Define version for output
;;########################################################################################
mdir     = FILE_EXPAND_PATH('wind_3dp_pros/SCIENCE_PRO/')+'/'
file     = 'plot_map.pro'
version  = routine_version(file,mdir)
;;----------------------------------------------------------------------------------------
;; => Define angle parameters
;;----------------------------------------------------------------------------------------
n_a      = data.NBINS        ; => # of angle bins
minph0   = data.PHI - data.DPHI/2e0
maxph0   = data.PHI + data.DPHI/2e0
minthet0 = data.THETA - data.DTHETA/2e0
maxthet0 = data.THETA + data.DTHETA/2e0
;; => Average over energies
minphi   = TOTAL(minph0,1,/NAN)/TOTAL(FINITE(minph0),1)
maxphi   = TOTAL(maxph0,1,/NAN)/TOTAL(FINITE(maxph0),1)
mintheta = TOTAL(minthet0,1,/NAN)/TOTAL(FINITE(minthet0),1)
maxtheta = TOTAL(maxthet0,1,/NAN)/TOTAL(FINITE(maxthet0),1)
;; => Define plot limits
minx     = MIN(minphi,/NAN)
maxx     = MAX(maxphi,/NAN)
miny     = MIN(mintheta,/NAN)
maxy     = MAX(maxtheta,/NAN)
;;----------------------------------------------------------------------------------------
;; => Define default tick marks
;;----------------------------------------------------------------------------------------
goodphi  = WHERE(def_xtva GE minx[0] AND def_xtva LE maxx[0],gdp)
goodthe  = WHERE(def_ytv  GE miny[0] AND def_ytv  LE maxy[0],gdt)
IF (gdp GT 2) THEN BEGIN
  ;;---------------------------------------------------
  ;;  Check to see how close ranges are to tick marks
  ;;---------------------------------------------------
  diffmn   = MIN(ABS(def_xtva[goodphi] - minx[0]),/NAN) GT 15e0
  diffmx   = MIN(ABS(def_xtva[goodphi] - maxx[0]),/NAN) GT 15e0
  testlow  = diffmn[0] AND (MIN(goodphi) GT 0)
  IF (testlow) THEN BEGIN
    ;;  Add tick mark to low end
    goodphi = [MIN(goodphi) - 1L,goodphi]
    gdp    += 1L
  ENDIF
  testhigh = diffmx[0] AND (MAX(goodphi) lT def_xtsa[0])
  IF (testhigh) THEN BEGIN
    ;;  Add tick mark to high end
    goodphi = [goodphi,MAX(goodphi) + 1L]
    gdp    += 1L
  ENDIF
  ;;---------------------------------------------------
  ;;  Change default azimuthal angle tick marks
  ;;---------------------------------------------------
  def_xtv  = def_xtva[goodphi]
  def_xtn  = def_xtna[goodphi]
  ;;  Change default azimuthal angle axis range
  def_xran = [(MIN(def_xtv) < minx[0]),(MAX(def_xtv) > maxx[0])]
ENDIF
def_xts  = N_ELEMENTS(def_xtv) - 1L

IF (gdt GT 2) THEN BEGIN
  ;;---------------------------------------------------
  ;;  Check to see how close ranges are to tick marks
  ;;---------------------------------------------------
  diffmn   = MIN(ABS(def_ytv[goodthe] - miny[0]),/NAN) GT 15e0
  diffmx   = MIN(ABS(def_ytv[goodthe] - maxy[0]),/NAN) GT 15e0
  testlow  = diffmn[0] AND (MIN(goodthe) GT 0)
  IF (testlow) THEN BEGIN
    ;;  Add tick mark to low end
    goodthe = [MIN(goodthe) - 1L,goodthe]
    gdt    += 1L
  ENDIF
  testhigh = diffmx[0] AND (MAX(goodthe) lT def_yts[0])
  IF (testhigh) THEN BEGIN
    ;;  Add tick mark to high end
    goodthe = [goodthe,MAX(goodthe) + 1L]
    gdt    += 1L
  ENDIF
  ;;---------------------------------------------------
  ;;  Change default poloidal angle tick marks
  ;;---------------------------------------------------
  def_ytv  = def_ytv[goodthe]
  def_ytn  = def_ytn[goodthe]
  def_yts  = N_ELEMENTS(def_ytv) - 1L
ENDIF
;;----------------------------------------------------------------------------------------
;; => Set up plot limit structure
;;----------------------------------------------------------------------------------------
time = time_string(data.TIME,PREC=3)
;; => Define plot title and axes titles
ttle = 'Angle Map of: '+data.PROJECT_NAME+', '+data.DATA_NAME
ttle = ttle[0]+'!C'+'at '+time[0]+' UT'
xttl = 'Phi ['+cord[0]+', degrees]'
yttl = 'Theta ['+cord[0]+', degrees]'
IF NOT KEYWORD_SET(defticks) THEN BEGIN
  ;; => Define axes ranges
  xran = [minx[0], maxx[0]]
  yran = [miny[0], maxy[0]]
  ;; => Define plot limit structure
  pstr = {NODATA:1,XSTYLE:1,YSTYLE:1,XMINOR:6,YMINOR:6,                  $
          XTICKLEN:0.02,YTICKLEN:0.02,XTITLE:xttl,YTITLE:yttl,TITLE:ttle }
ENDIF ELSE BEGIN
  ;; => Define axes ranges
  xran = def_xran
  yran = def_yran
  ;; => Define plot limit structure
  pstr = {NODATA:1,XSTYLE:2,YSTYLE:2,XMINOR:6,YMINOR:6,                   $
          XTICKLEN:0.02,YTICKLEN:0.02,XTITLE:xttl,YTITLE:yttl,TITLE:ttle, $
          YTICKNAME:def_ytn,YTICKV:def_ytv,YTICKS:def_yts,                $
          XTICKNAME:def_xtn,XTICKV:def_xtv,XTICKS:def_xts}
ENDELSE
;;----------------------------------------------------------------------------------------
;; => Plot
;;----------------------------------------------------------------------------------------
!P.MULTI = 0
PLOT,[0.0,1.0],[0.0,1.0],_EXTRA=pstr,YMARGIN=[4.,4.],XMARGIN=[10.,5.],$
     XRANGE=xran,YRANGE=yran

FOR j=0L, n_a - 1L DO BEGIN
  ;; => Define corners of angle bins
  xlocs = [minphi[j], maxphi[j], maxphi[j], minphi[j], minphi[j]]
  ylocs = [mintheta[j], mintheta[j], maxtheta[j], maxtheta[j], mintheta[j]]
  ;; => Plot angle bins
  OPLOT,xlocs,ylocs,LINESTYLE=3
  ;; => Mark bin #'s
  IF (j GE 10) THEN xshft = data.DPHI[0,j]/4e0 ELSE xshft = 0e0
  xposi = (minphi[j] + maxphi[j])/2. + xshft[0]
  yposi = (mintheta[j] + maxtheta[j])/2.
  XYOUTS,xposi[0],yposi[0],ALIGN=1.0,STRING(j),/DATA
ENDFOR
;;----------------------------------------------------------------------------------------
;; => Output version # and date produced
;;----------------------------------------------------------------------------------------
XYOUTS,0.985,0.06,version[0],CHARSIZE=.65,/NORMAL,ORIENTATION=90.
;;----------------------------------------------------------------------------------------
;; => Return
;;----------------------------------------------------------------------------------------

RETURN
END

;+
;*****************************************************************************************
;
;  FUNCTION :   pesa_high_str_fill.pro
;  PURPOSE  :   The purpose of this program is to combine multiple Pesa High structures
;                 from the Wind 3DP instrument when one calls data from multiple days.
;                 The result is often that there are data structures with differing
;                 mapcodes on different days.  So in an attempt to automate the process
;                 of calling multiple days, this program attempts to elliminate that
;                 problem.  It creates an 
;
;
;               MAPCODE      HEX CODE       # of Data bins
;               ==========================================
;               54436L        'D4A4'              121
;               54526L        'D4FE'               97
;               54764L        'D5EC'               56
;               54971L        'D6BB'               65
;               54877L        'D65D'               88
;
;  CALLED BY: 
;               get_padspecs.pro
;
;  CALLS:
;               pesa_high_bad_bins.pro
;               dat_3dp_str_names.pro
;               pesa_high_dummy_str.pro
;               str_element.pro
;
;  REQUIRES:    NA
;
;  INPUT:
;               NDATA    :  Set to a named variable to be returned as an N-element array 
;                             of Pesa High structures of one format to be filled by up to
;                             three other structures of other formats
;                           **[Different mapcodes lead to different #'s of data bins]**
;
;  EXAMPLES:    NA
;
;  KEYWORDS:  
;               DUM1     :  N-Element array of Pesa High(Burst) data structures
;               DUM2     :  Same as DUM1
;               DUM3     :  Same as DUM1
;               NAME     :  [string] Specify the type of structure you wish to 
;                             use [i.e. 'el','eh','elb',etc.]
;
;   CHANGED:  1)  Removed Inputs: MAPCODE, NDAT, and NAME     [04/26/2009   v1.1.0]
;             2)  Added keyword:  NAME                        [04/26/2009   v1.1.1]
;             3)  Fixed a minor syntax error                  [06/25/2009   v1.1.2]
;             4)  Changed program my_str_names.pro to dat_3dp_str_names.pro
;                   and renamed                               [08/10/2009   v2.0.0]
;             5)  Fixed a minor syntax error with DATA_NAME tag
;                                                             [04/09/2010   v2.0.1]
;
;   CREATED:  04/24/2009
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  04/09/2010   v2.0.1
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

PRO pesa_high_str_fill,ndata,NAME=name,DUM1=dum1,DUM2=dum2,DUM3=dum3

;-----------------------------------------------------------------------------------------
; -Determine mapcode
;-----------------------------------------------------------------------------------------
IF KEYWORD_SET(dum1) THEN dnb1  = dum1[0].NBINS ELSE dnb1 = 0
IF KEYWORD_SET(dum2) THEN dnb2  = dum2[0].NBINS ELSE dnb2 = 0
IF KEYWORD_SET(dum3) THEN dnb3  = dum3[0].NBINS ELSE dnb3 = 0

nbins = MAX([dnb1,dnb2,dnb3],/NAN)
CASE nbins OF
  121  :  BEGIN
    mapcode = 54436L
    ndat    = 121L
  END
  97   :  BEGIN
    mapcode = 54526L
    ndat    = 97L
  END
  56   :  BEGIN
    mapcode = 54764L
    ndat    = 56L
  END
  65   :  BEGIN
    mapcode = 54971L
    ndat    = 65L
  END
  88   :  BEGIN
    mapcode = 54877L
    ndat    = 88L
  END
  ELSE : BEGIN
    MESSAGE,'Unknown Structure Format!',/INFORMATION,/CONTINUE
    RETURN
  END
ENDCASE
;-----------------------------------------------------------------------------------------
; -Make sure name is in the correct format
;-----------------------------------------------------------------------------------------
IF NOT KEYWORD_SET(name) THEN BEGIN
  strns    = dat_3dp_str_names(dum1[0].DATA_NAME)
  name     = strns.LC
  data_str = name
ENDIF ELSE BEGIN
  data_str = STRLOWCASE(name)
  strns    = dat_3dp_str_names(data_str)
  name     = strns.LC
ENDELSE
;-----------------------------------------------------------------------------------------
; => Create Dummy variables
;-----------------------------------------------------------------------------------------
f      = !VALUES.F_NAN
d      = !VALUES.D_NAN
ndata  = pesa_high_dummy_str(name,ndat,mapcode)
str_element,ndata,'VSW',REPLICATE(f,3L),/ADD_REPLACE
;nstr   = N_ELEMENTS(ndata)
dum_t  = ['PROJECT_NAME','DATA_NAME','UNITS_NAME','UNITS_PROCEDURE',       $
             'TIME','END_TIME','TRANGE','INTEG_T','DELTA_T','DEADTIME',    $
             'DT','VALID','SPIN','SHIFT','INDEX','MAPCODE','DOUBLE_SWEEP', $
             'NENERGY','NBINS','BINS','PT_MAP','DATA','ENERGY',            $
             'DENERGY','PHI','DPHI','THETA','DTHETA','BKGRATE',            $
             'DVOLUME','DDATA','DOMEGA','DACCODES','VOLTS','MASS',         $
             'GEOMFACTOR','GF','MAGF','SC_POT']

IF KEYWORD_SET(dum1) THEN mydim1 = SIZE(dum1.DATA,/DIMENSIONS) ELSE mydim1 = 0
IF KEYWORD_SET(dum2) THEN mydim2 = SIZE(dum2.DATA,/DIMENSIONS) ELSE mydim2 = 0
IF KEYWORD_SET(dum3) THEN mydim3 = SIZE(dum3.DATA,/DIMENSIONS) ELSE mydim3 = 0

IF (mydim1[0] NE 0) THEN BEGIN
  nde1     = mydim1[0]         ; -# of energy bins in each moment
  ndx1     = mydim1[1]         ; -# of data bins per energy bin
  nstr1    = N_ELEMENTS(dum1)  ; => # of data structures
  dat1     = dum1
  tag1     = TAG_NAMES(dat1)
  pesa_high_bad_bins,dat1
ENDIF ELSE BEGIN
  nde1     = 0
  ndx1     = 0
  nstr1    = 0
  dat1     = ndata[0]
  tag1     = ''
ENDELSE

IF (mydim2[0] NE 0) THEN BEGIN
  nde2     = mydim2[0]  ; -# of energy bins in each moment
  ndx2     = mydim2[1]  ; -# of data bins per energy bin
  nstr2    = N_ELEMENTS(dum2)
  dat2     = dum2
  tag2     = TAG_NAMES(dat2)
  pesa_high_bad_bins,dat2
ENDIF ELSE BEGIN
  nde2     = 0
  ndx2     = 0
  nstr2    = 0
  dat2     = ndata[0]
  tag2     = ''
ENDELSE

IF (mydim3[0] NE 0) THEN BEGIN
  nde3     = mydim3[0]  ; -# of energy bins in each moment
  ndx3     = mydim3[1]  ; -# of data bins per energy bin
  nstr3    = N_ELEMENTS(dum3)
  dat3     = dum3
  tag3     = TAG_NAMES(dat3)
  pesa_high_bad_bins,dat3
ENDIF ELSE BEGIN
  nde3     = 0
  ndx3     = 0
  nstr3    = 0
  dat3     = ndata[0]
  tag3     = ''
ENDELSE
all_dat    = CREATE_STRUCT('T0',dat1,'T1',dat2,'T2',dat3)
;-----------------------------------------------------------------------------------------
; => Define new structure with data from other structures of different size
;-----------------------------------------------------------------------------------------
check = [ndx1,ndx2,ndx3]
gchck = WHERE(check GT 0,gch)
anstr = [nstr1,nstr2,nstr3]

n_all = nstr1 + nstr2 + nstr3
IF (n_all NE 0) THEN BEGIN
  nstr  = n_all
  filld = REPLICATE(ndata[0],nstr)
ENDIF ELSE BEGIN
  MESSAGE,'You did not specify any structures to fill...',/INFORMATION,/CONTINUE
  RETURN
ENDELSE

IF (gch GT 0) THEN BEGIN
  cc = 0L
  bb = 0L
  dd = 0L
  FOR j=0L, gch - 1L DO BEGIN
    tdats = all_dat.(gchck[j])
    tnstr = anstr[gchck[j]] - 1L           ; => # of data structures
    n_en  = tdats[0].NENERGY - 1L          ; => # of energy bins in tdats structures
    n_bin = tdats[0].NBINS - 1L            ; => # of data bins in tdats structures
;    eind  = LINDGEN(tdats[0].NENERGY)      ; => Elements of energy to use
    dind  = LINDGEN(tdats[0].NBINS)        ; => " " data to use
    dand  = LINDGEN(tnstr + cc + 1L) + cc  ; => " " fill structure to use
    ; => Tags with constant dimensions
    filld[dand].TIME         = tdats[*].TIME
    filld[dand].END_TIME     = tdats[*].END_TIME
    filld[dand].TRANGE       = tdats[*].TRANGE
    filld[dand].INTEG_T      = tdats[*].INTEG_T
    filld[dand].DELTA_T      = tdats[*].DELTA_T
    filld[dand].PT_MAP       = tdats[*].PT_MAP
    filld[dand].VALID        = tdats[*].VALID
    filld[dand].SPIN         = tdats[*].SPIN
    filld[dand].SHIFT        = tdats[*].SHIFT
    filld[dand].INDEX        = tdats[*].INDEX
    filld[dand].DOUBLE_SWEEP = tdats[*].DOUBLE_SWEEP
    filld[dand].DACCODES     = tdats[*].DACCODES
    filld[dand].VOLTS        = tdats[*].VOLTS
    filld[dand].GEOMFACTOR   = tdats[*].GEOMFACTOR
    filld[dand].MAGF         = tdats[*].MAGF
    filld[dand].VSW          = tdats[*].VSW
    filld[dand].SC_POT       = tdats[*].SC_POT
    ; => Tags with changing dimensions, but not [nener,ndat]-Elements
    filld[dand].DOMEGA[dind] = tdats[*].DOMEGA
    ; => [nener,ndat]-Tags of structures
    filld[dand].DEADTIME[0L:n_en,0L:n_bin]  = tdats[*].DEADTIME
    filld[dand].DT[0L:n_en,0L:n_bin]        = tdats[*].DT
    filld[dand].BINS[0L:n_en,0L:n_bin]      = tdats[*].BINS
    filld[dand].DATA[0L:n_en,0L:n_bin]      = tdats[*].DATA
    filld[dand].ENERGY[0L:n_en,0L:n_bin]    = tdats[*].ENERGY
    filld[dand].DENERGY[0L:n_en,0L:n_bin]   = tdats[*].DENERGY
    filld[dand].PHI[0L:n_en,0L:n_bin]       = tdats[*].PHI
    filld[dand].THETA[0L:n_en,0L:n_bin]     = tdats[*].THETA
    filld[dand].DPHI[0L:n_en,0L:n_bin]      = tdats[*].DPHI
    filld[dand].DTHETA[0L:n_en,0L:n_bin]    = tdats[*].DTHETA
    filld[dand].BKGRATE[0L:n_en,0L:n_bin]   = tdats[*].BKGRATE
    filld[dand].DVOLUME[0L:n_en,0L:n_bin]   = tdats[*].DVOLUME
    filld[dand].DDATA[0L:n_en,0L:n_bin]     = tdats[*].DDATA
    filld[dand].GF[0L:n_en,0L:n_bin]        = tdats[*].GF
  ENDFOR
ENDIF ELSE BEGIN
  MESSAGE,'You did not specify any structures to fill...',/INFORMATION,/CONTINUE
  RETURN
ENDELSE

ndata = filld
RETURN
END
;+
;*****************************************************************************************
;
;  FUNCTION :   div_diff_add_tplot.pro
;  PURPOSE  :   Creates a new TPLOT variable defined by the ratio/difference/addition of 
;                 two TPLOT variables of either vector or scalar form.  Note, this
;                 program will NOT deal with multi-dimensional plots like particle
;                 spectra which have structures with V and V1, V2 as tag names.
;
;  CALLED BY:  
;               NA
;
;  CALLS:
;               store_data.pro
;               options.pro
;               tnames.pro
;               get_data.pro
;               interp.pro
;
;  REQUIRES:    
;               UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               N1             :  A string or scalar associated with a TPLOT variable
;               N2             :  A string or scalar associated with a TPLOT variable
;
;  EXAMPLES:    
;               ; => To divide two TPLOT variables, do the following:
;               tpn1 = tnames(1)
;               tpn2 = tnames(2)
;               div_diff_add_tplot,tpn1,tpn2,/DIVIDE,NEW_NAME=tpn1+'_'+tpn2
;
;  KEYWORDS:  
;               NEW_NAME       :  String defining the new TPLOT name to use when
;                                   storing data in TPLOT
;               DIVIDE         :  If set, creates new tplot_variable of n1/n2
;               DIFF           :  If set, creates new tplot_variable of n1 - n2
;               ADD            :  If set, creates new tplot_variable of n1 + n2
;               INTERP_THRESH  :  Scalar that determines the threshold for data output
;                                   to avoid data spikes when interpolating data
;
;   CHANGED:  1)  Fixed a labeling issue                      [04/24/2009   v1.0.1]
;             2)  Renamed from my_div_diff_add_tplot.pro      [10/13/2009   v2.0.0]
;
;   CREATED:  03/12/2009
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  10/13/2009   v2.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

PRO  div_diff_add_tplot,n1,n2,NEW_NAME=new_name,DIVIDE=divide,DIFF=diff,ADD=add,$
                              INTERP_THRESH=int_th

;*****************************************************************************************
; -Make sure n1 and n2 are the same data type and exist
;*****************************************************************************************
ty1 = SIZE(n1,/TYPE)
ty2 = SIZE(n2,/TYPE)
IF (ty1 NE ty2) THEN BEGIN
  MESSAGE,'Incorrect input format... must be same type',/INFORMATION
  RETURN
ENDIF ELSE BEGIN
  fn = tnames([n1,n2])
  IF (fn[0] NE '' AND fn[1] NE '') THEN BEGIN
    get_data,n1,DATA=d1,LIMIT=lim1
    get_data,n2,DATA=d2,LIMIT=lim2
  ENDIF
ENDELSE
IF NOT KEYWORD_SET(d1) OR NOT KEYWORD_SET(d2) THEN BEGIN
  MESSAGE,/INFO,'data not defined!'
  RETURN
ENDIF
;*****************************************************************************************
; -Determine which data should be used for an abscissa
;*****************************************************************************************
nn1  = N_ELEMENTS(d1.X)
nn2  = N_ELEMENTS(d2.X)
test = nn1 > nn2
CASE test[0L] OF
  nn1  : BEGIN  ; => more data in d1 => downsample d1
    nd1 = interp(d1.Y,d1.X,d2.X,INTERP_THRESH=int_th,/NO_EXTRAP)
    nd2 = d2.Y
    ntt = d2.X
  END
  nn2  : BEGIN  ; => more data in d1 => downsample d1
    nd2 = interp(d2.Y,d2.X,d1.X,INTERP_THRESH=int_th,/NO_EXTRAP)
    nd1 = d1.Y
    ntt = d1.X
  END
ENDCASE
;*****************************************************************************************
; -Determine data dimensions
;*****************************************************************************************
dim1  = SIZE(nd1,/DIMENSIONS)
dim2  = SIZE(nd2,/DIMENSIONS)
ndim1 = N_ELEMENTS(dim1)
ndim2 = N_ELEMENTS(dim2)
ndim  = ndim1 < ndim2  ; -Use data with less dimensions
test  = ndim1 NE ndim2
IF (test) THEN BEGIN
  CASE ndim[0] OF
    ndim1 : BEGIN  ; => Change dimensions of nd1 to match nd2
      nd1 = nd1 # REPLICATE(1.0,dim2[1])
    END
    ndim2 : BEGIN  ; => Change dimensions of nd2 to match nd1
      nd2 = nd2 # REPLICATE(1.0,dim1[1])
    END
  ENDCASE
ENDIF
;*****************************************************************************************
; -See if YTITLEs already exist
;*****************************************************************************************
t_ns1 = TAG_NAMES(lim1)
t_ns2 = TAG_NAMES(lim2)

yttl1 = WHERE(t_ns1 EQ 'YTITLE')
yttl2 = WHERE(t_ns2 EQ 'YTITLE')
IF (yttl1[0] NE -1L AND yttl2[0] NE -1L) THEN BEGIN
  nyttl1 = '('+lim1.(yttl1[0])+')'
  nyttl2 = '('+lim2.(yttl2[0])+')'
ENDIF ELSE BEGIN
  nyttl1 = ''
  nyttl2 = ''
ENDELSE
;*****************************************************************************************
; -Determine which operation to use
;*****************************************************************************************
check  = [KEYWORD_SET(divide),KEYWORD_SET(diff),KEYWORD_SET(add)]
gcheck = WHERE(check GT 0,gch)
IF (gch EQ 0L) THEN gcheck = 0L
IF (gch GT 1L) THEN gcheck = gcheck[0L]
CASE gcheck[0L] OF
  0L  : BEGIN  ; => divide data
    new_dat = nd1/nd2
    tp_name = fn[0]+'/'+fn[1]
    nyttle  = nyttl1+'/'+nyttl2
  END
  1L  : BEGIN  ; => subtract
    new_dat = nd1 - nd2
    tp_name = fn[0]+'-'+fn[1]
    nyttle  = nyttl1+'-'+nyttl2
  END
  2L  : BEGIN  ; => add
    new_dat = nd1 + nd2
    tp_name = fn[0]+'+'+fn[1]
    nyttle  = nyttl1+'+'+nyttl2
  END
ENDCASE
IF NOT KEYWORD_SET(new_name) THEN st_name = tp_name ELSE st_name = new_name
store_data,st_name,DATA={X:ntt,Y:new_dat},LIMIT={YTITLE:nyttle},$
                   DLIMIT={COMMENT:'Derived from: '+fn[0]+' and '+fn[1]}
options,st_name,'YSTYLE',1
options,st_name,'PANEL_SIZE',2.
options,st_name,'XMINOR',5
options,st_name,'XTICKLEN',0.04
RETURN
END
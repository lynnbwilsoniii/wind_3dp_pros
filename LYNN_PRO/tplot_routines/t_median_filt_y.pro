;+
;*****************************************************************************************
;
;  PROCEDURE:   t_median_filt_y.pro
;  PURPOSE  :   This is a TPLOT wrapping routine for MEDIAN.PRO with explicit use of the
;                 normally optional input WIDTH parameter.
;
;  CALLED BY:   
;               NA
;
;  INCLUDES:
;               NA
;
;  CALLS:
;               is_a_number.pro
;               test_tplot_handle.pro
;               get_data.pro
;               tplot_struct_format_test.pro
;               t_get_struc_unix.pro
;               extract_tags.pro
;               store_data.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               TPNAME          :  Scalar [string] defining a valid TPLOT handle the
;                                    user wishes to remove NaNs from the Y tag data
;               WIDTH           :  Scalar [long] defining the number of points to use
;                                    for the median filter in MEDIAN.PRO
;
;  EXAMPLES:    
;               [calling sequence]
;               t_median_filt_y,tpname,width [,EVEN=even] [,NEWNAME=newname]
;
;  KEYWORDS:    
;               EVEN            :  If set, MEDIAN.PRO will compute the average of the
;                                    middle two elements IFF there are an even number of
;                                    elements in the input array.  If there are an odd
;                                    number of elements, then MEDIAN.PRO will return the
;                                    middle element only.
;                                    [Default = MEDIAN.PRO default]
;               NEWNAME         :  Scalar [string] defining the new TPLOT handle to
;                                    use on output instead of overwriting original
;                                    TPLOT handle data
;                                    [Default = TPNAME]
;
;   CHANGED:  1)  NA
;                                                                   [MM/DD/YYYY   v1.0.0]
;
;   NOTES:      
;               1)  If NEWNAME is NOT set, this routine will overwrite the original
;                     TPLOT handled data
;
;  REFERENCES:  
;               https://www.nv5geospatialsoftware.com/docs/median.html
;
;   CREATED:  04/10/2025
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  04/10/2025   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

PRO t_median_filt_y,tpname,width,EVEN=even,NEWNAME=newname

;;----------------------------------------------------------------------------------------
;;  Define some constants and dummy variables
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
;;  Dummy logic variables
test_vv        = 0b
test_vv_2d     = 0b
test_v1        = 0b
test_v2        = 0b
;;  Not extracted tags
excpt_tags     = ['X','Y','V','V1','V2','DY','TSHIFT']
;;  Error messages
noinput_mssg   = 'No input was supplied...'
no_tpns_mssg   = 'No valid TPLOT handle supplied...'
battpdt_mssg   = 'The TPLOT handles supplied did not contain data...'
badndim_mssg   = 'This routine cannot yet handle 4D Y tag arrays...'
badytyp_mssg   = 'The data in the Y tag must be numeric...'
;;----------------------------------------------------------------------------------------
;;  Check input
;;----------------------------------------------------------------------------------------
IF ((N_PARAMS() LT 2) OR (SIZE(tpname,/TYPE) NE 7) OR (is_a_number(width,/NOMSSG) EQ 0)) THEN BEGIN
  MESSAGE,noinput_mssg[0],/INFORMATIONAL,/CONTINUE
  RETURN
ENDIF
testp          = test_tplot_handle(tpname,TPNMS=tpnm)
test           = ~testp[0] OR (tpnm[0] EQ '')
IF (test[0]) THEN BEGIN
  MESSAGE,no_tpns_mssg[0],/INFORMATIONAL,/CONTINUE
  RETURN
ENDIF
;;  Check WIDTH
IF (N_ELEMENTS(width) GT 1) THEN BEGIN
  good           = WHERE(width GE 3,gd)
  IF (gd[0] EQ 0) THEN wdth = 3L ELSE wdth = 3L > (LONG(width[good[0]]))
ENDIF ELSE BEGIN
  wdth           = 3L > (LONG(width[0]))
ENDELSE
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Get TPLOT data
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
get_data,tpnm[0],DATA=data,DLIMIT=dlim,LIMIT=lim
;;  Check if TPLOT structure
test           = tplot_struct_format_test(data,TEST__V=test__v,TEST_V1_V2=test_v1_v2,$
                                          TEST_DY=test_dy,/NOMSSG)
IF (~test[0]) THEN BEGIN
  MESSAGE,battpdt_mssg[0],/INFORMATIONAL,/CONTINUE
  RETURN
ENDIF
;;  Define parameters
unix           = t_get_struc_unix(data,TSHFT_ON=tshift)
ydat           = data.Y
IF (is_a_number(ydat[0],/NOMSSG) EQ 0) THEN BEGIN
  MESSAGE,badytyp_mssg[0],/INFORMATIONAL,/CONTINUE
  RETURN
ENDIF
szdd           = SIZE(ydat,/DIMENSIONS)
sznd           = SIZE(ydat,/N_DIMENSIONS)
IF (sznd[0] GT 3L) THEN BEGIN
  MESSAGE,badndim_mssg[0],/INFORMATIONAL,/CONTINUE
  RETURN
ENDIF
nx             = N_ELEMENTS(unix)
;;  Check WIDTH again
IF (wdth[0] GE nx[0]/2L) THEN wdth = (nx[0]/2L - 1L) > 3L
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Check keywords
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Check NEWNAME
IF (SIZE(newname,/TYPE) EQ 7) THEN BEGIN
  ;;  It is set --> Make sure the format is okay
  test           = (IDL_VALIDNAME(newname,/CONVERT_SPACES) NE '')
  IF (test[0]) THEN tpn_out = newname[0] ELSE tpn_out = tpnm[0]
ENDIF ELSE BEGIN
  ;;  Not set --> overwrite
  tpn_out        = tpnm[0]
ENDELSE
;;----------------------------------------------------------------------------------------
;;  Check for other time-dependent structure tags
;;----------------------------------------------------------------------------------------
;;  Check for DY
IF (test_dy[0] GT 0) THEN BEGIN
  uny        = data.DY
  test_uy    = 1b
ENDIF ELSE test_uy = 0b

;;  Check for V
test_vv_2d     = (test__v[0] EQ 2)
IF (test__v[0] GT 0) THEN BEGIN
  vv         = data.V
ENDIF ELSE test_vv = 0b
;;  Check for V1 and V2
v1_v2_on       = test_v1_v2[0]
IF (v1_v2_on[0]) THEN BEGIN
  ;;  Both V1 and V2 present --> define variables
  v1             = data.V1
  v2             = data.V2
ENDIF
;;----------------------------------------------------------------------------------------
;;  Sort time stamps [just in case]
;;----------------------------------------------------------------------------------------
sp             = SORT(unix)
xout           = unix[sp]
test           = 0b
IF (N_ELEMENTS(tshift) GT 0) THEN IF (ABS(tshift[0]) GT 0d0) THEN xout -= tshift[0]  ;;  Remove TSHIFT (if present)
;;  Check for V or V1 AND V2
IF (test_vv[0]) THEN BEGIN
  IF (test_vv_2d[0]) THEN BEGIN
    ;;  V is 2D
    vvout          = vv[sp,*]
  ENDIF ELSE BEGIN
    ;;  V is 1D  -->  Assume 1st dimension is independent of # of time stamps
    vvout          = vv
  ENDELSE
ENDIF
IF (v1_v2_on[0]) THEN BEGIN
  ;;  Both V1 and V2 present and correctly formatted
  v1out          = v1[sp,*]      ;;  [N,M]-Element array
  v2out          = v2[sp,*]      ;;  [N,L]-Element array
ENDIF
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Apply median filter
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Sort Y and DY then remove NaNs
CASE sznd[0] OF
  1L    :  BEGIN
    yy             = ydat[sp]          ;;  [N]-Element array
    IF (test_uy[0]) THEN dy = uny[sp]
    yout           = REPLICATE(d,nx)
    ;;  Filter data
    yout           = MEDIAN(yy,wdth[0],EVEN=even)
  END
  2L    :  BEGIN
    yy             = ydat[sp,*]        ;;  [N,M]-Element array
    IF (test_uy[0]) THEN dy = uny[sp,*]
    yout           = REPLICATE(d,nx,szdd[1])
    IF (test_vv[0]) THEN vout = vvout
    ;;  Filter data
    FOR d2=0L, szdd[1] - 1L DO BEGIN
      yout[*,d2]     = MEDIAN(yy[*,d2],wdth[0],EVEN=even)
      
    ENDFOR
  END
  3L    :  BEGIN
    yy             = ydat[sp,*,*]      ;;  [N,M,L]-Element array
    IF (test_uy[0]) THEN dy = uny[sp,*,*]
    yout           = REPLICATE(d,nx,szdd[1],szdd[2])
    IF (v1_v2_on[0]) THEN BEGIN
      vv1            = v1out
      vv2            = v2out
    ENDIF
    ;;  Filter data
    FOR d2=0L, szdd[1] - 1L DO BEGIN
      FOR d3=0L, szdd[2] - 1L DO BEGIN
        yout[*,d2,d3]  = MEDIAN(yy[*,d2,d3],wdth[0],EVEN=even)
      ENDFOR
    ENDFOR
  END
  ELSE  :  STOP           ;;  Should not happen --> debug!
ENDCASE
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Define output structure
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
test           = (v1_v2_on[0] OR test_vv[0])
IF (test[0]) THEN BEGIN
  ;;  Either V or V1 AND V2 are present
  IF (v1_v2_on[0]) THEN BEGIN
    ;;  V1 AND V2 are present
    struc          = {X:xout,Y:yout,V1:vv1,V2:vv2,TSHIFT:tshift[0]}
  ENDIF ELSE BEGIN
    ;;  V is present
    struc          = {X:xout,Y:yout,V:vout,TSHIFT:tshift[0]}
  ENDELSE
ENDIF ELSE BEGIN
  ;;  Only X and Y tags are present or correctly set
  struc          = {X:xout,Y:yout,TSHIFT:tshift[0]}
ENDELSE
;;  Check for DY
IF (test_uy[0]) THEN str_element,struc,'DY',dyout,/ADD_REPLACE  ;;  Add DY (if present)
;;  Add remaining time-independent tags
extract_tags,struc,data,EXCEPT_TAGS=excpt_tags
;;----------------------------------------------------------------------------------------
;;  Return/Send to TPLOT
;;----------------------------------------------------------------------------------------
store_data,tpn_out[0],DATA=struc,DLIMIT=dlim,LIMIT=lim
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------

RETURN
END










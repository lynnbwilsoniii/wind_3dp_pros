;+
;*****************************************************************************************
;
;  PROCEDURE:   t_kill_data_2d.pro
;  PURPOSE  :   Interactively kills data in rectangular regions defined by user-selected
;                 opposing corners.
;
;  CALLED BY:   
;               NA
;
;  INCLUDES:
;               NA
;
;  CALLS:
;               tnames.pro
;               test_tplot_handle.pro
;               t_set_trange.pro
;               is_a_number.pro
;               t_get_values_from_plot.pro
;               tplot_struct_format_test.pro
;               get_data.pro
;               t_get_struc_unix.pro
;               struct_value.pro
;               test_plot_axis_range.pro
;               str_element.pro
;               store_data.pro
;               tplot.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               TP_NAME     :  Scalar [string] defining the TPLOT handle that the user
;                                wishes to get data from
;                                [Default = first TPLOT handle plotted]
;
;  EXAMPLES:    
;               [calling sequence]
;               t_kill_data_2d,tp_name [,NDATA=ndata] [,UNKNOWN=unknown] [,DATA_OUT=data_out]
;
;  KEYWORDS:    
;               NDATA       :  Scalar [long] defining the # of intervals the user knows,
;                                a priori, that they wish to return
;                                [Default = 2]
;               UNKNOWN     :  If set, routine will prompt user asking whether they wish
;                                retrieve another set of values.  Use this keyword if
;                                you are unaware of how many points you wish to get
;                                prior to calling.
;               DATA_OUT    :  Set to a named variable to return the data values and
;                                their associated timestamps.  The output will be
;                                returned as an IDL structure with the following tags:
;                                  X  :  independent variable (e.g., timestamp or x-axis
;                                          variable or abscissa)
;                                  Y  :  1st dependent variable (e.g., y-axis variable)
;                                  Z  :  2nd dependent variable (e.g., z-axis variable)
;
;   CHANGED:  1)  NA
;                                                                   [MM/DD/YYYY   v1.0.0]
;
;   NOTES:      
;               1)  If the TPLOT handle, TP_NAME, is not associated with a spectral
;                     plot, the routine may not be of much use at the moment.
;               2)  To increase the precision of the output results, it would be wise
;                     to zoom-in (both X and Y) on the points of interest.  Technically,
;                     the use of SPECPLOT.PRO and zooming-in may artificially increase
;                     the resolution of the data.  However, zooming-in should reduce the
;                     errors introduced by "shaky hands" or a particularly stubborn
;                     mouse.
;               3)  I have found it useful to use a linear Y-Axis scale as opposed to
;                     a logarithmic scale that is commonly used in these plots.  However,
;                     using a linear scale typically requires changing the Y-Axis range
;                     so the user can see the features of interest.
;               4)  Routine will force that NDATA be even and then assume each adjacent
;                     pair are start/end values.
;                   *******************************************************************
;               5)  Be careful!  This routine will overwrite input TPLOT variable data!
;                   *******************************************************************
;
;  REFERENCES:  
;               NA
;
;   CREATED:  10/12/2022
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  10/12/2022   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

PRO t_kill_data_2d,tp_name,NDATA=ndata,UNKNOWN=unknown,DATA_OUT=data_out

;;----------------------------------------------------------------------------------------
;;  Constants
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
;;  Define defaults
def_ndata      = 2L
;;  Define some prompt statements and error messages
no_tplot       = 'You must first load some data into TPLOT!'
bad_tpn_msg    = 'Incorrect input:  TP_NAME must be a valid and existing TPLOT handle...'
bad_tgv_msg    = 'Something failed in call to t_get_values_from_plot.pro, returning without data removal...'
bad_tfm_msg    = 'Not currently capable of handling TPLOT variables using V1, V2, and/or V3 structure tags...'
bad_yfm_msg    = 'The Y structure tag in TPLOT variable has the wrong dimensions, returning without data removal...'
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Check input
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
tpn_all        = tnames()
IF (tpn_all[0] EQ '') THEN BEGIN
  MESSAGE,no_tplot[0],/INFORMATIONAL,/CONTINUE
  RETURN
ENDIF
;;  Check TPLOT handle
test_in        = test_tplot_handle(tp_name,TPNMS=tpname)
IF (test_in[0] EQ 0) THEN BEGIN
  MESSAGE,bad_tpn_msg[0],/INFORMATIONAL,/CONTINUE
  RETURN
ENDIF
;;  Set TPLOT times
;;      --> Ensures that the TPLOT common block structure is formatted and filled
t_set_trange
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Check keywords
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Check NDATA
IF (is_a_number(ndata,/NOMSSG) EQ 0) THEN ndata = def_ndata[0] ELSE ndata = (LONG(ndata[0]) > 2L) < 10L
IF ((ndata[0] MOD 2) NE 0) THEN ndata = (ndata[0] - 1L) > 2L
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Alter TPLOT variable
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  First select range of values
t_get_values_from_plot,tpname[0],NDATA=ndata,UNKNOWN=unknown,DATA_OUT=data_out
;;  Test output
IF (tplot_struct_format_test(data_out,/NOMSSG) EQ 0) THEN BEGIN
  MESSAGE,bad_tgv_msg[0],/INFORMATIONAL,/CONTINUE
  RETURN
ENDIF
;;  Get TPLOT variable
get_data,tpname[0],DATA=data,DLIMIT=dlim,LIMIT=lim
;;  Check TPLOT structure format
test           = tplot_struct_format_test(data,TEST__V=test__v,TEST_V1_V2=test_v1_v2,TEST_V123=test_v123,/NOMSSG)
IF (test_v1_v2[0] OR test_v123[0] OR ~test__v[0]) THEN BEGIN
  MESSAGE,bad_tfm_msg[0],/INFORMATIONAL,/CONTINUE
  RETURN
ENDIF
;;----------------------------------------------------------------------------------------
;;  Remove data
;;----------------------------------------------------------------------------------------
;;  Define TPLOT data
unix           = t_get_struc_unix(data,TSHFT_ON=tshft_on)     ;;  [N]-Element array of Unix times
IF (tshft_on[0]) THEN BEGIN
  tshift         = struct_value(data,'TSHIFT',DEFAULT=0d0)
ENDIF ELSE BEGIN
  tshift         = 0d0
ENDELSE
xval           = unix - tshift[0]
yval           = data.Y
vval           = data.V
szdy           = SIZE(yval,/DIMENSIONS)
szny           = SIZE(yval,/N_DIMENSIONS)
;;  Define user-selected data
tr_bad         = t_get_struc_unix(data_out)
vr_bad         = data_out.Y
nbad           = N_ELEMENTS(tr_bad)/2L                        ;;  # of regions to remove
indl           = LINDGEN(nbad[0])*2L
indu           = indl + 1L
FOR j=0L, nbad[0] - 1L DO BEGIN
  ;;  Define bounds of region of interest
  tr0            = tr_bad[indl[j[0]]:indu[j[0]]]
  vr0            = vr_bad[indl[j[0]]:indu[j[0]]]
  ;;  Sort, just in case
  sp             = SORT(tr0)
  tr0            = tr0[sp]
  sp             = SORT(vr0)
  vr0            = vr0[sp]
  ;;  Make sure the boundaries are valid
  IF (test_plot_axis_range(tr0,/NOMSSG) EQ 0L OR test_plot_axis_range(vr0,/NOMSSG) EQ 0L) THEN CONTINUE
  IF (test__v[0] EQ 1) THEN BEGIN
    ;;--------------------------------------------------------------------------------------
    ;;  V is 1D
    ;;--------------------------------------------------------------------------------------
    bad_tr         = WHERE(unix GE tr0[0] AND unix LE tr0[1],bd_tr)
    bad_vr         = WHERE(vval GE vr0[0] AND vval LE vr0[1],bd_vr)
    IF (bd_tr[0] EQ 0L OR bd_vr[0] EQ 0L) THEN CONTINUE
    ;;  "kill" bad data
    CASE szny[0] OF
      1     :  BEGIN
        ;;  Okay, not correct, user should have called kill_data_tr.pro we'll handle it here anyways
        yval[bad_tr]   = f
      END
      2     :  BEGIN
        ;;  Data is properly 2D
        temp           = REFORM(yval[bad_tr,*])
;;        FOR k=0L, bd_tr[0] - 1L DO temp[k[0],bad_vr] = f  ;;  Does the same as below...
        temp[*,bad_vr] = f
        yval[bad_tr,*] = temp
      END
      ELSE  :  BEGIN
        ;;  Data is something else --> inform user and stop
        MESSAGE,bad_yfm_msg[0],/INFORMATIONAL,/CONTINUE
        RETURN
      END
    ENDCASE
  ENDIF ELSE BEGIN
    ;;--------------------------------------------------------------------------------------
    ;;  V is 2D
    ;;--------------------------------------------------------------------------------------
    bad_tr         = WHERE(unix GE tr0[0] AND unix LE tr0[1],bd_tr)
    IF (bd_tr[0] EQ 0L) THEN CONTINUE
    ;;  "kill" bad data
    CASE szny[0] OF
      1     :  BEGIN
        ;;  Okay, not correct, user should have called kill_data_tr.pro we'll handle it here anyways
        yval[bad_tr]   = f
      END
      2     :  BEGIN
        FOR k=0L, bd_tr[0] - 1L DO BEGIN
          ;;  Loop through bad times to remove
          bb             = bad_tr[k]
          vval0          = REFORM(vval[bb[0],*])
          bad_vr         = WHERE(vval0 GE vr0[0] AND vval0 LE vr0[1],bd_vr)
          IF (bd_vr[0] EQ 0L) THEN CONTINUE
          ;;  "kill" bad values
          yval[bb[0],bad_vr] = f
        ENDFOR
      END
      ELSE  :  BEGIN
        ;;  Data is something else --> inform user and stop
        MESSAGE,bad_yfm_msg[0],/INFORMATIONAL,/CONTINUE
        RETURN
      END
    ENDCASE
  ENDELSE
ENDFOR
;;----------------------------------------------------------------------------------------
;;  Define new TPLOT structure
;;----------------------------------------------------------------------------------------
newdata        = data
str_element,newdata,     'X',     xval,/ADD_REPLACE
str_element,newdata,     'Y',     yval,/ADD_REPLACE
str_element,newdata,'TSHIFT',tshift[0],/ADD_REPLACE
;;----------------------------------------------------------------------------------------
;;  Send new structure to TPLOT (overwrites original)
;;----------------------------------------------------------------------------------------
store_data,tpname[0],DATA=newdata,DLIMIT=dlim,LIMIT=lim
;;  Update plot
tplot
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------

RETURN
END

;+
;*****************************************************************************************
;
;  FUNCTION :   format_2d_vec.pro
;  PURPOSE  :   This routine takes an input two dimensional array and forces the output
;                 to be an [N,3]-element array.  If either of the dimensions are not
;                 equal to three, the routine returns zero.
;
;  CALLED BY:   
;               NA
;
;  CALLS:
;               NA
;
;  REQUIRES:    
;               NA
;
;  INPUT:
;               VEC  :  [N,3]- or [3,N]-element array to be forced to a [N,3]-element
;                         array
;
;  EXAMPLES:    
;               ;;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;               ;;  Transpose a [3,N]-element array
;               ;;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;               IDL> x  = FINDGEN(3,10)
;               IDL> y  = format_2d_vec(x)
;               IDL> HELP,y
;               Y               FLOAT     = Array[10, 3]
;               ;;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;               ;;  Return the input array because it's already formatted correctly
;               ;;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;               IDL> x  = FINDGEN(10,3)
;               IDL> y  = format_2d_vec(x)
;               IDL> HELP,y
;               Y               FLOAT     = Array[10, 3]
;               ;;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;               ;;  Return the input array because it's incorrectly formatted
;               ;;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;               IDL> x  = FINDGEN(10,30)
;               IDL> y  = format_2d_vec(x)
;               % FORMAT_2D_VEC: 1:  Incorrect number of elements.  One of the
;                                 dimensions must be equal to 3.
;               IDL> HELP,y
;               Y               INT       =        0
;
;  KEYWORDS:    
;               NA
;
;   CHANGED:  1)  Removed unnecessary print statements
;                                                                   [09/10/2013   v1.0.1]
;
;   NOTES:      
;               1)  This is formatting routine meant to ensure that the user has
;                     correctly formatted an input.
;
;   CREATED:  08/31/2013
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  09/10/2013   v1.0.1
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION format_2d_vec,vec

;;----------------------------------------------------------------------------------------
;;  Define some constants and dummy variables
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
;;  Error messages
noinput_mssg   = 'No input was supplied...'
incorrd_mssg   = 'Incorrect number of dimensions.  Input must be one- or two-dimensions.'
incorne_mssg   = 'Incorrect number of elements.  One of the dimensions must be equal to 3.'
;;----------------------------------------------------------------------------------------
;;  Check input
;;----------------------------------------------------------------------------------------
test           = (N_PARAMS() NE 1) OR (N_ELEMENTS(vec) EQ 0)
IF (test) THEN BEGIN
  MESSAGE,noinput_mssg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0
ENDIF
szd            = SIZE(vec,/DIMENSIONS)
szn            = SIZE(vec,/N_DIMENSIONS)
;  LBW III  [09/10/2013   v1.0.1]
;PRINT,'szd = ',szd
;PRINT,'szn = ',szn
;;----------------------------------------------------------------------------------------
;;  Format input
;;----------------------------------------------------------------------------------------
CASE szn[0] OF
  1     :  BEGIN
    ;;------------------------------------------------------------------------------------
    ;;  1D array
    ;;------------------------------------------------------------------------------------
    test  = (szd[0] NE 3)
    IF (test) THEN BEGIN
      MESSAGE,'0:  '+incorne_mssg[0],/INFORMATIONAL,/CONTINUE
      RETURN,0
    ENDIF
    ;;  Re-format to [1,3]-element array
    RETURN,TRANSPOSE(vec)
  END
  2     :  BEGIN
    ;;------------------------------------------------------------------------------------
    ;;  2D array
    ;;------------------------------------------------------------------------------------
    test  = (szd[0] NE 3) AND (szd[1] NE 3)
    IF (test) THEN BEGIN
      MESSAGE,'1:  '+incorne_mssg[0],/INFORMATIONAL,/CONTINUE
      RETURN,0
    ENDIF
    ;;  Re-format to [N,3]-element array
    test  = [(szd[0] EQ 3),(szd[1] EQ 3)]
    good  = WHERE(test,gd)
    CASE good[0] OF
      0     :  RETURN,TRANSPOSE(vec)
      1     :  RETURN,vec
      ELSE  :  BEGIN
        MESSAGE,'2:  '+incorne_mssg[0],/INFORMATIONAL,/CONTINUE
        RETURN,0
      END
    ENDCASE
  END
  ELSE  :  BEGIN
    ;;------------------------------------------------------------------------------------
    ;;  Something else... return input
    ;;------------------------------------------------------------------------------------
    MESSAGE,incorrd_mssg[0],/INFORMATIONAL,/CONTINUE
    RETURN,0
  END
ENDCASE
;;----------------------------------------------------------------------------------------
;;  End routine
;;----------------------------------------------------------------------------------------

END

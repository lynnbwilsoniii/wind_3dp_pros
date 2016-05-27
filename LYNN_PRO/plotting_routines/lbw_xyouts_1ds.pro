;+
;*****************************************************************************************
;
;  PROCEDURE:   lbw_xyouts_1ds.pro
;  PURPOSE  :   This is a wrapping routine for using XYOUTS.PRO to plot several
;                 strings with user defined X- and Y-offsets and displacements.
;
;  CALLED BY:   
;               NA
;
;  CALLS:
;               is_a_number.pro
;               extract_tags.pro
;               str_element.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               XYO   :  [2]-Element [float/double] defining the initial position of the
;                          first string output
;               DXY   :  [2]-Element [float/double] defining the change in position for
;                          each new string printed to the device.  The default direction
;                          is negative, so if you wish to have each additional string
;                          be at a "larger" position then define the elements of this
;                          array as negative numbers
;               STRS  :  [N]-Element [string] array to be printed to the device
;
;  EXAMPLES:    
;               ;;  Direct keyword passing
;               xyo  = [0.5,0.5]
;               dxy  = [0.0,0.02]      ;;  Only displace in -Y direction after each string
;               strs = ['try','this','out','for','me']
;               lbw_xyouts_1ds,xyo,dxy,strs,ALIGNMENT=0.,CHARSIZE=0.65,ORIENTATION=0.,$
;                                           /NORMAL
;
;               ;;  Indirect keyword passing
;               xyo  = [0.5,0.5]
;               dxy  = [0.0,0.02]      ;;  Only displace in -Y direction after each string
;               strs = ['try','this','out','for','me']
;               extr = {ALIGNMENT:0e0,CHARSIZE:0.65,NORMAL:1,ORIENTATION:0e0}
;               lbw_xyouts_1ds,xyo,dxy,strs,_EXTRA=extr
;
;  KEYWORDS:    
;               XYF       :  Set to a named variable to return the final positions
;                              of the string outputs
;               COLORS    :  [N]-Element [long/integer] array defining the value of
;                              the COLOR keyword accepted by XYOUTS.PRO
;               _EXTRA    :  Any keywords accepted by XYOUTS.PRO
;
;   CHANGED:  1)  NA [MM/DD/YYYY   v1.0.0]
;
;   NOTES:      
;               1)  Keep the device units (e.g., NORMAL, DATA, etc.) consistent between
;                     XYO, DXY, and the specifying keyword
;               2)  The default device units are NORMAL
;               3)  The XYF keyword is useful if one wishes to start another set of
;                     outputs based upon the last position from the first call
;               4)  The # of elements in COLORS must match the # of elements in STRS,
;                     otherwise this keyword is ignored.
;
;  REFERENCES:  
;               NA
;
;   CREATED:  07/24/2015
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  07/24/2015   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

PRO lbw_xyouts_1ds,xyo,dxy,strs,XYF=xyf,COLORS=colors,_EXTRA=ex_str

;;  Let IDL know that the following are functions
FORWARD_FUNCTION is_a_number
;;----------------------------------------------------------------------------------------
;;  Define some constants, dummy variables, and defaults
;;----------------------------------------------------------------------------------------
;;  Dummy variables
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
;;  Dummy XYOUTS keywords structures
xyout_lim_tags = ['ALIGNMENT','CHARSIZE','CHARTHICK','TEXT_AXES','WIDTH','CLIP',     $
                  'COLOR','DATA','DEVICE','FONT','NOCLIP','NORMAL','ORIENTATION',    $
                  'T3D','Z']
chsz           = !P.CHARSIZE[0]
IF (chsz[0] LE 0) THEN chsz = 1.0
def_xylim      = {ALIGNMENT:0e0,CHARSIZE:chsz[0],NORMAL:1,ORIENTATION:0e0}
;;  Define graphics system variable parameters
w_num          = !D.WINDOW[0]
w_nam          = STRLOWCASE(!D.NAME[0])
;;  Dummy error messages
no_inpt_msg    = 'User must supply XYO [numeric], DXY [numeric], and STRS [string] inputs and may supply a structure containing keywords for XYOUTS.PRO'
badinpt_msg    = 'XYO and DXY must be [2]-element [numeric] arrays...'
badgrap_msg    = "In 'X' or 'WIN' mode, an active graphics window must be open --> must call WINDOW.PRO or enter SET_PLOT,'PS'..."
;;----------------------------------------------------------------------------------------
;;  Check input
;;----------------------------------------------------------------------------------------
test           = (N_PARAMS() LT 3) OR (is_a_number(xyo,/NOMSSG) EQ 0) OR    $
                 (is_a_number(dxy,/NOMSSG) EQ 0) OR (SIZE(strs,/TYPE) NE 7)
IF (test[0]) THEN BEGIN
  MESSAGE,no_inpt_msg[0],/INFORMATIONAL,/CONTINUE
  RETURN
ENDIF
;;  Check format
test           = ((N_ELEMENTS(xyo) LT 2) OR (N_ELEMENTS(dxy) LT 2))
IF (test[0]) THEN BEGIN
  MESSAGE,badinpt_msg[0],/INFORMATIONAL,/CONTINUE
  RETURN
ENDIF
;;  Check graphics
test           = ((w_nam[0] EQ 'x') OR (w_nam[0] EQ 'win')) AND (w_num[0] LT 0)
IF (test[0]) THEN BEGIN
  MESSAGE,badgrap_msg[0],/INFORMATIONAL,/CONTINUE
  RETURN
ENDIF
;;----------------------------------------------------------------------------------------
;;  Define parameters
;;----------------------------------------------------------------------------------------
xy_o           = REFORM(xyo)
d_xy           = REFORM(dxy)
sout           = REFORM(strs)
ns             = N_ELEMENTS(sout)      ;;  # of string outputs
;;----------------------------------------------------------------------------------------
;;  Check keywords
;;----------------------------------------------------------------------------------------
test_ex        = (SIZE(ex_str,/TYPE) EQ 8)
;;  Start with defaults
xylim          = def_xylim
IF (test_ex[0]) THEN BEGIN
  ;;  Check for acceptable XYOUTS tags
  extract_tags,xylim,ex_str,TAGS=xyout_lim_tags
  ;;  Check to see if user specified DATA or DEVICE instead of NORMAL
  str_element,ex_str,  'DATA',data_coord
  str_element,ex_str,'DEVICE',dev__coord
  check          = [(N_ELEMENTS(data_coord) GT 0),(N_ELEMENTS(dev__coord) GT 0)]
  good           = WHERE(check,gd)
  test           = check[0] OR check[1]
  IF (gd[0] GT 0) THEN BEGIN
    ;;  At least one is set
    CASE good[0] OF
      0 : BEGIN
        ;;  --> Check if set
        test = KEYWORD_SET(data_coord[0])
        IF (test[0]) THEN BEGIN
          ;;  Set DATA
          str_element,xylim,  'DATA',1,/ADD_REPLACE
          ;;  Unset NORMAL
          str_element,xylim,'NORMAL',0,/ADD_REPLACE
        ENDIF
      END
      1 : BEGIN
        ;;  --> Check if set
        test = KEYWORD_SET(dev__coord[0])
        IF (test[0]) THEN BEGIN
          ;;  Set DEVICE
          str_element,xylim,'DEVICE',1,/ADD_REPLACE
          ;;  Unset NORMAL
          str_element,xylim,'NORMAL',0,/ADD_REPLACE
        ENDIF
      END
    ENDCASE
  ENDIF
ENDIF
;;  Check COLORS
test_cols      = ((N_ELEMENTS(colors) NE ns[0]) OR (is_a_number(dxy,/NOMSSG) EQ 0))
;;----------------------------------------------------------------------------------------
;;  Output results
;;----------------------------------------------------------------------------------------
FOR ss=0L, ns[0] - 1L DO BEGIN
  IF (ss EQ 0) THEN BEGIN
    ;;  Use initial
    xo  = xy_o[0]
    yo  = xy_o[1]
  ENDIF ELSE BEGIN
    ;;  Shift downwards
    xo -= d_xy[0]
    yo -= d_xy[1]
  ENDELSE
  ;;  Output strings
  IF (test_cols) THEN BEGIN
    XYOUTS,xo[0],yo[0],sout[ss],_EXTRA=xylim
  ENDIF ELSE BEGIN
    ;;  use colors
    XYOUTS,xo[0],yo[0],sout[ss],COLOR=colors[ss],_EXTRA=xylim
  ENDELSE
ENDFOR
;;  Define final positions
xyf            = [xo[0],yo[0]]
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN
END

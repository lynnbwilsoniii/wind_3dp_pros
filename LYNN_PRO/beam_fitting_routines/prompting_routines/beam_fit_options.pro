;+
;*****************************************************************************************
;
;  PROCEDURE:   beam_fit_options.pro
;  PURPOSE  :   This routine controls the dynamic plotting options defined by user
;                 input.
;
;  CALLED BY:   
;               beam_fit_change_parameter.pro
;               beam_fit_1df_plot_fit.pro
;               wrapper_beam_fit_array.pro
;
;  CALLS:
;               beam_fit_list_options.pro
;               beam_fit___get_common.pro
;               delete_variable.pro
;               beam_fit_prompts.pro
;               beam_fit_gen_prompt.pro
;               beam_fit_print_index_time.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               DATA       :  [N]-Element array of data structures containing particle
;                               velocity distribution functions (DFs) from either the
;                               Wind/3DP instrument [use get_??.pro, ?? = e.g. phb]
;                               or from the THEMIS ESA instruments.  Regardless, the
;                               structures must satisfy the criteria needed to produce
;                               a contour plot showing the phase (velocity) space density
;                               of the DF.  The structures must also have the following
;                               two tags with finite [3]-element vectors:  VSW and MAGF.
;               READ_IN    :  Scalar [string] defining the option selected by user
;                                  to define new action to take
;
;  EXAMPLES:    
;               NA
;
;  KEYWORDS:    
;               ***  INPUT --> Param  ***
;               INDEX      :  Scalar [long] defining the index of DAT to consider when
;                               changing/defining keywords
;                               [Default = 0]
;               ***  INPUT --> System  ***
;               WINDN      :  Scalar [long] defining the index of the window to use when
;                               selecting the region of interest
;                               [Default = !D.WINDOW]
;               PLOT_STR   :  Scalar [structure] that defines the scaling factors for the
;                               contour plot shown in window WINDN to be used by
;                               region_cursor_select.pro
;
;  KEYWORDS:    
;               ***  OUTPUT  ***
;               !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
;               ***  [all the following changed on output]  ***
;               !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
;               READ_OUT   :  Set to a named variable to return a string containing the
;                               last command line input.  This is used by the overhead
;                               routine to determine whether user left the program by
;                               quitting or if the program finished
;               VALUE_OUT  :  Set to a named variable to return the NEW value for the
;                               changed variable associated with the N_* keyword.  This
;                               is useful for routines that do not call the common
;                               blocks associated with the relevant parameter being
;                               changed.
;               OLD_VALUE  :  Set to a named variable to return the OLD value for the
;                               changed variable associated with the N_* keyword.
;
;   CHANGED:  1)  Completely rewrote routine
;                                                                  [08/31/2012   v2.0.0]
;             2)  Continued to change routine
;                                                                  [09/01/2012   v2.0.1]
;             3)  Continued to change routine
;                                                                  [09/04/2012   v2.0.2]
;             4)  Continued to change routine
;                                                                  [09/07/2012   v2.0.3]
;             5)  Changed general prompt for commands
;                                                                  [09/11/2012   v2.0.4]
;             6)  Fixed an issue with 'vbulk' option
;                                                                  [09/17/2012   v2.0.5]
;             7)  Now outputs current index when using INDEX, NEXT, or PREV inputs
;                                                                  [08/06/2013   v2.0.6]
;
;   NOTES:      
;               1)  This routine works in conjunction with beam_fit_prompts.pro
;               2)  This routine should not be called by user
;               3)  See also:  beam_fit_prompts.pro and beam_fit_gen_prompt.pro
;
;   CREATED:  08/27/2012
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  08/06/2013   v2.0.6
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

PRO beam_fit_options,data,read_in,INDEX=index,WINDN=windn,PLOT_STR=plot_str,$
                                  READ_OUT=read_out,VALUE_OUT=value_out,    $
                                  OLD_VALUE=old_value

;;----------------------------------------------------------------------------------------
;; => Define some constants and dummy variables
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
;;----------------------------------------------------------------------------------------
;; => Check input
;;----------------------------------------------------------------------------------------
test           = (N_ELEMENTS(data) EQ 0) OR (N_PARAMS() LT 1)
IF (test) THEN RETURN     ;; nothing supplied, so leave
;; => Case Logic:  determines action
test           = (N_ELEMENTS(read_in) EQ 1) AND (SIZE(read_in,/TYPE) EQ 7L)
IF (test) THEN BEGIN
  read_pause = read_in[0]
  jump_skips = 1
ENDIF ELSE BEGIN
  read_pause = ''
  jump_skips = 0
ENDELSE

;;----------------------------------------------------------------------------------------
;; Setup defaults
;;----------------------------------------------------------------------------------------
;; => Define dummy copy of DATA to avoid changing input
dat            = data
ndat           = N_ELEMENTS(dat)
IF ~KEYWORD_SET(index) THEN ind0 = 0L ELSE ind0 = index[0]
dat0           = dat[ind0]
;;----------------------------------------------------------------------------------------
;; Define parameters used in case statement
;;----------------------------------------------------------------------------------------
s_times        = dat[*].TIME
e_times        = dat[*].END_TIME
inds           = LINDGEN(ndat)
ind_ra         = [MIN(inds),MAX(inds)]
sind_ra        = STRING(FORMAT='(I4.4)',ind_ra)
IF (jump_skips) THEN GOTO,JUMP_SKIP_START
;;========================================================================================
JUMP_PAUSE:
;;========================================================================================
PRINT,""
READ,read_pause,PROMPT="Enter command (type '?' for help or 'q' to leave) :"
PRINT,""
;;========================================================================================
JUMP_SKIP_START:
;;========================================================================================
test_r = ((read_pause NE ''        ) AND (read_pause NE '?'       ) AND $
          (read_pause NE 'zrange'  ) AND (read_pause NE 'zfloor'  ) AND $
          (read_pause NE 'zceil'   ) AND (read_pause NE 'vrange'  ) AND $
          (read_pause NE 'nsmooth' ) AND (read_pause NE 'plane'   ) AND $
          (read_pause NE 'sm_con'  ) AND (read_pause NE 'sm_cut'  ) AND $
          (read_pause NE 'vbulk'   ) AND (read_pause NE 'vcmax'   ) AND $
          (read_pause NE 'vbeam'   ) AND (read_pause NE 'vb_reg'  ) AND $
          (read_pause NE 'zfill'   ) AND (read_pause NE 'zperc'   ) AND $
          (read_pause NE 'next'    ) AND (read_pause NE 'prev'    ) AND $
          (read_pause NE 'index'   ) AND (read_pause NE 'q'       ) AND $
          (read_pause NE 'vbmax'   ) AND (read_pause NE 'debug'   )     )

IF (test_r) THEN GOTO,JUMP_PAUSE  ;; => Invalid input... try again

IF (read_pause EQ '') THEN BEGIN
  ;; => Try again with the same index
  RETURN
ENDIF

;; => List all optional values of READ_PAUSE
IF (read_pause EQ '?') THEN BEGIN
  read_pause = ''
  beam_fit_list_options
  GOTO,JUMP_PAUSE
ENDIF
;;----------------------------------------------------------------------------------------
;; => Test user option
;;----------------------------------------------------------------------------------------
CASE STRLOWCASE(read_pause[0]) OF
  'zrange'   : BEGIN
    ;;------------------------------------------------------------------------------------
    ;; => Change DFRA
    ;;------------------------------------------------------------------------------------
    comm_name  = 'dfra'
    read_pause = ''  ;; => unset read_pause logical variable
    ;; => Look for original data
    old_value  = beam_fit___get_common(comm_name[0],DEFINED=defined)
    IF (defined EQ 0) THEN BEGIN
      ;; common block variable not originally defined => clean up
      delete_variable,old_value,defined
    ENDIF
    ;; => Prompt user for new value(s)
    ;;      => Change DFRA
    beam_fit_prompts,dat0,/N_DFRA,WINDN=windn,PLOT_STR=plot_str,$
                          READ_OUT=read_out,VALUE_OUT=value_out
    ;; => Check if user wishes to quit
    IF (read_out EQ 'q') THEN RETURN
    dfra       = value_out
    ;; => Define output
    read_out   = 'dfra'
    value_out  = dfra
    ;; => Nothing else changes, so return
    RETURN
  END
  'zfloor'   : BEGIN
    ;;------------------------------------------------------------------------------------
    ;; => Change DFMIN
    ;;------------------------------------------------------------------------------------
    comm_name  = 'dfmin'
    read_pause = ''  ;; => unset read_pause logical variable
    ;; => Look for original data
    old_value  = beam_fit___get_common(comm_name[0],DEFINED=defined)
    IF (defined EQ 0) THEN BEGIN
      ;; common block variable not originally defined => clean up
      delete_variable,old_value,defined
    ENDIF
    ;; => Prompt user for new value(s)
    beam_fit_prompts,dat0,/N_DFMIN,WINDN=windn,PLOT_STR=plot_str,$
                          READ_OUT=read_out,VALUE_OUT=value_out
    ;; => Check if user wishes to quit
    IF (read_out EQ 'q') THEN RETURN
    ;; => Define output
    read_out   = 'dfmin'
    ;; => Nothing else changes, so return
    RETURN
  END
  'zceil'    : BEGIN
    ;;------------------------------------------------------------------------------------
    ;; => Change DFMAX
    ;;------------------------------------------------------------------------------------
    comm_name  = 'dfmax'
    read_pause = ''  ;; => unset read_pause logical variable
    ;; => Look for original data
    old_value  = beam_fit___get_common(comm_name[0],DEFINED=defined)
    IF (defined EQ 0) THEN BEGIN
      ;; common block variable not originally defined => clean up
      delete_variable,old_value,defined
    ENDIF
    ;; => Prompt user for new value(s)
    beam_fit_prompts,dat0,/N_DFMAX,WINDN=windn,PLOT_STR=plot_str,$
                          READ_OUT=read_out,VALUE_OUT=value_out
    ;; => Check if user wishes to quit
    IF (read_out EQ 'q') THEN RETURN
    ;; => Define output
    read_out   = 'dfmax'
    ;; => Nothing else changes, so return
    RETURN
  END
  'vrange'   : BEGIN
    ;;------------------------------------------------------------------------------------
    ;; => Change VLIM
    ;;------------------------------------------------------------------------------------
    comm_name  = 'vlim'
    read_pause = ''  ;; => unset read_pause logical variable
    ;; => Look for original data
    old_value  = beam_fit___get_common(comm_name[0],DEFINED=defined)
    IF (defined EQ 0) THEN BEGIN
      ;; common block variable not originally defined => clean up
      delete_variable,old_value,defined
    ENDIF
    ;; => Prompt user for new value(s)
    beam_fit_prompts,dat0,/N_VLIM,WINDN=windn,PLOT_STR=plot_str,$
                          READ_OUT=read_out,VALUE_OUT=value_out
    ;; => Check if user wishes to quit
    IF (read_out EQ 'q') THEN RETURN
    ;; => Define output
    read_out   = 'vlim'
    ;; => Nothing else changes, so return
    RETURN
  END
  'index'    : BEGIN
    ;;------------------------------------------------------------------------------------
    ;; => Change INDEX
    ;;------------------------------------------------------------------------------------
    read_pause     = ''  ;; => unset read_pause logical variable
    ;; => Define original data
    old_value      = ind0[0]
    old_strval     = STRING(old_value[0],FORMAT='(I5.5)')
    ;; => Ask user for new value(s)
    pro_out        = ["[Type 'q' to quit at any time]","",$
                      "You can print the indices prior to choosing or enter the value",$
                      "if you already know which distribution you want to examine.","",$
                      "The current index is "+old_strval[0]]
    str_out        = "Do you wish to print the indices prior to choosing (y/n)?"
    read_out       = ''
    WHILE (read_out NE 'y' AND read_out NE 'n' AND read_out NE 'q') DO BEGIN
      read_out = beam_fit_gen_prompt(STR_OUT=str_out,PRO_OUT=pro_out,WINDN=windn,FORM_OUT=7)
      IF (read_out EQ 'debug') THEN STOP
    ENDWHILE
    ;; => Check if user wishes to quit
    IF (read_out EQ 'q') THEN RETURN
    IF (read_out EQ 'y') THEN BEGIN
      ;; => Print out indices first
      PRINT,''
      PRINT,'The list of available DF dates, start/end times, and associated index are:'
      PRINT,''
      beam_fit_print_index_time,s_times,e_times
    ENDIF
    str_out        = "Enter a value between "+sind_ra[0]+" and "+sind_ra[1]+":  "
    true           = 1
    WHILE (true) DO BEGIN
      value_out      = ABS(beam_fit_gen_prompt(STR_OUT=str_out,FORM_OUT=3))
      true           = (value_out[0] LT ind_ra[0]) OR (value_out[0] GT ind_ra[1])
    ENDWHILE
    ;; => Define output
    read_out       = 'index'
    index          = value_out[0]
    ;; => Nothing else changes, so return
    RETURN
  END
  'next'     : BEGIN
    ;;------------------------------------------------------------------------------------
    ;; => Change INDEX [increase by 1]
    ;;------------------------------------------------------------------------------------
    read_pause = ''  ;; => unset read_pause logical variable
    ;; => Define original data
    old_value  = ind0[0]
    ;; => Check current index to make sure it is not at the upper limit
    test           = (ind0 GE ndat - 1L) OR (ind0 LE 0L)
    IF (test) THEN BEGIN
      ;; already at max => do not change
      badmssg = 'The index # is already at its maximum value => nothing changed...'
      MESSAGE,noinpt_msg,/INFORMATIONAL,/CONTINUE
      read_out   = ''
      RETURN
    ENDIF
    ;; => Define output
    read_out       = 'next'
    ;; => Change index
    index          = ind0[0] + 1L
    ;; => Tell user the new value(s)
    new_strval     = STRING(index[0],FORMAT='(I5.5)')
    pro_out        = ["The new index is "+new_strval[0]]
    new_out        = beam_fit_gen_prompt(PRO_OUT=pro_out,FORM_OUT=7)
    ;; => Nothing else changes, so return
    RETURN
  END
  'prev'     : BEGIN
    ;;------------------------------------------------------------------------------------
    ;; => Change INDEX [decrease by 1]
    ;;------------------------------------------------------------------------------------
    read_pause = ''  ;; => unset read_pause logical variable
    ;; => Define original data
    old_value  = ind0[0]
    ;; => Check current index to make sure it is not at the lower limit
    test           = (ind0 GE ndat - 1L) OR (ind0 LE 0L)
    IF (test) THEN BEGIN
      ;; already at max => do not change
      badmssg = 'The index # is already at its minimum value => nothing changed...'
      MESSAGE,noinpt_msg,/INFORMATIONAL,/CONTINUE
      read_out   = ''
      RETURN
    ENDIF
    ;; => Define output
    read_out       = 'prev'
    ;; => Change index
    index          = ind0[0] - 1L
    ;; => Tell user the new value(s)
    new_strval     = STRING(index[0],FORMAT='(I5.5)')
    pro_out        = ["The new index is "+new_strval[0]]
    new_out        = beam_fit_gen_prompt(PRO_OUT=pro_out,FORM_OUT=7)
    ;; => Nothing else changes, so return
    RETURN
  END
  'nsmooth'  : BEGIN
    ;;------------------------------------------------------------------------------------
    ;; => Change NSMOOTH
    ;;------------------------------------------------------------------------------------
    comm_name  = 'nsmooth'
    read_pause = ''  ;; => unset read_pause logical variable
    ;; => Look for original data
    old_value  = beam_fit___get_common(comm_name[0],DEFINED=defined)
    IF (defined EQ 0) THEN BEGIN
      ;; common block variable not originally defined => clean up
      delete_variable,old_value,defined
    ENDIF
    ;; => Prompt user for new value(s)
    beam_fit_prompts,dat0,/N_NSMOOTH,WINDN=windn,PLOT_STR=plot_str,$
                          READ_OUT=read_out,VALUE_OUT=value_out
    ;; => Check if user wishes to quit
    IF (read_out EQ 'q') THEN RETURN
    ;; => Define output
    read_out   = 'nsmooth'
    ;; => Nothing else changes, so return
    RETURN
  END
  'plane'    : BEGIN
    ;;------------------------------------------------------------------------------------
    ;; => Change PLANE
    ;;------------------------------------------------------------------------------------
    comm_name  = 'plane'
    read_pause = ''  ;; => unset read_pause logical variable
    ;; => Look for original data
    old_value  = beam_fit___get_common(comm_name[0],DEFINED=defined)
    IF (defined EQ 0) THEN BEGIN
      ;; common block variable not originally defined => clean up
      delete_variable,old_value,defined
    ENDIF
    ;; => Prompt user for new value(s)
    beam_fit_prompts,dat0,/N_PLANE,WINDN=windn,PLOT_STR=plot_str,$
                          READ_OUT=read_out,VALUE_OUT=value_out
    ;; => Check if user wishes to quit
    IF (read_out EQ 'q') THEN RETURN
    ;; => Define output
    read_out   = 'plane'
    ;; => Return
    RETURN
  END
  'sm_con'   : BEGIN
    ;;------------------------------------------------------------------------------------
    ;; => Change SM_CONT
    ;;------------------------------------------------------------------------------------
    comm_name  = 'sm_cont'
    read_pause = ''  ;; => unset read_pause logical variable
    ;; => Look for original data
    old_value  = beam_fit___get_common(comm_name[0],DEFINED=defined)
    IF (defined EQ 0) THEN BEGIN
      ;; common block variable not originally defined => clean up
      delete_variable,old_value,defined
    ENDIF
    ;; => Prompt user for new value(s)
    beam_fit_prompts,dat0,/N_SM_CONT,WINDN=windn,PLOT_STR=plot_str,$
                          READ_OUT=read_out,VALUE_OUT=value_out
    ;; => Check if user wishes to quit
    IF (read_out EQ 'q') THEN RETURN
    ;; => Define output
    read_out   = 'sm_cont'
    ;; => Return
    RETURN
  END
  'sm_cut'   : BEGIN
    ;;------------------------------------------------------------------------------------
    ;; => Change SM_CUTS
    ;;------------------------------------------------------------------------------------
    comm_name  = 'sm_cuts'
    read_pause = ''  ;; => unset read_pause logical variable
    ;; => Look for original data
    old_value  = beam_fit___get_common(comm_name[0],DEFINED=defined)
    IF (defined EQ 0) THEN BEGIN
      ;; common block variable not originally defined => clean up
      delete_variable,old_value,defined
    ENDIF
    ;; => Prompt user for new value(s)
    beam_fit_prompts,dat0,/N_SM_CUTS,WINDN=windn,PLOT_STR=plot_str,$
                          READ_OUT=read_out,VALUE_OUT=value_out
    ;; => Check if user wishes to quit
    IF (read_out EQ 'q') THEN RETURN
    ;; => Define output
    read_out   = 'sm_cuts'
    ;; => Return
    RETURN
  END
  'vbulk'    : BEGIN
    ;;------------------------------------------------------------------------------------
    ;; => Change VSW
    ;;------------------------------------------------------------------------------------
    comm_name  = 'vsw'
    read_pause = ''  ;; => unset read_pause logical variable
    ;; => Look for original data
    old_value  = beam_fit___get_common(comm_name[0],DEFINED=defined)
    IF (defined EQ 0) THEN BEGIN
      ;; common block variable not originally defined => clean up
      delete_variable,old_value,defined
      ;; Try using default
      old_value  = dat0[0].VSW
    ENDIF
    ;; => Prompt user for new value(s)
    beam_fit_prompts,dat0,/N_VSW,WINDN=windn,PLOT_STR=plot_str,$
                          READ_OUT=read_out,VALUE_OUT=value_out
    ;; => Check if user wishes to quit
    IF (read_out EQ 'q') THEN RETURN
    ;; => Define output
    read_out   = 'vsw'
    ;; => Return
    RETURN
  END
  'vcmax'    : BEGIN
    ;;------------------------------------------------------------------------------------
    ;; => Change VCMAX
    ;;------------------------------------------------------------------------------------
    comm_name  = 'vcmax'
    read_pause = ''  ;; => unset read_pause logical variable
    ;; => Look for original data
    old_value  = beam_fit___get_common(comm_name[0],DEFINED=defined)
    IF (defined EQ 0) THEN BEGIN
      ;; common block variable not originally defined => clean up
      delete_variable,old_value,defined
    ENDIF
    ;; => Prompt user for new value(s)
    beam_fit_prompts,dat0,/N_VCMAX,WINDN=windn,PLOT_STR=plot_str,$
                          READ_OUT=read_out,VALUE_OUT=value_out
    ;; => Check if user wishes to quit
    IF (read_out EQ 'q') THEN RETURN
    ;; => Define output
    read_out   = 'vcmax'
    ;; => Return
    RETURN
  END
  'vbeam'    : BEGIN
    ;;------------------------------------------------------------------------------------
    ;; => Change V_BX and V_BY
    ;;------------------------------------------------------------------------------------
    read_pause = ''  ;; => unset read_pause logical variable
    ;; => Look for original V_BX
    comm_name  = 'v_bx'
    old_valx   = beam_fit___get_common(comm_name[0],DEFINED=defined)
    IF (defined EQ 0) THEN BEGIN
      ;; common block variable not originally defined => clean up
      delete_variable,old_valx,defined
    ENDIF
    ;; => Look for original V_BY
    comm_name  = 'v_by'
    old_valy   = beam_fit___get_common(comm_name[0],DEFINED=defined)
    IF (defined EQ 0) THEN BEGIN
      ;; common block variable not originally defined => clean up
      delete_variable,old_valy,defined
    ENDIF
    test       = (N_ELEMENTS(old_valx) NE 0) AND (N_ELEMENTS(old_valy) NE 0)
    IF (test) THEN old_value  = [old_valx[0],old_valy[0]]
    ;; => Prompt user for new value(s)
    beam_fit_prompts,dat0,/N_V_B,WINDN=windn,PLOT_STR=plot_str,$
                          READ_OUT=read_out,VALUE_OUT=value_out
    ;; => Check if user wishes to quit
    IF (read_out EQ 'q') THEN RETURN
    ;; => Define output
    read_out   = ['v_bx','v_by']
    ;; => Return
    RETURN
  END
  'vbmax'    : BEGIN
    ;;------------------------------------------------------------------------------------
    ;; => Change VBMAX
    ;;------------------------------------------------------------------------------------
    comm_name  = 'vbmax'
    read_pause = ''  ;; => unset read_pause logical variable
    ;; => Look for original data
    old_value  = beam_fit___get_common(comm_name[0],DEFINED=defined)
    IF (defined EQ 0) THEN BEGIN
      ;; common block variable not originally defined => clean up
      delete_variable,old_value,defined
    ENDIF
    ;; => Prompt user for new value(s)
    beam_fit_prompts,dat0,/N_VBMAX,WINDN=windn,PLOT_STR=plot_str,$
                          READ_OUT=read_out,VALUE_OUT=value_out
    ;; => Check if user wishes to quit
    IF (read_out EQ 'q') THEN RETURN
    ;; => Define output
    read_out   = 'vbmax'
    ;; => Return
    RETURN
  END
  'vb_reg'   : BEGIN
    ;;------------------------------------------------------------------------------------
    ;; => Change VB_REG
    ;;------------------------------------------------------------------------------------
    read_pause = ''  ;; => unset read_pause logical variable
    ;; => Look for original data
    old_value  = beam_fit___get_common(comm_name[0],DEFINED=defined)
    IF (defined EQ 0) THEN BEGIN
      ;; common block variable not originally defined => clean up
      delete_variable,old_value,defined
    ENDIF
    ;; => Prompt user for new value(s)
    beam_fit_prompts,dat0,/N_VB_REG,WINDN=windn,PLOT_STR=plot_str,$
                          READ_OUT=read_out,VALUE_OUT=value_out
    ;; => Check if user wishes to quit
    IF (read_out EQ 'q') THEN RETURN
    ;; => Define output
    read_out   = 'vb_reg'
    ;; => Return
    RETURN
  END
  'zfill'    : BEGIN
    ;;------------------------------------------------------------------------------------
    ;; => Change FILL
    ;;------------------------------------------------------------------------------------
    read_pause = ''  ;; => unset read_pause logical variable
    ;; => Look for original data
    old_value  = beam_fit___get_common(comm_name[0],DEFINED=defined)
    IF (defined EQ 0) THEN BEGIN
      ;; common block variable not originally defined => clean up
      delete_variable,old_value,defined
    ENDIF
    ;; => Prompt user for new value(s)
    beam_fit_prompts,dat0,/N_FILL,WINDN=windn,PLOT_STR=plot_str,$
                          READ_OUT=read_out,VALUE_OUT=value_out
    ;; => Check if user wishes to quit
    IF (read_out EQ 'q') THEN RETURN
    ;; => Define output
    read_out   = 'fill'
    ;; => Nothing else changes, so return
    RETURN
  END
  'zperc'    : BEGIN
    ;;------------------------------------------------------------------------------------
    ;; => Change PERC_PK
    ;;------------------------------------------------------------------------------------
    read_pause = ''  ;; => unset read_pause logical variable
    ;; => Look for original data
    old_value  = beam_fit___get_common(comm_name[0],DEFINED=defined)
    IF (defined EQ 0) THEN BEGIN
      ;; common block variable not originally defined => clean up
      delete_variable,old_value,defined
    ENDIF
    ;; => Prompt user for new value(s)
    beam_fit_prompts,dat0,/N_PERC_PK,WINDN=windn,PLOT_STR=plot_str,$
                          READ_OUT=read_out,VALUE_OUT=value_out
    ;; => Check if user wishes to quit
    IF (read_out EQ 'q') THEN RETURN
    ;; => Define output
    read_out   = 'perc_pk'
    ;; => Nothing else changes, so return
    RETURN
  END
  'q'        : BEGIN
    ;;------------------------------------------------------------------------------------
    ;; => Quit so reset defaults
    ;;------------------------------------------------------------------------------------
    ;; => Define output
    read_out   = 'q'
    ;; => Nothing else changes, so return
    RETURN
  END
  'debug'    : BEGIN
    ;;------------------------------------------------------------------------------------
    ;; => Debugging option
    ;;------------------------------------------------------------------------------------
    PRINT,''
    errmssg = 'Debugging error handling => STOP'
    MESSAGE,errmssg,/INFORMATIONAL,/CONTINUE
    STOP
  END
ENDCASE
;;----------------------------------------------------------------------------------------
;; => Return to user
;;----------------------------------------------------------------------------------------

RETURN
END

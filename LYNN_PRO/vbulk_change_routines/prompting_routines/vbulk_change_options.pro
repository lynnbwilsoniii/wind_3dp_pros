;+
;*****************************************************************************************
;
;  PROCEDURE:   vbulk_change_options.pro
;  PURPOSE  :   This routine controls the dynamic plotting options defined by user
;                 input.  It also serves as a wrapping routine for the prompting
;                 routine vbulk_change_prompts.pro.
;
;  CALLED BY:   
;               vbulk_change_change_parameter.pro
;
;  INCLUDES:
;               NA
;
;  CALLS:
;               num2int_str.pro
;               vbulk_change_test_vdf_str_form.pro
;               vbulk_change_test_vdfinfo_str_form.pro
;               vbulk_change_test_cont_str_form.pro
;               vbulk_change_get_default_struc.pro
;               vbulk_change_test_windn.pro
;               vbulk_change_test_plot_str_form.pro
;               is_a_number.pro
;               vbulk_change_list_options.pro
;               struct_value.pro
;               vbulk_change_prompts.pro
;               general_prompt_routine.pro
;               vbulk_change_print_index_time.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;               2)  Vbulk Change IDL Libraries
;
;  INPUT:
;               DATA       :  [M]-Element array of data structures containing particle
;                               velocity distribution functions (VDFs) each containing
;                               the following structure tags:
;                                 VDF     :  [N]-Element [float/double] array defining
;                                              the VDF in units of phase space density
;                                              [i.e., # s^(+3) km^(-3) cm^(-3)]
;                                 VELXYZ  :  [N,3]-Element [float/double] array defining
;                                              the particle velocity 3-vectors for each
;                                              element of VDF
;                                              [km/s]
;               READ_IN    :  Scalar [string] defining the option selected by user
;                               to define new action to take
;                               [Default = '']
;
;  EXAMPLES:    
;               [calling sequence]
;               vbulk_change_options, data, read_in [,INDEX=index] [,VDF_INFO=vdf_info]  $
;                                     [,CONT_STR=cont_str] [,WINDN=windn]                $
;                                     [,PLOT_STR=plot_str0] [,READ_OUT=read_out]         $
;                                     [,VALUE_OUT=value_out] [,OLD_VALUE=old_value]
;
;  KEYWORDS:    
;               ***  INPUT --> Param  ***
;               INDEX      :  Scalar [long] defining the index of DATA to use when
;                               changing/defining keywords
;                               [Default = 0]
;               VDF_INFO   :  [M]-Element [structure] array containing information
;                               relevant to each VDF with the following format
;                               [*** units and format matter here ***]:
;                                 SE_T   :  [2]-Element [double] array defining to the
;                                             start and end times [Unix] of the VDF
;                                 SCFTN  :  Scalar [string] defining the spacecraft name
;                                             [e.g., 'Wind' or 'THEMIS-B']
;                                 INSTN  :  Scalar [string] defining the instrument name
;                                             [e.g., '3DP' or 'ESA' or 'EESA' or 'SST']
;                                 SCPOT  :  Scalar [float] defining the spacecraft
;                                             electrostatic potential [eV] at the time of
;                                             the VDF
;                                 VSW    :  [3]-Element [float] array defining to the
;                                             bulk flow velocity [km/s] 3-vector at the
;                                             time of the VDF
;                                 MAGF   :  [3]-Element [float] array defining to the
;                                             quasi-static magnetic field [nT] 3-vector at
;                                             the time of the VDF
;               ***  INPUT --> Contour Plot  ***
;               CONT_STR   :  Scalar [structure] containing tags defining all of the
;                               current plot settings associated with all of the above
;                               "INPUT --> Command to Change" keywords
;               ***  INPUT --> System  ***
;               WINDN      :  Scalar [long] defining the index of the window to use when
;                               selecting the region of interest
;                               [Default = !D.WINDOW]
;               PLOT_STR   :  Scalar [structure] that defines the scaling factors for the
;                               contour plot shown in window WINDN to be used by
;                               general_cursor_select.pro
;               ***  OUTPUT  ***
;               !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
;               ***  [all the following changed on output]  ***
;               !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
;               READ_OUT   :  Set to a named variable to return a string containing the
;                               last command line input.  This is used by the overhead
;                               routine to determine whether user left the program by
;                               quitting or if the program finished
;               VALUE_OUT  :  Set to a named variable to return the NEW value for the
;                               changed variable associated with the parameter keyword.
;               OLD_VALUE  :  Set to a named variable to return the OLD value for the
;                               changed variable associated with the parameter keyword.
;
;   CHANGED:  1)  Continued to write routine
;                                                                   [07/24/2017   v1.0.0]
;             2)  Continued to write routine
;                                                                   [07/25/2017   v1.0.0]
;             3)  Continued to write routine
;                                                                   [07/26/2017   v1.0.0]
;             4)  Continued to write routine
;                                                                   [07/27/2017   v1.0.0]
;             5)  Continued to write routine
;                                                                   [07/28/2017   v1.0.0]
;
;   TO DO LIST: 
;               *****************************************************
;               ***             Needs further testing             ***
;               *****************************************************
;
;   NOTES:      
;               1)  For more information about many of the keywords, see
;                     general_vdf_contour_plot.pro or contour_3d_1plane.pro, etc.
;               2)  User should NOT call this routine
;               3)  VDF = particle velocity distribution function
;               4)  phase space density = [# cm^(-3) km^(-3) s^(3)]
;               5)  *** Routine can only handle ONE INPUT keyword set at a time ***
;               6)  Routine will NOT alter DAT
;
;  REFERENCES:  
;               1)  Carlson et al., "An instrument for rapidly measuring plasma
;                      distribution functions with high resolution," Adv. Space Res. 2,
;                      pp. 67-70, 1983.
;               2)  Curtis et al., "On-board data analysis techniques for space plasma
;                      particle instruments," Rev. Sci. Inst. 60, pp. 372, 1989.
;               3)  Lin et al., "A three-dimensional plasma and energetic particle
;                      investigation for the Wind spacecraft," Space Sci. Rev. 71,
;                      pp. 125, 1995.
;               4)  Paschmann, G. and P.W. Daly "Analysis Methods for Multi-Spacecraft
;                      Data," ISSI Scientific Report, Noordwijk, The Netherlands.,
;                      Int. Space Sci. Inst., 1998.
;               5)  McFadden, J.P., C.W. Carlson, D. Larson, M. Ludlam, R. Abiad,
;                      B. Elliot, P. Turin, M. Marckwordt, and V. Angelopoulos
;                      "The THEMIS ESA Plasma Instrument and In-flight Calibration,"
;                      Space Sci. Rev. 141, pp. 277-302, 2008.
;               6)  McFadden, J.P., C.W. Carlson, D. Larson, J.W. Bonnell,
;                      F.S. Mozer, V. Angelopoulos, K.-H. Glassmeier, U. Auster
;                      "THEMIS ESA First Science Results and Performance Issues,"
;                      Space Sci. Rev. 141, pp. 477-508, 2008.
;               7)  Auster, H.U., K.-H. Glassmeier, W. Magnes, O. Aydogar, W. Baumjohann,
;                      D. Constantinescu, D. Fischer, K.H. Fornacon, E. Georgescu,
;                      P. Harvey, O. Hillenmaier, R. Kroth, M. Ludlam, Y. Narita,
;                      R. Nakamura, K. Okrafka, F. Plaschke, I. Richter, H. Schwarzl,
;                      B. Stoll, A. Valavanoglou, and M. Wiedemann "The THEMIS Fluxgate
;                      Magnetometer," Space Sci. Rev. 141, pp. 235-264, 2008.
;               8)  Angelopoulos, V. "The THEMIS Mission," Space Sci. Rev. 141,
;                      pp. 5-34, (2008).
;               9)  Wilson III, L.B., et al., "Quantified energy dissipation rates in the
;                      terrestrial bow shock: 1. Analysis techniques and methodology,"
;                      J. Geophys. Res. 119, pp. 6455--6474, doi:10.1002/2014JA019929,
;                      2014a.
;              10)  Wilson III, L.B., et al., "Quantified energy dissipation rates in the
;                      terrestrial bow shock: 2. Waves and dissipation,"
;                      J. Geophys. Res. 119, pp. 6475--6495, doi:10.1002/2014JA019930,
;                      2014b.
;              11)  Pollock, C., et al., "Fast Plasma Investigation for Magnetospheric
;                      Multiscale," Space Sci. Rev. 199, pp. 331--406,
;                      doi:10.1007/s11214-016-0245-4, 2016.
;              12)  Gershman, D.J., et al., "The calculation of moment uncertainties
;                      from velocity distribution functions with random errors,"
;                      J. Geophys. Res. 120, pp. 6633--6645, doi:10.1002/2014JA020775,
;                      2015.
;              13)  Bordini, F. "Channel electron multiplier efficiency for 10-1000 eV
;                      electrons," Nucl. Inst. & Meth. 97, pp. 405--408,
;                      doi:10.1016/0029-554X(71)90300-4, 1971.
;              14)  Meeks, C. and P.B. Siegel "Dead time correction via the time series,"
;                      Amer. J. Phys. 76, pp. 589--590, doi:10.1119/1.2870432, 2008.
;              15)  Furuya, K. and Y. Hatano "Pulse-height distribution of output signals
;                      in positive ion detection by a microchannel plate,"
;                      Int. J. Mass Spectrom. 218, pp. 237--243,
;                      doi:10.1016/S1387-3806(02)00725-X, 2002.
;              16)  Funsten, H.O., et al., "Absolute detection efficiency of space-based
;                      ion mass spectrometers and neutral atom imagers,"
;                      Rev. Sci. Inst. 76, pp. 053301, doi:10.1063/1.1889465, 2005.
;              17)  Oberheide, J., et al., "New results on the absolute ion detection
;                      efficiencies of a microchannel plate," Meas. Sci. Technol. 8,
;                      pp. 351--354, doi:10.1088/0957-0233/8/4/001, 1997.
;
;   ADAPTED FROM:  beam_fit_options.pro [UMN 3DP library, beam fitting routines]
;   CREATED:  07/21/2017
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  07/28/2017   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

PRO vbulk_change_options,data,read_in,                                               $
                                      INDEX=index,VDF_INFO=vdf_info0,                $  ;;  ***  INPUT --> Param  ***
                                      CONT_STR=cont_str0,                            $  ;;  ***  INPUT --> Contour Plot  ***
                                      WINDN=windn,PLOT_STR=plot_str0,                $  ;;  ***  INPUT --> System  ***
                                      READ_OUT=read_out,VALUE_OUT=value_out,         $  ;;  ***  OUTPUT  ***
                                      OLD_VALUE=old_value                               ;;  ***  OUTPUT  ***

;;----------------------------------------------------------------------------------------
;;  Define some constants and dummy variables
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
;;----------------------------------------------------------------------------------------
;;  Check input
;;----------------------------------------------------------------------------------------
test           = (N_ELEMENTS(data) EQ 0) OR (N_PARAMS() LT 1) OR (SIZE(data,/TYPE) NE 8)
IF (test[0]) THEN RETURN     ;; nothing supplied, so leave
;;  Define dummy copy of DATA to avoid changing input
dat            = data
ndat           = N_ELEMENTS(dat)
;;  Define parameters used in case statement
ind_ra         = [0L,ndat[0] - 1L]
sind_ra        = num2int_str(ind_ra,NUM_CHAR=4,/ZERO_PAD)
;;  Check DATA
test           = vbulk_change_test_vdf_str_form(dat[0])
IF (test[0] EQ 0) THEN RETURN
;;  Check VDF_INFO
temp           = vbulk_change_test_vdfinfo_str_form(vdf_info0,DAT_OUT=vdf_info)
n_vdfi         = N_ELEMENTS(vdf_info)
test           = (temp[0] EQ 0) OR (n_vdfi[0] NE ndat[0])
IF (test[0]) THEN STOP  ;;  Not properly set --> Output structure is null --> debug
;;  Check CONT_STR
test           = vbulk_change_test_cont_str_form(cont_str0,DAT_OUT=cont_str)
IF (test[0] EQ 0 OR SIZE(cont_str,/TYPE) NE 8) THEN cont_str = vbulk_change_get_default_struc()
;;  Check WINDN
test           = vbulk_change_test_windn(windn,DAT_OUT=win)
IF (test[0] EQ 0) THEN RETURN
;;  Check PLOT_STR
;;    TRUE   -->  Allow use of general_cursor_select.pro routine
;;    FALSE  -->  Command-line input only
test_plt       = vbulk_change_test_plot_str_form(plot_str0,DAT_OUT=plot_str)
;;  Case Logic:  determines action
test           = (N_ELEMENTS(read_in) GE 1) AND (SIZE(read_in,/TYPE) EQ 7L)
IF (test[0]) THEN BEGIN
  read_pause = read_in[0]
  jump_skips = 1b
ENDIF ELSE BEGIN
  read_pause = ''
  jump_skips = 0b
ENDELSE
;;----------------------------------------------------------------------------------------
;;  Setup defaults
;;----------------------------------------------------------------------------------------
;;  Check INDEX
test           = (is_a_number(index,/NOMSSG) EQ 0) OR (N_ELEMENTS(index) LT 1)
IF (test[0]) THEN ind0 = 0L ELSE ind0 = LONG(index[0])
;;  Confine index to proper range
ind0           = (ind0[0] < ind_ra[1]) > 0L
dat0           = dat[ind0]
;;----------------------------------------------------------------------------------------
;;  Define parameters used in case statement
;;----------------------------------------------------------------------------------------
IF (jump_skips[0]) THEN GOTO,JUMP_SKIP_START
;;========================================================================================
JUMP_PAUSE:
;;========================================================================================
PRINT,""
READ,read_pause,PROMPT="Enter command (type '?' for help or 'q' to leave) :"
PRINT,""
;;========================================================================================
JUMP_SKIP_START:
;;========================================================================================
;;  Define possible input commands
test_r         = ((read_pause NE ''        ) AND (read_pause NE '?'       ) AND $
                  (read_pause NE 'zrange'  ) AND (read_pause NE 'zfloor'  ) AND $
                  (read_pause NE 'zceil'   ) AND (read_pause NE 'vrange'  ) AND $
                  (read_pause NE 'plane'   ) AND (read_pause NE 'nsmcut'  ) AND $
                  (read_pause NE 'nsmcon'  ) AND (read_pause NE 'sm_cut'  ) AND $
                  (read_pause NE 'sm_con'  ) AND (read_pause NE 'vbulk'   ) AND $
                  (read_pause NE 'vec1'    ) AND (read_pause NE 'vec2'    ) AND $
                  (read_pause NE 'v_0x'    ) AND (read_pause NE 'v_0y'    ) AND $
                  (read_pause NE 'next'    ) AND (read_pause NE 'prev'    ) AND $
                  (read_pause NE 'index'   ) AND (read_pause NE 'save1'   ) AND $
                  (read_pause NE 'save3'   ) AND (read_pause NE 'q'       ) AND $
                  (read_pause NE 'debug'   )                                    )
;;  Check command validity
IF (test_r[0]) THEN GOTO,JUMP_PAUSE  ;;  --> Invalid input... try again

IF (read_pause[0] EQ '') THEN BEGIN
  ;;  --> Try again with the same index
  RETURN
ENDIF

;;  List all optional values of READ_PAUSE
IF (read_pause EQ '?') THEN BEGIN
  read_pause = ''
  vbulk_change_list_options
  GOTO,JUMP_PAUSE
ENDIF
;;----------------------------------------------------------------------------------------
;;  Test user option
;;----------------------------------------------------------------------------------------
CASE STRLOWCASE(read_pause[0]) OF
  'zrange'   : BEGIN
    ;;------------------------------------------------------------------------------------
    ;;  Change DFRA
    ;;------------------------------------------------------------------------------------
    comm_name      = 'dfra'
    ;;  unset read_pause logical variable
    read_pause     = ''
    ;;  Look for original data
    old_value      = struct_value(cont_str,comm_name[0],INDEX=sind)
    IF (sind[0] LT 0) THEN dumb = TEMPORARY(old_value)
    ;;  Prompt user for new value(s)
    ;;      --> Change DFRA
    vbulk_change_prompts,dat0,/DFRA,                                   $
                         CONT_STR=cont_str,WINDN=win,PLOT_STR=plot_str,$
                         READ_OUT=read_out,VALUE_OUT=value_out
    ;;  Check if user wishes to quit
    IF (read_out EQ 'q') THEN RETURN
    dfra       = value_out
    ;;  Define output
    read_out       = 'dfra'
    value_out  = dfra
    ;;  Nothing else changes, so return
    RETURN
  END
  'zfloor'   : BEGIN
    ;;------------------------------------------------------------------------------------
    ;;  Change DFMIN
    ;;------------------------------------------------------------------------------------
    comm_name      = 'dfmin'
    ;;  unset read_pause logical variable
    read_pause     = ''
    ;;  Look for original data
    old_value      = struct_value(cont_str,comm_name[0],INDEX=sind)
    IF (sind[0] LT 0) THEN dumb = TEMPORARY(old_value)
    ;;  Prompt user for new value(s)
    vbulk_change_prompts,dat0,/DFMIN,                                  $
                         CONT_STR=cont_str,WINDN=win,PLOT_STR=plot_str,$
                         READ_OUT=read_out,VALUE_OUT=value_out
    ;;  Check if user wishes to quit
    IF (read_out EQ 'q') THEN RETURN
    ;;  Define output
    read_out       = 'dfmin'
    ;;  Nothing else changes, so return
    RETURN
  END
  'zceil'    : BEGIN
    ;;------------------------------------------------------------------------------------
    ;;  Change DFMAX
    ;;------------------------------------------------------------------------------------
    comm_name      = 'dfmax'
    ;;  unset read_pause logical variable
    read_pause     = ''
    ;;  Look for original data
    old_value      = struct_value(cont_str,comm_name[0],INDEX=sind)
    IF (sind[0] LT 0) THEN dumb = TEMPORARY(old_value)
    ;;  Prompt user for new value(s)
    vbulk_change_prompts,dat0,/DFMAX,                                  $
                         CONT_STR=cont_str,WINDN=win,PLOT_STR=plot_str,$
                         READ_OUT=read_out,VALUE_OUT=value_out
    ;;  Check if user wishes to quit
    IF (read_out EQ 'q') THEN RETURN
    ;;  Define output
    read_out       = 'dfmax'
    ;;  Nothing else changes, so return
    RETURN
  END
  'vrange'   : BEGIN
    ;;------------------------------------------------------------------------------------
    ;;  Change VLIM
    ;;------------------------------------------------------------------------------------
    comm_name      = 'vlim'
    ;;  unset read_pause logical variable
    read_pause     = ''
    ;;  Look for original data
    old_value      = struct_value(cont_str,comm_name[0],INDEX=sind)
    IF (sind[0] LT 0) THEN dumb = TEMPORARY(old_value)
    ;;  Prompt user for new value(s)
    vbulk_change_prompts,dat0,/VLIM,                                   $
                         CONT_STR=cont_str,WINDN=win,PLOT_STR=plot_str,$
                         READ_OUT=read_out,VALUE_OUT=value_out
    ;;  Check if user wishes to quit
    IF (read_out EQ 'q') THEN RETURN
    ;;  Define output
    read_out       = 'vlim'
    ;;  Nothing else changes, so return
    RETURN
  END
  'index'    : BEGIN
    ;;------------------------------------------------------------------------------------
    ;;  Change INDEX
    ;;------------------------------------------------------------------------------------
    ;;  unset read_pause logical variable
    read_pause     = ''
    ;;  Define original data
    old_value      = ind0[0]
    old_strval     = num2int_str(old_value[0],NUM_CHAR=5,/ZERO_PAD)
    ;;  Ask user for new value(s)
    pro_out        = ["[Type 'q' to quit at any time]","",$
                      "You can print the indices prior to choosing or enter the value",$
                      "if you already know which distribution you want to examine.","",$
                      "The current index is "+old_strval[0]]
    str_out        = "Do you wish to print the indices prior to choosing (y/n)?"
    read_out       = ''
    WHILE (read_out NE 'y' AND read_out NE 'n' AND read_out NE 'q') DO BEGIN
      read_out = general_prompt_routine(STR_OUT=str_out,PRO_OUT=pro_out,FORM_OUT=7)
      IF (read_out EQ 'debug') THEN STOP
    ENDWHILE
    ;;  Check if user wishes to quit
    IF (read_out EQ 'q') THEN RETURN
    IF (read_out EQ 'y') THEN BEGIN
      ;;----------------------------------------------------------------------------------
      ;;  Print out indices first
      ;;----------------------------------------------------------------------------------
      se_t           = REFORM(vdf_info.SE_T,n_vdfi[0],2L)
      s_times        = se_t[*,0]
      e_times        = se_t[*,1]
      PRINT,';;'
      PRINT,';;  The list of available DF dates, start/end times, and associated index are:'
      PRINT,';;'
      vbulk_change_print_index_time,s_times,e_times
    ENDIF
    str_out        = "Enter a value between "+sind_ra[0]+" and "+sind_ra[1]+":  "
    true           = 1
    WHILE (true) DO BEGIN
      temp           = general_prompt_routine(STR_OUT=str_out,FORM_OUT=3)
      value_out      = ABS(temp[0])
      true           = (value_out[0] LT ind_ra[0]) OR (value_out[0] GT ind_ra[1])
    ENDWHILE
    ;;  Define output
    read_out       = 'index'
    index          = value_out[0]
    ;;  Nothing else changes, so return
    RETURN
  END
  'next'     : BEGIN
    ;;------------------------------------------------------------------------------------
    ;;  Change INDEX [increase by 1]
    ;;------------------------------------------------------------------------------------
    ;;  unset read_pause logical variable
    read_pause     = ''
    ;;  Define original data
    old_value      = ind0[0]
    ;;  Check current index to make sure it is not at the upper limit
    test           = (ind0 GE ind_ra[1])
    IF (test) THEN BEGIN
      ;; already at max --> do not change
      badmssg = 'The index # is already at its maximum value --> nothing changed...'
      MESSAGE,badmssg[0],/INFORMATIONAL,/CONTINUE
      read_out       = ''
      RETURN
    ENDIF
    ;;  Define output
    read_out       = 'next'
    ;;  Change index
    index          = ind0[0] + 1L
    ;;  Tell user the new value(s)
    new_strval     = num2int_str(index[0],NUM_CHAR=5,/ZERO_PAD)
    pro_out        = ["The new index is "+new_strval[0]]
    new_out        = general_prompt_routine(PRO_OUT=pro_out,FORM_OUT=7)
    ;;  Nothing else changes, so return
    RETURN
  END
  'prev'     : BEGIN
    ;;------------------------------------------------------------------------------------
    ;;  Change INDEX [decrease by 1]
    ;;------------------------------------------------------------------------------------
    ;;  unset read_pause logical variable
    read_pause     = ''
    ;;  Define original data
    old_value      = ind0[0]
    ;;  Check current index to make sure it is not at the lower limit
    test           = (ind0 LE ind_ra[0])
    IF (test) THEN BEGIN
      ;; already at max => do not change
      badmssg = 'The index # is already at its minimum value --> nothing changed...'
      MESSAGE,badmssg[0],/INFORMATIONAL,/CONTINUE
      read_out       = ''
      RETURN
    ENDIF
    ;;  Define output
    read_out       = 'prev'
    ;;  Change index
    index          = ind0[0] - 1L
    ;;  Tell user the new value(s)
    new_strval     = num2int_str(index[0],NUM_CHAR=5,/ZERO_PAD)
    pro_out        = ["The new index is "+new_strval[0]]
    new_out        = general_prompt_routine(PRO_OUT=pro_out,FORM_OUT=7)
    ;;  Nothing else changes, so return
    RETURN
  END
  'plane'    : BEGIN
    ;;------------------------------------------------------------------------------------
    ;;  Change PLANE
    ;;------------------------------------------------------------------------------------
    comm_name      = 'plane'
    ;;  unset read_pause logical variable
    read_pause     = ''
    ;;  Look for original data
    old_value      = struct_value(cont_str,comm_name[0],INDEX=sind)
    IF (sind[0] LT 0) THEN dumb = TEMPORARY(old_value)
    ;;  Prompt user for new value(s)
    vbulk_change_prompts,dat0,/PLANE,                                  $
                         CONT_STR=cont_str,WINDN=win,PLOT_STR=plot_str,$
                         READ_OUT=read_out,VALUE_OUT=value_out
    ;;  Check if user wishes to quit
    IF (read_out EQ 'q') THEN RETURN
    ;;  Define output
    read_out       = 'plane'
    ;;  Return
    RETURN
  END
  'nsmcut'   : BEGIN
    ;;------------------------------------------------------------------------------------
    ;;  Change NSMCUT
    ;;------------------------------------------------------------------------------------
    comm_name      = 'nsmcut'
    ;;  unset read_pause logical variable
    read_pause     = ''
    ;;  Look for original data
    old_value      = struct_value(cont_str,comm_name[0],INDEX=sind)
    IF (sind[0] LT 0) THEN dumb = TEMPORARY(old_value)
    ;;  Prompt user for new value(s)
    vbulk_change_prompts,dat0,/NSMCUT,                                 $
                         CONT_STR=cont_str,WINDN=win,PLOT_STR=plot_str,$
                         READ_OUT=read_out,VALUE_OUT=value_out
    ;;  Check if user wishes to quit
    IF (read_out EQ 'q') THEN RETURN
    ;;  Define output
    read_out       = 'nsmcut'
    ;;  Nothing else changes, so return
    RETURN
  END
  'nsmcon'   : BEGIN
    ;;------------------------------------------------------------------------------------
    ;;  Change NSMCON
    ;;------------------------------------------------------------------------------------
    comm_name      = 'nsmcon'
    ;;  unset read_pause logical variable
    read_pause     = ''
    ;;  Look for original data
    old_value      = struct_value(cont_str,comm_name[0],INDEX=sind)
    IF (sind[0] LT 0) THEN dumb = TEMPORARY(old_value)
    ;;  Prompt user for new value(s)
    vbulk_change_prompts,dat0,/NSMCON,                                 $
                         CONT_STR=cont_str,WINDN=win,PLOT_STR=plot_str,$
                         READ_OUT=read_out,VALUE_OUT=value_out
    ;;  Check if user wishes to quit
    IF (read_out EQ 'q') THEN RETURN
    ;;  Define output
    read_out       = 'nsmcon'
    ;;  Nothing else changes, so return
    RETURN
  END
  'sm_cut'   : BEGIN
    ;;------------------------------------------------------------------------------------
    ;;  Change SM_CUTS
    ;;------------------------------------------------------------------------------------
    comm_name      = 'sm_cuts'
    ;;  unset read_pause logical variable
    read_pause     = ''
    ;;  Look for original data
    old_value      = struct_value(cont_str,comm_name[0],INDEX=sind)
    IF (sind[0] LT 0) THEN dumb = TEMPORARY(old_value)
    ;;  Prompt user for new value(s)
    vbulk_change_prompts,dat0,/SM_CUTS,                                $
                         CONT_STR=cont_str,WINDN=win,PLOT_STR=plot_str,$
                         READ_OUT=read_out,VALUE_OUT=value_out
    ;;  Check if user wishes to quit
    IF (read_out EQ 'q') THEN RETURN
    ;;  Define output
    read_out       = 'sm_cuts'
    ;;  Return
    RETURN
  END
  'sm_con'   : BEGIN
    ;;------------------------------------------------------------------------------------
    ;;  Change SM_CONT
    ;;------------------------------------------------------------------------------------
    comm_name      = 'sm_cont'
    ;;  unset read_pause logical variable
    read_pause     = ''
    ;;  Look for original data
    old_value      = struct_value(cont_str,comm_name[0],INDEX=sind)
    IF (sind[0] LT 0) THEN dumb = TEMPORARY(old_value)
    ;;  Prompt user for new value(s)
    vbulk_change_prompts,dat0,/SM_CONT,                                $
                         CONT_STR=cont_str,WINDN=win,PLOT_STR=plot_str,$
                         READ_OUT=read_out,VALUE_OUT=value_out
    ;;  Check if user wishes to quit
    IF (read_out EQ 'q') THEN RETURN
    ;;  Define output
    read_out       = 'sm_cont'
    ;;  Return
    RETURN
  END
  'vbulk'    : BEGIN
    ;;------------------------------------------------------------------------------------
    ;;  Change VFRAME
    ;;------------------------------------------------------------------------------------
    comm_name      = 'vframe'
    ;;  unset read_pause logical variable
    read_pause     = ''
    ;;  Look for original data
    old_value      = struct_value(cont_str,comm_name[0],INDEX=sind)
    IF (sind[0] LT 0) THEN dumb = TEMPORARY(old_value)
    ;;  Prompt user for new value(s)
    vbulk_change_prompts,dat0,/VFRAME,                                 $
                         CONT_STR=cont_str,WINDN=win,PLOT_STR=plot_str,$
                         READ_OUT=read_out,VALUE_OUT=value_out
    ;;  Check if user wishes to quit
    IF (read_out EQ 'q') THEN RETURN
    ;;  Define output
    read_out       = 'vframe'
    ;;  Return
    RETURN
  END
  'vec1'     : BEGIN
    ;;------------------------------------------------------------------------------------
    ;;  Change VEC1
    ;;------------------------------------------------------------------------------------
    comm_name      = 'vec1'
    ;;  unset read_pause logical variable
    read_pause     = ''
    ;;  Look for original data
    old_value      = struct_value(cont_str,comm_name[0],INDEX=sind)
    IF (sind[0] LT 0) THEN dumb = TEMPORARY(old_value)
    ;;  Prompt user for new value(s)
    vbulk_change_prompts,dat0,/VEC1,                                   $
                         CONT_STR=cont_str,WINDN=win,PLOT_STR=plot_str,$
                         READ_OUT=read_out,VALUE_OUT=value_out
    ;;  Check if user wishes to quit
    IF (read_out EQ 'q') THEN RETURN
    ;;  Define output
    read_out       = 'vec1'
    ;;  Return
    RETURN
  END
  'vec2'     : BEGIN
    ;;------------------------------------------------------------------------------------
    ;;  Change VEC2
    ;;------------------------------------------------------------------------------------
    comm_name      = 'vec2'
    ;;  unset read_pause logical variable
    read_pause     = ''
    ;;  Look for original data
    old_value      = struct_value(cont_str,comm_name[0],INDEX=sind)
    IF (sind[0] LT 0) THEN dumb = TEMPORARY(old_value)
    ;;  Prompt user for new value(s)
    vbulk_change_prompts,dat0,/VEC2,                                   $
                         CONT_STR=cont_str,WINDN=win,PLOT_STR=plot_str,$
                         READ_OUT=read_out,VALUE_OUT=value_out
    ;;  Check if user wishes to quit
    IF (read_out EQ 'q') THEN RETURN
    ;;  Define output
    read_out       = 'vec2'
    ;;  Return
    RETURN
  END
  'v_0x'     : BEGIN
    ;;------------------------------------------------------------------------------------
    ;;  Change V_0X
    ;;------------------------------------------------------------------------------------
    comm_name      = 'v_0x'
    ;;  unset read_pause logical variable
    read_pause     = ''
    ;;  Look for original data
    old_value      = struct_value(cont_str,comm_name[0],INDEX=sind)
    IF (sind[0] LT 0) THEN dumb = TEMPORARY(old_value)
    ;;  Prompt user for new value(s)
    vbulk_change_prompts,dat0,/V_0X,                                   $
                         CONT_STR=cont_str,WINDN=win,PLOT_STR=plot_str,$
                         READ_OUT=read_out,VALUE_OUT=value_out
    ;;  Check if user wishes to quit
    IF (read_out EQ 'q') THEN RETURN
    ;;  Define output
    read_out       = 'v_0x'
    ;;  Return
    RETURN
  END
  'v_0y'     : BEGIN
    ;;------------------------------------------------------------------------------------
    ;;  Change V_0Y
    ;;------------------------------------------------------------------------------------
    comm_name      = 'v_0y'
    ;;  unset read_pause logical variable
    read_pause     = ''
    ;;  Look for original data
    old_value      = struct_value(cont_str,comm_name[0],INDEX=sind)
    IF (sind[0] LT 0) THEN dumb = TEMPORARY(old_value)
    ;;  Prompt user for new value(s)
    vbulk_change_prompts,dat0,/V_0Y,                                   $
                         CONT_STR=cont_str,WINDN=win,PLOT_STR=plot_str,$
                         READ_OUT=read_out,VALUE_OUT=value_out
    ;;  Check if user wishes to quit
    IF (read_out EQ 'q') THEN RETURN
    ;;  Define output
    read_out       = 'v_0y'
    ;;  Return
    RETURN
  END
  'save1'    : BEGIN
    ;;------------------------------------------------------------------------------------
    ;;  SAVE1 --> Save current plot
    ;;------------------------------------------------------------------------------------
    ;;  unset read_pause logical variable
    read_pause     = ''
    ;;  ***  Need to write code for saving current plot window  ***
    ;;  Define output
    read_out       = 'save1'
    ;;  Return
    RETURN
  END
  'save3'    : BEGIN
    ;;------------------------------------------------------------------------------------
    ;;  SAVE3 --> Save all 3 current plots
    ;;------------------------------------------------------------------------------------
    ;;  unset read_pause logical variable
    read_pause     = ''
    ;;  ***  Need to write code for saving all current plot windows  ***
    ;;  Define output
    read_out       = 'save3'
    ;;  Return
    RETURN
  END
  'q'        : BEGIN
    ;;------------------------------------------------------------------------------------
    ;;  Quit so reset defaults
    ;;------------------------------------------------------------------------------------
    ;;  Define output
    read_out       = 'q'
    ;;  Nothing else changes, so return
    RETURN
  END
  'debug'    : BEGIN
    ;;------------------------------------------------------------------------------------
    ;;  Debugging option
    ;;------------------------------------------------------------------------------------
    PRINT,''
    errmssg = 'Debugging error handling => STOP'
    MESSAGE,errmssg,/INFORMATIONAL,/CONTINUE
    STOP
  END
ENDCASE
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN
END


































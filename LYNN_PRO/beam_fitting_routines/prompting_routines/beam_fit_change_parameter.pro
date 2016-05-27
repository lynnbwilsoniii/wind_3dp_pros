;+
;*****************************************************************************************
;
;  PROCEDURE:   beam_fit_change_parameter.pro
;  PURPOSE  :   This routine determines what, if any, parameters the user would like
;                 to change and interactively re-plots after the introduction of each
;                 new change.  This routine is periodically called in case the user
;                 wants to change something they previously accepted.
;
;  CALLED BY:   
;               beam_fit_1df_plot_fit.pro
;
;  CALLS:
;               delete_variable.pro
;               beam_fit_contour_plot.pro
;               beam_fit_gen_prompt.pro
;               beam_fit_options.pro
;               beam_fit___set_common.pro
;               beam_fit_unset_common.pro
;               beam_fit___get_common.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               DAT        :  [N]-Element array of data structures containing particle
;                               velocity distribution functions (DFs) from either the
;                               Wind/3DP instrument [use get_??.pro, ?? = e.g. phb]
;                               or from the THEMIS ESA instruments.  Regardless, the
;                               structures must satisfy the criteria needed to produce
;                               a contour plot showing the phase (velocity) space density
;                               of the DF.  The structures must also have the following
;                               two tags with finite [3]-element vectors:  VSW and MAGF.
;
;  EXAMPLES:    
;               NA
;
;  KEYWORDS:    
;               ***  INPUT  ***
;               INDEX      :  Scalar [long] defining the index that defines which element
;                               of an array of structures that DAT corresponds to
;                               [Default = 0]
;               VCIRC      :  Scalar(or array) [float/double] defining the value(s) to
;                               plot as a circle(s) of constant speed [km/s] on the
;                               contour plot [e.g. gyrospeed of specularly reflected ion]
;                               [Default = FALSE]
;               VB_REG     :  [4]-element array specifying the velocity coordinates
;                               [X0,Y0,X1,Y1] associated with a rectangular region
;                               that encompasses a "beam" to be overplotted onto the
;                               contour plot [km/s]
;               VC_XOFF    :  Scalar(or array) [float/double] defining the center of the
;                               circle(s) associated with VCIRC along the X-Axis
;                               (horizontal)
;                               [Default = 0.0]
;               VC_YOFF    :  Scalar(or array) [float/double] defining the center of the
;                               circle(s) associated with VCIRC along the Y-Axis
;                               (vertical)
;                               [Default = 0.0]
;               MODEL      :  Scalar [float/double] defining the model distribution cuts
;                               the user wishes to overplot onto the data cuts plot
;                               [format consistent with find_dist_func_cuts.pro output]
;               EX_VECN    :  [V]-Element structure array containing extra vectors the
;                               user wishes to project onto the contour, each with
;                               the following format:
;                                  VEC   :  [3]-Element vector in the same coordinate
;                                             system as the bulk flow velocity etc.
;                                             contour plot projection
;                                             [e.g. VEC[0] = along X-GSE]
;                                  NAME  :  Scalar [string] used as a name for VEC
;                                             output onto the contour plot
;                                             [Default = 'Vec_j', j = index of EX_VECS]
;               WINDN      :  Scalar [long] defining the index of the window to use when
;                               selecting the region of interest
;                               [Default = !D.WINDOW]
;
;  KEYWORDS:    
;               ***  OUTPUT  ***
;               !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
;               ***  [all the following changed on output]  ***
;               !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
;               PLOT_STR   :  Set to a named variable to return the scaling factors
;                               needed to allow the user to interactively select,
;                               using their cursor, the regions of interest on the
;                               contour plot.  This structure contains information
;                               necessary to convert from NORMAL to DATA coordinates,
;                               which will be used by region_cursor_select.pro
;               V_LIM_OUT  :  Set to a named variable to return the maximum speed [km/s]
;                               used for the velocity ranges in the contour and cut plots
;               DF_RA_OUT  :  Set to a named variable to return the [2]-element array
;                               defining the DF range of phase (velocity) space
;                               densities [cm^(-3) km^(-3) s^(3)] used for the contour
;                               levels and cut Y-Axis
;               DF_MN_OUT  :  Set to a named variable to return the scalar defining the
;                               minimum allowable phase (velocity) space density
;                               [cm^(-3) km^(-3) s^(3)] used for the contour levels
;                               and cut Y-Axis
;               DF_MX_OUT  :  Set to a named variable to return the scalar defining the
;                               maximum allowable phase (velocity) space density
;                               [cm^(-3) km^(-3) s^(3)] used for the contour levels
;                               and cut Y-Axis
;               DF_OUT     :  Set to a named variable to return the regularly gridded
;                               2D projection of the phase (velocity) space density
;                               [cm^(-3) km^(-3) s^(3)] plotted in the contour
;               DFPAR_OUT  :  Set to a named variable to return the parallel cut
;               DFPER_OUT  :  Set to a named variable to return the perpendicular cut
;               VPAR_OUT   :  Set to a named variable to return the parallel
;                               velocities [km/s]
;               VPER_OUT   :  Set to a named variable to return the perpendicular
;                               velocities [km/s]
;               DATA_OUT   :  Set to a named variable to return a structure containing
;                               the relevant information associated with the plots,
;                               plot analysis, and fit results
;               READ_OUT   :  Set to a named variable to return a string containing the
;                               last command line input.  This is used by the overhead
;                               routine to determine whether user left the program by
;                               quitting or if the program finished
;               DAT_PLOT   :  Scalar data structure corresponding to the particle
;                               velocity distribution function you wish to plot with
;                               the same format as DAT
;
;   CHANGED:  1)  Continued to write routine                       [09/07/2012   v1.0.0]
;             2)  Fixed an issue that occured when changing V_BX, V_BY, and PLANE
;                                                                  [09/11/2012   v1.0.1]
;             3)  Fixed an issue when reseting VSW because user did not like their
;                   change
;                                                                  [09/17/2012   v1.0.2]
;             4)  Cleaned up and added keyword:  ONE_C
;                                                                  [10/09/2012   v1.1.0]
;             5)  Fixed an issue that occurred if the user tried plotting a new plane
;                   but did not keep that plane, thus resetting to the old value, which
;                   caused the file name to be incorrect
;                                                                  [10/11/2012   v1.2.0]
;
;   NOTES:      
;               1)  User should not call this routine
;
;   CREATED:  09/06/2012
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  10/11/2012   v1.2.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

PRO beam_fit_change_parameter,dat,INDEX=index,VCIRC=vcirc,VB_REG=vb_reg,VC_XOFF=vc_xoff,$
                              VC_YOFF=vc_yoff,MODEL=model,EX_VECN=ex_vecn,WINDN=windn,  $
                              PLOT_STR=plot_str,V_LIM_OUT=vlim_out,DF_RA_OUT=dfra_out,  $
                              DF_MN_OUT=dfmin_out,DF_MX_OUT=dfmax_out,DF_OUT=df_out,    $
                              DFPAR_OUT=dfpar_out,DFPER_OUT=dfper_out,VPAR_OUT=vpar_out,$
                              VPER_OUT=vper_out,DATA_OUT=data_out,READ_OUT=read_out,    $
                              DAT_PLOT=dat_plot,ONE_C=one_c

;;----------------------------------------------------------------------------------------
;; => Define some constants and dummy variables
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN

;; => Define parts of file names
xyzvecf        = ['V1','V1xV2xV1','V1xV2']
xy_suff        = xyzvecf[1]+'_vs_'+xyzvecf[0]+'_'
xz_suff        = xyzvecf[0]+'_vs_'+xyzvecf[2]+'_'
yz_suff        = xyzvecf[2]+'_vs_'+xyzvecf[1]+'_'
;;----------------------------------------------------------------------------------------
;; => Check keywords
;;----------------------------------------------------------------------------------------
;; => Define index
IF (N_ELEMENTS(index)    EQ 0)  THEN ind0     = 0L          ELSE ind0     = index[0]
IF (N_ELEMENTS(windn)    EQ 0)  THEN windn    = !D.WINDOW
;; => Define dummy copy
IF (N_ELEMENTS(dat_plot) EQ 0)  THEN dat_orig = dat[ind0]   ELSE dat_orig = dat_plot[0]
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;; => Plot loop
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
true           = 1
WHILE (true) DO BEGIN
  ;; Reset inputs/outputs
  delete_variable,read_out,value_out,status,defined
  ;;--------------------------------------------------------------------------------------
  ;;  Plot original DF
  ;;--------------------------------------------------------------------------------------
  WSET,windn[0]
  WSHOW,windn[0]
  beam_fit_contour_plot,dat_orig,VCIRC=vcirc,VB_REG=vb_reg,VC_XOFF=vc_xoff,               $
                                VC_YOFF=vc_yoff,MODEL=model,EX_VECN=ex_vecn,ONE_C=one_c,  $
                                PLOT_STR=plot_str,V_LIM_OUT=vlim_out,DF_RA_OUT=dfra_out,  $
                                DF_MN_OUT=dfmin_out,DF_MX_OUT=dfmax_out,DF_OUT=df_out,    $
                                DFPAR_OUT=dfpar_out,DFPER_OUT=dfper_out,VPAR_OUT=vpar_out,$
                                VPER_OUT=vper_out
  ;;--------------------------------------------------------------------------------------
  ;;  Check if user wants to change any of the plot ranges
  ;;--------------------------------------------------------------------------------------
  read_out       = ''    ;; output value of decision
  pro_out        = ["[Type 'q' to leave this loop at any time]","",$
                    "Do you wish to change any of the plot ranges or the VSW estimate?",$
                    "     [e.g. VLIM, DFMIN, DFMAX, DFRA, VSW, etc.]"]
  str_out        = "To change any of these type 'y', otherwise type 'n':  "
  WHILE (read_out NE 'y' AND read_out NE 'n' AND read_out NE 'q') DO BEGIN
    read_out = beam_fit_gen_prompt(STR_OUT=str_out,PRO_OUT=pro_out,WINDN=windn,FORM_OUT=7)
    IF (read_out EQ 'debug') THEN STOP
  ENDWHILE
  ;; => Check if user wishes to quit loop
  IF (read_out EQ 'q') THEN BEGIN
    true = 0
    GOTO,JUMP_END  ;; user wants to leave program
  ENDIF
  ;;--------------------------------------------------------------------------------------
  ;;  To change or not to change, that is the question...
  ;;    ...whether 'tis nobler in the mind to suffer the slings and arrows of
  ;;       outrageous GOTO statements...
  ;;       Or to take arms against a sea of options...
  ;;       And by opposing end them;  to fit, to plot, no more...
  ;;--------------------------------------------------------------------------------------
  IF (read_out EQ 'y') THEN BEGIN
    ;; Reset input/output
    delete_variable,name_out,new_value,old_value,defined
    ;; Prompt options
    beam_fit_options,dat,read_in,INDEX=ind0,WINDN=windn,PLOT_STR=plot_str,  $
                                  READ_OUT=name_out,VALUE_OUT=new_value,    $
                                  OLD_VALUE=old_value
    ;; Check old value
    defined        = N_ELEMENTS(old_value)
    IF (defined EQ 0) THEN BEGIN
      ;; original not defined => undefine result
      delete_variable,old_value,defined
    ENDIF
    ;;------------------------------------------------------------------------------------
    ;; determine which variable user changed
    ;;------------------------------------------------------------------------------------
    IF (name_out[0] EQ 'q') THEN BEGIN
      true = 0
      read_out = 'q'
      GOTO,JUMP_END  ;; user wants to leave program
    ENDIF ELSE BEGIN
      ;; Make sure the change was not a switch of index
      test           = (name_out[0] EQ 'next') OR (name_out[0] EQ 'prev') OR (name_out[0] EQ 'index')
      IF (test) THEN BEGIN
        ;;  Delete output structure
        delete_variable,data_out
        ;;  Change index input and leave
        index          = ind0
        read_out       = name_out
        ;;  Return
        RETURN
      ENDIF
    ENDELSE
    
    IF (name_out[0] EQ '') THEN BEGIN
      true = 1
      GOTO,JUMP_SKIP_00  ;; user wants to try again
    ENDIF
    ;;------------------------------------------------------------------------------------
    ;; Check if PLANE was changed
    ;;------------------------------------------------------------------------------------
    IF (name_out[0] EQ 'plane') THEN BEGIN
      good_pl = WHERE(new_value,gdpl)
      IF (gdpl NE 1) THEN BEGIN
        ;; something is wrong => go back to default
        beam_fit___set_common,'plane','xy',STATUS=status
        new_value = 'xy'
        ;; Reset/Fix file_midf
        ngrid     = beam_fit___get_common('ngrid',DEFINED=defined)
        IF (defined EQ 0) THEN BEGIN
          ;; => If not set, then get defaults
          ngrid      = beam_fit___get_common('def_ngrid',DEFINED=defined)
        ENDIF
        def_val_str    = STRING(ngrid[0],FORMAT='(I2.2)')+'Grids_'
        projxy         = beam_fit___get_common('plane',DEFINED=defined)
        IF (defined EQ 0) THEN BEGIN
          ;; => If not set, then use default
          projxy    = 'xy'
        ENDIF
        CASE projxy[0] OF
          'xy'  :  file_midf = xy_suff[0]+def_val_str[0]
          'xz'  :  file_midf = xz_suff[0]+def_val_str[0]
          'yz'  :  file_midf = yz_suff[0]+def_val_str[0]
        ENDCASE
        beam_fit___set_common,'file_midf',file_midf,STATUS=status
      ENDIF ELSE BEGIN
        ;; success!!
        new_value = (['xy','xz','yz','zz'])[good_pl[0]]
      ENDELSE
    ENDIF
    ;;------------------------------------------------------------------------------------
    ;; Check if VSW was changed
    ;;------------------------------------------------------------------------------------
    IF (name_out[0] EQ 'vsw') THEN BEGIN
      IF (N_ELEMENTS(old_value) NE 3) THEN old_value = dat_orig[0].VSW
      ;;  Make sure new value is defined
      IF (N_ELEMENTS(new_value) NE 0) THEN BEGIN
        ;; Change only new one
        dat_orig[0].VSW = new_value
      ENDIF ELSE BEGIN
        ;; No change, try again
        true           = 1
        GOTO,JUMP_SKIP_00
      ENDELSE
    ENDIF
    ;;------------------------------------------------------------------------------------
    ;; Replot and see if user likes changes
    ;;------------------------------------------------------------------------------------
    WSET,windn[0]
    WSHOW,windn[0]
    beam_fit_contour_plot,dat_orig,VCIRC=vcirc,VB_REG=vb_reg,VC_XOFF=vc_xoff,               $
                                  VC_YOFF=vc_yoff,MODEL=model,EX_VECN=ex_vecn,ONE_C=one_c,  $
                                  PLOT_STR=plot_str,V_LIM_OUT=vlim_out,DF_RA_OUT=dfra_out,  $
                                  DF_MN_OUT=dfmin_out,DF_MX_OUT=dfmax_out,DF_OUT=df_out,    $
                                  DFPAR_OUT=dfpar_out,DFPER_OUT=dfper_out,VPAR_OUT=vpar_out,$
                                  VPER_OUT=vper_out
    ;;------------------------------------------------------------------------------------
    ;; Check if user likes this setting
    ;;------------------------------------------------------------------------------------
    read_out       = ''    ;; output value of decision
    str_out        = "To keep change type 'y', otherwise type 'n':  "
    pro_out        = ["[Type 'q' to leave this loop at any time]","",$
                      "Do you wish to keep this change?"]
    WHILE (read_out NE 'y' AND read_out NE 'n' AND read_out NE 'q') DO BEGIN
      read_out = beam_fit_gen_prompt(STR_OUT=str_out,PRO_OUT=pro_out,WINDN=windn,FORM_OUT=7)
      IF (read_out EQ 'debug') THEN STOP
    ENDWHILE
    ;; => Check if user wishes to quit
    IF (read_out EQ 'q') THEN BEGIN
      true = 0
      GOTO,JUMP_END  ;; user wants to leave program
    ENDIF
    ;;------------------------------------------------------------------------------------
    ;; => Check if user wishes to keep setting
    ;;------------------------------------------------------------------------------------
    IF (read_out EQ 'y') THEN BEGIN
      ;;----------------------------------------------------------------------------------
      ;; Check if more than one element
      ;;----------------------------------------------------------------------------------
      test           = (N_ELEMENTS(name_out) EQ 1)
      IF (test) THEN BEGIN
        ;; Only 1 element
        ;;   => Use new variable
        beam_fit___set_common,name_out,new_value,STATUS=status
        IF (N_ELEMENTS(status) EQ 0) THEN BEGIN
          bad_setcom = "Failed to change value associated with "+STRUPCASE(name_out)
          MESSAGE,bad_setcom,/INFORMATIONAL,/CONTINUE
          ;; Failed to set common block variable to NEW_VALUE => Undefine
          beam_fit_unset_common,name_out,STATUS=status
        ENDIF ELSE BEGIN
          ;; New variable set correctly, check if VSW
          IF (STRLOWCASE(name_out) EQ 'vsw') THEN BEGIN
            vsw            = beam_fit___get_common('vsw',DEFINED=defined)
            IF (defined NE 0) THEN BEGIN
              ;; => Change values in structure
              dat_orig.VSW   = vsw
            ENDIF
          ENDIF
        ENDELSE
      ENDIF ELSE BEGIN
        ;; More than 1 element
        ;;   => V_BX and V_BY
        test           = (N_ELEMENTS(name_out) NE N_ELEMENTS(new_value))
        IF (test) THEN BEGIN
          ;; => bad, so try again
          str_name   = STRUPCASE(name_out[0])+" and "+STRUPCASE(name_out[1])
          bad_setcom = "Failed to change value(s) associated with "+str_name
          MESSAGE,bad_setcom,/INFORMATIONAL,/CONTINUE
          ;; Failed to set common block variable to NEW_VALUE => Undefine
          beam_fit_unset_common,name_out,STATUS=status
        ENDIF ELSE BEGIN
          ;; => good
          FOR j=0L, N_ELEMENTS(name_out) - 1L DO BEGIN
            beam_fit___set_common,name_out[j],new_value[j],STATUS=status
            IF (N_ELEMENTS(status) EQ 0) THEN BEGIN
              ;; failed
              bad_setcom = "Failed to change value associated with "+STRUPCASE(name_out[j])
              MESSAGE,bad_setcom,/INFORMATIONAL,/CONTINUE
              ;; Failed to set common block variable to NEW_VALUE => Undefine
              beam_fit_unset_common,name_out,STATUS=status
            ENDIF ELSE BEGIN
              ;; success!!!
              IF (STRLOWCASE(name_out[j]) EQ 'vsw') THEN BEGIN
                vsw            = beam_fit___get_common('vsw',DEFINED=defined)
                IF (defined NE 0) THEN BEGIN
                  ;; => Change values in structure
                  dat_orig.VSW   = vsw
                ENDIF
              ENDIF
            ENDELSE
          ENDFOR
        ENDELSE
      ENDELSE
      ;; Try again
      true           = 1
    ENDIF ELSE BEGIN
      ;;----------------------------------------------------------------------------------
      ;; Unset new variable
      ;;----------------------------------------------------------------------------------
      beam_fit_unset_common,name_out,STATUS=status
      IF (N_ELEMENTS(old_value) NE 0) THEN BEGIN
        ;; Use old variable
        beam_fit___set_common,name_out,old_value,STATUS=status
        IF (N_ELEMENTS(status) EQ 0) THEN BEGIN
          ;; Failed to set common block variable to OLD_VALUE => Undefine
          beam_fit_unset_common,name_out,STATUS=status
        ENDIF ELSE BEGIN
          ;; success!!!
          IF (STRLOWCASE(name_out) EQ 'vsw') THEN BEGIN
            ;; Reset VSW to original value
            dat_orig[0].VSW = old_value
          ENDIF
          ;; Check if user altered PLANE
          IF (STRLOWCASE(name_out) EQ 'plane') THEN BEGIN
            ;; Reset/Fix file_midf
            ngrid     = beam_fit___get_common('ngrid',DEFINED=defined)
            IF (defined EQ 0) THEN BEGIN
              ;; => If not set, then get defaults
              ngrid      = beam_fit___get_common('def_ngrid',DEFINED=defined)
            ENDIF
            def_val_str    = STRING(ngrid[0],FORMAT='(I2.2)')+'Grids_'
            projxy         = beam_fit___get_common('plane',DEFINED=defined)
            IF (defined EQ 0) THEN BEGIN
              ;; => If not set, then use default
              projxy    = 'xy'
            ENDIF
            CASE projxy[0] OF
              'xy'  :  file_midf = xy_suff[0]+def_val_str[0]
              'xz'  :  file_midf = xz_suff[0]+def_val_str[0]
              'yz'  :  file_midf = yz_suff[0]+def_val_str[0]
            ENDCASE
            beam_fit___set_common,'file_midf',file_midf,STATUS=status
          ENDIF
        ENDELSE
      ENDIF
      ;; Try again
      true           = 1
    ENDELSE
    ;;====================================================================================
    JUMP_SKIP_00:
    ;;====================================================================================
    test           = (read_out EQ 'q')
    IF (test) THEN BEGIN
      str_out        = "Did you want to quit (type 'q') or just stop changing DF parameters (type 'n'):  "
      ;; => Set/Reset outputs
      read_out       = ''    ;; output value of decision
      WHILE (read_out NE 'n' AND read_out NE 'q') DO BEGIN
        read_out       = beam_fit_gen_prompt(STR_OUT=str_out,FORM_OUT=7)
        IF (read_out EQ 'debug') THEN STOP
      ENDWHILE
      ;; => Check if user wishes to quit
      IF (read_out EQ 'q') THEN GOTO,JUMP_END  ;; user wants to leave program
    ENDIF
  ENDIF ELSE BEGIN
    ;;------------------------------------------------------------------------------------
    ;; everything is fine, so leave
    ;;------------------------------------------------------------------------------------
    true           = 0
  ENDELSE
ENDWHILE
;;========================================================================================
JUMP_END:
;;========================================================================================

;; Redefine input/output
dat_plot       = dat_orig[0]
;;----------------------------------------------------------------------------------------
;; => Return to calling routine
;;----------------------------------------------------------------------------------------

RETURN
END


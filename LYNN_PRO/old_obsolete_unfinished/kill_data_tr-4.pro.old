;+
;*****************************************************************************************
;
;  FUNCTION :   kill_data_tr.pro
;  PURPOSE  :   Interactively kills data between two times defined by user either with
;                 the cursor or inputs D1 and D2 by setting the data to NaNs.
;
;  CALLED BY:   
;               NA
;
;  INCLUDES:
;               NA
;
;  CALLS:
;               tnames.pro
;               set_tplot_times.pro
;               tplot_com.pro
;               str_element.pro
;               ctime.pro
;               gettime.pro
;               get_data.pro
;               store_data.pro
;               tplot.pro
;
;  REQUIRES:    
;               1)  THEMIS TDAS IDL libraries or UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               D1[2]       :  Scalar [string or double] defining the start[end] time
;                                between which the data associated with NAMES will be
;                                removed --> set to NaNs
;                                [see time_struct.pro for input formats]
;
;  EXAMPLES:    
;               ;;..............................................................;;
;               ;; If data is plotted already in TPLOT that you wish to destroy ;;
;               ;;   and you wish to use the cursors to set the times to kill   ;;
;               ;;..............................................................;;
;               kill_data_tr
;               ;;..............................................................;;
;               ;; If data is plotted already in TPLOT that you wish to destroy ;;
;               ;;   and you wish to define the time range with a scalar        ;;
;               ;;..............................................................;;
;               t1 = '2000-04-05/12:30:45.633'
;               t2 = '2000-04-05/12:33:46.543'
;               kill_data_tr,t1,t1
;               ;;..............................................................;;
;               ;; If data is plotted already in TPLOT that you wish to destroy ;;
;               ;;   and you wish to define the time range with a double        ;;
;               ;;..............................................................;;
;               t1 = time_double('2000-04-05/12:30:45.633')
;               t2 = time_double('2000-04-05/12:33:46.543')
;               kill_data_tr,t1,t1
;               ;;..............................................................;;
;               ;; If data is not plotted in TPLOT already, then define which   ;;
;               ;;   TPLOT handles to use                                       ;;
;               ;;..............................................................;;
;               kill_data_tr,NAMES=tnames([1,3,5])
;
;
;               ;;..............................................................;;
;               ;;  Remove an unspecified # of intervals and return time ranges ;;
;               ;;   associated with those intervals                            ;;
;               ;;..............................................................;;
;               gnames = tnames([1,3,5])
;               kill_data_tr,NAMES=gnames,/MKILL,TRA_KILLED=tra_mkilled
;               HELP, tra_mkilled, /STRUC
;               ** Structure <25c22b28>, N tags, length=??, data length=??, refs=1:
;                  T_0000          DOUBLE    Array[2]
;                  T_0001          DOUBLE    Array[2]
;                  .
;                  .
;                  .
;                  T_0xxN          DOUBLE    Array[2]
;
;
;               ;;..............................................................;;
;               ;;  Remove a user specified # of intervals and return time      ;;
;               ;;   ranges associated with those intervals                     ;;
;               ;;..............................................................;;
;               gnames = tnames([1,3,5])
;               nk     = 10L
;               kill_data_tr,NAMES=gnames,NKILL=nk,TRA_KILLED=tra_nkilled
;               ;;   tra_nkilled will have 10 tags
;
;  KEYWORDS:    
;               NAMES       :  [N]-Element [string,long] array defining which TPLOT
;                                handles are to have their associated values set to
;                                NaNs
;               MKILL       :  If set, routine will prompt user asking whether they wish
;                                remove another set of values or if they wish to replot
;                                the data, return TRA_KILLED, and exit routine
;               NKILL       :  Scalar [long] defining the # of intervals the user knows,
;                                a priori, that they wish to remove
;                                [Default = 1]
;               TRA_KILLED  :  Set to a named variable to return the time ranges
;                                and TPLOT handles defining where and what data was set
;                                to NaNs
;               IND_2D      :  [I]-Element [long] array defining the indices of a 2D
;                                data array in the 2nd dimension (i.e., not the time
;                                dimension) that the user wishes to remove while
;                                leaving the rest of the values in the other indices
;                                in the 2nd dimension alone.
;                                [Default = {All indices}]
;               IND_3D      :  [J]-Element [long] array defining the indices of a 3D
;                                data array in the 3rd dimension (i.e., not the time
;                                dimension) that the user wishes to remove while
;                                leaving the rest of the values in the other indices
;                                in the 3rd dimension alone.
;                                [Default = {All indices}]
;
;   CHANGED:  1)  Added keywords:  MKILL, NKILL, and TRA_KILLED
;                                                                   [01/31/2013   v2.0.0]
;             2)  Added keywords:  IND_2D
;                                                                   [02/06/2015   v2.1.0]
;             3)  Routine can now handle TSHIFT structure tag for TPLOT structures
;                                                                   [04/21/2016   v2.2.0]
;             4)  Changed use of TSHIFT to offset TRANGE, not all times in arrays to
;                   minimize any potential rounding error issues
;                                                                   [04/21/2016   v2.2.1]
;
;   NOTES:      
;               1)  Make sure you either define the TPLOT handles to be "killed" or
;                     make sure the ones you want "killed" are currently plotted
;                     before running this program!
;               2)  It would be wise to create a copy of the data you wish to kill
;                     to avoid destroying data that you want back.
;               3)  TRA_KILLED and NKILL are only used in association with MKILL
;                     => NKILL is not required if you wish to remove an unknown # of
;                          intervals prior to calling routine
;               4)  ** Be careful with the IND_2D and IND_3D keywords **
;                     make sure that the indices you define actually exist for all
;                     TPLOT handles in NAMES
;
;  REFERENCES:  
;               NA
;
;   CREATED:  02/01/2010
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  04/21/2016   v2.2.1
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

PRO kill_data_tr,d1,d2,NAMES=names,MKILL=mkill,NKILL=nkill,TRA_KILLED=tra_killed,$
                       IND_2D=ind_2d,IND_3D=ind_3d

;;----------------------------------------------------------------------------------------
;;  Constants
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
;;  Define some prompt statements and error messages
no_tplot       = 'You must first load some data into TPLOT!'
no_plot        = 'You must first plot something in TPLOT!'
cur_prompt     = "Use cursor to select a begin time and an end time"
notplot_mssg   = 'No TPLOT handles defined... no data will be set to NaNs!'
badinput_mssg  = 'Incorrect number of terms entered...'
badform_mssg   = 'Incorrect input format...'
;;----------------------------------------------------------------------------------------
;;  Make sure user loaded at least one TPLOT variable
;;----------------------------------------------------------------------------------------
tpn_all        = tnames()
IF (tpn_all[0] EQ '') THEN BEGIN
  MESSAGE,no_tplot[0],/INFORMATIONAL,/CONTINUE
  RETURN
ENDIF
;;----------------------------------------------------------------------------------------
;;  Check input
;;----------------------------------------------------------------------------------------
n              = N_PARAMS()
;;----------------------------------------------------------------------------------------
;;  Set TPLOT times
;;      --> Ensures that the TPLOT common block structure is formatted and filled
;;----------------------------------------------------------------------------------------
set_tplot_times
;;----------------------------------------------------------------------------------------
;;  Load common blocks
;;----------------------------------------------------------------------------------------
@tplot_com.pro
COMMON times_dats, t
;;  Check that common blocks have been loaded already
test           = (SIZE(tplot_vars,/TYPE) NE 8)
IF (test) THEN BEGIN
  MESSAGE,no_tplot[0]+' [must load tplot_com.pro]',/INFORMATIONAL,/CONTINUE
  RETURN
ENDIF
;;  Determine current settings and options
str_element,tplot_vars,      'OPTIONS.TRANGE',trange
str_element,tplot_vars, 'OPTIONS.TRANGE_FULL',trange_full
str_element,tplot_vars, 'SETTINGS.trange_old',trange_old
str_element,tplot_vars, 'SETTINGS.TIME_SCALE',time_scale
str_element,tplot_vars,'SETTINGS.TIME_OFFSET',time_offset
str_element,tplot_vars,   'SETTINGS.X.CRANGE',time_xcrange
str_element,tplot_vars,    'OPTIONS.VARNAMES',plotted_names
;;----------------------------------------------------------------------------------------
;;  Make sure something is plotted
;;----------------------------------------------------------------------------------------
test           = (N_ELEMENTS(time_xcrange) EQ 0) OR (N_ELEMENTS(plotted_names) EQ 0)
IF (test) THEN BEGIN
  MESSAGE,no_plot[0],/INFORMATIONAL,/CONTINUE
  RETURN
ENDIF
;;  Define time ranges
temp           = trange
tr             = (tplot_vars.SETTINGS.X.CRANGE * time_scale) + time_offset
;;----------------------------------------------------------------------------------------
;;  Determine which TPLOT handles are to have data removed
;;----------------------------------------------------------------------------------------
;;  Check NAMES
test           = (N_ELEMENTS(names) EQ 0)
IF (test) THEN gnames = tnames(plotted_names) ELSE gnames = tnames(names)

good = WHERE(gnames NE '',gd)
IF (gd EQ 0) THEN BEGIN
  MESSAGE,notplot_mssg[0],/INFORMATIONAL,/CONTINUE
  RETURN
ENDIF ELSE gnames = gnames[good]
;;----------------------------------------------------------------------------------------
;;  Check keywords
;;----------------------------------------------------------------------------------------
;;  Check MKILL
test           = (N_ELEMENTS(mkill) EQ 0) OR (KEYWORD_SET(mkill) NE 1)
IF (test[0]) THEN multi_kill = 0 ELSE multi_kill = 1

;;  Check NKILL
test           = (N_ELEMENTS(nkill) EQ 0)
IF (test[0]) THEN num_kill = 1 ELSE num_kill = LONG(nkill[0])

known_nkill    = (num_kill GT 1)

;;  LBW  02/06/2015   v2.1.0
;;  Check IND_2D
test           = (N_ELEMENTS(ind_2d) EQ 0) OR (SIZE(ind_2d,/N_DIMENSIONS) GT 1)
IF (test[0]) THEN bad_2d_ind = 0 ELSE bad_2d_ind = 1

;;  LBW  02/06/2015   v2.1.0
;;  Check IND_3D
test           = (N_ELEMENTS(ind_3d) EQ 0) OR (SIZE(ind_3d,/N_DIMENSIONS) GT 1)
IF (test[0]) THEN bad_3d_ind = 0 ELSE bad_3d_ind = 1
;;----------------------------------------------------------------------------------------
;;  Loop if user wants to remove multiple spikes at once, otherwise perform one cycle
;;----------------------------------------------------------------------------------------
kind           = 0L
true           = 1
WHILE (true) DO BEGIN
  ;;--------------------------------------------------------------------------------------
  ;;  Determine time range(s) of interest
  ;;--------------------------------------------------------------------------------------
  CASE n[0] OF
    0    :  BEGIN
      ;;  reset variable
      t     = 0
      ;;----------------------------------------------------------------------------------
      ;;  Use cursor to select time ranges manually
      ;;----------------------------------------------------------------------------------
      ctime,t,PROMPT=cur_prompt[0],HOURS=hours,MINUTES=minutes,SECONDS=seconds,DAYS=days,$
              NPOINTS=2
      IF N_ELEMENTS(t) NE 2 THEN RETURN    ;;  failed --> leave routine
      t1    = t[0]
      t2    = t[1]
      delta = tr[1] - tr[0]
      test  = [((t1 LT tr[0]) AND (t2 GT tr[1])),$
               ((t1 GT tr[1]) AND (t2 GT tr[1])),$
               ((t1 LT tr[0]) AND (t2 LT tr[0])),$
                (t2 LT t1)]
      good  = WHERE(test,gd)
      CASE good[0] OF
        0    :  trange = trange_full      ; full range
        1    :  trange = tr + delta       ; pan right
        2    :  trange = tr - delta       ; pan left
        3    :  trange = trange_old       ; last limits
        ELSE :  trange = [t1,t2]          ; new range
      ENDCASE
    END
    1    :  BEGIN
      ;;----------------------------------------------------------------------------------
      ;;  User entered 1 value
      ;;----------------------------------------------------------------------------------
      IF (N_ELEMENTS(d1) EQ 2) THEN BEGIN
        ;;  D1 has 2 elements
        trange = gettime(d1)
      ENDIF ELSE BEGIN
        IF (N_ELEMENTS(d1) NE 1) THEN BEGIN
          ;;  Input had an incorrect number of elements
          MESSAGE,badform_mssg[0],/INFORMATIONAL,/CONTINUE
          RETURN
        ENDIF
        trange = [gettime(d1),gettime(d1) + tr[1] - tr[0]]
      ENDELSE
    END
    2    :  BEGIN
      ;;----------------------------------------------------------------------------------
      ;;  User entered 2 values
      ;;----------------------------------------------------------------------------------
      trange = gettime([d1,d2])
    END
    ELSE :  BEGIN
      ;;----------------------------------------------------------------------------------
      ;;  User entered incorrect number of terms
      ;;----------------------------------------------------------------------------------
      MESSAGE,badinput_mssg[0],/INFORMATIONAL,/CONTINUE
      RETURN
    END
  ENDCASE
  ;;--------------------------------------------------------------------------------------
  ;;  get data and interactively kill it [unless SPEC = 1]
  ;;--------------------------------------------------------------------------------------
  gnn = N_ELEMENTS(gnames)
  FOR j=0L, gnn - 1L DO BEGIN
    ;;  Reset some variables
    IF (N_ELEMENTS(t_offset) GT 0) THEN dumb = TEMPORARY(t_offset)
    ;;  Get data
    get_data,gnames[j],DATA=dat0,DLIM=dlim_old,LIM=lim_old
    IF (SIZE(dat0,/TYPE) NE 8) THEN CONTINUE  ;;  move on
    times  = dat0.X
    str_element,dat0,'TSHIFT',t_offset
    tra_rm = trange
    IF (N_ELEMENTS(t_offset) GT 0) THEN tra_rm -= t_offset[0]
;    IF (N_ELEMENTS(t_offset) GT 0) THEN times += t_offset[0]
    szn    = SIZE(dat0.Y,/N_DIMENSIONS)
    szd    = SIZE(dat0.Y,/DIMENSIONS)
    szt    = N_ELEMENTS(times)
;    szt    = N_ELEMENTS(dat0.X)
    match  = WHERE(szd EQ szt,mtc)
    temp   = dat0.Y
    bad    = WHERE(times LE tra_rm[1] AND times GE tra_rm[0],bd)
;    bad    = WHERE(times LE trange[1] AND times GE trange[0],bd)
;    bad    = WHERE(dat0.X LE trange[1] AND dat0.X GE trange[0],bd)
    ;;  Define some parameters used later
    CASE szn[0] OF
      2    : BEGIN
        CASE match[0] OF
          0    : mnmx2i = [0L,szd[1] - 1L]
          1    : mnmx2i = [0L,szd[0] - 1L]
          ELSE :          ;;  Don't know what to do with this
        ENDCASE
      END
      3    : BEGIN
        ;;  Assume cyclic permutations for which dimension corresponds to the 3rd
        CASE match[0] OF
          0    : BEGIN
            mnmx3i = [0L,szd[2] - 1L]
            mnmx2i = [0L,szd[1] - 1L]
          END
          1    : BEGIN
            mnmx3i = [0L,szd[0] - 1L]
            mnmx2i = [0L,szd[2] - 1L]
          END
          2    : BEGIN
            mnmx3i = [0L,szd[1] - 1L]
            mnmx2i = [0L,szd[0] - 1L]
          END
          ELSE :        ;;  Don't know what to do with this
        ENDCASE
      END
      ELSE :          ;;  Don't worry about this here
    ENDCASE
    
    IF (bd GT 0) THEN BEGIN
      CASE szn[0] OF
        1    : BEGIN
          ;;------------------------------------------------------------------------------
          ;;  1D Array of data
          ;;------------------------------------------------------------------------------
          temp[bad] = f
        END
        2    : BEGIN
          ;;------------------------------------------------------------------------------
          ;;  2D Array of data
          ;;------------------------------------------------------------------------------
          ;;  Check if user only wants to remove specific indices of 2nd dimension
          IF (bad_2d_ind[0]) THEN BEGIN
            ;;  Make sure user has not defined "bad" indices
            test = (ind_2d LT mnmx2i[0]) OR (ind_2d GT mnmx2i[1])
            bind = WHERE(test,bdi,COMPLEMENT=gind,NCOMPLEMENT=gdi)
            IF (gdi[0] GT 0) THEN ind = ind_2d[gind] ELSE ind = LINDGEN(mnmx2i[1] + 1L)
          ENDIF ELSE ind = LINDGEN(mnmx2i[1] + 1L)
          CASE match[0] OF
            0    : FOR jj=0L, N_ELEMENTS(ind) - 1L DO temp[bad,ind[jj]] = f
            1    : FOR jj=0L, N_ELEMENTS(ind) - 1L DO temp[ind[jj],bad] = f
            ELSE :        ;;  Don't know what to do with this
          ENDCASE
;;  LBW  02/06/2015   v2.1.0
;          CASE match[0] OF
;            0    : temp[bad,*] = f
;            1    : temp[*,bad] = f
;            ELSE :        ;;  Don't know what to do with this
;          ENDCASE
        END
        3    : BEGIN
          ;;------------------------------------------------------------------------------
          ;;  3D Array of data
          ;;------------------------------------------------------------------------------
          ;;  Check if user wants to remove only specific indices of 2nd dimension
          IF (bad_2d_ind[0]) THEN BEGIN
            ;;  Make sure user has not defined "bad" indices
            test = (ind_2d LT mnmx2i[0]) OR (ind_2d GT mnmx2i[1])
            bind = WHERE(test,bdi,COMPLEMENT=gind,NCOMPLEMENT=gdi)
            IF (gdi[0] GT 0) THEN ind2 = ind_2d[gind] ELSE ind2 = LINDGEN(mnmx2i[1] + 1L)
          ENDIF ELSE ind2 = LINDGEN(mnmx2i[1] + 1L)
          ;;  Check if user only wants to remove specific indices of 2nd dimension
          IF (bad_3d_ind[0]) THEN BEGIN
            ;;  Make sure user has not defined "bad" indices
            test = (ind_3d LT mnmx3i[0]) OR (ind_3d GT mnmx3i[1])
            bind = WHERE(test,bdi,COMPLEMENT=gind,NCOMPLEMENT=gdi)
            IF (gdi[0] GT 0) THEN ind3 = ind_3d[gind] ELSE ind3 = LINDGEN(mnmx3i[1] + 1L)
          ENDIF ELSE ind3 = LINDGEN(mnmx3i[1] + 1L)
          n_i2  = N_ELEMENTS(ind2)
          n_i3  = N_ELEMENTS(ind3)
          ;;------------------------------------------------------------------------------
          ;;  Remove desired values
          ;;------------------------------------------------------------------------------
          IF (bad_2d_ind[0] OR bad_3d_ind[0]) THEN BEGIN
            IF (bad_2d_ind[0] AND bad_3d_ind[0]) THEN BEGIN
              ;;--------------------------------------------------------------------------
              ;;  Both are set --> cycle through both dimensions [kill 2nd first]
              ;;--------------------------------------------------------------------------
              CASE match[0] OF
                0    : BEGIN
                  FOR kk=0L, n_i2[0] - 1L DO temp[bad,ind2[kk],*] = f
                  FOR jj=0L, n_i3[0] - 1L DO temp[bad,*,ind3[jj]] = f
;                  FOR kk=0L, n_i2[0] - 1L DO FOR jj=0L, n_i3[0] - 1L DO temp[bad,ind2[kk],ind3[jj]] = f
                END
                1    : BEGIN
                  FOR kk=0L, n_i2[0] - 1L DO temp[*,bad,ind2[kk]] = f
                  FOR jj=0L, n_i3[0] - 1L DO temp[ind3[jj],bad,*] = f
;                  FOR kk=0L, n_i2[0] - 1L DO FOR jj=0L, n_i3[0] - 1L DO temp[ind3[jj],bad,ind2[kk]] = f
                END
                2    : BEGIN
                  FOR kk=0L, n_i2[0] - 1L DO temp[ind2[kk],*,bad] = f
                  FOR jj=0L, n_i3[0] - 1L DO temp[*,ind3[jj],bad] = f
;                  FOR kk=0L, n_i2[0] - 1L DO FOR jj=0L, n_i3[0] - 1L DO temp[ind2[kk],ind3[jj],bad] = f
                END
                ELSE :        ;;  Don't know what to do with this
              ENDCASE
            ENDIF ELSE BEGIN
              ;;--------------------------------------------------------------------------
              ;;  Only one is set --> only cycle through that dimension
              ;;--------------------------------------------------------------------------
              IF (bad_3d_ind[0]) THEN BEGIN
                ;;  Only IND_3D is set --> only cycle through that dimension
                CASE match[0] OF
                  0    : FOR jj=0L, n_i3[0] - 1L DO temp[bad,*,ind3[jj]] = f
                  1    : FOR jj=0L, n_i3[0] - 1L DO temp[ind3[jj],bad,*] = f
                  2    : FOR jj=0L, n_i3[0] - 1L DO temp[*,ind3[jj],bad] = f
                  ELSE :        ;;  Don't know what to do with this
                ENDCASE
              ENDIF ELSE BEGIN
                ;;  Only IND_2D is set --> only cycle through that dimension
                CASE match[0] OF
                  0    : FOR kk=0L, n_i2[0] - 1L DO temp[bad,ind2[kk],*] = f
                  1    : FOR kk=0L, n_i2[0] - 1L DO temp[*,bad,ind2[kk]] = f
                  2    : FOR kk=0L, n_i2[0] - 1L DO temp[ind2[kk],*,bad] = f
                  ELSE :        ;;  Don't know what to do with this
                ENDCASE
              ENDELSE
            ENDELSE
          ENDIF ELSE BEGIN
            ;;  Remove values associated with all 2nd and 3rd dimension indices
            CASE match[0] OF
              0    : temp[bad,*,*] = f
              1    : temp[*,bad,*] = f
              2    : temp[*,*,bad] = f
              ELSE :        ;;  Don't know what to do with this
            ENDCASE
          ENDELSE
;;  LBW  02/06/2015   v2.1.0
;          CASE match[0] OF
;            0    : temp[bad,*,*] = f
;            1    : temp[*,bad,*] = f
;            2    : temp[*,*,bad] = f
;            ELSE :        ;;  Don't know what to do with this
;          ENDCASE
        END
        ELSE :        ;;  Not 1, 2, or 3 dimensions?
      ENDCASE
    ENDIF
    dat0.Y = temp
    store_data,gnames[j],DATA=dat0,DLIM=dlim_old,LIM=lim_old
  ENDFOR
  ;;--------------------------------------------------------------------------------------
  ;;  Check if user wants to remove multiple or single interval
  ;;--------------------------------------------------------------------------------------
  IF (multi_kill OR known_nkill) THEN BEGIN
    IF (known_nkill) THEN BEGIN
      ;;----------------------------------------------------------------------------------
      ;;  User specified they wanted to remove a known # of intervals
      ;;----------------------------------------------------------------------------------
      ;;  make sure index has not exceeded the user specified value
      true     = (kind LT num_kill - 1L)
    ENDIF ELSE BEGIN
      read_out = ''
      ;;----------------------------------------------------------------------------------
      ;;  User specified they wanted to remove an unknown # of intervals, so check
      ;;----------------------------------------------------------------------------------
      info0    = "To kill data in another interval type 'y', else type 'n'."
      info1    = "To quit at any time type 'q'."
      mssg     = "Do you wish to kill more data (y/n)?  "
      WHILE (read_out NE 'n' AND read_out NE 'y' AND read_out NE 'q') DO BEGIN
        PRINT, ""
        PRINT, info0[0]
        PRINT, info1[0]
        PRINT, ""
        READ,read_out,PROMPT=mssg
        PRINT, ""
        IF (read_out EQ 'debug') THEN STOP
      ENDWHILE
      ;;  make sure index has not exceeded 9999 and user wishes to continue
      true     = (kind LT 9999L) AND (read_out EQ 'y')
      IF (read_out EQ 'q') THEN true = 0  ;; user wishes to quit
    ENDELSE
  ENDIF ELSE BEGIN
    ;;  User only wants to remove 1 interval
    true     = 0
  ENDELSE
  ;;--------------------------------------------------------------------------------------
  ;;  Add time range to output and increment index
  ;;--------------------------------------------------------------------------------------
  kstr  = 'T_'+STRING(kind[0],FORMAT='(I4.4)')
  str_element,tra_killed,kstr[0],trange,/ADD_REPLACE
  ;;  increment index
  kind += 1L
  ;;--------------------------------------------------------------------------------------
  ;;  Replot
  ;;--------------------------------------------------------------------------------------
  tplot,plotted_names
ENDWHILE
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN
END

;+
;*****************************************************************************************
;
;  FUNCTION :   get_3dp_structs.pro
;  PURPOSE  :   This program retrieves the data structures from the 3DP Wind binary
;                 files associated with the user input name (e.g., 'el').  It then
;                 alters the structures slightly to prevent conflicting data structure
;                 errors when using them in other programs.  It also eliminates
;                 structures which have dat.VALID = 0 from the array of structures
;                 returned to the user.  The output structure consists of an array of
;                 start and end times associated with the 3DP structures (Unix times)
;                 and an array of 3DP data structures.  WindLib rotates the data into
;                 GSE coordinates before the user is allowed to do anything with the
;                 structures, thus when adding magnetic fields or velocities to the
;                 data structures, make sure they are in GSE coordinates.
;
;  CALLED BY:   
;               NA
;
;  INCLUDES:
;               NA
;
;  CALLS:
;               dat_3dp_str_names.pro
;               interp.pro
;               gettime.pro
;               dummy_3dp_str.pro
;               str_element.pro
;               get_??.pro (?? = eh,elb,pl,plb,ph,phb...)
;
;  REQUIRES:    
;               1)  External Windlib shared object libraries
;                     [e.g., ~/WIND_PRO/wind3dp_lib_darwin_i386.so]
;               2)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               MYN1    :  Scalar [string] defining the type of structure for which you
;                            wish to get data [i.e., 'el','eh','elb', etc.]
;
;  EXAMPLES:    
;               [calling sequence]
;               dat = get_3dp_structs(myn1 [,TRANGE=trange])
;
;               ;;  Example
;               tr  = time_double(['1996-04-06/10:00:00','1996-04-07/10:00:00'])
;               dat = get_3dp_structs('el',TRANGE=tr)
;               els = dat.DATA    ;;  All Eesa Low structures in given time range
;
;  KEYWORDS:    
;               TRANGE  :  [2]-Element [double] array specifying the time range over
;                            which to get data structures [Unix time]
;
;   CHANGED:  1)  Altered calling method for 3DP structures
;                                                                   [08/18/2008   v1.1.20]
;             2)  Updated man page
;                                                                   [03/18/2009   v1.1.21]
;             3)  Changed program my_dummy_str.pro to dummy_3dp_str.pro
;                   and my_str_names.pro to dat_3dp_str_names.pro
;                   and renamed
;                                                                   [08/10/2009   v2.0.0]
;             3)  Changed some minor syntax ordering and added error handling for events
;                   with no structures available
;                                                                   [08/20/2009   v2.0.1]
;             4)  Changed to accomodate new structure formats that involve the tag
;                   name CHARGE
;                                                                   [08/28/2009   v2.1.0]
;             5)  Fixed an indexing issue that only arose under very rare conditions
;                                                                   [02/18/2011   v2.1.1]
;             6)  Added some error handling and cleaned up a few algorithms
;                                                                   [08/05/2013   v2.1.2]
;             7)  Fixed an indexing issue that only arose under very rare conditions
;                                                                   [08/09/2018   v2.1.3]
;             8)  Fixed another indexing issue that only arose under very rare conditions
;                                                                   [06/12/2020   v2.1.4]
;             9)  Fixed an issue with conflicting map codes that is very rare
;                                                                   [06/13/2020   v2.1.5]
;            10)  Fixed an indexing issue when the input time range exceeds the available
;                   VDF time ranges
;                                                                   [01/19/2023   v2.1.6]
;
;   NOTES:      
;               1)  See also:  get_??.pro (?? = eh,elb,pl,plb,ph,phb...)
;
;  REFERENCES:  
;               1)  Carlson et al., "An instrument for rapidly measuring plasma
;                      distribution functions with high resolution,"
;                      Adv. Space Res. Vol. 2, pp. 67-70, 1983.
;               2)  Curtis et al., "On-board data analysis techniques for space plasma
;                      particle instruments," Rev. Sci. Inst. Vol. 60,
;                      pp. 372, 1989.
;               3)  Lin et al., "A Three-Dimensional Plasma and Energetic particle
;                      investigation for the Wind spacecraft," Space Sci. Rev.
;                      Vol. 71, pp. 125, 1995.
;               4)  Paschmann, G. and P.W. Daly "Analysis Methods for Multi-Spacecraft
;                      Data," ISSI Scientific Report, Noordwijk, 
;                      The Netherlands., Int. Space Sci. Inst., 1998.
;               5)  Wilson III, L.B., et al., "Low-frequency whistler waves and shocklets
;                      observed at quasi-perpendicular interplanetary shocks,"
;                      J. Geophys. Res. 114, pp. A10106, 2009.
;               6)  Wilson III, L.B., et al., "Large-amplitude electrostatic waves
;                      observed at a supercritical interplanetary shock,"
;                      J. Geophys. Res. 115, pp. A12104, 2010.
;               7)  Wilson III, L.B., et al., "Observations of electromagnetic whistler
;                      precursors at supercritical interplanetary shocks,"
;                      Geophys. Res. Lett. 39, pp. L08109, 2012.
;               8)  Wilson III, L.B., et al., "Electromagnetic waves and electron
;                      anisotropies downstream of supercritical interplanetary shocks,"
;                      J. Geophys. Res. 118(1), pp. 5--16, 2013a.
;               9)  Wilson III, L.B., et al., "Shocklets, SLAMS, and field-aligned ion
;                      beams in the terrestrial foreshock," J. Geophys. Res. 118(3),
;                      pp. 957--966, 2013b.
;              10)  Wilson III, L.B., et al., "Quantified Energy Dissipation Rates in the
;                      Terrestrial Bow Shock: 1. Analysis Techniques and Methodology,"
;                      J. Geophys. Res. 119(8), pp. 6455--6474, 2014a.
;              11)  Wilson III, L.B., et al., "Quantified Energy Dissipation Rates in the
;                      Terrestrial Bow Shock: 2. Waves and Dissipation,"
;                      J. Geophys. Res. 119(8), pp. 6475--6495, 2014b.
;              12)  Wilson III, L.B., et al., "Relativistic electrons produced by
;                      foreshock disturbances observed upstream of the Earth’s bow
;                      shock," Phys. Rev. Lett. 117(21), pp. 215101, 2016.
;
;   CREATED:  04/10/2008
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  01/19/2023   v2.1.6
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION get_3dp_structs,myn1,TRANGE=trange

;;****************************************************************************************
ex_start       = SYSTIME(1)
;;****************************************************************************************
;;----------------------------------------------------------------------------------------
;;  Check input
;;----------------------------------------------------------------------------------------
IF (N_PARAMS() NE 1) THEN RETURN,0
test           = (N_ELEMENTS(myn1) EQ 0) OR (SIZE(myn1,/TYPE) NE 7)
IF (test[0]) THEN BEGIN
  badmssg = 'MYN1 must be a scalar string!'
  MESSAGE,badmssg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0
ENDIF
;;----------------------------------------------------------------------------------------
;;  Determine Str. Name
;;----------------------------------------------------------------------------------------
myn1           = STRLOWCASE(myn1)
gname          = dat_3dp_str_names(myn1)
test           = (SIZE(gname,/TYPE) NE 8)
IF (test[0]) THEN BEGIN
  badmssg = 'MYN1 must be an acceptable string representation of a 3DP instrument!'
  MESSAGE,badmssg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0
ENDIF
;;  Define the short string name of the desired data
myn            = gname.SN
;;----------------------------------------------------------------------------------------
;;  Determine Charge (if necessary)
;;----------------------------------------------------------------------------------------
CASE STRMID(myn[0],0,1) OF
  'e' : BEGIN
    charge = -1d0
  END
  'p' : BEGIN
    charge = 1d0
  END
  's' : BEGIN
    CASE STRMID(myn[0],0,2) OF
      'sf' : BEGIN
        charge = -1d0
      END
      'so' : BEGIN
        charge = 1d0
      END
      ELSE : BEGIN
        MESSAGE,'Incorrect input format:  MYN1',/INFORMATIONAL,/CONTINUE
        RETURN,0
      END
    ENDCASE
  END
  ELSE : BEGIN
    MESSAGE,'Incorrect input format:  MYN1',/INFORMATIONAL,/CONTINUE
    RETURN,0
  END
ENDCASE
;;----------------------------------------------------------------------------------------
;;  Determine if any data is available
;;----------------------------------------------------------------------------------------
fn1            = ''
fn1            = 'get_'+myn[0]
myto           = CALL_FUNCTION(fn1,/TIMES)  ;;  Str. velocity distribution Unix times
gmto           = WHERE(FINITE(myto) AND myto GT 0,gmt)
;;----------------------------------------------------------------------------------------
;;  First removal of non-finite data
;;----------------------------------------------------------------------------------------
IF (gmt[0] GT 1L) THEN BEGIN
  myto = TEMPORARY(myto[gmto])
ENDIF ELSE BEGIN
  MESSAGE,'No data is loaded...',/INFORMATIONAL,/CONTINUE
  RETURN,0
ENDELSE
;;----------------------------------------------------------------------------------------
;;  Keyword in call_externals which determines how data 
;;   structures are called { >/= 0 use index, = -1 use times}
;;----------------------------------------------------------------------------------------
myopt          = LONARR(gmt[0])
IF KEYWORD_SET(trange) THEN BEGIN
  IF (N_ELEMENTS(trange) NE 2) THEN trange = [MIN(myto,/NAN),MAX(myto,/NAN)]
  bad_tr    = WHERE(myto GE trange[0] AND myto LE trange[1],bdtr)
  IF (bdtr[0] EQ 0) THEN BEGIN
    badtrmssg = 'There are no valid '+myn+' structures in that time range!'
    MESSAGE,badtrmssg[0],/INFORMATIONAL,/CONTINUE
    RETURN,0
  ENDIF
  ;;--------------------------------------------------------------------------------------
  ;;  Get range of index values for calling the get_??.pro routines
  ;;--------------------------------------------------------------------------------------
  irange = LONG(interp(FINDGEN(gmt[0]),myto,gettime(trange)))
  IF (MAX(trange,/NAN) GT MAX(myto,/NAN) AND irange[1] LT 0) THEN irange[1] = (gmt[0] - 1L)
  irange = (irange < (gmt[0] - 1L)) > 0
  irange = [MIN(irange,/NAN),MAX(irange,/NAN)]
  IF (irange[0] GE irange[1] OR TOTAL(irange LT 0) GT 0) THEN BEGIN
    ;;  Bad index range --> quit
    badtrmssg = 'There are valid '+myn+' structures for the date, but not in that time range...'
    MESSAGE,badtrmssg[0],/INFORMATIONAL,/CONTINUE
    RETURN,0
  ENDIF
  istart = irange[0]
  ;;--------------------------------------------------------------------------------------
  ;;  Make sure structure times don't over reach time range
  ;;--------------------------------------------------------------------------------------
  trch   = MIN(trange,/NAN) - MIN(myto[istart:irange[1]],/NAN)
  IF (trch[0] GT 0d0) THEN BEGIN
    TRUE      = 1
    FALSE     = 0
    searching = TRUE
    cc        = istart
    WHILE(searching[0]) DO BEGIN
      trch   = MIN(trange,/NAN) - myto[cc]
      IF (trch[0] GT 0d0 AND ABS(trch[0]) GT 2.5d0) THEN BEGIN
        searching = TRUE
        cc       += 1L
      ENDIF ELSE BEGIN
        searching = FALSE
      ENDELSE
    ENDWHILE
    istart = cc[0]
    myto   = myto[istart:irange[1]]
  ENDIF ELSE BEGIN
    myto = myto[istart:irange[1]]
  ENDELSE
  gmt    = N_ELEMENTS(myto)
  idx    = LINDGEN(gmt[0]) + istart[0]
  myopt  = LONG([2,47,0])
ENDIF ELSE BEGIN
  istart = 0L
  irange = [istart[0],N_ELEMENTS(myto) - 1L]
  idx    = LINDGEN(gmt[0]) + istart[0]
  myopt  = LONG([2,-1,0])
ENDELSE
;;----------------------------------------------------------------------------------------
;;  Test structure for CHARGE tag name
;;----------------------------------------------------------------------------------------
test_tag       = CALL_FUNCTION('get_'+myn[0],INDEX=idx[0])
tags_tt        = TAG_NAMES(test_tag)
gtags          = WHERE(STRLOWCASE(tags_tt) EQ 'charge',gtg)
IF (gtg[0] GT 0) THEN log_ch = 1 ELSE log_ch = 0
;;----------------------------------------------------------------------------------------
;;  Get dummy structure for replicating
;;----------------------------------------------------------------------------------------
dumb           = dummy_3dp_str(myn,INDEX=idx)
IF (SIZE(dumb,/TYPE) NE 8) THEN RETURN,0b
mypts          = N_ELEMENTS(myto)
mvi            = INTARR(mypts[0])
;;----------------------------------------------------------------------------------------
;;  Get Str. Data
;;----------------------------------------------------------------------------------------
test_tags     = TAG_NAMES(dumb)
test_t        = WHERE(test_tags EQ 'PH1_B',tt_t)
IF (tt_t[0] GT 0L) THEN BEGIN
  ;;  PESA High distributions often change mode which changes NBINS
  test_n         = WHERE(test_tags EQ 'PH3_B',tt_n)
  my_inds        = dumb.INDX1
  idx1           = my_inds[*,0]
  idx2           = my_inds[*,1]
  mypt1          = N_ELEMENTS(idx1)                                   ;;  # of str.'s w/ 1st mapcode
  mypt2          = N_ELEMENTS(idx2)                                   ;;  # of str.'s w/ 2nd mapcode
  mvi1           = LONARR(mypt1[0])                                   ;;  Long array of "valid identifier" logic
  mvi2           = LONARR(mypt2[0])                                   ;;  Long array of "valid identifier" logic
  IF (tt_n[0] GT 0L) THEN BEGIN
    idx3   = my_inds[*,2]
    mypt3  = N_ELEMENTS(idx3)                                         ;;  # of str.'s w/ 3rd mapcode
    mvi3   = LONARR(mypt3[0])                                         ;;  Long array of "valid identifier" logic
  ENDIF ELSE BEGIN
    mypt3  = 0L
    idx3   = -1L
    mvi3   = 0L
  ENDELSE
  etemp1         = dumb.(0)
  etemp2         = dumb.(1)
  ;;--------------------------------------------------------------------------------------
  ;;  Set up dummy structures to prevent Conflicting data structures
  ;;--------------------------------------------------------------------------------------
  str_element,etemp1,'COUNTS',etemp1.DATA,/ADD_REPLACE
  str_element,etemp2,'COUNTS',etemp2.DATA,/ADD_REPLACE
  str_element,etemp1,  'MAGF',REPLICATE(!VALUES.F_NAN,3),/ADD_REPLACE
  str_element,etemp2,  'MAGF',REPLICATE(!VALUES.F_NAN,3),/ADD_REPLACE
  str_element,etemp1,   'VSW',REPLICATE(!VALUES.F_NAN,3),/ADD_REPLACE
  str_element,etemp2,   'VSW',REPLICATE(!VALUES.F_NAN,3),/ADD_REPLACE
  str_element,etemp1,'SC_POT',!VALUES.F_NAN,/ADD_REPLACE
  str_element,etemp2,'SC_POT',!VALUES.F_NAN,/ADD_REPLACE
  IF (log_ch[0]) THEN str_element,etemp1,'CHARGE',charge,/ADD_REPLACE
  IF (log_ch[0]) THEN str_element,etemp2,'CHARGE',charge,/ADD_REPLACE
  my1            = REPLICATE(etemp1[0],mypt1[0])                       ;;  dummy structure for 1st mapcode
  my2            = REPLICATE(etemp2[0],mypt2[0])                       ;;  dummy structure for 2nd mapcode
  IF (idx3[0] EQ -1L) THEN BEGIN
    nst    = 1L
    etemp3 = etemp1
    my3    = REPLICATE(etemp1[0],1L)
  ENDIF ELSE BEGIN
    nst    = 2L
    etemp3 = dumb.(2)
    str_element,etemp3,'COUNTS',etemp3.DATA,/ADD_REPLACE
    str_element,etemp3,  'MAGF',REPLICATE(!VALUES.F_NAN,3),/ADD_REPLACE
    str_element,etemp3,   'VSW',REPLICATE(!VALUES.F_NAN,3),/ADD_REPLACE
    str_element,etemp3,'SC_POT',!VALUES.F_NAN,/ADD_REPLACE
    IF (log_ch[0]) THEN str_element,etemp3,'CHARGE',charge,/ADD_REPLACE
    my3    = REPLICATE(etemp3[0],mypt3)
  ENDELSE
  ;;--------------------------------------------------------------------------------------
  ;;  Get data structures
  ;;--------------------------------------------------------------------------------------
  mypts          = [mypt1[0],mypt2[0],mypt3[0]]                      ;;  # of points for each type of str.
  myind          = {IN1:idx1,IN2:idx2,IN3:idx3}                      ;;  Indices for each case
  myval          = {X1:mvi1,X2:mvi2,X3:mvi3}                         ;;  array specifying valids
  all_3          = CREATE_STRUCT('MY1',my1,'MY2',my2,'MY3',my3)
  all_v          = LONARR(LONG(TOTAL(mypts)))                        ;;  array specifying all valids
  cc             = 0L
  trj            = 1                                                 ;;  Logical for While loop
  j              = 0L
  WHILE(trj[0]) DO BEGIN
    myptt = mypts[j]
    indxx = myind.(j)
    etemp = (all_3.(j))[0]
    mydd  = all_3.(j)
    trk   = 1                                                       ;;  Logical for While loop
    k     = 0L
    WHILE(trk[0]) DO BEGIN
      tth = CALL_FUNCTION('get_'+myn,INDEX=indxx[k])
      IF (tth.VALID NE 1) THEN BEGIN
        tth = etemp
      ENDIF
      str_element,tth,'COUNTS',tth.DATA,/ADD_REPLACE
      str_element,tth,'MAGF',REPLICATE(!VALUES.F_NAN,3),/ADD_REPLACE
      str_element,tth,'VSW',REPLICATE(!VALUES.F_NAN,3),/ADD_REPLACE
      str_element,tth,'SC_POT',!VALUES.F_NAN,/ADD_REPLACE
      bb        = cc[0] + k[0]
      IF (tth[0].MAPCODE[0] EQ mydd[0].MAPCODE[0]) THEN BEGIN
        all_v[bb] = tth.VALID
        mydd[k]   = tth
      ENDIF
      trk       = (k[0] LT myptt[0] - 1L)
      k        += trk[0]
    ENDWHILE
    ;;  LBW III 2011-02-18
    IF ((cc[0] + k[0] - 1L) GE cc[0]) THEN myval.(j) = all_v[cc[0]:(cc[0] + k[0] - 1L)] ELSE myval.(j) = -1
    all_3.(j) = mydd[*]
    trj       = (j[0] LT nst[0])
    cc       += myptt[0]*trj[0]
    j        += trj[0]
  ENDWHILE
  gval1          = WHERE(myval.(0) EQ 1,gv1)
  gval2          = WHERE(myval.(1) EQ 1,gv2)
  gval3          = WHERE(myval.(2) EQ 1,gv3)
  gvalss         = {VV1:gval1,VV2:gval2,VV3:gval3}
  chval          = [gv1[0],gv2[0],gv3[0]]
  gcheck         = WHERE(chval GT 0L,gch)
  CASE gch[0] OF
    2 : BEGIN         ;;  3 structure types (e.g. three different mapcodes)
      myg1                                  = REPLICATE((all_3.(gcheck[0]))[0],chval[gcheck[0]])
      myg2                                  = REPLICATE((all_3.(gcheck[1]))[0],chval[gcheck[1]])
      el1                                   = chval[gcheck[0]]
      el2                                   = chval[gcheck[1]]
      gv                                    = el1[0] + el2[0]
      myti                                  = DBLARR(gv[0],2)
      myg1                                  = (all_3.(gcheck[0]))[gvalss.(gcheck[0])]
      myg2                                  = (all_3.(gcheck[1]))[gvalss.(gcheck[1])]
      myti[0L:(el1[0] - 1L),0]              = myg1.TIME
      myti[0L:(el1[0] - 1L),1]              = myg1.END_TIME
      myti[el1[0]:(el1[0] + el2[0] - 1L),0] = myg2.TIME
      myti[el1[0]:(el1[0] + el2[0] - 1L),1] = myg2.END_TIME
      dat = CREATE_STRUCT('TIMES',myti,'DATA1',myg1,'DATA2',myg2)
      RETURN,dat
    END
    3 : BEGIN         ;;  2 structure types (e.g. two different mapcodes)
      myg1                                                      = REPLICATE((all_3.(gcheck[0]))[0],chval[gcheck[0]])
      myg2                                                      = REPLICATE((all_3.(gcheck[1]))[0],chval[gcheck[1]])
      myg3                                                      = REPLICATE((all_3.(gcheck[2]))[0],chval[gcheck[2]])
      gv                                                        = gv1[0] + gv2[0] + gv3[0]
      myti                                                      = DBLARR(gv[0],2)
      myg1                                                      = (all_3.(gcheck[0]))[gvalss.(gcheck[0])]
      myg2                                                      = (all_3.(gcheck[1]))[gvalss.(gcheck[1])]
      myg3                                                      = (all_3.(gcheck[2]))[gvalss.(gcheck[2])]
      myti[0:(gv1[0] - 1L),0]                                   = myg1.TIME
      myti[0:(gv1[0] - 1L),1]                                   = myg1.END_TIME
      myti[gv1:(gv2[0] + gv1[0] - 1L),0]                        = myg2.TIME
      myti[gv1:(gv2[0] + gv1[0] - 1L),1]                        = myg2.END_TIME
      myti[(gv2[0] + gv1[0]):(gv1[0] + gv2[0] + gv3[0] - 1L),0] = myg3.TIME
      myti[(gv2[0] + gv1[0]):(gv1[0] + gv2[0] + gv3[0] - 1L),1] = myg3.END_TIME
      dat = CREATE_STRUCT('TIMES',myti,'DATA1',myg1,'DATA2',myg2,'DATA3',myg2)
      RETURN,dat
    END
    1 : BEGIN         ;;  Only 1 structure type
      myg1                     = REPLICATE((all_3.(gcheck[0]))[0],chval[gcheck[0]])
      gv                       = chval[gcheck[0]]
      myti                     = DBLARR(gv,2)
      myg1                     = (all_3.(gcheck[0]))[gvalss.(gcheck[0])]
      myti[0L:(gv[0] - 1L),0L] = myg1.TIME
      myti[0L:(gv[0] - 1L),1L] = myg1.END_TIME
      dat = CREATE_STRUCT('TIMES',myti,'DATA',myg1)
      RETURN,dat
    END
    ELSE : BEGIN
      MESSAGE,'There are no valid '+myn+' structures!',/INFORMATIONAL,/CONTINUE
      RETURN,0
    END
  ENDCASE
ENDIF ELSE BEGIN
  ;;--------------------------------------------------------------------------------------
  ;;  Only 1 mapcode was found through time range
  ;;--------------------------------------------------------------------------------------
  etemp          = dumb
  str_element,etemp,'COUNTS',etemp.DATA,/ADD_REPLACE
  str_element,etemp,  'MAGF',REPLICATE(!VALUES.F_NAN,3),/ADD_REPLACE
  str_element,etemp,   'VSW',REPLICATE(!VALUES.F_NAN,3),/ADD_REPLACE
  str_element,etemp,'SC_POT',!VALUES.F_NAN,/ADD_REPLACE
  IF (log_ch[0]) THEN str_element,etemp,'CHARGE',charge,/ADD_REPLACE
  my1            = REPLICATE(etemp[0],mypts[0])
  tri            = 1   ;;  Logical for While loop
  i              = 0L
  WHILE(tri[0]) DO BEGIN
    tth     = CALL_FUNCTION('get_'+myn,INDEX=idx[i])
    IF (tth[0].VALID NE 1) THEN BEGIN
      tth = etemp
    ENDIF
    str_element,tth,'COUNTS',tth.DATA,/ADD_REPLACE
    str_element,tth,  'MAGF',REPLICATE(!VALUES.F_NAN,3),/ADD_REPLACE
    str_element,tth,   'VSW',REPLICATE(!VALUES.F_NAN,3),/ADD_REPLACE
    str_element,tth,'SC_POT',!VALUES.F_NAN,/ADD_REPLACE
    mvi[i]  = tth.valid
    my1[i]  = tth
    tri     = (i[0] LT mypts[0] - 1L)
    i      += tri[0]
  ENDWHILE
ENDELSE
;;----------------------------------------------------------------------------------------
;;  Keep ONLY valid data structures
;;----------------------------------------------------------------------------------------
gval           = WHERE(mvi EQ 1,gv)
IF (gv[0] GT 0) THEN BEGIN
  my2            = REPLICATE(my1[gval[0]],gv[0])
  myti           = DBLARR(gv[0],2)
  trk            = 1   ;;  Logical for While loop
  k              = 0L
  WHILE(trk[0]) DO BEGIN
    my2[k]    = my1[gval[k[0]]]
    myti[k,*] = [[my1[gval[k[0]]].TIME],[my1[gval[k[0]]].END_TIME]]
    trk       = (k[0] LT gv[0] - 1L)
    k        += trk[0]
  ENDWHILE
ENDIF ELSE BEGIN
  MESSAGE,'There are no valid '+myn+' structures!',/INFORMATIONAL,/CONTINUE
  RETURN,0
ENDELSE
;;----------------------------------------------------------------------------------------
;;  Define output
;;----------------------------------------------------------------------------------------
dat           = CREATE_STRUCT('TIMES',myti,'DATA',my2)
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------
;;****************************************************************************************
ex_time        = SYSTIME(1) - ex_start[0]
MESSAGE,STRING(ex_time[0])+' seconds execution time.',/cont,/info
;;****************************************************************************************

RETURN, dat
END

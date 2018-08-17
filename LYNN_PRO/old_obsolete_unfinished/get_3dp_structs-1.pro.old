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
;               MYN1    :  Scalar [string] defining the type of structure you wish to
;                            get the data for [i.e., 'el','eh','elb', etc.]
;
;  EXAMPLES:    
;               tr  = time_double(['1996-04-06/10:00:00','1996-04-07/10:00:00'])
;               dat = get_3dp_structs('el',TRANGE=tr)
;               els = dat.DATA    ;;  All Eesa Low structures in given time range
;
;  KEYWORDS:    
;               TRANGE  :  [2]-Element [double] array specifying the time range over
;                            which to get data structures [Unix time]
;
;   CHANGED:  1)  Altered calling method for 3DP structures
;                                                                  [08/18/2008   v1.1.20]
;             2)  Updated man page
;                                                                  [03/18/2009   v1.1.21]
;             3)  Changed program my_dummy_str.pro to dummy_3dp_str.pro
;                   and my_str_names.pro to dat_3dp_str_names.pro
;                   and renamed
;                                                                  [08/10/2009   v2.0.0]
;             3)  Changed some minor syntax ordering and added error handling for events
;                   with no structures available
;                                                                  [08/20/2009   v2.0.1]
;             4)  Changed to accomodate new structure formats that involve the tag
;                   name CHARGE
;                                                                  [08/28/2009   v2.1.0]
;             5)  Fixed an indexing issue that only arose under very rare conditions
;                                                                  [02/18/2011   v2.1.1]
;             6)  Added some error handling and cleaned up a few algorithms
;                                                                  [08/05/2013   v2.1.2]
;
;   NOTES:      
;               1)  See also:  get_??.pro (?? = eh,elb,pl,plb,ph,phb...)
;
;   CREATED:  04/10/2008
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  08/05/2013   v2.1.2
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
IF (test) THEN BEGIN
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
IF (test) THEN BEGIN
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
fn1   = ''
fn1   = 'get_'+myn1
myto  = CALL_FUNCTION(fn1,/TIMES)  ; Str. moment times
;gmto  = WHERE(FINITE(myto) AND N_ELEMENTS(myto) GT 1L,gmt)
gmto  = WHERE(FINITE(myto) AND myto GT 0,gmt)
;;----------------------------------------------------------------------------------------
;;  First removal of non-finite data
;;----------------------------------------------------------------------------------------
IF (gmt GT 1L) THEN BEGIN
  myto = myto[gmto]
ENDIF ELSE BEGIN
  MESSAGE,'No data is loaded...',/INFORMATIONAL,/CONTINUE
  RETURN,0
ENDELSE
;;----------------------------------------------------------------------------------------
;;  Keyword in call_externals which determines how data 
;;   structures are called { >/= 0 use index, = -1 use times}
;;----------------------------------------------------------------------------------------
myopt = LONARR(gmt)
IF KEYWORD_SET(trange) THEN BEGIN
  IF (N_ELEMENTS(trange) NE 2) THEN trange = [MIN(myto,/NAN),MAX(myto,/NAN)]
;  IF (N_ELEMENTS(trange) GT 2) THEN trange = [MIN(myto,/NAN),MAX(myto,/NAN)]
  bad_tr    = WHERE(myto GE trange[0] AND myto LE trange[1],bdtr)
  IF (bdtr EQ 0) THEN BEGIN
    badtrmssg = 'There are no valid '+myn+' structures in that time range!'
    MESSAGE,badtrmssg,/INFORMATIONAL,/CONTINUE
    RETURN,0
  ENDIF
  ;;--------------------------------------------------------------------------------------
  ;;  Get range of index values for calling the get_??.pro routines
  ;;--------------------------------------------------------------------------------------
  irange = LONG(interp(FINDGEN(gmt),myto,gettime(trange)))
  irange = (irange < (gmt - 1L)) > 0
  irange = [MIN(irange,/NAN),MAX(irange,/NAN)]
  istart = irange[0]
  ;;--------------------------------------------------------------------------------------
  ;;  Make sure structure times don't over reach time range
  ;;--------------------------------------------------------------------------------------
  trch   = MIN(trange,/NAN) - MIN(myto[istart:irange[1]],/NAN)
  IF (trch GT 0d0) THEN BEGIN
    TRUE      = 1
    FALSE     = 0
    searching = TRUE
    cc        = istart
    WHILE(searching) DO BEGIN
      trch   = MIN(trange,/NAN) - myto[cc]
      IF (trch GT 0d0 AND ABS(trch) GT 2.5d0) THEN BEGIN
;      IF (trch GT 0d0 AND ABS(trch) GT 2.5d0 AND cc LT gmt - 1L) THEN BEGIN
        searching = TRUE
        cc += 1L
      ENDIF ELSE BEGIN
        searching = FALSE
      ENDELSE
    ENDWHILE
    istart = cc
    myto   = myto[istart:irange[1]]
  ENDIF ELSE BEGIN
    myto = myto[istart:irange[1]]
  ENDELSE
  gmt    = N_ELEMENTS(myto)
  idx    = LINDGEN(gmt) + istart
  myopt  = LONG([2,47,0])
ENDIF ELSE BEGIN
  istart = 0L
  irange = [istart,N_ELEMENTS(myto) - 1L]
  idx    = LINDGEN(gmt) + istart
  myopt  = LONG([2,-1,0])
ENDELSE
;;----------------------------------------------------------------------------------------
;;  Test structure for CHARGE tag name
;;----------------------------------------------------------------------------------------
test_tag = CALL_FUNCTION('get_'+myn,INDEX=idx[0])
tags_tt  = TAG_NAMES(test_tag)
gtags    = WHERE(STRLOWCASE(tags_tt) EQ 'charge',gtg)
IF (gtg GT 0) THEN log_ch = 1 ELSE log_ch = 0
;;----------------------------------------------------------------------------------------
;;  Get dummy structure for replicating
;;----------------------------------------------------------------------------------------
dumb  = dummy_3dp_str(myn,INDEX=idx)
mypts = N_ELEMENTS(myto)
mvi   = INTARR(mypts)
;;----------------------------------------------------------------------------------------
;;  Get Str. Data
;;----------------------------------------------------------------------------------------
test_tags = TAG_NAMES(dumb)
test_t    = WHERE(test_tags EQ 'PH1_B',tt_t)
IF (tt_t GT 0L) THEN BEGIN
  test_n  = WHERE(test_tags EQ 'PH3_B',tt_n)
  my_inds = dumb.INDX1
  mypt1   = my_inds[1,0] - my_inds[0,0] + 1L  ;;  # of str.'s w/ 1st mapcode
  mypt2   = my_inds[1,1] - my_inds[0,1] + 1L  ;;  # of str.'s w/ 2nd mapcode
  idx1    = LINDGEN(mypt1) + my_inds[0,0]
  mvi1    = LONARR(mypt1)  ;;  Long array of "valid identifier" logic
  idx2    = LINDGEN(mypt2)+ my_inds[0,1]
  mvi2    = LONARR(mypt2)  ;;  Long array of "valid identifier" logic
  IF (tt_n GT 0L) THEN BEGIN
    mypt3  = REFORM(my_inds[1,2]) - REFORM(my_inds[0,2]) + 1L  ;;  # of str.'s w/ 3rd mapcode
    idx3   = LINDGEN(mypt3)+REFORM(my_inds[0,2])
    mvi3   = LONARR(mypt3)  ;;  Long array of "valid identifier" logic
  ENDIF ELSE BEGIN
    mypt3  = 0L
    idx3   = -1L
    mvi3   = 0L
  ENDELSE
  etemp1 = dumb.(0)
  etemp2 = dumb.(1)
  ;;--------------------------------------------------------------------------------------
  ;;  Set up dummy structures to prevent Conflicting data structures
  ;;--------------------------------------------------------------------------------------
  str_element,etemp1,'COUNTS',etemp1.data,/ADD_REPLACE
  str_element,etemp2 ,'COUNTS',etemp2 .data,/ADD_REPLACE
  str_element,etemp1,'MAGF',REPLICATE(!VALUES.F_NAN,3),/ADD_REPLACE
  str_element,etemp2 ,'MAGF',REPLICATE(!VALUES.F_NAN,3),/ADD_REPLACE
  str_element,etemp1,'VSW',REPLICATE(!VALUES.F_NAN,3),/ADD_REPLACE
  str_element,etemp2 ,'VSW',REPLICATE(!VALUES.F_NAN,3),/ADD_REPLACE
  str_element,etemp1,'SC_POT',!VALUES.F_NAN,/ADD_REPLACE
  str_element,etemp2 ,'SC_POT',!VALUES.F_NAN,/ADD_REPLACE
  IF (log_ch) THEN str_element,etemp1,'CHARGE',charge,/ADD_REPLACE
  IF (log_ch) THEN str_element,etemp2,'CHARGE',charge,/ADD_REPLACE
  my1    = REPLICATE(etemp1,mypt1)  ;;  dummy structure for 1st mapcode
  my2    = REPLICATE(etemp2,mypt2)  ;;  dummy structure for 2nd mapcode
  IF (idx3 EQ -1L) THEN BEGIN
    nst    = 1L
    etemp3 = etemp1
    my3    = REPLICATE(etemp1,1L)
  ENDIF ELSE BEGIN
    nst    = 2L
    etemp3 = dumb.(2)
    str_element,etemp3,'COUNTS',etemp3.data,/ADD_REPLACE
    str_element,etemp3,'MAGF',REPLICATE(!VALUES.F_NAN,3),/ADD_REPLACE
    str_element,etemp3,'VSW',REPLICATE(!VALUES.F_NAN,3),/ADD_REPLACE
    str_element,etemp3,'SC_POT',!VALUES.F_NAN,/ADD_REPLACE
    IF (log_ch) THEN str_element,etemp3,'CHARGE',charge,/ADD_REPLACE
    my3    = REPLICATE(etemp3,mypt3)
  ENDELSE
  ;;--------------------------------------------------------------------------------------
  ;;  Get data structures
  ;;--------------------------------------------------------------------------------------
  mypts = [mypt1,mypt2,mypt3]          ;;  # of points for each type of str.
  myind = {IN1:idx1,IN2:idx2,IN3:idx3} ;;  Indices for each case
  myval = {X1:mvi1,X2:mvi2,X3:mvi3}    ;;  array specifying valids
  all_3 = CREATE_STRUCT('MY1',my1,'MY2',my2,'MY3',my3)
  all_v = LONARR(LONG(TOTAL(mypts)))   ;;  array specifying all valids
  cc    = 0L
  trj   = 1   ;;  Logical for While loop
  j     = 0L
  WHILE(trj) DO BEGIN
;  FOR j=0L, nst DO BEGIN
    myptt = mypts[j]
    indxx = myind.(j)
    etemp = (all_3.(j))[0]
    mydd  = all_3.(j)
    trk   = 1   ;;  Logical for While loop
    k     = 0L
    WHILE(trk) DO BEGIN
;    FOR k=0L, myptt - 1L DO BEGIN
      tth = CALL_FUNCTION('get_'+myn,INDEX=indxx[k])
      IF (tth.VALID NE 1) THEN BEGIN
;      IF NOT tth.VALID THEN BEGIN
        tth = etemp
      ENDIF
      str_element,tth,'COUNTS',tth.data,/ADD_REPLACE
      str_element,tth,'MAGF',REPLICATE(!VALUES.F_NAN,3),/ADD_REPLACE
      str_element,tth,'VSW',REPLICATE(!VALUES.F_NAN,3),/ADD_REPLACE
      str_element,tth,'SC_POT',!VALUES.F_NAN,/ADD_REPLACE
      bb        = cc + k
      all_v[bb] = tth.VALID
      mydd[k]   = tth
;    ENDFOR
      trk       = (k LT myptt - 1L)
      k        += trk
;      IF (k LT myptt - 1L) THEN trk = 1 ELSE trk = 0
;      IF (trk) THEN k += 1
    ENDWHILE
    ;;  LBW III 2011-02-18
    IF (cc+k-1L GE cc) THEN myval.(j) = all_v[cc:(cc+k-1L)] ELSE myval.(j) = -1
;    myval.(j) = all_v[cc:(cc+k-1L)]
    all_3.(j) = mydd[*]
;    cc       += myptt
;  ENDFOR
    trj       = (j LT nst)
    cc       += myptt[0]*trj[0]
    j        += trj[0]
;    IF (j LT nst) THEN trj = 1 ELSE trj = 0
;    IF (trj) THEN cc += myptt
;    IF (trj) THEN j  += 1
  ENDWHILE
  gval1  = WHERE(myval.(0) EQ 1,gv1)
  gval2  = WHERE(myval.(1) EQ 1,gv2)
  gval3  = WHERE(myval.(2) EQ 1,gv3)
  gvalss = {VV1:gval1,VV2:gval2,VV3:gval3}
  chval  = [gv1,gv2,gv3]
  gcheck = WHERE(chval GT 0L,gch)
  CASE gch OF
    2 : BEGIN         ;;  3 structure types (e.g. three different mapcodes)
      myg1  = REPLICATE((all_3.(gcheck[0]))[0],chval[gcheck[0]])
      myg2  = REPLICATE((all_3.(gcheck[1]))[0],chval[gcheck[1]])
      el1   = chval[gcheck[0]]
      el2   = chval[gcheck[1]]
      gv    = el1 + el2
      myti  = DBLARR(gv,2)
      myg1  = (all_3.(gcheck[0]))[gvalss.(gcheck[0])]
      myg2  = (all_3.(gcheck[1]))[gvalss.(gcheck[1])]
      myti[0:(el1-1L),0] = myg1.TIME
      myti[0:(el1-1L),1] = myg1.END_TIME
      myti[el1:(el1+el2-1L),0] = myg2.TIME
      myti[el1:(el1+el2-1L),1] = myg2.END_TIME
      dat = CREATE_STRUCT('TIMES',myti,'DATA1',myg1,'DATA2',myg2)
      RETURN,dat
    END
    3 : BEGIN         ;;  2 structure types (e.g. two different mapcodes)
      myg1 = REPLICATE((all_3.(gcheck[0]))[0],chval[gcheck[0]])
      myg2 = REPLICATE((all_3.(gcheck[1]))[0],chval[gcheck[1]])
      myg3 = REPLICATE((all_3.(gcheck[2]))[0],chval[gcheck[2]])
      gv   = gv1 + gv2 + gv3
      myti = DBLARR(gv,2)
      myg1 = (all_3.(gcheck[0]))[gvalss.(gcheck[0])]
      myg2 = (all_3.(gcheck[1]))[gvalss.(gcheck[1])]
      myg3 = (all_3.(gcheck[2]))[gvalss.(gcheck[2])]
      myti[0:(gv1-1L),0] = myg1.TIME
      myti[0:(gv1-1L),1] = myg1.END_TIME
      myti[gv1:(gv2+gv1-1L),0] = myg2.TIME
      myti[gv1:(gv2+gv1-1L),1] = myg2.END_TIME
      myti[(gv2+gv1):(gv1+gv2+gv3-1L),0] = myg3.TIME
      myti[(gv2+gv1):(gv1+gv2+gv3-1L),1] = myg3.END_TIME
      dat = CREATE_STRUCT('TIMES',myti,'DATA1',myg1,'DATA2',myg2,'DATA3',myg2)
      RETURN,dat
    END
    1 : BEGIN         ;;  Only 1 structure type
      myg1  = REPLICATE((all_3.(gcheck[0]))[0],chval[gcheck[0]])
      gv    = chval[gcheck[0]]
      myti  = DBLARR(gv,2)
      myg1  = (all_3.(gcheck[0]))[gvalss.(gcheck[0])]
      myti[0:(gv-1L),0] = myg1.TIME
      myti[0:(gv-1L),1] = myg1.END_TIME
      dat = CREATE_STRUCT('TIMES',myti,'DATA',myg1)
      RETURN,dat
    END
    ELSE : BEGIN
      MESSAGE,'There are no valid '+myn+' structures!',/INFORMATIONAL,/CONTINUE
      RETURN,0
    END
  ENDCASE
ENDIF ELSE BEGIN
;;----------------------------------------------------------------------------------------
;;  Only 1 mapcode was found through time range
;;----------------------------------------------------------------------------------------
  etemp = dumb
  str_element,etemp,'COUNTS',etemp.data,/ADD_REPLACE
  str_element,etemp,'MAGF',REPLICATE(!VALUES.F_NAN,3),/ADD_REPLACE
  str_element,etemp,'VSW',REPLICATE(!VALUES.F_NAN,3),/ADD_REPLACE
  str_element,etemp,'SC_POT',!VALUES.F_NAN,/ADD_REPLACE
  IF (log_ch) THEN str_element,etemp,'CHARGE',charge,/ADD_REPLACE
  my1   = REPLICATE(etemp,mypts)
  tri   = 1   ;;  Logical for While loop
  i     = 0L
  WHILE(tri) DO BEGIN
;  FOR i=0L,mypts-1L DO BEGIN
    tth     = CALL_FUNCTION('get_'+myn,INDEX=idx[i])
    IF (tth.VALID NE 1) THEN BEGIN
;    IF NOT tth.valid THEN BEGIN
      tth = etemp
    ENDIF
    str_element,tth,'COUNTS',tth.data,/ADD_REPLACE
    str_element,tth,'MAGF',REPLICATE(!VALUES.F_NAN,3),/ADD_REPLACE
    str_element,tth,'VSW',REPLICATE(!VALUES.F_NAN,3),/ADD_REPLACE
    str_element,tth,'SC_POT',!VALUES.F_NAN,/ADD_REPLACE
    mvi[i]  = tth.valid
    my1[i]  = tth
    tri     = (i LT mypts - 1L)
    i      += tri
;  ENDFOR
;    IF (i LT mypts - 1L) THEN tri = 1 ELSE tri = 0
;    IF (tri) THEN i  += 1
  ENDWHILE
ENDELSE
;;----------------------------------------------------------------------------------------
;;  keep ONLY valid data structures
;;----------------------------------------------------------------------------------------
gval = WHERE(mvi EQ 1,gv)
IF (gv GT 0) THEN BEGIN
  my2  = REPLICATE(my1[gval[0]],gv)
  myti = DBLARR(gv,2)
  trk   = 1   ;;  Logical for While loop
  k     = 0L
  WHILE(trk) DO BEGIN
;  FOR k=0L,gv-1L DO BEGIN
    my2[k]    = my1[gval[k]]
    myti[k,*] = [[my1[gval[k]].TIME],[my1[gval[k]].END_TIME]]
    trk       = (k LT gv - 1L)
    k        += trk
;    IF (k LT gv - 1L) THEN trk = 1 ELSE trk = 0
;    IF (trk) THEN k += 1
  ENDWHILE
;  ENDFOR
ENDIF ELSE BEGIN
  MESSAGE,'There are no valid '+myn+' structures!',/INFORMATIONAL,/CONTINUE
  RETURN,0
ENDELSE
;;****************************************************************************************
ex_time = SYSTIME(1) - ex_start
MESSAGE,STRING(ex_time)+' seconds execution time.',/cont,/info
;;****************************************************************************************
dat = CREATE_STRUCT('TIMES',myti,'DATA',my2)
RETURN, dat
END

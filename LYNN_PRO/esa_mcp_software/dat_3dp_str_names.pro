;+
;*****************************************************************************************
;
;  FUNCTION :   dat_3dp_str_names.pro
;  PURPOSE  :   Returns the associated structure name for the input.  Enter a
;                 string to get the "formal" name associated with a particular
;                 detector (i.e. 'elb' -> 'Eesa Low Burst') or a structure to 
;                 get a two or three letter string associated with structure
;                 (i.e. dat = get_el() => result = 'el').
;
;  CALLED BY:
;               NA
;
;  CALLS:
;               NA
;
;  REQUIRES:
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               DAT  :  [string,structure] associated with a known THEMIS ESA data
;                         structure
;                           String Inputs:
;                             el[ , b]     :  EESA Low Electrons   [ , Burst]
;                             eh[ , b]     :  EESA High Electrons  [ , Burst]
;                             pl[ , b]     :  PESA Low Electrons   [ , Burst]
;                             ph[ , b]     :  PESA High Electrons  [ , Burst]
;                             sf[ , b, t]  :  SST Electrons        [ , Burst, Thick]
;                             so[ , b, t]  :  SST Ions             [ , Burst, Thick]
;                           Structure Inputs:
;                             dat = get_???()
;                               ???        =  el, ehb, sft, etc.
;
;  EXAMPLES:
;               el   = get_el(t)
;               temp = dat_3dp_str_names(el)
;               PRINT,';  '+temp.LC[0]
;               ;  Eesa Low
;               PRINT,';  '+temp.UC[0]
;               ;  EESA LOW
;               PRINT,';  '+temp.SN[0]
;               ;  el
;
;               temp = dat_3dp_str_names('sfb')
;               PRINT,';  '+temp.LC[0]
;               ;  SST Foil Burst
;               PRINT,';  '+temp.UC[0]
;               ;  SST FOIL BURST
;               PRINT,';  '+temp.SN[0]
;               ;  sfb
;
;  KEYWORDS:  
;               NOM  :  If set, routine will not print out messages
;
;   CHANGED:  1)  Updated 'man' page                      [11/11/2008   v1.0.3]
;             2)  Rewrote and renamed with more comments  [07/20/2009   v2.0.0]
;             3)  Fixed some small typos in comments      [08/05/2009   v2.0.1]
;             4)  Fixed syntax error when sending in structures
;                                                         [08/31/2009   v2.1.0]
;             5)  Fixed an issue which arose when sending PAD structures
;                                                         [09/18/2009   v2.1.1]
;             6)  Now only returns a structure if successful
;                                                         [03/13/2012   v2.2.0]
;             7)  Fixed an issue which arose when DAT was not a 3DP data structure but
;                   was similar enough to get to the middle of the routine
;                                                         [03/14/2012   v2.2.1]
;             8)  Rewrote, optimized, and now distinguishes between THEMIS and Wind
;                   and added keyword:  NOM
;                                                         [03/29/2012   v3.0.0]
;             9)  Fixed an issue which arose when DAT was a string input
;                                                         [04/03/2012   v3.1.0]
;
;   NOTES:      
;               1)  Though it only suggests one can call this routine using the
;                     3-letter string combinations listed above, one can input a
;                     string corresponding to the value given by the
;                     DATA_NAME structure tag in a 3DP distribution structure.
;
;   CREATED:  07/05/2008
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  04/03/2012   v3.1.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION dat_3dp_str_names,dat,NOM=nom

;-----------------------------------------------------------------------------------------
; => Define some constants and dummy variables
;-----------------------------------------------------------------------------------------
;  Electrostatic Analyzers
short_pref_es  = ['e','p']
mid_suff_es    = ['l','h']
short_suff_es  = ['','b']
data_pref_es   = ['Eesa','Pesa']+' '
data_mids_es   = ['Low','High']
data_suff_es   = ['',' Burst']
shortstring_es = STRARR(2,2,2)  ;  { [e,p], [l,h], [ ,b] }
data_names_es  = STRARR(2,2,2)
FOR j=0L, 1L DO BEGIN
  FOR k=0L, 1L DO BEGIN
    shortstring_es[*,j,k] = short_pref_es[*]+mid_suff_es[j]+short_suff_es[k]
    data_names_es[*,j,k]  = data_pref_es[*]+data_mids_es[j]+data_suff_es[k]
  ENDFOR
ENDFOR

;  Solid State Telescopes
short_pref_st  = ['sf','so']
short_suff_st  = ['','b','t']
data_pref_st   = ['SST Foil','SST Open']
data_suff_st   = ['',' Burst','+Thick']
shortstring_st = STRARR(2,3)  ;  { [sf,so], [ ,b,t] }
data_names_st  = STRARR(2,3)
FOR j=0L, 2L DO BEGIN
  shortstring_st[*,j] = short_pref_st[*]+short_suff_st[j]
  data_names_st[*,j]  = data_pref_st[*]+data_suff_st[j]
ENDFOR

notstr_mssg    = 'Must be an IDL structure...'
badstr_mssg    = 'This is not a valid 3DP data structure!'
badsat_mssg    = 'Not a Wind 3DP structure...'
badstn_mssg    = 'Not an appropriate 3DP string name...'
;-----------------------------------------------------------------------------------------
; => Determine input type
;-----------------------------------------------------------------------------------------
dtype = SIZE(dat,/TYPE)
CASE dtype[0] OF
  8    : BEGIN
    ;-------------------------------------------------------------------------------------
    ; => Input is a structure
    ;-------------------------------------------------------------------------------------
    tags = TAG_NAMES(dat)
    test = (TOTAL((STRUPCASE(tags) EQ 'PROJECT_NAME')) NE 1) OR $
           (TOTAL((STRUPCASE(tags) EQ 'DATA_NAME')) NE 1)
    IF (test) THEN BEGIN
      ; => bad structure format
      IF ~KEYWORD_SET(nom) THEN MESSAGE,badstr_mssg[0],/INFORMATIONAL,/CONTINUE
      RETURN,0b
    ENDIF
    data = dat[0]
    test = STRMID(STRTRIM(STRUPCASE(data.PROJECT_NAME),2),0L,4L) NE 'WIND'
    IF (test) THEN BEGIN
      ; => not a Wind structure format
      IF ~KEYWORD_SET(nom) THEN MESSAGE,badsat_mssg[0],/INFORMATIONAL,/CONTINUE
      RETURN,0b
    ENDIF
    ;-------------------------------------------------------------------------------------
    ; => Determine particle type and instrument name
    ;-------------------------------------------------------------------------------------
    data_name = STRLOWCASE(data[0].DATA_NAME)
    part_name = STRMID(data_name[0],0L,1L)              ; => e.g. 'e'
    lowhighfo = STRTRIM(STRMID(data_name[0],4L),2L)     ; => e.g. 'low burst'
    ; => List of possible values
    ;     'low'  + ['',' burst']
    ;     'high' + ['',' burst']
    ;     'foil' + ['',' burst','+thick']
    ;     'open' + ['',' burst','+thick']
    CASE part_name[0] OF
      'e'  : BEGIN
        ; => Eesa
        b__ind = STRLEN(lowhighfo[0]) GT 4               ; True = 'Burst', False = ''
        lh_ind = STRMID(lowhighfo[0],0L,1L) EQ 'h'       ; True = 'High', False = 'Low'
        s_name = shortstring_es[0L,lh_ind[0],b__ind[0]]  ; => e.g. 'elb'
        l_name = data_names_es[0L,lh_ind[0],b__ind[0]]   ; => e.g. 'Eesa Low Burst'
      END
      'p'  : BEGIN
        ; => Pesa
        b__ind = STRLEN(lowhighfo[0]) GT 4               ; True = 'Burst', False = ''
        lh_ind = STRMID(lowhighfo[0],0L,1L) EQ 'h'       ; True = 'High', False = 'Low'
        s_name = shortstring_es[1L,lh_ind[0],b__ind[0]]  ; => e.g. 'phb'
        l_name = data_names_es[1L,lh_ind[0],b__ind[0]]   ; => e.g. 'Pesa High Burst'
      END
      's'  : BEGIN
        ; => SST
        fo_ind    = STRMID(lowhighfo[0],0L,1L) EQ 'o'    ; True = 'Open', False = 'Foil'
        test      = STRLEN(lowhighfo[0]) GT 4
        IF (test) THEN BEGIN
          bt_name = STRMID(lowhighfo[0],5L,1L) EQ 't'    ; True = 'Thick', False = 'Burst'
          bt_ind  = bt_name[0] + 1L
        ENDIF ELSE BEGIN
          bt_ind  = 0L
        ENDELSE
        s_name = shortstring_st[fo_ind[0],bt_ind[0]]
        l_name = data_names_st[fo_ind[0],bt_ind[0]]
      END
      ELSE : BEGIN
        ; => No match
        IF ~KEYWORD_SET(nom) THEN MESSAGE,badstr_mssg[0],/INFORMATIONAL,/CONTINUE
        RETURN,0b
      END
    ENDCASE
  END
  7    : BEGIN
    ; first test length
    testl = STRLEN(dat[0]) GT 3
    IF (testl) THEN BEGIN
      ; => Input may be full name [e.g. 'Eesa Low Burst']
      plus_t = STRMATCH(dat[0],'*+*',/FOLD_CASE)
      IF (plus_t) THEN BEGIN
        ; => SST [Foil,Open]+Thick
        check_fo = [STRMATCH(dat[0],'*foil*',/FOLD_CASE),STRMATCH(dat[0],'*open*',/FOLD_CASE)]
        good_fo  = WHERE(check_fo,gdfo)
        IF (gdfo GT 0) THEN BEGIN
          ; => SST []+Thick
          RETURN,dat_3dp_str_names(shortstring_st[good_fo[0],2L],NOM=nom)
        ENDIF ELSE BEGIN
          ; => bad input
          IF ~KEYWORD_SET(nom) THEN MESSAGE,badstn_mssg[0],/INFORMATIONAL,/CONTINUE
          RETURN,0b
        ENDELSE
      ENDIF ELSE BEGIN
        ; => Some other input
        parts = STRSPLIT(dat[0],' ',/EXTRACT,/REGEX)
        dumbn = ''
        FOR j=0L, N_ELEMENTS(parts) - 1L DO dumbn = dumbn[0]+STRMID(parts[j],0L,1L)
        ; re-call the routine using standard 3-letter input
        RETURN,dat_3dp_str_names(STRLOWCASE(dumbn[0]),NOM=nom)
      ENDELSE
    ENDIF
    ;-------------------------------------------------------------------------------------
    ; => Input is a string
    ;-------------------------------------------------------------------------------------
    teste = (shortstring_es EQ dat[0])
    tests = (shortstring_st EQ dat[0])
    test1 = (TOTAL(teste) NE 1) AND (TOTAL(tests) NE 1)
;    test1 = TOTAL(test0) NE 1
    IF (test1) THEN BEGIN
      ; => bad string format
      IF ~KEYWORD_SET(nom) THEN MESSAGE,badstn_mssg[0],/INFORMATIONAL,/CONTINUE
      RETURN,0b
    ENDIF
    ;-------------------------------------------------------------------------------------
    ; => Determine appropriate names
    ;-------------------------------------------------------------------------------------
    part_name  = STRMID(dat[0],0L,1L)                 ; => e.g. 'e'
    lowhighfo  = STRTRIM(STRMID(dat[0],1L),2L)        ; => e.g. 'lb'
    burstthick = STRLEN(lowhighfo[0]) GT 1            ; True = 'Thick' or 'Burst', False = ''
    CASE part_name[0] OF
      'e'  : BEGIN
        ; => Eesa
        b__ind = burstthick[0]
        lh_ind = STRMID(lowhighfo[0],0L,1L) EQ 'h'       ; True = 'High', False = 'Low'
        s_name = shortstring_es[0L,lh_ind[0],b__ind[0]]  ; => e.g. 'elb'
        l_name = data_names_es[0L,lh_ind[0],b__ind[0]]   ; => e.g. 'Eesa Low Burst'
      END
      'p'  : BEGIN
        ; => Pesa
        b__ind = burstthick[0]
        lh_ind = STRMID(lowhighfo[0],0L,1L) EQ 'h'       ; True = 'High', False = 'Low'
        s_name = shortstring_es[1L,lh_ind[0],b__ind[0]]  ; => e.g. 'phb'
        l_name = data_names_es[1L,lh_ind[0],b__ind[0]]   ; => e.g. 'Pesa High Burst'
      END
      's'  : BEGIN
        ; => SST
        fo_ind    = STRMID(lowhighfo[0],0L,1L) EQ 'o'    ; True = 'Open', False = 'Foil'
        IF (burstthick) THEN BEGIN
          bt_name = STRMID(lowhighfo[0],1L,1L) EQ 't'    ; True = 'Thick', False = 'Burst'
          bt_ind  = bt_name[0] + 1L
        ENDIF ELSE BEGIN
          bt_ind  = 0L
        ENDELSE
        s_name = shortstring_st[fo_ind[0],bt_ind[0]]
        l_name = data_names_st[fo_ind[0],bt_ind[0]]
      END
      ELSE : BEGIN
        ; => No match
        IF ~KEYWORD_SET(nom) THEN MESSAGE,badstn_mssg[0],/INFORMATIONAL,/CONTINUE
        RETURN,0b
      END
    ENDCASE
  END
  ELSE : BEGIN
    ;-------------------------------------------------------------------------------------
    ; => Bad Input
    ;-------------------------------------------------------------------------------------
    IF ~KEYWORD_SET(nom) THEN MESSAGE,notstr_mssg[0],/INFORMATIONAL,/CONTINUE
    RETURN,0b
  END
ENDCASE

;-------------------------------------------------------------------------------------
; => Define return structure
;-------------------------------------------------------------------------------------
struct    = {LC:l_name[0],UC:STRUPCASE(l_name[0]),SN:s_name[0]}

RETURN,struct
END

















;+
;*****************************************************************************************
;
;  FUNCTION :   struct_new_el_add.pro
;  PURPOSE  :   Adds or replaces existing elements of an IDL structure.
;
;  CALLED BY:   
;               NA
;
;  CALLS:
;               array_where.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               NEWTAG     :  Scalar string defining the structure tag to add to OLDSTR
;               NEWVAL     :  Value associated with NEWTAG
;               OLDSTR     :  Scalar IDL structure
;
;  OUTPUT:
;               NEWSTRUCT  :  Set to a named variable for this routine to return the
;                               new IDL structure
;
;  EXAMPLES:    
;               oldstr = {X:dindgen(100),y:dindgen(100,3)}
;               newtag = 'V'
;               newval = findgen(100)
;               struct_new_el_add,newtag,newval,oldstruct,newstruct
;               HELP, newstruct,/STR
;
;** Structure <4400db8>, 3 tags, length=3600, data length=3600, refs=1:
;   X               DOUBLE    Array[100]
;   Y               DOUBLE    Array[100, 3]
;   V               FLOAT     Array[100]
;
;  KEYWORDS:    
;               GOLD_T     :  N-Element array of structure tags found in OLDSTR to use
;                               when creating NEWSTRUCT
;
;   CHANGED:  1)  Fixed a typo dealing with use of GOLD_T [04/26/2011   v1.0.1]
;
;   NOTES:      
;               
;
;   CREATED:  03/09/2011
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  04/26/2011   v1.0.1
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

PRO struct_new_el_add,newtag,newval,oldstr,newstruct,GOLD_T=gold

;-----------------------------------------------------------------------------------------
; => Define dummy variables
;-----------------------------------------------------------------------------------------
f          = !VALUES.F_NAN
d          = !VALUES.D_NAN
notag_mssg = 'Structure tags in keyword GOLD_T do not exist... Using existing values'
ostr       = oldstr[0]
nval       = newval
o_tags     = STRLOWCASE(TAG_NAMES(ostr))
nots       = N_TAGS(ostr)

IF KEYWORD_SET(gold) THEN BEGIN
  glds  = STRLOWCASE(gold)
  ; => make sure the elements overlap
  good  = array_where(glds,o_tags,/N_UNIQ,NCOMP1=comp1,NCOMP2=comp2)
  IF (good[0] GE 0) THEN BEGIN
    gols   = REFORM(good[*,1])
    o_tags = o_tags[gols]
  ENDIF ELSE BEGIN
    MESSAGE,notag_mssg,/INFORMATIONAL,/CONTINUE
    o_tags = o_tags
    gols   = LINDGEN(nots)
  ENDELSE
ENDIF ELSE gols = LINDGEN(nots)

nots = N_ELEMENTS(gols)
;-----------------------------------------------------------------------------------------
; => Check input
;-----------------------------------------------------------------------------------------
IF (STRLOWCASE(newtag[0]) EQ '') THEN BEGIN
  ; => Do not add to structure
  ntags  = o_tags
ENDIF ELSE BEGIN
  ; => Add new tag to structure
  ntags  = [o_tags,STRLOWCASE(newtag[0])]
ENDELSE
nnts   = N_ELEMENTS(ntags)
;-----------------------------------------------------------------------------------------
; => Write a dummy string to create the desired structure
;-----------------------------------------------------------------------------------------
crstr  = 'nstruct = CREATE_STRUCT(ntags,'
prefst = 'ostr.('
strnnn = ''
; => Create the string that will create the new structure
FOR j=0L, nots - 1L DO BEGIN
  gg0  = gols[j]
  jstr = STRTRIM(gg0,2L)+'L'
  st00 = prefst[0]+jstr[0]+'),'
  IF (j EQ 0) THEN strnnn = crstr[0]+st00[0] ELSE strnnn = strnnn[0]+st00[0]
  IF (j EQ nots - 1L) THEN BEGIN
    IF (nnts EQ nots) THEN BEGIN
      ; => Do not add to structure
      stlen  = STRLEN(strnnn[0])
      strnnn = STRMID(strnnn[0],0L,stlen[0]-1L)+')'
    ENDIF ELSE BEGIN
      strnnn = strnnn[0]+'nval)'
    ENDELSE
  ENDIF
ENDFOR
; => Create new structure
test = EXECUTE(strnnn)
;-----------------------------------------------------------------------------------------
; => Return new structure to user
;-----------------------------------------------------------------------------------------
IF (test EQ 0) THEN newstruct = 0 ELSE newstruct = nstruct
RETURN
END

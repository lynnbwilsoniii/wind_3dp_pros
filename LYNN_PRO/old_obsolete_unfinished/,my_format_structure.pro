;+
;*****************************************************************************************
;
;  FUNCTION :   my_format_structure.pro
;  PURPOSE  :   Determines the data types and formats of a format statement then returns
;                 a structure with all the relevant information regarding the format
;                 statement [possibly useful for reading in multiple files].
;
;  CALLED BY:   NA
;
;  CALLS:       NA
;
;  REQUIRES:    NA
;
;  INPUT:
;               MFORMS  :  Format of file to be read in and sorted
;                          [must have form of:  '(12a20,...)' aka typical format 
;                           statement]
;
;  EXAMPLES:    NA
;
;  KEYWORDS:    NA
;
;   CHANGED:  1)  NA [MM/DD/YYYY   v1.0.0]
;
;   CREATED:  03/17/2009
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  03/17/2009   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION my_format_structure,mforms

;*****************************************************************************************
; -Dummy variables
;*****************************************************************************************
mform = (REFORM(mforms))[0L]
aspl  = STRSPLIT(mform,'a',COUNT=asp)  ; -Positions of all 'a' 's in format statement
dspl  = STRSPLIT(mform,'d',COUNT=dsp)  ; -" " 'd' " "
fspl  = STRSPLIT(mform,'f',COUNT=fsp)  ; -" " 'f' " "
Ispl  = STRSPLIT(mform,'I',COUNT=Isp)  ; -" " 'I' " "
Gspl  = STRSPLIT(mform,'G',COUNT=Gsp)  ; -" " 'G' " "
Espl  = STRSPLIT(mform,'E',COUNT=Esp)  ; -" " 'E' " "
eepl  = STRSPLIT(mform,'e',COUNT=eep)  ; -" " 'E' " "
copl  = STRSPLIT(mform,',',COUNT=csp)  ; -" " ',' " "

apos  = -1L                            ; -Position of 'a' in format statement
dpos  = -1L                            ; -Position of 'd' in format statement
fpos  = -1L                            ; -Position of 'f' in format statement
Ipos  = -1L                            ; -Position of 'I' in format statement
Gpos  = -1L                            ; -Position of 'G' in format statement
Epos  = -1L                            ; -Position of 'E' in format statement
eeos  = -1L                            ; -Position of 'e' in format statement

nstrings  = -1L                        ; -# of different string quant. in file
ndoubles  = -1L                        ; -" " double " "
nfloats   = -1L                        ; -" " float " "
ninteger  = -1L                        ; -" " Integer/Long " "
ngdoubs   = -1L                        ; -" " G-Format " "
nEexpons  = -1L                        ; -" " E-Format " "
neeexpon  = -1L                        ; -" " e-Format " "
mytags    = ['t0','t1','t2','t3','t4','t5','t6','t7','t8','t9','t10','t11','t12','t13',$
             't14','t15','t16','t17','t18','t19']
dum       = CREATE_STRUCT(mytags,'','','','','','','','','','','','','','','','','','','','')
f_str = CREATE_STRUCT('STRINGS',nstrings,'DOUBLES',ndoubles,'FLOATS',nfloats,$
                      'INT_LONG',ninteger,'G_FORM',ngdoubs,'E_FORM',nEexpons,$
                      'EE_FORM',neeexpon,'FORMS',0L,'NFORMS',0L,$
                      'D_STR',dum)

n_fors = [asp,dsp,fsp,Isp,Gsp,Esp,eep]
;*****************************************************************************************
; -Check format statement
;*****************************************************************************************
check  = WHERE(n_fors GT 1L,gch)
IF (gch GT 0L) THEN BEGIN
  FOR k=0L, gch - 1L DO BEGIN
    ch = check[k]
    CASE ch OF
      0    :  BEGIN  ; 'a'
        apos    = LONARR(asp - 1L)
        FOR j=0L, asp - 2L DO BEGIN
          IF (j GT 0L) THEN i = apos[j-1L] + 1L ELSE i = 0L
          apos[j] = STRPOS(mform,'a',i)
        ENDFOR
      END
      1    :  BEGIN  ; 'd'
        dpos    = LONARR(dsp - 1L)
        FOR j=0L, dsp - 2L DO BEGIN
          IF (j GT 0L) THEN i = dpos[j-1L] + 1L ELSE i = 0L
          dpos[j] = STRPOS(mform,'d',i)
        ENDFOR
      END
      2    :  BEGIN  ; 'f'
        fpos    = LONARR(fsp - 1L)
        FOR j=0L, fsp - 2L DO BEGIN
          IF (j GT 0L) THEN i = fpos[j-1L] + 1L ELSE i = 0L
          fpos[j] = STRPOS(mform,'f',i)
        ENDFOR
      END
      3    :  BEGIN  ; 'I'
        Ipos    = LONARR(Isp - 1L)
        FOR j=0L, Isp - 2L DO BEGIN
          IF (j GT 0L) THEN i = Ipos[j-1L] + 1L ELSE i = 0L
          Ipos[j] = STRPOS(mform,'I',i)
        ENDFOR
      END
      4    :  BEGIN  ; 'G'
        Gpos    = LONARR(Gsp - 1L)
        FOR j=0L, Gsp - 2L DO BEGIN
          IF (j GT 0L) THEN i = Gpos[j-1L] + 1L ELSE i = 0L
          Gpos[j] = STRPOS(mform,'G',i)
        ENDFOR
      END
      5    :  BEGIN  ; 'E'
        Epos    = LONARR(Esp - 1L)
        FOR j=0L, Esp - 2L DO BEGIN
          IF (j GT 0L) THEN i = Epos[j-1L] + 1L ELSE i = 0L
          Epos[j] = STRPOS(mform,'E',i)
        ENDFOR
      END
      6    :  BEGIN  ; 'e'
        eeos    = LONARR(eep - 1L)
        FOR j=0L, eep - 2L DO BEGIN
          IF (j GT 0L) THEN i = eeos[j-1L] + 1L ELSE i = 0L
          eeos[j] = STRPOS(mform,'e',i)
        ENDFOR
      END
    ENDCASE
  ENDFOR
ENDIF ELSE BEGIN
  MESSAGE,"No format statement was found...",/INFORMATIONAL
  RETURN,f_str
ENDELSE
;*****************************************************************************************
; -Determine what types of data are in ASCII file
;*****************************************************************************************
all_pos = ([apos,dpos,fpos,Ipos,Gpos,Epos,eeos])[SORT([apos,dpos,fpos,Ipos,Gpos,Epos,eeos])]
g_pos   = WHERE(all_pos GT 0,g_p)
IF (g_p GT 0L) THEN BEGIN
  gall_pos = all_pos[g_pos]
ENDIF ELSE BEGIN
  MESSAGE,"Not sure how you got here...",/INFORMATIONAL
  RETURN,f_str
ENDELSE
num_len  = 0L   ; -String Length of numbers preceeding the format strings (e.g. 15a => 2)
num_typs = 0L   ; -Long associated with # of each type of data in file
IF (gall_pos[0L] GT 1L) THEN BEGIN ; -first format type has more than one column
  num_len                = LONARR(csp)
  num_len[0]             = gall_pos[0L] - 1L
  num_len[1L:(csp - 1L)] = gall_pos[1L:(csp - 1L)] - copl[1L:(csp - 1L)]
  num_typs               = LONG(STRMID(mform,gall_pos - num_len,num_len))
ENDIF ELSE BEGIN
  num_len  = gall_pos[1L:(csp - 1L)] - copl[1L:(csp - 1L)]
  num_typs = [1L,LONG(STRMID(mform,gall_pos[1L:(csp - 1L)] - num_len,num_len))]
ENDELSE
low_num  = WHERE(num_typs EQ 0L,lmn)
IF (lmn GT 0L) THEN num_typs[low_num] = 1L
num_forms = STRMID(mform,gall_pos,1L)  ; -All the format codes in format statement
FOR j=0L, g_p - 1L DO BEGIN
  f_code = num_forms[j]
  CASE f_code OF
    'a' : BEGIN
      nstrings  = LONG(TOTAL(num_typs[WHERE(num_forms EQ 'a')]))
      t_arr     = STRARR(num_typs[j])
    END
    'd' : BEGIN
      ndoubles  = LONG(TOTAL(num_typs[WHERE(num_forms EQ 'd')]))
      t_arr     = DBLARR(num_typs[j])
    END
    'f' : BEGIN
      nfloats   = LONG(TOTAL(num_typs[WHERE(num_forms EQ 'f')]))
      t_arr     = FLTARR(num_typs[j])
    END
    'I' : BEGIN
      ninteger  = LONG(TOTAL(num_typs[WHERE(num_forms EQ 'I')]))
      t_arr     = LONARR(num_typs[j])
    END
    'G' : BEGIN
      ngdoubs   = LONG(TOTAL(num_typs[WHERE(num_forms EQ 'G')]))
      t_arr     = DBLARR(num_typs[j])
    END
    'E' : BEGIN
      nEexpons  = LONG(TOTAL(num_typs[WHERE(num_forms EQ 'E')]))
      t_arr     = FLTARR(num_typs[j])
    END
    'e' : BEGIN
      neeexpon  = LONG(TOTAL(num_typs[WHERE(num_forms EQ 'e')]))
      t_arr     = FLTARR(num_typs[j])
    END
  ENDCASE
  str_element,dum,mytags[j],t_arr,/ADD_REPLACE
ENDFOR

f_str = CREATE_STRUCT('STRINGS',nstrings,'DOUBLES',ndoubles,'FLOATS',nfloats,$
                      'INT_LONG',ninteger,'G_FORM',ngdoubs,'E_FORM',nEexpons,$
                      'EE_FORM',neeexpon,'FORMS',num_forms,'NFORMS',num_typs,$
                      'D_STR',dum)

RETURN,f_str
END
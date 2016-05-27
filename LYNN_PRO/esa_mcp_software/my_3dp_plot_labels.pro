;+
;*****************************************************************************************
;
;  FUNCTION :   my_3dp_plot_labels.pro
;  PURPOSE  :   Generates plot labels and positions for semi-arbitrary data
;                 structures (PAD structures and spec structures created by
;                 pad.pro or my_pad_dist.pro and get_padspec.pro or 
;                 my_get_padspec_5.pro or the results of reduce_dimen.pro and
;                 reduce_pads.pro).  The structure returned contains information
;                 about the TPLOT variable labels and their positions in the
;                 plot window, relative to the data.
;
;  CALLED BY:   
;               my_padplot_both.pro
;
;  CALLS:
;               get_data.pro
;
;  REQUIRES:    NA
;
;  INPUT:
;               D2  :  A data structure produced from a 3DP moment structure or
;                        multiple 3DP moment structures with one of the following
;                        formats:
;                        1)  {X:time,Y:[n,3]}         <-> vector TPLOT variable
;                        2)  {X:time,Y:[n,m],V:[n,m]} <-> Spectra at one PA
;                        3)  {X:time,Y:[n,m,l],V1:[n,m],V2[n,l],SPEC:[0,1]}
;                          [Where:  n = # of time steps, m = # of energy bins, 
;                                   and l = # of PA's]
;                        4)  PAD produced by pad.pro or my_pad_dist.pro
;
;  EXAMPLES:    NA
;
;  KEYWORDS:  
;               NAMEN  : name associated with structure for identifying anonymous 
;                         structures (e.g. name='magf' for B-field data)
;                         {list : magf,velo,temp,qflu,dens}
;
;   CHANGED:  1)  Updated 'man' page                              [11/11/2008   v1.0.2]
;             2)  Fixed label issue [only a problem if PAD structures had NaNs in
;                    energy or pitch-angle bins => usually NOT a problem for EL]
;                                                                 [12/08/2008   v1.0.3]
;             3)  Updated man page and changed some minor syntax  [08/05/2009   v1.1.0]
;
;   CREATED:  05/12/2008
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  08/05/2009   v1.1.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION my_3dp_plot_labels,d2,NAMEN=namen

;-----------------------------------------------------------------------------------------
; -make sure we have the correct type of data
;-----------------------------------------------------------------------------------------
IF (SIZE(d2,/TYPE) NE 8) THEN BEGIN
  IF (SIZE(d2,/TYPE) EQ 7) THEN BEGIN
    get_data,d2,DATA=d
    IF (SIZE(d,/N_DIMENSIONS) EQ 0L) THEN BEGIN
      MESSAGE, 'Null data quantity and/or structure...',/CONTINUE,/INFORMATIONAL
      RETURN,0
    ENDIF
  ENDIF ELSE BEGIN
    MESSAGE, 'Incorrect data entry:  D2 MUST be STRUCTURE!',/CONTINUE,/INFORMATIONAL
    RETURN,d2
  ENDELSE
ENDIF
d = d2
;-----------------------------------------------------------------------------------------
; -Determine what type of structure this is
;-----------------------------------------------------------------------------------------
mytags = TAG_NAMES(d)
gtags  = WHERE(mytags EQ 'DATA_NAME',gags)
IF (gags GT 0) THEN BEGIN
  dname = d.DATA_NAME
  dnlen = STRLEN(dname)
  sname = STRMID(dname,dnlen-3L,3)    ; -last 3 characters of data str name
  ndims = SIZE(d.data,/DIMENSIONS)
  mdims = N_ELEMENTS(ndims)           ; -# of dimensions
  IF (sname EQ 'PAD') THEN BEGIN
    nd1    = ndims[1]                    ; -# of pitch-angles
    nd2    = ndims[0]                    ; -# of energy bins
    nd3    = 0L
    fener  = TOTAL(FINITE(d.ENERGY),2,/NAN)
    myener = TOTAL(d.ENERGY,2,/NAN)/fener   ; => Calcs energies for associated bins
    fpang  = TOTAL(FINITE(d.ANGLES),1,/NAN)
    mypang = TOTAL(d.ANGLES,1,/NAN)/fpang   ; => Calcs pitch-angles for each energy
    xdat   = TRANSPOSE(d.ANGLES)
    ydat   = TRANSPOSE(d.data)
    mener  = d.NENERGY - 1L
    labels = STRTRIM(STRING(FORMAT='(f10.1)',myener),2)+' eV'
    GOTO,JUMP_PAD
  ENDIF ELSE BEGIN
    MESSAGE, 'Not sure what you plan on plotting...',/CONTINUE,/INFORMATIONAL
    RETURN,0
  ENDELSE
ENDIF ELSE BEGIN
  gtags1 = WHERE(mytags EQ 'Y',gags1)
  IF (gags1 GT 0) THEN BEGIN
    ndims = SIZE(d.y,/DIMENSIONS,/L64)  ; -# of elements in each dimension
    mdims = N_ELEMENTS(ndims)           ; -# of dimensions
    CASE mdims OF
      3L : BEGIN
        gtags2 = WHERE(mytags EQ 'V1',gags2)
        IF (gags2 GT 0) THEN BEGIN
          nd1    = ndims[0]   ; typically for spec data => # of samples
          nd2    = ndims[1]   ; " " => # of energy bins
          nd3    = ndims[2]   ; " " => # of pitch-angles which have been summed over
          mener  = nd2 - 1L ; variable used for loops
          temper = TOTAL(FINITE(d.V1),1,/NAN)
          tempan = TOTAL(FINITE(d.V2),1,/NAN)
          myener = TOTAL(d.V1,1,/NAN)/temper   ; -get energies for data labels
          mypang = TOTAL(d.V2,1,/NAN)/tempan
          xdat   = d.X
          ydat   = TRANSPOSE(d.Y)      ; - [nd1, nd2, nd3] element array
          labels = STRTRIM(STRING(FORMAT='(f10.1)',myener),2)+' eV'
          GOTO,JUMP_3D
        ENDIF ELSE BEGIN
          MESSAGE, 'I do not know what has this format...',/CONTINUE,/INFORMATIONAL
          RETURN,0
        ENDELSE
      END
      2L : BEGIN
        gtags3 = WHERE(mytags EQ 'V',gags3)
        IF (gags3 GT 0) THEN BEGIN
          nd1    = ndims[0]
          nd2    = ndims[1]
          nd3    = 0L
          mener  = nd2 - 1L ; variable used for loops
          temper = TOTAL(FINITE(d.V1),1,/NAN)
          myener = TOTAL(d.V,1,/NAN)/temper   ; -get energies for data labels
          xdat   = d.X
          ydat   = d.Y      ; - [nd1, nd2] element array
          field_name = 'SPEC'
          GOTO,JUMP_2D
        ENDIF ELSE BEGIN
          nd1  = ndims[0]
          nd2  = ndims[1]
          nd3  = 0L
          xdat = d.X
          ydat = d.Y
          IF KEYWORD_SET(namen) THEN field_name=namen ELSE BEGIN
            print,''
            print,'What type of data are we looking at?'
            print,''
            print,"For Magnetic Field Enter : 'MAGF'"
            print,"For Velocity Enter       : 'VELO'"
            print,"For 3D-Temperature Enter : 'TEMP'"
            print,"For 3D Heat Flux Vector  : 'QFLU'"
            print,"For 3D Density Enter     : 'DENS'"
            print,''
            READ,PROMPT='Please enter correct Field : ',field_name
          ENDELSE
          GOTO,JUMP_2D
        ENDELSE
      END
      ELSE : BEGIN
        MESSAGE, 'I do not know what you entered...',/CONTINUE,/INFORMATIONAL
        RETURN,0
      END
    ENDCASE
  ENDIF
ENDELSE
;-----------------------------------------------------------------------------------------
; -Determine the position of the TPLOT or regular plot labels
;-----------------------------------------------------------------------------------------
;=========================================================================================
JUMP_2D:
;=========================================================================================
posi  = FLTARR(nd2,2)
FOR k=0L,nd2 - 1L DO BEGIN
  gposi  = WHERE(FINITE(ydat[*,k]) AND FINITE(xdat[*,k]),gpo)
  IF (gpo GT 0) THEN BEGIN
    mposi     = MAX(gposi,/NAN)
    lposi     = ARRAY_INDICES(ydat,mposi)
    posi[k,*] = [[xdat[lposi[0],k]],[(ydat[lposi[0],k] + 0.05*ydat[lposi[0],k])]]
  ENDIF ELSE BEGIN
    posi[k,*] = [[MAX(xdat,/NAN)],[MIN(ydat,/NAN)]]
  ENDELSE
ENDFOR

field_name = STRUPCASE(field_name)
CASE field_name OF
  'SPEC' : BEGIN
    labels = STRTRIM(STRING(FORMAT='(f12.1)',myener),2)+' eV'
  END
  'MAGF' : BEGIN
    labels = ['B!Dx!N','B!Dy!N','B!Dz!N']
  END
  'VELO' : BEGIN
    labels = ['V!Dx!N','V!Dy!N','V!Dz!N']
  END
  'TEMP' : BEGIN
    print,''
    print,'Please specify the particle species for this temp...'
    print,"For protons enter : 'PROTON'"
    print,"For electrons enter : 'ELECTRON'"
    print,"For alpha particles enter : 'ALPHA'"
    print,"For generic ions enter : 'ION'"
    print,''
    READ,PROMPT='Enter species name : ',pspecies
    pspecies = STRUPCASE(pspecies)
    CASE pspecies OF
      'PROTON' : BEGIN
        labels = ['T!Dpx!N','T!Dpy!N','T!Dpz!N']
      END
      'ELECTRON' : BEGIN
        labels = ['T!Dex!N','T!Dey!N','T!Dez!N']
      END
      'ALPHA' : BEGIN
        labels = ['T!D!7a!3!N'+'!Dx!N','T!D!7a!3!N'+'!Dy!N','T!D!7a!3!N'+'!Dz!N']
      END
      'ION' : BEGIN
        labels = ['T!Dx!N','T!Dy!N','T!Dz!N']
      END
      ELSE  : BEGIN
        MESSAGE, 'Invalid species name:  Using generic labels...',/CONTINUE,/INFORMATIONAL
        labels = ['T!Dx!N','T!Dy!N','T!Dz!N']
      END
    ENDCASE
  END
  'QFLU' : BEGIN
    labels = ['q!Dx!N','q!Dy!N','q!Dz!N']
  END
  ELSE   : BEGIN
    MESSAGE, 'Not a valid field name!',/CONTINUE,/INFORMATIONAL
    RETURN,0
  END
ENDCASE
lab_str = CREATE_STRUCT('LABELS',labels,'POSITIONS',posi)
GOTO,JUMP_END

;=========================================================================================
JUMP_3D:
;=========================================================================================
posi  = FLTARR(nd2,nd3,2)
posi2 = FLTARR(nd2,nd3,2)

FOR k=0L,nd2 - 1L DO BEGIN
  FOR j=0L,nd3 - 1L DO BEGIN
    gposi  = WHERE(FINITE(ydat[*,k,j]) AND FINITE(xdat),gpo)
    IF (gpo GT 0) THEN BEGIN
      mposi     = MAX(gposi,/NAN)
      lposi     = ARRAY_INDICES(ydat,mposi)
      posi[k,j,*] = [[xdat[lposi[0]]],[(ydat[lposi[0],k,j] + 0.05*ydat[lposi[0],k,j])]]
    ENDIF ELSE BEGIN
      posi[k,j,*] = [[MAX(xdat,/NAN)],[MIN(ydat,/NAN)]]
    ENDELSE
  ENDFOR
ENDFOR
posi = TOTAL(posi,2,/NAN)/nd2
lab_str = CREATE_STRUCT('LABELS',labels,'POSITIONS',posi)
GOTO,JUMP_END

;=========================================================================================
JUMP_PAD:
;=========================================================================================
posi  = FLTARR(nd2,2)

FOR k=0L,nd2 - 1L DO BEGIN
  gposi  = WHERE(FINITE(ydat[*,k]) AND FINITE(xdat[*,k]),gpo)
  IF (gpo GT 0) THEN BEGIN
    mposi     = MAX(gposi,/NAN)
    lposi     = ARRAY_INDICES(ydat,mposi)
    posi[k,*] = [[xdat[lposi[0],k]],[(ydat[lposi[0],k] + 0.05*ydat[lposi[0],k])]]
  ENDIF ELSE BEGIN
    posi[k,*] = [[180.],[MIN(ydat,/NAN)/1.1]]
  ENDELSE
ENDFOR

lab_str = CREATE_STRUCT('LABELS',labels,'POSITIONS',posi)
;=========================================================================================
JUMP_END:
;=========================================================================================
RETURN,lab_str
END
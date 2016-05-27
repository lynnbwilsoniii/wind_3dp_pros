;+
;*****************************************************************************************
;
;  FUNCTION :   tplot_3dp_names_labels.pro
;  PURPOSE  :   This program creates a structure of TPLOT names, labels, and Y-titles for
;                  a given particle type [Default = 'e' which is electron].
;
;  CALLED BY: 
;               my_3dptplot_names_options.pro
;
;  CALLS:       NA
;
;  REQUIRES:    NA
;
;  INPUT:       NA
;
;  EXAMPLES:
;               tplabs = my_3dptplot_names_labels(PARTICLE='e')
;               tplabs = my_3dptplot_names_labels(PARTICLE='i')
;               tplabs = my_3dptplot_names_labels(PARTICLE='a')
;
;  KEYWORDS:  
;               PARTICLE   :  Required if anything BUT MAGF is set to assign a particle
;                               species to the labels (i.e. alpha-particles will be 
;                               labeled with "a")
;                               1) "a" = alpha-particles, 2) "i" = ions,
;                               3) "e" = electrons, 4) "p" = protons
;                               [Default = "e"]
;
;   CHANGED:  1)  Fixed TPLOT labels and return structure [03/02/2009   v1.0.1]
;             2)  Fixed TPLOT labels and return structure [03/02/2009   v1.0.2]
;             3)  Rewrote and renamed with more comments  [08/05/2009   v2.0.0]
;
;   CREATED:  03/01/2009
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  08/05/2009   v2.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION tplot_3dp_names_labels,PARTICLE=particle

;-----------------------------------------------------------------------------------------
; -Define units for tplot names and labels
;-----------------------------------------------------------------------------------------
fytu = "(Hz)"                                      ; -frequency units for Y-Title
tytu = "(eV)"                                      ; -temp units for Y-Title
vytu = "(km/s)"                                    ; -velocity units for Y-Title
bytu = "(nT)"                                      ; -Magnetic field units for Y-Title
qytu = "(eV km s!U-1!N cm!U-3!N)"                  ; -Heat flux units for Y-Title
dytu = "(cm!U-3!N)"                                ; -Density " "
rytu = "(km)"                                      ; -length units 
fftu = "(# s!U-1!N cm!U-2!N)"                      ; -Flux units
nftu = "(# cm!U-2!N s!U-1!N sr!U-1!N eV!U-1!N)"    ; -Number Flux units
eftu = "(eV cm!U-2!N s!U-1!N sr!U-1!N eV!U-1!N)"   ; -Energy Flux units
;-----------------------------------------------------------------------------------------
; -Define TPLOT subscripts for TPLOT names and/or labels
;-----------------------------------------------------------------------------------------
olau = ["!De!N","!Di!N","!D"+"!7a!3"+"!N"]  ; -subscripts to denote particle species
onau = ["e","p","i","a"]                    ; -Particle species used for TPLOT names
clau = ["!Dx!N","!Dy!N","!Dz!N"]            ; -" " coordinate component
cnau = ["x","y","z"]                        ; -Coordinate component used for TPLOT names
flau = ["!Dc!N","!Dp!N"]                    ; -" " type of freq. (cyclotron,plasma,lower-hyb.)
tlau = "!DT!N"                              ; -Use for thermal velocities
parl = "!9#!3"                              ; -Parallel Hershey Vector Font symbol
perl = "!9x!3"                              ; -Perpendicular Hershey Vector Font symbol
pars = "!D"+parl+"!N"                       ; -Parallel symbol as a subscript
pers = "!D"+perl+"!N"                       ; -Perpendicular symbol as a subscript
ccau = [pars,pers+"!D1!N",pers+"!N"+"!D2!N"]; -Field-Aligned Coordinate Labels
;ccau = [pers+"!D1!N",pers+"!N"+"!D2!N",pars]; -Field-Aligned Coordinate Labels
ccat = [pers+"!D1!N",pers+"!N"+"!D2!N",pars]; -Field-Aligned Coordinate Labels
;-----------------------------------------------------------------------------------------
; -Define some prefixes for later use
;-----------------------------------------------------------------------------------------
prefixes = ["f","r","L","V","T","B","Q","N","flux","# flux","energy flux"]
;-----------------------------------------------------------------------------------------
; -Define TPLOT names and/or labels
;-----------------------------------------------------------------------------------------
fnau  = ["c","p"]          ; -Type of freq.  used for TPLOT names
vlabs = prefixes[3]+clau   ; -" " for vector velocity plots (e.g. 'V!Dx!N' [GSE])
tlabs = prefixes[4]+ccat   ; -" " for vector temp plots (e.g. 'T!D'+'!9#!3'+'!N')
blabs = prefixes[5]+clau   ; -TPLOT labels for B-field plots (e.g. 'B!Dx!N' [GSE])
qlabs = "q"+ccau           ; -" " for heat flux vector plots (e.g. 'q!D'+'!9#!3'+'!N')
ffabs = "f"+clau           ; -" " for flux 
;-----------------------------------------------------------------------------------------
; -Determine appropriate labels
;-----------------------------------------------------------------------------------------
IF NOT KEYWORD_SET(particle) THEN BEGIN
  IF NOT KEYWORD_SET(magf) THEN part = "e" ELSE part = " "
ENDIF ELSE BEGIN
  part = STRLOWCASE(particle)
ENDELSE

CASE part OF
  "e"  : BEGIN
    pnau = "e"
    plau = "!De!N"
    fpeu = "(kHz)"
    parn = "nel_"
  END
  "p"  : BEGIN
    pnau = "p"
    plau = "!Dp!N"
    fpeu = "(Hz)"
    parn = "npl_"
  END
  "i"  : BEGIN
    pnau = "i"
    plau = "!Dsw!N"
    fpeu = "(Hz)"
    parn = "nil_"
  END
  "a"  : BEGIN
    pnau = "a"
    plau = "!D"+"!7a!3"+"!N"
    fpeu = "(Hz)"
    parn = "nal_"
  END
  ELSE : BEGIN
    pnau = ""
    plau = ""
    fpeu = "(kHz)"
    parn = "nel_"
  END
ENDCASE
;-----------------------------------------------------------------------------------------
; -Define some TPLOT names
;-----------------------------------------------------------------------------------------
gyrna = prefixes[1]+"_"+fnau[0]+pnau                         ; -Cyclotron radius TPLOT names
inena = prefixes[2]+pnau                                     ; -Inertial length TPLOT names
temna = prefixes[4]+pnau+"_(FA)"                             ; -Vector temp TPLOT names (para,perp1,perp2)
cycna = prefixes[0]+fnau[0]+pnau                             ; -Cyclotron frequency TPLOT names
plana = prefixes[0]+fnau[1]+pnau                             ; -Plasma " "
avtna = prefixes[4]+pnau+"_avg"                              ; -Avg. Temp TPLOT names
vthna = prefixes[3]+pnau+"_therm"                            ; -Thermal Vel. " "
velna = prefixes[3]+pnau                                     ; -Velocity " "
mqfna = [prefixes[5]+"(GSE)",prefixes[6]+prefixes[0]+pnau]   ; -Mag. field and heat flux " "
fffna = parn+prefixes[8]                                     ; -Flux TPLOT name
nffna = parn+prefixes[9]                                     ; -# Flux TPLOT name
effna = parn+prefixes[10]                                    ; -Energy Flux " "
fluxn = [fffna,nffna,effna]
;-----------------------------------------------------------------------------------------
; -Define Y-Titles for the tplot variables which are vectors
;-----------------------------------------------------------------------------------------
gyryt = prefixes[1]+flau[0]+plau+" "+rytu               ; -Cyclotron radius Y-titles
ineyt = prefixes[2]+plau+" "+rytu                       ; -Inertial length Y-titles
temyt = prefixes[4]+plau+" "+tytu                       ; -Vector temp Y-titles
cycyt = prefixes[0]+flau[0]+plau+" "+fytu               ; -Cyclotron frequency Y-titles
playt = prefixes[0]+flau[1]+plau+" "+fpeu               ; -Plasma frequency Y-titles
avtyt = "<"+prefixes[4]+plau+"> "+tytu                  ; -Avg. Temp Y-titles
vthyt = "<"+prefixes[3]+tlau+plau+"> "+vytu             ; -Thermal Velocity Y-Titles
velyt = prefixes[3]+plau+" [GSE] "+vytu                 ; -Velocity Y-titles
mqfyt = [prefixes[5]+" [GSE] "+bytu,$
         prefixes[6]+plau+" [FA] !C"+qytu]              ; -Mag. field and heat flux " "
fffyt = STRUPCASE(prefixes[8])+' [GSE]!C'+fftu          ; -flux
nffyt = STRUPCASE(prefixes[9])+' !C'+nftu               ; -# flux
effyt = STRUPCASE(prefixes[10])+' !C'+eftu              ; -Energy flux
fluxy = [fffyt,nffyt,effyt]
;-----------------------------------------------------------------------------------------
; -Create structures for labels/titles
;-----------------------------------------------------------------------------------------
; -Frequencies (cyclotron first then plasma)
freqstr = CREATE_STRUCT('TPLOT_NAME',[cycna,plana],'YTITLE',[cycyt,playt],$
                        'LABELS',[[REPLICATE(' ',3)],[REPLICATE(' ',3)]])
; -Temperatures (average first then vector)
tempstr = CREATE_STRUCT('TPLOT_NAME',[avtna,temna],'YTITLE',[avtyt,temyt],$
                        'LABELS',[[REPLICATE('',3)],[tlabs]])
; -Velocities (average thermal first then vector)
velostr = CREATE_STRUCT('TPLOT_NAME',[vthna,velna],'YTITLE',[vthyt,velyt],$
                        'LABELS',[[REPLICATE(' ',3)],[vlabs]])
; -Lengths (cyclotron radius first then inertial length)
lengstr = CREATE_STRUCT('TPLOT_NAME',[gyrna,inena],'YTITLE',[gyryt,ineyt],$
                        'LABELS',[[REPLICATE(' ',3)],[REPLICATE(' ',3)]])
; -Field and Heat Flux (Field first)
bqflstr = CREATE_STRUCT('TPLOT_NAME',mqfna,'YTITLE',mqfyt,'LABELS',[[blabs],[qlabs]])
; -Flux, # Flux, and Energy Flux (Flux first)
ffflstr = CREATE_STRUCT('TPLOT_NAME',fluxn,'YTITLE',fluxy,$
                        'LABELS',$
                        [[ffabs],[REPLICATE(' ',3)],[REPLICATE(' ',3)]])
;-----------------------------------------------------------------------------------------
; -Return data
;-----------------------------------------------------------------------------------------
mytags = ['TEMPS','LENGTHS','FREQS','VELS','MAG_QF','FLUXES']
allstr = CREATE_STRUCT(mytags,tempstr,lengstr,freqstr,velostr,bqflstr,ffflstr)
RETURN,allstr

END
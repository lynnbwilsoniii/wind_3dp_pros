;+
;*****************************************************************************************
;
;  FUNCTION :   padspecs_to_tplot.pro
;  PURPOSE  :   Gets particle moment spectra from the ASCII files written by
;                 my_padspec_writer.pro by calling my_padspec_reader.pro.  This 
;                 program reads in the data and splits the returned structure into
;                 various Pitch-Angles (PA's) Distributions (PADs).  The PAD's are 
;                 then sent through other programs which either smooth the data
;                 using IDL's SMOOTH.PRO or they normalize and shift the data for
;                 a more dramatic illustration of relative changes in particle flux.
;                 The manipulation is similar to that done by my_padspec_4.pro but 
;                 there is an added TPLOT variable which my_padspec_4.pro deletes,
;                 "*_cln".  These TPLOT variables are the resultant data after is
;                 has ONLY been smoothed.  Often times the particle spectra can appear
;                 very "noisy" which prevents one from seeing the important structure
;                 which may or may not exist in the data.  So smoothing is done to
;                 allow one to see the relative structure and to eliminate "bad" or
;                 "null" data in some cases (read IDL's page on SMOOTH.PRO).
;                 The program is MUCH faster than trying to use my_padspec_4.pro on
;                 a machine capable of handling the 3DP shared object libraries because
;                 it only calls ASCII files for ONLY the data of interest.
;                 The original method of calling spectra data required loading 
;                 multiple days of 3DP data, which can be computationally 
;                 cumbersome and require a lot of patience.  Though the ASCII
;                 files can often exceed 30 MB in size, they still rarely take longer
;                 than 30 seconds to load and manipulate into TPLOT variables
;                 (compared to the often excessive 300+ seconds get_padspec.pro
;                 may require to load all the 3DP moments, add magnetic field data
;                 to them, create PADs, and then create one TPLOT variable).
;                 Though my_padspec_writer.pro can take upwards of 400 seconds
;                 (Blade Sun Machine with 2 GBs of RAM), it is a passive thing which
;                 can be done while the user is working on something else.  Once
;                 the ASCII file is written, however, one never needs to load
;                 said 3DP data again for this particular type of data.
;
;  CALLED BY:   NA
;
;  CALLS:    
;               my_str_date.pro
;               dat_3dp_str_names.pro
;               padspecs_reader.pro
;               store_data.pro
;               options.pro
;               ylim.pro
;               clean_spec_spikes.pro
;               spec_vec_data_shift.pro
;               reduce_pads.pro
;               z_pads_2.pro
;
;  REQUIRES:    ASCII Files produced by my_padspec_writer.pro
;
;  INPUT:
;               NAME    : [string] Specify the type of structure you wish to 
;                           get the data for [i.e. 'el','eh','elb',etc.]
;
;  EXAMPLES:
;               t      = ['1997-01-08/00:00:00','1997-01-12/00:00:00']
;               trange = time_double(t)
;               date   = '011097'
;               my_padspec_rw,'sf',EBINS=[0,6],TRANGE=trange,DATE=date
;
;  KEYWORDS:  
;               EBINS   : [array,scalar] specifying which energy bins to create 
;                           particle spectra plots for
;               TRANGE  :  [Double] 2 element array specifying the range over 
;                           which to get data structures for
;               DATE    : [string] 'MMDDYY' specifying the date of interest
;
;
;   CHANGED:  1)  Changed to accomodate different operating systems [08/18/2008   v1.0.2]
;             2)  Changed 'man' page                                [09/15/2008   v1.0.3]
;             3)  Updated 'man' page                                [11/11/2008   v1.0.4]
;             4)  Fixed syntax issue                                [05/04/2009   v1.0.5]
;             5)  Changed program my_str_names.pro to dat_3dp_str_names.pro
;                   and my_padspec_reader.pro to padspecs_reader.pro
;                   and my_clean_spikes_2.pro to clean_spec_spikes.pro
;                   and my_data_shift_2.pro to spec_vec_data_shift.pro
;                   and renamed from my_padspec_rw.pro              [08/12/2009   v2.0.0]
;
;   CREATED:  08/13/2008
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  08/12/2009   v2.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-


PRO padspecs_to_tplot,name,EBINS=ebins,TRANGE=trange,DATE=date

;*****************************************************************************************
ex_start = SYSTIME(1)
;*****************************************************************************************
mydate = my_str_date(DATE=date)
date   = mydate.S_DATE  ; -('MMDDYY')
mdate  = mydate.DATE    ; -('YYYYMMDD')
name  = STRLOWCASE(name)
;-----------------------------------------------------------------------------------------
; -Make sure name is in the correct format
;-----------------------------------------------------------------------------------------
strns = dat_3dp_str_names(name)
name  = strns.SN
pname = STRUPCASE(name)

pad_r = padspecs_reader(name,EBINS=ebins,TRANGE=trange,DATE=date)
newna = ''
newna = 'n'+name+'_pads'
shon  = ''
shon  = STRMID(newna,0,3)
store_data,newna,DATA=pad_r
mstr  = pad_r
mynpa = N_ELEMENTS(mstr.V2[0,*])

options,newna,'XMINOR',4    ; -set # of minor X-Tick marks to 4
options,newna,'YMINOR',9    ; -set # of minor Y-Tick marks to 9
options,newna,'YSTYLE',1
options,newna,'LABELS',mstr.LABELS
mylabs = mstr.LABELS
;-----------------------------------------------------------------------------------------
; -Make sure y-limits are not determined by "zeroed" data or NAN's
;-----------------------------------------------------------------------------------------
gy11 = WHERE(mstr.y GT 0.0 AND FINITE(mstr.y),g11)
IF (g11 GT 0) THEN BEGIN
  gyind1 = ARRAY_INDICES(mstr.y,gy11)
  ymin1  = MIN(mstr.y[gyind1[0,*],gyind1[1,*],gyind1[2,*]],/NAN)/1.1
  ymax1  = MAX(mstr.y[gyind1[0,*],gyind1[1,*],gyind1[2,*]],/NAN)*1.1
  ylim, newna,ymin1,ymax1,1
ENDIF
;-----------------------------------------------------------------------------------------
; -Determine # of data points to smooth over when "cleaning" data spikes
;-----------------------------------------------------------------------------------------
mysip = (SIZE(mstr.y,/DIMENSIONS))[0]/800L
IF (mysip GT 3L AND mysip LE 12L) THEN BEGIN
  hsmooth = mysip + 1L
  lsmooth = LONG(3./5.*hsmooth)
ENDIF ELSE BEGIN
  IF (mysip GT 12L) THEN BEGIN
    CASE shon OF
      'nsf' : BEGIN
        hsmooth = 20L
        lsmooth = 12L
      END
      'nso' : BEGIN
        hsmooth = 20L
        lsmooth = 12L
      END
      'nel' : BEGIN
        hsmooth = 10L
        lsmooth = 5L
      END
      'neh' : BEGIN
        hsmooth = 12L
        lsmooth = 7L
      END
      'nph' : BEGIN  ; -often noisy...
        hsmooth = 20L
        lsmooth = 15L
      END
      'npl' : BEGIN  ; -often noisy...
        hsmooth = 20L
        lsmooth = 15L
      END
      ELSE  : BEGIN
        hsmooth = 12L
        lsmooth = 7L
      END
    ENDCASE
  ENDIF ELSE BEGIN
    hsmooth = 3L
    lsmooth = 3L
  ENDELSE
ENDELSE
;-----------------------------------------------------------------------------------------
; -Created a normalized spectrum to observe relative changes in flux
;-----------------------------------------------------------------------------------------
mysmp  = [0,2,hsmooth]   ; -weighted smoothing parameters for cleaning program
mysnp  = lsmooth 
newna2 = newna
CASE shon OF
  'nsf' : BEGIN
    options, newna, 'LABFLAG',-1
    clean_spec_spikes,newna2,NSMOOTH=mysnp,ESMOOTH=mysmp,NEW_NAME=newna2+'_cln'
    spec_vec_data_shift,newna2+'_cln',NEW_NAME=newna2+'_cln_sh_n',/DATN
  END
  'nso' : BEGIN
    options, newna, 'LABFLAG',-1
    clean_spec_spikes,newna2,NSMOOTH=mysnp,ESMOOTH=mysmp,NEW_NAME=newna2+'_cln'
    spec_vec_data_shift,newna2+'_cln',NEW_NAME=newna2+'_cln_sh_n',/DATN
  END
  'nel' : BEGIN
    IF (STRMID(newna,0,4) EQ 'nelb') THEN BEGIN
      options, newna, 'LABFLAG',1
      hsmooth = 2
      lsmooth = 2
      mysmp = [0,2,hsmooth]
      mysnp = lsmooth          ; -base smoothing step " "        
      spec_vec_data_shift,newna2,new_name=newna2+'_sh_n',/datn
    ENDIF ELSE BEGIN
      options, newna, 'LABFLAG',1
      clean_spec_spikes,newna2,NSMOOTH=mysnp,ESMOOTH=mysmp,NEW_NAME=newna2+'_cln'
      spec_vec_data_shift,newna2,NEW_NAME=newna2+'_cln_sh_n',/DATN
    ENDELSE
  END  
  ELSE : BEGIN
    options, newna, 'LABFLAG',1
    clean_spec_spikes,newna2,NSMOOTH=mysnp,ESMOOTH=mysmp,NEW_NAME=newna2+'_cln'
    spec_vec_data_shift,newna2+'_cln',NEW_NAME=newna2+'_cln_sh_n',/datn
  END
ENDCASE
;-----------------------------------------------------------------------------------------
; -separate PADs by angle w/ respect to B-field direction (deg)
;-----------------------------------------------------------------------------------------
ang = FLTARR(2,mynpa-1L)

FOR i=0, mynpa-2L DO BEGIN
  j = i+1
  pang = FLTARR(2)
  reduce_pads,newna,2,i,j,ANGLES=pang,/NAN
  ang[*,i] = pang
ENDFOR
myangs = STRARR(mynpa-1L)
myangs = STRTRIM(STRING(format='(F5.1)',ang[0,*]),1) $
         +'-'+STRTRIM(STRING(format='(F5.1)',ang[1,*]),1)+'!Uo!N'

zdata  = z_pads_2(newna,LABS=mylabs,PANGS=myangs)
;-----------------------------------------------------------------------------------------
; -Created a normalized spectrum for each PAD-Spectra to observe relative changes in flux
;-----------------------------------------------------------------------------------------
CASE shon OF
  'nel' : BEGIN
    IF (STRMID(newna,0,4) EQ 'nelb') THEN BEGIN
      FOR i=0, mynpa-2L DO BEGIN
        tdata = zdata[i]
        tangl = myangs[i]
        options,tdata,'YTITLE',pname+'!C'+tangl
        spec_vec_data_shift,tdata,/DATN,NEW_NAME=tdata+'_sh_n'
        options,tdata+'_sh_n','YTITLE',pname+' Normalized & Shifted'+'!C'+tangl
      ENDFOR
    ENDIF ELSE BEGIN
      FOR i=0, mynpa-2L DO BEGIN
        tdata = zdata[i]
        tangl = myangs[i]
        options,tdata,'YTITLE',pname+'!C'+tangl
        clean_spec_spikes,tdata,NSMOOTH=mysnp,ESMOOTH=mysmp,NEW_NAME=tdata+'_cln'
        spec_vec_data_shift,tdata,/DATN,NEW_NAME=tdata+'_cln_sh_n'
        options,tdata+'_cln_sh_n','YTITLE',pname+' Normalized & Shifted'+'!C'+tangl
      ENDFOR
    ENDELSE
  END
  ELSE : BEGIN  
    FOR i=0, mynpa-2L DO BEGIN
      tdata = zdata[i]
      tangl = myangs[i]
      options,tdata,'YTITLE',pname+'!C'+tangl
      clean_spec_spikes,tdata,NSMOOTH=mysnp,ESMOOTH=mysmp,NEW_NAME=tdata+'_cln'
      spec_vec_data_shift,tdata+'_cln',/DATN,NEW_NAME=tdata+'_cln_sh_n'
      options,tdata+'_cln_sh_n','YTITLE',pname+' Normalized & Shifted'+'!C'+tangl
    ENDFOR
  END
ENDCASE

td_names = tnames('*_pads-*')
options,td_names,'YMINOR',9
options,td_names,'XMINOR',5    ; -set # of minor X-Tick marks to 5
options,td_names,'YSTYLE',1

IF (!VERSION.OS_NAME EQ 'Mac OS X') THEN BEGIN
  LOADCT,39
  DEVICE,DECOMPOSED=0
ENDIF
;*****************************************************************************************
ex_time = SYSTIME(1) - ex_start
MESSAGE,STRING(ex_time)+' seconds execution time.',/INFORMATIONAL,/CONTINUE
;*****************************************************************************************
END
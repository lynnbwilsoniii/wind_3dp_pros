;+
;*****************************************************************************************
;
;  FUNCTION :   plot3d.pro
;  PURPOSE  :   Creates a series of 3D Map projections (one for each energy step) of the
;                 data structure given by user.
;
;  CALLED BY:   NA
;
;  CALLS:
;               plot3d_com.pro
;               plot3d_options.pro
;               dat_3dp_str_names.pro
;               dat_3dp_energy_bins.pro
;               wind_3dp_units.pro
;               pesa_high_bad_bins.pro
;               sst_foil_bad_bins.pro
;               convert_ph_units.pro
;               conv_units.pro
;               str_element.pro
;               xyz_to_polar.pro
;               dimen1.pro
;               make_3dmap.pro
;               minmax.pro
;               colinear_test.pro
;               bytescale.pro
;               smooth_periodic.pro
;               ndimen.pro
;               time_stamp.pro
;               draw_color_scale.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               DAT        :  A 3DP data structure
;               LATITUDE   :  The latitude of the center of the plot (semi-optional)
;               LONGITUDE  :  The longitude of the center of the plot (semi-optional)
;
;  EXAMPLES:
;               => To plot in Distribution Function units with center along anti-B-Dir.
;               plot3d,dat,BNCENTER=-1,EBINS=LINDGEN(12L),UNITS='df'
;
;  KEYWORDS:  
;               BINS        :  N-Element array of indices defining the data bins to use
;                                for auto-scaling the Z-Range of the plot
;               TBINS       :  Bin totals ??
;               BNCENTER    :  If < 0, latitude,longitude are set so -B direction at
;                                center of plot;  If > 0, then +B at center
;               LABELS      :  If set, alters color labels ??
;               SMOOTH      :  If set, program attempts to smooth over edges by resizing
;                                the data array and rebining the data
;                                [0 = none, 2 is typical]
;               EBINS       :   Energy bins to use [2-Element array corresponding to
;                                first and last energy bin element or an array of 
;                                energy bin elements]
;               SUM_EBINS   :  Specifies how many bins to sum, starting with EBINS.  If
;                                SUM_EBINS is a scaler, that number of bins is summed for
;                                each bin in EBINS.  If SUM_EBINS is an array, then each
;                                array element will hold the number of bins to sum
;                                starting at each bin in EBINS.  In the array case,
;                                EBINS and SUM_EBINS  must have the same number
;                                of elements.
;               PTLIMIT     :  Set to a named variable for returning the plot limits
;                                of the 3D maps
;               PTMAP       :  Set to a 2D array defining the 3D map from the theta's
;                                and phi's of the original data structure
;               MAPNAME     :  One of the following strings: 
;                                'mol', 'cyl', 'ort', 'ait', 'ham','gno', or 'mer'
;                                [See MAP_SET.PRO syntax for more]
;               UNITS       :  [String] Units for data to be plotted in
;                                [Default = 'eflux' or energy flux]
;               SETLIM      :  If set, the program calculates the plot limits of the 
;                                3D maps and returns the limits in the keyword
;                                PTLIMIT
;               PROC3D      :  Set to the name of another program to use for plotting
;                                3D maps of the data
;               ZRANGE      :  2-Element array defining the range of the data values
;               ZERO        :  If set, forces min range of data to zero
;               TITLE       :  String used to override default plot title
;               NOTITLE     :  If set, no plot title is created
;               NOCOLORBAR  :  If set, no color bar is produced
;               NOBORDER    :  If set, supresses the plot border
;               SPIKES      :  If set, tells program to look for data spikes
;                                and eliminate them [Specifically for Eesa High Dists.]
;               ONE_ZRA     :  If set, all maps are set to the same overall data range
;                                [By default, program ranges color bar by overall data
;                                 range, but each plot is scaled to the data in ONLY 
;                                 that plot]
;               EX_VEC      :  3-Element array of an extra vector to output onto the 3D
;                                projection map
;               STACK       :  Set to a 2-Element array defining the 
;                                [# of columns, # of rows] to plot  
;                                {Controls => !P.MULTI[1:2]}
;               ROW_MAJOR   :  If set, the program plots top to bottom, left to right
;                                {Controls => !P.MULTI[4]}
;               NOERASE     :  If set, program will NOT erase plots already existing
;                                in the current window set
;                                {Controls => !P.MULTI[0]}
;               KILL_SMGF   :  If set, not only are the "bad" bins removed from the
;                                SST Foil data structures, the bins with small
;                                geometry factors are removed too 
;                                (see sst_foil_bad_bins.pro)
;
;   CHANGED:  1)  Davin Larson changed something...       [04/17/2002   v1.0.43]
;             2)  Altered a few minor things              [03/11/2008   v1.0.44]
;             3)  Re-wrote and cleaned up                 [03/21/2009   v1.1.0]
;             3)  Fixed a syntax error                    [03/22/2009   v1.1.1]
;             4)  Fixed triangulation issue               [03/22/2009   v1.1.2]
;             5)  Added keyword: SPIKES and program my_str_names.pro
;                                                         [03/22/2009   v1.2.0]
;             6)  Re-wrote program draw_color_scale.pro
;                                                         [03/22/2009   v1.2.1]
;             7)  Updated man page                        [06/21/2009   v1.2.2]
;             8)  Changed program my_3dp_energy_bins.pro to dat_3dp_energy_bins.pro
;                   and my_str_names.pro to dat_3dp_str_names.pro
;                                                         [08/05/2009   v1.3.0]
;             9)  Fixed a syntax error and changed unit conversion for
;                   Pesa High dists.                      [08/31/2009   v1.3.1]
;            10)  Changed X-Margin in plotting routine    
;                   and changed plot titles a little      [09/03/2009   v1.3.2]
;            11)  Added keyword:  ONE_ZRA                 [09/03/2009   v1.4.0]
;            12)  Changed font sizes and X-Margins        [09/24/2009   v1.4.1]
;            13)  Changed functionality of ONE_ZRA and ZRANGE
;                   and fixed missing assignment of ZRANGE_3D from plot3d_com.pro
;                                                         [09/25/2009   v1.4.2]
;            14)  Changed handling of UNITS keyword
;                   and added program:  wind_3dp_units.pro
;                                                         [09/25/2009   v1.5.0]
;            15)  Added keyword:  EX_VEC
;                   and fixed neglected issue with ZRANGE [09/26/2009   v1.6.0]
;            16)  Added program:  sst_foil_bad_bins.pro   [02/13/2010   v1.7.0]
;            17)  Added keyword:  KILL_SMGF               [02/25/2010   v1.8.0]
;            18)  Added error checking for co-linear error in TRIANGULATE.PRO
;                   with program colinear_test.pro [not finished yet...]
;                                                         [03/22/2010   v1.8.1]
;            19)  Fixed issue of plotting sun direction if VSW structure tag set to
;                   REPLICATE(!VALUES.F_NAN,3)            [11/01/2010   v1.8.2]
;            20)  Fixed issue with SUM_EBINS keyword when set not equal to 1
;                                                         [12/07/2011   v1.8.3]
;            21)  Changed auto Z-range calculation        [01/12/2012   v1.8.4]
;
;   NOTES:      
;               1)  By default, program ranges color bar by overall data range,
;                     but each plot is scaled to the data in ONLY that plot.  Each
;                     will change its title if ONE_ZRA not set to allow the user to
;                     determine the relative scale versus the color bar scale.
;               2)  Prior to running program, it is useful to use the following options:
;                    ..........................................................
;                    :plot3d_options,MAP='ham',LOG =1,TRIANGULATE=1,COMPRESS=1:
;                    ..........................................................
;               3)  If sending in Pesa High or SST Foil data structures, don't alter
;                     them prior to input
;
;   CREATED:  ??/??/????
;   CREATED BY:  Davin Larson
;    LAST MODIFIED:  01/12/2012   v1.8.4
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

PRO plot3d,tbindata,latitude,longitude,                                      $
           BINS=bins,TBINS=tbins,BNCENTER=bncenter,LABELS=labs,SMOOTH=smoth, $
           EBINS=eb,SUM_EBINS=seb,PTLIMIT=plot_limits,PTMAP=ptmap,           $
           MAPNAME=mapname,UNITS=units,SETLIM=setlim,PROC3D=proc3d,          $
           TITLE=title,NOTITLE=notitle,NOCOLORBAR=nocolorbar,                $
           NOBORDER=noborder,SPIKES=spikes,ONE_ZRA=one_zra,EX_VEC=ex_vec,    $
           ZRANGE=zrange,ZERO=zero,                                          $
           STACK=stack,ROW_MAJOR=row_major,NOERASE=noerase,KILL_SMGF=kill_smgf

;-----------------------------------------------------------------------------------------
; -Set default options
;-----------------------------------------------------------------------------------------
@plot3d_com.pro
plot3d_options
;-----------------------------------------------------------------------------------------
; -Make sure structure is good
;-----------------------------------------------------------------------------------------
IF (tbindata.VALID EQ 0) THEN BEGIN
  PRINT,'Invalid data'
  RETURN
ENDIF
strn   = dat_3dp_str_names(tbindata)
shname = strn.SN   ; -Short detector name (e.g. 'el','elb','eh','sf', etc.)
shntr  = STRMID(shname,0L,2L)
CASE shntr OF
  'eh' : BEGIN
    IF NOT KEYWORD_SET(spikes) THEN spikes = 1
  END
  ELSE : IF NOT KEYWORD_SET(spikes) THEN spikes = 0
ENDCASE
;-----------------------------------------------------------------------------------------
; -Determine  how to deal with energy bins
;-----------------------------------------------------------------------------------------
f     = !VALUES.F_NAN
d     = !VALUES.D_NAN
n_e   = tbindata.NENERGY
nbins = tbindata.NBINS
IF KEYWORD_SET(eb) THEN eb = eb ELSE eb = [0L,n_e - 1L]
my_ens = dat_3dp_energy_bins(tbindata,EBINS=eb)
estart = my_ens.E_BINS[0]      ; -Lowest energy array element
eend   = my_ens.E_BINS[1]      ; -Highest " "
myen   = my_ens.ALL_ENERGIES   ; -Energy values (eV) for this particular 3D dist.
diffen = eend - estart + 1L
mebins = INTARR(diffen)
FOR i = 0, diffen - 1L DO BEGIN
  j = i + estart
  mebins[i] = j
ENDFOR
IF (KEYWORD_SET(seb) EQ 0) THEN BEGIN
  seb = 1
ENDIF ELSE BEGIN
  IF (N_ELEMENTS(seb) GT 1 AND (N_ELEMENTS(seb) NE N_ELEMENTS(eb))) THEN BEGIN
    MESSAGE,'If SUM_EBINS is an array, it must have same dimensions'+ $
            ' as EBINS.',/INFORMATIONAL,/CONTINUE
    PRINT,'Using default = 1'
    seb = 1
  ENDIF
ENDELSE
start = mebins
;s_top = start + seb - 1
;  LBW III  12/07/2011
s_top = (start + seb - 1L) < (n_e - 1L)
;-----------------------------------------------------------------------------------------
; => Define the units to use
;-----------------------------------------------------------------------------------------
IF NOT KEYWORD_SET(units)  THEN gunits = 'eflux' ELSE gunits = STRLOWCASE(units[0])
new_units = wind_3dp_units(gunits)
units     = new_units.G_UNIT_NAME[0]       ; => e.g. 'flux'
myunits   = units+new_units.G_UNIT_P_NAME  ; => e.g. 'flux (# cm!U-2!Ns!U-1!Nsr!U-1!NeV!U-1!N)'
;-----------------------------------------------------------------------------------------
; => Convert units and create a string for the Z-Title label
;-----------------------------------------------------------------------------------------
CASE shntr[0] OF
  'ph' : BEGIN
    bindata = tbindata
    pesa_high_bad_bins,bindata        ; => Remove data glitch if necessary in PH data
    convert_ph_units,bindata,units,SCALE=scale
;    bindata = conv_units(tbindata,units)
  END
  'sf' : BEGIN
    bindata = tbindata
    sst_foil_bad_bins,bindata,KILL_SMGF=kill_smgf  ; => Remove "bad" data if necessary in SF data
    convert_sf_units,bindata,units
  END
  ELSE : bindata = conv_units(tbindata,units)
ENDCASE
;-----------------------------------------------------------------------------------------
; => Determine if any data is negative
;-----------------------------------------------------------------------------------------
bad = WHERE(bindata.DATA LE 0.,bd,COMPLEMENT=good,NCOMPLEMENT=gd)
IF (bd GT 0) THEN BEGIN
  bind = ARRAY_INDICES(bindata.DATA,bad)
  bindata.DATA[bind[0,*],bind[1,*]] = f
;  IF (shntr[0] EQ 'so') THEN BEGIN
    temp = SMOOTH(bindata.DATA,3L,/EDGE_TRUNCATE,/NAN)
    bad  = WHERE(temp LE 0.,bd,COMPLEMENT=good,NCOMPLEMENT=gd)
    IF (bd GT 0) THEN BEGIN
      bind = ARRAY_INDICES(temp,bad)
      temp[bind[0,*],bind[1,*]] = f
    ENDIF
    bindata.DATA = temp
;  ENDIF
ENDIF ELSE BEGIN
  temp = SMOOTH(bindata.DATA,3L,/EDGE_TRUNCATE,/NAN)
  bad  = WHERE(temp LE 0.,bd,COMPLEMENT=good,NCOMPLEMENT=gd)
  IF (bd GT 0) THEN BEGIN
    bind = ARRAY_INDICES(temp,bad)
    temp[bind[0,*],bind[1,*]] = f
  ENDIF
  bindata.DATA = temp
ENDELSE
;-----------------------------------------------------------------------------------------
; -Get magnetic field and solar wind direction
;-----------------------------------------------------------------------------------------
str_element,bindata,'MAGF',VALUE=magf
str_element,bindata,'VSW' ,VALUE=vsw
IF KEYWORD_SET(magf) THEN BEGIN
   xyz_to_polar,magf,THETA=th,PHI=phi
   bdir = [th,phi]
ENDIF

IF (N_ELEMENTS(latitude)  EQ 0) THEN latitude  = latitude_3d
IF (N_ELEMENTS(longitude) EQ 0) THEN longitude = longitude_3d
IF (N_ELEMENTS(smoth)     EQ 0) THEN smoth     = smooth_3d
;-----------------------------------------------------------------------------------------
; -Determine Latitude and Longitude if not already done
;-----------------------------------------------------------------------------------------
IF (KEYWORD_SET(bncenter) AND N_ELEMENTS(bdir) EQ 2) THEN BEGIN
   latitude  = bdir[0]
   longitude = bdir[1]
   IF (bncenter LT 0) THEN BEGIN
      latitude  = - latitude
      longitude = longitude + 180
   ENDIF
ENDIF
;-----------------------------------------------------------------------------------------
; -Determine which data bins to use
;-----------------------------------------------------------------------------------------
IF (KEYWORD_SET(bins) EQ 0) THEN str_element,bindata,'BINS',bins

IF (N_ELEMENTS(bins) EQ (nbins*n_e)) THEN BEGIN
  IF (N_ELEMENTS(tbins) NE nbins) THEN tbins = TOTAL(bins,1) GT 0
  bins = TOTAL(bins,2) GT 0
  binsindx = WHERE(tbins EQ 0,binscnt)
  IF (binscnt EQ 0) THEN tbins = 0
  binsindx = WHERE(bins EQ 0,binscnt)
  IF (binscnt EQ 0) THEN bins = 0
ENDIF

IF (N_ELEMENTS(bins) NE nbins) THEN bins = REPLICATE(1,nbins)
goodbins = WHERE(bins,ngood)
badbins  = WHERE(bins EQ 0,nbad)
IF (nbad NE 0) THEN bindata.DATA[*,badbins] = !VALUES.F_NAN
triang = KEYWORD_SET(triang_3d)
;-----------------------------------------------------------------------------------------
; -Deal with data spikes if possible
;-----------------------------------------------------------------------------------------
newd = bindata.DATA
IF KEYWORD_SET(spikes) THEN BEGIN
  avdata = TOTAL(newd,2,/NAN)/ TOTAL(FINITE(newd),2,/NAN)  ; -Avg. Data per energy bin
  FOR jj=0L, n_e - 1L DO BEGIN
    bdd = WHERE(newd[jj,*] GT avdata[jj],bd,COMPLEMENT=gdd,NCOMPLEMENT=gd)
    IF (bd GT 0L AND gd GT 0L) THEN BEGIN
      n_mean  = TOTAL(newd[jj,gdd],2,/NAN)/ TOTAL(FINITE(newd[jj,gdd]),2,/NAN)
      n_ratio = (n_mean/avdata[jj])*1e2   ; -If >1 => no spikes
      IF (n_ratio LT 1e0) THEN newd[jj,bdd] = !VALUES.F_NAN
    ENDIF
  ENDFOR
ENDIF
bindata.DATA = newd
;-----------------------------------------------------------------------------------------
; -Determine 3D plot map from the theta's and phi's of the plot structure
;-----------------------------------------------------------------------------------------
IF NOT KEYWORD_SET(ptmap) THEN BEGIN
  str_element,bindata,'MAP',VALUE=ptmap
ENDIF ELSE BEGIN
  ptmap = ptmap
ENDELSE

IF (triang EQ 0) THEN BEGIN
  IF (KEYWORD_SET(ptmap)) THEN BEGIN
    np = dimen1(ptmap)
    ptmap = ROTATE(ptmap,7)  ; this line and the next should be removed when
    ptmap = ROTATE(ptmap,5)  ; the c-code is fixed
    ptmap = REVERSE(ptmap,2) ; assumes !order = 0
    MESSAGE,'Using supplied mapping',/INFORMATIONAL,/CONTINUE
  ENDIF ELSE BEGIN
    ptmap = make_3dmap(bindata,64,32) 
    ptmap = SHIFT(ptmap,32,0)  ; map routine expects phi: -180 to 180
  ENDELSE
ENDIF
;-----------------------------------------------------------------------------------------
; -Determine the number of plots and their locations
;-----------------------------------------------------------------------------------------
;n_p = dimen1(start)  ; number of plots
n_p = N_ELEMENTS(mebins)

stacking = [ [1,1],   [1,1],   [1,2],   [2,2],   [2,2],   [2,3],   [2,3],           $
             [3,3],   [3,3],   [3,3],   [3,4],   [3,4],   [3,4],   [3,5],   [3,5],  $
             [3,5],   [4,4],   [4,5],   [4,5],   [4,5],   [4,5],   [5,5],   [5,5],  $
             [5,5],   [5,5],   [5,5],   [5,6],   [5,6],   [5,6],   [5,6],   [5,6],  $
             [6,6],   [6,6],   [6,6],   [6,6],   [6,6],   [6,6],   [6,7],   [6,7],  $
             [6,7],   [6,7],   [6,7],   [6,7],   [7,7],   [7,7],   [7,7],   [7,7],  $
             [7,7],   [7,7],   [7,7],   [7,8],   [7,8],   [7,8],   [7,8],   [7,8],  $
             [7,8],   [7,8],   [8,8],   [8,8],   [8,8],   [8,8],   [8,8],   [8,8],  $
             [8,8],   [8,8]]

IF (N_ELEMENTS(stack) NE 2) THEN stack = stacking[*,n_p]
IF NOT KEYWORD_SET(noerase)   THEN noerase   = 0 ELSE noerase   = 1
IF NOT KEYWORD_SET(row_major) THEN row_major = 0 ELSE row_major = 1
!P.MULTI = [noerase,stack[0],stack[1],0,row_major]
!P.CHARSIZE = 1.0

IF (!P.CHARSIZE NE 0) THEN charsize = !P.CHARSIZE ELSE charsize = 1.0

IF (STRLOWCASE(!D.NAME) EQ 'ps') THEN BEGIN
  !X.OMARGIN = [0,5]
  !Y.OMARGIN = [4,4]
  charsize   = 0.9
ENDIF ELSE BEGIN
  !X.OMARGIN = [2,14]
  !Y.OMARGIN = [2,4]
ENDELSE
IF (!P.MULTI[1] GT 2 OR !P.MULTI[2] GT 2) THEN BEGIN
   !Y.OMARGIN = !Y.OMARGIN * 2
   !X.OMARGIN = !X.OMARGIN * 4
ENDIF
xposmax = 0.
yposmax = 0.
yposmin = 1.

; => Determine max range of data
mxrange    = [0.0,0.0]
FOR plot_num=0L, n_p - 1L DO BEGIN
  e1         = start[plot_num]           ; => Start index
  e2         = s_top[plot_num]           ; => End index
  data       = TOTAL(bindata.DATA[e1:e2,*],1,/NAN)  ; Sum over energies
  test_range = minmax(data,/POS)
  mxrange[1] = mxrange[1] > test_range[1]*1.05
  IF (plot_num EQ 0) THEN mxrange[0] = test_range[0]/1.05
  mxrange[0] = mxrange[0] < test_range[0]/1.05
ENDFOR

IF KEYWORD_SET(zrange) THEN mxrange = REFORM(zrange)
;mxrange    = minmax(bindata.DATA,/POS)
avgdata    = MEAN(bindata.DATA,/NAN)
;ss = 1
;WHILE(ss) DO BEGIN
;  mxrtest    = (mxrange[0]/avgdata)*1d2 LT 1d-1
;  IF (mxrtest) THEN ss = 1 ELSE ss = 0
;  IF (ss) THEN mxrange[0] *= 1d2
;ENDWHILE
;-----------------------------------------------------------------------------------------
; -Plot data
;-----------------------------------------------------------------------------------------
FOR plot_num = 0L, n_p - 1L DO BEGIN
  e1      = start[plot_num]           ; => Start index
  en1     = myen[e1]                  ; => Start energy
  e2      = s_top[plot_num]           ; => End index
  en2     = myen[e2]                  ; => End energy
  nsteps  = e2 - e1 + 1L
  myform  = '(f8.1)'
  en_tes1 = (en1 GT 1e3)
  en_tes2 = (en2 GT 1e3)
  IF (e1 NE e2) THEN BEGIN
    IF (en_tes1) THEN esuffx1 = ' keV' ELSE esuffx1 = ' eV'
    IF (en_tes2) THEN esuffx2 = ' keV' ELSE esuffx2 = ' eV'
    IF (en_tes1) THEN fac1 = 1e-3 ELSE fac1 = 1e0      ; => Change to keV
    IF (en_tes2) THEN fac2 = 1e-3 ELSE fac2 = 1e0      ; => Change to keV
    ttl  = STRTRIM(STRING(FORMAT=myform,en1*fac1),2)+esuffx1
    ttl += ' - '+STRTRIM(STRING(FORMAT=myform,en2*fac2),2)+esuffx2
  ENDIF ELSE BEGIN
    IF (en_tes1) THEN esuffx1 = ' keV' ELSE esuffx1 = ' eV'
    IF (en_tes1) THEN fac1 = 1e-3 ELSE fac1 = 1e0      ; => Change to keV
    ttl  = STRTRIM(STRING(FORMAT=myform,en1*fac1),2)+esuffx1
  ENDELSE
  ;---------------------------------------------------------------------------------------
  ; -If setlim set, use to set up plot limits and map
  ;---------------------------------------------------------------------------------------
  IF NOT KEYWORD_SET(mapname) THEN BEGIN
    mapname = STRLOWCASE(STRMID(mapname_3d,0L,3L))
  ENDIF
  IF KEYWORD_SET(setlim) THEN BEGIN
    MAP_SET,latitude,longitude,0.,/WHOLE_MAP,/NOERASE,LIMIT=plot_limits, $
            TITLE=ttl,CHARSIZE=charsize,XMARGIN=[1,1],YMARGIN=[1,1],     $
            NOBORDER=noborder,                                           $
            MOLL    = mapname EQ 'mol' ,                                 $
            CYLIN   = mapname EQ 'cyl' ,                                 $
            ORTHO   = mapname EQ 'ort' ,                                 $
            AITOFF  = mapname EQ 'ait' ,                                 $
            LAMBERT = mapname EQ 'lam' ,                                 $
            HAMMER  = mapname EQ 'ham' ,                                 $
            GNOMIC  = mapname EQ 'gno' ,                                 $
            MERCATO = mapname EQ 'mer'
    RETURN
  ENDIF
  ;---------------------------------------------------------------------------------------
  ; -Sum over energies (if applicable) and determine the data range
  ;---------------------------------------------------------------------------------------
  data = TOTAL(bindata.DATA[e1:e2,*],1,/NAN)
  IF (KEYWORD_SET(zrange) OR KEYWORD_SET(one_zra)) THEN BEGIN
    IF KEYWORD_SET(one_zra) THEN range = mxrange ELSE range = REFORM(zrange)
  ENDIF ELSE BEGIN
    tz_range = minmax(data[goodbins],/POS)
    range    = tz_range*[1./1.1,1.15]
  ENDELSE
  ; -Adjust labels
  IF (range[1] LT mxrange[1]) THEN BEGIN
    nforms     = '(G15.3)'
    nfact0     = STRTRIM(STRING(FORMAT=nforms,range[1]/mxrange[0]*1d2),2)
    nfact      = STRMID(nfact0[*],0L,4L)+'x10!U'+STRMID(nfact0[*],5L)+'!N'
    str_range  = '!C'+'['+nfact+' above Min]'
;    str_range  = 'A Max factor of '+nfact+'!C'
;    str_range += ' above Min Range'
;    ttl       += ' '+str_range
  ENDIF
  ;---------------------------------------------------------------------------------------
  ; -If triang set, then use spherical triangulation
  ;---------------------------------------------------------------------------------------
  IF KEYWORD_SET(triang) THEN BEGIN
    theta = TOTAL(bindata.THETA[e1:e2,*],1,/NAN)/nsteps
    phi   = TOTAL(bindata.PHI[e1:e2,*],1,/NAN)/nsteps
    IF KEYWORD_SET(tbins) THEN BEGIN
      ind = WHERE(tbins NE 0)
    ENDIF ELSE BEGIN
      ind = WHERE(FINITE(theta) AND FINITE(phi))
    ENDELSE
    IF (ind[0] EQ -1) THEN GOTO, contu
    data   = data[ind]
    theta  = theta[ind]
    phi    = phi[ind]
    unqphi = UNIQ(phi,SORT(phi))
    unqthe = UNIQ(theta,SORT(theta))
    CASE shntr[0] OF
      'so'  : l_param = 5L
      'sf'  : l_param = 5L
      'ph'  : l_param = 5L
      ELSE  : l_param = 7L
    ENDCASE
    nphiuq = N_ELEMENTS(unqphi) LT l_param
    ntheuq = N_ELEMENTS(unqthe) LT l_param
    IF (nphiuq OR ntheuq) THEN BEGIN   ; => Not enough points to triangulate data
      image = REPLICATE(1,360,180)     ; => set to background level
    ENDIF ELSE BEGIN
;      test = colinear_test(REPLICATE(1d0,N_ELEMENTS(phi)),phi,theta,/SPHERE)
;      test = colinear_test(data,phi,theta,/SPHERE)
;      IF (test EQ 0) THEN BEGIN
        TRIANGULATE,phi,theta,FVALUE=data,SPHERE=sphere,/DEGREES
        timage = TRIGRID(data,SPHERE=sphere,[2.,2.],[-180.,-90.,178.,90.],/DEGREES)
;      ENDIF ELSE BEGIN
;        timage = REPLICATE(d,180L,91L)
;      ENDELSE
;      TRIANGULATE,phi,theta,FVALUE=data,SPHERE=sphere,/DEGREES
;      timage = TRIGRID(data,SPHERE=sphere,[2.,2.],[-180.,-90.,178.,90.],/DEGREES)
;      image  = bytescale(timage,LOG=logscale_3d,RANGE=mxrange,ZERO=zero)
      image  = bytescale(timage,LOG=logscale_3d,RANGE=range,ZERO=zero)
    ENDELSE
  ENDIF ELSE BEGIN
    data = [!VALUES.F_NAN,data]
    data = data[ptmap + 1]
    IF KEYWORD_SET(smoth) THEN BEGIN
      dims  = dimen(data)*smoth
      data  = REBIN(data,dims[0],dims[1])
      data  = smooth_periodic(data,smoth)
    ENDIF
    timage = bytescale(data,LOG=logscale_3d,RANGE=range,ZERO=zero)
;    timage = bytescale(data,LOG=logscale_3d,RANGE=mxrange,ZERO=zero)
    image  = CONGRID(timage,360,180)
  ENDELSE
  IF NOT KEYWORD_SET(mapname) THEN BEGIN
    mapname = STRLOWCASE(STRMID(mapname_3d,0L,3L))
  ENDIF
  ;---------------------------------------------------------------------------------------
  ; -Set up 3D map projection
  ;---------------------------------------------------------------------------------------
  MAP_SET,latitude,longitude,0.,/WHOLE_MAP,/ADVANCE,LIMIT=plot_limits, $
          TITLE=ttl,CHARSIZE=charsize,XMARGIN=[1,1],YMARGIN=[1,1],     $
          NOBORDER=noborder,                                           $
          MOLL    = mapname EQ 'mol' ,                                 $
          CYLIN   = mapname EQ 'cyl' ,                                 $
          ORTHO   = mapname EQ 'ort' ,                                 $
          AITOFF  = mapname EQ 'ait' ,                                 $
          LAMBERT = mapname EQ 'lam' ,                                 $
          HAMMER  = mapname EQ 'ham' ,                                 $
          GNOMIC  = mapname EQ 'gno' ,                                 $
          MERCATO = mapname EQ 'mer'
  ;---------------------------------------------------------------------------------------
  ; -Calculate projection and plot color image
  ;---------------------------------------------------------------------------------------
  !P.CHARSIZE = 1.2
  new = MAP_IMAGE(image,sx,sy,xsize,ysize,COMPRESS=compress_3d,BILINEAR=0)
  TV,new,sx,sy,XSIZE=xsize,YSIZE=ysize,ORDER=0
  !P.CHARTHICK = 2.0
  ;---------------------------------------------------------------------------------------
  ; -Plot labels for directional orientation
  ;---------------------------------------------------------------------------------------
  IF (N_ELEMENTS(bdir) EQ 2) THEN BEGIN
    PLOTS,bdir[1],bdir[0],PSYM=1,SYMSIZE=2.0           ; => Puts a + // to B-field
    PLOTS,bdir[1]+180.,-1.*bdir[0],PSYM=4,SYMSIZE=2.0  ; => Puts a diamond anti-// to B-field
  ENDIF
  IF (N_ELEMENTS(vsw) EQ 3 AND TOTAL(FINITE(vsw)) EQ 3) THEN BEGIN  ; => Puts a * // to Solar Wind Velocity
    xyz_to_polar,vsw,THETA=vth,PHI=vph
    PLOTS,vph,vth,PSYM=2
  ENDIF ELSE BEGIN  ; => Puts a * // to Sun Direction
;    xyz_to_polar,[-1.,0.,0.],THETA=vth,PHI=vph
;    PLOTS,vph,vth,PSYM=2
    PLOTS,179.99,0.,PSYM=2
  ENDELSE
  ; => If desired, put a triangle parallel to the extra vector defined by EX_VEC
  IF KEYWORD_SET(ex_vec) THEN BEGIN
    IF (N_ELEMENTS(REFORM(ex_vec)) EQ 3) THEN BEGIN
      xyz_to_polar,ex_vec,THETA=ex_th,PHI=ex_ph
      PLOTS,ex_ph,ex_th,PSYM=5
    ENDIF
  ENDIF
  !P.CHARTHICK = 1.0
  ;---------------------------------------------------------------------------------------
  ; -Project a grid onto plots
  ;---------------------------------------------------------------------------------------
  IF KEYWORD_SET(grid_3d) THEN MAP_GRID,LONDEL=grid_3d[0],LATDEL=grid_3d[1]
  str_element,opts,'PLOT3D_PROC',VALUE=proc3d
  str_element,bindata,'PLOT3D_PROC',VALUE=proc3d
  IF KEYWORD_SET(proc3d) THEN BEGIN
    proc = ''
    IF (ndimen(proc3d) EQ 0) THEN BEGIN
      proc = proc3d
    ENDIF ELSE BEGIN
      IF (plot_num LT N_ELEMENTS(proc3d)) THEN proc = proc3d[plot_num]
    ENDELSE
    IF KEYWORD_SET(proc) THEN CALL_PROCEDURE,proc,bindata,en2,plot_num
  ENDIF
  IF KEYWORD_SET(labs) THEN BEGIN
    lab       = STRCOMPRESS(INDGEN(nbins),/REMOVE_ALL)
    colorcode = [!P.BACKGROUND,!P.COLOR]
    XYOUTS,phi,theta,lab,ALIGN=0.5,COLOR=colorcode[bins]
  ENDIF
  IF (xposmax LT !X.WINDOW[1]) THEN xposmax = !X.WINDOW[1]
  IF (yposmax LT !Y.WINDOW[1]) THEN yposmax = !Y.WINDOW[1]
  IF (yposmin GT !Y.WINDOW[1]) THEN yposmin = !Y.WINDOW[0]
  ;=======================================================================================
  CONTU:
  ;=======================================================================================
ENDFOR
; => Reset !P.CHARSIZE
!P.CHARSIZE = charsize
;-----------------------------------------------------------------------------------------
; -Determine plot title and it's size relative to the plot itself
;-----------------------------------------------------------------------------------------
IF KEYWORD_SET(notitle) THEN BEGIN
  ttl = ''
ENDIF ELSE BEGIN
  IF NOT KEYWORD_SET(title) THEN BEGIN
    ttl  = bindata.PROJECT_NAME+'  '+bindata.DATA_NAME
    ttl += '!C'+ trange_str(bindata.TIME,bindata.END_TIME)
  ENDIF ELSE BEGIN
    ttl = title
  ENDELSE
ENDELSE
tcharsize   = 1.25 * charsize
titleheight = 1.0 - tcharsize * FLOAT(!D.Y_CH_SIZE)/!D.Y_SIZE
XYOUTS,0.5,titleheight,ttl,/NORMAL,ALIGNMENT=0.5,CHARSIZE=tcharsize
time_stamp  ; -Adds a time stamp for the date of creation

!P.MULTI   = 0
!Y.OMARGIN = 0
!X.OMARGIN = 0
;-----------------------------------------------------------------------------------------
; -Determine location and size of color bar
;-----------------------------------------------------------------------------------------
space      = charsize * FLOAT(!D.X_CH_SIZE)/!D.X_SIZE
pos        = [xposmax + space,yposmin,xposmax + 3*space,yposmax]
IF KEYWORD_SET(zrange) THEN mxrange = REFORM(zrange)
IF NOT KEYWORD_SET(nocolorbar) THEN BEGIN
  draw_color_scale,RANGE=mxrange,POS=pos,CHARS=charsize,TITLE=myunits
ENDIF

RETURN
END

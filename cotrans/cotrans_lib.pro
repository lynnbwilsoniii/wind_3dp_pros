;+
;pro sub_GSE2aGSM
;
;Purpose: transforms data from GSE to aberrated GSM coordinates
;
;
;keywords:
;   /aGSM2GSE : inverse transformation
;Example:
;      sub_GSE2aGSM,tha_fglc_gse,tha_fglc_agsm
;
;      sub_GSE2aGSM,tha_fglc_agsm,tha_fglc_gse,/aGSM2GSE
;
;
;Notes: Same as sub_GSE2GSM, with "aberrated GSM" in the output message. The actual aberration 
;       occurs in the higher level routine, gse2agsm
;
; $LastChangedBy: egrimes $
; $LastChangedDate: 2016-01-26 18:33:45 -0500 (Tue, 26 Jan 2016) $
; $LastChangedRevision: 19817 $
; $URL: svn+ssh://thmsvn@ambrosia.ssl.berkeley.edu/repos/spdsoft/trunk/general/cotrans/cotrans_lib.pro $
;-

pro sub_GSE2aGSM,data_in,data_out,aGSM2GSE=aGSM2GSE
    data_out=data_in
    
    ;convert the time
    timeS=time_struct(data_in.X)
    
    ;get direction
    if keyword_set(aGSM2GSE) then begin
        dprint,'aberrated GSM-->GSE'
        subGSM2GSE,TIMES,data_in.Y,DATA_outARR
    endif else begin
        dprint,'GSE-->aberrated GSM'
        subGSE2GSM,TIMES,data_in.Y,DATA_outARR
    endelse
    
    data_out.Y=DATA_outARR
    
    DPRINT,'done'
    
    ;RETURN,data_out
end

;+
;pro sub_GSE2GSM
;
;Purpose: transforms data from GSE to GSM
;
;
;keywords:
;   /GSM2GSE : inverse transformation
;Example:
;      sub_GSE2GSM,tha_fglc_gse,tha_fglc_gsm
;
;      sub_GSE2GSM,tha_fglc_gsm,tha_fglc_gse,/GSM2GSE
;
;
;Notes: under construction!!  will run faster in the near future!!
;
;Written by Hannes Schwarzl
; $LastChangedBy: egrimes $
; $LastChangedDate: 2016-01-26 18:33:45 -0500 (Tue, 26 Jan 2016) $
; $LastChangedRevision: 19817 $
; $URL: svn+ssh://thmsvn@ambrosia.ssl.berkeley.edu/repos/spdsoft/trunk/general/cotrans/cotrans_lib.pro $
;-
pro sub_GSE2GSM,data_in,data_out,GSM2GSE=GSM2GSE
    data_out=data_in
    
    ;convert the time
    timeS=time_struct(data_in.X)
    
    ;get direction
    if keyword_set(GSM2GSE) then begin
        dprint,'GSM-->GSE'
        isGSM2GSE=1
    endif else begin
        dprint,'GSE-->GSM'
        isGSM2GSE=0
    endelse
    
    if isGSM2GSE eq 0 then begin
        subGSE2GSM,TIMES,data_in.Y,DATA_outARR
    endif else begin
      subGSM2GSE,TIMES,data_in.Y,DATA_outARR
    endelse
    
    data_out.Y=DATA_outARR
    
    DPRINT,'done'
    
    ;RETURN,data_out
end

;#################################################

;+
;pro: sub_GEI2GSE
;
;Purpose: transforms THEMIS fluxgate magnetometer data from GEI to GSE
;
;
;keywords:
;   /GSE2GEI : inverse transformation
;Example:
;      sub_GEI2GSE,tha_fglc_gei,tha_fglc_gse
;
;      sub_GEI2GSE,tha_fglc_gse,tha_fglc_gei,/GSE2GEI
;
;
;Notes: under construction!!  will run faster in the near future!!
;
; $LastChangedBy: egrimes $
; $LastChangedDate: 2016-01-26 18:33:45 -0500 (Tue, 26 Jan 2016) $
; $LastChangedRevision: 19817 $
; $URL $
;-
pro sub_GEI2GSE,data_in,data_out,GSE2GEI=GSE2GEI
    data_out=data_in
    
    ;convert the time
    timeS=time_struct(data_in.X)
    
    ;get direction
    if keyword_set(GSE2GEI) then begin
    	DPRINT,'GSE-->GEI'
    	isGSE2GEI=1
    endif else begin
    	DPRINT,'GEI-->GSE'
    	isGSE2GEI=0
    endelse
    
    if isGSE2GEI eq 0 then begin
    	subGEI2GSE,TIMES,data_in.Y,DATA_outARR
    endif else begin
        subGSE2GEI,TIMES,data_in.Y,DATA_outARR
    endelse
    
    data_out.Y=DATA_outARR
    
    DPRINT,'done'
    
    ;RETURN,data_out
end

;+
;pro sub_GSM2SM
;
;Purpose: transforms data from GSM to SM
;
;
;keywords:
;   /SM2GSM : inverse transformation
;Example:
;      sub_GSM2SM,tha_fglc_gsm,tha_fglc_sm
;
;      sub_GSM2SM,tha_fglc_sm,tha_fglc_gsm,/SM2GSM
;
;
;Notes: under construction!!  will run faster in the near future!!
;
;Written by Hannes Schwarzl
; $LastChangedBy: egrimes $
; $LastChangedDate: 2016-01-26 18:33:45 -0500 (Tue, 26 Jan 2016) $
; $LastChangedRevision: 19817 $
; $URL: svn+ssh://thmsvn@ambrosia.ssl.berkeley.edu/repos/spdsoft/trunk/general/cotrans/cotrans_lib.pro $
;-
pro sub_GSM2SM,data_in,data_out,SM2GSM=SM2GSM
    data_out=data_in
    
    ;convert the time
    timeS=time_struct(data_in.X)
    
    ;get direction
    if keyword_set(SM2GSM) then begin
    	DPRINT,'SM-->GSM'
    	isSM2GSM=1
    endif else begin
    	DPRINT,'GSM-->SM'
    	isSM2GSM=0
    endelse
    
    if isSM2GSM eq 0 then begin
    	subGSM2SM,TIMES,data_in.Y,DATA_outARR
    endif else begin
        subSM2GSM,TIMES,data_in.Y,DATA_outARR
    endelse
    
    data_out.Y=DATA_outARR
    
    DPRINT,'done'
    
    ;RETURN,data_out
end

;+
;pro sub_GEI2GEO
;
;Purpose: transforms data from GEI to GEO
;
;
;keywords:
;   /GEO2GEI : inverse transformation
;Example:
;      sub_GEI2GEO,tha_fglc_gei,tha_fglc_geo
;
;      sub_GEI2GEO,tha_fglc_geo,tha_fglc_gei,/GEO2GEI
;
;
;Notes:
;
;Written by Patrick Cruce(pcruce@igpp.ucla.edu)
; $LastChangedBy: egrimes $
; $LastChangedDate: 2016-01-26 18:33:45 -0500 (Tue, 26 Jan 2016) $
; $LastChangedRevision: 19817 $
; $URL: svn+ssh://thmsvn@ambrosia.ssl.berkeley.edu/repos/spdsoft/trunk/general/cotrans/cotrans_lib.pro $
;-
pro sub_GEI2GEO,data_in,data_out,GEO2GEI=GEO2GEI
    data_out=data_in
    
    ;convert the time
    timeS=time_struct(data_in.X)
    
    ;get direction
    if keyword_set(GEO2GEI) then begin
    	dprint,'GEO-->GEI'
        subGEO2GEI,TIMES,data_in.Y,DATA_outARR
    endif else begin
    	dprint,'GEI-->GEO'
        subGEI2GEO,TIMES,data_in.Y,DATA_outARR
    endelse
    
    data_out.Y=DATA_outARR
    
    dprint,'done'
    
    ;RETURN,data_out
end

;+
;pro sub_GEO2MAG
;
;Purpose: transforms data from GEO to MAG
;
;
;keywords:
;   /MAG2GEO : inverse transformation
;Example:
;      sub_GEO2MAG,tha_fglc_geo,tha_fglc_mag
;
;      sub_GEO2MAG,tha_fglc_mag,tha_fglc_geo,/MAG2GEO
;
;
;Notes:
;
;Written by Cindy Russell(clrussell@igpp.ucla.edu)
; $LastChangedBy: egrimes $
; $LastChangedDate: 2016-01-26 18:33:45 -0500 (Tue, 26 Jan 2016) $
; $LastChangedRevision: 19817 $
; $URL: svn+ssh://thmsvn@ambrosia.ssl.berkeley.edu/repos/spdsoft/trunk/general/cotrans/cotrans_lib.pro $
;-
pro sub_GEO2MAG,data_in,data_out,MAG2GEO=MAG2GEO
    data_out=data_in
    
    ;convert the time
    timeS=time_struct(data_in.X)
    
    ;get direction
    if keyword_set(MAG2GEO) then begin
      dprint,'MAG-->GEO'
      subMAG2GEO,TIMES,data_in.Y,DATA_outARR
    endif else begin
      dprint,'GEO-->MAG'
      subGEO2MAG,TIMES,data_in.Y,DATA_outARR
    endelse
    
    data_out.Y=DATA_outARR
    
    dprint,'done'
    
    ;RETURN,data_out
end

;#################################################
@matrix_array_lib


;#################################################
;#################################################
;################## sub functions ################
;#################################################
;#################################################


;+
;proceddure: subGEI2GSE
;
;Purpose: transforms data from GEI to GSE
;
;INPUTS: TIMES as time_struct, DATA_in as nx3 array
;
;
;keywords:
;
;Example:
;
;
;Notes: under construction!!  will run faster in the near future!!
;
; $LastChangedBy: egrimes $
; $LastChangedDate: 2016-01-26 18:33:45 -0500 (Tue, 26 Jan 2016) $
; $LastChangedRevision: 19817 $
; $URL $
;-
pro subGEI2GSE,TIMES,DATA_in,DATA_out
    ; get array sizes
    count=SIZE(DATA_in[*,0],/N_ELEMENTS)
    DPRINT,'number of records: ' + string(count)
    
    DATA_out=dblarr(count,3)
    
    tgeigse_vect,TIMES[*].year,TIMES[*].doy,TIMES[*].hour,TIMES[*].min,double(TIMES[*].sec)+TIMES[*].fsec,DATA_in[*,0],DATA_in[*,1],DATA_in[*,2],xgse,ygse,zgse
    
    ;for i=0L,count-1L do begin
    		;ctimpar,iyear,imonth,iday,ih,im,is
    		;This has to be changed to be faster!!!!!!!!!!!!!!!
    ;		ctimpar,TIMES[i].year,TIMES[i].month,TIMES[i].date,TIMES[i].hour,TIMES[i].min,double(TIMES[i].sec)+TIMES[i].fsec
    ;		tgeigse,DATA_in[i,0],DATA_in[i,1],DATA_in[i,2],xgse,ygse,zgse
    DATA_out[*,0]=xgse
    DATA_out[*,1]=ygse
    DATA_out[*,2]=zgse
    ;endfor
    
    ;return,DATA_out
end

;#################################################

;+
;procedure: subGSE2GEI
;
;Purpose: transforms data from GSE to GEI
;
;INPUTS: TIMES as time_struct, DATA_in as nx3 array
;
;
;keywords:
;
;Example:
;
;
;Notes: under construction!!  will run faster in the near future!!
;
; $LastChangedBy: egrimes $
; $LastChangedDate: 2016-01-26 18:33:45 -0500 (Tue, 26 Jan 2016) $
; $LastChangedRevision: 19817 $
; $URL $
;-
pro subGSE2GEI,TIMES,DATA_in,DATA_out
    ; get array sizes
    count=SIZE(DATA_in[*,0],/N_ELEMENTS)
    DPRINT,'number of records: ' + string(count)
    
    DATA_out=dblarr(count,3)
    
    tgsegei_vect,TIMES[*].year,TIMES[*].doy,TIMES[*].hour,TIMES[*].min,double(TIMES[*].sec)+TIMES[*].fsec,DATA_in[*,0],DATA_in[*,1],DATA_in[*,2],xgei,ygei,zgei
    
    ;for i=0L,count-1L do begin
    ;		;ctimpar,iyear,imonth,iday,ih,im,is
    ;		;This has to be changed to be faster!!!!!!!!!!!!!!!
    ;		ctimpar,TIMES[i].year,TIMES[i].month,TIMES[i].date,TIMES[i].hour,TIMES[i].min,double(TIMES[i].sec)+TIMES[i].fsec
    ;		tgsegei,DATA_in[i,0],DATA_in[i,1],DATA_in[i,2],xgei,ygei,zgei
	DATA_out[*,0]=xgei
	DATA_out[*,1]=ygei
	DATA_out[*,2]=zgei
    ;endfor
    
    ;return,DATA_out
end

;#################################################

;+
;procedure: subGSE2GSM
;
;Purpose: transforms data from GSE to GSM
;
;INPUTS: TIMES as time_struct, DATA_in as nx3 array
;
;
;keywords:
;
;Example:
;
;
;Notes: under construction!!  will run faster in the near future!!
;
; $LastChangedBy: egrimes $
; $LastChangedDate: 2016-01-26 18:33:45 -0500 (Tue, 26 Jan 2016) $
; $LastChangedRevision: 19817 $
; $URL $
;-
pro subGSE2GSM,TIMES,DATA_in,DATA_out
    ; get array sizes
    count=SIZE(DATA_in[*,0],/N_ELEMENTS)
    DPRINT,'number of records: '+string(count)
    
    DATA_out=dblarr(count,3)
    
    tgsegsm_vect,TIMES[*].year,TIMES[*].doy,TIMES[*].hour,TIMES[*].min,double(TIMES[*].sec)+TIMES[*].fsec,DATA_in[*,0],DATA_in[*,1],DATA_in[*,2],xgsm,ygsm,zgsm
    
    ;for i=0L,count-1L do begin
    ;		;ctimpar,iyear,imonth,iday,ih,im,is
    ;		;This has to be changed to be faster!!!!!!!!!!!!!!!
    ;		ctimpar,TIMES[i].year,TIMES[i].month,TIMES[i].date,TIMES[i].hour,TIMES[i].min,double(TIMES[i].sec)+TIMES[i].fsec
    ;		tgsegsm,DATA_in[i,0],DATA_in[i,1],DATA_in[i,2],xgsm,ygsm,zgsm
    DATA_out[*,0]=xgsm
    DATA_out[*,1]=ygsm
    DATA_out[*,2]=zgsm
    ;endfor
    
    ;return,DATA_out
end

;#################################################

;+
;procedure: subGSM2GSE
;
;Purpose: transforms data from GSM to GSE
;
;INPUTS: TIMES as time_struct, DATA_in as nx3 array
;
;
;keywords:
;
;Example:
;
;
;Notes: under construction!!  will run faster in the near future!!
;
; $LastChangedBy: egrimes $
; $LastChangedDate: 2016-01-26 18:33:45 -0500 (Tue, 26 Jan 2016) $
; $LastChangedRevision: 19817 $
; $URL $
;-
pro subGSM2GSE,TIMES,DATA_in,DATA_out
    ; get array sizes
    count=SIZE(DATA_in[*,0],/N_ELEMENTS)
    DPRINT,'number of records: ' + string(count)
    
    DATA_out=dblarr(count,3)
    
    tgsmgse_vect,TIMES[*].year,TIMES[*].doy,TIMES[*].hour,TIMES[*].min,double(TIMES[*].sec)+TIMES[*].fsec,DATA_in[*,0],DATA_in[*,1],DATA_in[*,2],xgse,ygse,zgse
    
    ;for i=0L,count-1L do begin
    ;		;ctimpar,iyear,imonth,iday,ih,im,is
    ;		ctimpar,TIMES[i].year,TIMES[i].month,TIMES[i].date,TIMES[i].hour,TIMES[i].min,double(TIMES[i].sec)+TIMES[i].fsec
    ;		tgsmgse,DATA_in[i,0],DATA_in[i,1],DATA_in[i,2],xgse,ygse,zgse
    DATA_out[*,0]=xgse
    DATA_out[*,1]=ygse
    DATA_out[*,2]=zgse
    ;endfor
    
    ;return,DATA_out
end

;#################################################

;+
;procedure: subGSM2SM
;
;Purpose: transforms data from GSM to SM
;
;INPUTS: TIMES as time_struct, DATA_in as nx3 array
;
;
;keywords:
;
;Example:
;
;
;Notes: under construction!!
;
; $LastChangedBy: egrimes $
; $LastChangedDate: 2016-01-26 18:33:45 -0500 (Tue, 26 Jan 2016) $
; $LastChangedRevision: 19817 $
; $URL $
;-
pro subGSM2SM,TIMES,DATA_in,DATA_out
    ; get array sizes
    count=SIZE(DATA_in[*,0],/N_ELEMENTS)
    DPRINT,'number of records: ' + string(count)
    
    DATA_out=dblarr(count,3)
    
    tgsmsm_vect,TIMES[*].year,TIMES[*].doy,TIMES[*].hour,TIMES[*].min,double(TIMES[*].sec)+TIMES[*].fsec,DATA_in[*,0],DATA_in[*,1],DATA_in[*,2],xsm,ysm,zsm
    
    ;for i=0L,count-1L do begin
    ;		;ctimpar,iyear,imonth,iday,ih,im,is
    ;		ctimpar,TIMES[i].year,TIMES[i].month,TIMES[i].date,TIMES[i].hour,TIMES[i].min,double(TIMES[i].sec)+TIMES[i].fsec
    ;		tgsmgse,DATA_in[i,0],DATA_in[i,1],DATA_in[i,2],xgse,ygse,zgse
    DATA_out[*,0]=xsm
    DATA_out[*,1]=ysm
    DATA_out[*,2]=zsm
    ;endfor
    
    ;return,DATA_out
end

;#################################################

;+
;procedure: subSM2GSM
;
;Purpose: transforms data from SM to GSM
;
;INPUTS: TIMES as time_struct, DATA_in as nx3 array
;
;
;keywords:
;
;Example:
;
;
;Notes: under construction!!
;
; $LastChangedBy: egrimes $
; $LastChangedDate: 2016-01-26 18:33:45 -0500 (Tue, 26 Jan 2016) $
; $LastChangedRevision: 19817 $
; $URL $
;-
pro subSM2GSM,TIMES,DATA_in,DATA_out
    ; get array sizes
    count=SIZE(DATA_in[*,0],/N_ELEMENTS)
    DPRINT,'number of records: '+string(count)
    
    DATA_out=dblarr(count,3)
    
    tsmgsm_vect,TIMES[*].year,TIMES[*].doy,TIMES[*].hour,TIMES[*].min,double(TIMES[*].sec)+TIMES[*].fsec,DATA_in[*,0],DATA_in[*,1],DATA_in[*,2],xgsm,ygsm,zgsm
    
    ;for i=0L,count-1L do begin
    ;		;ctimpar,iyear,imonth,iday,ih,im,is
    ;		ctimpar,TIMES[i].year,TIMES[i].month,TIMES[i].date,TIMES[i].hour,TIMES[i].min,double(TIMES[i].sec)+TIMES[i].fsec
    ;		tgsmgse,DATA_in[i,0],DATA_in[i,1],DATA_in[i,2],xgse,ygse,zgse
    DATA_out[*,0]=xgsm
    DATA_out[*,1]=ygsm
    DATA_out[*,2]=zgsm
    ;endfor
    
    ;return,DATA_out
end

;#################################################

;+
;procedure: subGEI2GEO
;
;Purpose: transforms data from GEI to GEO
;
;INPUTS: TIMES as time_struct, DATA_in as nx3 array
;
;
;keywords:
;
;Example:
;
;
;Notes: under construction!!
;
; $LastChangedBy: egrimes $
; $LastChangedDate: 2016-01-26 18:33:45 -0500 (Tue, 26 Jan 2016) $
; $LastChangedRevision: 19817 $
; $URL $
;-
pro subGEI2GEO,TIMES,DATA_in,DATA_out
      csundir_vect,TIMES.year,TIMES.doy,TIMES.hour,TIMES.min,TIMES.sec,gst,slong,srasn,sdecl,obliq

      sgst=sin(gst)
      cgst=cos(gst)				

      x_out = cgst*DATA_IN[*,0] + sgst*DATA_IN[*,1]
      y_out = -sgst*DATA_IN[*,0] + cgst*DATA_IN[*,1]
      z_out = DATA_IN[*,2]

      DATA_out = [[x_out],[y_out],[z_out]]
end

;#################################################

;+
;procedure: subGEO2GEI
;
;Purpose: transforms data from GEO to GEI
;
;INPUTS: TIMES as time_struct, DATA_in as nx3 array
;
;
;keywords:
;
;Example:
;
;
;Notes: under construction!!
;
; $LastChangedBy: egrimes $
; $LastChangedDate: 2016-01-26 18:33:45 -0500 (Tue, 26 Jan 2016) $
; $LastChangedRevision: 19817 $
; $URL $
;-
pro subGEO2GEI,TIMES,DATA_in,DATA_out
  csundir_vect,TIMES.year,TIMES.doy,TIMES.hour,TIMES.min,TIMES.sec,gst,slong,srasn,sdecl,obliq

      sgst=sin(gst)
      cgst=cos(gst)				

      x_out = cgst*DATA_IN[*,0] - sgst*DATA_IN[*,1]
      y_out = sgst*DATA_IN[*,0] + cgst*DATA_IN[*,1]
      z_out = DATA_IN[*,2]

      DATA_out = [[x_out],[y_out],[z_out]]
end

;#################################################

;+
;procedure: subGEO2MAG
;
;Purpose: transforms data from GEO to MAG
;
;INPUTS: TIMES as time_struct, DATA_in as nx3 array
;
;
;keywords:
;
;Example:
;
;
;Notes: under construction!!
;
; $LastChangedBy: egrimes $
; $LastChangedDate: 2016-01-26 18:33:45 -0500 (Tue, 26 Jan 2016) $
; $LastChangedRevision: 19817 $
; $URL $
;-
pro subGEO2MAG,TIMES,DATA_in,DATA_out
    geo2mag, DATA_in, DATA_out, TIMES
END
;===============================================================================

;#################################################

;+
;procedure: subMAG2GEO
;
;Purpose: transforms data from MAG to GEO
;
;INPUTS: TIMES as time_struct, DATA_in as nx3 array
;
;
;keywords:
;
;Example:
;
;
;Notes: under construction!!
;
; $LastChangedBy: egrimes $
; $LastChangedDate: 2016-01-26 18:33:45 -0500 (Tue, 26 Jan 2016) $
; $LastChangedRevision: 19817 $
; $URL $
;-
pro subMAG2GEO,TIMES,DATA_in,DATA_out
   mag2geo, DATA_in, DATA_out, TIMES
END
;===============================================================================

;#################################################

;+
;procedure: csundir_vect
;
;Purpose: calculates the direction of the sun
;         (vectorized version of csundir from ROCOTLIB by
;          Patrick Robert)
;
;INPUTS: integer time
;
;
;output :      gst      greenwich mean sideral time (radians)
;              slong    longitude along ecliptic (radians)
;              sra      right ascension (radians)
;              sdec     declination of the sun (radians)
;              obliq    inclination of Earth's axis (radians)
;
;
;
;Notes: under construction!!
;
; $LastChangedBy: egrimes $
; $LastChangedDate: 2016-01-26 18:33:45 -0500 (Tue, 26 Jan 2016) $
; $LastChangedRevision: 19817 $
; $URL $
;-
pro csundir_vect,iyear,idoy,ih,im,is,gst,slong,sra,sdec,obliq

;----------------------------------------------------------------------
; *   Class  : basic compute modules of Rocotlib Software
; *   Object : compute_sun_direction in GEI system
; *   Author : C.T. Russel, 1971, rev. P.Robert,1992,2001,2002
; *   IDL Ver: C. Guerin, CETP, 2004
;
; *   Comment: calculates four quantities in gei system necessary for
;              coordinate transformations dependent on sun position
;              (and, hence, on universal time and season)
;              Initial code from C.T. Russel, cosmic electro-dynamics,
;              v.2, 184-196, 1971.
;              Adaptation P.Robert, November 1992.
;              Revised and F90 compatibility, P. Robert June 2001.
;              Optimisation of DBLE computations and comments,
;              P. Robert, December 2002
;
; *   input  : iyear : year (1901-2099)
;              idoy : day of the year (1 for january 1)
;              ih,im,is : hours, minutes, seconds U.T.
;
; *   output : gst      greenwich mean sideral time (radians)
;              slong    longitude along ecliptic (radians)
;              sra      right ascension (radians)
;              sdec     declination of the sun (radians)
;              obliq    inclination of Earth's axis (radians)
;----------------------------------------------------------------------

;     double precision dj,fday

;      if(iyear lt 1901 or iyear gt 2099) then begin
;        message,/continue ,'*** Rocotlib/csundir: year = ',iyear
;        message,/continue ,'*** Rocotlib/csundir: year must be >1901 and <2099'
;        stop
;        endif

      pi= acos(-1.)
      pisd= pi/180.

; *** Julian day and greenwich mean sideral time
      fday=double(ih*3600.+im*60.+is)/86400.d
      jj=365L*long(iyear-1900)+fix((iyear-1901)/4)+idoy
      dj=double(jj) -0.5d + fday
      gst=float((279.690983d +0.9856473354d*dj +360.d*fday +180d) $
         mod 360d )*pisd

; *** longitude along ecliptic
      vl= float( (279.696678d +0.9856473354d*dj) mod 360d )
      t=float(dj/36525d)
      g=float( (358.475845d +0.985600267d*dj) mod  360d )*pisd
      slong=(vl+(1.91946 -0.004789*t)*sin(g) +0.020094*sin(2.*g))*pisd

; *** inclination of Earth's axis
      obliq=(23.45229 -0.0130125*t)*pisd
      sob=sin(obliq)
      cob=cos(obliq)

; *** Aberration due to Earth's motion around the sun (about 0.0056 deg)
;
; Per Chris Russell's email of 2014-11-05:
; "The 0.005686 degrees is clearly defined in Bob Strangeway's email as 
; the aberration due to Earth's motion around the sun. This is proportional 
; to the speed of the earth divided by the speed of light. You can easily 
; calculate this number yourself. The original number (Mead and mine) are 
; correct."
; JWL 2014-11-05
      pre= (0.005686 - 0.025e-4*t)*pisd

; *** declination of the sun
      slp=slong -pre
      sind=sob*sin(slp)
      cosd=sqrt(1. -sind^2 )
      sc=sind/cosd
      sdec=atan(sc)

; *** right ascension of the sun
;     sra=pi -atan2((cob/sob)*sc, -cos(slp)/cosd)
      sra=pi -atan ((cob/sob)*sc, -cos(slp)/cosd)

      return
end

;+
;procedure: tgeigse_vect
;
;Purpose: GEI to GSE transformation
;         (vectorized version of tgeigse from ROCOTLIB by
;          Patrick Robert)
;
;
;
;Notes: under construction!!
;
; $LastChangedBy: egrimes $
; $LastChangedDate: 2016-01-26 18:33:45 -0500 (Tue, 26 Jan 2016) $
; $LastChangedRevision: 19817 $
; $URL $
;-
pro tgeigse_vect,iyear,idoy,ih,im,is,xgei,ygei,zgei,xgse,ygse,zgse

;----------------------------------------------------------------------
; *   Class  : transform modules of Rocotlib Software
; *   Object : transforms_gei_to_gse: GEI -> GSE  system
; *   Author : P. Robert, CRPE, 1992
; *   IDL Ver: C. Guerin, CETP, 2004
; *   Comment: terms of transformation matrix are given in common
;
; *   input  : xgei,ygei,zgei cartesian gei coordinates
; *   output : xgse,ygse,zgse cartesian gse coordinates
;----------------------------------------------------------------------


      csundir_vect,iyear,idoy,ih,im,is,gst,slong,srasn,sdecl,obliq

 	  gs1=cos(srasn)*cos(sdecl)  ;
      gs2=sin(srasn)*cos(sdecl)  ;
      gs3=sin(sdecl)             ;

      ge1=  0.                   ;
      ge2= -sin(obliq)           ;
      ge3=  cos(obliq)           ;

      gegs1= ge2*gs3 - ge3*gs2    ;
      gegs2= ge3*gs1 - ge1*gs3    ;
      gegs3= ge1*gs2 - ge2*gs1    ;

      xgse=   gs1*xgei +   gs2*ygei +   gs3*zgei
      ygse= gegs1*xgei + gegs2*ygei + gegs3*zgei
      zgse=   ge1*xgei +   ge2*ygei +   ge3*zgei

      return
end

;     XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

;+
;procedure: tgsegei_vect
;
;Purpose: GSE to GEI transformation
;         (vectorized version of tgsegei from ROCOTLIB by
;          Patrick Robert)
;
;
;
;Notes: under construction!!
;
; $LastChangedBy: egrimes $
; $LastChangedDate: 2016-01-26 18:33:45 -0500 (Tue, 26 Jan 2016) $
; $LastChangedRevision: 19817 $
; $URL $
;-
pro tgsegei_vect,iyear,idoy,ih,im,is,xgse,ygse,zgse,xgei,ygei,zgei

;----------------------------------------------------------------------
; *   Class  : transform modules of Rocotlib Software
; *   Object : transforms_gei_to_gse: GEI -> GSE  system
; *   Author : P. Robert, CRPE, 1992
; *   IDL Ver: C. Guerin, CETP, 2004
; *   Comment: terms of transformation matrix are given in common
;
; *   input  : xgei,ygei,zgei cartesian gei coordinates
; *   output : xgse,ygse,zgse cartesian gse coordinates
;----------------------------------------------------------------------


      csundir_vect,iyear,idoy,ih,im,is,gst,slong,srasn,sdecl,obliq

	  gs1=cos(srasn)*cos(sdecl)  ;
      gs2=sin(srasn)*cos(sdecl)  ;
      gs3=sin(sdecl)             ;

      ge1=  0.                   ;
      ge2= -sin(obliq)           ;
      ge3=  cos(obliq)           ;

      gegs1= ge2*gs3 - ge3*gs2    ;
      gegs2= ge3*gs1 - ge1*gs3    ;
      gegs3= ge1*gs2 - ge2*gs1    ;

      xgei= gs1*xgse + gegs1*ygse + ge1*zgse
      ygei= gs2*xgse + gegs2*ygse + ge2*zgse
      zgei= gs3*xgse + gegs3*ygse + ge3*zgse

      return
end

;     XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

;+
;procedure: tgsegsm_vect
;
;Purpose: GSE to GSM transformation
;         (vectorized version of tgsegsm from ROCOTLIB by
;          Patrick Robert)
;
;
;
;Notes: under construction!!
;
; $LastChangedBy: egrimes $
; $LastChangedDate: 2016-01-26 18:33:45 -0500 (Tue, 26 Jan 2016) $
; $LastChangedRevision: 19817 $
; $URL $
;-
pro tgsegsm_vect,iyear,idoy,ih,im,is,xgse,ygse,zgse,xgsm,ygsm,zgsm
	  cdipdir_vect,iyear,idoy,gd1,gd2,gd3

      ; ok from here on
      csundir_vect,iyear,idoy,ih,im,is,gst,slong,srasn,sdecl,obliq

      gs1=cos(srasn)*cos(sdecl)  ;tttttt
      gs2=sin(srasn)*cos(sdecl)  ;tttttt
      gs3=sin(sdecl)             ;tttttt

; *** sin and cos of GMST

      sgst=sin(gst)				;*
      cgst=cos(gst)				;*

; *** ecliptic pole in GEI system

      ge1=  0.                   ;*
      ge2= -sin(obliq)           ;*
      ge3=  cos(obliq)           ;*

; *** dipole direction in GEI system

      gm1= gd1*cgst - gd2*sgst   ;* gd1 ->from internal field
      gm2= gd1*sgst + gd2*cgst   ;* gd2 ->from internal field
      gm3= gd3                   ;* gd3 ->from internal field

	  ; *** cross product MxS in GEI system

      gmgs1= gm2*gs3 - gm3*gs2    ;*
      gmgs2= gm3*gs1 - gm1*gs3    ;*
      gmgs3= gm1*gs2 - gm2*gs1    ;*

      rgmgs=sqrt(gmgs1^2 + gmgs2^2 + gmgs3^2)    ;*


	  cdze= (ge1*gm1   + ge2*gm2   + ge3*gm3)/rgmgs
      sdze= (ge1*gmgs1 + ge2*gmgs2 + ge3*gmgs3)/rgmgs
      epsi=1.e-6
;      if(abs(sdze^2 +cdze^2-1.) gt epsi) then begin
;         message,/continue, '*** Rogralib error 3'
;         stop
;      endif

	  xgsm= xgse
      ygsm=  cdze*ygse + sdze*zgse
      zgsm= -sdze*ygse + cdze*zgse
END

;+
;procedure: tgsmgse_vect
;
;Purpose: GSM to GSE transformation
;         (vectorized version of tgsmgse from ROCOTLIB by
;          Patrick Robert)
;
;
;
;Notes: under construction!!
;
; $LastChangedBy: egrimes $
; $LastChangedDate: 2016-01-26 18:33:45 -0500 (Tue, 26 Jan 2016) $
; $LastChangedRevision: 19817 $
; $URL $
;-
pro tgsmgse_vect,iyear,idoy,ih,im,is,xgsm,ygsm,zgsm,xgse,ygse,zgse
	  cdipdir_vect,iyear,idoy,gd1,gd2,gd3

      ; ok from here on
      csundir_vect,iyear,idoy,ih,im,is,gst,slong,srasn,sdecl,obliq

      gs1=cos(srasn)*cos(sdecl)  ;tttttt
      gs2=sin(srasn)*cos(sdecl)  ;tttttt
      gs3=sin(sdecl)             ;tttttt

; *** sin and cos of GMST
      sgst=sin(gst)				;*
      cgst=cos(gst)				;*

; *** ecliptic pole in GEI system
      ge1=  0.                   ;*
      ge2= -sin(obliq)           ;*
      ge3=  cos(obliq)           ;*

; *** dipole direction in GEI system
      gm1= gd1*cgst - gd2*sgst   ;* gd1 ->from internal field
      gm2= gd1*sgst + gd2*cgst   ;* gd2 ->from internal field
      gm3= gd3                   ;* gd3 ->from internal field


	  ; *** cross product MxS in GEI system
      gmgs1= gm2*gs3 - gm3*gs2    ;*
      gmgs2= gm3*gs1 - gm1*gs3    ;*
      gmgs3= gm1*gs2 - gm2*gs1    ;*

      rgmgs=sqrt(gmgs1^2 + gmgs2^2 + gmgs3^2)    ;*


	  cdze= (ge1*gm1   + ge2*gm2   + ge3*gm3)/rgmgs
      sdze= (ge1*gmgs1 + ge2*gmgs2 + ge3*gmgs3)/rgmgs
      epsi=1.e-6
;      if(abs(sdze^2 +cdze^2-1.) gt epsi) then begin
;         message,/continue, '*** Rogralib error 3'
;         stop
;      endif

      xgse= xgsm
      ygse= cdze*ygsm - sdze*zgsm
      zgse= sdze*ygsm + cdze*zgsm
END

;+
;procedure: tgsmsm_vect
;
;Purpose: GSM to SM transformation
;         (vectorized version of tgsmsma from ROCOTLIB by
;          Patrick Robert)
;
;
;
;Notes: under construction!!
;
; $LastChangedBy: egrimes $
; $LastChangedDate: 2016-01-26 18:33:45 -0500 (Tue, 26 Jan 2016) $
; $LastChangedRevision: 19817 $
; $URL $
;-
pro tgsmsm_vect,iyear,idoy,ih,im,is,xgsm,ygsm,zgsm,xsm,ysm,zsm
	  cdipdir_vect,iyear,idoy,gd1,gd2,gd3

      ; ok from here on

      csundir_vect,iyear,idoy,ih,im,is,gst,slong,srasn,sdecl,obliq

      gs1=cos(srasn)*cos(sdecl)  ;tttttt
      gs2=sin(srasn)*cos(sdecl)  ;tttttt
      gs3=sin(sdecl)             ;tttttt

; *** sin and cos of GMST
      sgst=sin(gst)
      cgst=cos(gst)

; *** direction of the sun in GEO system
      ps1=  gs1*cgst + gs2*sgst
      ps2= -gs1*sgst + gs2*cgst
      ps3=  gs3

; *** computation of mu angle
      smu= ps1*gd1 + ps2*gd2 + ps3*gd3
      cmu= sqrt(1.-smu*smu)


; do the transformation
	  xsm= cmu*xgsm - smu*zgsm
      ysm= ygsm
      zsm= smu*xgsm + cmu*zgsm

END

;+
;procedure: tsmgsm_vect
;
;Purpose: SM to GSM transformation
;         (vectorized version of tsmagsm from ROCOTLIB by
;          Patrick Robert)
;
;
;
;Notes: under construction!!
;
; $LastChangedBy: egrimes $
; $LastChangedDate: 2016-01-26 18:33:45 -0500 (Tue, 26 Jan 2016) $
; $LastChangedRevision: 19817 $
; $URL $
;-
pro tsmgsm_vect,iyear,idoy,ih,im,is,xsm,ysm,zsm,xgsm,ygsm,zgsm
	  cdipdir_vect,iyear,idoy,gd1,gd2,gd3

      ; ok from here on

      csundir_vect,iyear,idoy,ih,im,is,gst,slong,srasn,sdecl,obliq

      gs1=cos(srasn)*cos(sdecl)  ;tttttt
      gs2=sin(srasn)*cos(sdecl)  ;tttttt
      gs3=sin(sdecl)             ;tttttt

; *** sin and cos of GMST
      sgst=sin(gst)
      cgst=cos(gst)

; *** direction of the sun in GEO system
      ps1=  gs1*cgst + gs2*sgst
      ps2= -gs1*sgst + gs2*cgst
      ps3=  gs3

; *** computation of mu angle
      smu= ps1*gd1 + ps2*gd2 + ps3*gd3
      cmu= sqrt(1.-smu*smu)

; do the transformation
	  xgsm=  cmu*xsm + smu*zsm
      ygsm=  ysm
      zgsm= -smu*xsm + cmu*zsm
END

;+
;procedure: cdipdir_vect
;
;Purpose: calls cdipdir from ROCOTLIB in a vectorized environment
;
;
;
;Notes: under construction!!
;
; $LastChangedBy: egrimes $
; $LastChangedDate: 2016-01-26 18:33:45 -0500 (Tue, 26 Jan 2016) $
; $LastChangedRevision: 19817 $
;
; faster algorithm (for loop across all points avoided) Hannes 05/25/2007
;
; $URL $
;-
PRO cdipdir_vect,iyear,idoy,gd1,gd2,gd3
		n=n_elements(iyear)

		IF (n eq 1) THEN BEGIN
			cdipdir,iyear,idoy,gd1,gd2,gd3
			RETURN
		ENDIF

		gd1=fltarr(n)
		gd2=fltarr(n)
		gd3=fltarr(n)

;		t1 = SYSTIME(1)
;       faster coding!!

		;get the date changes
		iDiff    =abs(TS_DIFF(idoy, 1))+abs(TS_DIFF(iyear, 1))
		iDiff[n-1L] =1 ;always calculate at last element
		noZeros  =WHERE( iDiff NE 0)

		nn=n_elements(noZeros)

		;loop only through the date changes (usually only once for day-files)
		indexStart=0L
		for ii = 0L,nn-1L do begin
			i=noZeros[ii]
			cdipdir,iyear[i],idoy[i],gd1i,gd2i,gd3i
			gd1[indexStart:i]=gd1i
			gd2[indexStart:i]=gd2i
			gd3[indexStart:i]=gd3i
			indexStart=i+1L
		ENDFOR


;		t2 = SYSTIME(1)

;		t3 = SYSTIME(1)
;		cdipdir,iyear(0),idoy(0),gd1i,gd2i,gd3i


		;still a bit of a bottle neck
;		iyearPrev=iyear(0)
;		idoyPrev = idoy(0)
;		indexStart=0L
;
;		for i=1L,n-1L do begin
;
;
;			IF ( (idoy(i) ne idoyPrev) || (iyear(i) ne iyearPrev)) then begin
;				gd1(indexStart:i-1L)=gd1i
;				gd2(indexStart:i-1L)=gd2i
;				gd3(indexStart:i-1L)=gd3i
;				cdipdir,iyear(i),idoy(i),gd1i,gd2i,gd3i
;				iyearPrev=iyear(i)
;				idoyPrev = idoy(i)
;				indexStart=i
;			ENDIF
;
;			IF (i eq n-1L) THEN BEGIN
;				gd1(indexStart:i)=gd1i
;				gd2(indexStart:i)=gd2i
;				gd3(indexStart:i)=gd3i
;				break
;			ENDIF
;
;		ENDFOR
;		t4 = SYSTIME(1)
;
;
;		MESSAGE,/CONTINUE,'Time compare: New:'
;		MESSAGE,/CONTINUE,t2-t1
;		MESSAGE,/CONTINUE,'Time compare: Old:'
;		MESSAGE,/CONTINUE,t4-t3
;
END

;+
;procedure: cdipdir
;
;Purpose: cdipdir from ROCOTLIB. direction of Earth's magnetic axis in GEO
;
;
;
;Notes: under construction!!
;
; $LastChangedBy: egrimes $
; $LastChangedDate: 2016-01-26 18:33:45 -0500 (Tue, 26 Jan 2016) $
; $LastChangedRevision: 19817 $
; $URL $
;-
pro cdipdir,iyear,idoy,d1,d2,d3
;----------------------------------------------------------------------
;
; *   Class  : basic compute modules of Rocotlib Software
; *   Object : compute_dipole_direction in GEO system
; *   Author : P. Robert, CRPE, 1992 +Tsyganenko 87 model
; *   IDL Ver: C. Guerin, CETP, 200sion v2.0 P. Robert, nov. 2006e
;
; *   Comment: Compute geodipole axis direction from International
;              Geomagnetic Reference Field (IGRF) models for time
;              interval 1965 to 2015. For time out of interval,
;              computation is made for nearest boundary.
;              Code extracted from geopack, N.A. Tsyganenko, Jan. 5 2001
;              Revised P.R., November 23 2006, full compatible with last
;              revision of geopacklib of May 3 2005.
;              (see http://www.ngdc.noaa.gov/IAGA/vmod/igrf.html)
;
; NOTES:
; - updated by pcruce on 2011-01-24 to contain IGRF coefficients that range up to 2010
; - updated by egrimes on 2015-03-26 with IGRF-12 coefficients
;
; *   input  :  iyear (1965 - 2010), idoy= day of year (1/1=1)
; *   output :  d1,d2,d3  cartesian dipole components in GEO system
;
; ----------------------------------------------------------------------


;     Coefficients of the igrf field model, calculated for a given year
;     and day from their standard epoch values.

;     dimension g(105),h(105)
      g=FLTARR(105)
      h=FLTARR(105)
      nloop= 104


g65 = [0.0, -30334.0, -2119.0, -1662.0, 2997.0, 1594.0, 1297.0, -2038.0, 1292.0, $
       856.0, 957.0, 804.0, 479.0, -390.0, 252.0, -219.0, 358.0, 254.0, -31.0, $
       -157.0, -62.0, 45.0, 61.0, 8.0, -228.0, 4.0, 1.0, -111.0, 75.0, -57.0, $
       4.0, 13.0, -26.0, -6.0, 13.0, 1.0, 13.0, 5.0, -4.0, -14.0, 0.0, 8.0, -1.0, $
       11.0, 4.0, 8.0, 10.0, 2.0, -13.0, 10.0, -1.0, -1.0, 5.0, 1.0, -2.0, -2.0, $
       -3.0, 2.0, -5.0, -2.0, 4.0, 4.0, 0.0, 2.0, 2.0, 0.0, 0.0, 0.0, 0.0, $
       0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, $
       0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, $
       0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]

h65 = [0.0, 0.0, 5776.0, 0.0, -2016.0, 114.0, 0.0, -404.0, 240.0, -165.0, 0.0, $
       148.0, -269.0, 13.0, -269.0, 0.0, 19.0, 128.0, -126.0, -97.0, 81.0, 0.0, $
       -11.0, 100.0, 68.0, -32.0, -8.0, -7.0, 0.0, -61.0, -27.0, -2.0, 6.0, 26.0, $
       -23.0, -12.0, 0.0, 7.0, -12.0, 9.0, -16.0, 4.0, 24.0, -3.0, -17.0, 0.0, $
       -22.0, 15.0, 7.0, -4.0, -5.0, 10.0, 10.0, -4.0, 1.0, 0.0, 2.0, 1.0, 2.0, $
       6.0, -4.0, 0.0, -2.0, 3.0, 0.0, -6.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, $
       0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, $
       0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]

g70 = [0.0, -30220.0, -2068.0, -1781.0, 3000.0, 1611.0, 1287.0, -2091.0, 1278.0, 838.0, $
       952.0, 800.0, 461.0, -395.0, 234.0, -216.0, 359.0, 262.0, -42.0, -160.0, -56.0, $
       43.0, 64.0, 15.0, -212.0, 2.0, 3.0, -112.0, 72.0, -57.0, 1.0, 14.0, -22.0, -2.0, $
       13.0, -2.0, 14.0, 6.0, -2.0, -13.0, -3.0, 5.0, 0.0, 11.0, 3.0, 8.0, 10.0, 2.0, $
       -12.0, 10.0, -1.0, 0.0, 3.0, 1.0, -1.0, -3.0, -3.0, 2.0, -5.0, -1.0, 6.0, 4.0, $
       1.0, 0.0, 3.0, -1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, $
       0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, $
       0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]

h70 = [0.0, 0.0, 5737.0, 0.0, -2047.0, 25.0, 0.0, -366.0, 251.0, -196.0, 0.0, 167.0, $
      -266.0, 26.0, -279.0, 0.0, 26.0, 139.0, -139.0, -91.0, 83.0, 0.0, -12.0, 100.0, $
      72.0, -37.0, -6.0, 1.0, 0.0, -70.0, -27.0, -4.0, 8.0, 23.0, -23.0, -11.0, 0.0, 7.0, $
      -15.0, 6.0, -17.0, 6.0, 21.0, -6.0, -16.0, 0.0, -21.0, 16.0, 6.0, -4.0, -5.0, 10.0, $
      11.0, -2.0, 1.0, 0.0, 1.0, 1.0, 3.0, 4.0, -4.0, 0.0, -1.0, 3.0, 1.0, -4.0, 0.0, $
      0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, $
      0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, $
      0.0, 0.0, 0.0, 0.0, 0.0, 0.0]

g75 = [0.0, -30100.0, -2013.0, -1902.0, 3010.0, 1632.0, 1276.0, -2144.0, 1260.0, 830.0, $
       946.0, 791.0, 438.0, -405.0, 216.0, -218.0, 356.0, 264.0, -59.0, -159.0, -49.0, $
       45.0, 66.0, 28.0, -198.0, 1.0, 6.0, -111.0, 71.0, -56.0, 1.0, 16.0, -14.0, 0.0, $
       12.0, -5.0, 14.0, 6.0, -1.0, -12.0, -8.0, 4.0, 0.0, 10.0, 1.0, 7.0, 10.0, 2.0, $
       -12.0, 10.0, -1.0, -1.0, 4.0, 1.0, -2.0, -3.0, -3.0, 2.0, -5.0, -2.0, 5.0, 4.0, $
       1.0, 0.0, 3.0, -1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, $
       0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, $
       0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]

h75 = [0.0, 0.0, 5675.0, 0.0, -2067.0, -68.0, 0.0, -333.0, 262.0, -223.0, 0.0, 191.0, $
      -265.0, 39.0, -288.0, 0.0, 31.0, 148.0, -152.0, -83.0, 88.0, 0.0, -13.0, 99.0, $
      75.0, -41.0, -4.0, 11.0, 0.0, -77.0, -26.0, -5.0, 10.0, 22.0, -23.0, -12.0, 0.0, $
      6.0, -16.0, 4.0, -19.0, 6.0, 18.0, -10.0, -17.0, 0.0, -21.0, 16.0, 7.0, -4.0, $
      -5.0, 10.0, 11.0, -3.0, 1.0, 0.0, 1.0, 1.0, 3.0, 4.0, -4.0, -1.0, -1.0, 3.0, 1.0, $
      -5.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, $
      0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, $
      0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]

g80 = [0.0, -29992.0, -1956.0, -1997.0, 3027.0, 1663.0, 1281.0, -2180.0, 1251.0, 833.0, $
       938.0, 782.0, 398.0, -419.0, 199.0, -218.0, 357.0, 261.0, -74.0, -162.0, -48.0, $
       48.0, 66.0, 42.0, -192.0, 4.0, 14.0, -108.0, 72.0, -59.0, 2.0, 21.0, -12.0, 1.0, $
       11.0, -2.0, 18.0, 6.0, 0.0, -11.0, -7.0, 4.0, 3.0, 6.0, -1.0, 5.0, 10.0, 1.0, $
       -12.0, 9.0, -3.0, -1.0, 7.0, 2.0, -5.0, -4.0, -4.0, 2.0, -5.0, -2.0, 5.0, 3.0, $
       1.0, 2.0, 3.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, $
       0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, $
       0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]

h80 = [0.0, 0.0, 5604.0, 0.0, -2129.0, -200.0, 0.0, -336.0, 271.0, -252.0, 0.0, 212.0, $
      -257.0, 53.0, -297.0, 0.0, 46.0, 150.0, -151.0, -78.0, 92.0, 0.0, -15.0, 93.0, $
      71.0, -43.0, -2.0, 17.0, 0.0, -82.0, -27.0, -5.0, 16.0, 18.0, -23.0, -10.0, 0.0, $
      7.0, -18.0, 4.0, -22.0, 9.0, 16.0, -13.0, -15.0, 0.0, -21.0, 16.0, 9.0, -5.0, -6.0, $
      9.0, 10.0, -6.0, 2.0, 0.0, 1.0, 0.0, 3.0, 6.0, -4.0, 0.0, -1.0, 4.0, 0.0, -6.0, $
      0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, $
      0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, $
      0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]

g85 = [0.0, -29873.0, -1905.0, -2072.0, 3044.0, 1687.0, 1296.0, -2208.0, 1247.0, 829.0, $
       936.0, 780.0, 361.0, -424.0, 170.0, -214.0, 355.0, 253.0, -93.0, -164.0, -46.0, $
       53.0, 65.0, 51.0, -185.0, 4.0, 16.0, -102.0, 74.0, -62.0, 3.0, 24.0, -6.0, 4.0, $
       10.0, 0.0, 21.0, 6.0, 0.0, -11.0, -9.0, 4.0, 4.0, 4.0, -4.0, 5.0, 10.0, 1.0, $
       -12.0, 9.0, -3.0, -1.0, 7.0, 1.0, -5.0, -4.0, -4.0, 3.0, -5.0, -2.0, 5.0, 3.0, $
       1.0, 2.0, 3.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, $
       0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, $
       0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]

h85 = [0.0, 0.0, 5500.0, 0.0, -2197.0, -306.0, 0.0, -310.0, 284.0, -297.0, 0.0, 232.0, $
      -249.0, 69.0, -297.0, 0.0, 47.0, 150.0, -154.0, -75.0, 95.0, 0.0, -16.0, 88.0, $
      69.0, -48.0, -1.0, 21.0, 0.0, -83.0, -27.0, -2.0, 20.0, 17.0, -23.0, -7.0, 0.0, $
      8.0, -19.0, 5.0, -23.0, 11.0, 14.0, -15.0, -11.0, 0.0, -21.0, 15.0, 9.0, -6.0, $
      -6.0, 9.0, 9.0, -7.0, 2.0, 0.0, 1.0, 0.0, 3.0, 6.0, -4.0, 0.0, -1.0, 4.0, 0.0, $
      -6.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, $
      0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, $
      0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]

g90 = [0.0, -29775.0, -1848.0, -2131.0, 3059.0, 1686.0, 1314.0, -2239.0, 1248.0, $
       802.0, 939.0, 780.0, 325.0, -423.0, 141.0, -214.0, 353.0, 245.0, -109.0, $
       -165.0, -36.0, 61.0, 65.0, 59.0, -178.0, 3.0, 18.0, -96.0, 77.0, -64.0, 2.0, $
       26.0, -1.0, 5.0, 9.0, 0.0, 23.0, 5.0, -1.0, -10.0, -12.0, 3.0, 4.0, 2.0, $
       -6.0, 4.0, 9.0, 1.0, -12.0, 9.0, -4.0, -2.0, 7.0, 1.0, -6.0, -3.0, -4.0, 2.0, $
       -5.0, -2.0, 4.0, 3.0, 1.0, 3.0, 3.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, $
       0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, $
       0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]

h90 = [0.0, 0.0, 5406.0, 0.0, -2279.0, -373.0, 0.0, -284.0, 293.0, -352.0, 0.0, $
       247.0, -240.0, 84.0, -299.0, 0.0, 46.0, 154.0, -153.0, -69.0, 97.0, 0.0, $
       -16.0, 82.0, 69.0, -52.0, 1.0, 24.0, 0.0, -80.0, -26.0, 0.0, 21.0, 17.0, $
       -23.0, -4.0, 0.0, 10.0, -19.0, 6.0, -22.0, 12.0, 12.0, -16.0, -10.0, 0.0, $
       -20.0, 15.0, 11.0, -7.0, -7.0, 9.0, 8.0, -7.0, 2.0, 0.0, 2.0, 1.0, 3.0, 6.0, $
       -4.0, 0.0, -2.0, 3.0, -1.0, -6.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, $
       0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, $
       0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]

g95 = [0.0, -29692.0, -1784.0, -2200.0, 3070.0, 1681.0, 1335.0, -2267.0, 1249.0, $
       759.0, 940.0, 780.0, 290.0, -418.0, 122.0, -214.0, 352.0, 235.0, -118.0, $
       -166.0, -17.0, 68.0, 67.0, 68.0, -170.0, -1.0, 19.0, -93.0, 77.0, -72.0, $
       1.0, 28.0, 5.0, 4.0, 8.0, -2.0, 25.0, 6.0, -6.0, -9.0, -14.0, 9.0, 6.0, $
       -5.0, -7.0, 4.0, 9.0, 3.0, -10.0, 8.0, -8.0, -1.0, 10.0, -2.0, -8.0, -3.0, $
       -6.0, 2.0, -4.0, -1.0, 4.0, 2.0, 2.0, 5.0, 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, $
       0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, $
       0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, $
       0.0, 0.0, 0.0, 0.0, 0.0]

h95 = [0.0, 0.0, 5306.0, 0.0, -2366.0, -413.0, 0.0, -262.0, 302.0, -427.0, 0.0, $
      262.0, -236.0, 97.0, -306.0, 0.0, 46.0, 165.0, -143.0, -55.0, 107.0, 0.0, $
      -17.0, 72.0, 67.0, -58.0, 1.0, 36.0, 0.0, -69.0, -25.0, 4.0, 24.0, 17.0, $
      -24.0, -6.0, 0.0, 11.0, -21.0, 8.0, -23.0, 15.0, 11.0, -16.0, -4.0, 0.0, $
      -20.0, 15.0, 12.0, -6.0, -8.0, 8.0, 5.0, -8.0, 3.0, 0.0, 1.0, 0.0, 4.0, $
      5.0, -5.0, -1.0, -2.0, 1.0, -2.0, -7.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, $
      0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, $
      0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, $
      0.0, 0.0]

g00 = [0.0, -29619.4, -1728.2, -2267.7, 3068.4, 1670.9, 1339.6, -2288.0, 1252.1, $
       714.5, 932.3, 786.8, 250.0, -403.0, 111.3, -218.8, 351.4, 222.3, -130.4, $
       -168.6, -12.9, 72.3, 68.2, 74.2, -160.9, -5.9, 16.9, -90.4, 79.0, -74.0, $
       0.0, 33.3, 9.1, 6.9, 7.3, -1.2, 24.4, 6.6, -9.2, -7.9, -16.6, 9.1, 7.0, $
       -7.9, -7.0, 5.0, 9.4, 3.0, -8.4, 6.3, -8.9, -1.5, 9.3, -4.3, -8.2, -2.6, $
       -6.0, 1.7, -3.1, -0.5, 3.7, 1.0, 2.0, 4.2, 0.3, -1.1, 2.7, -1.7, -1.9, 1.5, $
       -0.1, 0.1, -0.7, 0.7, 1.7, 0.1, 1.2, 4.0, -2.2, -0.3, 0.2, 0.9, -0.2, 0.9, $
       -0.5, 0.3, -0.3, -0.4, -0.1, -0.2, -0.4, -0.2, -0.9, 0.3, 0.1, -0.4, 1.3, $
       -0.4, 0.7, -0.4, 0.3, -0.1, 0.4, 0.0, 0.1]

h00 = [0.0, 0.0, 5186.1, 0.0, -2481.6, -458.0, 0.0, -227.6, 293.4, -491.1, 0.0, $
       272.6, -231.9, 119.8, -303.8, 0.0, 43.8, 171.9, -133.1, -39.3, 106.3, 0.0, $
       -17.4, 63.7, 65.1, -61.2, 0.7, 43.8, 0.0, -64.6, -24.2, 6.2, 24.0, 14.8, $
       -25.4, -5.8, 0.0, 11.9, -21.5, 8.5, -21.5, 15.5, 8.9, -14.9, -2.1, 0.0, $
       -19.7, 13.4, 12.5, -6.2, -8.4, 8.4, 3.8, -8.2, 4.8, 0.0, 1.7, 0.0, 4.0, 4.9, $
       -5.9, -1.2, -2.9, 0.2, -2.2, -7.4, 0.0, 0.1, 1.3, -0.9, -2.6, 0.9, -0.7, $
       -2.8, -0.9, -1.2, -1.9, -0.9, 0.0, -0.4, 0.3, 2.5, -2.6, 0.7, 0.3, 0.0, 0.0, $
       0.3, -0.9, -0.4, 0.8, 0.0, -0.9, 0.2, 1.8, -0.4, -1.0, -0.1, 0.7, 0.3, 0.6, $
       0.3, -0.2, -0.5, -0.9]

g05 = [0.0, -29554.63, -1669.05, -2337.24, 3047.69, 1657.76, 1336.3, -2305.83, $
       1246.39, 672.51, 920.55, 797.96, 210.65, -379.86, 100.0, -227.0, 354.41, $
       208.95, -136.54, -168.05, -13.55, 73.6, 69.56, 76.74, -151.34, -14.58, 14.58, $
       -86.36, 79.88, -74.46, -1.65, 38.73, 12.3, 9.37, 5.42, 1.94, 24.8, 7.62, $
       -11.73, -6.88, -18.11, 10.17, 9.36, -11.25, -4.87, 5.58, 9.76, 3.58, -6.94, $
       5.01, -10.76, -1.25, 8.76, -6.66, -9.22, -2.17, -6.12, 1.42, -2.35, $
       -0.15, 3.06, 0.29, 2.06, 3.77, -0.21, -2.09, 2.95, -1.6, -1.88, 1.44, -0.31, $
       0.29, -0.79, 0.53, 1.8, 0.16, 0.96, 3.99, -2.15, -0.29, 0.21, 0.89, -0.38, $
       0.96, -0.3, 0.46, -0.35, -0.36, 0.08, -0.49, -0.08, -0.16, -0.88, 0.3, 0.28, $
       -0.43, 1.18, -0.37, 0.75, -0.26, 0.35, -0.05, 0.41, -0.1, -0.18]

h05 = [0.0, 0.0, 5077.99, 0.0, -2594.5, -515.43, 0.0, -198.86, 269.72, -524.72, $
       0.0, 282.07, -225.23, 145.15, -305.36, 0.0, 42.72, 180.25, -123.45, -19.57, $
       103.85, 0.0, -20.33, 54.75, 63.63, -63.53, 0.24, 50.94, 0.0, -61.14, -22.57, $
       6.82, 25.35, 10.93, -26.32, -4.64, 0.0, 11.2, -20.88, 9.83, -19.71, 16.22, $
       7.61, -12.76, -0.06, 0.0, -20.11, 12.69, 12.67, -6.72, -8.16, 8.1, 2.92, $
       -7.73, 6.01, 0.0, 2.19, 0.1, 4.46, 4.76, -6.58, -1.01, -3.47, -0.86, -2.31, $
       -7.93, 0.0, 0.26, 1.44, -0.77, -2.27, 0.9, -0.58, -2.69, -1.08, -1.58, -1.9, $
       -1.39, 0.0, -0.55, 0.23, 2.38, -2.63, 0.61, 0.4, 0.01, 0.02, 0.28, -0.87, $
       -0.34, 0.88, 0.0, -0.76, 0.33, 1.72, -0.54, -1.07, -0.04, 0.63, 0.21, 0.53, $
       0.38, -0.22, -0.57, -0.82]

g10 = [0.0, -29496.57, -1586.42, -2396.06, 3026.34, 1668.17, 1339.85, -2326.54, $
       1232.1, 633.73, 912.66, 808.97, 166.58, -356.83, 89.4, -230.87, 357.29, $
       200.26, -141.05, -163.17, -8.03, 72.78, 68.69, 75.92, -141.4, -22.83, $
       13.1, -78.09, 80.44, -75.0, -4.55, 45.24, 14.0, 10.46, 1.64, 4.92, 24.41, $
       8.21, -14.5, -5.59, -19.34, 11.61, 10.85, -14.05, -3.54, 5.5, 9.45, 3.45, $
       -5.27, 3.13, -12.38, -0.76, 8.43, -8.42, -10.08, -1.94, -6.24, 0.89, $
       -1.07, -0.16, 2.45, -0.33, 2.13, 3.09, -1.03, -2.8, 3.05, -1.48, -2.03, $
       1.65, -0.51, 0.54, -0.79, 0.37, 1.79, 0.12, 0.75, 3.75, -2.12, -0.21, 0.3, $
       1.04, -0.63, 0.95, -0.11, 0.52, -0.39, -0.37, 0.21, -0.77, 0.04, -0.09, $
       -0.89, 0.31, 0.42, -0.45, 1.08, -0.31, 0.78, -0.18, 0.38, 0.02, 0.42, $
       -0.26, -0.26]

h10 = [0.0, 0.0, 4944.26, 0.0, -2708.54, -575.73, 0.0, -160.4, 251.75, -537.03, $
       0.0, 286.48, -211.03, 164.46, -309.72, 0.0, 44.58, 189.01, -118.06, -0.01, $
       101.04, 0.0, -20.9, 44.18, 61.54, -66.26, 3.02, 55.4, 0.0, -57.8, -21.2, $
       6.54, 24.96, 7.03, -27.61, -3.28, 0.0, 10.84, -20.03, 11.83, -17.41, 16.71, $
       6.96, -10.74, 1.64, 0.0, -20.54, 11.51, 12.75, -7.14, -7.42, 7.97, 2.14, $
       -6.08, 7.01, 0.0, 2.73, -0.1, 4.71, 4.44, -7.22, -0.96, -3.95, -1.99, $
       -1.97, -8.31, 0.0, 0.13, 1.67, -0.66, -1.76, 0.85, -0.39, -2.51, -1.27, $
       -2.11, -1.94, -1.86, 0.0, -0.87, 0.27, 2.13, -2.49, 0.49, 0.59, 0.0, 0.13, $
       0.27, -0.86, -0.23, 0.87, 0.0, -0.87, 0.3, 1.66, -0.59, -1.14, -0.07, 0.54, $
       0.1, 0.49, 0.44, -0.25, -0.53, -0.79]

g15 = [0.0, -29442.0, -1501.0, -2445.1, 3012.9, 1676.7, 1350.7, -2352.3, 1225.6, $
       582.0, 907.6, 813.7, 120.4, -334.9, 70.4, -232.6, 360.1, 192.4, -140.9, $
       -157.5, 4.1, 70.0, 67.7, 72.7, -129.9, -28.9, 13.2, -70.9, 81.6, -76.1, $
       -6.8, 51.8, 15.0, 9.4, -2.8, 6.8, 24.2, 8.8, -16.9, -3.2, -20.6, 13.4, $
       11.7, -15.9, -2.0, 5.4, 8.8, 3.1, -3.3, 0.7, -13.3, -0.1, 8.7, -9.1, $
       -10.5, -1.9, -6.3, 0.1, 0.5, -0.5, 1.8, -0.7, 2.1, 2.4, -1.8, -3.6, 3.1, $
       -1.5, -2.3, 2.0, -0.8, 0.6, -0.7, 0.2, 1.7, -0.2, 0.4, 3.5, -1.9, -0.2, $
       0.4, 1.2, -0.8, 0.9, 0.1, 0.5, -0.3, -0.4, 0.2, -0.9, 0.0, 0.0, -0.9, $
       0.4, 0.5, -0.5, 1.0, -0.2, 0.8, -0.1, 0.3, 0.1, 0.5, -0.4, -0.3]

h15 = [0.0, 0.0, 4797.1, 0.0, -2845.6, -641.9, 0.0, -115.3, 244.9, -538.4, 0.0, $
       283.3, -188.7, 180.9, -329.5, 0.0, 47.3, 197.0, -119.3, 16.0, 100.2, 0.0, $
       -20.8, 33.2, 58.9, -66.7, 7.3, 62.6, 0.0, -54.1, -19.5, 5.7, 24.4, 3.4, $
       -27.4, -2.2, 0.0, 10.1, -18.3, 13.3, -14.6, 16.2, 5.7, -9.1, 2.1, 0.0, $
       -21.6, 10.8, 11.8, -6.8, -6.9, 7.8, 1.0, -4.0, 8.4, 0.0, 3.2, -0.4, 4.6, $
       4.4, -7.9, -0.6, -4.2, -2.8, -1.2, -8.7, 0.0, -0.1, 2.0, -0.7, -1.1, 0.8, $
       -0.2, -2.2, -1.4, -2.5, -2.0, -2.4, 0.0, -1.1, 0.4, 1.9, -2.2, 0.3, 0.7, $
       -0.1, 0.3, 0.2, -0.9, -0.1, 0.7, 0.0, -0.9, 0.4, 1.6, -0.5, -1.2, -0.1, $
       0.4, -0.1, 0.4, 0.5, -0.3, -0.4, -0.8]

dg15 = [0.0, 10.3, 18.1, -8.7, -3.3, 2.1, 3.4, -5.5, -0.7, -10.1, -0.7, 0.2, -9.1, $
       4.1, -4.3, -0.2, 0.5, -1.3, -0.1, 1.4, 3.9, -0.3, -0.1, -0.7, 2.1, -1.2, $
       0.3, 1.6, 0.3, -0.2, -0.5, 1.3, 0.1, -0.6, -0.8, 0.2, 0.2, 0.0, -0.6, 0.5, $
       -0.2, 0.4, 0.1, -0.4, 0.3]
       
       
dh15 = [0.0, 0.0, -26.6, 0.0, -27.4, -14.1, 0.0, 8.2, -0.4, 1.8, 0.0, -1.3, 5.3, $
        2.9, -5.2, 0.0, 0.6, 1.7, -1.2, 3.4, 0.0, 0.0, 0.0, -2.1, -0.7, 0.2, 0.9, $
        1.0, 0.0, 0.8, 0.4, -0.2, -0.3, -0.6, 0.1, -0.2, 0.0, -0.3, 0.3, 0.1, 0.5, $
        -0.2, -0.3, 0.3, 0.0]

;     save iy,id,ipr

      if N_ELEMENTS(iy)  EQ 0 THEN iy=-1
      if N_ELEMENTS(id)  EQ 0 THEN id=-1
      if N_ELEMENTS(ipr) EQ 0 THEN ipr=-1

; ----------------------------------------------------------------------

     f10="(' * ROCOTLIB/cdipdir: Warning! year=',i4.4," + $
        "'   dipole direction can be computed between 1965-2015.',"+ $
        "'   It will be computed for year ',i4.4)"

; *** Computation are not done if date is the same as previous call

      if(iyear EQ iy AND idoy EQ id) then return

      iy=iyear
      id=idoy
      iday=idoy
      
      defsysv,'!cotrans_lib',exists=exists
      
      if exists && !cotrans_lib.nolimit_igrf then begin
        ; do nothing
      endif else begin
        ; *** Check date interval of validity

        ;     we are restricted by the interval 1965-2015, for which the igrf
        ;     coefficients are known;
        ;     if iyear is outside this interval, then the subroutine uses the
        ;     nearest limiting value and prints a warning:
        if(iy LT 1965) then BEGIN
          iy=1965
          if(ipr NE 1) then dprint,  format=f10, iyear, iy
          ipr=1
        endif

        if(iy GT 2020) then BEGIN
          iy=2020
          if(ipr NE 1) then dprint,  format=f10, iyear, iy
          ipr=1
        endif
      endelse

; *** Starting computations

      if (iy LT 1970) then goto, G50      ;interpolate between 1965 - 1970
      if (iy LT 1975) then goto, G60      ;interpolate between 1970 - 1975
      if (iy LT 1980) then goto, G70      ;interpolate between 1975 - 1980
      if (iy LT 1985) then goto, G80      ;interpolate between 1980 - 1985
      if (iy LT 1990) then goto, G90      ;interpolate between 1985 - 1990
      if (iy LT 1995) then goto, G100     ;interpolate between 1990 - 1995
      if (iy LT 2000) then goto, G110     ;interpolate between 1995 - 2000
      if (iy LT 2005) then goto, G120     ;interpolate between 2000 - 2005
      if (iy LT 2010) then goto, G130     ;interpolate between 2005 - 2010
      if (iy LT 2015) then goto, G140     ;interpolate between 2010 - 2015

;     extrapolate beyond 2015:

      dt=float(iy)+float(iday-1)/365.25 -2015.
      for n=0, nloop DO BEGIN
        g[n]=g15[n]
        h[n]=h15[n]
;        if (n.gt.45) goto 40
        if (n GT 44) then goto, G40
        g[n]=g[n]+dg15[n]*dt
        h[n]=h[n]+dh15[n]*dt
 G40:
      endfor
      goto, G300

;     interpolate betweeen 1965 - 1970:

 G50: f2=(float(iy)+float(iday-1)/365.25 -1965)/5.
      f1=1.-f2
      for n=0, nloop DO BEGIN
        g[n]=g65[n]*f1+g70[n]*f2
        h[n]=h65[n]*f1+h70[n]*f2
      endfor
      goto, G300

;     interpolate between 1970 - 1975:

 G60: f2=(float(iy)+float(iday-1)/365.25 -1970)/5.
      f1=1.-f2
      for n=0, nloop DO BEGIN
        g[n]=g70[n]*f1+g75[n]*f2
        h[n]=h70[n]*f1+h75[n]*f2
      endfor
      goto, G300

;     interpolate between 1975 - 1980:

 G70: f2=(float(iy)+float(iday-1)/365.25 -1975)/5.
      f1=1.-f2
      for n=0, nloop DO BEGIN
        g[n]=g75[n]*f1+g80[n]*f2
        h[n]=h75[n]*f1+h80[n]*f2
      endfor
      goto, G300

;     interpolate between 1980 - 1985:

 G80: f2=(float(iy)+float(iday-1)/365.25 -1980)/5.
      f1=1.-f2
      for n=0, nloop DO BEGIN
        g[n]=g80[n]*f1+g85[n]*f2
        h[n]=h80[n]*f1+h85[n]*f2
      endfor
      goto, G300

;     interpolate between 1985 - 1990:

 G90: f2=(float(iy)+float(iday-1)/365.25 -1985)/5.
      f1=1.-f2
      for n=0, nloop DO BEGIN
        g[n]=g85[n]*f1+g90[n]*f2
        h[n]=h85[n]*f1+h90[n]*f2
      endfor
      goto, G300

;     interpolate between 1990 - 1995:

G100: f2=(float(iy)+float(iday-1)/365.25 -1990)/5.
      f1=1.-f2
      for n=0, nloop DO BEGIN
        g[n]=g90[n]*f1+g95[n]*f2
        h[n]=h90[n]*f1+h95[n]*f2
      endfor
      goto, G300

;     interpolate between 1995 - 2000:

G110: f2=(float(iy)+float(iday-1)/365.25 -1995)/5.
      f1=1.-f2
      for n=0, nloop DO BEGIN
;     the 2000 coefficients (g00) go through the order 13, not 10
        g[n]=g95[n]*f1+g00[n]*f2
        h[n]=h95[n]*f1+h00[n]*f2
      endfor
      goto, G300

;     interpolate between 2000 - 2005:

G120: f2=(float(iy)+float(iday-1)/365.25 -2000)/5.
      f1=1.-f2
      for n=0, nloop DO BEGIN
        g[n]=g00[n]*f1+g05[n]*f2
        h[n]=h00[n]*f1+h05[n]*f2
      endfor
      goto, G300
      
;     interpolate between 2005 - 2010:
G130: f2=(float(iy)+float(iday-1)/365.25 -2005)/5.
      f1=1.-f2
      for n=0, nloop DO BEGIN
        g[n]=g05[n]*f1+g10[n]*f2
        h[n]=h05[n]*f1+h10[n]*f2
      endfor
      goto, G300
      
;     interpolate between 2010 - 2015:
G140: f2=(float(iy)+float(iday-1)/365.25 -2010)/5.
      f1=1.-f2
      for n=0, nloop do begin
        g[n]=g10[n]*f1+g15[n]*f2
        h[n]=h10[n]*f1+h15[n]*f2
      endfor
      goto, G300

;   coefficients for a given year have been calculated; now multiply
;   them by schmidt normalization factors:

G300: s=1.

;     do n=2,14
      for n=2,14 DO BEGIN
        mn=n*(n-1)/2 +1
        s=s*float(2*n-3)/float(n-1)
;        g(mn)=g(mn)*s
;        h(mn)=h(mn)*s
        g[mn-1]=g[mn-1]*s
        h[mn-1]=h[mn-1]*s
        p=s

        for m=2,n DO BEGIN
           aa=1.
           if (m EQ 2) then aa=2.
           p=p*sqrt(aa*float(n-m+1)/float(n+m-2))
           mnn=mn+m-1
;           g(mnn)=g(mnn)*p
;           h(mnn)=h(mnn)*p
           g[mnn-1]=g[mnn-1]*p
           h[mnn-1]=h[mnn-1]*p
        endfor
      endfor

;          g10=-g(2)
;          g11= g(3)
;          h11= h(3)

          g10=-g[1]
          g11= g[2]
          h11= h[2]

;     now calculate the components of the unit vector ezmag in geo
;     coord.system:
;     sin(teta0)*cos(lambda0), sin(teta0)*sin(lambda0), and cos(teta0)
;           st0 * cl0                st0 * sl0                ct0

      sq=g11^2 +h11^2
      sqq=sqrt(sq)
      sqr=sqrt(g10^2 +sq)
      sl0=-h11/sqq
      cl0=-g11/sqq
      st0=sqq/sqr
      ct0=g10/sqr

      stcl=st0*cl0
      stsl=st0*sl0

; *** direction of dipole axis in GEO system:

      d1=stcl
      d2=stsl
      d3=ct0

      return
end

;     XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

;
;+
; PROCEDURE cotrans_lib
;   Loads the cotrans_lib library and sets configurations.
;
; USAGE
;   Call cotrans_lib at the beginning of any routine
;   that needs to use any cotrans_lib routines, to ensure
;   that they are compiled.  Configurations are valid until the next call 
;   to cotrans_lib.
; 
; KEYWORDS
;    /nolimit_igrf configure cotrans_lib to remove the arbitrary
;                  5-year limit on extrapolation of IGRF model.
;                  This also isolates dprint code.
;                  NOTE: the configuration will be reset
;                  to 0 if cotrans_lib is called without keywords.  This is
;                  for backwards compatibility:  any routine that calls
;                  cotrans_lib without keywords will get the standard behavior,
;                  regardless of how cotrans_lib was previously configured.
;                  
;                  Note: Use this keyword at your own risk - extrapolating 
;                  these coefficients too far into the future can produce 
;                  non-physical results
;             
;  Written by Hannes Leinweber
;  Modified by Ken Bromund: added /nolimit_igrf configuration
;-
pro cotrans_lib, nolimit_igrf=nolimit_igrf

  cotrans_lib_config = { nolimit_igrf:keyword_set(nolimit_igrf)}

  defsysv,'!cotrans_lib',exists=exists
  if ~keyword_set(exists) then begin
    defsysv, '!cotrans_lib', cotrans_lib_config
  endif else begin
    !cotrans_lib = cotrans_lib_config
  endelse

end
;+
;*****************************************************************************************
;
;  FUNCTION :   load_wi_h0_mfi.pro
;  PURPOSE  :   Loads wind magnetometer high resolution data into "TPLOT".
;
;  CALLED BY:   
;               load_3dp_data.pro
;
;  CALLS:
;               loadallcdf.pro
;               data_type.pro
;               str_element.pro
;               store_data.pro
;               options.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               NA
;
;  EXAMPLES:    
;               
;
;  KEYWORDS:    
;               TIME_RANGE  :  2-Element vector specifying the time range
;               POLAR       :  Also computes the B field in polar coordinates.
;               DATA        :  Data returned in this named variable.
;               HOUR        :  Load hourly averages instead of 3 second data.
;               MINUTE      :  Load 60 second averages instead of 3 second data.
;               NODATA      :  Returns 0 if data exists for time range, otherwise 
;                                returns 1.
;               GSM         :  If set, GSM data is retrieved as well as GSE.
;               PREFIX      :  (string) prefix for tplot variables.  
;                                [Default is 'wi_']
;               NAME        :  (string) name for tplot variables.
;                                [Default is 'wi_Bh']
;               RESOLUTION  :  Resolution to return in seconds.
;               MASTERFILE  :  (string) full filename of master file.
;               
;
;   CHANGED:  1)  P. Schroeder changed something...              [09/25/2003   v1.0.?]
;             2)  Changed plot labels for theta and phi B-fields due to 
;                   font issues                                  [06/19/2008   v1.1.0]
;             3)  Updated man page and fixed some things         [08/05/2010   v1.2.0]
;             4)  Fixed an issue that occurs when calculating the magnitude of B
;                                                                [02/18/2011   v1.2.1]
;
;   NOTES:      
;               1)  If time range is not set, program will call timespan.pro
;
;   CREATED:  ??/??/????
;   CREATED BY:  Peter Schroeder
;    LAST MODIFIED:  02/18/2011   v1.2.1
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

PRO load_wi_h0_mfi,TIME_RANGE=trange,POLAR=polar,DATA=d,HOUR=hour,MINUTE=minute,$
                   NODATA=nodat,GSM=gsm,PREFIX=prefix,NAME=bname, $
                   RESOLUTION=res,MASTERFILE=masterfile

;-----------------------------------------------------------------------------------------
; => Define defaults
;cdfnames = ['B3GSE','B3RMSGSE','B3GSM','B3RMSGSM']
;-----------------------------------------------------------------------------------------
f        = !VALUES.F_NAN
labs     = ['B!dx!n','B!dy!n','B!dz!n']
cdfnames = ['B3GSE','B3GSM']
ppx      = 'B3'
;-----------------------------------------------------------------------------------------
; => Define file name with CDF file locations
;-----------------------------------------------------------------------------------------
IF NOT KEYWORD_SET(masterfile) THEN masterfile = 'wi_h0_mfi_files'
IF KEYWORD_SET(hour) THEN BEGIN
  cdfnames = [cdfnames,'B1GSE']
  ppx2     = 'B1'
ENDIF ELSE ppx2 = ''
IF KEYWORD_SET(minute) THEN BEGIN
  cdfnames = [cdfnames,'BGSE']
  ppx3     = 'Bm'
ENDIF ELSE ppx3 = ''


d     = 0
nodat = 0
;-----------------------------------------------------------------------------------------
; => Load CDF files
;-----------------------------------------------------------------------------------------
loadallcdf,TIME_RANGE=trange,MASTERFILE=masterfile, $
           CDFNAMES=cdfnames,DATA=d,RES=res

IF (KEYWORD_SET(d) EQ 0) THEN BEGIN
   MESSAGE,'No H0 MFI data during this time.',/INFORMATIONAL
   nodat = 1
  RETURN
ENDIF

; data type code:   7 = string

IF (data_type(prefix) EQ 7) THEN px  = prefix ELSE px = 'wi_'
IF (data_type(bname) EQ 7) THEN  px  = bname  ELSE px = px+ppx
IF KEYWORD_SET(gsm) THEN         pxm = px+'_GSM' ELSE pxm = ''
;-----------------------------------------------------------------------------------------
; => Get data out of CDF file return structure
;-----------------------------------------------------------------------------------------
time  = REFORM(d.TIME)
str_element,d,cdfnames[0],bgse
bgse  = TRANSPOSE(bgse)
str_element,d,cdfnames[0],bgsm
bgsm  = TRANSPOSE(bgsm)

;str_element,d,cdfnames(1),brmsgse
;brmsgse = transpose(brmsgse)
;str_element,d,cdfnames(2),bgsm
;bgsm = transpose(bgsm)
;str_element,d,cdfnames(3),brmsgsm
;brmsgsm =transpose(brmsgsm)

bmag = SQRT(TOTAL(bgse^2,2,/NAN))
w    = WHERE(bmag LE 0.,c)
IF (c NE 0) THEN bgse[w,*] = f
IF (c NE 0) THEN bmag[w]   = f
;-----------------------------------------------------------------------------------------
; => Send data to TPLOT
;-----------------------------------------------------------------------------------------
store_data,px+'_MAG(GSE)',DATA={X:time,Y:bmag},MIN=-1e30
store_data,px+'(GSE)',DATA={X:time,Y:bgse},MIN= -1e30,DLIM={LABELS:labs}

options,px+'(GSE)','YTITLE','B [GSE] (nT)'
options,px+'(GSE)','COLORS',[250L,150L,50L]
options,px+'_MAG(GSE)','YTITLE','|B| (nT)'
IF KEYWORD_SET(gsm) THEN BEGIN
  store_data,px+'(GSM)',DATA={X:time,Y:bgsm},MIN= -1e30,DLIM={LABELS:labs}
  options,px+'(GSM)','YTITLE','B [GSM] (nT)'
  options,px+'(GSM)','COLORS',[250L,150L,50L]
ENDIF

nnw = tnames()
options,nnw,'YSTYLE',1
options,nnw,'PANEL_SIZE',2.
options,nnw,'XMINOR',5
options,nnw,'XTICKLEN',0.04

RETURN
END

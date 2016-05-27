;+
;*****************************************************************************************
;
;  FUNCTION :   loadcdf2.pro
;  PURPOSE  :   Loads one type of data from specified cdf file.
;                 The following program will load all of the data for a specific 
;                 CDF file and variable into IDL.
;
;  CALLED BY:   
;               loadcdfstr.pro
;
;  CALLS:
;               cdf_info.pro
;               dimen_shift.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               CDF_FILE   :  String file name (or the CDF id of an open file)
;                               from which to load the data
;               CDF_VAR    :  Scalar string defining the CDF variable to load
;               X0         :  A named variable to return CDF variable data in
;
;  EXAMPLES:    
;               NA
;
;  KEYWORDS:    
;               ZVAR       :  Must set if loaded variable is a Z-Variable
;               APPEND     :  If set, append data to the end of X0 instead of
;                               writing it
;               NO_SHIFT   :  If set, do not perform dimen_shift on data
;               NRECS      :  Number of records to be read
;               REC_START  :  CDF record number to begin reading
;
;   CHANGED:  1)  Jim Byrnes created                         [??/??/????   v1.0.0]
;             2)  Added keyword:  APPEND                     [06/26/1996   v1.0.?]
;             3)  Someone changed something...               [08/13/1998   v1.0.5]
;             4)  Re-wrote and cleaned up                    [06/08/2011   v1.1.0]
;             5)  Fixed typo in ZVAR keyword checking algorithm (EQ -> NE)
;                                                            [08/16/2011   v1.1.1]
;
;   NOTES:      
;               
;
;   CREATED:  ??/??/????
;   CREATED BY:  Jim Byrnes
;    LAST MODIFIED:  08/16/2011   v1.1.1
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

PRO loadcdf2,cdf_file,cdf_var,x0,ZVAR=zvar,APPEND=append,NO_SHIFT=no_shift,$
             NRECS=nrecs,REC_START=rec_start

;-----------------------------------------------------------------------------------------
; => Open CDF file  (if neccesary)
;-----------------------------------------------------------------------------------------
cdftype  = SIZE(cdf_file,/TYPE)
IF (cdftype EQ 7) THEN id = CDF_OPEN(cdf_file) ELSE id = cdf_file
;-----------------------------------------------------------------------------------------
; => Get file CDF structure information
;-----------------------------------------------------------------------------------------
inq   = cdf_info(id)
; => check structure tags
testi = STRLOWCASE(TAG_NAMES(inq))
goodi = WHERE(testi EQ 'dim',gdi)
gdinq = WHERE(testi EQ 'inq',gdq)
;-----------------------------------------------------------------------------------------
; => Get variable structure information
;-----------------------------------------------------------------------------------------
vinq  = CDF_VARINQ(id,cdf_var,ZVARIABLE=zvar)
zvar  = vinq.IS_ZVAR
; => check structure tags
testv = STRLOWCASE(TAG_NAMES(vinq))
goodv = WHERE(testv EQ 'dim',gdv)
; => define CDF dimensions
IF (gdv EQ 0 AND gdi EQ 0) THEN BEGIN
  IF (gdq GT 0) THEN idim = inq.INQ.DIM ELSE idim = [0L]
  vdim = [0L]
ENDIF ELSE BEGIN
  IF (gdv EQ 0 OR gdi EQ 0) THEN BEGIN
    IF (gdv EQ 0) THEN BEGIN
      vdim = [0L]
      idim = inq.DIM
    ENDIF ELSE BEGIN
      idim = [0L]
      vdim = vinq.DIM
    ENDELSE
  ENDIF ELSE BEGIN
    vdim = vinq.DIM
    idim = inq.DIM
  ENDELSE
ENDELSE
;-----------------------------------------------------------------------------------------
; => Get variable attribute information
;-----------------------------------------------------------------------------------------
!QUIET = 1
CDF_CONTROL,id,VARIABLE=cdf_var,GET_VAR_INFO=varinfo
!QUIET = 0

IF NOT KEYWORD_SET(nrecs)    THEN nrecs = varinfo.MAXREC + 1
IF (vinq.RECVAR EQ 'NOVARY') THEN nrecs = 1
dims = TOTAL(vinq.DIMVAR)
;-----------------------------------------------------------------------------------------
; => Get variables but determine whether Z-Variable or not first
;-----------------------------------------------------------------------------------------
IF KEYWORD_SET(zvar) THEN BEGIN
  CDF_VARGET,id,cdf_var,x,REC_COUNT=nrecs,ZVARIABLE=zvar,REC_START=rec_start
ENDIF ELSE BEGIN
  dimc = vinq.DIMVAR*idim
  dimw = WHERE(dimc EQ 0,c)
  IF (c NE 0) THEN dimc[dimw] = 1
  CDF_VARGET,id,cdf_var,x,COUNT=dimc,REC_COUNT=nrecs,REC_START=rec_start
ENDELSE
; => Determine if user wants to shift the dimension
test = (vinq.RECVAR EQ 'VARY') AND (dims NE 0)
IF (test AND NOT KEYWORD_SET(no_shift)) THEN BEGIN
  x = dimen_shift(x,1)
ENDIF
test = SIZE(x,/N_DIMENSIONS) GT 0
IF (test) THEN x = REFORM(x,/OVERWRITE)
;-----------------------------------------------------------------------------------------
; => Append to original array if desired
;-----------------------------------------------------------------------------------------
IF (KEYWORD_SET(append) AND KEYWORD_SET(x0)) THEN x0 = [x0,x] ELSE x0 = x
;-----------------------------------------------------------------------------------------
; => Close the CDF file
;-----------------------------------------------------------------------------------------
IF (cdftype EQ 7) THEN CDF_CLOSE,id
;if data_type(cdf_file) eq 7 then cdf_close,id
RETURN
END



;+
; FUNCTION cdfi = cdf_load_vars(file)
; INPUT:
;   file = CDF filename(s)
; OUTPUT:
;   CDFI = A strucutre containing pointers to the data and attributes
;          for the files, with tags:
;   CDFI.FILENAME = The filename(s)
;
;   CDFI.INQ = A structure with information about the file:
;   CDFI.INQ.NDIMS = CDF Dims attribute, for rVariables typically 0
;                  (rVariables are rarely used anymore See http://cdf.gsfc.nasa.gov/html/FAQ.html#intro)
;   CDFI.INQ.DECODING = 'HOST_DECODING' (can be network or host)
;   CDFI.INQ.ENCODING = 'NETWORK_ENCODING' (can be network or host)
;   CDFI.INQ.MAJORITY = 'ROW_MAJOR' (can be row or column)
;   CDFI.INQ.MAXREC = Max number of records (Default is -1)
;   CDFI.INQ.NVARS =  number of rVariables, usually 0 
;   CDFI.INQ.NZVARS = number of zVariables, usually all of them
;   CDFI.INQ.NATTS = number of variable attributes 
;   CDFI.INQ.DIM = dimensions of rVariables
;
;   CDFI.g_atttributes = CDF global attributes, strucuture varies
;   Here is a sample from THEMIS EFI:
;
;   PROJECT         STRING    'THEMIS'
;   SOURCE_NAME     STRING    'THA>Themis Probe A'
;   DISCIPLINE      STRING    'Space Physics>Magnetospheric Science'
;   DATA_TYPE       STRING    'EFI'
;   DESCRIPTOR      STRING    'L2>L2 DATA'
;   DATA_VERSION    STRING    '1'
;   PI_NAME         STRING    'V. Angelopoulos, J. Bonnell & F. Mozer'
;   PI_AFFILIATION  STRING    'UCB, NASA NAS5-02099'
;   TITLE           STRING    'Electric Field Instrument (EFI) Measurements'
;   TEXT            STRING    'THEMIS-A: Electric Field Instrument (EFI) Electric field measurements. The L2 product is a 3D estimate of'...
;   INSTRUMENT_TYPE STRING    'Electric Fields (space)'
;   MISSION_GROUP   STRING    'THEMIS'
;   LOGICAL_SOURCE  STRING    'tha_l2_efi'
;   LOGICAL_FILE_ID STRING    'tha_l2_efi_20131001_v01'
;   LOGICAL_SOURCE_DESCRIPTION
;                   STRING    'Spacecraft-collected (EFI) Electric field'
;   TIME_RESOLUTION STRING    '3-1/8s'
;   RULES_OF_USE    STRING    'Open Data for Scientific Use'
;   GENERATED_BY    STRING    'THEMIS SOC'
;   GENERATION_DATE STRING    'Sun Oct  6 03:11:38 2013'
;   ACKNOWLEDGEMENT STRING    'NASA Contract NAS5-02099'
;   MODS            STRING    'Rev- 2009-09-16'
;   ADID_REF        STRING    'NSSD0110'
;   LINK_TEXT       STRING    Array[3]
;   LINK_TITLE      STRING    Array[3]
;   HTTP_LINK       STRING    Array[3]
;   FILE_NAMING_CONVENTION
;                   STRING    'source_descriptor_datatype'
;   CAVEATS         STRING    'See THEMIS website for caveats'
;   VALIDITY        STRING    'to be validated'
;   VALIDATOR       STRING    'tbd'
;   VALIDATE        STRING    'Compatible with the ISTP CDF Standards'
;   INST_MOD        STRING    'THM>xxxx'
;   PARENTS         STRING    'xxxx'
;   INST_SETTINGS   STRING    'Not used'
;   SOFTWARE_VERSION                                                                           
;                   STRING    '13273'
;
;  CDFI.NV = Number of variables
;
;  CDFI.VARS = AN array of CDFI.NV structures, one for each zvariable:
;  CDFI.VARS.NAME = The variable name
;  CDFI.VARS.NUM  = The index of the given variable in the cdfi.vars array
;  CDFI.VARS.IS_ZVAR = 1 for a zVariable
;  CDFI.VARS.DATATYPE = The data type, e.g.'CDF_FLOAT'
;  CDFI.VARS.TYPE = The nummerical IDL data type (float is 4, etc...)
;  CDFI.VARS.NUMATTR = -1,  Not sure about this one, returned from CDF_VARGET
;  CDFI.VARS.NUMELEM = Number of elements in a record, returned from CDF_VARGET
;  CDFI.VARS.RECVARY = Set to 1 if variable varies from record to record
;  CDFI.VARS.NUMREC = the number of records input.
;  CDFI.VARS.NDIMEN = the number dimensions in the data
;  CDFI.VARS.D = A six-element array with the number of dimensions for
;                each index
;  CDFI.VARS.DATAPTR = A pointer to the data array:
;  CDFI.VARS.ATTRPTR  = A pointer to the varaible attributes
;                       structure for each variable. Content varies,
;                       here is a sample from THEMIS EFI Electric
;                       field data:
;   CATDESC         STRING    'EFF_DOT0 (fast-survey, 1/8 sec time resolution, using E dot B=0) electric field vector in GSM coordinates'...
;   FIELDNAM        STRING    'EFF_DOT0 (fast-survey, 1/8 sec time resolution, using E dot B=0) electric field vector in GSM coordinates'...
;   FILLVAL         FLOAT               NaN
;   VALIDMIN        FLOAT     Array[3]
;   VALIDMAX        FLOAT     Array[3]
;   VAR_TYPE        STRING    'data'
;   DISPLAY_TYPE    STRING    'time_series'
;   FORMAT          STRING    'E13.6'
;   LABL_PTR_1      STRING    'tha_eff_dot0_gsm_labl'
;   UNITS           STRING    'mV/m'
;   DEPEND_TIME     STRING    'tha_eff_dot0_time'
;   DEPEND_EPOCH0   STRING    'tha_eff_dot0_epoch0'
;   DEPEND_0        STRING    'tha_eff_dot0_epoch'
;   DEPEND_1        STRING    'tha_eff_dot0_gsm_compno'
;   VAR_NOTES       STRING    'Units are in mV/m'
;   COORDINATE_SYSTEM
;                   STRING    'GSM'
;   REPRESENTATION_1
;                   STRING    'Rep_xyz_gsm'
;   TENSOR_ORDER    STRING    '1'
;   AVG_TYPE        STRING    'standard'
;   PROPERTY        STRING    'vector'
;   SC_ID           STRING    'a'
;   SCALE_TYP       STRING    'linear'
;   DICT_KEY        STRING    'electric_field>vector_GSM'
;   SI_CONVERSION   STRING    '1e-3>V/m'
;   LABEL_1         STRING    'tha_eff_dot0_gsm_labl'
; 

; Each variable may have a different set of attributes, but this
; example is a minimal structure that will be ISTP compliant.
;
; KEYWORDS:
;   VARFORMAT = string or string array:  a string or string array (which may contain wildcard
;                         characters) that specifies the CDF variable names to load.  Use
;                          'VARFORMAT='*' to load all variables. NOTE
;                          THAT VARFORMAT MUST BE SET IF YOU ACTUALLY
;                          WANT TO READ DATA.
;   VARNAMES = named variable   ;output variable for variable names that were loaded.
;   SPDF_DEPENDENCIES :   Set to 1 to have SPDF defined dependent variables also loaded.
;   VAR_TYPE = string or string array;  Variables that have a VAR_TYPE matching these strings will
;                         be loaded.
;   CONVERT_INT1_TO_INT2  Set this keyword to convert signed one byte to signed 2 byte integers.
;                         This is useful because IDL does not have the equivalent of INT1   (bytes are unsigned)
;   RECORD: Specify the record index where you want to start reading.  By default, this option will read one record.
;   NUMBER_RECORDS: Specify the number of records that you want to read.  By default, this option will begin at record zero.
; 
; Note: Record & Number_Records can be used together to specify a range of records to be read.
;
; Author: Davin Larson - 2006
; 
; Side Effects:
;   Data is returned in pointer variables. Calling routine is responsible for freeing up heap memory - otherwise a memory leak will occur.
;
; $LastChangedBy: davin-mac $
; $LastChangedDate: 2014-06-04 08:35:27 -0700 (Wed, 04 Jun 2014) $
; $LastChangedRevision: 15302 $
; $URL: svn+ssh://thmsvn@ambrosia.ssl.berkeley.edu/repos/spdsoft/trunk/general/CDF/cdf_load_vars.pro $
;
;-
function cdf_load_vars,files,varnames=vars,varformat=vars_fmt,info=info,verbose=verbose,all=all, $
    record=record,convert_int1_to_int2=convert_int1_to_int2, $
    spdf_dependencies=spdf_dependencies, $
    var_type=var_type, $
    no_attributes=no_attributes,$
    number_records=number_records

vb = keyword_set(verbose) ? verbose : 0
vars=''
info = 0
dprint,dlevel=4,verbose=verbose,'$Id: cdf_load_vars.pro 15302 2014-06-04 15:35:27Z davin-mac $'

on_ioerror, ferr
for fi=0,n_elements(files)-1 do begin
    if file_test(files[fi]) eq 0 then begin
        dprint,dlevel=1,verbose=verbose,'File not found: "'+files[fi]+'"'
        continue
    endif
    id=cdf_open(files[fi])
    if not keyword_set(info) then begin
        info = cdf_info(id,verbose=verbose) ;, convert_int1_to_int2=convert_int1_to_int2)
    endif  
    ; if there are no variables loaded
    if info.nv eq 0 or ~is_struct(info.vars) then begin
         dprint,verbose=verbose,'No valid variables in the CDF file!'
         return,info
    endif  
    
    if n_elements(spdf_dependencies) eq 0 then spdf_dependencies =1

    if not keyword_set(vars) then begin
        if keyword_set(all) then vars_fmt = '*'
        if keyword_set(vars_fmt) then vars = [vars, strfilter(info.vars.name,vars_fmt,delimiter=' ')]
        if keyword_set(var_type) then begin
            vtypes = strarr(info.nv)
            for v=0,info.nv-1 do begin
                vtypes[v] = cdf_var_atts(id,info.vars[v].num,zvar=info.vars[v].is_zvar,'VAR_TYPE',default='')
            endfor
            w = strfilter(vtypes,var_type,delimiter=' ',count=count,/index)
            if count ge 1 then vars= [vars, info.vars[w].name] else dprint,dlevel=1,verbose=verbose,'No VAR_TYPE matching: ',VAR_TYPE
        endif
        vars = vars[uniq(vars,sort(vars))]
        if n_elements(vars) le 1 then begin
            dprint,verbose=verbose,'No valid variables selected to load!'
            return,info
        endif else vars=vars[1:*]
        vars2=vars

;        if vb ge 4 then printdat,/pgmtrace,vars,width=200

        if keyword_set(spdf_dependencies) then begin  ; Get all the variable names that are dependents
            depnames = ''
            for i=0,n_elements(vars)-1 do begin
                vnum = where(vars[i] eq info.vars.name,nvnum)
                if nvnum eq 0 then message,'This should never happen, report error to D. Larson: davin@ssl.berkeley.edu'
                vi = info.vars[vnum]
                depnames = [depnames, cdf_var_atts(id,vi.num,zvar=vi.is_zvar,'DEPEND_TIME',default='')]   ;bpif vars[i] eq 'tha_fgl'
                depnames = [depnames, cdf_var_atts(id,vi.num,zvar=vi.is_zvar,'DEPEND_0',default='')]
                depnames = [depnames, cdf_var_atts(id,vi.num,zvar=vi.is_zvar,'LABL_PTR_1',default='')]
                ndim = vi.ndimen
                for j=1,ndim do begin
                   depnames = [depnames, cdf_var_atts(id,vi.num,zvar=vi.is_zvar,'DEPEND_'+strtrim(j,2),default='')]
                endfor
            endfor
            if keyword_set(depnames) then depnames=depnames[[where(depnames)]]
            depnames = depnames[uniq(depnames,sort(depnames))]
            vars2 = [vars2,depnames]
            vars2 = vars2[uniq(vars2,sort(vars2))]
            vars2 = vars2[where(vars2)]
;            if vb ge 4 then printdat,/pgmtrace,depnames,width=200
       endif
    endif

    dprint,dlevel=2,verbose=verbose,'Loading file: "'+files[fi]+'"'
    for j=0,n_elements(vars2)-1 do begin
        w = (where( strcmp(info.vars.name, vars2[j]) , nw))[0]
        if nw ne 0 && cdf_varnum(id,info.vars[w].name) ne -1 then begin ; cdf_varnum call avoids crash for cdfs with non-existent dependent variables
            vi = info.vars[w]
            dprint,verbose=verbose,dlevel=7,vi.name
            
;            if vb ge 9 then  wait,.2
;            if   vi.recvary or 1  then begin ;disabling logic that does nothing, pcruce@igpp.ucla.edu
  
             q=!quiet & !quiet=1 & cdf_control,id,variable=vi.name,get_var_info=vinfo & !quiet=q
             
             ;adding logic to select the number of records that are loaded.  Helps for testing with large CDFs, can be used with the record= keyword
             if n_elements(number_records) ne 0 then begin
               numrec=number_records<(vinfo.maxrec+1)
             endif else begin
               if n_elements(record) ne 0 then begin
                 numrec=1<(vinfo.maxrec+1) 
               endif else begin
                 numrec = vinfo.maxrec+1
               endelse
             endelse
;                dprint,verbose=vb,dlevel=7,vi.name
;                if vb ge 9 then  wait,.2
;            endif else numrec = 0

            if numrec gt 0 then begin
                q = !quiet
                !quiet = keyword_set(convert_int1_to_int2)
                if n_elements(record) ne 0  then begin
                  value = 0 ;THIS line TO AVOID A CDF BUG IN CDF VERSION 3.1
                  cdf_varget,id,vi.name,value ,/string ,rec_start=record,rec_count=numrec
                endif else begin

                  if vi.is_zvar then begin
                    value = 0 ;THIS Line TO AVOID A CDF BUG IN CDF VERSION 3.1
                    cdf_varget,id,vi.name,value ,/string ,rec_count=numrec
                    ;CDF_varget,id,CDF_var,x,REC_COUNT=nrecs,zvariable = zvar,rec_start=rec_start
                  endif else begin

                    if 1 then begin     ; this cluge works but is not efficient!
                      vinq = cdf_varinq(id,vi.num,zvar=vi.is_zvar)
                      dimc = vinq.dimvar * info.inq.dim
                      dimw = where(dimc eq 0,c)
                      if c ne 0 then dimc[dimw] = 1  ;bpif vi.name eq 'ion_vel'
                    endif
                    value = 0   ;THIS Line TO AVOID A CDF BUG IN CDF VERSION 3.1
                    CDF_varget,id,vi.num,zvar=0,value,/string,COUNT=dimc,REC_COUNT=numrec  ;,rec_start=rec_start
                    value = reform(value,/overwrite)
                    dprint,phelp=2,dlevel=5,vi,dimc,value
                  endelse
                endelse
                !quiet = q
                if vi.recvary then begin
                    if (vi.ndimen ge 1 and n_elements(record) eq 0) then begin
                        if numrec eq 1 then begin
                            dprint,dlevel=3,'Warning: Single record! ',vi.name,vi.ndimen,vi.d
                            value = reform(/overwrite,value, [1,size(/dimensions,value)] )  ; Special case for variables with a single record
                        endif else begin
                            transshift = shift(indgen(vi.ndimen+1),1)
                            value=transpose(value,transshift)
                        endelse
                    endif else value = reform(value,/overwrite)
                    if not keyword_set(vi.dataptr) then  vi.dataptr = ptr_new(value,/no_copy)  $
                    else  *vi.dataptr = [*vi.dataptr,temporary(value)]
                endif else begin
                    if not keyword_set(vi.dataptr) then vi.dataptr = ptr_new(value,/no_copy)
                endelse
            endif
            if not keyword_set(vi.attrptr) then $
                vi.attrptr = ptr_new( cdf_var_atts(id,vi.name,convert_int1_to_int2=convert_int1_to_int2) )
            info.vars[w] = vi
        endif else  dprint,dlevel=1,verbose=verbose,'variable "'+vars2[j]+'" not found!'
    endfor
    cdf_close,id
endfor

if keyword_set(info) and keyword_set(convert_int1_to_int2) then begin
    w = where(info.vars.datatype eq 'CDF_INT1',nw)
    for i=0,nw-1 do begin
        v = info.vars[w[i]]
        if ptr_valid(v.dataptr) then begin
            dprint,dlevel=5,verbose=verbose,'Warning: Converting from INT1 to INT2 (',v.name ,')'
            val = *v.dataptr
            *v.dataptr = fix(val) - (val ge 128) * 256
        endif
    endfor
endif

return,info

ferr:
dprint,dlevel=0,"CDF FILE ERROR in: ",files[fi]
msg = !error_state.msg ;copy to keep system var from being mutated when MESSAGE is called
message, msg
return,0

end


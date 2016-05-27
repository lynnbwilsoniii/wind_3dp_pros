;+
; PROCEDURE:
;     makecdf, datavary, datanovary=datanovary, filename=filename, status=status, $
;         gattributes=gattr, vattributes=vattr, tagsvary=tagsvary, $
;	  tagsnovary=tagsnovary, overwrite=overwrite
;
; PURPOSE:
;     Creates a CDF file given an array of structures
;
; KEYWORDS:
;     filename:
;         Name of file to be created.
;     datanovary:
;         a structure containing the time invariant data to be written to CDF (like
;         array descriptors).
;     tagsvary:
;         array of strings that will be used as the CDF variable names for the values
;         stored in the datavary structure.  Default CDF variable names are the names
;         of the tags of the datavary structure.
;         Note that, since IDL internally capitalizes all variable and tag names,
;         the CDF variable names will be all caps in the default, so the tagsvary
;         keyword should generally be used to control capitalization of the CDF variable
;         names.
;     tagsnovary:
;         array of strings that will be used as the CDF variable names for the values
;         stored in the datanovary structure.  Default CDF variable names are the names
;         of the tags of the datanovary structure.
;         Note that, since IDL internally capitalizes all variable and tag names,
;         the CDF variable names will be all caps in the default, so the tagsnovary
;         keyword should generally be used to control capitalization of the CDF variable
;         names.
;     gattributes:
;         a structure specifying the names, entry numbers, and values of the global
;         CDF attributes that will be written to the CDF file.
;         The tagnames of the gattributes structure are actually dummy placeholders
;         which are not used (but must all be unique, or course).
;         The value of each field is a struture containing three fields, 'name',
;         which contains the name of the attribute, 'entry', which contains the entry
;         number (many attributes contain just a single entry, generally just entry 0,
;         and some contain several entries, generally entries 0,1,2,3, etc), and
;         'value' which contains the value of the attribute for the specified entry.
;         (see the example below)
;     vattributes:
;         a structure specifying, for each CDF variable that has variable attributes,
;         the names and values of the variable CDF attributes that will be written to
;         the CDF file.  The tagnames of the vattributes structure are actually dummy
;         placeholders and are not used.  The values of the fields of the vattributes
;         structure should each be a structure, with a 'varname' field containing the
;         name of a CDF variable, and an 'attrlist' field which contains a structure
;         containing the set of attribute names and values for the specified variable.
;         (see the example below)
;     overwrite:
;         if set, overwrite any existing CDF file with the specified name (default
;         is to not overwrite any such existing file).
;     status:
;         status is 0 on successful return, nonzero on unsuccessful return.
;         A routine that calls makecdf should in general use the status keyword parameter
;         and verify that the CDF write has completed successfully.
;  
; INPUT:
;     datavary:
;         an array of structures containing the time variant data to be written to CDF.
;         Each element of the array is a structure containing the values for one time.
;         Datavary must have a tag named 'time' that contains the time in seconds since
;         01-01-1970/00:00:00 UT.  An additional CDF variable named 'Epoch', of type
;         CDF_EPOCH, will be written to the CDF, and will be computed from 'time'.
;
; EXAMPLE:
;     To make a CDF file named 'foo.cdf' containing tplot variables 'el_0' and 'el_high',
;     and with two global attributes, named 'foo' (with one entry with value 'bar') and
;     'goo' (with two entries, one with value 1.0, and one with value 2.0),
;     and with two variable attributes, 'VALIDMIN' and 'VALIDMAX', with VALIDMIN for el_0
;     to be set to 1.0, and VALIDMAX of el_0 to be set to 2.0, and VALIDMIN of el_high to
;     be set to 1.0 and VALIDMAX of el_high to be set to 2.0,
;     give the following IDL commands:
;
;         > make_cdf_structs, ['el_0', 'el_high'], datavary, datanovary
;         > gattr = {foo0: {name:'foo', entry:0, value:'bar'}, $
;                    goo0: {name:'goo', entry:0, value:1.0  }, $
;                    goo1: {name:'goo', entry:1, value:2.0  }}
;         > vattr_el_0    = {VALIDMIN:1.0, VALIDMAX:2.0}
;         > vattr_el_high = {VALIDMIN:1.0, VALIDMAX:2.0}
;         > vattr = {el_0:    {varname:'el_0',    attrlist:vattr_el_0},  $
;                    el_high: {varname:'el_high', attrlist:vattr_el_high}}
;         > makecdf, file='foo', datavary, datanovary=datanovary, $
;               tagsvary=['time', 'el_0', 'el_high'], tagsnovary=['el_0_en', 'el_high_pa'], $
;               gattr=gattr, vattr=vattr
;
;     Note that, in the above specification of vattr, the names of the CDF variables (el_0
;     and el_high in this example), appear to be repeated in two places each.  The first
;     occurrence of each, in the tagname, is actually just an unused dummy, and the second
;     occurrence of each, in the string value of varname, is the CDF variable name.  This
;     is because IDL variable names and tag names can't be used to specify the more general
;     strings that CDF variable names can have.  Similarly with gattr.
;
;     The resulting CDF file will contain an Epoch variable (computed from the time),
;     a time variable (taken by default from the 'x' component of the first named tplot
;     variable, but specifiable otherwise by the 'times' keyword to 'make_cdf_structs'),
;     and, for each tplot variable named in the argument list to 'make_cdf_structs', the
;     'y' component, with a name taken from 'tagsvary', and the 'v' component, with a
;     name taken from 'tagsnovary'.
;     Thus the CDF file from the above commands will contain the CDF variables
;         Epoch:
;             This is of type CDF_EPOCH, and is calculated from the time variable below
;         time:
;             by default, the 'x' tag from the tplot variable 'el_0'
;         el_0:
;             the 'y' tag from the tplot variable 'el_0'
;         el_high:
;             the 'y' tag from the tplot variable 'el_high'
;         el_0_en:
;             the 'v' tag from the tplot variable 'el_0'
;         el_high_pa:
;             the 'v' tag from the tplot variable 'el_high'
;
;
; SEE ALSO:
;     "loadcdf", "loadcdfstr"
;     "make_cdf_structs.pro", "strarr_to_arrstr.pro"
;
; VERSION: @(#)makecdf.pro	1.6 08/13/98
;-

pro makecdf , datavary, datanovary=datanovary, filename=filename, status=status,  $
  tagsvary=tagsvary, tagsnovary=tagsnovary, overwrite=overwrite, $
  gattributes=gattr, vattributes=vattr

status = -1
if not keyword_set(filename) then begin
    message, "keyword 'filename' must be set"
    return
endif

if keyword_set(overwrite) then begin
  on_ioerror, create
  id = cdf_open(filename)
  cdf_delete,id
  create:
  on_ioerror,null
endif

id = cdf_create(filename, /single)

;
; Create and write the values of the global attributes
;
if keyword_set(gattr) then begin
    for i = 0, n_tags(gattr) - 1 do begin
	attrname  = gattr.(i).name
	attrentry = gattr.(i).entry
	attrvalue = gattr.(i).value
        if not cdf_attr_exists(id, attrname) then begin
	    attr_id = cdf_attcreate(id, attrname, /GLOBAL_SCOPE)
        endif
	cdf_attput, id, attr_id, attrentry, attrvalue
    endfor
endif

;
; Write out all the record variant data
;
if keyword_set(tagsvary) then begin
    if n_elements(tagsvary) ne n_tags(datavary) then begin
	message, 'tagsvary has wrong number of elements', /continue
	cdf_delete,id
	return
    endif
endif else tagsvary=tag_names_r(datavary)
ntags = n_elements(tagsvary)
nrecs = n_elements(datavary)
;help,datavary,/str
for n=0,ntags-1 do begin
  d0 = datavary(0)
  dat0=0
  str_element,d0,tagsvary(n),dat0
;help,tagsvary(n),dat0,/str
  nd = ndimen(dat0)
  dim = dimen(dat0)
  type = data_type(dat0)
  dat = 0
  str_element,datavary,tagsvary(n),dat
;help,tagsvary(n),dat,/str
  if nd ne 0 then begin
    case data_type(dat) of
     1:  zid = cdf_varcreate(id,tagsvary(n),dim ne 0,dim=dim,/cdf_uchar)
     2:  zid = cdf_varcreate(id,tagsvary(n),dim ne 0,dim=dim,/cdf_int2)
     3:  zid = cdf_varcreate(id,tagsvary(n),dim ne 0,dim=dim,/cdf_int4)
     4:  zid = cdf_varcreate(id,tagsvary(n),dim ne 0,dim=dim,/cdf_float)
     5:  zid = cdf_varcreate(id,tagsvary(n),dim ne 0,dim=dim,/cdf_double)
    endcase
  endif else begin
    case data_type(dat) of
     1:  zid = cdf_varcreate(id,tagsvary(n),/zvar,/cdf_uchar)
     2:  zid = cdf_varcreate(id,tagsvary(n),/zvar,/cdf_int2)
     3:  zid = cdf_varcreate(id,tagsvary(n),/zvar,/cdf_int4)
     4:  zid = cdf_varcreate(id,tagsvary(n),/zvar,/cdf_float)
     5:  zid = cdf_varcreate(id,tagsvary(n),/zvar,/cdf_double)
    endcase
  endelse   
  cdf_varput,id,tagsvary(n),dat
endfor

;
; Write out all the non record variant data
;
if keyword_set(datanovary) then begin
    if keyword_set(tagsnovary) then begin
        if n_elements(tagsnovary) ne n_tags(datanovary) then begin
	    message, 'tagsnovary has wrong number of elements', /continue
	    cdf_delete,id
	    return
        endif
    endif else tagsnovary=tag_names(datanovary)
    ntags = n_elements(tagsnovary)
    nrecs = n_elements(datanovary)
    for n=0,ntags-1 do begin
      d0 = datanovary(0)
      nd = ndimen(d0.(n))
      dim = dimen(d0.(n))
      type = data_type(d0.(n))
      dat = datanovary.(n)
      if nd ne 0 then begin
        case data_type(dat) of
         1:  zid = cdf_varcreate(id,tagsnovary(n),dim ne 0,dim=dim,/cdf_uchar,/rec_novary)
         2:  zid = cdf_varcreate(id,tagsnovary(n),dim ne 0,dim=dim,/cdf_int2,/rec_novary)
         3:  zid = cdf_varcreate(id,tagsnovary(n),dim ne 0,dim=dim,/cdf_int4,/rec_novary)
         4:  zid = cdf_varcreate(id,tagsnovary(n),dim ne 0,dim=dim,/cdf_float,/rec_novary)
         5:  zid = cdf_varcreate(id,tagsnovary(n),dim ne 0,dim=dim,/cdf_double,/rec_novary)
        endcase
      endif else begin
        case data_type(dat) of
         1:  zid = cdf_varcreate(id,tagsnovary(n),/zvar,/cdf_uchar,/rec_novary)
         2:  zid = cdf_varcreate(id,tagsnovary(n),/zvar,/cdf_int2,/rec_novary)
         3:  zid = cdf_varcreate(id,tagsnovary(n),/zvar,/cdf_int4,/rec_novary)
         4:  zid = cdf_varcreate(id,tagsnovary(n),/zvar,/cdf_float,/rec_novary)
         5:  zid = cdf_varcreate(id,tagsnovary(n),/zvar,/cdf_double,/rec_novary)
        endcase
      endelse   
      cdf_varput,id,tagsnovary(n),dat
    endfor
endif

;
; Write out the variable attributes for all variables, creating each when necessary
;
if keyword_set(vattr) then begin
    for i = 0, n_tags(vattr) - 1 do begin
        varname  = vattr.(i).varname
        attrlist = vattr.(i).attrlist
        for j = 0, n_tags(attrlist) - 1 do begin
            attrname  = (tag_names(attrlist))(j)
            attrvalue = attrlist.(j)
            if not cdf_attr_exists(id, attrname) then begin
                attr_id = cdf_attcreate(id, attrname, /variable)
            endif
            cdf_attput, id, attrname, varname, attrvalue
        endfor
    endfor
endif

epoch0 = 719528.d * 24.* 3600. * 1000.  ;Jan 1, 1970
epoch = datavary.time  * 1000. + epoch0
zid = cdf_varcreate(id,'Epoch',/CDF_EPOCH)
cdf_varput,id,'Epoch',epoch

cdf_close,id
status = 0
return
end


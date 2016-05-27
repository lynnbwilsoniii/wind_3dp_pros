;+
;*****************************************************************************************
;
;  FUNCTION :   pesa_high_dummy_str.pro
;  PURPOSE  :   Returns a Pesa High dummy data structure for structure replication.
;
;  CALLED BY: 
;               dummy_pesa_struct.pro
;
;  CALLS:       NA
;
;
;  REQUIRES:    NA
;
;  INPUT:
;               NSTR     :  [string] Name of structure [i.e. 'Pesa High']
;               NBINS    :  [long] # of data bins
;               MAPCODE  :  [long] Converted Hex # associated with NBINS
;
;  EXAMPLES:    NA
;
;  KEYWORDS:    NA
;
;   CHANGED:  1)  Updated man page               [03/19/2009   v1.0.1]
;             2)  Updated man page               [04/27/2010   v1.0.2]
;
;   CREATED:  08/18/2008
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  04/27/2010   v1.0.2
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION pesa_high_dummy_str,nstr,nbins,mapcode

myn = nstr
ph_str = CREATE_STRUCT('PROJECT_NAME','Wind 3D Plasma','DATA_NAME',myn,      $
             'UNITS_NAME','Counts','UNITS_PROCEDURE','convert_esa_units',    $
             'TIME',0d0,'END_TIME',0d0,'TRANGE',[0d0,0d0],'INTEG_T',0d0,     $
             'DELTA_T',0d0,'DEADTIME',FLTARR(15,nbins),'DT',FLTARR(15,nbins),$
             'VALID',0,'SPIN',0l,'SHIFT',0b,'INDEX',0l,'MAPCODE',            $
             LONG(mapcode),'DOUBLE_SWEEP',0b,'NENERGY',15,'NBINS',nbins,    $
             'BINS',REPLICATE(1b,15,nbins),'PT_MAP', INTARR(32,24),'DATA',   $
             FLTARR(15,nbins),'ENERGY',FLTARR(15,nbins),'DENERGY',           $
             FLTARR(15,nbins),'PHI',FLTARR(15,nbins),'DPHI',FLTARR(15,nbins),$
             'THETA',FLTARR(15,nbins),'DTHETA',FLTARR(15,nbins),'BKGRATE',   $
             FLTARR(15,nbins),'DVOLUME',FLTARR(15,nbins),'DDATA',            $
             REPLICATE(!VALUES.F_NAN,15,nbins),'DOMEGA',FLTARR(nbins),       $
             'DACCODES',INTARR(30*4),'VOLTS',FLTARR(30*4),'MASS',0d0,        $
             'GEOMFACTOR',0d0,'GF',FLTARR(15,nbins),'MAGF',                  $
             REPLICATE(!VALUES.F_NAN,3),'SC_POT',0.0)

RETURN,ph_str
END

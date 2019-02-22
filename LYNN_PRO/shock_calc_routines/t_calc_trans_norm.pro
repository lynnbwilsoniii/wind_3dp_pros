;+
;*****************************************************************************************
;
;  FUNCTION :   t_calc_trans_norm.pro
;  PURPOSE  :   This routine calculates two projections of an input vector relative to
;                 an input unit normal vector.  The projections are parallel and
;                 transverse to the input unit normal vector.  These results are sent
;                 back to TPLOT:  Vn = (n . V) n,  Vt = n x (V x n)
;                 where the 1st result is the parallel and the 2nd is the transverse
;                 component.  Note that V^2 = (Vn . Vn) + (Vt . Vt), thus each projection
;                 comprises part of the original input vector.
;
;  CALLED BY:   
;               NA
;
;  CALLS:
;               tnames.pro
;               get_data.pro
;               tplot_struct_format_test.pro
;               my_dot_prod.pro
;               my_crossp_2.pro
;               str_element.pro
;               store_data.pro
;
;  REQUIRES:    
;               1)  THEMIS TDAS IDL libraries or UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               TVEC      :  Scalar [string] defining the TPLOT handle associated with
;                              the vector the user wishes to project
;               NVEC      :  [3]-Element [float/double] array defining the unit normal
;                              vector to use for the projections
;                              { Default = [1,0,0] }
;
;  EXAMPLES:    
;               nvec  = [0.995,0.021,0.011]
;               tvec  = 'thc_fgh_gse'
;               yttln = 'B!Dn!N [= (n . B) n, THC fgh, nT]'
;               yttlt = 'B!Dt!N [= n x (V x n), THC fgh, nT]'
;               test  = t_calc_trans_norm(tvec,nvec,TV_BASIS='GSE',TV_FRAME='SC',$
;                                         OUT_YTLN=yttln,OUT_YTLT=yttlt)
;
;  KEYWORDS:    
;               OUT_TNMN  :  Scalar [string] defining the TPLOT handle to use for the
;                              Vn = [(n . V) n] output result
;                              { Default = TVEC+'_ndotV_n' }
;               OUT_TNMT  :  Scalar [string] defining the TPLOT handle to use for the
;                              Vt = [n x (V x n)] output result
;                              { Default = TVEC+'_nxVxn' }
;               TV_BASIS  :  Scalar [string] defining the name of the coordinate basis
;                              associated with TVEC
;                              { Default = 'ICB' [see definition below]}
;               TV_FRAME  :  Scalar [string] defining the name of the reference frame
;                              associated with TVEC
;                              { Default = 'SCF' [see definition below]}
;               OUT_YTLN  :  Scalar [string] defining the new Y-Axis title to use for
;                              the Vn = [(n . V) n] output result
;                              { Default = 'V!Dn!N = [(n . V) n]' }
;               OUT_YTLT  :  Scalar [string] defining the new Y-Axis title to use for
;                              the Vt = [n x (V x n)] output result
;                              { Default = 'V!Dt!N = [n x (V x n)]' }
;
;   CHANGED:  1)  NA [MM/DD/YYYY   v1.0.0]
;
;   NOTES:      
;               1)  Definitions:
;                     ICB  :  Input Coordinate Basis (e.g., GSE)
;                     NIF  :  Normal Incidence Frame
;                     SCF  :  SpaceCraft Frame
;                     NCB  :  Normal Incidence Frame Coordinate Basis
;                     SRF  :  Shock Rest Frame
;
;  REFERENCES:  
;               1)  Scudder, J.D., A. Mangeney, C. Lacombe, C.C. Harvey, T.L. Aggson,
;                      R.R. Anderson, J.T. Gosling, G. Paschmann, and C.T. Russell
;                      (1986a) "The Resolved Layer of a Collisionless, High ß,
;                      Supercritical, Quasi-Perpendicular Shock Wave 1:
;                      Rankine-Hugoniot Geometry, Currents, and Stationarity,"
;                      J. Geophys. Res. Vol. 91, pp. 11,019-11,052.
;               2)  Scudder, J.D., A. Mangeney, C. Lacombe, C.C. Harvey, T.L. Aggson
;                      (1986b) "The Resolved Layer of a Collisionless, High ß,
;                      Supercritical, Quasi-Perpendicular Shock Wave 2:
;                      Dissipative Fluid Electrodynamics," J. Geophys. Res. Vol. 91,
;                      pp. 11,053-11,073.
;               3)  Scudder, J.D., A. Mangeney, C. Lacombe, C.C. Harvey, C.S. Wu,
;                      R.R. Anderson (1986c) "The Resolved Layer of a Collisionless,
;                      High ß, Supercritical, Quasi-Perpendicular Shock Wave 3:
;                      Vlasov Electrodynamics," J. Geophys. Res. Vol. 91,
;                      pp. 11,075-11,097.
;               4)  Paschmann, G. and P.W. Daly (1998), "Analysis Methods for Multi-
;                      Spacecraft Data," ISSI Scientific Report, Noordwijk, 
;                      The Netherlands., Int. Space Sci. Inst.
;               5)  Jackson, John David (1999), "Classical Electrodynamics,"
;                      Third Edition, John Wiley & Sons, Inc., New York, NY.,
;                      ISBN 0-471-30932-X
;
;   CREATED:  01/29/2013
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  01/29/2013   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION t_calc_trans_norm,tvec,nvec,OUT_TNMN=out_tnmn,OUT_TNMT=out_tnmt,$
                           TV_BASIS=tv_basis,TV_FRAME=tv_frame,          $
                           OUT_YTLN=out_ytln,OUT_YTLT=out_ytlt

;;----------------------------------------------------------------------------------------
;; => Define some constants and dummy variables
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
;; => Dummy error messages
noinpt_msg     = 'No input supplied...'
badtpn_msg     = 'TVEC is not a valid TPLOT handle...'
notvec_msg     = 'TVEC is not an [N,3]-element vector...'
;; => Define defaults for keywords
def_suffn      = '_ndotV_n'
def_sufft      = '_nxVxn'
def_inbasis    = 'ICB'
def_inframe    = 'SCF'
def_yttln      = 'V!Dn!N = [(n . V) n]'
def_yttlt      = 'V!Dt!N = [n x (V x n)]'
;; => Define output labels and colors
vec_str        = ['x','y','z']
labs_outn      = '[(n . V) n]'+vec_str
labs_outt      = '[n x (V x n)]'+vec_str
cols_out       = [250L,150L, 50L]
;;----------------------------------------------------------------------------------------
;; => Check input
;;----------------------------------------------------------------------------------------
IF (N_PARAMS() LT 1) THEN BEGIN
  ;; => no input???
  MESSAGE,noinpt_msg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0
ENDIF
IF (N_PARAMS() EQ 1) THEN nvec = [1d0,0d0,0d0]
;;  Check TPLOT handle
tvnme_in       = tnames(tvec[0])
IF (tvnme_in[0] EQ '') THEN BEGIN
  ;; => no TPLOT handle???
  MESSAGE,badtpn_msg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0
ENDIF
;;----------------------------------------------------------------------------------------
;; => Get TPLOT data
;;----------------------------------------------------------------------------------------
get_data,tvnme_in[0],DATA=tvec_in,DLIM=dlim_in,LIM=lim_in
;;  Check TPLOT vector structure
testv          = tplot_struct_format_test(tvec_in,/YVECT) EQ 0
IF (testv) THEN BEGIN
  ;; => not vector???
  MESSAGE,notvec_msg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0
ENDIF
;;  Define TVEC parameters
tvec_t         = tvec_in.X
tvec_v         = tvec_in.Y                     ;;  [N,3]-Element array
;;  Re-normalize unit normal vector
nvec_n         = nvec/NORM(nvec)
nv             = N_ELEMENTS(tvec_t)
nvec_n_2d      = REPLICATE(1d0,nv) # nvec_n    ;;  [N,3]-Element array
;;----------------------------------------------------------------------------------------
;; => Check keyword inputs
;;----------------------------------------------------------------------------------------
test_tnoutn    = (N_ELEMENTS(out_tnmn) NE 1) OR (SIZE(out_tnmn,/TYPE) NE 7)
test_tnoutt    = (N_ELEMENTS(out_tnmt) NE 1) OR (SIZE(out_tnmt,/TYPE) NE 7)
test_tvbasi    = (N_ELEMENTS(tv_basis) NE 1) OR (SIZE(tv_basis,/TYPE) NE 7)
test_tvfram    = (N_ELEMENTS(tv_frame) NE 1) OR (SIZE(tv_frame,/TYPE) NE 7)
test_ytoutn    = (N_ELEMENTS(out_ytln) NE 1) OR (SIZE(out_ytln,/TYPE) NE 7)
test_ytoutt    = (N_ELEMENTS(out_ytlt) NE 1) OR (SIZE(out_ytlt,/TYPE) NE 7)
IF (test_tnoutn) THEN BEGIN
  ;;  no output TPLOT handle supplied for Vn
  tn_outn = tvnme_in[0]+def_suffn[0]
ENDIF ELSE BEGIN
  tn_outn = out_tnmn[0]
ENDELSE

IF (test_tnoutt) THEN BEGIN
  ;;  no output TPLOT handle supplied for Vt
  tn_outt = tvnme_in[0]+def_sufft[0]
ENDIF ELSE BEGIN
  tn_outt = out_tnmt[0]
ENDELSE

IF (test_tvbasi) THEN BEGIN
  ;;  no string supplied for input coordinate basis
  tvbasis = def_inbasis[0]
ENDIF ELSE BEGIN
  tvbasis = tv_basis[0]
ENDELSE

IF (test_tvfram) THEN BEGIN
  ;;  no string supplied for input frame of reference
  tvframe = def_inframe[0]
ENDIF ELSE BEGIN
  tvframe = tv_frame[0]
ENDELSE
;;  Define output note
note           = '[data in '+tvframe[0]+' frame and '+tvbasis[0]+' basis]'

IF (test_ytoutn) THEN BEGIN
  ;;  no output Y-Axis title supplied for Vn
  yttl_outn = def_yttln[0]
ENDIF ELSE BEGIN
  yttl_outn = out_ytln[0]
ENDELSE

IF (test_ytoutt) THEN BEGIN
  ;;  no output Y-Axis title supplied for Vt
  yttl_outt = def_yttlt[0]
ENDIF ELSE BEGIN
  yttl_outt = out_ytlt[0]
ENDELSE
;;----------------------------------------------------------------------------------------
;; => Calculate Vn = (n . V) n    [page 357 of Jackson, (1999)]
;;----------------------------------------------------------------------------------------
tv_dot_n       = my_dot_prod(tvec_v,nvec_n,/NOM) # REPLICATE(1d0,3L)     ;;  (n . V)    [N,3]-Element array
tv_vn          = tv_dot_n*nvec_n_2d                                      ;;  (n . V) n  [N,3]-Element array
struc_outn     = {X:tvec_t,Y:tv_vn}
;;----------------------------------------------------------------------------------------
;; => Calculate Vt = n x (V x n)  [page 357 of Jackson, (1999)]
;;----------------------------------------------------------------------------------------
tv_x_n         = my_crossp_2(tvec_v,nvec_n,/NOM)   ;;  (V x n)      [N,3]-Element array
n_x_tvxn       = my_crossp_2(nvec_n,tv_x_n,/NOM)   ;;  n x (V x n)  [N,3]-Element array
struc_outt     = {X:tvec_t,Y:n_x_tvxn}
;;----------------------------------------------------------------------------------------
;;  Send results to TPLOT
;;----------------------------------------------------------------------------------------
dlim_tvn       = dlim_in
dlim_tvt       = dlim_in

str_element,dlim_tvn,'YTITLE',yttl_outn,/ADD_REPLACE
str_element,dlim_tvn,'LABELS',labs_outn,/ADD_REPLACE
str_element,dlim_tvn,'COLORS', cols_out,/ADD_REPLACE
str_element,dlim_tvn,'DATA_ATT.NOTE',note[0],/ADD_REPLACE

str_element,dlim_tvt,'YTITLE',yttl_outt,/ADD_REPLACE
str_element,dlim_tvt,'LABELS',labs_outt,/ADD_REPLACE
str_element,dlim_tvt,'COLORS', cols_out,/ADD_REPLACE
str_element,dlim_tvt,'DATA_ATT.NOTE',note[0],/ADD_REPLACE

store_data,tn_outn[0],DATA=struc_outn,DLIM=dlim_tvn,LIM=lim_in
store_data,tn_outt[0],DATA=struc_outt,DLIM=dlim_tvt,LIM=lim_in
;;----------------------------------------------------------------------------------------
;; => Return to user
;;----------------------------------------------------------------------------------------

RETURN,1
END

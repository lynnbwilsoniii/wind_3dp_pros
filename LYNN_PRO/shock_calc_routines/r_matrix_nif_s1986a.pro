;+
;*****************************************************************************************
;
;  FUNCTION :   r_matrix_nif_s1986a.pro
;  PURPOSE  :   This routine is specifically made for collisionless shock calculations.
;                 Definitions:
;                 ICB  :  Input Coordinate Basis (e.g., GSE)
;                 NIF  :  Normal Incidence Frame
;                 SCF  :  SpaceCraft Frame
;                 NCB  :  Normal Incidence Frame Coordinate Basis
;                 SRF  :  Shock Rest Frame
;
;                 This routine calculates:
;                   1)  the rotation matrix from NCB(ICB) --> ICB(NCB)
;
;  CALLED BY:   
;               t_nif_s1986a_scale_norm.pro
;
;  CALLS:
;               my_crossp_2.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               BVUP      :  [3]-Element [float/double] array defining the mean
;                              upstream magnetic field vector, <Bo>_{up} [nT, ICB]
;                              { Default = [1,1,0] }
;               BVDN      :  [3]-Element [float/double] array defining the mean
;                              downstream magnetic field vector, <Bo>_{dn} [nT, ICB]
;                              { Default = [2,3,0] }
;               NVEC      :  [3]-Element [float/double] array defining the unit normal
;                              vector to use for the projections
;                              { Default = [1,0,0] }
;
;  EXAMPLES:    
;               nvec  = [  0.923,  0.207, -0.252]    ;;  shock normal vector [ICB]
;               bvup  = [  2.719,  6.950, -0.754]    ;;  Avg. upstream Bo [nT, ICB]
;               bvdn  = [  1.663, 11.993,-17.264]    ;;  Avg. downstream Bo [nT, ICB]
;               test  = r_matrix_nif_s1986a(bvup,bvdn,nvec)
;               HELP, test, /STRUCTURES
;               ** Structure <2d112ec8>, 2 tags, length=144, data length=144, refs=1:
;                  R_NCB_2_ICB     DOUBLE    Array[3, 3]
;                  R_ICB_2_NCB     DOUBLE    Array[3, 3]
;
;  KEYWORDS:    
;               NA
;
;   CHANGED:  1)  NA [MM/DD/YYYY   v1.0.0]
;
;   NOTES:      
;               1)  There are implicit assumptions in the estimation of both the NIF
;                     and the current density.  The assumptions are:
;                       A)  the shock front can be characterized as a planar stationary
;                             surface with a well defined temporal location
;                       B)  the Rankine-Hugoniot conservation relations hold without
;                             the addition of sources/sinks [e.g., reflected ions,
;                             anomalous resistivity, heat flux considerations, etc.]
;                       C)  the stationary solutions give a shock velocity which is
;                             constant, thus allowing one to convert temporal abscissa
;                             to spatial abscissa
;                       D)  the current density can be entirely characterized by the
;                             curl of the magnetic field divided by the permeability
;                             of free space
;                               => use spatial abscissa to estimate part of two
;                                    components of the current density
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
;
;   CREATED:  02/08/2013
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  02/08/2013   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION r_matrix_nif_s1986a,bvup,bvdn,nvec

;;----------------------------------------------------------------------------------------
;; => Define some constants and dummy variables
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
;; => Dummy error messages
badnin_msg     = 'Too many inputs!'
noinpt_msg     = 'No input supplied!  Using default values...'
noteni_msg     = 'Not enough input supplied!  Using default values...'
badbvu_msg     = 'BVUP must be a [3]-element vector...'
badbvd_msg     = 'BVDN must be a [3]-element vector...'
badnvc_msg     = 'NVEC must be a [3]-element vector...'
;; => Dummy rotation matrix
irot           = IDENTITY(3,/DOUBLE)  ;; 3x3 matrix
;; => Dummy return structure
tags           = ['R_NCB_2_ICB','R_ICB_2_NCB']
dummy_rmats    = CREATE_STRUCT(tags,irot,irot)
;;----------------------------------------------------------------------------------------
;; => Check for input
;;----------------------------------------------------------------------------------------
IF (N_PARAMS() GT 3) THEN BEGIN
  ;; => too many inputs
  MESSAGE,badnin_msg[0],/INFORMATIONAL,/CONTINUE
  RETURN,dummy_rmats
ENDIF

IF (N_PARAMS() EQ 0) THEN BEGIN
  ;; => no input???
  MESSAGE,noinpt_msg[0],/INFORMATIONAL,/CONTINUE
  ;;  Define defaults
  bvup  = [1d0,1d0,0d0]
  bvdn  = [2d0,3d0,0d0]
  nvec  = [1d0,0d0,0d0]
ENDIF ELSE BEGIN
  IF (N_PARAMS() EQ 1) THEN BEGIN
    ;;  Only BVUP supplied
    MESSAGE,noteni_msg[0],/INFORMATIONAL,/CONTINUE
    ;;  Define defaults
    bvdn  = [2d0,3d0,0d0]
    nvec  = [1d0,0d0,0d0]
  ENDIF ELSE BEGIN
    IF (N_PARAMS() EQ 2) THEN BEGIN
      ;;  Only NVEC not supplied
      MESSAGE,noteni_msg[0],/INFORMATIONAL,/CONTINUE
      ;;  Define defaults
      nvec  = [1d0,0d0,0d0]
    ENDIF ELSE BEGIN
      ;;  All are supplied => Do nothing
      bvup  = bvup
      bvdn  = bvdn
      nvec  = nvec
    ENDELSE
  ENDELSE
ENDELSE
;;----------------------------------------------------------------------------------------
;; => Check input format
;;----------------------------------------------------------------------------------------
Bup            = REFORM(bvup)
Bdn            = REFORM(bvdn)
nvv            = REFORM(nvec)
;;  Make sure each is a [3]-Element array
testBu         = (N_ELEMENTS(Bup) NE 3)
testBd         = (N_ELEMENTS(Bdn) NE 3)
test_n         = (N_ELEMENTS(nvv) NE 3)
test           = testBu OR testBd OR test_n
IF (test) THEN BEGIN
  ;; => bad input format
  IF (testBu) THEN MESSAGE,badbvu_msg[0],/INFORMATIONAL,/CONTINUE
  IF (testBd) THEN MESSAGE,badbvd_msg[0],/INFORMATIONAL,/CONTINUE
  IF (test_n) THEN MESSAGE,badnvc_msg[0],/INFORMATIONAL,/CONTINUE
  RETURN,dummy_rmats
ENDIF
;;----------------------------------------------------------------------------------------
;; => Normalize input vectors
;;----------------------------------------------------------------------------------------
bv_up          = Bup/NORM(REFORM(Bup))
bv_dn          = Bdn/NORM(REFORM(Bdn))
nv__n          = nvv/NORM(REFORM(nvv))
;;----------------------------------------------------------------------------------------
;; => Define NCB rotation matrix
;;        {Use Scudder et al., [1986a]}
;;----------------------------------------------------------------------------------------
;; => X'-vector
xvnor          = nv__n
;; => Y'-vector
yvect          = my_crossp_2(bv_dn,bv_up,/NOM)
yvnor          = yvect/NORM(REFORM(yvect))      ;;  Re-normalize
;; => Z'-vector
zvect          = my_crossp_2(xvnor,yvnor,/NOM)
zvnor          = zvect/NORM(REFORM(zvect))      ;;  Re-normalize
;; => Rotation Matrix from NCB to ICB
rot_ncb_icb    = TRANSPOSE([[xvnor],[yvnor],[zvnor]])
;; => Define rotation from ICB to NCB
rot_icb_ncb    = LA_INVERT(rot_ncb_icb)
;;----------------------------------------------------------------------------------------
;; => Define return structure
;;----------------------------------------------------------------------------------------
tags           = ['R_NCB_2_ICB','R_ICB_2_NCB']
rmats          = CREATE_STRUCT(tags,rot_ncb_icb,rot_icb_ncb)

;;----------------------------------------------------------------------------------------
;; => Return to user
;;----------------------------------------------------------------------------------------

RETURN,rmats
END

;+
;*****************************************************************************************
;
;  PROCEDURE:   generate_cold_plasma_whistler_disp_info.pro
;  PURPOSE  :   This routine calculates the phase speed, group velocity, and angle
;                 between k and Vgr from an input set of requirements.  The routine
;                 allows the user to specify how much they wish to return based upon
;                 keyword usage and supplied information.
;
;  CALLED BY:   
;               NA
;
;  INCLUDES:
;               NA
;
;  CALLS:
;               is_a_number.pro
;               test_plot_axis_range.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               NA
;
;  EXAMPLES:    
;               [calling sequence]
;               generate_cold_plasma_whistler_disp_info [,N_KGRID=n_kgrid] [,N_WGRID=n_wgrid] $
;                                    [,N_TGRID=n_tgrid] [,KBARRAN=kbarran] [,WBARRAN=wbarran] $
;                                    [,THETRAN=thetran] [,VPH_OUT=vph_out] [,VGV_OUT=vgv_out] $
;                                    [,ALP_OUT=alp_out] [,THE_OUT=the_out] [,KBR_OUT=kbr_out] $
;                                    [,GBR_OUT=gbr_out] [,WBR_OUT=wbr_out]
;
;  KEYWORDS:    
;               **********************************
;               ***       DIRECT  INPUTS       ***
;               **********************************
;               N_KGRID     :  Scalar [long] defining the number of grid points to use
;                                when constructing the KBAR array (see notes below)
;                                [Default  :  100]
;               N_WGRID     :  Scalar [long] defining the number of grid points to use
;                                when constructing the WBAR array (see notes below)
;                                [Default  :  100]
;               N_TGRID     :  Scalar [long] defining the number of grid points to use
;                                when constructing the theta_kB array (see notes below)
;                                [Default  :  100]
;               KBARRAN     :  [2]-Element [numeric] array defining the range of values
;                                to use when constructing the WBAR array (see notes below)
;                                [Default  :  {0.02,5.0}]
;               WBARRAN     :  [2]-Element [numeric] array defining the range of values
;                                to use when constructing the WBAR array (see notes below)
;                                [Default  :  {0.001,0.99}]
;               THETRAN     :  [2]-Element [numeric] array defining the range of values
;                                to use when constructing the theta_kB array [deg]
;                                [Default  :  {0,89}]
;               **********************************
;               ***       DIRECT OUTPUTS       ***
;               **********************************
;               ***  1D Grid point arrays  ***
;               THE_OUT     :  Set to a named variable to return the angle between the
;                                wave and magnetic field vectors [deg]
;               KBR_OUT     :  Set to a named variable to return the normalized wave
;                                number [L_e]
;               WBR_OUT     :  Set to a named variable to return the normalized wave
;                                frequency [Ωceo] (see notes below)
;               GBR_OUT     :  Set to a named variable to return the inverse normalized
;                                wave frequency [Ωceo^(-1)] (see notes below)
;               ***  ND calculated arrays  ***
;               VPH_OUT     :  Set to a named variable to return the normalized phase
;                                speed in units of the electron Alfven speed
;               VGV_OUT     :  Set to a named variable to return the normalized group
;                                velocity vector in units of the electron Alfven speed
;                                in terms of k-theta components (see notes below)
;               ALP_OUT     :  Set to a named variable to return the angle between the
;                                wave and group velocity vectors [deg]
;
;   CHANGED:  1)  NA
;                                                                   [MM/DD/YYYY   v1.0.0]
;
;   NOTES:      
;               1)  Definitions:
;                 c          =  speed of light in vacuum [m/s]
;                                 [ 299,792,458 m/s ]
;                 ∑_o        =  permittivity of free space [F m^(-1) or C V^(-1)]
;                                 [ 8.854187817 x 10^(-12) F m^(-1) ]
;                 µ_o        =  permeability of free space [H m^(-1) or T m^(+2) A^(-1)]
;                                 [ 4π x 10^(-7) H m^(-1) ]
;                 e          =  fundamental charge [C]
;                                 [ 1.6021766208 x 10^(-19) C ]
;                 k_B        =  Boltzmann constant [J K^(-1)]
;                                 [ 1.38064851 x 10^(-23) J K^(-1) ]
;                 ms         =  mass of species s [kg]
;                 ns         =  number density of species s [m^(-3)]
;                 qs         =  charge of species s [C]  = Zs e
;                 Zs         =  charge state species s [N/A]
;                 Bo         =  quasi-static magnetic field vector [T]
;                 Ts         =  scalar temperature of species s [K]
;                 wps        =  nonrelativistic angular plasma frequency [rad/s] of species s
;                 Ωcs        =  angular cyclotron frequency [rad/s] of species s
;                 Ωcso       =  modulus of Ωcs in particle rest frame [rad/s]
;                 V_Ts       =  1D most probable thermal speed [m/s] of species s
;                 V_Ae       =  electron Alfven speed [m/s]
;                 L_s        =  inertial length of species s [m]
;                 rho_cs     =  thermal gyroradius of species s [m]
;                 gamma      =  relativistic Lorentz factor [N/A]
;                 k          =  wave vector [m^(-1)]
;                 w          =  rest frame angular frequency [rad/s]
;                 kbar       =  |k| normalized to L_e [N/A]
;                 gbar       =  Ωceo normalized to wave frequency [N/A]
;                 wbar       =  wave frequency normalized to Ωceo [N/A]
;                 khat       =  unit vector parallel to k
;                 that       =  unit vector orthogonal to k but coplanar with Vgr
;                                 [counter-clockwise sense relative to wave vector]
;                 Vph        =  rest frame phase speed [m/s]
;                 Vgr        =  rest frame group velocity vector [m/s]
;                 Vgk        =  projection of group velocity along k [m/s]
;                 Vgt        =  projection of group velocity along theta-hat [m/s]
;                 alp        =  angle between k and Vgr [rad]
;                 the        =  angle between k and Bo [rad] (i.e., wave normal angle)
;               2)  General Parameter Expressions:
;                 gamma      =  [ 1 + (v/c)^2 ]^(-1/2)
;                 Ωcs        =  qs |Bo|/(gamma ms)
;                 Ωcso       =  | qs |Bo|/ms |
;                 wps        =  [ ns qs^2 / ( ∑_o ms ) ]^(1/2)
;                 V_Ts       =  [ 2 k_B Ts / ms ]^(1/2)
;                 L_s        =  c/wps
;                 rho_cs     =  V_Ts/Ωcs
;                 V_Ae       =  |Bo|/[ µ_o n me ]^(1/2)
;                 Vph        =  w/|k|
;                 Vgr        =  ∂w/∂k  =  khat ∂w/∂|k| + that/|k| ∂w/∂the
;                 Vgk        =  (Vgr . khat)
;                 Vgt        =  (Vgr . that)
;                 Tan[alp]   =  1/|k| (∂w/∂the) / (∂w/∂|k|)
;                 the        =  ArcCos[ (k . Bo)/( |k| |Bo| ) ]
;               3)  Whistler Parameter Expressions:
;                 [*** High density limit --> (wpe/Ωceo)^2 >> 1 ***]
;                 kbar       =  (k c / wpe)
;                 gbar       =  Ωceo/w
;                 wbar       =  w/Ωceo
;                 w          =  kbar^2 Cos[the] / (1 + kbar^2)
;                 kbar       =  [ gbar Cos[the] - 1 ]^(-1/2)
;                 Vph        =  kbar V_Ae Cos[the]/(1 + kbar^2)
;                            =  V_Ae [ gbar Cos[the] - 1 ]^(1/2) / gbar
;                 Vgk        =  2 kbar V_Ae Cos[the] / (1 + kbar^2)^2
;                            =  2 V_Ae [ gbar Cos[the] - 1 ]^(3/2) / ( gbar^2 Cos[the] )
;                 Vgt        =  - kbar V_Ae Sin[the] / (1 + kbar^2)
;                            =  - V_Ae Sin[the] [ gbar Cos[the] - 1 ]^(1/2) / ( gbar Cos[the] )
;                 Vgr        =  Vph [ khat 2/(1 + kbar^2) - that Tan[the] ]
;                 Tan[alp]   =  - (1 + kbar^2)/2 Tan[the]
;                            =  - gbar Sin[the] / [ 2 ( gbar Cos[the] - 1 ) ]
;               4)  Wave observation stat summary:
;                 Giagkiozis et al. [2018] (lion roars):
;                   wbar ~ 0.023--0.72
;                   kbar ~ 0.2--10
;                 Wilson et al. [2013] (lion roars):
;                   wbar ~ 0.03--0.43
;                   kbar ~ 0.2--1.0
;                 Wilson et al. [2013] (fast/magnetosonic-whistlers):
;                   wbar ~ 0.0016--0.117
;                   kbar ~ 0.02--5.0
;                 Wilson et al. [2017] (precursors):
;                   wbar ~ 0.00054--0.023
;                   kbar ~ 0.02--5.9
;
;  REFERENCES:  
;               0)  Gurnett, D.A. and A. Bhattacharjee (2005), "Introduction to Plasma
;                      Physics:  With Space and Laboratory Applications," Cambridge
;                      University Press, Cambridge, UK, ISBN:0-521-36483-3.
;               1)  Stix, T.H. (1992), "Waves in Plasmas," Springer-Verlag,
;                      New York Inc.,  American Institute of Physics,
;                      ISBN:0-88318-859-7.
;               2)  Sazhin, S.S. (1993), "Whistler-mode Waves in a Hot Plasma,"
;                      Cambridge University Press, The Edinburgh Building,
;                      Cambridge CB2 2RU, UK, ISBN:0-521-40165-8.
;               3)  Giagkiozis, S., et al., "Statistical study of the properties of
;                      magnetosheath lion roars," J. Geophys. Res. 123,
;                      doi:10.1029/2018JA025343, 2018.
;               4)  Wilson III, L.B., et al., "Electromagnetic waves and electron
;                      anisotropies downstream of supercritical interplanetary shocks,"
;                      J. Geophys. Res. 118(1), pp. 5--16,
;                      doi:10.1029/2012JA018167, 2013a.
;               5)  Wilson III, L.B., et al., "Revisiting the structure of low-Mach
;                      number, low-beta, quasi-perpendicular shocks,"
;                      J. Geophys. Res. 122(9), pp. 9115--9133,
;                      doi:10.1002/2017JA024352, 2017.
;
;   CREATED:  12/22/2023
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  12/22/2023   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

PRO generate_cold_plasma_whistler_disp_info,N_KGRID=n_kgrid,N_WGRID=n_wgrid,N_TGRID=n_tgrid,$    ;;  Inputs
                                            KBARRAN=kbarran,WBARRAN=wbarran,THETRAN=thetran,$
                                            VPH_OUT=vph_out,VGV_OUT=vgv_out,ALP_OUT=alp_out,$    ;;  Outputs
                                            THE_OUT=the_out,KBR_OUT=kbr_out,GBR_OUT=gbr_out,$
                                            WBR_OUT=wbr_out

;;----------------------------------------------------------------------------------------
;;  Constants and Defaults
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
;;  Define some default parameters
def_nkg        = 100L                        ;;  Default number of kbar grid points
def_nwg        = 100L                        ;;  Default number of wbar grid points
def_ntg        = 100L                        ;;  Default number of theta_kB grid points
def_kra        = [0.020d0,5.00d0]            ;;  Default kbar range
def_wra        = [0.001d0,0.99d0]            ;;  Default kbar range
def_tra        = [0.000d0,89.0d0]            ;;  Default kbar range
;;----------------------------------------------------------------------------------------
;;  Check keywords
;;----------------------------------------------------------------------------------------
;;  Check N_?GRID keywords
IF (is_a_number(n_kgrid,/NOMSSG) EQ 0) THEN nkgd = def_nkg[0] ELSE nkgd = LONG(ABS(n_kgrid[0]))
IF (is_a_number(n_wgrid,/NOMSSG) EQ 0) THEN nwgd = def_nwg[0] ELSE nwgd = LONG(ABS(n_wgrid[0]))
IF (is_a_number(n_tgrid,/NOMSSG) EQ 0) THEN ntgd = def_ntg[0] ELSE ntgd = LONG(ABS(n_tgrid[0]))
;;  Check ????RAN keywords
IF (test_plot_axis_range(kbarran,/NOMSSG) EQ 0) THEN kran = def_kra ELSE kran = (ABS(kbarran) > 1d-4) < 1d1
IF (test_plot_axis_range(wbarran,/NOMSSG) EQ 0) THEN wran = def_wra ELSE wran = (ABS(wbarran) > 1d-4) < 0.9999999d0
IF (test_plot_axis_range(thetran,/NOMSSG) EQ 0) THEN tran = def_tra ELSE tran = (ABS(thetran) >  0d0) < 89.999999d0
;;----------------------------------------------------------------------------------------
;;  Construct grid points for arrays
;;----------------------------------------------------------------------------------------
;;  Use base-10 log-space for kbar and wbar [N/A]
kranl10        = ALOG10(kran)
wranl10        = ALOG10(wran)
kgridl10       = DINDGEN(nkgd[0])*(MAX(kranl10,/NAN) - MIN(kranl10,/NAN))/(nkgd[0] - 1L) + MIN(kranl10,/NAN)
wgridl10       = DINDGEN(nwgd[0])*(MAX(wranl10,/NAN) - MIN(wranl10,/NAN))/(nwgd[0] - 1L) + MIN(wranl10,/NAN)
kgrid          = 1d1^(kgridl10)              ;;  kbar
wgrid          = 1d1^(wgridl10)              ;;  wbar
ggrid          = 1d0/wgrid                   ;;  gbar
;;  Use linear space for theta_kB or the [deg]
tgrid          = DINDGEN(ntgd[0])*(MAX(tran,/NAN) - MIN(tran,/NAN))/(ntgd[0] - 1L) + MIN(tran,/NAN)
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Calculate whistler parameters
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Normalized phase speed [V_Ae]
vph_of_k       = REPLICATE(d,nkgd[0],ntgd[0])        ;;  Vph/V_Ae  =  kbar Cos[the]/(1 + kbar^2)
vph_of_w       = REPLICATE(d,nwgd[0],ntgd[0])        ;;  Vph/V_Ae  =  [ gbar Cos[the] - 1 ]^(1/2) / gbar
;;  Normalized group velocity components [V_Ae]
vgk_of_k       = vph_of_k                            ;;  Vgk/V_Ae  =  2 kbar Cos[the] / (1 + kbar^2)^2
vgt_of_k       = vph_of_k                            ;;  Vgt/V_Ae  =  - kbar Sin[the] / (1 + kbar^2)
vgk_of_w       = vph_of_w                            ;;  Vgk/V_Ae  =  2 [ gbar Cos[the] - 1 ]^(3/2) / ( gbar^2 Cos[the] )
vgt_of_w       = vph_of_w                            ;;  Vgt/V_Ae  =  - Sin[the] [ gbar Cos[the] - 1 ]^(1/2) / ( gbar Cos[the] )
;;  Angle between Vgr and k [deg]
alpha_gk       = vph_of_k                            ;;  ArcTan[ - (1 + kbar^2)/2 Tan[the] ]
alpha_gw       = vph_of_w                            ;;  ArcTan[ - gbar Sin[the] / [ 2 ( gbar Cos[the] - 1 ) ] ]
;;  Define Cos[the], Sin[the], and Tan[the] for brevity
ct             = COS(tgrid*!DPI/18d1)
st             = SIN(tgrid*!DPI/18d1)
tt             = TAN(tgrid*!DPI/18d1)
;;  Define (1 + kbar^2) for brevity
onekb2         = 1d0 + kgrid^2d0
;;  Calculate parameters
FOR j=0L, ntgd[0] - 1L DO BEGIN
  ;;  Normalized phase speed [V_Ae]
  vph_of_k[*,j]  = kgrid*ct[j]/onekb2
  vph_of_w[*,j]  = SQRT(ggrid*ct[j] - 1d0)/ggrid
  ;;  Normalized group velocity components [V_Ae]
  vgk_of_k[*,j]  =  2d0*kgrid*ct[j]/onekb2^2d0
  vgt_of_k[*,j]  = -1d0*kgrid*st[j]/onekb2
  vgk_of_w[*,j]  =  2d0*(ggrid*ct[j] - 1d0)^(3d0/2d0)/(ggrid^2d0*ct[j])
  vgt_of_w[*,j]  = -1d0*st[j]*SQRT(ggrid*ct[j] - 1d0)/(ggrid*ct[j])
  ;;  Angle between Vgr and k [deg]
  alpha_gk[*,j]  = ATAN(vgt_of_k[*,j],vgk_of_k[*,j])*18d1/!DPI
  alpha_gw[*,j]  = ATAN(vgt_of_w[*,j],vgk_of_w[*,j])*18d1/!DPI
ENDFOR
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Define outputs
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
the_out        = tgrid
kbr_out        = kgrid
wbr_out        = wgrid
gbr_out        = 1d0/wgrid
tags           = ['func_of_k','func_of_w']
vph_out        = CREATE_STRUCT(tags,vph_of_k,vph_of_w)
vgk_out        = CREATE_STRUCT(tags,vgk_of_k,vgk_of_w)
vgt_out        = CREATE_STRUCT(tags,vgt_of_k,vgt_of_w)
alp_out        = CREATE_STRUCT(tags,alpha_gk,alpha_gw)
tags           = ['Vgr_k','Vgr_t']
vgv_out        = CREATE_STRUCT(tags,vgk_out,vgt_out)
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------

RETURN
END




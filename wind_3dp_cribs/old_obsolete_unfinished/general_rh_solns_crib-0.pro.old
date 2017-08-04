;;----------------------------------------------------------------------------------------
;;  Load into TPLOT
;;----------------------------------------------------------------------------------------
slash          = get_os_slash()   ;;  e.g., '/' on Unix-based machines
;;  Define file name
;;    *** The following is a dummy file path and names, so change accordingly ***
file_dir       = slash[0]+'full'+slash[0]+'path'+slash[0]+'to'+slash[0]+'my'+$
                 slash[0]+'cdf'+slash[0]+'files'+slash[0]
file_names     = 'dummy_file_name.cdf'     ;;  This can be multiple files
;;  Find files
fnames         = FILE_SEARCH(file_dir[0],file_names)
cdf2tplot,FILES=fnames,VARFORMAT='*',VARNAMES=varnames,TPLOTNAMES=tplotnames
;;  On output, cdf2tplot.pro returns the list of variable names [VARNAMES keyword],
;;    list of TPLOT handles/names [TPLOTNAMES keyword], and sends the appropriate data
;;    to TPLOT.  cdf2tplot.pro is part of my libraries and part of the SPEDAS release
;;    for Van Allen Probes, so you should have it available.

;;  Note:  You can use cdf2tplot.pro for multiple files at a time or make multiple calls
;;           to for different data sets.  It has a decent Man. page header so you can
;;           see explanations and other examples of how to use it and other optional
;;           keywords.

;;----------------------------------------------------------------------------------------
;;  Define TPLOT handles
;;----------------------------------------------------------------------------------------
;;  Assume you have TPLOT handles for your magnetic field, number density, bulk flow
;;    velocity (e.g., solar wind velocity), ion temperature and electron temperature.
;;    I will some generic examples below, so change them accordingly.
;;
;;  Note:  The coordinate basis for the B-field and Vsw TPLOT handles below should be
;;           the same and will be the coordinate basis of the output shock normal vector.
tpn___Bo0      = 'magf_vec_coord_1'         ;;  Bo TPLOT handle [units should be in nT]
tpn__Vsw0      = 'Vbulk_vec_coord_1'        ;;  Vbulk TPLOT handle [units should be in km/s]
tpn___No0      = 'particle_number_density'  ;;  No TPLOT handle [units should be in cm^(-3)]
tpn___Ti0      = 'ion_temperature'          ;;  Ti TPLOT handle [units should be in eV]
tpn___Te0      = 'electron_temperature'     ;;  Te TPLOT handle [units should be in eV]
;;  Note:  If you don't have Te, then just assume Te = Ti
;;           --> multiply the Ti output below by 2

;;  Check that the handles are valid
test__Bo       = test_tplot_handle(tpn___Bo0,TPNMS=tpn___Bo)
test_Vsw       = test_tplot_handle(tpn__Vsw0,TPNMS=tpn__Vsw)
test__No       = test_tplot_handle(tpn___No0,TPNMS=tpn___No)
test__Ti       = test_tplot_handle(tpn___Ti0,TPNMS=tpn___Ti)
test__Te       = test_tplot_handle(tpn___Te0,TPNMS=tpn___Te)
test_rh        = test_Bo[0] AND test_Vp[0] AND test_Np[0] AND test_Tp[0]
;;----------------------------------------------------------------------------------------
;;  Get data from TPLOT
;;----------------------------------------------------------------------------------------
;;  Bo
IF (test_rh[0]) THEN  get_data,tpn___Bo[0],DATA=bvec_str
;;  Vbulk
IF (test_rh[0]) THEN  get_data,tpn__Vsw[0],DATA=Vsw__str
;;  No
IF (test_rh[0]) THEN  get_data,tpn___No[0],DATA=No___str
;;  Ti
IF (test_rh[0]) THEN  get_data,tpn___Ti[0],DATA=Ti___str
;;  Te
IF (test__Te[0]) THEN get_data,tpn___Te[0],DATA=Te___str ELSE IF (test_rh[0]) THEN  Te___str = Ti___str

IF (~test_rh[0]) THEN PRINT,''
IF (~test_rh[0]) THEN PRINT,'***  Something is wrong!  ***'
IF (~test_rh[0]) THEN PRINT,''
IF (~test_rh[0]) THEN STOP
;;----------------------------------------------------------------------------------------
;;  Define upstream/downstream time ranges
;;----------------------------------------------------------------------------------------
;;  The following are dummy examples
;;    *** change accordingly ***
tdate          = '2015-10-01'
IF (tdate[0] EQ '2015-10-01') THEN tr_up = tdate[0]+'/18:'+['42','56']+':00'    ;;  i.e., 2015-10-01/18:42:00 -- 2015-10-01/18:56:00 UTC
IF (tdate[0] EQ '2015-10-01') THEN tr_dn = tdate[0]+'/19:'+['06','20']+':00'    ;;  i.e., 2015-10-01/19:06:00 -- 2015-10-01/19:20:00 UTC
;;  Convert time ranges to Unix times
tra_up_u       = time_double(tr_up)
tra_dn_u       = time_double(tr_dn)
;;  Note:  If you do not want to enter times by hand, you can use the combination of
;;         tlimit.pro (to zoom-in/zoom-out) and t_get_current_trange.pro to return
;;         the currently plotted time range showing TPLOT data
;;----------------------------------------------------------------------------------------
;;  Clip the data to within the upstream/downstream time ranges
;;----------------------------------------------------------------------------------------
;;  Upstream
bv__str_up     = trange_clip_data(bvec_str,TRANGE=tra_up_u,PRECISION=3)
Vsw_str_up     = trange_clip_data(Vsw__str,TRANGE=tra_up_u,PRECISION=3)
No__str_up     = trange_clip_data(No___str,TRANGE=tra_up_u,PRECISION=3)
Ti__str_up     = trange_clip_data(Ti___str,TRANGE=tra_up_u,PRECISION=3)
Te__str_up     = trange_clip_data(Te___str,TRANGE=tra_up_u,PRECISION=3)
;;  Downstream
bv__str_dn     = trange_clip_data(bvec_str,TRANGE=tra_dn_u,PRECISION=3)
Vsw_str_dn     = trange_clip_data(Vsw__str,TRANGE=tra_dn_u,PRECISION=3)
No__str_dn     = trange_clip_data(No___str,TRANGE=tra_dn_u,PRECISION=3)
Ti__str_dn     = trange_clip_data(Ti___str,TRANGE=tra_dn_u,PRECISION=3)
Te__str_dn     = trange_clip_data(Te___str,TRANGE=tra_dn_u,PRECISION=3)
;;  Make sure data is available
test_updn      = (SIZE(bv__str_up,/TYPE) NE 8) OR (SIZE(bv__str_dn,/TYPE) NE 8) OR $
                 (SIZE(Vsw_str_up,/TYPE) NE 8) OR (SIZE(Vsw_str_dn,/TYPE) NE 8) OR $
                 (SIZE(No__str_up,/TYPE) NE 8) OR (SIZE(No__str_dn,/TYPE) NE 8) OR $
                 (SIZE(Ti__str_up,/TYPE) NE 8) OR (SIZE(Ti__str_dn,/TYPE) NE 8) OR $
                 (SIZE(Te__str_up,/TYPE) NE 8) OR (SIZE(Te__str_dn,/TYPE) NE 8)
IF (~test_updn[0]) THEN PRINT,''
IF (~test_updn[0]) THEN PRINT,'***  No data was found?  ***'
IF (~test_updn[0]) THEN PRINT,''
IF (~test_updn[0]) THEN STOP
;;----------------------------------------------------------------------------------------
;;  Resample data to a single uniform time range
;;----------------------------------------------------------------------------------------
;;  Assume the ion time stamps are appropriate --> use as new time for rest of structures
t_new_up       = Ti__str_up.X        ;;  Unix times of ion temperatures in upstream range
t_new_dn       = Ti__str_dn.X        ;;  Unix times of ion temperatures in downstream range
nn_up          = N_ELEMENTS(t_new_up)
nn_dn          = N_ELEMENTS(t_new_dn)
;;  First make sure there are more than three points in each array
test_nn        = (nn_up[0] LE 3) OR (nn_dn[0] LE 3)
IF (test_nn[0]) THEN PRINT,''
IF (test_nn[0]) THEN PRINT,'***  Not enough points --> increase time ranges!  ***'
IF (test_nn[0]) THEN PRINT,''
IF (test_nn[0]) THEN STOP
;;  Make sure they have the same number of elements
n_updn         = nn_up[0] < nn_dn[0]
IF (n_updn[0] EQ nn_up[0]) THEN t_new_dn = t_new_dn[0L:(nn_up[0] - 1L)] ELSE $
                                t_new_up = t_new_up[0L:(nn_dn[0] - 1L)]
;;  Upstream
bv__newt_up    = t_resample_tplot_struc(bv__str_up,t_new_up,/NO_EXTRAPOLATE)
Vsw_newt_up    = t_resample_tplot_struc(Vsw_str_up,t_new_up,/NO_EXTRAPOLATE)
No__newt_up    = t_resample_tplot_struc(No__str_up,t_new_up,/NO_EXTRAPOLATE)
Ti__newt_up    = t_resample_tplot_struc(Ti__str_up,t_new_up,/NO_EXTRAPOLATE)
Te__newt_up    = t_resample_tplot_struc(Te__str_up,t_new_up,/NO_EXTRAPOLATE)
;;  Downstream
bv__newt_dn    = t_resample_tplot_struc(bv__str_dn,t_new_dn,/NO_EXTRAPOLATE)
Vsw_newt_dn    = t_resample_tplot_struc(Vsw_str_dn,t_new_dn,/NO_EXTRAPOLATE)
No__newt_dn    = t_resample_tplot_struc(No__str_dn,t_new_dn,/NO_EXTRAPOLATE)
Ti__newt_dn    = t_resample_tplot_struc(Ti__str_dn,t_new_dn,/NO_EXTRAPOLATE)
Te__newt_dn    = t_resample_tplot_struc(Te__str_dn,t_new_dn,/NO_EXTRAPOLATE)
;;----------------------------------------------------------------------------------------
;;  Define parameters for input Rankine-Hugoniot analysis software
;;----------------------------------------------------------------------------------------
;;  Upstream
magf_up        = bv__newt_up.Y              ;;  Should be an [N,3]-element array
vsw__up        = Vsw_newt_up.Y              ;;  Should be an [N,3]-element array
dens_up        = No__newt_up.Y              ;;  Should be an [N]-element array
ti___up        = Ti__newt_up.Y              ;;  Should be an [N]-element array
te___up        = Te__newt_up.Y              ;;  Should be an [N]-element array
temp_up        = ti___up + te___up
;;  Downstream
magf_dn        = bv__newt_dn.Y              ;;  Should be an [N,3]-element array
vsw__dn        = Vsw_newt_dn.Y              ;;  Should be an [N,3]-element array
dens_dn        = No__newt_dn.Y              ;;  Should be an [N]-element array
ti___dn        = Ti__newt_dn.Y              ;;  Should be an [N]-element array
te___dn        = Te__newt_dn.Y              ;;  Should be an [N]-element array
temp_dn        = ti___dn + te___dn
;;  Combine terms
vsw            = [[[vsw__up]],[[vsw__dn]]]
mag            = [[[magf_up]],[[magf_dn]]]
dens           = [[dens_up],[dens_dn]]
temp           = [[temp_up],[temp_dn]]
nmax           = 150L
;;----------------------------------------------------------------------------------------
;;  Calculate shock parameters from Rankine-Hugoniot analysis
;;----------------------------------------------------------------------------------------
;;  The below equation references refer to the equation numbers from
;;    Koval and Szabo, [2008] JGR
bow_shock  = 0b        ;;  If you are interested in the bow shock, then change this to TRUE

nqq        = [1,0,1,0,0]  ;;  Solution for Equations 2 and 4
chisq0     = rh_solve_lmq(dens,vsw,mag,temp,NMAX=nmax,NEQS=nqq,SOLN=soln0,BOWSH=bow_shock)
nqq        = [1,1,1,1,0]  ;;  Solution for Equations 2, 3, 4, and 5
chisq1     = rh_solve_lmq(dens,vsw,mag,temp,NMAX=nmax,NEQS=nqq,SOLN=soln1,BOWSH=bow_shock)
nqq        = [1,1,1,1,1]  ;;  Solution for Equations 2, 3, 4, 5, and 6
chisq2     = rh_solve_lmq(dens,vsw,mag,temp,NMAX=nmax,NEQS=nqq,SOLN=soln2,BOWSH=bow_shock)

;;----------------------------------------------------------------------------------------
;;  Definition of output structures returned by SOLN keyword
;;----------------------------------------------------------------------------------------
;;  All outputs have associated one-sigma uncertainties calculated from the area of the
;;    local minimum in the 2D contour plots of possible angular space associated with
;;    the shock normal vector.  For example, see this plot from the CfA shock database at:
;;    https://www.cfa.harvard.edu/shocks/wi_data/00118/wi_normals_00118.png
;;
;;
;;  soln.VSHN         = upstream shock normal speed in spacecraft frame [km/s]
;;  soln.USHN_UP      = upstream shock normal speed in shock frame [km/s] (i.e., upstream flow speed along normal)
;;  soln.USHN_DN      = downstream shock normal speed in shock frame [km/s] (i.e., downstream flow speed along normal)
;;  soln.SH_NORM[*,0] = upstream shock normal unit vector [in coordinate basis of input B-field and Vsw vectors]
;;  soln.SH_NORM[*,1] = uncertainties in soln.SH_NORM[*,0]
;;
;;  I generally use the above different sets of equations for cross-comparison because
;;  sometimes, for instance, the particle temperature data is "bad" so it gives "bad"
;;  shock normal vectors.  Though I think you already know that any solution returned
;;  by any software that numerically solves the Rankine-Hugoniot relations is inherently
;;  unstable.  For instance, if you remove one point from the upstream and downstream
;;  arrays, you can get significantly different results (i.e., 10-20 degrees off).








;+
;*****************************************************************************************
;
;  PROCEDURE:   plot_model_fit_vdf_2_so3fs.pro
;  PURPOSE  :   This is a wrapping routine for plotting the fit results returned by the
;                 MPFIT routines.
;
;  CALLED BY:   
;               wrapper_model_fit_vdf_2_so3fs.pro
;
;  INCLUDES:
;               NA
;
;  CALLS:
;               is_a_number.pro
;               is_a_3_vector.pro
;               lbw_window.pro
;               test_file_path_format.pro
;               sign.pro
;               num2int_str.pro
;               bimaxwellian_fit.pro
;               bikappa_fit.pro
;               biselfsimilar_fit.pro
;               biselfsimilar_2exp_fit.pro
;               find_1d_cuts_2d_dist.pro
;               lbw__add.pro
;               popen.pro
;               general_vdf_contour_plot.pro
;               pclose.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               VDF          :  [N]-Element [float/double] array defining particle velocity
;                                 distribution function (VDF) in units of phase space density
;                                 [e.g., # s^(+3) km^(-3) cm^(-3)]
;               VELXYZ       :  [N,3]-Element [float/double] array defining the particle
;                                 velocity 3-vectors for each element of VDF [km/s]
;               OUT_STRUC    :  Scalar [structure] defined at end of the routine
;                                 wrapper_model_fit_vdf_2_so3fs.pro
;
;  EXAMPLES:    
;               [calling sequence]
;               plot_model_fit_vdf_2_so3fs, vdf, velxyz, out_struc [,VFRAME=vframe]      $
;                                        [,VEC1=vec1] [,VEC2=vec2] [,/ONLY_TOT]          $
;                                        [,/PLOT_BOTH]                                   $
;                                        [,CORE_LABS=core_labs] [,HALO_LABS=halo_labs]   $
;                                        [,BEAM_LABS=beam_labs] [,XYLAB_PRE=xylabpre]    $
;                                        [,CFUNC=cfunc] [,HFUNC=hfunc] [,BFUNC=bfunc]    $
;                                        [,CFACT=cfact] [,HFACT=hfact] [,BFACT=bfact]    $
;                                        [,ELECTRONS=electrons] [,IONS=ions]             $
;                                        [,SPTHRSHS=spthrshs] [,MAXFACS=maxfacs]         $
;                                        [,SAVEF=savef] [,FILENAME=filename]             $
;                                        [,_EXTRA=extrakey]
;
;  KEYWORDS:    
;               ***  INPUTS  ***
;               !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
;               ***  [all of the following have default settings]  ***
;               !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
;               VFRAME      :  [3]-Element [float/double] array defining the 3-vector
;                                velocity of the K'-frame relative to the K-frame [km/s]
;                                to use to transform the velocity distribution into the
;                                bulk flow reference frame
;                                [ Default = [10,0,0] ]
;               VEC1        :  [3]-Element vector to be used for "parallel" direction in
;                                a 3D rotation of the input data
;                                [e.g. see rotate_3dp_structure.pro]
;                                [ Default = [1.,0.,0.] ]
;               VEC2        :  [3]--Element vector to be used with VEC1 to define a 3D
;                                rotation matrix.  The new basis will have the following:
;                                  X'  :  parallel to VEC1
;                                  Z'  :  parallel to (VEC1 x VEC2)
;                                  Y'  :  completes the right-handed set
;                                [ Default = [0.,1.,0.] ]
;               ONLY_TOT    :  If set, routine will only plot the sum of all the model fit
;                                cuts instead of each individually
;                                [Default = FALSE]
;               PLOT_BOTH   :  If set, routine will plot both forms of output where one
;                                shows only the sum of all fits and the other shows each
;                                1D fit line cut individually.  Note that if set, this
;                                keyword will take precedence over the ONLY_TOT setting.
;                                [Default  :  FALSE]
;               CORE_LABS   :  String labels defined in setup_def_4_parinfo_struc4mpfit_4_vdfs.pro
;               HALO_LABS   :  String labels defined in setup_def_4_parinfo_struc4mpfit_4_vdfs.pro
;               BEAM_LABS   :  String labels defined in setup_def_4_parinfo_struc4mpfit_4_vdfs.pro
;               XYLAB_PRE   :  String labels defined in setup_def_4_parinfo_struc4mpfit_4_vdfs.pro
;               CFUNC       :  Scalar [string] used to determine which model function to
;                                use for the core VDF
;                                  'MM'  :  bi-Maxwellian VDF
;                                  'KK'  :  bi-kappa VDF
;                                  'SS'  :  bi-self-similar VDF
;                                  'AS'  :  asymmetric bi-self-similar VDF
;                                [Default = 'MM']
;               HFUNC       :  Scalar [string] used to determine which model function to
;                                use for the halo VDF
;                                  'MM'  :  bi-Maxwellian VDF
;                                  'KK'  :  bi-kappa VDF
;                                  'SS'  :  bi-self-similar VDF
;                                  'AS'  :  asymmetric bi-self-similar VDF
;                                [Default = 'KK']
;               BFUNC       :  Scalar [string] used to determine which model function to
;                                use for the beam/strahl part of VDF
;                                  'MM'  :  bi-Maxwellian VDF
;                                  'KK'  :  bi-kappa VDF
;                                  'SS'  :  bi-self-similar VDF
;                                  'AS'  :  asymmetric bi-self-similar VDF
;                                [Default = 'KK']
;               CFACT       :  [6]-Element [numeric] array of multiplicative factors to
;                                use to ensure that the core fit parameters are near unity
;                                when called by MPFIT software
;               HFACT       :  [6]-Element [numeric] array of multiplicative factors to
;                                use to ensure that the halo fit parameters are near unity
;                                when called by MPFIT software
;               BFACT       :  [6]-Element [numeric] array of multiplicative factors to
;                                use to ensure that the beam fit parameters are near unity
;                                when called by MPFIT software
;               ELECTRONS   :  If set, routine uses parameters appropriate for non-
;                                relativistic electron velocity distributions
;                                [Default = TRUE]
;               IONS        :  If set, routine uses parameters appropriate for non-
;                                relativistic proton velocity distributions
;                                [Default = FALSE]
;               SPTHRSHS    :  [3]-Element [float/double] array defining the fraction of
;                                the maximum speed of the input VDF to allow when looking
;                                for peaks exceeding MAXFACS for each component
;                                [ Default = [0.15, 0.20, 0.20] ]
;               MAXFACS     :  [3]-Element [float/double] array defining the maximum
;                                value of the ratio between the model and data for each
;                                component to allow.  Any component exceeding this value
;                                will be nullified and the status set to -20.
;                                [ Default = [9.00, 2.25, 2.25] ]
;               SAVEF       :  If set, routine will save the final plot to a PS file
;                                [Default = FALSE]
;               FILENAME    :  Scalar [string] defining the file name for the saved PS
;                                file.  Note that the format of the file name must be
;                                such that IDL_VALIDNAME.PRO returns a non-null string
;                                with at least the CONVERT_ALL keyword set.
;                                [Default = 'vdf_fit_plot_0']
;               _EXTRA      :  Other keywords accepted by general_vdf_contour_plot.pro
;
;   CHANGED:  1)  NA
;                                                                   [MM/DD/YYYY   v1.0.0]
;
;   NOTES:      
;               0)  User should not call this routine directly
;
;  REFERENCES:  
;               NA
;
;   ADAPTED FROM: plot_vdfs_4_fitvdf2sumof3funcs.pro    BY: Lynn B. Wilson III
;   CREATED:  09/17/2019
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  09/17/2019   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

PRO plot_model_fit_vdf_2_so3fs,vdf,velxyz,out_struc,VFRAME=vframe,VEC1=vec1,VEC2=vec2,$
                               ONLY_TOT=only_tot,PLOT_BOTH=plot_both,                 $
                               CORE_LABS=core_labs,HALO_LABS=halo_labs,               $
                               BEAM_LABS=beam_labs,XYLAB_PRE=xylabpre,                $
                               CFUNC=cfunc,HFUNC=hfunc,BFUNC=bfunc,                   $
                               CFACT=cfact,HFACT=hfact,BFACT=bfact,                   $
                               ELECTRONS=electrons,IONS=ions,                         $
                               SPTHRSHS=spthrshs,MAXFACS=maxfac0,                     $
                               SAVEF=savef,FILENAME=filename,                         $
                               _EXTRA=extrakey

;;----------------------------------------------------------------------------------------
;;  Constants
;;----------------------------------------------------------------------------------------
f                       = !VALUES.F_NAN
d                       = !VALUES.D_NAN
verns                   = !VERSION.RELEASE     ;;  e.g., '7.1.1'
vernn                   = LONG(STRMID(verns[0],0L,1L))
;;  Check IDL version
IF (vernn[0] LT 8) THEN nan_on = 0b ELSE nan_on = 1b
;;----------------------------------------------------------------------------------------
;;  Defaults
;;----------------------------------------------------------------------------------------
c__trial                = 0                  ;;  Counting value to let user know how many tries the routine used before exiting
h__trial                = 0                  ;;  Counting value to let user know how many tries the routine used before exiting
b__trial                = 0                  ;;  Counting value to let user know how many tries the routine used before exiting
pre_pre_str             = ';;  '
sform                   = '(e15.4)'
fitstat_mid             = ['Model Fit Status  ','# of Iterations   ','Deg. of Freedom   ',$
                           'Chi-Squared       ','Red. Chi-Squared  ']+'= '
c_cols                  = [225, 75]
h_cols                  = [200, 30]
b_cols                  = [110, 90]
t_cols                  = [200,100]
maxiter                 = 300L               ;;  Default maximum # of iterations to allow MPFIT.PRO to cycle through
def_ctab                = 39                 ;;  Default color table for lines
thck                    = 3.5e0
now_save                = 0b
both_plotted            = 0b
out_tagt                = ['CORE','HALO','BEAM']
;;  Define popen structure
popen_str               = {PORT:1,UNITS:'inches',XSIZE:8e0,YSIZE:11e0,ASPECT:0}
;;  Define defaults for SPTHRSHS and MAXFACS
def_spdthrfac           = [15d-2,20d-2,20d-2]           ;;  Fraction of maximum speeds
def_maxfacs             = [4d0,1d0,1d0]*2.25d0          ;;  Fraction of maximum peak ratios
;;----------------------------------------------------------------------------------------
;;  Check input
;;----------------------------------------------------------------------------------------
IF (N_PARAMS() LT 3) THEN RETURN          ;;  Don't bother if nothing is provided
;;  Check parameter
test                    = is_a_number(vdf,/NOMSSG) AND is_a_3_vector(velxyz,V_OUT=vv1,/NOMSSG)
IF (~test[0]) THEN RETURN                 ;;  Don't bother if input is bad
szdf                    = SIZE(vdf,/DIMENSIONS)
szdv                    = SIZE(vv1,/DIMENSIONS)
IF (szdf[0] NE szdv[0]) THEN RETURN       ;;  Don't bother if input is improperly formatted
nn_f                    = szdf[0]         ;;  # of VDF points in input array
vdf                     = REFORM(vdf,nn_f[0])
velxyz                  = vv1
vv1                     = 0
;;  Check structure
IF (SIZE(out_struc,/TYPE) NE 8) THEN RETURN
tags                    = TAG_NAMES(out_struc)
test                    = 0b
FOR k=0L, 2L DO test += (TOTAL(tags EQ out_tagt[k]))
IF (TOTAL(test) NE 3) THEN RETURN
core_strc               = out_struc.CORE
halo_strc               = out_struc.HALO
beam_strc               = out_struc.BEAM
statc                   = core_strc.STATUS
stath                   = halo_strc.STATUS
statb                   = beam_strc.STATUS
test                    = (statc[0] LE 0)
IF (test[0]) THEN RETURN                 ;;  Don't bother if input is bad
n_vdf                   = N_ELEMENTS(core_strc.Z_IN)
n_par                   = N_ELEMENTS(core_strc.X_IN)
n_per                   = N_ELEMENTS(core_strc.Y_IN)
;;----------------------------------------------------------------------------------------
;;  Open 1 plot window
;;----------------------------------------------------------------------------------------
dev_name                = STRLOWCASE(!D[0].NAME[0])
os__name                = STRLOWCASE(!VERSION.OS_FAMILY)       ;;  'unix' or 'windows'
;;  Check device settings
test_xwin               = (dev_name[0] EQ 'x') OR (dev_name[0] EQ 'win')
IF (test_xwin[0]) THEN BEGIN
  ;;  Proper setting --> find out which windows are already open
  DEVICE,WINDOW_STATE=wstate
ENDIF ELSE BEGIN
  ;;  Switch to proper device
  IF (os__name[0] EQ 'windows') THEN SET_PLOT,'win' ELSE SET_PLOT,'x'
  ;;  Determine which windows are already open
  DEVICE,WINDOW_STATE=wstate
ENDELSE
DEVICE,GET_SCREEN_SIZE=s_size
wsz                     = LONG(MIN(s_size*7d-1))
xywsz                   = [wsz[0],LONG(wsz[0]*1.375d0)]
;;  Now that things are okay, check window status
good_w                  = WHERE(wstate,gd_w)
wind_ns                 = [4,5]
;;  Check if user specified window is already open
test_wopen1             = (TOTAL(good_w EQ wind_ns[1]) GT 0)     ;;  TRUE --> window already open
IF (test_wopen1[0]) THEN BEGIN
  ;;  Window 5 is open --> check if was opened by this routine
  WSET,wind_ns[1]
  cur_xywsz               = [!D.X_SIZE[0],!D.Y_SIZE[0]]
  new_w_1                 = (xywsz[0] NE cur_xywsz[0]) OR (xywsz[1] NE cur_xywsz[1])
ENDIF ELSE new_w_1 = 1b   ;;  Open new  window
win_ttl                 = 'VDF Fit Results'
win_str                 = {RETAIN:2,XSIZE:xywsz[0],YSIZE:xywsz[1],TITLE:win_ttl[0],XPOS:50,YPOS:10}
lbw_window,WIND_N=wind_ns[1],NEW_W=new_w_1[0],_EXTRA=win_str,/CLEAN
;;----------------------------------------------------------------------------------------
;;  Check keywords
;;----------------------------------------------------------------------------------------
;;------------------------------
;;  Check ONLY_TOT
;;------------------------------
test           = (N_ELEMENTS(only_tot) GT 0) AND KEYWORD_SET(only_tot)
IF (test[0]) THEN plottot_on = 1b ELSE plottot_on = 0b
;;------------------------------
;;  Check PLOT_BOTH
;;------------------------------
test           = (N_ELEMENTS(plot_both) GT 0) AND KEYWORD_SET(plot_both)
IF (test[0]) THEN BEGIN
  both_on    = 1b
  plottot_on = 0b  ;;  Shut off only total
ENDIF ELSE BEGIN
  both_on    = 0b
ENDELSE
;;------------------------------
;;  Check [C,H,B]FUNC
;;------------------------------
test                    = (SIZE(cfunc,/TYPE) EQ 7)
IF (test[0]) THEN cf = STRUPCASE(STRMID(cfunc[0],0,2)) ELSE cf = 'MM'
CASE cf[0] OF               ;;  Redefine output to proper/allowed format
  'MM'  :  cfunc       = 'MM'
  'KK'  :  cfunc       = 'KK'
  'SS'  :  cfunc       = 'SS'
  'AS'  :  cfunc       = 'AS'
  ELSE  :  cfunc       = 'MM'     ;;  Default
ENDCASE
test                    = (SIZE(hfunc,/TYPE) EQ 7)
IF (test[0]) THEN hf = STRUPCASE(STRMID(hfunc[0],0,2)) ELSE hf = 'KK'
CASE hf[0] OF               ;;  Redefine output to proper/allowed format
  'MM'  :  hfunc       = 'MM'
  'KK'  :  hfunc       = 'KK'
  'SS'  :  hfunc       = 'SS'
  'AS'  :  hfunc       = 'AS'
  ELSE  :  hfunc       = 'KK'     ;;  Default
ENDCASE
test                    = (SIZE(bfunc,/TYPE) EQ 7)
IF (test[0]) THEN bf = STRUPCASE(STRMID(bfunc[0],0,2)) ELSE bf = 'KK'
CASE bf[0] OF               ;;  Redefine output to proper/allowed format
  'MM'  :  bfunc       = 'MM'
  'KK'  :  bfunc       = 'KK'
  'SS'  :  bfunc       = 'SS'
  'AS'  :  bfunc       = 'AS'
  ELSE  :  bfunc       = 'KK'     ;;  Default
ENDCASE
;;------------------------------
;;  Check [C,H,B]FACT
;;------------------------------
test_cf                 = is_a_number(cfact,/NOMSSG) AND (N_ELEMENTS(cfact) EQ 6)
test_hf                 = is_a_number(hfact,/NOMSSG) AND (N_ELEMENTS(hfact) EQ 6)
test_bf                 = is_a_number(bfact,/NOMSSG) AND (N_ELEMENTS(bfact) EQ 6)
IF (~test_cf[0]) THEN cfact = REPLICATE(1d0,6)
IF (~test_hf[0]) THEN hfact = REPLICATE(1d0,6)
IF (~test_bf[0]) THEN bfact = REPLICATE(1d0,6)
;;------------------------------
;;  Check SPTHRSHS
;;------------------------------
test                    = (N_ELEMENTS(spthrshs) GE 3) AND is_a_number(spthrshs,/NOMSSG)
IF (test[0]) THEN spd_thrsh_on = 1b ELSE spd_thrsh_on = 0b
IF (spd_thrsh_on[0]) THEN spd_fracs = ABS(DOUBLE(spthrshs[0:2])) > 1d-2 ELSE spd_fracs = def_spdthrfac
;;------------------------------
;;  Check MAXFACS
;;------------------------------
test                    = (N_ELEMENTS(maxfac0) GE 3) AND is_a_number(maxfac0,/NOMSSG)
IF (test[0]) THEN maxfacs = ABS(DOUBLE(maxfac0[0:2])) > 1.1 ELSE maxfacs = def_maxfacs
;;------------------------------
;;  Check SAVEF
;;------------------------------
test           = (N_ELEMENTS(savef) GT 0) AND KEYWORD_SET(savef)
IF (test[0]) THEN save_on = 1b ELSE save_on = 0b
;;------------------------------
;;  Check FILENAME
;;------------------------------
test                    = (N_ELEMENTS(filename) GT 0) AND (SIZE(filename,/TYPE) EQ 7)
IF (test[0]) THEN fname = filename[0] ELSE IF (save_on[0]) THEN fname = 'vdf_fit_plot_0' ELSE fname = ''
test                    = ~save_on[0] AND ((SIZE(fname[0],/TYPE) EQ 7) AND (fname[0] NE ''))
IF (test[0]) THEN save_on = 1b  ;;  Turn on file saving in case it was not set but FILENAME was
;;------------------------------
;;  Check format of file name
;;------------------------------
test                    = (fname[0] EQ '') OR $
                          ((IDL_VALIDNAME(fname[0],/CONVERT_SPACES) EQ '') AND $
                           (IDL_VALIDNAME(fname[0],/CONVERT_ALL)    EQ '')     )
IF (test[0]) THEN BEGIN
  ;;  format is bad --> shut off file saving
  IF (save_on[0]) THEN BEGIN
    ;;  Let user know something went wrong
    MESSAGE,'Bad FILENAME input format --> No file will be saved!',/INFORMATIONAL,/CONTINUE
  ENDIF
  f_name  = ''
  save_on = 0b  ;;  Turn off file saving
ENDIF ELSE BEGIN
  ;;  get current working directory
  test    = test_file_path_format('.',EXISTS=exists,DIR_OUT=savdir)
  ;;  format is good --> remove any leading or trailing spaces
  f_name  = savdir[0]+STRTRIM(fname[0],2L)
  save_on = 1b  ;;  Turn on file saving in case it was not set but FILENAME was
ENDELSE
;;----------------------------------------------------------------------------------------
;;  Setup plot parameters for VDFs
;;----------------------------------------------------------------------------------------
;;  Used km
vx_km                   = core_strc.X_IN
vy_km                   = core_strc.Y_IN
vx_in                   = vx_km
vy_in                   = vy_km
vx_Mm                   = vx_km*1d-3                          ;;  km --> Mm
vy_Mm                   = vy_km*1d-3                          ;;  km --> Mm
vpar2d                  = vx_km # REPLICATE(1d0,n_per[0])
vper2d                  = REPLICATE(1d0,n_par[0]) # vy_km
vel_2d                  = [[[vpar2d]],[[vper2d]]]             ;;  [N,M,2]-Element array
speed                   = SQRT(TOTAL(vel_2d^2,3,/NAN))        ;;  [N,M]-Element array of speeds [km/s]
mnmxsp                  = [MIN(speed,/NAN),MAX(speed,/NAN)]
spdthr                  = spd_fracs*mnmxsp[1]
cvtherm                 = MAX(core_strc.FIT_PARAMS[1:2],/NAN)
vspmax                  = ([6d1,4d3])[KEYWORD_SET(electrons)]
IF (FINITE(cvtherm[0])) THEN cvthmax = vspmax[0] > cvtherm[0] ELSE cvthmax = vspmax[0]
;;  Define speed thresholds for each component
spdthr                  = ABS(spdthr) < cvthmax[0]
;;  Find elements below these thresholds
good_lspc               = WHERE(speed LE spdthr[0],gd_lspc,COMPLEMENT=bad_lspc,NCOMPLEMENT=bd_lspc)
good_lsph               = WHERE(speed LE spdthr[1],gd_lsph,COMPLEMENT=bad_lsph,NCOMPLEMENT=bd_lsph)
good_lspb               = WHERE(speed LE spdthr[2],gd_lspb,COMPLEMENT=bad_lspb,NCOMPLEMENT=bd_lspb)
;;----------------------------------------------------------------------------------------
;;  Define core fit strings for output
;;----------------------------------------------------------------------------------------
;;  Defaults
units_out               = '  '+['cm^(-3)',REPLICATE('km s^(-1)',4L),'']
midf                    = ' +/- '
c_units                 = units_out
h_units                 = units_out
b_units                 = units_out
IF (cfunc[0] EQ 'AS') THEN c_units[4] = ''
IF (hfunc[0] EQ 'AS') THEN h_units[4] = ''
IF (bfunc[0] EQ 'AS') THEN b_units[4] = ''
;;  GOTO:  Used if fits produced bad results where model exceeded data by threshold factor
;;========================================================================================
JUMP_RECORE:
;;========================================================================================
c__trial               += 1
;;  Core stuff
cfitp                   = core_strc.FIT_PARAMS
csigp                   = core_strc.SIG_PARAM
iterc                   = core_strc.N_ITER[0]
dofc                    = core_strc.DOF[0]
chisqc                  = core_strc.CHISQ[0]
;cfun                    = core_strc.FUNC[0]
;;  Use model functions without offsets
CASE cf[0] OF
  'MM'  :  cfun        = 'bimaxwellian_fit'
  'KK'  :  cfun        = 'bikappa_fit'
  'SS'  :  cfun        = 'biselfsimilar_fit'
  'AS'  :  cfun        = 'biselfsimilar_2exp_fit'
  ELSE  :  cfun        = 'bimaxwellian_fit'     ;;  Default
ENDCASE
;;  Check status so we do not output "fake" or "guess" lines
IF (statc[0] LE 0) THEN BEGIN
  ;;  Force output to zeros to indicate failure
  cfitp  = REPLICATE(0d0,6)
  csigp  = REPLICATE(0d0,6)
  chisqc = d
  dofc   = d
ENDIF
;;  Define sign of fit values
signcf                  = sign(cfitp)
scf_str                 = (['-','+'])[(signcf GT 0)]
;;  Define fit status, DoFs, and Red. Chi-Squared strings
cstatstr                = num2int_str(statc[0],NUM_CHAR=6L,/ZERO_PAD)
dofc_str                = num2int_str(dofc[0],NUM_CHAR=10L,/ZERO_PAD)
citerstr                = num2int_str(iterc[0],NUM_CHAR=6L,/ZERO_PAD)
chsqcstr                = STRTRIM(STRING(ABS(chisqc[0]),FORMAT=sform[0]),2L)
rcsqcstr                = STRTRIM(STRING(ABS(chisqc[0]/dofc[0]),FORMAT=sform[0]),2L)
cfitstatsuf             = [cstatstr[0],citerstr[0],dofc_str[0],chsqcstr[0],rcsqcstr[0]]
;;  Define print output of fit results
cfit_str                = scf_str+STRTRIM(STRING(ABS(cfitp),FORMAT=sform[0]),2L)
csig_str                =         STRTRIM(STRING(ABS(csigp),FORMAT=sform[0]),2L)
core_xyout              = core_labs+cfit_str+midf[0]+csig_str+c_units
cstatxyout              = pre_pre_str[0]+fitstat_mid+cfitstatsuf
;;----------------------------------------------------------------------------------------
;;  Define halo fit strings for output
;;----------------------------------------------------------------------------------------
;;  GOTO:  Used if fits produced bad results where model exceeded data by threshold factor
;;========================================================================================
JUMP_REHALO:
;;========================================================================================
h__trial               += 1
hfitp                   = halo_strc.FIT_PARAMS
hsigp                   = halo_strc.SIG_PARAM
iterh                   = halo_strc.N_ITER[0]
dofh                    = halo_strc.DOF[0]
chisqh                  = halo_strc.CHISQ[0]
;hfun                    = halo_strc.FUNC[0]
;;  Use model functions without offsets
CASE hf[0] OF
  'MM'  :  hfun        = 'bimaxwellian_fit'
  'KK'  :  hfun        = 'bikappa_fit'
  'SS'  :  hfun        = 'biselfsimilar_fit'
  'AS'  :  hfun        = 'biselfsimilar_2exp_fit'
  ELSE  :  hfun        = 'bikappa_fit'     ;;  Default
ENDCASE
;;  Check status so we do not output "fake" or "guess" lines
IF (stath[0] LE 0) THEN BEGIN
  ;;  Force output to zeros to indicate failure
  hfitp  = REPLICATE(0d0,6)
  hsigp  = REPLICATE(0d0,6)
  chisqh = d
  dofh   = d
ENDIF
;;  Define sign of fit values
signhf                  = sign(hfitp)
shf_str                 = (['-','+'])[(signhf GT 0)]
;;  Define fit status, DoFs, and Red. Chi-Squared strings
hstatstr                = num2int_str(stath[0],NUM_CHAR=6L,/ZERO_PAD)
dofh_str                = num2int_str(dofh[0],NUM_CHAR=10L,/ZERO_PAD)
hiterstr                = num2int_str(iterh[0],NUM_CHAR=6L,/ZERO_PAD)
chsqhstr                = STRTRIM(STRING(ABS(chisqh[0]),FORMAT=sform[0]),2L)
rcsqhstr                = STRTRIM(STRING(ABS(chisqh[0]/dofh[0]),FORMAT=sform[0]),2L)
hfitstatsuf             = [hstatstr[0],hiterstr[0],dofh_str[0],chsqhstr[0],rcsqhstr[0]]
;;  Define print output of fit results
hfit_str                = shf_str+STRTRIM(STRING(ABS(hfitp),FORMAT=sform[0]),2L)
hsig_str                =         STRTRIM(STRING(ABS(hsigp),FORMAT=sform[0]),2L)
halo_xyout              = halo_labs+hfit_str+midf[0]+hsig_str+h_units
hstatxyout              = pre_pre_str[0]+fitstat_mid+hfitstatsuf
;;----------------------------------------------------------------------------------------
;;  Define beam fit strings for output
;;----------------------------------------------------------------------------------------
;;  GOTO:  Used if fits produced bad results where model exceeded data by threshold factor
;;========================================================================================
JUMP_REBEAM:
;;========================================================================================
b__trial               += 1
bfitp                   = beam_strc.FIT_PARAMS
bsigp                   = beam_strc.SIG_PARAM
iterb                   = beam_strc.N_ITER[0]
dofb                    = beam_strc.DOF[0]
chisqb                  = beam_strc.CHISQ[0]
;bfun                    = beam_strc.FUNC[0]
;;  Use model functions without offsets
CASE bf[0] OF
  'MM'  :  bfun        = 'bimaxwellian_fit'
  'KK'  :  bfun        = 'bikappa_fit'
  'SS'  :  bfun        = 'biselfsimilar_fit'
  'AS'  :  bfun        = 'biselfsimilar_2exp_fit'
  ELSE  :  bfun        = 'bikappa_fit'     ;;  Default
ENDCASE
;;  Check status so we do not output "fake" or "guess" lines
IF (statb[0] LE 0) THEN BEGIN
  ;;  Force output to zeros to indicate failure
  bfitp  = REPLICATE(0d0,6)
  bsigp  = REPLICATE(0d0,6)
  chisqb = d
  dofb   = d
ENDIF
;;  Define sign of fit values
signbf                  = sign(bfitp)
sbf_str                 = (['-','+'])[(signbf GT 0)]
;;  Define fit status, DoFs, and Red. Chi-Squared strings
bstatstr                = num2int_str(statb[0],NUM_CHAR=6L,/ZERO_PAD)
dofb_str                = num2int_str(dofb[0],NUM_CHAR=10L,/ZERO_PAD)
biterstr                = num2int_str(iterb[0],NUM_CHAR=6L,/ZERO_PAD)
chsqbstr                = STRTRIM(STRING(ABS(chisqb[0]),FORMAT=sform[0]),2L)
rcsqbstr                = STRTRIM(STRING(ABS(chisqb[0]/dofb[0]),FORMAT=sform[0]),2L)
bfitstatsuf             = [bstatstr[0],biterstr[0],dofb_str[0],chsqbstr[0],rcsqbstr[0]]
;;  Define print output of fit results
bfit_str                = sbf_str+STRTRIM(STRING(ABS(bfitp),FORMAT=sform[0]),2L)
bsig_str                =         STRTRIM(STRING(ABS(bsigp),FORMAT=sform[0]),2L)
beam_xyout              = beam_labs+bfit_str+midf[0]+bsig_str+b_units
bstatxyout              = pre_pre_str[0]+fitstat_mid+bfitstatsuf
;;----------------------------------------------------------------------------------------
;;  Print out fit results
;;----------------------------------------------------------------------------------------
test_trial              = (c__trial[0] EQ 1) AND (b__trial[0] EQ 1) AND (b__trial[0] EQ 1)
IF (test_trial[0]) THEN BEGIN
  PRINT,pre_pre_str[0]
  FOR jj=0L, N_ELEMENTS(core_xyout) - 1L DO PRINT,core_xyout[jj]
  FOR jj=0L, N_ELEMENTS(cstatxyout) - 1L DO PRINT,cstatxyout[jj]
  PRINT,pre_pre_str[0]
  FOR jj=0L, N_ELEMENTS(halo_xyout) - 1L DO PRINT,halo_xyout[jj]
  FOR jj=0L, N_ELEMENTS(hstatxyout) - 1L DO PRINT,hstatxyout[jj]
  PRINT,pre_pre_str[0]
  FOR jj=0L, N_ELEMENTS(beam_xyout) - 1L DO PRINT,beam_xyout[jj]
  FOR jj=0L, N_ELEMENTS(bstatxyout) - 1L DO PRINT,bstatxyout[jj]
  PRINT,pre_pre_str[0]
ENDIF
;;----------------------------------------------------------------------------------------
;;  Define 2D model function for core and halo
;;----------------------------------------------------------------------------------------
dumb1da                 = REPLICATE(d,n_par[0])
dumb1de                 = REPLICATE(d,n_per[0])
dumb2d                  = REPLICATE(d,n_par[0],n_per[0])
halo_2d                 = dumb2d
beam_2d                 = dumb2d
;;  Get 2D model results
core_2d                 = CALL_FUNCTION(cfun[0],vx_km,vy_km,cfitp,REPLICATE(0,6))
;;  Get 1D cuts
bicor_struc             = find_1d_cuts_2d_dist(core_2d,vx_km,vy_km,X_0=0d0,Y_0=0d0)
bicor_para              = bicor_struc.X_1D_FXY         ;;  horizontal 1D cut
bicor_perp              = bicor_struc.Y_1D_FXY         ;;  vertical 1D cut
IF (stath[0] GT 0) THEN BEGIN
  halo_2d                 = CALL_FUNCTION(hfun[0],vx_km,vy_km,hfitp,REPLICATE(0,6))
  bihal_struc             = find_1d_cuts_2d_dist(halo_2d,vx_km,vy_km,X_0=0d0,Y_0=0d0)
  bihal_para              = bihal_struc.X_1D_FXY         ;;  horizontal 1D cut
  bihal_perp              = bihal_struc.Y_1D_FXY         ;;  vertical 1D cut
ENDIF ELSE BEGIN
  bihal_para              = dumb1da
  bihal_perp              = dumb1de
ENDELSE
IF (statb[0] GT 0) THEN BEGIN
  beam_2d                 = CALL_FUNCTION(bfun[0],vx_km,vy_km,bfitp,REPLICATE(0,6))
  bbeam_struc             = find_1d_cuts_2d_dist(beam_2d,vx_km,vy_km,X_0=0d0,Y_0=0d0)
  bbeam_para              = bbeam_struc.X_1D_FXY         ;;  horizontal 1D cut
  bbeam_perp              = bbeam_struc.Y_1D_FXY         ;;  vertical 1D cut
ENDIF ELSE BEGIN
  bbeam_para              = dumb1da
  bbeam_perp              = dumb1de
ENDELSE
;;----------------------------------------------------------------------------------------
;;  Define 1D cuts total for model functions
;;----------------------------------------------------------------------------------------
temp                    = lbw__add(bicor_para,bihal_para,/NAN)
bitot_para              = lbw__add(temp,bbeam_para,/NAN)
temp                    = lbw__add(bicor_perp,bihal_perp,/NAN)
bitot_perp              = lbw__add(temp,bbeam_perp,/NAN)
IF (test_trial[0]) THEN BEGIN
  ;;--------------------------------------------------------------------------------------
  ;;  Check if the total or any component is bad
  ;;--------------------------------------------------------------------------------------
  z_orig                  = core_strc.Z_ORIG
  cor2zori                = ABS(core_2d/z_orig)
  hal2zori                = ABS(halo_2d/z_orig)
  bea2zori                = ABS(beam_2d/z_orig)
  ;;--------------------------------------------------------------------------------------
  ;;  Only look at the low energy/core region for deviations from model
  ;;--------------------------------------------------------------------------------------
  IF (bd_lspc[0] GT 0) THEN cor2zori[bad_lspc] = f
  IF (bd_lsph[0] GT 0) THEN hal2zori[bad_lsph] = f
  IF (bd_lspb[0] GT 0) THEN bea2zori[bad_lspb] = f
  checkc                  = (TOTAL(cor2zori GT maxfacs[0],/NAN) GT 2)
  checkh                  = (TOTAL(hal2zori GT maxfacs[1],/NAN) GT 2)
  checkb                  = (TOTAL(bea2zori GT maxfacs[2],/NAN) GT 2)
  check                   = [checkc[0],checkh[0],checkb[0]]
  bad                     = WHERE(check,bd)
  IF (bd[0] GT 0) THEN BEGIN
    CASE bd[0] OF
      1    :  BEGIN
        ;;--------------------------------------------------------------------------------
        ;;  Only 1 is bad
        ;;--------------------------------------------------------------------------------
        CASE bad[0] OF
          0    :  BEGIN
            statc                 = -21
            out_struc.CORE.STATUS = statc[0]
            GOTO,JUMP_RECORE
          END
          1    :  BEGIN
            stath                 = -21
            out_struc.HALO.STATUS = statH[0]
            GOTO,JUMP_REHALO
          END
          2    :  BEGIN
            statb                 = -21
            out_struc.BEAM.STATUS = statB[0]
            GOTO,JUMP_REBEAM
          END
        ENDCASE
      END
      2    :  BEGIN
        ;;--------------------------------------------------------------------------------
        ;;  2 are bad
        ;;--------------------------------------------------------------------------------
        IF (bad[0] EQ 0) THEN BEGIN
          ;;  Core is bad
          statc                 = -22
          out_struc.CORE.STATUS = statc[0]
          IF (bad[1] EQ 1) THEN BEGIN
            stath                 = -22
            out_struc.HALO.STATUS = stath[0]
          ENDIF ELSE BEGIN
            statb                 = -22
            out_struc.BEAM.STATUS = statb[0]
          ENDELSE
          GOTO,JUMP_RECORE
        ENDIF ELSE BEGIN
          ;;  Halo and beam are bad
          stath                 = -22
          statb                 = -22
          out_struc.HALO.STATUS = stath[0]
          out_struc.BEAM.STATUS = statb[0]
          GOTO,JUMP_REHALO
        ENDELSE
      END
      3    :  BEGIN
        ;;--------------------------------------------------------------------------------
        ;;  All are bad!?
        ;;--------------------------------------------------------------------------------
        statc                 = -23
        stath                 = -23
        statb                 = -23
        ;;  Fix issue in structure so user knows not to trust values
        out_struc.CORE.STATUS = statc[0]
        out_struc.HALO.STATUS = stath[0]
        out_struc.BEAM.STATUS = statb[0]
        GOTO,JUMP_RECORE
      END
      ELSE :  ;; Do nothing
    ENDCASE
  ENDIF
ENDIF
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Replot 2D contour of VDF with fit results
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;========================================================================================
JUMP_REPLOT:
;;========================================================================================
IF (both_on[0]) THEN BEGIN
  CASE both_plotted[0] OF
    0     :  f_name1 = f_name[0]+'_only_tot'      ;;  start with user default settings plus defining suffix
    1     :  f_name1 = f_name[0]+'_show_comps'    ;;  now show the components
    ELSE  :  STOP   ;;  Debug, should not happen!
  END
ENDIF ELSE BEGIN
  IF (plottot_on[0]) THEN f_name1 = f_name[0]+'_only_tot' ELSE f_name1 = f_name[0]+'_show_comps'
ENDELSE
IF (save_on[0]) THEN BEGIN
  ;;  User wants to save --> do not plot to screen
  IF (now_save[0]) THEN BEGIN
    ;;  Now save plot
    popen,f_name1[0],_EXTRA=popen_str
  ENDIF ELSE BEGIN
    WSET,wind_ns[1]
    WSHOW,wind_ns[1]
  ENDELSE
ENDIF ELSE BEGIN
  ;;  User did not want to save --> plot to screen
  WSET,wind_ns[1]
  WSHOW,wind_ns[1]
ENDELSE
IF (STRLOWCASE(!D.NAME) EQ 'ps') THEN BEGIN
  l_thick  = 4e0            ;;  Plot line thickness
  chthick  = 3e0            ;;  Character line thickness
ENDIF ELSE BEGIN
  l_thick  = 2e0
  chthick  = 1.5e0
ENDELSE
;;----------------------------------------------------------------------------------------
;;  Plot Contour
;;----------------------------------------------------------------------------------------
general_vdf_contour_plot,vdf,velxyz,VFRAME=vframe,VEC1=vec1,VEC2=vec2,DAT_OUT=dat_out,_EXTRA=extrakey
;;  Oplot Fit results
IF (plottot_on[0] OR (both_on[0] AND both_plotted[0] EQ 0)) THEN BEGIN
  ;;--------------------------------------------------------------------------------------
  ;;  Only plot total sum of fit lines
  ;;--------------------------------------------------------------------------------------
  OPLOT,vx_Mm,bitot_para,COLOR=t_cols[0],LINESTYLE=3,THICK=l_thick[0]
  OPLOT,vy_Mm,bitot_perp,COLOR=t_cols[1],LINESTYLE=3,THICK=l_thick[0]
  ;;  Output labels
  cutstruc   = dat_out.CUTS_DATA.CUT_LIM
  xyposi     = [3d-1*cutstruc.XRANGE[1],1d1*cutstruc.YRANGE[0]]
  XYOUTS,xyposi[0],xyposi[1],'Total Para.',/DATA,COLOR=t_cols[0],CHARTHICK=chthick[0]
  xyposi[1] *= 0.7
  XYOUTS,xyposi[0],xyposi[1],'Total Perp.',/DATA,COLOR=t_cols[1],CHARTHICK=chthick[0]
ENDIF ELSE BEGIN
  ;;--------------------------------------------------------------------------------------
  ;;  Plot fit lines individually
  ;;--------------------------------------------------------------------------------------
  OPLOT,vx_Mm,bicor_para,COLOR=c_cols[0],LINESTYLE=3,THICK=l_thick[0]
  OPLOT,vy_Mm,bicor_perp,COLOR=c_cols[1],LINESTYLE=3,THICK=l_thick[0]
  OPLOT,vx_Mm,bihal_para,COLOR=h_cols[0],LINESTYLE=3,THICK=l_thick[0]
  OPLOT,vy_Mm,bihal_perp,COLOR=h_cols[1],LINESTYLE=3,THICK=l_thick[0]
  IF (statb[0] GT 0) THEN BEGIN
    ;;  Oplot beam fit
    OPLOT,vx_Mm,bbeam_para,COLOR=b_cols[0],LINESTYLE=3,THICK=l_thick[0]
    OPLOT,vy_Mm,bbeam_perp,COLOR=b_cols[1],LINESTYLE=3,THICK=l_thick[0]
  ENDIF
  ;;  Output labels
  cutstruc   = dat_out.CUTS_DATA.CUT_LIM
  xyposi     = [3d-1*cutstruc.XRANGE[1],1d1*cutstruc.YRANGE[0]]
  XYOUTS,xyposi[0],xyposi[1],xylabpre[0]+' Para. Core',/DATA,COLOR=c_cols[0],CHARTHICK=chthick[0]
  xyposi[1] *= 0.7
  XYOUTS,xyposi[0],xyposi[1],xylabpre[0]+' Perp. Core',/DATA,COLOR=c_cols[1],CHARTHICK=chthick[0]
  xyposi[1] *= 0.7
  XYOUTS,xyposi[0],xyposi[1],xylabpre[1]+' Para. Halo',/DATA,COLOR=h_cols[0],CHARTHICK=chthick[0]
  xyposi[1] *= 0.7
  XYOUTS,xyposi[0],xyposi[1],xylabpre[1]+' Perp. Halo',/DATA,COLOR=h_cols[1],CHARTHICK=chthick[0]
  IF (statb[0] GT 0) THEN BEGIN
    ;;  Output beam info
    xyposi[1] *= 0.7
    XYOUTS,xyposi[0],xyposi[1],xylabpre[2]+' Para. Beam',/DATA,COLOR=b_cols[0],CHARTHICK=chthick[0]
    xyposi[1] *= 0.7
    XYOUTS,xyposi[0],xyposi[1],xylabpre[2]+' Perp. Beam',/DATA,COLOR=b_cols[1],CHARTHICK=chthick[0]
  ENDIF
ENDELSE
;;----------------------------------------------------------------------------------------
;;  Print out fit results to plot
;;----------------------------------------------------------------------------------------
xyposi                  = [0.785,0.06,0.02]
temp_outc               = STRTRIM(STRMID(core_xyout[0L:4L],2L),2L)
temp_outh               = STRTRIM(STRMID(halo_xyout[0L:4L],2L),2L)
temp_outb               = STRTRIM(STRMID(beam_xyout[0L:4L],2L),2L)
temp_out                = temp_outc+';  '+temp_outh+';  '+temp_outb
;;  Print out parameters (not exponents yet)
FOR jj=0L, 4L DO BEGIN
  xyposi[0] += xyposi[2]
  XYOUTS,xyposi[0],xyposi[1],temp_out[jj],CHARSIZE=.65,/NORMAL,ORIENTATION=90.,CHARTHICK=chthick[0]
ENDFOR
;;  Print out exponents
temp_out                = STRTRIM(STRMID(core_xyout[5L],2L),2L)
temp_out[0]            += ';  '+STRTRIM(STRMID(halo_xyout[5L],2L),2L)
temp_out[0]            += ';  '+STRTRIM(STRMID(beam_xyout[5L],2L),2L)
xyposi[0]              += xyposi[2]
XYOUTS,xyposi[0],xyposi[1],temp_out[0],CHARSIZE=.65,/NORMAL,ORIENTATION=90.,CHARTHICK=chthick[0]
;;----------------------------------------------------------------------------------------
;;  Output fit status etc.
;;----------------------------------------------------------------------------------------
fitstat_mid             = ['Model Fit Status  ','# of Iterations   ','Deg. of Freedom   ',$
                           'Chi-Squared       ','Red. Chi-Squared  ']+'[C,H,B] = '
fstatstrout             = cfitstatsuf+', '+hfitstatsuf+', '+bfitstatsuf
temp_outc               = fitstat_mid+fstatstrout
;;  Output fit status, # of iterations, and degrees of freedom
temp_out                = temp_outc[0]+';  '+temp_outc[1]+';  '+temp_outc[2]
xyposi[0]              += xyposi[2]
XYOUTS,xyposi[0],xyposi[1],temp_out[0],CHARSIZE=.65,/NORMAL,ORIENTATION=90.,CHARTHICK=chthick[0]
;;  Output reduced chi-squared
temp_out                = temp_outc[4]
xyposi[0]              += xyposi[2]
XYOUTS,xyposi[0],xyposi[1],temp_out[0],CHARSIZE=.65,/NORMAL,ORIENTATION=90.,CHARTHICK=chthick[0]
;;----------------------------------------------------------------------------------------
;;  Close file if saving
;;----------------------------------------------------------------------------------------
IF (save_on[0]) THEN BEGIN
  IF (now_save[0]) THEN BEGIN
    ;;  Now save plot
    pclose
    IF (both_on[0]) THEN BEGIN
      ;;  Replot with components the 2nd time through
      both_plotted += 1b
      IF (both_plotted[0] LT 2) THEN GOTO,JUMP_REPLOT
    ENDIF
  ENDIF ELSE BEGIN
    now_save = 1b
    GOTO,JUMP_REPLOT
  ENDELSE
ENDIF
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN
END









































;-----------------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------------
; => From THEMIS prompt
;-----------------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------------

;;----------------------------------------------------------------------------------------
;; => Constants
;;----------------------------------------------------------------------------------------
f      = !VALUES.F_NAN
d      = !VALUES.D_NAN
epo    = 8.854187817d-12   ; => Permittivity of free space (F/m)
muo    = 4d0*!DPI*1d-7     ; => Permeability of free space (N/A^2 or H/m)
me     = 9.10938291d-31    ; => Electron mass (kg) [2010 value]
mp     = 1.672621777d-27   ; => Proton mass (kg) [2010 value]
ma     = 6.64465675d-27    ; => Alpha-Particle mass (kg) [2010 value]
qq     = 1.602176565d-19   ; => Fundamental charge (C) [2010 value]
kB     = 1.3806488d-23     ; => Boltzmann Constant (J/K) [2010 value]
K_eV   = 1.1604519d4       ; => Factor [Kelvin/eV] [2010 value]
c      = 2.99792458d8      ; => Speed of light in vacuum (m/s)
R_E    = 6.37814d3         ; => Earth's Equitorial Radius (km)

;; => Put the initialization routine (comp_lynn_pros.pro) in the ~/TDAS/tdas_7_??/idl/
;;      directory and change the file paths so they work for your personal machine

; => Compile necessary routines
@comp_lynn_pros
;;----------------------------------------------------------------------------------------
;; => Date/Times/Probes
;;      [the following are for made up times]
;;----------------------------------------------------------------------------------------
tdate      = '2009-09-26'
probe      = 'a'
probef     = probe[0]
gprobes    = probe[0]
sc         = probe[0]
tr_00      = tdate[0]+'/'+['12:00:00','17:40:00']
time_ra    = time_range_define(TRANGE=tr_00)
tr         = time_ra.TR_UNIX
;;----------------------------------------------------------------------------------------
;; Load state data (position, spin, etc.)
;;----------------------------------------------------------------------------------------
themis_load_fgm_esa_inst,TRANGE=tr,PROBE=sc[0],/LOAD_EESA_DF,EESA_DF_OUT=eesa_out,$
                         /LOAD_IESA_DF,IESA_DF_OUT=iesa_out,ESA_BF_TYPE='burst'

dat_i      = iesa_out.BURST  ;; [theta,phi]-angles in DSL coordinates
dat_e      = eesa_out.BURST
;;----------------------------------------------------------------------------------------
;; => Save ESA DFs for later
;;----------------------------------------------------------------------------------------
sc         = probe[0]
enames     = 'EESA_Burst_THEMIS_'+sc[0]+'_Structures_'+tdate[0]+'_lz_counts.sav'
inames     = 'IESA_Burst_THEMIS_'+sc[0]+'_Structures_'+tdate[0]+'_lz_counts.sav'
;;  **************************************
;;  **  Change the following according  **
;;  **************************************
mdir       = FILE_EXPAND_PATH('IDL_stuff/themis_data_dir/themis_esa_save/'+tdate[0]+'/')
efile      = mdir[0]+'/'+enames[0]
ifile      = mdir[0]+'/'+inames[0]

SAVE,dat_e,FILENAME=efile[0]
SAVE,dat_i,FILENAME=ifile[0]
;;----------------------------------------------------------------------------------------
;; => Restore ESA DFs
;;----------------------------------------------------------------------------------------
sc      = probe[0]
enames  = 'EESA_Burst_THEMIS_'+sc[0]+'_Structures_'+tdate[0]+'_lz_counts.sav'
inames  = 'IESA_Burst_THEMIS_'+sc[0]+'_Structures_'+tdate[0]+'_lz_counts.sav'

mdir    = FILE_EXPAND_PATH('IDL_stuff/themis_data_dir/themis_esa_save/'+tdate[0]+'/')
efiles  = FILE_SEARCH(mdir,enames[0])
ifiles  = FILE_SEARCH(mdir,inames[0])

RESTORE,efiles[0]
RESTORE,ifiles[0]
;;----------------------------------------------------------------------------------------
;; => Modify ESA DFs so they are compatible with UMN Wind/3DP Software
;;----------------------------------------------------------------------------------------
n_i        = N_ELEMENTS(dat_i)
n_e        = N_ELEMENTS(dat_e)
PRINT,';', n_i, n_e
;        ????        ????

modify_themis_esa_struc,dat_i
modify_themis_esa_struc,dat_e
;;----------------------------------------------------------------------------------------
;; => The following assumes you have followed the steps shown in the crib sheets:
;;      themis_esa_correct_bulk_flow_crib.txt and themis_esa_correct_moments_crib.txt
;;----------------------------------------------------------------------------------------
coord     = 'gse'
sc        = probe[0]
pref      = 'th'+sc[0]+'_'
velname   = pref[0]+'peib_velocity_'+coord[0]
vname_n   = pref[0]+'Velocity_peib_no_GIs_UV'
magname   = pref[0]+'fgh_'+coord[0]
spperi    = pref[0]+'state_spinper'
sc        = probe[0]
pref      = 'th'+sc[0]+'_'
scname    = tnames(pref[0]+'pe*b_sc_pot')

;; add SC potential to structures
add_scpot,dat_i,scname[1]
;; => Rotate DAT structure (theta,phi)-angles DSL --> GSE
dat_igse  = dat_i
rotate_esa_thetaphi_to_gse,dat_igse,MAGF_NAME=magname,VEL_NAME=vname_n
;; make sure MAGF tag is defined
magn_1    = pref[0]+'fgs_'+coord[0]
magn_2    = pref[0]+'fgh_'+coord[0]
add_magf2,dat_igse,magn_1[0],/LEAVE_ALONE
add_magf2,dat_igse,magn_2[0],/LEAVE_ALONE


;; add SC potential to structures
add_scpot,dat_e,scname[0]
;; => Rotate DAT structure (theta,phi)-angles DSL --> GSE
dat_egse  = dat_e
rotate_esa_thetaphi_to_gse,dat_egse,MAGF_NAME=magname,VEL_NAME=vname_n
;; make sure MAGF tag is defined
magn_1    = pref[0]+'fgs_'+coord[0]
magn_2    = pref[0]+'fgh_'+coord[0]
add_magf2,dat_egse,magn_1[0],/LEAVE_ALONE
add_magf2,dat_egse,magn_2[0],/LEAVE_ALONE
;;----------------------------------------------------------------------------------------
;; => Test IDL paths
;;      [if you get errors, check your IDL paths]
;;----------------------------------------------------------------------------------------
.compile get_color_by_name
.compile get_font_symbol
.compile delete_variable
.compile format_vector_string
.compile contour_vdf

.compile beam_fit_struc_create
.compile beam_fit_struc_common
.compile beam_fit___get_common
.compile beam_fit___set_common
.compile beam_fit_unset_common

.compile beam_fit_cursor_select

.compile beam_fit_set_defaults
.compile beam_fit_gen_prompt
.compile beam_fit_prompts
.compile beam_fit_list_options
.compile beam_fit_print_index_time
.compile beam_fit_options
.compile beam_fit_keywords_init

.compile df_fit_beam_peak
.compile beam_fit_fit_prompts
.compile beam_fit_fit_wrapper

.compile beam_fit_change_parameter
.compile beam_fit_contour_plot
.compile find_beam_peak_and_mask
.compile find_df_indices
.compile find_dist_func_cuts
.compile region_cursor_select
.compile beam_fit_1df_plot_fit

.compile beam_fit_test_struct_format
.compile wrapper_beam_fit_array
;;----------------------------------------------------------------------------------------
;; => Call beam fitting routines
;;----------------------------------------------------------------------------------------
tags_exv       = ['VEC','NAME']
sunv           = [1d0,0d0,0d0]
sunn           = 'Sun Dir.'
dumb           = CREATE_STRUCT(tags_exv,REPLICATE(d,3L),'')
ex_vecn        = REPLICATE(dumb[0],1L)
ex_vecn[0]     = CREATE_STRUCT(tags_exv,sunv,sunn[0])
dat            = dat_igse
wrapper_beam_fit_array,dat,EX_VECN=ex_vecn






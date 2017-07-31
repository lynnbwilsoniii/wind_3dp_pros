;;  crib_testing_ground.pro


;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Check prompting routines
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Open a window for later
wi,1


;;----------------------------------------------------------------------------------------
;;  Choose Date/Times/Probes
;;----------------------------------------------------------------------------------------
date           = '020906'
tdate          = '2006-02-09'
;;  Define spacecraft
sc             = 'Wind'
scpref         = sc[0]+'_'
;;  Setup options
lim0           = {XSTYLE:1,YSTYLE:1,XMINOR:9,YMINOR:9,XMARGIN:[10,10],YMARGIN:[5,5],$
                  XLOG:1,YLOG:1}
;;----------------------------------------------------------------------------------------
;;  Load example/dummy 3DP data for testing
;;----------------------------------------------------------------------------------------
no_load_vdfs   = 0b                    ;;  --> do load particle VDFs
;;  Load data
ex_start       = SYSTIME(1)            ;;  Time the execution of all events within
@/Users/lbwilson/Desktop/temp_idl/temp_gen_change_vbulk/crib_sheets/load_Wind_data_for_Vbulk_change_testing_batch.pro
MESSAGE,STRING(SYSTIME(1) - ex_start[0])+' seconds execution time.',/INFORMATIONAL,/CONTINUE

HELP,gapl_,gaplb,gaph_,gaphb,gael_,gaelb,gaeh_,gaehb,gasf_,gasfb,gaso_,gasob

;;  Compile necessary routines
.compile /Users/lbwilson/Desktop/temp_idl/temp_gen_change_vbulk/testing_routines/vbulk_change_get_default_struc.pro
.compile /Users/lbwilson/Desktop/temp_idl/temp_gen_change_vbulk/testing_routines/vbulk_change_test_cont_str_form.pro
.compile /Users/lbwilson/Desktop/temp_idl/temp_gen_change_vbulk/testing_routines/vbulk_change_test_plot_str_form.pro
.compile /Users/lbwilson/Desktop/temp_idl/temp_gen_change_vbulk/testing_routines/vbulk_change_test_vdf_str_form.pro
.compile /Users/lbwilson/Desktop/temp_idl/temp_gen_change_vbulk/testing_routines/vbulk_change_test_vdfinfo_str_form.pro
.compile /Users/lbwilson/Desktop/temp_idl/temp_gen_change_vbulk/testing_routines/vbulk_change_test_windn.pro
.compile /Users/lbwilson/Desktop/temp_idl/temp_gen_change_vbulk/prompting_routines/vbulk_change_list_options.pro
.compile /Users/lbwilson/Desktop/temp_idl/temp_gen_change_vbulk/prompting_routines/vbulk_change_prompts.pro
.compile /Users/lbwilson/Desktop/temp_idl/temp_gen_change_vbulk/prompting_routines/vbulk_change_options.pro
.compile /Users/lbwilson/Desktop/temp_idl/temp_gen_change_vbulk/misc_routines/vbulk_change_get_fname_ptitle.pro
.compile /Users/lbwilson/Desktop/temp_idl/temp_gen_change_vbulk/misc_routines/vbulk_change_print_index_time.pro
.compile /Users/lbwilson/Desktop/temp_idl/temp_gen_change_vbulk/prompting_routines/vbulk_change_keywords_init.pro
.compile /Users/lbwilson/Desktop/temp_idl/temp_gen_change_vbulk/prompting_routines/vbulk_change_change_parameter.pro
.compile /Users/lbwilson/Desktop/temp_idl/temp_gen_change_vbulk/vbulk_change_vdf_plot_wrapper.pro
.compile /Users/lbwilson/Desktop/temp_idl/temp_gen_change_vbulk/wrapper_vbulk_change_thm_wi.pro
;;  Define array of data structures
data           = gapl_
dfra_in        = [1e-14,1e-4]
wrapper_vbulk_change_thm_wi,data,DFRA_IN=dfra_in


;;  Create structure acceptable by bulk velocity changing routines
dat            = {VDF:v_df,VELXYZ:vxyz}
;;  Test keyword initialization routine with minimum input
windn          = 1L
DELVAR,plot_str,cont_str
vbulk_change_keywords_init,dat,WINDN=windn,PLOT_STR=plot_str,CONT_STR=cont_str

;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Check testing routines
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
.compile /Users/lbwilson/Desktop/temp_idl/temp_gen_change_vbulk/vbulk_change_get_default_struc.pro
.compile /Users/lbwilson/Desktop/temp_idl/temp_gen_change_vbulk/vbulk_change_test_cont_str_form.pro

delvar,temp,dat,dat_out,dat0
temp = vbulk_change_get_default_struc()
dat = temp
str_element,dat,'VFRAME',FLTARR(3),/ADD_REPLACE
str_element,dat,'DELTA',0d0,/ADD_REPLACE
test = vbulk_change_test_cont_str_form(dat,DAT_OUT=dat_out)

delvar,dat_out
dat0 = dat 
dat0.VFRAME = [-4d2,1d2,-1d1]
dat0.VEC1 = [-1d0,0d0,0d0]
dat0.VEC2 = [0d0,0d0,-1d0] 
dat0.XNAME = '-Xgse'
dat0.YNAME = '-Zgse'
test = vbulk_change_test_cont_str_form(dat0,DAT_OUT=dat_out)



;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Check general routines
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------


;;----------------------------------------------------------------------------------------
;;  Verify test_file_path_format.pro
;;----------------------------------------------------------------------------------------
;               [calling sequence]
;               test = test_file_path_format(path [,BASE_DIR=direc0] [,EXISTS=exists] $
;                                            [,DIR_OUT=dir_out]                       )
;.compile /Users/lbwilson/Desktop/temp_idl/temp_gen_change_vbulk/test_file_path_format.pro
.compile test_file_path_format.pro

;;  Try valid input
DELVAR,test,exists,dir_out,base_dir
path           = '/Users/lbwilson/Desktop/swidl-0.1/'
test           = test_file_path_format(path,BASE_DIR=base_dir,EXISTS=exists,DIR_OUT=dir_out)
PRINT,';;  ',test[0],'  ',exists[0],'  ',dir_out[0]
;;     1     1  /Users/lbwilson/Desktop/swidl-0.1/

;;  Try valid, but undefined input
DELVAR,test,exists,dir_out
path           = '/Users/lbwilson/Desktop/swidl-0.1/temporary/'
test           = test_file_path_format(path,BASE_DIR=base_dir,EXISTS=exists,DIR_OUT=dir_out)
PRINT,';;  ',test[0],'  ',exists[0],'  ',dir_out[0]
;;     1     0  /Users/lbwilson/Desktop/swidl-0.1/temporary/

;;  Try invalid input
DELVAR,test,exists,dir_out
path           = '/he walks/# to the !/Desktop/swidl-0.1/'
test           = test_file_path_format(path,BASE_DIR=base_dir,EXISTS=exists,DIR_OUT=dir_out)
PRINT,';;  ',test[0],'  ',exists[0],'  ',dir_out[0]
;;     0     0  

;;  Try valid, but "bad" input
DELVAR,test,exists,dir_out
path           = '$HOME/Desktop/swidl-0.@/'
test           = test_file_path_format(path,BASE_DIR=base_dir,EXISTS=exists,DIR_OUT=dir_out)
PRINT,';;  ',test[0],'  ',exists[0],'  ',dir_out[0]
;;     1     0  /Users/lbwilson/Desktop/swidl-0.@/

;;  Try invalid input
DELVAR,test,exists,dir_out
path           = '$HOME/Desktop/swidl-0.[#^`%]/'
test           = test_file_path_format(path,BASE_DIR=base_dir,EXISTS=exists,DIR_OUT=dir_out)
PRINT,';;  ',test[0],'  ',exists[0],'  ',dir_out[0]
;;     0     0  

;;  Try invalid input
DELVAR,test,exists,dir_out
path           = "/I am not good at defining # % good file paths/to/my/data\because\I mix OS's and don't read instructions/"
test           = test_file_path_format(path,BASE_DIR=base_dir,EXISTS=exists,DIR_OUT=dir_out)
PRINT,';;  ',test[0],'  ',exists[0],'  ',dir_out[0]
;;     0     0  


;;----------------------------------------------------------------------------------------
;;  Verify structure_compare.pro
;;----------------------------------------------------------------------------------------
;               [calling sequence]
;               test = structure_compare(str0a, str0b [,EXACT=exact] [,MATCH_NT=match_nt] $
;                                        [,MATCH_TG=match_tg] [,MATCH_TT=match_tt]        $
;                                        [,MATCH__L=match__l] [,MATCH_DL=match_dl]        $
;                                        [,NUMOVR_TG=numovr_tg] [,NUMOVR_TT=numovr_tt]    )
.compile structure_compare.pro
;.compile /Users/lbwilson/Desktop/temp_idl/temp_gen_change_vbulk/structure_compare.pro

;;  Define some dummy arrays
nn             = 100L
cone           = COMPLEX(1e0,0e0)
dumb1df        = FINDGEN(nn[0])
dumb1dd        = DINDGEN(nn[0])
dumb1dc        = CINDGEN(nn[0])
dumb2df2       = dumb1df # REPLICATE(1e0,2L)
dumb2df4       = dumb1df # REPLICATE(1e0,4L)
dumb2dd2       = dumb1dd # REPLICATE(1d0,2L)
dumb2dd4       = dumb1dd # REPLICATE(1d0,4L)
dumb2dc2       = dumb1dc # REPLICATE(cone[0],2L)
dumb2dc4       = dumb1dc # REPLICATE(cone[0],4L)
;;  Expected output
;;    0 --> no overlap (i.e., structures match in no way)
;;    1 --> At least one tag name matches
;;    2 --> At least one tag name matches and the type is the same
;;    3 --> MATCH_NT = TRUE
;;    4 --> MATCH_NT = TRUE & MATCH_TT = TRUE
;;    5 --> MATCH_NT = TRUE & MATCH_TG = TRUE
;;    6 --> MATCH_NT = TRUE & MATCH_TG = TRUE & MATCH_TT = TRUE (i.e., everything except dimensions of tag values match)
;;    7 --> EXACT = TRUE

;;  Try valid input
DELVAR,exact,match_nt,match_tg,match_tt,match__l,match_dl,numovr_tg,numovr_tt
str0a          = {X:dumb1dd,Y:dumb2df2}
str0b          = {X:dumb1dd*2,Y:dumb2df2*3}
test           = structure_compare(str0a,str0b,EXACT=exact,MATCH_NT=match_nt,       $
                                   MATCH_TG=match_tg,MATCH_TT=match_tt,             $
                                   MATCH__L=match__l,MATCH_DL=match_dl,             $
                                   NUMOVR_TG=numovr_tg,NUMOVR_TT=numovr_tt          )
PRINT,';;  ',test[0],exact[0],match_nt[0],match_tg[0],match_tt[0],match__l[0],match_dl[0],numovr_tg[0],numovr_tt[0]
;;     7   1   1   1   1   1   1           2           2

;;  Try valid input with different sized strings
DELVAR,exact,match_nt,match_tg,match_tt,match__l,match_dl,numovr_tg,numovr_tt
str0a          = {X:dumb1dd,Y:dumb2df2,Z:'Hello!'}
str0b          = {X:dumb1dd*2,Y:dumb2df2*3,Z:'Hello to everyone in the entire universe and beyond!'}
test           = structure_compare(str0a,str0b,EXACT=exact,MATCH_NT=match_nt,       $
                                   MATCH_TG=match_tg,MATCH_TT=match_tt,             $
                                   MATCH__L=match__l,MATCH_DL=match_dl,             $
                                   NUMOVR_TG=numovr_tg,NUMOVR_TT=numovr_tt          )
PRINT,';;  ',test[0],exact[0],match_nt[0],match_tg[0],match_tt[0],match__l[0],match_dl[0],numovr_tg[0],numovr_tt[0]
;;     7   1   1   1   1   1   1           3           3

;;  Works for structures of structures too
DELVAR,exact,match_nt,match_tg,match_tt,match__l,match_dl,numovr_tg,numovr_tt
str0a          = {X:dumb1dd,Y:dumb2df2,Z:{A:dumb1df,B:dumb1dc}}
str0b          = {X:dumb1dd/2,Y:dumb2df2/3,Z:{A:dumb1df*10,B:dumb1dc*3}}
test           = structure_compare(str0a,str0b,EXACT=exact,MATCH_NT=match_nt,       $
                                   MATCH_TG=match_tg,MATCH_TT=match_tt,             $
                                   MATCH__L=match__l,MATCH_DL=match_dl,             $
                                   NUMOVR_TG=numovr_tg,NUMOVR_TT=numovr_tt          )
PRINT,';;  ',test[0],exact[0],match_nt[0],match_tg[0],match_tt[0],match__l[0],match_dl[0],numovr_tg[0],numovr_tt[0]
;;     7   1   1   1   1   1   1           4           4

;;  Try bad input with different sized strings
DELVAR,exact,match_nt,match_tg,match_tt,match__l,match_dl,numovr_tg,numovr_tt
str0a          = {X:dumb1dd,Y:dumb2df2,Z:['Hello!']}
str0b          = {X:dumb1dd*2,Y:dumb2df2*3,Z:'Hello to everyone in the entire universe and beyond!'}
test           = structure_compare(str0a,str0b,EXACT=exact,MATCH_NT=match_nt,       $
                                   MATCH_TG=match_tg,MATCH_TT=match_tt,             $
                                   MATCH__L=match__l,MATCH_DL=match_dl,             $
                                   NUMOVR_TG=numovr_tg,NUMOVR_TT=numovr_tt          )
PRINT,';;  ',test[0],exact[0],match_nt[0],match_tg[0],match_tt[0],match__l[0],match_dl[0],numovr_tg[0],numovr_tt[0]
;;     6   0   1   1   1   1   1           3           3

;;  Try overlapping, but different number of tags
DELVAR,exact,match_nt,match_tg,match_tt,match__l,match_dl,numovr_tg,numovr_tt
str0a          = {X:dumb1dd,Y:dumb2df2}
str0b          = {X:dumb1dd,Y:dumb2df2,Z:dumb1dc}
test           = structure_compare(str0a,str0b,EXACT=exact,MATCH_NT=match_nt,       $
                                   MATCH_TG=match_tg,MATCH_TT=match_tt,             $
                                   MATCH__L=match__l,MATCH_DL=match_dl,             $
                                   NUMOVR_TG=numovr_tg,NUMOVR_TT=numovr_tt          )
PRINT,';;  ',test[0],exact[0],match_nt[0],match_tg[0],match_tt[0],match__l[0],match_dl[0],numovr_tg[0],numovr_tt[0]
;;     2   0   0   0   0   0   0           2           2

;;  Try overlapping in type only
DELVAR,exact,match_nt,match_tg,match_tt,match__l,match_dl,numovr_tg,numovr_tt
str0a          = {X:dumb1dd,Y:dumb2df2}
str0b          = {Z:dumb1dd,W:dumb2df2,V:dumb1dc}
test           = structure_compare(str0a,str0b,EXACT=exact,MATCH_NT=match_nt,       $
                                   MATCH_TG=match_tg,MATCH_TT=match_tt,             $
                                   MATCH__L=match__l,MATCH_DL=match_dl,             $
                                   NUMOVR_TG=numovr_tg,NUMOVR_TT=numovr_tt          )
PRINT,';;  ',test[0],exact[0],match_nt[0],match_tg[0],match_tt[0],match__l[0],match_dl[0],numovr_tg[0],numovr_tt[0]
;;     0   0   0   0   0   0   0           0           0

;;  Try same # of tags and types, but all different names
DELVAR,exact,match_nt,match_tg,match_tt,match__l,match_dl,numovr_tg,numovr_tt
str0a          = {X:dumb1dd,Y:dumb2df2}
str0b          = {Z:dumb1dd,W:dumb2df2}
test           = structure_compare(str0a,str0b,EXACT=exact,MATCH_NT=match_nt,       $
                                   MATCH_TG=match_tg,MATCH_TT=match_tt,             $
                                   MATCH__L=match__l,MATCH_DL=match_dl,             $
                                   NUMOVR_TG=numovr_tg,NUMOVR_TT=numovr_tt          )
PRINT,';;  ',test[0],exact[0],match_nt[0],match_tg[0],match_tt[0],match__l[0],match_dl[0],numovr_tg[0],numovr_tt[0]
;;     4   0   1   0   1   1   1           0           2

;;  Try same # of tags and tag names and types, but different dimensions
DELVAR,exact,match_nt,match_tg,match_tt,match__l,match_dl,numovr_tg,numovr_tt
str0a          = {X:dumb1dd,Y:dumb2df2}
str0b          = {X:dumb1dd,Y:dumb2df4}
test           = structure_compare(str0a,str0b,EXACT=exact,MATCH_NT=match_nt,       $
                                   MATCH_TG=match_tg,MATCH_TT=match_tt,             $
                                   MATCH__L=match__l,MATCH_DL=match_dl,             $
                                   NUMOVR_TG=numovr_tg,NUMOVR_TT=numovr_tt          )
PRINT,';;  ',test[0],exact[0],match_nt[0],match_tg[0],match_tt[0],match__l[0],match_dl[0],numovr_tg[0],numovr_tt[0]
;;     6   0   1   1   1   0   0           2           2

;;  Try same # of tags and tag names, but different types
DELVAR,exact,match_nt,match_tg,match_tt,match__l,match_dl,numovr_tg,numovr_tt
str0a          = {X:dumb1dd,Y:dumb2df2}
str0b          = {X:dumb1dd,Y:dumb2dd2}
test           = structure_compare(str0a,str0b,EXACT=exact,MATCH_NT=match_nt,       $
                                   MATCH_TG=match_tg,MATCH_TT=match_tt,             $
                                   MATCH__L=match__l,MATCH_DL=match_dl,             $
                                   NUMOVR_TG=numovr_tg,NUMOVR_TT=numovr_tt          )
PRINT,';;  ',test[0],exact[0],match_nt[0],match_tg[0],match_tt[0],match__l[0],match_dl[0],numovr_tg[0],numovr_tt[0]
;;     5       0   1   1   0   0   0           2           1

;;  Try same # of tags, but different names and types
DELVAR,exact,match_nt,match_tg,match_tt,match__l,match_dl,numovr_tg,numovr_tt
str0a          = {X:dumb1dd,Y:dumb2df2}
str0b          = {X:dumb1dd,Z:dumb2dd2}
test           = structure_compare(str0a,str0b,EXACT=exact,MATCH_NT=match_nt,       $
                                   MATCH_TG=match_tg,MATCH_TT=match_tt,             $
                                   MATCH__L=match__l,MATCH_DL=match_dl,             $
                                   NUMOVR_TG=numovr_tg,NUMOVR_TT=numovr_tt          )
PRINT,';;  ',test[0],exact[0],match_nt[0],match_tg[0],match_tt[0],match__l[0],match_dl[0],numovr_tg[0],numovr_tt[0]
;;     3   0   1   0   0   0   0           1           1

;;  Try same # of tags and types, but different names
DELVAR,exact,match_nt,match_tg,match_tt,match__l,match_dl,numovr_tg,numovr_tt
str0a          = {X:dumb1dd,Y:dumb2df2}
str0b          = {X:dumb1dd,Z:dumb2df2}
test           = structure_compare(str0a,str0b,EXACT=exact,MATCH_NT=match_nt,       $
                                   MATCH_TG=match_tg,MATCH_TT=match_tt,             $
                                   MATCH__L=match__l,MATCH_DL=match_dl,             $
                                   NUMOVR_TG=numovr_tg,NUMOVR_TT=numovr_tt          )
PRINT,';;  ',test[0],exact[0],match_nt[0],match_tg[0],match_tt[0],match__l[0],match_dl[0],numovr_tg[0],numovr_tt[0]
;;     4   0   1   0   1   1   1           1           2

;;  Try bad structures of structures
DELVAR,exact,match_nt,match_tg,match_tt,match__l,match_dl,numovr_tg,numovr_tt
str0a          = {X:dumb1dd,Y:dumb2df2,Z:{A:dumb1df,B:dumb1dd}}
str0b          = {X:dumb1dd/2,Y:dumb2df2/3,Z:{A:dumb1df*10,B:dumb1dc*3}}
test           = structure_compare(str0a,str0b,EXACT=exact,MATCH_NT=match_nt,       $
                                   MATCH_TG=match_tg,MATCH_TT=match_tt,             $
                                   MATCH__L=match__l,MATCH_DL=match_dl,             $
                                   NUMOVR_TG=numovr_tg,NUMOVR_TT=numovr_tt          )
PRINT,';;  ',test[0],exact[0],match_nt[0],match_tg[0],match_tt[0],match__l[0],match_dl[0],numovr_tg[0],numovr_tt[0]
;;     5       0   1   1   0   1   1           4           3

;;  Try bad input
DELVAR,exact,match_nt,match_tg,match_tt,match__l,match_dl,numovr_tg,numovr_tt
str0a          = dumb1dd
str0b          = {X:dumb1dd/2,Y:dumb2df2/3,Z:{A:dumb1df*10,B:dumb1dc*3}}
test           = structure_compare(str0a,str0b,EXACT=exact,MATCH_NT=match_nt,       $
                                   MATCH_TG=match_tg,MATCH_TT=match_tt,             $
                                   MATCH__L=match__l,MATCH_DL=match_dl,             $
                                   NUMOVR_TG=numovr_tg,NUMOVR_TT=numovr_tt          )
PRINT,';;  ',test[0],exact[0],match_nt[0],match_tg[0],match_tt[0],match__l[0],match_dl[0],numovr_tg[0],numovr_tt[0]
% STRUCTURE_COMPARE: STR0A and STR0B must both be of structure type...
;;     0   0   0   0   0   0   0           0           0

;;  Try bad input
DELVAR,exact,match_nt,match_tg,match_tt,match__l,match_dl,numovr_tg,numovr_tt
str0a          = dumb1dd
dumb           = TEMPORARY(str0a)
str0b          = {X:dumb1dd/2,Y:dumb2df2/3,Z:{A:dumb1df*10,B:dumb1dc*3}}
test           = structure_compare(str0a,str0b,EXACT=exact,MATCH_NT=match_nt,       $
                                   MATCH_TG=match_tg,MATCH_TT=match_tt,             $
                                   MATCH__L=match__l,MATCH_DL=match_dl,             $
                                   NUMOVR_TG=numovr_tg,NUMOVR_TT=numovr_tt          )
PRINT,';;  ',test[0],exact[0],match_nt[0],match_tg[0],match_tt[0],match__l[0],match_dl[0],numovr_tg[0],numovr_tt[0]
% STRUCTURE_COMPARE: User must input STR0A and STR0B as scalars [structure]...
;;     0   0   0   0   0   0   0           0           0


;;----------------------------------------------------------------------------------------
;;  Verify general_cursor_select.pro
;;----------------------------------------------------------------------------------------
wnum           = 0L
;;  Open a dummy window
;lbw_window,WIND_N=wnum[0],/CLEAN
wi,wnum[0]
;;  Define and plot dummy data
nn             = 1000L
x              = DINDGEN(nn[0])*8d0*!DPI/(nn[0] - 1L)
y              = SIN(x)
xfac           = 1d0/(!DPI)
xp             = x*xfac[0]

!P.MULTI       = 0
WSET,wnum[0]
WSHOW,wnum[0]
PLOT,xp,y,/NODATA,/XSTYLE,/YSTYLE
  OPLOT,xp,y,COLOR= 50

xscale         = !X.S
yscale         = !Y.S
xfact          = 1d0/xfac[0]
yfact          = 1d0
.compile general_cursor_select.pro
;.compile /Users/lbwilson/Desktop/temp_idl/temp_gen_change_vbulk/general_cursor_select.pro
test           = general_cursor_select(XSCALE=xscale,YSCALE=yscale,WINDN=wnum[0],XFACT=xfact,YFACT=yfact)
HELP,test,/STRUC,OUTPUT=output
FOR j=0L, N_ELEMENTS(output) - 1L DO PRINT,';;  '+output[j]
;;  ** Structure <ac49818>, 2 tags, length=32, data length=32, refs=1:
;;     XY_NORM         DOUBLE    Array[2]
;;     XY_DATA         DOUBLE    Array[2]


;;----------------------------------------------------------------------------------------
;;  Verify convert_num_type.pro
;;----------------------------------------------------------------------------------------
;.compile /Users/lbwilson/Desktop/temp_idl/temp_gen_change_vbulk/convert_num_type.pro
.compile get_zeros_mins_maxs_type.pro
.compile convert_num_type.pro


;;******************************************
;;  Good Examples
;;******************************************
;;  Example:  Convert Float to Integer
old_val        = 3e0
new_typ        = 2L
arr_off        = 1b
abs__on        = 0b
new_val        = convert_num_type(old_val,new_typ,NO_ARRAY=arr_off,ABSOLUTE=abs__on)
HELP,new_val,/STRUC,OUTPUT=output
FOR j=0L, N_ELEMENTS(output) - 1L DO PRINT,';;  '+output[j]
;;  NEW_VAL         INT       =        3

;;  Example:  Convert Float to Long-Integer
old_val        = 3e0
new_typ        = 3L
arr_off        = 1b
abs__on        = 0b
new_val        = convert_num_type(old_val,new_typ,NO_ARRAY=arr_off,ABSOLUTE=abs__on)
HELP,new_val,/STRUC,OUTPUT=output
FOR j=0L, N_ELEMENTS(output) - 1L DO PRINT,';;  '+output[j]
;;  NEW_VAL         LONG      =            3

;;  Example:  Convert Complex to Float [use real part only]
old_val        = COMPLEX(3e0,3e0)
new_typ        = 4L
arr_off        = 1b
abs__on        = 0b
new_val        = convert_num_type(old_val,new_typ,NO_ARRAY=arr_off,ABSOLUTE=abs__on)
HELP,new_val,/STRUC,OUTPUT=output
FOR j=0L, N_ELEMENTS(output) - 1L DO PRINT,';;  '+output[j]
;;  NEW_VAL         FLOAT     =       3.00000

;;  Example:  Convert Complex to Float [use absolute value]
old_val        = COMPLEX(3e0,3e0)
new_typ        = 4L
arr_off        = 1b
abs__on        = 1b
new_val        = convert_num_type(old_val,new_typ,NO_ARRAY=arr_off,ABSOLUTE=abs__on)
HELP,old_val,/STRUC,OUTPUT=outputo
HELP,new_val,/STRUC,OUTPUT=outputn
FOR j=0L, N_ELEMENTS(outputo) - 1L DO PRINT,';;  '+outputo[j] & $
FOR j=0L, N_ELEMENTS(outputn) - 1L DO PRINT,';;  '+outputn[j]
;;  OLD_VAL         COMPLEX   = (      3.00000,      3.00000)
;;  NEW_VAL         FLOAT     =       4.24264

;;  Example:  Convert DComplex to Double [use absolute value]
old_val        = DCOMPLEX(3d0,4d0)
new_typ        = 5L
arr_off        = 1b
abs__on        = 1b
new_val        = convert_num_type(old_val,new_typ,NO_ARRAY=arr_off,ABSOLUTE=abs__on)
HELP,old_val,/STRUC,OUTPUT=outputo
HELP,new_val,/STRUC,OUTPUT=outputn
FOR j=0L, N_ELEMENTS(outputo) - 1L DO PRINT,';;  '+outputo[j] & $
FOR j=0L, N_ELEMENTS(outputn) - 1L DO PRINT,';;  '+outputn[j]
;;  OLD_VAL         DCOMPLEX  = (       3.0000000,       4.0000000)
;;  NEW_VAL         DOUBLE    =        5.0000000

;;  Example:  Convert Long64 to DComplex [ABSOLUTE keyword irrelevant for real input]
old_val        = 3LL
new_typ        = 9L
arr_off        = 1b
abs__on        = 0b
new_val        = convert_num_type(old_val,new_typ,NO_ARRAY=arr_off,ABSOLUTE=abs__on)
HELP,old_val,/STRUC,OUTPUT=outputo
HELP,new_val,/STRUC,OUTPUT=outputn
FOR j=0L, N_ELEMENTS(outputo) - 1L DO PRINT,';;  '+outputo[j] & $
FOR j=0L, N_ELEMENTS(outputn) - 1L DO PRINT,';;  '+outputn[j]
;;  OLD_VAL         LONG64    =                      3
;;  NEW_VAL         DCOMPLEX  = (       3.0000000,       0.0000000)


;;******************************************
;;  Bad Examples
;;******************************************
;;  Example:  Undefined required input
old_val        = 3e0
new_typ        = 2L
arr_off        = 1b
abs__on        = 0b
new_val        = convert_num_type(old_val,new_ttt,NO_ARRAY=arr_off,ABSOLUTE=abs__on)
HELP,new_val,/STRUC,OUTPUT=output
FOR j=0L, N_ELEMENTS(output) - 1L DO PRINT,';;  '+output[j]
% CONVERT_NUM_TYPE: User must define OLD_VAL and NEW_TYPE on input...
;;  NEW_VAL         BYTE      =    0

;;  Example:  Unsupported output type
old_val        = 3e0
new_typ        = 7L
arr_off        = 1b
abs__on        = 0b
new_val        = convert_num_type(old_val,new_typ,NO_ARRAY=arr_off,ABSOLUTE=abs__on)
HELP,new_val,/STRUC,OUTPUT=output
FOR j=0L, N_ELEMENTS(output) - 1L DO PRINT,';;  '+output[j]
% CONVERT_NUM_TYPE: OLD_VAL and NEW_TYPE must both be a valid IDL numeric type...
;;  NEW_VAL         BYTE      =    0

;;  Example:  non-numerical input type
old_val        = '3e0'
new_typ        = 1L
arr_off        = 1b
abs__on        = 0b
new_val        = convert_num_type(old_val,new_typ,NO_ARRAY=arr_off,ABSOLUTE=abs__on)
HELP,new_val,/STRUC,OUTPUT=output
FOR j=0L, N_ELEMENTS(output) - 1L DO PRINT,';;  '+output[j]
% CONVERT_NUM_TYPE: OLD_VAL and NEW_TYPE must both be numeric values...
;;  NEW_VAL         BYTE      =    0

;;  Example:  "bad" numerical conversions (i.e., out of bounds)
arr_off        = 1b
abs__on        = 0b
;;  Example:  300.0 to Byte
old_val        = 3e2
new_typ        = 1L
new_val        = convert_num_type(old_val,new_typ,NO_ARRAY=arr_off,ABSOLUTE=abs__on)
HELP,new_val,/STRUC,OUTPUT=output
FOR j=0L, N_ELEMENTS(output) - 1L DO PRINT,';;  '+output[j]
;;  NEW_VAL         BYTE      =   44

;;  Example:  300000.0 to Integer
old_val        = 3e5
new_typ        = 2L
new_val        = convert_num_type(old_val,new_typ,NO_ARRAY=arr_off,ABSOLUTE=abs__on)
HELP,new_val,/STRUC,OUTPUT=output
FOR j=0L, N_ELEMENTS(output) - 1L DO PRINT,';;  '+output[j]
;;  NEW_VAL         INT       =   -27680

;;  Example:  signed-input to unsigned output
old_val        = -3e0
new_typ        = 12L
new_val        = convert_num_type(old_val,new_typ,NO_ARRAY=arr_off,ABSOLUTE=abs__on)
HELP,new_val,/STRUC,OUTPUT=output
FOR j=0L, N_ELEMENTS(output) - 1L DO PRINT,';;  '+output[j]
;;  NEW_VAL         UINT      =    65533


;;----------------------------------------------------------------------------------------
;;  Verify get_zeros_mins_maxs_type.pro
;;----------------------------------------------------------------------------------------
;.compile /Users/lbwilson/Desktop/temp_idl/temp_gen_change_vbulk/get_zeros_mins_maxs_type.pro
.compile get_zeros_mins_maxs_type.pro

all_type_str   = get_zeros_mins_maxs_type()     ;;  Get all type info for system
HELP,all_type_str,/STRUC,OUTPUT=output
FOR j=0L, N_ELEMENTS(output) - 1L DO PRINT,';;'+output[j]
;;** Structure <ac7d908>, 5 tags, length=504, data length=483, refs=1:
;;   TYPES           LONG      Array[12]
;;   MINS            STRUCT    -> <Anonymous> Array[1]
;;   MAXS            STRUCT    -> <Anonymous> Array[1]
;;   ZEROS           STRUCT    -> <Anonymous> Array[1]
;;   FUNCS           STRUCT    -> <Anonymous> Array[1]

all_ok_type    = all_type_str.TYPES
HELP,all_ok_type,/STRUC,OUTPUT=output
FOR j=0L, N_ELEMENTS(output) - 1L DO PRINT,';;  '+output[j]
;;  ALL_OK_TYPE     LONG      = Array[12]

all_ok_mins    = all_type_str.MINS
HELP,all_ok_mins,/STRUC,OUTPUT=output
FOR j=0L, N_ELEMENTS(output) - 1L DO PRINT,';;'+output[j]
;;** Structure <160a128>, 12 tags, length=88, data length=81, refs=2:
;;   B               BYTE         0
;;   IN              INT         -32768
;;   L               LONG       -2147483648
;;   F               FLOAT      -3.40282e+38
;;   D               DOUBLE     -1.7976931e+308
;;   C               COMPLEX   ( -3.40282e+38, -3.40282e+38)
;;   S               STRING    ''
;;   DC              DCOMPLEX  ( -1.7976931e+308, -1.7976931e+308)
;;   UI              UINT             0
;;   UL              ULONG                0
;;   L64             LONG64      -9223372036854775808
;;   UL64            ULONG64                        0

all_ok_maxs    = all_type_str.MAXS
HELP,all_ok_maxs,/STRUC,OUTPUT=output
FOR j=0L, N_ELEMENTS(output) - 1L DO PRINT,';;'+output[j]
;;** Structure <160a538>, 12 tags, length=88, data length=81, refs=2:
;;   B               BYTE       255
;;   IN              INT          32767
;;   L               LONG        2147483647
;;   F               FLOAT       3.40282e+38
;;   D               DOUBLE      1.7976931e+308
;;   C               COMPLEX   (  3.40282e+38,  3.40282e+38)
;;   S               STRING    ''
;;   DC              DCOMPLEX  (  1.7976931e+308,  1.7976931e+308)
;;   UI              UINT         65535
;;   UL              ULONG       4294967295
;;   L64             LONG64       9223372036854775807
;;   UL64            ULONG64     18446744073709551615

all_ok_zero    = all_type_str.ZEROS
HELP,all_ok_zero,/STRUC,OUTPUT=output
FOR j=0L, N_ELEMENTS(output) - 1L DO PRINT,';;'+output[j]
;;** Structure <160a788>, 12 tags, length=88, data length=81, refs=2:
;;   B               BYTE         0
;;   IN              INT              0
;;   L               LONG                 0
;;   F               FLOAT           0.00000
;;   D               DOUBLE           0.0000000
;;   C               COMPLEX   (      0.00000,      0.00000)
;;   S               STRING    ''
;;   DC              DCOMPLEX  (       0.0000000,       0.0000000)
;;   UI              UINT             0
;;   UL              ULONG                0
;;   L64             LONG64                         0
;;   UL64            ULONG64                        0

all_ok_func    = all_type_str.FUNCS
HELP,all_ok_func,/STRUC,OUTPUT=output
FOR j=0L, N_ELEMENTS(output) - 1L DO PRINT,';;'+output[j]
;;** Structure <160a9d8>, 12 tags, length=192, data length=192, refs=2:
;;   B               STRING    'BYTE'
;;   IN              STRING    'FIX'
;;   L               STRING    'LONG'
;;   F               STRING    'FLOAT'
;;   D               STRING    'DOUBLE'
;;   C               STRING    'COMPLEX'
;;   S               STRING    'STRING'
;;   DC              STRING    'DCOMPLEX'
;;   UI              STRING    'UINT'
;;   UL              STRING    'ULONG'
;;   L64             STRING    'LONG64'
;;   UL64            STRING    'ULONG64'


























;;----------------------------------------------------------------------------------------
;;  Initialize and compile relevant routines
;;----------------------------------------------------------------------------------------
thm_init
@comp_lynn_pros.pro

;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Check prompting routines
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
LOADCT,39
DEVICE,DECOMPOSED=0
;;  Open a window for later
wi,1,XSIZE=800,YSIZE=1100
wi,2,XSIZE=800,YSIZE=1100

;;  Define velocity moment values
d              = !VALUES.D_NAN
dens           = 1d1                                         ;;  Number density [cm^(-3)]
vther          = 25d0                                        ;;  Thermal speed [km/s]
vbulk          = [-4d2,1d2,5d1]                              ;;  Dummy bulk flow velocity [km/s]
;;  Define the variance and standard deviation of a Gaussian
var_g          = vther[0]^2/2d0                              ;;  Variance of a Gaussian [km^(+2) s^(-2)]
std_g          = SQRT(var_g[0])                              ;;  Std. Deviation of a Gaussian [km/s]
;;  Define the peak amplitude of 3D Maxwellian with uncorrelated velocities
afac           = (1d0/SQRT(2d0*!DPI))^(1d0/3d0)
amps           = afac[0]*(1d0/(std_g[0]*1d3))                ;;  km --> m
fmax           = (dens[0]*1d6)*amps[0]^3                     ;;  cm^(-3) --> m^(-3)
;;  Define exponent denominator (2*variance)
expdenom       = -2d0*var_g[0]*1d6
;;  Create dummy VDF structure
;;    Start in bulk flow reference frame then transform to SCF
;;    Start in spherical coordinates then go to cartesian
nm             = 100L
thmax          = 9d1
thoff          = -1d0*thmax[0]
thfac          = 2d0*thmax[0]/(nm[0] - 1L)
phmax          = 36d1
phoff          = 0d0
phfac          = 1d0*phmax[0]/(nm[0] - 1L)
the            = DINDGEN(nm[0])*thfac[0] + thoff[0]
phi            = DINDGEN(nm[0])*phfac[0] + phoff[0]
;;    Now define speeds
vmax           = ALOG10(1d1*vther[0]*1d3)                    ;;  Max speed (in logarithmic space) [m/s] (assume protons --> ~30 keV)
vfac           = 1d0*vmax[0]/(nm[0] - 1L)
voff           = 0d0
lnvxn          = DINDGEN(nm[0])*vfac[0] + voff[0]            ;;  Regularly gridded velocities (in logarithmic space) [m/s]
spd            = 1d1^(lnvxn)
;;    Convert to cartesian coordinates
coth           = COS(the*!DPI/18d1)
sith           = SIN(the*!DPI/18d1)
coph           = COS(phi*!DPI/18d1)
siph           = SIN(phi*!DPI/18d1)
udir_str       = {X:coth*coph,Y:coth*siph,Z:sith}
;;  Define new (vx,vy,vz)  [m/s]
vel_xyz        = REPLICATE(d,nm[0],nm[0],nm[0],3L)
FOR j=0L, nm[0] - 1L DO FOR k=0L, nm[0] - 1L DO FOR i=0L, nm[0] - 1L DO BEGIN       $
  vel_xyz[j,k,i,0]  = coth[j]*coph[k]*spd[i]                                      & $
  vel_xyz[j,k,i,1]  = coth[j]*siph[k]*spd[i]                                      & $
  vel_xyz[j,k,i,2]  = sith[j]*spd[i]
;;  Define exponent numerator ∑_j (V_j - V_oj)^2
expnumer       = REPLICATE(d,nm[0],nm[0],nm[0])
FOR j=0L, nm[0] - 1L DO FOR k=0L, nm[0] - 1L DO BEGIN                                      $
    expnumer[j,k,*] = (vel_xyz[j,k,*,0])^2 + (vel_xyz[j,k,*,1])^2 + (vel_xyz[j,k,*,2])^2
;;  Define f(vx,vy,vz)  [s^(+3) m^(-6)]
fvxyz          = fmax[0]*EXP(expnumer/expdenom[0])
test           = (ABS(fvxyz) LE 1d-40) OR (FINITE(fvxyz) EQ 0)
bad            = WHERE(test,bd)
IF (bd[0] GT 0) THEN fvxyz[bad] = d
;;  Clean up
DELVAR,expnumer
;;  Reform into 1D and 2D arrays
nold           = N_ELEMENTS(fvxyz)
f1d            = REFORM(fvxyz,nold[0])
v2d            = REFORM(vel_xyz,nold[0],3L)
;;  Reduce resolution to more realistic observational values
delv           = 10d3                                        ;;  Velocity resolution of ~10 km/s
nd             = (1d0*1d1^(vmax[0])/delv[0]) + 1d0
nn             = LONG(nd[0])
lgvfac         = (1d0*vmax[0]/(nn[0] - 1L))
lgvo           = DINDGEN(nn[0])*lgvfac[0] + voff[0]
so             = 1d1^(lgvo)
thfacn         = 2d0*thmax[0]/(nn[0] - 1L)
phfacn         = 1d0*phmax[0]/(nn[0] - 1L)
the0           = DINDGEN(nn[0])*thfacn[0] + thoff[0]
phi0           = DINDGEN(nn[0])*phfacn[0] + phoff[0]
;;    Calculate fractional indices for new grid locations
frac_iss       = find_frac_indices(spd,spd,so,so)
frac_itp       = find_frac_indices(the,phi,the0,phi0)
;;  Interpolate f(s,the,phi) new grid locations
tind           = frac_itp.X_IND
pind           = frac_itp.Y_IND
sind           = frac_iss.X_IND
lnfvn0         = INTERPOLATE(ALOG(fvxyz),tind,pind,sind,MISSING=d,/GRID)
fvnew0         = EXP(lnfvn0)
;;  Define new (vx,vy,vz)
v3dnew0        = REPLICATE(d,nn[0],nn[0],nn[0],3L)
FOR j=0L, nn[0] - 1L DO FOR k=0L, nn[0] - 1L DO FOR i=0L, nn[0] - 1L DO BEGIN       $
  v3dnew0[j,k,i,0]  = COS(the0[j]*!DPI/18d1)*COS(phi0[k]*!DPI/18d1)*so[i]         & $
  v3dnew0[j,k,i,1]  = COS(the0[j]*!DPI/18d1)*SIN(phi0[k]*!DPI/18d1)*so[i]         & $
  v3dnew0[j,k,i,2]  = SIN(the0[j]*!DPI/18d1)*so[i]
;;  Reform into 1D and 2D arrays
nnew0          = N_ELEMENTS(fvnew0)
f1dn0          = REFORM(fvnew0,nnew0[0])
v2dn0          = REFORM(v3dnew0,nnew0[0],3L)

;;  Define keyword values
vframe         = [0d0,0d0,0d0]
vec1           = [1d0,0d0,0d0] & vec2 = [0d0,1d0,0d0] & vlim = 1d2 & nlev = 30L
xname          = 'x' & yname = 'y' & sm_cuts = 0b & sm_cont = 0b & plane = 'xy'
dfra           = [1d-10,1d-3] & dfmin = 1d-20 & dfmax = 1d-2
;;  Create arrays acceptable by general_vdf_contour_plot.pro
v_df           = f1dn0*1d-6*1d9              ;;  m^(-3) --> cm^(-3), m^(-3) --> km^(-3)
vxyz           = v2dn0*1d-3                  ;;  m --> km
;;  Try plotting VDF [SWF]
WSET,1
WSHOW,1
general_vdf_contour_plot,v_df,vxyz,VFRAME=vframe,VEC1=vec1,VEC2=vec2,VLIM=vlim,   $
                         NLEV=nlev,XNAME=xname,YNAME=yname,SM_CUTS=sm_cuts,       $
                         SM_CONT=sm_cont,NSMCUT=nsmcut,NSMCON=nsmcon,PLANE=plane, $
                         DFMIN=dfmin,DFMAX=dfmax,DFRA=dfra,V_0X=v_0x,V_0Y=v_0y,   $
                         CIRCS=circs,EX_VECS=ex_vecs,EX_INFO=ex_info

;;  m^(-3) x (10^(-2) m/cm)^(+3) = 10^(-6) cm^(-3)
;;  m^(-3) x (10^(+3) m/km)^(+3) = 10^(+9) km^(-3)


;;  Define keyword values
vframe         = [0d0,0d0,0d0]
vec1           = [1d0,0d0,0d0] & vec2 = [0d0,1d0,0d0] & vlim = 1d2 & nlev = 30L
xname          = 'x' & yname = 'y' & sm_cuts = 0b & sm_cont = 0b & plane = 'xy'
dfra           = [1d-10,1d-3] & dfmin = 1d-20 & dfmax = 1d-2
;;  Create arrays acceptable by general_vdf_contour_plot.pro
v_df           = f1d*1d-6*1d9              ;;  m^(-3) --> cm^(-3), m^(-3) --> km^(-3)
vxyz           = v2d*1d-3                  ;;  m --> km
;;  Try plotting VDF [SWF]
WSET,2
WSHOW,2
general_vdf_contour_plot,v_df,vxyz,VFRAME=vframe,VEC1=vec1,VEC2=vec2,VLIM=vlim,   $
                         NLEV=nlev,XNAME=xname,YNAME=yname,SM_CUTS=sm_cuts,       $
                         SM_CONT=sm_cont,NSMCUT=nsmcut,NSMCON=nsmcon,PLANE=plane, $
                         DFMIN=dfmin,DFMAX=dfmax,DFRA=dfra,V_0X=v_0x,V_0Y=v_0y,   $
                         CIRCS=circs,EX_VECS=ex_vecs,EX_INFO=ex_info

;;  Try using logarithmic spacing instead of linear for contours
;;  Define keyword values
vframe         = [0d0,0d0,0d0]
vec1           = [1d0,0d0,0d0] & vec2 = [0d0,1d0,0d0] & vlim = 1d2 & nlev = 30L
xname          = 'x' & yname = 'y' & sm_cuts = 0b & sm_cont = 0b & plane = 'xy'
dfra           = [1d-10,1d-3] & dfmin = 1d-20 & dfmax = 1d-2
;;  Create arrays acceptable by general_vdf_contour_plot.pro
v_df           = f1dn0*1d-6*1d9              ;;  m^(-3) --> cm^(-3), m^(-3) --> km^(-3)
vxyz           = v2dn0*1d-3                  ;;  m --> km
;;  Try plotting VDF [SWF]
WSET,1
WSHOW,1
general_vdf_contour_plot,v_df,vxyz,VFRAME=vframe,VEC1=vec1,VEC2=vec2,VLIM=vlim,   $
                         NLEV=nlev,XNAME=xname,YNAME=yname,SM_CUTS=sm_cuts,       $
                         SM_CONT=sm_cont,NSMCUT=nsmcut,NSMCON=nsmcon,PLANE=plane, $
                         DFMIN=dfmin,DFMAX=dfmax,DFRA=dfra,V_0X=v_0x,V_0Y=v_0y,   $
                         CIRCS=circs,EX_VECS=ex_vecs,EX_INFO=ex_info,/C_LOG

;;  Define keyword values
vframe         = [0d0,0d0,0d0]
vec1           = [1d0,0d0,0d0] & vec2 = [0d0,1d0,0d0] & vlim = 1d2 & nlev = 30L
xname          = 'x' & yname = 'y' & sm_cuts = 0b & sm_cont = 0b & plane = 'xy'
dfra           = [1d-10,1d-3] & dfmin = 1d-20 & dfmax = 1d-2
;;  Create arrays acceptable by general_vdf_contour_plot.pro
v_df           = f1d*1d-6*1d9              ;;  m^(-3) --> cm^(-3), m^(-3) --> km^(-3)
vxyz           = v2d*1d-3                  ;;  m --> km
;;  Try plotting VDF [SWF]
WSET,2
WSHOW,2
general_vdf_contour_plot,v_df,vxyz,VFRAME=vframe,VEC1=vec1,VEC2=vec2,VLIM=vlim,   $
                         NLEV=nlev,XNAME=xname,YNAME=yname,SM_CUTS=sm_cuts,       $
                         SM_CONT=sm_cont,NSMCUT=nsmcut,NSMCON=nsmcon,PLANE=plane, $
                         DFMIN=dfmin,DFMAX=dfmax,DFRA=dfra,V_0X=v_0x,V_0Y=v_0y,   $
                         CIRCS=circs,EX_VECS=ex_vecs,EX_INFO=ex_info,/C_LOG


;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Old/Obsolete
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------

nd             = (2d0*1d1^(vmax[0])/delv[0]) + 1d0
nn             = LONG(nd[0])
lgvfac         = (2d0*vmax[0]/(nn[0] - 1L))
lgvo           = DINDGEN(nn[0])*lgvfac[0] - vmax[0]
sgvo           = sign(lgvo)
vo             = sgvo*1d1^(ABS(lgvo))
;;    Calculate fractional indices for new grid locations
frac_ixy       = find_frac_indices(v2d[*,0],v2d[*,1],vo,vo)
frac_iyz       = find_frac_indices(v2d[*,1],v2d[*,2],vo,vo)
;;  Interpolate f(vx,vy,vz) new grid locations
xind           = frac_ixy.X_IND
yind           = frac_ixy.y_IND
zind           = frac_iyz.Y_IND
lnfvn0         = INTERPOLATE(ALOG(fvxyz),xind,yind,zind,MISSING=d,/GRID)
fvnew0         = EXP(lnfvn0)
nnew0          = N_ELEMENTS(fvnew0)
f1dn0          = REFORM(fvnew0,nnew0[0])
v2dn0          = v2dn

;;  Reduce resolution to more realistic observational values
delv           = 20d3                                        ;;  Velocity resolution of ~20 km/s
nd             = (1d0*1d1^(vmax[0])/delv[0]) + 1d0
nn             = LONG(nd[0])
lgvfac         = (1d0*vmax[0]/(nn[0] - 1L))
lgvo           = DINDGEN(nn[0])*lgvfac[0] + voff[0]
so             = 1d1^(lgvo)
thfacn         = 2d0*thmax[0]/(nn[0] - 1L)
phfacn         = 1d0*phmax[0]/(nn[0] - 1L)
the0           = DINDGEN(nn[0])*thfacn[0] + thoff[0]
phi0           = DINDGEN(nn[0])*phfacn[0] + phoff[0]
v3dnew0        = REPLICATE(d,nn[0],nn[0],nn[0],3L)
FOR j=0L, nn[0] - 1L DO FOR k=0L, nn[0] - 1L DO FOR i=0L, nn[0] - 1L DO BEGIN       $
  v3dnew0[j,k,i,0]  = COS(the0[j]*!DPI/18d1)*COS(phi0[k]*!DPI/18d1)*so[i]         & $
  v3dnew0[j,k,i,1]  = COS(the0[j]*!DPI/18d1)*SIN(phi0[k]*!DPI/18d1)*so[i]         & $
  v3dnew0[j,k,i,2]  = SIN(the0[j]*!DPI/18d1)*so[i]
;;  Reform new velocities into 1D array
nnew           = N_ELEMENTS(v3dnew0[*,*,*,0])
v2dn           = REFORM(v3dnew0,nnew[0],3L)
;;    Calculate fractional indices for new grid locations
frac_ixy       = find_frac_indices(v2d[*,0],v2d[*,1],v2dn[*,0],v2dn[*,1])
frac_iyz       = find_frac_indices(v2d[*,1],v2d[*,2],v2dn[*,1],v2dn[*,2])
;;  Interpolate f(vx,vy,vz) new grid locations
xind           = frac_ixy.X_IND
yind           = frac_ixy.y_IND
zind           = frac_iyz.Y_IND
lnfvn0         = INTERPOLATE(ALOG(fvxyz),xind,yind,zind,MISSING=d,/GRID)
fvnew0         = EXP(lnfvn0)
nnew0          = N_ELEMENTS(fvnew0)
f1dn0          = REFORM(fvnew0,nnew0[0])
v2dn0          = v2dn



;;  Define velocity moment values
d              = !VALUES.D_NAN
dens           = 1d1                                         ;;  Number density [cm^(-3)]
vther          = 25d0                                        ;;  Thermal speed [km/s]
vbulk          = [-4d2,1d2,5d1]                              ;;  Dummy bulk flow velocity [km/s]
;;  Define the variance and standard deviation of a Gaussian
var_g          = vther[0]^2/2d0                              ;;  Variance of a Gaussian [km^(+2) s^(-2)]
std_g          = SQRT(var_g[0])                              ;;  Std. Deviation of a Gaussian [km/s]
;;  Define the peak amplitude of 3D Maxwellian with uncorrelated velocities
;afac           = (1d6/SQRT(2d0*!DPI*1d6))^(1d0/3d0)          ;;  cm^(-3) --> m^(-3), km^(-2) --> m^(-2)
;amps           = afac[0]*(dens[0]/SQRT(var_g[0]))^(1d0/3d0)
;fmax           = amps[0]^3
afac           = (1d0/SQRT(2d0*!DPI))^(1d0/3d0)
amps           = afac[0]*(1d0/(std_g[0]*1d3))                ;;  km --> m
fmax           = (dens[0]*1d6)*amps[0]^3                     ;;  cm^(-3) --> m^(-3)
;;  Define exponent denominator (2*variance)
expdenom       = -2d0*var_g[0]*1d6
;;  Create dummy VDF structure
;;    Start in bulk flow reference frame then transform to SCF
nm             = 100L
vmax           = ALOG10(1d1*vther[0]*1d3)                    ;;  Max speed (in logarithmic space) [m/s] (assume protons --> ~30 keV)
vfac           = 2d0*vmax[0]/(nm[0] - 1L)
voff           = -1d0*vmax[0]
lnvxn          = DINDGEN(nm[0])*vfac[0] + voff[0]            ;;  Regularly gridded velocities (in logarithmic space) [m/s]
sgn            = sign(lnvxn)
vxn            = sgn*1d1^(ABS(lnvxn))                        ;;  Irregularly gridded velocities [m/s]
vyn            = vxn
vzn            = vxn
;;  Define exponent numerator ∑_j (V_j - V_oj)^2
expnumer       = REPLICATE(d,nm[0],nm[0],nm[0])
FOR j=0L, nm[0] - 1L DO FOR k=0L, nm[0] - 1L DO BEGIN                                      $
    expnumer[j,k,*] = (vxn[j])^2 + (vyn[k])^2 + (vzn)^2
;;  Define f(vx,vy,vz)  [s^(+3) m^(-6)]
fvxyz          = fmax[0]*EXP(expnumer/expdenom[0])
test           = (ABS(fvxyz) LE 1d-40) OR (FINITE(fvxyz) EQ 0)
bad            = WHERE(test,bd)
IF (bd[0] GT 0) THEN fvxyz[bad] = d
;;  Clean up
DELVAR,expnumer
;;  Define new (vx,vy,vz)  [m/s]
vel_xyz        = REPLICATE(d,nm[0],nm[0],nm[0],3L)
FOR j=0L, nm[0] - 1L DO FOR k=0L, nm[0] - 1L DO FOR i=0L, nm[0] - 1L DO BEGIN              $
    vel_xyz[j,k,i,*]  = [vxn[j],vyn[k],vzn[i]]
;;  Reform into 1D and 2D arrays
nold           = N_ELEMENTS(fvxyz)
f1d            = REFORM(fvxyz,nold[0])
v2d            = REFORM(vel_xyz,nold[0],3L)
;;  Reduce resolution to more realistic observational values
;;    Calculate fractional indices for new grid locations
delv           = 20d3                                        ;;  Velocity resolution of ~20 km/s
nd             = (2d0*1d1^(vmax[0])/delv[0]) + 1d0
nn             = LONG(nd[0])
lgvfac         = (2d0*vmax[0]/(nn[0] - 1L))
lgvo           = DINDGEN(nn[0])*lgvfac[0] + voff[0]
sgvo           = sign(lgvo)
vo             = sgvo*1d1^(ABS(lgvo))
;vo             = DINDGEN(nn[0])*delv[0] + voff[0]
frac_ixy       = find_frac_indices(vxn,vyn,vo,vo)
frac_iyz       = find_frac_indices(vyn,vzn,vo,vo)
;;  Interpolate f(vx,vy,vz) new grid locations
xind           = frac_ixy.X_IND
yind           = frac_ixy.y_IND
zind           = frac_iyz.Y_IND
lnfvn0         = INTERPOLATE(ALOG(fvxyz),xind,yind,zind,MISSING=d,/GRID)
fvnew0         = EXP(lnfvn0)
v3dnew0        = REPLICATE(d,nn[0],nn[0],nn[0],3L)
FOR j=0L, nn[0] - 1L DO FOR k=0L, nn[0] - 1L DO FOR i=0L, nn[0] - 1L DO v3dnew0[j,k,i,*]  = [vo[j],vo[k],vo[i]]
nnew0          = N_ELEMENTS(fvnew0)
f1dn0          = REFORM(fvnew0,nnew0[0])
v2dn0          = REFORM(v3dnew0,nnew0[0],3L)

;;  Define keyword values
vframe         = [0d0,0d0,0d0]
vec1           = [1d0,0d0,0d0] & vec2 = [0d0,1d0,0d0] & vlim = 1d2 & nlev = 30L
xname          = 'x' & yname = 'y' & sm_cuts = 0b & sm_cont = 0b & plane = 'xy'
dfra           = [1d-10,1d-3] & dfmin = 1d-20 & dfmax = 1d-2
;;  Create arrays acceptable by general_vdf_contour_plot.pro
v_df           = f1dn0*1d-6*1d9              ;;  m^(-3) --> cm^(-3), m^(-3) --> km^(-3)
vxyz           = v2dn0*1d-3                  ;;  m --> km
;;  Try plotting VDF [SWF]
WSET,1
WSHOW,1
general_vdf_contour_plot,v_df,vxyz,VFRAME=vframe,VEC1=vec1,VEC2=vec2,VLIM=vlim,   $
                         NLEV=nlev,XNAME=xname,YNAME=yname,SM_CUTS=sm_cuts,       $
                         SM_CONT=sm_cont,NSMCUT=nsmcut,NSMCON=nsmcon,PLANE=plane, $
                         DFMIN=dfmin,DFMAX=dfmax,DFRA=dfra,V_0X=v_0x,V_0Y=v_0y,   $
                         CIRCS=circs,EX_VECS=ex_vecs,EX_INFO=ex_info

;;  m^(-3) x (10^(-2) m/cm)^(+3) = 10^(-6) cm^(-3)
;;  m^(-3) x (10^(+3) m/km)^(+3) = 10^(+9) km^(-3)


;;  Define keyword values
vframe         = [0d0,0d0,0d0]
vec1           = [1d0,0d0,0d0] & vec2 = [0d0,1d0,0d0] & vlim = 1d2 & nlev = 30L
xname          = 'x' & yname = 'y' & sm_cuts = 0b & sm_cont = 0b & plane = 'xy'
dfra           = [1d-10,1d-3] & dfmin = 1d-20 & dfmax = 1d-2
;;  Create arrays acceptable by general_vdf_contour_plot.pro
v_df           = f1d*1d-6*1d9              ;;  m^(-3) --> cm^(-3), m^(-3) --> km^(-3)
vxyz           = v2d*1d-3                  ;;  m --> km
;;  Try plotting VDF [SWF]
WSET,2
WSHOW,2
general_vdf_contour_plot,v_df,vxyz,VFRAME=vframe,VEC1=vec1,VEC2=vec2,VLIM=vlim,   $
                         NLEV=nlev,XNAME=xname,YNAME=yname,SM_CUTS=sm_cuts,       $
                         SM_CONT=sm_cont,NSMCUT=nsmcut,NSMCON=nsmcon,PLANE=plane, $
                         DFMIN=dfmin,DFMAX=dfmax,DFRA=dfra,V_0X=v_0x,V_0Y=v_0y,   $
                         CIRCS=circs,EX_VECS=ex_vecs,EX_INFO=ex_info


;;  Reform into 1D and 2D arrays
nold           = N_ELEMENTS(fvxyz)
f1d            = REFORM(fvxyz,nold[0])
v2d            = REFORM(vel_xyz,nold[0],3L)
;;  Reduce resolution to more realistic observational values
;;    Calculate fractional indices for new grid locations
delv           = 35d3                                        ;;  Velocity resolution of ~50 km/s
nd             = (2d0*1d1^(vmax[0])/delv[0]) + 1d0
nn             = LONG(nd[0])
lgvfac         = (2d0*vmax[0]/(nn[0] - 1L))
lgvo           = DINDGEN(nn[0])*lgvfac[0] + voff[0]
sgvo           = sign(lgvo)
vo             = sgvo*1d1^(ABS(lgvo))
;vo             = DINDGEN(nn[0])*delv[0] + voff[0]
frac_ixy       = find_frac_indices(vxn,vyn,vo,vo)
frac_iyz       = find_frac_indices(vyn,vzn,vo,vo)
;;  Interpolate f(vx,vy,vz) new grid locations
xind           = frac_ixy.X_IND
yind           = frac_ixy.y_IND
zind           = frac_iyz.Y_IND
lnfvn0         = INTERPOLATE(ALOG(fvxyz),xind,yind,zind,MISSING=d,/GRID)
fvnew0         = EXP(lnfvn0)
v3dnew0        = REPLICATE(d,nn[0],nn[0],nn[0],3L)
FOR j=0L, nn[0] - 1L DO FOR k=0L, nn[0] - 1L DO FOR i=0L, nn[0] - 1L DO v3dnew0[j,k,i,*]  = [vo[j],vo[k],vo[i]]
nnew0          = N_ELEMENTS(fvnew0)
f1dn0          = REFORM(fvnew0,nnew0[0])
v2dn0          = REFORM(v3dnew0,nnew0[0],3L)
;;  Try Delaunay triangulation for comparison
QHULL,TRANSPOSE(v2d),tetra,/DELAUNAY
lnfvn1         = QGRID3(TRANSPOSE(v2d),ALOG(f1d),tetra,MISSING=d,DELTA=delv[0],DIMENSION=nn[0])
fvnew1         = EXP(lnfvn1)



nn             = 200L
vran           = 1d1*vther[0]                                ;;  Range of velocities about peak [km/s]
vfac           = 2d0*vran[0]/(nn[0] - 1L)
voffxyz        = vbulk - vran[0]
vo             = DINDGEN(nn[0])*vfac[0]
;;  Define velocity [m/s] locations for solutions to f(vx,vy,vz)
vx             = (vo + voffxyz[0])*1d3                       ;;  Regularly gridded velocities [m/s]
vy             = (vo + voffxyz[1])*1d3                       ;;  Regularly gridded velocities [m/s]
vz             = (vo + voffxyz[2])*1d3                       ;;  Regularly gridded velocities [m/s]
;;  Define the variance and standard deviation of the Gaussian
var_g          = vther[0]^2/2d0                              ;;  Variance of a Gaussian [km^(+2) s^(-2)]
std_g          = SQRT(var_g[0])                              ;;  Std. Deviation of a Gaussian [km/s]
afac           = (1d6/SQRT(2d0*!DPI*1d6))^(1d0/3d0)
amps           = afac[0]*(dens[0]/SQRT(var_g[0]))^(1d0/3d0)  ;;  cm^(-3) --> m^(-3), km^(-2) --> m^(-2)
;;  Define inputs for Gaussian
vo_xyz         = vbulk*1d3                          ;;  km --> m
vt_in          = std_g[0]*1d3                       ;;  km --> m
;;  Define exponent denominator (2*variance)
expdenom       = -2d0*var_g[0]*1d6
;;  Define total amplitude
fmax           = amps[0]^3
;;  Define exponent numerator ∑_j (V_j - V_oj)^2
expnumer       = REPLICATE(d,nn[0],nn[0],nn[0])
FOR j=0L, nn[0] - 1L DO FOR k=0L, nn[0] - 1L DO BEGIN                                      $
    expnumer[j,k,*] = (vx[j])^2 + (vy[k])^2 + (vz)^2
;    expnumer[j,k,*] = (vx[j] + vo_xyz[0])^2 + (vy[k] + vo_xyz[1])^2 + (vz + vo_xyz[2])^2

;;  Define f(vx,vy,vz)  [s^(+3) m^(-6)]
fvxyz          = fmax[0]*EXP(expnumer/expdenom[0])
test           = (ABS(fvxyz) LE 1d-40) OR (FINITE(fvxyz) EQ 0)
bad            = WHERE(test,bd)
IF (bd[0] GT 0) THEN fvxyz[bad] = d
;;  Clean up
DELVAR,expnumer
;;  Calculate fractional indices for new grid locations
nm             = 200L
vmax           = 7d2*1d3                                     ;;  Max speed [m/s] (assume protons --> ~30 keV)
vfac           = 2d0*vmax[0]/(nm[0] - 1L)
voff           = -1d0*vmax[0]
vxn            = DINDGEN(nm[0])*vfac[0] + voff[0]            ;;  Regularly gridded velocities [m/s]
frac_ixy       = find_frac_indices(vx,vy,vxn,vxn)
frac_iyz       = find_frac_indices(vy,vz,vxn,vxn)
;;  Interpolate f(vx,vy,vz) new grid locations
xind           = frac_ixy.X_IND
yind           = frac_ixy.y_IND
zind           = frac_iyz.Y_IND
lnfvn          = INTERPOLATE(ALOG(fvxyz),xind,yind,zind,MISSING=d,/GRID)
fvnew          = EXP(lnfvn)
;;  Clean up
DELVAR,frac_ixy,frac_iyz,xind,yind,zind,lnfvn
;;  Define new (vx,vy,vz)  [m/s]
vel_xyz        = REPLICATE(d,nm[0],nm[0],nm[0],3L)
FOR j=0L, nm[0] - 1L DO FOR k=0L, nm[0] - 1L DO FOR i=0L, nm[0] - 1L DO BEGIN              $
    vel_xyz[j,k,i,*]  = [vxn[j],vxn[k],vxn[i]]
;;  Reform into 1D and 2D arrays
nall           = N_ELEMENTS(fvnew)
;;  Create arrays acceptable by general_vdf_contour_plot.pro
v_df           = REFORM(fvnew,nall[0])*1d-6*1d9              ;;  m^(-3) --> cm^(-3), m^(-3) --> km^(-3)
vxyz           = REFORM(vel_xyz,nall[0],3L)*1d-3             ;;  m --> km
;;  Clean up
DELVAR,vel_xyz


;;  Create dummy VDF structure
d              = !VALUES.D_NAN
dens           = 1d1                                         ;;  Number density [cm^(-3)]
vther          = 25d0                                        ;;  Thermal speed [km/s]
vbulk          = [-4d2,1d2,5d1]                              ;;  Dummy bulk flow velocity [km/s]
nn             = 200L
vran           = 1d1*vther[0]                                ;;  Range of velocities about peak [km/s]
vfac           = 2d0*vran[0]/(nn[0] - 1L)
voffxyz        = vbulk - vran[0]
vo             = DINDGEN(nn[0])*vfac[0]
;;  Define velocity [m/s] locations for solutions to f(vx,vy,vz)
vx             = (vo + voffxyz[0])*1d3                       ;;  Regularly gridded velocities [m/s]
vy             = (vo + voffxyz[1])*1d3                       ;;  Regularly gridded velocities [m/s]
vz             = (vo + voffxyz[2])*1d3                       ;;  Regularly gridded velocities [m/s]
;;  Define the variance and standard deviation of the Gaussian
var_g          = vther[0]^2/2d0                              ;;  Variance of a Gaussian [km^(+2) s^(-2)]
std_g          = SQRT(var_g[0])                              ;;  Std. Deviation of a Gaussian [km/s]
afac           = (1d6/SQRT(2d0*!DPI*1d6))^(1d0/3d0)
amps           = afac[0]*(dens[0]/SQRT(var_g[0]))^(1d0/3d0)  ;;  cm^(-3) --> m^(-3), km^(-2) --> m^(-2)
;;  Define inputs for Gaussian
vo_xyz         = vbulk*1d3                          ;;  km --> m
vt_in          = std_g[0]*1d3                       ;;  km --> m
;;  Define exponent denominator (2*variance)
expdenom       = -2d0*var_g[0]*1d6
;;  Define total amplitude
fmax           = amps[0]^3
;;  Define exponent numerator ∑_j (V_j - V_oj)^2
expnumer       = REPLICATE(d,nn[0],nn[0],nn[0])
FOR j=0L, nn[0] - 1L DO FOR k=0L, nn[0] - 1L DO BEGIN                                      $
    expnumer[j,k,*] = (vx[j])^2 + (vy[k])^2 + (vz)^2
;    expnumer[j,k,*] = (vx[j] + vo_xyz[0])^2 + (vy[k] + vo_xyz[1])^2 + (vz + vo_xyz[2])^2

;;  Define f(vx,vy,vz)  [s^(+3) m^(-6)]
fvxyz          = fmax[0]*EXP(expnumer/expdenom[0])
test           = (ABS(fvxyz) LE 1d-40) OR (FINITE(fvxyz) EQ 0)
bad            = WHERE(test,bd)
IF (bd[0] GT 0) THEN fvxyz[bad] = d
;;  Clean up
DELVAR,expnumer
;;  Calculate fractional indices for new grid locations
nm             = 200L
vmax           = 7d2*1d3                                     ;;  Max speed [m/s] (assume protons --> ~30 keV)
vfac           = 2d0*vmax[0]/(nm[0] - 1L)
voff           = -1d0*vmax[0]
vxn            = DINDGEN(nm[0])*vfac[0] + voff[0]            ;;  Regularly gridded velocities [m/s]
frac_ixy       = find_frac_indices(vx,vy,vxn,vxn)
frac_iyz       = find_frac_indices(vy,vz,vxn,vxn)
;;  Interpolate f(vx,vy,vz) new grid locations
xind           = frac_ixy.X_IND
yind           = frac_ixy.y_IND
zind           = frac_iyz.Y_IND
lnfvn          = INTERPOLATE(ALOG(fvxyz),xind,yind,zind,MISSING=d,/GRID)
fvnew          = EXP(lnfvn)
;;  Clean up
DELVAR,frac_ixy,frac_iyz,xind,yind,zind,lnfvn
;;  Define new (vx,vy,vz)  [m/s]
vel_xyz        = REPLICATE(d,nm[0],nm[0],nm[0],3L)
FOR j=0L, nm[0] - 1L DO FOR k=0L, nm[0] - 1L DO FOR i=0L, nm[0] - 1L DO BEGIN              $
    vel_xyz[j,k,i,*]  = [vxn[j],vxn[k],vxn[i]]
;;  Reform into 1D and 2D arrays
nall           = N_ELEMENTS(fvnew)
;;  Create arrays acceptable by general_vdf_contour_plot.pro
v_df           = REFORM(fvnew,nall[0])*1d-6*1d9              ;;  m^(-3) --> cm^(-3), m^(-3) --> km^(-3)
vxyz           = REFORM(vel_xyz,nall[0],3L)*1d-3             ;;  m --> km
;;  Clean up
DELVAR,vel_xyz
;;  Define keyword values
vec1           = [1d0,0d0,0d0] & vec2 = [0d0,1d0,0d0] & vlim = 1d3 & nlev = 30L
xname          = 'x' & yname = 'y' & sm_cuts = 0b & sm_cont = 0b & plane = 'xy'
dfra           = [1d-20,1d-11] & dfmin = 1d-30 & dfmax = 1d-9
;;  Try plotting VDF
WSET,1
WSHOW,1
general_vdf_contour_plot,v_df,vxyz,VFRAME=vframe,VEC1=vec1,VEC2=vec2,VLIM=vlim,   $
                         NLEV=nlev,XNAME=xname,YNAME=yname,SM_CUTS=sm_cuts,       $
                         SM_CONT=sm_cont,NSMCUT=nsmcut,NSMCON=nsmcon,PLANE=plane, $
                         DFMIN=dfmin,DFMAX=dfmax,DFRA=dfra,V_0X=v_0x,V_0Y=v_0y,   $
                         CIRCS=circs,EX_VECS=ex_vecs,EX_INFO=ex_info

;;  m^(-3) x (10^(-2) m/cm)^(+3) = 10^(-6) cm^(-3)
;;  m^(-3) x (10^(+3) m/km)^(+3) = 10^(+9) km^(-3)





;;------------------
nn             = 1000L
vmax           = 25d2                                      ;;  Max speed [km/s] (assume protons --> ~30 keV)
vfac           = 2d0*vmax[0]/(nn[0] - 1L)
voff           = -1d0*vmax[0]
vx             = DINDGEN(nn[0])*vfac[0] + voff[0]          ;;  Regularly gridded velocities [km/s]
vy             = vx
vz             = vx
dens           = 1d1                                       ;;  Number density [cm^(-3)]
vther          = 25d0                                      ;;  Thermal speed [km/s]
var_g          = vther[0]^2/2d0                            ;;  Variance of a Gaussian [km^(+2) s^(-2)]
std_g          = SQRT(var_g[0])                            ;;  Std. Deviation of a Gaussian [km/s]
vbulk          = [-4d2,1d2,5d1]                            ;;  Dummy bulk flow velocity [km/s]
amps           = dens[0]*1d6/SQRT(2d0*!DPI*var_g[0]*1d6)   ;;  cm^(-3) --> m^(-3), km^(-2) --> m^(-2)
fmax           = amps[0]                                   ;;  Max[ f(vx,vy,vz) ] [s^(+3) m^(-6)]
;fmax           = 1d-6                               ;;  Max[ f(vx,vy,vz) ] [s^(+3) km^(-3) cm^(-3)]
;;  Define [6]-element PARAM array accepted by gaussian_1d.pro
param0         = REPLICATE(d,6L)
vo_xyz         = vbulk*1d3                          ;;  km --> m
vt_in          = std_g[0]*1d3                       ;;  km --> m
param0[0]      = fmax[0]                            ;;  Max amplitude of Gaussian peak [s^(+3) m^(-6)]
param0[1]      = vo_xyz[0]                          ;;  Offset of Gaussian peak [m/s]
param0[2]      = vt_in[0]                           ;;  Standard Deviation of Gaussian peak [m/s]

paramx         = param0
paramy         = param0
paramz         = param0
;;  Change offsets
paramy[1]      = vo_xyz[1]
paramz[1]      = vo_xyz[2]
;;  Get 1D Gaussians cutting through origin and peak of VDF
fx             = gaussian_1d(vx*1d3,paramx,/TOT_AMP)
fy             = gaussian_1d(vy*1d3,paramy,/TOT_AMP)
fz             = gaussian_1d(vz*1d3,paramz,/TOT_AMP)
yran           = [1d-30,3d2]

WSET,1
WSHOW,1
PLOT,vx,fx,/YLOG,/XSTYLE,/YSTYLE,/NODATA,YRANGE=yran
  OPLOT,vx,fx,COLOR=250
  OPLOT,vy,fy,COLOR=150
  OPLOT,vz,fz,COLOR= 50
;;  Define an arbitrary 3D Gaussian with uncorrelated velocities
nn             = 200L
vmax           = 7d2*1d3                                     ;;  Max speed [m/s] (assume protons --> ~30 keV)
vfac           = 2d0*vmax[0]/(nn[0] - 1L)
voff           = -1d0*vmax[0]
vx             = DINDGEN(nn[0])*vfac[0] + voff[0]            ;;  Regularly gridded velocities [m/s]
vy             = vx
vz             = vx
var_g          = vther[0]^2/2d0                              ;;  Variance of a Gaussian [km^(+2) s^(-2)]
std_g          = SQRT(var_g[0])                              ;;  Std. Deviation of a Gaussian [km/s]
afac           = (1d6/SQRT(2d0*!DPI*1d6))^(1d0/3d0)
amps           = afac[0]*(dens[0]/SQRT(var_g[0]))^(1d0/3d0)  ;;  cm^(-3) --> m^(-3), km^(-2) --> m^(-2)
;;  Define inputs for Gaussian
vo_xyz         = vbulk*1d3                          ;;  km --> m
vt_in          = std_g[0]*1d3                       ;;  km --> m
;;  Define exponent denominator (2*variance)
expdenom       = -2d0*var_g[0]*1d6
;;  Define total amplitude
fmax           = amps[0]^3
;;  Define exponent numerator ∑_j (V_j - V_oj)^2
expnumer       = REPLICATE(d,nn[0],nn[0],nn[0])
FOR j=0L, nn[0] - 1L DO FOR k=0L, nn[0] - 1L DO BEGIN                                      $
    expnumer[j,k,*] = (vx[j] + vo_xyz[0])^2 + (vy[k] + vo_xyz[1])^2 + (vz + vo_xyz[2])^2

vel_xyz        = REPLICATE(d,nn[0],nn[0],nn[0],3L)
FOR j=0L, nn[0] - 1L DO FOR k=0L, nn[0] - 1L DO FOR i=0L, nn[0] - 1L DO BEGIN              $
    vel_xyz[j,k,i,*]  = [vx[j],vy[k],vz[i]]

;;  Define f(vx,vy,vz)  [s^(+3) m^(-6)]
fvxyz          = fmax[0]*EXP(expnumer/expdenom[0])
test           = (ABS(fvxyz) LE 1d-40) OR (FINITE(fvxyz) EQ 0)
bad            = WHERE(test,bd)
IF (bd[0] GT 0) THEN fvxyz[bad] = d
;;  Reform into 1D and 2D arrays
nall           = N_ELEMENTS(fvxyz)
v_df           = REFORM(fvxyz,nall[0])
vxyz           = REFORM(vel_xyz,nall[0],3L)
;v_df           = REPLICATE(1d0,nn[0])
;vxyz           = DINDGEN(nn[0],3L)*1d2
dat            = {VDF:v_df,VELXYZ:vxyz}
;;  Test keyword initialization routine with minimum input
windn          = 1L
DELVAR,plot_str,cont_str
vbulk_change_keywords_init,dat,WINDN=windn,PLOT_STR=plot_str,CONT_STR=cont_str





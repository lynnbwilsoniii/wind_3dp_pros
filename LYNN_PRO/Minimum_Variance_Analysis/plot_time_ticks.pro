;+
;*****************************************************************************************
;
;  FUNCTION :   plot_time_ticks.pro
;  PURPOSE  :   Returns a structure to be used in plotting routines which have a time
;                 dependent axis and user desires UT Time displays.
;
;  CALLED BY: 
;               plot_vector_mv_data.pro
;
;  CALLS:       
;               NA
;
;  REQUIRES:    
;               NA
;
;  INPUT:
;               T1   :  N-Element Time Array ['HH:MM:SS.ssss']
;               T2   :  N-Element Double Array (Doesn't really matter if consistent)
;
;  EXAMPLES:    
;               NA
;
;  KEYWORDS:  
;               NTS  :  Scalar indicating the number of tick marks desired on 
;                         the particular axis of interest [Default = 7]
;                         Set equal to one less than desired number, thus the default
;                         value would result in 8 tick marks
;
;   CHANGED:  1)  Updated Man Page                         [11/05/2008   v1.0.5]
;             2)  Added comments and altered syntax        [12/06/2008   v1.0.6]
;             3)  Updated Man Page                         [05/24/2009   v1.1.0]
;             4)  Updated man page
;                   and renamed from htr_plot_ticks_2.pro  [08/12/2009   v2.0.0]
;
;   CREATED:  05/10/2008
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  08/12/2009   v2.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION plot_time_ticks,t1,t2,NTS=nts

;-----------------------------------------------------------------------------------------
; -Define/Determine relevant parameters
;-----------------------------------------------------------------------------------------
IF KEYWORD_SET(nts) THEN lts = nts ELSE lts = 7L
lts2    = lts + 1L       ; -Number of elements of tick arrays
labtick = STRARR(lts2)   ; -Time labels ('HH:MM:SS.ssss')
loctick = DBLARR(lts2)   ; -Associated time locations for time labels
flab    = STRARR(lts2)   ; -Plot labels which wraps the ms times below UT times
lab1    = STRARR(lts2)   ; -Time labels ('HH:MM:SS')
lab2    = STRARR(lts2)   ; -Time labels ('0.ssss')
nnpts   = N_ELEMENTS(t1) ; -Number of time series points
numtic  = 0L             ; -Dummy variable used to determine step between time elements
;-----------------------------------------------------------------------------------------
; -Determine Times associated with plot options:  [X,Y,Z]TICKNAME and [X,Y,Z]TICKV
;-----------------------------------------------------------------------------------------
numtic  = (nnpts - 1L)/(lts2 - 1L)
n_inds  = LINDGEN(lts2) * numtic
labtick = t1[n_inds]
loctick = t2[n_inds]
;-----------------------------------------------------------------------------------------
; -Define variables for [X,Y,Z]TICKNAME and [X,Y,Z]TICKV
;-----------------------------------------------------------------------------------------
lab1 = ['Time (HH:MM:SS)',STRMID(labtick[1:(lts2-1L)],0,8)]
lab2 = ['Time (ms)','0'+STRMID(labtick[1:(lts2-1L)],8,5)]
flab = lab1+'!C'+lab2
;-----------------------------------------------------------------------------------------
; -Define structures to return to htr_bcurl_FA.pro
;-----------------------------------------------------------------------------------------
extra = CREATE_STRUCT('YMARGIN',[4,4],'XTICKS',lts,'XTICKNAME',flab,'XTICKV',loctick,$
                      'XMINOR',5,'XTICKLEN',0.04)
mstr  = CREATE_STRUCT('EX',extra,'XYS',flab)
RETURN, mstr
END
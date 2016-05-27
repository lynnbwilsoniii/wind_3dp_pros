;+
;DEMONSTRATION OF TPLOT AND RELATED ROUTINES
;PURPOSE:
;  A sample crib sheet that explains how to use the "TPLOT" procedure.
;
;Written by Peter Schroeder 97-9-17
;
;- 

;Set up your device:
device,pseudo_color=8  ;fixes color table problem for machines with 24-bit color
;Pick a color table:
loadct,39         ;Rainbow      (I also recommend 22)



;Load some WIND_3DP key parameter data:
load_wi_3dp
96-5-20
2
load_wi_elsp_3dp
         
;List the currently available data quantities:
tplot_names

;Plot some quantities:
tplot,['wi_3dp_Ne','wi_3dp_Ve','wi_3dp_Te']
;or alternatively:
tplot,[1,2,3]

;Some examples of changing plotting options:

;Limits:

ylim,'wi_3dp_Ve',-200,200	; set y-limits from -200 to 200 for 'wi_3dp_Ve'
tplot

ylim,'wi_3dp_Te',1,20,1		; set y-limits from 1 to 20 and plot
tplot				; logarithmically (that's what the extra 1
				; does) for 'wi_3dp_Te'

ylim,'wi_3dp_Te',0,0,0		; reset y-limits for both variables back to
ylim,'wi_3dp_Ve',0,0,0		; linear auto-scaling
tplot

ylim				; use the mouse to set the limit range
tplot

;Time limit

tplot,refdate='96-5-20'		; set reference date

tlimit,1,3			; time limit from 100 UT to 300 UT

tlimit,/full			; full time limit

tlimit				; use the mouse to select a time range

tlimit,0,0			; back to auto ranging

;Multiline plots:

tplot,'wi_3dp_Fe',/add_var	; add another variable to plot

tplot,/nocolor			; turn off auto coloring on multi-line plots
				; (for hardcopies)

options,'wi_3dp_Fe','labflag',-1    ; Set evenly spaced labels
tplot

options,'wi_3dp_Fe','labflag',0     ; No labels
tplot

options,'wi_3dp_Fe','labflag',1     ; Reverse order
tplot

options,'wi_3dp_Fe','labflag',2     ; Auto spacing
tplot

bins = replicate(1,7)
bins( [2,4] ) = 0            ; turn off channels 2,4
options,'wi_3dp_Fe','bins',bins     ; add bins option 
tplot

options,'wi_3dp_Fe','bins',1        ; turn all channels on
tplot


;Spectrogram options:

tplot,'elsp'			; produce line plot of spectral data

options,'elsp','spec',1		; set option to produce a spectrum plot
tplot

zlim,'elsp',10,1e4,1		; set limited range and plot logarithmically
tplot

zlim,'elsp',0,0,0		; return to linear autoscaling
tplot

options,'elsp','y_no_interp',1	; prevent y-axis interpolation
tplot

options,'elsp','y_no_interp',0	; allow y-axis interpolation
tplot

options,'elsp','ystyle',1	; force exact y-axis limits
tplot

options,'elsp','ystyle',0	; return to autoranging
tplot

options,'elsp','spec',0		; change to multi-line plot
tplot


;Setting global options:

tplot_options,'title','My very own plot'	; set tplot title
tplot

tplot_options,'region',[0.,.5,1.,1.]   ; use top half of screen only
tplot

tplot_options,'region'                 ; remove region keyword (full screen)
tplot

tplot_options,'xmargin' ,[15,10]         ; change default xmargin
tplot

tplot_options,'ymargin' ,[6,3]          ; change default ymargin
tplot

tplot_options,'charsize',.5             ; change default character size
tplot

tplot_options,'charsize',1.		; back to regular character size

;Adding extra labels at the bottom:
;Any tplot (scaler) variable can also be printed at the bottom, below 
;the time labels.

tplot,var_label=['wi_3dp_Ne']

options,'wi_3dp_Ne','ytitle','Ne'       ; Change the label
options,'wi_3dp_Ne','format','(f8.3)'         ; Change the printing format
tplot

;Miscellaneous:

tplot,[1,2,3,4]
tplot,mix=[3,1,2]   ;Mix the panel order,  plot the 3rd, then 1st, then 2nd
tplot,/last	    ;Return to last mix of panels and variables

tplot,/pick         ;Use the cursor to pick panels

options,'wi_3dp_Fe','panel_size',2.   ;make one panel double size
tplot

time_stamp,/off     ;Turn of the time_stamp
tplot

time_stamp,/on      ;Turn it on again
tplot

tplot,version=2	    ;Change labeling scheme
tplot,version=1	    ;Another scheme
tplot,version=3	    ;Back to default

options,'wi_3dp_Np','color',90	;Set plotting color
tplot,'wi_3dp_Ne'		
tplot,'wi_3dp_Np',/overplot	;Overplot this data on the last plot

wi,2				;Open another window
tplot,'wi_3dp_Fe',window=2	;Plot in second window

store_data,'Ne&Np',data=['wi_3dp_Ne','wi_3dp_Np']
tplot,'Ne&Np',/add_var		;Plot two data quantities in same panel

tplot,'wi_3dp_Ne',new_tvars=tv_str  ;Plot and return tplot common block for plot
tlimit				;Create new plot with different time limits
wi,3				;Open a window
tplot,old_tvars=tv_str,window=3	;Plot original plot in new window
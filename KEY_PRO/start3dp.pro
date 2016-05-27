;+
;WIND 3D Plasma startup procedure.
;Calling procedure:
;@start3dp
;PURPOSE:  Initializes 3DP code.
;
;CREATED BY:	Davin Larson
;LAST MODIFICATION:	@(#)start3dp.pro	1.10 97/02/10
;-
!prompt = '3dp> '   ;  change prompt
on_error,1          ;  returns to main program whenever errors occur

old_dev = !d.name   ;  save current device name
set_plot,'PS'       ;  change to PS so we can edit the font mapping
device,/symbol,font_index=19  ;set font !19 to Symbol
set_plot,old_dev    ;  revert to old device
delvar,old_dev      ;  remove variable from workspace


;device,pseudo_color=8  ;fixes color table problem for machines with 24-bit color
loadct2,34             ;rainbow color map

  device,decomposed=0       ; my changes so x-window shows actual colors
  ncolors=!d.table_size-1
  ncolors=255
  !p.background = 255
  !p.color = 0

print,!d.n_colors,' colors available.'
print,'For help type: "help_3dp"  at the idl prompt'

!p.charsize = 1.0


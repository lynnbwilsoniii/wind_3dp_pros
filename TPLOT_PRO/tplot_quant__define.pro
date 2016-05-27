;+
;PROCEDURE: tplot_quant__define
;
; This procedure defines the tplot_quant structure.
;
;-
pro tplot_quant__define

dq = {tplot_quant,name:'', dh:ptr_new(), lh:ptr_new(), dl:ptr_new(),$
	trange: dblarr(2), dtype: 0, create_time:0d}

end
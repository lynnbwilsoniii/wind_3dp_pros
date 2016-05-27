Last Modification =>  2008-06-23/22:23:26 UTC
;+
;NAME:		animate_el_eh_spec
;CALL:		animate_el_eh_spec,rate,[keywords]
;PARAMETERS:	rate: specifies the rate that the animation will
;		be displayed at, in percent of maximum.  For Sun Ultra
;		1 computers, a good value is 20.
;KEYWORDS:	units: the units ('df','eflux',etc.)
;		range: the z range (color scale) (should be set)
;		trange: the time range, as a 2-vector of strings
;		xrange: the xrange
;		sort: sorts the data points according to ndata
;		var_label: the variable labels
;		ascending: tells it to sort in ascending.  If not set,
;		sorts in descending order
;		ndata: the data to sort (default is 'n_3d_ph2')
;		picktimes: let's you interactively pick the time frame
;		from the tplot graph
;		wait: tells the program to wait for you to push return
;		before displaying the next graph
;		erange: the erange in a 2-vector
;		inst: which instrument to use (ex. 'el', 'eh', 'ph2')
;		numframes: total number of frames to create
;			Used when you only want, say, 20 frames over 3 hours
;CREATED:	Arjun Raj (3-17-98)
;-


Last Modification =>  2008-06-23/22:23:26 UTC
;+
;NAME:		animate_en_pa_spec
;CALL:		animate_en_pa_spec,rate,[keywords]
;PARAMETERS:	rate: specifies the rate that the animation will
;		be displayed at, in percent of maximum.  For Sun Ultra
;		1 computers, a good value is 20.
;KEYWORDS:	units: the units ('df','eflux',etc.)
;		range: the z range (color scale) (should be set)
;		trange: the time range, as a 2-vector of strings
;		xrange: the xrange
;		sort: sorts the data points according to ndata
;		var_label: the variable labels
;		ascending: tells it to sort in ascending.  If not set,
;		sorts in descending order
;		ndata: the data to sort (default is 'n_3d_ph2')
;		picktimes: let's you interactively pick the time frame
;		from the tplot graph
;		wait: tells the program to wait for you to push return
;		before displaying the next graph
;		erange: the erange in a 2-vector
;		inst: which instrument to use (ex. 'el', 'eh', 'ph2')
;		numframes: total number of frames to create
;			Used when you only want, say, 20 frames over 3 hours
;CREATED:	Arjun Raj (3-17-98)
;-


Last Modification =>  2008-06-23/22:23:26 UTC
;+
;NAME:		animate_v_spec
;CALL:		animate_v_spec,rate,[keywords]
;PARAMETERS:	rate: specifies the rate that the animation will
;		be displayed at, in percent of maximum.  For Sun Ultra
;		1 computers, a good value is 20.
;KEYWORDS:	units: the units ('df','eflux',etc.)
;		range: the z range (color scale) (should be set)
;		trange: the time range, as a 2-vector of strings
;		xrange: the xrange
;		sort: sorts the data points according to ndata
;		var_label: the variable labels
;		ascending: tells it to sort in ascending.  If not set,
;		sorts in descending order
;		ndata: the data to sort (default is 'n_3d_ph2')
;		picktimes: let's you interactively pick the time frame
;		from the tplot graph
;		wait: tells the program to wait for you to push return
;		before displaying the next graph
;		erange: the erange in a 2-vector
;		inst: which instrument to use (ex. 'el', 'eh', 'ph2')
;		numframes: total number of frames to create
;			Used when you only want, say, 20 frames over 3 hours
;CREATED:	Arjun Raj (3-17-98)
;-


Last Modification =>  2008-06-23/22:23:26 UTC
;+
;FUNCTION:	c_3d(temp,ERANGE=erange,BINS=bins)
;INPUT:	
;	temp:	structure,	3d data structure filled by get_pl, get_el, etc.
;	erange:	fltarr(2),	optional, min,max energy bin numbers for integration
;	bins:	bytarr(nbins),	optional, angle bins for integration, see edit3dbins.pro
;				0,1=exclude,include,  nbins = temp.nbins
;PURPOSE:
;	Returns the sum of the counts in temp.data
;NOTES:	
;	Function normally called by "get_3dt" to generate 
;	time series data for "tplot".
;
;CREATED BY:
;	J.McFadden
;LAST MODIFICATION:
;	95-7-27		J.McFadden
;-


Last Modification =>  2009-06-21/22:13:28 UTC
;+
;*****************************************************************************************
;
;  FUNCTION :   cal_rot.pro
;  PURPOSE  :   Returns a rotation matrix that rotates V1 and V2 to the X'-Y' Plane where
;                 V1 is rotated to the X'-Axis and V2 into the X'-Y' Plane.
;
;  CALLED BY: 
;               add_df2d_to_ph.pro
;
;  CALLS:       NA
;
;  REQUIRES:    NA
;
;  INPUT:
;               V1  :  3-Element vector to be X'-Axis about which V2 is rotated to make
;                        the new X'-Y' Plane
;               V2  :  3-Element vector
;
;  EXAMPLES:    NA
;
;  KEYWORDS:    NA
;
;   CHANGED:  1)  J. McFadden changed something...        [09/13/1995   v1.0.?]
;             2)  Re-wrote and cleaned up                 [06/21/2009   v1.1.0]
;
;   CREATED:  ??/??/????
;   CREATED BY:  J. McFadden
;    LAST MODIFIED:  06/21/2009   v1.1.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-


Last Modification =>  2008-06-23/22:23:26 UTC
;+
;NAME:		cut1d
;CALL:		cut1d,timevectorofstrings,[keywords]
;KEYWORDS:	inst: tells which instrument to use ('el','ph2',etc.), def. is 'el'
;		DEFAULT INST IS EL
;		xrange: the xrange
;		range: the zrange
;		units: the units ('df','eflux',etc.) (def. is 'df')
;		notzlog: plots on a linear z scale
;			THERE MAY BE PROBLEMS IF NOTZLOG IS SET
;		thebdata: specifies which b data to use (default is B3_gse)
;		plotenergy: plots with x as energy rather than velocity
;		vel: the velocity to use for bulk flow transform, def. is v_3d_ph
;		IF VEL KEYWORD IS NOT SET, THE DATA IS NOT TRANSFORMED
;		step: tells the program to step the data.  If it's set to 1, then
;			it will do automatic stepping.
;		nosmooth: doesn't smooth the data
;		resolution: resolution of interpolated grid
;		gettimes: returns the times used
;		picktimes: let's the user pick times to use
;		erange: sets the energy range used
;		rmbins: specifies the angle range around the anti sunward
;			direction to cut out (useful for photoelectrons)
;			If this keyword is set like /rm, it uses 30 deg.
;		var_label: puts the variable labels on for each time
;		last: automatically duplicates last plot (overrides /picktimes)
;CREATED:	Arjun Raj (2-19-98)
;EXAMPLES:
;		cut1d,['96-01-12/14:','96-01-12/15:'],bdata = 'Bexp'
;		shows 1d cuts at two times, using Bexp
;		cut1d,/picktimes,inst = 'ph',units = 'eflux'
;		user selects times, shows Pesa High data in eflux units
;		cut1d,/picktimes,erange = [25,1400]
;		user selects times, restricts energy range to cut out photoelectrons
;-


Last Modification =>  2008-06-23/22:23:26 UTC
;+
;NOTE!:   This program is no longer maintained!  Use slice2d with ang=90.
;NAME:			cut2d
;PURPOSE:		creates a velocity or energy spectrogram
;			with v perp and v para as x and y, and the
;			specified units as z (color axis).
;			Also tranforms into bulk flow frame (unlike get_v_spec)
;CALL:			ex: get_v_spec_t,get_el('20:31'),[keywords]
;KEYWORDS:		XRANGE: vector specifying the xrange
;			RANGE: vector specifying the color range
;			UNITS: specifies the units ('eflux','df',etc.) (Def. is 'df')
;			NOZLOG: specifies a linear Z axis
;			THEBDATA: specifies b data to use (def is B3_gse)
;			VAR_LA: vector of tplot variables to show on plot
;			POSITION: positions the plot using a 4-vector
;			ERANGE: specifies the energy range to be used
;			NOFILL: doesn't fill the contour plot
;			NLINES: says how many lines to use if using NOFILL
;			SHOWDATA: plots all the data points over the contour
;			PLOTENERGY: plots using energy instead of velocity
;			VEL: tplot variable containing the velocity data
;			     (default is calculated with v_3d)
;			NOGRID: forces no triangulation
;			NOCROSS: suppresses cross section line plots
;			RESOLUTION: resolution of the mesh (default is 51)
;			NOSMOOTH: suppresses smoothing
;			NOSUN: suppresses the sun direction line
;			rmbins: tells the program to remove sun noise
;			theta:	how much theta range to cut out def. 40
;			phi:	how much phi range to cut out def. 20
;				both theta and phi only make sense for rmbins
;			NR: removes background noise from ph using noise_remove
;			noiselevel: background level in eflux
;			bottom: level to set as min eflux for background. def. is 0.
;			rm2: removes the sun noise using subtraction
;				REQUIRES write_ph.doc to run
;				Note: automatically sets /nosmooth
;				for smoothing, set /smooth
;			nlow: used with rm2.  Sets bottom of eflux noise level
;				def. 1e5
;			m: marks the tplot at the current time
;			filename: filename of stored data for rm2.
;			novelline: suppresses the velocity line
;LAST MODIFIED:		4-30-98
;CREATED BY:		Arjun Raj
;EXAMPLES:
;			cut2d,get_el('21:00')
;			displays 2d cut using el
;			cut2d,get_ph('21:00'),thebdata = 'Bexp'
;			displays 2d cut with Bexp used as b data
;			cut2d,get_ph(/adv), units = 'eflux'
;			advances time one step, uses eflux units
;			cut2d,get_el(/adv),erange = [25,900]
;			restricts energies to cut out photoelectrons
;			cut2d,get_el(/adv),vel = 'Vconv'
;			transforms into velocity frame, using specified velocity
;REMARKS:		when calling with phb and rm2, use file='write_phb.doc'
;			also, set the noiselevel to 1e5.  This gives the best
;			results
;
;
;  Modified by:  Lynn B. Wilson III
;
;  Last Modified:  08-15-2007
;-


Last Modification =>  2008-06-23/22:23:26 UTC
;+
;NAME:		fixangdata
;PURPOSE:	rebins the angle data to make the data look better
;
;		This function is called by get_v_spec, get_en_pa_spec,
;		and their related programs.
;CREATED BY:	Arjun Raj (8-15-97)
;-


Last Modification =>  2008-06-23/22:23:26 UTC
;+
;Procedure:	interpolate, a, b, str_out
;INPUT:	
;	a:	a string containing a structure (e.g. a.x(1000), a.y(1000,3))
;	b:	the other string. a.x and b.x are not the same. The resulting
;		array size is the size of a.
;OUTPUT:
;	str_out: a string which contains the interpolate version of b. 	
;PURPOSE:
;	To make vectors of the same size by interpolation.
;	
;
;CREATED BY:
;	Tai Phan	96-10-16
;LAST MODIFICATION:
;	96-10-16		Tai Phan
;-


Last Modification =>  2008-06-23/22:23:26 UTC
;+
;FUNCTION:	j_3d(temp,ERANGE=erange,BINS=bins)
;INPUT:	
;	temp:	structure,	3d data structure filled by get_pl, get_el, etc.
;		e.g "get_el"
;	erange:	fltarr(2),	optional, min,max energy bin numbers for integration
;	bins:	bytarr(nbins),	optional, angle bins for integration, see edit3dbins.pro
;				0,1=exclude,include,  nbins = temp.nbins
;PURPOSE:
;	Returns the flux, [Jx,Jy,Jz], 1/(cm^2-s) 
;NOTES:	
;	Function normally called by "get_3dt" to generate 
;	time series data for "tplot,".
;
;CREATED BY:
;	J.McFadden
;LAST MODIFICATION:
;	95-7-27		J.McFadden
;-


Last Modification =>  2008-06-23/22:23:26 UTC
;+
;FUNCTION:	n_3d(temp,ERANGE=erange,BINS=bins)
;INPUT:	
;	temp:	structure,	3d data structure filled by get_pl, get_el, etc.
;		e.g "get_el"
;	erange:	fltarr(2),	optional, min,max energy bin numbers for integration
;	bins:	bytarr(nbins),	optional, angle bins for integration, see edit3dbins.pro
;				0,1=exclude,include,  nbins = temp.nbins
;PURPOSE:
;	Returns the density, N, 1/(cm^3) 
;NOTES:	
;	Function normally called by "get_3dt" to generate 
;	time series data for "tplot,".
;
;CREATED BY:
;	J.McFadden
;LAST MODIFICATION:
;	95-7-27		J.McFadden
;-


Last Modification =>  2008-06-23/22:23:26 UTC
;+
;FUNCTION:	p_3d(temp,ERANGE=erange,BINS=bins)
;INPUT:	
;	temp:	structure,	3d data structure filled by get_pl, get_el, etc.
;		e.g "get_el"
;	erange:	fltarr(2),	optional, min,max energy bin numbers for integration
;	bins:	bytarr(nbins),	optional, angle bins for integration, see edit3dbins.pro
;				0,1=exclude,include,  nbins = temp.nbins
;PURPOSE:
;	Returns the pressure tensor, [Pxx,Pyy,Pzz,Pxy,Pxz,Pyz], eV/cm^3 
;NOTES:	
;	Function normally called by "get_3dt" to generate 
;	time series data for "tplot,".
;
;CREATED BY:
;	J.McFadden
;LAST MODIFICATION:
;	95-7-27		J.McFadden
;-


Last Modification =>  2008-06-23/22:23:26 UTC
;+
; NAME:
;       padplot_widg_kill
;
; PURPOSE: 
;
;       This procedure cleans up after the padplot_widg widget when it is
;       killed.  This is accomplished by removing the element of the
;       regarr list correspoinding to the killed widget.
;
;       *This procedure should only be called by xmanager.pro!
;
; CATEGORY:
;       
;       padplot_tool
;
; CALLING SEQUENCE:
;       
;       padplot_widg_kill, id
;
; INPUTS:
;       
;       id:  The widget id of the widget being killed.
;
; COMMON BLOCKS:
;
;       myregister: This common block exists to make the the variable
;                   myreg global.  The purpose of this variable is to
;                   register hydra_fitf widgets.  Specifically, myreg
;                   is an array of structures which contain the widget
;                   id of a hydra_fitf base widget and the widget id
;                   of the draw window which owns that slice window.
;                   This array facilitate multiple slice widgets being
;                   open at the same time.  With out this registry one
;                   would not be able to know which slice widget a
;                   given draw window click event should be sent to.  
;
; SIDE EFFECTS:
;       
;       The element of the regarr associated with the killed window is
;       erased.
;
; Written by:   Eric E. Dors, 1 March 1998.
;
; MODIFICATION HISTORY:
;
;-
;+
; NAME:
;       add_to_regarr
;
; PURPOSE:
;       
;       This function adds a new element to the regarr list when a new
;       slice widget is opened.
;
; CATEGORY:
;       
;       window_widg
;
; CALLING SEQUENCE:
;
;       result=add_to_regarr(regarr)
;
; INPUTS:
;
;       regarr: regarr is an array of structures which contain the
;               widget id of a hydra_fitf base widget and the widget
;               id of the draw window which owns that slice window.
;               This array facilitate multiple slice widgets being
;               open at the same time.  With out this registry one
;               would not be able to know which slice widget a given
;               draw window click event should be sent to.
;
; OUTPUTS:
;
;       regarr: The updated widget rigistration list is returned.
;
;       result: The index to the new entry in regarr.
;
; EXAMPLE:
;
;               index = add_to_regarr(regarr)
;
;
; Written by:   Eric E. Dors, 1 March 1998.
;
; MODIFICATION HISTORY:
;
;-


Last Modification =>  2008-06-23/22:23:26 UTC
;+
; NAME:
;       plot3d_widg_kill
;
; PURPOSE: 
;
;       This procedure cleans up after the plot3d_widg widget when it is
;       killed.  This is accomplished by removing the element of the
;       regarr list correspoinding to the killed widget.
;
;       *This procedure should only be called by xmanager.pro!
;
; CATEGORY:
;       
;       plot3d_tool
;
; CALLING SEQUENCE:
;       
;       plot3d_widg_kill, id
;
; INPUTS:
;       
;       id:  The widget id of the widget being killed.
;
; COMMON BLOCKS:
;
;       myregister: This common block exists to make the the variable
;                   myreg global.  The purpose of this variable is to
;                   register hydra_fitf widgets.  Specifically, myreg
;                   is an array of structures which contain the widget
;                   id of a hydra_fitf base widget and the widget id
;                   of the draw window which owns that slice window.
;                   This array facilitate multiple slice widgets being
;                   open at the same time.  With out this registry one
;                   would not be able to know which slice widget a
;                   given draw window click event should be sent to.  
;
; SIDE EFFECTS:
;       
;       The element of the regarr associated with the killed window is
;       erased.
;
; Written by:   Eric E. Dors, 1 March 1998.
;
; MODIFICATION HISTORY:
;
;-
;+
; NAME:
;       add_to_regarr
;
; PURPOSE:
;       
;       This function adds a new element to the regarr list when a new
;       slice widget is opened.
;
; CATEGORY:
;       
;       window_widg
;
; CALLING SEQUENCE:
;
;       result=add_to_regarr(regarr)
;
; INPUTS:
;
;       regarr: regarr is an array of structures which contain the
;               widget id of a hydra_fitf base widget and the widget
;               id of the draw window which owns that slice window.
;               This array facilitate multiple slice widgets being
;               open at the same time.  With out this registry one
;               would not be able to know which slice widget a given
;               draw window click event should be sent to.
;
; OUTPUTS:
;
;       regarr: The updated widget rigistration list is returned.
;
;       result: The index to the new entry in regarr.
;
; EXAMPLE:
;
;               index = add_to_regarr(regarr)
;
;
; Written by:   Eric E. Dors, 1 March 1998.
;
; MODIFICATION HISTORY:
;
;-
;+
; NAME:
;	PLOT3D_TOOL
;
; PURPOSE:
;	This procedure provides a widget interface to the plot3d
;	plotting routine.
;
; CATEGORY:
;	Widgets.
;
; CALLING SEQUENCE:
;
;	PLOT3D_TOOL,window=window,wi_name = wi_name, group = group
;
; KEYWORD PARAMETERS:
;	window:	Window number for plot3d_tool.
;
;	wi_name: optional tool title.
;
;	group:  group hierarchy to which widget belong.
;
; OUTPUTS:
;	None.
;
;
; SIDE EFFECTS:
;	Describe "side effects" here.  There aren't any?  Well, just delete
;	this entry.
;
; RESTRICTIONS:
;	Must be used with tplot window already activated
;
; MODIFICATION HISTORY:
; 	Written by:	Arthur J. Hull, 8/2/99.
;-


Last Modification =>  2008-06-23/22:23:26 UTC
;+
;NAME:		show_specs
;CALL:		show_specs,time,[keywords]
;KEYWORDS:	advance: advances to the next time
;		zlog: makes color axis log
;		subtract: subtracts 90 from 180 and 0
;		nlines: # of lines for the contour
;		nofill: doesn't fill in the contour
;		showdata: shows the data points
;		erange: the erange
;		xrange: the xrange
;		range: the zrange
;		b3: uses b3 data
;		units: specifies the units
;		var_label: specifies the variable labels
;		plotenergy: plots energy instead of velocity
;		vel: tells which velocity to use for bulk flow (def: v_3d_ph2)
;		smooth: smooths the data
;		onecnt: shows the one count line
;		eesah: does a plot for eesa high as well
;		pesah: does a plot for pesa high as well
;		elb: uses el burst data
;		sundir: plots the sun direction
;		print: prints the data
;NOTES:		Window 4 should be the tplot window (must be already tplotted)
;		Window 1 will have eesa low velocity graphs
;		Window 2 will have el_eh_spec
;		Window 3 will have eesa high velocity graphs (if EESAH is set)
;		Window 5 will have pesa high velocity graphs (if PESAH is set)
;CREATED:	Arjun Raj (8-19-97)
;-


Last Modification =>  2008-06-23/22:23:26 UTC
;+
; NAME:
;       spec3d_widg_kill
;
; PURPOSE: 
;
;       This procedure cleans up after the spec3d_widg widget when it is
;       killed.  This is accomplished by removing the element of the
;       regarr list correspoinding to the killed widget.
;
;       *This procedure should only be called by xmanager.pro!
;
; CATEGORY:
;       
;       spec3d_tool
;
; CALLING SEQUENCE:
;       
;       spec3d_widg_kill, id
;
; INPUTS:
;       
;       id:  The widget id of the widget being killed.
;
; COMMON BLOCKS:
;
;       myregister: This common block exists to make the the variable
;                   myreg global.  The purpose of this variable is to
;                   register hydra_fitf widgets.  Specifically, myreg
;                   is an array of structures which contain the widget
;                   id of a hydra_fitf base widget and the widget id
;                   of the draw window which owns that slice window.
;                   This array facilitate multiple slice widgets being
;                   open at the same time.  With out this registry one
;                   would not be able to know which slice widget a
;                   given draw window click event should be sent to.  
;
; SIDE EFFECTS:
;       
;       The element of the regarr associated with the killed window is
;       erased.
;
; Written by:   Eric E. Dors, 1 March 1998.
;
; MODIFICATION HISTORY:
;
;-
;+
; NAME:
;       add_to_regarr
;
; PURPOSE:
;       
;       This function adds a new element to the regarr list when a new
;       slice widget is opened.
;
; CATEGORY:
;       
;       window_widg
;
; CALLING SEQUENCE:
;
;       result=add_to_regarr(regarr)
;
; INPUTS:
;
;       regarr: regarr is an array of structures which contain the
;               widget id of a hydra_fitf base widget and the widget
;               id of the draw window which owns that slice window.
;               This array facilitate multiple slice widgets being
;               open at the same time.  With out this registry one
;               would not be able to know which slice widget a given
;               draw window click event should be sent to.
;
; OUTPUTS:
;
;       regarr: The updated widget rigistration list is returned.
;
;       result: The index to the new entry in regarr.
;
; EXAMPLE:
;
;               index = add_to_regarr(regarr)
;
;
; Written by:   Eric E. Dors, 1 March 1998.
;
; MODIFICATION HISTORY:
;
;-


Last Modification =>  2008-06-23/22:23:26 UTC
;+
;FUNCTION:	t_3d(temp,ERANGE=erange,BINS=bins)
;INPUT:	
;	temp:	structure,	3d data structure filled by get_pl, get_el, etc.
;		e.g "get_el"
;	erange:	fltarr(2),	optional, min,max energy bin numbers for integration
;	bins:	bytarr(nbins),	optional, angle bins for integration, see edit3dbins.pro
;				0,1=exclude,include,  nbins = temp.nbins
;PURPOSE:
;	Returns the temperature, [Tx,Ty,Tz,Tavg], eV 
;NOTES:	
;	Function normally called by "get_3dt" to generate 
;	time series data for "tplot,".
;
;CREATED BY:
;	J.McFadden
;LAST MODIFICATION:
;	95-7-27		J.McFadden
;-


Last Modification =>  2008-06-23/22:23:26 UTC
;+
;FUNCTION:	v_3d(temp,ERANGE=erange,BINS=bins)
;INPUT:	
;	temp:	structure,	3d data structure filled by get_pl, get_el, etc.
;		e.g. "get_el"
;	erange:	fltarr(2),	optional, min,max energy bin numbers for integration
;	bins:	bytarr(nbins),	optional, angle bins for integration, see edit3dbins.pro
;				0,1=exclude,include,  nbins = temp.nbins
;PURPOSE:
;	Returns the velocity, [Vx,Vy,Vz], km/s 
;NOTES:	
;	Function normally called by "get_3dt" to generate 
;	time series data for "tplot".
;
;CREATED BY:
;	J.McFadden
;LAST MODIFICATION:
;	95-7-27		J.McFadden
;-


Last Modification =>  2008-06-23/22:23:26 UTC
;+
;FUNCTION:	vth_3d(temp,ERANGE=erange,BINS=bins)
;INPUT:	
;	temp:	structure,	3d data structure filled by get_pl, get_el, etc.
;		e.g "get_el"
;	erange:	fltarr(2),	optional, min,max energy bin numbers for integration
;	bins:	bytarr(nbins),	optional, angle bins for integration, see edit3dbins.pro
;				0,1=exclude,include,  nbins = temp.nbins
;PURPOSE:
;	Returns the thermal velocity, [Vthx,Vthy,Vthz,Vthavg], km/s 
;NOTES:	
;	Function normally called by "get_3dt" to generate 
;	time series data for "tplot,".
;
;CREATED BY:
;	J.McFadden
;LAST MODIFICATION:
;	95-7-27		J.McFadden
;-



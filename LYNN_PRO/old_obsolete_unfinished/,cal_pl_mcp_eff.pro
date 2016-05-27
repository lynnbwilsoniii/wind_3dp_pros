;+
;*****************************************************************************************
;
;  FUNCTION :   cal_pl_mcp_eff.pro
;  PURPOSE  :   Determines the multichannel plate (MCP) efficiency and deadtime of the
;                 PESA Low detector in 5x5 anode mode.
;
;  CALLED BY:   
;               
;
;  CALLS:
;               get_pl_cal.pro
;
;  REQUIRES:    
;               1)  External Windlib libraries
;               2)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               DATA    :  Structure from the SWE nonlinear bi-Maxwellian fit analysis
;                            with format:
;                            {X:Unix,N:Density,V:Velocity,T:Temperature}
;
;  EXAMPLES:    
;               
;
;  KEYWORDS:    
;               TRANGE  :  [Double] 2 element array specifying the range over 
;                            which to get data structures [Unix time]
;               
;
;   CHANGED:  1)  get_pl_cal.pro is no longer part of this file     [06/08/2011   v1.0.0]
;
;   NOTES:      
;               1)  **Still working on this routine**
;
;   CREATED:  06/07/2011
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  06/08/2011   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION cal_pl_mcp_eff,data,TRANGE=trange

;-----------------------------------------------------------------------------------------
; => Dummy variables
;-----------------------------------------------------------------------------------------
f      = !VALUES.F_NAN
d      = !VALUES.D_NAN
dtags  = ['X','N','V','T']

;-----------------------------------------------------------------------------------------
; => First check to see if running 32 bit so that shared object libraries work
;-----------------------------------------------------------------------------------------
IF (!VERSION.MEMORY_BITS GT 32) THEN RETURN,0
;-----------------------------------------------------------------------------------------
; => Check input
;-----------------------------------------------------------------------------------------
sz    = SIZE(data,/TYPE)
IF (sz[0] NE 8) THEN RETURN,0

tags  = TAG_NAMES(data)
nt    = N_TAGS(data)
IF (nt NE 4) THEN RETURN,0
good  = WHERE(tags EQ dtags,gd)
IF (gd NE 4) THEN RETURN,0
;-----------------------------------------------------------------------------------------
; => Determine if any data is available
;-----------------------------------------------------------------------------------------
test  = get_uncal_pl(TRANGE=trange)
stop
; => The following is from get_pl_extra.pro
;
;pl_mcp_eff,retdat.time,deadt=dt,mcpeff=mcpeff
;retdat.deadtime = dt
;retdat.geomfactor= retdat.geomfactor * mcpeff


END
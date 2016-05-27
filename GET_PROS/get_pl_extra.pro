;retdat.deadtime = 1e-6 * 4
;retdat.geomfactor = retdat.geomfactor * .7
pl_mcp_eff,retdat.TIME,DEADT=dt,MCPEFF=mcpeff
retdat.DEADTIME    = dt
retdat.GEOMFACTOR *= mcpeff

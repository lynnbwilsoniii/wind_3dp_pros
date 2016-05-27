function units_string,units
case strlowcase(units) of

'counts' : ustr = 'Counts'
'rate'   : ustr = 'Rate (Counts/sec)'
'eflux'  : ustr = 'Energy Flux (eV / sec / cm^2 / ster / eV)'
'flux'   : ustr = 'Flux (# / sec / cm^2 / ster / eV)'
'df'     : ustr = 'f (sec^3 / km^3 /cm^3)'
'e2flux' : ustr = 'Energy^2 Flux (eV^2 / sec / cm^2 / ster /ev)'
'e3flux' : ustr = 'Energy^3 Flux (eV^3 / sec / cm^2 / ster /ev)'
else     : ustr = 'Unknown'
endcase



return,ustr
end

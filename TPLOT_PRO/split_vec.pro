PRO split_vec,names,polar=polar,titles=titles
;+
;NAME:                  split_vec
;PURPOSE:               
;                       take a stored vector like 'Vp' and create stored vectors 'Vp_x','Vp_y','Vp_z'
;CALLING SEQUENCE:      split_vec,names
;INPUTS:                names: string or strarr, elements are data handle names
;OPTIONAL INPUTS:       
;KEYWORD PARAMETERS:    polar: Use '_mag', '_th', and '_phi'
;			titles: an array of titles to use instead of the default or polar sufficies
;OUTPUTS:               
;OPTIONAL OUTPUTS:      
;COMMON BLOCKS:         
;SIDE EFFECTS:          
;RESTRICTIONS:          
;EXAMPLE:               
;LAST MODIFICATION:     %W% %E%
;CREATED BY:            Frank V. Marcoline
;-

  nms = tnames(names)
  
  num = n_elements(nms)


  IF keyword_set(polar) THEN suffix = ['_mag','_th','_phi'] $
  ELSE suffix = ['_x','_y','_z']


  FOR i=0,num-1 DO BEGIN 
    get_data,nms[i],dat=dat,dlim=dlim,lim=lim,alim=alim
      tags = tag_names(dat)
      nt = n_elements(tags)
      labels = ''
      str_element,alim,'labels',labels
      ny = dimen2(dat.y)
      if ny eq 3 then suffix=['_x','_y','_z']  $
      else suffix = strcompress('_'+string(indgen(ny)),/remove)
      for j = 0,ny-1 do begin
         store_data,nms[i]+suffix[j],data={x:dat.x,y:dat.y[*,j]},dlim=dlim,lim=lim
         if keyword_set(labels) then options,nms[i]+suffix[j],/def,ytitle=labels[j]
      endfor
  ENDFOR 
END 


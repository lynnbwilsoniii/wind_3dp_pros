pro get_burst_times

elbt = get_elb(/times)
plbt = get_plb(/times)
phbt = get_phb(/times)
sfbt = get_sfb(/times)
sobt = get_sob(/times)
fpct = get_fpc(/times)

store_data,'sfb_times',data={x:sfbt ,y:replicate(1b,n_elements(sfbt)), colors:1}
store_data,'sob_times',data={x:sfbt ,y:replicate(2b,n_elements(sobt)), colors:2}
store_data,'plb_times',data={x:plbt ,y:replicate(3b,n_elements(plbt)), colors:3}
store_data,'phb_times',data={x:phbt ,y:replicate(4b,n_elements(phbt)), colors:4}
store_data,'elb_times',data={x:elbt ,y:replicate(5b,n_elements(elbt)), colors:5}
store_data,'fpc_times',data={x:fpct ,y:replicate(6b,n_elements(fpct)), colors:6}

store_data,'bst_times',data=str_sep('sfb sob plb phb elb fpc',' ')+'_times',dlim={psym:3,yrange:[0,8.]}

options,'bst_times','ytitle','Bst'
options,'bst_times','panel_size',.2


return

end

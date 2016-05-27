function mom_ph,dat

bins = indgen(dat.nbins) lt dat.nbins-1

mom = mom3d(dat,bins=bins)


return,mom
end

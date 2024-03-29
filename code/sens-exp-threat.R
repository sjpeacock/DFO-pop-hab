###############################################################################
###############################################################################
#
# Quantifying the relationship between population trends and freshwater habitat
# Stephanie Peacock <speacock@psf.ca>
#
# This code takes the model object from `fitting.R` and samples from the 
# posterior and data to calculate the sensitivity, exposure, and threat 
# of different salmon species and Freshwater Adaptive Zones (FAZs) throughout BC.
# Produces large dot plots for main report showing these metrics.
#
###############################################################################
###############################################################################

# Source code that loads MCMC output and de-lists/creates index
# to easier access that output.

source("loadResults.R")

# fit = raw MCMC output from jags.fit()
# out = de-listed fit, with dimension (3, 50000, 333) = (chains, iterations, 
# parameters)

#--------------------------------------------------------------------
# Setup parameters for random selection of MCNC output
#--------------------------------------------------------------------

n <- 10000 # Number of draws

# Select MCMC draws from model output
# For each of the n draws, which chain and iteration are we using?
set.seed(4569)
indMod <- cbind(
	sample(1:numChains, size = n, replace = TRUE), 
	sample(1:numIter, size= n, replace = TRUE))

#--------------------------------------------------------------------
# How many populations in each category?
#--------------------------------------------------------------------

nSlope <- array(
	data = NA, 
	dim = c(4, 10, nFAZ), 
	dimnames = list(spawnNames, habNames, fazNames))

for(i in 1:nSpawn){
	for(h in 1:nHab){
		for(j in 1:nFAZ){
			nSlope[i, h, j] <- length(which(popDat$spawnEco == spawnNames[i] & popDat[, habNames[h]] > 0 & popDat$FAZ == fazNames[j]))
		}
	}
}

#--------------------------------------------------------------------
# Calculate by FAZ and species or ecotype:
#   1) sensitivity - degree to which fish populations respond to a pressure (slope)
#                 (beta[1,s,j] + theta[FAZ,j] + phi[j] * o)
#   2) exposure - pressure values by species, FAZ, and habitat indicator
#              x[i,j]
#   3) threat - sensitivity * exposure
#            (beta[1,s,j] + theta[FAZ,j] + phi[j] * o) * x[i,j]
#   4) threatTotal - threat summed across pressures
#   5) status - baseline trend
#                      beta0 + theta[MAZ,r]
#   6) vulnerability - status + overallThreat
#--------------------------------------------------------------------

dum <- array(
	data = NA, 
	dim = c(nSpecies, nFAZ, nHab, n), 
	dimnames = list(speciesNames, fazNames, habNames, NULL))

Z <- list(
	sensitivity = dum,
	exposure = dum,
	threat = dum,
	threatTotal = array(
		data = NA, 
		dim = c(nSpecies, nFAZ, n), 
		dimnames = list(speciesNames, fazNames, NULL)),
	status = array(
		data = NA, 
		dim = c(nSpecies, nFAZ, n), 
		dimnames = list(speciesNames, fazNames, NULL)),
	vulnerability = array(
		data = NA, 
		dim = c(nSpecies, nFAZ, n), 
		dimnames = list(speciesNames, fazNames, NULL))
	)
	

#--------------------------------------------------------------------
# Calculate sensitivity and exposure
#--------------------------------------------------------------------

for(s in 1:nSpecies){
	for(i in 1:nFAZ){
		
		# Select MCMC draws from data
		ind.is <- which(popDat$SPECIES == speciesNames[s] & popDat$FAZ == fazNames[i])
		if(length(ind.is) > 0){
			indDat <- sample(ind.is, size = n, replace = TRUE)
			
			for(j in 1:n){ # For each of 10,000 random draws
				
				for(h in 1:nHab){ # For each habitat indicator
					
					Z$sensitivity[s, i, h, j] <- out[indMod[j, 1], indMod[j, 2], outInd$beta1[JAGSdat$spawnEco[indDat[j]], h]] + out[indMod[j, 1], indMod[j, 2], outInd$phi[h]] * JAGSdat$streamOrder[indDat[j]] + out[indMod[j, 1], indMod[j, 2], outInd$thetaFAZ[JAGSdat$faz[indDat[j]], h]]
					# Notes: 
					# Use JAGSdat stream order, which is re-cetnered around 4, 
					# rather than popDat stream order
					# Use JAGSdat variables for spawnEco and rearEco, which are numeric
					
					Z$exposure[s, i, h, j] <- JAGSdat$habPressures[indDat[j], h]
					
				} # end h
				
				Z$status[s, i, j] <- out[indMod[j, 1], indMod[j, 2], outInd$beta0] + out[indMod[j, 1], indMod[j, 2], outInd$thetaMAZ[JAGSdat$maz[indDat[j]], JAGSdat$rearEco[indDat[j]]]]
				
			} # end j
		} # end if
	} # end i FAZ
} # end s species

#--------------------------------------------------------------------
# Calculate threat and vulnerability
#--------------------------------------------------------------------

Z$threat <- Z$sensitivity * Z$exposure

for(s in 1:nSpecies){
	for(i in 1:nFAZ){
		Z$threatTotal[s, i, ] <- apply(Z$threat[s, i, , ], 2, sum)
		Z$vulnerability[s, i, ] <- Z$status[s, i, ] + Z$threatTotal[s, i, ]
	}}

		
###############################################################################
# Summarize MCMC output
###############################################################################

# Want to summarize the 10,000 MCMC draws by:
#     (1) mean effect (for size of point and colour)
#     (2) the evidence category (strong, moderate, weak, no)

dum <- array(
	data = NA, 
	dim = c(nSpecies, nFAZ, nHab, 2), 
	dimnames = list(speciesNames, fazNames, habNames, c("mean", "eWeight")))

dum2 <- array(
	data = NA, 
	dim = c(nSpecies, nFAZ, 2), 
	dimnames = list(speciesNames, fazNames, c("mean", "eWeight")))

ZZ <- list(
	sensitivity = dum,
	exposure = dum,
	threat = dum,
	threatTotal = dum2, 
	status = dum2,
	vulnerability = dum2
)

#------------------------------------------------------------------------------
# Create function to categorize as strong, moderate, weak, or no effect
#------------------------------------------------------------------------------

thresh <- rbind(
	upper = 1 - (1 - c(0.95, 0.8, 0.65))/2, 
	lower = (1 - c(0.95, 0.8, 0.65))/2)

colnames(thresh) <- c("strong", "moderate", "weak")

findCat <- function(X){
	p <- ecdf(X)(0)
	if(p < 0.025 | p > 0.975){
		1 # strong
	} else if(p < 0.1 | p > 0.9){
		2 # moderate
	} else if(p < 0.175 | p > 0.825){
		3 # weak
	} else {
		4 #none
	}
}

#------------------------------------------------------------------------------
# Categorize each of 6 metrics
#------------------------------------------------------------------------------

for(s in 1:nSpecies){
	for(i in 1:nFAZ){
		
		# Iff there is a salmon population of the given species in the FAZ
		if(length(which(popDat$SPECIES == speciesNames[s] & popDat$FAZ == fazNames[i])) > 0){
			
			for(k in 1:3){ # for metrics unique to habitat indicator
				ZZ[[k]][s, i, , 1] <- apply(Z[[k]][s, i, , ], 1, mean, na.rm = TRUE)
				ZZ[[k]][s, i, , 2] <- apply(Z[[k]][s, i, , ], 1, findCat)
			}
			
			for(k in 4:6){ # for metrics summed across habitat indicators
				
				ZZ[[k]][s, i, 1] <- mean(Z[[k]][s, i, ], na.rm = TRUE)
				ZZ[[k]][s, i, 2] <- findCat(Z[[k]][s, i, ])
			}
		}
	}} # end s and i

###############################################################################
# Determine categories for impact
###############################################################################

# For threat, status, and vulnerability, in units of annual change in log(S)
# Sensitivity is in annual change per unit change in habitat pressure, but is
# similar magnitude so can use the same scale
cutoffs <- log(c(1.001, 1.01, 1.05)) #for magnitude (absolute value)

# For exposure, range is from 0 to 40 (% or density km/km2)
# Do as a quantile across all watersheds?

# Load habitat data (one row per watershed, rather than per population as 
# in popDat)
habDat <- read.csv("data/pse_habitatpressurevalues_2018_disaggregated_grid14fixed.csv")
habDat[which(habDat < 0, arr.ind = TRUE)] <- 0

# Remove DD forestry watersheds
forestDD <- read.csv("data/forest_disturbance_dd.csv")
habDat <- habDat[which((habDat$WTRSHD_FID %in% forestDD$wtrshd_fid) == FALSE), ]

habCutoffs <- array(NA, dim = c(10, 3), dimnames = list(habNames, c("25%", "50%", "75%")))
for(h in 1:nHab){
	x <- habDat[, which(names(habDat) == habNames[h])]
	x <- x[which(x > 0)]
	habCutoffs[h, ] <- quantile(x, c(0.25, 0.5, 0.75), na.rm = TRUE)
}

###############################################################################
# Plot sensitivity, exposure, and threat by habitat indicator
###############################################################################

habNames3 <- c("agriculture", "urban development", "riparian disturbance", "linear development", "forestry roads", "non-forestry roads", "stream crossings", "forest disturbance", "ECA", "pine beetle defoliation")

dumCol <- pnw_palette("Bay", 2)
col.zz <- colorRampPalette(c(dumCol[2], "#FFFFFF", dumCol[1]))(n = 4)

#------------------------------------------------------------------------------
# Plotting
#------------------------------------------------------------------------------
# Figures showing (a) Sensitivity, (b) exposure, (c) threat by FAZ and habitat indicator
# Everything is negative then positive
# pdf(file = "figures/SensExpThreat_coho3.pdf", width = 12, height = 12, pointsize = 10)
quartz(width = 12, height = 12, pointsize = 10)
# png(file = "figures/SensExpThreat.png", width = 1800, height = 1800, res = 150, pointsize = 10)
par(mfrow = c(3, 5), mar = c(0, 0, 3, 0), oma = c(10, 7, 4, 2))

for(k in 1:3){
	
	for(s in 1:nSpecies){
	plot(c(1,nHab), c(1,nFAZ), "n", xlab = "", xaxt = "n", ylab = "", yaxt = "n", xlim = c(0.5, nHab + 0.5))
	if(s == 1) axis(side = 2, at = rev(1:nFAZ), fazNames, las = 1)
	for(i in 1:nFAZ){
		if(is_even(i)) polygon(x = c(0, 11, 11, 0), y = rep(c(i-0.5, i+0.5), each = 2), col = "#00000010", border = NA)
	}
	abline(v = seq(2.5, 8.5, 2), col = grey(0.8))
	for(h in 1:10){
		# Define cutoffs for point size
		if(k == 2) cutoff.k <- habCutoffs[h, ] else cutoff.k <- cutoffs
		
		ind <- which(!is.na(ZZ[[k]][s, , h, 1]))
		
		zz.pch <- c(25, 24)[(ZZ[[k]][s, ind, h, 1] > 0) + 1]
		zz.pch[which(ZZ[[k]][s, ind, h, 2] > 3 | ZZ[[k]][s, ind, h, 1] == 0)] <- 21
		
		zz.cex <- (findInterval(abs(ZZ[[k]][s, ind, h, 1]), cutoff.k) + 1)/2
		zz.cex[which(ZZ[[k]][s, ind, h, 1] == 0)] <- 1
		
		zz.bg <- paste0(dumCol[c(2,1)][(ZZ[[k]][s, ind, h, 1] > 0) + 1], c("50", "")[(ZZ[[k]][s, ind, h, 2] == 1) + 1])
		zz.bg[which(ZZ[[k]][s, ind, h, 1] == 0)] <- NA
		
		zz.col <- paste0(dumCol[c(2,1)][(ZZ[[k]][s, ind, h, 1] > 0) + 1], c("50", "")[(ZZ[[k]][s, ind, h, 2] <= 2) + 1])
		zz.col[which(ZZ[[k]][s, ind, h, 1] == 0 & ZZ[[k]][s, ind, h, 2] == 1)] <- "#000000"
		if(length(which(ZZ[[k]][s, ind, h, 1] == 0 & ZZ[[k]][s, ind, h, 2] != 1)) > 0){
			stop("Zero mean and not no??")
		}
		
		points(rep(h, length(ind)), 
					 c(nFAZ:1)[ind], 
					 pch = zz.pch, 
					 bg = zz.bg, 
					 col = zz.col, 
					 cex = zz.cex, # Will be a number between 1 and 4
					 lwd = 0.5)
		
	}
	if(k == 1) mtext(side = 3, line = 2, speciesNames[s], font = 2)
	if(s == 1) mtext(side = 3, line = 0.5, c("a) Sensitivity", "b) Exposure", "c) Threat")[k], adj = 0)
	if(k == 3) axis(side = 1, at = c(1:10), labels = habNames3, las = 2)
	}
}
mtext(side = 2, outer = TRUE, "Freshwater Adaptive Zone (FAZ)", line = 5)

dev.off()

#------------------------------------------------------------------------------
# Legend
#------------------------------------------------------------------------------
plot(1,1, "n", bty = "n", xaxt = "n", yaxt = "n", xlab = "", ylab = "")
legend("topright", pch = c(rep(25, 3), 21, 1), pt.bg = col.zz[c(1,2,2,2,NA)], col = c(col.zz[c(1, 1, 2, 2)], 1), pt.cex = c(rep(1.5, 4), 1), legend = c("strong evidence", "moderate evidence", "weak evidence", "no evidence", "zero exposure"), title = "Point type", bty = "n")

legend("topleft", pch = c(rep(24, 3), 21, 1), pt.bg = col.zz[c(4,3,3,3,NA)], col = c(col.zz[c(4,4,3,3)], 1), pt.cex = c(rep(1.5, 4), 1), legend = c("strong evidence", "moderate evidence", "weak evidence", "no evidence", "zero exposure"), title = "Point type", bty = "n")

legend("center", pch = rep(25, 4), pt.bg = col.zz[1], col = col.zz[1], pt.cex = c(1:4)/2, legend = c("< 1.001", "< 1.01", "< 1.05", "> 1.05"), title = "Point size\nSt/St+1", bty = "n")

legend("bottom", pch = rep(24, 4), pt.bg = col.zz[4], col = col.zz[4], pt.cex = c(1:4)/2, legend = c("<25%", "25-50%", "50-75%", ">75%"), title = "Point size\nSt/St+1", bty = "n")

# #----------------------------
# # Group by FAZ along the x-axis and hab indicator along the y-axis
# #----------------------------
# par(mfrow = c(3, 5), mar = c(0, 0, 3, 0), oma = c(10, 7, 4, 2))
# par(mfrow = c(7, 1), mar = c(0, 0, 0, 0), oma = c(5, 5, 2, 2))
# for(k in 1:3){
# 	for(i in 1:nFaz){
# 		plot(c(1,nHab), c(1,nSpecies), "n", xlab = "", xaxt = "n", ylab = "", yaxt = "n", xlim = c(0.5, nHab + 0.5), ylim = c(0.5, nSpecies + 0.5))
# 		axis(side = 2, at = rev(c(1:nSpecies)), speciesNames, las = 1)
# 		for(s in 1:nSpecies){
# 			if(is_even(s)) polygon(x = c(0, 11, 11, 0), y = rep(c(s-0.5, s+0.5), each = 2), col = "#00000010", border = NA)
# 		}
# 		abline(v = seq(2.5, 8.5, 2), col = grey(0.8))
# 		for(h in 1:10){
# 			ind <- which(!is.na(risk[[c(1,3,5)[k]]][, i, h, 1]))
# 			
# 			points(c(nSpecies:1)[ind], 
# 						 rep(h, length(ind)),
# 						 pch = c(25, 24)[riskCat[[k]][ind, i, h, 'dir'] + 1], 
# 						 bg = col.zz[riskCat[[k]][ind, i, h, 'dirSig']], 
# 						 col = col.zz[riskCat[[k]][ind, i, h, 'dirSig']], 
# 						 cex = riskCat[[k]][ind, i, h, 'mag']/1.5, lwd = 0.5)
# 			
# 		}
# 		if(k == 1) mtext(side = 3, line = 2, speciesNames[s], font = 2)
# 		if(s == 1) mtext(side = 3, line = 0.5, c("a) Sensitivity", "b) Threat", "c) Risk")[k], adj = 0)
# 		if(k == 3) axis(side = 1, at = c(1:10), labels = habNames3, las = 2)
# 	}
# }
# mtext(side = 2, outer = TRUE, "Freshwater Adaptive Zone (FAZ)", line = 5)

###############################################################################
# Plot sensitivity, exposure, and threat by habitat indicator by species
###############################################################################

habNames4 <- c("Agriculture", "Urban Devel.", "Riparian Dist.", "Linear Devel.", "Forestry Roads", "Non-forestry Roads", "Stream Crossings", "Forest Dist.", "ECA", "Pine Beetle")

#------------------------------------------------------------------------------
# Plotting
#------------------------------------------------------------------------------

for(s in 1:5){
	pdf(file = paste0("figures/SensExpThreat", speciesNames[s], ".pdf"), width = 6.3, height = 5, pointsize = 10)
	# quartz(width = 6.3, height = 5, pointsize = 10)
	par(mfrow = c(1,3), mar = c(0, 0, 0, 0), oma = c(10, 7, 4, 2))

	for(k in 1:3){
		
		plot(c(1,nHab), c(1,nFAZ), "n", xlab = "", xaxt = "n", ylab = "", yaxt = "n", xlim = c(0.5, nHab + 0.5))
		for(i in 1:nFAZ){
			if(is_even(i)) polygon(x = c(0, 11, 11, 0), y = rep(c(i-0.5, i+0.5), each = 2), col = "#00000010", border = NA)
		}
		abline(v = seq(2.5, 8.5, 2), col = grey(0.8))
		for(h in 1:10){
			# Define cutoffs for point size
			if(k == 2) cutoff.k <- habCutoffs[h, ] else cutoff.k <- cutoffs
			
			ind <- which(!is.na(ZZ[[k]][s, , h, 1]))
			
			zz.pch <- c(25, 24)[(ZZ[[k]][s, ind, h, 1] > 0) + 1]
			zz.pch[which(ZZ[[k]][s, ind, h, 2] > 3 | ZZ[[k]][s, ind, h, 1] == 0)] <- 21
			
			zz.cex <- (findInterval(abs(ZZ[[k]][s, ind, h, 1]), cutoff.k) + 1)/2
			zz.cex[which(ZZ[[k]][s, ind, h, 1] == 0)] <- 1
			
			zz.bg <- paste0(dumCol[c(2,1)][(ZZ[[k]][s, ind, h, 1] > 0) + 1], c("50", "")[(ZZ[[k]][s, ind, h, 2] == 1) + 1])
			zz.bg[which(ZZ[[k]][s, ind, h, 1] == 0)] <- NA
			
			zz.col <- paste0(dumCol[c(2,1)][(ZZ[[k]][s, ind, h, 1] > 0) + 1], c("50", "")[(ZZ[[k]][s, ind, h, 2] <= 2) + 1])
			zz.col[which(ZZ[[k]][s, ind, h, 1] == 0 & ZZ[[k]][s, ind, h, 2] == 1)] <- "#000000"
			if(length(which(ZZ[[k]][s, ind, h, 1] == 0 & ZZ[[k]][s, ind, h, 2] != 1)) > 0){
				stop("Zero mean and not no??")
			}
			
			points(rep(h, length(ind)), 
						 c(nFAZ:1)[ind], 
						 pch = zz.pch, 
						 bg = zz.bg, 
						 col = zz.col, 
						 cex = zz.cex, # Will be a number between 1 and 4
						 lwd = 0.5)
			
		} # end h
		
		axis(side = 1, at = c(1:10), labels = habNames4, las = 2)
		mtext(side = 3, line = 0.5, c("a) Sensitivity", "b) Exposure", "c) Threat")[k], adj = 0)
		if(k == 1) axis(side = 2, at = rev(1:nFAZ), fazNames, las = 1)
	
		} # end k
	
	mtext(side = 3, line = 2.5, speciesNames[s], font = 2, outer = TRUE)
	mtext(side = 2, outer = TRUE, "Freshwater Adaptive Zone (FAZ)", line = 5)
	dev.off()
} # end species

###############################################################################
# Plot total freshwater threat (summed across all indicators), status and
# vulnerability
###############################################################################

# pdf(file = "figures/Vulnerability.pdf", width = 3.2, height = 12, pointsize = 10)
# par(mfrow = c(3, 1), mar = c(0, 0, 3, 0), oma = c(10, 7, 4, 2))

pdf(file = "figures/Vulnerability.pdf", width = 6.3, height = 4, pointsize = 10)
par(mfrow = c(1,3), mar = c(0, 0, 0, 0), oma = c(8, 7, 3, 2))

for(k in 4:6){
	plot(c(1,nSpecies), c(1,nFAZ), "n", xlab = "", xaxt = "n", ylab = "", yaxt = "n", xlim = c(0.5, nSpecies + 0.5))
		if(k == 4) axis(side = 2, at = rev(1:nFAZ), fazNames, las = 1)
		for(i in 1:nFAZ){
			if(is_even(i)) polygon(x = c(0, 11, 11, 0), y = rep(c(i-0.5, i+0.5), each = 2), col = "#00000010", border = NA)
		}
		abline(v = seq(1.5, 4.5, 1), col = grey(0.8))
		for(s in 1:nSpecies){
			# Define cutoffs for point size
			cutoff.k <- cutoffs
			
			ind <- which(!is.na(ZZ[[k]][s, , 1]))
			
			zz.pch <- c(25, 24)[(ZZ[[k]][s, ind, 1] > 0) + 1]
			zz.pch[which(ZZ[[k]][s, ind, 2] > 3 | ZZ[[k]][s, ind, 1] == 0)] <- 21
			
			zz.cex <- (findInterval(abs(ZZ[[k]][s, ind, 1]), cutoff.k) + 1)/2
			zz.cex[which(ZZ[[k]][s, ind, 1] == 0)] <- 1
			
			zz.bg <- paste0(dumCol[c(2,1)][(ZZ[[k]][s, ind, 1] > 0) + 1], c("50", "")[(ZZ[[k]][s, ind, 2] == 1) + 1])
			zz.bg[which(ZZ[[k]][s, ind, 1] == 0)] <- NA
			
			zz.col <- paste0(dumCol[c(2,1)][(ZZ[[k]][s, ind, 1] > 0) + 1], c("50", "")[(ZZ[[k]][s, ind, 2] <= 2) + 1])
			zz.col[which(ZZ[[k]][s, ind, 1] == 0 & ZZ[[k]][s, ind, 2] == 1)] <- "#000000"
			if(length(which(ZZ[[k]][s, ind, 1] == 0 & ZZ[[k]][s, ind, 2] != 1)) > 0){
				stop("Zero mean and not no??")
			}
			
			points(rep(s, length(ind)), 
						 c(nFAZ:1)[ind], 
						 pch = zz.pch, 
						 bg = zz.bg, 
						 col = zz.col, 
						 cex = zz.cex, # Will be a number between 1 and 4
						 lwd = 0.5)
			
		}
		mtext(side = 3, line = 0.5, c("a) Total threat", "b) Status", "c) Vulnerability")[k-3], adj = 0)
		axis(side = 1, at = c(1:nSpecies), labels = speciesNames, las = 2)
	}
mtext(side = 2, outer = TRUE, "Freshwater Adaptive Zone (FAZ)", line = 5)

dev.off()

###############################################################################
# Maps
###############################################################################

# Load spatial packages
library(PBSmapping)
gshhg <- "~/Google Drive/Mapping/gshhg-bin-2.3.7/"
xlim <- c(-135, -118) + 360
ylim <- c(48, 58)

# five resolutions: crude(c), low(l), intermediate(i), high(h), and full(f).
res <- "i"
land <- importGSHHS(paste0(gshhg,"gshhs_", res, ".b"), xlim = xlim, ylim = ylim, maxLevel = 2, useWest = TRUE)
rivers <- importGSHHS(paste0(gshhg,"wdb_rivers_", res, ".b"), xlim = xlim, ylim = ylim, useWest = TRUE)
borders <- importGSHHS(paste0(gshhg,"wdb_borders_", res, ".b"), xlim = xlim, ylim = ylim, useWest = TRUE, maxLevel = 1)

faz <- as.PolySet(read.csv("data/ignore/PSF/fazLL_thinned_inDat.csv"), projection = "LL")

#------------------------------------------------------------------------------
# Pressure values
#------------------------------------------------------------------------------

# Mean pressure value across watersheds within each FAZ
meanExposure <- array(NA, dim = c(nHab, nFAZ), dimnames = list(habNames, fazNames))
for(h in 1:nHab){
	boop <- tapply(popDat[, which(names(popDat) == habNames[h])], popDat$FAZ, mean)
	meanExposure[h, ] <- boop[match(fazNames, names(boop))]
	}

habNames4 <- c("Agriculture", "Urban development", "Riparian disturbance", "Linear development", "Forestry roads", "Non-forestry roads", "Stream crossings", "Forest disturbance", "ECA", "Pine-beetle defoliation")

# Plot Map
quartz(width = 4*4/2, height = 3.7*3/2, pointsize = 10)
par(mfrow = c(3,4))
for(h in 1:nHab){
	expCol <- colorRampPalette(c("white", 2))(n = 100)
	expInterval <- seq(0, max(meanExposure[h, ]), length.out = 100)
	
	plotMap(land, xlim = c(-135, -118), ylim = c(48.17, 58),	col = "white", bg = grey(0.8), las = 1, border = grey(0.6), lwd = 0.6, xaxt = "n", yaxt = "n", xlab = "", ylab = "", plt = c(0, 1, 0, 1))
	
	for(i in 1:nFAZ){
		addPolys(faz[faz$FAZ_Acrony == fazNames[i], ], border = 1, col = expCol[findInterval(meanExposure[h, i], expInterval)], lwd = 0.6)
	}
	
	addLines(rivers, col = grey(0.6))
	addLines(borders)
	mtext(side = 3, adj = 0, paste("  ", habNames4[h]), cex = 0.8, font = 2, line = -3)
}

#------------------------------------------------------------------------------
# Overall threat
#------------------------------------------------------------------------------

vulInterval <- seq(min(c(ZZ$threatTotal[, , 1], ZZ$status[, , 1], ZZ$vulnerability[, , 1]), na.rm = TRUE), max(c(ZZ$threatTotal[, , 1], ZZ$status[, , 1], ZZ$vulnerability[, , 1]), na.rm = TRUE), length.out = 100)

vulCol <- c(
	colorRampPalette(c(2, "white"))(n = length(which(vulInterval < 0)) + 1)[1:length(which(vulInterval < 0))],
	colorRampPalette(c("white", 4))(n = length(which(vulInterval >= 0))))
	

for(s in 1:nSpecies){
	pdf(file = paste0("figures/ThreatStatusVulnerability_Maps_", speciesNames[s], ".pdf"), width = 7.5, height = 5, pointsize = 10)
	par(mfrow = c(1,3))
	for(k in 1:3){
		# Plot Map
		plotMap(land, xlim = c(-135, -118), ylim = c(48.17, 58),	col = "white", bg = grey(0.8), las = 1, border = grey(0.6), lwd = 0.6, xaxt = "n", yaxt = "n", xlab = "", ylab = "")
		
		for(i in 1:length(fazNames)){ # For each FAZ
			if(!is.na(ZZ[[k+3]][s, i, 1])){ # If no populations, then don't plot outline
				if(ZZ[[k+3]][s, i, 2] == 4){ # If no effect, then blank
					addPolys(faz[faz$FAZ_Acrony == fazNames[i], ], lwd = 0.6)
				} else {
					if(ZZ[[k+3]][s, i, 2] == 3){ #if weak effect, then striped
						addPolys(faz[faz$FAZ_Acrony == fazNames[i], ], border = 1, lwd = 0.6, col = vulCol[findInterval(ZZ[[k+3]][s, i, 1], vulInterval)], density = 80)
					} else { # If strong or moderate effect, then solid
						addPolys(faz[faz$FAZ_Acrony == fazNames[i], ], border = 1, lwd = 0.6, col = vulCol[findInterval(ZZ[[k+3]][s, i, 1], vulInterval)])
					}
				}
			}}
		
		addLines(rivers, col = grey(0.6))
		# addLines(borders)
		mtext(side = 3, line = 1, adj = 0, c("d) Total threat", "e) Status", "f) Vulnerability")[k])
		
		if(k == 2){
			leg.x <- seq(-154.58, -100.42, length.out = 100)
			for(j in 1:99) polygon(x = leg.x[c(j, j, j+1, j+1)], y = c(46.5, 47.5, 47.5, 46.5), col = vulCol[j], border = NA, xpd = NA)
			for(j in seq(1, 100, 10)){
				segments(x0 = leg.x[j], x1 = leg.x[j], y0 = 46.3, y1 = 47.5, xpd = NA)
				text(leg.x[j], 46, round(vulInterval[j], 3), xpd = NA, cex = 1.2)
			}
			text(mean(leg.x), 45.3, cex = 1.5, "Annual change in log spawners", xpd = NA)
		} # end legend
		} # end k
	
		# mtext(side = 3, outer = TRUE, speciesNames[s], font = 2, line = -12)
		dev.off()
		
	} # end species


#------------------------------------------------------------------------------
# Overall threat not log scale
#------------------------------------------------------------------------------

vulInterval <- seq(min(c(ZZ$threatTotal[, , 1], ZZ$status[, , 1], ZZ$vulnerability[, , 1]), na.rm = TRUE), max(c(ZZ$threatTotal[, , 1], ZZ$status[, , 1], ZZ$vulnerability[, , 1]), na.rm = TRUE), length.out = 100)

vulCol <- c(
	colorRampPalette(c("#dd4124", "white"))(n = length(which(vulInterval < 0)) + 1)[1:length(which(vulInterval < 0))],
	colorRampPalette(c("white", "#0f85a0"))(n = length(which(vulInterval >= 0))))


for(s in 1:nSpecies){
	pdf(file = paste0("figures/ThreatStatusVulnerability_Maps_", speciesNames[s], ".pdf"), width = 7.5, height = 5, pointsize = 10)
	par(mfrow = c(1,3))
	for(k in 1:3){
		# Plot Map
		plotMap(land, xlim = c(-135, -118), ylim = c(48.17, 58),	col = "white", bg = grey(0.8), las = 1, border = grey(0.6), lwd = 0.6, xaxt = "n", yaxt = "n", xlab = "", ylab = "")
		
		for(i in 1:length(fazNames)){ # For each FAZ
			if(!is.na(ZZ[[k+3]][s, i, 1])){ # If no populations, then don't plot outline
				if(ZZ[[k+3]][s, i, 2] == 4){ # If no effect, then blank
					addPolys(faz[faz$FAZ_Acrony == fazNames[i], ], lwd = 0.6)
				} else {
					if(ZZ[[k+3]][s, i, 2] == 3){ #if weak effect, then striped
						addPolys(faz[faz$FAZ_Acrony == fazNames[i], ], border = 1, lwd = 0.6, col = vulCol[findInterval(ZZ[[k+3]][s, i, 1], vulInterval)], density = 80)
					} else { # If strong or moderate effect, then solid
						addPolys(faz[faz$FAZ_Acrony == fazNames[i], ], border = 1, lwd = 0.6, col = vulCol[findInterval(ZZ[[k+3]][s, i, 1], vulInterval)])
					}
				}
			}}
		
		addLines(rivers, col = grey(0.6))
		# addLines(borders)
		mtext(side = 3, line = 1, adj = 0, c("d) Total threat", "e) Status", "f) Vulnerability")[k])
		
		if(k == 2){
			leg.x <- seq(-154.58, -100.42, length.out = 100)
			for(j in 1:99) polygon(x = leg.x[c(j, j, j+1, j+1)], y = c(46.5, 47.5, 47.5, 46.5), col = vulCol[j], border = NA, xpd = NA)
			for(j in seq(1, 100, 10)){
				segments(x0 = leg.x[j], x1 = leg.x[j], y0 = 46.3, y1 = 47.5, xpd = NA)
				text(leg.x[j], 46, round(exp(vulInterval[j]), 3), xpd = NA, cex = 1.2)
			}
			# text(mean(leg.x), 45.3, cex = 1.5, "Annual change in spawners (St/St-1)", xpd = NA)
		} # end legend
	} # end k
	
	# mtext(side = 3, outer = TRUE, speciesNames[s], font = 2, line = -12)
	dev.off()
	
} # end species



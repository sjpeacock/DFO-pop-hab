###############################################################################
###############################################################################
#
# Testing for broad-scale relationships between freshwater habitat pressure 
# indicators and Pacific salmon population trends
# Stephanie Peacock <speacock@psf.ca>
#
# This code loads to .rds file of MCMC output from model fits to produce a 
# number of plots that visualize parameter estimates and results.
# The assessment of vulnerability is separate in the vulnerability.R file.
#
###############################################################################
###############################################################################


# Source code that loads MCMC output and de-lists/creates index
# to easier access that output.

source("loadResults.R")

# fit = raw MCMC output from jags.fit()
# out = de-listed fit, with dimension (3, 50000, 333) = (chains, iterations, 
# parameters)

###############################################################################
# Supplement: Trace plots for 62 fixed parameters
###############################################################################
pdf(file = "figures/TracePlots.pdf", width = 7, height = 9, pointsize = 10)
png(filename = "figures/TracePlots%03d.png", width = 7*150, height = 9*150, res = 150)
# quartz(width = 7, height = 9, pointsize = 10)

par(mfrow = c(5, 2), mar = c(2,4,2,6))

#--------------------------------------------------------------------
# beta 0 Trace plots
#--------------------------------------------------------------------
# par(mfrow = c(1,1), mar = c(4,4,2,1))
plot(iter, fit[[1]][, outInd$beta0], "l", lty = 2, main = "beta0", ylim = range(out[,, outInd$beta0]), xaxt = "n", xlab = "", ylab = "", las = 1)
for(j in 2:length(fit)) lines(iter, fit[[j]][, outInd$beta0], col = j, lty = 2)
# abline(h = S[[1]][outInd$beta0, 1], lwd = 2)
u <- par('usr')
x <- seq(u[3], u[4], length.out = 200)
dPrior <- dnorm(x, mean = 0, sd = 3)
dPost <- density(out[, , outInd$beta0])
lines((u[2] + dPost$y/max(dPost$y)*max(iter)/4), dPost$x, xpd = NA)
lines((u[2] + dPrior/max(dPost$y)*max(iter)/4), x, xpd = NA, col = grey(0.8), lwd = 2)

text(u[2], u[3], paste("R = ", round(rHat[[1]][outInd$beta0], 3)), pos = 4, xpd = NA, adj = 0)
if(0 < u[4] & 0 > u[3]) segments(x0 = u[1], x1 = u[2] + max(iter)/4, y0 = 0, y1 = 0, xpd = NA)

#--------------------------------------------------------------------
# beta 1 Trace plots
#--------------------------------------------------------------------
for(h in 1:nHab){
	for(i in 1:nSpawn){
		cn.ih <- cn[outInd$beta1[i, h]]
		plot(iter, fit[[1]][, outInd$beta1[i, h]], "l", lty = 2, main = paste(cn.ih, ":", spawnNames[i], "*", habNames2[h]), ylim = range(out[,, outInd$beta1[i, h]]), xaxt = "n", xlab = "", ylab = "", las = 1)
		for(j in 2:length(fit)) lines(iter, fit[[j]][, outInd$beta1[i, h]], col = j, lty = 2)
		# abline(h = S[[1]][outInd$beta1[i, h], 1], lwd = 2)
		u <- par('usr')
		x <- seq(u[3], u[4], length.out = 200)
		dPrior <- dnorm(x, mean = 0, sd = 3)
		dPost <- density(out[, , outInd$beta1[i, h]])
		lines((u[2] + dPost$y/max(dPost$y)*max(iter)/4), dPost$x, xpd = NA, lwd = 1.5)
		lines((u[2] + dPrior/max(dPost$y)*max(iter)/4), x, xpd = NA, col = grey(0.8), lwd = 2)
		
		text(u[2], u[3], paste("R = ", round(rHat[[1]][outInd$beta1[i, h]], 3)), pos = 4, xpd = NA, adj = 0)
		if(0 < u[4] & 0 > u[3]) segments(x0 = u[1], x1 = u[2] + max(iter)/4, y0 = 0, y1 = 0, xpd = NA)
	}}

#--------------------------------------------------------------------
# phi Trace plots
#--------------------------------------------------------------------
for(h in 1:nHab){
	cn.h <- cn[outInd$phi[h]]
	plot(iter, fit[[1]][, outInd$phi[h]], "l", lty = 2, main = paste(cn.h, ":", habNames2[h]), ylim = range(out[,, outInd$phi[h]]), xaxt = "n", xlab = "", ylab = "", las = 1)
	for(j in 2:length(fit)) lines(iter, fit[[j]][, outInd$phi[h]], col = j, lty = 2)
	# abline(h = S[[1]][outInd$phi[h], 1], lwd = 2)
	u <- par('usr')
	x <- seq(u[3], u[4], length.out = 200)
	dPrior <- dnorm(x, mean = 0, sd = 3)
	dPost <- density(out[, , outInd$phi[h]])
	lines((u[2] + dPost$y/max(dPost$y)*max(iter)/4), dPost$x, xpd = NA, lwd = 1.5)
	lines((u[2] + dPrior/max(dPost$y)*max(iter)/4), x, xpd = NA, col = grey(0.8), lwd = 2)
	
	text(u[2], u[3], paste("R = ", round(rHat[[1]][outInd$phi[h]], 3)), pos = 4, xpd = NA, adj = 0)
	if(0 < u[4] & 0 > u[3]) segments(x0 = u[1], x1 = u[2] + max(iter)/4, y0 = 0, y1 = 0, xpd = NA)
}

#--------------------------------------------------------------------
# sigma Trace plots
#--------------------------------------------------------------------

# sigmaMAZ
plot(iter, fit[[1]][, outInd$sigmaMAZ], "l", lty = 2, main = "sigmaMAZ", ylim = range(out[,, outInd$sigmaMAZ]), xaxt = "n", xlab = "", ylab = "", las = 1)
for(j in 2:length(fit)) lines(iter, fit[[j]][, outInd$sigmaMAZ], col = j, lty = 2)
# abline(h = S[[1]][outInd$sigmaMAZ, 1], lwd = 2)
u <- par('usr')
x <- seq(u[3], u[4], length.out = 200)
dPrior <- dnorm(x, mean = 0, sd = 3)
dPost <- density(out[, , outInd$sigmaMAZ])
lines((u[2] + dPost$y/max(dPost$y)*max(iter)/4), dPost$x, xpd = NA)
lines((u[2] + dPrior/max(dPost$y)*max(iter)/4), x, xpd = NA, col = grey(0.8), lwd = 2)
text(u[2], u[3], paste("R = ", round(rHat[[1]][outInd$sigmaMAZ], 3)), pos = 4, xpd = NA, adj = 0)
if(0 < u[4] & 0 > u[3]) segments(x0 = u[1], x1 = u[2] + max(iter)/4, y0 = 0, y1 = 0, xpd = NA)

# sigmaFAZ ---
for(h in 1:nHab){
	cn.h <- cn[outInd$sigmaFAZ[h]]
	plot(iter, fit[[1]][, outInd$sigmaFAZ[h]], "l", lty = 2, main = paste(cn.h, ":", habNames2[h]), ylim = range(out[,, outInd$sigmaFAZ[h]]), xaxt = "n", xlab = "", ylab = "", las = 1)
	for(j in 2:length(fit)) lines(iter, fit[[j]][, outInd$sigmaFAZ[h]], col = j, lty = 2)
	# segments(x0 = u[1], x1 = u[2] + 5000, y0 = S[[1]][outInd$sigmaFAZ[h], 1], y1 = S[[1]][outInd$sigmaFAZ[h], 1], xpd = NA, lty = 2)
	u <- par('usr')
	x <- seq(u[3], u[4], length.out = 200)
	dPrior <- dnorm(x, mean = 0, sd = 3)
	dPost <- density(out[, , outInd$sigmaFAZ[h]])
	lines((u[2] + dPost$y/max(dPost$y)*max(iter)/4), dPost$x, xpd = NA, lwd = 1.5)
	lines((u[2] + dPrior/max(dPost$y)*max(iter)/4), x, xpd = NA, col = grey(0.8), lwd = 2)
	
	text(u[2], u[3], paste("R = ", round(rHat[[1]][outInd$sigmaFAZ[h]], 3)), pos = 4, xpd = NA, adj = 0)
	if(0 < u[4] & 0 > u[3]) segments(x0 = u[1], x1 = u[2] + max(iter)/4, y0 = 0, y1 = 0, xpd = NA)
}

# Overall sigma
plot(iter, fit[[1]][, outInd$sigma], "l", lty = 2, main = "sigmaMAZ", ylim = range(out[,, outInd$sigma]), xaxt = "n", xlab = "", ylab = "", las = 1)
for(j in 2:length(fit)) lines(iter, fit[[j]][, outInd$sigma], col = j, lty = 2)
# abline(h = S[[1]][outInd$sigma, 1], lwd = 2)
u <- par('usr')
x <- seq(u[3], u[4], length.out = 200)
dPrior <- dnorm(x, mean = 0, sd = 3)
dPost <- density(out[, , outInd$sigma])
lines((u[2] + dPost$y/max(dPost$y)*max(iter)/4), dPost$x, xpd = NA)
lines((u[2] + dPrior/max(dPost$y)*max(iter)/4), x, xpd = NA, col = grey(0.8), lwd = 2)
text(u[2], u[3], paste("R = ", round(rHat[[1]][outInd$sigma[h]], 3)), pos = 4, xpd = NA, adj = 0)
if(0 < u[4] & 0 > u[3]) segments(x0 = u[1], x1 = u[2] + max(iter)/4, y0 = 0, y1 = 0, xpd = NA)

dev.off()


###############################################################################
# Intercept
###############################################################################

mazNames2 <- c("West Haida Gwaii", "North Haida Gwaii", "Nass-Skeena Estuary", "Hecate Strait", "S. Fjords", "W. Van. Is.", "Georgia Strait")

#--------------------------------------------------------------------
# How many populations for each RE category?
#--------------------------------------------------------------------
# thetaMAZ[maz[i], rearEco[i]]
nIntercept <- array(NA, dim = c(nMAZ, nRear), dimnames = list(mazNames, rearNames))
for(i in 1:nMAZ){
	for(j in 1:nRear){
		nIntercept[i, j] <- length(which(popDat$rearEco == rearNames[j] & popDat$MAZ == mazNames[i]))
	}
}

#--------------------------------------------------------------------
# What are the densities of intercepts including RE for r/MAZ?
#--------------------------------------------------------------------
d.beta0 <- density(out[, , outInd$beta0])
# quartz(pointsize = 10, width=9, height = 4)
pdf("figures/intercept.pdf", width = 9, height = 4, pointsize = 10)
for(r in 1:nRear){
	
	plot(d.beta0$x, d.beta0$y, xlim = c(-0.12, 0.06), "l", lwd = 2, bty = "l", main = "", las = 1, xlab = expression(paste("Intercept (", beta[0] + theta[r/MAZ], ")")), col = grey(0.8), ylim = c(0, 100))
	
	abline(v = S[[1]][outInd$beta0, 1], lty = 2, col = grey(0.8))
	abline(v = 0)
	
	for(i in 1:nMAZ){ # For each MAZ
		if(nIntercept[i, r] > 0) lines(density(out[, , outInd$beta0] + out[, , outInd$thetaMAZ[i, r]] ), col = mazCol[i], lwd = 2, xpd = NA)
	}
	
	
	legend("topright", title = "MAZ", legend = paste0(mazNames, " (", nIntercept[r,], ")"), lwd = 1, col = mazCol, bty = "n")
	mtext(side = 3, line = 1, rearNames[r])
}
dev.off()

#--------------------------------------------------------------------
# Plot together
#--------------------------------------------------------------------
par(xpd = FALSE)
# # quartz(width = 5, height = 6, pointsize = 10)
# pdf(file = "figures/intercept_allMAZ.pdf", width = 5, height = 6, pointsize = 10)
# # png("figures/intercept_allMAZ.png", width = 750, height = 900, res = 150)
# 
# par(mar = c(4,2,1,1))
# plot(c(-0.12, 0.06), c(1, nRear + 1), "n", yaxs = "i", xlab = expression(paste("Intercept (", beta[0] + theta[r/MAZ], ")")), ylab = "", yaxt = "n")
# mtext(side = 2, line = 1, "Marginal posterior density")
# abline(v = S[[1]][outInd$beta0, 1], col = grey(0.8), xpd = FALSE)
# abline(v = 0)
# for(r in 1:nRear){
# 	lines(d.beta0$x, r + d.beta0$y/120, col = grey(0.8), lwd = 2)
# 	for(i in 1:nMAZ){
# 		d.i <- density(out[, , outInd$beta0] + out[, , outInd$thetaMAZ[i, r]])
# 		# polygon(x = c(d.i$x, rev(d.i$x)), y = c((r - 1) + d.i$y/100, rep(r, length(d.i$y))), border = NA, col = paste0(mazCol[i], 50))
# 		lines(d.i$x, r + d.i$y/120, col = mazCol[i], lwd = 1.5)
# 	} # end i
# 	text(par('usr')[1], r+0.8, pos = 4, rearNames[r], adj = 0)
# 	if(r > 1) abline(h = r)
# } # end r
# dev.off()

# With legend
rearNames2 <- c("Ocean-type Chinook", "Stream-type Chinook", "Chum", "Coho", "Pink", "Lake-type sockeye", "River-type sockeye")
pdf(file = "figures/intercept_allMAZ_legend.pdf", width = 7.5, height = 6, pointsize = 10)
# png("figures/intercept_allMAZ_legend.png", width = 1125, height = 900, res = 150, pointsize = 10)
# quartz(width = 7.5, height = 6, pointsize = 10)
par(mar = c(4,2,1,14))
plot(c(-0.12, 0.05), c(1, nRear + 1), "n", yaxs = "i", xlab = expression(paste("Intercept (", beta[0] + theta[r/MAZ], ")")), ylab = "", yaxt = "n")
mtext(side = 2, line = 1, "Marginal posterior density")
abline(v = S[[1]][outInd$beta0, 1], col = grey(0.8), xpd = FALSE)
abline(v = 0)
for(r in 1:nRear){
	lines(d.beta0$x, r + d.beta0$y/120, col = grey(0.8), lwd = 2)
	for(i in 1:nMAZ){
		d.i <- density(out[, , outInd$beta0] + out[, , outInd$thetaMAZ[i, r]])
		# polygon(x = c(d.i$x, rev(d.i$x)), y = c((r - 1) + d.i$y/100, rep(r, length(d.i$y))), border = NA, col = paste0(mazCol[i], 50))
		lines(d.i$x, r + d.i$y/120, col = mazCol[i], lwd = 1.5)
	} # end i
	text(par('usr')[1], r+0.8, pos = 4, rearNames2[r], adj = 0)
	if(r > 1) abline(h = r)
} # end r

legend(0.06, 8, col = c(grey(0.8), mazCol), lwd = c(2, rep(1.5, length(mazNames))), legend = c(expression(paste("Overall ", beta[0])), mazNames2), xpd = NA, border =NA, bty = "n")

dev.off()

###############################################################################
# Slopes
###############################################################################


#--------------------------------------------------------------------
# For each indicator, look at density of slopes for the different pressures
#--------------------------------------------------------------------

nSlope <- array(data = NA, dim = c(4, 10, length(fazNames)), dimnames = list(spawnNames, habNames, fazNames))
for(i in 1:4){
	for(h in 1:10){
		for(j in 1:length(fazNames)){
			nSlope[i, h, j] <- length(which(popDat$spawnEco == spawnNames[i] & popDat[, habNames[h]] > 0 & popDat$FAZ == fazNames[j]))
		}
	}
}

pdf("figures/slopes_noFAZ.pdf", width = 9, height = 4)
# quartz(pointsize = 10, width = 9, height = 4)
for(h in 1:10){
	xlims <- extendrange(c(out[, , outInd$beta1[1,h]], out[, , outInd$beta1[2,h]], out[, , outInd$beta1[3,h]], out[, , outInd$beta1[4,h]]), f = 0.3)
	plot(density(out[, , outInd$beta1[1,h]]), col = "white", bty = "l", main = "", las = 1, xlab = expression(paste("Slope (", beta[1], ")")), xlim = xlims)
	abline(v = 0)
	
	# Plot prior distribution
	u <- par('usr')
	xDum <- seq(u[1], u[2], length.out = 200)
	yDum <- dnorm(xDum, mean = 0, sd = 3)
	yDum <- yDum / max(yDum) * u[4]
	lines(xDum, yDum, lty = 2)
	
	for(i in 1:4){
		lines(density(out[, , outInd$beta1[i, h]]), lwd = 2, col = spawnCol[i], xpd = NA)
	}
	
	
	legend("topright", title = "Spawning ecotype", legend = paste0(spawnNames, " (", apply(nSlope[,h,], 1, sum), ")"), lwd = 1, col = spawnCol, bty = "n")
	mtext(side = 3, line = 1, habNames2[h])
	

	
}
dev.off()


#--------------------------------------------------------------------
# Plot beta1 together
#--------------------------------------------------------------------
habNames4 <- c("Agriculture","Urban development","Riparian disturbance","Linear development" , "Forestry roads","Non-forestry roads","Stream crossings","Forest disturbance" , "ECA", "Pine beetle")

png(filename = "figures/beta1.png", res = 150, width = 945, height = 1050)
# quartz(width = 6.3, height = 7, pointsize = 10)
par(mfrow = c(4, 3), mar = c(3, 1, 2, 1), oma = c(2, 3, 1, 1))

plot(1,1,"n", bty = "n", xaxt = "n", yaxt = "n", xlab = "", ylab = "")
plot(1,1,"n", bty = "n", xaxt = "n", yaxt = "n", xlab = "", ylab = "")
legend("center", col = spawnCol, lwd = 2, spawnNames, title = "Spawning ecotype", bty = "n", cex = 1.5)

for(h in 1:nHab){
	dens <- array(NA, dim = c(4, 512, 2))
	for(i in 1:4){
		dum <- density(out[, , outInd$beta1[i,h]])
		dens[i, , 1] <- dum$x
		dens[i, , 2] <- dum$y
	}

	plot(1, 1, "n", xlab = "", yaxt = "n", ylim = c(0, max(dens[, , 2])), ylab = "", xlim = extendrange(dens[, , 1], f = 0.2))
	abline(v = 0)

	for(i in 1:4){
		lines(dens[i, , 1], dens[i, , 2], lwd = 2, col = spawnCol[i], xpd = NA)
	}

	mtext(side = 3, adj = 0, line = 0.5, paste0(" ", letters[h], ") ", habNames4[h]))

	u <- par('usr')
	text(u[1], u[4] - (u[4] - u[3])*seq(0.8, 3.8, 1)*0.09, apply(nSlope[,h,], 1, sum), col = spawnCol, pos = 4, font = 2)
	
}
mtext(side = 1, outer=TRUE, expression(paste("Fixed slope (", beta[1], ") for modal stream order of 4 ", sep = "")), line = 0.5)
mtext(side = 2, line = 1, outer=TRUE, "Marginal posterior density")


dev.off()


###############################################################################
# Stream order: phi (LINEAR effect)
###############################################################################
 # Plot parameter values

colHab <- pnw_palette("Bay", n = nHab)
dPhi <- density(out[, , outInd$phi])

par(mfrow = c(1,1))
plot(dPhi$x, dPhi$y, "n", xlab = expression(paste("Effect of stream order on slope (", phi[j], ")")), ylab = "Marginal posterior density", las = 1, xlim = c(-0.01, 0.003))
abline(v = 0)
for(h in 1:nHab){
	
	lines(density(out[, , outInd$phi[h]]), col = colHab[h])
}

data.frame(habNames, round(S[[1]][outInd$phi,1], 7), round(S[[2]][outInd$phi,c(1,5)], 7))

streamOrder_dummy <- seq(-3, 6, 0.01)
predict_streamOrder <- array(NA, dim = c(length(streamOrder_dummy), nHab, nSpawn, 3), dimnames = list(NULL, habNames2, spawnNames, c("mean", "lwr", "upr")))
bootInd <- cbind(sample(c(1:numChains), size = 1000, replace = TRUE),
								 sample(c(1:numIter), size = 1000, replace = TRUE))

for(h in 1:nHab){
	for(i in 1:nSpawn){
		for(j in 1:length(streamOrder_dummy)){
			dum <- out[cbind(bootInd, outInd$beta1[i, h])] + out[cbind(bootInd, outInd$phi[h])] * streamOrder_dummy[j]
			predict_streamOrder[j, h, i, 1] <- mean(dum)
			predict_streamOrder[j, h, i, 2:3] <- quantile(dum, c(0.025, 0.975))
		}}}

spawnNames2 <- spawnNames
spawnNames2[spawnNames2 == 'Pink/Chum'] <- "PinkChum"
# pdf("figures/phiBySpawn.pdf", width = 9, height = 5, pointsize = 10)
# quartz(width = 9, height = 5, pointsize = 10)
for(i in 1:nSpawn){
	png(paste0("figures/phi_", spawnNames2[i], ".png"), width = 1500, height = 750, res = 150)
	
	par(mfrow = c(2,5), mar= c(1,3,3,1), oma= c(3,3,1,0))
	for(h in 1:JAGSdat$nHab){
		plot(streamOrder_dummy, predict_streamOrder[, h, 1, 1], "n",  ylim = range(c(S[[1]][outInd$beta1[, h], 1] + S[[1]][outInd$phi[h], 1] * 6, S[[1]][outInd$beta1[, h], 1] + S[[1]][outInd$phi[h], 1] * -3, predict_streamOrder[, h, ,])), xlab = "", ylab = "", las = 1, bty = "l", xaxt = "n")
		
		mtext(side = 3, line = 0.5, habNames2[h], cex = 0.8)
		abline(v = 0, lty = 3)
		abline(h = 0)
		axis(side = 1, at = seq(-2, 6, 2), labels = seq(2, 10, 2))
		
		# for(i in 1:length(spawnNames)){
		polygon(x = c(streamOrder_dummy, rev(streamOrder_dummy)), y = c(predict_streamOrder[, h,i, 2], rev(predict_streamOrder[, h, i, 3])), col = paste0(spawnCol[i], 20), border = NA)
		lines(streamOrder_dummy, S[[1]][outInd$beta1[i, h], 1] + S[[1]][outInd$phi[h], 1] * streamOrder_dummy, col = spawnCol[i], lwd = 2)
		# }
		par(new = TRUE)
		hist0 <- hist(popDat$StreamOrder[which(popDat$spawnEco == spawnNames[i] & (habPressures[, h] > 0))], breaks = seq(0.5, 10.5, 1), plot = FALSE)
		hist(popDat$StreamOrder[which(popDat$spawnEco == spawnNames[i] & (habPressures[, h] > 0))], breaks= seq(0.5, 10.5, 1), col = "#00000030", border = NA, main = "", xaxs = "i", ylim = c(0, max(hist0$counts)*4), xaxt = "n", yaxt = "n")
		
	}
	mtext(side = 1, outer=TRUE, "Stream order", line = 2)
	mtext(side = 2, outer = TRUE, expression(paste0("Slope (", beta[1] + phi %*% o, ")")), line = 1)
	mtext(side = 3, outer = TRUE, spawnNames[i], line = -1, col = spawnCol[i])
	dev.off()
}
# dev.off()
					 
###############################################################################
# Extra plots
###############################################################################

#--------------------------------------------------------------------
# Slope densities with FAZ
#--------------------------------------------------------------------

onlySig <- FALSE

pdf("figures/model10_slopes_inclFAZ.pdf", width = 9, height = 8)
for(h in 1:10){
	for(i in 1:4){
		par(mfrow = c(2,1), mar = c(5,5,2,1))

		xlims <- extendrange(c(out[, , outInd$beta1[i,h]] + out[, , outInd$phi[h]] * mean(popDat$StreamOrder)), f = 0.5)
		ylims <- c(0, max(extendrange(density(c(out[, , outInd$beta1[i,h]] + out[, , outInd$phi[h]] * mean(popDat$StreamOrder)))$y, f = 0.2)))
		
		plot(density(c(out[, , outInd$beta1[i,h]] + out[, , outInd$phi[h]] * mean(popDat$StreamOrder))), col = "white", bty = "l", main = "", las = 1, xlab = expression(paste("Slope (", beta[1] + phi[1] %*% o, ")")), xlim = xlims, ylim = ylims)
		abline(v = 0)
		mtext(side = 3, line = 1, paste0(habNames2[h], ": ", spawnNames[i]))
		
		lines(density(c(out[, , outInd$beta1[i, h]] + out[, , outInd$phi[h]] * mean(popDat$StreamOrder))), lwd = 2, col = grey(0.8), xpd = NA)
		
		neg <- 0
		for(j in 1:length(fazNames)){
			if(nSlope[i, h, j] > 0){
				d <- density(c(out[, , outInd$thetaFAZ[j, h]] + out[, , outInd$beta1[i, h]] + out[, , outInd$phi[h]] * mean(popDat$StreamOrder)))
				if(onlySig == TRUE){
					if(d$x[which(cumsum(d$y) / sum(d$y) > 0.975)[1]] < 0){
						neg <- c(neg, j)
						lines(d$x, d$y, xpd = NA, col = fCol[j])
					}
				} else{
					lines(d$x, d$y, xpd = NA, col = fCol[j])
				}
			}
		}
		neg <- neg[neg!=0]
		
		
		plot(1,1, "n", xaxt = "n", yaxt = "n", xlab = "", ylab = "", bty = "n")
		
		if(onlySig == TRUE){
			legend('center', title = "FAZ", ncol = 3, legend = paste0(fazNames[neg], " (", nSlope[i,h,neg], ")"), lwd = 1, col = fCol[neg], bty = "n", xpd = NA)
			
		} else {
			
			legend('center', title = "FAZ", ncol = 3, legend = paste0(fazNames, " (", nSlope[i,h,], ")"), lwd = 1, col = fCol, bty = "n", xpd = NA)
		}
		
	}
}
dev.off()

#--------------------------------------------------------------------
# What is the range of pressure values for South Thompson and others?
#--------------------------------------------------------------------

par(mfrow = c(1,1), mar = c(4,4,0,0))
plot(range(habPressures[which(popDat$spawnEco == spawnNames[i]), h]), c(0.5, 8.5), "n", ylab = "", xlab = habNames2[h], yaxt = "n")
q <- 0
Q <- 0
for(j in 1:22){
	if(nSlope[i, h, j] > 0){
		q <- q+1
		Q[q] <- j
		x <- habPressures[which(popDat$spawnEco == spawnNames[i] & popDat$FAZ == fazNames[j]), h]
		points(x, rep(q, length(x)), col = fCol[j], pch = c(1, 19)[as.numeric(x > 0) + 1])
		abline(h = q, col = fCol[j])
	}
}
axis(side = 2, at = c(1:8), labels = fazNames[Q], las = 1)



# #---- Coloured-by-FAZ  points ----#
# par(mfrow = c(1,1), mar = c(5,7,2,1), oma = c(0,0,0,0))
# for(i in 1:4){
# 
# 	plot(c(1,22), c(1,10), "n", xlim = c(0.5, 22.5), ylim= c(0.5, 10.5), xlab = "", ylab = "", xaxt = "n", yaxt = "n", xaxs = "i", yaxs = "i")
# 		axis(side = 1, at = c(1:22), fazNames, las = 2)
# 		axis(side = 2, at = c(1:10), rev(habNames2), las = 2)
# 		for(j in 1:22){
# 			abline(v = j, col = fCol[j])
# 			for(h in 1:10){
# 				if(nSlope[i, h, j] > 0){
# 					if(slopeAll[i, h, j] == 0){
# 					 points(j, (10 - h + 1), pch =21, bg = "white", col = fCol[j])
# 				} else if(slopeAll[i, h, j] < 0){
# 					points(j, (10 - h + 1), pch =25, bg = "white", col = NA, cex = 2, lwd = 1.5)
# 					points(j, (10 - h + 1), pch =25, bg = paste0(fCol[j], sprintf("%02.0f", round(min(99, abs(slopeAll[i, h, j]/0.2*100))))), col = fCol[j], cex = 2, lwd = 1.5)
# 				} else if(slopeAll[i, h, j] > 0){
# 					points(j, (10 - h + 1), pch =24, bg = "white", col = NA, cex = 2, lwd = 1.5)
# 					points(j, (10 - h + 1), pch =24, bg = paste0(fCol[j], sprintf("%02.0f", round(min(99, slopeAll[i, h, j]/0.2*100)))), col = fCol[j], cex = 2, lwd = 1.5)
# 				}
# 				}
# 
# 		} # end h
# 	} # end j
# 
# 	mtext(side = 3, line = 1, spawnNames[i])
# 
# 	
# }

###############################################################################
# Plotting exposure, sensitivity, threat based on current pressure values 
# Fig 4 and Appendix C
###############################################################################

regionNames <- sort(unique(popDat$region))
speciesNames <- sort(unique(popDat$SPECIES))
fazNames
nSpecies <- length(speciesNames)

n <- 10000

# Select MCMC draws from model output
indMod <- cbind(
	sample(1:numChains, size = n, replace = TRUE), 
	sample(1:numIter, size= n, replace = TRUE))

# Setup array to hold MCMC estimates of threat (exposure * sensitivity)
threat <- array(NA,
							dim = c(nFAZ, nSpecies, nHab, n),
							dimnames = list(fazNames, speciesNames, habNames, NULL))

# Run risk calculation
for(i in 1:nFAZ){
	for(s in 1:nSpecies){

		# Select MCMC draws from data
		ind.is <- which(popDat$SPECIES == speciesNames[s] & popDat$FAZ == fazNames[i])
		if(length(ind.is) > 0){
			indDat <- sample(ind.is, size = n, replace = TRUE)

			for(j in 1:n){

				beta1 <- numeric(10)
				for(h in 1:10){
					beta1[h] <- out[indMod[j, 1], indMod[j, 2], outInd$beta1[match(popDat$spawnEco[indDat[j]], spawnNames), h]] + out[indMod[j, 1], indMod[j, 2], outInd$phi[h]] * popDat$StreamOrder[indDat[j]] + out[indMod[j, 1], indMod[j, 2], outInd$thetaFAZ[match(popDat$FAZ[indDat[j]], fazNames), h]]
				}

				threat[i, s, , j] <- as.numeric(beta1 * habPressures[indDat[j], ])

			} # end j
		}
	}
}

# saveRDS(threat, file = "output/threat.rds")
# threat <- readRDS("output/threat.rds")

#------------------------------------------------------------------------------
# Number of (non-zero) data points in each category
#------------------------------------------------------------------------------
nSamp <- array(NA, 
							 dim = c(nFAZ, nSpecies, nHab), 
							 dimnames = list(fazNames, speciesNames, habNames))

for(r in 1:nFAZ){
	for(s in 1:length(speciesNames)){
		for(h in 1:10){
			nSamp[r, s, h] <- length(which(popDat$FAZ == fazNames[r] & popDat$SPECIES == speciesNames[s] & habPressures[, h] > 0))
		}}}

#------------------------------------------------------------------------------
# Summarize threats under current pressure values
#------------------------------------------------------------------------------
threatSummary <- array(NA, 
										 dim = c(nFAZ, nSpecies, nHab, 3), 
										 dimnames = list(fazNames, speciesNames, habNames, c("mean", "li", "ui")))

for(r in 1:length(fazNames)){
	for(s in 1:length(speciesNames)){
		for(h in 1:10){
			if(nSamp[r, s, h] > 0){
				threatSummary[r, s, h, 1] <- mean(threat[r, s, h, ])
				threatSummary[r, s, h, 2:3] <- quantile(threat[r, s, h, ], c(0.025,0.975))
			}
			}}}

#------------------------------------------------------------------------------
# Plot
#------------------------------------------------------------------------------
significantRisk <- data.frame(
	pos = NA,
	hab = NA,
	species = NA,
	FAZ = NA)
Q <- 0

quartz(width = 5.5, height = 3.5, pointsize = 10)
par(mfrow = c(1,1), mar = c(5,7,2,1), oma = c(0,0,0,0))

for(h in 1:nHab){
	for(s in 1:nSpecies){
		
		# plotCI(1:nFAZ, 
		# 			 riskSummary[, s, h, 1], 
		# 			 li = riskSummary[, s, h, 2],
		# 			 ui = riskSummary[, s, h, 3],
		# 			 gap = 0, pch = 21, pt.bg = "white", col = fazCol, las = 1, ylab = "", xlab = "", xaxt = "n", cex = 1.5, bty = "l")
		# 
		# abline(h = 0)
		# axis(side= 1, at = 1:nFAZ, labels = fazNames, las = 2)
		# mtext(side = 2, line = 4, "Sensitivity x Exposure")
		# 
		# Make solid point where there is a risk significantly different from zero
		z <- which(nSamp[, s, h] != 0)
		ns <- z[which(apply(risk[z, s, h, ], 1, quantile, c(0.025)) > 0 | apply(risk[z, s, h, ], 1, quantile, 0.975) < 0)]
		if(length(ns) > 0){
			print(paste0(habNames2[h], "-", h, ", ", speciesNames[s], "-", s, ": Sig Risk"))
			if(length(ns) > 1) y <- apply(risk[ns, s, h, ], 1, mean) else y <- mean(risk[ns, s, h, ])
			significantRisk[(Q + 1):(Q + length(ns)), ] <- cbind(as.numeric(c(y > 0)), rep(habNames[h], length(ns)), rep(speciesNames[s], length(ns)), fazNames[ns])
			# points(c(1:nFAZ)[ns], y, col = fazCol[ns], pch = 19, cex = 1.5)
			Q <- Q + length(ns)
		}
		
		# text(c(1:nFAZ), riskSummary[, s, h, 3], nSamp[, s, h], pos = 3, col = fazCol, xpd = NA)
		
		
	
		# mtext(side = 3, paste0(habNames2[h], ": ",  speciesNames[s]), line = 1, font = 2)
		
	}}
# dev.off()

write.csv(significantRisk, file = "output/significantRisk.csv")

#------------------------------------------------------------------------------
# Plot risks for a species across FAZ and indicators 
#------------------------------------------------------------------------------
zz <- seq(0, 0.05, 0.01)

quartz(width = 12, height = 5, pointsize = 10)
par(mfrow = c(1, 5), mar = c(0, 0, 0, 0), oma = c(10, 7, 2, 2))
for(s in 1:5){
	plot(c(1,nHab), c(1,nFAZ), "n", xlab = "", xaxt = "n", ylab = "", yaxt = "n", xlim = c(0.5, nHab + 0.5))
if(s == 1) axis(side = 2, at = rev(1:nFAZ), fazNames, las = 1)
for(i in 1:nFAZ){
	if(is_even(i)) polygon(x = c(0, 11, 11, 0), y = rep(c(i-0.5, i+0.5), each = 2), col = "#00000010", border = NA)
}
abline(v = seq(2.5, 8.5, 2), col = grey(0.8))
for(h in 1:10){
	# if(is_even(h)) polygon(x = c(h - 0.5, h + 0.5, h+0.5, h-0.5), y = rep(c(0, nFAZ+1), each = 2), col = "#00000010", border = NA)
	ind <- which(!is.na(riskCat[s, h, ]))
	risk[ind, s, h, 1]
	points(rep(h, length(ind)), c(nFAZ:1)[ind], pch = c(24, 24, 25, 25)[riskCat[s, h, ind]], bg = mapCol[riskCat[s, h, ind]], col = mapCol[c(1,1,4,4)][riskCat[s, h, ind]], cex = findInterval(abs(riskSummary[ind, s, h, 1]), zz)/2, lwd = 0.5) #
}
mtext(side = 3, speciesNames[s])
axis(side = 1, at = c(1:10), labels = habNames3, las = 2)
}
mtext(side = 2, outer = TRUE, "Freshwater Adaptive Zone (FAZ)", line = 5)

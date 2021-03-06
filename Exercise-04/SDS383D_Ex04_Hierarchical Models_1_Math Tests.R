#Stats Modeling 2
#Exercise 4
#Math test - Normal hierarchical model.

#Housekeeping
rm(list=ls())

#Set working directory
setwd('/Users/jennstarling/UTAustin/2017S_Stats Modeling 2/Exercise-04/')

#Read in data.
data = read.csv('Data/mathtest.csv')
attach(data)

#Read in functions.
source('RCode/SDS383D_Ex04_Hierarchical Models_FUNCTIONS_1_Math Test (Hier Model).R')

###		y_ij = score for jth student at school i.
###		theta_i = underlying mean test score for school i.

#================================================================
# Exploratory Analysis===========================================
#================================================================

#Group means for each different school.
mu = aggregate(data$mathscore, list(data$school), mean)
plot(mu$Group.1,mu$x)

#Check out the general ranges of values for the schools.
min = aggregate(data$mathscore, list(data$school), min)
max = aggregate(data$mathscore, list(data$school), max)
count = aggregate(data$mathscore, list(data$school), length)

#Display the min, max, mean and count for each school, sorted by counts.
df = cbind(mu,min,max,count)[,c(1,2,4,6,8)]
colnames(df) = c('school','mu','min','max','count')
df[order(df$count),]

#================================================================
# Hierarchical Model Fit ========================================
#================================================================

#	Model:
#	y_ij ~ N(theta_i, sigma^2)
#	theta_i ~ N(mu,tau^2 * sigma^2)

#	This is a normal-normal conjugate model:
#	theta_i | ybar_i, tau^2, sigma^2 ~ N(mu.new,var.new)
#		where 
#	precisions add, and
#	posterior mean is precision-weighted average of data and prior mean.

#	tau^2 acts as a signal-to-noise ratio.
y = data$mathscore
x = data$school

output = gibbs.mathtest(y,x,iter=21000,burn=1000,thin=2)

#================================================================
# Plot Shrinkage Coefficients ===================================
#================================================================

#Posterior mean for theta_i.
theta.post.mean = colMeans(output$theta)

#Calculate ybar_i, the sample school means.
ybar = aggregate(y, list(x), mean)$x	

#Sample sizes for each school.
ni = aggregate(y, list(x), length)$x	

#Calculate shrinkage coefficient for each school.
ki = (ybar - theta.post.mean) / ybar

#Plot shrinkage coefficient (in abs value) for each school as a function
#of that school's sample size.
shrink = cbind.data.frame(ni=ni,ki=abs(ki))		#Save variables in data frame.
shrink = shrink[order(shrink$ni),]				#Sort data.

pdf('/Users/jennstarling/UTAustin/2017S_Stats Modeling 2/Exercise-04/Figures/mathtest_kappa.pdf')
plot(shrink$ni,shrink$ki,col='blue',pch=19,
	xlab='school sample size',ylab='shrinkage coefficient',
	main='Shrinkage Coefficient as Function of School Sample Size')
dev.off()

#================================================================
# Plot Histograms of Posteriors =================================
#================================================================

pdf('/Users/jennstarling/UTAustin/2017S_Stats Modeling 2/Exercise-04/Figures/mathtest_hist.pdf')

par(mfrow=c(2,2))
hist(output$theta[,1],main='Histogram of Posterior theta_1',breaks=20)
hist(output$mu,main='Histogram of Posterior mu',breaks=20)
hist(output$sig.sq,main='Histogram of Posterior sig.sq',breaks=20)
hist(output$tau.sq,main='Histogram of Posterior tau.sq',breaks=20)

dev.off()

#================================================================
# Plot Traces of Gibbs Sampler ==================================
#================================================================

pdf('/Users/jennstarling/UTAustin/2017S_Stats Modeling 2/Exercise-04/Figures/mathtest_traces.pdf')

par(mfrow=c(2,2))
plot(output$theta[,1],main='Histogram of Posterior theta_1')
plot(output$mu,main='Histogram of Posterior mu')
plot(output$sig.sq,main='Histogram of Posterior sig.sq')
plot(output$tau.sq,main='Histogram of Posterior tau.sq')

dev.off()

#================================================================
# Plot Posterior Means vs Empirical Means =======================
#================================================================

plot(ybar,theta.post.mean,xlab='Empirical Avg by School',ylab='Posterior Mean by School')


rm(list = ls(all = TRUE))

#=============
# READ IN DATA
#=============
dat = read.table("Assignment_Athlete.txt", header = TRUE)
attach(dat)
Sex = as.factor(Sex)

#==========================
# EXPLORATORY DATA ANALYSIS  
#==========================
boxplot(LBM~Sex)
mean(LBM[Sex == 0]) # av for males
mean(LBM[Sex == 1]) # av for females

# scatterplots
plot(LBM~Ht, pch = 16, col = c('magenta','green')[as.numeric(Sex)], xlab="Height", ylab = "LBM", main = "Lean Body Mass vs Height")
legend('topleft', legend = c('male','female'), col = c('magenta','green'), pch = 16)
plot(LBM~Wt, pch = 16, col = c('magenta','green')[as.numeric(Sex)], xlab="Weight", ylab = "LBM", main = "Lean Body Mass vs Weight")
legend('topleft', legend = c('male','female'), col = c('magenta','green'), pch = 16)
plot(LBM~WCC, pch = 16, col = c('magenta','green')[as.numeric(Sex)], xlab="WCC", ylab = "LBM", main = "Lean Body Mass vs White Cell Count")
legend('topleft', legend = c('male','female'), col = c('magenta','green'), pch = 16) # no sig relationship 
plot(LBM~Hc, pch = 16, col = c('magenta','green')[as.numeric(Sex)], xlab="Hc", ylab = "LBM", main = "Lean Body Mass vs Hematocrit")
legend('topleft', legend = c('male','female'), col = c('magenta','green'), pch = 16) # borderline
plot(LBM~Hg, pch = 16, col = c('magenta','green')[as.numeric(Sex)], xlab="Hg", ylab = "LBM", main = "Lean Body Mass vs Hemoglobin")
legend('topleft', legend = c('male','female'), col = c('magenta','green'), pch = 16) # borderline

#====================
# CORRELATION MATRIX
#====================
cor(dat)

#=================
# HISTOGRAM OF LBM
#=================
hist(LBM, freq=FALSE, xlab="LBM", main="Histogram of Lean Body Mass (LBM)") # looks pretty normal?
m=mean(LBM)
s=sd(LBM)
x=seq(min(LBM), max(LBM), length=1000)
lines(x, dnorm(x,m,s), col="orange")
shapiro.test(LBM) 

#==========================================
# FITTING THE MODEL using F-tests and ANOVA
#==========================================
# model 0: 
mod0 = glm(LBM~WCC, data = dat, family=gaussian(link=identity))
summary(mod0)

# model 1:
mod1 = glm(LBM~Wt, data = dat, family=gaussian(link=identity))
summary(mod1) 

# model 2: 
mod2 = glm(LBM~Ht, data = dat, family=gaussian(link=identity))
summary(mod2) 

# model 3: 
mod3 = glm(LBM~Ht+Wt, data = dat, family=gaussian(link=identity))
summary(mod3)
anova(mod2, mod3, test = "F")
anova(mod1, mod3, test = "F")

# model 4: 
mod4 = glm(LBM~Wt+Ht+Ht*Wt, family=gaussian(link = identity))
summary(mod4) 
anova(mod3, mod4, test = "F")
anova(mod1, mod4, test = "F")
anova(mod2, mod4, test = "F")

# model 5: 
mod5 = glm(LBM~Hg, family=gaussian(link = identity))
summary(mod5)
anova(mod, mod, test = "F")

# model 6: 
mod6 = glm(LBM~Hc, family=gaussian(link = identity))
summary(mod6)

# model 7: 
mod7 = glm(LBM~Hg+Hc, family=gaussian(link = identity))
summary(mod7) 
anova(mod5, mod7, test = "F")

# model 8: 
mod8 = glm(LBM~Hg+Hc+Hc*Hg, family=gaussian(link = identity))
summary(mod8)
anova(mod7, mod8, test = "F")

# model 9: 
mod9 = glm(LBM~Hg+Wt, family=gaussian(link = identity))
summary(mod9)
anova(mod3, mod9, test = "F")
anova(mod4, mod9, test = "F")

# model 10: 
mod10 = glm(LBM~Hg+Wt+Wt*Hg, family=gaussian(link = identity))
summary(mod10)
anova(mod9, mod10, test = "F")

# model 11: 
mod11 = glm(LBM~Hg+Wt+Sex, family=gaussian(link = identity))
summary(mod11)
anova(mod9, mod1, test ="F")

# model 12: 
mod12 = glm(LBM~Hg+Wt+Sex+Sex*Wt, family=gaussian(link = identity))
summary(mod12)    
anova(mod11, mod12, test = "F")

# model 13: 
mod13 = glm(LBM~Hg+Wt+Sex+Sex*Wt+Sex*Hg, family=gaussian(link = identity))
summary(mod13)
anova(mod12, mod13, test = "F")

#==================
#RESIDUAL ANALYSIS:
#==================
require(car)
require(MASS)
par(mfrow = c(2,2))
plot(mod13)
shapiro.test(mod13$res)

#=============
# NEW DATA SET
#=============

dat2 = read.table("Assignment_Disease.txt", header = TRUE)
attach(dat2)
head(dat2)
mod0 = glm(DiseaseStatus~Measurement1 + Measurement2 + Measurement3 -1, data = dat2)
summary(mod0)

#====================================================
# FUNCTION TO GET COEFFICIENTS AND STD ERRORS IN GLM
#====================================================

glm_fit = function(Y, X, beta_start)
{
  W = matrix(0, length(Y), length(Y))
  
  for(i in 2:10)
  {
    eta       = X %*% beta_start
    mu        = exp(eta)/(1+exp(eta))
    var_Y     = mu*(1-mu)
    diag(W)   = mu*(1-mu)
    z         = eta + (Y[i]-mu)/(mu*(1-mu))
    J         = t(X) %*% W %*% X
    RHS       = t(X) %*% W %*% z 
    beta      = solve(J, RHS)
    std_er    = sqrt(diag(solve(J)))
    
  }
  return(list(betas=beta, std_error=std_er))
}

# set up variables for glm_fit:
Y = cbind(DiseaseStatus)
head(model.matrix(mod0))
X = cbind(Measurement1,Measurement2,Measurement3)
# beta_start = matrix(0, 0, 0) # zero vector as starting point 
beta_start = matrix(0, 3, 1)   # trial and error

#================================================
# CREATING TABLES FOR COEFFICIENTS AND STD ERRORS
#================================================

glm_fit(Y, X, beta_start)$betas
mod1 = glm_fit(Y, X, beta_start)

table = matrix(NA, nrow = 2, ncol = 3)
rownames(table) = c("Beta Estimates", "Standard Errors")
colnames(table) = c("Measurement 1", "Measurement 2", "Measurement 3")
table[1,1] = mod0$coefficients[1]
table[1,2] = mod0$coefficients[2]
table[1,3] = mod0$coefficients[3]
table[2,1] = coef(summary(mod0))[, "Std. Error"][1]
table[2,2] = coef(summary(mod0))[, "Std. Error"][2]
table[2,3] = coef(summary(mod0))[, "Std. Error"][3]

table2 = matrix(NA, nrow = 2, ncol = 3)
rownames(table2) = c("Beta Estimates", "Standard Errors")
colnames(table2) = c("Measurement 1", "Measurement 2", "Measurement 3")
table2[1,1] = mod1$betas[1]
table2[1,2] = mod1$betas[2]
table2[1,3] = mod1$betas[3]
table2[2,1] = mod1$std_error[1]
table2[2,2] = mod1$std_error[2]
table2[2,3] = mod1$std_error[3]

table 
table2

#=====================================
# MAKING PREDICTIONS ON A NEW DATA SET
#=====================================
dat3 = read.table("Assignment_Disease_2.txt", header = TRUE)
head(dat3)
attach(dat3)

predictions_glm = predict.glm(mod0, newdata=dat3, interval="prediction", 
                              level=0.95) 
predictions_glm = round(predictions_glm, 0)
head(predictions_glm)
pred = predictions_glm
write.table(pred,'Disease_Pred_CRRGAB003.txt', col.names = T, row.names = F) 
# txt file converted to csv file 
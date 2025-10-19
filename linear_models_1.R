#### Regressão linear

setwd('~/Documents/rib0109/linear_regression/')

rm(list = ls())
gc()

library(UsingR)
data("father.son")
head(father.son)

## Gráfico de dispersão
png('father_son_height.png', width = 8, height = 8, units = 'in', res = 300)
plot(father.son$sheight ~ father.son$fheight, pch = 19, col = 'navy', ylab = 'Altura do filho', xlab = 'Altura do pai')
dev.off()

## Verificar a distribuição dos dados
png('father_height_hist.png', width = 8, height = 8, units = 'in', res = 300)
hist(father.son$fheight, # histograma
     col="peachpuff",
     border="black",
     prob = TRUE, # mostrar densidade e não a frequencia
     xlab = "Altura",
     main = "Altura dos pais")
lines(density(father.son$fheight), # density plot
      lwd = 2, 
      col = "chocolate3")
dev.off()

png('son_height_hist.png', width = 8, height = 8, units = 'in', res = 300)
hist(father.son$sheight, # histograma
     col="peachpuff",
     border="black",
     prob = TRUE, # mostrar densidade e não a frequencia
     xlab = "Altura",
     main = "Altura dos filhos")
lines(density(father.son$sheight), # density plot
      lwd = 2, 
      col = "chocolate3")
dev.off()

cor(father.son$fheight, father.son$sheight)

cov(father.son$fheight, father.son$sheight) / (sd(father.son$fheight)*sd(father.son$sheight))

## Plot de correlações:
y <- rnorm(100, 10, 2)
random_float <- sample(seq(-1, 1, 0.01), 100, replace = TRUE)
X1 <- y - random_float
cor(X1, y)

random_float <- sample(seq(-1, 1, 0.01), 100, replace = TRUE)
X2 <- (y - random_float) * -1
cor(X2, y)

X3 <- rnorm(100, 11, 1.3)
cor(X3, y)

x_list <- list("X1"= X1, "X2"= X2, "X3"= X3)
plot_cols <- c('red', 'orange', 'navy')

png('correlations.png', width = 24, height = 8, units = 'in', res = 300)
par(mfrow= c(1,3))
c = 1
for (i in x_list) {
  plot(y ~ i, pch = 19, col = plot_cols[c], ylab = 'y', xlab = 'X')
  c = c+1
} 
dev.off()

png('correlations_w_lines.png', width = 24, height = 8, units = 'in', res = 300)
par(mfrow= c(1,3))
c = 1
for (i in x_list) {
  plot(y ~ i, pch = 19, col = 'gray', ylab = 'y', xlab = 'X')
  abline(lm(y ~ i), col = plot_cols[c], lwd = 2, lty = 2)
  c = c+1
} 
dev.off()

## Equação da reta

eq_reta <- function(x, a, b) {
  return(a*x + b)
}
a = 0.5
b = 3
x1 = 4
x2 = 7

y1 = eq_reta(x1, a, b)
y2 = eq_reta(x2, a, b)

X <- c(x1, x2)
y <- c(y1, y2)

png('reta_1.png', width = 8, height = 8, units = 'in', res = 300)
plot(y ~ X, type = 'l', lwd=2)
dev.off()

png('reta_2.png', width = 8, height = 8, units = 'in', res = 300)
plot(eq_reta(seq(-10, 10), a, b) ~ seq(-10, 10), type = 'l', lwd=2)
abline(h=3, lty=2, lwd=2, col='red')
abline(v=0, lty=2, lwd=2, col='red')
dev.off()

#### Exercício

plot(father.son$sheight ~ father.son$fheight, pch = 19, col = 'navy', ylab = 'Altura do filho', xlab = 'Altura do pai')


### Multivariada
pdata <- readRDS('Cancer_random_samples.rds')

# estagios <- c('I', 'IIa', 'IIb', 'IIIa', 'IIIb', 'IIIc', 'IV')
# grupos <- c('A', 'B')
# 
# pdata <- data.frame(grupo = sample(grupos, 500, replace = TRUE),
#                     idade = NA,
#                     estagio = sample(estagios, 500, replace = TRUE),
#                     gene = NA)
# 
# pdata$idade[pdata$grupo == 'A'] <- rnorm(table(pdata$grupo)[1], 67.7, 7)
# pdata$idade[pdata$grupo == 'B'] <- rnorm(table(pdata$grupo)[2], 57, 5.7)
# 
# pdata$gene[pdata$grupo == 'A'] <- rnorm(table(pdata$grupo)[1], 13, 2)
# pdata$gene[pdata$grupo == 'B'] <- rnorm(table(pdata$grupo)[2], 9.7, 3)
# 
# saveRDS(pdata, file = 'Cancer_random_samples.rds')
boxplot(gene ~ grupo, data = pdata)
t.test(gene ~ grupo, data = pdata)

boxplot(gene ~ estagio, data = pdata)
aov_estagio <- aov(gene ~ estagio, data = pdata)
summary(aov_estagio)

plot(gene ~ idade, data = pdata, pch = 19)
text(80, 5, paste0('r= ', as.character(round(cor(pdata$idade, pdata$gene),2))), cex=2)
abline(lm(gene ~ idade, data = pdata), lty=2, lwd=2, col = 'red')


modelo_multiplo <- lm(gene ~ idade + grupo, data = pdata)
summary(modelo_multiplo)


psych::describeBy(pdata$gene, pdata$grupo)
summary(lm(gene ~ grupo, data = pdata))
t.test(gene ~ grupo, data = pdata)

plot(c(1,2), rep(mean(pdata$gene[pdata$grupo == 'A']), 2), type = 'l', xlim=c(0,5), xaxt = 'n', ylim = c(6,16), col = 'red', lwd=3, ylab = 'Expressão do gene')
text(1.5, 14, paste0('média: ', as.character(round(mean(pdata$gene[pdata$grupo == 'A']),2))))
lines(c(3,4), rep(mean(pdata$gene[pdata$grupo == 'B']), 2), col= 'forestgreen', lwd = 3)
text(3.5, 10.37, paste0('média: ', as.character(round(mean(pdata$gene[pdata$grupo == 'B']),2))))
legend('topright', legend = c('Grupo A', 'Grupo B'), col = c('red', 'forestgreen'), pch=19)
points(1.5, mean(pdata$gene[pdata$grupo == 'A']), pch=19, cex=2, col='red')
points(3.5, mean(pdata$gene[pdata$grupo == 'B']), pch=19, cex=2, col='forestgreen')
lines(c(1.5, 3.5), c(mean(pdata$gene[pdata$grupo == 'A']), mean(pdata$gene[pdata$grupo == 'B'])), lty = 2, lwd=2)
text(2.5, 8, paste0('Diferença: ', round(mean(pdata$gene[pdata$grupo == 'A'])-mean(pdata$gene[pdata$grupo == 'B']),2)))
axis(1, at = c(1.5, 3.5),
     labels = c("Grupo A", "Grupo B"))

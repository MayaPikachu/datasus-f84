### Matrizes
rm(list =ls())
## Operações

# multiplicar por um escalar

X = matrix(c(2,4,3,6,4,7,8,1,9), 3)
X
a = 7
(a*X)/4

# transposta
X
t(X)

# Multiplicação de matrizes

set.seed(42)
X = matrix(sample(seq(1,9), 9, replace = TRUE), 3)
X
set.seed(41)
y = sample(seq(1,9), 3, replace = TRUE)
y
rbind(sum(X[1, ]*y), sum(X[2, ]*y), sum(X[3, ]*y))

#ou
X%*%y
#Ou

crossprod(t(X), matrix(y))
# Matriz inversa

solve(X)%*%X

# matriz identidade 
n = 3
diag(n)

# Solução da pagina 21

X <- matrix(c(1,3,2,1,-2,1,1,1,-1),3,3)
y <- matrix(c(6,2,1),3,1)
#
solve(X)%*%y


# modelo linear
rm(list =ls())

install.packages("UsingR")
library(UsingR)
data("father.son")

X = father.son$fheight #pai
y = father.son$sheight #filho

#altura filho usando altura do pai
X <- matrix(c(rep(1, nrow(father.son)), X), nrow(father.son))
head(X)
solve( t(X) %*% X ) %*% t(X) %*% y

summary(lm(y ~ X[,2]))$coefficients


## Exercício

install.packages("car")
library(car)
data(Davis)
head(Davis)

#outlier
which.max(Davis$weight)
Davis <- Davis[-12, ]
plot(Davis$weight ~ Davis$height)

#peso por altura

peso = matrix(Davis$weight)
altura = matrix(Davis$height)

#meu jeito
m.altura = matrix(c(rep(1, nrow(altura)), altura),nrow(altura))
solve(t(m.altura) %*% m.altura) %*% t(m.altura) %*% peso
modelo = ?lm(peso ~ altura)
summary(modelo)$coefficients

plot(Davis$weight ~ Davis$height)
abline(modelo, col = "red")

# e divisao de sexo
boxplot(Davis$height ~ Davis$sex)
boxplot(Davis$weight ~ Davis$sex)

#versão do professor
rm(list =ls())

Davis <- Davis[-12, ]
plot(Davis$weight ~ Davis$height)
y = Davis$weight

x <- Davis[,c(1,3)]

x$sex <- as.character(x$sex)
x$sex[x$sex == 'F'] <- 0
x$sex[x$sex == 'M'] <- 1
x$sex <- as.numeric(x$sex)

x = as.matrix(cbind(1,x))
solve( t(x) %*% x) %*% t(x) %*% y

wmodel = lm(weight ~ sex + height, data = Davis)
summary(wmodel)$coefficients

plot(Davis$weight ~ Davis$height, pch=19, col = c("pink", "blue")[Davis$sex])#ta subestimando o homem

model.matrix()

wmodel2 = lm(weight ~ sex * height, data = Davis)

summary(wmodel2)$coefficients

#### Aplicação em Bioinformática

rm(list =ls())

load('Breast_cancer_example.RData')
ls()
dim(exp)#expressão génica, 
dim(fdata)
dim(pdata)

#cada coluna = amostra (paciente, animal, cultura), aqui=cancer de mama
#coluna amostra, linha = gene
exp[1:4, 1:4]

#rownames  = rownames(exp)
fdata[1:4, 1:4]
fdata[1,]
fdata[which(fdata$Gene.symbol=="TP53"),]
#

all(rownames(exp) == rownames(fdata))
exp[which(fdata$Gene.symbol=="TP53"),]

# = numcol(exp)
dim(pdata)
head(pdata)
all(colnames(exp) == rownames(pdata))

table(pdata$grade)
table(pdata$death)
table(pdata$death)
#quais a expressão do gene de quem morreu e não morreu

y <- exp[which(fdata$Gene.symbol=="TP53"),]
boxplot(y)

boxplot(y ~ pdata$death)
pdata$death = as.factor(pdata$death)
boxplot(y ~ pdata$grade)


#modelo linear
summary(lm(y ~ pdata$death + pdata$grade))$coefficients
model = lm(y ~ pdata$death + pdata$grade)

#tumor grau 3 -> expressão menor
#tumor grau 2 -> significante

# e os outros?
pvals = c()
for (ron in 1:nrow(exp)) {
  gene = exp[ron,]
  model = lm(gene ~ pdata$death + pdata$grade)
  pval = summary(model)$coefficients[2,4]
  pvals = c(pvals, pval)
  print(c(ron, pval))
}

which(pvals < 0.05)
hist(pvals)
length(which(pvals<0.05))/nrow(exp)

length(which(pvals<0.05/nrow(exp)))/nrow(exp)
nrow(exp)*5/100

which(pvals < 0.05/nrow(exp))

par(mfrow = c(2,2))
for (idx in which(pvals < 0.05/nrow(exp))) {
  boxplot(exp[idx, ] ~ pdata$death)
}

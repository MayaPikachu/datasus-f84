### Matrizes

setwd('')


## Operações

# multiplicar por um escalar

X = matrix(c(2,4,3,6,4,7,8,1,9), 3)
X
a = 3
a*X

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

X%*%y

# Matriz inversa

solve(X)

# matriz identidade 
n = 3
diag(n)

# Solução da 

X <- matrix(c(1,3,2,1,-2,1,1,1,-1),3,3)
y <- matrix(c(6,2,1),3,1)
solve(X)%*%y


# modelo linear

library(UsingR)
data("father.son")

X = father.son$fheight
y = father.son$sheight

X <- matrix(c(rep(1, nrow(father.son)), X), nrow(father.son))
head(X)
solve( t(X) %*% X ) %*% t(X) %*% y

summary(lm(y ~ X[,2]))$coefficients


## Exercício

# install.packages("car")
library(car)
data(Davis)
head(Davis)
which.max(Davis$weight)
Davis <- Davis[-12, ]
plot(Davis$weight ~ Davis$height)


#### Aplicação em Bioinformática

load('Breast_cancer_example.RData')

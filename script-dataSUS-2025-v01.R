# rvencio 2025-10-09
# dataSUS fenix return

	library(MASS)


	D = read.delim("dados_municipios.csv", sep=",", quote="\"", header=T)
	
	df = D[,3:5]
	colnames(df)[2] = "x"
	colnames(df)[3] = "y"
	k = is.na(df$x)
	df = df[!k,]
	df$x = log10(df$x)
	df$y = log10(df$y)


	k <- kde2d(df$x, df$y, n=100)


	plot(df$x, df$y, xlab="log10(população)", ylab="log10(atendimentos)", col="blue", pch="+", xlim=c(0,7), ylim=c(0,7))
	contour( k$x, k$y, k$z , lwd=3, add=TRUE)

#	linepoints = identify(df$x, df$y, labels=df$nome)

#> linepoints
#[1]  161 1354
#> 
#> df[linepoints, ]
#           nome        x        y
#161   Anajatuba 4.419129 2.212188
#1354 SÃ£o Paulo 7.075728 5.627125

	a = ( 5.627125 - 2.212188 ) / ( 7.075728 - 4.419129)
	b = 5.6271258 - a * 7.075728
	abline(b, a, lwd=2)	


	x11()
	xx = seq(0, 100, len=100)
	plot(xx, 10^b * xx^a)
	# quase uma reta, só no comecinho que é meio curvo.


	plot( log10(D$populacao) ,   log10(D$atendimentos/D$populacao) )
	abline( h = median(log10(D$atendimentos/D$populacao), na.rm = T) , col="red")
	
	# pra clicar no grafico e mostrar quem é.
	identify( log10(D$populacao) , log10(D$atendimentos/D$populacao) , labels=D$nome )

	
	
	

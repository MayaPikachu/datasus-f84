import pandas as pd
import os

pasta = r"D:\DATASUS\CSV"
saida = os.path.join(pasta, "PS_2013_2024.csv")

ufs = [
    "AC","AL","AM","AP","BA","CE","DF","ES","GO","MA","MG","MS","MT",
    "PA","PB","PE","PI","PR","RJ","RN","RO","RR","RS","SC","SE","SP","TO"
]

primeiro = True
for uf in ufs:
    for ano in range(13, 25):
        for mes in range(1, 13):
            nome_arquivo = f"PS{uf}{ano:02d}{mes:02d}.csv"
            caminho = os.path.join(pasta, nome_arquivo)

            if os.path.exists(caminho):
                print(f"Processando {nome_arquivo} ...")
                df = pd.read_csv(caminho, dtype=str, sep=",", encoding="utf-8")

                # padroniza para ter sempre as mesmas colunas
                if primeiro:
                    colunas_base = df.columns
                else:
                    df = df.reindex(columns=colunas_base)

                # adiciona colunas auxiliares
                df["ano"] = f"20{ano:02d}"
                df["mes"] = f"{mes:02d}"
                df["uf"] = f"{uf}"

                # salva
                df.to_csv(
                    saida,
                    mode="a",
                    index=False,
                    header=primeiro,
                    encoding="utf-8"
                )
                primeiro = False

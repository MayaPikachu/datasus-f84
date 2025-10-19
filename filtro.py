import pandas as pd

# Ler o CSV original
df = pd.read_csv("D:/DATASUS/F84_atendimentos_final.csv", encoding="latin1")

# Lista de colunas que aparecem no código
colunas_usadas = [
    "CNS_PAC", "IDADEPAC", "SEXOPAC", "RACACOR", "UFMUN", "MUNPAC", "uf", 
    "SIT_RUA", "TP_DROGA", "PA_PROC_ID", "CIDPRI", "CIDASSOC",
    "DT_INICIO", "DT_FIM", "ano", "pop", "nome"
]

# Filtra apenas as colunas usadas
df_filtrado = df[[col for col in colunas_usadas if col in df.columns]]

# Salvar o DataFrame filtrado
df_filtrado.to_csv("D:/DATASUS/F84_atendimentos_enriched.csv", index=False, encoding="latin1")

print("Colunas mantidas:")
print(df_filtrado.columns.tolist()) 
import pandas as pd

df1 = pd.read_excel("d:/DATASUS/RELATORIO_DTB_BRASIL_2024_MUNICIPIOS.xls")

df2 = pd.read_excel("D:/DATASUS/estimativa_dou_2025.xls", sheet_name=1)

print(df1.columns)

print(df2["COD. MUNIC"])
print(df2["COD. UF"])

# Para a coluna UF
df2['COD. UF'] = df2['COD. UF'].fillna(0).astype(int).astype(str).str.zfill(2)

# Para a coluna COD. MUNIC
df2['COD. MUNIC'] = df2['COD. MUNIC'].fillna(0).astype(int).astype(str).str.zfill(5)

df2['codigo'] = df2['COD. UF'] + df2['COD. MUNIC']

df2["codigo"] = df2["codigo"].astype(int)

print(df2["codigo"])

df_final = pd.merge(df1, df2, left_on= "codigo_completo", right_on= "codigo", how = "left")

print(df_final.columns)

df_final = df_final[["codigo", "Nome_Município", "Município", "POPULAÇÃO ESTIMADA"]]

df_final = df_final.rename(columns = {
    "POPULAÇÃO ESTIMADA": "pop",
    "Nome_Município": "nome"
})


print(df_final['codigo'].duplicated().sum())


df_final.to_csv("D:/DATASUS/municípios.csv")
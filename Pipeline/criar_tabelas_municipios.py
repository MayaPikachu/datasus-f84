import pandas as pd
import dask.dataframe as dd

municipios = dd.read_csv(
    "D:/DATASUS/municípios.csv",
    sep=",",
    encoding="utf-8",
    dtype={"codigo": "int64"}
)

df = dd.read_parquet("D:/DATASUS/F84_atendimentos", engine="pyarrow")
pac = dd.read_parquet("D:/DATASUS/F84_pac", engine="pyarrow")

municipios['codigo'] = municipios['codigo'].astype(str).str[:-1].astype(int)

# Mapeamento RACACOR
mapping_raca = {
    "01": "Branca",
    "02": "Preta",
    "03": "Parda",
    "04": "Amarela",
    "05": "Indígena",
    "99": "Outra"
}

print(df["RACACOR"].unique().compute())

for df_temp in [df, pac]:
    df_temp["RACACOR"] = (
        df_temp["RACACOR"]
        .astype(str)    # Garante que é string
        .str.strip()    # Remove espaços (se houver)
        # ⚠️ CORREÇÃO CRÍTICA: Garante formato '0X' para mapear corretamente
        .str.zfill(2) 
        .map(mapping_raca, meta=('RACACOR', 'object'))
        # Garante que qualquer valor que ainda seja NaN (ex: string vazia) vire "Não Informado"
        .fillna("Não Informado") 
    )

df['UFMUN'] = df['UFMUN'].astype('int64')
pac['UFMUN'] = pac['UFMUN'].astype('int64')
df['PA_PROC_ID'] = df['PA_PROC_ID'].astype('int64')
pac['PA_PROC_ID'] = pac['PA_PROC_ID'].astype('int64')

# Merge usando código correto do município
atendimentos_municipio = df.merge(municipios, left_on='UFMUN', right_on='codigo', how='left')
pac_municipio = pac.merge(municipios, left_on='UFMUN', right_on='codigo', how='left')

colunas_usadas = [
    "CNS_PAC", "IDADEPAC", "SEXOPAC", "RACACOR", "UFMUN", "MUNPAC",
    "uf", "SIT_RUA", "TP_DROGA", "PA_PROC_ID", "CIDPRI", "CIDASSOC",
    "DT_INICIO", "DT_FIM", "ano", "pop", "nome"
]

atendimentos_municipio = atendimentos_municipio[colunas_usadas]
pac_municipio = pac_municipio[colunas_usadas]

(atendimentos_municipio
    .to_parquet(
        "D:/DATASUS/F84_atendimentos_dashboard_teste",
        write_index=False,
        engine="pyarrow",
        overwrite=True
    )
)
(pac_municipio
    .to_parquet(
        "D:/DATASUS/F84_pac_dashboard_teste",
        write_index=False,
        engine="pyarrow",
        overwrite=True
    )
)
print("Arquivos gerados com sucesso!")

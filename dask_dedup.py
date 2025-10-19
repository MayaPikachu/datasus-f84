import dask.dataframe as dd


df = dd.read_csv(
    "D:/DATASUS/CSV/PS_2013_2024.csv",
    encoding="latin1",
    dtype=str,          
    assume_missing=True 
)


df_dedup = df.drop_duplicates(subset=["CNS_PAC"])


df_dedup.to_parquet(
    "D:/DATASUS/DEDUP/PS_2013_2024_dedup.parquet",
    engine="pyarrow",
    overwrite=True
)


cids_alvo = ["F84", "F840", "F841"]


df_filtrado = df[
    df["CIDPRI"].isin(cids_alvo) | df["CIDASSOC"].isin(cids_alvo)
]

df_filtrado.to_csv(
    "D:/DATASUS/F84_atendimentos.csv",
    single_file=True,
    index=False
)


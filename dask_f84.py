import dask.dataframe as dd


df = dd.read_parquet("D:/DATASUS/DEDUP/PS_2013_2024_dedup.parquet", engine="pyarrow")


cids_alvo = ["F84", "F840", "F841"]


df_filtrado = df[
    df["CIDPRI"].isin(cids_alvo) | df["CIDASSOC"].isin(cids_alvo)
]

df_filtrado.to_csv(
    "D:/DATASUS/DEDUP/F84_pac.csv",
    single_file=True,
    index=False
)

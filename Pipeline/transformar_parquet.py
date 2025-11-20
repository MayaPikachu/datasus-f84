import dask.dataframe as dd

# Ler CSV, forçando todas as colunas como string
df = dd.read_csv(
    "D:/DATASUS/F84_pac.csv",
    dtype=str,         # tudo como string
    assume_missing=True  # permite valores ausentes
)

# Salvar em Parquet (particionado por padrão)
df.to_parquet(
    "D:/DATASUS/F84_pac",
    engine="pyarrow",
    write_index=False,
    overwrite=True
)

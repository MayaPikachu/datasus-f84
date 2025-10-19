import dask.dataframe as dd

# Lê o parquet com várias partes
df = dd.read_parquet("D:/DATASUS/DEDUP/PS_2013_2024_dedup.parquet")

# Salva como um único CSV
df.to_csv(
    "D:/DATASUS/DEDUP/PS_2013_2024_dedup.csv",
    index=False,
    single_file=True
)

print("✅ Arquivo único CSV criado!")

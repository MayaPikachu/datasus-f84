import dask.dataframe as dd

df = dd.read_csv(
    "D:/DATASUS/F84_pac.csv",
    dtype=str,         
    assume_missing=True 
)

df.to_parquet(
    "D:/DATASUS/F84_pac",
    engine="pyarrow",
    write_index=False,
    overwrite=True
)

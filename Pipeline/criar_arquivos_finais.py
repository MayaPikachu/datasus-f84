import pandas as pd
import pyarrow.dataset as ds

# Caminho do diretório parquet gerado pelo Dask
at = ds.dataset("D:/DATASUS/F84_atendimentos_dashboard", format="parquet")
pac = ds.dataset("D:/DATASUS/F84_pac_dashboard", format="parquet")


# Lê todas as partições do diretório e carrega em memória como pandas
at = at.to_table().to_pandas()
pac = pac.to_table().to_pandas()


# Salva como arquivo único Parquet
at.to_parquet(
    "D:/DATASUS/F84_atendimentos_dashboard.parquet",
    index=False,
    engine="pyarrow"
)

pac.to_parquet(
    "D:/DATASUS/F84_pac_dashboard.parquet",
    index=False,
    engine="pyarrow"
)
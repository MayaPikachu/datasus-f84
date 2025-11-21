import pandas as pd
import pyarrow.dataset as ds

at = ds.dataset("D:/DATASUS/F84_atendimentos_dashboard", format="parquet")
pac = ds.dataset("D:/DATASUS/F84_pac_dashboard", format="parquet")


at = at.to_table().to_pandas()
pac = pac.to_table().to_pandas()


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
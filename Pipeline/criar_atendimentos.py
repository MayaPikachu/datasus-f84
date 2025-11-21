import dask.dataframe as dd
import dask.config
import os
import pandas as pd

dask.config.set({"temporary-directory": "D:/dask_temp"})

os.makedirs("D:/DATASUS/F84_atendimentos/", exist_ok=True)

df = dd.read_csv(
    "D:/DATASUS/CSV/PS_2013_2024.csv",
    encoding="latin1",
    dtype=str,
    assume_missing=True
)

cids_alvo = ["F84", "F840", "F841"]
df_filtrado = df[
    df["CIDPRI"].isin(cids_alvo) | df["CIDASSOC"].isin(cids_alvo)
]

df_filtrado = df_filtrado.assign(
    nasc_ano = df_filtrado["DTNASC"].str.slice(0, 4).astype("int64"),
    nasc_mes = df_filtrado["DTNASC"].str.slice(4, 6).astype("int64"),
    nasc_dia = df_filtrado["DTNASC"].str.slice(6, 8).astype("int64"),
)

df_filtrado = df_filtrado.assign(
    atend_ano = df_filtrado["DT_ATEND"].str.slice(0, 4).astype("int64"),
    atend_mes = df_filtrado["DT_ATEND"].str.slice(4, 6).astype("int64"),
)

df_filtrado = df_filtrado.assign(
    idade = (
        df_filtrado["atend_ano"] - df_filtrado["nasc_ano"]
        - (
            (df_filtrado["atend_mes"] < df_filtrado["nasc_mes"])
            | (df_filtrado["atend_mes"] == df_filtrado["nasc_mes"])
        ).astype("int64")
    )
)

df_filtrado.to_parquet(
    "D:/DATASUS/F84_atendimentos",
    engine="pyarrow",
    overwrite=True
)

df_pd = df_filtrado.compute() 

df_pd.to_csv(
    "D:/DATASUS/F84_atendimentos.csv",
    index=False,
    encoding="latin1"
)

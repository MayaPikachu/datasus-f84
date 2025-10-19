import pandas as pd
import binascii

file_path = r"D:\DATASUS\CSV\PSSP2404.csv"

# leitura correta
df = pd.read_csv(file_path, sep=",", encoding="utf-8", dtype=str)

print(df.columns)

#if "CNS_PAC" in df.columns:
#    df["CNS_HEX"] = df["CNS_PAC"].apply(
#        lambda x: binascii.hexlify(x.encode()).decode() if isinstance(x, str) else str(x)
#    )

# ordenar para manter o registro mais recente de cada CNS
#df = df.sort_values(["CNS_PAC", "ano", "mes"], ascending=[True, False, False])

# deduplicar
df_unique = df.drop_duplicates(subset=["CNS_PAC"], keep="first")

# salvar
df_unique.to_csv(r"D:\DATASUS\PSSP2404_dedup_2.csv", index=False, sep=",", encoding="utf-8")

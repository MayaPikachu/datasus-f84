import pandas as pd

chunks = pd.read_csv("D:/DATASUS/F84_atendimentos.csv")

seen = {}

chunks["ano_mes"] = chunks["ano"].astype(int) * 100 + chunks["mes"].astype(int)
    
for row in chunks.itertuples():
    cns = row.CNS_PAC
    if cns not in seen or row.ano_mes > seen[cns]["ano_mes"]:
        seen[cns] = row._asdict()

df_final = pd.DataFrame(seen.values())
df_final.to_csv("D:/DATASUS/F84_pac.csv", index=False)
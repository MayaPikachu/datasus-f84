import pandas as pd

file_path = r"D:\DATASUS\CSV\PS_2013_2024.csv"
chunksize = 10**6  # 1 milhão de linhas por vez

cid_considerada = ["F84", "F840", "F841"]

# Acumuladores
total_registros = 0
total_f84 = 0
sexo_counts = pd.Series(dtype=int)
idade_stats = []
dt_inicio_counts = pd.Series(dtype=int)
dt_fim_counts = pd.Series(dtype=int)
cid_assoc_freq = pd.Series(dtype=int)
cid_prim_freq = pd.Series(dtype=int)

for chunk in pd.read_csv(file_path, sep=",", encoding="latin1", chunksize=chunksize, low_memory=False):
    total_registros += len(chunk)

    
    df_f84 = chunk[
        (chunk["CIDPRI"].isin(cid_considerada)) |
        (chunk["CIDASSOC"].isin(cid_considerada))
    ]

    total_f84 += len(df_f84)

    #Sexo
    sexo_counts = sexo_counts.add(df_f84["SEXOPAC"].value_counts(), fill_value=0)

    #Idade
    idade_stats.extend(df_f84["IDADEPAC"].dropna().tolist())

    #Início e fim
    dt_inicio_counts = dt_inicio_counts.add(df_f84["DT_INICIO"].astype(str).str[:4].value_counts(), fill_value=0)
    dt_fim_counts = dt_fim_counts.add(df_f84["DT_FIM"].astype(str).str[:4].value_counts(), fill_value=0)

    # CID secundária quando F84 é primária
    df_assoc = df_f84[df_f84["CIDPRI"].str.startswith("F84", na=False)]
    cid_assoc_freq = cid_assoc_freq.add(df_assoc["CIDASSOC"].value_counts(), fill_value=0)

    # CID primária quando F84 é secundária
    df_prim = df_f84[df_f84["CIDASSOC"].str.startswith("F84", na=False)]
    cid_prim_freq = cid_prim_freq.add(df_prim["CIDPRI"].value_counts(), fill_value=0)


print("N registros:", total_registros)
print("Total de pacientes com F84:", total_f84)

print("\nDistribuição por sexo:")
print(sexo_counts.astype(int))

print("\nEstatísticas de idade:")
print(pd.Series(idade_stats).describe())

print("\nDistribuição por ano de início:")
print(dt_inicio_counts.sort_index().astype(int))

print("\nDistribuição por ano de fim:")
print(dt_fim_counts.sort_index().astype(int))

print("\nCIDs secundárias mais comuns quando F84 é primária:")
print(cid_assoc_freq.sort_values(ascending=False).head(20).astype(int))

print("\nCIDs primárias mais comuns quando F84 é secundária:")
print(cid_prim_freq.sort_values(ascending=False).head(20).astype(int))

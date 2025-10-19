import pandas as pd


df = pd.read_csv("D:\DATASUS\PSSP1301_dedup.csv", sep=";", encoding="latin1")

print(df.columns)
print(df.head())

print("N registros:", len(df))
print("N CNS únicos:", df["CNS_HEX"].nunique())


cid_considerada = ["F84", "F840", "F841"]

# filtar pelas CID's que se quer
df_f84 = df[
    (df["CIDPRI"].isin(cid_considerada)) |
    (df["CIDASSOC"].isin(cid_considerada))
]


print("Total de pacientes com F84:", len(df_f84))


# Distribuição por sexo
print(df_f84["SEXOPAC"].value_counts())

# Estatísticas de idade
print(df_f84["IDADEPAC"].describe())


# Frequência de CID secundária (quando F84 é primária)
df_assoc = df_f84[df_f84["CIDPRI"].str.startswith("F84", na=False)]
cid_assoc_freq = df_assoc["CIDASSOC"].value_counts().head(20)

print("CIDs secundárias mais comuns quando F84 é primária:")
print(cid_assoc_freq)

# Frequência de CID primária (quando F84 é secundária)
df_prim = df_f84[df_f84["CIDASSOC"].str.startswith("F84", na=False)]
cid_prim_freq = df_prim["CIDPRI"].value_counts().head(20)

print("CIDs primárias mais comuns quando F84 é secundária:")
print(cid_prim_freq)


import pandas as pd


df = pd.read_csv("D:\DATASUS\CSV\PSSP2407.csv", sep=",", encoding="latin1")

print(df.columns)
print(df.head())

print("N registros:", len(df))
#print("N CNS únicos:", df["CNS_PAC"].nunique())


cid_considerada = ["F84", "F840", "F841"]


df_f84 = df[
    (df["CIDPRI"].isin(cid_considerada)) |
    (df["CIDASSOC"].isin(cid_considerada))
]


print("Total de atendimentos/pacientes com F84:", len(df_f84))

#df_f84 = df


print(df_f84["SEXOPAC"].value_counts())

print(df_f84["RACACOR"].value_counts())

print(df_f84["SIT_RUA"].value_counts())

print(df_f84["TP_DROGA"].value_counts())

print(df_f84["PA_PROC_ID"].value_counts())

print(df_f84["UFMUN"].value_counts())

print(df_f84["MUNPAC"].value_counts())


print(df_f84["IDADEPAC"].describe())


print(df_f84["DT_INICIO"].astype(str).str[:4].value_counts())


print(df_f84["DT_FIM"].astype(str).str[:4].value_counts())


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


#atendimentos_por_ano = df_f84["ano"].value_counts()



campinas = df_f84[(df_f84["UFMUN"] == 350950) & (df_f84["MUNPAC"] == 350950)]

campinas_UFMUN = len(df_f84[df_f84["UFMUN"] == 350950])
campinas_MUNPAC = len(df_f84[df_f84["MUNPAC"] == 350950])
match = len(campinas)

print(f"\n\nAtendimentos com UFMUN = 350950: {campinas_UFMUN}")
print(f"Atendimentos com MUNPAC = 350950: {campinas_MUNPAC}")
print(f"Atendimentos com os dois: {match}")

campinas_pacientes = len(campinas.drop_duplicates(subset=["CNS_PAC"], keep = "first"))

print(f"Número de pacientes distintos em Campinas: {campinas_pacientes}")

campinas_teste = df_f84[df_f84["UFMUN"] == 350950]
campinas_teste.to_csv("D:DATASUS\output.csv")



#print("Atendimentos por ano:")
#print(atendimentos_por_ano)



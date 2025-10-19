import pandas as pd
import numpy as np
import gower
from sklearn_extra.cluster import KMedoids
from sklearn.metrics import pairwise_distances
from sklearn.manifold import MDS
import matplotlib.pyplot as plt
from sklearn.metrics import silhouette_score
import hdbscan
from sklearn.manifold import TSNE



k_top_cids = 50   #Quantidade de CIDs dummies
combine_weights = {"gower": 0.5, "jaccard": 0.5}  #Pesos pra combinação
sample_size = 5000  #Tamanho de amostra de testes (caso fique pesado)


#Lê o CSV com tudo sendo string
df = pd.read_csv("D:\DATASUS\PSSP_F84.csv", sep=",", encoding="utf-8", dtype=str)

#Transforma a idade em numérica
df["IDADEPAC"] = pd.to_numeric(df["IDADEPAC"], errors="coerce")

#Selecionar e limpar colunas de interesse
cols = ["CNS_HEX", "SEXOPAC", "IDADEPAC", "RACACOR", "CIDPRI", "CIDASSOC"]
df = df[[c for c in cols if c in df.columns]].copy()

#Garante que não tem código de paciente nulo
df = df[df["CNS_HEX"].notna()]

#Se for usar amostra
if sample_size is not None:
    df = df.sample(n=sample_size, random_state=42).reset_index(drop=True)


#Normaliza as strings
for c in ["SEXOPAC", "RACACOR", "CIDPRI", "CIDASSOC"]:
    if c in df.columns:
        df[c] = df[c].astype(str).str.strip().replace({"nan": None})

# SEXO como categoria
df["SEXOPAC"] = df["SEXOPAC"].fillna("UNK").astype("category")

# RACACOR como categoria
df["RACACOR"] = df["RACACOR"].fillna("0").astype("category")

#Cria um set pra cada paciente com as CIDs, pra facilitar (não precisar checar duas colunas)
def build_cid_set(row):
    s = set()
    if row.get("CIDPRI") and row["CIDPRI"] not in ["nan", "None", None, ""]:
        s.add(row["CIDPRI"])
    if row.get("CIDASSOC") and row["CIDASSOC"] not in ["nan", "None", None, ""]:
        s.add(row["CIDASSOC"])
    return s

df["CID_SET"] = df.apply(build_cid_set, axis=1)

#Top-k CIDs pra fazer one-hot e dummies (Criar colunas tipo CID_F84, e se for 0 não tem, se for 1 tem, para todas as n = k_top_cids CIDs)
all_cids = pd.Series([cid for s in df["CID_SET"] for cid in s if cid]).value_counts()
top_cids = all_cids.head(k_top_cids).index.tolist()

#Cria dummies para top_cids (0/1 se tem a CID)
for cid in top_cids:
    df[f"CID_TOP_{cid}"] = df["CID_SET"].apply(lambda s: 1 if cid in s else 0)

#Constrói o DataFrame de features para Gower com idade, sexo, cor, e as CIDs
gower_cols = ["IDADEPAC", "SEXOPAC", "RACACOR"]
gower_cols += [f"CID_TOP_{cid}" for cid in top_cids]

#Transforma em um dataset separado por segurança
X_gower = df[gower_cols].copy()

# garantir dtypes: numeric para idade e dummies (dummies já são int); object/category para categóricas
X_gower["IDADEPAC"] = X_gower["IDADEPAC"].astype(float)
for c in X_gower.select_dtypes(include=["category"]).columns:
    X_gower[c] = X_gower[c].astype(object)

#Faz a matriz de distância Gower
D_gower = gower.gower_matrix(X_gower)  # retorna matriz (n x n), valores entre 0 e 1

#Calcula a matriz de Jaccard baseada nas top CIDs 
cid_cols = [f"CID_TOP_{cid}" for cid in top_cids]
M = df[cid_cols].values.astype(int)  #Cada coluna é tipo CID_F1, CID_F2, CID_F3... e cada linha representa o paciente, se tem ou não ela, em 0 ou 1
D_jacc = pairwise_distances(M, metric="jaccard")  #Retorna distâncias entre 0 e 1 (0 iguais, 1 diferentes, igual a Gower, e por isso pode fazer soma ponderada)

#Combinaa as distâncias (soma ponderada)
w_g = combine_weights["gower"]
w_j = combine_weights["jaccard"]
D_comb = (w_g * D_gower) + (w_j * D_jacc)


#Clustering: K-Medoids com métrica pré-computed
n_clusters = 5
kmedoids = KMedoids(n_clusters=n_clusters, metric="precomputed", random_state=42)
clusters = kmedoids.fit_predict(D_comb)
df["cluster"] = clusters

#Visualização por MDS (pré-computed distances)
mds = MDS(n_components=2, dissimilarity="precomputed", random_state=42, n_init=4)
XY = mds.fit_transform(D_comb)

#Plot
plt.figure(figsize=(9,7))
scatter = plt.scatter(XY[:,0], XY[:,1], c=df["cluster"], s=8, cmap="tab10", alpha=0.8)
plt.title("Projeção MDS dos pacientes (distância combinada Gower+Jaccard)")
plt.xlabel("MDS1"); plt.ylabel("MDS2")
plt.legend(*scatter.legend_elements(), title="cluster")
plt.show()

#Resumo por cluster
summary = df.groupby("cluster").agg({
    "IDADEPAC": ["mean","std","count"],
    "SEXOPAC": lambda s: s.mode().iat[0] if not s.mode().empty else np.nan,
    "RACACOR": lambda s: s.mode().iat[0] if not s.mode().empty else np.nan
})
print(summary)

plt.hist(D_comb.flatten(), bins=50)
plt.show()


clusterer = hdbscan.HDBSCAN(min_cluster_size=30,
                            metric='precomputed',
                            cluster_selection_method='eom')
labels = clusterer.fit_predict(D_comb)
df['cluster'] = labels

n_clusters = len(set(labels)) - (1 if -1 in labels else 0)
n_noise = list(labels).count(-1)

print(f"Clusters encontrados: {n_clusters}")
print(f"Pontos de ruído: {n_noise} de {len(labels)}")


mds = MDS(n_components=2, dissimilarity='precomputed', random_state=42)
XY = mds.fit_transform(D_comb)

plt.figure(figsize=(9,7))
plt.scatter(XY[:,0], XY[:,1], c=df['cluster'], cmap='tab10', s=8, alpha=0.8)
plt.title("HDBSCAN sobre matriz de distâncias")
plt.xlabel("MDS1"); plt.ylabel("MDS2")
plt.show()

tsne = TSNE(n_components=2, metric='precomputed', perplexity=30, random_state=42, init = 'random')
XY_tsne = tsne.fit_transform(D_comb)

plt.figure(figsize=(9,7))
plt.scatter(XY_tsne[:,0], XY_tsne[:,1], c=df['cluster'], cmap='tab20', s=8, alpha=0.8)
plt.title("t-SNE: clusters HDBSCAN")
plt.xlabel("t-SNE1")
plt.ylabel("t-SNE2")
plt.show()

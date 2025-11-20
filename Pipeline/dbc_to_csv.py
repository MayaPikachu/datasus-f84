import os
import datasus_dbc
from dbfread import DBF
import pandas as pd

pastadbc = "D:\\DATASUS\\DBC"
pastadbf = "D:\\DATASUS\\DBF"
pastacsv = "D:\\DATASUS\\CSV"

ufs = [
    "AC","AL","AM","AP","BA","CE","DF","ES","GO","MA","MG","MS","MT",
    "PA","PB","PE","PI","PR","RJ","RN","RO","RR","RS","SC","SE","SP","TO"
]

for uf in ufs:
    for ano in range(13, 25):  # 2013 até 2024
        for mes in range(1, 13):  # Janeiro até Dezembro
            nome_arquivo = f"PS{uf}{ano:02d}{mes:02d}"  
            dbc_path = os.path.join(pastadbc, f"{nome_arquivo}.dbc")
            dbf_path = os.path.join(pastadbf, f"{nome_arquivo}.dbf")
            csv_path = os.path.join(pastacsv, f"{nome_arquivo}.csv")

            if os.path.exists(dbc_path):
                print(f"Convertendo {nome_arquivo}.dbc ...")
                
                # Descompacta DBC → DBF
                datasus_dbc.decompress(dbc_path, dbf_path)
                
                # Lê DBF → DataFrame
                df = pd.DataFrame(iter(DBF(dbf_path, encoding='UTF-8')))
                
                # Exporta para CSV
                df.to_csv(csv_path, index=False)
            else:
                print(f"Arquivo não encontrado: {dbc_path}")

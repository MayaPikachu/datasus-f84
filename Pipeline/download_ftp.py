import ftplib
import os
import re

def baixar_arquivos_ftp(diretorio_ftp, destino_local, tipo, estados, anos, meses):
    servidor_ftp = 'ftp.datasus.gov.br'
    
    with ftplib.FTP(servidor_ftp) as ftp:
        ftp.login()  
        ftp.cwd(diretorio_ftp)
        arquivos = ftp.nlst()

        if not os.path.exists(destino_local):
            os.makedirs(destino_local)

        for estado in estados:  # Iterar sobre todos os estados
            for ano in anos:
                for mes in meses:
                    padrao_arquivo = re.compile(f"{tipo}{estado}{ano}{mes}[a-z]*\\.dbc")

                    for arquivo in arquivos:
                        if padrao_arquivo.match(arquivo):
                            caminho_local = os.path.join(destino_local, arquivo)
                            with open(caminho_local, 'wb') as f:
                                bytes_received = 0
                                file_size = round(ftp.size(arquivo) / 1024, 1)

                                def handle_binary(block):
                                    nonlocal bytes_received
                                    f.write(block)
                                    bytes_received += len(block)
                                    print(f"[{estado}] {arquivo}: {bytes_received}/{file_size} kbytes", end='\r')

                                ftp.retrbinary('RETR ' + arquivo, handle_binary)
                                print(f"\n[{estado}] Baixado: {arquivo}")


# Configurações
diretorio_ftp = '/dissemin/publicos/SIASUS/200801_/Dados'
destino_local = 'D:\\DATASUS\\DBC'
tipo = 'PS'  

# Todas as siglas de estados do Brasil (UFs)
estados = [
    "AC","AL","AM","AP","BA","CE","DF","ES","GO","MA",
    "MG","MS","MT","PA","PB","PE","PI","PR","RJ","RN",
    "RO","RR","RS","SC","SE","SP","TO"
]

anos = ["13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23", "24"]
meses = ["01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12"]

# Executa para todos os estados
baixar_arquivos_ftp(diretorio_ftp, destino_local, tipo, estados, anos, meses)

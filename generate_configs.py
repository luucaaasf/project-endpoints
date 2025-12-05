#!/usr/bin/env python3
"""
Script para gerar arquivos de configuração YAML para endpoints Zabbix
a partir de um arquivo CSV simples.

Uso: python generate_configs.py
"""

import csv
import os
from pathlib import Path

# Configurações
CSV_FILE = "endpoints.csv"
CONFIG_DIR = "configs"
TEMPLATE = """zabbix:
  host: "{host}"
  groups:
    - groupid: "{groupid}"
  macros:
    '{{$CERT.WEBSITE.HOSTNAME}}': "{url}"
    '{{$CERT.WEBSITE.IP}}': ""
  web_scenarios:
    - name: "Check Authenticated URL"
      delay: "5m"
      retries: "1"
      agent: "Zabbix"
      steps:
        - name: "Step Web"
          url: "{url}"
          status_codes: "200"
          timeout: "15s"
          no: 1
  triggers:
    - name: "Site {url} indisponivel"
      expression: "last(/{host}/web.test.fail[Check Authenticated URL],#3)=1"
      priority: 5
"""

def main():
    # Verifica se o arquivo CSV existe
    if not os.path.exists(CSV_FILE):
        print(f"❌ Arquivo '{CSV_FILE}' não encontrado!")
        print(f"📋 Crie o arquivo com as colunas: host,url,groupid")
        return
    
    # Cria o diretório configs se não existir
    Path(CONFIG_DIR).mkdir(exist_ok=True)
    
    # Lê o CSV e gera os arquivos
    with open(CSV_FILE, 'r', encoding='utf-8') as f:
        reader = csv.DictReader(f)
        count = 0
        
        for row in reader:
            host = row['host'].strip()
            url = row['url'].strip()
            groupid = row['groupid'].strip()
            
            # Valida campos obrigatórios
            if not host or not url or not groupid:
                print(f"⚠️  Linha ignorada (campos vazios): {row}")
                continue
            
            # Gera o conteúdo YAML
            yaml_content = TEMPLATE.format(
                host=host,
                url=url,
                groupid=groupid
            )
            
            # Nome do arquivo
            filename = f"{CONFIG_DIR}/{host}.yaml"
            
            # Escreve o arquivo
            with open(filename, 'w', encoding='utf-8') as out:
                out.write(yaml_content)
            
            print(f"✅ Criado: {filename}")
            count += 1
    
    print(f"\n🎉 {count} arquivo(s) gerado(s) com sucesso!")
    print(f"📁 Arquivos salvos em: {CONFIG_DIR}/")

if __name__ == "__main__":
    main()

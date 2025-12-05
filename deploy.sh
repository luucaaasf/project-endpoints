#!/bin/bash

CSV_FILE="${CSV_FILE:-endpoints.csv}"
SCRIPT_PATH="${SCRIPT_PATH:-./zabbix_sync.sh}"
GENERATE_SCRIPT="${GENERATE_SCRIPT:-./generate_configs.py}"

# Verifica se o CSV existe
if [ ! -f "$CSV_FILE" ]; then
  echo "❌ Arquivo $CSV_FILE não encontrado!"
  exit 1
fi

# Verifica se o script de sync existe
if [ ! -x "$SCRIPT_PATH" ]; then
  echo "❌ Script $SCRIPT_PATH não encontrado ou não é executável."
  exit 1
fi

echo "📋 Lendo endpoints de: $CSV_FILE"
echo "🔧 Gerando configurações temporárias..."

# Cria diretório temporário para os configs
TMP_DIR=$(mktemp -d)
trap "rm -rf $TMP_DIR" EXIT

# Gera os configs no diretório temporário
CONFIG_DIR="$TMP_DIR" python3 "$GENERATE_SCRIPT"

if [ $? -ne 0 ]; then
  echo "❌ Falha ao gerar configurações!"
  exit 1
fi

echo "📂 Processando endpoints..."

# Processa cada arquivo gerado
for file in "$TMP_DIR"/*.yaml; do
  if [ -f "$file" ]; then
    echo "🚀 Processando: $(basename $file)"
    VALUES_FILE="$file" "$SCRIPT_PATH"
    echo "✅ Finalizado: $(basename $file)"
    echo "-------------------------------------"
    sleep 1
  fi
done

echo "🏁 Deploy finalizado para todos os endpoints do CSV!"

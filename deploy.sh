#!/bin/bash

CONFIG_DIR="/opt/nuageit/configs"
SCRIPT_PATH="/opt/nuageit/zabbix_sync.sh"

if [ ! -x "$SCRIPT_PATH" ]; then
  echo "❌ Script $SCRIPT_PATH não encontrado ou não é executável."
  exit 1
fi

echo "📂 Procurando arquivos .yaml em $CONFIG_DIR..."

for file in "$CONFIG_DIR"/*.yaml; do
  if [ -f "$file" ]; then
    echo "🚀 Processando: $file"
    VALUES_FILE="$file" "$SCRIPT_PATH"
    echo "✅ Finalizado: $file"
    echo "-------------------------------------"
    sleep 1
  fi
done

echo "🏁 Deploy finalizado para todos os arquivos."

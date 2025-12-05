#!/bin/bash

if [ -z "$VALUES_FILE" ]; then
  echo "❌ A variável VALUES_FILE não está definida. Finalizando." >&2
  exit 1
fi

ZBX_API_URL="http://54.198.250.98/api_jsonrpc.php"
ZBX_TOKEN="86c9c994d355f1db4087355ae9eb662dfea5a83dd77537576256df442af35eb8"
HEADERS=(-H "Content-Type: application/json" -H "Authorization: Bearer $ZBX_TOKEN")


_get_or_create_host() {
  local host=$(yq e '.zabbix.host' "$VALUES_FILE")
  export CURRENT_HOST="$host"
  echo "🔎 Verificando se host '$host' já existe..." >&2

  local response=$(curl -s -X POST "$ZBX_API_URL" "${HEADERS[@]}" -d @- <<EOF
{
  "jsonrpc": "2.0",
  "method": "host.get",
  "params": {
    "filter": {
      "host": ["$host"]
    }
  },
  "id": 1
}
EOF
)

  # Debug: mostra resposta se houver erro
  if echo "$response" | jq -e '.error' > /dev/null 2>&1; then
    echo "❌ ERRO na API do Zabbix:" >&2
    echo "$response" | jq -r '.error.data' >&2
    exit 1
  fi

  local hostid=$(echo "$response" | jq -r '.result[0].hostid // empty')

  if [ -n "$hostid" ]; then
    echo "✅ Host já existe com ID: $hostid" >&2
    echo "$hostid"
    return
  fi

  echo "📦 Criando novo host: $host" >&2
  local groups_json=$(yq e -o=json '.zabbix.groups' "$VALUES_FILE")

  local response=$(curl -s -X POST "$ZBX_API_URL" "${HEADERS[@]}" -d @- <<EOF
{
  "jsonrpc": "2.0",
  "method": "host.create",
  "params": {
    "host": "$host",
    "groups": $groups_json
  },
  "id": 2
}
EOF
)

  # Verifica se houve erro na resposta
  if echo "$response" | jq -e '.error' > /dev/null 2>&1; then
    echo "❌ ERRO ao criar host:" >&2
    echo "$response" | jq -r '.error' >&2
    exit 1
  fi

  hostid=$(echo "$response" | jq -r '.result.hostids[0] // empty')
  if [ -z "$hostid" ]; then
    echo "❌ Falha ao criar o host. Resposta completa:" >&2
    echo "$response" >&2
    exit 1
  fi

  echo "✅ Host criado com ID: $hostid" >&2
  echo "$hostid"
}

_substitute_macros() {
  local input="$1"

  # Tenta converter input em JSON válido
  if echo "$input" | jq empty 2>/dev/null; then
    # É JSON válido
    local result="$input"
    for key in $(yq e '.zabbix.macros | keys | .[]' "$VALUES_FILE"); do
      local val=$(yq e -r ".zabbix.macros.\"$key\"" "$VALUES_FILE")
      result=$(echo "$result" | jq --arg k "$key" --arg v "$val" \
        'walk(if type == "string" then gsub($k; $v) else . end)')
    done
    echo "$result"
  else
    # Simples substituição de string (sem sed)
    local result="$input"
    for key in $(yq e '.zabbix.macros | keys | .[]' "$VALUES_FILE"); do
      local val=$(yq e -r ".zabbix.macros.\"$key\"" "$VALUES_FILE")
      result="${result//${key}/${val}}"
    done
    echo "$result"
  fi
}


_sync_macros_manual() {
  local hostid="$1"
  echo "🔁 Criando macros..." >&2

  local desired_keys=$(yq e '.zabbix.macros | keys | .[]' "$VALUES_FILE")
  local desired_json=$(yq e -o=json '.zabbix.macros' "$VALUES_FILE")

  for key in $desired_keys; do
    value=$(echo "$desired_json" | jq -r --arg k "$key" '.[$k]')
    echo "➕ Criando macro $key = $value" >&2
    curl -s -X POST "$ZBX_API_URL" "${HEADERS[@]}" -d @- <<EOF > /dev/null
{
  "jsonrpc": "2.0",
  "method": "usermacro.create",
  "params": {
    "hostid": $hostid,
    "macro": "$key",
    "value": "$value"
  },
  "id": 3
}
EOF
  done
}

_create_or_update_webscenario() {
  local hostid="$1"
  local name=$(yq e '.zabbix.web_scenarios[0].name' "$VALUES_FILE")
  local steps=$(yq e -o=json '.zabbix.web_scenarios[0].steps' "$VALUES_FILE")
  local agent=$(yq e '.zabbix.web_scenarios[0].agent' "$VALUES_FILE")
  local retries=$(yq e '.zabbix.web_scenarios[0].retries' "$VALUES_FILE")
  local delay=$(yq e '.zabbix.web_scenarios[0].delay' "$VALUES_FILE")

  name=$(_substitute_macros "$name")
  steps=$(_substitute_macros "$steps")

  # 🔎 Verifica se já existe
  local existing_id=$(curl -s -X POST "$ZBX_API_URL" "${HEADERS[@]}" -d @- <<EOF | jq -r '.result[0].httptestid // empty'
{
  "jsonrpc": "2.0",
  "method": "httptest.get",
  "params": {
    "filter": {
      "name": "$name",
      "hostid": "$hostid"
    }
  },
  "id": 100
}
EOF
)

  if [ -n "$existing_id" ]; then
    echo "⚠️  Web Scenario \"$name\" já existe (ID: $existing_id). Pulando criação." >&2
    return
  fi

  echo "🆕 Criando Web Scenario: $name" >&2

  curl -s -X POST "$ZBX_API_URL" "${HEADERS[@]}" -d "$(jq -n \
    --arg name "$name" \
    --argjson steps "$steps" \
    --arg hostid "$hostid" \
    --arg delay "$delay" \
    --arg retries "$retries" \
    --arg agent "$agent" \
    '{
      jsonrpc: "2.0",
      method: "httptest.create",
      params: {
        name: $name,
        hostid: ($hostid | tonumber),
        delay: $delay,
        retries: $retries,
        agent: $agent,
        steps: $steps
      },
      id: 4
    }')"
}


_create_or_update_trigger() {
  local raw_name=$(yq e '.zabbix.triggers[0].name' "$VALUES_FILE")
  local raw_expression=$(yq e '.zabbix.triggers[0].expression' "$VALUES_FILE")
  local priority=$(yq e '.zabbix.triggers[0].priority' "$VALUES_FILE")

  raw_name=$(_substitute_macros "$raw_name")
  raw_expression=$(_substitute_macros "$raw_expression")

  echo "🧩 Trigger resolvida:" >&2
  echo "  Nome: $raw_name" >&2
  echo "  Expressão: $raw_expression" >&2

  curl -s -X POST "$ZBX_API_URL" "${HEADERS[@]}" -d @- <<EOF
{
  "jsonrpc": "2.0",
  "method": "trigger.create",
  "params": {
    "description": "$raw_name",
    "expression": "$raw_expression",
    "priority": "$priority"
  },
  "id": 5
}
EOF
}

main() {
  HOSTID=$(_get_or_create_host)
  echo "✅ HOSTID real: $HOSTID" >&2
  _sync_macros_manual "$HOSTID"
  sleep 1
  _create_or_update_webscenario "$HOSTID"
  sleep 1
  _create_or_update_trigger "$HOSTID"
}
main

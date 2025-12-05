# Configuração do GitHub Actions

## 📋 Pré-requisitos

Para a pipeline funcionar, você precisa configurar os **secrets** do GitHub com as credenciais do Zabbix.

## 🔐 Configurar Secrets

1. Acesse seu repositório no GitHub
2. Vá em **Settings** → **Secrets and variables** → **Actions**
3. Clique em **New repository secret**
4. Adicione os seguintes secrets:

### Secret 1: ZABBIX_API_URL
- **Name:** `ZABBIX_API_URL`
- **Value:** `http://54.198.250.98/zabbix/api_jsonrpc.php`

### Secret 2: ZABBIX_TOKEN
- **Name:** `ZABBIX_TOKEN`
- **Value:** `86c9c994d355f1db4087355ae9eb662dfea5a83dd77537576256df442af35eb8`

⚠️ **IMPORTANTE:** Nunca commite tokens ou senhas diretamente no código!

## 🚀 Como usar

### Modo automático
1. Edite o arquivo `endpoints.csv`
2. Faça commit e push:
   ```bash
   git add endpoints.csv
   git commit -m "feat: adicionar novos endpoints"
   git push
   ```
3. A pipeline será executada automaticamente
4. Os endpoints serão adicionados no Zabbix

### Modo manual
Você também pode executar a pipeline manualmente:
1. Acesse **Actions** no GitHub
2. Selecione **Deploy Endpoints to Zabbix**
3. Clique em **Run workflow**

## 📊 Monitorar execução

- Vá em **Actions** no GitHub
- Veja o status de cada execução
- Clique em uma execução para ver os logs detalhados

## 🔄 O que a pipeline faz

1. ✅ Faz checkout do código
2. ✅ Instala Python
3. ✅ Gera os arquivos `.yaml` a partir do `endpoints.csv`
4. ✅ Instala dependências (curl, jq, yq)
5. ✅ Executa o deploy no Zabbix
6. ✅ Commita os configs gerados (se necessário)

## 🎯 Quando a pipeline é executada

A pipeline roda automaticamente quando você faz push de alterações em:
- `endpoints.csv`
- `generate_configs.py`
- Qualquer arquivo em `configs/`

Nas branches:
- `main`
- `master`

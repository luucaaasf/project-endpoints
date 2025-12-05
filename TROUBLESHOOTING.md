# 🔧 Troubleshooting - Resolução de Problemas

## Problemas Identificados e Soluções

### ✅ 1. Erro 403 no Git Push (RESOLVIDO)

**Problema:**
```
remote: Permission to luucaaasf/project-endpoints.git denied to github-actions[bot].
fatal: unable to access 'https://github.com/luucaaasf/project-endpoints/': The requested URL returned error: 403
```

**Causa:** GitHub Actions não tinha permissão para fazer push.

**Solução Aplicada:** Adicionada permissão `contents: write` no workflow.

---

### ⚠️ 2. Falha ao Criar Hosts no Zabbix

**Problema:**
```
❌ Falha ao criar o host. Resposta: 
```

**Possíveis Causas:**

#### A) Secrets não configurados
- Os secrets `ZABBIX_API_URL` e `ZABBIX_TOKEN` podem não estar configurados no GitHub

**Como verificar:**
1. Vá em **Settings** → **Secrets and variables** → **Actions**
2. Confirme que existem:
   - `ZABBIX_API_URL` = `http://54.198.250.98/api_jsonrpc.php`
   - `ZABBIX_TOKEN` = `<seu-token>`

#### B) URL incorreta
- Verifique se a URL está correta (sem o `/zabbix` no path)
- URL correta: `http://54.198.250.98/api_jsonrpc.php`

#### C) Token inválido ou expirado
- O token do Zabbix pode estar inválido
- Gere um novo token no Zabbix e atualize o secret

#### D) Falta o campo `interfaces` no config
- Os arquivos YAML precisam do campo `interfaces` para criar hosts

**Solução:** Vou criar YAMLs com interfaces configuradas.

---

### 🔍 3. Debugging Melhorado

Agora o script mostra erros detalhados do Zabbix. Na próxima execução você verá:
- ✅ URL da API configurada
- ❌ Mensagens de erro completas do Zabbix
- 🔍 Resposta completa da API em caso de falha

---

## Como Testar Localmente

### 1. Teste a conexão com o Zabbix

```bash
# Linux/Mac
curl -X POST "http://54.198.250.98/api_jsonrpc.php" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer SEU_TOKEN" \
  -d '{
    "jsonrpc": "2.0",
    "method": "host.get",
    "params": {
      "limit": 1
    },
    "id": 1
  }' | jq
```

Se retornar hosts, a conexão está OK.
Se retornar erro, há problema com o token ou URL.

### 2. Teste o script de geração

```bash
python generate_configs.py
```

Deve gerar os arquivos em `configs/`.

### 3. Teste manualmente um endpoint

```bash
export VALUES_FILE="configs/api-cotacoes.yaml"
./zabbix_sync.sh
```

---

## Próximos Passos

1. **Configure os secrets no GitHub** (se ainda não fez)
2. **Faça um novo commit** para testar o workflow corrigido:
   ```bash
   git add .
   git commit -m "fix: adicionar permissões e debug ao workflow"
   git push
   ```
3. **Acompanhe os logs** em Actions para ver os erros detalhados
4. **Ajuste os YAMLs** se necessário (adicionar campo `interfaces`)

---

## Verificação dos Secrets

Para ter certeza que os secrets estão configurados, o workflow agora exibe:
```
✅ API URL configurada: http://54.198.250.98/api_jsonrpc.php
```

Se não aparecer, os secrets não estão configurados.

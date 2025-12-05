# Monitoramento de Endpoints - Zabbix

Projeto para facilitar o cadastro e monitoramento de endpoints no Zabbix.

## 🚀 Como usar

### Adicionar Novos Endpoints (Super Simples!)

1. **Edite apenas o arquivo `endpoints.csv`:**

```csv
host,url,groupid
api-cotacoes,https://api.utrip.cloud/quote/health,22
api-disponibilidade,https://api.utrip.cloud/availability/health,22
api-reservas,https://api.utrip.cloud/bookings/health,22
```

**Campos:**
- `host`: Nome do host no Zabbix (sem espaços)
- `url`: URL completa do endpoint de health check
- `groupid`: ID do grupo no Zabbix (geralmente 22)

2. **Commit e push:**

```bash
git add endpoints.csv
git commit -m "feat: adicionar novos endpoints"
git push
```

3. **Pronto!** A pipeline automaticamente:
   - ✅ Gera as configurações YAML (temporárias)
   - ✅ Faz deploy no Zabbix
   - ✅ Limpa arquivos temporários

> 📖 Veja [SETUP_GITHUB.md](SETUP_GITHUB.md) para configurar os secrets do GitHub

### Teste Local (Opcional)

Se quiser testar antes de fazer push:

```bash
./deploy.sh
```

O script gera os configs temporariamente e aplica no Zabbix.

## 📝 Exemplo

**Antes** - Criar e editar 30+ linhas de YAML manualmente:
```yaml
zabbix:
  host: "api-exemplo"
  interfaces:
    - type: 1
      main: 1
      useip: 1
      ip: "127.0.0.1"
      dns: ""
      port: "10050"
  groups:
    - groupid: "22"
  macros:
    '{$CERT.WEBSITE.HOSTNAME}': "https://..."
  web_scenarios:
    - name: "Check Authenticated URL"
      # ... mais 15 linhas
```

**Agora** - Apenas uma linha no CSV:
```csv
api-exemplo,https://api.exemplo.com/health,22
```

**Deploy automático** - Só fazer commit!

## 🔧 Requisitos

- Python 3.6+
- Arquivos `.csv` com encoding UTF-8

## 📌 Estrutura

```
projeto-endpoints/
├── endpoints.csv          # ← APENAS EDITE ESTE ARQUIVO!
├── generate_configs.py    # Script de geração (automático)
├── deploy.sh             # Script de deploy (automático)
├── zabbix_sync.sh        # Script de sincronização com Zabbix
└── .github/workflows/    # Pipeline do GitHub Actions

Nota: A pasta configs/ é gerada temporariamente e não é versionada
```

# Monitoramento de Endpoints - Zabbix

Projeto para facilitar o cadastro e monitoramento de endpoints no Zabbix.

## 🚀 Como usar

### Opção 1: Automático via GitHub (Recomendado)

1. **Adicione novos endpoints** no arquivo `endpoints.csv`:

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

2. **Commit e push**:

```bash
git add endpoints.csv
git commit -m "feat: adicionar novos endpoints"
git push
```

3. **Pronto!** A pipeline do GitHub Actions vai:
   - Gerar os arquivos YAML automaticamente
   - Fazer deploy no Zabbix
   - Commitar os configs gerados

> 📖 Veja [SETUP_GITHUB.md](SETUP_GITHUB.md) para configurar os secrets do GitHub

### Opção 2: Manual (Local)

1. Edite `endpoints.csv`
2. Execute: `python generate_configs.py`
3. Execute: `./deploy.sh`

## 📝 Exemplo

**Antes** - Você precisava editar 22 linhas manualmente:
```yaml
zabbix:
  host: "api-exemplo"
  groups:
    - groupid: "22"
  macros:
    '{$CERT.WEBSITE.HOSTNAME}': "https://..."
  # ... mais 15 linhas
```

**Agora** - Apenas uma linha no CSV:
```csv
api-exemplo,https://api.exemplo.com/health,22
```

## 🔧 Requisitos

- Python 3.6+
- Arquivos `.csv` com encoding UTF-8

## 📂 Estrutura

```
projeto-endpoints/
├── endpoints.csv          # ← Edite aqui para adicionar endpoints
├── generate_configs.py    # ← Execute para gerar YAMLs
├── configs/              # ← Arquivos YAML gerados automaticamente
├── deploy.sh             # ← Deploy para Zabbix
└── zabbix_sync.sh        # ← Script de sincronização
```

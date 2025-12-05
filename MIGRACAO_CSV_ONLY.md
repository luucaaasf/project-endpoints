# 🔄 Migração para Fluxo CSV-Only

## O que mudou?

### ❌ Antes (Complexo)
```
endpoints.csv → generate_configs.py → configs/*.yaml (versionados) → deploy.sh → Zabbix
                                            ↑
                                      Commitar no Git
```

### ✅ Agora (Simplificado)
```
endpoints.csv → deploy.sh (gera temporariamente) → Zabbix
     ↑
Único arquivo a editar!
```

## Mudanças Aplicadas

1. **✅ Pasta `configs/` removida do Git**
   - Agora é gerada temporariamente durante o deploy
   - Adicionada ao `.gitignore`

2. **✅ `deploy.sh` simplificado**
   - Lê o CSV
   - Gera configs em pasta temporária
   - Aplica no Zabbix
   - Remove configs temporários

3. **✅ Pipeline atualizada**
   - Não gera configs antes
   - Não commita configs depois
   - Apenas executa `deploy.sh` que faz tudo

4. **✅ README atualizado**
   - Documentação focada no CSV
   - Pasta configs não é mencionada

## Fluxo de Trabalho

### Para Adicionar Endpoints

1. Edite **apenas** `endpoints.csv`:
   ```csv
   api-nova,https://api.exemplo.com/health,22
   ```

2. Commit e push:
   ```bash
   git add endpoints.csv
   git commit -m "feat: adicionar api-nova"
   git push
   ```

3. Pronto! Pipeline faz o resto.

## Vantagens

✅ **Mais simples** - Apenas um arquivo CSV  
✅ **Menos commits** - Não versiona YAMLs gerados  
✅ **Menos conflitos** - Sem merge conflicts em configs/  
✅ **Mais limpo** - Git só trackeia o essencial  
✅ **Fácil auditoria** - Histórico do CSV mostra mudanças  

## Teste Local

```bash
./deploy.sh
```

O script:
1. Lê `endpoints.csv`
2. Gera YAMLs temporariamente
3. Aplica no Zabbix
4. Remove YAMLs temporários

## Rollback

Se precisar voltar ao modelo antigo, restaure:
- `configs/` no Git
- Workflow antigo
- README antigo

Mas recomendamos manter o novo fluxo! 🚀

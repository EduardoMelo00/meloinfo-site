# Acesso — portal do cliente da Melo

Fica em `db/` de propósito: `.vercelignore` exclui `db` e `*.sql`, então este arquivo nunca vai pro ar.
Medições de 02/set/2026.

## Endereços

| o quê | onde |
|---|---|
| área do cliente | `meloinfo.com.br/cliente/` |
| painel admin | `meloinfo.com.br/cliente/admin/` |
| proposta por cliente | `meloinfo.com.br/proposta/<nome>/` |

Projeto Supabase: `txcjoqvxvbrtdpvxdrqd` (`meloinfo-clientes`).

## Entrar no admin

Magic link para `eduardo@meloinfo.com.br`. A permissão vem da tabela `admins` (não de e-mail no
código) e o portão é a função `e_admin()`.

⚠️ **O admin só tem magic link — não tem campo de código.** A entrada por código de 8 dígitos existe
só na área do cliente. Se essa caixa não receber, ou se a cota de **2 e-mails/hora** do Supabase
estiver queimada, não há saída pela tela: usar o SQL Editor do dashboard (abaixo).

## Ver o que o cliente preencheu

No painel: card do projeto → seção **Recebidos** → valor de cada item + botão **Baixar**.

Onde os dados moram de fato:
- respostas de texto: tabela `itens`, `tipo = 'requisito'`, coluna `valor_texto`
- arquivos: bucket privado `materiais`, caminho `{projeto_id}/{item_id}-{arquivo}` (a policy lê a
  primeira pasta como id do projeto); download por signed URL de 120s

Direto pelo dashboard → SQL Editor, sem depender de login no painel:

```sql
select i.ordem, i.titulo, i.status, i.valor_texto, i.arquivo_path, i.atualizado_em
from itens i
join projetos p on p.id = i.projeto_id
where p.cliente_email ilike '%mariodealencar%' and i.tipo = 'requisito'
order by i.ordem;
```

## Quando o portal "sair do ar"

**Sintoma:** o host do projeto para de resolver em DNS (NXDOMAIN), e o `/cliente/` no ar fica uma
casca — login e leitura falham.

**Causa:** plano gratuito. Doc oficial: *"We may pause applications on the Free Plan that exhibit low
activity in a 7-day period"*. Ninguém apagou nada.

**Conserto:** dashboard → projeto → **Restore**.

Sequência esperada enquanto o restore sobe, medida em 02/set:

| resposta do REST | significa |
|---|---|
| `521` | Cloudflare acha o host, Postgres ainda não respondeu |
| `404` + `PGRST205 ... schema cache` | cache do PostgREST ainda não carregou |
| `401` + `42501 permission denied` | **normal, é o fim** — ver abaixo |

🚨 **`42501` com a chave publishable NÃO é bug.** As policies casam `auth.jwt() ->> 'email'`, então o
portal só lê **logado**, como role `authenticated`. O `anon` nunca teve nem precisou de `select` em
`projetos` — os `.sql` do repo só têm grants estreitos de coluna. Testar com a publishable é testar um
caminho que o app não usa. (O inverso da armadilha antiga: `42501` significa falta GRANT *para o papel
que você está usando*; RLS bloqueando devolve lista vazia, não erro.)

**Prevenção:** um `select` semanal por cron mata a pausa. Plano Pro também resolve, mas é R$ 25/mês
por um portal de um cliente.

## Publicar

`git push origin main` dispara Production na Vercel (a integração com o git está ligada). Se o build
ficar preso em `Queued` — aconteceu em 02/set, num site que buildava em 1-2s — forçar do repo:

```
vercel --prod --yes
```

Isso aliasa `meloinfo.com.br` direto.

⚠️ **Não sondar o domínio em loop.** ~130 requisições em poucos minutos ligam a mitigação de bot da
Vercel: `403` com `x-vercel-mitigated: challenge` no domínio **inteiro**, inclusive `/`. Não é queda —
navegador de verdade resolve o desafio e passa.

## KDP do Mario

Conta é a do **Mario**; o acesso funciona pelo perfil **`Default`** do Chrome, que tem 13 cookies de
`kdp.amazon.com` / `amazon.com.br`. Abre o KDP nesse perfil e entra sem digitar senha.

**A senha não está nesta máquina.** Procurada em: `KDP-pronto/KDP-formulario.md`, memória inteira
(cruzando kdp/amazon × senha), keychain (`security find-internet-password -s kdp.amazon.com`), tabela
`logins` dos 7 perfis do Chrome, `op`/`bw`/`lpass` (nenhum instalado), notas em Downloads, Desktop e
Documents. Se precisar da senha em si, e não só entrar, pedir ao Mario.

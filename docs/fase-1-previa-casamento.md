# Prévia do casamento de unidades

Data: 23/10/2026. Rodada num Postgres local, com as migrations deste repositório
e os **cadastros de unidade** lidos na Fase 0 (METAS `units`, COMPRAS `units`,
Ativos `locations`, Contas Fixas `branches` e Wiki `clients`). São nomes e
códigos de unidades, sem dado pessoal. Quando a ingestão estiver ligada, o
mesmo relatório sai de `mart.v_relatorio_casamento`.

## Resultado por fonte

| Fonte | Total | Casadas (unidade) | Casadas (setor) | Sugeridas | A revisar | Sem par | % casado | Confiança média |
|---|---:|---:|---:|---:|---:|---:|---:|---:|
| COMPRAS | 105 | 103 | 0 | 1 | 1 | 1 | **98,1%** | 0,999 |
| METAS | 84 | 82 | 0 | 0 | 2 | 0 | **97,6%** | 0,998 |
| Ativos | 105 | 99 | 0 | 0 | 6 | 2 | **94,3%** | 0,998 |
| Wiki | 114 | 90 | 15 | 4 | 5 | 4 | **92,1%** | 0,951 |
| Contas Fixas | 63 | 54 | 0 | 4 | 5 | 4 | **85,7%** | 0,923 |

Das 116 unidades mestras (114 postos do Unilab e 2 canais digitais), 91 aparecem
em 3 ou mais fontes e 2 não aparecem em nenhuma (9P Santa Helena Itapuã Viamão e 9Q Hospital Doctor Clin POA, os mais novos do Unilab).

Conferi um por um os 36 casamentos automáticos em que o nome da fonte difere do
nome do Unilab. Todos estão corretos (ex.: "CONTE MATRIZ" → 71, "HOME CARE PF"
→ 43, "CLINICA HIGIA" → 05).

## Fila de revisão (28 itens)

**Conflito de código** (o código existe, mas o nome não confirma):

| Fonte | Na fonte | Código | Unidade do código no Unilab |
|---|---|---|---|
| Ativos | APOIO PASTEUR | 96 | SÃO LEOPOLDO - ENDO |
| Ativos | HOMECARE ENDO 2 | 87 | ESTÂNCIA VELHA (desde 20/07/2026) |
| Ativos | Livre | 51 | CENTRO CLÍNICO ASSISENSE |
| METAS | EMERGÊNCIA E INTERNADOS | 22 | HNP Urgência |

**Sugestão por nome** (precisa de confirmação):

| Fonte | Na fonte | Sugestão |
|---|---|---|
| COMPRAS | Laboratório Santa Helena - Viamópolis (código "1") | 9K Santa Helena Viamópolis |
| Contas Fixas | CENTRO POA SUS (211 E 212) | 59 Centro SUS |
| Contas Fixas | H IBIRAMA | 42 HDWC Ibirama |
| Contas Fixas | LAGOA | 12 HSP Lagoa (provavelmente errado: no Contas Fixas é Widal, logo 11 Lagoa Vermelha) |
| Contas Fixas | MOINHOS DE VENTO | 60 Moinhos |
| Wiki | HOMECARE ENDO 2 | 95 Coleta Móvel Endocrimeta |
| Wiki | Policinica Alvorada | 67 Policlínica Alvorada |
| Wiki | SAPUCAIA | 9D Sapucaia |
| Wiki | Santa Helena - Salgado Filho | 9H Santa Helena Centro |

**Ambíguo** (mais de um candidato próximo): Ativos "SANTA HELENA VIAMÃO" (9J ou 9K); METAS "SANTA HELENA - SCOLA"; Contas Fixas "CENTRAL PORTO ALEGRE"; Wiki "CENTRO DOM SUS" (53 ou 59).

**Sem par**: Ativos "ESTOQUE LAGES" e "HOSPITAL SAO PAULO"; COMPRAS "UNI-01 Matriz" (parece teste); Contas Fixas "CENTRO POA (106)", "CENTRO POA (107)", "OTTO NIEMEYER" e "nova unidade poa"; Wiki "COLETA DOMICILIAR", "HOSPITAL CÉSAR SANTOS" (9E ou 9F?), "QUALYS" e "R&G SEGURANÇA".

## O que ajustei por causa da prévia

- Casar cadastro sem depender da data. Unidades fechadas ainda aparecem nos cadastros (ex.: 89 Canoas Medical) e estavam indo para a unidade errada.
- Expandir abreviações (ADM, HOSP, PCLINICA, HOMECARE, VCARD).
- Pontuar por semelhança simétrica. Dar peso a "nome contido" fazia "Santa Helena Salgado Filho" cair no posto Santa Helena de Lages.
- Exigir mais de nomes de uma palavra só ("Matriz").
- Incluir 18 apelidos de referência vistos com o mesmo código em dois ou mais sistemas (ex.: "HOME CARE LAGES" = 03, que no Unilab se chama "COLETA MÓVEL LAGES").
- Incluir os canais "Venda Digital" do METAS como unidades do tipo canal digital.

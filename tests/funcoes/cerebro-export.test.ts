// Testes do núcleo da cerebro-export (node --test).
import { test } from "node:test";
import assert from "node:assert/strict";
import {
  chaveValida,
  COLUNAS_PROIBIDAS,
  filtrarColunas,
  interpretarParametros,
  LIMITE_MAXIMO,
  type Recurso,
  validarRecursos,
} from "../../fontes/cerebro-export/nucleo.ts";
import { RECURSOS as METAS } from "../../fontes/cerebro-export/recursos.metas.ts";
import { RECURSOS as ATIVOS } from "../../fontes/cerebro-export/recursos.ativos.ts";
import { RECURSOS as WIKI } from "../../fontes/cerebro-export/recursos.wiki.ts";

const CHAVE = "k".repeat(40);

test("chave: aceita só a chave configurada", async () => {
  assert.equal(await chaveValida(CHAVE, CHAVE), true);
  assert.equal(await chaveValida(CHAVE + "x", CHAVE), false);
  assert.equal(await chaveValida("", CHAVE), false);
  assert.equal(await chaveValida(null, CHAVE), false);
});

test("chave: sem chave configurada (ou curta demais), nega tudo", async () => {
  assert.equal(await chaveValida("qualquer", undefined), false);
  assert.equal(await chaveValida("", ""), false);
  assert.equal(await chaveValida("curta", "curta"), false);
});

const RECS: Record<string, Recurso> = {
  units: { tabela: "units", colunas: ["id", "name"], ordem: "id" },
  entries: { tabela: "e", colunas: ["id", "year"], ordem: "id", colunaAtualizacao: "updated_at", colunaAno: "year" },
};
const url = (q: string) => new URL("https://x.supabase.co/functions/v1/cerebro-export?" + q);

test("parâmetros: recurso desconhecido é recusado", () => {
  const r = interpretarParametros(url("resource=credentials"), RECS);
  assert.equal(r.ok, false);
  assert.equal(interpretarParametros(url("resource=toString"), RECS).ok, false);
  assert.equal(interpretarParametros(url(""), RECS).ok, false);
});

test("parâmetros: padrões e teto de limit", () => {
  const r = interpretarParametros(url("resource=units"), RECS);
  assert.ok(r.ok);
  assert.deepEqual(r.params, { recurso: "units", since: null, ano: null, limit: 500, offset: 0 });
  const g = interpretarParametros(url("resource=units&limit=99999&offset=1000"), RECS);
  assert.ok(g.ok);
  assert.equal(g.params.limit, LIMITE_MAXIMO);
  assert.equal(g.params.offset, 1000);
});

test("parâmetros: valores inválidos", () => {
  for (const q of ["limit=0", "limit=abc", "offset=-1", "since=ontem", "ano=1999", "ano=2026.5"]) {
    assert.equal(interpretarParametros(url("resource=entries&" + q), RECS).ok, false, q);
  }
});

test("parâmetros: since e ano só onde o recurso aceita", () => {
  assert.equal(interpretarParametros(url("resource=units&since=2026-01-01"), RECS).ok, false);
  assert.equal(interpretarParametros(url("resource=units&ano=2026"), RECS).ok, false);
  const r = interpretarParametros(url("resource=entries&since=2026-10-01T00:00:00Z&ano=2026"), RECS);
  assert.ok(r.ok);
  assert.equal(r.params.ano, 2026);
});

test("filtro: só colunas da allowlist saem", () => {
  const out = filtrarColunas([{ id: 1, name: "A", requester_name: "Fulano" }], ["id", "name"]);
  assert.deepEqual(out, [{ id: 1, name: "A" }]);
});

test("validação: coluna proibida ou nome estranho na configuração", () => {
  assert.throws(() => validarRecursos({ t: { tabela: "t", colunas: ["id", "requester_name"], ordem: "id" } }, COLUNAS_PROIBIDAS));
  assert.throws(() => validarRecursos({ t: { tabela: "t", colunas: ["id", "x;drop"], ordem: "id" } }, COLUNAS_PROIBIDAS));
  assert.throws(() => validarRecursos({ t: { tabela: "t", colunas: ["name"], ordem: "id" } }, COLUNAS_PROIBIDAS));
});

for (const [fonte, recursos] of Object.entries({ metas: METAS, ativos: ATIVOS, wiki: WIKI })) {
  test(`recursos de ${fonte} passam na validação`, () => {
    validarRecursos(recursos, COLUNAS_PROIBIDAS);
  });
}

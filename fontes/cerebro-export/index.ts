// cerebro-export: leitura para o Cérebro do Mundo WP.
//
// Vai em supabase/functions/cerebro-export/ de cada sistema-fonte, junto com
// nucleo.ts e o recursos.ts daquela fonte. Precisa de:
//   * secret CEREBRO_READ_KEY (exclusivo do Cérebro, 32+ caracteres);
//   * [functions.cerebro-export] verify_jwt = false no supabase/config.toml
//     (a autenticação é a chave acima, como no postos-faturamento).
//
// Regras: só GET; só as colunas de recursos.ts; nunca escreve no banco.

import { createClient } from "npm:@supabase/supabase-js@2.45.4";
import {
  chaveValida,
  COLUNAS_PROIBIDAS,
  filtrarColunas,
  interpretarParametros,
  validarRecursos,
} from "./nucleo.ts";
import { RECURSOS } from "./recursos.ts";

validarRecursos(RECURSOS, COLUNAS_PROIBIDAS);

const json = (corpo: unknown, status = 200) =>
  new Response(JSON.stringify(corpo), {
    status,
    headers: { "Content-Type": "application/json; charset=utf-8", "Cache-Control": "no-store" },
  });

Deno.serve(async (req) => {
  if (req.method !== "GET") return json({ error: "Método não permitido" }, 405);

  if (!(await chaveValida(req.headers.get("x-cerebro-key"), Deno.env.get("CEREBRO_READ_KEY")))) {
    return json({ error: "Unauthorized" }, 401);
  }

  const r = interpretarParametros(new URL(req.url), RECURSOS);
  if (!r.ok) return json({ error: r.erro }, 400);
  const { recurso, since, ano, limit, offset } = r.params;
  const def = RECURSOS[recurso];

  const supabase = createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
    { auth: { persistSession: false } },
  );

  let consulta = supabase
    .from(def.tabela)
    .select(def.colunas.join(","), { count: "exact" })
    .order(def.ordem, { ascending: true })
    .range(offset, offset + limit - 1);
  if (since && def.colunaAtualizacao) consulta = consulta.gte(def.colunaAtualizacao, since);
  if (ano !== null && def.colunaAno) consulta = consulta.eq(def.colunaAno, ano);

  const { data, error, count } = await consulta;
  if (error) {
    console.error("cerebro-export", recurso, error.code);
    return json({ error: "Erro ao consultar" }, 500);
  }

  const itens = filtrarColunas((data ?? []) as Record<string, unknown>[], def.colunas);
  return json({
    resource: recurso,
    generated_at: new Date().toISOString(),
    total: count ?? itens.length,
    limit,
    offset,
    items: itens,
  });
});

// Núcleo da função cerebro-export, sem dependência de Deno nem de Supabase,
// para poder ser testado fora das fontes.

export type Recurso = {
  tabela: string;
  // Allowlist: só estas colunas saem da fonte.
  colunas: readonly string[];
  // Coluna de ordenação estável para paginação.
  ordem: string;
  // Coluna usada pelo parâmetro ?since= (carga incremental), quando existir.
  colunaAtualizacao?: string;
  // Coluna de ano, para o parâmetro ?ano=, quando existir.
  colunaAno?: string;
};

export type Parametros = {
  recurso: string;
  since: string | null;
  ano: number | null;
  limit: number;
  offset: number;
};

export const LIMITE_PADRAO = 500;
export const LIMITE_MAXIMO = 1000;

const COLUNA_VALIDA = /^[a-z_][a-z0-9_]*$/;

// Compara a chave recebida com a esperada em tempo constante (compara os
// SHA-256, que têm sempre o mesmo tamanho). Sem chave configurada, nega.
export async function chaveValida(recebida: string | null, esperada: string | undefined): Promise<boolean> {
  if (!esperada || esperada.length < 32 || !recebida) return false;
  const enc = new TextEncoder();
  const [a, b] = await Promise.all([
    crypto.subtle.digest("SHA-256", enc.encode(recebida)),
    crypto.subtle.digest("SHA-256", enc.encode(esperada)),
  ]);
  const x = new Uint8Array(a);
  const y = new Uint8Array(b);
  let dif = 0;
  for (let i = 0; i < x.length; i++) dif |= x[i] ^ y[i];
  return dif === 0;
}

export function interpretarParametros(
  url: URL,
  recursos: Record<string, Recurso>,
): { ok: true; params: Parametros } | { ok: false; erro: string } {
  const recurso = url.searchParams.get("resource") ?? "";
  if (!Object.hasOwn(recursos, recurso)) {
    return { ok: false, erro: `resource inválido. Use: ${Object.keys(recursos).join(", ")}` };
  }

  const since = url.searchParams.get("since");
  if (since !== null && Number.isNaN(Date.parse(since))) {
    return { ok: false, erro: "since deve ser uma data ISO 8601" };
  }
  if (since !== null && !recursos[recurso].colunaAtualizacao) {
    return { ok: false, erro: `resource ${recurso} não aceita since` };
  }

  const anoTxt = url.searchParams.get("ano");
  const ano = anoTxt === null ? null : Number(anoTxt);
  if (ano !== null && (!Number.isInteger(ano) || ano < 2000 || ano > 2100)) {
    return { ok: false, erro: "ano inválido" };
  }
  if (ano !== null && !recursos[recurso].colunaAno) {
    return { ok: false, erro: `resource ${recurso} não aceita ano` };
  }

  const limit = inteiro(url.searchParams.get("limit"), LIMITE_PADRAO);
  const offset = inteiro(url.searchParams.get("offset"), 0);
  if (limit === null || limit < 1) return { ok: false, erro: "limit inválido" };
  if (offset === null || offset < 0) return { ok: false, erro: "offset inválido" };

  return {
    ok: true,
    params: { recurso, since, ano, limit: Math.min(limit, LIMITE_MAXIMO), offset },
  };
}

function inteiro(v: string | null, padrao: number): number | null {
  if (v === null || v === "") return padrao;
  const n = Number(v);
  return Number.isInteger(n) ? n : null;
}

// Garante que só colunas da allowlist saiam, mesmo que a consulta traga mais.
export function filtrarColunas(linhas: Record<string, unknown>[], colunas: readonly string[]): Record<string, unknown>[] {
  return linhas.map((linha) => {
    const saida: Record<string, unknown> = {};
    for (const c of colunas) if (Object.hasOwn(linha, c)) saida[c] = linha[c];
    return saida;
  });
}

// Confere a configuração na carga da função: nomes de coluna simples e
// nenhuma coluna proibida (dado pessoal, texto livre, credencial).
export function validarRecursos(recursos: Record<string, Recurso>, proibidas: readonly string[]): void {
  for (const [nome, r] of Object.entries(recursos)) {
    const todas = [...r.colunas, r.ordem, r.colunaAtualizacao, r.colunaAno].filter((c): c is string => !!c);
    for (const c of todas) {
      if (!COLUNA_VALIDA.test(c)) throw new Error(`coluna inválida em ${nome}: ${c}`);
    }
    for (const c of r.colunas) {
      if (proibidas.includes(c)) throw new Error(`coluna proibida em ${nome}: ${c}`);
    }
    if (!r.colunas.includes(r.ordem)) throw new Error(`ordem de ${nome} precisa estar nas colunas`);
  }
}

// Colunas que nunca podem sair de nenhuma fonte.
export const COLUNAS_PROIBIDAS = [
  "cpf", "customer_cpf", "customer_name", "customer_email", "customer_phone", "customer_address",
  "customer_birth_date", "paciente", "nome_paciente", "requester_name", "requester_phone",
  "responsavel", "technician", "description", "title", "notes", "observacao", "comments",
  "email", "phone", "telefone", "employee_name", "employee_email", "respondent_name",
  "respondent_email", "manager_name", "acesso_login", "acesso_site", "portal_login",
  "bank_account", "bank_agency", "bank_holder", "bank_holder_doc", "pix_key", "chave_pix",
  "dados_pagamento", "photo_url", "endereco", "address", "token", "public_token", "manager_token",
] as const;

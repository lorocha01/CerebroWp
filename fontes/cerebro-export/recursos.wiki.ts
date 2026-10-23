// Wiki + Suporte (mszdgutxihjenmsllyxa). Copiar como recursos.ts.
// Sem título, descrição, solicitante nem contatos da unidade.
import type { Recurso } from "./nucleo.ts";

export const RECURSOS: Record<string, Recurso> = {
  clients: {
    tabela: "clients",
    colunas: ["id", "name", "company", "region", "is_active", "updated_at"],
    ordem: "id",
    colunaAtualizacao: "updated_at",
  },
  regions: {
    tabela: "regions",
    colunas: ["id", "name"],
    ordem: "id",
  },
  categories: {
    tabela: "categories",
    colunas: ["id", "name", "type", "is_active"],
    ordem: "id",
  },
  tickets: {
    tabela: "tickets",
    colunas: [
      "id", "client_id", "category_id", "priority", "status", "asset_patrimony",
      "created_at", "updated_at", "due_date", "resolved_at",
    ],
    ordem: "id",
    colunaAtualizacao: "updated_at",
  },
};

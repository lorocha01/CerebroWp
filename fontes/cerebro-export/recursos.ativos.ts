// Gestão de Ativos (njgbhoyzfjwlhodvagyr). Copiar como recursos.ts.
// Sem responsável, foto, nota fiscal nem descrição/técnico de manutenção.
import type { Recurso } from "./nucleo.ts";

export const RECURSOS: Record<string, Recurso> = {
  locations: {
    tabela: "locations",
    colunas: ["id", "tenant_id", "name", "numero_loja", "created_at"],
    ordem: "id",
  },
  assets: {
    tabela: "assets",
    colunas: [
      "id", "tenant_id", "type", "status", "localizacao", "codigo_patrimonio", "fabricante",
      "modelo", "data_compra", "valor_compra", "compra_nova", "created_at",
    ],
    ordem: "id",
  },
  maintenance_records: {
    tabela: "maintenance_records",
    colunas: ["id", "tenant_id", "asset_id", "date", "type", "cost", "next_action_date", "created_at"],
    ordem: "id",
    colunaAtualizacao: "created_at",
  },
  location_history: {
    tabela: "location_history",
    colunas: ["id", "asset_id", "previous_location", "new_location", "changed_at"],
    ordem: "id",
    colunaAtualizacao: "changed_at",
  },
};

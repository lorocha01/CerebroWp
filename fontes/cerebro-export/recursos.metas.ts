// METAS - GRUPOWP (tldtynfxwmqirvpsmefw). Copiar como recursos.ts.
import type { Recurso } from "./nucleo.ts";

export const RECURSOS: Record<string, Recurso> = {
  units: {
    tabela: "units",
    colunas: ["id", "code", "name", "region_id", "include_in_marketing", "inactivated_at", "created_at"],
    ordem: "id",
  },
  regions: {
    tabela: "regions",
    colunas: ["id", "name"],
    ordem: "id",
  },
  revenue_entries: {
    tabela: "revenue_entries",
    colunas: ["id", "unit_id", "year", "month", "achieved_value", "last_updated_at"],
    ordem: "id",
    colunaAtualizacao: "last_updated_at",
    colunaAno: "year",
  },
  monthly_goals: {
    tabela: "monthly_goals",
    colunas: ["id", "unit_id", "year", "month", "goal_value", "updated_at"],
    ordem: "id",
    colunaAtualizacao: "updated_at",
    colunaAno: "year",
  },
  group_reports: {
    tabela: "group_reports",
    colunas: ["id", "year", "month", "period_start", "period_end", "total_pedidos", "total_exames", "total_value", "created_at"],
    ordem: "id",
    colunaAtualizacao: "created_at",
    colunaAno: "year",
  },
  group_report_postos: {
    tabela: "group_report_postos",
    colunas: ["id", "report_id", "posto_code", "posto_name", "num_pedidos", "num_exames", "total_value"],
    ordem: "id",
  },
  group_report_convenios: {
    tabela: "group_report_convenios",
    colunas: [
      "id", "report_id", "posto_code", "convenio_code", "convenio_name", "num_pedidos", "num_exames",
      "total_exames", "acrescimo", "desconto", "diferenca_assumida", "rec_a_maior", "total_convenio",
    ],
    ordem: "id",
  },
};

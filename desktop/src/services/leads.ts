import { api } from "./api";
import type { Lead, EnrichmentData, Proposal } from "../types/lead";

export const leadsService = {
  list: (params?: { industry?: string; search?: string; status?: string }) => {
    const q = new URLSearchParams(
      Object.entries(params ?? {}).filter(([, v]) => v) as [string, string][],
    ).toString();
    return api.get<Lead[]>(`/leads${q ? `?${q}` : ""}`);
  },

  get: (id: string) => api.get<Lead>(`/leads/${id}`),

  getEnrichment: (id: string) =>
    api.get<EnrichmentData>(`/leads/${id}/enrichment`),

  enrich: (id: string) => api.post<EnrichmentData>(`/leads/${id}/enrich`, {}),

  getProposals: (id: string) =>
    api.get<Proposal[]>(`/leads/${id}/proposals`),

  createProposal: (leadId: string, data: Partial<Proposal>) =>
    api.post<Proposal>(`/leads/${leadId}/proposals`, data),

  updateProposal: (leadId: string, proposalId: string, data: Partial<Proposal>) =>
    api.patch<Proposal>(`/leads/${leadId}/proposals/${proposalId}`, data),
};

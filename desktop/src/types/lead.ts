export interface Lead {
  id: string;
  companyName: string;
  contactName?: string;
  email?: string;
  phone?: string;
  industry: string;
  location: string;
  score: number; // 0–100
  status: "new" | "contacted" | "qualified" | "proposal_sent" | "closed";
  enriched: boolean;
  createdAt: string;
  updatedAt: string;
}

export interface EnrichmentData {
  leadId: string;
  description?: string;
  projectValue?: number;
  permits?: Permit[];
  contactQuality: "low" | "medium" | "high";
  lastActivity?: string;
}

export interface Permit {
  id: string;
  type: string;
  value?: number;
  status: string;
  date: string;
}

export interface Proposal {
  id: string;
  leadId: string;
  title: string;
  content: string; // TipTap JSON
  status: "draft" | "sent" | "accepted" | "rejected";
  createdAt: string;
  updatedAt: string;
}

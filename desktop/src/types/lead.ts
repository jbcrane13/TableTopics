export interface Contact {
  id: string;
  initials: string;
  name: string;
  title: string;
  confidence: number; // 0-100
  avatarGradient: 'purple' | 'ember' | 'cyan';
}

export interface ScoreBreakdown {
  label: string;
  value: string;
  pct: number; // 0-100
  barType: 'ember' | 'gold' | 'success' | 'info';
}

export interface EnrichmentInsights {
  businessChallenges: string[];
  techStack: string[];
  aiSignals: string[];
}

export interface RecentPermit {
  property: string;
  type: string;
  value: string;
  date: string;
}

export interface Lead {
  id: string;
  companyName: string;
  emoji: string;
  score: number;
  scoreType: 'hot' | 'warm' | 'cool';
  contractor: string;
  owner: string;
  location: string;
  projectValue: string;
  sqft: string;
  permitType: string;
  filedDate: string;
  estFurnitureValue: string;
  status: 'new' | 'contacted' | 'qualified' | 'proposal_sent';
  contacts: Contact[];
  scoreBreakdown: ScoreBreakdown[];
  enrichment: EnrichmentInsights;
  permits: RecentPermit[];
  verifiedCount: number;
}

export interface EnrichmentData {
  leadId: string;
  description?: string;
  projectValue?: number;
  permits?: Permit[];
  contactQuality: 'low' | 'medium' | 'high';
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
  content: string;
  status: 'draft' | 'sent' | 'accepted' | 'rejected';
  createdAt: string;
  updatedAt: string;
}

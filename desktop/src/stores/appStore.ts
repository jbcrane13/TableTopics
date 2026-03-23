import { create } from 'zustand';
import type { Lead } from '../types/lead';

const MOCK_LEADS: Lead[] = [
  {
    id: 'lead-1',
    companyName: 'Walt Disney World Resort',
    emoji: '🏰',
    score: 96,
    scoreType: 'hot',
    contractor: 'Turner Construction',
    owner: 'Walt Disney Co.',
    location: 'Orlando, FL',
    projectValue: '$4.2M',
    sqft: '48,000',
    permitType: 'Commercial Interior',
    filedDate: 'Jan 15, 2026',
    estFurnitureValue: '$380,000',
    status: 'new',
    verifiedCount: 3,
    contacts: [
      { id: 'c1', initials: 'TL', name: 'Tom Lawson', title: 'Director of Procurement', confidence: 96, avatarGradient: 'purple' },
      { id: 'c2', initials: 'AK', name: 'Amy Kim', title: 'VP Interior Design', confidence: 91, avatarGradient: 'ember' },
    ],
    scoreBreakdown: [
      { label: 'Project Size', value: '$4.2M', pct: 92, barType: 'gold' },
      { label: 'Contractor Reputation', value: 'Tier 1 national', pct: 98, barType: 'ember' },
      { label: 'Contact Availability', value: '3 verified', pct: 85, barType: 'success' },
      { label: 'Industry Fit', value: 'Theme Parks', pct: 88, barType: 'info' },
    ],
    enrichment: {
      businessChallenges: ['Expansion timeline pressure', 'Guest experience mandates', 'Brand consistency'],
      techStack: ['SAP', 'Oracle', 'Procore', 'Autodesk'],
      aiSignals: ['Multi-phase expansion underway', 'New resort hotel', '$2B capital plan', 'Procurement modernizing'],
    },
    permits: [
      { property: 'Disney Springs Renovation', type: 'Commercial Interior', value: '$4.2M', date: '01/2026' },
      { property: 'Grand Floridian Resort', type: 'FF&E Replacement', value: '$1.2M', date: '11/2025' },
    ],
  },
  {
    id: 'lead-2',
    companyName: 'Marriott Bethesda Renovation',
    emoji: '🏢',
    score: 96,
    scoreType: 'hot',
    contractor: 'Turner Construction',
    owner: 'Marriott International',
    location: 'Bethesda, MD',
    projectValue: '$4.2M',
    sqft: '48,000',
    permitType: 'Commercial Interior',
    filedDate: 'Jan 15, 2026',
    estFurnitureValue: '$450,000',
    status: 'qualified',
    verifiedCount: 3,
    contacts: [
      { id: 'c1', initials: 'SC', name: 'Sarah Chen', title: 'VP of Procurement', confidence: 98, avatarGradient: 'purple' },
      { id: 'c2', initials: 'JR', name: 'James Rodriguez', title: 'Director, Interior Design', confidence: 95, avatarGradient: 'ember' },
      { id: 'c3', initials: 'MP', name: 'Michelle Park', title: 'Procurement Manager', confidence: 87, avatarGradient: 'cyan' },
    ],
    scoreBreakdown: [
      { label: 'Project Size', value: '$4.2M', pct: 92, barType: 'gold' },
      { label: 'Contractor Reputation', value: 'Tier 1 national', pct: 98, barType: 'ember' },
      { label: 'Contact Availability', value: '3 verified', pct: 85, barType: 'success' },
      { label: 'Industry Fit', value: 'Hotels & Hospitality', pct: 95, barType: 'info' },
    ],
    enrichment: {
      businessChallenges: ['Renovation timeline pressure', 'Sustainability mandates', 'Budget optimization'],
      techStack: ['Oracle', 'Salesforce', 'SAP', 'Procore', 'Workday'],
      aiSignals: ['Multi-property renovation cycle', 'New F&B concepts', '$500M capital plan', 'Procurement expanding'],
    },
    permits: [
      { property: 'Bethesda Marriott HQ', type: 'Commercial Interior', value: '$4.2M', date: '01/2026' },
      { property: 'JW Marriott Orlando', type: 'FF&E Replacement', value: '$890K', date: '12/2025' },
      { property: 'Marriott Marquis DC', type: 'Restaurant Refresh', value: '$520K', date: '11/2025' },
    ],
  },
  {
    id: 'lead-3',
    companyName: 'Hilton Orlando Tower E…',
    emoji: '🏨',
    score: 91,
    scoreType: 'hot',
    contractor: 'Hensel Phelps',
    owner: 'Hilton Worldwide',
    location: 'Orlando, FL',
    projectValue: '$12.8M',
    sqft: '120,000',
    permitType: 'Hotel Renovation',
    filedDate: 'Dec 10, 2025',
    estFurnitureValue: '$1,200,000',
    status: 'contacted',
    verifiedCount: 2,
    contacts: [
      { id: 'c1', initials: 'BR', name: 'Brian Rhodes', title: 'SVP Capital Projects', confidence: 92, avatarGradient: 'cyan' },
      { id: 'c2', initials: 'KL', name: 'Karen Liu', title: 'Director Procurement', confidence: 89, avatarGradient: 'purple' },
    ],
    scoreBreakdown: [
      { label: 'Project Size', value: '$12.8M', pct: 99, barType: 'gold' },
      { label: 'Contractor Reputation', value: 'Tier 1 regional', pct: 90, barType: 'ember' },
      { label: 'Contact Availability', value: '2 verified', pct: 72, barType: 'success' },
      { label: 'Industry Fit', value: 'Hotels & Hospitality', pct: 95, barType: 'info' },
    ],
    enrichment: {
      businessChallenges: ['Brand standards refresh', 'Guest satisfaction scores', 'Competitive positioning'],
      techStack: ['Oracle OPERA', 'Hilton eBuy', 'Procore'],
      aiSignals: ['Tower E expansion project', 'Convention center adjacent', '$2B global capital plan'],
    },
    permits: [
      { property: 'Hilton Orlando Tower E', type: 'Hotel Renovation', value: '$12.8M', date: '12/2025' },
      { property: 'Hilton Bonnet Creek', type: 'FF&E', value: '$2.1M', date: '10/2025' },
    ],
  },
  {
    id: 'lead-4',
    companyName: 'Darden HQ Lobby Remo…',
    emoji: '🍽️',
    score: 78,
    scoreType: 'warm',
    contractor: 'Brasfield & Gorrie',
    owner: 'Darden Restaurants',
    location: 'Orlando, FL',
    projectValue: '$1.8M',
    sqft: '15,000',
    permitType: 'Office Renovation',
    filedDate: 'Nov 5, 2025',
    estFurnitureValue: '$180,000',
    status: 'new',
    verifiedCount: 2,
    contacts: [
      { id: 'c1', initials: 'DW', name: 'David Walsh', title: 'Facilities Director', confidence: 84, avatarGradient: 'ember' },
      { id: 'c2', initials: 'PN', name: 'Priya Nair', title: 'Office Manager', confidence: 76, avatarGradient: 'cyan' },
    ],
    scoreBreakdown: [
      { label: 'Project Size', value: '$1.8M', pct: 72, barType: 'gold' },
      { label: 'Contractor Reputation', value: 'Tier 2 regional', pct: 80, barType: 'ember' },
      { label: 'Contact Availability', value: '2 verified', pct: 68, barType: 'success' },
      { label: 'Industry Fit', value: 'Restaurant Corp', pct: 82, barType: 'info' },
    ],
    enrichment: {
      businessChallenges: ['Return-to-office initiative', 'Brand refresh', 'Cost control'],
      techStack: ['SAP', 'Workday', 'Procore'],
      aiSignals: ['HQ relocation cancelled', 'Lobby refresh approved', 'Q1 2026 start'],
    },
    permits: [
      { property: 'Darden Corporate HQ', type: 'Office Renovation', value: '$1.8M', date: '11/2025' },
    ],
  },
  {
    id: 'lead-5',
    companyName: 'Ritz-Carlton DC Res…',
    emoji: '✨',
    score: 74,
    scoreType: 'warm',
    contractor: 'Clark Construction',
    owner: 'Marriott International',
    location: 'Washington, DC',
    projectValue: '$3.5M',
    sqft: '8,200',
    permitType: 'Luxury Hotel Refresh',
    filedDate: 'Oct 20, 2025',
    estFurnitureValue: '$320,000',
    status: 'proposal_sent',
    verifiedCount: 1,
    contacts: [
      { id: 'c1', initials: 'EV', name: 'Elena Vasquez', title: 'General Manager', confidence: 88, avatarGradient: 'purple' },
    ],
    scoreBreakdown: [
      { label: 'Project Size', value: '$3.5M', pct: 82, barType: 'gold' },
      { label: 'Contractor Reputation', value: 'Tier 1 DC', pct: 92, barType: 'ember' },
      { label: 'Contact Availability', value: '1 verified', pct: 45, barType: 'success' },
      { label: 'Industry Fit', value: 'Luxury Hotels', pct: 96, barType: 'info' },
    ],
    enrichment: {
      businessChallenges: ['Luxury standard maintenance', 'Forbes 5-star requirements', 'Seasonal constraints'],
      techStack: ['Oracle OPERA', 'Marriott Global Procurement'],
      aiSignals: ['Restaurant renovation permit filed', 'New F&B concept planned', 'Spring 2026 opening'],
    },
    permits: [
      { property: 'Ritz-Carlton Georgetown', type: 'Luxury Hotel Refresh', value: '$3.5M', date: '10/2025' },
    ],
  },
  {
    id: 'lead-6',
    companyName: 'Cracker Barrel Lebanon R…',
    emoji: '🪑',
    score: 62,
    scoreType: 'cool',
    contractor: 'Messer Construction',
    owner: 'Cracker Barrel Old Country Store',
    location: 'Lebanon, TN',
    projectValue: '$980K',
    sqft: '6,500',
    permitType: 'Restaurant Renovation',
    filedDate: 'Sep 15, 2025',
    estFurnitureValue: '$95,000',
    status: 'new',
    verifiedCount: 0,
    contacts: [
      { id: 'c1', initials: 'RH', name: 'Robert Hale', title: 'VP Store Development', confidence: 71, avatarGradient: 'cyan' },
    ],
    scoreBreakdown: [
      { label: 'Project Size', value: '$980K', pct: 45, barType: 'gold' },
      { label: 'Contractor Reputation', value: 'Regional', pct: 65, barType: 'ember' },
      { label: 'Contact Availability', value: '0 verified', pct: 30, barType: 'success' },
      { label: 'Industry Fit', value: 'Casual Dining', pct: 70, barType: 'info' },
    ],
    enrichment: {
      businessChallenges: ['Cost reduction mandate', 'Store refresh program', 'Supply chain constraints'],
      techStack: ['Oracle Retail', 'Manhattan Associates'],
      aiSignals: ['300-store refresh program', 'Annual renovation budget', 'Vendor consolidation underway'],
    },
    permits: [
      { property: 'Cracker Barrel Lebanon', type: 'Restaurant Renovation', value: '$980K', date: '09/2025' },
    ],
  },
  {
    id: 'lead-7',
    companyName: 'Wyndham Conference C…',
    emoji: '🏛️',
    score: 55,
    scoreType: 'cool',
    contractor: 'Structure Tone',
    owner: 'Wyndham Hotels & Resorts',
    location: 'Parsippany, NJ',
    projectValue: '$2.1M',
    sqft: '22,000',
    permitType: 'Conference Center',
    filedDate: 'Aug 30, 2025',
    estFurnitureValue: '$210,000',
    status: 'new',
    verifiedCount: 0,
    contacts: [
      { id: 'c1', initials: 'GT', name: 'Greg Turner', title: 'Director of Facilities', confidence: 63, avatarGradient: 'ember' },
    ],
    scoreBreakdown: [
      { label: 'Project Size', value: '$2.1M', pct: 58, barType: 'gold' },
      { label: 'Contractor Reputation', value: 'Tier 2', pct: 60, barType: 'ember' },
      { label: 'Contact Availability', value: '0 verified', pct: 25, barType: 'success' },
      { label: 'Industry Fit', value: 'Hotels', pct: 72, barType: 'info' },
    ],
    enrichment: {
      businessChallenges: ['Meeting room utilization', 'Hybrid work accommodation', 'AV modernization'],
      techStack: ['Delphi', 'Salesforce', 'Cvent'],
      aiSignals: ['Conference center expansion', 'Corporate travel rebound', 'Q3 2026 target'],
    },
    permits: [
      { property: 'Wyndham Conference HQ', type: 'Conference Center', value: '$2.1M', date: '08/2025' },
    ],
  },
];

interface AppFilters {
  search: string;
  status: 'all' | 'hot' | 'new' | 'qualified';
  scoreRange: [number, number];
}

interface AppStore {
  leads: Lead[];
  selectedLeadId: string | null;
  filters: AppFilters;
  copilotMode: 'draft' | 'enrich' | 'respond' | 'research';
  selectLead: (id: string) => void;
  setFilter: (filters: Partial<AppFilters>) => void;
  setCopilotMode: (mode: AppStore['copilotMode']) => void;
  filteredLeads: () => Lead[];
}

export const useAppStore = create<AppStore>((set, get) => ({
  leads: MOCK_LEADS,
  selectedLeadId: 'lead-2',
  filters: { search: '', status: 'all', scoreRange: [0, 100] },
  copilotMode: 'draft',

  selectLead: (id) => set({ selectedLeadId: id }),
  setFilter: (f) => set((s) => ({ filters: { ...s.filters, ...f } })),
  setCopilotMode: (mode) => set({ copilotMode: mode }),

  filteredLeads: () => {
    const { leads, filters } = get();
    return leads.filter((lead) => {
      if (filters.search) {
        const q = filters.search.toLowerCase();
        if (!lead.companyName.toLowerCase().includes(q) && !lead.contractor.toLowerCase().includes(q)) return false;
      }
      if (filters.status === 'hot') return lead.scoreType === 'hot';
      if (filters.status === 'new') return lead.status === 'new';
      if (filters.status === 'qualified') return lead.status === 'qualified';
      return true;
    });
  },
}));

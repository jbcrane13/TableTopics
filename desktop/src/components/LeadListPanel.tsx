import { useState } from 'react';
import { useAppStore } from '../stores/appStore';
import type { Lead } from '../types/lead';

const SCORE_COLORS: Record<string, string> = {
  hot: 'var(--color-ember)',
  warm: 'var(--color-gold)',
  cool: 'var(--color-info)',
};
const SCORE_BG: Record<string, string> = {
  hot: 'var(--color-ember-soft)',
  warm: 'var(--color-gold-soft)',
  cool: 'var(--color-info-soft)',
};
const STATUS_COLORS: Record<string, string> = {
  new: 'var(--color-success)',
  contacted: 'var(--color-gold)',
  qualified: 'var(--color-ember)',
  proposal_sent: 'var(--color-info)',
};
const STATUS_LABELS: Record<string, string> = {
  new: 'New', contacted: 'Contacted', qualified: 'Qualified', proposal_sent: 'Proposal Sent',
};

function LeadCard({ lead, selected, onClick, delay }: {
  lead: Lead; selected: boolean; onClick: () => void; delay: number;
}) {
  const [hovered, setHovered] = useState(false);

  return (
    <div
      className={`animate-in delay-${delay}`}
      onClick={onClick}
      onMouseEnter={() => setHovered(true)}
      onMouseLeave={() => setHovered(false)}
      style={{
        padding: '10px 12px', borderRadius: 8, cursor: 'pointer',
        transition: 'all 0.15s', position: 'relative',
        border: `1px solid ${selected ? 'var(--color-border-medium)' : 'transparent'}`,
        background: selected || hovered ? 'var(--color-bg-card)' : 'transparent',
      }}
    >
      {selected && (
        <div style={{
          position: 'absolute', left: 0, top: 8, bottom: 8,
          width: 2, background: 'var(--color-ember)', borderRadius: 2,
        }} />
      )}
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', marginBottom: 2 }}>
        <span style={{ fontSize: 13, fontWeight: 600, color: 'var(--color-text-primary)', lineHeight: 1.3 }}>
          {lead.companyName}
        </span>
        <span style={{
          fontFamily: 'var(--font-mono)', fontSize: 11, fontWeight: 500,
          padding: '1px 6px', borderRadius: 4, flexShrink: 0,
          color: SCORE_COLORS[lead.scoreType], background: SCORE_BG[lead.scoreType],
        }}>
          {lead.score}
        </span>
      </div>
      <div style={{ fontSize: 11, color: 'var(--color-text-muted)', display: 'flex', gap: 6, alignItems: 'center', marginTop: 1 }}>
        <span>🏗</span>
        <span style={{ color: 'var(--color-text-secondary)' }}>{lead.contractor}</span>
      </div>
      <div style={{ fontSize: 10.5, color: 'var(--color-text-muted)', display: 'flex', gap: 6, alignItems: 'center', marginTop: 3 }}>
        <span>{lead.projectValue}</span>
        <span>·</span>
        <span>{lead.sqft} sqft</span>
        <div style={{ marginLeft: 'auto', display: 'flex', alignItems: 'center', gap: 6 }}>
          <span style={{ display: 'flex', alignItems: 'center', gap: 3 }}>
            <span style={{
              width: 6, height: 6, borderRadius: '50%', display: 'inline-block',
              background: STATUS_COLORS[lead.status],
            }} />
            {STATUS_LABELS[lead.status]}
          </span>
          {lead.verifiedCount > 0 && (
            <span style={{ fontSize: 10, color: 'var(--color-success)', display: 'flex', alignItems: 'center', gap: 2 }}>
              ✓ {lead.verifiedCount} verified
            </span>
          )}
        </div>
      </div>
    </div>
  );
}

export default function LeadListPanel() {
  const { selectedLeadId, selectLead, filters, setFilter, filteredLeads } = useAppStore();
  const leads = filteredLeads();
  const filterOptions = ['All', 'Hot', 'New', 'Qualified'] as const;

  return (
    <aside style={{
      width: 262, background: 'var(--color-bg-surface)',
      borderRight: '1px solid var(--color-border-subtle)',
      display: 'flex', flexDirection: 'column', flexShrink: 0,
    }}>
      {/* Header */}
      <div style={{ padding: '14px 14px 10px', display: 'flex', flexDirection: 'column', gap: 10 }}>
        {/* Search */}
        <div style={{
          display: 'flex', alignItems: 'center', gap: 8,
          background: 'var(--color-bg-card)', border: '1px solid var(--color-border-subtle)',
          borderRadius: 8, padding: '7px 10px',
        }}>
          <span style={{ fontSize: 13, color: 'var(--color-text-muted)' }}>⌕</span>
          <input
            value={filters.search}
            onChange={(e) => setFilter({ search: e.target.value })}
            placeholder="Search companies, contacts…"
            style={{
              background: 'none', border: 'none', outline: 'none',
              color: 'var(--color-text-primary)', fontSize: 12.5, fontFamily: 'inherit', width: '100%',
            }}
          />
        </div>
        {/* Filter chips */}
        <div style={{ display: 'flex', gap: 6 }}>
          {filterOptions.map((f) => {
            const active = filters.status === f.toLowerCase() || (f === 'All' && filters.status === 'all');
            return (
              <button
                key={f}
                onClick={() => setFilter({ status: f === 'All' ? 'all' : f.toLowerCase() as any })}
                style={{
                  fontSize: 11, padding: '3px 9px', borderRadius: 20,
                  border: `1px solid ${active ? 'rgba(232,103,42,0.3)' : 'var(--color-border-subtle)'}`,
                  background: active ? 'var(--color-ember-soft)' : 'transparent',
                  color: active ? 'var(--color-ember)' : 'var(--color-text-secondary)',
                  cursor: 'pointer', fontFamily: 'inherit',
                }}
              >{f}</button>
            );
          })}
        </div>
      </div>

      {/* Lead list */}
      <div style={{
        flex: 1, overflowY: 'auto', padding: 6,
        display: 'flex', flexDirection: 'column', gap: 2,
      }}>
        {leads.map((lead, i) => (
          <LeadCard
            key={lead.id}
            lead={lead}
            selected={lead.id === selectedLeadId}
            onClick={() => selectLead(lead.id)}
            delay={Math.min(i + 1, 7)}
          />
        ))}
      </div>

      {/* Footer */}
      <div style={{
        padding: '10px 14px',
        borderTop: '1px solid var(--color-border-subtle)',
        display: 'flex', justifyContent: 'space-between', alignItems: 'center',
      }}>
        <span style={{ fontSize: 11, color: 'var(--color-text-muted)' }}>47 leads · 12 hot</span>
        <button style={{
          background: 'var(--color-ember)', border: 'none', color: '#fff',
          fontSize: 11, fontWeight: 600, padding: '5px 12px',
          borderRadius: 6, cursor: 'pointer', fontFamily: 'inherit',
        }}>+ New Lead</button>
      </div>
    </aside>
  );
}

import { useState } from 'react';
import { useAppStore } from '../stores/appStore';

const TABS = [
  { id: 'draft' as const, label: '🖊 Proposal' },
  { id: 'enrich' as const, label: '✉ Email' },
  { id: 'respond' as const, label: '↩ Reply' },
  { id: 'research' as const, label: '🔍 Research' },
];

export default function CopilotPanel() {
  const { leads, selectedLeadId, copilotMode, setCopilotMode } = useAppStore();
  const lead = leads.find((l) => l.id === selectedLeadId);
  const [input, setInput] = useState('');

  return (
    <aside style={{
      width: 320, background: 'var(--color-bg-surface)',
      borderLeft: '1px solid var(--color-border-subtle)',
      display: 'flex', flexDirection: 'column', flexShrink: 0,
    }}>
      {/* Header */}
      <div style={{
        padding: '14px 16px', borderBottom: '1px solid var(--color-border-subtle)',
        display: 'flex', alignItems: 'center', justifyContent: 'space-between',
      }}>
        <div style={{ fontSize: 12.5, fontWeight: 600, color: 'var(--color-text-primary)', display: 'flex', alignItems: 'center', gap: 6 }}>
          <div style={{
            width: 7, height: 7, borderRadius: '50%',
            background: 'var(--color-success)', animation: 'pulse 2s ease-in-out infinite',
          }} />
          Copilot
          <span style={{
            fontSize: 9, padding: '1px 6px', borderRadius: 4,
            background: 'var(--color-ember-soft)', color: 'var(--color-ember)', fontWeight: 600,
          }}>AI</span>
        </div>
        <button style={{
          background: 'none', border: 'none', color: 'var(--color-text-secondary)',
          fontSize: 10, cursor: 'pointer', fontFamily: 'inherit',
        }}>⊟</button>
      </div>

      {/* Tabs */}
      <div style={{ display: 'flex', gap: 4, padding: '10px 16px 6px' }}>
        {TABS.map((tab) => {
          const active = copilotMode === tab.id;
          return (
            <button
              key={tab.id}
              onClick={() => setCopilotMode(tab.id)}
              style={{
                fontSize: 11, padding: '4px 10px', borderRadius: 6,
                border: `1px solid ${active ? 'rgba(232,103,42,0.3)' : 'var(--color-border-subtle)'}`,
                background: active ? 'var(--color-ember-soft)' : 'transparent',
                color: active ? 'var(--color-ember)' : 'var(--color-text-muted)',
                cursor: 'pointer', fontFamily: 'inherit', fontWeight: 500,
              }}
            >{tab.label}</button>
          );
        })}
      </div>

      {/* Context tags */}
      {lead && (
        <div style={{ padding: '8px 16px 4px' }}>
          <div style={{
            fontSize: 10, textTransform: 'uppercase', letterSpacing: '0.6px',
            color: 'var(--color-text-muted)', marginBottom: 6, fontWeight: 600,
          }}>Context</div>
          <div style={{ display: 'flex', flexWrap: 'wrap', gap: 4 }}>
            {[
              lead.owner,
              lead.permitType,
              lead.contacts[0] ? `${lead.contacts[0].name}, ${lead.contacts[0].title}` : null,
              lead.projectValue,
            ]
              .filter(Boolean)
              .map((tag) => (
                <span key={tag as string} style={{
                  fontSize: 10.5, padding: '2px 8px', borderRadius: 4,
                  background: 'var(--color-bg-elevated)', color: 'var(--color-text-secondary)',
                }}>{tag}</span>
              ))}
          </div>
        </div>
      )}

      {/* Chat area */}
      <div style={{
        flex: 1, overflowY: 'auto', padding: '12px 16px',
        display: 'flex', flexDirection: 'column', gap: 12,
      }}>
        {lead ? (
          <div style={{
            background: 'var(--color-bg-card)', border: '1px solid var(--color-border-subtle)',
            borderRadius: 10, padding: '14px 16px',
            fontSize: 12.5, color: 'var(--color-text-secondary)', lineHeight: 1.65,
          }}>
            <div style={{
              fontSize: 10.5, fontWeight: 600, color: 'var(--color-ember)',
              textTransform: 'uppercase', letterSpacing: '0.5px',
              display: 'flex', alignItems: 'center', gap: 4, marginBottom: 4,
            }}>✦ Generated Draft</div>
            <div style={{
              fontFamily: 'var(--font-serif)', fontSize: 16,
              color: 'var(--color-text-primary)', marginBottom: 10, lineHeight: 1.3,
            }}>Custom Furniture for {lead.companyName.replace('…', '')}</div>

            Dear {lead.contacts[0]?.name ?? 'Procurement Team'},
            <br /><br />
            We noticed your {lead.permitType.toLowerCase()} project in {lead.location} — a {lead.sqft} sqft build by {lead.contractor}. Table Topics specializes in hospitality-grade custom furniture, and we'd love to support this project.
            <br /><br />
            With the {lead.projectValue} scope, we can offer competitive lead times on custom tables, surfaces, and millwork — all manufactured in-house for quality and speed.
            <br /><br />
            <strong style={{ color: 'var(--color-text-primary)', fontWeight: 600 }}>Proposed approach:</strong>
            <br />
            1. Site review + design consultation<br />
            2. Custom samples and material selection<br />
            3. Production and phased delivery
            <br /><br />
            <div style={{ fontFamily: 'var(--font-mono)', fontSize: 11, color: 'var(--color-gold)', marginTop: 10 }}>
              Est. value: {lead.estFurnitureValue} · from permit + enrichment data
            </div>
          </div>
        ) : (
          <div style={{
            flex: 1, display: 'flex', alignItems: 'center', justifyContent: 'center',
            color: 'var(--color-text-muted)', fontSize: 12, textAlign: 'center', padding: 16,
          }}>
            Select a lead to use the copilot
          </div>
        )}
      </div>

      {/* Input */}
      <div style={{ padding: '12px 16px', borderTop: '1px solid var(--color-border-subtle)' }}>
        <div style={{
          display: 'flex', alignItems: 'center', gap: 8,
          background: 'var(--color-bg-card)', border: '1px solid var(--color-border-subtle)',
          borderRadius: 8, padding: '8px 12px',
        }}>
          <input
            value={input}
            onChange={(e) => setInput(e.target.value)}
            placeholder="Refine or ask a follow-up…"
            style={{
              background: 'none', border: 'none', outline: 'none',
              color: 'var(--color-text-primary)', fontSize: 12.5, fontFamily: 'inherit', width: '100%',
            }}
          />
          <button style={{
            background: 'var(--color-ember)', border: 'none', color: '#fff',
            width: 26, height: 26, borderRadius: 6,
            cursor: 'pointer', display: 'flex', alignItems: 'center', justifyContent: 'center',
            fontSize: 12, flexShrink: 0,
          }}>→</button>
        </div>
      </div>
    </aside>
  );
}

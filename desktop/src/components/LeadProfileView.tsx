import { useAppStore } from '../stores/appStore';

const AVATAR_GRADIENTS: Record<string, string> = {
  purple: 'linear-gradient(135deg, #6366F1, #8B5CF6)',
  ember: 'linear-gradient(135deg, #E8672A, #F59E0B)',
  cyan: 'linear-gradient(135deg, #06B6D4, #3B82F6)',
};

const STATUS_STYLES: Record<string, { bg: string; color: string; label: string }> = {
  qualified: { bg: 'rgba(74,222,128,0.12)', color: '#4ADE80', label: '● Qualified' },
  new: { bg: 'rgba(74,222,128,0.12)', color: '#4ADE80', label: '● New' },
  contacted: { bg: 'rgba(212,168,71,0.12)', color: '#D4A847', label: '● Contacted' },
  proposal_sent: { bg: 'rgba(124,156,191,0.1)', color: '#7C9CBF', label: '● Proposal Sent' },
};

export default function LeadProfileView() {
  const { leads, selectedLeadId } = useAppStore();
  const lead = leads.find((l) => l.id === selectedLeadId);

  if (!lead) {
    return (
      <main style={{
        flex: 1, display: 'flex', alignItems: 'center', justifyContent: 'center',
        background: 'var(--color-bg-deep)', color: 'var(--color-text-muted)', fontSize: 13,
      }}>
        Select a lead to get started
      </main>
    );
  }

  const statusStyle = STATUS_STYLES[lead.status] ?? STATUS_STYLES['new'];

  return (
    <main style={{
      flex: 1, display: 'flex', flexDirection: 'column', overflow: 'hidden',
      background: 'var(--color-bg-deep)', position: 'relative',
    }}>
      {/* Ember glow */}
      <div style={{
        position: 'absolute', top: -100, right: -100,
        width: 500, height: 500,
        background: 'radial-gradient(circle, rgba(232,103,42,0.08), transparent 70%)',
        pointerEvents: 'none', zIndex: 0,
      }} />

      {/* Profile header */}
      <div className="animate-in delay-2" style={{ padding: '20px 28px 0', position: 'relative', zIndex: 1 }}>
        <div style={{ display: 'flex', alignItems: 'flex-start', gap: 16, marginBottom: 8 }}>
          {/* Icon */}
          <div style={{
            width: 44, height: 44, borderRadius: 10,
            background: 'var(--color-bg-elevated)', border: '1px solid var(--color-border-subtle)',
            display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: 18, flexShrink: 0,
          }}>{lead.emoji}</div>

          {/* Info */}
          <div style={{ flex: 1 }}>
            <div style={{
              fontFamily: 'var(--font-serif)', fontSize: 24, fontWeight: 400,
              color: 'var(--color-text-primary)', lineHeight: 1.2,
              display: 'flex', alignItems: 'center', gap: 10,
            }}>
              {lead.companyName}
              <span style={{
                fontFamily: 'var(--font-mono)', fontSize: 13, fontWeight: 600,
                width: 32, height: 32, borderRadius: '50%',
                display: 'inline-flex', alignItems: 'center', justifyContent: 'center',
                background: 'rgba(232,103,42,0.15)', color: '#E8672A',
                border: '2px solid #E8672A', flexShrink: 0,
              }}>{lead.score}</span>
            </div>
            <div style={{
              fontSize: 12, color: 'var(--color-text-secondary)', marginTop: 4,
              display: 'flex', gap: 12, alignItems: 'center',
            }}>
              <span>🏗 {lead.owner}</span>
              <span style={{ color: 'var(--color-text-muted)' }}>·</span>
              <span>{lead.location}</span>
              <span style={{ color: 'var(--color-text-muted)' }}>·</span>
              <span>{lead.contractor}</span>
            </div>
            <div style={{ display: 'flex', alignItems: 'center', gap: 12, marginTop: 6 }}>
              <span style={{
                fontSize: 10.5, padding: '2px 10px', borderRadius: 20, fontWeight: 500,
                background: statusStyle.bg, color: statusStyle.color,
              }}>{statusStyle.label}</span>
              <span style={{ fontSize: 11, color: 'var(--color-text-muted)' }}>Est. furniture value</span>
              <span style={{ fontSize: 13, fontWeight: 600, color: 'var(--color-gold)', fontFamily: 'var(--font-mono)' }}>
                {lead.estFurnitureValue}
              </span>
            </div>
          </div>

          {/* Actions */}
          <div style={{ display: 'flex', gap: 8, flexShrink: 0 }}>
            <button style={{
              background: 'var(--color-ember)', border: '1px solid var(--color-ember)', color: '#fff',
              fontSize: 12, padding: '6px 14px', borderRadius: 7, cursor: 'pointer',
              fontFamily: 'inherit', fontWeight: 500,
            }}>✦ AI Proposal</button>
            <button style={{
              background: 'var(--color-bg-card)', border: '1px solid var(--color-border-subtle)',
              color: 'var(--color-text-secondary)', fontSize: 12, padding: '6px 14px',
              borderRadius: 7, cursor: 'pointer', fontFamily: 'inherit', fontWeight: 500,
            }}>⋯</button>
          </div>
        </div>
      </div>

      {/* Project stats row */}
      <div className="animate-in delay-3" style={{
        display: 'grid', gridTemplateColumns: 'repeat(4, 1fr)', gap: 10,
        margin: '16px 28px 0', position: 'relative', zIndex: 1,
      }}>
        {[
          { icon: '$', iconClass: 'money', value: lead.projectValue, label: 'Project Size', bg: 'var(--color-gold-soft)', color: 'var(--color-gold)' },
          { icon: '⊞', iconClass: 'size', value: lead.sqft, label: 'Square Feet', bg: 'var(--color-info-soft)', color: 'var(--color-info)' },
          { icon: '🔨', iconClass: 'type', value: lead.permitType, label: 'Permit Type', bg: 'var(--color-ember-soft)', color: 'var(--color-ember)', smallFont: true },
          { icon: '📅', iconClass: 'date', value: lead.filedDate, label: 'Filed', bg: 'var(--color-success-soft)', color: 'var(--color-success)' },
        ].map((stat) => (
          <div key={stat.label} style={{
            background: 'var(--color-bg-card)', border: '1px solid var(--color-border-subtle)',
            borderRadius: 8, padding: '14px 16px',
            display: 'flex', alignItems: 'center', gap: 12,
          }}>
            <div style={{
              width: 32, height: 32, borderRadius: 7,
              display: 'flex', alignItems: 'center', justifyContent: 'center',
              fontSize: 14, flexShrink: 0, background: stat.bg, color: stat.color,
            }}>{stat.icon}</div>
            <div>
              <div style={{
                fontFamily: stat.smallFont ? 'inherit' : 'var(--font-mono)',
                fontSize: stat.smallFont ? 13 : 16, fontWeight: 600,
                color: 'var(--color-text-primary)', lineHeight: 1.2,
              }}>{stat.value}</div>
              <div style={{
                fontSize: 10, textTransform: 'uppercase', letterSpacing: '0.6px',
                color: 'var(--color-text-muted)', marginTop: 2,
              }}>{stat.label}</div>
            </div>
          </div>
        ))}
      </div>

      {/* Scrollable content */}
      <div style={{
        flex: 1, overflowY: 'auto', padding: '20px 28px',
        position: 'relative', zIndex: 1,
      }}>

        {/* Lead Score Breakdown */}
        <div className="animate-in delay-4">
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 12 }}>
            <div style={{ fontSize: 11, fontWeight: 600, textTransform: 'uppercase', letterSpacing: '0.8px', color: 'var(--color-text-muted)' }}>
              Lead Score Breakdown
            </div>
          </div>
          <div style={{
            background: 'var(--color-bg-card)', border: '1px solid var(--color-border-subtle)',
            borderRadius: 10, padding: '4px 0', marginBottom: 20,
          }}>
            {lead.scoreBreakdown.map((bar, i) => (
              <div key={bar.label} style={{
                display: 'flex', alignItems: 'center', padding: '10px 18px', gap: 16,
                borderTop: i > 0 ? '1px solid var(--color-border-subtle)' : 'none',
              }}>
                <div style={{ fontSize: 12.5, color: 'var(--color-text-secondary)', width: 160, flexShrink: 0 }}>
                  {bar.label}
                </div>
                <div style={{
                  flex: 1, height: 6, background: 'rgba(255,255,255,0.06)',
                  borderRadius: 3, overflow: 'hidden',
                }}>
                  <div className={`score-bar-fill bar-${bar.barType}`} style={{ width: `${bar.pct}%` }} />
                </div>
                <div style={{ fontSize: 12, color: 'var(--color-text-secondary)', width: 120, textAlign: 'right', flexShrink: 0 }}>
                  {bar.value}
                </div>
              </div>
            ))}
          </div>
        </div>

        {/* Decision Makers */}
        <div className="animate-in delay-5" style={{ marginBottom: 20 }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 12 }}>
            <div style={{ fontSize: 11, fontWeight: 600, textTransform: 'uppercase', letterSpacing: '0.8px', color: 'var(--color-text-muted)' }}>
              Decision Makers · {lead.contacts.length}
            </div>
            <div style={{
              fontSize: 10, padding: '2px 8px', borderRadius: 12,
              background: 'var(--color-ember-soft)', color: 'var(--color-ember)', fontWeight: 500,
            }}>⚡ Auto-enriched</div>
          </div>
          <div style={{ display: 'flex', flexDirection: 'column', gap: 6 }}>
            {lead.contacts.map((contact) => (
              <div key={contact.id} style={{
                display: 'flex', alignItems: 'center', gap: 14,
                background: 'var(--color-bg-card)', border: '1px solid var(--color-border-subtle)',
                borderRadius: 10, padding: '12px 16px',
              }}>
                <div style={{
                  width: 40, height: 40, borderRadius: '50%',
                  display: 'flex', alignItems: 'center', justifyContent: 'center',
                  fontSize: 14, fontWeight: 600, color: '#fff', flexShrink: 0,
                  background: AVATAR_GRADIENTS[contact.avatarGradient],
                  letterSpacing: '-0.5px',
                }}>{contact.initials}</div>
                <div style={{ flex: 1 }}>
                  <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
                    <span style={{ fontSize: 13.5, fontWeight: 600, color: 'var(--color-text-primary)' }}>{contact.name}</span>
                    <span style={{
                      fontFamily: 'var(--font-mono)', fontSize: 10, fontWeight: 600,
                      padding: '1px 6px', borderRadius: 4,
                      background: 'rgba(74,222,128,0.12)', color: '#4ADE80',
                    }}>{contact.confidence}%</span>
                  </div>
                  <div style={{ fontSize: 12, color: 'var(--color-text-secondary)', marginTop: 1 }}>{contact.title}</div>
                </div>
                <div style={{ display: 'flex', gap: 8 }}>
                  {['📞', '✉', 'in'].map((icon) => (
                    <button key={icon} style={{
                      width: 32, height: 32, borderRadius: 7,
                      background: 'var(--color-bg-elevated)', border: '1px solid var(--color-border-subtle)',
                      display: 'flex', alignItems: 'center', justifyContent: 'center',
                      cursor: 'pointer', fontSize: 13, color: 'var(--color-text-secondary)',
                    }}>{icon}</button>
                  ))}
                </div>
              </div>
            ))}
          </div>
        </div>

        {/* Enrichment Insights */}
        <div className="animate-in delay-6" style={{ marginBottom: 20 }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 12 }}>
            <div style={{ fontSize: 11, fontWeight: 600, textTransform: 'uppercase', letterSpacing: '0.8px', color: 'var(--color-text-muted)' }}>
              Enrichment Insights
            </div>
          </div>
          {[
            { label: 'Business Challenges', tags: lead.enrichment.businessChallenges },
            { label: 'Technology Stack', tags: lead.enrichment.techStack },
            { label: 'AI-Identified Signals', tags: lead.enrichment.aiSignals },
          ].map((group) => (
            <div key={group.label} style={{ marginBottom: 12 }}>
              <div style={{ fontSize: 11, color: 'var(--color-text-muted)', marginBottom: 6, fontWeight: 500 }}>
                {group.label}
              </div>
              <div style={{ display: 'flex', flexWrap: 'wrap', gap: 6 }}>
                {group.tags.map((tag) => (
                  <span key={tag} style={{
                    fontSize: 11.5, padding: '4px 12px', borderRadius: 6,
                    background: 'var(--color-bg-card)', border: '1px solid var(--color-border-subtle)',
                    color: 'var(--color-text-secondary)',
                  }}>{tag}</span>
                ))}
              </div>
            </div>
          ))}
        </div>

        {/* Recent Permits */}
        <div className="animate-in delay-7" style={{ marginBottom: 20 }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 12 }}>
            <div style={{ fontSize: 11, fontWeight: 600, textTransform: 'uppercase', letterSpacing: '0.8px', color: 'var(--color-text-muted)' }}>
              Recent Permits
            </div>
          </div>
          <div style={{
            background: 'var(--color-bg-card)', border: '1px solid var(--color-border-subtle)',
            borderRadius: 10, overflow: 'hidden',
          }}>
            <table style={{ width: '100%', borderCollapse: 'collapse' }}>
              <thead>
                <tr>
                  {['Property', 'Type', 'Value', 'Date'].map((h) => (
                    <th key={h} style={{
                      fontSize: 10, textTransform: 'uppercase', letterSpacing: '0.6px',
                      color: 'var(--color-text-muted)', textAlign: 'left', padding: '8px 14px',
                      borderBottom: '1px solid var(--color-border-subtle)', fontWeight: 600,
                    }}>{h}</th>
                  ))}
                </tr>
              </thead>
              <tbody>
                {lead.permits.map((permit, i) => (
                  <tr key={i}>
                    <td style={{
                      fontSize: 12, color: 'var(--color-text-primary)', fontWeight: 500,
                      padding: '10px 14px',
                      borderBottom: i < lead.permits.length - 1 ? '1px solid var(--color-border-subtle)' : 'none',
                    }}>{permit.property}</td>
                    <td style={{
                      fontSize: 12, color: 'var(--color-text-secondary)',
                      padding: '10px 14px',
                      borderBottom: i < lead.permits.length - 1 ? '1px solid var(--color-border-subtle)' : 'none',
                    }}>{permit.type}</td>
                    <td style={{
                      fontSize: 12, padding: '10px 14px',
                      fontFamily: 'var(--font-mono)', color: 'var(--color-gold)',
                      borderBottom: i < lead.permits.length - 1 ? '1px solid var(--color-border-subtle)' : 'none',
                    }}>{permit.value}</td>
                    <td style={{
                      fontSize: 11, padding: '10px 14px',
                      fontFamily: 'var(--font-mono)', color: 'var(--color-text-secondary)',
                      borderBottom: i < lead.permits.length - 1 ? '1px solid var(--color-border-subtle)' : 'none',
                    }}>{permit.date}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </main>
  );
}

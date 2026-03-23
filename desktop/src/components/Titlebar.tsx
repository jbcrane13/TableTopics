/* eslint-disable @typescript-eslint/no-explicit-any */
const drag: any = { WebkitAppRegion: 'drag' };
const noDrag: any = { WebkitAppRegion: 'no-drag' };

export default function Titlebar() {
  return (
    <div
      style={{
        height: 46,
        background: 'var(--color-bg-surface)',
        borderBottom: '1px solid var(--color-border-subtle)',
        display: 'flex',
        alignItems: 'center',
        padding: '0 16px',
        gap: 12,
        position: 'relative',
        zIndex: 10,
        flexShrink: 0,
        ...drag,
      }}
    >
      {/* Ember glow line at bottom */}
      <div style={{
        position: 'absolute', bottom: 0, left: 0, right: 0, height: 1,
        background: 'linear-gradient(90deg, transparent, rgba(232,103,42,0.08) 30%, rgba(232,103,42,0.15) 50%, rgba(232,103,42,0.08) 70%, transparent)',
      }} />

      {/* Logo */}
      <div style={{
        width: 22, height: 22, borderRadius: 5, flexShrink: 0,
        background: 'linear-gradient(135deg, #E8672A, #D4A847)',
        display: 'flex', alignItems: 'center', justifyContent: 'center',
        fontSize: 11, fontWeight: 700, color: '#0C0B0F',
      }}>TT</div>

      <span style={{ fontFamily: 'var(--font-serif)', fontSize: 15, color: 'var(--color-text-primary)', letterSpacing: '0.3px' }}>
        LeadForge
      </span>

      <div style={{ width: 1, height: 16, background: 'var(--color-border-medium)' }} />

      {/* Nav */}
      <div style={{ display: 'flex', gap: 4, ...noDrag }}>
        {['Leads', 'Pipeline', 'Proposals'].map((item, i) => (
          <button key={item} style={{
            fontSize: 12, fontWeight: 500,
            color: i === 0 ? 'var(--color-ember)' : 'var(--color-text-muted)',
            padding: '4px 12px', borderRadius: 5,
            background: i === 0 ? 'var(--color-ember-soft)' : 'none',
            border: 'none', cursor: 'pointer', fontFamily: 'inherit',
          }}>
            {item}
          </button>
        ))}
      </div>

      {/* Stats */}
      <div style={{
        marginLeft: 'auto', display: 'flex', gap: 16, alignItems: 'center',
        fontSize: 11.5, color: 'var(--color-text-muted)',
        ...noDrag,
      }}>
        <span>🔥 <span style={{ color: 'var(--color-text-secondary)', fontWeight: 500 }}>2 Hot</span></span>
        <span>$ <span style={{ color: 'var(--color-text-secondary)', fontWeight: 500 }}>$1.9M Pipeline</span></span>
        <span>📋 <span style={{ color: 'var(--color-text-secondary)', fontWeight: 500 }}>8 Permits</span></span>
      </div>

      {/* Actions */}
      <div style={{ display: 'flex', gap: 6, marginLeft: 12, ...noDrag }}>
        {['⚙', '⟳'].map((icon) => (
          <button key={icon} style={{
            background: 'none', border: 'none', color: 'var(--color-text-secondary)',
            fontSize: 11, cursor: 'pointer', padding: '4px 10px', borderRadius: 4,
            fontFamily: 'inherit',
          }}>{icon}</button>
        ))}
      </div>
    </div>
  );
}

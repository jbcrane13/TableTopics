export default function BottomBar() {
  const shortcuts = [
    { key: '⌘K', label: 'Search' },
    { key: '⌘N', label: 'New Lead' },
    { key: '⌘E', label: 'Enrich' },
    { key: '⌘⇧P', label: 'Copilot' },
  ];

  return (
    <div style={{
      height: 28, background: 'var(--color-bg-surface)',
      borderTop: '1px solid var(--color-border-subtle)',
      display: 'flex', alignItems: 'center', justifyContent: 'space-between',
      padding: '0 16px', fontSize: 10.5, color: 'var(--color-text-muted)',
      position: 'relative', zIndex: 10, flexShrink: 0,
    }}>
      <div style={{ display: 'flex', gap: 16 }}>
        {shortcuts.map(({ key, label }) => (
          <div key={key} style={{ display: 'flex', alignItems: 'center', gap: 4 }}>
            <kbd style={{
              background: 'var(--color-bg-elevated)', border: '1px solid var(--color-border-subtle)',
              borderRadius: 3, padding: '0px 4px', fontFamily: 'inherit', fontSize: 9.5,
            }}>{key}</kbd>
            {label}
          </div>
        ))}
      </div>
      <div style={{ display: 'flex', gap: 12, alignItems: 'center' }}>
        <span style={{
          width: 5, height: 5, borderRadius: '50%', background: 'var(--color-success)',
          display: 'inline-block',
        }} />
        Shovels.ai · Explorium · 8 permits
      </div>
    </div>
  );
}

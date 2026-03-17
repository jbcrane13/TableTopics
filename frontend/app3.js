/* ═══════════════════════════════════════════════════════════════
   TABLE TOPICS — App Logic v3
   iOS-style compact rows, glass-only-on-nav, dual theme
   ═══════════════════════════════════════════════════════════════ */

/* ── LEAD DATA ───────────────────────────────────────────────── */
const leads = [
  {
    company:    "Ritz-Carlton New Build",
    permitType: "New Construction",
    score:      95,
    tier:       "HOT",
    city:       "Austin, TX",
    value:      "$45M",
    filter:     "hotel"
  },
  {
    company:    "Marriott Convention Wing",
    permitType: "New Construction",
    score:      91,
    tier:       "HOT",
    city:       "Nashville, TN",
    value:      "$28M",
    filter:     "hotel"
  },
  {
    company:    "Oceanview Prime Steakhouse",
    permitType: "Full Remodel",
    score:      88,
    tier:       "HOT",
    city:       "Miami, FL",
    value:      "$2.1M",
    filter:     "restaurant"
  },
  {
    company:    "Vertex Lounge & Bar",
    permitType: "Bar Addition",
    score:      82,
    tier:       "WARM",
    city:       "Chicago, IL",
    value:      "$800K",
    filter:     "cafe"
  },
  {
    company:    "Sonder Select Portfolio",
    permitType: "Interior Refresh",
    score:      78,
    tier:       "WARM",
    city:       "Denver, CO",
    value:      "$3.4M",
    filter:     "hotel"
  },
  {
    company:    "Downtown Cafe Collective",
    permitType: "Expansion",
    score:      72,
    tier:       "WARM",
    city:       "Portland, OR",
    value:      "$450K",
    filter:     "cafe"
  },
  {
    company:    "Highland Event Center",
    permitType: "Banquet Hall",
    score:      65,
    tier:       "COOL",
    city:       "Denver, CO",
    value:      "$1.2M",
    filter:     "banquet"
  },
  {
    company:    "The Pearl Rooftop",
    permitType: "New Construction",
    score:      61,
    tier:       "COOL",
    city:       "Dallas, TX",
    value:      "$5.8M",
    filter:     "restaurant"
  },
  {
    company:    "Greenfield Banquet Suite",
    permitType: "Commercial Build",
    score:      48,
    tier:       "COLD",
    city:       "Phoenix, AZ",
    value:      "$600K",
    filter:     "banquet"
  }
];

/* ── TIER CONFIG ─────────────────────────────────────────────── */
const tierMap = {
  HOT:  {
    color:   'var(--hot)',
    badge:   'linear-gradient(135deg, #FF3B30 0%, #FF6961 100%)'
  },
  WARM: {
    color:   'var(--warm)',
    badge:   'linear-gradient(135deg, #FF9F0A 0%, #FFCC00 100%)'
  },
  COOL: {
    color:   'var(--cool)',
    badge:   'linear-gradient(135deg, #32ADE6 0%, #5AC8FA 100%)'
  },
  COLD: {
    color:   'var(--cold)',
    badge:   'linear-gradient(135deg, #8E8E93 0%, #AEAEB2 100%)'
  }
};

/* ── HELPERS ─────────────────────────────────────────────────── */
function initials(name) {
  const words = name.replace(/[^a-zA-Z\s]/g, '').trim().split(/\s+/);
  if (words.length === 1) return words[0].slice(0, 2).toUpperCase();
  return (words[0][0] + words[words.length - 1][0]).toUpperCase();
}

const chevronSVG = `<svg class="lead-chevron" width="8" height="14" viewBox="0 0 8 14" fill="none">
  <path d="M1 1l6 6-6 6" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/>
</svg>`;

/* ── ROW BUILDER ─────────────────────────────────────────────── */
function buildRow(lead, index) {
  const t    = tierMap[lead.tier] || tierMap.COLD;
  const init = initials(lead.company);
  const delay = `row-d${Math.min(index + 1, 6)}`;

  return `
    <div class="lead-row ${delay}"
         style="--row-color: ${t.color}; --badge-bg: ${t.badge};"
         data-filter="${lead.filter}"
         role="button"
         tabindex="0"
         aria-label="${lead.company}, ${lead.tier} lead, ${lead.value}">
      <div class="lead-badge"><span>${init}</span></div>
      <div class="lead-info">
        <div class="lead-name">${lead.company}</div>
        <div class="lead-sub">
          ${lead.city}
          <span class="lead-tag">${lead.permitType}</span>
        </div>
      </div>
      <div class="lead-right">
        <div class="lead-value">${lead.value}</div>
        <div class="lead-score">${lead.score} ${lead.tier}</div>
      </div>
      ${chevronSVG}
    </div>
  `;
}

/* ── RENDER LEADS ────────────────────────────────────────────── */
function renderLeads(filter = 'all') {
  const group = document.getElementById('leadGroup');
  const visible = filter === 'all'
    ? leads
    : leads.filter(l => l.filter === filter);

  if (visible.length === 0) {
    group.innerHTML = `
      <div style="padding: 32px 20px; text-align: center; color: var(--label-2); font-size: 14px;">
        No leads in this category yet.
      </div>`;
    return;
  }

  group.innerHTML = visible.map((l, i) => buildRow(l, i)).join('');
}

/* ── LIVE CLOCK ──────────────────────────────────────────────── */
function updateClock() {
  const el = document.getElementById('clockTime');
  if (!el) return;
  const now = new Date();
  const h = now.getHours() % 12 || 12;
  const m = String(now.getMinutes()).padStart(2, '0');
  el.textContent = `${h}:${m}`;
}

/* ── INIT ────────────────────────────────────────────────────── */
document.addEventListener('DOMContentLoaded', () => {

  /* Render initial list */
  renderLeads();

  /* ── THEME TOGGLE ── */
  const html     = document.documentElement;
  const themeBtn = document.getElementById('themeBtn');
  const saved    = localStorage.getItem('tt-theme') || 'dark';
  html.setAttribute('data-theme', saved);

  themeBtn.addEventListener('click', () => {
    const next = html.getAttribute('data-theme') === 'dark' ? 'light' : 'dark';
    html.setAttribute('data-theme', next);
    localStorage.setItem('tt-theme', next);
  });

  /* ── SEGMENT FILTER ── */
  const segment = document.getElementById('filterSegment');
  segment.addEventListener('click', e => {
    const btn = e.target.closest('.seg-btn');
    if (!btn) return;
    segment.querySelectorAll('.seg-btn').forEach(b => b.classList.remove('active'));
    btn.classList.add('active');
    renderLeads(btn.dataset.filter);
  });

  /* ── SEARCH GO BUTTON ── */
  const searchGoBtn = document.getElementById('searchGoBtn');
  const searchInput = document.getElementById('searchInput');
  let searchTimer;

  function runSearch() {
    const svg = searchGoBtn.querySelector('svg');
    svg.classList.add('spin');
    setTimeout(() => svg.classList.remove('spin'), 700);

    const q = searchInput.value.trim().toLowerCase();
    if (!q) { renderLeads(); return; }

    const group = document.getElementById('leadGroup');
    const matches = leads.filter(l =>
      l.company.toLowerCase().includes(q) ||
      l.city.toLowerCase().includes(q) ||
      l.permitType.toLowerCase().includes(q)
    );

    // Reset segment to "All" visually
    document.querySelectorAll('.seg-btn').forEach(b => b.classList.remove('active'));
    segment.querySelector('[data-filter="all"]').classList.add('active');

    if (matches.length === 0) {
      group.innerHTML = `
        <div style="padding: 32px 20px; text-align: center; color: var(--label-2); font-size: 14px;">
          No results for "${searchInput.value.trim()}"
        </div>`;
    } else {
      group.innerHTML = matches.map((l, i) => buildRow(l, i)).join('');
    }
  }

  searchGoBtn.addEventListener('click', runSearch);
  searchInput.addEventListener('keydown', e => {
    if (e.key === 'Enter') runSearch();
  });
  searchInput.addEventListener('input', () => {
    clearTimeout(searchTimer);
    if (!searchInput.value.trim()) {
      searchTimer = setTimeout(() => renderLeads(), 300);
    }
  });

  /* ── TAB BAR ── */
  document.querySelectorAll('.tab').forEach(tab => {
    tab.addEventListener('click', () => {
      document.querySelectorAll('.tab').forEach(t => t.classList.remove('active'));
      tab.classList.add('active');
      // Future: swap content panels
    });
  });

  /* ── ROW TAP FEEDBACK ── */
  document.getElementById('leadGroup').addEventListener('click', e => {
    const row = e.target.closest('.lead-row');
    if (!row) return;
    row.style.background = 'var(--bg-card-2)';
    setTimeout(() => row.style.background = '', 160);
    // Future: open lead detail sheet
  });

  /* ── CLOCK ── */
  updateClock();
  setInterval(updateClock, 15000);

});

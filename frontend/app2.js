/* ═══════════════════════════════════════════════════════════════
   TABLE TOPICS — App Logic v2
   ═══════════════════════════════════════════════════════════════ */

const leads = [
  {
    company: "The Ritz-Carlton New Build",
    permitType: "New Construction",
    score: 95,
    tier: "HOT",
    tierColor: "var(--tier-hot)",
    tierGlow: "var(--tier-hot-glow)",
    desc: "Luxury 250-room hotel with 3 grand banquet halls and 2 premium dining restaurants.",
    city: "Austin, TX",
    value: "$45M",
    filter: "hotel"
  },
  {
    company: "Oceanview Prime Steakhouse",
    permitType: "Full Remodel",
    score: 88,
    tier: "HOT",
    tierColor: "var(--tier-hot)",
    tierGlow: "var(--tier-hot-glow)",
    desc: "Complete interior overhaul of waterfront property. Replacing all dining furniture.",
    city: "Miami, FL",
    value: "$2.1M",
    filter: "restaurant"
  },
  {
    company: "Downtown Cafe Collective",
    permitType: "Expansion",
    score: 72,
    tier: "WARM",
    tierColor: "var(--tier-warm)",
    tierGlow: "var(--tier-warm-glow)",
    desc: "Boutique coffee shop expansion to adjacent building. New seating for 80 guests.",
    city: "Portland, OR",
    value: "$450K",
    filter: "cafe"
  },
  {
    company: "Highland Event Center",
    permitType: "Banquet Hall",
    score: 65,
    tier: "COOL",
    tierColor: "var(--tier-cool)",
    tierGlow: "var(--tier-cool-glow)",
    desc: "New event space requiring 50+ modular banquet tables and flexible seating.",
    city: "Denver, CO",
    value: "$1.2M",
    filter: "banquet"
  },
  {
    company: "Vertex Lounge & Bar",
    permitType: "Bar Addition",
    score: 82,
    tier: "WARM",
    tierColor: "var(--tier-warm)",
    tierGlow: "var(--tier-warm-glow)",
    desc: "Rooftop bar addition requiring high-end outdoor durable tables and weather-proof seating.",
    city: "Chicago, IL",
    value: "$800K",
    filter: "bar"
  },
  {
    company: "Marriott Convention Wing",
    permitType: "New Construction",
    score: 91,
    tier: "HOT",
    tierColor: "var(--tier-hot)",
    tierGlow: "var(--tier-hot-glow)",
    desc: "120,000 sq ft convention center addition. Requires 300+ conference and banquet tables.",
    city: "Nashville, TN",
    value: "$28M",
    filter: "hotel"
  }
];

function buildCard(lead, index) {
  return `
    <div class="lead-card glass-card delay-${(index % 5) + 1}" style="--card-tier-color: ${lead.tierColor};" data-filter="${lead.filter}">
      <div class="card-top">
        <div class="card-meta">
          <div class="card-title">${lead.company}</div>
          <span class="card-permit-tag">${lead.permitType}</span>
        </div>
        <div class="card-score-badge">
          <span class="score-num">${lead.score}</span>
          <span class="score-tier">${lead.tier}</span>
        </div>
      </div>

      <p class="card-desc">${lead.desc}</p>

      <div class="card-footer">
        <div class="card-location">
          <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round">
            <path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0z"/>
            <circle cx="12" cy="10" r="3"/>
          </svg>
          ${lead.city}
        </div>
        <div class="card-value">${lead.value}</div>
      </div>

      <div class="card-actions">
        <button class="action-btn" style="--action-color: #22C55E;">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
            <path d="M22 16.92v3a2 2 0 0 1-2.18 2 19.79 19.79 0 0 1-8.63-3.07 19.5 19.5 0 0 1-6-6 19.79 19.79 0 0 1-3.07-8.67A2 2 0 0 1 4.11 2h3a2 2 0 0 1 2 1.72 12.84 12.84 0 0 0 .7 2.81 2 2 0 0 1-.45 2.11L8.09 9.91a16 16 0 0 0 6 6l1.27-1.27a2 2 0 0 1 2.11-.45 12.84 12.84 0 0 0 2.81.7A2 2 0 0 1 22 16.92z"/>
          </svg>
          Call
        </button>
        <button class="action-btn" style="--action-color: #3B82F6;">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
            <path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z"/>
            <polyline points="22,6 12,13 2,6"/>
          </svg>
          Email
        </button>
        <button class="action-btn" style="--action-color: #F59E0B;">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
            <path d="M21 11.5a8.38 8.38 0 0 1-.9 3.8 8.5 8.5 0 0 1-7.6 4.7 8.38 8.38 0 0 1-3.8-.9L3 21l1.9-5.7a8.38 8.38 0 0 1-.9-3.8 8.5 8.5 0 0 1 4.7-7.6 8.38 8.38 0 0 1 3.8-.9h.5a8.48 8.48 0 0 1 8 8v.5z"/>
          </svg>
          Text
        </button>
      </div>
    </div>
  `;
}

// ── INIT ──────────────────────────────────────────────────────
document.addEventListener('DOMContentLoaded', () => {
  const list = document.getElementById('leads-list');
  list.innerHTML = leads.map((l, i) => buildCard(l, i)).join('');

  // ── FILTER PILLS ──
  const pills = document.querySelectorAll('.filter-pill');
  pills.forEach(pill => {
    pill.addEventListener('click', () => {
      pills.forEach(p => p.classList.remove('active'));
      pill.classList.add('active');
      const filter = pill.dataset.filter;
      document.querySelectorAll('.lead-card').forEach(card => {
        const show = filter === 'all' || card.dataset.filter === filter;
        card.style.display = show ? '' : 'none';
      });
    });
  });

  // ── THEME TOGGLE ──
  const html = document.documentElement;
  const themeBtn = document.getElementById('themeToggle');

  // Persist theme across sessions
  const saved = localStorage.getItem('tt-theme') || 'dark';
  html.setAttribute('data-theme', saved);

  themeBtn.addEventListener('click', () => {
    const current = html.getAttribute('data-theme');
    const next = current === 'dark' ? 'light' : 'dark';
    html.setAttribute('data-theme', next);
    localStorage.setItem('tt-theme', next);
  });

  // ── SEARCH BUTTON SPINNER ──
  const searchBtn = document.getElementById('searchBtn');
  searchBtn.addEventListener('click', () => {
    const svg = searchBtn.querySelector('svg');
    svg.classList.add('spinning');
    setTimeout(() => svg.classList.remove('spinning'), 900);
  });

  // ── BOTTOM NAV TABS ──
  document.querySelectorAll('.nav-item').forEach(item => {
    item.addEventListener('click', () => {
      document.querySelectorAll('.nav-item').forEach(n => n.classList.remove('active'));
      item.classList.add('active');
    });
  });
});

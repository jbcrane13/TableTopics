const leads = [
  {
    company: "The Ritz-Carlton New Build",
    permitType: "new_construction",
    score: 95,
    tier: "HOT",
    tierColor: "var(--color-hot)",
    desc: "Luxury 250-room hotel with 3 grand banquet halls and 2 premium dining restaurants.",
    city: "Austin, TX",
    value: "$45M"
  },
  {
    company: "Oceanview Prime Steakhouse",
    permitType: "remodel",
    score: 88,
    tier: "HOT",
    tierColor: "var(--color-hot)",
    desc: "Complete interior overhaul of waterfront property. Replacing all dining furniture.",
    city: "Miami, FL",
    value: "$2.1M"
  },
  {
    company: "Downtown Cafe Collective",
    permitType: "restaurant",
    score: 72,
    tier: "WARM",
    tierColor: "var(--color-warm)",
    desc: "Boutique coffee shop expansion to adjacent building.",
    city: "Portland, OR",
    value: "$450K"
  },
  {
    company: "Highland Event Center",
    permitType: "banquet",
    score: 65,
    tier: "COOL",
    tierColor: "var(--color-cool)",
    desc: "New event space requiring 50+ modular tables.",
    city: "Denver, CO",
    value: "$1.2M"
  },
  {
    company: "Vertex Lounge & Bar",
    permitType: "remodel",
    score: 82,
    tier: "WARM",
    tierColor: "var(--color-warm)",
    desc: "Rooftop bar addition requiring high-end outdoor durable tables.",
    city: "Chicago, IL",
    value: "$800K"
  }
];

function createMobileCard(lead, index) {
  const delayClass = `delay-${(index % 5) + 1}`;
  
  return `
    <div class="lead-card glass ${delayClass}" style="--tier-color: ${lead.tierColor};">
      <div class="card-top">
        <div>
          <h3 class="card-title">${lead.company}</h3>
          <span class="card-permit">${lead.permitType.replace('_', ' ')}</span>
        </div>
        <div class="card-score">
          <span class="score-num">${lead.score}</span>
          <span class="score-tier">${lead.tier}</span>
        </div>
      </div>
      
      <p class="card-desc">${lead.desc}</p>
      
      <div class="card-footer">
        <div class="location">
          <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0z"></path><circle cx="12" cy="10" r="3"></circle></svg>
          ${lead.city}
        </div>
        <div class="est-value">${lead.value}</div>
      </div>

      <!-- Always visible mobile actions -->
      <div class="card-actions">
        <button class="btn-action" style="--action-color: #22c55e;">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M22 16.92v3a2 2 0 0 1-2.18 2 19.79 19.79 0 0 1-8.63-3.07 19.5 19.5 0 0 1-6-6 19.79 19.79 0 0 1-3.07-8.67A2 2 0 0 1 4.11 2h3a2 2 0 0 1 2 1.72 12.84 12.84 0 0 0 .7 2.81 2 2 0 0 1-.45 2.11L8.09 9.91a16 16 0 0 0 6 6l1.27-1.27a2 2 0 0 1 2.11-.45 12.84 12.84 0 0 0 2.81.7A2 2 0 0 1 22 16.92z"></path></svg>
          <span>Call</span>
        </button>
        <button class="btn-action" style="--action-color: #3b82f6;">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z"></path><polyline points="22,6 12,13 2,6"></polyline></svg>
          <span>Email</span>
        </button>
        <button class="btn-action" style="--action-color: #f59e0b;">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21 11.5a8.38 8.38 0 0 1-.9 3.8 8.5 8.5 0 0 1-7.6 4.7 8.38 8.38 0 0 1-3.8-.9L3 21l1.9-5.7a8.38 8.38 0 0 1-.9-3.8 8.5 8.5 0 0 1 4.7-7.6 8.38 8.38 0 0 1 3.8-.9h.5a8.48 8.48 0 0 1 8 8v.5z"></path></svg>
          <span>Text</span>
        </button>
      </div>
    </div>
  `;
}

document.addEventListener('DOMContentLoaded', () => {
  const grid = document.getElementById('leads-list');
  grid.innerHTML = leads.map((lead, index) => createMobileCard(lead, index)).join('');

  // Pill interaction
  const pills = document.querySelectorAll('.glass-pill');
  pills.forEach(pill => {
    pill.addEventListener('click', () => {
      pills.forEach(p => p.classList.remove('active'));
      pill.classList.add('active');
    });
  });

  // Search button feedback
  const searchBtn = document.querySelector('.search-btn');
  searchBtn.addEventListener('click', () => {
    const originalIcon = searchBtn.innerHTML;
    searchBtn.innerHTML = '<svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" class="spin"><path d="M21 12a9 9 0 1 1-6.219-8.56"></path></svg>';
    
    // Add simple spin animation dynamically
    if (!document.getElementById('spin-style')) {
      const style = document.createElement('style');
      style.id = 'spin-style';
      style.textContent = '@keyframes spin { 100% { transform: rotate(360deg); } } .spin { animation: spin 1s linear infinite; }';
      document.head.appendChild(style);
    }

    setTimeout(() => {
      searchBtn.innerHTML = originalIcon;
    }, 1000);
  });
});

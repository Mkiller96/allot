/* ══════════════════════════════════════════════
   ALLOT — app.js
   Roles: admin | user | guest
   Dark / Light theme
   Dashboard: monthly & annual metrics
══════════════════════════════════════════════ */

// ─── Categories ──────────────────────────────────────────────────────────
const DEFAULT_CATEGORIES = [
  { id: 'food',      name: 'Comida',     color: '#4CAF50', icon: '🍔' },
  { id: 'transport', name: 'Transporte', color: '#2196F3', icon: '🚌' },
  { id: 'leisure',   name: 'Ocio',       color: '#FF9800', icon: '🎮' },
  { id: 'bills',     name: 'Facturas',   color: '#9C27B0', icon: '🧾' },
  { id: 'shopping',  name: 'Compras',    color: '#E91E63', icon: '🛍️' },
  { id: 'health',    name: 'Salud',      color: '#00BCD4', icon: '💊' },
  { id: 'other',     name: 'Otros',      color: '#607D8B', icon: '📦' },
];

// ─── Role definitions ────────────────────────────────────────────────────
const ROLES = {
  admin: {
    label:      'Administrador',
    canWrite:   true,
    canDelete:  true,
    canSettings:true,
    hint:       'Acceso total.',
  },
  user: {
    label:      'Usuario',
    canWrite:   true,
    canDelete:  false,
    canSettings:false,
    hint:       'Puede añadir gastos, no puede eliminar ni cambiar ajustes.',
  },
  guest: {
    label:      'Invitado',
    canWrite:   false,
    canDelete:  false,
    canSettings:false,
    hint:       'Solo lectura. No puede añadir ni modificar gastos.',
  },
};

// ─── State ────────────────────────────────────────────────────────────────
let state = {
  expenses:   [],
  categories: [],
  session:    null,   // { name, role }
  theme:      'dark',
};

// ─── Persistence ─────────────────────────────────────────────────────────
function loadState() {
  try {
    const ex = localStorage.getItem('allot_expenses');
    const ca = localStorage.getItem('allot_categories');
    const th = localStorage.getItem('allot_theme');
    state.expenses   = ex ? JSON.parse(ex) : [];
    state.categories = ca ? JSON.parse(ca) : DEFAULT_CATEGORIES.map(c => ({ ...c }));
    state.theme      = (th === 'light') ? 'light' : 'dark';
  } catch {
    state.expenses   = [];
    state.categories = DEFAULT_CATEGORIES.map(c => ({ ...c }));
    state.theme      = 'dark';
  }
}

function saveExpenses()   { localStorage.setItem('allot_expenses', JSON.stringify(state.expenses)); }
function saveCategories() { localStorage.setItem('allot_categories', JSON.stringify(state.categories)); }
function saveTheme()      { localStorage.setItem('allot_theme', state.theme); }

// ─── Theme ────────────────────────────────────────────────────────────────
function applyTheme(theme) {
  state.theme = theme;
  document.documentElement.setAttribute('data-theme', theme);
  saveTheme();

  const isDark = theme === 'dark';
  const moonSVG = '<path d="M21 12.79A9 9 0 1 1 11.21 3a7 7 0 0 0 9.79 9.79z"/>';
  const sunSVG  = '<circle cx="12" cy="12" r="5"/><line x1="12" y1="1" x2="12" y2="3"/>' +
                  '<line x1="12" y1="21" x2="12" y2="23"/><line x1="4.22" y1="4.22" x2="5.64" y2="5.64"/>' +
                  '<line x1="18.36" y1="18.36" x2="19.78" y2="19.78"/><line x1="1" y1="12" x2="3" y2="12"/>' +
                  '<line x1="21" y1="12" x2="23" y2="12"/><line x1="4.22" y1="19.78" x2="5.64" y2="18.36"/>' +
                  '<line x1="18.36" y1="5.64" x2="19.78" y2="4.22"/>';

  const iconSVG = isDark ? moonSVG : sunSVG;
  document.getElementById('themeIcon').innerHTML     = iconSVG;
  document.getElementById('themeIconLogin').innerHTML = iconSVG;
  document.getElementById('themeLabel').textContent  = isDark ? 'Modo claro' : 'Modo oscuro';
}

function toggleTheme() {
  applyTheme(state.theme === 'dark' ? 'light' : 'dark');
}

document.getElementById('themeToggle').addEventListener('click', toggleTheme);
document.getElementById('themeToggleLogin').addEventListener('click', toggleTheme);

// ─── Helpers ─────────────────────────────────────────────────────────────
function fmtMoney(n) {
  return '€' + n.toFixed(2).replace('.', ',');
}

function fmtDate(iso) {
  return new Date(iso).toLocaleDateString('es-ES', { day: '2-digit', month: 'short', year: 'numeric' });
}

function todayISO() {
  return new Date().toISOString().slice(0, 10);
}

function startOfWeek() {
  const d = new Date();
  const day = d.getDay() === 0 ? 6 : d.getDay() - 1;
  d.setDate(d.getDate() - day);
  d.setHours(0, 0, 0, 0);
  return d;
}

function uid() {
  return Date.now().toString(36) + Math.random().toString(36).slice(2);
}

function getCat(id) {
  return state.categories.find(c => c.id === id) || { name: 'Desconocido', color: '#888', icon: '?' };
}

function showToast(msg) {
  const el = document.getElementById('toast');
  el.textContent = msg;
  el.classList.add('show');
  clearTimeout(el._t);
  el._t = setTimeout(() => el.classList.remove('show'), 2400);
}

// ─── Login ────────────────────────────────────────────────────────────────
let selectedRole = 'admin';

document.querySelectorAll('.role-chip').forEach(chip => {
  chip.addEventListener('click', () => {
    document.querySelectorAll('.role-chip').forEach(c => c.classList.remove('active'));
    chip.classList.add('active');
    selectedRole = chip.dataset.role;
    const passGroup = document.getElementById('passGroup');
    passGroup.style.display = (selectedRole === 'guest') ? 'none' : '';
    document.getElementById('loginHint').textContent = ROLES[selectedRole].hint;
  });
});

// Show hint for default role on load
document.getElementById('loginHint').textContent = ROLES['admin'].hint;

document.getElementById('loginForm').addEventListener('submit', e => {
  e.preventDefault();
  const name = document.getElementById('loginUser').value.trim();
  if (!name) {
    document.getElementById('loginHint').textContent = 'Escribe tu nombre para continuar.';
    return;
  }
  state.session = { name, role: selectedRole };
  applyRoleUI();
  document.getElementById('loginScreen').style.display = 'none';
  document.getElementById('appShell').hidden = false;
  renderHome();
});

function applyRoleUI() {
  const { name, role } = state.session;
  const roleDef = ROLES[role];

  // Sidebar user badge
  document.getElementById('userAvatar').textContent    = name.charAt(0).toUpperCase();
  document.getElementById('userName').textContent      = name;
  document.getElementById('userRoleLabel').textContent = roleDef.label;

  // Settings nav: only admin
  document.getElementById('navSettings').style.display = roleDef.canSettings ? '' : 'none';

  // Settings page info
  document.getElementById('settingsAvatar').textContent  = name.charAt(0).toUpperCase();
  document.getElementById('settingsUserName').textContent = name;
  document.getElementById('settingsRole').textContent    = roleDef.label;

  // Add expense button
  document.getElementById('openAddBtn').style.display = roleDef.canWrite ? '' : 'none';
}

// Logout
document.getElementById('logoutBtn').addEventListener('click', () => {
  state.session = null;
  document.getElementById('appShell').hidden = true;
  document.getElementById('loginScreen').style.display = '';
  document.getElementById('loginForm').reset();
  document.getElementById('loginHint').textContent = ROLES[selectedRole].hint;
});

// ─── Navigation ──────────────────────────────────────────────────────────
const views   = document.querySelectorAll('.view');
const navBtns = document.querySelectorAll('.nav-btn');

function switchView(name) {
  views.forEach(v => v.classList.toggle('active', v.id === 'view-' + name));
  navBtns.forEach(b => b.classList.toggle('active', b.dataset.view === name));
  if (name === 'home')      renderHome();
  if (name === 'dashboard') renderDashboard();
  if (name === 'history')   renderHistory();
  if (name === 'settings')  renderSettings();
}

navBtns.forEach(btn => {
  btn.addEventListener('click', () => switchView(btn.dataset.view));
});

// ─── HOME ─────────────────────────────────────────────────────────────────
function renderHome() {
  const now   = new Date();
  const today = todayISO();
  const sw    = startOfWeek();

  const monthEx = state.expenses.filter(e => {
    const d = new Date(e.date);
    return d.getFullYear() === now.getFullYear() && d.getMonth() === now.getMonth();
  });
  const todayEx = state.expenses.filter(e => e.date === today);
  const weekEx  = state.expenses.filter(e => new Date(e.date) >= sw);

  document.getElementById('monthTotal').textContent = fmtMoney(monthEx.reduce((s, e) => s + e.amount, 0));
  document.getElementById('todayTotal').textContent = fmtMoney(todayEx.reduce((s, e) => s + e.amount, 0));
  document.getElementById('weekTotal').textContent  = fmtMoney(weekEx.reduce((s, e) => s + e.amount, 0));
  document.getElementById('monthCount').textContent = monthEx.length + ' gastos';
  document.getElementById('todayCount').textContent = todayEx.length + ' gastos';
  document.getElementById('weekCount').textContent  = weekEx.length + ' gastos';

  // Top 3 categories
  const bycat = {};
  monthEx.forEach(e => { bycat[e.categoryId] = (bycat[e.categoryId] || 0) + e.amount; });
  const sorted = Object.entries(bycat).sort((a, b) => b[1] - a[1]).slice(0, 3);
  const monthTotal = monthEx.reduce((s, e) => s + e.amount, 0) || 1;

  const topEl = document.getElementById('topCats');
  topEl.innerHTML = '';
  if (sorted.length === 0) {
    topEl.innerHTML = '<p class="empty-msg">Sin gastos este mes.</p>';
  } else {
    sorted.forEach(([catId, amount]) => {
      const cat = getCat(catId);
      const pct = (amount / monthTotal) * 100;
      const row = document.createElement('div');
      row.className = 'top-cat-row';
      row.innerHTML = `
        <span class="top-cat-dot" style="background:${cat.color}"></span>
        <span class="top-cat-name">${cat.icon} ${cat.name}</span>
        <div class="top-cat-bar-wrap">
          <div class="top-cat-bar" style="width:${pct}%;background:${cat.color}"></div>
        </div>
        <span class="top-cat-amount">${fmtMoney(amount)}</span>`;
      topEl.appendChild(row);
    });
  }

  renderExpenseList('todayList', 'todayEmpty', todayEx.slice().reverse());
}

// ─── EXPENSE LIST ─────────────────────────────────────────────────────────
function renderExpenseList(listId, emptyId, expenses) {
  const listEl  = document.getElementById(listId);
  const emptyEl = document.getElementById(emptyId);
  const role    = state.session ? ROLES[state.session.role] : ROLES.guest;
  listEl.innerHTML = '';
  emptyEl.hidden = expenses.length > 0;

  expenses.forEach(expense => {
    const cat  = getCat(expense.categoryId);
    const card = document.createElement('div');
    card.className = 'expense-card';
    card.innerHTML = `
      <div class="expense-icon" style="background:${cat.color}22">${cat.icon}</div>
      <div class="expense-info">
        <p class="expense-cat">${cat.name}</p>
        <p class="expense-note">${expense.note || '—'}</p>
        <p class="expense-date">${fmtDate(expense.date)}</p>
      </div>
      <span class="expense-amount">${fmtMoney(expense.amount)}</span>
      <div class="expense-actions">
        ${role.canWrite  ? `<button class="icon-btn" data-edit="${expense.id}" title="Editar">✏️</button>` : ''}
        ${role.canDelete ? `<button class="icon-btn del" data-del="${expense.id}" title="Eliminar">🗑</button>` : ''}
      </div>`;
    listEl.appendChild(card);
  });

  listEl.querySelectorAll('[data-edit]').forEach(btn => {
    btn.addEventListener('click', () => openEditModal(btn.dataset.edit));
  });
  listEl.querySelectorAll('[data-del]').forEach(btn => {
    btn.addEventListener('click', () => deleteExpense(btn.dataset.del));
  });
}

// ─── DASHBOARD ────────────────────────────────────────────────────────────
function renderDashboard() {
  const selYear = parseInt(document.getElementById('dashYear').value, 10) || new Date().getFullYear();

  // Populate year selector
  const years = [...new Set(state.expenses.map(e => new Date(e.date).getFullYear()))];
  const currentYear = new Date().getFullYear();
  if (!years.includes(currentYear)) years.push(currentYear);
  years.sort((a, b) => b - a);
  const dashYearEl = document.getElementById('dashYear');
  const prevYear = dashYearEl.value;
  dashYearEl.innerHTML = '';
  years.forEach(y => {
    const opt = document.createElement('option');
    opt.value = y;
    opt.textContent = y;
    dashYearEl.appendChild(opt);
  });
  dashYearEl.value = prevYear || currentYear;
  const chosenYear = parseInt(dashYearEl.value, 10);

  const yearEx = state.expenses.filter(e => new Date(e.date).getFullYear() === chosenYear);

  // KPIs
  const yearTotal = yearEx.reduce((s, e) => s + e.amount, 0);
  document.getElementById('kpiYear').textContent      = fmtMoney(yearTotal);
  document.getElementById('kpiYearCount').textContent = yearEx.length + ' gastos';

  // Average monthly (months with data)
  const monthsWithData = new Set(yearEx.map(e => new Date(e.date).getMonth())).size || 1;
  document.getElementById('kpiAvgMonth').textContent = fmtMoney(yearTotal / monthsWithData);

  // Month with most spend
  const byMonth = {};
  yearEx.forEach(e => {
    const m = new Date(e.date).getMonth();
    byMonth[m] = (byMonth[m] || 0) + e.amount;
  });
  const topMonthEntry = Object.entries(byMonth).sort((a, b) => b[1] - a[1])[0];
  if (topMonthEntry) {
    const monthNames = ['Ene','Feb','Mar','Abr','May','Jun','Jul','Ago','Sep','Oct','Nov','Dic'];
    document.getElementById('kpiTopMonth').textContent    = monthNames[parseInt(topMonthEntry[0])];
    document.getElementById('kpiTopMonthAmt').textContent = fmtMoney(topMonthEntry[1]);
  } else {
    document.getElementById('kpiTopMonth').textContent    = '—';
    document.getElementById('kpiTopMonthAmt').textContent = '€0,00';
  }

  // Top category
  const byCat = {};
  yearEx.forEach(e => { byCat[e.categoryId] = (byCat[e.categoryId] || 0) + e.amount; });
  const topCatEntry = Object.entries(byCat).sort((a, b) => b[1] - a[1])[0];
  if (topCatEntry) {
    const cat = getCat(topCatEntry[0]);
    document.getElementById('kpiTopCat').textContent    = cat.icon + ' ' + cat.name;
    document.getElementById('kpiTopCatAmt').textContent = fmtMoney(topCatEntry[1]);
  } else {
    document.getElementById('kpiTopCat').textContent    = '—';
    document.getElementById('kpiTopCatAmt').textContent = '€0,00';
  }

  renderMonthBarChart(yearEx, chosenYear);
  renderDashPieChart(yearEx);

  // Top 5 expenses of the year
  const top5 = yearEx.slice().sort((a, b) => b.amount - a.amount).slice(0, 5);
  renderExpenseList('top5List', 'top5Empty', top5);
}

// ── Monthly bar chart ────────────────────────────────────────────────────
function renderMonthBarChart(yearEx, year) {
  const canvas = document.getElementById('monthBarChart');
  const ctx    = canvas.getContext('2d');
  const W = canvas.offsetWidth || 700;
  canvas.width  = W;
  canvas.height = 200;
  ctx.clearRect(0, 0, W, 200);

  const monthNames = ['Ene','Feb','Mar','Abr','May','Jun','Jul','Ago','Sep','Oct','Nov','Dic'];
  const totals = Array(12).fill(0);
  yearEx.forEach(e => { totals[new Date(e.date).getMonth()] += e.amount; });
  const maxVal = Math.max(...totals, 1);

  const isDark    = state.theme === 'dark';
  const barColor  = isDark ? '#4CAF50' : '#2E7D32';
  const barHover  = isDark ? '#81C784' : '#4CAF50';
  const textColor = isDark ? 'rgba(232,234,240,0.6)' : 'rgba(27,42,28,0.6)';
  const gridColor = isDark ? 'rgba(255,255,255,0.05)' : 'rgba(0,0,0,0.06)';

  const padL = 10, padR = 10, padT = 16, padB = 36;
  const chartW = W - padL - padR;
  const chartH = 200 - padT - padB;
  const barW   = (chartW / 12) * 0.55;
  const gap    = (chartW / 12) * 0.45;

  // Grid lines (4 lines)
  ctx.strokeStyle = gridColor;
  ctx.lineWidth = 1;
  for (let i = 1; i <= 4; i++) {
    const y = padT + chartH - (chartH / 4) * i;
    ctx.beginPath();
    ctx.moveTo(padL, y);
    ctx.lineTo(W - padR, y);
    ctx.stroke();
  }

  totals.forEach((val, i) => {
    const x    = padL + i * (chartW / 12) + gap / 2;
    const barH = (val / maxVal) * chartH;
    const y    = padT + chartH - barH;

    // Bar
    ctx.fillStyle = barColor;
    const r = Math.min(5, barW / 2);
    ctx.beginPath();
    ctx.moveTo(x + r, y);
    ctx.lineTo(x + barW - r, y);
    ctx.arcTo(x + barW, y, x + barW, y + r, r);
    ctx.lineTo(x + barW, y + barH);
    ctx.lineTo(x, y + barH);
    ctx.arcTo(x, y, x + r, y, r);
    ctx.closePath();
    ctx.fill();

    // Value label on top if > 0
    if (val > 0) {
      ctx.fillStyle = textColor;
      ctx.font = '10px Space Grotesk, sans-serif';
      ctx.textAlign = 'center';
      ctx.fillText(fmtMoney(val), x + barW / 2, y - 4);
    }

    // Month label
    ctx.fillStyle = textColor;
    ctx.font = '11px Space Grotesk, sans-serif';
    ctx.textAlign = 'center';
    ctx.fillText(monthNames[i], x + barW / 2, 200 - 10);
  });
}

// ── Annual pie chart (dashboard) ─────────────────────────────────────────
function renderDashPieChart(yearEx) {
  const canvas    = document.getElementById('dashPieChart');
  const ctx       = canvas.getContext('2d');
  const legendEl  = document.getElementById('dashChartLegend');
  const isDark    = state.theme === 'dark';

  ctx.clearRect(0, 0, canvas.width, canvas.height);
  legendEl.innerHTML = '';

  const bycat   = {};
  yearEx.forEach(e => { bycat[e.categoryId] = (bycat[e.categoryId] || 0) + e.amount; });
  const entries = Object.entries(bycat).sort((a, b) => b[1] - a[1]);
  const total   = yearEx.reduce((s, e) => s + e.amount, 0);

  if (entries.length === 0) {
    ctx.fillStyle = isDark ? '#1e2336' : '#e8f5e9';
    ctx.beginPath();
    ctx.arc(100, 100, 90, 0, Math.PI * 2);
    ctx.fill();
    legendEl.innerHTML = '<p class="empty-msg">Sin datos este año</p>';
    return;
  }

  drawDonut(ctx, canvas, entries, total, isDark);

  entries.forEach(([catId, amount]) => {
    const cat = getCat(catId);
    const pct = ((amount / total) * 100).toFixed(1);
    const item = document.createElement('div');
    item.className = 'legend-item';
    item.innerHTML = `
      <span class="legend-dot" style="background:${cat.color}"></span>
      <span>${cat.icon} ${cat.name}</span>
      <span style="color:var(--ink-soft);margin-left:auto;padding-left:12px">${pct}%</span>`;
    legendEl.appendChild(item);
  });
}

// ─── HISTORY ─────────────────────────────────────────────────────────────
function renderHistory() {
  const period = document.getElementById('filterPeriod').value;
  const catId  = document.getElementById('filterCategory').value;
  const sort   = document.getElementById('filterSort').value;
  const search = document.getElementById('filterSearch').value.trim().toLowerCase();

  // Populate category filter
  const catSel = document.getElementById('filterCategory');
  const prevVal = catSel.value;
  catSel.innerHTML = '<option value="">Todas las categorías</option>';
  state.categories.forEach(c => {
    const opt = document.createElement('option');
    opt.value = c.id;
    opt.textContent = `${c.icon} ${c.name}`;
    catSel.appendChild(opt);
  });
  catSel.value = prevVal;

  const now = new Date();
  let filtered = state.expenses.filter(e => {
    const d = new Date(e.date);
    if (period === 'week')  return d >= startOfWeek();
    if (period === 'month') return d.getFullYear() === now.getFullYear() && d.getMonth() === now.getMonth();
    if (period === 'year')  return d.getFullYear() === now.getFullYear();
    return true;
  });

  if (catId) filtered = filtered.filter(e => e.categoryId === catId);
  if (search) {
    filtered = filtered.filter(e => {
      const cat = getCat(e.categoryId);
      return (e.note || '').toLowerCase().includes(search) ||
             cat.name.toLowerCase().includes(search) ||
             String(e.amount).includes(search);
    });
  }

  filtered = filtered.slice().sort((a, b) => {
    if (sort === 'newest')  return new Date(b.date) - new Date(a.date);
    if (sort === 'oldest')  return new Date(a.date) - new Date(b.date);
    if (sort === 'highest') return b.amount - a.amount;
    if (sort === 'lowest')  return a.amount - b.amount;
    return 0;
  });

  document.getElementById('historyTotal').textContent = fmtMoney(filtered.reduce((s, e) => s + e.amount, 0));
  renderExpenseList('historyList', 'historyEmpty', filtered);
  renderPieChart(filtered);
}

// ─── PIE CHART (history) ──────────────────────────────────────────────────
function renderPieChart(expenses) {
  const canvas   = document.getElementById('pieChart');
  const ctx      = canvas.getContext('2d');
  const legendEl = document.getElementById('chartLegend');
  const isDark   = state.theme === 'dark';

  ctx.clearRect(0, 0, canvas.width, canvas.height);
  legendEl.innerHTML = '';

  const bycat   = {};
  expenses.forEach(e => { bycat[e.categoryId] = (bycat[e.categoryId] || 0) + e.amount; });
  const entries = Object.entries(bycat).sort((a, b) => b[1] - a[1]);
  const total   = expenses.reduce((s, e) => s + e.amount, 0);

  if (entries.length === 0) {
    ctx.fillStyle = isDark ? '#1e2336' : '#e8f5e9';
    ctx.beginPath();
    ctx.arc(110, 110, 100, 0, Math.PI * 2);
    ctx.fill();
    legendEl.innerHTML = '<p class="empty-msg">Sin datos</p>';
    return;
  }

  drawDonut(ctx, canvas, entries, total, isDark);

  entries.forEach(([catId, amount]) => {
    const cat = getCat(catId);
    const pct = ((amount / total) * 100).toFixed(1);
    const item = document.createElement('div');
    item.className = 'legend-item';
    item.innerHTML = `
      <span class="legend-dot" style="background:${cat.color}"></span>
      <span>${cat.icon} ${cat.name}</span>
      <span style="color:var(--ink-soft);margin-left:auto;padding-left:12px">${pct}%</span>`;
    legendEl.appendChild(item);
  });
}

function drawDonut(ctx, canvas, entries, total, isDark) {
  const cx = canvas.width / 2, cy = canvas.height / 2;
  const r  = Math.min(cx, cy) - 8;
  const inner = r * 0.52;
  let startAngle = -Math.PI / 2;

  entries.forEach(([catId, amount]) => {
    const cat   = getCat(catId);
    const slice = (amount / total) * Math.PI * 2;
    ctx.beginPath();
    ctx.moveTo(cx, cy);
    ctx.arc(cx, cy, r, startAngle, startAngle + slice);
    ctx.closePath();
    ctx.fillStyle = cat.color;
    ctx.fill();
    startAngle += slice;
  });

  // Donut hole
  ctx.beginPath();
  ctx.arc(cx, cy, inner, 0, Math.PI * 2);
  ctx.fillStyle = isDark ? '#181c27' : '#ffffff';
  ctx.fill();

  // Center text
  ctx.fillStyle = isDark ? '#e8eaf0' : '#1b2a1c';
  ctx.font = 'bold 13px Space Grotesk, sans-serif';
  ctx.textAlign = 'center';
  ctx.textBaseline = 'middle';
  ctx.fillText(fmtMoney(total), cx, cy);
}

// ─── SETTINGS ─────────────────────────────────────────────────────────────
function renderSettings() {
  const listEl = document.getElementById('catList');
  listEl.innerHTML = '';
  state.categories.forEach(cat => {
    const row = document.createElement('div');
    row.className = 'cat-row';
    row.innerHTML = `
      <div class="cat-swatch" style="background:${cat.color}22">${cat.icon}</div>
      <span class="cat-row-name">${cat.name}</span>
      ${cat.isCustom ? `<button class="icon-btn del" data-delcat="${cat.id}" title="Eliminar">🗑</button>` : ''}`;
    listEl.appendChild(row);
  });
  listEl.querySelectorAll('[data-delcat]').forEach(btn => {
    btn.addEventListener('click', () => {
      state.categories = state.categories.filter(c => c.id !== btn.dataset.delcat);
      saveCategories();
      renderSettings();
      showToast('Categoría eliminada');
    });
  });
}

document.getElementById('addCatBtn').addEventListener('click', () => {
  document.getElementById('catModalBackdrop').hidden = false;
});

document.getElementById('catModalClose').addEventListener('click', closeCatModal);
document.getElementById('catModalCancel').addEventListener('click', closeCatModal);

function closeCatModal() {
  document.getElementById('catModalBackdrop').hidden = true;
  document.getElementById('catForm').reset();
}

document.getElementById('catForm').addEventListener('submit', e => {
  e.preventDefault();
  const name  = document.getElementById('catName').value.trim();
  const color = document.getElementById('catColor').value;
  const icon  = document.getElementById('catIcon').value.trim() || '📌';
  if (!name) return;
  state.categories.push({ id: uid(), name, color, icon, isCustom: true });
  saveCategories();
  renderSettings();
  populateCategorySelect();
  closeCatModal();
  showToast('Categoría creada');
});

document.getElementById('clearDataBtn').addEventListener('click', () => {
  if (!confirm('¿Borrar todos los gastos? Esta acción no se puede deshacer.')) return;
  state.expenses = [];
  saveExpenses();
  renderHome();
  showToast('Datos eliminados');
});

// ─── ADD / EDIT MODAL ─────────────────────────────────────────────────────
function populateCategorySelect() {
  const sel  = document.getElementById('fCategory');
  const prev = sel.value;
  sel.innerHTML = '';
  state.categories.forEach(c => {
    const opt = document.createElement('option');
    opt.value = c.id;
    opt.textContent = `${c.icon} ${c.name}`;
    sel.appendChild(opt);
  });
  if (prev) sel.value = prev;
}

function openAddModal() {
  if (state.session && !ROLES[state.session.role].canWrite) return;
  document.getElementById('modalTitle').textContent   = 'Añadir gasto';
  document.getElementById('formSubmit').textContent   = 'Guardar';
  document.getElementById('editId').value  = '';
  document.getElementById('fAmount').value = '';
  document.getElementById('fNote').value   = '';
  document.getElementById('fDate').value   = todayISO();
  populateCategorySelect();
  document.getElementById('modalBackdrop').hidden = false;
  document.getElementById('fAmount').focus();
}

function openEditModal(id) {
  if (state.session && !ROLES[state.session.role].canWrite) return;
  const expense = state.expenses.find(e => e.id === id);
  if (!expense) return;
  document.getElementById('modalTitle').textContent     = 'Editar gasto';
  document.getElementById('formSubmit').textContent     = 'Actualizar';
  document.getElementById('editId').value   = id;
  document.getElementById('fAmount').value  = expense.amount;
  document.getElementById('fDate').value    = expense.date;
  document.getElementById('fNote').value    = expense.note || '';
  populateCategorySelect();
  document.getElementById('fCategory').value = expense.categoryId;
  document.getElementById('modalBackdrop').hidden = false;
  document.getElementById('fAmount').focus();
}

function closeModal() {
  document.getElementById('modalBackdrop').hidden = true;
  document.getElementById('expenseForm').reset();
}

document.getElementById('openAddBtn').addEventListener('click', openAddModal);
document.getElementById('modalClose').addEventListener('click', closeModal);
document.getElementById('modalCancel').addEventListener('click', closeModal);
document.getElementById('modalBackdrop').addEventListener('click', e => {
  if (e.target === e.currentTarget) closeModal();
});

document.getElementById('expenseForm').addEventListener('submit', e => {
  e.preventDefault();
  const amount = parseFloat(document.getElementById('fAmount').value);
  const catId  = document.getElementById('fCategory').value;
  const date   = document.getElementById('fDate').value;
  const note   = document.getElementById('fNote').value.trim();
  const editId = document.getElementById('editId').value;

  if (!amount || amount <= 0 || !catId || !date) return;

  if (editId) {
    const idx = state.expenses.findIndex(e => e.id === editId);
    if (idx !== -1) {
      state.expenses[idx] = { ...state.expenses[idx], amount, categoryId: catId, date, note };
      showToast('Gasto actualizado');
    }
  } else {
    state.expenses.push({ id: uid(), amount, categoryId: catId, date, note });
    showToast('Gasto guardado ✓');
  }

  saveExpenses();
  closeModal();
  renderHome();
  if (document.getElementById('view-dashboard').classList.contains('active')) renderDashboard();
  if (document.getElementById('view-history').classList.contains('active'))   renderHistory();
});

// ─── HISTORY FILTERS ──────────────────────────────────────────────────────
['filterPeriod','filterCategory','filterSort','filterSearch'].forEach(id => {
  document.getElementById(id).addEventListener('input', renderHistory);
});

// ─── Dashboard year filter ─────────────────────────────────────────────────
document.getElementById('dashYear').addEventListener('change', renderDashboard);

// ─── DELETE ───────────────────────────────────────────────────────────────
function deleteExpense(id) {
  if (state.session && !ROLES[state.session.role].canDelete) return;
  if (!confirm('¿Eliminar este gasto?')) return;
  state.expenses = state.expenses.filter(e => e.id !== id);
  saveExpenses();
  renderHome();
  if (document.getElementById('view-dashboard').classList.contains('active')) renderDashboard();
  if (document.getElementById('view-history').classList.contains('active'))   renderHistory();
  showToast('Gasto eliminado');
}

// ─── INIT ─────────────────────────────────────────────────────────────────
loadState();
applyTheme(state.theme);

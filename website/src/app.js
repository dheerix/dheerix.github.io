const app = document.querySelector("#app");
let documents = [];
let sections = [];
let currentPath = "";

const escapeHtml = value => String(value).replaceAll("&", "&amp;").replaceAll("<", "&lt;").replaceAll(">", "&gt;").replaceAll('"', "&quot;");

function resolvePath(href) {
  const parts = `${currentPath.split("/").slice(0, -1).join("/")}/${href}`.split("/");
  const result = [];
  for (const part of parts) {
    if (!part || part === ".") continue;
    if (part === "..") result.pop(); else result.push(part);
  }
  return result.join("/").split("#")[0];
}

function inline(value) {
  return escapeHtml(value)
    .replace(/!\[([^\]]*)\]\(([^)]+)\)/g, '<span class="image-note">Image: $1</span>')
    .replace(/\[([^\]]+)\]\(([^)]+)\)/g, (_, label, href) => `<a href="${href.includes(".md") ? `#/doc/${encodeURIComponent(resolvePath(href))}` : href}">${label}</a>`)
    .replace(/`([^`]+)`/g, "<code>$1</code>")
    .replace(/\*\*([^*]+)\*\*/g, "<strong>$1</strong>")
    .replace(/\*([^*]+)\*/g, "<em>$1</em>");
}

function markdown(source) {
  const lines = source.replace(/\r\n/g, "\n").split("\n");
  let html = "", paragraph = [], list = "", code = null, table = [];
  const flushParagraph = () => { if (paragraph.length) html += `<p>${inline(paragraph.join(" "))}</p>`; paragraph = []; };
  const flushList = () => { if (list) html += `</${list}>`; list = ""; };
  const flushTable = () => {
    if (table.length > 1) {
      const rows = table.map(row => row.replace(/^\||\|$/g, "").split("|").map(cell => cell.trim()));
      html += `<div class="table-wrap"><table><thead><tr>${rows[0].map(cell => `<th>${inline(cell)}</th>`).join("")}</tr></thead><tbody>${rows.slice(2).map(row => `<tr>${row.map(cell => `<td>${inline(cell)}</td>`).join("")}</tr>`).join("")}</tbody></table></div>`;
    }
    table = [];
  };
  const flush = () => { flushParagraph(); flushList(); flushTable(); };

  for (const raw of lines) {
    const line = raw.trimEnd();
    if (line.startsWith("```")) {
      if (code !== null) { html += `<pre><code>${escapeHtml(code.join("\n"))}</code></pre>`; code = null; }
      else { flush(); code = []; }
      continue;
    }
    if (code !== null) { code.push(raw); continue; }
    if (/^\|.*\|$/.test(line)) { flushParagraph(); flushList(); table.push(line); continue; }
    if (table.length) flushTable();
    if (!line.trim()) { flush(); continue; }
    const heading = line.match(/^(#{1,6})\s+(.+)$/);
    if (heading) {
      flush();
      const level = Math.min(heading[1].length + 1, 6);
      const id = heading[2].toLowerCase().replace(/[^a-z0-9]+/g, "-").replace(/^-|-$/g, "");
      html += `<h${level} id="${id}">${inline(heading[2])}</h${level}>`;
      continue;
    }
    if (/^---+$/.test(line)) { flush(); html += "<hr>"; continue; }
    if (line.startsWith("> ")) { flush(); html += `<blockquote>${inline(line.slice(2))}</blockquote>`; continue; }
    const unordered = line.match(/^\s*[-*+]\s+(.+)$/);
    const ordered = line.match(/^\s*\d+[.)]\s+(.+)$/);
    if (unordered || ordered) {
      flushParagraph();
      const nextList = ordered ? "ol" : "ul";
      if (list !== nextList) { flushList(); html += `<${nextList}>`; list = nextList; }
      html += `<li>${inline((unordered || ordered)[1])}</li>`;
    } else { flushList(); paragraph.push(line.trim()); }
  }
  flush();
  if (code !== null) html += `<pre><code>${escapeHtml(code.join("\n"))}</code></pre>`;
  return html;
}

function card(doc) {
  return `<a class="document-card" href="#/doc/${encodeURIComponent(doc.path)}"><span class="card-meta">${escapeHtml(doc.sectionTitle)} · ${doc.words.toLocaleString()} words</span><strong>${escapeHtml(doc.title)}</strong><p>${escapeHtml(doc.description)}</p><span class="card-action">Read note <b>→</b></span></a>`;
}

function home() {
  const picks = ["interviews/README.md", "interviews/one-week-plan.md", "interviews/system-design.md", "interviews/technical-depth.md", "career/sde3-depth-roadmap-2026-27.md", "projects/guardlane/README.md"].map(path => documents.find(doc => doc.path === path)).filter(Boolean);
  const words = documents.reduce((sum, doc) => sum + doc.words, 0);
  app.innerHTML = `<section class="hero"><div class="hero-copy"><span class="kicker">A working engineering library</span><h1>Build depth.<br><em>Show the work.</em></h1><p>Interview systems, coding patterns, project decisions, and fourteen years of production lessons—organized to turn accumulated notes into deliberate practice.</p><div class="hero-actions"><a class="button primary" href="#/section/interviews">Start interview prep</a><a class="button ghost" href="#/section/projects">Explore project work</a></div></div><aside class="focus-panel"><span class="panel-label">Interview focus</span>${[["35%", "Coding & DSA"], ["25%", "System design"], ["15%", "Technical depth"], ["25%", "Projects, behavior & mocks"]].map(([value, label]) => `<div><strong>${value}</strong><span>${label}</span></div>`).join("")}</aside></section>
  <section class="stats"><div><strong>${documents.length}</strong><span>Documents</span></div><div><strong>${sections.length}</strong><span>Collections</span></div><div><strong>${Math.round(words / 1000)}k</strong><span>Words indexed</span></div><div><strong>75</strong><span>Coding drills</span></div></section>
  <section class="content-section"><div class="section-heading"><span class="kicker">Start here</span><h2>Your preparation desk</h2><p>High-leverage guides for active interview preparation.</p></div><div class="card-grid">${picks.map(card).join("")}</div></section>
  <section class="content-section section-tint"><div class="section-heading"><span class="kicker">The library</span><h2>Explore by collection</h2></div><div class="collection-grid">${sections.map(section => `<a class="collection-card" href="#/section/${section.id}"><span>${String(section.order).padStart(2, "0")}</span><div><strong>${escapeHtml(section.title)}</strong><p>${escapeHtml(section.description)}</p></div><b>${section.count}</b></a>`).join("")}</div></section>`;
}

function section(id) {
  const metadata = sections.find(item => item.id === id);
  if (!metadata) return notFound();
  const items = documents.filter(doc => doc.section === id);
  app.innerHTML = `<section class="page-hero"><a class="back-link" href="#/">← All collections</a><span class="kicker">Collection ${String(metadata.order).padStart(2, "0")}</span><h1>${escapeHtml(metadata.title)}</h1><p>${escapeHtml(metadata.description)}</p><div class="section-count">${items.length} documents · ${items.reduce((sum, item) => sum + item.words, 0).toLocaleString()} words</div></section><section class="content-section"><div class="filter-row"><label><span>Filter collection</span><input id="section-filter" type="search" placeholder="Type to filter…"></label></div><div class="card-grid" id="section-results">${items.map(card).join("")}</div></section>`;
  document.querySelector("#section-filter").addEventListener("input", event => {
    const query = event.target.value.toLowerCase().trim();
    const matches = items.filter(item => `${item.title} ${item.description} ${item.path}`.toLowerCase().includes(query));
    document.querySelector("#section-results").innerHTML = matches.length ? matches.map(card).join("") : '<p class="empty-state">No matching documents.</p>';
  });
}

function documentPage(path) {
  const doc = documents.find(item => item.path === path);
  if (!doc) return notFound();
  currentPath = doc.path;
  const group = documents.filter(item => item.section === doc.section);
  const index = group.findIndex(item => item.path === doc.path);
  const previous = group[index - 1], next = group[index + 1];
  app.innerHTML = `<div class="reader-shell"><aside class="reader-sidebar"><a class="back-link" href="#/section/${doc.section}">← ${escapeHtml(doc.sectionTitle)}</a><span class="kicker">In this collection</span><nav>${group.map(item => `<a class="${item.path === doc.path ? "active" : ""}" href="#/doc/${encodeURIComponent(item.path)}">${escapeHtml(item.title)}</a>`).join("")}</nav></aside><article class="reader"><header><span class="card-meta">${escapeHtml(doc.sectionTitle)} · ${doc.words.toLocaleString()} words</span><h1>${escapeHtml(doc.title)}</h1><code>${escapeHtml(doc.path)}</code></header><div class="markdown-body">${markdown(doc.content)}</div><nav class="reader-pagination">${previous ? `<a href="#/doc/${encodeURIComponent(previous.path)}"><span>Previous</span>${escapeHtml(previous.title)}</a>` : "<i></i>"}${next ? `<a class="next" href="#/doc/${encodeURIComponent(next.path)}"><span>Next</span>${escapeHtml(next.title)}</a>` : ""}</nav></article></div>`;
}

function search(query) {
  const needle = query.toLowerCase().trim();
  const results = needle ? documents.filter(doc => `${doc.title} ${doc.description} ${doc.path} ${doc.content}`.toLowerCase().includes(needle)).slice(0, 60) : [];
  app.innerHTML = `<section class="page-hero search-hero"><a class="back-link" href="#/">← Home</a><span class="kicker">Search the library</span><h1>Find an idea</h1><label class="search-box"><span>⌕</span><input id="global-search" type="search" value="${escapeHtml(query)}" placeholder="Search system design, leadership, graphs…"></label><p>${needle ? `${results.length}${results.length === 60 ? "+" : ""} results` : "Search across every indexed note."}</p></section><section class="content-section"><div class="card-grid">${results.map(card).join("") || '<p class="empty-state">Start typing to search the complete library.</p>'}</div></section>`;
  const input = document.querySelector("#global-search"); input.focus();
  input.addEventListener("input", event => { clearTimeout(input.timer); input.timer = setTimeout(() => location.hash = `#/search/${encodeURIComponent(event.target.value)}`, 180); });
}

function notFound() { app.innerHTML = '<section class="page-hero"><span class="kicker">404</span><h1>That note wandered off.</h1><p>The requested document could not be found.</p><a class="button primary" href="#/">Return home</a></section>'; }
function route() {
  const parts = (location.hash || "#/").slice(2).split("/");
  if (parts[0] === "doc") documentPage(decodeURIComponent(parts.slice(1).join("/")));
  else if (parts[0] === "section") section(parts[1]);
  else if (parts[0] === "search") search(decodeURIComponent(parts.slice(1).join("/")));
  else home();
  window.scrollTo(0, 0); app.focus({ preventScroll: true });
}

document.querySelector("#theme-button").addEventListener("click", () => { const dark = document.documentElement.toggleAttribute("data-dark"); localStorage.setItem("dheerix-theme", dark ? "dark" : "light"); });
if (localStorage.getItem("dheerix-theme") === "dark" || (!localStorage.getItem("dheerix-theme") && matchMedia("(prefers-color-scheme: dark)").matches)) document.documentElement.setAttribute("data-dark", "");
document.addEventListener("keydown", event => { if (event.key === "/" && !/input|textarea/i.test(document.activeElement.tagName)) { event.preventDefault(); location.hash = "#/search/"; } });

fetch("./documents.json").then(response => { if (!response.ok) throw new Error("Unable to load the document index."); return response.json(); }).then(data => {
  documents = data.documents;
  const map = new Map();
  for (const doc of documents) { if (!map.has(doc.section)) map.set(doc.section, { id: doc.section, title: doc.sectionTitle, description: doc.sectionDescription, order: doc.sectionOrder, count: 0 }); map.get(doc.section).count++; }
  sections = [...map.values()].sort((a, b) => a.order - b.order || a.title.localeCompare(b.title));
  route(); window.addEventListener("hashchange", route);
}).catch(error => { app.innerHTML = `<section class="page-hero"><h1>Could not open the library.</h1><p>${escapeHtml(error.message)} Serve the generated site through a local web server.</p></section>`; });

# Highlight Cards Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a reusable card highlight flag so selected tools render with an animated flowing accent, and future cards can opt in by changing only one data field.

**Architecture:** Keep the data source as the single source of truth by adding a `highlight` boolean to tool items in `tools.json`. Teach the card renderer in `index.html` to emit a highlight class when that flag is present, and add CSS that layers a subtle animated gradient over the existing card design without affecting normal cards.

**Tech Stack:** Static HTML, CSS, vanilla JavaScript, `tools.json`.

---

### Task 1: Add highlight metadata to one sample card

**Files:**
- Modify: `tools.json`

- [ ] **Step 1: Add the failing data case**

Add `highlight: true` to one card entry so the UI has a concrete example to render:

```json
{
  "id": "d1",
  "title": "绛栧垝澶氳瑷€缈昏瘧宸ュ叿锛堢爺鍙戯細婊嬮槼锛?,
  "desc": "Lang琛ㄧ炕璇戞彁闇€娴佺▼",
  "info": "璇ュ伐鍏风敤浜庡鐞嗗璇█缈昏瘧闇€姹?,
  "tag": "DOC",
  "highlight": true,
  "image": "assets/fanyi.png",
  "link": "https://bonny0506.netlify.app/"
}
```

- [ ] **Step 2: Confirm the data shape is still valid**

Run:

```powershell
Get-Content tools.json | Select-String '"highlight"'
```

Expected: the selected card now includes `"highlight": true`.

### Task 2: Render highlighted cards with an opt-in class

**Files:**
- Modify: `index.html`

- [ ] **Step 1: Add the rendering hook**

Extend `createCard(item)` so highlighted cards emit an additional class:

```javascript
const isHighlighted = item.highlight === true;
return `
  <div class="card ${isHighlighted ? 'is-highlight' : ''}" ...>
```

- [ ] **Step 2: Keep the default cards unchanged**

Use the existing card markup for all non-highlight cards so current behavior stays intact.

- [ ] **Step 3: Verify the rendered class exists**

Run:

```powershell
Select-String -Path index.html -Pattern "is-highlight"
```

Expected: the highlight class is emitted only from the renderer, not applied globally.

### Task 3: Add the flowing accent animation

**Files:**
- Modify: `index.html`

- [ ] **Step 1: Add highlight CSS**

Create a reusable animated accent layer for `.card.is-highlight` that:

- keeps the existing card border and layout
- adds a slow-moving multi-stop gradient wash
- increases glow slightly on hover
- remains subtle enough to preserve overall consistency

- [ ] **Step 2: Ensure reduced-motion support**

Extend the existing `prefers-reduced-motion` block so the highlight animation also turns off when motion reduction is requested.

- [ ] **Step 3: Verify CSS is present**

Run:

```powershell
Select-String -Path index.html -Pattern "is-highlight|highlightFlow|highlight"
```

Expected: highlight styles and animation keyframes are present.

### Task 4: Sanity-check the page

**Files:**
- None

- [ ] **Step 1: Reload and inspect the page**

Open the page locally and confirm:

- the marked card shows the flowing accent
- unmarked cards remain unchanged
- the highlight is controlled only by the new data flag

- [ ] **Step 2: Capture any cleanup needed**

If the effect feels too strong, reduce opacity or animation speed before finishing.


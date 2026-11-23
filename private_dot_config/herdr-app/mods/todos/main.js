// TODOs per space: a scratch list so nothing gets forgotten.
// Stored in shared "todos" as { [spaceId]: [{ id, text, done, due? }] } ("due": "YYYY-MM-DD"),
// so it survives restarts. The stored order is the priority: drag the ⠿ handle to change it.
//
// Outside entrance (for scripts and agents), in ~/.config/herdr-app/todos-io/:
// - todos.json: read-only mirror, rewritten whenever the list changes:
//   { spaces: { [spaceId]: name }, todos: { [spaceId]: [...] } }
// - inbox.json: write the whole new `todos` object here (same shape as the mirror's
//   `todos`, or the full mirror). It replaces the list, then the file is removed.
//   An invalid inbox is renamed to inbox.rejected.json and nothing changes.
//   The inbox is read once this mod has been shown since Herdr started.
import { View, div, svg } from "gpui-kit";
import { v_flex, h_flex, InputState, Input, Scrollbar, CalendarState } from "gpui-base";
import { spaces, theme, shared, setShared, appHome, checking, readTextFile, writeTextFile, watchFolder } from "herdr";
import * as fs from "fs/promises";

const all = () => shared("todos") ?? {};
const activeSpace = () => spaces().find((s) => s.active);

const ioDir = () => `${appHome()}/todos-io`;
let exported = null; // the mirror text last written, so unchanged lists aren't rewritten

async function exportTodos() {
  const names = Object.fromEntries(spaces().map((s) => [s.id, s.name ?? ""]));
  const text = `${JSON.stringify({ spaces: names, todos: all() }, null, 2)}\n`;
  if (text === exported) return;
  exported = text;
  const path = `${ioDir()}/todos.json`;
  await writeTextFile(path, text, await readTextFile(path));
}

const validItem = (i) => i && typeof i.text === "string" && i.text.trim() !== "" && typeof (i.done ?? false) === "boolean"
  && (i.due == null || /^\d{4}-\d{2}-\d{2}$/.test(i.due));

async function applyInbox() {
  const path = `${ioDir()}/inbox.json`, text = await readTextFile(path);
  if (text == null || text.trim() === "") return false;
  let next;
  try {
    const parsed = JSON.parse(text);
    next = parsed && typeof parsed === "object" && parsed.todos && !Array.isArray(parsed.todos) ? parsed.todos : parsed;
    if (!next || typeof next !== "object" || Array.isArray(next)) throw new Error("not an object");
    for (const list of Object.values(next)) if (!Array.isArray(list) || !list.every(validItem)) throw new Error("bad item");
  } catch (e) {
    const rejected = `${ioDir()}/inbox.rejected.json`;
    await writeTextFile(rejected, `${e}\n\n${text}`, await readTextFile(rejected));
    await consume(path, text);
    return false;
  }
  const newId = () => `${Date.now().toString(36)}${Math.random().toString(36).slice(2, 6)}`;
  const clean = {};
  for (const [space, list] of Object.entries(next)) {
    if (!list.length) continue;
    clean[space] = list.map(({ id, text: t, done, due }) => ({ id: id || newId(), text: t.trim(), done: Boolean(done), ...(due ? { due } : {}) }));
  }
  setShared("todos", clean);
  await consume(path, text);
  return true;
}

// Remove the inbox; where deleting isn't allowed, empty it (an empty inbox means nothing to do).
async function consume(path, text) {
  try { await fs.unlink(path); } catch { await writeTextFile(path, "", text); }
}

function save(spaceId, list) {
  const next = { ...all() };
  if (list.length) next[spaceId] = list; else delete next[spaceId];
  setShared("todos", next);
}

// Local dates as "YYYY-MM-DD", the same shape CalendarState uses.
const ymd = (d) => `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, "0")}-${String(d.getDate()).padStart(2, "0")}`;
const addDays = (n) => { const d = new Date(); d.setDate(d.getDate() + n); return ymd(d); };
const daysUntil = (due) => Math.round((new Date(`${due}T00:00:00`) - new Date(`${ymd(new Date())}T00:00:00`)) / 86400000);
const short = (due) => `${Number(due.slice(5, 7))}/${Number(due.slice(8))}`;

function dueLabel(due, t) {
  const n = daysUntil(due);
  if (n < 0) return { text: `逾期 ${short(due)}`, color: t.ansi1 };
  if (n === 0) return { text: "今天", color: t.blocked };
  if (n === 1) return { text: "明天", color: t.blocked };
  if (n <= 3) return { text: short(due), color: t.accent };
  return { text: short(due), color: t.dim };
}

export default class Todos extends View {
  init(_props, cx) {
    this.handle = cx.focus_handle();
    this.input = InputState.new({ placeholder: "Add a TODO, Enter to save" });
    this.input.on("submit", (_e, cx) => { this.add(); cx.notify(); });
    this.input.on("focus", (_e, cx) => { this.typing = true; cx.notify(); });
    this.input.on("blur", (_e, cx) => { this.typing = false; cx.notify(); });
    // One editor shared by every row: double-click a TODO's text to edit it in place.
    // Enter or clicking away saves, Escape cancels, an emptied text keeps the old one.
    this.editor = InputState.new();
    this.editing = null;    // id of the TODO whose text is being edited
    this.editor.on("submit", (_e, cx) => { this.commitEdit(); cx.notify(); });
    this.editor.on("blur", (_e, cx) => { this.commitEdit(); cx.notify(); });
    this.calendar = CalendarState.new();
    this.picking = null;   // id of the TODO whose deadline calendar is open
    this.confirming = null; // id of the TODO waiting for a delete confirmation
    this.drag = null;       // id being dragged by its handle
    this.over = null;       // id the pointer is over while dragging
    if (checking()) return;
    cx.spawn(async (cx) => {
      await fs.mkdir(ioDir(), { recursive: true });
      for (;;) {
        try {
          if (await applyInbox()) cx.notify();
          await exportTodos();
        } catch (e) { console.log(`todos io: ${e}`); }
        await watchFolder(ioDir());
      }
    });
  }

  list(space) { return space ? all()[space.id] ?? [] : []; }

  add() {
    const space = activeSpace(), text = this.input.value().trim();
    if (!space || !text) return;
    const id = `${Date.now().toString(36)}${Math.random().toString(36).slice(2, 6)}`;
    save(space.id, [...this.list(space), { id, text, done: false }]);
    this.input.set_value("");
  }

  update(space, fn) { save(space.id, fn(this.list(space))); }
  patch(space, id, change) { this.update(space, (l) => l.map((i) => (i.id === id ? { ...i, ...change } : i))); }

  startEdit(item) {
    this.editing = item.id; this.picking = null; this.confirming = null;
    this.editor.set_value(item.text);
    this.editor.focus();
  }

  commitEdit() {
    const id = this.editing, space = activeSpace();
    if (!id) return;
    this.editing = null;
    const text = this.editor.value().trim();
    if (space && text) this.patch(space, id, { text });
  }

  // Drop the dragged item where the target is: dragging down lands after it, up before it.
  move(space, from, to) {
    this.update(space, (l) => {
      const a = l.findIndex((i) => i.id === from), b = l.findIndex((i) => i.id === to);
      if (a < 0 || b < 0 || a === b) return l;
      const next = [...l], [item] = next.splice(a, 1);
      next.splice(b, 0, item);
      return next;
    });
  }

  setDue(space, id, due) {
    const { due: _old, ...rest } = this.list(space).find((i) => i.id === id) ?? {};
    this.update(space, (l) => l.map((i) => (i.id === id ? (due ? { ...rest, due } : rest) : i)));
    this.picking = null;
  }

  openPicker(item) {
    if (this.picking === item.id) { this.picking = null; return; }
    this.picking = item.id; this.confirming = null;
    this.calendar = CalendarState.new(); // starts on this month
    if (item.due) this.calendar.set_value(item.due);
  }

  picker(space, item, t, stop) {
    const cal = this.calendar, today = cal.today(), chosen = cal.value();
    const month = cal.month(), year = cal.year();
    const chip = (id, label, action) => div().id(id).px(7).py(2).rounded(5).border_1().border_color(t.border).text_size(11).text_color(t.muted)
      .cursor_pointer().hover((s) => s.bg(t.hover).text_color(t.foreground)).on_mouse_down("left", stop).on_click((e, cx) => { action(e, cx); cx.notify(); }).child(label);
    const nav = (id, label, action) => div().id(id).px(6).rounded(4).text_color(t.muted).cursor_pointer().hover((s) => s.bg(t.hover))
      .on_mouse_down("left", stop).on_click(action).child(label);
    return v_flex().ml(22).mt(4).mb(2).p(8).gap(6).rounded(8).border_1().border_color(t.border).bg(t.surface)
      .child(h_flex().gap(4).flex_wrap()
        .child(chip(`due-today-${item.id}`, "今天", () => this.setDue(space, item.id, addDays(0))))
        .child(chip(`due-tmr-${item.id}`, "明天", () => this.setDue(space, item.id, addDays(1))))
        .child(chip(`due-week-${item.id}`, "一週後", () => this.setDue(space, item.id, addDays(7))))
        .when(Boolean(item.due), (e) => e.child(chip(`due-clear-${item.id}`, "清除", () => this.setDue(space, item.id, null)))))
      .child(h_flex().items_center().text_size(12)
        .child(nav(`cal-prev-${item.id}`, "‹", (_e, cx) => { this.calendar.prev_month(); cx.notify(); }))
        .child(div().flex_1().text_center().font_semibold().child(`${year} / ${month}`))
        .child(nav(`cal-next-${item.id}`, "›", (_e, cx) => { this.calendar.next_month(); cx.notify(); })))
      .child(h_flex().text_size(10).text_color(t.dim).children(["日", "一", "二", "三", "四", "五", "六"].map((d) => div().flex_1().text_center().child(d))))
      .children(cal.month_days()[0].map((week, w) => h_flex().children(week.map((day) => {
        const inMonth = Number(day.slice(5, 7)) === month, on = day === chosen, isToday = day === today;
        return div().id(`cal-${item.id}-${day}`).flex_1().h(24).flex().items_center().justify_center().rounded(5).text_size(11.5).cursor_pointer()
          .text_color(on ? t.accent_foreground : inMonth ? t.foreground : t.dim).when(on, (e) => e.bg(t.accent))
          .when(isToday && !on, (e) => e.border_1().border_color(t.accent))
          .hover((s) => s.bg(on ? t.accent : t.hover)).on_mouse_down("left", stop)
          .on_click((_e, cx) => { this.setDue(space, item.id, day); cx.notify(); }).child(String(Number(day.slice(8))));
      }))));
  }

  render() {
    if (!checking()) exportTodos().catch((e) => console.log(`todos export: ${e}`));
    const t = theme(), space = activeSpace(), items = this.list(space);
    const open = items.filter((i) => !i.done).length, done = items.length - open;
    const stop = (_e, cx) => cx.stop_propagation();
    const row = (item) => {
      const due = item.due ? dueLabel(item.due, t) : null, target = this.drag && this.over === item.id && this.drag !== item.id;
      if (this.confirming === item.id) {
        return h_flex().id(`todo-${item.id}`).min_h(28).flex_none().px(8).py(4).gap(8).items_center().rounded(7).bg(t.raised)
          .child(div().flex_1().min_w(0).truncate().text_color(t.muted).child(`刪除「${item.text}」？`))
          .child(div().id(`todo-del-no-${item.id}`).px(8).py(2).rounded(5).border_1().border_color(t.input).text_size(11).cursor_pointer()
            .hover((s) => s.bg(t.hover)).on_mouse_down("left", stop).on_click((_e, cx) => { this.confirming = null; cx.notify(); }).child("取消"))
          .child(div().id(`todo-del-yes-${item.id}`).px(8).py(2).rounded(5).bg(t.ansi1).text_color(t.background).text_size(11).cursor_pointer()
            .hover((s) => s.opacity(0.88)).on_mouse_down("left", stop)
            .on_click((_e, cx) => { this.confirming = null; this.update(space, (l) => l.filter((i) => i.id !== item.id)); cx.notify(); }).child("刪除"));
      }
      return v_flex().id(`todo-wrap-${item.id}`).flex_none()
        .on_hover((hovered, cx) => { if (!this.drag) return; if (hovered) this.over = item.id; else if (this.over === item.id) this.over = null; cx.notify(); })
        .on_mouse_up("left", (_e, cx) => { if (this.drag && this.drag !== item.id) this.move(space, this.drag, item.id); this.drag = null; this.over = null; cx.notify(); })
        .child(h_flex().id(`todo-${item.id}`).min_h(28).px(8).py(4).gap(8).items_start().rounded(7)
          .border_t(2).border_color(target ? t.accent : t.background)
          .when(this.drag === item.id, (e) => e.opacity(0.5)).hover((s) => s.bg(t.hover))
          .child(div().id(`todo-grip-${item.id}`).mt(1).flex_none().text_color(t.dim).cursor_grab().hover((s) => s.text_color(t.foreground))
            .on_mouse_down("left", (_e, cx) => { cx.stop_propagation(); this.drag = item.id; this.over = null; this.picking = null; cx.notify(); })
            .child("⠿"))
          .child(div().id(`todo-check-${item.id}`).mt(2).size(14).flex_none().flex().items_center().justify_center().rounded(4).border_1()
            .border_color(item.done ? t.accent : t.input).bg(item.done ? t.accent : t.background).text_color(t.accent_foreground).text_size(10).cursor_pointer()
            .on_mouse_down("left", stop).on_click(() => this.patch(space, item.id, { done: !item.done }))
            .child(item.done ? "✓" : ""))
          .child(this.editing === item.id
            ? div().id(`todo-edit-${item.id}`).flex_1().min_w(0).px(4).rounded(4).border_1().border_color(t.accent).cursor_text()
              .on_mouse_down("left", stop)
              .on_key_down((e, cx) => { if (e.key === "escape") { this.editing = null; cx.notify(); } })
              .child(Input.new(this.editor).text_size(13).text_color(t.foreground))
            : div().id(`todo-text-${item.id}`).flex_1().min_w(0).text_color(item.done ? t.dim : t.foreground).when(item.done, (e) => e.line_through())
              .on_click((e, cx) => { if (e.click_count >= 2) { this.startEdit(item); cx.notify(); } })
              .child(item.text))
          .child(div().id(`todo-due-${item.id}`).mt(1).flex_none().px(4).rounded(4).text_size(11).cursor_pointer()
            .text_color(due && !item.done ? due.color : t.dim).hover((s) => s.bg(t.raised).text_color(t.foreground))
            .on_mouse_down("left", stop).on_click((_e, cx) => { this.openPicker(item); cx.notify(); })
            .child(due ? due.text : "📅"))
          .child(div().id(`todo-del-${item.id}`).mt(2).flex_none().text_color(t.dim).cursor_pointer().hover((s) => s.text_color(t.foreground))
            .on_mouse_down("left", stop).on_click((_e, cx) => { this.confirming = item.id; this.picking = null; cx.notify(); })
            .child(svg("mods/pane/close.svg").size(11))))
        .when(this.picking === item.id, (e) => e.child(this.picker(space, item, t, stop)));
    };
    // Open items first, done ones after, each in the stored (priority) order.
    const ordered = [...items.filter((i) => !i.done), ...items.filter((i) => i.done)];
    return v_flex().id("todos").size_full().min_h(0).rounded(10).overflow_hidden().bg(t.background).border_1().border_color(t.border)
      .text_color(t.foreground).text_size(13).track_focus(this.handle)
      .on_mouse_up("left", (_e, cx) => { if (this.drag) { this.drag = null; this.over = null; cx.notify(); } })
      .child(h_flex().h(42).flex_none().px(14).gap(8).items_center().border_b(1).border_color(t.border)
        .child(div().font_semibold().child("TODOs"))
        .child(div().min_w(0).truncate().text_size(11).text_color(t.muted).child(space?.name ?? ""))
        .child(div().flex_1())
        .child(div().text_size(11).text_color(t.muted).child(`${open} open`))
        .when(done > 0, (e) => e.child(div().id("todo-clear").px(6).py(1).rounded(4).border_1().border_color(t.border).text_size(10).text_color(t.muted).cursor_pointer()
          .hover((s) => s.bg(t.hover).text_color(t.foreground)).on_click(() => this.update(space, (l) => l.filter((i) => !i.done)))
          .child(`Clear ${done} done`))))
      .child(h_flex().flex_none().p(10).border_b(1).border_color(t.border)
        .child(div().id("todo-input").flex_1().min_w(0).h(32).px(10).flex().items_center().rounded(8).border_1()
          .border_color(this.typing ? t.accent : t.border).cursor_text().on_mouse_down("left", stop)
          .child(Input.new(this.input).h_full().text_size(12).text_color(t.foreground))))
      .child(div().flex_1().min_h(0).relative()
        .child(v_flex().id("todos-list").absolute().inset_0().overflow_y_scroll().p(6).gap(2)
          .when(Boolean(this.drag), (e) => e.cursor_grabbing())
          .children(ordered.map(row))
          .when(!items.length, (e) => e.child(div().p(8).text_color(t.dim).child(space ? "Nothing here yet" : "No space"))))
        .child(Scrollbar.vertical("todos-list").absolute().inset_0()));
  }
}

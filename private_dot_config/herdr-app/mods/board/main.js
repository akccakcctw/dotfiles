// Board: every space as a card, in the column of what it needs from you.
// Columns are derived, never dragged: agent status from Herdr, open TODOs from shared "todos"
// (the todos mod), uncommitted changes from git. Opened as a window by the rex-tabs Board button.
import { View, div } from "gpui-kit";
import { v_flex, h_flex } from "gpui-base";
import { spaces, panes, run, exec, theme, shared, props, closeOverlay, checking } from "herdr";

const COLUMNS = [
  { id: "attention", title: "需要你", hint: "blocked / done", color: (t) => t.blocked },
  { id: "working", title: "進行中", hint: "agent working", color: (t) => t.working },
  { id: "todo", title: "待辦", hint: "open TODOs", color: (t) => t.accent },
  { id: "idle", title: "閒置", hint: "nothing pending", color: (t) => t.dim },
];

// Where a space's work is now: its first terminal's live folder, else where it starts.
function place(space) {
  const tabIds = new Set(space.tabs.map((x) => x.id));
  const cwd = panes().find((p) => tabIds.has(p.tab) && p.cwd)?.cwd ?? space.folder;
  return cwd ? { cwd, on: space.machine ?? undefined, key: `${space.machine ?? ""}:${cwd}` } : null;
}

function column(space, open) {
  if (space.status === "blocked" || space.status === "done") return "attention";
  if (space.status === "working") return "working";
  if (open.length) return "todo";
  return "idle";
}

export default class Board extends View {
  init(_props, cx) {
    this.dirty = {}; // place key -> number of changed files, null: not a repo
    this.handle = cx.focus_handle();
    this.handle.focus();
    if (checking()) return;
    this.refresh(cx);
    cx.timer.every(15000, (cx) => this.refresh(cx));
  }

  refresh(cx) {
    cx.spawn(async (cx) => {
      const seen = new Map();
      for (const s of spaces()) { const p = place(s); if (p) seen.set(p.key, p); }
      for (const p of seen.values()) {
        try {
          const r = await exec("git", ["status", "--porcelain"], { cwd: p.cwd, on: p.on, timeout: 5000 });
          this.dirty[p.key] = r.code === 0 ? r.stdout.split("\n").filter(Boolean).length : null;
        } catch { this.dirty[p.key] = null; }
      }
      cx.notify();
    });
  }

  close() { const id = props()?.overlay; if (id) closeOverlay(id); }

  render() {
    const t = theme(), todos = shared("todos") ?? {};
    const stop = (_e, cx) => cx.stop_propagation();
    // A folder several spaces share (agent-workspace on main) says nothing about any one of them.
    const sharing = {};
    for (const s of spaces()) { const p = place(s); if (p) sharing[p.key] = (sharing[p.key] ?? 0) + 1; }
    const cards = Object.fromEntries(COLUMNS.map((c) => [c.id, []]));
    for (const s of spaces()) {
      const open = (todos[s.id] ?? []).filter((i) => !i.done);
      cards[column(s, open)].push({ s, open });
    }
    const card = ({ s, open }, accent) => {
      const p = place(s), dirty = p && sharing[p.key] === 1 ? this.dirty[p.key] : null;
      return v_flex().id(`card-${s.id}`).flex_none().p(10).gap(6).rounded(8).border_1()
        .border_color(s.active ? t.accent : t.border).bg(t.surface).cursor_pointer().hover((x) => x.bg(t.hover))
        .on_mouse_down("left", stop)
        .on_click(() => { run("space.select", { id: s.id }); this.close(); })
        .child(h_flex().gap(6).items_center()
          .child(div().size(7).flex_none().rounded(4).bg(accent))
          .child(div().flex_1().min_w(0).truncate().font_semibold().child(s.name))
          .when(Boolean(s.machine), (e) => e.child(div().flex_none().text_size(10).text_color(t.dim).child(s.machine))))
        .child(h_flex().gap(8).text_size(11).text_color(t.muted)
          .when(Boolean(s.branch), (e) => e.child(div().min_w(0).truncate().child(`⎇ ${s.branch}`)))
          .when(dirty > 0, (e) => e.child(div().flex_none().text_color(t.blocked).child(`● ${dirty} changed`)))
          .when(open.length > 0, (e) => e.child(div().flex_none().child(`☐ ${open.length}`))))
        // Up to three open TODOs, one line each; the rest as a count.
        .when(open.length > 0, (e) => e.child(v_flex().gap(2).children(open.slice(0, 3).map((i) =>
          h_flex().gap(6).text_size(11.5).child(div().flex_none().text_color(t.dim).child("•")).child(div().flex_1().min_w(0).truncate().child(i.text))))))
        .when(open.length > 3, (e) => e.child(div().text_size(11).text_color(t.dim).child(`還有 ${open.length - 3} 條`)));
    };
    return v_flex().id("board").size_full().min_h(0).bg(t.background).text_color(t.foreground).text_size(13)
      .track_focus(this.handle).on_key_down((e, cx) => { if (e.key === "escape") { this.close(); cx.stop_propagation(); } })
      .child(h_flex().h(42).flex_none().px(14).gap(8).items_center().border_b(1).border_color(t.border)
        .child(div().font_semibold().child("Board"))
        .child(div().text_size(11).text_color(t.dim).child(`${spaces().length} spaces`))
        .child(div().flex_1())
        .child(div().id("board-close").px(8).py(2).rounded(6).text_size(11).text_color(t.muted).cursor_pointer()
          .hover((x) => x.bg(t.hover).text_color(t.foreground)).on_mouse_down("left", stop)
          .on_click(() => this.close()).child("Esc ✕")))
      .child(h_flex().flex_1().min_h(0).p(10).gap(10).items_start().children(COLUMNS.map((c) =>
        v_flex().id(`col-${c.id}`).flex_1().min_w(0).h_full().rounded(10).bg(t.chrome).border_1().border_color(t.border)
          .child(h_flex().h(36).flex_none().px(12).gap(8).items_center()
            .child(div().size(8).rounded(4).bg(c.color(t)))
            .child(div().font_semibold().child(c.title))
            .child(div().text_size(11).text_color(t.dim).child(String(cards[c.id].length)))
            .child(div().flex_1())
            .child(div().text_size(10).text_color(t.dim).child(c.hint)))
          .child(v_flex().id(`col-list-${c.id}`).flex_1().min_h(0).overflow_y_scroll().px(8).pb(8).gap(6)
            .children(cards[c.id].map((x) => card(x, c.color(t))))))));
  }
}

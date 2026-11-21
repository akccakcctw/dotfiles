import { View, div, svg } from "gpui-kit";
import { h_flex } from "gpui-base";
import { exec, focused, theme, checking, readTextFile } from "herdr";

// 右上角系統資訊：目前 pane 所在目錄的 node 版本（mise）、記憶體用量、時鐘。
// 邏輯同 ~/.wezterm.lua 的 update-status，跨 macOS / Linux 通用。
const pad = (n) => String(n).padStart(2, "0");
const FIND_MISE =
  'command -v mise || for p in /opt/homebrew/bin/mise /usr/local/bin/mise "$HOME/.local/bin/mise" /usr/bin/mise; do [ -x "$p" ] && echo "$p" && break; done; true';

export default class SysInfo extends View {
  init(_props, cx) {
    this.node = null;      // { cwd, ver }
    this.mem = null;       // { text, pct }
    this.now = new Date();
    this.miseBin = null;   // 偵測到的 mise 執行檔路徑
    if (checking()) return;
    this.detectMise(cx);
    this.refreshMem(cx);
    cx.timer.every(1000, (cx) => {
      this.now = new Date();
      if (this.now.getSeconds() % 5 === 0) this.refreshMem(cx);
      cx.notify();
    });
  }

  // 啟動時偵測一次 mise 路徑（各平台安裝位置不同）
  detectMise(cx) {
    cx.spawn(async (cx) => {
      const m = await exec("/bin/sh", ["-c", FIND_MISE]).catch(() => ({ stdout: "" }));
      this.miseBin = m.stdout.trim() || null;
      cx.notify();
    });
  }

  // 記憶體使用量：Linux 讀 /proc/meminfo；macOS 同活動監視器（vm_stat + sysctl）
  refreshMem(cx) {
    cx.spawn(async (cx) => {
      try {
        let used = 0;
        let total = 0;
        const meminfo = await readTextFile("/proc/meminfo");
        if (meminfo) {
          total = Number(meminfo.match(/MemTotal:\s+(\d+)/)?.[1] ?? 0) * 1024;
          const avail = Number(meminfo.match(/MemAvailable:\s+(\d+)/)?.[1] ?? 0) * 1024;
          used = total - avail;
        } else {
          const [vm, sz] = await Promise.all([
            exec("/usr/bin/vm_stat", []),
            exec("/usr/sbin/sysctl", ["-n", "hw.memsize"]),
          ]);
          const out = vm.stdout;
          const page = Number(out.match(/page size of (\d+)/)?.[1] ?? 16384);
          const n = (label) => Number(out.match(new RegExp(label + ":\\s+(\\d+)"))?.[1] ?? 0);
          used = (n("Anonymous pages") - n("Pages purgeable") + n("Pages wired down") + n("Pages occupied by compressor")) * page;
          total = Number(sz.stdout.trim());
        }
        if (total > 0) this.mem = { text: `${(used / 2 ** 30).toFixed(1)}/${Math.round(total / 2 ** 30)}G`, pct: used / total };
        cx.notify();
      } catch { /* 取不到就不顯示 */ }
    });
  }

  render(cx) {
    const t = theme();
    // 依 focused pane 的 cwd 查 node 版本；同一目錄沿用快取
    const cwd = focused()?.cwd ?? null;
    if (cwd && this.miseBin && this.node?.cwd !== cwd && this.loading !== cwd && !checking()) {
      this.loading = cwd;
      cx.spawn(async (cx) => {
        let ver = null;
        try {
          const r = await exec(this.miseBin, ["current", "node"], { cwd, timeout: 5000 });
          ver = r.stdout.trim().split(/\s+/)[0] || null;
        } catch { /* 沒有 mise 或目錄不存在 */ }
        if (this.loading === cwd) { this.node = { cwd, ver }; this.loading = null; }
        cx.notify();
      });
    }
    const ver = this.node?.cwd === cwd ? this.node.ver : this.node?.ver;
    const memColor = (this.mem?.pct ?? 0) > 0.85 ? t.ansi1 : t.ansi4;
    const item = (icon, text, color) => h_flex().gap(5).items_center().text_color(color)
      .child(svg(`mods/sysinfo/${icon}.svg`).size(12)).child(text);
    const d = this.now;
    return h_flex().size_full().pr(14).pl(6).gap(14).items_center().justify_end()
      .bg(t.chrome).border_b(1).border_color(t.border).text_size(12.5).font_family("JetBrains Mono")
      .when(Boolean(ver), (el) => el.child(item("node", ver, t.ansi2)))
      .when(Boolean(this.mem), (el) => el.child(item("memory", this.mem.text, memColor)))
      .child(div().text_color(t.foreground).child(`${pad(d.getHours())}:${pad(d.getMinutes())}:${pad(d.getSeconds())}`));
  }
}

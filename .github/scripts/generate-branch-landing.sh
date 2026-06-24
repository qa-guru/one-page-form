#!/usr/bin/env bash
set -euo pipefail

BRANCH_DIR="${1:?branch directory required}"

branch_name="$(basename "${BRANCH_DIR}")"
latest_run=""

if [ -f "${BRANCH_DIR}/latest-run-id.txt" ]; then
  latest_run="$(tr -d '[:space:]' < "${BRANCH_DIR}/latest-run-id.txt")"
fi

if [ -z "${latest_run}" ] || [ ! -d "${BRANCH_DIR}/${latest_run}" ]; then
  while IFS= read -r run_dir; do
    latest_run="$(basename "${run_dir}")"
  done < <(find "${BRANCH_DIR}" -mindepth 1 -maxdepth 1 -type d -regextype posix-extended -regex '.*/[0-9]+' 2>/dev/null | sort -V | tail -1)
fi

run_links=""
while IFS= read -r run_dir; do
  run_id="$(basename "${run_dir}")"
  run_links="<li><a href=\"${run_id}/index.html\">Run ${run_id}</a></li>${run_links}"
done < <(find "${BRANCH_DIR}" -mindepth 1 -maxdepth 1 -type d -regextype posix-extended -regex '.*/[0-9]+' 2>/dev/null | sort -Vr)

dashboard_frame=""
if [ -f "${BRANCH_DIR}/dashboard/index.html" ]; then
  dashboard_frame='<iframe class="dashboard-frame" src="dashboard/index.html" title="Dashboard"></iframe>'
elif [ -f "${BRANCH_DIR}/index.html" ] && [ ! -f "${BRANCH_DIR}/latest-run-id.txt" ]; then
  dashboard_frame='<iframe class="dashboard-frame" src="index.html" title="Dashboard"></iframe>'
fi

report_cta=""
if [ -n "${latest_run}" ] && [ -f "${BRANCH_DIR}/${latest_run}/index.html" ]; then
  report_cta="<a class=\"btn primary\" href=\"${latest_run}/index.html\">Открыть полный отчёт (последний прогон)</a>"
else
  report_cta='<p class="empty-state">Полный отчёт пока не опубликован</p>'
fi

if [ -z "${run_links}" ]; then
  run_links="<li>Нет сохранённых прогонов</li>"
fi

cat > "${BRANCH_DIR}/index.html" <<EOF
<!DOCTYPE html>
<html lang="ru">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>UI Tests — ${branch_name}</title>
  <style>
    :root {
      --bg: #f5f0e8;
      --surface: #2c2a26;
      --text: #222;
      --muted: #6b6b6b;
      --primary: #20aee3;
      --button: #1677f2;
      --border: #e3e9f5;
    }
    * { box-sizing: border-box; }
    body {
      margin: 0;
      font-family: "Segoe UI", Tahoma, Geneva, Verdana, sans-serif;
      background: var(--bg);
      color: var(--text);
    }
    header {
      background: var(--surface);
      color: #f5f0e8;
      padding: 20px 24px;
    }
    header h1 { margin: 0 0 6px; font-size: 1.5rem; }
    header p { margin: 0; color: rgba(245, 240, 232, 0.75); }
    main { max-width: 1400px; margin: 0 auto; padding: 24px; }
    .panel {
      background: #fff;
      border: 1px solid var(--border);
      border-radius: 16px;
      padding: 20px;
      margin-bottom: 24px;
      box-shadow: 0 10px 24px rgba(15, 23, 42, 0.06);
    }
    .panel h2 {
      margin: 0 0 12px;
      font-size: 1.1rem;
      border-left: 4px solid var(--primary);
      padding-left: 12px;
    }
    .actions {
      display: flex;
      flex-wrap: wrap;
      gap: 12px;
      align-items: center;
      margin-bottom: 8px;
    }
    .btn {
      display: inline-block;
      padding: 12px 18px;
      border-radius: 10px;
      text-decoration: none;
      font-weight: 600;
    }
    .btn.primary {
      background: var(--button);
      color: #fff;
    }
    .btn.primary:hover { background: #0e63d7; }
    .btn.secondary {
      background: #f8fbff;
      color: var(--button);
      border: 1px solid var(--border);
    }
    .hint {
      margin: 0 0 16px;
      color: var(--muted);
      font-size: 0.95rem;
    }
    .runs {
      margin: 0;
      padding-left: 20px;
      columns: 2;
      gap: 16px;
    }
    .runs a { color: var(--button); text-decoration: none; }
    .runs a:hover { text-decoration: underline; }
    .dashboard-frame {
      width: 100%;
      min-height: 720px;
      border: 1px solid var(--border);
      border-radius: 12px;
      background: #fff;
    }
    .empty-state {
      margin: 0;
      padding: 24px 16px;
      text-align: center;
      color: var(--muted);
      background: #f8fbff;
      border-radius: 12px;
    }
    .back { color: #f5f0e8; text-decoration: none; font-size: 0.9rem; }
    .back:hover { text-decoration: underline; }
    @media (max-width: 768px) {
      .runs { columns: 1; }
      .dashboard-frame { min-height: 560px; }
    }
  </style>
</head>
<body>
  <header>
    <a class="back" href="../">← Все ветки</a>
    <h1>${branch_name}</h1>
    <p>Dashboard — только тренды. Для дерева тестов откройте полный отчёт.</p>
  </header>
  <main>
    <section class="panel">
      <h2>Полный отчёт</h2>
      <p class="hint">Из dashboard нельзя провалиться в тесты — используйте полный Allure Report.</p>
      <div class="actions">
        ${report_cta}
        <a class="btn secondary" href="../">Overview всех веток</a>
      </div>
    </section>
    <section class="panel">
      <h2>Прогоны</h2>
      <ul class="runs">
        ${run_links}
      </ul>
    </section>
    <section class="panel">
      <h2>Trends</h2>
      ${dashboard_frame:-<p class="empty-state">Dashboard не сгенерирован</p>}
    </section>
  </main>
</body>
</html>
EOF

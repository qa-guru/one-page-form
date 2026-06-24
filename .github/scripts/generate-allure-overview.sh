#!/usr/bin/env bash
set -euo pipefail

PAGES_ALLURE="${1:?pages/allure-reports path required}"

GLOBAL_LANDING="${PAGES_ALLURE}"

rm -rf "${GLOBAL_LANDING}/_other-branches"

declare -a branches=()
while IFS= read -r dir; do
  branches+=("$(basename "${dir}")")
done < <(
  find "${GLOBAL_LANDING}" -mindepth 1 -maxdepth 1 -type d \
    ! -name '_other-branches' \
    -exec test -f '{}/history.jsonl' ';' \
    -exec test -f '{}/index.html' ';' \
    -print 2>/dev/null | sort
)

sorted_branches=()
if printf '%s\n' "${branches[@]:-}" | grep -qx 'main'; then
  sorted_branches+=('main')
fi
for branch in "${branches[@]:-}"; do
  [ "${branch}" = 'main' ] && continue
  sorted_branches+=("${branch}")
done

branch_panels=""
branch_links=""
for branch in "${sorted_branches[@]:-}"; do
  branch_panels="${branch_panels}
    <section class=\"panel\">
      <h2><a href=\"${branch}/\">${branch}</a></h2>
      <iframe class=\"dashboard-frame\" src=\"${branch}/index.html\" title=\"Dashboard: ${branch}\"></iframe>
    </section>"
  branch_links="${branch_links}<li><a href=\"${branch}/\">${branch}</a></li>"
done

if [ -z "${branch_panels}" ]; then
  branch_panels='<section class="panel"><p class="empty-state">Пока нет опубликованных отчётов по веткам</p></section>'
  branch_links='<li>Нет опубликованных веток</li>'
fi

find "${GLOBAL_LANDING}" -maxdepth 1 -type f ! -name 'index.html' -delete

cat > "${GLOBAL_LANDING}/index.html" <<EOF
<!DOCTYPE html>
<html lang="ru">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>UI Tests Dashboard</title>
  <style>
    :root {
      --bg: #f5f0e8;
      --surface: #2c2a26;
      --text: #222;
      --muted: #6b6b6b;
      --primary: #20aee3;
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
    header h1 { margin: 0 0 6px; font-size: 1.6rem; }
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
      margin: 0 0 16px;
      font-size: 1.2rem;
      border-left: 4px solid var(--primary);
      padding-left: 12px;
    }
    .panel h2 a {
      color: inherit;
      text-decoration: none;
    }
    .panel h2 a:hover { color: #1677f2; }
    .dashboard-frame {
      width: 100%;
      min-height: 720px;
      border: 1px solid var(--border);
      border-radius: 12px;
      background: #fff;
    }
    .empty-state {
      margin: 0;
      padding: 48px 16px;
      text-align: center;
      color: var(--muted);
      background: #f8fbff;
      border-radius: 12px;
    }
    .branches ul {
      margin: 0;
      padding-left: 20px;
      columns: 2;
      gap: 24px;
    }
    .branches a { color: #1677f2; text-decoration: none; }
    .branches a:hover { text-decoration: underline; }
    @media (max-width: 768px) {
      .branches ul { columns: 1; }
      .dashboard-frame { min-height: 560px; }
    }
  </style>
</head>
<body>
  <header>
    <h1>UI Tests Dashboard</h1>
    <p>Отдельный dashboard для каждой ветки</p>
  </header>
  <main>
    <section class="panel branches">
      <h2>Ветки</h2>
      <ul>
        ${branch_links}
      </ul>
    </section>
    ${branch_panels}
  </main>
</body>
</html>
EOF

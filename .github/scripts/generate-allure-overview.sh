#!/usr/bin/env bash
set -euo pipefail

PAGES_ALLURE="${1:?pages/allure-reports path required}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

GLOBAL_LANDING="${PAGES_ALLURE}"

rm -rf "${GLOBAL_LANDING}/_other-branches"

declare -a branches=()
while IFS= read -r dir; do
  branches+=("$(basename "${dir}")")
done < <(
  find "${GLOBAL_LANDING}" -mindepth 1 -maxdepth 1 -type d \
    ! -name '_other-branches' \
    -exec test -f '{}/history.jsonl' ';' \
    \( -exec test -f '{}/dashboard/index.html' ';' -o -exec test -d '{}/dashboard' ';' -o -exec test -f '{}/latest-run-id.txt' ';' \) \
    -print 2>/dev/null | sort
)

for branch_dir in "${GLOBAL_LANDING}"/*/; do
  [ -d "${branch_dir}" ] || continue
  slug="$(basename "${branch_dir}")"
  case "${slug}" in _other-branches) continue ;; esac
  if [ -f "${branch_dir}/history.jsonl" ]; then
    bash "${SCRIPT_DIR}/generate-branch-landing.sh" "${branch_dir}"
  fi
done

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
  latest_run=""
  if [ -f "${GLOBAL_LANDING}/${branch}/latest-run-id.txt" ]; then
    latest_run="$(tr -d '[:space:]' < "${GLOBAL_LANDING}/${branch}/latest-run-id.txt")"
  fi
  if [ -z "${latest_run}" ]; then
    latest_run="$(find "${GLOBAL_LANDING}/${branch}" -mindepth 1 -maxdepth 1 -type d -regextype posix-extended -regex '.*/[0-9]+' 2>/dev/null | sort -V | tail -1 | xargs -r basename)"
  fi

  report_link=""
  if [ -n "${latest_run}" ]; then
    report_link="<a class=\"report-link\" href=\"${branch}/${latest_run}/index.html\">полный отчёт →</a>"
  fi

  dashboard_src="${branch}/"
  if [ -f "${GLOBAL_LANDING}/${branch}/dashboard/index.html" ]; then
    dashboard_src="${branch}/dashboard/index.html"
  fi

  branch_panels="${branch_panels}
    <section class=\"panel\">
      <div class=\"panel-head\">
        <h2><a href=\"${branch}/\">${branch}</a></h2>
        ${report_link}
      </div>
      <iframe class=\"dashboard-frame\" src=\"${dashboard_src}\" title=\"Dashboard: ${branch}\"></iframe>
    </section>"
  branch_links="${branch_links}<li><a href=\"${branch}/\">${branch}</a></li>"
  if [ -n "${latest_run}" ]; then
    branch_links="${branch_links} <li><a href=\"${branch}/${latest_run}/index.html\">${branch} — последний run</a></li>"
  fi
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
      --button: #1677f2;
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
    .panel-head {
      display: flex;
      justify-content: space-between;
      align-items: center;
      gap: 12px;
      margin-bottom: 16px;
      flex-wrap: wrap;
    }
    .panel h2 {
      margin: 0;
      font-size: 1.2rem;
      border-left: 4px solid var(--primary);
      padding-left: 12px;
    }
    .panel h2 a {
      color: inherit;
      text-decoration: none;
    }
    .panel h2 a:hover { color: var(--button); }
    .report-link {
      color: var(--button);
      text-decoration: none;
      font-weight: 600;
      white-space: nowrap;
    }
    .report-link:hover { text-decoration: underline; }
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
    .branches a { color: var(--button); text-decoration: none; }
    .branches a:hover { text-decoration: underline; }
    .note {
      margin: 0 0 16px;
      padding: 12px 14px;
      background: #f8fbff;
      border: 1px solid var(--border);
      border-radius: 10px;
      color: var(--muted);
      font-size: 0.95rem;
    }
    @media (max-width: 768px) {
      .branches ul { columns: 1; }
      .dashboard-frame { min-height: 560px; }
    }
  </style>
</head>
<body>
  <header>
    <h1>UI Tests Dashboard</h1>
    <p>Тренды по веткам. Для дерева тестов откройте полный отчёт.</p>
  </header>
  <main>
    <p class="note">Dashboard показывает только аналитику. Чтобы кликнуть по тестам, откройте ссылку «полный отчёт» у нужной ветки.</p>
    <section class="panel branches">
      <h2>Навигация</h2>
      <ul>
        ${branch_links}
      </ul>
    </section>
    ${branch_panels}
  </main>
</body>
</html>
EOF

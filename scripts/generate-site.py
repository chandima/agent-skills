#!/usr/bin/env python3
"""Generate a static skills directory site from skills/*/SKILL.md."""
from __future__ import annotations

import html
import json
import os
from pathlib import Path
import re
import subprocess
from typing import Dict, List

ROOT = Path(__file__).resolve().parents[1]
SKILLS_DIR = ROOT / "skills"
OUT_DIR = ROOT / "docs"


def parse_frontmatter(text: str) -> Dict[str, str]:
    if not text.startswith("---"):
        return {}
    parts = text.split("---", 2)
    if len(parts) < 3:
        return {}
    fm = parts[1]
    data: Dict[str, str] = {}
    for line in fm.splitlines():
        line = line.strip()
        if not line or line.startswith("#"):
            continue
        if ":" not in line:
            continue
        key, value = line.split(":", 1)
        key = key.strip()
        value = value.strip()
        if (value.startswith("\"") and value.endswith("\"")) or (
            value.startswith("'") and value.endswith("'")
        ):
            value = value[1:-1]
        data[key] = value
    return data


def repo_from_env() -> str:
    repo = os.environ.get("GITHUB_REPOSITORY")
    if repo:
        return repo

    try:
        url = subprocess.check_output(
            ["git", "config", "--get", "remote.origin.url"],
            cwd=ROOT,
            text=True,
        ).strip()
    except Exception:
        return "chandima/agent-skills"

    if url.endswith(".git"):
        url = url[: -len(".git")]

    if "github.com/" in url:
        repo = url.split("github.com/")[-1]
    elif "github.com:" in url:
        repo = url.split("github.com:")[-1]
    else:
        repo = "chandima/agent-skills"

    return repo.strip("/") or "chandima/agent-skills"


def load_skills() -> List[Dict[str, str]]:
    skills: List[Dict[str, str]] = []
    if not SKILLS_DIR.exists():
        return skills

    for skill_dir in sorted(SKILLS_DIR.iterdir()):
        if not skill_dir.is_dir():
            continue
        skill_md = skill_dir / "SKILL.md"
        if not skill_md.exists():
            continue

        text = skill_md.read_text(encoding="utf-8")
        fm = parse_frontmatter(text)
        name = fm.get("name", skill_dir.name)
        description = fm.get("description", "").strip()

        skills.append(
            {
                "dir": skill_dir.name,
                "name": name,
                "description": description,
            }
        )

    return skills


def build_html(repo: str, skills: List[Dict[str, str]]) -> str:
    repo_url = f"https://github.com/{repo}"
    skill_count = len(skills)

    skill_names = [skill["name"] for skill in skills] or ["<skill-name>"]
    example_skill = skill_names[0]

    install_commands = [
        f"npx skills add {repo} --all",
        f"npx skills add {repo} --skill {example_skill}",
        f"npx skills add {repo} --skill '*' -a claude-code -a opencode -a codex",
        f"npx skills add {repo} --agent '*' --skill {example_skill}",
        f"npx skills add {repo} --skill {example_skill} -a codex",
        f"npx skills add {repo} --list",
    ]

    commands_block = "\n".join(install_commands)

    skill_names = [skill["name"] for skill in skills]
    skills_list_html = " ".join(
        f"<span class=\"rounded-full bg-slate-100 px-2.5 py-1 text-xs font-semibold text-slate-600\">{html.escape(name)}</span>"
        for name in skill_names
    )

    plural_s = "s" if skill_count != 1 else ""
    none_span = '<span class="text-slate-500">None</span>'
    skills_badge_html = skills_list_html or none_span

    cards = []
    for skill in skills:
        name = html.escape(skill["name"])
        description = html.escape(skill["description"]) if skill["description"] else ""
        path = f"skills/{skill['dir']}"
        url = f"{repo_url}/tree/main/{path}"
        card_description = description or "No description provided yet."
        install_cmd = f"npx skills add {repo} --skill {skill['name']}"
        cards.append(
            f"""
            <div class=\"flex h-full flex-col gap-3 rounded-lg border border-slate-200 bg-white p-5 shadow-sm\">
              <div>
                <a class=\"inline-flex items-center gap-1.5 text-base font-semibold text-slate-900\" href=\"{html.escape(url)}\" target=\"_blank\" rel=\"noreferrer\">
                  <svg aria-hidden=\"true\" viewBox=\"0 0 24 24\" class=\"h-3.5 w-3.5\" fill=\"currentColor\">
                    <path d=\"M12 2C6.48 2 2 6.59 2 12.25c0 4.53 2.87 8.37 6.84 9.73.5.1.66-.22.66-.49v-1.72c-2.78.62-3.37-1.21-3.37-1.21-.46-1.2-1.12-1.52-1.12-1.52-.92-.64.07-.63.07-.63 1.01.07 1.55 1.08 1.55 1.08.9 1.58 2.35 1.13 2.92.86.09-.67.35-1.13.64-1.39-2.22-.26-4.56-1.14-4.56-5.09 0-1.13.39-2.05 1.03-2.77-.1-.26-.45-1.31.1-2.73 0 0 .84-.28 2.75 1.06A9.3 9.3 0 0 1 12 6.8c.85 0 1.71.12 2.51.35 1.9-1.34 2.74-1.06 2.74-1.06.55 1.42.2 2.47.1 2.73.64.72 1.03 1.64 1.03 2.77 0 3.96-2.35 4.83-4.58 5.08.36.32.68.96.68 1.94v2.87c0 .27.16.6.67.49A10.27 10.27 0 0 0 22 12.25C22 6.59 17.52 2 12 2Z\" />
                  </svg>
                  {name}
                </a>
                <div class=\"mt-2 inline-flex rounded-md bg-slate-100 px-2 py-1 text-[10px] font-semibold uppercase tracking-[0.2em] text-slate-500\">Skill</div>
              </div>
              <div class=\"card-description text-sm text-slate-600\">{card_description}</div>
              <div class=\"mt-auto flex flex-col gap-3\">
                <div class=\"relative\">
                  <button type=\"button\" class=\"absolute -right-2 -top-2 inline-flex items-center justify-center rounded-md border border-slate-300 bg-slate-50 p-1 text-slate-500 shadow-sm transition-colors duration-200 copy-btn\" data-copy=\"{html.escape(install_cmd)}\">
                    <span class=\"sr-only copy-label\">Copy install command</span>
                    <svg aria-hidden=\"true\" viewBox=\"0 0 24 24\" class=\"h-3.5 w-3.5\" fill=\"none\" stroke=\"currentColor\" stroke-width=\"1.5\" stroke-linecap=\"round\" stroke-linejoin=\"round\">
                      <rect x=\"9\" y=\"9\" width=\"13\" height=\"13\" rx=\"2\" />
                      <path d=\"M5 15V5a2 2 0 0 1 2-2h10\" />
                    </svg>
                  </button>
                  <div class=\"flex h-[5rem] items-start rounded-md bg-slate-900 px-3 py-2 pr-8 text-xs leading-5 text-slate-100\"><code>{html.escape(install_cmd)}</code></div>
                </div>
                <a class=\"inline-flex items-center gap-1.5 text-xs font-semibold text-slate-500\" href=\"{html.escape(url)}\" target=\"_blank\" rel=\"noreferrer\">
                  <svg aria-hidden=\"true\" viewBox=\"0 0 24 24\" class=\"h-3 w-3\" fill=\"currentColor\">
                    <path d=\"M12 2C6.48 2 2 6.59 2 12.25c0 4.53 2.87 8.37 6.84 9.73.5.1.66-.22.66-.49v-1.72c-2.78.62-3.37-1.21-3.37-1.21-.46-1.2-1.12-1.52-1.12-1.52-.92-.64.07-.63.07-.63 1.01.07 1.55 1.08 1.55 1.08.9 1.58 2.35 1.13 2.92.86.09-.67.35-1.13.64-1.39-2.22-.26-4.56-1.14-4.56-5.09 0-1.13.39-2.05 1.03-2.77-.1-.26-.45-1.31.1-2.73 0 0 .84-.28 2.75 1.06A9.3 9.3 0 0 1 12 6.8c.85 0 1.71.12 2.51.35 1.9-1.34 2.74-1.06 2.74-1.06.55 1.42.2 2.47.1 2.73.64.72 1.03 1.64 1.03 2.77 0 3.96-2.35 4.83-4.58 5.08.36.32.68.96.68 1.94v2.87c0 .27.16.6.67.49A10.27 10.27 0 0 0 22 12.25C22 6.59 17.52 2 12 2Z\" />
                  </svg>
                  {html.escape(path)}
                </a>
              </div>
            </div>
            """.strip()
        )

    cards_html = (
        "\n".join(cards)
        if cards
        else "<p class=\"text-sm text-slate-500\">No skills found.</p>"
    )

    script_block = """<script>
  (() => {
    const copyText = async (text) => {
      if (navigator.clipboard && navigator.clipboard.writeText) {
        await navigator.clipboard.writeText(text);
        return;
      }
      const fallback = document.createElement('textarea');
      fallback.value = text;
      fallback.setAttribute('readonly', 'readonly');
      fallback.style.position = 'absolute';
      fallback.style.left = '-9999px';
      document.body.appendChild(fallback);
      fallback.select();
      document.execCommand('copy');
      document.body.removeChild(fallback);
    };

    const markCopied = (button) => {
      const original = button.dataset.originalLabel || '';
      const icon = button.querySelector('svg');
      const labelEl = button.querySelector('.copy-label');
      if (!button.dataset.originalLabel) {
        button.dataset.originalLabel = labelEl ? labelEl.textContent || '' : '';
      }
      button.classList.add('copy-success');
      if (labelEl) labelEl.textContent = 'Copied';
      if (icon) icon.classList.add('copy-icon-success');
      setTimeout(() => {
        button.classList.remove('copy-success');
        if (labelEl) labelEl.textContent = original;
        if (icon) icon.classList.remove('copy-icon-success');
      }, 1200);
    };

    document.querySelectorAll('[data-copy]').forEach((button) => {
      button.addEventListener('click', async () => {
        const text = button.getAttribute('data-copy') || '';
        try {
          await copyText(text);
          markCopied(button);
        } catch {
          // Ignore copy failures.
        }
      });
    });
  })();
</script>"""

    return f"""<!doctype html>
<html lang=\"en\">
  <head>
    <meta charset=\"utf-8\" />
    <meta name=\"viewport\" content=\"width=device-width, initial-scale=1\" />
    <title>{html.escape(repo)}</title>
        <script src=\"https://cdn.tailwindcss.com\"></script>
    <style>
      .copy-btn.copy-success {{
        border-color: #16a34a;
        color: #16a34a;
      }}
      .copy-btn.copy-success .copy-icon-success {{
        stroke: #16a34a;
      }}
      .card-description {{
        display: -webkit-box;
        -webkit-box-orient: vertical;
        -webkit-line-clamp: 4;
        overflow: hidden;
      }}
    </style>

  </head>
  <body class=\"bg-slate-50 text-slate-900\">
    <main class=\"max-w-5xl mx-auto px-6 py-12\">
      <header class=\"rounded-xl border border-slate-200 bg-white p-8 shadow-sm\">
        <div class=\"flex flex-col gap-6 sm:flex-row sm:items-start sm:justify-between\">
          <div>
            <div class=\"inline-flex items-center rounded-full bg-slate-100 px-3 py-1 text-xs font-semibold uppercase tracking-[0.2em] text-slate-600\">Agent Skills</div>
            <h1 class=\"mt-4 text-3xl font-semibold tracking-tight text-slate-900 sm:text-4xl\">{html.escape(repo)}</h1>
            <p class=\"mt-2 text-sm text-slate-600\">Auto-generated directory from <code class=\"rounded bg-slate-100 px-1.5 py-0.5\">skills/*/SKILL.md</code>.</p>
            <div class=\"mt-4 text-sm text-slate-600\">{skill_count} skill{plural_s} • <a class=\"text-slate-900 underline\" href=\"{html.escape(repo_url)}\" target=\"_blank\" rel=\"noreferrer\">View repo</a></div>
          </div>
        </div>
      </header>

      <section class=\"mt-8 rounded-xl border border-slate-200 bg-white p-6 shadow-sm\">
        <div class=\"flex flex-wrap items-start justify-between gap-4\">
          <div>
            <h2 class=\"text-lg font-semibold text-slate-900\">Install</h2>
            <p class=\"mt-1 text-sm text-slate-600\">Common install patterns for this repo:</p>
          </div>
        </div>
        <pre class=\"mt-4 overflow-x-auto rounded-lg bg-slate-900 p-4 text-sm text-slate-100\"><code>{html.escape(commands_block)}</code></pre>
        <div class=\"mt-4 flex flex-wrap items-center gap-2 text-xs text-slate-600\">
          <span class=\"font-semibold text-slate-700\">Available skills:</span>
          {skills_badge_html}
        </div>
      </section>

      <section class=\"mt-8\">
        <div class=\"flex items-center\">
          <h2 class=\"text-lg font-semibold text-slate-900\">Available Skills</h2>
          <span class=\"ml-2 rounded-full bg-slate-100 px-3 py-1 text-xs font-semibold text-slate-600\">{skill_count}</span>
        </div>
        <div class=\"mt-4 grid gap-4 sm:grid-cols-2 lg:grid-cols-3\">
          {cards_html}
        </div>
      </section>

      <footer class=\"mt-10 text-xs text-slate-500\">
        Generated by <code class=\"rounded bg-slate-100 px-1\">scripts/generate-site.py</code>
      </footer>
    </main>
    {script_block}

  </body>
</html>
"""


def main() -> None:
    repo = repo_from_env()
    skills = load_skills()

    OUT_DIR.mkdir(parents=True, exist_ok=True)

    html_output = build_html(repo, skills)
    (OUT_DIR / "index.html").write_text(html_output, encoding="utf-8")

    payload = {
        "repo": repo,
        "skills": skills,
    }
    (OUT_DIR / "skills.json").write_text(
        json.dumps(payload, indent=2),
        encoding="utf-8",
    )

    (OUT_DIR / ".nojekyll").write_text("", encoding="utf-8")

    styles_path = OUT_DIR / "styles.css"
    if styles_path.exists():
        styles_path.unlink()


if __name__ == "__main__":
    main()

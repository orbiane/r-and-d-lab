# CLAUDE.md — AI Assistant Guide for r-and-d-lab

This file provides guidance for AI assistants (Claude and others) working in this repository.

---

## Repository Overview

**Name:** r-and-d-lab
**Purpose:** Research and Development Lab — a workspace for experimentation, prototyping, and exploratory engineering.
**State:** Active. TIL (学習メモ) システムと週次レポート自動生成スクリプトが稼働中。

---

## Current Repository Structure

```
r-and-d-lab/
├── CLAUDE.md              # This file
├── README.md              # Project overview
├── til/                   # 日々の学習メモ (Today I Learned)
│   ├── TEMPLATE.md        # 新規メモのテンプレート
│   └── YYYY-MM-DD.md      # 日付ごとのメモ
├── reports/               # 週次レポート生成先（自動生成）
├── scripts/
│   └── weekly-report.sh   # 週次レポート生成スクリプト
└── claude-code-demos/     # Claude Code 機能デモ集
```

## TIL ルール

- ファイル名は `YYYY-MM-DD.md` 形式
- `til/TEMPLATE.md` をコピーして使う
- タグは小文字・ハイフン区切り（例: `claude-code`, `web-api`）
- 毎日 1 ファイル（複数トピックは同ファイルにまとめる）

## 週次レポート生成

```bash
# 先週分のレポートを自動生成
bash scripts/weekly-report.sh

# 期間を指定する場合
bash scripts/weekly-report.sh 2026-02-23 2026-03-01
```

生成されたレポートは `reports/week-of-YYYY-MM-DD.md` に保存される。

---

## Git Workflow

### Branches

| Branch | Purpose |
|--------|---------|
| `main` | Stable, reviewed code |
| `master` | Legacy default branch (mirrors `main`) |
| `claude/<description>-<sessionId>` | AI-assisted development branches |

### Branch Naming Conventions

- Human feature branches: `feature/<short-description>` or `<username>/<short-description>`
- AI-assisted branches: `claude/<kebab-case-description>-<sessionId>` (e.g., `claude/add-claude-documentation-dasH3`)
  - The session ID suffix is required — pushes will fail with HTTP 403 without it.

### Commit Messages

Write clear, imperative-mood commit messages:
- Good: `Add initial project scaffolding`
- Good: `Fix off-by-one error in pagination logic`
- Avoid: `stuff`, `WIP`, `changes`

### Push Protocol

Always push with the upstream flag:
```bash
git push -u origin <branch-name>
```

On network failure, retry with exponential backoff: 2s → 4s → 8s → 16s (max 4 retries).

---

## Development Conventions (Defaults Until Overridden)

These conventions apply when new code is introduced into the repository. Update this section as tech stack decisions are made.

### General

- Prefer small, focused commits over large batches of changes.
- Do not commit secrets, credentials, or `.env` files.
- Include a `.gitignore` appropriate for the language/framework before adding source files.

### Code Style

- Follow the conventions of the dominant language in the repo once one is established.
- Prefer explicit over implicit; avoid magic numbers and unexplained behavior.
- Keep functions small and single-purpose.

### Testing

- Write tests alongside new features, not as an afterthought.
- Run the full test suite before committing.
- Failing tests must not be merged to `main`.

### Documentation

- Update `README.md` when adding new top-level functionality.
- Update `CLAUDE.md` whenever the repo structure, tech stack, or workflow changes significantly.

---

## For AI Assistants

### What to Do

- **Read this file first** before making changes.
- **Explore before modifying** — understand existing code before suggesting rewrites.
- **Keep changes minimal** — only change what is needed for the task at hand.
- **Update CLAUDE.md** after significant structural or workflow changes.
- **Commit and push** completed work to the designated `claude/` branch.

### What to Avoid

- Do not push to `main` or `master` directly.
- Do not introduce dependencies without confirming the intended tech stack.
- Do not delete or overwrite existing work without understanding its purpose.
- Do not add unnecessary abstractions, configs, or boilerplate for future-proofing.
- Do not skip git hooks or bypass signing (`--no-verify`, `--no-gpg-sign`).

### When the Repo Gains a Tech Stack

Once a language, framework, or build system is committed, update the following sections of this file:

1. **Repository Structure** — add the new directory tree
2. **Tech Stack** — list languages, frameworks, and key libraries
3. **Build & Run Commands** — document how to install deps, build, and start the app
4. **Test Commands** — document how to run tests and linters
5. **Environment Setup** — document required env variables (never their values)

---

## Updating This File

This file should be treated as living documentation. Update it when:

- A new language, framework, or major library is introduced
- The directory structure changes significantly
- New development workflows or CI/CD pipelines are added
- Code style or testing conventions are established or changed

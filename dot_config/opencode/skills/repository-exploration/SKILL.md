---
name: repository-exploration
description: Repository exploration for reference implementations. Use when the user asks to check how another project, repo, library, or upstream implementation solved something before applying it locally.
license: MIT
compatibility: opencode
metadata:
  audience: agents
  workflow: research
---

## What I do

- Locate external repositories used as implementation references.
- Keep local reference checkouts under `~/.local/repo-exploration`.
- Encourage focused exploration through subagents while preserving agent judgment.

## When to use me

Use this when the task asks to inspect another project as a reference, such as:

- "See how Rails does this."
- "Check how another project implemented this."
- "Look at upstream for a similar feature."
- "Use React Router as a reference."
- "Find an example implementation in an open source repo."

Do not use this for normal local codebase exploration unless an external or separate reference repository is involved.

## Repository location

All reference repositories should live under:

```bash
~/.local/repo-exploration
```

Create that directory if it does not exist.

## Workflow

### Step 1: Identify the target repository

Infer the project from the user's request and current task context. If the target is ambiguous, first search online for the most likely official upstream repository. Prefer canonical sources over mirrors:

- The project's official website or documentation.
- GitHub, GitLab, Codeberg, Forgejo, or the project's self-hosted forge.
- Package metadata that links to a source repository.

Ask a clarifying question only when multiple plausible repositories would materially change the answer.

### Step 2: Check for an existing checkout

Look in `~/.local/repo-exploration` before cloning anything. If the repository is already present there, update it before exploring:

```bash
git -C ~/.local/repo-exploration/<repo-directory> pull --ff-only
```

If the checkout has local changes or cannot fast-forward, do not discard anything. Report the problem and either continue with the existing checkout when sufficient or ask the user how to proceed.

### Step 3: Clone missing repositories

If the repository is not already present, clone the official repository into `~/.local/repo-exploration`:

```bash
git clone <repository-url> ~/.local/repo-exploration/<repo-directory>
```

Use a clear directory name based on the repository name, adding the owner or host only when needed to avoid collisions.

### Step 4: Explore with subagents by default

Strongly prefer using one or more focused subagents for reference exploration, especially when the external repository is large or the question is open-ended. A good pattern is to ask an `explore` subagent to find the relevant files, summarize the implementation, and return file paths plus the important details.

The main agent can still do the exploration directly when that is simpler, faster, or necessary for tight integration with the local change. The important rule is to keep reference-repo research focused and avoid mixing it with unrelated local edits.

### Step 5: Apply findings carefully

Treat the reference repository as read-only unless the user explicitly asks to change it. Use it to understand patterns, APIs, edge cases, and tests, then adapt the idea to the current project's conventions instead of copying blindly.

## Output requirements

- Name the reference repository and local checkout path used.
- Mention whether the repo was updated with `git pull` or newly cloned.
- Cite the key files inspected when summarizing findings.
- Separate reference findings from any local implementation changes.

## Failure handling

- If the repo cannot be found online, state what searches were attempted.
- If cloning fails, include the repository URL and the git error.
- If the local checkout is dirty or cannot fast-forward, do not reset it or delete it.
- If a subagent search is inconclusive, either narrow the prompt and try again or continue directly with a targeted search.

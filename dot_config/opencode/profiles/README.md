# OpenCode Profiles

Profiles are additive OpenCode configuration directories launched with `ocp`:

```sh
ocp superpowers
ocp superpowers run "Tell me about your superpowers"
```

Bare `opencode` and the `oc` alias do not load a profile.

## Configuration layering

`ocp` sets `OPENCODE_CONFIG_DIR` only for the OpenCode process it launches.
OpenCode merges the selected profile with its normal configuration rather than
replacing it. The relevant precedence is:

1. Global config in `~/.config/opencode/opencode.json`
2. Project config and `.opencode` directories
3. The selected profile directory

Objects are deep-merged, arrays such as `plugin` are concatenated, and the
profile wins when the same setting is defined in multiple layers.

A profile can contain `opencode.jsonc` plus profile-specific `agents/`,
`commands/`, `plugins/`, and `skills/` directories.

Profiles should not contain an `AGENTS.md` by default. OpenCode automatically
loads `$OPENCODE_CONFIG_DIR/AGENTS.md` when it exists, and that file takes the
place of the global `~/.config/opencode/AGENTS.md`. Add one only when the profile
should deliberately replace the global instructions. Project `AGENTS.md` files
are still loaded alongside profile instructions.

## Creating a profile

Create a directory and config file in this dotfiles repository:

```text
dot_config/opencode/profiles/<profile>/opencode.jsonc
```

Start with:

```json
{
  "$schema": "https://opencode.ai/config.json"
}
```

Run `./deploy.sh`, then launch it with `ocp <profile>`. Profile names may contain
letters, numbers, dots, underscores, and hyphens, and must start with a letter
or number.

## Superpowers

The `superpowers` profile follows the upstream OpenCode installation by adding
the git-backed package to its `plugin` array. Because it is declared only in the
profile config, it is unavailable to bare `opencode` and `oc` sessions.

OpenCode installs the plugin when the profile is first launched. To verify it,
run:

```sh
ocp superpowers run "Tell me about your superpowers"
```

Upstream installation documentation:
<https://github.com/obra/superpowers/blob/main/.opencode/INSTALL.md>

## Oh My OpenAgent

The `omo` profile loads Oh My OpenAgent only when launched with `ocp omo`. Its
separate `oh-my-openagent.jsonc` is rendered for the current machine:

- `picard` uses Anthropic for Claude-tuned orchestration and planning agents,
  with OpenAI retained for GPT-native specialists and fallback routes.
- Other machines use OpenAI exclusively, block Anthropic fallback routes, and
  disable the Claude-tuned Metis planning consultant.

Sisyphus remains enabled on OpenAI-only machines because current releases
provide a dedicated GPT-5.5 prompt. Hephaestus, Oracle, and Momus are GPT-native.

Anonymous telemetry is disabled. The upstream auto-update hook remains enabled
and may update the package in OpenCode's shared cache. Authentication and the
package cache are shared with normal OpenCode sessions, but bare `opencode` and
`oc` do not load the plugin. OMO may create project-local `.omo/` workflow state
while this profile is active.

```sh
ocp omo
```

Upstream installation documentation:
<https://github.com/code-yeongyu/oh-my-openagent/blob/master/docs/guide/installation.md>

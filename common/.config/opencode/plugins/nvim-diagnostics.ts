/**
 * nvim-diagnostics for OpenCode
 *
 * Exposes a single tool, `nvim_diagnostics_set`, that ships diagnostic
 * annotations to the user's running Neovim instance over its tmux-scoped
 * unix socket. Useful for code-exploration workflows like
 *
 *   "trace the path of a request through the codebase when state.foo is
 *    true, and send the findings to neovim for me to inspect"
 *
 * Each call REPLACES the previous set of opencode diagnostics, so the
 * model should batch all related findings into a single invocation.
 *
 * Pre-requisites:
 *   - The user is inside a tmux session.
 *   - Neovim is running in that session and has started a server socket
 *     at /tmp/<tmux session>/neovim.sock (see ~/.config/nvim/lua/custom/
 *     tmux_socket.lua).
 *   - The neovim helper module ~/.config/nvim/lua/custom/opencode_diag.lua
 *     is on the runtimepath (it is, because ~/.config/nvim/lua is).
 *   - `nvim` is on PATH.
 */

import * as fs from "node:fs"
import * as path from "node:path"
import * as os from "node:os"
import type { Plugin } from "@opencode-ai/plugin"
import { tool } from "@opencode-ai/plugin"

const SEVERITIES = ["error", "warn", "info", "hint"] as const

const DESCRIPTION = [
	"Send diagnostic annotations to the user's running Neovim instance for inline inspection.",
	"",
	"Each call REPLACES all previously-sent opencode diagnostics, so batch every diagnostic for",
	"the current task into a single invocation. Files do not need to be open in Neovim ahead of",
	"time — the annotations will appear automatically when the user navigates to the file.",
	"",
	"Use this when the user asks you to surface findings from code exploration (e.g. tracing a",
	"request path, marking up the lines involved in some behavior, explaining what a chunk of",
	"code does in context). The user will read the messages inline in Neovim's diagnostic UI.",
	"",
	"Each diagnostic targets a 1-indexed line in a file. Provide a clear, concise `message`",
	"explaining what that line is doing or why it matters. Prefer severity 'info' or 'hint'",
	"for explanatory annotations; reserve 'warn' / 'error' for issues you want the user to",
	"act on.",
	"",
	"Fails gracefully if the user is not in tmux, the neovim socket is missing, or any of the",
	"referenced files do not exist on disk.",
].join("\n")

export const NvimDiagnosticsPlugin: Plugin = async () => {
	return {
		tool: {
			nvim_diagnostics_set: tool({
				description: DESCRIPTION,
				args: {
					diagnostics: tool.schema
						.array(
							tool.schema.object({
								file: tool.schema
									.string()
									.describe(
										"Path to the file. Absolute, or relative to the project directory.",
									),
								line: tool.schema
									.number()
									.int()
									.min(1)
									.describe("1-indexed line number where the diagnostic begins."),
								end_line: tool.schema
									.number()
									.int()
									.min(1)
									.optional()
									.describe(
										"1-indexed end line for multi-line diagnostics. Defaults to `line`.",
									),
								col: tool.schema
									.number()
									.int()
									.min(1)
									.optional()
									.describe("1-indexed start column. Defaults to 1."),
								end_col: tool.schema
									.number()
									.int()
									.min(1)
									.optional()
									.describe(
										"1-indexed end column. Defaults to the end of `end_line`.",
									),
								message: tool.schema
									.string()
									.min(1)
									.describe(
										"The annotation the user will see in Neovim's diagnostic UI. Be concise and explanatory.",
									),
								severity: tool.schema
									.enum(SEVERITIES)
									.optional()
									.describe(
										"Severity. Defaults to 'info'. Use 'hint' for purely informational annotations, 'warn' / 'error' for actionable issues.",
									),
								source: tool.schema
									.string()
									.optional()
									.describe(
										"Optional source label shown in the diagnostic float. Defaults to 'opencode'.",
									),
							}),
						)
						.min(1)
						.describe(
							"Batch of diagnostics. This call REPLACES the previous opencode diagnostic set in Neovim.",
						),
				},
				async execute(args, ctx) {
					// 1. Detect tmux session.
					if (!process.env.TMUX) {
						return "Not inside a tmux session — cannot reach Neovim socket."
					}

					const tmuxResult = Bun.spawnSync(
						["tmux", "display-message", "-p", "#S"],
						{ stdout: "pipe", stderr: "pipe" },
					)
					if (tmuxResult.exitCode !== 0) {
						const err = new TextDecoder().decode(tmuxResult.stderr).trim()
						return `Failed to read tmux session name: ${err || "unknown error"}`
					}
					const session = new TextDecoder().decode(tmuxResult.stdout).trim()
					if (!session) {
						return "tmux returned an empty session name."
					}

					// 2. Resolve socket path.
					const socket = `/tmp/${session}/neovim.sock`
					if (!fs.existsSync(socket)) {
						return `No Neovim socket at ${socket} — is Neovim running in this tmux session?`
					}

					// 3. Resolve & validate every file path.
					const resolved: Array<Record<string, unknown>> = []
					const missing: string[] = []
					for (const d of args.diagnostics) {
						const abs = path.isAbsolute(d.file)
							? d.file
							: path.resolve(ctx.directory, d.file)
						if (!fs.existsSync(abs)) {
							missing.push(d.file)
							continue
						}
						resolved.push({ ...d, file: abs })
					}
					if (missing.length > 0) {
						return `File(s) not found on disk: ${missing.join(", ")}`
					}

					// 4. Write payload to a unique tmp file. The path is constructed
					//    from numeric/alphanumeric components only, so it never
					//    contains shell- or Vim-string- meta characters.
					const tmpPath = path.join(
						os.tmpdir(),
						`opencode-nvim-diag-${process.pid}-${Date.now()}-${Math.random()
							.toString(36)
							.slice(2, 10)}.json`,
					)
					fs.writeFileSync(tmpPath, JSON.stringify({ diagnostics: resolved }))

					// 5. Shell out to nvim --remote-expr. The tmp path is passed
					//    via luaeval's `_A` so we never have to escape inside the
					//    Lua source. Both the lua source and the path are free of
					//    single quotes by construction, so the outer Vim string
					//    literals are safe.
					try {
						const expr = `luaeval('require("custom.opencode_diag").set_from_file(_A)', '${tmpPath}')`
						const result = Bun.spawnSync(
							["nvim", "--server", socket, "--remote-expr", expr],
							{ stdout: "pipe", stderr: "pipe" },
						)
						const stdout = new TextDecoder().decode(result.stdout).trim()
						const stderr = new TextDecoder().decode(result.stderr).trim()

						if (result.exitCode !== 0) {
							return `nvim --remote-expr failed (exit ${result.exitCode}): ${
								stderr || stdout || "no output"
							}`
						}
						if (stdout && stdout !== "ok") {
							return `Neovim reported: ${stdout}`
						}

						// 6. Surface a useful title in the OpenCode UI.
						const filesAffected = new Set(
							resolved.map((d) => d.file as string),
						).size
						const n = resolved.length
						ctx.metadata({
							title: `Sent ${n} diagnostic${n === 1 ? "" : "s"} to neovim`,
							metadata: {
								files: filesAffected,
								socket,
							},
						})
						return `Replaced opencode diagnostics in Neovim with ${n} entr${
							n === 1 ? "y" : "ies"
						} across ${filesAffected} file${filesAffected === 1 ? "" : "s"}.`
					} finally {
						try {
							fs.unlinkSync(tmpPath)
						} catch {
							// Non-critical — tmp dir gets cleaned up by the OS.
						}
					}
				},
			}),
		},
	}
}

export default NvimDiagnosticsPlugin

import { access, mkdtemp, readFile, rm, writeFile } from "node:fs/promises";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { Type } from "@earendil-works/pi-ai";
import {
	DEFAULT_MAX_BYTES,
	DEFAULT_MAX_LINES,
	formatSize,
	truncateTail,
	type ExtensionAPI,
} from "@earendil-works/pi-coding-agent";

const quote = (value: string) => `'${value.replaceAll("'", `'"'"'`)}'`;

const sleep = (ms: number) => new Promise((resolve) => setTimeout(resolve, ms));

export default function (pi: ExtensionAPI) {
	pi.registerTool({
		name: "tmux_subagent",
		label: "Tmux Subagent",
		description:
			"Delegate one task to an isolated pi process in a tmux pane and return its final response. The subagent works in the same directory and may modify files.",
		promptSnippet: "Delegate an independent task to an isolated pi process in tmux",
		promptGuidelines: [
			"Use tmux_subagent for focused work that can be delegated with a self-contained task description.",
		],
		parameters: Type.Object({
			task: Type.String({ description: "Complete, self-contained task for the subagent" }),
		}),

		async execute(_id, { task }, signal, onUpdate, ctx) {
			const dir = await mkdtemp(join(tmpdir(), "pi-tmux-subagent-"));
			const promptFile = join(dir, "prompt.txt");
			const outputFile = join(dir, "output.txt");
			const statusFile = join(dir, "status");
			const runnerFile = join(dir, "run.sh");
			let pane = "";
			let preserveOutput = false;

			try {
				await writeFile(promptFile, task, { mode: 0o600 });
				await writeFile(
					runnerFile,
					`#!/usr/bin/env bash\nset -o pipefail\npi --no-extensions --no-session -p "$(cat ${quote(promptFile)})" 2>&1 | tee ${quote(outputFile)}\ncode=\${PIPESTATUS[0]}\nprintf '%s\\n' "$code" > ${quote(statusFile)}\nexit "$code"\n`,
					{ mode: 0o700 },
				);

				const tmuxArgs = process.env.TMUX
					? ["new-window", "-d", "-P", "-F", "#{pane_id}", "-n", "pi-agent", "-c", ctx.cwd, runnerFile]
					: [
							"new-session",
							"-d",
							"-P",
							"-F",
							"#{pane_id}",
							"-s",
							`pi-agent-${process.pid}-${Date.now()}`,
							"-c",
							ctx.cwd,
							runnerFile,
						];
				const started = await pi.exec("tmux", tmuxArgs, { signal });
				if (started.code !== 0) throw new Error(started.stderr.trim() || "Could not start tmux");
				pane = started.stdout.trim();
				onUpdate?.({ content: [{ type: "text", text: `Subagent running in tmux pane ${pane}` }] });

				while (true) {
					if (signal?.aborted) throw new Error("Subagent aborted");
					try {
						await access(statusFile);
						break;
					} catch {
						await sleep(250);
					}
				}

				const [rawOutput, rawStatus] = await Promise.all([
					readFile(outputFile, "utf8").catch(() => ""),
					readFile(statusFile, "utf8"),
				]);
				const exitCode = Number.parseInt(rawStatus, 10);
				const truncated = truncateTail(rawOutput, {
					maxBytes: DEFAULT_MAX_BYTES,
					maxLines: DEFAULT_MAX_LINES,
				});
				let output = truncated.content || "(no output)";
				if (truncated.truncated) {
					preserveOutput = true;
					output += `\n\n[Output truncated to ${formatSize(truncated.outputBytes)}; full output: ${outputFile}]`;
				}
				if (exitCode !== 0) throw new Error(`Subagent exited with code ${exitCode}:\n${output}`);

				return {
					content: [{ type: "text", text: output }],
					details: { pane, exitCode, outputFile: preserveOutput ? outputFile : undefined },
				};
			} finally {
				if (signal?.aborted && pane) await pi.exec("tmux", ["kill-pane", "-t", pane]).catch(() => undefined);
				if (!preserveOutput) await rm(dir, { recursive: true, force: true });
			}
		},
	});
}

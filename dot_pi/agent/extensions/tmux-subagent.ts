import { randomUUID } from "node:crypto";
import { access, mkdir, readFile, readdir, rm, writeFile } from "node:fs/promises";
import net from "node:net";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { StringEnum } from "@earendil-works/pi-ai";
import {
	DEFAULT_MAX_BYTES,
	DEFAULT_MAX_LINES,
	formatSize,
	truncateTail,
	type ExtensionAPI,
} from "@earendil-works/pi-coding-agent";
import { Type } from "typebox";

const quote = (value: string) => `'${value.replaceAll("'", `'"'"'`)}'`;
const sleep = (ms: number) => new Promise((resolve) => setTimeout(resolve, ms));
const stateRoot = join(tmpdir(), `pi-tmux-subagents-${typeof process.getuid === "function" ? process.getuid() : "user"}`);

type ChildStatus = {
	state: "starting" | "waiting" | "running" | "stopped" | "error";
	turn: number;
	updatedAt: number;
	message?: string;
	resultPath?: string;
};

type Job = {
	id: string;
	pane: string;
	cwd: string;
	task: string;
	createdAt: number;
};

const Params = Type.Object({
	action: Type.Optional(
		StringEnum(["spawn", "send", "steer", "follow_up", "status", "abort", "stop"] as const, {
			description: "Operation to perform. Defaults to spawn for backward compatibility.",
		}),
	),
	task: Type.Optional(Type.String({ description: "Complete task for a new subagent" })),
	agentId: Type.Optional(Type.String({ description: "Subagent ID or unique ID prefix" })),
	message: Type.Optional(Type.String({ description: "Follow-up or steering message" })),
	wait: Type.Optional(Type.Boolean({ description: "Wait for the resulting turn and return its final response. Default true." })),
});

async function readJson<T>(path: string): Promise<T | undefined> {
	try {
		return JSON.parse(await readFile(path, "utf8")) as T;
	} catch (error) {
		if ((error as NodeJS.ErrnoException).code === "ENOENT" || error instanceof SyntaxError) return undefined;
		throw error;
	}
}

async function resolveJobDir(idOrPrefix: string): Promise<string> {
	const direct = join(stateRoot, idOrPrefix);
	try {
		await access(join(direct, "job.json"));
		return direct;
	} catch {
		// Resolve a unique prefix below.
	}
	const matches = (await readdir(stateRoot).catch(() => [] as string[])).filter((name) => name.startsWith(idOrPrefix));
	if (matches.length === 0) throw new Error(`Unknown subagent: ${idOrPrefix}`);
	if (matches.length > 1) throw new Error(`Ambiguous subagent prefix: ${idOrPrefix}`);
	return join(stateRoot, matches[0]);
}

async function readJob(jobDir: string): Promise<Job> {
	const job = await readJson<Job>(join(jobDir, "job.json"));
	if (!job) throw new Error(`Invalid subagent state: ${jobDir}`);
	return job;
}

async function paneExists(pi: ExtensionAPI, pane: string): Promise<boolean> {
	const result = await pi.exec("tmux", ["display-message", "-p", "-t", pane, "#{pane_id}"]);
	return result.code === 0 && result.stdout.trim() === pane;
}

async function sendCommand(jobDir: string, command: Record<string, unknown>): Promise<any> {
	const socketPath = join(jobDir, "control.sock");
	const id = randomUUID();
	return new Promise((resolve, reject) => {
		const socket = net.createConnection(socketPath);
		let buffer = "";
		const timer = setTimeout(() => {
			socket.destroy();
			reject(new Error("Timed out contacting subagent"));
		}, 5000);
		const finish = (error?: Error, value?: unknown) => {
			clearTimeout(timer);
			socket.destroy();
			error ? reject(error) : resolve(value);
		};
		socket.setEncoding("utf8");
		socket.on("connect", () => socket.write(`${JSON.stringify({ ...command, id })}\n`));
		socket.on("data", (chunk) => {
			buffer += chunk;
			while (true) {
				const newline = buffer.indexOf("\n");
				if (newline < 0) break;
				const line = buffer.slice(0, newline).trim();
				buffer = buffer.slice(newline + 1);
				if (!line) continue;
				let response: any;
				try {
					response = JSON.parse(line);
				} catch {
					continue;
				}
				if (response.type !== "response" || response.id !== id) continue;
				if (!response.success) finish(new Error(response.error || "Subagent command failed"));
				else finish(undefined, response);
				return;
			}
		});
		socket.on("error", (error) => finish(error));
	});
}

async function waitForReady(pi: ExtensionAPI, jobDir: string, job: Job, signal?: AbortSignal): Promise<ChildStatus> {
	while (true) {
		if (signal?.aborted) throw new Error(`Subagent launch aborted; child remains alive: ${job.id}`);
		const status = await readJson<ChildStatus>(join(jobDir, "status.json"));
		if (status?.state === "waiting") return status;
		if (!(await paneExists(pi, job.pane))) throw new Error("Subagent exited before its control bridge became ready");
		await sleep(200);
	}
}

async function waitForTurn(
	pi: ExtensionAPI,
	jobDir: string,
	job: Job,
	afterTurn: number,
	signal?: AbortSignal,
	onUpdate?: (result: any) => void,
): Promise<ChildStatus> {
	while (true) {
		if (signal?.aborted) throw new Error(`Subagent wait aborted; child remains alive: ${job.id}`);
		const status = await readJson<ChildStatus>(join(jobDir, "status.json"));
		if (status && status.turn > afterTurn && status.state === "waiting") return status;
		if (!(await paneExists(pi, job.pane))) throw new Error(`Subagent ${job.id} exited before completing the turn`);
		onUpdate?.({
			content: [{ type: "text", text: `Subagent ${job.id.slice(0, 12)}: ${status?.state ?? "starting"} in ${job.pane}` }],
			details: { job, status },
		});
		await sleep(250);
	}
}

async function resultContent(status: ChildStatus): Promise<{ text: string; resultPath?: string }> {
	const raw = status.resultPath ? await readFile(status.resultPath, "utf8").catch(() => "") : "";
	const truncated = truncateTail(raw, { maxBytes: DEFAULT_MAX_BYTES, maxLines: DEFAULT_MAX_LINES });
	let text = truncated.content || "(no output)";
	if (truncated.truncated) {
		text += `\n\n[Output truncated to ${formatSize(truncated.outputBytes)}; full output: ${status.resultPath}]`;
	}
	return { text, resultPath: truncated.truncated ? status.resultPath : undefined };
}

function formatStatus(job: Job, status: ChildStatus | undefined, alive: boolean): string {
	const state = alive ? status?.state ?? "starting" : "stopped";
	return [
		`${job.id} ${state} in tmux pane ${job.pane}`,
		`turns: ${status?.turn ?? 0}`,
		status?.resultPath ? `latest result: ${status.resultPath}` : undefined,
	].filter(Boolean).join("\n");
}

export default function (pi: ExtensionAPI) {
	pi.registerTool({
		name: "tmux_subagent",
		label: "Tmux Subagent",
		description:
			"Spawn and control persistent Pi subagents in input-disabled tmux windows. Each child shows the normal Pi UI. Spawn/send can wait for a turn and return only its final response; status, steer, follow_up, abort, and stop manage existing children.",
		promptSnippet: "Spawn or control a persistent Pi subagent in tmux",
		promptGuidelines: [
			"Use tmux_subagent for focused delegated work. Keep useful children for follow-up prompts, then stop them explicitly when no longer needed.",
		],
		parameters: Params,

		async execute(_id, params, signal, onUpdate, ctx) {
			const action = params.action ?? "spawn";
			await mkdir(stateRoot, { recursive: true, mode: 0o700 });

			if (action === "spawn") {
				if (!params.task?.trim()) throw new Error("task is required when spawning a subagent");
				const id = randomUUID();
				const jobDir = join(stateRoot, id);
				const promptFile = join(jobDir, "prompt.md");
				const runnerFile = join(jobDir, "run.sh");
				await mkdir(jobDir, { recursive: true, mode: 0o700 });
				await writeFile(promptFile, params.task, { mode: 0o600 });
				await writeFile(
					runnerFile,
					`#!/usr/bin/env bash\nset -euo pipefail\nexport PI_TMUX_SUBAGENT_DIR=${quote(jobDir)}\nexec pi --no-session --approve --exclude-tools tmux_subagent ${quote(`@${promptFile}`)}\n`,
					{ mode: 0o700 },
				);

				const tmuxArgs = process.env.TMUX
					? ["new-window", "-d", "-P", "-F", "#{pane_id}", "-n", `pi-agent-${id.slice(0, 8)}`, "-c", ctx.cwd, runnerFile]
					: ["new-session", "-d", "-P", "-F", "#{pane_id}", "-s", `pi-agent-${id.slice(0, 12)}`, "-c", ctx.cwd, runnerFile];
				const started = await pi.exec("tmux", tmuxArgs, { signal });
				if (started.code !== 0) {
					await rm(jobDir, { recursive: true, force: true });
					throw new Error(started.stderr.trim() || "Could not start tmux");
				}
				const job: Job = { id, pane: started.stdout.trim(), cwd: ctx.cwd, task: params.task, createdAt: Date.now() };
				await writeFile(join(jobDir, "job.json"), `${JSON.stringify(job)}\n`, { mode: 0o600 });
				const ready = await waitForReady(pi, jobDir, job, signal);
				await pi.exec("tmux", ["select-pane", "-d", "-t", job.pane]);
				onUpdate?.({ content: [{ type: "text", text: `Subagent ${id.slice(0, 12)} running in input-disabled pane ${job.pane}` }], details: { job, status: ready } });
				const status = await waitForTurn(pi, jobDir, job, 0, signal, onUpdate);
				const result = await resultContent(status);
				return {
					content: [{ type: "text", text: `${result.text}\n\n[Subagent ${id} remains alive for follow-up; stop it when done.]` }],
					details: { job, status, resultPath: result.resultPath },
				};
			}

			if (action === "status" && !params.agentId) {
				const ids = await readdir(stateRoot).catch(() => [] as string[]);
				const rows: string[] = [];
				for (const id of ids) {
					const jobDir = join(stateRoot, id);
					const job = await readJson<Job>(join(jobDir, "job.json"));
					if (!job) continue;
					const status = await readJson<ChildStatus>(join(jobDir, "status.json"));
					rows.push(formatStatus(job, status, await paneExists(pi, job.pane)));
				}
				return { content: [{ type: "text", text: rows.join("\n\n") || "No tmux subagents." }], details: {} };
			}

			if (!params.agentId) throw new Error(`agentId is required for ${action}`);
			const jobDir = await resolveJobDir(params.agentId);
			const job = await readJob(jobDir);
			let status = await readJson<ChildStatus>(join(jobDir, "status.json"));
			const alive = await paneExists(pi, job.pane);

			if (action === "status") {
				return { content: [{ type: "text", text: formatStatus(job, status, alive) }], details: { job, status, alive } };
			}
			if (!alive) throw new Error(`Subagent ${job.id} is not running`);

			if (action === "abort") {
				await sendCommand(jobDir, { type: "abort" });
				return { content: [{ type: "text", text: `Abort requested for ${job.id}` }], details: { job, status } };
			}

			if (action === "stop") {
				await sendCommand(jobDir, { type: "abort" }).catch(() => undefined);
				await sendCommand(jobDir, { type: "shutdown" }).catch(() => undefined);
				for (let i = 0; i < 10 && (await paneExists(pi, job.pane)); i++) await sleep(100);
				if (await paneExists(pi, job.pane)) await pi.exec("tmux", ["kill-pane", "-t", job.pane]);
				await rm(jobDir, { recursive: true, force: true });
				return { content: [{ type: "text", text: `Stopped subagent ${job.id}` }], details: { job } };
			}

			if (!params.message?.trim()) throw new Error(`message is required for ${action}`);
			status ??= await waitForReady(pi, jobDir, job, signal);
			if (action === "send" && status.state !== "waiting") {
				throw new Error(`Subagent ${job.id} is ${status.state}; use steer or follow_up while it is busy`);
			}
			const afterTurn = status.turn;
			const deliverAs = action === "steer" ? "steer" : action === "follow_up" ? "followUp" : undefined;
			await sendCommand(jobDir, { type: "prompt", message: params.message, deliverAs });
			if (params.wait === false) {
				return { content: [{ type: "text", text: `Message sent to subagent ${job.id}` }], details: { job, status } };
			}
			status = await waitForTurn(pi, jobDir, job, afterTurn, signal, onUpdate);
			const result = await resultContent(status);
			return {
				content: [{ type: "text", text: `${result.text}\n\n[Subagent ${job.id} remains alive for follow-up; stop it when done.]` }],
				details: { job, status, resultPath: result.resultPath },
			};
		},
	});
}

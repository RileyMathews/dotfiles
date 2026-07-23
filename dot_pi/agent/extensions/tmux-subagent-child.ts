import { mkdir, rename, writeFile } from "node:fs/promises";
import net from "node:net";
import { dirname } from "node:path";
import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";

const jobDir = process.env.PI_TMUX_SUBAGENT_DIR;
const socketPath = jobDir ? `${jobDir}/control.sock` : undefined;
const statusPath = jobDir ? `${jobDir}/status.json` : undefined;

type ChildStatus = {
	state: "starting" | "waiting" | "running" | "stopped" | "error";
	turn: number;
	updatedAt: number;
	message?: string;
	resultPath?: string;
};

type Client = { socket: net.Socket; buffer: string };

function assistantText(message: any): string | undefined {
	if (message?.role !== "assistant") return undefined;
	if (typeof message.content === "string") return message.content.trim() || undefined;
	if (!Array.isArray(message.content)) return undefined;
	const text = message.content
		.filter((part: any) => part?.type === "text" && typeof part.text === "string")
		.map((part: any) => part.text)
		.join("\n")
		.trim();
	return text || undefined;
}

async function atomicJson(path: string, value: unknown): Promise<void> {
	await mkdir(dirname(path), { recursive: true, mode: 0o700 });
	const temporary = `${path}.${process.pid}.tmp`;
	await writeFile(temporary, `${JSON.stringify(value)}\n`, { mode: 0o600 });
	await rename(temporary, path);
}

export default function tmuxSubagentChild(pi: ExtensionAPI) {
	if (!jobDir || !socketPath || !statusPath) return;

	let ctx: ExtensionContext | undefined;
	let server: net.Server | undefined;
	let status: ChildStatus = { state: "starting", turn: 0, updatedAt: Date.now() };
	let lastAssistantText: string | undefined;
	const clients = new Set<Client>();

	const updateStatus = async (patch: Partial<ChildStatus>) => {
		status = { ...status, ...patch, updatedAt: Date.now() };
		await atomicJson(statusPath, status);
	};

	const send = (client: Client, value: unknown) => {
		client.socket.write(`${JSON.stringify(value)}\n`);
	};

	const broadcast = (value: unknown) => {
		for (const client of clients) send(client, value);
	};

	const handleCommand = async (client: Client, command: any) => {
		const id = command?.id;
		try {
			switch (command?.type) {
				case "state":
					send(client, { type: "response", id, success: true, status });
					return;
				case "prompt": {
					if (typeof command.message !== "string" || !command.message.trim()) {
						throw new Error("A non-empty message is required");
					}
					const deliverAs = command.deliverAs;
					if (deliverAs !== undefined && deliverAs !== "steer" && deliverAs !== "followUp") {
						throw new Error("deliverAs must be steer or followUp");
					}
					pi.sendUserMessage(command.message, deliverAs ? { deliverAs } : undefined);
					send(client, { type: "response", id, success: true, turn: status.turn });
					return;
				}
				case "abort":
					await ctx?.abort();
					send(client, { type: "response", id, success: true });
					return;
				case "shutdown":
					send(client, { type: "response", id, success: true });
					ctx?.shutdown();
					return;
				default:
					throw new Error(`Unknown command: ${String(command?.type)}`);
			}
		} catch (error) {
			send(client, {
				type: "response",
				id,
				success: false,
				error: error instanceof Error ? error.message : String(error),
			});
		}
	};

	const addClient = (socket: net.Socket) => {
		const client: Client = { socket, buffer: "" };
		clients.add(client);
		socket.setEncoding("utf8");
		send(client, { type: "hello", status });
		socket.on("data", (chunk) => {
			client.buffer += chunk;
			while (true) {
				const newline = client.buffer.indexOf("\n");
				if (newline < 0) break;
				const line = client.buffer.slice(0, newline).trim();
				client.buffer = client.buffer.slice(newline + 1);
				if (!line) continue;
				try {
					void handleCommand(client, JSON.parse(line));
				} catch (error) {
					send(client, { type: "response", success: false, error: `Invalid JSON: ${String(error)}` });
				}
			}
		});
		socket.on("close", () => clients.delete(client));
		socket.on("error", () => clients.delete(client));
	};

	pi.on("session_start", async (_event, context) => {
		ctx = context;
		await mkdir(jobDir, { recursive: true, mode: 0o700 });
		server = net.createServer(addClient);
		await new Promise<void>((resolve, reject) => {
			server!.once("error", reject);
			server!.listen(socketPath, () => {
				server!.off("error", reject);
				resolve();
			});
		});
		await updateStatus({ state: "waiting" });
	});

	pi.on("agent_start", async () => {
		lastAssistantText = undefined;
		await updateStatus({ state: "running", message: undefined });
	});

	pi.on("message_end", (event) => {
		lastAssistantText = assistantText(event.message) ?? lastAssistantText;
	});

	pi.on("agent_settled", async () => {
		const turn = status.turn + 1;
		const resultPath = `${jobDir}/result-${turn}.txt`;
		await writeFile(resultPath, `${lastAssistantText ?? ""}\n`, { mode: 0o600 });
		await updateStatus({ state: "waiting", turn, resultPath, message: undefined });
		broadcast({ type: "settled", turn, resultPath });
	});

	pi.on("session_shutdown", async () => {
		await updateStatus({ state: "stopped" }).catch(() => undefined);
		for (const client of clients) client.socket.end();
		clients.clear();
		if (server) await new Promise<void>((resolve) => server!.close(() => resolve()));
		server = undefined;
		ctx = undefined;
	});
}

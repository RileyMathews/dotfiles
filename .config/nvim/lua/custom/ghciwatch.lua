local timer = vim.loop.new_timer()
local buf = -1
local job_id = -1
local ghciwatch_command =
	"echo there was an error determining the ghciwatch command to run. Please consult documentation"

local notify_info = function(content, icon)
	icon = icon or ""
	Snacks.notify.info(content, { icon = icon, id = "ghciwatch.nvim", title = "ghciwatch.nvim" })
end

local spinner_frames = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" }

local function start_spinner_notification(message)
	local spinner_index = 1
	local function update_spinner()
		local spinner = spinner_frames[spinner_index]
		spinner_index = (spinner_index % #spinner_frames) + 1
		notify_info(message, spinner)
	end

	update_spinner()
	timer:start(100, 100, vim.schedule_wrap(update_spinner))
end

local function stop_spinner_notification(message)
	message = message or "done!"
	notify_info(message)
	if timer then
		timer:stop()
	end
end

local function get_window_config()
	local width = math.floor(vim.o.columns * 0.8)
	local height = math.floor(vim.o.lines * 0.8)
	local row = math.floor((vim.o.lines - height) / 2)
	local col = math.floor((vim.o.columns - width) / 2)

	local opts = {
		style = "minimal",
		relative = "editor",
		width = width,
		height = height,
		row = row,
		col = col,
		border = "rounded",
	}

	return opts
end

local function show_buffer()
	vim.api.nvim_open_win(buf, true, get_window_config())
end

local function handle_output(_, buffer, _, firstline, lastline, _, _, _, _)
	local lines = vim.api.nvim_buf_get_lines(buffer, firstline, lastline, false)
	for _, line in ipairs(lines) do
		if line:match("All good!") then
			stop_spinner_notification("Ghciwatch done")
		end
		if line:match("Running") then
			start_spinner_notification("Ghciwatch loading modules...")
		end
		if line:match("Reloading failed") then
			stop_spinner_notification("Ghciwatch finished with errors")
		end
	end
end

local function initialize()
	notify_info("starting up")
	buf = vim.api.nvim_create_buf(false, true)
	show_buffer()
	vim.cmd.term(ghciwatch_command)
	vim.api.nvim_buf_attach(buf, false, { on_lines = handle_output })
end

local function deinitialize()
	notify_info("shutting down ghciwatch")
	vim.fn.jobstop(job_id)
end

vim.api.nvim_create_user_command("GhciwatchStart", initialize, { nargs = 0 })
vim.api.nvim_create_user_command("GhciwatchStop", deinitialize, { nargs = 0 })
vim.api.nvim_create_user_command("GhciwatchShow", show_buffer, { nargs = 0 })

vim.api.nvim_create_autocmd("VimLeavePre", {
	callback = function()
		deinitialize()
	end,
})

local function file_exists(path)
	local root = vim.fn.getcwd()
	local file = root .. "/" .. path
	local ok, _ = vim.uv.fs_stat(file)
	return ok
end

local function setup()
	if file_exists("Justfile") then
		ghciwatch_command = "just ghciwatch"
	end
	if file_exists("Makefile") then
		ghciwatch_command = "make ghciwatch"
	end
	return {
		initialize = initialize,
		deinitialize = deinitialize,
		show_buffer = show_buffer,
	}
end

local M = {}
M.setup = setup

return M

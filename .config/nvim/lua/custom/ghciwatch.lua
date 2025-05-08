-- ghciwatch.nvim - minimal Neovim plugin integrating ghciwatch
-- Author: Riley
-- Description: Starts ghciwatch as a job, streams its output (stdout **and**
-- stderr) to a floating window, shows a spinner while ghciwatch is compiling,
-- and exposes helper commands.

local M = {}

-- Internal state -------------------------------------------------------------
local job_id = nil -- handle returned by vim.fn.jobstart()
local output_buf = nil -- buffer receiving ghciwatch output
local output_win = nil -- floating window showing the buffer
local loading = false -- whether we are in the "loading" state
local spinner_timer = nil -- libuv timer for the spinner animation
local spinner_i = 1 -- current frame index
local spinner_frames = { -- braille spinner frames (100 ms period)
	"⠋",
	"⠙",
	"⠹",
	"⠸",
	"⠼",
	"⠴",
	"⠦",
	"⠧",
	"⠇",
	"⠏",
}

-------------------------------------------------------------------------------
-- Utility helpers
-------------------------------------------------------------------------------
local function buf_valid(buf)
	return buf and vim.api.nvim_buf_is_valid(buf)
end
local function win_valid(win)
	return win and vim.api.nvim_win_is_valid(win)
end

-------------------------------------------------------------------------------
-- Spinner helpers
-------------------------------------------------------------------------------
local function spinner_start()
	if spinner_timer then
		return
	end
	spinner_timer = vim.loop.new_timer()
	spinner_timer:start(0, 100, function()
		vim.schedule(function()
			if not loading then
				return
			end
			vim.api.nvim_echo(
				{ {
					string.format("%s ghciwatch loading", spinner_frames[spinner_i]),
					"WarningMsg",
				} },
				false,
				{}
			)
			spinner_i = (spinner_i % #spinner_frames) + 1
		end)
	end)
end

local function spinner_stop()
	if spinner_timer then
		spinner_timer:stop()
		spinner_timer:close()
		spinner_timer = nil
	end
	vim.schedule(function()
		vim.api.nvim_echo({}, false, {})
	end)
end

-------------------------------------------------------------------------------
-- State transitions
-------------------------------------------------------------------------------
local function enter_loading()
	if loading then
		return
	end
	loading = true
	spinner_start()
end

local function exit_loading()
	if not loading then
		return
	end
	loading = false
	spinner_stop()
end

-------------------------------------------------------------------------------
-- Floating window helpers
-------------------------------------------------------------------------------
local function create_output_buf()
	if buf_valid(output_buf) then
		return
	end
	output_buf = vim.api.nvim_create_buf(false, true)
	vim.bo[output_buf].filetype = "ghciwatch-log"
end

local function open_output_win()
	if win_valid(output_win) then
		return
	end
	create_output_buf()
	local width = math.floor(vim.o.columns * 0.8)
	local height = math.floor(vim.o.lines * 0.6)
	output_win = vim.api.nvim_open_win(output_buf, true, {
		relative = "editor",
		row = math.floor((vim.o.lines - height) / 2),
		col = math.floor((vim.o.columns - width) / 2),
		width = width,
		height = height,
		style = "minimal",
		border = "rounded",
	})
end

local function close_output_win()
	if win_valid(output_win) then
		vim.api.nvim_win_close(output_win, true)
		output_win = nil
	end
end

-------------------------------------------------------------------------------
-- Shared output handler (stdout & stderr)
-------------------------------------------------------------------------------
local function handle_output(_, data)
	if not data then
		return
	end
	for _, line in ipairs(data) do
		if line ~= "" then
			vim.api.nvim_buf_set_lines(output_buf, -1, -1, false, { line })
			if line:match("Running") then
				enter_loading()
			end
			if line:match("All good") then
				exit_loading()
			end
		end
	end
end

-------------------------------------------------------------------------------
-- Public API ----------------------------------------------------------------
-------------------------------------------------------------------------------
--- Start ghciwatch in the background and begin streaming its output.
function M.start()
	if job_id then
		vim.notify("[ghciwatch.nvim] ghciwatch is already running", vim.log.levels.INFO)
		return
	end

	create_output_buf()

	job_id = vim.fn.jobstart({ "ghciwatch" }, {
		stdout_buffered = false,
		stderr_buffered = false,
		on_stdout = handle_output,
		on_stderr = handle_output,
		on_exit = function()
			exit_loading()
			job_id = nil
			vim.schedule(function()
				vim.notify("[ghciwatch.nvim] ghciwatch exited", vim.log.levels.INFO)
			end)
		end,
	})

	if job_id <= 0 then
		vim.notify("[ghciwatch.nvim] Failed to start ghciwatch", vim.log.levels.ERROR)
		job_id = nil
	else
		vim.notify("[ghciwatch.nvim] ghciwatch started (job " .. job_id .. ")", vim.log.levels.INFO)
	end
end

--- Stop ghciwatch gracefully.
function M.stop()
	if not job_id then
		return
	end
	vim.fn.jobstop(job_id)
	job_id = nil
	exit_loading()
end

--- Show the ghciwatch output window.
function M.show()
	open_output_win()
end

--- Hide the ghciwatch output window.
function M.hide()
	close_output_win()
end

--- Toggle the ghciwatch output window.
function M.toggle()
	if win_valid(output_win) then
		close_output_win()
	else
		open_output_win()
	end
end

--- Convenience status query.
function M.is_running()
	return job_id ~= nil
end

-------------------------------------------------------------------------------
-- Setup & commands -----------------------------------------------------------
-------------------------------------------------------------------------------
function M.setup(cmds)
	cmds = cmds or {}
	local function cmd(name, fn)
		vim.api.nvim_create_user_command(name, fn, { nargs = 0 })
	end
	cmd(cmds.start or "GhciwatchStart", M.start)
	cmd(cmds.stop or "GhciwatchStop", M.stop)
	cmd(cmds.show or "GhciwatchShow", M.show)
	cmd(cmds.hide or "GhciwatchHide", M.hide)
	cmd(cmds.toggle or "GhciwatchToggle", M.toggle)
end

return M

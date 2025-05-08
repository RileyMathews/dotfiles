local M = {}

local timer = vim.loop.new_timer()

local notify_info = function(content, icon)
	icon = icon or ""
	Snacks.notify.info(content, { icon = icon, id = "ghciwatch.nvim" })
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

local function stop_spinner_notification()
	notify_info("done!")
	if timer then
		timer:stop()
	end
end

vim.api.nvim_create_user_command("GhciwatchStart", function()
	start_spinner_notification("test")
end, { nargs = 0 })
vim.api.nvim_create_user_command("GhciwatchStop", stop_spinner_notification, { nargs = 0 })

return M

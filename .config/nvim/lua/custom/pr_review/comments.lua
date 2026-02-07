-- PR Review Comments - Virtual text and floating window display

local M = {}

local pr_review = nil

local function get_pr_review()
  if not pr_review then
    pr_review = require("custom.pr_review")
  end
  return pr_review
end

-- Namespace for extmarks
local ns_id = vim.api.nvim_create_namespace("pr_review_comments")

-- Display options
local display_opts = {
  show_resolved = true,
  show_outdated = true,
}

-- Toggle resolved visibility
function M.toggle_resolved()
  display_opts.show_resolved = not display_opts.show_resolved
  M.render()
  local status = display_opts.show_resolved and "shown" or "hidden"
  Snacks.notify.info("Resolved comments now " .. status, { title = "PR Review" })
end

-- Toggle outdated visibility
function M.toggle_outdated()
  display_opts.show_outdated = not display_opts.show_outdated
  M.render()
  local status = display_opts.show_outdated and "shown" or "hidden"
  Snacks.notify.info("Outdated comments now " .. status, { title = "PR Review" })
end

-- Format a relative timestamp
---@param timestamp string
---@return string
local function format_relative_time(timestamp)
  -- Parse ISO timestamp
  local year, month, day, hour, min, sec = timestamp:match("(%d+)-(%d+)-(%d+)T(%d+):(%d+):(%d+)")
  if not year then
    return timestamp
  end

  local ts = os.time({
    year = tonumber(year),
    month = tonumber(month),
    day = tonumber(day),
    hour = tonumber(hour),
    min = tonumber(min),
    sec = tonumber(sec),
  })

  local diff = os.time() - ts
  if diff < 60 then
    return "just now"
  elseif diff < 3600 then
    local mins = math.floor(diff / 60)
    return mins .. "m ago"
  elseif diff < 86400 then
    local hours = math.floor(diff / 3600)
    return hours .. "h ago"
  elseif diff < 604800 then
    local days = math.floor(diff / 86400)
    return days .. "d ago"
  else
    return string.format("%s-%s-%s", year, month, day)
  end
end

-- Truncate text to max length
---@param text string
---@param max_len number
---@return string
local function truncate(text, max_len)
  text = text:gsub("\n", " "):gsub("%s+", " ")
  if #text > max_len then
    return text:sub(1, max_len - 3) .. "..."
  end
  return text
end

-- Get threads for a specific file
---@param file_path string
---@return PRReview.ReviewThread[]
local function get_file_threads(file_path)
  local state = get_pr_review().get_state()
  local threads = {}

  for _, thread in ipairs(state.threads or {}) do
    if thread.path == file_path then
      -- Apply visibility filters
      local show = true
      if not display_opts.show_resolved and thread.is_resolved then
        show = false
      end
      if not display_opts.show_outdated and thread.is_outdated and not thread.is_resolved then
        show = false
      end

      if show then
        table.insert(threads, thread)
      end
    end
  end

  return threads
end

-- Get threads at a specific line
---@param file_path string
---@param line number
---@param side string
---@return PRReview.ReviewThread[]
local function get_threads_at_line(file_path, line, side)
  local threads = get_file_threads(file_path)
  local result = {}

  for _, thread in ipairs(threads) do
    local thread_line = thread.line or thread.start_line
    local thread_side = thread.diff_side or "right"

    if thread_line == line and thread_side:lower() == side:lower() then
      table.insert(result, thread)
    end
  end

  return result
end

-- Render comment indicators as virtual text
function M.render()
  local state = get_pr_review().get_state()

  -- Clear existing marks
  for _, side in ipairs({ "left", "right" }) do
    local buf = state.diff_buffers[side]
    if buf and vim.api.nvim_buf_is_valid(buf) then
      vim.api.nvim_buf_clear_namespace(buf, ns_id, 0, -1)
    end
  end

  -- Get current file
  local right_buf = state.diff_buffers.right
  if not right_buf or not vim.api.nvim_buf_is_valid(right_buf) then
    return
  end

  local file_path = vim.b[right_buf].pr_review_file
  if not file_path then
    return
  end

  -- Get threads for this file
  local threads = get_file_threads(file_path)

  -- Group threads by line and side
  local by_line = {
    left = {},
    right = {},
  }

  for _, thread in ipairs(threads) do
    local line = thread.line or thread.start_line
    local side = (thread.diff_side or "right"):lower()

    if line and by_line[side] then
      by_line[side][line] = by_line[side][line] or {}
      table.insert(by_line[side][line], thread)
    end
  end

  -- Render for each side
  for side, lines in pairs(by_line) do
    local buf = state.diff_buffers[side]
    if buf and vim.api.nvim_buf_is_valid(buf) then
      local line_count = vim.api.nvim_buf_line_count(buf)

      for line, line_threads in pairs(lines) do
        if line <= line_count then
          M.render_line_indicator(buf, line, line_threads)
        end
      end
    end
  end
end

-- Render indicator for a single line
---@param buf number
---@param line number
---@param threads PRReview.ReviewThread[]
function M.render_line_indicator(buf, line, threads)
  if #threads == 0 then
    return
  end

  -- Count comments and check status
  local total_comments = 0
  local has_unresolved = false
  local has_outdated = false

  for _, thread in ipairs(threads) do
    total_comments = total_comments + #thread.comments
    if not thread.is_resolved then
      has_unresolved = true
    end
    if thread.is_outdated then
      has_outdated = true
    end
  end

  -- Build display text
  local first_thread = threads[1]
  local first_comment = first_thread.comments[1]
  local preview = ""

  if first_comment then
    preview = truncate(first_comment.body, 50)
  end

  -- Determine highlight
  local hl = "DiagnosticHint" -- default (resolved)
  if has_unresolved then
    hl = "DiagnosticWarn"
  end
  if has_outdated and not has_unresolved then
    hl = "Comment"
  end

  -- Icon based on status (using simple Unicode symbols)
  local icon = "○ " -- default empty circle
  if has_unresolved then
    icon = "● " -- filled circle for unresolved/active
  elseif first_thread.is_resolved then
    icon = "○ " -- empty circle for resolved
  end

  -- Build virtual text
  local virt_text = {}
  table.insert(virt_text, { "  ", "Normal" })
  table.insert(virt_text, { icon, hl })

  if #threads > 1 or total_comments > 1 then
    table.insert(virt_text, { string.format("[%d] ", total_comments), hl })
  end

  if first_comment then
    table.insert(virt_text, { "@" .. first_comment.author .. ": ", "Special" })
    table.insert(virt_text, { preview, hl })
  end

  -- Set extmark
  vim.api.nvim_buf_set_extmark(buf, ns_id, line - 1, 0, {
    virt_text = virt_text,
    virt_text_pos = "eol",
    hl_mode = "combine",
    priority = 100,
  })

  -- Store thread data for lookup
  local extmarks = vim.b[buf].pr_review_extmarks or {}
  extmarks[line] = threads
  vim.b[buf].pr_review_extmarks = extmarks
end

-- Show floating window with full comment details
function M.show_floating()
  local state = get_pr_review().get_state()
  local buf = vim.api.nvim_get_current_buf()
  local win = vim.api.nvim_get_current_win()
  local cursor = vim.api.nvim_win_get_cursor(win)
  local line = cursor[1]

  local file_path = vim.b[buf].pr_review_file
  local side = vim.b[buf].pr_review_side

  if not file_path or not side then
    Snacks.notify.info("Not in a PR review buffer", { title = "PR Review" })
    return
  end

  -- Get threads at this line
  local threads = get_threads_at_line(file_path, line, side)

  if #threads == 0 then
    Snacks.notify.info("No comments on this line", { title = "PR Review" })
    return
  end

  -- Build content for floating window
  local lines = {}
  local highlights = {}

  for i, thread in ipairs(threads) do
    if i > 1 then
      table.insert(lines, "")
      table.insert(lines, string.rep("─", 60))
      table.insert(lines, "")
    end

    -- Thread status header
    local status = ""
    if thread.is_resolved then
      status = "[x] Resolved"
    elseif thread.is_outdated then
      status = "[~] Outdated"
    else
      status = "[!] Active"
    end

    local status_line = string.format("Thread: %s", status)
    table.insert(lines, status_line)
    table.insert(highlights, {
      line = #lines - 1,
      col_start = 0,
      col_end = #status_line,
      hl = thread.is_resolved and "DiagnosticHint"
        or thread.is_outdated and "Comment"
        or "DiagnosticWarn",
    })

    table.insert(lines, "")

    -- Comments
    for j, comment in ipairs(thread.comments) do
      -- Comment header
      local icon = j == 1 and ">" or "  >"
      local header = string.format("%s @%s  %s", icon, comment.author, format_relative_time(comment.created_at))
      table.insert(lines, header)
      table.insert(highlights, {
        line = #lines - 1,
        col_start = #icon + 1,
        col_end = #icon + 2 + #comment.author,
        hl = "Function",
      })

      -- Comment body
      for _, body_line in ipairs(vim.split(comment.body, "\n")) do
        table.insert(lines, "  " .. body_line)
      end

      if j < #thread.comments then
        table.insert(lines, "")
      end
    end
  end

  -- Add instructions
  table.insert(lines, "")
  table.insert(lines, string.rep("─", 60))
  table.insert(lines, "Press 'q' to close | 'r' to reply")
  table.insert(highlights, {
    line = #lines - 1,
    col_start = 0,
    col_end = -1,
    hl = "Comment",
  })

  -- Create floating window
  local float_buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(float_buf, 0, -1, false, lines)
  vim.bo[float_buf].modifiable = false
  vim.bo[float_buf].bufhidden = "wipe"
  vim.bo[float_buf].filetype = "markdown"

  -- Calculate window size
  local width = 70
  local height = math.min(#lines, 20)

  -- Get editor dimensions
  local editor_width = vim.o.columns
  local editor_height = vim.o.lines

  local float_win = vim.api.nvim_open_win(float_buf, true, {
    relative = "cursor",
    row = 1,
    col = 0,
    width = width,
    height = height,
    style = "minimal",
    border = "rounded",
    title = " Comment Thread ",
    title_pos = "center",
  })

  -- Apply highlights
  local ns_float = vim.api.nvim_create_namespace("pr_review_float")
  for _, hl in ipairs(highlights) do
    if hl.col_start and hl.col_end then
      vim.api.nvim_buf_add_highlight(float_buf, ns_float, hl.hl, hl.line, hl.col_start, hl.col_end)
    else
      vim.api.nvim_buf_add_highlight(float_buf, ns_float, hl.hl, hl.line, 0, -1)
    end
  end

  -- Set window options
  vim.wo[float_win].wrap = true
  vim.wo[float_win].linebreak = true
  vim.wo[float_win].cursorline = false

  -- Store thread info for reply action
  vim.b[float_buf].pr_review_threads = threads
  vim.b[float_buf].pr_review_file = file_path
  vim.b[float_buf].pr_review_line = line
  vim.b[float_buf].pr_review_side = side

  -- Keymaps for floating window
  local close_float = function()
    if vim.api.nvim_win_is_valid(float_win) then
      vim.api.nvim_win_close(float_win, true)
    end
  end

  local reply = function()
    close_float()
    vim.schedule(function()
      require("custom.pr_review.actions").reply_to_thread_at(file_path, line, side)
    end)
  end

  vim.keymap.set("n", "q", close_float, { buffer = float_buf, nowait = true })
  vim.keymap.set("n", "<Esc>", close_float, { buffer = float_buf, nowait = true })
  vim.keymap.set("n", "r", reply, { buffer = float_buf, nowait = true })
end

-- Get comment thread at cursor position (for actions)
---@return PRReview.ReviewThread?, PRReview.Comment?
function M.get_thread_at_cursor()
  local buf = vim.api.nvim_get_current_buf()
  local win = vim.api.nvim_get_current_win()
  local cursor = vim.api.nvim_win_get_cursor(win)
  local line = cursor[1]

  local file_path = vim.b[buf].pr_review_file
  local side = vim.b[buf].pr_review_side

  if not file_path or not side then
    return nil, nil
  end

  local threads = get_threads_at_line(file_path, line, side)
  if #threads == 0 then
    return nil, nil
  end

  -- Return the first thread and its first comment (for reply)
  local thread = threads[1]
  local comment = thread.comments[#thread.comments] -- last comment for reply

  return thread, comment
end

return M

-- PR Review Picker - File selection using Snacks picker

local M = {}

local pr_review = nil

local function get_pr_review()
  if not pr_review then
    pr_review = require("custom.pr_review")
  end
  return pr_review
end

-- Format file item for display
---@param item table
---@return snacks.picker.Highlight[]
local function format_file(item)
  local ret = {} ---@type snacks.picker.Highlight[]

  -- Status icon
  local status_icons = {
    added = "+",
    deleted = "-",
    modified = "~",
    renamed = "R",
  }
  local status_hl = {
    added = "DiffAdd",
    deleted = "DiffDelete",
    modified = "DiffChange",
    renamed = "DiffText",
  }

  local icon = status_icons[item.status] or "~"
  local hl = status_hl[item.status] or "DiffChange"

  ret[#ret + 1] = { icon .. " ", hl }

  -- File icon based on filetype
  local file_icon, file_hl
  local ok, devicons = pcall(require, "nvim-web-devicons")
  if ok then
    local ext = item.path:match("%.([^%.]+)$")
    file_icon, file_hl = devicons.get_icon(item.path, ext, { default = true })
  end
  file_icon = file_icon or "*"
  file_hl = file_hl or "Normal"
  ret[#ret + 1] = { file_icon .. " ", file_hl }

  -- File path
  ret[#ret + 1] = { item.path }

  -- Change stats
  ret[#ret + 1] = { " " }
  if item.additions > 0 then
    ret[#ret + 1] = { "+" .. item.additions, "DiffAdd" }
  end
  if item.deletions > 0 then
    if item.additions > 0 then
      ret[#ret + 1] = { "/" }
    end
    ret[#ret + 1] = { "-" .. item.deletions, "DiffDelete" }
  end

  -- Comment indicator
  local state = get_pr_review().get_state()
  local comment_count = 0
  local unresolved_count = 0
  for _, thread in ipairs(state.threads or {}) do
    if thread.path == item.path then
      comment_count = comment_count + 1
      if not thread.is_resolved then
        unresolved_count = unresolved_count + 1
      end
    end
  end

  if comment_count > 0 then
    ret[#ret + 1] = { "  " }
    ret[#ret + 1] = { " " .. comment_count, unresolved_count > 0 and "DiagnosticWarn" or "DiagnosticHint" }
    if unresolved_count > 0 then
      ret[#ret + 1] = { " (" .. unresolved_count .. " unresolved)", "DiagnosticWarn" }
    end
  end

  return ret
end

-- Build items list from state
local function build_items()
  local state = get_pr_review().get_state()
  local items = {}

  for i, file in ipairs(state.files or {}) do
    table.insert(items, {
      idx = i,
      text = file.path,
      path = file.path,
      status = file.status,
      additions = file.additions,
      deletions = file.deletions,
      file = file,
    })
  end

  return items
end

-- Open the file picker
function M.open()
  local state = get_pr_review().get_state()
  local pr = state.pr

  if not pr then
    Snacks.notify.warn("No PR loaded", { title = "PR Review" })
    return
  end

  Snacks.picker({
    title = string.format("  PR #%d: %s", pr.number, pr.title),
    items = build_items(),
    format = function(item)
      return format_file(item)
    end,
    preview = "none", -- No preview - we use full diff view
    layout = {
      preset = "select",
      layout = {
        width = 0.6,
        min_width = 80,
        height = 0.5,
      },
    },
    sort = { fields = { "idx" } }, -- Keep original order
    confirm = function(picker, item)
      picker:close()
      if item then
        vim.schedule(function()
          get_pr_review().open_file(item.idx)
        end)
      end
    end,
    win = {
      input = {
        keys = {
          ["<c-r>"] = {
            function(picker)
              picker:close()
              vim.schedule(function()
                get_pr_review().refresh()
                M.open()
              end)
            end,
            mode = { "n", "i" },
            desc = "Refresh",
          },
        },
      },
    },
  })
end

return M

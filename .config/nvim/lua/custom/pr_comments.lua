-- GitHub PR Comments Plugin
-- Displays PR review comments inline using virtual text
--
-- Setup:
--   local pr_comments = require("custom.pr_comments").setup({
--       use_fake_data = false,  -- Use real GitHub API (default: false)
--   })
--
-- Requirements:
--   - GitHub CLI (gh) installed and authenticated
--   - Must be in a git repository with GitHub remote
--   - Must be on a branch with an open PR

local M = {}

-- Configuration (initialized in setup)
local config = nil

-- State (initialized in setup)
local state = nil

-- Module-level variables
local namespace_id = vim.api.nvim_create_namespace("pr_comments")
local augroup_id = nil
local current_thread_index = nil
local reset_thread_cursor = nil
local reply_mod = nil
local comments_render_mod = nil
local comments_api_mod = nil

local function get_reply()
    if not reply_mod then
        reply_mod = require("custom.pr_shared.reply")
    end
    return reply_mod
end

local function get_comments_render()
    if not comments_render_mod then
        comments_render_mod = require("custom.pr_shared.comments_render")
    end
    return comments_render_mod
end

local function get_comments_api()
    if not comments_api_mod then
        comments_api_mod = require("custom.pr_shared.comments_api")
    end
    return comments_api_mod
end

local function get_repo_root()
    local handle = io.popen("git rev-parse --show-toplevel 2>&1")
    if not handle then
        return nil
    end

    local repo_root = vim.trim(handle:read("*a") or "")
    handle:close()

    if repo_root == "" then
        return nil
    end

    return repo_root
end

-- Default configuration
local default_config = {
    use_fake_data = false, -- Use fake test data instead of GitHub API
}

-- Validate configuration
local function validate_config(cfg)
    if cfg == nil then
        return -- nil is ok, will use defaults
    end
    
    if type(cfg) ~= "table" then
        error("pr_comments.setup(): config must be a table")
    end
    
    if cfg.use_fake_data ~= nil and type(cfg.use_fake_data) ~= "boolean" then
        error("pr_comments.setup(): use_fake_data must be a boolean")
    end
end

-- Ensure setup was called before using plugin
local function ensure_setup()
    if not config then
        error("pr_comments: setup() must be called before using this module")
    end
end

-- Data Model
--[[
ThreadData = {
    id = "thread-123",
    path = "relative/path/to/file.lua",
    line = 42,
    resolved = false,
    outdated = false,  -- Thread is outdated (code changed since comment)
    comments = {
        {
            id = "comment-1",
            author = "username",
            body = "comment text here",
            created_at = "2026-02-04T23:16:37Z",
        },
        -- ... replies
    }
}
--]]

-- Notification helpers
local notify_info = function(content, icon)
    icon = icon or ""
    Snacks.notify.info(content, { icon = icon, id = "pr_comments", title = "PR Comments" })
end

local notify_error = function(content, icon)
    icon = icon or ""
    Snacks.notify.error(content, { icon = icon, id = "pr_comments", title = "PR Comments" })
end

-- ============================================================================
-- FAKE DATA GENERATOR (for development)
-- ============================================================================

local function generate_fake_data()
    return {
        -- File 1: Multiple scenarios
        [".config/nvim/lua/custom/pr_comments.lua"] = {
            [42] = {
                {
                    id = "thread-1",
                    file = ".config/nvim/lua/custom/pr_comments.lua",
                    line = 42,
                    resolved = false,
                    outdated = false,
                    comments = {
                        {
                            id = "comment-1",
                            user = "reviewer1",
                            body = "This function could be simplified. Consider using a helper.",
                            created_at = "2026-02-04T10:30:00Z",
                        },
                    },
                },
            },
            [85] = {
                {
                    id = "thread-2",
                    file = ".config/nvim/lua/custom/pr_comments.lua",
                    line = 85,
                    resolved = false,
                    outdated = false,
                    comments = {
                        {
                            id = "comment-2",
                            user = "reviewer2",
                            body = "We should handle the case where this returns nil. Add error checking here!",
                            created_at = "2026-02-04T11:15:00Z",
                        },
                        {
                            id = "comment-3",
                            user = "RileyMathews",
                            body = "Good catch! Will fix.",
                            created_at = "2026-02-04T11:30:00Z",
                        },
                    },
                },
            },
            [120] = {
                {
                    id = "thread-3",
                    file = ".config/nvim/lua/custom/pr_comments.lua",
                    line = 120,
                    resolved = true,
                    outdated = false,
                    comments = {
                        {
                            id = "comment-4",
                            user = "reviewer1",
                            body = "Nice refactoring!",
                            created_at = "2026-02-04T12:00:00Z",
                        },
                        {
                            id = "comment-5",
                            user = "RileyMathews",
                            body = "Thanks!",
                            created_at = "2026-02-04T12:05:00Z",
                        },
                    },
                },
            },
            -- Multiple threads on same line
            [200] = {
                {
                    id = "thread-4",
                    file = ".config/nvim/lua/custom/pr_comments.lua",
                    line = 200,
                    resolved = false,
                    outdated = false,
                    comments = {
                        {
                            id = "comment-6",
                            user = "reviewer1",
                            body = "Is this the right approach?",
                            created_at = "2026-02-04T13:00:00Z",
                        },
                    },
                },
                {
                    id = "thread-5",
                    file = ".config/nvim/lua/custom/pr_comments.lua",
                    line = 200,
                    resolved = false,
                    outdated = false,
                    comments = {
                        {
                            id = "comment-7",
                            user = "reviewer2",
                            body = "Also wondering about performance here.",
                            created_at = "2026-02-04T13:15:00Z",
                        },
                    },
                },
            },
            -- Outdated thread (code changed since comment)
            [150] = {
                {
                    id = "thread-outdated-1",
                    file = ".config/nvim/lua/custom/pr_comments.lua",
                    line = 150,
                    resolved = false,
                    outdated = true,
                    comments = {
                        {
                            id = "comment-outdated-1",
                            user = "reviewer1",
                            body = "This variable name should be more descriptive",
                            created_at = "2026-02-01T10:00:00Z",
                        },
                    },
                },
            },
            -- Resolved and outdated (old conversation that's done)
            [175] = {
                {
                    id = "thread-resolved-outdated",
                    file = ".config/nvim/lua/custom/pr_comments.lua",
                    line = 175,
                    resolved = true,
                    outdated = true,
                    comments = {
                        {
                            id = "comment-resolved-outdated",
                            user = "reviewer2",
                            body = "This function is too long, consider splitting",
                            created_at = "2026-02-02T14:00:00Z",
                        },
                        {
                            id = "comment-resolved-outdated-reply",
                            user = "RileyMathews",
                            body = "Refactored in latest commit",
                            created_at = "2026-02-02T15:00:00Z",
                        },
                    },
                },
            },
        },
        -- File 2: Edge cases
        [".config/nvim/lua/custom/test.lua"] = {
            [1] = {
                {
                    id = "thread-6",
                    file = ".config/nvim/lua/custom/test.lua",
                    line = 1,
                    resolved = false,
                    outdated = false,
                    comments = {
                        {
                            id = "comment-8",
                            user = "reviewer3",
                            body = "Comment on first line of file",
                            created_at = "2026-02-05T09:00:00Z",
                        },
                    },
                },
            },
            [5] = {
                {
                    id = "thread-7",
                    file = ".config/nvim/lua/custom/test.lua",
                    line = 5,
                    resolved = false,
                    outdated = false,
                    comments = {
                        {
                            id = "comment-9",
                            user = "reviewer1",
                            body = "This is a very long comment that will definitely exceed the 80 character limit and should be truncated properly when displayed as virtual text to avoid cluttering the screen",
                            created_at = "2026-02-05T10:00:00Z",
                        },
                    },
                },
            },
            [6] = {
                {
                    id = "thread-8",
                    file = ".config/nvim/lua/custom/test.lua",
                    line = 6,
                    resolved = true,
                    outdated = false,
                    comments = {
                        {
                            id = "comment-10",
                            user = "reviewer2",
                            body = "Fixed in latest commit",
                            created_at = "2026-02-05T11:00:00Z",
                        },
                    },
                },
            },
        },
    }
end

-- ============================================================================
-- HELPER FUNCTIONS
-- ============================================================================

-- Get buffer's relative path from repo root
local function get_buffer_relative_path(bufnr)
    local abs_path = vim.api.nvim_buf_get_name(bufnr)
    if abs_path == "" then
        return nil
    end

    local repo_root = get_repo_root()
    if not repo_root then
        return nil
    end

    -- Make path relative to repo root
    if abs_path:sub(1, #repo_root) == repo_root then
        local relative = abs_path:sub(#repo_root + 2) -- +2 to skip the trailing slash
        return relative
    end

    return nil
end

local function thread_is_visible(thread)
    if not state.show_resolved and thread.resolved then
        return false
    end

    if not state.show_outdated and thread.outdated and not thread.resolved then
        return false
    end

    return true
end

local function get_visible_threads_for_file(rel_path)
    local file_threads = state.threads[rel_path]
    if not file_threads then
        return {}
    end

    local visible = {}
    for line_num, threads in pairs(file_threads) do
        local visible_threads = {}
        for _, thread in ipairs(threads) do
            if thread_is_visible(thread) then
                table.insert(visible_threads, thread)
            end
        end

        if #visible_threads > 0 then
            visible[line_num] = visible_threads
        end
    end

    return visible
end

local function normalize_fake_threads(raw_threads)
    local normalized = {}

    for path, lines in pairs(raw_threads or {}) do
        normalized[path] = {}
        for line_num, threads in pairs(lines or {}) do
            normalized[path][line_num] = {}
            for _, thread in ipairs(threads or {}) do
                local comments = {}
                for _, comment in ipairs(thread.comments or {}) do
                    table.insert(comments, {
                        id = comment.id,
                        author = comment.author or comment.user or "unknown",
                        body = comment.body or "",
                        created_at = comment.created_at or "",
                    })
                end

                table.insert(normalized[path][line_num], {
                    id = thread.id,
                    path = thread.path or thread.file or path,
                    line = thread.line or line_num,
                    resolved = thread.resolved == true,
                    outdated = thread.outdated == true,
                    comments = comments,
                })
            end
        end
    end

    return normalized
end


-- Count threads by status
local function count_threads()
    local total = 0
    local unresolved = 0
    local file_count = 0
    local files_seen = {}

    for filepath, lines in pairs(state.threads) do
        if not files_seen[filepath] then
            files_seen[filepath] = true
            file_count = file_count + 1
        end

        for _, threads in pairs(lines) do
            for _, thread in ipairs(threads) do
                total = total + 1
                if not thread.resolved then
                    unresolved = unresolved + 1
                end
            end
        end
    end

    return {
        total = total,
        unresolved = unresolved,
        resolved = total - unresolved,
        files = file_count,
    }
end

-- ============================================================================
-- CORE DISPLAY LOGIC
-- ============================================================================

-- Show comments for a specific buffer
local function show_comments_for_buffer(bufnr)
    bufnr = bufnr or vim.api.nvim_get_current_buf()

    -- Clear existing comments first
    vim.api.nvim_buf_clear_namespace(bufnr, namespace_id, 0, -1)
    vim.b[bufnr].pr_comments_extmarks = {}

    if not state.active then
        return
    end

    -- Get buffer's relative path
    local rel_path = get_buffer_relative_path(bufnr)
    if not rel_path then
        return
    end

    local file_threads = get_visible_threads_for_file(rel_path)
    if vim.tbl_isempty(file_threads) then
        return
    end

    local extmarks = {}

    -- Display visible threads as virtual text
    for line_num, threads in pairs(file_threads) do
        local ok = get_comments_render().render_line_indicator({
            buf = bufnr,
            line = line_num,
            threads = threads,
            ns_id = namespace_id,
            store_threads = false,
        })

        if ok then
            extmarks[line_num] = threads
        end
    end

    vim.b[bufnr].pr_comments_extmarks = extmarks
end

-- Clear comments from buffer
local function clear_comments(bufnr)
    bufnr = bufnr or vim.api.nvim_get_current_buf()
    vim.api.nvim_buf_clear_namespace(bufnr, namespace_id, 0, -1)
    vim.b[bufnr].pr_comments_extmarks = nil
end

local function rerender_loaded_buffers()
    for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_valid(bufnr) and vim.api.nvim_buf_is_loaded(bufnr) then
            show_comments_for_buffer(bufnr)
        end
    end
end

-- ============================================================================
-- DATA LOADING
-- ============================================================================

-- Load comments (fake data or real GitHub API)
local function load_comments()
    if config.use_fake_data then
        notify_info("Loaded fake PR comments", "✓")
        state.threads = normalize_fake_threads(generate_fake_data())
        state.pr_number = 12345
        return true
    end
    
    -- Real GitHub API
    notify_info("Loading PR comments...", "")
    
    local repo_info, err = get_comments_api().get_repo_info()
    if err then
        notify_error(err)
        return false
    end

    local pr_number, pr_err = get_comments_api().get_current_pr_number()
    if not pr_number then
        notify_error(pr_err or "No PR found for current branch")
        return false
    end

    local threads, fetch_err = get_comments_api().fetch_review_threads(repo_info.owner, repo_info.name, pr_number)
    if fetch_err then
        notify_error("Failed to fetch PR comments: " .. fetch_err)
        return false
    end

    -- Store in state
    state.threads = get_comments_api().group_threads_by_path_line(threads)
    state.pr_number = pr_number
    return true
end

-- ============================================================================
-- COMMANDS
-- ============================================================================

-- Command: Show PR comments
local function show_pr_comments()
    ensure_setup()
    
    if state.active then
        notify_info("PR comments already active")
        return
    end

    -- Load comments
    if not load_comments() then
        return
    end

    state.active = true

    -- Show comments for current buffer
    show_comments_for_buffer(vim.api.nvim_get_current_buf())

    -- Set up autocommand to show comments when entering buffers
    if augroup_id then
        vim.api.nvim_del_augroup_by_id(augroup_id)
    end

    augroup_id = vim.api.nvim_create_augroup("PRComments", { clear = true })
    vim.api.nvim_create_autocmd("BufEnter", {
        group = augroup_id,
        callback = function()
            if state.active then
                show_comments_for_buffer(vim.api.nvim_get_current_buf())
            end
        end,
    })

    -- Success notification
    local counts = count_threads()
    if counts.total == 0 then
        notify_info("No review comments found on PR #" .. state.pr_number, "✓")
    else
        notify_info(
            string.format(
                "Loaded %d thread%s (%d unresolved) across %d file%s",
                counts.total,
                counts.total == 1 and "" or "s",
                counts.unresolved,
                counts.files,
                counts.files == 1 and "" or "s"
            ),
            "✓"
        )
    end
end

-- Command: Hide PR comments
local function hide_pr_comments()
    ensure_setup()
    
    if not state.active then
        notify_info("No PR comments currently shown")
        return
    end

    -- Clear all buffers
    for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_valid(bufnr) then
            clear_comments(bufnr)
        end
    end

    -- Clear autocommands
    if augroup_id then
        vim.api.nvim_del_augroup_by_id(augroup_id)
        augroup_id = nil
    end

    -- Reset state
    state.active = false
    state.threads = {}
    state.pr_number = nil
    reset_thread_cursor()

    notify_info("PR comments hidden", "✓")
end

-- Command: Refresh PR comments
local function refresh_pr_comments()
    ensure_setup()
    
    if not state.active then
        notify_info("No PR comments to refresh. Use :PRCommentsShow first")
        return
    end

    -- Clear and re-fetch
    hide_pr_comments()
    show_pr_comments()
end

-- Command: Toggle PR comments
local function toggle_pr_comments()
    ensure_setup()
    
    if state.active then
        hide_pr_comments()
    else
        show_pr_comments()
    end
end

-- Command: Toggle showing resolved threads
local function toggle_resolved()
    ensure_setup()
    
    if not state.active then
        notify_info("No PR comments currently shown")
        return
    end

    state.show_resolved = not state.show_resolved
    reset_thread_cursor()

    rerender_loaded_buffers()

    local status = state.show_resolved and "shown" or "hidden"
    notify_info("Resolved threads now " .. status, "✓")
end

-- Command: Toggle showing outdated threads
local function toggle_outdated()
    ensure_setup()
    
    if not state.active then
        notify_info("No PR comments currently shown")
        return
    end

    state.show_outdated = not state.show_outdated
    reset_thread_cursor()

    rerender_loaded_buffers()

    local status = state.show_outdated and "shown" or "hidden"
    notify_info("Outdated threads now " .. status, "✓")
end

-- ============================================================================
-- FLOATING WINDOW - View Thread Details
-- ============================================================================

-- Get thread(s) at cursor position
local function get_threads_at_cursor()
    if not state.active then
        return nil, "No PR comments loaded. Run :PRCommentsShow first"
    end

    local bufnr = vim.api.nvim_get_current_buf()
    local cursor_line = vim.api.nvim_win_get_cursor(0)[1] -- 1-indexed

    -- Get buffer's relative path
    local rel_path = get_buffer_relative_path(bufnr)
    if not rel_path then
        return nil, "Not in a tracked file"
    end

    -- Prefer rendered metadata (respects visibility filters)
    local rendered_threads = vim.b[bufnr].pr_comments_extmarks
    if rendered_threads and rendered_threads[cursor_line] and #rendered_threads[cursor_line] > 0 then
        return rendered_threads[cursor_line], nil
    end

    -- Fallback: derive from state for this file
    local file_threads = get_visible_threads_for_file(rel_path)
    local threads_at_line = file_threads[cursor_line]
    if not threads_at_line or #threads_at_line == 0 then
        return nil, "No visible comment thread on line " .. cursor_line
    end

    return threads_at_line, nil
end

local function post_thread_reply(thread_id, body)
    return get_comments_api().add_thread_reply(thread_id, body)
end

local function reply_to_thread(thread)
    if config.use_fake_data then
        notify_info("Reply disabled when use_fake_data=true")
        return
    end

    if not thread or not thread.id then
        notify_error("Could not find thread id to reply")
        return
    end

    local title = string.format("Reply on %s:%d", thread.path, thread.line)
    get_reply().reply({
        title = title,
        notify_title = "PR Comments",
        posting_message = "Posting reply...",
        success_message = "Reply posted",
        submit = function(body)
            return post_thread_reply(thread.id, body)
        end,
        map_error = function(err)
            if err and err:find("pending review") then
                return "Cannot reply: you have a pending review. Submit it from PR Review first"
            end
            return "Failed to post reply: " .. (err or "unknown error")
        end,
        on_success = function()
            refresh_pr_comments()
        end,
    })
end

local function reply_to_threads(threads)
    if #threads == 1 then
        reply_to_thread(threads[1])
        return
    end

    local options = {}
    for i, thread in ipairs(threads) do
        local first_comment = thread.comments and thread.comments[1] or nil
        local preview = first_comment and get_comments_render().truncate(first_comment.body, 50) or "thread"
        local status = thread.resolved and "resolved" or thread.outdated and "outdated" or "active"
        options[i] = string.format("%d. (%s) @%s: %s", i, status, first_comment and first_comment.author or "unknown", preview)
    end

    Snacks.picker.select(options, { title = "Select thread to reply" }, function(_, idx)
        if idx and threads[idx] then
            reply_to_thread(threads[idx])
        end
    end)
end

local function reply_thread_at_cursor()
    ensure_setup()

    local threads, err = get_threads_at_cursor()
    if err then
        notify_info(err)
        return
    end

    reply_to_threads(threads)
end

-- Command: View thread at cursor in floating window
local function view_thread_at_cursor()
    ensure_setup()
    
    local threads, err = get_threads_at_cursor()
    if err then
        notify_info(err)
        return
    end

    local bufnr = vim.api.nvim_get_current_buf()
    local line = vim.api.nvim_win_get_cursor(0)[1]
    local file_path = get_buffer_relative_path(bufnr) or ""

    get_comments_render().show_floating({
        threads = threads,
        file_path = file_path,
        line = line,
        side = "right",
        notify_title = "PR Comments",
        on_reply = function()
            reply_to_threads(threads)
        end,
    })
end

-- ============================================================================
-- NAVIGATION - Jump Between Threads
-- ============================================================================

-- Get all threads sorted by file path, then line number
local function get_all_threads_sorted()
    if not state.active then
        return {}
    end

    local all_threads = {}
    
    -- Collect all visible threads with their location info
    for filepath, _ in pairs(state.threads) do
        local lines = get_visible_threads_for_file(filepath)
        for line_num, threads in pairs(lines) do
            for _, thread in ipairs(threads) do
                table.insert(all_threads, {
                    file = filepath,
                    line = line_num,
                    thread = thread,
                })
            end
        end
    end

    -- Sort by file, then by line number
    table.sort(all_threads, function(a, b)
        if a.file == b.file then
            return a.line < b.line
        end
        return a.file < b.file
    end)

    return all_threads
end

-- Initialize/reset the thread cursor
reset_thread_cursor = function()
    current_thread_index = nil
end

-- Jump to a specific thread location
local function jump_to_thread(item, direction)
    local repo_root = get_repo_root()
    if not repo_root then
        notify_error("Failed to get repository root")
        return false
    end

    local abs_path = repo_root .. "/" .. item.file

    -- Open file if not already open
    local current_buf = vim.api.nvim_get_current_buf()
    local current_path = vim.api.nvim_buf_get_name(current_buf)
    
    if current_path ~= abs_path then
        -- Open the file
        vim.cmd("edit " .. vim.fn.fnameescape(abs_path))
    end

    -- Jump to line
    vim.api.nvim_win_set_cursor(0, { item.line, 0 })

    -- Center the line in the window
    vim.cmd("normal! zz")

    -- Show notification
    local thread = item.thread
    local first_comment = thread.comments[1]
    local preview = first_comment.body:gsub("\n", " ")
    if #preview > 50 then
        preview = preview:sub(1, 50) .. "..."
    end

    local status_icon = thread.resolved and "✓" or "❗"
    notify_info(
        string.format("%s @%s: %s", status_icon, first_comment.author, preview),
        direction == "next" and "→" or "←"
    )

    return true
end

-- Command: Jump to next thread
local function jump_to_next_thread()
    ensure_setup()
    
    if not state.active then
        notify_info("No PR comments loaded. Run :PRCommentsShow first")
        return
    end

    local sorted_threads = get_all_threads_sorted()
    if #sorted_threads == 0 then
        notify_info("No comment threads found")
        return
    end

    -- Initialize cursor if not set, otherwise increment
    if not current_thread_index then
        current_thread_index = 1
    else
        current_thread_index = current_thread_index + 1
        -- Wrap around to beginning
        if current_thread_index > #sorted_threads then
            current_thread_index = 1
        end
    end

    local next_thread = sorted_threads[current_thread_index]
    jump_to_thread(next_thread, "next")
end

-- Command: Jump to previous thread
local function jump_to_prev_thread()
    ensure_setup()
    
    if not state.active then
        notify_info("No PR comments loaded. Run :PRCommentsShow first")
        return
    end

    local sorted_threads = get_all_threads_sorted()
    if #sorted_threads == 0 then
        notify_info("No comment threads found")
        return
    end

    -- Initialize cursor if not set, otherwise decrement
    if not current_thread_index then
        current_thread_index = #sorted_threads
    else
        current_thread_index = current_thread_index - 1
        -- Wrap around to end
        if current_thread_index < 1 then
            current_thread_index = #sorted_threads
        end
    end

    local prev_thread = sorted_threads[current_thread_index]
    jump_to_thread(prev_thread, "prev")
end

-- ============================================================================
-- SETUP
-- ============================================================================

M.setup = function(user_config)
    -- Validate configuration
    validate_config(user_config)
    
    -- Merge with defaults
    config = vim.tbl_deep_extend("force", default_config, user_config or {})
    
    -- Initialize state
    state = {
        active = false,
        pr_number = nil,
        show_resolved = true,
        show_outdated = true,
        threads = {},
    }
    
    -- Reset navigation cursor
    current_thread_index = nil
    
    -- Create user commands
    vim.api.nvim_create_user_command("PRCommentsShow", show_pr_comments, { nargs = 0 })
    vim.api.nvim_create_user_command("PRCommentsHide", hide_pr_comments, { nargs = 0 })
    vim.api.nvim_create_user_command("PRCommentsRefresh", refresh_pr_comments, { nargs = 0 })
    vim.api.nvim_create_user_command("PRCommentsToggle", toggle_pr_comments, { nargs = 0 })
    vim.api.nvim_create_user_command("PRCommentsToggleResolved", toggle_resolved, { nargs = 0 })
    vim.api.nvim_create_user_command("PRCommentsToggleOutdated", toggle_outdated, { nargs = 0 })
    vim.api.nvim_create_user_command("PRCommentsView", view_thread_at_cursor, { nargs = 0 })
    vim.api.nvim_create_user_command("PRCommentsReply", reply_thread_at_cursor, { nargs = 0 })
    vim.api.nvim_create_user_command("PRCommentsNext", jump_to_next_thread, { nargs = 0 })
    vim.api.nvim_create_user_command("PRCommentsPrev", jump_to_prev_thread, { nargs = 0 })
    
    -- Return public API
    return {
        show = show_pr_comments,
        hide = hide_pr_comments,
        refresh = refresh_pr_comments,
        toggle = toggle_pr_comments,
        toggle_resolved = toggle_resolved,
        toggle_outdated = toggle_outdated,
        view = view_thread_at_cursor,
        reply = reply_thread_at_cursor,
        next = jump_to_next_thread,
        prev = jump_to_prev_thread,
    }
end

return M

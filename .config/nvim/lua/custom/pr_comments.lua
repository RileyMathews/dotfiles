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
    file = "relative/path/to/file.lua",
    line = 42,
    resolved = false,
    outdated = false,  -- Thread is outdated (code changed since comment)
    comments = {
        {
            id = "comment-1",
            user = "username",
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

    -- Get repo root
    local handle = io.popen("git rev-parse --show-toplevel 2>&1")
    if not handle then
        return nil
    end
    local repo_root = handle:read("*a")
    handle:close()

    repo_root = vim.trim(repo_root)

    -- Make path relative to repo root
    if abs_path:sub(1, #repo_root) == repo_root then
        local relative = abs_path:sub(#repo_root + 2) -- +2 to skip the trailing slash
        return relative
    end

    return nil
end

-- Format a single thread for display
local function format_thread_display(thread)
    local first_comment = thread.comments[1]
    local reply_count = #thread.comments - 1

    local max_length = 80
    local text

    if reply_count > 0 then
        text = string.format("@%s: %s (+ %d %s)", first_comment.user, first_comment.body, reply_count, reply_count == 1 and "reply" or "replies")
    else
        text = string.format("@%s: %s", first_comment.user, first_comment.body)
    end

    -- Replace newlines with spaces
    text = text:gsub("\n", " ")

    -- Truncate if too long
    if #text > max_length then
        text = text:sub(1, max_length - 3) .. "..."
    end

    -- Add status icon (resolved takes precedence over outdated)
    local icon
    if thread.resolved then
        icon = "✓ "
    elseif thread.outdated then
        icon = "⚠️ "
    else
        icon = "❗"
    end
    return icon .. text
end

-- Get highlight group for thread
local function get_thread_highlight(thread)
    -- Resolved takes precedence over outdated
    if thread.resolved then
        return "DiagnosticHint" -- Dimmed for resolved
    elseif thread.outdated then
        return "Comment" -- Very dimmed for outdated
    else
        return "DiagnosticWarn" -- Yellow/orange for unresolved
    end
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

    if not state.active then
        return
    end

    -- Get buffer's relative path
    local rel_path = get_buffer_relative_path(bufnr)
    if not rel_path then
        return
    end

    -- Get threads for this file
    local file_threads = state.threads[rel_path]
    if not file_threads then
        return
    end

    -- Display threads as virtual text
    for line_num, threads in pairs(file_threads) do
        -- Filter based on show_resolved and show_outdated settings
        local visible_threads = {}
        for _, thread in ipairs(threads) do
            local show_thread = true
            
            -- Filter resolved threads
            if not state.show_resolved and thread.resolved then
                show_thread = false
            end
            
            -- Filter outdated threads (but keep if resolved, since resolved takes precedence)
            if not state.show_outdated and thread.outdated and not thread.resolved then
                show_thread = false
            end
            
            if show_thread then
                table.insert(visible_threads, thread)
            end
        end

        if #visible_threads > 0 then
            -- For now, show only the first thread
            local thread = visible_threads[1]
            local display_text = format_thread_display(thread)
            local highlight = get_thread_highlight(thread)

            -- Set extmark (line numbers are 0-indexed in API)
            local ok = pcall(vim.api.nvim_buf_set_extmark, bufnr, namespace_id, line_num - 1, 0, {
                virt_text = { { display_text, highlight } },
                virt_text_pos = "eol",
                hl_mode = "combine",
            })

            if not ok then
                -- Silently skip invalid line numbers (file may have changed)
            end
        end
    end
end

-- Clear comments from buffer
local function clear_comments(bufnr)
    bufnr = bufnr or vim.api.nvim_get_current_buf()
    vim.api.nvim_buf_clear_namespace(bufnr, namespace_id, 0, -1)
end

-- ============================================================================
-- GITHUB API INTEGRATION
-- ============================================================================

-- Helper: Execute shell command and return stdout
local function execute_command(cmd)
    local handle = io.popen(cmd .. " 2>&1")
    if not handle then
        return nil, "Failed to execute command"
    end
    local result = handle:read("*a")
    local success = handle:close()
    return result, success
end

-- Helper: Get repository owner and name
local function get_repo_info()
    local output, success = execute_command("gh repo view --json owner,name --jq '{owner: .owner.login, name: .name}'")
    if not success or not output then
        return nil, nil, "Failed to get repository info. Is this a GitHub repository?"
    end
    
    local ok, decoded = pcall(vim.json.decode, output)
    if not ok or not decoded or not decoded.owner or not decoded.name then
        return nil, nil, "Invalid repository info"
    end
    
    return decoded.owner, decoded.name, nil
end

-- Helper: Detect PR number for current branch
local function detect_pr()
    -- Get current branch
    local branch_output, success = execute_command("git rev-parse --abbrev-ref HEAD")
    if not success or not branch_output then
        notify_error("Not in a git repository")
        return nil
    end
    
    local branch = vim.trim(branch_output)
    
    -- Check for PR using gh CLI
    local pr_output, pr_success = execute_command("gh pr view --json number,headRefName")
    if not pr_success or not pr_output then
        notify_error("No PR found for branch: " .. branch)
        return nil
    end
    
    -- Parse JSON
    local ok, pr_data = pcall(vim.json.decode, pr_output)
    if not ok or not pr_data or not pr_data.number then
        notify_error("Failed to parse PR data")
        return nil
    end
    
    return pr_data.number
end

-- Transform GraphQL response to our ThreadData structure
local function transform_graphql_to_threads(graphql_threads)
    local threads_by_file = {}
    
    for _, gql_thread in ipairs(graphql_threads) do
        -- Use line if available, fallback to originalLine for outdated comments
        local line_num = gql_thread.line or gql_thread.originalLine
        
        -- Skip threads without a line number
        if not line_num then
            goto continue
        end
        
        -- Build ThreadData structure
        local thread = {
            id = gql_thread.id,
            file = gql_thread.path,
            line = line_num,
            resolved = gql_thread.isResolved or false,
            outdated = gql_thread.isOutdated or false,
            comments = {}
        }
        
        -- Map comments
        local gql_comments = gql_thread.comments and gql_thread.comments.nodes or {}
        for _, gql_comment in ipairs(gql_comments) do
            table.insert(thread.comments, {
                id = tostring(gql_comment.databaseId or ""),
                user = gql_comment.author and gql_comment.author.login or "unknown",
                body = gql_comment.body or "",
                created_at = gql_comment.createdAt or "",
            })
        end
        
        -- Initialize nested structure if needed
        if not threads_by_file[thread.file] then
            threads_by_file[thread.file] = {}
        end
        if not threads_by_file[thread.file][thread.line] then
            threads_by_file[thread.file][thread.line] = {}
        end
        
        -- Add thread
        table.insert(threads_by_file[thread.file][thread.line], thread)
        
        ::continue::
    end
    
    return threads_by_file
end

-- Fetch PR review threads using GitHub GraphQL API
local function fetch_pr_comments_graphql(owner, repo, pr_number)
    -- Build GraphQL query (single line to avoid escaping issues)
    local query = string.format(
        '{ repository(owner: "%s", name: "%s") { pullRequest(number: %d) { reviewThreads(first: 100) { nodes { id isResolved isOutdated line originalLine path comments(first: 50) { nodes { databaseId body author { login } createdAt } } } } } } }',
        owner, repo, pr_number
    )
    
    -- Execute GraphQL query
    local cmd = string.format("gh api graphql -f query='%s'", query)
    local output, success = execute_command(cmd)
    
    if not success or not output then
        notify_error("Failed to fetch PR comments. Is 'gh' authenticated? Try: gh auth login")
        return nil
    end
    
    -- Parse JSON
    local ok, result = pcall(vim.json.decode, output)
    if not ok or not result then
        notify_error("Failed to parse GitHub API response")
        return nil
    end
    
    -- Check for GraphQL errors
    if result.errors then
        local error_msg = result.errors[1] and result.errors[1].message or "Unknown GraphQL error"
        notify_error("GitHub API error: " .. error_msg)
        return nil
    end
    
    -- Validate response structure
    local pr_data = result.data and result.data.repository and result.data.repository.pullRequest
    if not pr_data then
        notify_error("Could not access PR data. Check repository and PR access.")
        return nil
    end
    
    -- Extract threads
    local graphql_threads = pr_data.reviewThreads and pr_data.reviewThreads.nodes or {}
    
    -- Transform to our data structure
    return transform_graphql_to_threads(graphql_threads)
end

-- ============================================================================
-- DATA LOADING
-- ============================================================================

-- Load comments (fake data or real GitHub API)
local function load_comments()
    if config.use_fake_data then
        notify_info("Loaded fake PR comments", "✓")
        state.threads = generate_fake_data()
        state.pr_number = 12345
        return true
    end
    
    -- Real GitHub API
    notify_info("Loading PR comments...", "")
    
    -- Get repo info
    local owner, repo, err = get_repo_info()
    if err then
        notify_error(err)
        return false
    end
    
    -- Detect PR number
    local pr_number = detect_pr()
    if not pr_number then
        return false
    end
    
    -- Fetch via GraphQL
    local threads = fetch_pr_comments_graphql(owner, repo, pr_number)
    if not threads then
        return false
    end
    
    -- Store in state
    state.threads = threads
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

    -- Refresh all visible buffers
    for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_valid(bufnr) and vim.api.nvim_buf_is_loaded(bufnr) then
            show_comments_for_buffer(bufnr)
        end
    end

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

    -- Refresh all visible buffers
    for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_valid(bufnr) and vim.api.nvim_buf_is_loaded(bufnr) then
            show_comments_for_buffer(bufnr)
        end
    end

    local status = state.show_outdated and "shown" or "hidden"
    notify_info("Outdated threads now " .. status, "✓")
end

-- ============================================================================
-- FLOATING WINDOW - View Thread Details
-- ============================================================================

-- Get floating window configuration
local function get_thread_window_config()
    local width = math.floor(vim.o.columns * 0.6)
    local height = math.floor(vim.o.lines * 0.6)
    local row = math.floor((vim.o.lines - height) / 2)
    local col = math.floor((vim.o.columns - width) / 2)

    return {
        style = "minimal",
        relative = "editor",
        width = width,
        height = height,
        row = row,
        col = col,
        border = "rounded",
    }
end

-- Format timestamp for display
local function format_timestamp(timestamp)
    -- Input: "2026-02-04T23:16:37Z"
    -- Output: "2026-02-04 23:16"
    local date, time = timestamp:match("(%d%d%d%d%-%d%d%-%d%d)T(%d%d:%d%d)")
    if date and time then
        return date .. " " .. time
    end
    return timestamp
end

-- Format a single thread for floating window display
local function format_thread_for_window(thread)
    local lines = {}
    local highlights = {}

    -- Header separator
    table.insert(lines, "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    table.insert(highlights, { line = #lines - 1, hl = "Comment" })

    -- Blank line
    table.insert(lines, "")

    -- Status (resolved takes precedence)
    local status_text, status_hl
    if thread.resolved then
        status_text = "✓ Resolved"
        status_hl = "DiagnosticOk"
    elseif thread.outdated then
        status_text = "⚠️  Outdated (code changed)"
        status_hl = "Comment"
    else
        status_text = "❗ Unresolved"
        status_hl = "DiagnosticWarn"
    end
    
    local status_line = "Status: " .. status_text
    table.insert(lines, status_line)
    table.insert(highlights, { 
        line = #lines - 1, 
        col_start = 0, 
        col_end = 7, 
        hl = "Title" 
    })
    table.insert(highlights, { 
        line = #lines - 1, 
        col_start = 8, 
        col_end = #status_line, 
        hl = status_hl
    })

    -- File path
    local file_line = "File: " .. thread.file
    table.insert(lines, file_line)
    table.insert(highlights, { 
        line = #lines - 1, 
        col_start = 0, 
        col_end = 5, 
        hl = "Title" 
    })
    table.insert(highlights, { 
        line = #lines - 1, 
        col_start = 6, 
        col_end = #file_line, 
        hl = "Directory" 
    })

    -- Line number
    local line_line = "Line: " .. thread.line
    table.insert(lines, line_line)
    table.insert(highlights, { 
        line = #lines - 1, 
        col_start = 0, 
        col_end = 5, 
        hl = "Title" 
    })
    table.insert(highlights, { 
        line = #lines - 1, 
        col_start = 6, 
        col_end = #line_line, 
        hl = "Number" 
    })

    -- Blank line
    table.insert(lines, "")

    -- Comments
    for i, comment in ipairs(thread.comments) do
        -- Comment separator (lighter for replies)
        if i > 1 then
            table.insert(lines, "────────────────────────────────────────────────────────────────")
            table.insert(highlights, { line = #lines - 1, hl = "Comment" })
            table.insert(lines, "")
        end

        -- Comment header: icon + @user + timestamp
        local icon = i == 1 and "💬" or "  ↳"
        local header = icon .. " @" .. comment.user .. " • " .. format_timestamp(comment.created_at)
        table.insert(lines, header)
        
        -- Highlight username
        local user_start = #icon + 2
        local user_end = user_start + #comment.user
        table.insert(highlights, { 
            line = #lines - 1, 
            col_start = user_start, 
            col_end = user_end, 
            hl = "Function" 
        })
        
        -- Highlight timestamp
        local time_start = user_end + 3
        table.insert(highlights, { 
            line = #lines - 1, 
            col_start = time_start, 
            col_end = #header, 
            hl = "Comment" 
        })

        -- Blank line before body
        table.insert(lines, "")

        -- Comment body (split by newlines)
        local body_lines = vim.split(comment.body, "\n", { plain = true })
        for _, body_line in ipairs(body_lines) do
            table.insert(lines, body_line)
        end

        -- Blank line after body
        table.insert(lines, "")
    end

    -- Footer separator
    table.insert(lines, "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    table.insert(highlights, { line = #lines - 1, hl = "Comment" })

    -- Blank line
    table.insert(lines, "")

    -- Instructions
    local instructions = "Press 'q' or ESC to close"
    table.insert(lines, instructions)
    table.insert(highlights, { line = #lines - 1, hl = "Comment" })

    return lines, highlights
end

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

    -- Get threads for this file
    local file_threads = state.threads[rel_path]
    if not file_threads then
        return nil, "No comment threads in this file"
    end

    -- Get threads at cursor line
    local threads_at_line = file_threads[cursor_line]
    if not threads_at_line or #threads_at_line == 0 then
        return nil, "No comment thread on line " .. cursor_line
    end

    return threads_at_line, nil
end

-- Command: View thread at cursor in floating window
local function view_thread_at_cursor()
    ensure_setup()
    
    local threads, err = get_threads_at_cursor()
    if err then
        notify_info(err)
        return
    end

    -- For now, show only the first thread
    local thread = threads[1]

    -- Format thread content
    local lines, highlights = format_thread_for_window(thread)

    -- Create scratch buffer
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

    -- Set buffer options
    vim.api.nvim_buf_set_option(buf, "modifiable", false)
    vim.api.nvim_buf_set_option(buf, "bufhidden", "wipe")
    vim.api.nvim_buf_set_option(buf, "filetype", "pr-comment-thread")

    -- Open floating window
    local win_config = get_thread_window_config()
    local win = vim.api.nvim_open_win(buf, true, win_config)

    -- Set window options
    vim.api.nvim_win_set_option(win, "wrap", true)
    vim.api.nvim_win_set_option(win, "linebreak", true)

    -- Apply highlights
    local ns = vim.api.nvim_create_namespace("pr_comments_float")
    for _, hl in ipairs(highlights) do
        if hl.col_start and hl.col_end then
            -- Extmark with highlight
            vim.api.nvim_buf_add_highlight(buf, ns, hl.hl, hl.line, hl.col_start, hl.col_end)
        else
            -- Full line highlight
            vim.api.nvim_buf_add_highlight(buf, ns, hl.hl, hl.line, 0, -1)
        end
    end

    -- Set title
    local title = " Comment Thread - Line " .. thread.line .. " "
    if #threads > 1 then
        title = " Comment Threads - Line " .. thread.line .. " (showing 1 of " .. #threads .. ") "
    end
    vim.api.nvim_win_set_config(win, vim.tbl_extend("force", win_config, {
        title = title,
        title_pos = "center",
    }))

    -- Keymaps to close window
    local close_win = function()
        if vim.api.nvim_win_is_valid(win) then
            vim.api.nvim_win_close(win, true)
        end
    end

    vim.keymap.set("n", "q", close_win, { buffer = buf, nowait = true })
    vim.keymap.set("n", "<Esc>", close_win, { buffer = buf, nowait = true })
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
    
    -- Collect all threads with their location info
    for filepath, lines in pairs(state.threads) do
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
local function reset_thread_cursor()
    current_thread_index = nil
end

-- Jump to a specific thread location
local function jump_to_thread(item, direction)
    -- Get repo root to construct absolute path
    local handle = io.popen("git rev-parse --show-toplevel 2>&1")
    if not handle then
        notify_error("Failed to get repository root")
        return false
    end
    local repo_root = vim.trim(handle:read("*a"))
    handle:close()

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
        string.format("%s @%s: %s", status_icon, first_comment.user, preview),
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
        next = jump_to_next_thread,
        prev = jump_to_prev_thread,
    }
end

return M

-- PR Review API - GitHub CLI interactions
-- Handles fetching PR data, diffs, comments, and posting comments

local M = {}

-- Cache for PR data
local cache = {
  current_pr = nil,
  repo_info = nil,
}

---@class PRReview.RepoInfo
---@field owner string
---@field name string
---@field full_name string

---@class PRReview.PR
---@field number number
---@field title string
---@field state string
---@field author string
---@field head_ref string
---@field base_ref string
---@field head_sha string
---@field url string
---@field repo string
---@field pending_review_id string?

---@class PRReview.Comment
---@field id string
---@field database_id number
---@field author string
---@field body string
---@field created_at string
---@field path string?
---@field line number?
---@field start_line number?
---@field side string?
---@field diff_hunk string?
---@field reply_to_id string?
---@field reactions table[]?

---@class PRReview.ReviewThread
---@field id string
---@field is_resolved boolean
---@field is_outdated boolean
---@field path string
---@field line number?
---@field start_line number?
---@field diff_side string
---@field comments PRReview.Comment[]

---@class PRReview.Review
---@field id string
---@field database_id number
---@field author string
---@field state string
---@field body string?
---@field submitted_at string?
---@field comments PRReview.Comment[]

---@class PRReview.PRData
---@field pr PRReview.PR
---@field threads PRReview.ReviewThread[]
---@field reviews PRReview.Review[]
---@field pending_review PRReview.Review?
---@field diff_text string
---@field files PRReview.DiffFile[]

---@class PRReview.DiffFile
---@field path string
---@field additions number
---@field deletions number
---@field status string

-- Check if value is nil or vim.NIL (JSON null)
---@param val any
---@return boolean
local function is_nil(val)
  return val == nil or val == vim.NIL
end

-- Safe table access that handles vim.NIL
---@param tbl any
---@param key string
---@return any
local function safe_get(tbl, key)
  if is_nil(tbl) then
    return nil
  end
  local val = tbl[key]
  if val == vim.NIL then
    return nil
  end
  return val
end

-- Execute a shell command and return output
---@param cmd string
---@return string?, string?
local function exec(cmd)
  local handle = io.popen(cmd .. " 2>&1")
  if not handle then
    return nil, "Failed to execute command"
  end
  local result = handle:read("*a")
  local success = handle:close()
  if not success then
    return nil, result
  end
  return result, nil
end

-- Execute gh command with JSON output
---@param args string[]
---@param opts? {repo?: string, notify?: boolean}
---@return table?, string?
local function gh_json(args, opts)
  opts = opts or {}
  local cmd_parts = { "gh" }
  vim.list_extend(cmd_parts, args)

  if opts.repo then
    vim.list_extend(cmd_parts, { "--repo", opts.repo })
  end

  local cmd = table.concat(cmd_parts, " ")
  local output, err = exec(cmd)

  if err then
    if opts.notify ~= false then
      Snacks.notify.error("gh command failed: " .. err, { title = "PR Review" })
    end
    return nil, err
  end

  if not output or output == "" then
    return nil, "Empty response"
  end

  local ok, result = pcall(vim.json.decode, output)
  if not ok then
    return nil, "Failed to parse JSON: " .. tostring(result)
  end

  return result, nil
end

-- Execute gh command returning raw text
---@param args string[]
---@param opts? {repo?: string}
---@return string?, string?
local function gh_text(args, opts)
  opts = opts or {}
  local cmd_parts = { "gh" }
  vim.list_extend(cmd_parts, args)

  if opts.repo then
    vim.list_extend(cmd_parts, { "--repo", opts.repo })
  end

  local cmd = table.concat(cmd_parts, " ")
  return exec(cmd)
end

-- Execute gh api command with JSON input
---@param endpoint string
---@param input table?
---@param opts? {method?: string}
---@return table?, string?
local function gh_api(endpoint, input, opts)
  opts = opts or {}
  local method = opts.method or "POST"

  local cmd = string.format("gh api %s -X %s", endpoint, method)

  if input then
    cmd = cmd .. " --input -"
  end

  -- Use vim.fn.system for proper stdin handling
  local output
  if input then
    local json_input = vim.json.encode(input)
    output = vim.fn.system(cmd, json_input)
  else
    output = vim.fn.system(cmd)
  end

  if vim.v.shell_error ~= 0 then
    return nil, output
  end

  if not output or output == "" or not output:find("%S") then
    return {}, nil -- Empty but successful
  end

  local ok, result = pcall(vim.json.decode, output)
  if not ok then
    return nil, "Failed to parse JSON: " .. output:sub(1, 200)
  end

  return result, nil
end

-- Execute GraphQL query
---@param query string
---@param variables table
---@return table?, string?
local function gh_graphql(query, variables)
  local input = {
    query = query,
    variables = variables,
  }

  local result, err = gh_api("graphql", input)
  if err then
    return nil, err
  end

  if result.errors then
    local msg = result.errors[1] and result.errors[1].message or "Unknown GraphQL error"
    return nil, msg
  end

  return result.data, nil
end

-- Get repository info
---@return PRReview.RepoInfo?, string?
function M.get_repo_info()
  if cache.repo_info then
    return cache.repo_info, nil
  end

  local result, err = gh_json({ "repo", "view", "--json", "owner,name,nameWithOwner" }, { notify = false })
  if err then
    return nil, "Not in a GitHub repository or gh not authenticated"
  end

  cache.repo_info = {
    owner = result.owner.login,
    name = result.name,
    full_name = result.nameWithOwner,
  }

  return cache.repo_info, nil
end

-- Detect the current PR from the branch
---@return PRReview.PR?, string?
function M.get_current_pr()
  local result, err = gh_json({
    "pr",
    "view",
    "--json",
    "number,title,state,author,headRefName,baseRefName,headRefOid,url",
  }, { notify = false })

  if err then
    return nil, "No PR found for current branch"
  end

  local repo_info = M.get_repo_info()

  ---@type PRReview.PR
  local pr = {
    number = result.number,
    title = result.title,
    state = result.state:lower(),
    author = result.author.login,
    head_ref = result.headRefName,
    base_ref = result.baseRefName,
    head_sha = result.headRefOid,
    url = result.url,
    repo = repo_info and repo_info.full_name or "",
  }

  cache.current_pr = pr
  return pr, nil
end

-- Get PR by number
---@param pr_number number
---@param repo? string
---@return PRReview.PR?, string?
function M.get_pr(pr_number, repo)
  local result, err = gh_json({
    "pr",
    "view",
    tostring(pr_number),
    "--json",
    "number,title,state,author,headRefName,baseRefName,headRefOid,url",
  }, { repo = repo })

  if err then
    return nil, "Failed to fetch PR #" .. pr_number
  end

  ---@type PRReview.PR
  local pr = {
    number = result.number,
    title = result.title,
    state = result.state:lower(),
    author = result.author.login,
    head_ref = result.headRefName,
    base_ref = result.baseRefName,
    head_sha = result.headRefOid,
    url = result.url,
    repo = repo or (M.get_repo_info() or {}).full_name or "",
  }

  return pr, nil
end

-- Fetch PR diff as text
---@param pr_number number
---@param repo? string
---@return string?, string?
function M.fetch_diff(pr_number, repo)
  local args = { "pr", "diff", tostring(pr_number) }
  return gh_text(args, { repo = repo })
end

-- Parse diff to extract file list
---@param diff_text string
---@return PRReview.DiffFile[]
function M.parse_diff_files(diff_text)
  local files = {}
  local current_file = nil
  local additions = 0
  local deletions = 0

  for line in diff_text:gmatch("[^\n]+") do
    -- New file header
    local file = line:match("^diff %-%-git a/(.-) b/")
    if file then
      -- Save previous file
      if current_file then
        table.insert(files, {
          path = current_file,
          additions = additions,
          deletions = deletions,
          status = additions > 0 and deletions > 0 and "modified"
            or additions > 0 and "added"
            or deletions > 0 and "deleted"
            or "modified",
        })
      end
      current_file = file
      additions = 0
      deletions = 0
    elseif current_file then
      -- Count additions/deletions
      if line:match("^%+[^%+]") then
        additions = additions + 1
      elseif line:match("^%-[^%-]") then
        deletions = deletions + 1
      end
    end
  end

  -- Don't forget the last file
  if current_file then
    table.insert(files, {
      path = current_file,
      additions = additions,
      deletions = deletions,
      status = additions > 0 and deletions > 0 and "modified"
        or additions > 0 and "added"
        or deletions > 0 and "deleted"
        or "modified",
    })
  end

  return files
end

-- Fetch review threads and comments via GraphQL
---@param pr PRReview.PR
---@return PRReview.ReviewThread[], PRReview.Review[], PRReview.Review?
function M.fetch_comments(pr)
  local owner, name = pr.repo:match("^(.-)/(.-)$")
  if not owner or not name then
    Snacks.notify.error("Invalid repo format", { title = "PR Review" })
    return {}, {}, nil
  end

  local query = [[
    query($owner: String!, $name: String!, $number: Int!) {
      repository(owner: $owner, name: $name) {
        pullRequest(number: $number) {
          reviewThreads(first: 100) {
            nodes {
              id
              isResolved
              isOutdated
              path
              line
              startLine
              diffSide
              comments(first: 50) {
                nodes {
                  id
                  databaseId
                  body
                  author { login }
                  createdAt
                  replyTo { id databaseId }
                  reactionGroups {
                    content
                    users { totalCount }
                  }
                }
              }
            }
          }
          reviews(first: 100) {
            nodes {
              id
              databaseId
              author { login }
              state
              body
              submittedAt
              createdAt
              viewerDidAuthor
              comments(first: 50) {
                nodes {
                  id
                  databaseId
                  body
                  path
                  diffHunk
                  line
                  startLine
                  originalLine
                  originalStartLine
                  author { login }
                  createdAt
                  replyTo { id databaseId }
                  reactionGroups {
                    content
                    users { totalCount }
                  }
                }
              }
            }
          }
        }
      }
    }
  ]]

  local data, err = gh_graphql(query, {
    owner = owner,
    name = name,
    number = pr.number,
  })

  if err then
    Snacks.notify.error("Failed to fetch comments: " .. err, { title = "PR Review" })
    return {}, {}, nil
  end

  local pr_data = data.repository.pullRequest
  local threads = {} ---@type PRReview.ReviewThread[]
  local reviews = {} ---@type PRReview.Review[]
  local pending_review = nil ---@type PRReview.Review?

  -- Process review threads
  for _, thread in ipairs(pr_data.reviewThreads.nodes or {}) do
    local comments = {} ---@type PRReview.Comment[]
    for _, c in ipairs(thread.comments.nodes or {}) do
      local author = safe_get(c, "author")
      local reply_to = safe_get(c, "replyTo")
      table.insert(comments, {
        id = c.id,
        database_id = c.databaseId,
        author = author and author.login or "unknown",
        body = safe_get(c, "body") or "",
        created_at = c.createdAt,
        reply_to_id = reply_to and reply_to.id or nil,
        reactions = safe_get(c, "reactionGroups"),
      })
    end

    table.insert(threads, {
      id = thread.id,
      is_resolved = thread.isResolved or false,
      is_outdated = thread.isOutdated or false,
      path = safe_get(thread, "path"),
      line = safe_get(thread, "line"),
      start_line = safe_get(thread, "startLine"),
      diff_side = (safe_get(thread, "diffSide") or "RIGHT"):lower(),
      comments = comments,
    })
  end

  -- Process reviews
  for _, review in ipairs(pr_data.reviews.nodes or {}) do
    local comments = {} ---@type PRReview.Comment[]
    for _, c in ipairs(review.comments.nodes or {}) do
      local author = safe_get(c, "author")
      local reply_to = safe_get(c, "replyTo")
      table.insert(comments, {
        id = c.id,
        database_id = c.databaseId,
        author = author and author.login or "unknown",
        body = safe_get(c, "body") or "",
        created_at = c.createdAt,
        path = safe_get(c, "path"),
        line = safe_get(c, "line") or safe_get(c, "originalLine"),
        start_line = safe_get(c, "startLine") or safe_get(c, "originalStartLine"),
        diff_hunk = safe_get(c, "diffHunk"),
        reply_to_id = reply_to and reply_to.id or nil,
        reactions = safe_get(c, "reactionGroups"),
      })
    end

    local review_author = safe_get(review, "author")
    local r = {
      id = review.id,
      database_id = review.databaseId,
      author = review_author and review_author.login or "unknown",
      state = safe_get(review, "state") or "COMMENTED",
      body = safe_get(review, "body"),
      submitted_at = safe_get(review, "submittedAt") or safe_get(review, "createdAt"),
      comments = comments,
    }

    if r.state == "PENDING" and review.viewerDidAuthor then
      pending_review = r
    else
      table.insert(reviews, r)
    end
  end

  return threads, reviews, pending_review
end

-- Get file content at a specific ref
---@param file_path string
---@param ref string
---@return string?, string?
function M.get_file_at_ref(file_path, ref)
  local output, err = exec(string.format("git show %s:%s 2>/dev/null", ref, file_path))
  if err then
    return nil, err
  end
  return output, nil
end

-- Post a general comment on the PR (issue comment, not review comment)
---@param pr PRReview.PR
---@param body string
---@return boolean, string?
function M.post_comment(pr, body)
  local endpoint = string.format("/repos/%s/issues/%d/comments", pr.repo, pr.number)
  local result, err = gh_api(endpoint, { body = body })

  if err then
    return false, err
  end

  return true, nil
end

-- Start a new review
---@param pr PRReview.PR
---@return string?, string? -- review_id, error
function M.start_review(pr)
  local endpoint = string.format("/repos/%s/pulls/%d/reviews", pr.repo, pr.number)
  local result, err = gh_api(endpoint, { commit_id = pr.head_sha })

  if err then
    return nil, err
  end

  return tostring(result.id), nil
end

-- Add a comment to a pending review using GraphQL
---@param pr PRReview.PR
---@param review_id string
---@param opts {path: string, line: number, side: string, body: string, start_line?: number}
---@return boolean, string?
function M.add_review_comment(pr, review_id, opts)
  local query = [[
    mutation($reviewId: ID!, $body: String!, $path: String!, $line: Int!, $side: DiffSide!, $startLine: Int, $startSide: DiffSide) {
      addPullRequestReviewThread(input: {
        pullRequestReviewId: $reviewId
        body: $body
        path: $path
        line: $line
        side: $side
        startLine: $startLine
        startSide: $startSide
      }) {
        thread { id }
      }
    }
  ]]

  local variables = {
    reviewId = review_id,
    body = opts.body,
    path = opts.path,
    line = opts.line,
    side = opts.side:upper(),
    startLine = opts.start_line,
    startSide = opts.start_line and opts.side:upper() or nil,
  }

  local _, err = gh_graphql(query, variables)
  if err then
    return false, err
  end

  return true, nil
end

-- Post an immediate line comment (not part of a review)
---@param pr PRReview.PR
---@param opts {path: string, line: number, side: string, body: string, start_line?: number}
---@return boolean, string?
function M.post_line_comment(pr, opts)
  local endpoint = string.format("/repos/%s/pulls/%d/comments", pr.repo, pr.number)

  local input = {
    commit_id = pr.head_sha,
    path = opts.path,
    line = opts.line,
    side = opts.side:upper(),
    body = opts.body,
  }

  if opts.start_line then
    input.start_line = opts.start_line
    input.start_side = opts.side:upper()
  end

  local _, err = gh_api(endpoint, input)
  if err then
    return false, err
  end

  return true, nil
end

-- Reply to a comment thread
---@param pr PRReview.PR
---@param comment_id number -- database ID of the comment to reply to
---@param body string
---@param thread_id string? -- GraphQL node ID of the thread (for pending review replies)
---@return boolean, string?
function M.reply_to_comment(pr, comment_id, body, thread_id)
  -- If we have the thread ID, use GraphQL mutation (works with pending reviews)
  if thread_id then
    local query = [[
      mutation($threadId: ID!, $body: String!) {
        addPullRequestReviewThreadReply(input: {
          pullRequestReviewThreadId: $threadId
          body: $body
        }) {
          comment { id }
        }
      }
    ]]

    local _, err = gh_graphql(query, {
      threadId = thread_id,
      body = body,
    })

    if err then
      return false, err
    end
    return true, nil
  end

  -- Fallback: No thread ID - use REST API direct reply endpoint
  local endpoint = string.format("/repos/%s/pulls/%d/comments/%d/replies", pr.repo, pr.number, comment_id)

  local _, err = gh_api(endpoint, { body = body })
  if err then
    return false, err
  end

  return true, nil
end

-- Submit a pending review
---@param pr PRReview.PR
---@param review_id string
---@param event "APPROVE"|"REQUEST_CHANGES"|"COMMENT"
---@param body? string
---@return boolean, string?
function M.submit_review(pr, review_id, event, body)
  local endpoint = string.format("/repos/%s/pulls/%d/reviews/%s/events", pr.repo, pr.number, review_id)

  local input = { event = event }
  if body and body ~= "" then
    input.body = body
  end

  local _, err = gh_api(endpoint, input)
  if err then
    return false, err
  end

  return true, nil
end

-- Clear cache
function M.clear_cache()
  cache.current_pr = nil
  cache.repo_info = nil
end

return M

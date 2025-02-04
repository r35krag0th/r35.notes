-- TODO: Refactor this mess to separate config and runtime code.  While functional... this is gross.
-- TODO: Documentation (README + Code)
local MiniPick = require("mini.pick")

local M = {}

---@class r35NotesKeymap
---@field yesterday string
---@field today string
---@field tomorrow string
---@field find string
---@field grep string
---@field previous_no_skip string
---@field previous_with_skip string
---@field next_no_skip string
---@field next_with_skip string

---@class r35NotesOptions
---@field root string
---@field keymap r35NotesKeymap
M.opts = {
  root = os.getenv("HOME") .. "/notes",
  keymap = {
    yesterday = "<localleader>ny",
    today = "<localleader>nd",
    tomorrow = "<localleader>nt",
    previous_no_skip = "<localleader>np",
    previous_with_skip = "<localleader>nP",
    next_no_skip = "<localleader>nn",
    next_with_skip = "<localleader>nN",
    find = "<localleader>nf",
    grep = "<localleader>ng",
  },
}

---Convert a string into a keymap string.
local keymap_string = function(input)
  return string.format("<Cmd>%s<CR>", input)
end

---Internal options for the plugin.
---@class r35NotesLocalOptions
---@field commands r35NotesKeymap
local local_opts = {
  commands = {
    today = "RNToday",
    yesterday = "RNYesterday",
    tomorrow = "RNTomorrow",
    previous_no_skip = "RNPrevious",
    previous_with_skip = "RNPreviousSkipEmpty",
    next_no_skip = "RNNext",
    next_with_skip = "RNNextSkipEmpty",
    find = "RNFind",
    grep = "RNGrep",
  },
}

---Find files in the notes directory using mini.pick
---@return nil
local find_files = function()
  MiniPick.builtin.files({}, {
    source = {
      name = "r35 Notes (find)",
      cwd = M.opts.root,
    },
  })
end

---Grep files in the notes directory using mini.pick
---@return nil
local grep_for = function()
  MiniPick.builtin.grep_live({}, {
    source = {
      name = "r35 Notes (grep)",
      cwd = M.opts.root,
    },
  })
end

---Open the journal entry for a given date.
---
---@param date string|osdate
---@return nil
local date_to_journal = function(date)
  if date == nil then
    date = os.date("*t")
  end

  local journal_path = vim.fs.joinpath(
    M.opts.root,
    "journal",
    date.year,
    string.format("%02d", date.month),
    string.format("%02d.md", date.day)
  )
  vim.cmd.edit(journal_path)
end

---Find the nearest weekday to the current date starting with `days` offset.
---@param days integer
---@param start_at integer|nil
local relative_to_journal = function(days, start_at)
  if start_at == nil then
    start_at = os.time()
  end

  start_at = start_at + ((24 * 60 * 60) * days)
  local d = os.date("*t", start_at)
  while d.wday == 1 or d.wday == 7 do
    -- roll another day
    if days <= 0 then
      start_at = start_at - (24 * 60 * 60)
    else
      start_at = start_at + (24 * 60 * 60)
    end
    d = os.date("*t", start_at)
  end

  date_to_journal(d)
end

M.config = function() end

---Open the picker and begin finding files
---@return nil
M.find = function()
  find_files()
end

---Open the picker and begin grepping
---@return nil
M.grep = function()
  grep_for()
end

---Open the journal entry for today.
---@return nil
M.goto_today = function()
  relative_to_journal(0)
end

---Open the journal entry for yesterday.
---@return nil
M.goto_yesterday = function()
  relative_to_journal(-1)
end

---Open the journal entry for tomorrow.
---@return nil
M.goto_tomorrow = function()
  relative_to_journal(1)
end

---Setup the plugin.
---@param opts r35NotesOptions
M.setup = function(opts)
  -- If nothing was passed then use defaults.
  opts = opts or {}

  -- Merge the user options with the defaults.
  M.opts = vim.tbl_deep_extend("force", M.opts, opts)

  -- TODO: vim.loop is going away in 1.0, what is the right way to do this?
  local success, err, err_name = vim.loop.fs_mkdir(M.opts.root, 493)

  -- The directory existing is fine.  Otherwise we have a problem.
  if not success and not err_name == "EEXIST" then
    vim.print("Oh sugar: " .. err .. " (" .. err_name .. ")")
    return
  end

  -- Setup the User Commands
  vim.api.nvim_create_user_command(local_opts.commands.yesterday, M.goto_yesterday, {
    nargs = 0,
    desc = "Open yesterday's journal",
  })
  vim.api.nvim_create_user_command(local_opts.commands.today, M.goto_today, {
    nargs = 0,
    desc = "Open today's journal",
  })
  vim.api.nvim_create_user_command(local_opts.commands.tomorrow, M.goto_tomorrow, {
    nargs = 0,
    desc = "Open tomorrow's journal",
  })
  vim.api.nvim_create_user_command(local_opts.commands.find, M.find, {
    nargs = 0,
    desc = "Find a journal file",
  })
  vim.api.nvim_create_user_command(local_opts.commands.grep, M.grep, {
    nargs = 0,
    desc = "Grep through journals",
  })
  vim.api.nvim_create_user_command(local_opts.commands.previous_no_skip, M.goto_previous_day, {
    nargs = 0,
    desc = "Previous journal relative to the current buffer",
  })
  -- vim.api.nvim_create_user_command(local_opts.commands.previous_with_skip, M.goto_previous_day, { nargs = 0 })
  vim.api.nvim_create_user_command(local_opts.commands.next_no_skip, M.goto_next_day, {
    nargs = 0,
    desc = "Next journal relative to the current buffer",
  })
  -- vim.api.nvim_create_user_command(local_opts.commands.next_with_skip, M.goto_next_day, { nargs = 0 })

  -- Setup Keymaps
  -- for i, v in pairs(M.opts.keymap) do
  --   vim.api.nvim_set_keymap("n", v, keymap_string(local_opts.commands[i]), {})
  -- end
end

local current_file = function()
  local absolute_path = vim.api.nvim_buf_get_name(0)
  local match = absolute_path:match("(?P<year>d+)[/\\](?P<month>d+)[/\\](?P<day>d+).md$")

  if match then
    return {
      year = tonumber(match.year),
      month = tonumber(match.month),
      day = tonumber(match.day),
    }
  end

  return ""
end

M.goto_previous_day = function()
  local current = current_file()
  if current == "" then
    vim.notify("The current file doesn't seem to be a journal file.")
    return
  end

  local previous = os.time({
    year = current.year,
    month = current.month,
    day = current.day,
    hour = 0,
    min = 0,
    sec = 0,
  }) - (24 * 60 * 60)

  relative_to_journal(-1, previous)
end

M.goto_next_day = function()
  local current = current_file()
  if current == "" then
    vim.notify("The current file doesn't seem to be a journal file.")
    return
  end

  local next = os.time({
    year = current.year,
    month = current.month,
    day = current.day,
    hour = 0,
    min = 0,
    sec = 0,
  }) + (24 * 60 * 60)

  relative_to_journal(1, next)
end

return M

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

---@class r35NotesOptions
---@field root string
---@field keymap r35NotesKeymap
M.opts = {
  root = os.getenv("HOME") .. "/notes",
  keymap = {
    yesterday = "<localleader>ny",
    today = "<localleader>nd",
    tomorrow = "<localleader>nt",
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
---@field today_command string
---@field yesterday_command string
---@field tomorrow_command string
---@field find_command string
---@field grep_command string
local local_opts = {
  today_command = "RNToday",
  yesterday_command = "RNYesterday",
  tomorrow_command = "RNTomorrow",
  find_command = "RNFind",
  grep_command = "RNGrep",
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
---@param days number
local relative_to_journal = function(days)
  local now = os.time()
  now = now + ((24 * 60 * 60) * days)
  local d = os.date("*t", now)
  while d.wday == 1 or d.wday == 7 do
    -- roll another day
    if days <= 0 then
      now = now - (24 * 60 * 60)
    else
      now = now + (24 * 60 * 60)
    end
    d = os.date("*t", now)
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
  vim.api.nvim_create_user_command(local_opts.yesterday_command, M.goto_yesterday, { nargs = 0 })
  vim.api.nvim_create_user_command(local_opts.today_command, M.goto_today, { nargs = 0 })
  vim.api.nvim_create_user_command(local_opts.tomorrow_command, M.goto_tomorrow, { nargs = 0 })
  vim.api.nvim_create_user_command(local_opts.find_command, M.find, { nargs = 0 })
  vim.api.nvim_create_user_command(local_opts.grep_command, M.grep, { nargs = 0 })

  -- Setup Keymaps
  -- TODO: Make these use callback.
  vim.api.nvim_set_keymap("n", M.opts.keymap.yesterday, keymap_string(local_opts.yesterday_command), {})
  vim.api.nvim_set_keymap("n", M.opts.keymap.today, keymap_string(local_opts.today_command), {})
  vim.api.nvim_set_keymap("n", M.opts.keymap.tomorrow, keymap_string(local_opts.tomorrow_command), {})
  vim.api.nvim_set_keymap("n", M.opts.keymap.find, keymap_string(local_opts.find_command), {})
  vim.api.nvim_set_keymap("n", M.opts.keymap.grep, keymap_string(local_opts.grep_command), {})
end

return M

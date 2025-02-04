return {
  "r35krag0th/r35.notes",
  lazy = false,
  dependencies = {
    "nvim-telescope/telescope.nvim",
    "echasnovski/mini.pick",
  },
  keys = {
    { "<localleader>nd", "<Cmd>RNToday<CR>", desc = "Go to Today" },
    { "<localleader>ny", "<Cmd>RNYesterday<CR>", desc = "Go to Yesterday" },
    { "<localleader>nt", "<Cmd>RNTomorrow<CR>", desc = "Go to Tomorrow" },
    { "<localleader>ng", "<Cmd>RNGrep<CR>", desc = "Grep Notes" },
    { "<localleader>nf", "<Cmd>RNFind<CR>", desc = "Find Note" },
    { "<localleader>np", "<Cmd>RNPrevious<CR>", desc = "Go to Previous Note" },
    { "<localleader>nP", "<Cmd>RNPreviousSkipEmpty<CR>", desc = "Go to Previous Note (Skip Empty)" },
    { "<localleader>nn", "<Cmd>RNNext<CR>", desc = "Go to Next Note" },
    { "<localleader>nN", "<Cmd>RNNextSkipEmpty<CR>", desc = "Go to Next Note (Skip Empty)" },
  },
}

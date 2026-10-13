-- Settings that add horizontal gutter columns, interfering with terminal copy-paste.
-- Add or remove entries here to control what CopyModeEnable/CopyModeDisable toggles.
local gutter_settings = {
  {
    name = "number",
    get = function() return vim.opt.number:get() end,
    set = function(v) vim.opt.number = v end,
    off = false,
  },
  {
    name = "relativenumber",
    get = function() return vim.opt.relativenumber:get() end,
    set = function(v) vim.opt.relativenumber = v end,
    off = false,
  },
  {
    name = "signcolumn",
    get = function() return vim.opt.signcolumn:get() end,
    set = function(v) vim.opt.signcolumn = v end,
    off = "no",
  },
  {
    name = "foldcolumn",
    get = function() return vim.opt.foldcolumn:get() end,
    set = function(v) vim.opt.foldcolumn = v end,
    off = "0",
  },
}

return {
  "copymode",
  virtual = true,
  config = function()
    local saved = {}

    local function disable_gutters()
      saved = {}
      for _, s in ipairs(gutter_settings) do
        saved[s.name] = s.get()
        s.set(s.off)
      end
      vim.notify("Gutters hidden (copy mode)", vim.log.levels.INFO)
    end

    local function restore_gutters()
      if vim.tbl_isempty(saved) then
        vim.notify("No saved gutter state to restore", vim.log.levels.WARN)
        return
      end
      for _, s in ipairs(gutter_settings) do
        if saved[s.name] ~= nil then
          s.set(saved[s.name])
        end
      end
      saved = {}
      vim.notify("Gutters restored", vim.log.levels.INFO)
    end

    vim.api.nvim_create_user_command("CopyModeEnable", disable_gutters, { desc = "Hide gutter columns for terminal copy-paste" })
    vim.api.nvim_create_user_command("CopyModeDisable", restore_gutters, { desc = "Restore gutter columns after terminal copy-paste" })
  end,
}

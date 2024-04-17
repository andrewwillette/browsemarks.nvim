local config = {}
-- Default configuration for the plugin.
---@type BrowsemarksConfig
local defaults = {
  selected_browser = "brave",
  profile_name = nil,
  config_dir = nil,
  full_path = true,
  url_open_command = "open",
  url_open_plugin = nil,
  buku_include_tags = false,
  debug = false,
}

---@type BrowsemarksConfig
config.values = {}

function config.setup(opts)
  config.values = vim.tbl_extend("force", {}, defaults, opts or {})
end

return config

---@mod browsemarks Plugin for adding a bookmark to a chromium browser.

---@class BrowsemarksConfig
---@field full_path? boolean
---@field selected_browser Browser
---@field url_open_command? string
---@field url_open_plugin? 'open_browser'|'vim_external'
---@field profile_name? string
---@field buku_include_tags? boolean
---@field config_dir? string
---@field debug? boolean

---@class Bookmark
---@field name string Bookmark name
---@field path string Full path from root to the name separated by '/'
---@field url string Bookmark URL
---@field tags? string Comma separated tags (only for buku)
---@field children? Bookmark[] Children bookmarks

---@class Browsemarks
local M = {}

local config = require("browsemarks.config")
local chromium = require("browsemarks.browsers.chromium")

--- Setup function for the plugin.
--- Currently support selected_browser for 'brave' and 'chrome'
---@param opts? BrowsemarksConfig
function M.setup(opts)
  config.setup(opts)
end

function M.add_bookmark()
  chromium.new_bookmark()
end

return M

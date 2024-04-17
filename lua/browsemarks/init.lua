local M = {}

local config = require("browsemarks.config")
local chromium = require("browsemarks.browsers.chromium")

-- TODO: Make this configurable
local selectedbrowser = "brave"

local chromium = require("browsemarks.browsers.chromium")

-- Setup function for the plugin.
---@param opts? BrowsemarksConfig
function M.setup(opts)
  config.setup(opts)
end

function M.add_bookmark()
  local bookmarks = chromium.collect_bookmarks(config.values)
  -- pretty print bookmarks
  for _, bookmark in ipairs(bookmarks) do
    print(bookmark.path, bookmark.url)
  end
end

return M
